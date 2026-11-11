//
//  CustomerProfile.swift
//  GIS
//
//  Created by Apple Hawkscode on 07/04/21.
//

import UIKit
import Alamofire
import DropDown

class CustomerProfile: UIViewController, UIViewControllerTransitioningDelegate {
    
    
    
    var mCName = ""
    var mCCountryState = ""
    var mCContact = ""
    var mCEmail = ""
    
    var mSHCountryId = ""
    var mBLCountryId = ""
    
    
    @IBOutlet weak var mMoreOptionsView: UIView!
    
    @IBOutlet weak var mEditIcon: UIImageView!
    @IBOutlet weak var mDisableView: UIView!
    
    
    
   
    @IBOutlet weak var mCustomerImage: UIImageView!
    @IBOutlet weak var mCustomerName: UILabel!
    @IBOutlet weak var mCustomerIdNo: UILabel!
    @IBOutlet weak var mSource: UILabel!
    @IBOutlet weak var mEmailAddress: UILabel!
    @IBOutlet weak var mGender: UILabel!
    @IBOutlet weak var mBirthDay: UILabel!
    @IBOutlet weak var mPhone: UILabel!
    
    @IBOutlet weak var mInstagram: UILabel!
    
    @IBOutlet weak var mLocationAddress: UITextView!
    @IBOutlet weak var mNationalFlag:UIImageView!
    
    @IBOutlet weak var mNationality: UILabel!
    
    
    @IBOutlet weak var mIdCardNumber: UILabel!
    
    @IBOutlet weak var mOccasion: UILabel!
    
    @IBOutlet weak var mSource1: UILabel!
    
    @IBOutlet weak var mBillingAddress: UITextView!
    
    
    @IBOutlet weak var mTaxIdNo: UILabel!
    
    @IBOutlet weak var mShippingAddress: UITextView!
    
    
    @IBOutlet weak var mUserEmailAddress: UILabel!
    
    @IBOutlet weak var mMobileNumberView: UIStackView!
    @IBOutlet weak var mEmailsView: UIStackView!
    
    var mFrontDocImage = ""
    var mBackDocImage = ""
    
    
    
    
    @IBOutlet weak var mSaveButton: UIButton!
    
    
    
    
    
    
    var mCustomerData = NSArray()
    
    @IBOutlet weak var mCProfileLABEL: UILabel!
    @IBOutlet weak var CPaymentLABEL: UILabel!
    @IBOutlet weak var mCPurchaseHistoryLABEL: UILabel!
    @IBOutlet weak var mCWishListLABEL: UILabel!
    
    @IBOutlet weak var mPartialPaymentLABEL: UILabel!
    @IBOutlet weak var mHProfileLABEL: UILabel!
    @IBOutlet weak var mDOBLABEL: UILabel!
    @IBOutlet weak var mIDLABEL: UILabel!
    @IBOutlet weak var mNationalityLABEL: UILabel!
    @IBOutlet weak var mGenderLABEL: UILabel!
    @IBOutlet weak var mMobileLABEL: UILabel!
    @IBOutlet weak var mOccasionLABEL: UILabel!
    @IBOutlet weak var mSourceLABEL: UILabel!
    @IBOutlet weak var mShipToLABEL: UILabel!
    @IBOutlet weak var mTaxIDNoLABEL: UILabel!
    @IBOutlet weak var mBillToLABEL: UILabel!
    @IBOutlet weak var mEmailLABEL: UILabel!
    @IBOutlet weak var mInstagramLABEL: UILabel!
    

    
    
    let mDatePicker:UIDatePicker = UIDatePicker()
    var mGenderList = [ "Male","Female","Others"]
    var mSourceList = ["Event","Instagram","Facebook","Twitter","Newspaper","Internet Ads","Youtube","Blog/Forum","TV","Radio","Friends/Family","Outdoor","Others"]
    var  mGroupList = ["Silver", "Gold","Diamond","Platinum"]
    var mOccassionList  =  ["Gift"]
    var mCountryList = [String]()
    var mCountryListId = [String]()
    var mStateList = [String]()
    var mStateListId = [String]()
    var mCityList = [String]()
    var mCityListId = [String]()
    var mAgeRangeList = ["20 - 30","30 - 40","40 - 50","50 - 60","60 - 70"]
    var mPhoneCodeList = ["+91","+66"]
    var mYearv = ""
    var mMonthv = ""
    var mDayv = ""
    var mSameShippingAddress = ""
    var mBCountryId = ""
    var mSCountryId = ""
    
    
    
    
    
 
    
    
    override func viewWillAppear(_ animated: Bool) {
        mHProfileLABEL.text = "Profile".localizedString
        mEmailLABEL.text = "Email".localizedString
        mGenderLABEL.text = "Gender".localizedString
        mMobileLABEL.text = "Phone".localizedString
        mSourceLABEL.text = "Source".localizedString
        mOccasionLABEL.text = "Occasion".localizedString
        mInstagramLABEL.text = "Instagram".localizedString
        mDOBLABEL.text = "Birth Date".localizedString
        mNationalityLABEL.text = "Nationality".localizedString
        mIDLABEL.text = "ID".localizedString
        mTaxIDNoLABEL.text = "Tax ID No.".localizedString
        mBillToLABEL.text = "Bill to".localizedString
        mShipToLABEL.text = "Ship to".localizedString
        CPaymentLABEL.text = "Payment History".localizedString
        mCPurchaseHistoryLABEL.text = "Purchase History".localizedString
        mCWishListLABEL.text = "Wishlist".localizedString
        mPartialPaymentLABEL.text = "Partial History".localizedString

        mGetCustomerData()
     
    }
    
    var mCustomerId = ""
    
    /// Raw `kycStatus` from the customer list / customer API. `nil` means the
    /// API did not return it, so no KYC banner is shown.
    var mKycStatus: Any?
    /// Raw `kycExpireDate` ("yyyy-MM-dd"). A past date means the documents expired.
    var mKycExpireDate: Any?
    private var mIsCreatingKyc = false
    private var mKycBannerView: KycProfileBannerView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
               
        mCustomerName.text = mCName
        // This translucent overlay sits on top of the whole info card and was
        // swallowing every tap (including the KYC Verify button).
        mDisableView.isUserInteractionEnabled = false
        applyKycBanner()
        mCustomerImage.contentMode = .scaleAspectFill
        mEmailAddress.text = mCEmail
        
        mUserEmailAddress.text = mCEmail
       
        self.view.backgroundColor = UIColor(named: "themeBackground")

        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.mHideOptions))
                    mMoreOptionsView.addGestureRecognizer(tap)
                    mMoreOptionsView.isUserInteractionEnabled = true
        
        
    }
    
    @IBAction func mBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - KYC status
    
    /// The vertical stack that holds the profile info card inside the scroll view.
    private func kycBannerContainerStack() -> UIStackView? {
        var current: UIView? = mGender
        while let view = current {
            if let stack = view as? UIStackView, stack.superview is UIScrollView {
                return stack
            }
            current = view.superview
        }
        return nil
    }
    
    /// Shows the KYC banner above the info card, and the verified shield after
    /// the name when the customer's KYC is completed.
    private func applyKycBanner() {
        mKycBannerView?.removeFromSuperview()
        mKycBannerView = nil
        
        let banner = KycProfileBanner(apiValue: mKycStatus, expireDate: mKycExpireDate)
        updateNameShield(isVerified: banner == .completed)
        
        guard let banner, banner.showsBanner, let stack = kycBannerContainerStack() else { return }
        let bannerView = KycProfileBannerView(banner: banner)
        bannerView.onVerify = { [weak self] in self?.openOndatoVerify() }
        stack.insertArrangedSubview(bannerView, at: 0)
        mKycBannerView = bannerView
    }
    
    private func updateNameShield(isVerified: Bool) {
        // Drop a shield attachment left from an earlier pass.
        let baseName = (mCustomerName.attributedText?.string ?? mCustomerName.text ?? "")
            .replacingOccurrences(of: "\u{FFFC}", with: "")
            .trimmingCharacters(in: .whitespaces)
        guard isVerified, let shield = UIImage(named: "kyc_completed") else {
            mCustomerName.text = baseName
            return
        }
        let attachment = NSTextAttachment()
        attachment.image = shield
        attachment.bounds = CGRect(x: 0, y: -3, width: 18, height: 18)
        let text = NSMutableAttributedString(string: baseName + " ", attributes: [
            .font: mCustomerName.font as Any,
            .foregroundColor: mCustomerName.textColor as Any
        ])
        text.append(NSAttributedString(attachment: attachment))
        mCustomerName.attributedText = text
    }
    
    /// Opens the Ondato verification page in an in-app web view.
    private func openOndatoVerify() {
        guard !mCustomerId.isEmpty, !mIsCreatingKyc else { return }
        guard Reachability.isConnectedToNetwork() else {
            CommonClass.showSnackBar(message: "No Internet Connection")
            return
        }
        
        // Same call as GIS web: create the verification, then open the returned page.
        mIsCreatingKyc = true
        CommonClass.showFullLoader(view: self.view)
        AF.request(mCreateKyc, method: .post, parameters: ["id": mCustomerId],
                   encoding: JSONEncoding.default, headers: sGisHeaders2).responseJSON { [weak self] response in
            CommonClass.stopLoader()
            guard let self else { return }
            self.mIsCreatingKyc = false
            
            if response.response?.statusCode == 403 {
                CommonClass.sessionExpired(isExpired: true, navigation: self.navigationController)
                return
            }
            let json = response.data.flatMap { try? JSONSerialization.jsonObject(with: $0) as? NSDictionary }
            #if DEBUG
            print("create-kyc status = \(response.response?.statusCode ?? 0), body = \(json ?? [:])")
            #endif
            guard response.error == nil,
                  let json,
                  json["success"] as? Bool == true,
                  let info = json["data"] as? NSDictionary,
                  let url = KycVerifyWebViewController.verifyURL(from: info) else {
                // The customer needs country, first/last name, email and phone before KYC;
                // show the reason from the server when it sends one.
                let reason = (json?["message"] as? String) ?? (json?["error"] as? String)
                CommonClass.showSnackBar(message: reason?.isEmpty == false ? reason! : "OOP's something went wrong!")
                return
            }
            // Profile data (and the KYC status) is reloaded in viewWillAppear on return.
            let webViewController = KycVerifyWebViewController(url: url)
            let navigationController = UINavigationController(rootViewController: webViewController)
            navigationController.modalPresentationStyle = .fullScreen
            self.present(navigationController, animated: true)
        }
    }
    @objc func mHideOptions(){
        mMoreOptionsView.isHidden = true
    }
    
    @IBAction func mOptions(_ sender: Any) {
        mMoreOptionsView.isHidden = false

    }
    
    @IBAction func mShowProfile(_ sender: Any) {
        mMoreOptionsView.isHidden = true

    }
    
    @IBAction func mShowPurchasehistory(_ sender: Any) {
        mMoreOptionsView.isHidden = true
        let storyBoard: UIStoryboard = UIStoryboard(name: "transactions", bundle: nil)
        if let mCPayment = storyBoard.instantiateViewController(withIdentifier: "CustomerPurchaseHistory") as? CustomerPurchaseHistory {
            mCPayment.mCustomerId = mCustomerId
            mCPayment.mCustomerName = mCustomerName.attributedText?.string ?? mCustomerName.text ?? ""
            mCPayment.modalPresentationStyle = .overFullScreen
            mCPayment.transitioningDelegate = self
            self.present(mCPayment,animated: true)
        }
    }
    
    @IBAction func mShowPayment(_ sender: Any) {
        mMoreOptionsView.isHidden = true
        let storyBoard: UIStoryboard = UIStoryboard(name: "transactions", bundle: nil)
        if let mCPayment = storyBoard.instantiateViewController(withIdentifier: "CustomerPaymentHistory") as? CustomerPaymentHistory {
        mCPayment.mCustomerId = mCustomerId
        mCPayment.modalPresentationStyle = .overFullScreen
        mCPayment.transitioningDelegate = self
        self.present(mCPayment,animated: true)
        }
    }
    
    @IBAction func mShowWishList(_ sender: Any) {
        
        mMoreOptionsView.isHidden = true
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "catalog", bundle: nil)
        if let mCPayment = storyBoard.instantiateViewController(withIdentifier: "WishListControllerNew") as? WishListController{
            mCPayment.mCustomerId = mCustomerId
            mCPayment.modalPresentationStyle = .overFullScreen
            mCPayment.transitioningDelegate = self
            self.present(mCPayment,animated: true)
        }
    }
    
  
    
    @IBAction func mShowPartialPaymentHistory(_ sender: Any) {
        mMoreOptionsView.isHidden = true
        let storyBoard: UIStoryboard = UIStoryboard(name: "laybyInstallment", bundle: nil)
        if let mPartialPaymentHistory = storyBoard.instantiateViewController(withIdentifier: "PartialPaymentHistory") as? PartialPaymentHistory{
            mPartialPaymentHistory.mCustomerId = self.mCustomerId
            mPartialPaymentHistory.modalPresentationStyle = .automatic
            mPartialPaymentHistory.transitioningDelegate = self
            self.present(mPartialPaymentHistory,animated: true)
        }
    }
    
    @IBAction func mEditSaveButton(_ sender: UIButton) {
   
        let storyBoard: UIStoryboard = UIStoryboard(name: "reserveBoard", bundle: nil)
        if let home = storyBoard.instantiateViewController(withIdentifier: "UpdateCustomer") as? UpdateCustomer {
            home.mCustomerIds = mCustomerId
            self.navigationController?.pushViewController(home, animated:true)
        }
    }
    
    func mCreateNewCustomer() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "reserveBoard", bundle: nil)
        if let mCreateCustomer = storyBoard.instantiateViewController(withIdentifier: "CreateCustomer") as? CreateCustomer {
            self.navigationController?.pushViewController(mCreateCustomer, animated:true)
        }
    }
    
    func mGetNumberView(contact: NSDictionary) -> UIStackView {
        let mNumberStackView = UIStackView()
        let emptyLabel = UILabel()
        let mNewMobileNumber = UILabel()
    
        mNumberStackView.axis = .horizontal
        mNumberStackView.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
    
        emptyLabel.widthAnchor.constraint(equalToConstant: 80).isActive = true
        emptyLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        mNewMobileNumber.text = "+\(contact.value(forKey: "phoneCode") ?? "")-\(contact.value(forKey: "number") ?? "")"
        if let font = UIFont(name: "Segoe UI", size: 14.0) {
            mNewMobileNumber.font = font
        }
        mNewMobileNumber.textColor = UIColor(named: "themeLightText")
        
        mNumberStackView.addArrangedSubview(emptyLabel)
        mNumberStackView.addArrangedSubview(mNewMobileNumber)
        return mNumberStackView
    }
    
    func mGetEmailsView(email: String) -> UIStackView {
        let mEmailStackView = UIStackView()
        let emptyLabel = UILabel()
        let mNewEMail = UILabel()
    
        mEmailStackView.axis = .horizontal
        mEmailStackView.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
    
        emptyLabel.widthAnchor.constraint(equalToConstant: 80).isActive = true
        emptyLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        mNewEMail.text = "\(email)"
        if let font = UIFont(name: "Segoe UI", size: 14.0) {
            mNewEMail.font = font
        }
        mNewEMail.textColor = UIColor(named: "themeLightText")
        
        mEmailStackView.addArrangedSubview(emptyLabel)
        mEmailStackView.addArrangedSubview(mNewEMail)
        return mEmailStackView
    }

    
    func mGetCustomerData(){
        
        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
        
        let urlPath =  mGetCustomerById
        let params = ["id": mCustomerId]
        CommonClass.showFullLoader(view: self.view)
        print("mGetCustomerData params: \(params)")
        if Reachability.isConnectedToNetwork() == true {
            AF.request(urlPath, method:.post, parameters:params, headers: sGisHeaders2).responseJSON
            { response in
                CommonClass.stopLoader()
                if(response.error != nil){
                    
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
                        if let mData = jsonResult.value(forKey: "data") as? NSDictionary {
                            print("CUSTOMER_DATA =", mData)
                            if let kycStatus = mData.value(forKey: "kycStatus") {
                                self.mKycStatus = kycStatus
                            }
                            if let kycExpireDate = mData.value(forKey: "kycExpireDate") {
                                self.mKycExpireDate = kycExpireDate
                            }
                            // Run after the name label is filled in below.
                            DispatchQueue.main.async { self.applyKycBanner() }
                            if let mMiddleName =  mData.value(forKey: "mname") as? String {
                                if mMiddleName != "" {
                                    self.mCustomerName.text = "\(mData.value(forKey: "title") ?? "") " + "\(mData.value(forKey: "fname") ?? "")" + " \(mMiddleName)" + " \(mData.value(forKey: "lname") ?? "")"
                                }else{
                                    self.mCustomerName.text = "\(mData.value(forKey: "title") ?? "") " + "\(mData.value(forKey: "fname") ?? "")" + " \(mData.value(forKey: "lname") ?? "")"
                                }
                            }else{
                                self.mCustomerName.text = "\(mData.value(forKey: "title") ?? "") " + "\(mData.value(forKey: "fname") ?? "")" + " \(mData.value(forKey: "lname") ?? "")"
                            }
                            
                            if mData.value(forKey: "profile") != nil {
                                self.mCustomerImage.downlaodImageFromUrl(urlString: "\(mData.value(forKey: "profile")!)")
                            }
                            
                            
                            if mData.value(forKey: "email") != nil {
                                self.mEmailAddress.text = "\(mData.value(forKey: "email") ?? "--")"
                                self.mUserEmailAddress.text = "\(mData.value(forKey: "email") ?? "--")"
                            }
                            
                            if let emailArray = mData.value(forKey: "emails") as? [String] {
                                if emailArray.count > 0 {
                                    for email in emailArray {
                                        let newView = self.mGetEmailsView(email: email)
                                        self.mEmailsView.addArrangedSubview(newView)
                                    }
                                }
                            }
                            
                            if mData.value(forKey: "customerid") != nil {
                                self.mCustomerIdNo.text = "\(mData.value(forKey: "customerid") ?? "--")"
                            }
                            if mData.value(forKey: "phone_code") != nil {
                                self.mPhone.text = "\(mData.value(forKey: "phone_code") ?? "--")" + "-\(mData.value(forKey: "mobile") ?? "--")"
                            }
                            // New Contacts array
                            if let contactArray = mData.value(forKey: "contacts") as? NSArray {
                                if contactArray.count > 0 {
                                    for index in 0...contactArray.count - 1 {
                                        if let contact = contactArray[index] as? NSDictionary {
                                            if index == 0 {
                                                self.mPhone.text = "+\(contact.value(forKey: "phoneCode") ?? "")-\(contact.value(forKey: "number") ?? "")"
                                            }else{
                                                if contact.value(forKey: "phoneCode") as? String ?? "" != "" && contact.value(forKey: "number") as? String ?? "" != "" {
                                                    let newView = self.mGetNumberView(contact: contact)
                                                    self.mMobileNumberView.addArrangedSubview(newView)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            
                            self.mGender.text = "\(mData.value(forKey: "gender") ?? "--")"
                            let behaviorMap: [String:String] = [
                                "Polite": "Frequent Buyer",
                                "Noise": "One Time Buyer",
                                "VIP": "Occasional Buyer",
                                "Royal": "Seasonal Buyer"
                            ]

                            let oldBehavior = "\(mData.value(forKey: "group") ?? "")"
                            // The API now sends the customer group (e.g. "Gold") here; only the
                            // old behavior names are translated, anything else is shown as is.
                            let groupText = oldBehavior.trimmingCharacters(in: .whitespacesAndNewlines)
                            self.mSource.text = behaviorMap[groupText] ?? (groupText.isEmpty ? "--" : groupText)
//                            self.mSource.text = "\(mData.value(forKey: "group") ?? "--")"
                            print("DEBUG_CUSTOMER_GROUP =", mData.value(forKey: "group") ?? "")
                            self.mSource1.text = "\(mData.value(forKey: "source") ?? "--")"
                            self.mInstagram.text = "\(mData.value(forKey: "Instagram") ?? "--")"
                            
                            
                            if mData.value(forKey: "iddigits") != nil {
                                self.mIdCardNumber.text = "\(mData.value(forKey: "iddigits") ?? "--")" + "(\("\(mData.value(forKey: "idtype") ?? "--"))")"
                            }
                            
                            if let mDobData = mData.value(forKey: "date_of_birth") as? NSDictionary {
                                
                                let mBirthYear = "\(mDobData.value(forKey: "year") ?? "2005" )"
                                var mCurrentYear = Int()
                                if #available(iOS 15, *) {
                                    mCurrentYear = Calendar(identifier: .gregorian).dateComponents([.year], from: .now).year ?? 0
                                    
                                } else {
                                    mCurrentYear = Calendar(identifier: .gregorian).dateComponents([.year], from: Date()).year ?? 0
                                    
                                }
                                
                                let mCurrentAge = mCurrentYear - (Int(mBirthYear) ?? 18)
                                self.mBirthDay.text = "\(mDobData.value(forKey: "date") ?? "01")/" + "\(mDobData.value(forKey: "month") ?? "01")/" + "\(mDobData.value(forKey: "year") ?? "2005")" + " \(mCurrentAge) years old"
                                
                            }
                            
                            self.mLocationAddress.text = "\(mData.value(forKey: "address") ?? "--")"
                            
                            let nationality = "\(mData.value(forKey: "nationality") ?? "--")"
                            self.mNationality.text = nationality
                            print("nationality = \(nationality)")
                            switch nationality.lowercased() {
                                
                            case "australian","Australian":
                                self.mNationalFlag.image = UIImage(named: "australian")
                            case "canada":
                                self.mNationalFlag.image = UIImage(named: "canada")
                            case "irish":
                                self.mNationalFlag.image = UIImage(named: "irish")
                            case "british":
                                self.mNationalFlag.image = UIImage(named: "british")
                            case "thai", "thailand":
                                self.mNationalFlag.image = UIImage(named: "thai")
                            case "american", "usa", "united states", "united states of america":
                                self.mNationalFlag.image = UIImage(named: "usa")

                            default:
                                self.mNationalFlag.image = nil
                            }
                            
                            self.mNationalFlag.isHidden = true
                            
                            self.mOccasion.text = "\(mData.value(forKey: "occasion") ?? "--")"
                            
                            if let bData = mData.value(forKey: "billing_address") as? NSArray, bData.count > 0 {
                                for item in bData {
                                    if let data = item as? NSDictionary, data.value(forKey: "is_default") as? Int == 1 {
                                        let mBillingData = data
                                        if let countryData = mBillingData.value(forKey: "country") as? NSDictionary {
                                            self.mBillingAddress.text = "\(mBillingData.value(forKey: "address") ?? "")" + " \(countryData.value(forKey: "label") ?? "")" + " \(mData.value(forKey: "state") ?? "")" + " \(mBillingData.value(forKey: "city") ?? "")" + " \(mBillingData.value(forKey: "zipcode") ?? "")"
                                        }
                                        if mBillingData.value(forKey: "tax_number") != nil {

                                            self.mTaxIdNo.text = mBillingData.value(forKey: "tax_number") as? String ?? ""
                                        }
                                    }
                                }
                            }
                            
                            if let sData = mData.value(forKey: "shipping_address") as? NSArray, sData.count > 0 {
                                for item in sData {
                                    if let data = item as? NSDictionary, data.value(forKey: "is_default") as? Int == 1 {
                                        let mShippingData = data
                                        if let countryData = mShippingData.value(forKey: "country") as? NSDictionary {
                                            self.mShippingAddress.text = "\(mShippingData.value(forKey: "address") ?? "")" + " \(countryData.value(forKey: "label") ?? "")" + " \(mShippingData.value(forKey: "state") ?? "")" + " \(mShippingData.value(forKey: "city") ?? "")" + " \(mShippingData.value(forKey: "zipcode") ?? "")"
                                        }
                                    }
                                }
                            }
                        }
                    }else{
                        if jsonResult.value(forKey: "error") != nil {
                            if "\(jsonResult.value(forKey: "error") ?? "")" == "Authorization has been expired" {
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
   
  

    
   
    func mShowDatePicker(){
        let currentDate = Date()
        var datecomp = DateComponents()
        let min = Calendar.init(identifier: .gregorian)
        
        mDatePicker.preferredDatePickerStyle = .wheels
        datecomp.year = -100
        let minDates = min.date(byAdding: datecomp, to: currentDate)
        
        datecomp.year = -20
        let maxDates = min.date(byAdding: datecomp, to: currentDate)
        mDatePicker.minimumDate = minDates
        mDatePicker.maximumDate = maxDates
        mDatePicker.datePickerMode = .date
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
    
    }
    @objc func doneDatePick(){
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "dd/MM/yyyy"

        let deliveryDate = formatter.string(from: mDatePicker.date)

        self.view.endEditing(true)
   
    }
    @objc func mCancelDatePick(){
        self.view.endEditing(true)
    }
   

    
    func mGetStates(id : String){
        
        
        let urlPath = mFetchStates + id
        
        if Reachability.isConnectedToNetwork() == true {
            AF.request(urlPath, method:.post, parameters:nil, headers: sGisHeaders2).responseJSON
            { response in
                
                if(response.error != nil){
                    
                    CommonClass.showSnackBar(message: "OOP's something went wrong!")
                    
                }else{
                    if let jsonData = response.data {
                        let json = try? JSONSerialization.jsonObject(with: jsonData, options: [])
                        
                        if let jsonResult = json as? NSDictionary,
                           let data = jsonResult.value(forKey: "data") as? NSArray {
                            
                            for i in data {
                                if let stateData = i as? NSDictionary,
                                let state = stateData.value(forKey:"name"),
                                let stateId = stateData.value(forKey:"id") {
                                    self.mStateList.append("\(state)")
                                    self.mStateListId.append("\(stateId)")
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
    
    func mGetCitie(id : String){
        
        let urlPath = mFetchCities + id
        
        
        if Reachability.isConnectedToNetwork() == true {
            AF.request(urlPath, method:.post, parameters:nil, headers: sGisHeaders2).responseJSON
            { response in
                
                if(response.error != nil){
                    
                    CommonClass.showSnackBar(message: "OOP's something went wrong!")
                    
                }else{
                    if let jsonData = response.data {
                        let json = try? JSONSerialization.jsonObject(with: jsonData, options: [])
                        
                        if let jsonResult = json as? NSDictionary,
                           let data = jsonResult.value(forKey: "data") as? NSArray {
                            
                            for i in data {
                                if let cityData = i as? NSDictionary,
                                   let city = cityData.value(forKey:"name"),
                                   let cityId = cityData.value(forKey:"id") {
                                    self.mCityList.append("\(city)")
                                    self.mCityListId.append("\(cityId)")
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
    
}


// MARK: - KYC banner

/// KYC state shown on the customer Profile screen, derived from `kycStatus`.
enum KycProfileBanner: Equatable {
    case notVerified, rejected, expired, inProgress, approved, completed
    
    /// Returns `nil` when the API did not send `kycStatus` (nothing is shown) or
    /// the value is unknown. An empty value means the customer was never verified.
    init?(apiValue: Any?) {
        self.init(apiValue: apiValue, expireDate: nil)
    }
    
    /// Approved / Completed customers whose `kycExpireDate` is before `today`
    /// are treated as expired so they can verify again.
    init?(apiValue: Any?, expireDate: Any?, today: Date = Date()) {
        guard let apiValue, !(apiValue is NSNull) else { return nil }
        let text = "\(apiValue)".trimmingCharacters(in: .whitespacesAndNewlines)
        if text.isEmpty {
            self = .notVerified
            return
        }
        guard let status = KycStatus(apiValue: text) else { return nil }
        switch status {
        case .expired: self = .expired
        case .rejected: self = .rejected
        case .inProgress: self = .inProgress
        case .approved: self = Self.isExpired(expireDate, today: today) ? .expired : .approved
        case .completed: self = Self.isExpired(expireDate, today: today) ? .expired : .completed
        }
    }
    
    /// `kycExpireDate` is "yyyy-MM-dd" (a longer ISO string is cut to its date part).
    static func isExpired(_ expireDate: Any?, today: Date = Date()) -> Bool {
        guard let expireDate, !(expireDate is NSNull) else { return false }
        let text = String("\(expireDate)".trimmingCharacters(in: .whitespacesAndNewlines).prefix(10))
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: text) else { return false }
        return date < Calendar(identifier: .gregorian).startOfDay(for: today)
    }
    
    /// Completed customers get a shield after the name instead of a banner.
    var showsBanner: Bool { self != .completed }
    
    var showsVerifyButton: Bool {
        switch self {
        case .notVerified, .rejected, .expired: return true
        case .inProgress, .approved, .completed: return false
        }
    }
    
    var iconName: String? {
        switch self {
        case .notVerified, .completed: return nil
        case .rejected: return "kyc_rejected"
        case .expired: return "kyc_expired"
        case .inProgress: return "kyc_in_progress"
        case .approved: return "kyc_approved"
        }
    }
    
    /// Localization keys: text in the normal color, then an optional red lead.
    var messageKey: String {
        switch self {
        case .notVerified: return "This customer is not verified KYC yet"
        case .rejected: return "Try again"
        case .expired: return "The KYC verification has expired. Try again"
        case .inProgress: return "Verification is in progress. Please wait."
        case .approved: return "Verification approved. Wait to complete."
        case .completed: return ""
        }
    }
    
    var redLeadKey: String? {
        self == .rejected ? "KYC verification was rejected." : nil
    }
}

/// Banner row under the profile header: status icon, message and a Verify button.
final class KycProfileBannerView: UIView {
    
    var onVerify: (() -> Void)?
    
    init(banner: KycProfileBanner) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .white
        layer.cornerRadius = 8
        
        let font = UIFont(name: "Segoe UI", size: 12) ?? UIFont.systemFont(ofSize: 12)
        // Message color from the design (#A4A4A4).
        let grayColor = UIColor(red: 164 / 255, green: 164 / 255, blue: 164 / 255, alpha: 1)
        let redColor = UIColor(named: "themeRed") ?? .systemRed
        
        let iconView = UIImageView()
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.contentMode = .scaleAspectFit
        if let iconName = banner.iconName {
            iconView.image = UIImage(named: iconName)
        }
        iconView.isHidden = banner.iconName == nil
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        let text = NSMutableAttributedString()
        if let redLeadKey = banner.redLeadKey {
            text.append(NSAttributedString(string: redLeadKey.localizedString + " ", attributes: [
                .font: font, .foregroundColor: redColor
            ]))
        }
        text.append(NSAttributedString(string: banner.messageKey.localizedString, attributes: [
            .font: font, .foregroundColor: grayColor
        ]))
        label.attributedText = text
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        let verifyButton = UIButton(type: .system)
        verifyButton.translatesAutoresizingMaskIntoConstraints = false
        verifyButton.setTitle("Verify".localizedString, for: .normal)
        verifyButton.setTitleColor(redColor, for: .normal)
        verifyButton.titleLabel?.font = UIFont(name: "Segoe UI", size: 11) ?? UIFont.systemFont(ofSize: 11)
        verifyButton.layer.borderWidth = 1
        verifyButton.layer.borderColor = redColor.cgColor
        verifyButton.layer.cornerRadius = 3
        verifyButton.isHidden = !banner.showsVerifyButton
        verifyButton.addTarget(self, action: #selector(verifyTapped), for: .touchUpInside)
        
        addSubview(iconView)
        addSubview(label)
        addSubview(verifyButton)
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(greaterThanOrEqualToConstant: 40),
            
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 18),
            iconView.heightAnchor.constraint(equalToConstant: 18),
            
            verifyButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            verifyButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            verifyButton.widthAnchor.constraint(equalToConstant: 58),
            verifyButton.heightAnchor.constraint(equalToConstant: 24),
            
            label.leadingAnchor.constraint(
                equalTo: banner.iconName == nil ? leadingAnchor : iconView.trailingAnchor,
                constant: banner.iconName == nil ? 12 : 6),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            label.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 8),
            label.trailingAnchor.constraint(
                equalTo: banner.showsVerifyButton ? verifyButton.leadingAnchor : trailingAnchor,
                constant: -8)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func verifyTapped() {
        onVerify?()
    }
}
