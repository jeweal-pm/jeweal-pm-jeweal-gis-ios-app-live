//
//  PosCustomerSearch.swift
//  GIS
//
//  Created by MacBook Hawkscode  on 06/02/23.
//  Copyright © 2023 Hawkscode. All rights reserved.
//

import UIKit
import Alamofire

class PosCustomerSearch: UIViewController , UITableViewDelegate ,UITableViewDataSource , UICollectionViewDelegate , UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, GetInventoryFiltersDelegate, UIViewControllerTransitioningDelegate{
    
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
    var mLocationArrayId = [String]()
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
    
    @IBOutlet weak var mFilterLABEL: UILabel!
    
    private let speechRecongniger = SpeechRecognizer(localeIdentifier: "en-US")
    private var isSpeechRecongnitionOn = false
    
    override func viewWillAppear(_ animated: Bool) {
        self.view.backgroundColor = UIColor(named: "themeBackground")

        mSearchField.placeholder =  "Search customer by name, mobile, email, country".localizedString
        mHCustomerLABEL.text = "Customer".localizedString
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        
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
    
        let storyBoard: UIStoryboard = UIStoryboard(name: "reserveBoard", bundle: nil)
        if let mProfile = storyBoard.instantiateViewController(withIdentifier: "CreateCustomer") as? CreateCustomer {
            self.navigationController?.pushViewController(mProfile, animated:true)
        }
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
        let storyBoard: UIStoryboard = UIStoryboard(name: "reserveBoard", bundle: nil)
        if let home = storyBoard.instantiateViewController(withIdentifier: "HomePage1") as? HomePage {
            self.navigationController?.pushViewController(home, animated:true)
        }
    }
    //MoreOptions Buttons
    
    @IBAction func mClearData(_ sender: Any) {
        mEmailArrayId = [String]()
        mNameArrayId = [String]()
        mLocationArrayId = [String]()
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
        if let mProfile = storyBoard.instantiateViewController(withIdentifier: "CustomerProfile") as? CustomerProfile 
        {
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
        searchCustomer(key: sender.text ?? "")
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return mCustomerData.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false

        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CustomerSearchCell") as? CustomerSearchCell {
            
            if let mData = mCustomerData[indexPath.row] as? NSDictionary {
                
                if UserDefaults.standard.string(forKey: "DEFAULTCUSTOMER") == "\(mData.value(forKey: "_id") ?? "")" {
                    cell.mCustomerName.textColor = UIColor(named: "themeColor")
                    if let cusId = mData.value(forKey: "_id") {
                        mCustomerId = "\(cusId)"
                    }
                    
                    if let name = mData.value(forKey: "name") as? String {
                        cell.mCustomerName.text =  name
                    } else {
                        cell.mCustomerName.text = "\(mData.value(forKey: "fname") ?? "")" + "\(mData.value(forKey: "lname") ?? "")"
                    }
                    
                    if let phoneCode = mData.value(forKey: "phone_code") {
                        self.mContactNumber.text = "\(phoneCode)"
                    }
                    if let phone = mData.value(forKey: "phone") {
                        self.mContactNumber.text?.append(" \(phone)")
                    }
                    
                    if let email = mData.value(forKey: "email_user") {
                        mEmailAddress.text = "\(email)"
                    }
                    if let conName = mData.value(forKey: "con_name") {
                        self.mCountryState.text = ("\(mData.value(forKey: "city_name") ?? ""), \(conName) ")
                    }
                    
                }
                else {
                    cell.mCustomerName.textColor = .black
                }
                
                if mData.value(forKey: "profile") != nil {
                    cell.mProfilrPicture.downlaodImageFromUrl(urlString: "\(mData.value(forKey: "profile") ?? "")")
                    cell.mProfilrPicture.contentMode = .scaleAspectFill
                }
                
                if let name = mData.value(forKey: "name") as? String {
                    cell.mCustomerName.text =  name
                }else{
                    cell.mCustomerName.text = "\(mData.value(forKey: "fname") ?? "")" + "\(mData.value(forKey: "lname") ?? "")"
                }
                
                if mData.value(forKey: "phone_code") != nil {
                    cell.mContactNumber.text = "\(mData.value(forKey: "phone_code") ?? "")"
                }
                if mData.value(forKey: "phone") != nil {
                    cell.mContactNumber.text?.append(" \(mData.value(forKey: "phone") ?? "")")
                }
                
                if let contactArray = mData.value(forKey: "contacts") as? NSArray {
                    if contactArray.count > 0 {
                        if let contact = contactArray[0] as? NSDictionary {
                            cell.mContactNumber.text? = "+\(contact.value(forKey: "phoneCode") ?? "")-\(contact.value(forKey: "number") ?? "")"
                        }
                    }
                }
                
                if let conName = mData.value(forKey: "con_name") {
                    cell.mCountryState.text = ("\(mData.value(forKey: "city_name") ?? "") , \(conName) ")
                }
                
            }
            return cell
        } else { return UITableViewCell()}
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let mData = mCustomerData[indexPath.row] as? NSDictionary {
            
            mIndex = indexPath.row
            if mData.value(forKey: "_id") != nil {
                mCustomerId = "\(mData.value(forKey: "_id") ?? "")"
            }
            
            self.dismiss(animated: true)
            let storyBoard: UIStoryboard = UIStoryboard(name: "reserveBoard", bundle: nil)
            if let mProfile = storyBoard.instantiateViewController(withIdentifier: "CustomerProfile") as? CustomerProfile {
                mProfile.mCustomerId = mCustomerId
                self.navigationController?.pushViewController(mProfile, animated:true)
                self.mCustomerTableView.reloadData()
            }
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CustomerSearchCell") as? CustomerSearchCell {
            return cell.mView.frame.height + 10
        } else { return 0 }
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
                
                if mNameArrayId.contains("\(self.mNameArray[indexPath.row])") {
                    cells.mName.backgroundColor =  #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)
                    cells.backgroundColor =  #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)
                }else{
                    cells.mName.backgroundColor =  #colorLiteral(red: 0.8078431373, green: 0.9333333333, blue: 0.9254901961, alpha: 1)
                    cells.backgroundColor =  #colorLiteral(red: 0.8078431373, green: 0.9333333333, blue: 0.9254901961, alpha: 1)
                }
                
                cells.layoutSubviews()
                
                cell = cells
            }
        }else if collectionView == self.mEmailCollectionView {
            if let cells = collectionView.dequeueReusableCell(withReuseIdentifier: "EmailCell", for: indexPath) as? EmailCell {
                
                cells.mEmail.text = "\(mEmailArray[indexPath.row])"
                if mEmailArrayId.contains("\(self.mEmailArray[indexPath.row])") {
                    cells.mEmail.backgroundColor =  #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)
                    cells.backgroundColor =  #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)
                }else{
                    cells.mEmail.backgroundColor =  #colorLiteral(red: 0.8078431373, green: 0.9333333333, blue: 0.9254901961, alpha: 1)
                    cells.backgroundColor =  #colorLiteral(red: 0.8078431373, green: 0.9333333333, blue: 0.9254901961, alpha: 1)
                }
                
                cells.layoutSubviews()
                cell = cells
            }
        }else if collectionView == self.mLocationCollectionView {
            if let cells = collectionView.dequeueReusableCell(withReuseIdentifier: "LocCell", for: indexPath) as? LocCell {
                if let mData = mLocationArray[indexPath.row] as? NSDictionary {
                    cells.mLocation.text = "\(mData.value(forKey: "name") ?? "")"
                    
                    if mLocationArrayId.contains(mData.value(forKey: "id") as? String ?? "") {
                        cells.mLocation.backgroundColor =  #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)
                        cells.backgroundColor =  #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)
                    }else{
                        cells.mLocation.backgroundColor =  #colorLiteral(red: 0.8078431373, green: 0.9333333333, blue: 0.9254901961, alpha: 1)
                        cells.backgroundColor =  #colorLiteral(red: 0.8078431373, green: 0.9333333333, blue: 0.9254901961, alpha: 1)
                    }
                    
                    cells.layoutSubviews()
                }
                cell = cells
            }
        }
      
        
        
        return cell
    }
    

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == self.mLocationCollectionView {
          
            if let mData = mLocationArray[indexPath.row] as? NSDictionary {
                if mLocationArrayId.contains(mData.value(forKey: "id") as? String ?? "") {
                    mLocationArrayId = mLocationArrayId.filter {$0 != mData.value(forKey: "id") as? String ?? "" }
                }else{
                    mLocationArrayId.append(mData.value(forKey: "id") as? String ?? "")
                }
                self.mLocationCollectionView.reloadData()
            }
        }
        
        if collectionView == self.mNameCollectionView {
          
            if mNameArrayId.contains(mNameArray[indexPath.row]) {
                mNameArrayId = mNameArrayId.filter {$0 != mNameArray[indexPath.row]}
              
            }else{
                mNameArrayId.append(mNameArray[indexPath.row])
            }
            self.mNameCollectionView.reloadData()
            
        }
        
        if collectionView == self.mEmailCollectionView {
          
            if mEmailArrayId.contains(mEmailArray[indexPath.row]) {
                mEmailArrayId = mEmailArrayId.filter {$0 != mEmailArray[indexPath.row]}
              
            }else{
                mEmailArrayId.append(mEmailArray[indexPath.row])
            }
            self.mEmailCollectionView.reloadData()
            
        }
    }
    

    func mGetCustomers(){
        
        let urlPath = mGetCustomerList
        
        let params:[String: Any] = ["search":"",
                                    "name":self.mNameId,
                                    "gender": mGenderId,
                                    "group":mGroupId,
                                    "minAge":mMinAge,
                                    "maxAge":mMaxAge,
                                    "country":mCountryId,
                                    "limit":""]
        
        guard Reachability.isConnectedToNetwork() == true else {
            CommonClass.showSnackBar(message: "No Internet Connection")
            return
        }
        CommonClass.showFullLoader(view: self.view)
        AF.request(urlPath, method:.post, parameters:params, encoding: JSONEncoding.default,headers: sGisHeaders2).responseJSON
        { response in
            CommonClass.stopLoader()
            
            if(response.error != nil){
                
                CommonClass.showSnackBar(message: "OOP's something went wrong!")
                
                
                
            }else{
                if let jsonData = response.data {
                    let json = try? JSONSerialization.jsonObject(with: jsonData, options: [])
                    if let jsonResult = json as? NSDictionary {
                        
                        if let mCode =  jsonResult.value(forKey: "code") as? Int {
                            if mCode == 403 {
                                CommonClass.sessionExpired(isExpired: true, navigation: self.navigationController)
                                return
                            }
                        }
                        
                        if jsonResult.value(forKey: "code") as? Int == 200 {
                            
                            
                            if jsonResult.value(forKey: "data") != nil {
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
                                        if let id = mData.value(forKey: "_id") {
                                            self.mCustomerId = "\(id)"
                                        }
                                        
                                        if let fName = mData.value(forKey: "fname") {
                                            self.mCustomerName.text =  "\(fName)"
                                            
                                        }
                                        if let lName = mData.value(forKey: "lname") {
                                            self.mCustomerName.text?.append(" \(lName)")
                                            
                                        }
                                        if let pCode = mData.value(forKey: "phone_code") {
                                            self.mContactNumber.text = "\(pCode)"
                                        }
                                        if let phone = mData.value(forKey: "phone") {
                                            self.mContactNumber.text?.append(" \(phone)")
                                        }
                                        
                                        if let email = mData.value(forKey: "email_user"){
                                            self.mEmailAddress.text = "\(email)"
                                        }
                                        if let cName = mData.value(forKey: "con_name") {
                                            self.mCountryState.text = ("\(mData.value(forKey: "city_name") ?? "") , \(cName)")
                                        }
                                    }
                                }
                            }
                            
                        } else {
                            if jsonResult.value(forKey: "error") != nil {
                                if "\(jsonResult.value(forKey: "error") ?? "")" == "Authorization has been expired" {
                                    CommonClass.sessionExpired(isExpired: true, navigation: self.navigationController)
                                }
                                
                            }
                        }
                    }
                }
            }
            
        }
        
    }
   
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
}
