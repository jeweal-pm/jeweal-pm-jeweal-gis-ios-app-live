//
//  RegisterCustomer.swift
//  GIS
//
//  Created by Apple Hawkscode on 11/12/20.
//

import UIKit
import Alamofire
import DropDown


class RegisterCustomer: UIViewController {
    
    @IBOutlet weak var mFirstName: UITextField!
    @IBOutlet weak var mLastName: UITextField!
    
    @IBOutlet weak var mDOB: UITextField!
    
    @IBOutlet weak var mAgeRange: UITextField!
    
    @IBOutlet weak var mGender: UITextField!
    
    @IBOutlet weak var mGroup: UITextField!
    
    @IBOutlet weak var mHome: UITextField!
    
    @IBOutlet weak var mPhoneCode: UITextField!
    
    @IBOutlet weak var mPhoneNumber: UITextField!
    
    @IBOutlet weak var mOccasion: UITextField!
    
    @IBOutlet weak var mSource: UITextField!
    
    @IBOutlet weak var mEmail: UITextField!
    
    @IBOutlet weak var mInstaMail: UITextField!
    
    @IBOutlet weak var mRemark: UITextView!
    
    @IBOutlet weak var mBCompany: UITextField!
    
    @IBOutlet weak var mBAddress: UITextView!
    
    @IBOutlet weak var mBCountry: UITextField!
    
    @IBOutlet weak var mBState: UITextField!
    
    @IBOutlet weak var mBCity: UITextField!
    
    @IBOutlet weak var mBZip: UITextField!
    
    @IBOutlet weak var mBTaxId: UITextField!
    
    @IBOutlet weak var mShipingStackView: UIStackView!
    @IBOutlet weak var mCheckShippingIcon: UIImageView!
    @IBOutlet weak var mSCompany: UITextField!
    
    @IBOutlet weak var mSAddress: UITextView!
    
    @IBOutlet weak var mSCountry: UITextField!
    
    @IBOutlet weak var mSState: UITextField!
    
    @IBOutlet weak var msCity: UITextField!
    
    @IBOutlet weak var mSZip: UITextField!
    
    @IBOutlet weak var mSTaxId: UITextField!
    
    
    
    
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
    
    
    
    @IBOutlet weak var mHRegisterLABEL: UILabel!
    
    @IBOutlet weak var mFullNameLABEL: UILabel!
    
    @IBOutlet weak var mDOBLABEL: UILabel!
    
    @IBOutlet weak var mAgeLABEL: UILabel!
    
    
    @IBOutlet weak var mGenderLABEL: UILabel!
    
    @IBOutlet weak var mGoupLABEL: UILabel!
    
    @IBOutlet weak var mHomeLABEL: UILabel!
    
    @IBOutlet weak var mMobileLABEL: UILabel!
    
    
    @IBOutlet weak var mOccasionLABEL: UILabel!
    
    
    @IBOutlet weak var mSourceLABEL: UILabel!
    
    
    @IBOutlet weak var mEmailLABEL: UILabel!
    @IBOutlet weak var mInstagramLABEL: UILabel!
    
    @IBOutlet weak var mRemarkLABEL: UILabel!
    
    
    
    @IBOutlet weak var mLastNameLABEL: UILabel!
    
    @IBOutlet weak var mBillingAddressHLABEL: UILabel!
    
    
    @IBOutlet weak var mBCompanyLABEL: UILabel!
    
    @IBOutlet weak var mBAddressLABEL: UILabel!
    
    @IBOutlet weak var mBCountryLABEL: UILabel!
    
    @IBOutlet weak var mBProvinceLABEL: UILabel!
    
    @IBOutlet weak var mBCityLABEL: UILabel!
    
    @IBOutlet weak var mBZipLABEL: UILabel!
    @IBOutlet weak var mBTaxOptionalLABEL: UILabel!
    
    @IBOutlet weak var mShippingAddressHLABEL: UILabel!
    
    @IBOutlet weak var mSCompanyLABEL: UILabel!
    
    @IBOutlet weak var mSAddressLABEL: UILabel!
    
    @IBOutlet weak var mSCountryLABEL: UILabel!
    
    @IBOutlet weak var mSProvinceLABEL: UILabel!
    
    @IBOutlet weak var mSCityLABEL: UILabel!
    
    @IBOutlet weak var mSZipLABEL: UILabel!
    @IBOutlet weak var mSTaxOptionalLABEL: UILabel!
    
    @IBOutlet weak var mSubmitBUTTON: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        mSubmitBUTTON.setTitle("Submit".localizedString, for: .normal)
        mHRegisterLABEL.text = "Register".localizedString
        mAgeLABEL.text = "Age".localizedString
        mGoupLABEL.text = "Group".localizedString
        mHomeLABEL.text = "Home".localizedString
        mEmailLABEL.text = "Email".localizedString
        mGenderLABEL.text = "Gender".localizedString
        mMobileLABEL.text = "Mobile".localizedString
        mSourceLABEL.text = "Source".localizedString
        mRemarkLABEL.text = "Remark".localizedString
        mOccasionLABEL.text = "Occasion".localizedString
        mInstagramLABEL.text = "Instagram".localizedString
        mDOBLABEL.text = "Date of Birth".localizedString
        mBZipLABEL.text = "Zip".localizedString
        mSZipLABEL.text = "Zip".localizedString
        mBCityLABEL.text = "City".localizedString
        mSCityLABEL.text = "City".localizedString
        mFullNameLABEL.text = "Full Name".localizedString
        mLastNameLABEL.text = "Last Name".localizedString
        mBillingAddressHLABEL.text = "Billing Address".localizedString
        mShippingAddressHLABEL.text = "Shipping address same as billing address".localizedString
        mBCompanyLABEL.text = "Company".localizedString
        mBCountryLABEL.text = "Country".localizedString
        mBTaxOptionalLABEL.text = "Tax ID No. (optional)".localizedString
        mBProvinceLABEL.text = "Province / State".localizedString
        mBAddressLABEL.text = "Address".localizedString
        mSAddressLABEL.text = "Address".localizedString
        mSCompanyLABEL.text = "Company".localizedString
        mSCountryLABEL.text = "Country".localizedString
        mSTaxOptionalLABEL.text = "Tax ID No. (optional)".localizedString
        mSProvinceLABEL.text = "Province / State".localizedString
        
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.applyGradient(withColours: [#colorLiteral(red: 0.7725490196, green: 0.9019607843, blue: 0.8745098039, alpha: 1),#colorLiteral(red: 0.9207345247, green: 0.9503677487, blue: 0.978346765, alpha: 1)], gradientOrientation: .vertical)
        
        mShowDatePicker()
        mGetCountries()
    }
    
    @IBAction func mBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func mChooseAgeRange(_ sender: Any) {
        mDropDown(dropdownKey: "age")
    }
    
    @IBAction func mChooseGender(_ sender: Any) {
        mDropDown(dropdownKey: "gender")
    }
    
    @IBAction func mChooseGroup(_ sender: Any) {
        mDropDown(dropdownKey: "group")
    }
    
    @IBAction func mChooseCountryCode(_ sender: Any) {
        mDropDown(dropdownKey: "code")
    }
    
    @IBAction func mChooseOccasion(_ sender: Any) {
        mDropDown(dropdownKey: "occassion")
    }
    
    @IBAction func mChooseSource(_ sender: Any) {
        mDropDown(dropdownKey: "source")
    }
    
    @IBAction func mChooseCountry(_ sender: Any) {
        mDropDown(dropdownKey: "country")
    }
    
    @IBAction func mChooseState(_ sender: Any) {}
    
    @IBAction func mChooseCity(_ sender: Any) {}
    
    @IBAction func mChooseZip(_ sender: Any) {}
    
    @IBAction func mChooseSCountry(_ sender: Any) {
        mDropDown(dropdownKey: "scountry")
    }
    
    @IBAction func mChooseSState(_ sender: Any) {}
    
    @IBAction func mChooseSCity(_ sender: Any) {}
    
    @IBAction func mSubmit(_ sender: Any) {
        
        if mFirstName.text == "" {
            CommonClass.showSnackBar(message: "Please fill first name.")
        }else if mLastName.text == ""{
            CommonClass.showSnackBar(message: "Please fill last name.")
        }else if mDOB.text == "" {
            CommonClass.showSnackBar(message: "Please fill Date of Birth.")
        }else if mHome.text == "" {
            CommonClass.showSnackBar(message: "Please fill Home.")
        }else if mPhoneCode.text == "" {
            CommonClass.showSnackBar(message: "Please fill Phone code.")
        }else if mPhoneNumber.text == "" {
            CommonClass.showSnackBar(message: "Please fill Phone number.")
        }else if mBAddress.text == "" {
            CommonClass.showSnackBar(message: "Please fill Billing address.")
        }else if mBCountry.text == "" {
            CommonClass.showSnackBar(message: "Please choose Billing Country.")
        }else if mBState.text == "" {
            CommonClass.showSnackBar(message: "Please fill Billing State.")
        }else if mBCity.text == "" {
            CommonClass.showSnackBar(message: "Please fill Billing City.")
        }else if mSameShippingAddress == "1" {
            mCreate(isShippingSelected: "1")
        }else{
            if mSAddress.text == "" {
                CommonClass.showSnackBar(message: "Please fill Shipping address.")
                
            }else if mSCountry.text == "" {
                CommonClass.showSnackBar(message: "Please choose Shipping Country.")
            }else if mSState.text == "" {
                CommonClass.showSnackBar(message: "Please fill Shipping State.")
            }else if msCity.text == "" {
                CommonClass.showSnackBar(message: "Please fill Shipping city.")
            }else {
                mCreate(isShippingSelected: "")
            }
        }
    }
    
    func mDropDown (dropdownKey: String) {
        
        if dropdownKey == "age" {
            let dropdown = DropDown()
            dropdown.anchorView = self.mAgeRange
            dropdown.direction = .bottom
            dropdown.bottomOffset = CGPoint(x: 0, y: self.mAgeRange.frame.size.height)
            dropdown.width = self.mAgeRange.frame.size.width
            dropdown.dataSource = mAgeRangeList
            dropdown.selectionAction = {
                [unowned self](index:Int, item: String) in
                self.mAgeRange.text  = item
                
            }
            dropdown.show()
        }else if dropdownKey == "gender" {
            
            let dropdown = DropDown()
            dropdown.anchorView = self.mGender
            dropdown.direction = .bottom
            dropdown.bottomOffset = CGPoint(x: 0, y: self.mGender.frame.size.height)
            dropdown.width = self.mGender.frame.size.width
            dropdown.dataSource = mGenderList
            dropdown.selectionAction = {
                [unowned self](index:Int, item: String) in
                self.mGender.text  = item
                
            }
            dropdown.show()
        }else if dropdownKey == "group" {
            let dropdown = DropDown()
            dropdown.anchorView = self.mGroup
            dropdown.direction = .bottom
            dropdown.bottomOffset = CGPoint(x: 0, y: self.mGender.frame.size.height)
            dropdown.width = self.mGroup.frame.size.width
            dropdown.dataSource = mGroupList
            dropdown.selectionAction = {
                [unowned self](index:Int, item: String) in
                self.mGroup.text  = item
                
            }
            dropdown.show()
            
        }else if dropdownKey == "source" {
            let dropdown = DropDown()
            dropdown.anchorView = self.mSource
            dropdown.direction = .bottom
            dropdown.bottomOffset = CGPoint(x: 0, y: self.mSource.frame.size.height)
            dropdown.width = self.mSource.frame.size.width
            dropdown.dataSource = mSourceList
            dropdown.selectionAction = {
                [unowned self](index:Int, item: String) in
                self.mSource.text  = item
                
            }
            dropdown.show()
        }else if dropdownKey == "occassion" {
            let dropdown = DropDown()
            dropdown.anchorView = self.mOccasion
            dropdown.direction = .bottom
            dropdown.bottomOffset = CGPoint(x: 0, y: self.mOccasion.frame.size.height)
            dropdown.width = self.mOccasion.frame.size.width
            dropdown.dataSource = mOccassionList
            dropdown.selectionAction = {
                [unowned self](index:Int, item: String) in
                self.mOccasion.text  = item
                
            }
            dropdown.show()
        }
        else if dropdownKey == "code" {
            let dropdown = DropDown()
            dropdown.anchorView = self.mPhoneCode
            dropdown.direction = .bottom
            dropdown.bottomOffset = CGPoint(x: 0, y: self.mOccasion.frame.size.height)
            dropdown.width = self.mPhoneCode.frame.size.width
            dropdown.dataSource = mPhoneCodeList
            dropdown.selectionAction = {
                [unowned self](index:Int, item: String) in
                self.mPhoneCode.text  = item
                
            }
            dropdown.show()
        }  else if dropdownKey == "country" {
            let dropdown = DropDown()
            dropdown.anchorView = self.mBCountry
            dropdown.direction = .bottom
            dropdown.bottomOffset = CGPoint(x: 0, y: self.mBCountry.frame.size.height)
            dropdown.width = 200
            dropdown.dataSource = mCountryList
            dropdown.selectionAction = {
                [unowned self](index:Int, item: String) in
                self.mBCountry.text  = item
                self.mStateList.removeAll()
                self.mStateListId.removeAll()
                self.mCityList.removeAll()
                self.mCityListId.removeAll()
                self.mBState.text = ""
                self.mBCity.text = ""
                self.mBCountryId = self.mCountryListId[index]
                
            }
            dropdown.show()
        }else if dropdownKey == "scountry" {
            let dropdown = DropDown()
            dropdown.anchorView = self.mSCountry
            dropdown.direction = .bottom
            dropdown.bottomOffset = CGPoint(x: 0, y: self.mSCountry.frame.size.height)
            dropdown.width = 200
            dropdown.dataSource = mCountryList
            dropdown.selectionAction = {
                [unowned self](index:Int, item: String) in
                self.mSCountry.text  = item
                self.mStateList.removeAll()
                self.mStateListId.removeAll()
                self.mCityList.removeAll()
                self.mCityListId.removeAll()
                self.mSState.text = ""
                self.msCity.text = ""
                self.mSCountryId = self.mCountryListId[index]
                
            }
            dropdown.show()
        }
        else if dropdownKey == "state" {
            let dropdown = DropDown()
            dropdown.anchorView = self.mBState
            dropdown.direction = .bottom
            dropdown.bottomOffset = CGPoint(x: 0, y: self.mBState.frame.size.height)
            dropdown.width = 200
            dropdown.dataSource = mStateList
            dropdown.selectionAction = {
                [unowned self](index:Int, item: String) in
                self.mBState.text  = item
                self.mCityList.removeAll()
                self.mCityListId.removeAll()
                self.mBCity.text = ""
                var id = self.mStateListId[index]
                self.mGetCitie(id: id)
                
            }
            dropdown.show()
        }else if dropdownKey == "city" {
            let dropdown = DropDown()
            dropdown.anchorView = self.mBCity
            dropdown.direction = .bottom
            dropdown.bottomOffset = CGPoint(x: 0, y: self.mBCity.frame.size.height)
            dropdown.width = 200
            dropdown.dataSource = mCityList
            dropdown.selectionAction = {
                [unowned self](index:Int, item: String) in
                self.mBCity.text  = item
                var id = self.mCityListId[index]
                
            }
            dropdown.show()
        }
    }
    
    
    
    
    func mCreate(isShippingSelected : String){
        
        let mLocation = UserDefaults.standard.string(forKey: "location")
        let urlPath = mRegister
        var params: [String: Any] = ["POS_Location_id":mLocation ?? "",
                                     "fname":mFirstName.text ?? "",
                                     "lname":mLastName.text ?? "",
                                     "dob":mDOB.text ?? "",
                                     "age":mAgeRange.text ?? "",
                                     "gender":mGender.text ?? "",
                                     "email":mEmail.text ?? "",
                                     "Instagram":mInstaMail.text ?? "",
                                     "source":mSource.text ?? "",
                                     "phone_code":mPhoneCode.text ?? "",
                                     "phone":mPhoneNumber.text ?? "",
                                     "home":mHome.text ?? "",
                                     "occasion":mOccasion.text ?? "",
                                     "rmark":mRemark.text ?? "",
                                     "group":mGroup.text ?? "",
                                     "taxid":mBTaxId.text ?? ""]
        
        var mShippingAddress = [String:Any]()
        var mBillingAddress = [String:Any]()
        
        if isShippingSelected.isEmpty {
            
            var mShippingAddress: [String: Any] = [:]
                if let company = mSCompany.text, let address = mSAddress.text,
                   let state = mSState.text, let city = msCity.text, let zip = mSZip.text {
                    mShippingAddress = [
                        "company": company,
                        "address": address,
                        "country": mSCountryId,
                        "state": state,
                        "city": city,
                        "zip": zip
                    ]
                }
                
                var mBillingAddress: [String: Any] = [:]
                if let company = mBCompany.text, let address = mBAddress.text,
                   let state = mBState.text, let city = mBCity.text, let zip = mBZip.text {
                    mBillingAddress = [
                        "company": company,
                        "address": address,
                        "country": mBCountryId,
                        "state": state,
                        "city": city,
                        "zip": zip
                    ]
                }
                
                params["billing_address"] = mBillingAddress
                params["shipping_address"] = mShippingAddress
        }else {
            var mBillingAddress: [String: Any] = [:]
                if let company = mBCompany.text, let address = mBAddress.text,
                   let state = mBState.text, let city = mBCity.text, let zip = mBZip.text {
                    mBillingAddress = [
                        "company": company,
                        "address": address,
                        "country": mBCountryId,
                        "state": state,
                        "city": city,
                        "zip": zip
                    ]
                }
                
                params["billing_address"] = mBillingAddress
                params["sameshippingaddress"] = "1"
                params["shipping_address"] = []
            
        }
        
        guard Reachability.isConnectedToNetwork() else {
            CommonClass.showSnackBar(message: "No Internet Connection")
            return
        }
        AF.request(urlPath, method: .post, parameters: params, encoding: JSONEncoding.default, headers: sGisHeaders)
            .responseJSON { response in
                if let error = response.error {
                    CommonClass.showSnackBar(message: "OOP's something went wrong! \(error.localizedDescription)")
                    return
                }
                
                guard let jsonData = response.data,
                      let jsonResult = try? JSONSerialization.jsonObject(with: jsonData) as? NSDictionary,
                      let code = jsonResult.value(forKey: "code") as? Int else {
                    CommonClass.showSnackBar(message: "Unexpected server response")
                    return
                }
                
                if code == 200 {
                    CommonClass.showSnackBar(message: "Successfully Added!")
                    self.navigationController?.popViewController(animated: true)
                } else if let errorMessage = jsonResult.value(forKey: "error") as? String,
                          errorMessage == "Authorization has been expired" {
                    CommonClass.sessionExpired(isExpired: true, navigation: self.navigationController)
                }
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
        
        mDOB.inputAccessoryView = mToolBar
        mDOB.inputView = mDatePicker
        
    }
    @objc func doneDatePick(){
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "dd/MM/yyyy"

        let deliveryDate = formatter.string(from: mDatePicker.date)
        
        mDOB.text  =  deliveryDate
        
        self.view.endEditing(true)
        
    }
    @objc func mCancelDatePick(){
        self.view.endEditing(true)
    }
    
    func mGetCountries() {
        
        let urlPath = mFetchCountries
        guard Reachability.isConnectedToNetwork() else {
            CommonClass.showSnackBar(message: "No Internet Connection")
            return
        }
        
        AF.request(urlPath, method: .post, parameters: nil, headers: sGisHeaders2).responseJSON { response in
            if let error = response.error {
                CommonClass.showSnackBar(message: "OOP's something went wrong! \(error.localizedDescription)")
                return
            }
            
            guard let jsonData = response.data else {
                CommonClass.showSnackBar(message: "Unexpected server response")
                return
            }
            
            do {
                if let jsonResult = try JSONSerialization.jsonObject(with: jsonData) as? NSDictionary,
                   let data = jsonResult.value(forKey: "data") as? NSArray {
                    for i in data {
                        if let countryData = i as? NSDictionary,
                           let name = countryData.value(forKey: "name") as? String,
                           let id = countryData.value(forKey: "id") {
                            self.mCountryList.append(name)
                            self.mCountryListId.append("\(id)")
                        }
                    }
                }
            } catch {
                CommonClass.showSnackBar(message: "Error parsing JSON")
            }
        }
    }
    
    func mGetStates(id : String){
    
        let urlPath = mFetchStates + id
        guard Reachability.isConnectedToNetwork() else {
            CommonClass.showSnackBar(message: "No Internet Connection")
            return
        }
        
        AF.request(urlPath, method: .post, parameters: nil, headers: sGisHeaders2).responseJSON { response in
            if let error = response.error {
                CommonClass.showSnackBar(message: "OOP's something went wrong! \(error.localizedDescription)")
                return
            }
            
            guard let jsonData = response.data else {
                CommonClass.showSnackBar(message: "Unexpected server response")
                return
            }
            
            do {
                if let jsonResult = try JSONSerialization.jsonObject(with: jsonData) as? NSDictionary,
                   let data = jsonResult.value(forKey: "data") as? NSArray {
                    for i in data {
                        if let stateData = i as? NSDictionary,
                           let name = stateData.value(forKey: "name") as? String,
                           let id = stateData.value(forKey: "id") {
                            self.mStateList.append(name)
                            self.mStateListId.append("\(id)")
                        }
                    }
                }
            } catch {
                CommonClass.showSnackBar(message: "Error parsing JSON")
            }
        }
    }
    
    func mGetCitie(id : String){
        
        let urlPath = mFetchCities + id
    
        guard Reachability.isConnectedToNetwork() else {
            CommonClass.showSnackBar(message: "No Internet Connection")
            return
        }
        
        AF.request(urlPath, method: .post, parameters: nil, headers: sGisHeaders2).responseJSON { response in
            if let error = response.error {
                CommonClass.showSnackBar(message: "Oops, something went wrong! \(error.localizedDescription)")
                return
            }
            
            guard let jsonData = response.data else {
                CommonClass.showSnackBar(message: "Unexpected server response")
                return
            }
            
            do {
                if let jsonResult = try JSONSerialization.jsonObject(with: jsonData) as? NSDictionary,
                   let data = jsonResult.value(forKey: "data") as? NSArray {
                    for i in data {
                        if let cityData = i as? NSDictionary,
                           let name = cityData.value(forKey: "name") as? String,
                           let id = cityData.value(forKey: "id") {
                            self.mCityList.append(name)
                            self.mCityListId.append("\(id)")
                        }
                    }
                }
            } catch {
                CommonClass.showSnackBar(message: "Error parsing JSON")
            }
        }
    }
    
    
    @IBAction func mCheckShipping(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected == true {
            mCheckShippingIcon.image = UIImage(systemName: "record.circle.fill")
            mShipingStackView.isHidden = true
            mSameShippingAddress =  "1"
        }
        else{
            mCheckShippingIcon.image = UIImage(systemName: "circle")
            mShipingStackView.isHidden = false
            mSameShippingAddress =  ""
        }
    }
    
}
