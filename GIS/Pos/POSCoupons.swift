//
//  POSCoupons.swift
//  GIS
//
//  Created by Apple Hawkscode on 21/09/21.
//

import UIKit
import DropDown
import Alamofire

class POSCoupons: UIViewController ,GetCustomerDataDelegate, UIViewControllerTransitioningDelegate  {
    
    @IBOutlet weak var mCouponValidity: UITextField!
    @IBOutlet weak var mCouponNumber: UITextField!
    @IBOutlet weak var mCouponAmount: UITextField!
    @IBOutlet weak var mCouponCurrency: UILabel!
    @IBOutlet weak var mCouponRemarks: UITextField!
    @IBOutlet weak var mCouponName: UITextField!
    var mCurrencyImageData = [String]()
    var mCurrencyNameData = [String]()
    
    @IBOutlet weak var mCustomerName: UILabel!
    @IBOutlet weak var mCustomerImage: UIImageView!
    @IBOutlet weak var mSelectedCustomerIcon: UIImageView!
    var mCustomerId = ""
    var mCurrency = ""
    
    @IBOutlet weak var mCurrencyImage: UIImageView!
    var isEdit = ""
    var mCouponId = ""
    var mCCouponName = ""
    
    var mCCouponCode = ""
    var mCustomerNames = ""
    
    var mCCouponValidity = ""
    var mCCouponAmount = ""
    var mCCouponRemark = ""
    var mCCouponCurrency = ""
    var mDatePicker:UIDatePicker = UIDatePicker()
    
    @IBOutlet weak var mChooseCurrencyButt: UIButton!
    @IBOutlet weak var mGiftCardNumberLABEL: UILabel!
    @IBOutlet weak var mValidDateLABEL: UILabel!
    
    @IBOutlet weak var mAddGiftCardLABEL: UILabel!
    
    @IBOutlet weak var mGiftCardNameLABEL: UILabel!
    @IBOutlet weak var mHeaderLABEL: UILabel!
    
    @IBOutlet weak var mAmountLABEL: UILabel!
    var mStoreCurrency = ""

    @IBOutlet weak var mCreateBUTTON: UIButton!

    // MARK: - Remarks Suggestions
    private var mRemarksSuggestionsView: UIView?
    private var mRemarksSuggestionButtons: [UIButton] = []

    // The popup must keep the position it had when Remarks was tapped.
    // When the keyboard appears UIKit may move the form/Remarks, but the
    // Suggestions popup must NOT follow that movement.
    private var mRemarksSuggestionsLockedFrame: CGRect?
    private var mRemarksClearButton: UIButton?
    private var mIsSelectingRemarkSuggestion = false
    @IBOutlet weak var mCustomerLABEL: UILabel!
    
    @IBOutlet weak var mAddressPickerIcon: UIImageView!
    @IBOutlet weak var mAddressPickerAlertIcon: UIImageView!
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let mStoreCurr = UserDefaults.standard.string(forKey: "storeCurrency") {
            mStoreCurrency = mStoreCurr
        }
        mGetCurrency()
        mGiftCardNameLABEL.text = "Gift Card Name".localizedString
        mAmountLABEL.text = "Amount".localizedString
        mCreateBUTTON.setTitle("create".localizedString , for: .normal)
        mCouponName.placeholder = "Happy Birthday".localizedString
        mCouponRemarks.placeholder = "Remarks".localizedString
        mHeaderLABEL.text = "Gift Card".localizedString
        mCustomerLABEL.text = "Customer".localizedString
        mGiftCardNumberLABEL.text = "Gift Card Number".localizedString
        mValidDateLABEL.text = "Valid Date".localizedString
        
        
        mCustomerId  = UserDefaults.standard.string( forKey: "DEFAULTCUSTOMER") ?? ""
        self.mSelectedCustomerIcon.image = UIImage(named: "selected_customer")
        self.mCustomerImage.contentMode = .scaleAspectFill
        self.mCustomerImage.downlaodImageFromUrl(urlString: UserDefaults.standard.string( forKey: "DEFAULTCUSTOMERPICTURE") ?? "")
        self.mCustomerName.text = UserDefaults.standard.string( forKey: "DEFAULTCUSTOMERNAME") ?? ""
        self.mCustomerName.isHidden = false
        
        if mCustomerId == "" {
            mOpenCustomerSheet()
        } else {
            mCheckAddresse()
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Keep the Suggestions popup positioned relative to Remarks.
        // IMPORTANT: Do NOT move self.view when the keyboard appears.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(notification:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(notification:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )

        
        mCouponAmount.keyboardType = .numberPad
        setupRemarksSuggestions()
        setupRemarksClearButton()
        mCurrencyImage.layer.cornerRadius = 0

        if isEdit != "" {
            
            if let mData = UserDefaults.standard.object(forKey: "EDITCARD") as? NSDictionary {
                self.mCouponName.text = "\(mData.value(forKey: "name") ?? "" )"
                self.mCouponNumber.text = "\(mData.value(forKey: "card_no") ?? "" )"
                self.mCouponRemarks.text = "\(mData.value(forKey: "remark") ?? "" )"
                self.mCouponValidity.text = "\(mData.value(forKey: "expire_date") ?? "" )"
                self.mCouponAmount.text = "\(mData.value(forKey: "amount") ?? "" )"
                self.mCouponId = "\(mData.value(forKey: "custom_cart_id") ?? "" )"
            }
            
        }
        self.mCouponCurrency.text = "\(UserDefaults.standard.string(forKey: "currencySymbol") ?? "")"
        mShowDatePicker()
        
    }
    
    
    
    
    
    override func viewDidLayoutSubviews() {
        
        self.view.applyGradient(withColours: [#colorLiteral(red: 0.9607843137, green: 0.9411764706, blue: 0.9098039216, alpha: 1),#colorLiteral(red: 0.7803921569, green: 0.7803921569, blue: 0.7803921569, alpha: 1)], gradientOrientation: .vertical)
        
        
    }
    
    
    @objc func keyboardWillShow(notification: Notification) {
        // DO NOT recalculate the popup from mCouponRemarks here.
        //
        // UIKit can move Remarks when the keyboard appears. The Suggestions
        // popup was already positioned in window coordinates before that
        // movement, so it must stay at that exact screen position.
        guard let popup = mRemarksSuggestionsView,
              let lockedFrame = mRemarksSuggestionsLockedFrame else {
            return
        }
        
        guard let window = view.window else { return }
        let fieldFrame = mCouponRemarks.convert(
            mCouponRemarks.bounds,
            to: window
        )
        print("keyboardWillShow popup.frame = \(popup.frame)")
        print("keyboardWillShow mCouponRemarks.frame = \(fieldFrame)")
        popup.frame = lockedFrame
        print("keyboardWillShow popup.frame = \(popup.frame)")
        print("keyboardWillShow mCouponRemarks.frame = \(fieldFrame)")
    }

    @objc func keyboardWillHide(notification: Notification) {
        // Keep the popup locked while it exists. Normally the popup is hidden
        // when editing ends/selection is made, so there is nothing to move.
        guard let popup = mRemarksSuggestionsView,
              let lockedFrame = mRemarksSuggestionsLockedFrame else {
            return
        }
        print("keyboardWillHide popup.frame = \(popup.frame)")
        print("keyboardWillHide mCouponRemarks.frame = \(mCouponRemarks.frame)")
        popup.frame = lockedFrame
        print("keyboardWillHide popup.frame = \(popup.frame)")
        print("keyboardWillHide mCouponRemarks.frame = \(mCouponRemarks.frame)")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }


    // MARK: - Remarks Suggestions

    private func setupRemarksSuggestions() {
        mCouponRemarks.clearButtonMode = .never
        mCouponRemarks.addTarget(self,
                                 action: #selector(remarksEditingDidBegin),
                                 for: .editingDidBegin)
        // Only real text editing should trigger filtering.
        mCouponRemarks.addTarget(self,
                                 action: #selector(remarksEditingChanged),
                                 for: .editingChanged)
    }

    private func setupRemarksClearButton() {
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .systemGray3
        button.addTarget(self,
                         action: #selector(clearRemarksAndDismiss),
                         for: .touchUpInside)
        button.accessibilityLabel = "Clear remarks"

        let container = UIView(frame: CGRect(x: 0, y: 0, width: 34, height: 30))
        button.center = CGPoint(x: container.bounds.midX, y: container.bounds.midY)
        container.addSubview(button)

        mRemarksClearButton = button
        mCouponRemarks.rightView = container
        mCouponRemarks.rightViewMode = .whileEditing
    }

    @objc private func remarksEditingDidBegin() {
        guard mCouponRemarks.isFirstResponder else { return }

        let text = (mCouponRemarks.text ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        if text.isEmpty {
            showRemarksSuggestions(currentRemarksSuggestions())
        } else {
            updateRemarksSuggestions(for: text)
        }
    }

    @objc private func remarksEditingChanged() {
        guard !mIsSelectingRemarkSuggestion else { return }

        let text = (mCouponRemarks.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        if text.isEmpty {
            hideRemarksSuggestions()
        } else {
            updateRemarksSuggestions(for: text)
        }
    }

    @objc private func clearRemarksAndDismiss() {
        mIsSelectingRemarkSuggestion = true
        mCouponRemarks.text = ""
        hideRemarksSuggestions()

        // Required behavior: clear -> close Suggestions -> hide keyboard ->
        // Remarks is no longer the first responder.
        mCouponRemarks.resignFirstResponder()
        view.endEditing(true)

        mIsSelectingRemarkSuggestion = false
    }

    @objc private func handleRemarksOutsideTap(_ gesture: UITapGestureRecognizer) {
        guard gesture.state == .ended else { return }

        guard let window = view.window else {
            hideRemarksSuggestions()
            view.endEditing(true)
            return
        }

        let pointInWindow = gesture.location(in: window)

        // Popup is hosted directly in UIWindow, so its frame is already
        // in window coordinates.
        if let popup = mRemarksSuggestionsView,
           popup.frame.contains(pointInWindow) {
            return
        }

        let remarksFrame = mCouponRemarks.convert(
            mCouponRemarks.bounds,
            to: window
        )

        if !remarksFrame.contains(pointInWindow) {
            hideRemarksSuggestions()
            view.endEditing(true)
        }
    }

    private func currentRemarksSuggestions() -> [String] {
        var validDate = (mCouponValidity.text ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        // If Valid Date has not been selected yet, use today's date.
        if validDate.isEmpty {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US")
            formatter.calendar = Calendar(identifier: .gregorian)
            formatter.dateFormat = "dd/MM/yyyy"
            validDate = formatter.string(from: Date())
        }

        return [
            "Promotional use",
            "Customer request",
            "Valid until \(validDate)",
            "Customer appreciation"
        ]
    }

    private func updateRemarksSuggestions(for searchText: String) {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !query.isEmpty else {
            hideRemarksSuggestions()
            return
        }

        let suggestions = currentRemarksSuggestions().filter {
            $0.range(of: query,
                      options: [.caseInsensitive, .diacriticInsensitive]) != nil
        }

        // No match -> hide the whole popup, including "Suggestions".
        guard !suggestions.isEmpty else {
            hideRemarksSuggestions()
            return
        }

        showRemarksSuggestions(suggestions)
    }

    private func showRemarksSuggestions(_ suggestions: [String]) {
        hideRemarksSuggestions()

        // IMPORTANT:
        // Put the popup in UIWindow, not inside the Gift Card form.
        // The form/container can clip anything that extends above Remarks.
        // Using the window coordinate system also keeps the popup anchored
        // to the actual on-screen position of Remarks while the keyboard moves.
        guard let window = view.window else { return }

        let popup = UIView()
        popup.backgroundColor = .white
        popup.layer.cornerRadius = 8
        popup.layer.masksToBounds = false
        popup.layer.shadowColor = UIColor.black.cgColor
        popup.layer.shadowOpacity = 0.12
        popup.layer.shadowOffset = CGSize(width: 0, height: 2)
        popup.layer.shadowRadius = 5

        let popupWidth: CGFloat = 172
        let headerHeight: CGFloat = 32
        let rowHeight: CGFloat = 36
        let popupHeight = headerHeight + CGFloat(suggestions.count) * rowHeight + 8
        let gap: CGFloat = 12

        // Use WINDOW coordinates. This is deliberately calculated from the
        // visible Remarks field, not from the form's superview/frame.
        let fieldFrame = mCouponRemarks.convert(
            mCouponRemarks.bounds,
            to: window
        )

        let x = max(8, min(
            fieldFrame.minX,
            window.bounds.width - popupWidth - 8
        ))

        // Exact relationship requested by the reference image:
        // popup bottom sits just above the Remarks field.
        let y = fieldFrame.minY - popupHeight - gap - 104

        let popupFrame = CGRect(
            x: x,
            y: y,
            width: popupWidth,
            height: popupHeight
        )

        print("showRemarksSuggestions popup.frame = \(popup.frame)")
        print("showRemarksSuggestions mCouponRemarks.frame = \(fieldFrame)")
        popup.frame = popupFrame
        print("showRemarksSuggestions popup.frame = \(popup.frame)")
        print("showRemarksSuggestions mCouponRemarks.frame = \(fieldFrame)")
        // LOCK the screen position now, BEFORE the keyboard moves Remarks.
        // From this point on keyboardWillShow must never derive a new Y from
        // mCouponRemarks.
        mRemarksSuggestionsLockedFrame = popupFrame

        window.addSubview(popup)
        window.bringSubviewToFront(popup)

        mRemarksSuggestionsView = popup
        mRemarksSuggestionButtons.removeAll()

        let title = UILabel(frame: CGRect(
            x: 16,
            y: 0,
            width: popupWidth - 32,
            height: headerHeight
        ))
        title.text = "Suggestions"
        title.font = segoeUIFont(size: 13, weight: .bold)
        title.textColor = .label
        popup.addSubview(title)

        for (index, suggestion) in suggestions.enumerated() {
            let button = UIButton(type: .system)
            button.frame = CGRect(
                x: 18,
                y: headerHeight + CGFloat(index) * rowHeight,
                width: popupWidth - 26,
                height: rowHeight
            )
            button.contentHorizontalAlignment = .left
            button.contentEdgeInsets = UIEdgeInsets(
                top: 0,
                left: 8,
                bottom: 0,
                right: 2
            )
            button.titleLabel?.font = segoeUIFont(size: 12, weight: .regular)
            button.setTitleColor(.darkGray, for: .normal)
            button.setTitle(suggestion, for: .normal)
            button.tag = index
            button.addTarget(
                self,
                action: #selector(selectRemarksSuggestion(_:)),
                for: .touchUpInside
            )
            popup.addSubview(button)
            mRemarksSuggestionButtons.append(button)
        }
    }

    private func positionRemarksSuggestionsPopup(animatedDuration: TimeInterval = 0) {
        guard let popup = mRemarksSuggestionsView,
              let window = view.window else {
            return
        }

        // If the popup has already been shown, its position is locked.
        // Never derive a new position from Remarks while the keyboard is up.
        if let lockedFrame = mRemarksSuggestionsLockedFrame {
            if animatedDuration > 0 {
                UIView.animate(
                    withDuration: animatedDuration,
                    delay: 0,
                    options: [.beginFromCurrentState, .curveEaseInOut, .allowUserInteraction]
                ) {
                    popup.frame = lockedFrame
                }
            } else {
                popup.frame = lockedFrame
            }

            window.bringSubviewToFront(popup)
            return
        }

        // Fallback: only used if this method is called before the popup has
        // been locked.
        let fieldFrame = mCouponRemarks.convert(
            mCouponRemarks.bounds,
            to: window
        )

        let width = popup.bounds.width
        let height = popup.bounds.height
        let gap: CGFloat = 12

        let x = max(8, min(
            fieldFrame.minX,
            window.bounds.width - width - 8
        ))

        let y = fieldFrame.minY - height - gap

        let newFrame = CGRect(
            x: x,
            y: y,
            width: width,
            height: height
        )

        popup.frame = newFrame
        mRemarksSuggestionsLockedFrame = newFrame
        window.bringSubviewToFront(popup)
    }

    @objc private func selectRemarksSuggestion(_ sender: UIButton) {
        guard let title = sender.title(for: .normal), !title.isEmpty else {
            return
        }

        // Keep the selection operation isolated from editingChanged.
        // Sending .editingChanged here could immediately rebuild/filter
        // the Suggestions popup and make the selected value appear
        // intermittently missing.
        mIsSelectingRemarkSuggestion = true

        // 1. Put the selected value directly into Remarks.
        mCouponRemarks.text = title

        // 2. Close Suggestions immediately.
        hideRemarksSuggestions()

        // 3. Remove focus and keyboard immediately.
        mCouponRemarks.resignFirstResponder()
        view.endEditing(true)

        mIsSelectingRemarkSuggestion = false
    }

    private func hideRemarksSuggestions() {
        mRemarksSuggestionsView?.removeFromSuperview()
        mRemarksSuggestionsView = nil
        mRemarksSuggestionButtons.removeAll()
        mRemarksSuggestionsLockedFrame = nil
    }

    private func segoeUIFont(size: CGFloat, weight: UIFont.Weight) -> UIFont {
        if weight == .bold {
            return UIFont(name: "segoe_bold", size: size)
                ?? UIFont.systemFont(ofSize: size, weight: weight)
        }

        return UIFont(name: "segoe_regular", size: size)
            ?? UIFont.systemFont(ofSize: size, weight: weight)
    }

    func mGetCurrency(){
        print("7")
        let urlPath = mGetCurrencies
        if Reachability.isConnectedToNetwork() == true {
            AF.request(urlPath, method:.post, parameters:nil, headers: sGisHeaders2).responseJSON
            { response in
                
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
                    
                    if let data = jsonResult.value(forKey: "data") as? NSArray {
                        self.mCurrencyNameData = [String]()
                        self.mCurrencyImageData = [String]()
                        for i in data {
                            
                            if let currencyData = i as? NSDictionary {
                                if let currency = currencyData.value(forKey:"currency") , let locationData = currencyData.value(forKey:"url") {
                                    self.mCurrencyNameData.append("\(currency)")
                                    self.mCurrencyImageData.append("\(locationData)")
                                    
                                    if "\(currency)" == self.mStoreCurrency {
                                        
                                        self.mCurrencyImage.downlaodImageFromUrl(urlString: "\(locationData)")
                                        self.mCouponCurrency.text =  "\(currency)"
                                        self.mCurrency = "\(currency)"
                                    }
                                }
                            }
                        }
                    }
                }
                
            }
        }else{
            CommonClass.showSnackBar(message: "No Internet Connection")
        }
        
        
    }
    
    
    @IBAction func mBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func mAddCoupon(_ sender: Any) {
    }
    
    
    @IBAction func mCheckout(_ sender: Any) {
    }
    
    
    @IBAction func mOpenAddressPicker(_ sender: Any) {
        if !mCustomerId.isEmpty {
            let storyBoard: UIStoryboard = UIStoryboard(name: "AddressPicker", bundle: nil)
            if let addressPicker = storyBoard.instantiateViewController(withIdentifier: "AddressPicker") as? AddressPicker {
                addressPicker.mCustomerId = mCustomerId
                self.navigationController?.pushViewController(addressPicker, animated: true)
            }
        }
    }
    
    
    @IBAction func mMyCoupons(_ sender: Any) {
        
        if mCustomerId != "" {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            
            if let mCoupons = storyBoard.instantiateViewController(withIdentifier: "POSAllCoupons") as? POSAllCoupons {
                mCoupons.mCustomerId = self.mCustomerId
                self.navigationController?.pushViewController(mCoupons, animated:true)
            }
        }else{
            CommonClass.showSnackBar(message: "Please choose Customer!")
        }
    }
    @IBAction func mChooseCustomer(_ sender: Any) {
        mOpenCustomerSheet()
    }
    func mCreateNewCustomer() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "reserveBoard", bundle: nil)
        if let mCreateCustomer = storyBoard.instantiateViewController(withIdentifier: "CreateCustomer") as? CreateCustomer {
            self.navigationController?.pushViewController(mCreateCustomer, animated:true)
        }
    }
    
    func mCheckAddresse() {
        
        guard Reachability.isConnectedToNetwork() == true else {
            return
        }
        
        let params = ["id": mCustomerId] as [String : Any]
        
        AF.request(mCheckAddress, method:.post,parameters: params,encoding: JSONEncoding.default, headers: sGisHeaders).responseJSON { response in
            
            guard let jsonData = response.data else {
                return
            }
            
            do {
                guard let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
                      let code = json["code"] as? Int else {
                    return
                }
                
                switch code {
                case 200:
                    if let haveAddress = json["AddressExists"] as? Bool, haveAddress {
                        self.mAddressPickerIcon.image = UIImage(named: "address_pick_ic_green")
                        self.mAddressPickerAlertIcon.isHidden = true
                    } else {
                        self.mAddressPickerIcon.image = UIImage(named: "address_pick_ic_green")
                        self.mAddressPickerAlertIcon.isHidden = false
                    }
                case 403:
                    CommonClass.sessionExpired(isExpired: true, navigation: self.navigationController)
                default:
                    break
                }
            } catch {
            }
        }
        
    }
    
    func mGetCustomerData(data: NSMutableDictionary) {
        
        if let id = data.value(forKey: "id") as? String {
            UserDefaults.standard.set(id, forKey: "DEFAULTCUSTOMER")
            self.mCustomerId = id
        }
        
        let profile = data.value(forKey: "profile") as? String ?? ""
        UserDefaults.standard.set(profile, forKey: "DEFAULTCUSTOMERPICTURE")
        
        if let name = data.value(forKey: "name") as? String {
            UserDefaults.standard.set(name, forKey: "DEFAULTCUSTOMERNAME")
            self.mCustomerName.isHidden = false
            self.mCustomerName.text = name
        }
        
        self.mCustomerId = data.value(forKey: "id") as? String ?? ""
        self.mCustomerImage.downlaodImageFromUrl(urlString: profile)
        self.mSelectedCustomerIcon.image = UIImage(named: "selected_customer")
        self.mCustomerImage.contentMode = .scaleAspectFill
        
        UserDefaults.standard.setValue(nil, forKey: "CustomerBillingAddressUDID")
        UserDefaults.standard.setValue(nil, forKey: "CustomerShippingAddressUDID")
        
        if let haveAddresses = data.value(forKey: "haveAddresses") as? Bool, haveAddresses {
            mAddressPickerIcon.image = UIImage(named: "address_pick_ic_green")
            mAddressPickerAlertIcon.isHidden = true
        } else {
            mAddressPickerIcon.image = UIImage(named: "address_pick_ic_green")
            mAddressPickerAlertIcon.isHidden = false
        }
        
    }
    
    func mOpenCustomerSheet(){
        let storyBoard: UIStoryboard = UIStoryboard(name: "common", bundle: nil)
        if let home = storyBoard.instantiateViewController(withIdentifier: "CustomerPicker") as? CustomerPicker {
            home.delegate = self
            home.modalPresentationStyle = .automatic
            home.transitioningDelegate = self
            self.present(home,animated: true)
        }
    }
    @IBAction func mChooseCurrency(_ sender: Any)
    {
        let dropdown = DropDown()
        dropdown.anchorView = self.mChooseCurrencyButt
        dropdown.direction = .bottom
        dropdown.bottomOffset = CGPoint(x: 0, y: 50)
        dropdown.width = 200
        dropdown.dataSource = self.mCurrencyNameData
        dropdown.cellNib = UINib(nibName: "Currency", bundle: nil)
        dropdown.customCellConfiguration = {
            (index:Index, item:String,cell: DropDownCell) -> Void in
            guard let cell = cell as? CurrencyCell else { return}
            
            cell.mCurrencyImage.downlaodImageFromUrl(urlString: "\(self.mCurrencyImageData[index])")
            
        }
        dropdown.selectionAction = {
            [unowned self](index:Int, item: String) in
            
            self.mCouponCurrency.text = item
            self.mCurrency = item
            self.mCurrencyImage.downlaodImageFromUrl(urlString: self.mCurrencyImageData[index])
            
            
        }
        dropdown.show()
        
    }
    
    @IBAction func mAddCouponNow(_ sender: Any) {
        if mCustomerId == "" {
            mOpenCustomerSheet()
            CommonClass.showSnackBar(message: "Please Choose Customer!")
        }else if mCouponName.text == "" {
            CommonClass.showSnackBar(message: "Please Fill Coupon Name!")
        }else if mCouponNumber.text == "" {
            CommonClass.showSnackBar(message: "Please Fill Coupon Number!")
        }else if mCouponAmount.text == "" {
            CommonClass.showSnackBar(message: "Please Fill Coupon Amount!")
            
        }else  if Double(self.mCouponAmount.text ?? "0") ?? 0.00 == 0.0 {
            CommonClass.showSnackBar(message: "Please fill valid amount!")
            return
        }else if mCouponValidity.text == "" {
            CommonClass.showSnackBar(message: "Please Fill Coupon Validity!")
        }else if mCouponRemarks.text == "" {
            CommonClass.showSnackBar(message: "Please Fill Coupon Remarks!")
        }else{
            guard self.mAddressPickerAlertIcon.isHidden else {
                CommonClass.showSnackBar(message: "Add Billing and Shipping address")
                return
            }
            
            mAddCoupon()
        }
    }
    
    
    
    
    
    
    func mAddCoupon(){
        
        
        let mLocation = UserDefaults.standard.string(forKey: "location")
        
        
        var params = [String : Any]()
        var urlPath =  ""
        if self.isEdit != "" {
            
            urlPath =  mUpdateCoupons
            params = ["custom_cart_id": mCouponId,
                      "name":mCouponName.text ?? "",
                      "amount":Double(mCouponAmount.text ?? "0.00") ?? 0.00,
                      "currency":mCurrency,
                      "card_no":mCouponNumber.text ?? "",
                      "expire_date":mCouponValidity.text ?? "",
                      "remark":mCouponRemarks.text ?? ""]
            
        }else{
            urlPath =  mAddNewCoupons
            
            params = ["customer_id": mCustomerId,
                      "coupon_amount":Double(mCouponAmount.text ?? "0.00") ?? 0.00,
                      "coupon_code":mCouponNumber.text ?? "",
                      "coupon_expire_date":mCouponValidity.text ?? "",
                      "coupon_remark":mCouponRemarks.text ?? "",
                      "currency":mCurrency,
                      "coupon_name":mCouponName.text ?? "" ]
        }
        
        if Reachability.isConnectedToNetwork() == true {
            CommonClass.showFullLoader(view: self.view)
            AF.request(urlPath, method:.post, parameters:params,headers: sGisHeaders2).responseJSON
            { response in
                CommonClass.stopLoader()
                
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
                        if self.isEdit == "" {
                            CommonClass.showSnackBar(message: "Added Successfuly!")
                        }else {
                            CommonClass.showSnackBar(message: "Updated Successfuly!")
                        }
                        
                        self.openCouponCart()
                    }
                    else {
                        CommonClass.showSnackBar(message: "\(jsonResult.value(forKey: "message") ?? "Please try again later.")")
                        if let error = jsonResult.value(forKey: "error") as? String {
                            if error == "Authorization has been expired" {
                                CommonClass.sessionExpired(isExpired: true, navigation: self.navigationController)
                            }
                        }
                        
                    }
                    
                }
                
                
            }
        }else{
            CommonClass.showSnackBar(message: "No Internet Connection")
        }
        
        
    }
    
    private func openCouponCart(){
        
        if let controllers = self.navigationController?.viewControllers {
            for controller in controllers {
                if let posAllCoupon = controller as? POSAllCoupons {
                    self.navigationController?.popToViewController(posAllCoupon, animated: true)
                    return
                }
            }
        }
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "moreBoard", bundle: nil)
        if let mCoupons = storyBoard.instantiateViewController(withIdentifier: "POSAllCoupons") as? POSAllCoupons {
            mCoupons.mCustomerId = self.mCustomerId
            self.navigationController?.pushViewController(mCoupons, animated:true)
        }
    }
    
    
    func mShowDatePicker(){
        
        let currentDate = Date()

        var datecomp = DateComponents()
        let calendar = Calendar(identifier: .gregorian)
        mDatePicker = UIDatePicker()
        
        mDatePicker.datePickerMode = .date
        mDatePicker.preferredDatePickerStyle = .wheels

        // Force Gregorian calendar
        mDatePicker.locale = Locale(identifier: "en_US")
        mDatePicker.calendar = Calendar(identifier: .gregorian)

        datecomp.day = 0
        mDatePicker.minimumDate = calendar.date(byAdding: datecomp, to: currentDate)

        datecomp.year = 5
        mDatePicker.maximumDate = calendar.date(byAdding: datecomp, to: currentDate)

        mDatePicker.backgroundColor = .white
        //ToolBar
        let mToolBar = UIToolbar()
        mToolBar.sizeToFit()
        mToolBar.backgroundColor = .white
        mToolBar.barTintColor = .white
        let mDone = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneDatePick))
        let mSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let mCancel = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(mCancelDatePick))
        mToolBar.setItems([mDone, mSpace,mCancel], animated: false)
        
        if #available(iOS 13.4, *) {
            mDatePicker.overrideUserInterfaceStyle = .light
        }
        
        mCouponValidity.inputAccessoryView = mToolBar
        mCouponValidity.inputView = mDatePicker
        
    }
    @objc func doneDatePick() {

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "dd/MM/yyyy"

        mCouponValidity.text = formatter.string(from: mDatePicker.date)

        view.endEditing(true)
    }
    @objc func mCancelDatePick(){
        self.view.endEditing(true)
    }
    
}
