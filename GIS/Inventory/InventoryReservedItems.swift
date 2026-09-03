//
//  InventoryReservedItems.swift
//  GIS
//
//  Created by MacBook Hawkscode  on 08/12/22.
//  Copyright © 2022 Hawkscode. All rights reserved.
//

import UIKit
import Alamofire
class InventoryReservedItemsCell : UITableViewCell {

    @IBOutlet weak var mCustomerName: UILabel!
    @IBOutlet weak var mView: UIView!
    @IBOutlet weak var mDueDate: UILabel!
    @IBOutlet weak var mCheckView: UIView!
    @IBOutlet weak var mStockName: UILabel!
    @IBOutlet weak var mStockId: UILabel!
    @IBOutlet weak var mStatusColor: UILabel!
    @IBOutlet weak var mAmount: UILabel!
    @IBOutlet weak var mQuantity: UILabel!
    @IBOutlet weak var mCheckIcon: UIImageView!
    @IBOutlet weak var mDesignView: UIView!
    @IBOutlet weak var mDesignIcon: UIImageView!

    @IBOutlet weak var mOrderNo: UILabel!

    @IBOutlet weak var mSalesPersonName: UILabel!

    @IBOutlet weak var mLocationName: UILabel!

    override func prepareForReuse() {
        super.prepareForReuse()

        // Reset only the variant/design icon state so a reused cell
        // cannot display the previous row's icon.
        mDesignIcon.image = nil
        mDesignView.isHidden = true
    }
}


class InventoryReservedItems: UIViewController, UITableViewDelegate, UITableViewDataSource, UIViewControllerTransitioningDelegate {
    
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
    var mSKUForImage = ""
    var mProductIdForImage = ""
    
    @IBOutlet weak var mReserveHeadingLABEL: UILabel!
    @IBOutlet weak var mICollectionLABEL: UILabel!
    @IBOutlet weak var mIMetalLABEL: UILabel!
    @IBOutlet weak var mIStoneLABEL: UILabel!
    @IBOutlet weak var mISizeLABEL: UILabel!
    
    
    override func viewWillAppear(_ animated: Bool) {
        mSearchField.placeholder = "Search by SKU/Customer".localizedString
        mReserveHeadingLABEL.text = "Reserve List".localizedString
        mICollectionLABEL.text = "Collection".localizedString
        mIMetalLABEL.text = "Metal".localizedString
        mIStoneLABEL.text = "Stone".localizedString
        mISizeLABEL.text = "Size".localizedString
        mNoDataFound.text = "No Data Found!".localizedString
        mRemoveReserveButton.setTitle("REMOVE".localizedString, for: .normal)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CommonClass.showFullLoader(view: self.view)
        
        mGetData(url: mGetReserveList ,headers: sGisHeaders,  params: ["":""]) { response , status in
            CommonClass.stopLoader()
            print("InventoryReservedItems mGetReserveList response: \(response)")
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
//                            self.mSize.text = "\(mData.value(forKey: "size") ?? "--")"
//                            self.mCollectionName.text = "\(mData.value(forKey: "collection_name") ?? "--")"
                            let sizeName = "\(mData.value(forKey: "Size_name") ?? mData.value(forKey: "size_name") ?? "--")"
                            self.mSize.text = !sizeName.isEmpty ? sizeName : "--"

                            self.mCollectionName.text = "\(mData.value(forKey: "Collection_name") ?? mData.value(forKey: "collection_name") ?? "--")"
                        }
                        self.mReserveTable.delegate = self
                        self.mReserveTable.dataSource = self
                        self.mReserveTable.reloadData()
                    }
                }else{
                    self.setDefaults()
                    if let error = response.value(forKey: "error") as? String {
                        if error == "Authorization has been expired" {
                            CommonClass.sessionExpired(isExpired: true, navigation: self.navigationController)
                        }
                    }
                }
            }
        }
        
        mBottomViewHeight.constant = 0
        mRemoveReserveButton.isHidden = true
        
        
    }
    

    @IBAction func mBack(_ sender: Any) {
        mNavigate()
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
                    
                    if let searchKey = sender.text,
                       mValue.lowercased().contains(searchKey.lowercased()) || mStockId.contains(searchKey)  {
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
        
        if mProductIdForImage != "" {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Test", bundle: nil)
            if let mGlobalImageViewer = storyBoard.instantiateViewController(withIdentifier: "GlobalImageViewer") as? GlobalImageViewer {
                mGlobalImageViewer.modalPresentationStyle = .overFullScreen
                mGlobalImageViewer.mProductId = mProductIdForImage
                mGlobalImageViewer.mSKUName = mSKUForImage
                mGlobalImageViewer.transitioningDelegate = self
                self.present(mGlobalImageViewer,animated: false)
            }
        }
        
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
                        print("InventoryReservedItems mRemoveItems mGetReserveList response: \(response)")
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
                                        let sizeName = "\(mData.value(forKey: "Size_name") ?? mData.value(forKey: "size_name") ?? "--")"
                                        self.mSize.text = !sizeName.isEmpty ? sizeName : "--"
                                        self.mCollectionName.text = "\(mData.value(forKey: "Collection_name") ?? "--")"
                                    }
                                    self.mReserveTable.delegate = self
                                    self.mReserveTable.dataSource = self
                                    self.mReserveTable.reloadData()
                                }
                            }else{
                                self.setDefaults()
                                if let error = response.value(forKey: "error") as? String {
                                    if error == "Authorization has been expired" {
                                        CommonClass.sessionExpired(isExpired: true, navigation: self.navigationController)
                                    }
                                }
                            }
                        }
                    }
                    
                }else{
                    if let error = response.value(forKey: "error") as? String {
                        if error == "Authorization has been expired" {
                            CommonClass.sessionExpired(isExpired: true, navigation: self.navigationController)
                        }
                    }
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
            mRemoveReserveButton.isHidden = true
            
        }else{
            mNoDataFound.isHidden = true
            mReserveTable.isHidden = false
        }
        return mData.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "InventoryReservedItemsCell") as? InventoryReservedItemsCell else {
            return UITableViewCell()
        }
        
        if let mData = mData[indexPath.row] as? NSDictionary {
            print("mData = \(mData)")
//            cell.mDueDate.text = "\(mData.value(forKey: "dueDate") ?? "--")"
            cell.mDueDate.numberOfLines = 1
            cell.mDueDate.adjustsFontSizeToFitWidth = true
            cell.mDueDate.minimumScaleFactor = 0.5
            cell.mDueDate.lineBreakMode = .byClipping
            let due = "\(mData["dueDate"] ?? "--")"
            cell.mDueDate.text = formatReserveDate(due)
            self.mProductImage.downlaodImageFromUrl(urlString: "\(mData.value(forKey: "main_image") ?? "")")
            
            cell.mCustomerName.text = "\(mData.value(forKey: "customer_name") ?? "--")"
//            let formatter = NumberFormatter()
//            formatter.numberStyle = .decimal
//            formatter.minimumFractionDigits = 2
//            formatter.maximumFractionDigits = 2
            print("mData.value(forKey: price) = \(mData.value(forKey: "price") ?? "--")")
//            if let price = mData.value(forKey: "price") as? NSNumber {
//                cell.mAmount.text = formatter.string(from: price)
//            } else if let price = mData.value(forKey: "price") as? Double {
//                cell.mAmount.text = formatter.string(from: NSNumber(value: price))
//            } else if let price = mData.value(forKey: "price") as? Int {
//                cell.mAmount.text = formatter.string(from: NSNumber(value: price))
//            } else {
//                cell.mAmount.text = "--"
//            }
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
            
            if (indexPath.row % 2 == 0) {
                cell.mView.backgroundColor = UIColor(named: "themeBackground")
            }else{
                cell.mView.backgroundColor = #colorLiteral(red: 0.9568627451, green: 0.9568627451, blue: 0.9568627451, alpha: 1)
            }
            
            if mSelectedItems.isEmpty {
                mBottomViewHeight.constant = 0
                mRemoveReserveButton.isHidden = true
            }else{
                mBottomViewHeight.constant = 80
                mRemoveReserveButton.isHidden = false
            }
            
            if let poId = mData.value(forKey: "po_product_id") as? String,
               mSelectedItems.contains(poId) {
                cell.mCheckIcon.image = UIImage(named: "check_item")
            }else{
                cell.mCheckIcon.image = UIImage(named: "uncheck_item")
                
                
            }
            
            if mIndex == indexPath.row {
                self.mProductImage.downlaodImageFromUrl(urlString: "\(mData.value(forKey: "main_image") ?? "")")
                self.mStockId.text = "\(mData.value(forKey: "stock_id") ?? "--")"
                self.mMetaTag.text = "\(mData.value(forKey: "Matatag") ?? "--")"
                self.mLocationName.text = "\(mData.value(forKey: "location_name") ?? "--")"
                self.mMetalName.text = "\(mData.value(forKey: "metal_name") ?? "--")"
                self.mStoneName.text = "\(mData.value(forKey: "stone_name") ?? "--")"
                self.mSKUName.text = "\(mData.value(forKey: "SKU") ?? "__")"
//                self.mSize.text = "\(mData.value(forKey: "size_name") ?? "--")"
//                self.mSize.text = "\(mData.value(forKey: "size_name") ?? mData.value(forKey: "size") ?? "--")"
//                self.mCollectionName.text = "\(mData.value(forKey: "collection_name")  ?? "--")"
                let sizeName = "\(mData.value(forKey: "Size_name") ?? mData.value(forKey: "size_name") ?? "--")"
                self.mSize.text = !sizeName.isEmpty ? sizeName : "--"
                self.mCollectionName.text = "\(mData.value(forKey: "Collection_name") ?? mData.value(forKey: "collection_name") ?? "--")"
            }
        }
        cell.layoutSubviews()
        return cell
        
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print("tableView didSelectRowAt")
        if let mData = mData[indexPath.row] as? NSDictionary {
            
            self.mSKUForImage = "\(mData.value(forKey: "SKU") ?? "--")"
            
            if let mPId = mData.value(forKey: "product_id") as? String {
                self.mProductIdForImage = mPId
            }
            
            mIndex = indexPath.row
            
            if let id = mData.value(forKey: "po_product_id") as? String {
                if mSelectedItems.contains(id) {
                    mSelectedItems = mSelectedItems.filter {$0 != id}
                } else {
                    mSelectedItems.append(id)
                }
            }
        }
        self.mReserveTable.reloadData()
    }
    
    
}
