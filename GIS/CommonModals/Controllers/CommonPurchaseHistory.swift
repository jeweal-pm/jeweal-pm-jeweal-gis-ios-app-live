//
//  CommonPurchaseHistory.swift
//  GIS
//
//  Created by MacBook Hawkscode  on 23/03/23.
//  Copyright © 2023 Hawkscode. All rights reserved.
//

import UIKit
import Alamofire
class CommonPurchaseHistoryCell : UITableViewCell {
    
    
    
    @IBOutlet weak var mProductImage: UIImageView!
    @IBOutlet weak var mLocationName: UILabel!
    @IBOutlet weak var mPosInvoice: UILabel!
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
    
}

class CommonPurchaseHistory: UIViewController, UITableViewDelegate, UITableViewDataSource {
     
    @IBOutlet weak var mSearchField: UITextField!
    var delegate:GetInventoryDataItemsDelegate? = nil

    @IBOutlet weak var mNoDataFound: UILabel!
    @IBOutlet weak var mReserveTable: UITableView!
    @IBOutlet weak var mReserveBottomView: UIView!
    
    @IBOutlet weak var mRemoveReserveButton: UIButton!
    @IBOutlet weak var mBottomViewHeight: NSLayoutConstraint!
    var mData = NSMutableArray()
    var mDefaultData = NSArray()
    var mIndex = -1
    var mSelectedItems = [String]()
    
    var mCustomerId = ""
    var mOrderType = ""
    var mType = ""
    
    var mOrderId = ""
    var mCartId = ""
    var mDiscount = ""
    var mDiscountPercent = ""
    
    @IBOutlet weak var mHeadingLABEL: UILabel!
    override func viewWillAppear(_ animated: Bool) {
        
        
        mRemoveReserveButton.setTitle("SUBMIT".localizedString, for: .normal)
        mNoDataFound.text = "No Data Found!".localizedString
        mHeadingLABEL.text = "History".localizedString
        mSearchField.placeholder = "Search by Invoice / Stock Id".localizedString
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
        
        CommonClass.showFullLoader(view: self.view)
        
        
        mGetData(url: mGetSalesOrderHistory ,headers: sGisHeaders,  params: ["customer_id":mCustomerId]) { response , status in
            CommonClass.stopLoader()
            if status {
                self.mData =  NSMutableArray()
                self.mDefaultData = NSArray()
                if "\(response.value(forKey: "code") ?? "")" == "200" {
                    
                    if let mDataItems = response.value(forKey: "data") as? NSArray {
                        
                        if mDataItems.count == 0 {
                            return
                        }
                        self.mData =  NSMutableArray(array: mDataItems)
                        self.mDefaultData = mDataItems
                        
                        self.mReserveTable.delegate = self
                        self.mReserveTable.dataSource = self
                        self.mReserveTable.reloadData()
                    }
                }else{

                }
            }
        }
        
        mBottomViewHeight.constant = 0
        mRemoveReserveButton.isHidden = true
        
    }

    @IBAction func mBack(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    
    @IBAction func mSearchFilters(_ sender: UITextField) {
        
        if sender.text == "" {
            
            mIndex = -1
            self.mData = NSMutableArray(array: mDefaultData)
            mReserveTable.reloadData()
            
        }else {
            mIndex = -1
            mData = NSMutableArray()
            for i in mDefaultData {
                if let mData = i as? NSDictionary {
                    let mValue = "\(mData.value(forKey: "ref_no") ?? "")"
                    let mStockId = "\(mData.value(forKey: "stock_id") ?? "")"
                    if let text = sender.text {
                        if mValue.lowercased().contains(text.lowercased()) || mStockId.contains(text)  {
                            self.mData.add(mData)
                        }
                    }
                    mReserveTable.reloadData()
                }
            }
        }
    }
    @IBAction func mAddToCart(_ sender: Any) {
        self.dismiss(animated: true)
        if mOrderType == "repair_order" {
            
            let mData = NSMutableArray()
            for i in [self.mDefaultData[mIndex]] {
                let mItems = NSMutableDictionary()
                if let items = i as? NSDictionary {
                    mItems.setValue(1, forKey: "Qty")
                    mItems.setValue("\(items.value(forKey: "SKU") ?? "")", forKey: "SKU")
                    mItems.setValue("\(items.value(forKey: "amount") ?? "")", forKey: "amount")
                    mItems.setValue("\(items.value(forKey: "cart_id") ?? "")", forKey: "cart_id")
                    mItems.setValue("\(items.value(forKey: "date") ?? "")", forKey: "date")
                    mItems.setValue("\(items.value(forKey: "image") ?? "")", forKey: "image")
                    mItems.setValue("\(items.value(forKey: "location") ?? "")", forKey: "location")
                    mItems.setValue("\(items.value(forKey: "order_id") ?? "")", forKey: "order_id")
                    mItems.setValue("\(items.value(forKey: "ref_no") ?? "")", forKey: "ref_no")
                    mItems.setValue("\(items.value(forKey: "stock_id") ?? "")", forKey: "stock_id")
                    mData.add(mItems)
                }
            }
            
            let mParams = ["cart_ids":mData, "customer_id":mCustomerId, "order_type":mOrderType] as [String : Any]
            
            mGetData(url: mAddRepairProduct ,headers: sGisHeaders,  params:mParams) { response , status in
                
                CommonClass.stopLoader()
                if status {
                    self.mData =  NSMutableArray()
                    self.mDefaultData = NSArray()
                    if "\(response.value(forKey: "code") ?? "")" == "200" {
                        self.dismiss(animated: true)
                        self.delegate?.mGetInventoryItems(items: [""])
                        
                    }else{
                        
                    }
                }
            }
            
        }else{
            var items = [mOrderId,mCartId]
            if mOrderType == "refund_order" {
                items.append(mDiscount)
                items.append(mDiscountPercent)
            }
            self.delegate?.mGetInventoryItems(items: items)
            
        }
    }
    
    @IBAction func mOpenImageView(_ sender: Any) {
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        if mData.count == 0 {
            mNoDataFound.isHidden = false
            mReserveTable.isHidden = true
            
            
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommonPurchaseHistoryCell") as? CommonPurchaseHistoryCell else {
            return UITableViewCell()
        }
        
        if let mData = mData[indexPath.row] as? NSDictionary {
//            cell.mDueDate.text = "\(mData.value(forKey: "date") ?? "--")"
            let dateString = "\(mData.value(forKey: "date") ?? "--")"

            let inputFormatter = DateFormatter()
            inputFormatter.calendar = Calendar(identifier: .gregorian)
            inputFormatter.locale = Locale(identifier: "en_US_POSIX")
            inputFormatter.dateFormat = "dd-MM-yyyy"

            let outputFormatter = DateFormatter()
            outputFormatter.calendar = Calendar(identifier: .gregorian)
            outputFormatter.locale = Locale(identifier: "en_US_POSIX")
            outputFormatter.dateFormat = "dd/MM/yyyy"

            if let date = inputFormatter.date(from: dateString) {
                cell.mDueDate.text = outputFormatter.string(from: date)
            } else {
                cell.mDueDate.text = dateString
            }
            
            cell.mProductImage.downlaodImageFromUrl(urlString: "\(mData.value(forKey: "image") ?? "--")")
            cell.mPosInvoice.text = "\(mData.value(forKey: "customer_name") ?? "--")"
            cell.mStockName.text = "\(mData.value(forKey: "SKU") ?? "--")"
            cell.mStockId.text = "\(mData.value(forKey: "stock_id") ?? "--")"
            
//            cell.mDueDate.text = "\(mData.value(forKey: "date") ?? "")"
            
            cell.mPosInvoice.text = "\(mData.value(forKey: "ref_no") ?? "")"
            cell.mLocationName.text = "\(mData.value(forKey: "location") ?? "")"
            cell.mQuantity.text = "\(mData.value(forKey: "Qty") ?? "")"
            
            let amount = Double("\(mData.value(forKey: "amount") ?? 0)") ?? 0

            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.minimumFractionDigits = 2
            formatter.maximumFractionDigits = 2

            let mCurrencySymbol = "\(UserDefaults.standard.string(forKey: "currencySymbol") ?? "$")"
            if UIDevice.current.userInterfaceIdiom == .pad {
//                cell.mAmount.text = "\(mData.value(forKey: "amount") ?? "0.0")"
                cell.mAmount.text = "\(mCurrencySymbol)\(formatter.string(from: NSNumber(value: amount)) ?? "0.00")"
            }else{
//                cell.mAmount.text = "\(mData.value(forKey: "amount") ?? "0.0")"
                cell.mAmount.text = "\(mCurrencySymbol)\(formatter.string(from: NSNumber(value: amount)) ?? "0.00")"
            }
            
            let backgroundColor = (indexPath.row % 2 == 0) ? UIColor(named: "themeBackground") : #colorLiteral(red: 0.9568627451, green: 0.9568627451, blue: 0.9568627451, alpha: 1)

            cell.mView.backgroundColor = backgroundColor
            cell.backgroundColor = backgroundColor
            
            
            if mOrderType == "repair_order"{
                
                if mSelectedItems.isEmpty {
                    mBottomViewHeight.constant = 0
                    mRemoveReserveButton.isHidden = true
                }else{
                    mBottomViewHeight.constant = 80
                    mRemoveReserveButton.isHidden = false
                }
                
                
                if let cartId = mData.value(forKey: "cart_id") as? String,mSelectedItems.contains(cartId) {
                    cell.mCheckIcon.image = UIImage(named: "check_item")
                    
                }else{
                    cell.mCheckIcon.image = UIImage(named: "uncheck_item")
                    
                    
                }
            }else{
                if mIndex == indexPath.row {
                    cell.mCheckIcon.image = UIImage(named: "check_item")
                    mBottomViewHeight.constant = 80
                    mRemoveReserveButton.isHidden = false
                }else{
                    cell.mCheckIcon.image = UIImage(named: "uncheck_item")
                    
                }
            }
        }
        cell.layoutSubviews()
        
        return cell
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if let mData = mData[indexPath.row] as? NSDictionary {
            
            if mOrderType == "repair_order"{
                
                mIndex = indexPath.row
                if let cartId = mData.value(forKey: "cart_id") as? String {
                    if mSelectedItems.contains(cartId) {
                        mSelectedItems = mSelectedItems.filter {$0 != cartId }
                        
                    }else{
                        mSelectedItems.append(cartId)
                        
                    }
                }
                
            }else{
                mIndex = indexPath.row
                if let mOrderId =  mData.value(forKey: "order_id") {
                    self.mOrderId = "\(mOrderId)"
                }
                if let mCartId =  mData.value(forKey: "cart_id") {
                    self.mCartId = "\(mCartId)"
                }
                if let discount =  mData.value(forKey: "discount") {
                    self.mDiscount = "\(discount)"
                }
                if let discountPercent =  mData.value(forKey: "discount_percent") {
                    self.mDiscountPercent = "\(discountPercent)"
                }
            }
        }
        
        
        self.mReserveTable.reloadData()
        
        
    }
    
    
}
