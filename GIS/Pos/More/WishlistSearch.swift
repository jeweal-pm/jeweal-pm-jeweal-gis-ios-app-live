//
//  WishlistSearch.swift
//  GIS
//
//  Created by MacBook Hawkscode  on 16/12/22.
//  Copyright © 2022 Hawkscode. All rights reserved.
//

import UIKit
import Alamofire

class WishListSearchItems: UITableViewCell {
    @IBOutlet weak var mView: UIView!
    @IBOutlet weak var mProfilrPicture: UIImageView!

    @IBOutlet weak var mCustomerName: UILabel!
    
    @IBOutlet weak var mCountryState: UILabel!
    
    @IBOutlet weak var mTotalCounts: UILabel!
    @IBOutlet weak var mContactNumber: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
class WishlistSearch: UIViewController , UITableViewDelegate ,UITableViewDataSource ,GetCustomerDataDelegate, UIViewControllerTransitioningDelegate {
    
    
    @IBOutlet weak var mCustomerImage: UIImageView!
    
    
    @IBOutlet weak var mCounts: UILabel!
    
    
    var mCreatedAt = "-1"
    var mMostWishlisted = "-1"
    
    @IBOutlet weak var mNoData: UILabel!
    var mCustomerId = ""
    var mIndex = 0
    
    var mCustomerData = NSMutableArray()
    var mCustomerDataDefault = NSArray()
    
    
    @IBOutlet weak var mWishListTable: UITableView!
    
    
    @IBOutlet weak var mHeadingLABEL: UILabel!
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
    
    @IBOutlet weak var mBottomView: UIView!
    @IBOutlet weak var mBottomSheet: UIView!
    
    @IBOutlet weak var mMostWishList: UILabel!
    
    @IBOutlet weak var mNewestCustomer: UILabel!
    
    @IBOutlet weak var mOldestCustomer: UILabel!
    
    @IBOutlet weak var mFLSelectAllBUTTON: UIButton!
    
    @IBOutlet weak var mSortByLABEL: UILabel!
    @IBOutlet weak var mTotalCustomerLABEL: UILabel!
    @IBOutlet weak var mFilterLABEL: UILabel!
    override func viewWillAppear(_ animated: Bool) {
        self.view.backgroundColor = UIColor(named: "themeBackground")

        
        mSearchField.placeholder = "Search by SKU/Customer".localizedString
        mHeadingLABEL.text = "Wishlist".localizedString
        mNoData.text = "No Data Found!".localizedString
        mTotalCustomerLABEL.text = "Total Customer".localizedString
        mSortByLABEL.text = "Sort By".localizedString

        
        mCounts.text = "--"
        mGetCustomers()
        addDoneButtonOnKeyboard()
    }
    
    
    @IBAction func mHideFilters(_ sender: Any) {
    
        
        self.mBottomSheet.isHidden = true
        self.mBottomView.isHidden = true
    }
    
    func addDoneButtonOnKeyboard(){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Search", style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        mSearchField.inputAccessoryView = doneToolbar
    }

    @objc func doneButtonAction(){
        
        self.mGetCustomers()
        mSearchField.resignFirstResponder()
    }
 
    @IBOutlet weak var mFilterName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(self.onTapMost))
        mMostWishList.addGestureRecognizer(tap1)
        mMostWishList.isUserInteractionEnabled = true
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(self.onTapOld))
        mOldestCustomer.addGestureRecognizer(tap2)
        mOldestCustomer.isUserInteractionEnabled = true
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(self.onTapNew))
        mNewestCustomer.addGestureRecognizer(tap3)
        mNewestCustomer.isUserInteractionEnabled = true
        
        self.mMostWishList.textColor = UIColor(named: "themeColor")
        self.mMostWishList.backgroundColor = UIColor(named: "themeVeryLight")
        self.mMostWishList.font = UIFont(name: "SegoeUI-Bold", size: 16.0)
        
        self.mOldestCustomer.textColor = UIColor(named: "themeText")
        self.mOldestCustomer.backgroundColor = .clear
        self.mOldestCustomer.font = UIFont(name: "SegoeUI", size: 16.0)
        
     
        self.mNewestCustomer.textColor = UIColor(named: "themeText")
        self.mNewestCustomer.backgroundColor = .clear
        self.mNewestCustomer.font = UIFont(name: "SegoeUI", size: 16.0)
        
        mBottomView.layer.cornerRadius = 10
        mBottomView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        mBottomView.dropShadow()
        
    }
    
 
    @IBAction func mBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        
    }
    
    
    
    @IBAction func mShowFilter(_ sender: Any) {
        
        self.mBottomSheet.isHidden = false
        
        mBottomView.slideFromBottom()
        self.mBottomView.isHidden = false
        
        
    }
    
    
    @objc
    func onTapMost(){
        
        
        self.mMostWishList.textColor = UIColor(named: "themeColor")
        self.mMostWishList.backgroundColor = UIColor(named: "themeVeryLight")
        self.mMostWishList.font = UIFont(name: "SegoeUI-Bold", size: 16.0)
        
        self.mOldestCustomer.textColor = UIColor(named: "themeText")
        self.mOldestCustomer.backgroundColor = .clear
        self.mOldestCustomer.font = UIFont(name: "SegoeUI", size: 16.0)
        
        
        self.mNewestCustomer.textColor = UIColor(named: "themeText")
        self.mNewestCustomer.backgroundColor = .clear
        self.mNewestCustomer.font = UIFont(name: "SegoeUI", size: 16.0)
        self.mBottomSheet.isHidden = true
        self.mBottomView.isHidden = true
        self.mFilterName.text = "Most Wishlist"
        mCreatedAt = "-1"
        mMostWishlisted = "1"
        mGetCustomers()
        
    }
    @objc
    func onTapOld(){
        self.mOldestCustomer.textColor = UIColor(named: "themeColor")
        self.mOldestCustomer.backgroundColor = UIColor(named: "themeVeryLight")
        self.mOldestCustomer.font = UIFont(name: "SegoeUI-Bold", size: 16.0)
        
        
        self.mMostWishList.textColor = UIColor(named: "themeText")
        self.mMostWishList.backgroundColor = .clear
        self.mMostWishList.font = UIFont(name: "SegoeUI", size: 16.0)
        
        self.mNewestCustomer.textColor = UIColor(named: "themeText")
        self.mNewestCustomer.backgroundColor = .clear
        self.mNewestCustomer.font = UIFont(name: "SegoeUI", size: 16.0)
        
        self.mFilterName.text = "Oldest Customer"
        self.mBottomSheet.isHidden = true
        self.mBottomView.isHidden = true
        mCreatedAt = "1"
        mMostWishlisted = "-1"
        mGetCustomers()
        
    }
    @objc
    func onTapNew(){
        self.mNewestCustomer.textColor = UIColor(named: "themeColor")
        self.mNewestCustomer.backgroundColor = UIColor(named: "themeVeryLight")
        self.mNewestCustomer.font = UIFont(name: "SegoeUI-Bold", size: 16.0)
        
        self.mOldestCustomer.textColor = UIColor(named: "themeText")
        self.mOldestCustomer.backgroundColor = .clear
        self.mOldestCustomer.font = UIFont(name: "SegoeUI", size: 16.0)
        
        self.mMostWishList.textColor = UIColor(named: "themeText")
        self.mMostWishList.backgroundColor = .clear
        self.mMostWishList.font = UIFont(name: "SegoeUI", size: 16.0)
        self.mFilterName.text = "Newest Customer"
        self.mBottomSheet.isHidden = true
        self.mBottomView.isHidden = true
        mCreatedAt = "1"
        mMostWishlisted = "-1"
        mGetCustomers()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        if mCustomerData.count == 0 {
            mNoData.isHidden = false
            mWishListTable.isHidden = true
            
        }else{
            mNoData.isHidden = true
            mWishListTable.isHidden = false
        }
        return mCustomerData.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "WishListSearchItems") as? WishListSearchItems else {
            return UITableViewCell()
        }
        
        if let mData = mCustomerData[indexPath.row] as? NSDictionary {
            cell.mProfilrPicture.contentMode = .scaleAspectFill
            cell.mCustomerName.text = "\(mData.value(forKey: "name") ?? "--" )"
            cell.mCountryState.text = "\(mData.value(forKey: "country_name") ?? "--" )"
            cell.mTotalCounts.text = "\(mData.value(forKey: "product_count") ?? "--" )"
            cell.mContactNumber.text = "\(mData.value(forKey: "mobile") ?? "--" )"
            if let profile = mData.value(forKey: "profile") as? String, !profile.isEmpty {
                cell.mProfilrPicture.downlaodImageFromUrl(urlString: profile)
            } else {
                cell.mProfilrPicture.image = UIImage(named: "avatar_ic")
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let mData = mCustomerData[indexPath.row] as? NSDictionary,
           let customerId = mData.value(forKey: "customer_id") as? String{
            let storyBoard: UIStoryboard = UIStoryboard(name: "catalog", bundle: nil)
            if let mProfile = storyBoard.instantiateViewController(withIdentifier: "WishListControllerNew") as? WishListController {
                mProfile.mCustomerId = customerId
                self.navigationController?.pushViewController(mProfile, animated:true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "WishListSearchItems") as? WishListSearchItems {
            return cell.mView.frame.height + 10
        } else {
            return CGFloat(integerLiteral: 0)
        }
    }
    
    
    
    
    @IBAction func mChooseCustomer(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "common", bundle: nil)
        if let home = storyBoard.instantiateViewController(withIdentifier: "CustomerPicker") as? CustomerPicker {
            home.delegate = self
            home.modalPresentationStyle = .automatic
            home.transitioningDelegate = self
            self.present(home,animated: true)
        }
    }
    func mCreateNewCustomer() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "reserveBoard", bundle: nil)
        if let mCreateCustomer = storyBoard.instantiateViewController(withIdentifier: "CreateCustomer") as? CreateCustomer {
            self.navigationController?.pushViewController(mCreateCustomer, animated:true)
        }
    }
    
    func mGetCustomerData(data: NSMutableDictionary) {
        if let id = data.value(forKey: "id") as? String,
           let profile = data.value(forKey: "profile") as? String,
           let name = data.value(forKey: "name") as? String {
            UserDefaults.standard.set(id, forKey: "DEFAULTCUSTOMER")
            UserDefaults.standard.set(profile, forKey: "DEFAULTCUSTOMERPICTURE")
            UserDefaults.standard.set(name , forKey: "DEFAULTCUSTOMERNAME")
            
            self.mCustomerId = id
            let storyBoard: UIStoryboard = UIStoryboard(name: "catalog", bundle: nil)
            if let mProfile = storyBoard.instantiateViewController(withIdentifier: "WishListControllerNew") as? WishListController {
                mProfile.mCustomerId = mCustomerId
                self.navigationController?.pushViewController(mProfile, animated:true)
            }
        }
    }
    
    
    @IBAction func mLikeDislike(_ sender: Any) {
    }
    
    
    
    
    func mGetCustomers(){
        
        let urlPath = mGetWishList
        
        let params: [String: Any] = ["search":mSearchField.text ?? "", "createdAt":mCreatedAt, "most_wishlist": mMostWishlisted]
        
        if Reachability.isConnectedToNetwork() == true {
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
                    
                    self.mCustomerData = NSMutableArray()
                    
                    if jsonResult.value(forKey: "code") as? Int == 200 {
                        
                        self.mCounts.text = "\(jsonResult.value(forKey: "count") ?? "--")"
                        
                        if let data = jsonResult.value(forKey: "data")  as? NSArray {
                            
                            self.mCustomerDataDefault = data
                            
                            self.mCustomerData = NSMutableArray(array: data)
                            self.mWishListTable.delegate = self
                            self.mWishListTable.dataSource = self
                            self.mWishListTable.reloadData()
                            
                        } else {
                            
                            self.mWishListTable.reloadData()
                            
                        }
                        
                    }else{
                        self.mWishListTable.reloadData()
                        
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
    
    
    
}
