//
//  LoginController.swift
//  GIS
//
//  Created by Apple Hawkscode on 16/10/20.
//

import UIKit
import Alamofire
import Security


public class StoreItem: UITableViewCell {
    
    @IBOutlet weak var mStoreName: UILabel!
    @IBOutlet weak var mStoreDomain: UILabel!
    @IBOutlet weak var mSelect: UIButton!
    public override func awakeFromNib() {
        super.awakeFromNib()
    }
    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
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
    private let mOrganizationSubtitle = UILabel()
    
    
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
        mStoreView.layer.cornerRadius = 20
        mStoreView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        
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

    private func configureOrganizationSheetHeader() {
        mStoreHeader.text = "Organization"
        mStoreHeader.textColor = UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1.0)
        mStoreHeader.font = UIFont(name: "SegoeUI-Semibold", size: 20)
            ?? UIFont.systemFont(ofSize: 20, weight: .semibold)

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
                constant: 8
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
        mStoreHeader.text = "Choose Store"
        mOrganizationSubtitle.isHidden = true
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

    private func dismissStoreContentView() {
        self.mStoreContentView.slideTop()
        self.mStoreContentView.isHidden = true
        configureOrganizationSheetHeader()
        self.mKey = ""
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
            defer {
                CommonClass.stopLoader()
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
                        self.mKey = "org"
                        self.configureOrganizationSheetHeader()
                        self.mStoreData = orgData
                        self.mStoreTableView.delegate = self
                        self.mStoreTableView.dataSource = self
                        self.mStoreTableView.reloadData()
                        self.mStoreContentView.isHidden = false
                        self.mStoreContentView.slideFromBottom()
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
            print("mFetchStoresLocations urlPath = \(urlPath)")
            AF.request(urlPath, method:.post, parameters: ["":""],headers: sFetchStoreHeader).responseJSON
            { response in
                print("mFetchStoresLocations response = \(response)")
                if(response.error != nil){
                    
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
                        if let mStoreData = jsonResult.value(forKey: "data") as? NSArray {
                            if mStoreData.count == 0 {
                                CommonClass.showSnackBar(message: "No Stores available!")
                                
                                return
                            }
                            UserDefaults.standard.set(jsonResult, forKey: "storeData")
                            self.mKey = "store"
                            self.configureStoreSheetHeader()
                            self.mStoreData = mStoreData
                            self.mStoreTableView.delegate = self
                            self.mStoreTableView.dataSource = self
                            self.mStoreTableView.reloadData()
                            self.mStoreContentView.isHidden = false
                        }else{
                            CommonClass.showSnackBar(message: "No Stores available!")
                            return
                        }
                    } else if jsonResult.value(forKey: "code") as? Int == 400 {
                        
                        CommonClass.showSnackBar(message: "No Stores available!")
                    }
                    
                }
                
                
            }
        }else{
            CommonClass.showSnackBar(message: "No Internet Connection!")
        }
        
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
                print("mGeneratePOSToken response = \(response)")
                if(response.error != nil){
                    
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
                    
                    cells.mStoreName.text = mData.value(forKey: "voucher_name") as? String
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
//            if let orgId = mData.value(forKey: "organization_id") as? String{
//                mOrgId = orgId
//                mLoginWithPassword(org_id: orgId)
//                UserDefaults.standard.set(orgId, forKey: "organization_id")
//            }
            if let orgId = mData["organization_id"] as? String {

                mOrgId = orgId

                UserDefaults.standard.set(orgId, forKey: "organization_id")
                UserDefaults.standard.set(mData["domain"], forKey: "website_url")

                mLoginWithPassword(org_id: orgId)
            }
        }else if mKey == "store"{
            
            if let location = mData.value(forKey: "location_id") as? String,
               let locationName = mData.value(forKey: "location_name") as? String {
                
                mCurrency = "\(mData.value(forKey: "currency") ?? "")"
                mLocationId = "\(mData.value(forKey: "location_id") ?? "")"
                mVoucherId = "\(mData.value(forKey: "voucher_id") ?? "")"
                
                UserDefaults.standard.setValue("\(mCurrency)", forKey: "posCurrency")
                UserDefaults.standard.setValue("\(mLocationId)", forKey: "posLocation")
                UserDefaults.standard.setValue("\(mVoucherId)", forKey: "posVoucher")
                UserDefaults.standard.setValue("\(location)", forKey: "location")
                UserDefaults.standard.setValue("\(locationName)", forKey: "locationName")
                
                // Require the normal login PIN after selecting the Store.
                if self.mRequiresOrganizationStorePin {
                    // Organization switcher: require PIN or Face ID after Store selection.
                    let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                    guard let pinController = storyBoard.instantiateViewController(
                        withIdentifier: "LoginWithPin"
                    ) as? LoginWithPin else {
                        CommonClass.showSnackBar(message: "Unable to open PIN screen.")
                        return
                    }

                    pinController.mRequiresOrganizationStorePin = true
                    self.navigationController?.pushViewController(pinController, animated: true)
                } else {
                    // Normal Email + Password login: enter directly after Store selection.
                    self.mGeneratePOSToken()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
        
    }
}
