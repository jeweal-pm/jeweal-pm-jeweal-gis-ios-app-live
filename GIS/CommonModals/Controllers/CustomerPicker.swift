//
//  CustomerPicker.swift
//  GIS
//
//  Created by MacBook Hawkscode  on 29/10/22.
//  Copyright © 2022 Hawkscode. All rights reserved.
//

import UIKit
import Alamofire

protocol GetCustomerDataDelegate {
    func mGetCustomerData(data : NSMutableDictionary)
    
    func mCreateNewCustomer()
}

class CustomerPicker: UIViewController , UITableViewDelegate ,UITableViewDataSource , UICollectionViewDelegate , UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, GetInventoryFiltersDelegate, UIViewControllerTransitioningDelegate{
    
    @IBOutlet weak var mFilterHeader: UIView!
    @IBOutlet weak var mFilterView: UIView!
    
    @IBOutlet weak var mCustomerImage: UIImageView!
    
    @IBOutlet weak var mCustomerName: UILabel!
    @IBOutlet weak var mCountryState: UILabel!
    
    @IBOutlet weak var mCustomerTableView: UITableView!
    
    @IBOutlet weak var mContactNumber: UILabel!
    @IBOutlet weak var mEmailAddress: UILabel!
    
    
    @IBOutlet weak var mMoreOptionsView: UIView!
    
    var mCustomerId = ""
    var mIndex = 0
    @IBOutlet weak var mNameCollectionView: UICollectionView!
    @IBOutlet weak var mLocationCollectionView: UICollectionView!
    @IBOutlet weak var mEmailCollectionView: UICollectionView!
    
    var mCustomerData = NSMutableArray()
    var mCustomerDataDefault = NSArray()
    var mNameArray = [String]()
    var mNameArrayId = [String]()
    
    var mEmailArray  = [String]()
    var mEmailArrayId = [String]()
    
    
    var mLocationArray = NSArray()
    
    var mNameId = [String]()
    var mGroupId = [String]()
    var mGenderId = [String]()
    var mCountryId = [String]()
    var mMinAge = ""
    var mMaxAge = ""
    
    
    
    var mFilterData = NSMutableDictionary()
    
    @IBOutlet weak var mHCustomerLABEL: UILabel!
    @IBOutlet weak var mSearchField: UITextField!
    @IBOutlet weak var mCProfileLABEL: UILabel!
    @IBOutlet weak var CPaymentLABEL: UILabel!
    @IBOutlet weak var mCPurchaseHistoryLABEL: UILabel!
    @IBOutlet weak var mCWishListLABEL: UILabel!
    @IBOutlet weak var mClearAllBUTTON: UIButton!
    @IBOutlet weak var mApplyFilterBUTTON: UIButton!
    @IBOutlet weak var mFNameLABEL: UILabel!
    
    @IBOutlet weak var mSelectAllBUTTON: UIButton!
    
    @IBOutlet weak var mFEmailLABEL: UILabel!
    @IBOutlet weak var mFSelectAllEBUTTON: UIButton!
    
    @IBOutlet weak var mFLocationLABEL: UILabel!
    
    @IBOutlet weak var mFLSelectAllBUTTON: UIButton!
    
    @IBOutlet weak var mCreateNewCustomerLABEL: UILabel!
    @IBOutlet weak var mFilterLABEL: UILabel!
    var mLocationArrayId = [String]()
    
    private let speechRecongniger = SpeechRecognizer(localeIdentifier: "en-US")
    private var isSpeechRecongnitionOn = false
    
    override func viewWillAppear(_ animated: Bool) {
        self.view.backgroundColor = UIColor(named: "themeBackground")
        
        mCreateNewCustomerLABEL.text = "CREATE NEW CUSTOMER".localizedString
        mSearchField.placeholder = "Search customer by name, mobile, email, country".localizedString
        mHCustomerLABEL.text = "Choose Customer".localizedString
        mClearAllBUTTON.setTitle("Clear All".localizedString, for: .normal)
        mApplyFilterBUTTON.setTitle("Apply Filter".localizedString, for: .normal)
        mFNameLABEL.text = "Name".localizedString
        mFEmailLABEL.text = "Email".localizedString
        mFLocationLABEL.text = "Location".localizedString
        mSelectAllBUTTON.setTitle("Select All".localizedString, for: .normal)
        mFSelectAllEBUTTON.setTitle("Select All".localizedString, for: .normal)
        mFLSelectAllBUTTON.setTitle("Select All".localizedString, for: .normal)
        mFilterLABEL.text = "Filter".localizedString
        
    }
    
    var delegate:GetCustomerDataDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.mHideOptions))
        mMoreOptionsView.addGestureRecognizer(tap)
        mMoreOptionsView.isUserInteractionEnabled = true
        
        mFilterHeader.layer.cornerRadius = 20
        mFilterHeader.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        
        self.mNameCollectionView.delegate = self
        self.mNameCollectionView.dataSource = self
        
        
        self.mEmailCollectionView.delegate = self
        self.mEmailCollectionView.dataSource = self
        
        self.mLocationCollectionView.delegate = self
        self.mLocationCollectionView.dataSource = self
        
        
        mGetCustomers()
    }
    
    
    @objc func mHideOptions(){
        mMoreOptionsView.isHidden = true
    }
    
    @IBAction func mAddNew(_ sender: Any) {

        self.dismiss(animated: true, completion: nil)
        self.delegate?.mCreateNewCustomer()
    }

    
    
    @IBAction func mOptions(_ sender: Any) {
        mMoreOptionsView.isHidden = false
        
    }
    
    @IBAction func mApplyFilters(_ sender: Any) {
        mFilterView.slideTop()
        mFilterView.isHidden = true
        mGetCustomers()
    }
    @IBAction func mBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func mCreateNewCustomer(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        self.delegate?.mCreateNewCustomer()
    }
    
    
    //MoreOptions Buttons
    
    @IBAction func mClearData(_ sender: Any) {
        mEmailArrayId = [String]()
        mNameArrayId = [String]()
        mNameCollectionView.reloadData()
        mEmailCollectionView.reloadData()
        mLocationCollectionView.reloadData()
        mGetCustomers()
    }
    @IBAction func mShowFilter(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "common", bundle: nil)
        if let mFilters = storyBoard.instantiateViewController(withIdentifier: "CommonCustomerFilters") as? CommonCustomerFilters {
            mFilters.delegate = self
            mFilters.mNameArrayId = mNameId
            mFilters.mMetalsId = mGroupId
            mFilters.mCollectionId = mGenderId
            mFilters.mLocationsId = mCountryId
            mFilters.mMinAges = mMinAge
            mFilters.mMaxAges = mMaxAge
            mFilters.modalPresentationStyle = .automatic
            mFilters.transitioningDelegate = self
            self.present(mFilters,animated: true)
        }
    }
    
    func mGetInventoryFilterData(itemsId: [String], metalId: [String], collectionId: [String], stoneId: [String], sizeId: [String], locationId: [String], statusId: [String], minPrice: String, maxPrice: String) {
        
        
        mNameId = itemsId
        mGroupId = metalId
        mGenderId = collectionId
        mCountryId = locationId
        mMinAge = minPrice
        mMaxAge = maxPrice
        
        mGetCustomers()
    }
    
    @IBAction func mHideFilterView(_ sender: Any) {
        mFilterView.slideTop()
        mFilterView.isHidden = true
        
    }
    
    @IBAction func mShowProfile(_ sender: Any) {
        mMoreOptionsView.isHidden = true
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let mProfile = storyBoard.instantiateViewController(withIdentifier: "CustomerProfile") as? CustomerProfile {
            mProfile.mCustomerId = mCustomerId
            mProfile.mCName = mCustomerName.text ?? ""
            mProfile.mCCountryState = mCountryState.text ?? ""
            mProfile.mCContact = mContactNumber.text ?? ""
            mProfile.mCEmail = mEmailAddress.text ?? ""
            self.navigationController?.pushViewController(mProfile, animated:true)
        }
    }
    
    
    @IBAction func mWishList(_ sender: Any) {
        
    }
    
    @IBAction func mPayment(_ sender: Any) {
    }
    
    @IBAction func mPurchase(_ sender: Any) {
        
    }
    
    
    @IBAction func mShowPurchasehistory(_ sender: Any) {
        mMoreOptionsView.isHidden = true
        mMoreOptionsView.isHidden = true
        let storyBoard: UIStoryboard = UIStoryboard(name: "Test", bundle: nil)
        if let mCustomerPurchaseHistory = storyBoard.instantiateViewController(withIdentifier: "CustomerPurchaseHistory") as? CustomerPurchaseHistory {
            mCustomerPurchaseHistory.mCustomerId = mCustomerId
            self.navigationController?.pushViewController(mCustomerPurchaseHistory, animated:true)
        }
    }
    
    @IBAction func mShowPayment(_ sender: Any) {
        mMoreOptionsView.isHidden = true
        let storyBoard: UIStoryboard = UIStoryboard(name: "Test", bundle: nil)
        if let mCPayment = storyBoard.instantiateViewController(withIdentifier: "CustomerPayment") as? CustomerPayment {
            mCPayment.mCustomerId = mCustomerId
            self.navigationController?.pushViewController(mCPayment, animated:true)
        }
    }
    
    @IBAction func mShowWishList(_ sender: Any) {
        
        mMoreOptionsView.isHidden = true
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let mProfile = storyBoard.instantiateViewController(withIdentifier: "WishListController") as? WishListController {
            self.navigationController?.pushViewController(mProfile, animated:true)
        }
    }
    
    @IBAction func mSearchCustomer(_ sender: UITextField) {
        
        if sender.text == "" {
            mIndex = 0
            mCustomerData = NSMutableArray(array: mCustomerDataDefault)
            mCustomerTableView.reloadData()
        } else {
            mIndex = 0
            mCustomerData = NSMutableArray()
            
            for i in mCustomerDataDefault {
                
                if let mData = i as? NSDictionary,
                   let mValue = mData.value(forKey: "name") as? String,
                   let search = sender.text, mValue.lowercased().contains(search.lowercased()) {
                    mCustomerData.add(mData)
                    mCustomerTableView.reloadData()
                }else{
                    mCustomerTableView.reloadData()
                }
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return mCustomerData.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CustomerSearchCell") as? CustomerSearchCell else {
            return UITableViewCell()
        }
        
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        
        if let mData = mCustomerData[indexPath.row] as? [String: Any] {
            cell.mProfilrPicture.contentMode = .scaleAspectFill
            
            if let defaultCustomerId = UserDefaults.standard.string(forKey: "DEFAULTCUSTOMER"),
               "\(mData["_id"] ?? "")" == defaultCustomerId {
                cell.mCustomerName.textColor = UIColor(named: "themeColor")
            } else {
                cell.mCustomerName.textColor = .black
            }
            
            if let mProfile = mData["profile"] as? String {
                cell.mProfilrPicture.downlaodImageFromUrl(urlString: mProfile)
            }
            
            if let country = mData["country"] as? String {
                cell.mCountryState.text = country
            }
            
            if let name = mData["name"] as? String {
                cell.mCustomerName.text = name
            } else {
                if let fname = mData["fname"] as? String,
                   let lname = mData["lname"] as? String {
                    cell.mCustomerName.text = fname + lname
                }
            }
            
            if let phone = mData["phone"] as? String {
                cell.mContactNumber.text = phone
            } else if let contactArray = mData["contacts"] as? [[String: Any]], !contactArray.isEmpty {
                if let contact = contactArray.first,
                   let phoneCode = contact["phoneCode"] as? String,
                   let number = contact["number"] as? String {
                    cell.mContactNumber.text = "+\(phoneCode)-\(number)"
                }
            }
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let mData = mCustomerData[indexPath.row] as? [String: Any] else {
            return
        }
        
        mIndex = indexPath.row
        if let id = mData["_id"] as? String {
            mCustomerId = id
        }
        
        let mCustomerData = NSMutableDictionary()
        
        if let mId = mData["_id"] {
            mCustomerData.setValue(mId, forKey: "id")
        }
        
        mCustomerData.setValue(mData["name"] as? String ?? "", forKey: "name")
        mCustomerData.setValue(mData["email"] as? String ?? "", forKey: "email")
        mCustomerData.setValue(mData["profile"] as? String ?? "", forKey: "profile")
        
        mCheckAddresse(mCustomerData)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CustomerSearchCell") as? CustomerSearchCell {
            return cell.mView.frame.height + 10
        } else {
            return 0
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count = 0
        if collectionView == self.mNameCollectionView {
            count = mNameArray.count
            
        }else if collectionView == self.mEmailCollectionView {
            count = mEmailArray.count
            
            
        }else if collectionView == self.mLocationCollectionView {
            count = mLocationArray.count
            
        }
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell = UICollectionViewCell()
        if collectionView == self.mNameCollectionView {
            if let cells = collectionView.dequeueReusableCell(withReuseIdentifier: "NameCell", for: indexPath) as? NameCell {
                
                cells.mName.text = "\(self.mNameArray[indexPath.row])"
                
                let nameExist = mNameArrayId.contains("\(self.mNameArray[indexPath.row])")
                
                cells.mName.backgroundColor = nameExist ? #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1) : #colorLiteral(red: 0.8078431373, green: 0.9333333333, blue: 0.9254901961, alpha: 1)
                cells.backgroundColor = nameExist ? #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1) : #colorLiteral(red: 0.8078431373, green: 0.9333333333, blue: 0.9254901961, alpha: 1)
                
                cells.layoutSubviews()
                cell = cells
            }
        }else if collectionView == self.mEmailCollectionView {
            if let cells = collectionView.dequeueReusableCell(withReuseIdentifier: "EmailCell", for: indexPath) as? EmailCell {
                
                cells.mEmail.text = "\(mEmailArray[indexPath.row])"
                
                let emailExist = mEmailArrayId.contains("\(self.mEmailArray[indexPath.row])")
                
                cells.mEmail.backgroundColor = emailExist ? #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1) : #colorLiteral(red: 0.8078431373, green: 0.9333333333, blue: 0.9254901961, alpha: 1)
                cells.backgroundColor = emailExist ? #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1) : #colorLiteral(red: 0.8078431373, green: 0.9333333333, blue: 0.9254901961, alpha: 1)
                
                cells.layoutSubviews()
                cell = cells
            }
        }else if collectionView == self.mLocationCollectionView {
            if let cells = collectionView.dequeueReusableCell(withReuseIdentifier: "LocCell", for: indexPath) as? LocCell {
                
                if let mData = mLocationArray[indexPath.row] as? NSDictionary {
                    
                    cells.mLocation.text = "\(mData.value(forKey: "name") ?? "")"
                    
                    let locationExist = mLocationArrayId.contains(mData.value(forKey: "id") as? String ?? "")
                    
                    cells.mLocation.backgroundColor = locationExist ? #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1) : #colorLiteral(red: 0.8078431373, green: 0.9333333333, blue: 0.9254901961, alpha: 1)
                    cells.backgroundColor = locationExist ? #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1) : #colorLiteral(red: 0.8078431373, green: 0.9333333333, blue: 0.9254901961, alpha: 1)
                    
                }
                cells.layoutSubviews()
                cell = cells
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
        case self.mLocationCollectionView:
            guard let mData = mLocationArray[indexPath.row] as? [String: Any],
                  let locationId = mData["id"] as? String else { return }
            
            if let index = mLocationArrayId.firstIndex(of: locationId) {
                mLocationArrayId.remove(at: index)
            } else {
                mLocationArrayId.append(locationId)
            }
            self.mLocationCollectionView.reloadData()
            
        case self.mNameCollectionView:
            
            if let index = mNameArrayId.firstIndex(of: mNameArray[indexPath.row]) {
                mNameArrayId.remove(at: index)
            } else {
                mNameArrayId.append(mNameArray[indexPath.row])
            }
            self.mNameCollectionView.reloadData()
            
        case self.mEmailCollectionView:
            
            if let index = mEmailArrayId.firstIndex(of: mEmailArray[indexPath.row]) {
                mEmailArrayId.remove(at: index)
            } else {
                mEmailArrayId.append(mEmailArray[indexPath.row])
            }
            self.mEmailCollectionView.reloadData()
            
        default:
            break
        }
    }

    func mGetCustomers(){
        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
        
        let urlPath = mGetCustomerList
        
        let params:[String: Any] = ["search":"",
                                    "name":self.mNameId,
                                    "gender": mGenderId,
                                    "group":mGroupId,
                                    "minAge":mMinAge,
                                    "maxAge":mMaxAge,
                                    "country":mCountryId,
                                    "limit":""]
        
        guard Reachability.isConnectedToNetwork() == true else{
            CommonClass.showSnackBar(message: "No Internet Connection")
            return
        }
            
        AF.request(urlPath, method:.post, parameters:params, encoding: JSONEncoding.default,headers: sGisHeaders2).responseJSON
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
                
                if jsonResult.value(forKey: "code") as? Int == 200 {
                    
                    if let data = jsonResult.value(forKey: "data") as? NSArray {
                        
                        self.mCustomerDataDefault = data
                        if data.count == 0 {
                            self.mCustomerData = NSMutableArray(array: data)
                            self.mCustomerTableView.delegate = self
                            self.mCustomerTableView.dataSource = self
                            self.mCustomerTableView.reloadData()
                            return
                        }
                        
                        self.mCustomerData = NSMutableArray(array: data)
                        self.mCustomerTableView.delegate = self
                        self.mCustomerTableView.dataSource = self
                        self.mCustomerTableView.reloadData()
                        if let mData = data[0] as? NSDictionary {
                            if let id = mData.value(forKey: "_id") as? String {
                                self.mCustomerId = id
                            }
                            
                            if let fname = mData.value(forKey: "fname") as? String {
                                self.mCustomerName.text =  fname
                            }
                            
                            if let lname = mData.value(forKey: "lname") as? String {
                                self.mCustomerName.text?.append(" \(lname)")
                            }
                            
                            if let pCode = mData.value(forKey: "phone_code") as? String {
                                self.mContactNumber.text = pCode
                            }
                            
                            if let phone = mData.value(forKey: "phone") as? String {
                                self.mContactNumber.text?.append(" \(phone)")
                            }
                            
                            if let email = mData.value(forKey: "email_user") as? String {
                                self.mEmailAddress.text = email
                            }
                            
                            if let conName = mData.value(forKey: "con_name") as? String,
                               let cityName = mData.value(forKey: "city_name")as? String {
                                self.mCountryState.text = ("\(cityName), \(conName)")
                            }
                        }
                    }
                    
                }else{
                    if let error = jsonResult.value(forKey: "error") {
                        if "\(error)" == "Authorization has been expired" {
                            CommonClass.sessionExpired(isExpired: true, navigation: self.navigationController)
                        }
                    }
                    
                }
                
                
            }
            
        }
           
    }
    
    func mCheckAddresse(_ customerData: NSMutableDictionary) {
        
        guard Reachability.isConnectedToNetwork() == true else {
            self.dismiss(animated: true, completion: nil)
            self.delegate?.mGetCustomerData(data: customerData)
            return
        }
        
        let params = ["id": mCustomerId] as [String : Any]
        
        AF.request(mCheckAddress, method:.post,parameters: params,encoding: JSONEncoding.default, headers: sGisHeaders).responseJSON { response in
            
            guard let jsonData = response.data else {
                self.dismiss(animated: true, completion: nil)
                self.delegate?.mGetCustomerData(data: customerData)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
                   let code = json["code"] as? Int {
                    switch code {
                    case 200:
                        if let haveAddress = json["AddressExists"] as? Bool {
                            customerData.setValue(haveAddress, forKey: "haveAddresses")
                        }
                        self.dismiss(animated: true, completion: nil)
                        self.delegate?.mGetCustomerData(data: customerData)
                    case 403:
                        CommonClass.sessionExpired(isExpired: true, navigation: self.navigationController)
                    default:
                        self.dismiss(animated: true, completion: nil)
                        self.delegate?.mGetCustomerData(data: customerData)
                    }
                }
            } catch {
                self.dismiss(animated: true, completion: nil)
                self.delegate?.mGetCustomerData(data: customerData)
            }
        }
        
    }
    
    func mGetFilterData(){}
    
    // Speech Recognition
    @IBOutlet weak var sMicImage: UIImageView!
    @IBAction func sSpeechRecognitionButton(_ sender: Any) {
        if !isSpeechRecongnitionOn {
            self.isSpeechRecongnitionOn = true
            self.sMicImage.image = UIImage(systemName: "mic.slash.fill")
            speechRecongniger.startRecognition { value in
                
                DispatchQueue.main.async {
                    self.isSpeechRecongnitionOn = false
                    self.sMicImage.image = UIImage(systemName: "mic.fill")
                    if let text = value , !text.isEmpty{
                        self.mSearchField.text = text
                        self.searchCustomer(key: text)
                        self.mSearchField.becomeFirstResponder()
                    }
                }
            }
            
        } else {
            self.sMicImage.image = UIImage(systemName: "mic.fill")
            self.isSpeechRecongnitionOn = false
            speechRecongniger.stopRecognition()
        }
    }
    
    private func searchCustomer(key: String){
        if key == "" {
            
            mIndex = 0
            mCustomerData = NSMutableArray(array: mCustomerDataDefault)
            mCustomerTableView.reloadData()
            
        }else {
            mIndex = 0
            mCustomerData = NSMutableArray()
            for i in mCustomerDataDefault {
                
                if let mData = i as? NSDictionary {
                    let mValue = "\(mData.value(forKey: "name") ?? "")"
                    
                    if mValue.lowercased().contains(key.lowercased()) {
                        mCustomerData.add(mData)
                        mCustomerTableView.reloadData()
                    }else{
                        mCustomerTableView.reloadData()
                    }
                }
            }
        }
    }
    
}
