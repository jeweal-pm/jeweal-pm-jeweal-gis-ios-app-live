//
//  UpdateCustomer.swift
//  GIS
//
//  Created by MacBook Hawkscode  on 15/11/22.
//  Copyright © 2022 Hawkscode. All rights reserved.
//

import UIKit
import Alamofire
import DropDown

class UpdateCustomer: UIViewController , UITableViewDataSource, UITableViewDelegate  , UIImagePickerControllerDelegate , UINavigationControllerDelegate ,UITextViewDelegate, AddressManagerDelegate {
    
    
    @IBOutlet weak var mBackIdImage: UIImageView!
    
    @IBOutlet weak var mFrontIdImage: UIImageView!
    @IBOutlet weak var mIdView: UIView!
    
    var imagePicker = UIImagePickerController()
    
    @IBOutlet weak var mYear: UITextField!
    @IBOutlet weak var mDay: UITextField!
    @IBOutlet weak var mMonth: UITextField!
    @IBOutlet weak var mEmailTableHeight: NSLayoutConstraint!
    @IBOutlet weak var mMobileTableHeight: NSLayoutConstraint!
    
    @IBOutlet weak var mTitle: UITextField!
    
    
    @IBOutlet weak var mCustomerImage: UIImageView!
    
    @IBOutlet weak var mCustomerName: UILabel!
    @IBOutlet weak var mCountryState: UILabel!
    
    @IBOutlet weak var mContactNumber: UILabel!
    @IBOutlet weak var mEmailAddress: UILabel!
    
    var mCName = ""
    var mCCountryState = ""
    var mCContact = ""
    var mCEmail = ""
    
    var mSHCountryId = ""
    var mBLCountryId = ""
    
    
    @IBOutlet weak var mMoreOptionsView: UIView!
    
    @IBOutlet weak var mEditIcon: UIImageView!
    @IBOutlet weak var mDisableView: UIView!
    
    
    
    @IBOutlet weak var mFirstName: UITextField!
    @IBOutlet weak var mMiddleName: UITextField!
    @IBOutlet weak var mCustomerId: UITextField!
    
    var mCustomerIds = ""
    @IBOutlet weak var mLastName: UITextField!
    
    @IBOutlet weak var mDOB: UITextField!
    
    @IBOutlet weak var mAgeRange: UITextField!
    
    
    @IBOutlet weak var mGender: UITextField!
    
    
    @IBOutlet weak var mGroup: UITextField!
    
    @IBOutlet weak var mNationalityFlag: UIImageView!
    
    @IBOutlet weak var mNationality: UITextField!
    @IBOutlet weak var mIdCard: UITextField!
    
    @IBOutlet weak var mIdNumber: UITextField!
    
    @IBOutlet weak var mAddress: UITextView!
    
    
    @IBOutlet weak var mCountry: UITextField!
    @IBOutlet weak var mCity: UITextField!
    @IBOutlet weak var mProvince: UITextField!
    @IBOutlet weak var mZipCode: UITextField!
    
    
    @IBOutlet weak var mPhoneCode: UITextField!
    @IBOutlet weak var mPhoneNumber: UITextField!
    
    
    @IBOutlet weak var mEmailTable: UITableView!
    @IBOutlet weak var mMoblieNumTable: UITableView!
    
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
    
    @IBOutlet weak var mSaveButton: UIButton!
    
    @IBOutlet weak var mDataHandlingIcon: UIImageView!
    
    @IBOutlet weak var mCheckTermIcon: UIImageView!
    
    @IBOutlet weak var mCardCreationSAIcon: UIImageView!
    
    @IBOutlet weak var mMarketingMessageCheckIcon: UIImageView!
    
    @IBOutlet weak var mMarketiingCheckButton: UIButton!
    @IBOutlet weak var mDataHandlingButton: UIButton!
    @IBOutlet weak var mContacttermButton: UIButton!
    @IBOutlet weak var mCardCreationButton: UIButton!
    
    @IBOutlet weak var mTaxExempButton: UIButton!
    @IBOutlet weak var mTaxExempIcon: UIImageView!
    var mCustomerData = NSArray()
    
    @IBOutlet weak var mCProfileLABEL: UILabel!
    @IBOutlet weak var CPaymentLABEL: UILabel!
    @IBOutlet weak var mCPurchaseHistoryLABEL: UILabel!
    @IBOutlet weak var mCWishListLABEL: UILabel!
    
    @IBOutlet weak var mHProfileLABEL: UILabel!
    @IBOutlet weak var mCustomerInfoLABEL: UILabel!
    @IBOutlet weak var mTitleLABEL: UILabel!
    @IBOutlet weak var CustomerIdLABEL: UILabel!
    @IBOutlet weak var mFisrtNameLABEL: UILabel!
    @IBOutlet weak var mMiddleNameLABEL: UILabel!
    @IBOutlet weak var mLastNameLABEL: UILabel!
    @IBOutlet weak var mBirthDateLABEL: UILabel!
    @IBOutlet weak var mDayLABEL: UILabel!
    @IBOutlet weak var mMonthLABEL: UILabel!
    @IBOutlet weak var mYearLABEL: UILabel!
    @IBOutlet weak var mAgeLABEL: UILabel!
    @IBOutlet weak var mGenderLABEL: UILabel!
    @IBOutlet weak var mGroupLABEL: UILabel!
    @IBOutlet weak var mNationalityLABEL: UILabel!
    @IBOutlet weak var mIDLABEL: UILabel!
    @IBOutlet weak var mAddressLABEL: UILabel!
    @IBOutlet weak var mCountryLABEL: UILabel!
    @IBOutlet weak var mProvinceStateLABEL: UILabel!
    @IBOutlet weak var mCityLABEL: UILabel!
    @IBOutlet weak var mZipCodeLABEL: UILabel!
    @IBOutlet weak var mPhoneLABEL: UILabel!
    @IBOutlet weak var mAddPhoneLABEL: UILabel!
    @IBOutlet weak var mAddEmailLABEL: UILabel!
    @IBOutlet weak var mInstagramLABEL: UILabel!
    @IBOutlet weak var mOccasionLABEL: UILabel!
    @IBOutlet weak var mSourceLABEL: UILabel!
    

    @IBOutlet weak var mConfirmIDBUTTON: UIButton!
    @IBOutlet weak var mCancelIDBUTTON: UIButton!
    @IBOutlet weak var mEmailAddLABEL: UILabel!
    @IBOutlet weak var mPrivacyLABEL: UILabel!
    
    @IBOutlet weak var mCardCreationSALABEL: UILabel!
    @IBOutlet weak var mDataHandlingLABEL: UILabel!
    @IBOutlet weak var mContactTermLABEL: UILabel!
    @IBOutlet weak var mCustomerOptUpdatesLABEL: UITextView!
    @IBOutlet weak var mTaxExemptLABEL: UITextView!
    @IBOutlet weak var mSubmitLABEL: UIButton!
    
    @IBOutlet weak var mBillingAddressHLABEL: UILabel!
    @IBOutlet weak var mBCompanyLABEL: UILabel!
    @IBOutlet weak var mBAddressLABEL: UILabel!
    @IBOutlet weak var mBCountryLABEL: UILabel!
    @IBOutlet weak var mBProvinceLABEL: UILabel!
    @IBOutlet weak var mBCityLABEL: UILabel!
    @IBOutlet weak var mBZipLABEL: UILabel!
    @IBOutlet weak var mBTaxOptionalLABEL: UILabel!
    
    @IBOutlet weak var mShippingAddressHeadingLABEL: UILabel!
    @IBOutlet weak var mShippingAddressHLABEL: UILabel!
    @IBOutlet weak var mSCompanyLABEL: UILabel!
    @IBOutlet weak var mSAddressLABEL: UILabel!
    @IBOutlet weak var mSCountryLABEL: UILabel!
    @IBOutlet weak var mSProvinceLABEL: UILabel!
    @IBOutlet weak var mSCityLABEL: UILabel!
    @IBOutlet weak var mSZipLABEL: UILabel!
    @IBOutlet weak var mSTaxOptionalLABEL: UILabel!
    
    //New Address Module
    @IBOutlet weak var mSelectBillingAddressLabel: UILabel!
    @IBOutlet weak var mSelectShippingAddressLabel: UILabel!
    @IBOutlet weak var mAddShippingAddressLabel: UILabel!
    @IBOutlet weak var mAddBillingAddressLabel: UILabel!
    @IBOutlet weak var mSelectBillingAddress: UITextField!
    @IBOutlet weak var mSelectShippingAddress: UITextField!
    
    private var mBillingAddressList : [[String : Any]] = []
    private var mBillingFullAddressList : [String] = []
    private var mShippingAddressList : [[String : Any]] = []
    private var mShippingFullAddressList : [String] = []
    private var mBillingAddressIndex = 0
    private var mShippingAddressIndex = 0
    
    let mDatePicker:UIDatePicker = UIDatePicker()
    
    
    var mGenderList = [ "Male","Female","Group","Others"]
    var mSourceList = ["Facebook","Friends/Family","Instagram","Snapchat","Social Media","Magazine","Event","Walk-In"]
    var mOccassionList  =  ["Anniversary","Gift", "Personal", "Prize","Wedding","Other"]
    var mIdTypeList = ["Passport","Driving Licence","Citizen Id"]
    var mTitleList = ["Ms","Mr","Mrs","Miss"]
    
    // ✨ แก้ข้อ 20: อัปเดตลิสต์ถ้าจำเป็น (สมมติว่าเป็น mGroupList หรืออื่นๆ ที่มี Thief)
    var  mGroupList = ["Silver", "Gold","Diamond","Platinum"]
//    var  mGroupList = ["Silver", "Gold","Diamond","Platinum"]
    
    var mCountryList = [String]()
    var mCountryListId = [String]()
    var mStateList = [String]()
    var mStateListId = [String]()
    var mCityList = [String]()
    var mCityListId = [String]()
    var mAgeRangeList = ["20 - 30","30 - 40","40 - 50","50 - 60","60 - 70"]
    var mPhoneCodeList = ["+91","+66"]
    var mDayList = ["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","29","30","31"]
    var mMonthList = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]
    
    var mYearList = [String]()
    var mYearv = ""
    var mFinalAge = ""
    var mMonthv = ""
    var mDayv = ""
    var mSameShippingAddress = ""
    var mBCountryId = ""
    var mSCountryId = ""
    var mProfilePicUrl = ""
    var mFrontIdPicUrl = ""
    var mBackIdPicUrl = ""
    var mTaxCheck = "uncheck"
    var mMarketCheck = "uncheck"
    var mCountryId = ""
    var mDataHandling = "uncheck"
    var mContractTerm = "uncheck"
    var mCardCreation = "uncheck"
    
    var mAlternateNumData = NSMutableArray()
    var mEmailData = [String]()
    var mNumberCount = 0
    var mEmailCount = 0
    var mOpenImageFor = ""
    var mPlaceHolderAddress = "458/7 5th Floor, City Mall , Bangkok, 10500"
    
    var sContactsArray = NSMutableArray()
    var sAlternateEmails = [String]()
    
    private var selectedPhoneCodeIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
        
        
        self.mMoblieNumTable.delegate = self
        self.mMoblieNumTable.dataSource = self
        self.mMoblieNumTable.reloadData()
        
        self.mEmailTable.delegate = self
        self.mEmailTable.dataSource = self
        self.mEmailTable.reloadData()
        
        
        
        
        var mCurrentYear = Int()
        if #available(iOS 15, *) {
            mCurrentYear = Calendar(identifier: .gregorian).dateComponents([.year], from: .now).year ?? 0
            mCurrentYear = mCurrentYear - 18
            
        } else {
            mCurrentYear = Calendar(identifier: .gregorian).dateComponents([.year], from: Date()).year ?? 0
            
            mCurrentYear = mCurrentYear - 18
        }
        
        
        
        
        self.mAgeRange.isEnabled = false
        for i in 0...100 {
            mYearList.append("\(mCurrentYear - i)")
        }
        
        mGetCountries()
        
        
        
        mAddress.delegate = self
        mAddress.text = mPlaceHolderAddress
        mAddress.textColor = .placeholderText
        
        mBAddress.delegate = self
        mBAddress.text = mPlaceHolderAddress
        mBAddress.textColor = .placeholderText
        
        mSAddress.delegate = self
        mSAddress.text = mPlaceHolderAddress
        mSAddress.textColor = .placeholderText
        
        
        mSelectBillingAddress.isEnabled = false
        mCustomerId.isUserInteractionEnabled = false
        
        mGetCustomerData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.mHProfileLABEL.text = "Edit Customer".localizedString
        
        
        self.mCustomerInfoLABEL.text = "Customer Information".localizedString
        self.mTitleLABEL.text = "Title".localizedString
        self.CustomerIdLABEL.text = "Customer Id".localizedString
        self.mFisrtNameLABEL.text = "First Name".localizedString
        self.mMiddleNameLABEL.text = "Middle Name".localizedString
        self.mLastNameLABEL.text = "Last Name".localizedString
        self.mBirthDateLABEL.text = "Birth Date".localizedString
        self.mDayLABEL.text = "Day".localizedString
        self.mMonthLABEL.text = "Month".localizedString
        self.mYearLABEL.text = "Year".localizedString
        self.mAgeLABEL.text = "Age".localizedString
        self.mGenderLABEL.text = "Gender".localizedString
        self.mGroupLABEL.text = "Group".localizedString
        self.mNationalityLABEL.text = "Nationality".localizedString
        self.mIDLABEL.text = "ID".localizedString
        self.mAddressLABEL.text = "Address".localizedString
        self.mCountryLABEL.text = "Country".localizedString
        self.mProvinceStateLABEL.text = "Province".localizedString
        self.mCityLABEL.text = "City".localizedString
        self.mZipCodeLABEL.text = "Zip Code".localizedString
        self.mPhoneLABEL.text = "Phone".localizedString
        self.mAddPhoneLABEL.text = "Add Phone".localizedString
        self.mAddEmailLABEL.text = "Add Email".localizedString
        self.mInstagramLABEL.text = "Instagram".localizedString
        self.mOccasionLABEL.text = "Occasion".localizedString
        self.mSourceLABEL.text = "Source".localizedString
        
        
        self.mConfirmIDBUTTON.setTitle("CONFIRM".localizedString, for: .normal)
        self.mCancelIDBUTTON.setTitle("CANCEL".localizedString, for: .normal)
        self.mEmailAddLABEL.text = "Email".localizedString
        self.mPrivacyLABEL.text = "Privacy".localizedString
        
        self.mCardCreationSALABEL.text = "Card Creation SA".localizedString
        self.mDataHandlingLABEL.text = "Data Handling".localizedString
        self.mContactTermLABEL.text = "Contact Term".localizedString
        self.mCustomerOptUpdatesLABEL.text = "Customer has opted to receive offers, updates, marketing and promotion by email.".localizedString
        self.mTaxExemptLABEL.text = "This customer is tax exempt. All taxes to be removed when this customer profile is allocated to a sale.".localizedString
        self.mSubmitLABEL.setTitle("SUBMIT".localizedString, for: .normal)
        
        
        self.mBillingAddressHLABEL.text = "Billing Address".localizedString
        self.mBCompanyLABEL.text = "Company".localizedString
        self.mBAddressLABEL.text = "Address".localizedString
        self.mBCountryLABEL.text = "Country".localizedString
        self.mBProvinceLABEL.text = "Province".localizedString
        self.mBCityLABEL.text = "City".localizedString
        self.mBZipLABEL.text = "Zip Code".localizedString
        self.mBTaxOptionalLABEL.text = "Tax ID No.".localizedString
        
        self.mShippingAddressHeadingLABEL.text = "Shipping Address".localizedString
        self.mShippingAddressHLABEL.text = "Shipping address same as billing address".localizedString
        self.mSCompanyLABEL.text = "Company".localizedString
        self.mSAddressLABEL.text = "Address".localizedString
        self.mSCountryLABEL.text = "Country".localizedString
        self.mSProvinceLABEL.text = "Province".localizedString
        self.mSCityLABEL.text = "City".localizedString
        self.mSZipLABEL.text = "Zip Code".localizedString
        self.mSTaxOptionalLABEL.text = "Tax ID No. (Optional)".localizedString
        self.mSelectBillingAddressLabel.text = "Select billing address".localizedString
        self.mSelectShippingAddressLabel.text = "Select shipping address".localizedString
        self.mAddShippingAddressLabel.text = "Add shipping address".localizedString
        self.mAddBillingAddressLabel.text = "Add billing address".localizedString
        
    }
    
    
    
    @IBAction func mBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == mAddress {
            mAddress.text = ""
            mAddress.textColor =  UIColor(named: "themeLightText")
        }else if textView == mBAddress {
            mBAddress.text = ""
            mBAddress.textColor =  UIColor(named: "themeLightText")
        }else if textView == mSAddress{
            mSAddress.text = ""
            mSAddress.textColor =  UIColor(named: "themeLightText")
        }
        
        
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == mAddress {
            if mAddress.text == "" {
                mAddress.text = mPlaceHolderAddress
                mAddress.textColor = .placeholderText
            }
        }else if textView == mBAddress {
            if mBAddress.text == "" {
                
                mBAddress.text = mPlaceHolderAddress
                mBAddress.textColor = .placeholderText
            }
        }else if textView == mSAddress{
            if mSAddress.text == "" {
                mSAddress.text = mPlaceHolderAddress
                mSAddress.textColor = .placeholderText
            }
            
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == mMoblieNumTable {
            return mNumberCount
            
        }else{
            return mEmailCount
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        
        var cell = UITableViewCell()
        
        if tableView == mMoblieNumTable {
            if let cells = tableView.dequeueReusableCell(withIdentifier: "MobileEmailList") as? MobileEmailList {
                
                cells.mRemoveButton.tag = indexPath.row
                cells.mChooseCode.tag = indexPath.row
                if indexPath.row + 1 < sContactsArray.count {
                    if let mData = sContactsArray[indexPath.row + 1] as? NSDictionary{
                        cells.mCountryCode.text = "\(mData.value(forKey: "phoneCode") ?? "")"
                        cells.mNumberEmail.text = "\(mData.value(forKey: "number") ?? "")"
                    }
                }else{
                    cells.mCountryCode.text = ""
                    cells.mNumberEmail.text = ""
                }
                cell = cells
            }
        }else{
            if let cells = tableView.dequeueReusableCell(withIdentifier: "MobileEmailList") as? MobileEmailList {
                
                cells.mRemoveButton.tag = indexPath.row
                cells.mNumberEmail.keyboardType = .emailAddress
                if indexPath.row < sAlternateEmails.count {
                    cells.mNumberEmail.text = "\(sAlternateEmails[indexPath.row])"
                }else {
                    cells.mNumberEmail.text = ""
                }
                cell = cells
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 50
        
    }
    
    override func viewWillLayoutSubviews() {
        mMobileTableHeight.constant = mMoblieNumTable.contentSize.height
        mEmailTableHeight.constant = mEmailTable.contentSize.height
        
    }
    
    
    @IBAction func mOpenCamera(_ sender: Any) {
        
        mOpenImageFor = "profile"
        mOpenCam()
        
    }
    
    @IBAction func mChooseGender(_ sender: Any) {
        mDropDown(dropdownKey: "gender")
        
    }
    
    @IBAction func mChooseGroup(_ sender: Any) {
        mDropDown(dropdownKey: "group")
        
        
    }
    @IBAction func mChooseNationality(_ sender: Any) {
    }
    
    @IBAction func mChooseDay(_ sender: Any) {
        
        mDropDown(dropdownKey: "day")
    }
    @IBAction func mChooseMonth(_ sender: Any) {
        mDropDown(dropdownKey: "month")
    }
    @IBAction func mChooseYear(_ sender: Any) {
        mDropDown(dropdownKey: "year")
    }
    
    
    @IBAction func mChooseIdCard(_ sender: Any) {
        mDropDown(dropdownKey: "id")
    }
    
    @IBAction func mChooseTitle(_ sender: Any) {
        mDropDown(dropdownKey: "title")
        
    }
    
    @IBAction func mAttatchIdCard(_ sender: Any) {
        mIdView.isHidden = false
    }
    
    
    @IBAction func mChooseCountry(_ sender: Any) {
        mDropDown(dropdownKey: "country")
        
    }
    
    
    @IBAction func mChoosePhoneCode(_ sender: Any) {
        mDropDown(dropdownKey: "phoneCode")
    }
    
   
    @IBAction func mChoosePhoneCodeForList(_ sender: UIButton) {
        selectedPhoneCodeIndex = sender.tag
        mDropDown(dropdownKey: "phoneCodeList")
    }
    
    
    @IBAction func mAddPhones(_ sender: Any) {
        
        mNumberCount = mNumberCount + 1
        mMoblieNumTable.reloadData()
        mMobileTableHeight.constant = mMoblieNumTable.contentSize.height
        
    }
    
    //New address Moudle functions
    @IBAction func mShowBillingAddresses(_ sender: Any) {
        mDropDown(dropdownKey: "billingAddress")
    }
    
    @IBAction func mShowShippingAddresses(_ sender: Any) {
        mDropDown(dropdownKey: "shippingAddress")
    }
    
    @IBAction func mAddBillingAddress(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "AddressPicker", bundle: nil)
        if let addressManager = storyBoard.instantiateViewController(withIdentifier: "AddressManager") as? AddressManager {
            addressManager.customerID = mCustomerIds
            addressManager.addressType = .addBillingAddress
            addressManager.delegate = self
            addressManager.manageLocally = true
            self.navigationController?.pushViewController(addressManager, animated:true)
        }
    }
    
    @IBAction func mAddShippingAddress(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "AddressPicker", bundle: nil)
        if let addressManager = storyBoard.instantiateViewController(withIdentifier: "AddressManager") as? AddressManager {
            addressManager.customerID = mCustomerIds
            addressManager.addressType = .addShippingAddress
            addressManager.delegate = self
            addressManager.manageLocally = true
            self.navigationController?.pushViewController(addressManager, animated:true)
        }
    }
    
    @IBAction func mEditBillingAddress(_ sender: Any) {
        if mBillingAddressList.count > 0 {
            let storyBoard: UIStoryboard = UIStoryboard(name: "AddressPicker", bundle: nil)
            if let addressManager = storyBoard.instantiateViewController(withIdentifier: "AddressManager") as? AddressManager {
                addressManager.customerID = mCustomerIds
                addressManager.addressType = .editBillingAddress
                addressManager.addressData = mBillingAddressList[mBillingAddressIndex]
                addressManager.delegate = self
                addressManager.manageLocally = true
                self.navigationController?.pushViewController(addressManager, animated:true)
            }
        }
    }
    
    @IBAction func mEditShippingAddress(_ sender: Any) {
        if mShippingAddressList.count > 0 {
            let storyBoard: UIStoryboard = UIStoryboard(name: "AddressPicker", bundle: nil)
            if let addressManager = storyBoard.instantiateViewController(withIdentifier: "AddressManager") as? AddressManager {
                addressManager.customerID = mCustomerIds
                addressManager.addressType = .editShippingAddress
                addressManager.addressData = mShippingAddressList[mShippingAddressIndex]
                addressManager.delegate = self
                addressManager.manageLocally = true
                self.navigationController?.pushViewController(addressManager, animated:true)
            }
        }
    }
    //Delegate function to manage Edit|Add|Remove addresses
    func didEditAddress(addressData: [String : Any]?, addressType: AddressType) {
        if let addressData = addressData {
            switch addressType {
            case .editBillingAddress:
                if addressData["is_default"] as? Int == 1 {
                    for i in mBillingAddressList.indices {
                        mBillingAddressList[i]["is_default"] = 0
                    }
                }
                mBillingAddressList[mBillingAddressIndex] = addressData
                mBillingFullAddressList[mBillingAddressIndex] = "\(addressData["fullAddress"] ?? "")"
                
                setBillingAddress(addressData: addressData)
                
            case .editShippingAddress:
                if addressData["is_default"] as? Int == 1 {
                    for i in mShippingAddressList.indices {
                        mShippingAddressList[i]["is_default"] = 0
                    }
                }
                mShippingAddressList[mShippingAddressIndex] = addressData
                mShippingFullAddressList[mShippingAddressIndex] = "\(addressData["fullAddress"] ?? "")"
                
                setShippingAddress(addressData: addressData)
                
            case .addBillingAddress:
                if addressData["is_default"] as? Int == 1 {
                    for i in mBillingAddressList.indices {
                        mBillingAddressList[i]["is_default"] = 0
                    }
                }
                mBillingAddressList.append(addressData)
                mBillingFullAddressList.append("\(addressData["fullAddress"] ?? "")")
            case .addShippingAddress:
                if addressData["is_default"] as? Int == 1 {
                    for i in mShippingAddressList.indices {
                        mShippingAddressList[i]["is_default"] = 0
                    }
                }
                mShippingAddressList.append(addressData)
                mShippingFullAddressList.append("\(addressData["fullAddress"] ?? "")")
            }
        } else {
            
            switch addressType {
            case .editBillingAddress:
                mBillingAddressList.remove(at: mBillingAddressIndex)
                mBillingFullAddressList.remove(at: mBillingAddressIndex)
                if let addressData = mBillingAddressList.first {
                    setBillingAddress(addressData: addressData)
                    mBillingAddressIndex = 0
                } else {
                    setBillingAddress(addressData: [:])
                }
            case .editShippingAddress:
                mShippingAddressList.remove(at: mShippingAddressIndex)
                mShippingFullAddressList.remove(at: mShippingAddressIndex)
                if let addressData = mShippingAddressList.first {
                    setShippingAddress(addressData: addressData)
                    mShippingAddressIndex = 0
                } else {
                    setShippingAddress(addressData: [:])
                }
            case .addBillingAddress, .addShippingAddress:
                break
            }
            
        }
    }
    
    func setBillingAddress(addressData: [String : Any]) {
        self.mSelectBillingAddress.text = "\(addressData["fullAddress"] ?? "")"
        self.mBAddress.text = "\(addressData["address"] ?? "")"
        self.mBCompany.text = "\(addressData["company"] ?? "")"
        let country = addressData["country"] as? [String : Any]
        self.mBCountry.text = "\(country?["label"] ?? "")"
        self.mBCountryId = "\(country?["value"] ?? "")"
        self.mBState.text = "\(addressData["state"] ?? "")"
        self.mBCity.text = "\(addressData["city"] ?? "")"
        self.mBTaxId.text = "\(addressData["tax_number"] ?? "")"
        self.mBZip.text = "\(addressData["zipcode"] ?? "")"
    }
    
    func setShippingAddress(addressData: [String : Any]) {
        self.mSelectShippingAddress.text  = "\(addressData["fullAddress"] ?? "")"
        self.mSAddress.text = "\(addressData["address"] ?? "")"
        self.mSCompany.text = "\(addressData["company"] ?? "")"
        let country = addressData["country"] as? [String : Any]
        self.mSCountry.text = "\(country?["label"] ?? "")"
        self.mSCountryId = "\(country?["value"] ?? "")"
        self.mSState.text = "\(addressData["state"] ?? "")"
        self.msCity.text = "\(addressData["city"] ?? "")"
        self.mSTaxId.text = "\(addressData["tax_number"] ?? "")"
        self.mSZip.text = "\(addressData["zipcode"] ?? "")"
    }
    
    func mOpenCam() {
        
        
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            let alert:UIAlertController=UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
            
            
            let cameraAction = UIAlertAction(title: "Camera", style: UIAlertAction.Style.default) {
                UIAlertAction in
                self.openCamera(UIImagePickerController.SourceType.camera)
            }
            let gallaryAction = UIAlertAction(title: "Gallery", style: UIAlertAction.Style.default) {
                UIAlertAction in
                self.openCamera(UIImagePickerController.SourceType.photoLibrary)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
                
                UIAlertAction in
            }
            
            // Add the actions
            imagePicker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
            alert.addAction(cameraAction)
            alert.addAction(gallaryAction)
            alert.addAction(cancelAction)
            addActionSheetForiPad(actionSheet: alert)
            self.present(alert, animated: true, completion: nil)
            
            
            
            
        }else{
            let alert:UIAlertController=UIAlertController(title: "Choose Image", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
            let cameraAction = UIAlertAction(title: "Camera", style: UIAlertAction.Style.default) {
                UIAlertAction in
                self.openCamera(UIImagePickerController.SourceType.camera)
            }
            let gallaryAction = UIAlertAction(title: "Gallery", style: UIAlertAction.Style.default) {
                UIAlertAction in
                self.openCamera(UIImagePickerController.SourceType.photoLibrary)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
                
                UIAlertAction in
            }
            
            // Add the actions
            imagePicker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
            alert.addAction(cameraAction)
            alert.addAction(gallaryAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    
    @IBAction func mTapFrontId(_ sender: Any) {
        
        mOpenImageFor = "frontId"
        mOpenCam()
        
    }
    
    @IBAction func mTapBackId(_ sender: Any) {
        mOpenImageFor = "backId"
        mOpenCam()
        
    }
    func openCamera(_ sourceType: UIImagePickerController.SourceType) {
        imagePicker.sourceType = sourceType
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true, completion: nil)
        
    }
    
    
    @IBAction func mCancel(_ sender: Any) {
        
        self.mIdView.isHidden = true
    }
    
    @IBAction func mConfirm(_ sender: Any) {
        self.mIdView.isHidden = true
        
    }
    
    //MARK: UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController,didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let uiImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        
        if mOpenImageFor == "profile" {
            self.mCustomerImage.image = uiImage
            let base64EncodedPath = uiImage.pngData()?.base64EncodedString()
            mGetImageUrl(base64: base64EncodedPath ?? "" , type: "profile")
        }else if mOpenImageFor == "frontId" {
            self.mFrontIdImage.image = uiImage
            let base64EncodedPath = uiImage.toBase64()
            mGetImageUrl(base64: base64EncodedPath ?? "", type: "front")
            
        }else if mOpenImageFor == "backId" {
            self.mBackIdImage.image = uiImage
            let base64EncodedPath = uiImage.toBase64()
            mGetImageUrl(base64: base64EncodedPath ?? "", type: "back")
        }
        imagePicker.dismiss(animated: true, completion: nil)
        
    }
    
    func mGetImageUrl(base64 : String , type: String){
        let params:[String: Any] = ["image":base64,"name":type]
        
        CommonClass.showFullLoader(view: self.view)
        
        
        mGetData(url: mGenerateImageUrlAPI,headers: sGisHeaders,  params: params) { response , status in
            CommonClass.stopLoader()
            if status {
                guard let code = response.value(forKey: "code") as? String, code == "200" else {
                    return
                }
                
                guard let data = response.value(forKey: "data") as? NSDictionary,
                      let images = data.value(forKey: "images") as? NSDictionary,
                      let imageUrl = images.value(forKey: "url") as? String
                else {
                    CommonClass.showSnackBar(message: "Image uploading failed!")
                    return
                }
                
                switch type {
                case "back":
                    self.mBackIdPicUrl = imageUrl
                case "front":
                    self.mFrontIdPicUrl = imageUrl
                case "profile":
                    self.mProfilePicUrl = imageUrl
                default:
                    break
                }
                
                CommonClass.showSnackBar(message: "Image uploaded successfully!")
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func mAddEmails(_ sender: Any) {
        
        mEmailCount = mEmailCount + 1
        mEmailTable.reloadData()
        mEmailTableHeight.constant = mEmailTable.contentSize.height
        
    }
    
    
    
    @IBAction func mRemoveEmailItems(_ sender: UIButton) {
        
        if mEmailCount > -1 {
            mEmailCount = mEmailCount - 1
            
            if sender.tag < sAlternateEmails.count {
                sAlternateEmails.remove(at: sender.tag)
            }
            mEmailTable.reloadData()
            mEmailTableHeight.constant = mEmailTable.contentSize.height
            
        }
    }
    @IBAction func mRemoveItems(_ sender: UIButton) {
        if mNumberCount > -1 {
            
            mNumberCount = mNumberCount - 1
            
            if sender.tag + 1 < sContactsArray.count {
                sContactsArray.removeObject(at: sender.tag + 1)
            }
            mMoblieNumTable.reloadData()
            mMobileTableHeight.constant = mMoblieNumTable.contentSize.height
            
        }
        
    }
    
    
    
    @IBAction func mChooseOccasion(_ sender: Any) {
        mDropDown(dropdownKey: "occassion")
        
    }
    
    
    @IBAction func mChooseSource(_ sender: Any) {
        mDropDown(dropdownKey: "source")
    }
    @IBAction func mBillingCountry(_ sender: Any) {
        mDropDown(dropdownKey: "bcountry")
    }
    
    
    
    @IBAction func mShipCountry(_ sender: Any) {
        
        mDropDown(dropdownKey: "scountry")
    }
    @IBAction func mCheckDataHandling(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected == true {
            mDataHandlingIcon.image = UIImage(named: "checked_box_ic")
            mDataHandling =  "check"
        }
        else{
            mDataHandlingIcon.image = UIImage(named: "unchecked_box_ic")
            mDataHandling =  "uncheck"
        }
        
        
    }
    
    @IBAction func mCheckContactTerm(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected == true {
            mCheckTermIcon.image = UIImage(named: "checked_box_ic")
            mContractTerm =  "check"
        }
        else{
            mCheckTermIcon.image = UIImage(named: "unchecked_box_ic")
            mContractTerm =  "uncheck"
        }
        
    }
    
    
    @IBAction func mCheckCardCreation(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected == true {
            mCardCreationSAIcon.image = UIImage(named: "checked_box_ic")
            mCardCreation =  "check"
        }
        else{
            mCardCreationSAIcon.image = UIImage(named: "unchecked_box_ic")
            mCardCreation =  "uncheck"
        }
    }
    
    
    
    @IBAction func mMarketingCheck(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected == true {
            mMarketingMessageCheckIcon.image = UIImage(named: "checked_box_ic")
            mMarketCheck =  "check"
        }
        else{
            mMarketingMessageCheckIcon.image = UIImage(named: "unchecked_box_ic")
            mMarketCheck =  "uncheck"
        }
    }
    
    
    @IBAction func mTaxExempted(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected == true {
            mTaxExempIcon.image = UIImage(named: "checked_box_ic")
            mTaxCheck =  "check"
        }
        else{
            mTaxExempIcon.image = UIImage(named: "unchecked_box_ic")
            mTaxCheck =  "uncheck"
        }
    }
    
    @IBAction func mSubmitButton(_ sender: Any) {
        
        
        var mAlternateNumber = NSMutableArray()
        var mAlternateEmail = [String]()
        for i in 0...mNumberCount {
            let mIndexPath = IndexPath(row:i,section: 0)
            
            if let cell = self.mMoblieNumTable.cellForRow(at: mIndexPath) as? MobileEmailList {
                
                if let numOrEmail = cell.mNumberEmail.text,
                   let countryCode = cell.mCountryCode.text {
                    let mData = NSMutableDictionary()
                    let value =  cell.mNumberEmail.text ?? ""
                    
                    mData.setValue( countryCode, forKey: "code")
                    mData.setValue( numOrEmail, forKey: "number")
                    
                    mAlternateNumber.add(mData)
                }
            }
        }
        
        let sContactArray = NSMutableArray()
        let data = NSMutableDictionary()
        if let phoneCode = mPhoneCode.text,
           let phoneNumber = mPhoneNumber.text {
            data.setValue( phoneCode, forKey: "phoneCode")
            data.setValue( phoneNumber, forKey: "number")
            data.setValue( "1", forKey: "icon")
            sContactArray.add(data)
        }
        
        for i in 0...mNumberCount {
            let mIndexPath = IndexPath(row:i,section: 0)
            
            if let cell = self.mMoblieNumTable.cellForRow(at: mIndexPath) as? MobileEmailList {
                
                if let numOrEmail = cell.mNumberEmail.text,
                   let phoneCode = cell.mCountryCode.text {
                    if !numOrEmail.isEmpty && !phoneCode.isEmpty {
                        let mData = NSMutableDictionary()
                        
                        mData.setValue( phoneCode, forKey: "phoneCode")
                        mData.setValue( numOrEmail, forKey: "number")
                        mData.setValue( "1", forKey: "icon")
                        
                        sContactArray.add(mData)
                    }
                }
            }
        }
        
        
        for i in 0...mEmailCount {
            let mIndexPath = IndexPath(row:i,section: 0)
            
            if let cell = self.mEmailTable.cellForRow(at: mIndexPath) as? MobileEmailList {
                if let value =  cell.mNumberEmail.text, !value.isEmpty {
                    mAlternateEmail.append(value)
                }
            }
        }
        
        
        
        var mParams = [String: Any]()
        
        var mBillingAddress = mBillingAddressList
        
        for index in 0..<mBillingAddress.count {
            let country = mBillingAddress[index]["country"] as? [String : Any]
            mBillingAddress[index]["country"] = country?["value"] ?? ""
            mBillingAddress[index].removeValue(forKey: "fullAddress")
            mBillingAddress[index].removeValue(forKey: "customer_id")
        }
        
        var mShillipngAddress: [[String : Any]] = []
        if mSameShippingAddress == "1" {
            mShillipngAddress = mBillingAddress
        }else{
            mShillipngAddress = mShippingAddressList
        }
        
        for index in 0..<mShillipngAddress.count {
            let country = mShillipngAddress[index]["country"] as? [String : Any]
            mShillipngAddress[index]["country"] = country?["value"] ?? ""
            mShillipngAddress[index].removeValue(forKey: "fullAddress")
            mShillipngAddress[index].removeValue(forKey: "customer_id")
        }
        
        
        let mPrivacyCheck = [
            
            "data_handling": mDataHandling,
            "contact_term": mContractTerm,
            "cardcreation": mCardCreation
            
        ]
        
        var monthNumber = "1"
        if let monthIndex = mMonthList.firstIndex(of: mMonth.text ?? "") {
            monthNumber = "\(monthIndex + 1)"
        }
        
        let mDobdata = ["date": mDay.text ?? "", "month":monthNumber, "year": mYear.text ?? ""]
        
        mParams = [
            "id": mCustomerIds,
            "customerid": self.mCustomerId.text!,
            "title": mTitle.text ?? "",
            "fname": mFirstName.text ?? "",
            "mname": mMiddleName.text ?? "",
            "lname": mLastName.text ?? "",
            "date_of_birth": mDobdata,
            "age": mFinalAge,
            "gender":mGender.text ?? "",
            "group": mGroup.text ?? "",
            "nationality": mNationality.text ?? "",
            "idtype": mIdCard.text ?? "",
            "iddigits": mIdNumber.text ?? "",
            "address": mAddress.text ?? "",
            "country": mCountryId,
            "state": mProvince.text ?? "",
            "city": mCity.text ?? "",
            "zipcode": mZipCode.text ?? "",
            "contacts": sContactArray,
            "email": mEmail.text ?? "",
            "emails":mAlternateEmail,
            "Instagram": mInstaMail.text ?? "",
            "occasion": mOccasion.text ?? "",
            "source":mSource.text ?? "",
            "billing_address": mBillingAddress,
            "shipping_address": mShillipngAddress,
            "privacy": mPrivacyCheck,
            "opt": mMarketCheck,
            "tax_exempt": mTaxCheck,
            "profile": mProfilePicUrl,
            "front": mFrontIdPicUrl,
            "back": mBackIdPicUrl,
            "status": 1,
            "samebillingaddress": (mSameShippingAddress == "1") ? true : false,
            
        ]
        
        if mCustomerId.text == "" {
            CommonClass.showSnackBar(message: "Please fill customer id.")
        }else if mTitle.text == "" {
            CommonClass.showSnackBar(message: "Please choose title.")
        }
        else if mFirstName.text == "" {
            CommonClass.showSnackBar(message: "Please fill first name.")
        }else if mLastName.text == ""{
            CommonClass.showSnackBar(message: "Please fill last name.")
        }else if mYear.text == "" {
            CommonClass.showSnackBar(message: "Please fill Date of Birth.")
        }else if mGender.text == "" {
            CommonClass.showSnackBar(message: "Please choose Gender.")
        }else if mGroup.text == "" {
            CommonClass.showSnackBar(message: "Please choose Group.")
        }else if mNationality.text == "" {
            CommonClass.showSnackBar(message: "Please fill Nationality.")
        } else if mAddress.text == "" ||  mAddress.text == mPlaceHolderAddress {
            CommonClass.showSnackBar(message: "Please fill Address.")
        }else if mCountry.text == "" {
            CommonClass.showSnackBar(message: "Please choose Country.")
        }else if mProvince.text == "" {
            CommonClass.showSnackBar(message: "Please fill Province/State.")
        }else if mCity.text == "" {
            CommonClass.showSnackBar(message: "Please fill City.")
        }else if mPhoneCode.text == "" {
            CommonClass.showSnackBar(message: "Please fill Phone code.")
        }else if mZipCode.text == "" {
            CommonClass.showSnackBar(message: "Please fill Zip code.")
        }else if mPhoneNumber.text == "" {
            CommonClass.showSnackBar(message: "Please fill Phone number.")
        }else if mEmail.text == "" {
            CommonClass.showSnackBar(message: "Please fill Email address.")
        }else if mBAddress.text == "" ||  mBAddress.text == mPlaceHolderAddress {
            CommonClass.showSnackBar(message: "Please fill Billing address.")
        }else if mBCountry.text == "" {
            CommonClass.showSnackBar(message: "Please choose Billing Country.")
        }else if mSameShippingAddress == "1" {
            
            // Temporarily disabled as requested.
            // Waiting for confirmation after discussion with Born sir.
//            if mDataHandling == "uncheck" {
//                CommonClass.showSnackBar(message: "Please check Data Handling.")
//                return
//            }else if mContractTerm == "uncheck" {
//                CommonClass.showSnackBar(message: "Please check Contact Term.")
//                return
//            }
            
            CommonClass.showFullLoader(view: self.view)
            mGetData(url: mCreateCustomer,headers: sGisHeaders,  params: mParams) { response , status in
                CommonClass.stopLoader()
                if status {
                    let isSuccess =
                        (response["code"] as? Int == 200) ||
                        (response["code"] as? String == "200")
                    if isSuccess {
                        let message = response.value(forKey: "message") as? String
                                    ?? "Customer updated successfully."

                        CommonClass.showSnackBar(message: message)

                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }
            
        }else{
            if mSAddress.text == "" ||  mSAddress.text == mPlaceHolderAddress {
                CommonClass.showSnackBar(message: "Please fill Shipping address.")
            }else if mSCountry.text == "" {
                CommonClass.showSnackBar(message: "Please choose Shipping Country.")
            }else {
                if mDataHandling == "uncheck" {
                    CommonClass.showSnackBar(message: "Please check Data Handling.")
                    return
                }else if mContractTerm == "uncheck" {
                    CommonClass.showSnackBar(message: "Please check Contact Term.")
                    return
                }
                CommonClass.showFullLoader(view: self.view)
                mGetData(url: mCreateCustomer,headers: sGisHeaders, params: mParams) { response , status in
                    CommonClass.stopLoader()
                    if status {
//                        if let code = response.value(forKey: "code") as? String , code == "200" {
                        let isSuccess =
                            (response["code"] as? Int == 200) ||
                            (response["code"] as? String == "200")
                        if isSuccess {
                            let message = response.value(forKey: "message") as? String
                                        ?? "Customer updated successfully."

                            CommonClass.showSnackBar(message: message)

                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                self.navigationController?.popViewController(animated: true)
                            }
                        }
                    }
                }
                
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
    
    
    
    func mGetCustomerData(){
        
        let urlPath =  mGetCustomerById
        let params = ["id": mCustomerIds]
        if Reachability.isConnectedToNetwork() == true {
            AF.request(urlPath, method:.post, parameters:params, headers: sGisHeaders2).responseJSON
            { response in
                
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
                            
                            if let middleName = mData.value(forKey: "mname") as? String {
                                self.mMiddleName.text = middleName
                            }
                            
                            if let profileUrl = mData.value(forKey: "profile") as? String {
                                self.mProfilePicUrl = profileUrl
                                self.mCustomerImage.downlaodImageFromUrl(urlString: profileUrl)
                            }
                            
                            if let backImageUrl = mData.value(forKey: "back") as? String {
                                self.mBackIdPicUrl = backImageUrl
                                self.mBackIdImage.downlaodImageFromUrl(urlString: backImageUrl)
                            }
                            
                            if let frontImageUrl = mData.value(forKey: "front") as? String {
                                self.mFrontIdPicUrl = frontImageUrl
                                self.mFrontIdImage.downlaodImageFromUrl(urlString: frontImageUrl)
                            }
                            
                            if let address = mData.value(forKey: "address") as? String {
                                self.mAddress.text = address
                                self.mAddress.textColor = UIColor(named: "themeLightText")
                            }
                            if let age = mData.value(forKey: "age") as? String {
                                self.mAgeRange.text = age
                            }
                            if let firstName = mData.value(forKey: "fname") as? String {
                                self.mFirstName.text = firstName
                            }
                            if let lastName = mData.value(forKey: "lname") as? String {
                                self.mLastName.text = lastName
                            }
                            if let profileUrl = mData.value(forKey: "profile") as? String {
                                self.mCustomerImage.downlaodImageFromUrl(urlString: profileUrl)
                            }
                            
                            if let gender = mData.value(forKey: "gender") as? String {
                                self.mGender.text = gender
                            }
                            
                            if let title = mData.value(forKey: "title") as? String {
                                self.mTitle.text = title
                            }
                            
                            if let email = mData.value(forKey: "email") as? String {
                                self.mEmail.text = email
                            }
                            
                            if let emailArray = mData.value(forKey: "emails") as? [String] {
                                self.sAlternateEmails = emailArray
                                self.mEmailCount = self.sAlternateEmails.count
                                self.mEmailTable.reloadData()
                            }
                            
                            
                            if let customerId = mData.value(forKey: "customerid") as? String {
                                self.mCustomerId.text = customerId
                            }
                            if let phoneCode = mData.value(forKey: "phone_code") as? String {
                                self.mPhoneCode.text = phoneCode
                            }
                            if let mobile = mData.value(forKey: "mobile") as? String {
                                self.mPhoneNumber.text = mobile
                            }
                            // New Contact Array
                            if let contactArray = mData.value(forKey: "contacts") as? NSArray {
                                if contactArray.count > 0 {
                                    if let firstContact = contactArray.firstObject as? NSDictionary {
                                        self.mPhoneCode.text = firstContact.value(forKey: "phoneCode") as? String ?? ""
                                        self.mPhoneNumber.text = firstContact.value(forKey: "number") as? String ?? ""
                                        self.mNumberCount = contactArray.count - 1
                                        if let contactArray = contactArray.mutableCopy() as? NSMutableArray {
                                            self.sContactsArray = contactArray
                                        }
                                        self.mMoblieNumTable.reloadData()
                                    }
                                }
                            }
                            
                            self.mGroup.text = "\(mData.value(forKey: "group") ?? "")"
                            self.mSource.text = "\(mData.value(forKey: "source") ?? "")"
                            self.mInstaMail.text = "\(mData.value(forKey: "Instagram") ?? "")"
                            self.mNationality.text = "\(mData.value(forKey: "nationality") ?? "")"
                            
                            
                            
                            
                            if let zipcode = mData.value(forKey: "zipcode") as? String {
                                self.mZipCode.text = zipcode
                            }
                            if let countryName = mData.value(forKey: "country_name") as? String {
                                self.mCountry.text = countryName
                            }
                            if let state = mData.value(forKey: "state") as? String {
                                self.mProvince.text = state
                            }
                            if let city = mData.value(forKey: "city") as? String {
                                self.mCity.text = city
                            }
                            
                            if let mPrivacyData = mData.value(forKey: "privacy") as? NSDictionary {
                                
                                if let mDHandling =  mPrivacyData.value(forKey: "data_handling") as? String {
                                    self.mDataHandling = mDHandling
                                    if self.mDataHandling == "check"{
                                        self.mDataHandlingButton.isSelected = true
                                        self.mDataHandlingIcon.image = UIImage(named: "checked_box_ic")
                                    }else{
                                        self.mDataHandlingButton.isSelected = false
                                        self.mDataHandlingIcon.image = UIImage(named: "unchecked_box_ic")
                                    }
                                    
                                }
                                
                                if let mCterm =  mPrivacyData.value(forKey: "contact_term") as? String {
                                    self.mContractTerm = mCterm
                                    if self.mContractTerm == "check"{
                                        self.mContacttermButton.isSelected = true
                                        self.mCheckTermIcon.image = UIImage(named: "checked_box_ic")
                                    }else{
                                        self.mContacttermButton.isSelected = false
                                        self.mCheckTermIcon.image = UIImage(named: "unchecked_box_ic")
                                    }
                                }
                                if let mCCreate =  mPrivacyData.value(forKey: "cardcreation") as? String {
                                    self.mCardCreation = mCCreate
                                    if self.mCardCreation == "check"{
                                        self.mCardCreationButton.isSelected = true
                                        self.mCardCreationSAIcon.image = UIImage(named: "checked_box_ic")
                                    }else{
                                        self.mCardCreationButton.isSelected = false
                                        self.mCardCreationSAIcon.image = UIImage(named: "unchecked_box_ic")
                                    }
                                    
                                    
                                }
                                
                                
                                if let mDHandlingBool =  mPrivacyData.value(forKey: "data_handling") as? Bool {
                                    if mDHandlingBool {
                                        self.mDataHandling  = "check"
                                        self.mDataHandlingButton.isSelected = true
                                        self.mDataHandlingIcon.image = UIImage(named: "checked_box_ic")
                                    }else{
                                        self.mDataHandling  = "uncheck"
                                        self.mDataHandlingButton.isSelected = false
                                        self.mDataHandlingIcon.image = UIImage(named: "unchecked_box_ic")
                                    }
                                    
                                }
                                
                                if let mCtermBool =  mPrivacyData.value(forKey: "contact_term") as? Bool {
                                    if mCtermBool {
                                        self.mContractTerm = "check"
                                        self.mContacttermButton.isSelected = true
                                        self.mCheckTermIcon.image = UIImage(named: "checked_box_ic")
                                    }else{
                                        self.mContractTerm = "uncheck"
                                        self.mContacttermButton.isSelected = false
                                        self.mCheckTermIcon.image = UIImage(named: "unchecked_box_ic")
                                    }
                                }
                                if let mCCreateBool =  mPrivacyData.value(forKey: "cardcreation") as? Bool {
                                    if mCCreateBool {
                                        self.mCardCreation = "check"
                                        self.mCardCreationButton.isSelected = true
                                        self.mCardCreationSAIcon.image = UIImage(named: "checked_box_ic")
                                    }else{
                                        self.mCardCreation = "uncheck"
                                        self.mCardCreationButton.isSelected = false
                                        self.mCardCreationSAIcon.image = UIImage(named: "unchecked_box_ic")
                                    }
                                    
                                    
                                }
                                
                                
                                self.mDataHandlingButton.isEnabled = false
                                self.mContacttermButton.isEnabled = false
                                
                            }
                            
                            if let mMarketOption = mData.value(forKey: "opt") as? String {
                                
                                self.mMarketCheck = mMarketOption
                                
                                if self.mMarketCheck == "check"{
                                    self.mMarketiingCheckButton.isSelected = true
                                    self.mMarketingMessageCheckIcon.image = UIImage(named: "checked_box_ic")
                                    self.mMarketCheck =  "check"
                                }
                                else{
                                    self.mMarketingMessageCheckIcon.image = UIImage(named: "unchecked_box_ic")
                                    self.mMarketCheck =  "uncheck"
                                    self.mMarketiingCheckButton.isSelected = false
                                    
                                }
                            }
                            
                            if let mMarketOptionBool = mData.value(forKey: "opt") as? Bool {
                                if mMarketOptionBool {
                                    self.mMarketiingCheckButton.isSelected = true
                                    self.mMarketingMessageCheckIcon.image = UIImage(named: "checked_box_ic")
                                    self.mMarketCheck =  "check"
                                }
                                else{
                                    self.mMarketingMessageCheckIcon.image = UIImage(named: "unchecked_box_ic")
                                    self.mMarketCheck =  "uncheck"
                                    self.mMarketiingCheckButton.isSelected = false
                                    
                                }
                            }
                            
                            
                            if let mTaxStatus = mData.value(forKey: "tax_exempt") as? String {
                                
                                self.mTaxCheck = mTaxStatus
                                
                                if self.mTaxCheck == "check"{
                                    self.mTaxExempButton.isSelected = true
                                    self.mTaxExempIcon.image = UIImage(named: "checked_box_ic")
                                    self.mTaxCheck =  "check"
                                }
                                else{
                                    self.mTaxExempIcon.image = UIImage(named: "unchecked_box_ic")
                                    self.mTaxCheck =  "uncheck"
                                    self.mTaxExempButton.isSelected = false
                                    
                                }
                                
                            }
                            if let mTaxStatusBool = mData.value(forKey: "tax_exempt") as? Bool {
                                if mTaxStatusBool {
                                    self.mTaxExempButton.isSelected = true
                                    self.mTaxExempIcon.image = UIImage(named: "checked_box_ic")
                                    self.mTaxCheck =  "check"
                                }
                                else{
                                    self.mTaxExempIcon.image = UIImage(named: "unchecked_box_ic")
                                    self.mTaxCheck =  "uncheck"
                                    self.mTaxExempButton.isSelected = false
                                    
                                }
                                
                            }
                            
                            
                            if mData.value(forKey: "iddigits") != nil {
                                self.mIdNumber.text = "\(mData.value(forKey: "iddigits") ?? "")"
                            }
                            if mData.value(forKey: "idtype") != nil {
                                
                                self.mIdCard.text  = "\(mData.value(forKey: "idtype") ?? "")"
                            }
                            
                            if let mDobData = mData.value(forKey: "date_of_birth") as? NSDictionary {
                                
                                let mBirthYear = "\(mDobData.value(forKey: "year") ?? "1920")"
                                self.mDay.text = "\(mDobData.value(forKey: "date") ?? "1")"
                                let monthNo = Int("\(mDobData.value(forKey: "month") ?? "1")") ?? 1
                                self.mMonth.text = self.mMonthList[monthNo - 1]
                                self.mYear.text = "\(mDobData.value(forKey: "year") ?? "1920")"
                                
                                var mCurrentYear = Int()
                                if #available(iOS 15, *) {
                                    mCurrentYear = Calendar(identifier: .gregorian).dateComponents([.year], from: .now).year ?? 0
                                    
                                } else {
                                    mCurrentYear = Calendar(identifier: .gregorian).dateComponents([.year], from: Date()).year ?? 0
                                }
                                
                                let mCurrentAge = mCurrentYear - (Int(mBirthYear) ?? 0)
                                self.mAgeRange.text = "\(mCurrentAge)"
                                
                            }
                            
                            self.mOccasion.text = "\(mData.value(forKey: "occasion") ?? "")"
                            
                            if let bData = mData.value(forKey: "billing_address") as? NSArray, bData.count > 0 {
                                
                                self.mBillingAddressList.removeAll()
                                self.mBillingFullAddressList.removeAll()
                                
                                for item in bData {
                                    if let data = item as? NSDictionary, data.value(forKey: "is_default") as? Int == 1 {
                                        
                                        let mBillingData = data
                                        let countryData = mBillingData.value(forKey: "country") as? NSDictionary
                                        self.mSelectBillingAddress.text = "\(mBillingData.value(forKey: "fullAddress") ?? "")"
                                        self.mBAddress.text = "\(mBillingData.value(forKey: "address") ?? "")"
                                        self.mBAddress.textColor =  UIColor(named: "themeLightText")
                                        self.mBState.text = "\(mBillingData.value(forKey: "state") ?? "")"
                                        self.mBCity.text = "\(mBillingData.value(forKey: "city") ?? "")"
                                        self.mBCountry.text = "\(countryData?.value(forKey: "label") ?? "")"
                                        self.mBZip.text = "\(mBillingData.value(forKey: "zipcode") ?? "")"
                                        self.mBTaxId.text = "\(mBillingData.value(forKey: "tax_number") ?? "")"
                                        
                                    }
                                    if let data = item as? [String : Any] {
                                        self.mBillingAddressList.append(data)
                                        self.mBillingFullAddressList.append(data["fullAddress"] as? String ?? "")
                                    }
                                }
                            }
                            
                            if let sData = mData.value(forKey: "shipping_address") as? NSArray, sData.count > 0 {
                                
                                self.mShippingAddressList.removeAll()
                                self.mShippingFullAddressList.removeAll()
                                
                                for item in sData {
                                    if let data = item as? NSDictionary, data.value(forKey: "is_default") as? Int == 1 {
                                        let mShippingData = data
                                        let countryData = mShippingData.value(forKey: "country") as? NSDictionary
                                        self.mSelectShippingAddress.text = "\(mShippingData.value(forKey: "fullAddress") ?? "")"
                                        self.mSAddress.text = "\(mShippingData.value(forKey: "address") ?? "")"
                                        self.mSAddress.textColor =  UIColor(named: "themeLightText")
                                        self.mSState.text = "\(mShippingData.value(forKey: "state") ?? "")"
                                        self.msCity.text = "\(mShippingData.value(forKey: "city") ?? "")"
                                        self.mSCountry.text = "\(countryData?.value(forKey: "label") ?? "")"
                                        self.mSZip.text = "\(mShippingData.value(forKey: "zipcode") ?? "")"
                                        self.mSTaxId.text = "\(mShippingData.value(forKey: "tax_number") ?? "")"
                                    }
                                    if let data = item as? [String : Any] {
                                        self.mShippingAddressList.append(data)
                                        self.mShippingFullAddressList.append(data["fullAddress"] as? String ?? "")
                                    }
                                }
                            }
                            
                        }
                        
                        
                    }else{
                        if jsonResult.value(forKey: "error") != nil {
                            if let error = jsonResult.value(forKey: "error") as? String,
                               error == "Authorization has been expired" {
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
    
    func mDropDown (dropdownKey: String) {
        
        if dropdownKey == "age" {
            let dropdown = DropDown()
            dropdown.anchorView = self.mAgeRange
            dropdown.direction = .any
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
            dropdown.direction = .any
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
            dropdown.direction = .any
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
            dropdown.direction = .any
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
            dropdown.direction = .any
            dropdown.bottomOffset = CGPoint(x: 0, y: self.mOccasion.frame.size.height)
            dropdown.width = self.mOccasion.frame.size.width
            dropdown.dataSource = mOccassionList
            dropdown.selectionAction = {
                [unowned self](index:Int, item: String) in
                self.mOccasion.text  = item
                
            }
            dropdown.show()
        } else if dropdownKey == "phoneCode" {
            let dropdown = DropDown()
            dropdown.anchorView = self.mPhoneCode
            dropdown.direction = .any
            dropdown.bottomOffset = CGPoint(x: 0, y: self.mPhoneCode.frame.size.height)
            dropdown.width = self.mPhoneCode.frame.size.width
            dropdown.dataSource = mPhoneCodeList
            dropdown.selectionAction = {
                [unowned self](index:Int, item: String) in
                self.mPhoneCode.text  = item
                
            }
            dropdown.show()
        }else if dropdownKey == "phoneCodeList" {
            if let cell = self.mMoblieNumTable.cellForRow(at: IndexPath(row:selectedPhoneCodeIndex,section: 0) ) as? MobileEmailList {
                let dropdown = DropDown()
                dropdown.anchorView = cell.mCountryCode
                dropdown.direction = .any
                dropdown.bottomOffset = CGPoint(x: 0, y: cell.mCountryCode.frame.size.height)
                dropdown.width = cell.mCountryCode.frame.size.width
                dropdown.dataSource = mPhoneCodeList
                dropdown.selectionAction = {
                    [unowned self](index:Int, item: String) in
                    cell.mCountryCode.text  = item
                    
                }
                dropdown.show()
            }
        }  else if dropdownKey == "country" {
            let dropdown = DropDown()
            dropdown.anchorView = self.mCountry
            dropdown.direction = .any
            dropdown.bottomOffset = CGPoint(x: 0, y: self.mCountry.frame.size.height)
            dropdown.width = 200
            dropdown.dataSource = mCountryList
            dropdown.selectionAction = {
                [unowned self](index:Int, item: String) in
                self.mCountry.text  = item
                
                self.mCity.text = ""
                self.mCountryId = self.mCountryListId[index]
            }
            dropdown.show()
        }  else if dropdownKey == "bcountry" {
            let dropdown = DropDown()
            dropdown.anchorView = self.mBCountry
            dropdown.direction = .any
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
            dropdown.direction = .any
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
            dropdown.direction = .any
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
        }else if dropdownKey == "title" {
            let dropdown = DropDown()
            dropdown.anchorView = self.mTitle
            dropdown.direction = .any
            dropdown.bottomOffset = CGPoint(x: 0, y: self.mTitle.frame.size.height)
            dropdown.width = 200
            dropdown.dataSource = mTitleList
            dropdown.selectionAction = {
                [unowned self](index:Int, item: String) in
                self.mTitle.text  = item
                
            }
            dropdown.show()
        }else if dropdownKey == "day" {
            let dropdown = DropDown()
            dropdown.anchorView = self.mDay
            dropdown.direction = .any
            dropdown.bottomOffset = CGPoint(x: 0, y: self.mDay.frame.size.height)
            dropdown.width = 200
            dropdown.dataSource = mDayList
            dropdown.selectionAction = {
                [unowned self](index:Int, item: String) in
                self.mDay.text  = item
                
            }
            dropdown.show()
        }else if dropdownKey == "month" {
            let dropdown = DropDown()
            dropdown.anchorView = self.mMonth
            dropdown.direction = .any
            dropdown.bottomOffset = CGPoint(x: 0, y: self.mMonth.frame.size.height)
            dropdown.width = 120
            dropdown.dataSource = mMonthList
            dropdown.selectionAction = {
                [unowned self](index:Int, item: String) in
                self.mMonth.text  = item
                
            }
            dropdown.show()
        }else if dropdownKey == "year" {
            let dropdown = DropDown()
            dropdown.anchorView = self.mYear
            dropdown.direction = .any
            dropdown.bottomOffset = CGPoint(x: 0, y: self.mYear.frame.size.height)
            dropdown.width = 200
            dropdown.dataSource = mYearList
            dropdown.selectionAction = {
                [unowned self](index:Int, item: String) in
                self.mYear.text  = item
                
                var mCurrentYear = Int()
                if #available(iOS 15, *) {
                    mCurrentYear = Calendar(identifier: .gregorian).dateComponents([.year], from: .now).year ?? 0
                    
                } else {
                    mCurrentYear = Calendar(identifier: .gregorian).dateComponents([.year], from: Date()).year ?? 0
                    
                }
                
                let mCurrentAge = mCurrentYear - (Int(item) ?? 0)
                
                self.mFinalAge = "\(mCurrentAge)"
                self.mAgeRange.text = "\(mCurrentAge) years old"
                
            }
            dropdown.show()
        }else if dropdownKey == "id" {
            let dropdown = DropDown()
            dropdown.anchorView = self.mIdCard
            dropdown.direction = .any
            dropdown.bottomOffset = CGPoint(x: 0, y: 180)
            dropdown.width = 200
            dropdown.dataSource = mIdTypeList
            dropdown.selectionAction = {
                [unowned self](index:Int, item: String) in
                self.mIdCard.text  = item
            }
            dropdown.show()
        } else if dropdownKey == "billingAddress" {
            let dropdown = DropDown()
            dropdown.anchorView = self.mSelectBillingAddress
            dropdown.direction = .any
            dropdown.bottomOffset = CGPoint(x: 0, y: self.mSelectBillingAddress.frame.size.height)
            dropdown.width =  self.mSelectBillingAddress.bounds.width
            dropdown.dataSource = mBillingFullAddressList
            dropdown.selectionAction = {
                [unowned self](index:Int, item: String) in
                setBillingAddress(addressData: mBillingAddressList[index])
                self.mBillingAddressIndex = index
            }
            dropdown.show()
        } else if dropdownKey == "shippingAddress" {
            let dropdown = DropDown()
            dropdown.anchorView = self.mSelectShippingAddress
            dropdown.direction = .any
            dropdown.bottomOffset = CGPoint(x: 0, y: self.mSelectShippingAddress.frame.size.height)
            dropdown.width =  self.mSelectShippingAddress.bounds.width
            dropdown.dataSource = mShippingFullAddressList
            dropdown.selectionAction = {
                [unowned self](index:Int, item: String) in
                setShippingAddress(addressData: mShippingAddressList[index])
                
                self.mShippingAddressIndex = index
            }
            dropdown.show()
        }
        
        
    }
    
    
    func mGetCountries(){
        
        let urlPath = mGrapQlUrl
        let params = ["query":"{countries{name id sortname phoneCode}}"]
        
        if Reachability.isConnectedToNetwork() == true {
            AF.request(urlPath, method:.post, parameters:params,encoding:JSONEncoding.default, headers: sGisHeaders2).responseJSON
            { response in
                
                if(response.error != nil){
                    
                    CommonClass.showSnackBar(message: "OOP's something went wrong!")
                    
                }else{
                    guard let jsonData = response.data else {
                        CommonClass.showSnackBar(message: "OOP's something went wrong!")
                        return
                    }
                    let json = try? JSONSerialization.jsonObject(with: jsonData, options: [])
                    guard let jsonResult = json as? NSDictionary,
                          let sData = jsonResult.value(forKey: "data") as? NSDictionary,
                          let data = sData.value(forKey: "countries") as? [[String: Any]]
                    else {
                        CommonClass.showSnackBar(message: "OOP's something went wrong!")
                        return
                    }
                    
                    let sortedData = data.sorted {
                        guard let name1 = ($0["name"] as? String)?.lowercased(),
                              let name2 = ($1["name"] as? String)?.lowercased()
                        else {
                            return false // Handle error or define sorting behavior for non-string values
                        }
                        return name1 < name2
                    }
                    
                    self.mPhoneCodeList.removeAll()
                    for countryData in sortedData {
                        if let countryName = countryData["name"] as? String,
                           let countryId = countryData["id"] as? String {
                            self.mCountryList.append(countryName)
                            self.mCountryListId.append(countryId)
                            if countryId == self.mBLCountryId {
                                self.mBCountry.text = countryName
                                self.mBCountryId = self.mBLCountryId
                            }
                            if countryId == self.mSHCountryId {
                                self.mSCountry.text = countryName
                                self.mSCountryId = self.mSHCountryId
                            }
                        }
                        if let pCode = countryData["phoneCode"] as? String, !pCode.isEmpty {
                            if !pCode.trim().isEmpty {
                                self.mPhoneCodeList.append(pCode)
                            }
                        }
                    }
                    
                }
                
            }
        }else{
            CommonClass.showSnackBar(message: "No Internet Connection")
        }
        
        
    }
    
    @IBAction func mCheckShipping(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected == true {
            
            mCheckShippingIcon.image = UIImage(named: "checked_box_ic")
            mShipingStackView.isHidden = true
            mSameShippingAddress =  "1"
            
        }
        else{
            mCheckShippingIcon.image = UIImage(named: "unchecked_box_ic")
            mShipingStackView.isHidden = false
            mSameShippingAddress =  "0"
        }
    }
    
    
    
}
