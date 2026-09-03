//
//  ItemSearchSoldReserved.swift
//  GIS
//
//  Created by MacBook Hawkscode  on 06/04/23.
//  Copyright © 2023 Hawkscode. All rights reserved.
//

import UIKit
import Alamofire
class ItemSearchSoldReserved : UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var mHeader: UILabel!
    @IBOutlet weak var mProductImage: UIImageView!
    @IBOutlet weak var mSearchField: UITextField!
    @IBOutlet weak var mStatusDot: UILabel!
    @IBOutlet weak var mMetaTag: UILabel!
    @IBOutlet weak var mMetalName: UILabel!
    @IBOutlet weak var mStoneName: UILabel!
    @IBOutlet weak var mSize: UILabel!
    @IBOutlet weak var mCollectionName: UILabel!
    @IBOutlet weak var mLocationName: UILabel!
    @IBOutlet weak var mNoDataFound: UILabel!
    @IBOutlet weak var mReserveTable: UITableView!
    @IBOutlet weak var mSKUName: UILabel!
    @IBOutlet weak var mStatusName: UILabel!
    @IBOutlet weak var mStockId: UILabel!
    @IBOutlet weak var mReserveBottomView: UIView!
    @IBOutlet weak var mRemoveReserveButton: UIButton!
    @IBOutlet weak var mBottomViewHeight: NSLayoutConstraint!
    var mData = NSMutableArray()
    var mDefaultData = NSArray()
    var mIndex = -1
    var mSelectedItems = [String]()
    var mIds = [String]()
    var mType = ""
    var mLocationId = ""
    var mSearchKey = ""
    var mSKUKey = ""
    @IBOutlet weak var mCollectionLABEL: UILabel!
    @IBOutlet weak var mSizeLABEL: UILabel!
    @IBOutlet weak var mStoneLABEL: UILabel!
    @IBOutlet weak var mMetalLABEL: UILabel!
 
    @IBOutlet weak var mProductSummaryLABEL: UILabel!
    @IBOutlet weak var mMaterialLABEL: UILabel!
    @IBOutlet weak var mPStoneLABEL: UILabel!
    @IBOutlet weak var mReferenceNoLABEL: UILabel!
    @IBOutlet weak var mCertificateLABEL: UILabel!
    
        override func viewDidLoad() {
            super.viewDidLoad()

            
            
            
            mNoDataFound.text = "No Data Found!".localizedString
            mProductSummaryLABEL.text = "Product Summary".localizedString
            mMaterialLABEL.text = "Material".localizedString
            mPStoneLABEL.text = "Stone".localizedString
            mReferenceNoLABEL.text = "Reference No.".localizedString
            mCertificateLABEL.text = "Certificate".localizedString

            mMetalLABEL.text = "Metal".localizedString
            mSizeLABEL.text = "Stone".localizedString
            mStoneLABEL.text = "Size".localizedString
            mCollectionLABEL.text = "Collection".localizedString
        
            mSearchField.placeholder = "Search by Stock Id / Customer".localizedString
            mRemoveReserveButton.setTitle("REMOVE".localizedString, for: .normal)
            
            
            if mType == "reserve" {
                mHeader.text = "Reserve".localizedString
                
                CommonClass.showFullLoader(view: self.view)
                var mParams = [String:Any]()
                mParams = ["location_id":mLocationId,"type":mType,"limit":"","search":mSearchKey,"SKU":mSKUKey]
                
                mGetData(url: mReserveSoldAPI ,headers: sGisHeaders,  params: mParams) { response , status in
                    CommonClass.stopLoader()
                    if status {
                        self.mData =  NSMutableArray()
                        self.mDefaultData = NSArray()
                    if "\(response.value(forKey: "code") ?? "")" == "200" {
                        
                        if let mDataItems = response.value(forKey: "data") as? NSArray {
                            
                            if mDataItems.count == 0 {
                                self.setDefaults()
                                return
                            }
                            self.mData =  NSMutableArray(array: mDataItems)
                            self.mDefaultData = mDataItems
                            
                            if let mData = mDataItems[0] as? NSDictionary {
                                self.mProductImage.downlaodImageFromUrl(urlString: "\(mData.value(forKey: "main_image") ?? "")")
                                
                                self.mStockId.text = "\(mData.value(forKey: "stock_id") ?? "--")"
                                self.mMetaTag.text = "\(mData.value(forKey: "Matatag") ?? "--")"
                                self.mLocationName.text = "\(mData.value(forKey: "location_name") ?? "--")"
                                self.mMetalName.text = "\(mData.value(forKey: "metal_name") ?? "--")"
                                self.mStoneName.text = "\(mData.value(forKey: "stone_name") ?? "--")"
                                self.mSKUName.text = "\(mData.value(forKey: "SKU") ?? "--")"
                                self.mSize.text = "\(mData.value(forKey: "size") ?? "--")"
                                self.mCollectionName.text = "\(mData.value(forKey: "collection_name") ?? "--")"
                            }
                            
                            self.mReserveTable.delegate = self
                            self.mReserveTable.dataSource = self
                            self.mReserveTable.reloadData()
                        }
                     }else{
                         self.setDefaults()

                        }
                      }
                     }
            }else{
                mHeader.text = "Sold".localizedString
                CommonClass.showFullLoader(view: self.view)
                var mParams = [String:Any]()
                mParams = ["ids":mIds]
             
                mGetData(url: mSoldAPI ,headers:sGisHeaders,  params: mParams) { response , status in
                    CommonClass.stopLoader()
                    if status {                        
                        self.mData =  NSMutableArray()
                        self.mDefaultData = NSArray()
                        if "\(response.value(forKey: "code") ?? "")" == "200" {
                            
                            if let mDataItems = response.value(forKey: "data") as? NSArray {
                                
                                if mDataItems.count == 0 {
                                    self.setDefaults()
                                    return
                                }
                                self.mData =  NSMutableArray(array: mDataItems)
                                self.mDefaultData = mDataItems
                            }
                            
                            if let mData = response.value(forKey: "SKUData") as? NSDictionary {
                                self.mProductImage.downlaodImageFromUrl(urlString: "\(mData.value(forKey: "images") ?? "")")
                                
                                self.mStockId.text = "\(mData.value(forKey: "stock_id") ?? "")"
                                self.mMetaTag.text = "\(mData.value(forKey: "Matatag") ?? "--")"
                                self.mLocationName.text = "\(mData.value(forKey: "location") ?? "--")"
                                self.mMetalName.text = "\(mData.value(forKey: "metal_name") ?? "--")"
                                self.mStoneName.text = "\(mData.value(forKey: "stone_name") ?? "--")"
                                self.mSKUName.text = "\(mData.value(forKey: "SKU") ?? "--")"
                                self.mSize.text = "\(mData.value(forKey: "size_name") ?? "--")"
                                self.mCollectionName.text = "\(mData.value(forKey: "Collection") ?? "--")"
                            }
                            
                            self.mStatusDot.backgroundColor = UIColor(named: "themeRed")
                            self.mStatusName.textColor = UIColor(named: "themeRed")
                            
                            self.mReserveTable.delegate = self
                            self.mReserveTable.dataSource = self
                            self.mReserveTable.reloadData()
                            
                        }else{
                         self.setDefaults()

                        }
                      }
                     }
                
            }

            
            mBottomViewHeight.constant = 0
            mReserveBottomView.isHidden = true
            
            
        }
        

    @IBAction func mBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        
    }
    
    func mNavigate(){
        if mType == "Inventory" {
            let storyBoard: UIStoryboard = UIStoryboard(name: "reserveBoard", bundle: nil)
            if let mInventoryPage = storyBoard.instantiateViewController(withIdentifier: "InventoryPageNew") as? InventoryPage {
                self.navigationController?.pushViewController(mInventoryPage, animated:true)
            }
        }else if mType == "ItemSearch" {
            let storyBoard: UIStoryboard = UIStoryboard(name: "reserveBoard", bundle: nil)
            if let mInventoryPage = storyBoard.instantiateViewController(withIdentifier: "ItemSearchPageNew") as? ItemSearchPage {
                self.navigationController?.pushViewController(mInventoryPage, animated:true)
            }
        }else  {
            self.navigationController?.popViewController(animated: true)
        }
    }
        
    @IBAction func mSearchFilters(_ sender: UITextField) {
        
        if sender.text == "" {
            mIndex = 0
            self.mData = NSMutableArray(array: mDefaultData)
            mReserveTable.reloadData()
        }else {
            mIndex = 0
            mData = NSMutableArray()
            
            for i in mDefaultData {
                if let mData = i as? NSDictionary {
                    let mValue = "\(mData.value(forKey: "customer_name") ?? "")"
                    let mStockId = "\(mData.value(forKey: "stock_id") ?? "")"
                    if let searchText = sender.text {
                        if mValue.lowercased().contains(searchText.lowercased()) || mStockId.contains(searchText) {
                            self.mData.add(mData)
                        }
                        mReserveTable.reloadData()
                    } else {
                        mReserveTable.reloadData()
                    }
                }
            }
        }
    }

        @IBAction func mOpenImageView(_ sender: Any) {
        }
        
        @IBAction func mRemoveItems(_ sender: Any) {
        
            CommonClass.showFullLoader(view: self.view)
            
           
            mGetData(url: mRemoveReserve ,headers: sGisHeaders,  params: ["id":mSelectedItems]) { response , status in
                
                CommonClass.stopLoader()
                if status {
                    if "\(response.value(forKey: "code") ?? "")" == "200" {
                        self.mSelectedItems = [String]()
                        CommonClass.showSnackBar(message: "Removed Successfully!")
                        
                        mGetData(url: mGetReserveList ,headers: sGisHeaders, params: ["":""]) { response , status in
                            CommonClass.stopLoader()
                            print("ItemSearchSoldReserved mGetReserveList response: \(response)")
                            if status {
                                self.mData =  NSMutableArray()
                                self.mDefaultData = NSArray()
                                if "\(response.value(forKey: "code") ?? "")" == "200" {
                                    
                                    if let mDataItems = response.value(forKey: "data") as? NSArray {
                                        
                                        if mDataItems.count == 0 {
                                            self.setDefaults()
                                            return
                                        }
                                        self.mData =  NSMutableArray(array: mDataItems)
                                        self.mDefaultData = mDataItems
                                        
                                        if let mData = mDataItems[0] as? NSDictionary {
                                            self.mProductImage.downlaodImageFromUrl(urlString: "\(mData.value(forKey: "main_image") ?? "")")
                                            self.mStockId.text = "\(mData.value(forKey: "stock_id") ?? "--")"
                                            self.mMetaTag.text = "\(mData.value(forKey: "Matatag") ?? "--")"
                                            self.mLocationName.text = "\(mData.value(forKey: "location_name") ?? "--")"
                                            self.mMetalName.text = "\(mData.value(forKey: "metal_name") ?? "--")"
                                            self.mStoneName.text = "\(mData.value(forKey: "stone_name") ?? "--")"
                                            self.mSKUName.text = "\(mData.value(forKey: "SKU") ?? "--")"
                                            self.mSize.text = "\(mData.value(forKey: "size") ?? "--")"
                                            self.mCollectionName.text = "\(mData.value(forKey: "collection_name") ?? "--")"
                                        }
                                        
                                        self.mReserveTable.delegate = self
                                        self.mReserveTable.dataSource = self
                                        self.mReserveTable.reloadData()
                                    }
                                }else{
                                    self.setDefaults()
                                    
                                }
                            }
                        }
                        
                    }else{
                    }
                }
            }
        
        }
        
        
        func setDefaults() {
            self.mStockId.text = "--"
            self.mMetaTag.text = "--"
            self.mSKUName.text = "--"
            self.mLocationName.text = "--"
            self.mSize.text = "--"
            self.mCollectionName.text = "--"
            self.mMetalName.text = "--"
            self.mStoneName.text = "--"
            self.mStatusName.text = "--"
            
            self.mData =  NSMutableArray()
            self.mDefaultData = NSArray()
            self.mReserveTable.delegate = self
            self.mReserveTable.dataSource = self
            self.mReserveTable.reloadData()
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            
            
            if mData.count == 0 {
                mNoDataFound.isHidden = false
                mReserveTable.isHidden = true
                self.mStockId.text = "--"
                self.mMetaTag.text = "--"
                self.mSKUName.text = "--"
                self.mLocationName.text = "--"
                self.mSize.text = "--"
                self.mCollectionName.text = "--"
                self.mMetalName.text = "--"
                self.mStoneName.text = "--"
                self.mStatusName.text = "--"
                
                
                mSelectedItems = [String]()
                mBottomViewHeight.constant = 0
                mReserveBottomView.isHidden = true
               
            }else{
                mNoDataFound.isHidden = true
                mReserveTable.isHidden = false
            }
            return mData.count
        }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        
        if mType == "reserve" {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "InventoryReservedItemsCell") as? InventoryReservedItemsCell else {
                return UITableViewCell()
            }
            
            if let mData = mData[indexPath.row] as? NSDictionary {
                cell.mDueDate.text = "\(mData.value(forKey: "dueDate") ?? "--")"
                self.mProductImage.downlaodImageFromUrl(urlString: "\(mData.value(forKey: "main_image") ?? "")")
                
                cell.mCustomerName.text = "\(mData.value(forKey: "customer_name") ?? "--")"
                cell.mAmount.text = "\(mData.value(forKey: "price") ?? "--")"
                cell.mQuantity.text = "\(mData.value(forKey: "reserve_qty")  ?? "--")"
                cell.mStockName.text = "\(mData.value(forKey: "SKU") ?? "--")"
                cell.mStockId.text = "\(mData.value(forKey: "stock_id") ?? "--")"
                
                cell.mView.backgroundColor = (indexPath.row % 2 == 0) ? UIColor(named: "themeBackground") : #colorLiteral(red: 0.9568627451, green: 0.9568627451, blue: 0.9568627451, alpha: 1)
                
                if mSelectedItems.isEmpty {
                    mBottomViewHeight.constant = 0
                    mReserveBottomView.isHidden = true
                }else{
                    mBottomViewHeight.constant = 80
                    mReserveBottomView.isHidden = false
                }

                if let poProductId = mData.value(forKey: "po_product_id") as? String {
                    if mSelectedItems.contains(poProductId) {
                        cell.mCheckIcon.image = UIImage(named: "check_item")
                    } else {
                        cell.mCheckIcon.image = UIImage(named: "uncheck_item")
                    }
                }
                
                if mIndex == indexPath.row {
                    self.mProductImage.downlaodImageFromUrl(urlString: "\(mData.value(forKey: "main_image") ?? "")")
                    self.mStockId.text = "\(mData.value(forKey: "stock_id") ?? "--")"
                    self.mMetaTag.text = "\(mData.value(forKey: "Matatag") ?? "--")"
                    self.mLocationName.text = "\(mData.value(forKey: "location_name") ?? "--")"
                    self.mMetalName.text = "\(mData.value(forKey: "metal_name") ?? "--")"
                    self.mStoneName.text = "\(mData.value(forKey: "stone_name") ?? "--")"
                    self.mSKUName.text = "\(mData.value(forKey: "SKU") ?? "__")"
                    self.mSize.text = "\(mData.value(forKey: "size_name") ?? "--")"
                    self.mCollectionName.text = "\(mData.value(forKey: "collection_name")  ?? "--")"
                    
                }
            }

            cell.layoutSubviews()
            return cell
            
        }else{
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "InventorySoldItemsCell") as? InventoryReservedItemsCell else {
                return UITableViewCell()
            }
            
            if let mData = mData[indexPath.row] as? NSDictionary {
                cell.mDueDate.text = "\(mData.value(forKey: "Date") ?? "--")"
                cell.mCustomerName.text = "\(mData.value(forKey: "customer_name") ?? "--")"
                cell.mQuantity.text = "\(mData.value(forKey: "qty")  ?? "--")"
                cell.mStockName.text = "\(mData.value(forKey: "SKU") ?? "--")"
                cell.mStockId.text = "\(mData.value(forKey: "stock_id") ?? "--")"
                cell.mAmount.text = "\(mData.value(forKey: "price") ?? "--")"
                cell.mOrderNo.text = "\(mData.value(forKey: "order_no") ?? "--")"
                cell.mSalesPersonName.text = "\(mData.value(forKey: "salesPerson") ?? "--")"
                cell.mLocationName.text = "\(mData.value(forKey: "location") ?? "--")"

                cell.mView.backgroundColor = (indexPath.row % 2 == 0) ? UIColor(named: "themeBackground") : #colorLiteral(red: 0.9568627451, green: 0.9568627451, blue: 0.9568627451, alpha: 1)
            }
            
            cell.layoutSubviews()
            return cell
        }
        
    }
        
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            if mType == "reserve"{
                return 74

            }else{
                return 146
            }
        }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if mType == "reserve" {
            if let mData = mData[indexPath.row] as? NSDictionary {
                mIndex = indexPath.row
                if let poProductId = mData.value(forKey: "po_product_id") as? String {
                    if mSelectedItems.contains(poProductId) {
                        mSelectedItems = mSelectedItems.filter { $0 != poProductId }
                    } else {
                        mSelectedItems.append(poProductId)
                    }
                }
                
                self.mReserveTable.reloadData()
            }
        }
    }
    
    
}
