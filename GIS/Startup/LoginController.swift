//
//  LoginController.swift
//  GIS
//
//  Created by Apple Hawkscode on 16/10/20.
//

import UIKit
import AVFoundation
import SafariServices
import Alamofire
import Security


/// Frosted blur with different top (34pt) and bottom (58pt) corner radii, for iOS versions without Liquid Glass.
private final class StoreCardBlurView: UIVisualEffectView {
    private let cornerMask = CAShapeLayer()

    override func layoutSubviews() {
        super.layoutSubviews()
        let rect = bounds
        let top: CGFloat = 34, bottom: CGFloat = 58
        let path = UIBezierPath()
        path.move(to: CGPoint(x: rect.minX + top, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - top, y: rect.minY))
        path.addArc(withCenter: CGPoint(x: rect.maxX - top, y: rect.minY + top), radius: top,
                    startAngle: -.pi / 2, endAngle: 0, clockwise: true)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - bottom))
        path.addArc(withCenter: CGPoint(x: rect.maxX - bottom, y: rect.maxY - bottom), radius: bottom,
                    startAngle: 0, endAngle: .pi / 2, clockwise: true)
        path.addLine(to: CGPoint(x: rect.minX + bottom, y: rect.maxY))
        path.addArc(withCenter: CGPoint(x: rect.minX + bottom, y: rect.maxY - bottom), radius: bottom,
                    startAngle: .pi / 2, endAngle: .pi, clockwise: true)
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + top))
        path.addArc(withCenter: CGPoint(x: rect.minX + top, y: rect.minY + top), radius: top,
                    startAngle: .pi, endAngle: -.pi / 2, clockwise: true)
        path.close()
        cornerMask.path = path.cgPath
        layer.mask = cornerMask
    }
}

public class StoreItem: UITableViewCell {
    
    @IBOutlet weak var mStoreName: UILabel!
    @IBOutlet weak var mStoreDomain: UILabel!
    @IBOutlet weak var mSelect: UIButton!
    public override func awakeFromNib() {
        super.awakeFromNib()
        styleForGlassSheet()
    }
    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    /// Rows sit directly on the glass sheet: transparent, name on the left and the
    /// domain on the right (the storyboard splits the row into two equal white halves).
    private func styleForGlassSheet() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        clearBackgrounds(in: contentView)

        guard let nameContainer = mStoreName.superview,
              let domainContainer = mStoreDomain.superview else { return }
        (nameContainer.superview as? UIStackView)?.distribution = .fill
        (nameContainer.superview as? UIStackView)?.spacing = 8
        // The fixed 40pt container heights would fight the 48pt row.
        [nameContainer, domainContainer].forEach { container in
            container.constraints
                .filter { $0.firstAttribute == .height && $0.secondItem == nil }
                .forEach { $0.isActive = false }
        }
        nameContainer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        domainContainer.setContentHuggingPriority(.required, for: .horizontal)
        domainContainer.setContentCompressionResistancePriority(.required, for: .horizontal)
        mStoreName.font = UIFont(name: "SegoeUI", size: 16) ?? .systemFont(ofSize: 16)
        mStoreDomain.font = UIFont(name: "SegoeUI", size: 14) ?? .systemFont(ofSize: 14)
        mStoreDomain.textAlignment = .right
    }

    private func clearBackgrounds(in view: UIView) {
        view.subviews.forEach { subview in
            subview.backgroundColor = .clear
            clearBackgrounds(in: subview)
        }
    }
    
    
    
}

class LoginController: UIViewController , UITableViewDataSource, UITableViewDelegate , UITextFieldDelegate{
    
    
    
    
    @IBOutlet weak var mOTPView: UIView!
    @IBOutlet weak var mOTPOne: UITextField!
    @IBOutlet weak var mOTPTwo: UITextField!
    @IBOutlet weak var mOTPThree: UITextField!
    @IBOutlet weak var mOTPFour: UITextField!
    @IBOutlet weak var mOTPFive: UITextField!
    
    @IBOutlet weak var mOTPSix: UITextField!
    
    @IBOutlet weak var mResendBUTTON: UIButton!
    @IBOutlet weak var mPleaseCheckMailLABEL: UILabel!
    @IBOutlet weak var mOTPVerificationLABEL: UILabel!
    @IBOutlet weak var mCountDown: UILabel!
    @IBOutlet weak var mOTPSubmitBUTTON: UIButton!
    @IBOutlet weak var mDidntReceiveLABEL: UILabel!
    var mOTPs = ""
    var mOrgId = ""
    var mCountDownTimer = Timer()
    var totalTime = 30
    
    @IBOutlet weak var mStoreContentView: UIView!
    @IBOutlet weak var mLoginButton: UIButton!
    
    @IBOutlet weak var mStoreView: UIView!
    
    @IBOutlet weak var mUserName: UITextField!
    @IBOutlet weak var mPassword: UITextField!
    
    @IBOutlet weak var mQuickLoginText: UILabel!
    @IBOutlet weak var mLoginWithPinButton: UIButton!
    
    @IBOutlet weak var mDotSquare: UIImageView!
    @IBOutlet weak var mStoreTableView: UITableView!
    var mStoreData = NSArray()
    var mKey = ""
    var mCurrency = ""
    var mLocationId = ""
    var mVoucherId = ""

    // Extra PIN/Face ID is required only when switching Organization.
    var mRequiresOrganizationStorePin = false
    private var mCredentialUserName = ""
    private var mCredentialPassword = ""
    private let savedCredentialService = "GIS.SavedLoginCredentials"
    
    @IBOutlet weak var mStoreHeader: UILabel!
    private let mOrganizationButton = UIButton(type: .system)
    // TestFlight test organization: intentionally has no stores.
    private let storeSetupMockOrganizationID = "__store_setup_demo_no_stores__"
    private let mOrganizationSubtitle = UILabel()
    // The overlay's dim colour is faded in/out while only the sheet slides.
    private var storeSheetDimColor: UIColor?
    private var isStoreSheetAnimating = false
    // Distance from the header to the first row: larger while the organization subtitle is visible.
    private var storeTableTopConstraint: NSLayoutConstraint?

    /// False while the Organization/Store sheet is on screen or animating, so a
    /// second tap on the organization button doesn't present it again.
    var canPresentStoreSheet: Bool {
        mStoreContentView.isHidden && !isStoreSheetAnimating
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        mOTPView.isHidden = true
        mOTPOne.delegate = self
        mOTPTwo.delegate = self
        mOTPThree.delegate = self
        mOTPFour.delegate = self
        mOTPFive.delegate = self
        mOTPSix.delegate = self
        mOTPOne.keyboardType  = .numberPad
        mOTPTwo.keyboardType  = .numberPad
        mOTPThree.keyboardType  = .numberPad
        mOTPFour.keyboardType  = .numberPad
        mOTPFive.keyboardType  = .numberPad
        mOTPSix.keyboardType  = .numberPad
        
        mUserName.autocorrectionType = UITextAutocorrectionType.no
        
        configureOrganizationSheetHeader()
        mStoreHeader.numberOfLines = 1
        mStoreHeader.adjustsFontSizeToFitWidth = false
        mStoreHeader.lineBreakMode = .byClipping
        configureGlassStoreSheet()
        
        if(UserDefaults.standard.string(forKey: "email") == nil){
            UserDefaults.standard.set("", forKey: "email")
            mQuickLoginText.isHidden = false
            mLoginWithPinButton.isHidden = false
        }else{
            if(UserDefaults.standard.string(forKey: "email") != "" ){
                
                let mUserName =  UserDefaults.standard.string(forKey: "email")
                // Do not display the saved email in the Login field.
                self.mUserName.text = ""
                
                mQuickLoginText.isHidden = false
                mLoginWithPinButton.isHidden = false
            }else{
                mQuickLoginText.isHidden = true
                mLoginWithPinButton.isHidden = true
            }
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.onClickDot))
        mDotSquare.addGestureRecognizer(tap)
        mDotSquare.isUserInteractionEnabled = true
        
        setupOrganizationButton()
        // mStoreContentView is a full-screen overlay. Put the dismiss gesture
        // on the overlay itself so taps in its transparent/top area are received.
        let dismissStoreSheetTap = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissStoreSheetIfTappedOutside(_:))
        )
        dismissStoreSheetTap.cancelsTouchesInView = false
        mStoreContentView.addGestureRecognizer(dismissStoreSheetTap)
        mStoreContentView.isUserInteractionEnabled = true

        
        self.view.backgroundColor = UIColor(named: "themeBackground")
        self.mStoreContentView.isHidden = true
        
    }

    /// Organization / store picker as a floating Liquid Glass card (design "Organizations.png"):
    /// 6pt from the sides and bottom, 425pt tall, 44pt corners, no grabber, rows without separators.
    private func configureGlassStoreSheet() {
        // The dim overlay was pinned to the safe area, which left the status bar strip undimmed.
        view.constraints
            .filter { $0.firstItem === mStoreContentView && $0.firstAttribute == .top }
            .forEach { $0.isActive = false }
        mStoreContentView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        mStoreContentView.constraints
            .filter { $0.firstItem === mStoreView || $0.secondItem === mStoreView }
            .forEach { $0.isActive = false }
        NSLayoutConstraint.activate([
            mStoreView.leadingAnchor.constraint(equalTo: mStoreContentView.leadingAnchor, constant: 6),
            mStoreView.trailingAnchor.constraint(equalTo: mStoreContentView.trailingAnchor, constant: -6),
            mStoreView.bottomAnchor.constraint(equalTo: mStoreContentView.bottomAnchor, constant: -6)
        ])
        mStoreView.constraints
            .first { $0.firstItem === mStoreView && $0.firstAttribute == .height && $0.secondItem == nil }?
            .constant = 424

        // Title centre 44pt below the card top; the first row starts 75pt below it; rows inset 24pt.
        let headerView = mStoreHeader.superview?.superview
        headerView?.subviews.first { $0.bounds.size == CGSize(width: 50, height: 4) }?.isHidden = true
        mStoreView.constraints
            .first { $0.firstItem === headerView && $0.firstAttribute == .top }?.constant = -3
        storeTableTopConstraint = mStoreView.constraints
            .first { $0.firstItem === mStoreTableView && $0.firstAttribute == .top }
        storeTableTopConstraint?.constant = mOrganizationSubtitle.isHidden ? -2 : 10
        mStoreView.constraints
            .first { $0.firstItem === mStoreTableView && $0.firstAttribute == .leading }?.constant = 24
        mStoreView.constraints
            .first { $0.secondItem === mStoreTableView && $0.firstAttribute == .trailing }?.constant = 24
        mStoreTableView.backgroundColor = .clear
        mStoreTableView.separatorStyle = .none

        mStoreView.backgroundColor = .clear

        // Design: 363x424 card, top corners 34pt and bottom corners 58pt (they follow the screen's rounded corners).
        let effectView: UIVisualEffectView
        if #available(iOS 26.0, *) {
            effectView = UIVisualEffectView(effect: UIGlassEffect(style: .regular))
            effectView.cornerConfiguration = .corners(
                topLeftRadius: .fixed(34),
                topRightRadius: .fixed(34),
                bottomLeftRadius: .fixed(58),
                bottomRightRadius: .fixed(58)
            )
        } else {
            // Before iOS 26 there is no Liquid Glass: use a light frosted blur with the same corners.
            effectView = StoreCardBlurView(effect: UIBlurEffect(style: .systemThinMaterialLight))
        }
        effectView.isUserInteractionEnabled = false
        effectView.translatesAutoresizingMaskIntoConstraints = false
        mStoreView.insertSubview(effectView, at: 0)
        NSLayoutConstraint.activate([
            effectView.topAnchor.constraint(equalTo: mStoreView.topAnchor),
            effectView.bottomAnchor.constraint(equalTo: mStoreView.bottomAnchor),
            effectView.leadingAnchor.constraint(equalTo: mStoreView.leadingAnchor),
            effectView.trailingAnchor.constraint(equalTo: mStoreView.trailingAnchor)
        ])
    }

    private func configureOrganizationSheetHeader() {
        mStoreHeader.text = "Organization"
        mStoreHeader.textColor = .black
        mStoreHeader.font = UIFont(name: "SegoeUI-Semibold", size: 17)
            ?? UIFont.systemFont(ofSize: 17, weight: .semibold)

        // With the subtitle the list starts lower, so the subtitle stays with the title.
        storeTableTopConstraint?.constant = 10
        guard mOrganizationSubtitle.superview == nil else {
            mOrganizationSubtitle.isHidden = false
            return
        }

        mOrganizationSubtitle.translatesAutoresizingMaskIntoConstraints = false
        mOrganizationSubtitle.text = "Select an organization to continue"
        mOrganizationSubtitle.textAlignment = .center
        mOrganizationSubtitle.textColor = UIColor(
            red: 134.0 / 255.0,
            green: 134.0 / 255.0,
            blue: 134.0 / 255.0,
            alpha: 1.0
        )
        mOrganizationSubtitle.font = UIFont(name: "SegoeUI", size: 12)
            ?? UIFont.systemFont(ofSize: 12, weight: .regular)
        mStoreView.addSubview(mOrganizationSubtitle)

        NSLayoutConstraint.activate([
            mOrganizationSubtitle.topAnchor.constraint(
                equalTo: mStoreHeader.bottomAnchor,
                constant: 2
            ),
            mOrganizationSubtitle.centerXAnchor.constraint(
                equalTo: mStoreView.centerXAnchor
            ),
            mOrganizationSubtitle.leadingAnchor.constraint(
                greaterThanOrEqualTo: mStoreView.leadingAnchor,
                constant: 24
            ),
            mOrganizationSubtitle.trailingAnchor.constraint(
                lessThanOrEqualTo: mStoreView.trailingAnchor,
                constant: -24
            )
        ])
    }

    private func configureStoreSheetHeader() {
        mStoreHeader.text = "Choode Store"
        mOrganizationSubtitle.isHidden = true
        storeTableTopConstraint?.constant = -2
    }
    
    private func setupOrganizationButton() {
        guard let saved = loadSavedCredentials(),
              !saved.username.isEmpty,
              !saved.password.isEmpty else {
            mOrganizationButton.isHidden = true
            return
        }

        mOrganizationButton.translatesAutoresizingMaskIntoConstraints = false
        mOrganizationButton.backgroundColor = UIColor.white.withAlphaComponent(0.96)
        mOrganizationButton.tintColor = UIColor(
            red: 0.10, green: 0.62, blue: 0.62, alpha: 1.0
        )
        mOrganizationButton.layer.cornerRadius = 24
        mOrganizationButton.layer.shadowColor = UIColor.black.cgColor
        mOrganizationButton.layer.shadowOpacity = 0.16
        mOrganizationButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        mOrganizationButton.layer.shadowRadius = 7

        let image = UIImage(systemName: "building.2.fill")
            ?? UIImage(systemName: "square.grid.2x2.fill")
        mOrganizationButton.setImage(image, for: .normal)
        mOrganizationButton.accessibilityLabel = "Select Organization"
        mOrganizationButton.addTarget(
            self,
            action: #selector(didTapOrganizationButton),
            for: .touchUpInside
        )

        view.addSubview(mOrganizationButton)

        NSLayoutConstraint.activate([
            mOrganizationButton.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 14
            ),
            mOrganizationButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -18
            ),
            mOrganizationButton.widthAnchor.constraint(equalToConstant: 48),
            mOrganizationButton.heightAnchor.constraint(equalToConstant: 48)
        ])

        view.bringSubviewToFront(mOrganizationButton)
    }

    @objc
    private func didTapOrganizationButton() {
        // The sheet is already open (the button sits above it); don't load it again.
        guard canPresentStoreSheet else { return }
        // Organization switcher requires PIN or Face ID after Store selection.
        mRequiresOrganizationStorePin = true
        view.endEditing(true)
        openSavedOrganizationPicker()
    }

    // Existing 9-dot button remains Quick Login with PIN.
    @objc
    func onClickDot(){
        // Normal Quick Login with PIN is not the Organization switcher flow.
        mRequiresOrganizationStorePin = false
        view.endEditing(true)

        if UserDefaults.standard.string(forKey: "email") != "" {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            if let home = storyBoard.instantiateViewController(
                withIdentifier: "LoginWithPin"
            ) as? LoginWithPin {
                navigationController?.pushViewController(home, animated: true)
            }
        } else {
            CommonClass.showSnackBar(message: "Please login first !")
        }
    }

    private func openSavedOrganizationPicker() {
        guard let credentials = loadSavedCredentials() else {
            CommonClass.showSnackBar(message: "Please login with username and password first !")
            return
        }

        mCredentialUserName = credentials.username
        mCredentialPassword = credentials.password

        // Keep credentials for Organization login, but do not display
        // the saved email in the visible Login field.
        mUserName.text = ""

        print("openSavedOrganizationPicker username = \(credentials.username)")
        print("openSavedOrganizationPicker -> loading Organizations with saved credentials")

        mGetOrganization(username: credentials.username)
    }

    private func saveCredentials(username: String, password: String) {
        guard !username.isEmpty, !password.isEmpty else { return }

        let account = username.lowercased()
        let data = Data(password.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: savedCredentialService,
            kSecAttrAccount as String: account
        ]

        SecItemDelete(query as CFDictionary)

        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: savedCredentialService,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]

        let status = SecItemAdd(addQuery as CFDictionary, nil)
        print("saveCredentials Keychain status = \(status)")

        UserDefaults.standard.set(username, forKey: "email")
    }

    private func loadSavedCredentials() -> (username: String, password: String)? {
        let username = UserDefaults.standard.string(forKey: "email")?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !username.isEmpty else { return nil }

        let account = username.lowercased()
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: savedCredentialService,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess,
              let data = result as? Data,
              let password = String(data: data, encoding: .utf8),
              !password.isEmpty else {
            print("loadSavedCredentials Keychain status = \(status)")
            return nil
        }

        return (username, password)
    }
    
    @objc
    private func dismissStoreSheetIfTappedOutside(_ gesture: UITapGestureRecognizer) {
        guard !mStoreContentView.isHidden else { return }

        let tapPoint = gesture.location(in: self.view)

        // mStoreContentView covers the whole screen, while mStoreView is the
        // actual visible bottom sheet. Only taps above that sheet dismiss it.
        let sheetFrame = mStoreView.convert(mStoreView.bounds, to: self.view)

        if tapPoint.y < sheetFrame.minY {
            dismissStoreContentView()
        }
    }

    /// Fades the dim background in while the sheet slides up from the bottom.
    private func showStoreContentView() {
        guard canPresentStoreSheet else { return }
        let dimColor = storeSheetDimColor ?? mStoreContentView.backgroundColor
        storeSheetDimColor = dimColor
        isStoreSheetAnimating = true

        mStoreContentView.backgroundColor = .clear
        mStoreContentView.isHidden = false
        view.layoutIfNeeded()
        mStoreView.transform = CGAffineTransform(translationX: 0, y: mStoreView.bounds.height)

        UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseOut, animations: {
            self.mStoreContentView.backgroundColor = dimColor
            self.mStoreView.transform = .identity
        }, completion: { _ in
            self.isStoreSheetAnimating = false
        })
    }

    private func dismissStoreContentView() {
        guard !mStoreContentView.isHidden else {
            configureOrganizationSheetHeader()
            self.mKey = ""
            return
        }
        guard !isStoreSheetAnimating else { return }
        isStoreSheetAnimating = true

        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            self.mStoreContentView.backgroundColor = .clear
            self.mStoreView.transform = CGAffineTransform(translationX: 0, y: self.mStoreView.bounds.height)
        }, completion: { _ in
            self.mStoreContentView.isHidden = true
            self.mStoreContentView.backgroundColor = self.storeSheetDimColor
            self.mStoreView.transform = .identity
            self.isStoreSheetAnimating = false
            self.configureOrganizationSheetHeader()
            self.mKey = ""
        })
    }

    @IBAction func mHideStoreContentView(_ sender: Any) {
        dismissStoreContentView()
    }
    
    
    
    @IBAction func mShowHidePass(_ sender: UIButton) {
        
        
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            
            mPassword.isSecureTextEntry = false
        }else{
            mPassword.isSecureTextEntry = true
            
        }
        
    }
    
    
    
    
    @IBAction func mHideOTPView(_ sender: Any) {
        mOTPView.isHidden = true
        mOTPOne.text = ""
        mOTPTwo.text = ""
        mOTPThree.text = ""
        mOTPFour.text = ""
        mOTPFive.text = ""
        mOTPSix.text = ""
        mCountDownTimer.invalidate()
        mCountDownTimer = Timer()
        mCountDown.isHidden = true
        totalTime =  30
        self.mResendBUTTON.setTitleColor(#colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1), for: .normal)
        self.mResendBUTTON.isUserInteractionEnabled = true
        self.view.endEditing(true)
    }
    
    @IBAction func mResendOtp(_ sender: Any) {
        
        mResendCode()
    }
    func mStartTimer() {
        mCountDown.isHidden = false
        mCountDownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(mUpdateTimer), userInfo: nil, repeats: true)
    }
    @objc
    func mUpdateTimer() {
        mCountDown.text = "\(formatTime(totalTime))"
        
        if totalTime <= 0 {
            mCountDownTimer.invalidate()
            mCountDownTimer =  Timer()
            mCountDown.isHidden = true
            self.mResendBUTTON.setTitleColor(#colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1), for: .normal)
            self.mResendBUTTON.isUserInteractionEnabled = true
        }else{
            totalTime -= 1
            
        }
    }
    
    func formatTime(_ totalSeconds: Int) -> String {
        
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds/60) % 60
        
        return String(format: "%02d:%02d", minutes,seconds)
    }
    @IBAction func mSubmitOTP(_ sender: Any) {
        
        guard let one = mOTPOne.text, let two = mOTPTwo.text, let three = mOTPThree.text, let four = mOTPFour.text, let five = mOTPFive.text, let six = mOTPSix.text else {
            CommonClass.showSnackBar(message: "Invalid OTP!")
            return
        }
        
        let oneTimePass = one + two + three + four + five + "\(six)"
        
        if(oneTimePass.count != 6){
            CommonClass.showSnackBar(message: "Incorrect OTP! \(oneTimePass)")
        }else{
            mVerifyOTP(otp: oneTimePass)
        }
        
    }
    
    
    @IBAction func mOTPOne(_ sender: Any) {
        
        if(mOTPOne.text?.count == 1){
            mOTPTwo.becomeFirstResponder()
        }else if(mOTPOne.text == ""){
            self.mOTPOne.text = ""
            self.mOTPTwo.text = ""
            self.mOTPThree.text = ""
            self.mOTPFour.text = ""
            self.mOTPFive.text = ""
            self.mOTPSix.text = ""
            mOTPOne.becomeFirstResponder()
        }
    }
    
    
    @IBAction func mOTPTwo(_ sender: Any) {
        if(mOTPTwo.text?.count == 1){
            mOTPThree.becomeFirstResponder()
        }else if(mOTPTwo.text == ""){
            self.mOTPOne.text = ""
            self.mOTPTwo.text = ""
            self.mOTPThree.text = ""
            self.mOTPFour.text = ""
            self.mOTPFive.text = ""
            self.mOTPSix.text = ""
            mOTPOne.becomeFirstResponder()
        }
    }
    @IBAction func mOTPThree(_ sender: Any) {
        if(mOTPThree.text?.count == 1){
            mOTPFour.becomeFirstResponder()
        }else if(mOTPThree.text == ""){
            self.mOTPOne.text = ""
            self.mOTPTwo.text = ""
            self.mOTPThree.text = ""
            self.mOTPFour.text = ""
            self.mOTPFive.text = ""
            self.mOTPSix.text = ""
            mOTPOne.becomeFirstResponder()
        }
    }
    
    
    @IBAction func mOTPFour(_ sender: Any) {
        if(mOTPFour.text?.count == 1){
            mOTPFive.becomeFirstResponder()
        }else if(mOTPFour.text == ""){
            self.mOTPOne.text = ""
            self.mOTPTwo.text = ""
            self.mOTPThree.text = ""
            self.mOTPFour.text = ""
            self.mOTPFive.text = ""
            self.mOTPSix.text = ""
            mOTPOne.becomeFirstResponder()
        }
    }
    
    @IBAction func mOTPFive(_ sender: Any) {
        if(mOTPFive.text?.count == 1){
            mOTPSix.becomeFirstResponder()
        }else if(mOTPFive.text == ""){
            self.mOTPOne.text = ""
            self.mOTPTwo.text = ""
            self.mOTPThree.text = ""
            self.mOTPFour.text = ""
            self.mOTPFive.text = ""
            self.mOTPSix.text = ""
            mOTPOne.becomeFirstResponder()
        }
    }
    @IBAction func mOTPSix(_ sender: Any) {
        if(mOTPSix.text?.count == 1){
            self.view.endEditing(true)
        }else if(mOTPSix.text == ""){
            self.mOTPOne.text = ""
            self.mOTPTwo.text = ""
            self.mOTPThree.text = ""
            self.mOTPFour.text = ""
            self.mOTPFive.text = ""
            self.mOTPSix.text = ""
            mOTPOne.becomeFirstResponder()
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentTextField = textField.text ?? ""
        
        guard let stringrange = Range(range,in:currentTextField)
        else{
            return false
        }
        let updatedText = currentTextField.replacingCharacters(in: stringrange, with: string)
        return updatedText.count < 2
    }
    
    override func viewDidLayoutSubviews() {
        
        self.view.applyGradient(withColours: [#colorLiteral(red: 0.7725490196, green: 0.9019607843, blue: 0.8745098039, alpha: 1),#colorLiteral(red: 0.9207345247, green: 0.9503677487, blue: 0.978346765, alpha: 1)], gradientOrientation: .vertical)
        
        
    }
    
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    
    
    @IBAction func mLoginNow(_ sender: UIButton) {
        sender.showAnimation{}
        
        // Direct Email + Password login does not require PIN after Store.
        mRequiresOrganizationStorePin = false

        print("mLoginNow")
        if mUserName.text == "" || mUserName.text?.isEmptyOrSpaces() == true {
            CommonClass.showSnackBar(message: "Please fill email!")
        }else if mPassword.text == "" || mPassword.text?.isEmptyOrSpaces() == true {
            CommonClass.showSnackBar(message: "Please fill password!")
        }else if mUserName.text?.isValidEmail == false {
            CommonClass.showSnackBar(message: "Please enter valid email.")
        }else{
            self.view.endEditing(true)

            mCredentialUserName = mUserName.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            mCredentialPassword = mPassword.text ?? ""

            mGetOrganization(username: mCredentialUserName)
        }
    }
    
    @IBAction func mForgotPassword(_ sender:  UIButton) {
        sender.showAnimation{
            
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            
            guard let mForgotPassPage = storyBoard.instantiateViewController(withIdentifier: "ForgotPassPage") as? ForgotPassPage else {return}
            
            self.navigationController?.pushViewController(mForgotPassPage, animated:true)
        }
        
    }
    
    @IBAction func mLoginWithPin(_ sender:  UIButton) {
        sender.showAnimation{
            
            if(UserDefaults.standard.string(forKey: "email") != "" ){
                
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                
                guard let home = storyBoard.instantiateViewController(withIdentifier: "LoginWithPin") as? LoginWithPin else {return}
                
                self.navigationController?.pushViewController(home, animated:true)
                
            }else{
                CommonClass.showSnackBar(message: "Please login first !")
            }
            
        }
    }
    
    
    func mGetOrganization(username: String? = nil) {
        let urlPath = mLoginUser
        let userName = (username ?? mUserName.text ?? "").removeWhitespace()
        guard !userName.isEmpty else{
            CommonClass.showSnackBar(message: "Fill UserName field")
            return
        }
        
        let params: [String: String] = ["username": userName]
        
        guard Reachability.isConnectedToNetwork() else {
            CommonClass.showSnackBar(message: "No Internet Connection!")
            return
        }
        
        CommonClass.showFullLoader(view: self.view)
        print("mGetOrganization urlPath \(urlPath)")
        print("mGetOrganization params \(params)")
        AF.request(urlPath, method: .post, parameters: params).responseJSON { response in
            var keepsLoadingForAutomaticSelection = false
            defer {
                if !keepsLoadingForAutomaticSelection {
                    CommonClass.stopLoader()
                }
            }
            print("mGetOrganization response.response?.statusCode \(response.response?.statusCode ?? 0)")
            print("mGetOrganization response.value \(response.value ?? "")")
            print("response = \(response)")
            switch response.result {
            case .success(let value):
                guard let jsonResult = value as? [String: Any],
                      let code = jsonResult["code"] as? Int else {
                    return
                }
                
                if code == 200 {
                    if let mData = jsonResult["data"] as? [String: Any],
                       let orgData = mData["org_data"] as? NSArray {
                        let organizationsForSelection = NSMutableArray(array: orgData)
                        // Keep the QA-only no-store organization visible without
                        // requiring the tester to scroll through a long account list.
                        organizationsForSelection.insert([
                            "organization_id": self.storeSetupMockOrganizationID,
                            "organization": "Demo (No Stores)",
                            "domain": "https://www.gis247.net"
                        ], at: 0)
                        // A user with one organization has no organization
                        // choice to make. Continue directly to its store list.
                        if organizationsForSelection.count == 1,
                           let onlyOrganization = organizationsForSelection.firstObject as? NSDictionary {
                            print("mGetOrganization -> selecting the only available organization")
                            keepsLoadingForAutomaticSelection = true
                            self.selectOrganization(onlyOrganization)
                            return
                        }

                        self.mKey = "org"
                        self.configureOrganizationSheetHeader()
                        self.mStoreData = organizationsForSelection
                        self.mStoreTableView.delegate = self
                        self.mStoreTableView.dataSource = self
                        self.mStoreTableView.reloadData()
                        self.showStoreContentView()
                    } else {
                        
                    }
                } else if code == 400 {
                    if let message = jsonResult["message"] as? String {
                        CommonClass.showSnackBar(message: message)
                    } else {
                        
                    }
                } else {
                    
                }
                
            case .failure(let error):
                print("response error = \(error)")
                CommonClass.showSnackBar(message: "OOP's something went wrong!")
            }
        }
    }
    
    
    func mLoginWithPassword(org_id: String){
        
        let urlPath = mLoginUser
        
        guard let bundleShortVersionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
              let bundleVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        else { return }
        
        let userNmae = mCredentialUserName.isEmpty ? (mUserName.text ?? "") : mCredentialUserName
        let password = mCredentialPassword.isEmpty ? (mPassword.text ?? "") : mCredentialPassword
        guard !userNmae.isEmpty, !password.isEmpty else {
            CommonClass.showSnackBar(message: "Fill username and password first.")
            return
        }

        let params:[String:String] = ["username" : userNmae ,
                                      "password": password ,
                                      "organization_id":org_id,
                                      "platform":mGetDeviceInfo() ,
                                      "agent":"\(bundleShortVersionString).\(bundleVersion)"]
        
        print("mLoginWithPassword params = \(params)")
        if Reachability.isConnectedToNetwork() == true {
            CommonClass.showFullLoader(view: self.view)
            print("mLoginWithPassword urlPath = \(urlPath)")
            AF.request(urlPath, method:.post, parameters: params,encoding: JSONEncoding.default).responseJSON
            { response in
                CommonClass.stopLoader()
                
                print("mLoginWithPassword response = \(response)")
                if(response.error != nil) {
                    CommonClass.showSnackBar(message: "OOP's something went wrong!")
                    
                }else{
                    guard let jsonData = response.data else {
                        print("jsonData != response.data")
                        CommonClass.showSnackBar(message: "OOP's something went wrong!")
                        return
                    }
                    
                    let json = try? JSONSerialization.jsonObject(with: jsonData, options: [])
                    
                    guard let jsonResult = json as? NSDictionary else {
                        print("jsonResult != json")
                        CommonClass.showSnackBar(message: "OOP's something went wrong!")
                        return
                    }
                    print("jsonResult code = \(String(describing: jsonResult.value(forKey: "code")))")
                    if jsonResult.value(forKey: "code") as? Int == 200 {
                        if let mData = jsonResult.value(forKey: "data") as? NSDictionary {

                            let mToken = "\(mData.value(forKey: "login_token") ?? "")"
                            UserDefaults.standard.set(mToken, forKey: "token")
                            HomePage.pendingHolidayWelcome = true

                            if "\(mData.value(forKey: "twofactorauth") ?? "0")" == "0" {
                                
                                let mUDID = "\(mData.value(forKey: "mobileUDID") ?? "")"
                                UserDefaults.standard.set(mUDID, forKey: "mobileUDID")
                                self.saveCredentials(username: userNmae, password: password)
                                self.mFetchStoresLocations()
                            }else{
                                self.mStoreContentView.isHidden = true
                                
                                self.mOTPView.isHidden = false
                                self.mOTPOne.text = ""
                                self.mOTPTwo.text = ""
                                self.mOTPThree.text = ""
                                self.mOTPFour.text = ""
                                self.mOTPFive.text = ""
                                self.mOTPSix.text = ""
                                self.mCountDownTimer =  Timer()
                                self.mCountDown.isHidden = true
                                self.mResendBUTTON.setTitleColor(#colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1), for: .normal)
                                self.mResendBUTTON.isUserInteractionEnabled = true
                                
                            }
                        } else {
                            CommonClass.showSnackBar(message: "OOP's something went wrong!")
                            return
                        }
                    } else if jsonResult.value(forKey: "code") as? Int == 400 {
                        
                        CommonClass.showSnackBar(message: "\(jsonResult.value(forKey: "message")!)")
                    }
                    
                }
                
            }
        }else{
            CommonClass.showSnackBar(message: "No Internet Connection!")
        }
        
        
    }
    
    func mVerifyOTP(otp:String){
        
        let urlPath = mVerifyOneTimeCode
        let mAuthToken = UserDefaults.standard.string(forKey: "token") ?? ""
        
        guard let bundleShortVersionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
              let bundleVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        else { return }
        
        let params:[String:String] = ["authToken" :mAuthToken ,"otp":otp ,"platform":mGetDeviceInfo(), "agent":"\(bundleShortVersionString).\(bundleVersion)"]
        
        if Reachability.isConnectedToNetwork() == true {
            CommonClass.showFullLoader(view: self.view)
            AF.request(urlPath, method:.post, parameters: params,encoding: JSONEncoding.default).responseJSON
            { response in
                CommonClass.stopLoader()
                
                if(response.error != nil) {
                    
                    CommonClass.showSnackBar(message: "OOP's something went wrong!")
                    
                }else{
                    guard let jsonData = response.data else {
                        CommonClass.showSnackBar(message: "OOP's something went wrong!")
                        return
                    }
                    
                    let json = try? JSONSerialization.jsonObject(with: jsonData, options: [])
                    
                    guard let jsonResult = json as? NSDictionary else {
                        CommonClass.showSnackBar(message: "OOP's something went wrong!")
                        return
                    }
                    
                    if jsonResult.value(forKey: "code") as? Int == 200 {
                        
                        self.mCountDownTimer.invalidate()
                        self.mCountDownTimer =  Timer()
                        self.mCountDown.isHidden = true
                        self.mOTPView.isHidden = true
                        self.mResendBUTTON.setTitleColor(#colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1), for: .normal)
                        self.mResendBUTTON.isUserInteractionEnabled = true
                        
                        if let mData = jsonResult.value(forKey: "data") as? NSDictionary {
                            let mToken = "\(mData.value(forKey: "login_token") ?? "")"
                            let udid = "\(mData.value(forKey: "mobileUDID") ?? "")"
                            UserDefaults.standard.set(udid, forKey: "mobileUDID")
                            UserDefaults.standard.set(mToken, forKey: "token")
                            HomePage.pendingHolidayWelcome = true
                            if !self.mCredentialUserName.isEmpty && !self.mCredentialPassword.isEmpty {
                                self.saveCredentials(username: self.mCredentialUserName, password: self.mCredentialPassword)
                            }
                            self.mFetchStoresLocations()
                            
                        }else{
                            if let mMessage = jsonResult.value(forKey: "message") as? String {
                                if mMessage == "invalid otp" {
                                    CommonClass.showSnackBar(message: "Please enter a valid OTP!")
                                }else{
                                    CommonClass.showSnackBar(message: mMessage)
                                }
                            }
                        }
                        
                    } else if jsonResult.value(forKey: "code") as? Int == 400 {
                        
                        CommonClass.showSnackBar(message: "Invalid OTP!")
                    }
                }
                
            }
        }else{
            CommonClass.showSnackBar(message: "No Internet Connection!")
        }
        
    }
    
    func mResendCode(){
        
        let urlPath = mResendOneTimeCode
        
        let mAuthToken = UserDefaults.standard.string( forKey: "token")
        
        let params:[String:String] = ["authToken" : mAuthToken ?? ""]
        
        if Reachability.isConnectedToNetwork() == true {
            CommonClass.showFullLoader(view: self.view)
            AF.request(urlPath, method:.post, parameters: params,encoding: JSONEncoding.default).responseJSON
            { response in
                
                CommonClass.stopLoader()
                if(response.error != nil) {
                    CommonClass.showSnackBar(message: "OOP's something went wrong!")
                    
                }else{
                    guard let jsonData = response.data else {
                        CommonClass.showSnackBar(message: "OOP's something went wrong!")
                        return
                    }
                    
                    let json = try? JSONSerialization.jsonObject(with: jsonData, options: [])
                    
                    guard let jsonResult = json as? NSDictionary else {
                        CommonClass.showSnackBar(message: "OOP's something went wrong!")
                        return
                    }
                    
                    if jsonResult.value(forKey: "code") as? Int == 200 {
                        
                        CommonClass.showSnackBar(message: "Please check your mail!")
                        
                        self.mOTPOne.text = ""
                        self.mOTPTwo.text = ""
                        self.mOTPThree.text = ""
                        self.mOTPFour.text = ""
                        self.mOTPFive.text = ""
                        self.mOTPSix.text = ""
                        self.totalTime =  30
                        self.view.endEditing(true)
                        self.mResendBUTTON.setTitleColor(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1), for: .normal)
                        self.mResendBUTTON.isUserInteractionEnabled = false
                        self.mStartTimer()
                        
                        
                    } else if jsonResult.value(forKey: "code") as? Int == 400 {
                        
                        CommonClass.showSnackBar(message: "Please try again!")
                    }
                    
                }
                
            }
        }else{
            CommonClass.showSnackBar(message: "No Internet Connection!")
        }
        
    }
    
    func mFetchStoresLocations(){
        
        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
        
        guard let loginToken = mUserLoginToken else {
            CommonClass.showSnackBar(message: "OOP's something went wrong!")
            return
        }
        
        let sFetchStoreHeader:
        HTTPHeaders = [
            "Authorization": loginToken
        ]
        
        let urlPath = mFetchStores
        
        if Reachability.isConnectedToNetwork() == true {
            CommonClass.showFullLoader(view: self.view)
            print("mFetchStoresLocations urlPath = \(urlPath)")
            AF.request(urlPath, method:.post, parameters: ["":""],headers: sFetchStoreHeader).responseJSON
            { response in
                print("mFetchStoresLocations response = \(response)")
                if(response.error != nil){
                    CommonClass.stopLoader()
                    CommonClass.showSnackBar(message: "OOP's something went wrong!")
                    
                    
                    
                }else{
                    guard let jsonData = response.data else {
                        CommonClass.stopLoader()
                        CommonClass.showSnackBar(message: "OOP's something went wrong!")
                        return
                    }
                    
                    // --- DEBUG: Log raw store response ---
                    if let rawJSON = String(data: jsonData, encoding: .utf8) {
                        print("🔵 [Stores] RAW JSON Response:\n\(rawJSON)")
                    }
                    // --- END DEBUG ---
                    
                    let json = try? JSONSerialization.jsonObject(with: jsonData, options: [])
                    
                    guard let jsonResult = json as? NSDictionary else {
                        CommonClass.stopLoader()
                        CommonClass.showSnackBar(message: "OOP's something went wrong!")
                        return
                    }
                    if jsonResult.value(forKey: "code") as? Int == 200 {
                        if let mStoreData = jsonResult.value(forKey: "data") as? NSArray {
                            if mStoreData.count == 0 {
                                CommonClass.stopLoader()
                                self.showNoStoresFoundOverlay()
                                
                                return
                            }
                            UserDefaults.standard.set(jsonResult, forKey: "storeData")

                            // A single voucher has no user choice to make. Select it
                            // immediately and continue through the same authentication
                            // path used when the user taps a store row.
                            if mStoreData.count == 1,
                               let onlyStore = mStoreData.firstObject as? NSDictionary {
                                print("mFetchStoresLocations -> selecting the only available store")
                                self.selectStore(onlyStore)
                                return
                            }

                            self.mKey = "store"
                            self.configureStoreSheetHeader()
                            self.mStoreData = mStoreData
                            self.mStoreTableView.delegate = self
                            self.mStoreTableView.dataSource = self
                            self.mStoreTableView.reloadData()
                            CommonClass.stopLoader()
                            self.mStoreContentView.isHidden = false
                        }else{
                            CommonClass.stopLoader()
                            self.showNoStoresFoundOverlay()
                            return
                        }
                    } else if jsonResult.value(forKey: "code") as? Int == 400 {
                        CommonClass.stopLoader()
                        self.showNoStoresFoundOverlay()
                    }
                    
                }
                
                
            }
        }else{
            CommonClass.showSnackBar(message: "No Internet Connection!")
        }
        
    }
    
    
    
    
    private func showNoStoresFoundOverlay() {
        CommonClass.stopLoader()
        mStoreContentView.isHidden = true
        let setupURL = URL(string: "https://gis247.net/login/")
        let controller = StoreSetupEmptyStateController(setupURL: setupURL)
        controller.modalPresentationStyle = .overFullScreen
        // The controller fades its dim background and slides its own sheet up.
        present(controller, animated: false)
    }

    func mGeneratePOSToken(){
        
        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        print("mGeneratePOSToken mUserLoginToken = \(String(describing: mUserLoginToken))")
        
        print("mGeneratePOSToken urlPath = \(mPOSAuthToken)")
        guard let bundleShortVersionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
              let bundleVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        else { return }
        guard let loginToken = mUserLoginToken else {
            CommonClass.showSnackBar(message: "OOP's something went wrong!")
            return
        }
        let sGenPosHeader: HTTPHeaders = [
            "Authorization": loginToken,
            "agent" : "\(bundleShortVersionString).\(bundleVersion)",
            "platform" : mGetDeviceInfo(),
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        let urlPath = mPOSAuthToken
        
        let params:[String:String] = ["currency" : mCurrency, "voucher_id":mVoucherId, "location_id":mLocationId ]
        
        
        print("mGeneratePOSToken params = \(params)")
        if Reachability.isConnectedToNetwork() == true {
            print("mGeneratePOSToken urlPath = \(urlPath)")
            AF.request(urlPath, method:.post, parameters: params,headers: sGenPosHeader).responseJSON
            { response in
                defer {
                    CommonClass.stopLoader()
                }
                print("mGeneratePOSToken response = \(response)")
                if(response.error != nil){
                    
                    CommonClass.showSnackBar(message: "OOP's something went wrong!")
                    
                }else{
                    guard let jsonData = response.data else {
                        CommonClass.showSnackBar(message: "OOP's something went wrong!")
                        return
                    }
                    
                    // --- DEBUG: Log raw POS token response ---
                    if let rawJSON = String(data: jsonData, encoding: .utf8) {
                        print("🟣 [POS Token] RAW JSON Response:\n\(rawJSON)")
                    }
                    // --- END DEBUG ---
                    
                    let json = try? JSONSerialization.jsonObject(with: jsonData, options: [])
                    
                    guard let jsonResult = json as? NSDictionary else {
                        CommonClass.showSnackBar(message: "OOP's something went wrong!")
                        return
                    }
                    if jsonResult.value(forKey: "code") as? Int == 200 {
                        self.mKey = ""
                        if jsonResult.value(forKey: "data") != nil {
                            if let mData = jsonResult.value(forKey: "data") as? NSDictionary {
                                let finalUsername = self.mCredentialUserName.isEmpty ? (self.mUserName.text ?? "") : self.mCredentialUserName
                                let finalPassword = self.mCredentialPassword.isEmpty ? (self.mPassword.text ?? "") : self.mCredentialPassword
                                if !finalUsername.isEmpty {
                                    UserDefaults.standard.set(finalUsername, forKey: "email")
                                }
                                if !finalUsername.isEmpty && !finalPassword.isEmpty {
                                    self.saveCredentials(username: finalUsername, password: finalPassword)
                                }
                                UserDefaults.standard.setValue("\(mData.value(forKey: "token") ?? "")", forKey: "token_pos")
                                
                                mSESSION = ""
                                self.mStoreContentView.isHidden = true
                                UserDefaults.standard.setValue("", forKey: "LANG")
                                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                if let mLanguageController = storyBoard.instantiateViewController(withIdentifier: "LanguageController") as? LanguageController {
                                    self.navigationController?.pushViewController(mLanguageController, animated:true)
                                }
                            }
                        }
                        
                    } else if jsonResult.value(forKey: "code") as? Int == 400 {
                        
                        CommonClass.showSnackBar(message: "Failed to Authenticate!")
                    }else if jsonResult.value(forKey: "code") as? Int == 403 {
                        CommonClass.showSnackBar(message: "Session Expired!! Please Re-login.")
                        self.navigationController?.popViewController(animated: true)
                    } else {
                        CommonClass.showSnackBar(message: "OOP's something went wrong!")
                    }
                    
                }
                
            }
        }else{
            CommonClass.showSnackBar(message: "No Internet Connection!")
        }
        
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return mStoreData.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        
        if let cells = tableView.dequeueReusableCell(withIdentifier: "StoreItem") as? StoreItem {
            
            cells.mSelect.tag = indexPath.row
            
            if let mData = mStoreData[indexPath.row] as? NSDictionary{
                
                if mKey == "org" {
                    cells.mStoreName.text = mData.value(forKey: "organization") as? String
                    cells.mStoreDomain.text = mData.value(forKey: "domain") as? String
                    
                }else if mKey == "store"{
                    
                    // Some vouchers have no name set; fall back to the location name.
                    let voucherName = (mData.value(forKey: "voucher_name") as? String)?
                        .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                    cells.mStoreName.text = voucherName.isEmpty
                        ? mData.value(forKey: "location_name") as? String
                        : voucherName
                    cells.mStoreDomain.text = ""
                }
            }
            return cells
        } else {
            return UITableViewCell()
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
    }
    
    @IBAction func mSelectOrgStore(_ sender: UIButton) {
        
        print("mSelectOrgStore")
        guard let mData = mStoreData[sender.tag] as? NSDictionary else {return}
        print("mSelectOrgStore mKey = \(mKey)")
        print("Organization =", mData)
        if mKey == "org" {
            selectOrganization(mData)
        }else if mKey == "store"{
            selectStore(mData)
        }
    }

    /// Continues login for the selected organization. Used for both a manual
    /// selection and the automatic single-organization path.
    private func selectOrganization(_ organization: NSDictionary) {
        guard let orgId = organization["organization_id"] as? String,
              !orgId.isEmpty else {
            CommonClass.showSnackBar(message: "Unable to select organization!")
            return
        }

        mOrgId = orgId
        UserDefaults.standard.set(orgId, forKey: "organization_id")
        UserDefaults.standard.set(organization["domain"], forKey: "website_url")
        if orgId == storeSetupMockOrganizationID {
            showNoStoresFoundOverlay()
            return
        }
        mLoginWithPassword(org_id: orgId)
    }

    /// Saves the selected store and continues login. Both the manual store row
    /// and the single-store shortcut use this method to keep their behavior equal.
    private func selectStore(_ store: NSDictionary) {
        guard let location = store.value(forKey: "location_id") as? String,
              let locationName = store.value(forKey: "location_name") as? String else {
            CommonClass.showSnackBar(message: "Unable to select store!")
            return
        }

        mCurrency = "\(store.value(forKey: "currency") ?? "")"
        mLocationId = "\(store.value(forKey: "location_id") ?? "")"
        mVoucherId = "\(store.value(forKey: "voucher_id") ?? "")"

        UserDefaults.standard.setValue(mCurrency, forKey: "posCurrency")
        UserDefaults.standard.setValue(mLocationId, forKey: "posLocation")
        UserDefaults.standard.setValue(mVoucherId, forKey: "posVoucher")
        UserDefaults.standard.setValue(location, forKey: "location")
        UserDefaults.standard.setValue(locationName, forKey: "locationName")

        if mRequiresOrganizationStorePin {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            guard let pinController = storyBoard.instantiateViewController(
                withIdentifier: "LoginWithPin"
            ) as? LoginWithPin else {
                CommonClass.showSnackBar(message: "Unable to open PIN screen.")
                return
            }

            pinController.mRequiresOrganizationStorePin = true
            navigationController?.pushViewController(pinController, animated: true)
        } else {
            CommonClass.showFullLoader(view: view)
            mGeneratePOSToken()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
        
    }
}

final class StoreSetupEmptyStateController: UIViewController {
    private let setupURL: URL?
    private let teal = UIColor(red: 0.36, green: 0.78, blue: 0.756, alpha: 1)
    private let dimView = UIView()
    private var hasAnimatedIn = false
    // iPad layout follows the tablet design (sheet 80pt from the top, 40pt corners, 52pt buttons).
    private let isPad = UIDevice.current.userInterfaceIdiom == .pad
    private let detailLabel = UILabel()
    private lazy var detailHeight: NSLayoutConstraint = detailLabel.heightAnchor.constraint(equalToConstant: 42)
    /// The white bottom sheet. Internal so tests can check its layout.
    let sheetView = UIView()
    /// Store icon from the UX/UI design (`building_storefront`).
    let iconView = UIImageView()

    init(setupURL: URL?) {
        self.setupURL = setupURL
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        // The dim background only fades; the sheet slides (see viewDidAppear).
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.30)
        dimView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dimView)

        let sheet = sheetView
        sheet.backgroundColor = .white
        sheet.layer.cornerRadius = isPad ? 40 : 34
        sheet.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        sheet.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sheet)

        let grabber = UIView()
        grabber.backgroundColor = UIColor(white: 0.8, alpha: 1)
        grabber.layer.cornerRadius = 2
        grabber.translatesAutoresizingMaskIntoConstraints = false
        sheet.addSubview(grabber)

        let close = UIButton(type: .system)
        close.setImage(UIImage(systemName: "xmark"), for: .normal)
        close.tintColor = .darkGray
        close.addTarget(self, action: #selector(dismissOverlay), for: .touchUpInside)
        close.translatesAutoresizingMaskIntoConstraints = false
        sheet.addSubview(close)

        // The 48pt asset has 3pt of padding, so a 48pt frame at x=24 puts the glyph at x=27 like the design.
        let icon = iconView
        icon.image = UIImage(named: "building_storefront") ?? UIImage(systemName: "storefront")
        icon.tintColor = .darkGray
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false
        let iconRow = UIView()
        iconRow.addSubview(icon)

        let title = UILabel()
        title.text = "No Stores Found"
        title.font = .systemFont(ofSize: 23, weight: .semibold)
        title.textColor = .label

        let detail = detailLabel
        // 14.5pt with a 21pt line height breaks the text after "set up" like the design.
        let detailStyle = NSMutableParagraphStyle()
        detailStyle.minimumLineHeight = 21
        detailStyle.maximumLineHeight = 21
        detail.attributedText = NSAttributedString(
            string: "This organization doesn't have any stores set up yet.",
            attributes: [
                .font: UIFont.systemFont(ofSize: 14.5),
                .foregroundColor: UIColor.secondaryLabel,
                .paragraphStyle: detailStyle
            ]
        )
        detail.numberOfLines = 0

        let guide = makeButton(title: "View Setup Guide", filled: true)
        guide.addTarget(self, action: #selector(showGuide), for: .touchUpInside)
        let setup = makeButton(title: "Go to Setup", filled: false)
        setup.addTarget(self, action: #selector(openSetup), for: .touchUpInside)

        let content = UIStackView(arrangedSubviews: [iconRow, title, detail, guide, setup])
        content.axis = .vertical
        content.alignment = .fill
        content.spacing = 12
        // Gaps measured from the design (Setup 7.png, 375x812).
        content.setCustomSpacing(27, after: iconRow)
        content.setCustomSpacing(13, after: title)
        content.setCustomSpacing(24, after: detail)
        content.translatesAutoresizingMaskIntoConstraints = false
        sheet.addSubview(content)

        NSLayoutConstraint.activate([
            dimView.topAnchor.constraint(equalTo: view.topAnchor),
            dimView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dimView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            sheet.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sheet.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sheet.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            // Design: the sheet top sits just below the status bar (72pt on a 812pt phone, 80pt on a 1024pt iPad).
            isPad
                ? sheet.topAnchor.constraint(equalTo: view.topAnchor, constant: 80)
                : sheet.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25),

            grabber.topAnchor.constraint(equalTo: sheet.topAnchor, constant: 5),
            grabber.centerXAnchor.constraint(equalTo: sheet.centerXAnchor),
            grabber.widthAnchor.constraint(equalToConstant: 58),
            grabber.heightAnchor.constraint(equalToConstant: 4),

            close.leadingAnchor.constraint(equalTo: sheet.leadingAnchor, constant: 24),
            close.topAnchor.constraint(equalTo: sheet.topAnchor, constant: 24),
            close.widthAnchor.constraint(equalToConstant: 28),
            close.heightAnchor.constraint(equalToConstant: 28),

            content.leadingAnchor.constraint(equalTo: sheet.leadingAnchor, constant: 24),
            content.trailingAnchor.constraint(equalTo: sheet.trailingAnchor, constant: -24),
            // Design: the content is pinned to the bottom of the tall sheet.
            isPad
                ? content.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -48)
                : content.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -14),
            icon.leadingAnchor.constraint(equalTo: iconRow.leadingAnchor),
            icon.topAnchor.constraint(equalTo: iconRow.topAnchor),
            icon.bottomAnchor.constraint(equalTo: iconRow.bottomAnchor),
            icon.heightAnchor.constraint(equalToConstant: 48),
            icon.widthAnchor.constraint(equalToConstant: 48),
            // Whole-point heights keep every element on a pixel boundary like the design.
            title.heightAnchor.constraint(equalToConstant: 28),
            detailHeight,
            guide.heightAnchor.constraint(equalToConstant: isPad ? 52 : 48),
            setup.heightAnchor.constraint(equalToConstant: isPad ? 52 : 48)
        ])
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // One line on a wide iPad, two on a phone: size the detail text to its wrapped height.
        let width = view.bounds.width - 48
        guard width > 0 else { return }
        let height = ceil(detailLabel.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude)).height)
        if abs(detailHeight.constant - height) > 0.5 { detailHeight.constant = height }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard !hasAnimatedIn else { return }
        // Start with the dim transparent and the sheet below the screen.
        dimView.alpha = 0
        view.layoutIfNeeded()
        sheetView.transform = CGAffineTransform(translationX: 0, y: view.bounds.height)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !hasAnimatedIn else { return }
        hasAnimatedIn = true
        UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseOut) {
            self.dimView.alpha = 1
            self.sheetView.transform = .identity
        }
    }

    private func makeButton(title: String, filled: Bool) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.layer.cornerRadius = isPad ? 26 : 24
        button.layer.borderWidth = filled ? 0 : 1
        button.layer.borderColor = UIColor.systemGray5.cgColor
        button.backgroundColor = filled ? teal : .white
        button.setTitleColor(filled ? .white : .darkGray, for: .normal)
        return button
    }

    /// The end state of the slide-out: dim faded away, sheet below the screen. Call it inside an animation block.
    func applySlideOutState() {
        dimView.alpha = 0
        sheetView.transform = CGAffineTransform(translationX: 0, y: view.bounds.height)
    }

    @objc private func dismissOverlay() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            self.applySlideOutState()
        }, completion: { _ in
            self.dismiss(animated: false)
        })
    }

    @objc private func showGuide() {
        let controller = StoreSetupGuideController(setupURL: setupURL)
        // Over the full screen (not replacing it) so "No Stores Found" stays underneath and can slide away with it.
        controller.modalPresentationStyle = .overFullScreen
        // Switch pages without the slide-up animation.
        present(controller, animated: false)
    }

    @objc private func openSetup() {
        guard let setupURL else { return }
        present(SFSafariViewController(url: setupURL), animated: true)
    }
}

/// A view whose own layer is the player layer, so the video always fills exactly the view's bounds
/// (a separately sized sublayer could be left at a stale size and crop the picture).
private final class GuidePlayerView: UIView {
    override class var layerClass: AnyClass { AVPlayerLayer.self }
    var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
}

private final class StoreSetupGuideController: UIViewController {
    private let setupURL: URL?
    private let teal = UIColor(red: 0.36, green: 0.78, blue: 0.756, alpha: 1)
    // A queue player with a looper plays each step video again and again without a gap.
    private let player = AVQueuePlayer()
    private var looper: AVPlayerLooper?
    private var page = 0
    // iPad layout follows the tablet design (sheet 80pt from the top, 40pt corners, 52pt buttons).
    private let isPad = UIDevice.current.userInterfaceIdiom == .pad

    private let titles = [
        "Open Store Setup",
        "Select a Store",
        "Configure Voucher Types",
        "Enable and Save",
        "Ready to Set Up Your Store?"
    ]
    private let messages = [
        "Select Setup > Quick Store Setup on the left side navigation bar.",
        "Choose the store you want to set up.",
        "Under POS, tap the edit icon to enable the voucher types supported by your store.",
        "1. Check the {checkbox} to enable the voucher type for your store.\n\n2. Set the voucher numbering format using a prefix, sequence number, and suffix.\n\n3. Tap Save to apply your changes.",
        "You've completed the guide. Now follow the steps to configure your store."
    ]
    private let videoNames = [
        "Step1_Open_Store_Setup",
        "Step2_Select_Location",
        "Step3_Edit_Voucher_Type",
        "Step4_Enable_and_Save"
    ]

    private let sheetView = UIView()
    private let videoView = GuidePlayerView()
    // Free space for the video: below the header, above the title (padding: 24 sides, 12 top, 48 bottom).
    private let videoArea = UILayoutGuide()
    private var dotWidthConstraints: [NSLayoutConstraint] = []
    private lazy var messageHeight: NSLayoutConstraint = messageLabel.heightAnchor.constraint(equalToConstant: 0)
    private var primaryBottomToSafe: NSLayoutConstraint!
    private var primaryBottomToSecondary: NSLayoutConstraint!
    private let completedIcon = UIImageView(image: UIImage(named: "check_circle") ?? UIImage(systemName: "checkmark.circle"))
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let primaryButton = UIButton(type: .system)
    private let secondaryButton = UIButton(type: .system)
    private let dots = UIStackView()

    init(setupURL: URL?) {
        self.setupURL = setupURL
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.66, green: 0.76, blue: 0.74, alpha: 1)
        makeLayout()
        updatePage(animated: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // The label's own intrinsic size can stay at the unwrapped height (one line per step) for this
        // attributed text, which clipped the last step. Give it the wrapped height explicitly.
        let messageWidth = view.bounds.width - 48
        guard messageWidth > 0 else { return }
        let wrappedHeight = ceil(messageLabel.sizeThatFits(
            CGSize(width: messageWidth, height: .greatestFiniteMagnitude)
        ).height)
        if abs(messageHeight.constant - wrappedHeight) > 0.5 {
            messageHeight.constant = wrappedHeight
        }
    }

    deinit { player.pause() }

    private func makeLayout() {
        let sheet = sheetView
        sheet.backgroundColor = .white
        sheet.layer.cornerRadius = isPad ? 40 : 34
        sheet.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        sheet.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sheet)

        let grabber = UIView()
        grabber.backgroundColor = UIColor(white: 0.8, alpha: 1)
        grabber.layer.cornerRadius = 2
        grabber.translatesAutoresizingMaskIntoConstraints = false
        sheet.addSubview(grabber)

        let back = UIButton(type: .system)
        back.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        back.tintColor = .darkGray
        back.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        back.translatesAutoresizingMaskIntoConstraints = false
        sheet.addSubview(back)

        dots.axis = .horizontal
        dots.alignment = .center
        dots.spacing = 4
        dots.translatesAutoresizingMaskIntoConstraints = false
        for _ in 0..<5 {
            let dot = UIView()
            dot.layer.cornerRadius = 2
            dot.translatesAutoresizingMaskIntoConstraints = false
            let width = dot.widthAnchor.constraint(equalToConstant: 16)
            width.isActive = true
            dotWidthConstraints.append(width)
            dot.heightAnchor.constraint(equalToConstant: 4).isActive = true
            dots.addArrangedSubview(dot)
        }
        sheet.addSubview(dots)

        videoView.backgroundColor = .white
        videoView.layer.cornerRadius = 8
        videoView.clipsToBounds = true
        videoView.translatesAutoresizingMaskIntoConstraints = false
        sheet.addSubview(videoView)

        // 1pt #E3E3E3 border drawn above the video, as in the design.
        let videoBorder = UIView()
        videoBorder.isUserInteractionEnabled = false
        videoBorder.layer.cornerRadius = 8
        videoBorder.layer.borderWidth = 1
        videoBorder.layer.borderColor = UIColor(white: 227.0 / 255.0, alpha: 1).cgColor
        videoBorder.translatesAutoresizingMaskIntoConstraints = false
        videoView.addSubview(videoBorder)
        NSLayoutConstraint.activate([
            videoBorder.topAnchor.constraint(equalTo: videoView.topAnchor),
            videoBorder.bottomAnchor.constraint(equalTo: videoView.bottomAnchor),
            videoBorder.leadingAnchor.constraint(equalTo: videoView.leadingAnchor),
            videoBorder.trailingAnchor.constraint(equalTo: videoView.trailingAnchor)
        ])

        completedIcon.tintColor = teal
        completedIcon.contentMode = .scaleAspectFit
        completedIcon.translatesAutoresizingMaskIntoConstraints = false
        sheet.addSubview(completedIcon)

        // Same typography as the "No Stores Found" sheet.
        titleLabel.font = .systemFont(ofSize: 23, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        // Keep the text at its natural height; the video takes the leftover space.
        titleLabel.setContentHuggingPriority(.required, for: .vertical)
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)

        messageLabel.font = .systemFont(ofSize: 14.5)
        messageLabel.textColor = .secondaryLabel
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.setContentHuggingPriority(.required, for: .vertical)
        messageLabel.setContentCompressionResistancePriority(.required, for: .vertical)

        primaryButton.layer.cornerRadius = isPad ? 26 : 24
        primaryButton.backgroundColor = teal
        primaryButton.setTitleColor(.white, for: .normal)
        primaryButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        primaryButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        primaryButton.translatesAutoresizingMaskIntoConstraints = false

        secondaryButton.layer.cornerRadius = isPad ? 26 : 24
        secondaryButton.layer.borderWidth = 1
        secondaryButton.layer.borderColor = UIColor.systemGray5.cgColor
        secondaryButton.setTitleColor(.darkGray, for: .normal)
        secondaryButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        secondaryButton.setTitle("Maybe Later", for: .normal)
        secondaryButton.addTarget(self, action: #selector(maybeLater), for: .touchUpInside)
        secondaryButton.translatesAutoresizingMaskIntoConstraints = false

        [titleLabel, messageLabel, primaryButton, secondaryButton].forEach(sheet.addSubview)

        // Positions measured from the design (Setup 6/8/9/10/11, 375x812). The sheet is as
        // tall as the "No Stores Found" sheet and the text is pinned above the button.
        sheet.addLayoutGuide(videoArea)
        // Video: always the video's own 3:4 shape (so nothing is cropped), as large as fits in the free
        // space between the header glyphs and the title glyphs with at least 24pt on each side, and centred
        // so the visible gap above equals the gap below (at least 24pt).
        let preferredHeight = videoView.heightAnchor.constraint(equalTo: videoArea.heightAnchor, constant: -48)
        preferredHeight.priority = .defaultHigh
        let preferredWidth = videoView.widthAnchor.constraint(equalTo: videoArea.widthAnchor)
        preferredWidth.priority = .defaultHigh
        // The title glyphs start ~5pt below the label top, so measure the bottom gap to them.
        let areaBottom = videoArea.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: 5)
        areaBottom.priority = UILayoutPriority(999)
        if isPad {
            // Tablet design: video 82pt below the sheet top, always 3:4, centred, ending 57pt above the title glyphs.
            let bottom = videoView.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -52)
            bottom.priority = UILayoutPriority(999)
            NSLayoutConstraint.activate([
                videoView.topAnchor.constraint(equalTo: sheet.topAnchor, constant: 82),
                videoView.centerXAnchor.constraint(equalTo: sheet.centerXAnchor),
                videoView.widthAnchor.constraint(equalTo: videoView.heightAnchor, multiplier: 0.75),
                videoView.heightAnchor.constraint(greaterThanOrEqualToConstant: 0),
                bottom,
                // The free space (header glyphs to title glyphs) is also used to centre the last page's check circle.
                videoArea.topAnchor.constraint(equalTo: sheet.topAnchor, constant: 47),
                videoArea.heightAnchor.constraint(greaterThanOrEqualToConstant: 0),
                areaBottom
            ])
        } else {
            NSLayoutConstraint.activate([
                // Header glyphs (back arrow, dots) end ~47pt below the sheet top.
                videoArea.topAnchor.constraint(equalTo: sheet.topAnchor, constant: 47),
                videoArea.leadingAnchor.constraint(equalTo: sheet.leadingAnchor, constant: 24),
                videoArea.trailingAnchor.constraint(equalTo: sheet.trailingAnchor, constant: -24),
                videoArea.heightAnchor.constraint(greaterThanOrEqualToConstant: 0),
                areaBottom,
                videoView.centerXAnchor.constraint(equalTo: videoArea.centerXAnchor),
                videoView.centerYAnchor.constraint(equalTo: videoArea.centerYAnchor),
                videoView.widthAnchor.constraint(equalTo: videoView.heightAnchor, multiplier: 0.75),
                videoView.widthAnchor.constraint(lessThanOrEqualTo: videoArea.widthAnchor),
                videoView.heightAnchor.constraint(lessThanOrEqualTo: videoArea.heightAnchor, constant: -48),
                preferredWidth,
                preferredHeight
            ])
        }
        primaryBottomToSafe = isPad
            ? primaryButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -48)
            : primaryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -14)
        primaryBottomToSecondary = primaryButton.bottomAnchor.constraint(
            equalTo: secondaryButton.topAnchor, constant: -12
        )

        NSLayoutConstraint.activate([
            sheet.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sheet.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sheet.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            isPad
                ? sheet.topAnchor.constraint(equalTo: view.topAnchor, constant: 80)
                : sheet.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25),

            grabber.topAnchor.constraint(equalTo: sheet.topAnchor, constant: 5),
            grabber.centerXAnchor.constraint(equalTo: sheet.centerXAnchor),
            grabber.widthAnchor.constraint(equalToConstant: 58),
            grabber.heightAnchor.constraint(equalToConstant: 4),

            // Design: the arrow glyph is centred 37pt from the left edge.
            back.leadingAnchor.constraint(equalTo: sheet.leadingAnchor, constant: 19),
            back.topAnchor.constraint(equalTo: sheet.topAnchor, constant: 20),
            back.widthAnchor.constraint(equalToConstant: 36),
            back.heightAnchor.constraint(equalToConstant: 36),
            dots.centerXAnchor.constraint(equalTo: sheet.centerXAnchor),
            dots.centerYAnchor.constraint(equalTo: back.centerYAnchor),

            completedIcon.centerXAnchor.constraint(equalTo: sheet.centerXAnchor),
            // The design asset is 200pt with 27pt of padding, so the 146pt circle sits at y 261-406.
            // Centred in the free space between the header and the title (the 200pt asset has even padding).
            completedIcon.centerYAnchor.constraint(equalTo: videoArea.centerYAnchor),
            completedIcon.widthAnchor.constraint(equalToConstant: isPad ? 252 : 200),
            completedIcon.heightAnchor.constraint(equalToConstant: isPad ? 252 : 200),

            titleLabel.leadingAnchor.constraint(equalTo: sheet.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: sheet.trailingAnchor, constant: -24),
            messageLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            messageLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 13),
            messageLabel.bottomAnchor.constraint(equalTo: primaryButton.topAnchor, constant: -24),
            messageHeight,

            secondaryButton.leadingAnchor.constraint(equalTo: sheet.leadingAnchor, constant: 24),
            secondaryButton.trailingAnchor.constraint(equalTo: sheet.trailingAnchor, constant: -24),
            isPad
                ? secondaryButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -48)
                : secondaryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -14),
            secondaryButton.heightAnchor.constraint(equalToConstant: isPad ? 52 : 48),
            primaryButton.leadingAnchor.constraint(equalTo: secondaryButton.leadingAnchor),
            primaryButton.trailingAnchor.constraint(equalTo: secondaryButton.trailingAnchor),
            primaryButton.heightAnchor.constraint(equalToConstant: isPad ? 52 : 48)
        ])
    }

    private func updatePage(animated: Bool) {
        titleLabel.text = titles[page]
        messageLabel.attributedText = messageText(for: page)
        // Buttons, text and icons switch instantly: only the progress bars animate (no fading title/colour).
        UIView.performWithoutAnimation {
            // Last page: two buttons, otherwise one button at the bottom.
            primaryBottomToSecondary.isActive = false
            primaryBottomToSafe.isActive = false
            (page == 4 ? primaryBottomToSecondary : primaryBottomToSafe).isActive = true
            primaryButton.setTitle(page == 4 ? "Start Setup  →" : "Next", for: .normal)
            secondaryButton.isHidden = page != 4
            completedIcon.isHidden = page != 4
            videoView.isHidden = page == 4
            primaryButton.layoutIfNeeded()
            view.layoutIfNeeded()
        }
        // Design: current page is a 24x4 #2A2A2A bar, the others are 16x4 #D9D9D9.
        let applyDots = {
            for (index, dot) in self.dots.arrangedSubviews.enumerated() {
                dot.backgroundColor = index == self.page
                    ? UIColor(red: 42.0 / 255.0, green: 42.0 / 255.0, blue: 42.0 / 255.0, alpha: 1)
                    : UIColor(red: 217.0 / 255.0, green: 217.0 / 255.0, blue: 217.0 / 255.0, alpha: 1)
                self.dotWidthConstraints[index].constant = index == self.page ? 24 : 16
            }
            self.dots.layoutIfNeeded()
        }
        if animated {
            UIView.animate(withDuration: 0.2, animations: applyDots)
        } else {
            applyDots()
        }
        player.pause()
        looper?.disableLooping()
        looper = nil
        player.removeAllItems()
        if page < videoNames.count,
           let url = Bundle.main.url(forResource: videoNames[page], withExtension: "mp4", subdirectory: "StoreSetupVideo") {
            // Show the whole 3:4 frame; the border view sits above the video.
            videoView.playerLayer.player = player
            videoView.playerLayer.videoGravity = .resizeAspect
            looper = AVPlayerLooper(player: player, templateItem: AVPlayerItem(url: url))
            player.play()
        }
    }

    /// Message text with a 21pt line height. Numbered steps ("1. ...") get a hanging indent like the design.
    private func messageText(for page: Int) -> NSAttributedString {
        let style = NSMutableParagraphStyle()
        style.minimumLineHeight = 21
        style.maximumLineHeight = 21
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14.5),
            .foregroundColor: UIColor.secondaryLabel,
            .paragraphStyle: style
        ]
        let steps = messages[page].components(separatedBy: "\n\n")
        let isNumberedList = steps.count > 1 && steps.allSatisfy { $0.range(of: #"^\d+\. "#, options: .regularExpression) != nil }
        guard isNumberedList else {
            return attributedString(messages[page], attributes: attributes)
        }
        style.firstLineHeadIndent = 7.5
        style.headIndent = 24.5
        style.paragraphSpacing = 8
        style.tabStops = [NSTextTab(textAlignment: .left, location: 24.5)]
        let text = steps.map { step -> String in
            guard let dot = step.range(of: ". ") else { return step }
            return step.replacingCharacters(in: dot, with: ".\t")
        }.joined(separator: "\n")
        return attributedString(text, attributes: attributes)
    }

    /// Replaces the `{checkbox}` token with the teal checked box shown in the design.
    private func attributedString(_ text: String, attributes: [NSAttributedString.Key: Any]) -> NSAttributedString {
        let result = NSMutableAttributedString(string: text, attributes: attributes)
        let token = (text as NSString).range(of: "{checkbox}")
        guard token.location != NSNotFound else { return result }
        let attachment = NSTextAttachment()
        attachment.image = checkboxImage()
        // Sit the 16pt box on the text baseline like the design.
        attachment.bounds = CGRect(x: 0, y: -3, width: 16, height: 16)
        let attachmentString = NSMutableAttributedString(attachment: attachment)
        attachmentString.addAttributes(attributes, range: NSRange(location: 0, length: attachmentString.length))
        result.replaceCharacters(in: token, with: attachmentString)
        return result
    }

    private func checkboxImage() -> UIImage {
        let size = CGSize(width: 16, height: 16)
        return UIGraphicsImageRenderer(size: size).image { _ in
            teal.setFill()
            UIBezierPath(roundedRect: CGRect(origin: .zero, size: size), cornerRadius: 3.5).fill()
            let check = UIImage(systemName: "checkmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 10, weight: .bold))?
                .withTintColor(.white, renderingMode: .alwaysOriginal)
            check?.draw(in: CGRect(x: 3, y: 3.5, width: 10, height: 9).insetBy(dx: 0, dy: 0))
        }
    }

    @objc private func nextTapped() {
        if page == 4 {
            guard let setupURL else { return }
            present(SFSafariViewController(url: setupURL), animated: true)
            return
        }
        page += 1
        updatePage(animated: true)
    }

    @objc private func backTapped() {
        // Back from the first page switches to "No Stores Found" without the slide-down animation.
        if page == 0 { dismiss(animated: false) }
        else { page -= 1; updatePage(animated: true) }
    }

    @objc private func maybeLater() {
        // Close every popup (guide and "No Stores Found"): both sheets slide down together, then return to the login screen.
        var base: UIViewController = self
        while let presenter = base.presentingViewController { base = presenter }
        let noStores = presentingViewController as? StoreSetupEmptyStateController
        view.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            self.sheetView.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height)
            self.view.backgroundColor = .clear
            noStores?.applySlideOutState()
        }, completion: { _ in
            base.dismiss(animated: false)
        })
    }
}
