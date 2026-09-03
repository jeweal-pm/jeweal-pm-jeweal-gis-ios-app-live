//
//  InventoryReserved.swift
//  GIS
//
//  Created by MacBook Hawkscode  on 07/04/23.
//  Copyright © 2023 Hawkscode. All rights reserved.
//

import UIKit
import Alamofire
class InventoryReserved : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
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
    var mType = ""
    
    
    @IBOutlet weak var mCollectionLABEL: UILabel!
    @IBOutlet weak var mSizeLABEL: UILabel!
    @IBOutlet weak var mStoneLABEL: UILabel!
    @IBOutlet weak var mMetalLABEL: UILabel!
    @IBOutlet weak var mHeading: UILabel!
    
    @IBOutlet weak var mProductSummaryLABEL: UILabel!
    @IBOutlet weak var mMaterialLABEL: UILabel!
    @IBOutlet weak var mPStoneLABEL: UILabel!
    @IBOutlet weak var mReferenceNoLABEL: UILabel!
    @IBOutlet weak var mCertificateLABEL: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("InventoryReserved OPEN")
        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
               
        mNoDataFound.text = "No Data Found!".localizedString
        mProductSummaryLABEL.text = "Product Summary".localizedString
        mMaterialLABEL.text = "Material".localizedString
        mPStoneLABEL.text = "Stone".localizedString
        mReferenceNoLABEL.text = "Reference No.".localizedString
        mCertificateLABEL.text = "Certificate".localizedString

        mMetalLABEL.text = "Metal".localizedString
        mSizeLABEL.text = "Size".localizedString
        mStoneLABEL.text = "Stone".localizedString
        mCollectionLABEL.text = "Collection".localizedString
        mHeading.text = "Reserved Items".localizedString
        mSearchField.placeholder = "Search by Stock Id / Customer".localizedString
        mRemoveReserveButton.setTitle("REMOVE".localizedString, for: .normal)
        
        print("viewDidLoad 111 mSize = \(mSize.text) , mMaterialLABEL = \(mMaterialLABEL.text)")

        CommonClass.showFullLoader(view: self.view)
        
        
        
        mGetData(url: mGetReserveList ,headers: sGisHeaders,  params: ["":""]) { response , status in
            CommonClass.stopLoader()
            if status {
                self.mData =  NSMutableArray()
                self.mDefaultData = NSArray()
            print("InventoryReserved mGetReserveList response: \(response)")
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
                        self.mSize.text = "\(mData.value(forKey: "Size_name") ?? "--")"
                        self.mCollectionName.text = "\(mData.value(forKey: "Collection_name") ?? "--")"
                        print("viewDidLoad 2222 mSize = \(self.mSize.text) , mMaterialLABEL = \(self.mMaterialLABEL.text)")
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
        
        mBottomViewHeight.constant = 0
        mRemoveReserveButton.isHidden = true
        
        
    }
    

    @IBAction func mBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
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
                    
                    let search = sender.text ?? ""
                    if mValue.lowercased().contains(search.lowercased()) || mStockId.contains(search)  {
                        self.mData.add(mData)
                        mReserveTable.reloadData()
                    }else{
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
                
                
                mGetData(url: mGetReserveList ,headers: sGisHeaders,  params: ["":""]) { response , status in
                    CommonClass.stopLoader()
                    if status {
                        self.mData =  NSMutableArray()
                        self.mDefaultData = NSArray()
                        print("mGetReserveList response = \(response)")
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
                                self.mSize.text = "\(mData.value(forKey: "Size_name") ?? "--")"
                                self.mCollectionName.text = "\(mData.value(forKey: "Collection_name") ?? "--")"
                                print("mRemoveItems mSize = \(self.mSize.text) , mMaterialLABEL = \(self.mMaterialLABEL.text)")
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
        
        print("setDefaults mSize = \(self.mSize.text) , mMaterialLABEL = \(self.mMaterialLABEL.text)")
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
            mRemoveReserveButton.isHidden = true
           
        }else{
            mNoDataFound.isHidden = true
            mReserveTable.isHidden = false
        }
        print("numberOfRowsInSection mSize = \(self.mSize.text) , mMaterialLABEL = \(self.mMaterialLABEL.text)")
        return mData.count
    }
    
    func formatReserveDate(_ value: String) -> String {

        print("FORMAT INPUT =", value)

        let parts = value.components(separatedBy: "/")

        print("PARTS =", parts)

        guard parts.count == 3 else {
            return value
        }

        let first = Int(parts[0]) ?? 0
        let second = Int(parts[1]) ?? 0
        let third = Int(parts[2]) ?? 0

        var year: Int
        var month: Int
        var day: Int

        // yyyy/MM/dd
        if first > 2500 || first >= 1000 {

            year = first
            month = second
            day = third

        // dd/MM/yyyy
        } else {

            day = first
            month = second
            year = third
        }

        // พ.ศ. -> ค.ศ.
        if year > 2500 {
            year -= 543
        }

        let result = String(
            format: "%02d/%02d/%04d",
            day,
            month,
            year
        )

        print("RESULT =", result)

        return result
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "InventoryReservedItemsCell") as? InventoryReservedItemsCell else {
            return UITableViewCell()
        }
       
        if let mData = mData[indexPath.row] as? NSDictionary {
//            cell.mDueDate.text = "\(mData.value(forKey: "dueDate") ?? "--")"
            let due = "\(mData["dueDate"] ?? "--")"
            cell.mDueDate.numberOfLines = 1
            cell.mDueDate.adjustsFontSizeToFitWidth = true
            cell.mDueDate.minimumScaleFactor = 0.5
            cell.mDueDate.lineBreakMode = .byClipping
            cell.mDueDate.text = formatReserveDate(due)
            self.mProductImage.downlaodImageFromUrl(urlString: "\(mData.value(forKey: "main_image") ?? "")")

            cell.mCustomerName.text = "\(mData.value(forKey: "customer_name") ?? "--")"
            cell.mAmount.text = "\(mData.value(forKey: "price") ?? "--")"
            cell.mQuantity.text = "\(mData.value(forKey: "reserve_qty")  ?? "--")"
            cell.mStockName.text = "\(mData.value(forKey: "SKU") ?? "--")"
            cell.mStockId.text = "\(mData.value(forKey: "stock_id") ?? "--")"

            let variantType = "\(mData.value(forKey: "product_variants_enable") ?? "0")"

            cell.mDesignView.isHidden = false

            switch variantType {
            case "1":
                // Variant
                cell.mDesignIcon.image = UIImage(named: "variantic")
            case "2":
                // Design
                cell.mDesignIcon.image = UIImage(named: "diamond_ic")
            case "3":
                // Packaging
                cell.mDesignIcon.image = UIImage(named: "diamond_ic")
            default:
                // Non-Variant
                cell.mDesignView.isHidden = true
                cell.mDesignIcon.image = nil
            }

            cell.mView.backgroundColor = (indexPath.row % 2 == 0) ? UIColor(named: "themeBackground") : #colorLiteral(red: 0.9568627451, green: 0.9568627451, blue: 0.9568627451, alpha: 1)

            if mSelectedItems.isEmpty {
                mBottomViewHeight.constant = 0
                mRemoveReserveButton.isHidden = true
            }else{
                mBottomViewHeight.constant = 80
                mRemoveReserveButton.isHidden = false
            }

            if let pId = mData.value(forKey: "po_product_id") as? String, mSelectedItems.contains(pId) {
                cell.mCheckIcon.image = UIImage(named: "check_item")
            }else{
                cell.mCheckIcon.image = UIImage(named: "uncheck_item")
            }
            print("cellForRowAt 1111 mSize = \(self.mSize.text) , mMaterialLABEL = \(self.mMaterialLABEL.text)")
            if mIndex == indexPath.row {
                self.mProductImage.downlaodImageFromUrl(urlString: "\(mData.value(forKey: "main_image") ?? "")")
                self.mStockId.text = "\(mData.value(forKey: "stock_id") ?? "--")"
                self.mMetaTag.text = "\(mData.value(forKey: "Matatag") ?? "--")"
                self.mLocationName.text = "\(mData.value(forKey: "location_name") ?? "--")"
                self.mMetalName.text = "\(mData.value(forKey: "metal_name") ?? "--")"
                self.mStoneName.text = "\(mData.value(forKey: "stone_name") ?? "--")"
                self.mSKUName.text = "\(mData.value(forKey: "SKU") ?? "__")"
                self.mSize.text = "\(mData.value(forKey: "size_name") ?? "--")"
                if(self.mSize.text == ""){self.mSize.text = "--"}
                self.mCollectionName.text = "\(mData.value(forKey: "Collection_name")  ?? "--")"
            }
            
            print("cellForRowAt 2222 mSize = \(self.mSize.text) , mMaterialLABEL = \(self.mMaterialLABEL.text)")
        }

        cell.layoutSubviews()
        return cell
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if let mData = mData[indexPath.row] as? NSDictionary {
            mIndex = indexPath.row
            print("tableView didSelectRowAt mData = \(mData)")
            if let poProductId = mData.value(forKey: "po_product_id") as? String {
                if mSelectedItems.contains(poProductId) {
                    mSelectedItems = mSelectedItems.filter {$0 != poProductId }
                }else{
                    mSelectedItems.append(poProductId)
                }
            }
            self.mReserveTable.reloadData()
        }
    }
    
    
}
