//
//  CustomerPaymentHistory.swift
//  GIS
//
//  Created by Macbook Pro on 05/05/23.
//  Copyright © 2023 Hawkscode. All rights reserved.
//

import UIKit
import Alamofire

class CommonNestedCell : UITableViewCell{
    @IBOutlet weak var mSNo: UILabel!
    @IBOutlet weak var mProductImage: UIImageView!
    @IBOutlet weak var mProductName: UILabel!
    @IBOutlet weak var mStockId: UILabel!
    @IBOutlet weak var mPrice: UILabel!
    @IBOutlet weak var mMetalSizeColor: UILabel!
    @IBOutlet weak var mSKUName: UILabel!
    @IBOutlet weak var mDate: UILabel!
    @IBOutlet weak var mOrderNo: UILabel!
    @IBOutlet weak var mLocation: UILabel!
    @IBOutlet weak var mQty: UILabel!
    
    
}
class CommonTransleCell : UITableViewCell , UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var mTableHeight: NSLayoutConstraint!
    @IBOutlet weak var mParkItemsTable: UITableView!
    
    @IBOutlet weak var mLocation: UILabel!
    @IBOutlet weak var mOrderNo: UILabel!
    @IBOutlet weak var mView: UIView!
    @IBOutlet weak var mDate: UILabel!
    var mType = ""
    
    var mCartData = NSArray()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return mCartData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CommonNestedCell") as? CommonNestedCell,
           let mData = mCartData[indexPath.row] as? NSDictionary{
            if mType == "purchase" {
                cell.mSNo.text = "\(indexPath.row + 1)"
                cell.mProductName.text = "\(mData.value(forKey: "name") ?? "")"
                cell.mQty.text = "\(mData.value(forKey: "qty") ?? "")"
                cell.mPrice.text = "\(mData.value(forKey: "price") ?? "")"
                cell.mStockId.text = "\(mData.value(forKey: "stock_id") ?? "")"
                cell.mSKUName.text = "\(mData.value(forKey: "SKU") ?? "")"
                cell.mMetalSizeColor.text = "\(mData.value(forKey: "metal") ?? "")" + "\(mData.value(forKey: "size") ?? "")"
                cell.mProductImage.downlaodImageFromUrl(urlString: "\(mData.value(forKey: "main_image") ?? "")")
            }else{
                cell.mDate.text = "\(mData.value(forKey: "date") ?? "")"
                cell.mOrderNo.text = "\(mData.value(forKey: "order_no") ?? "")"
                cell.mQty.text = "\(mData.value(forKey: "total_Qty") ?? "")"
                cell.mPrice.text = "\(mData.value(forKey: "total_amount") ?? "")"
                cell.mLocation.text = "\(mData.value(forKey: "location") ?? "")"
            }
            
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    
}



class CustomerPaymentHistory: UIViewController, UITableViewDelegate,UITableViewDataSource {
    
    
    @IBOutlet weak var TransactionTable: UITableView!
    
    @IBOutlet weak var mTransactionView: UIStackView!
    
    @IBOutlet weak var mTotalQuantity: UILabel!
    @IBOutlet weak var mMostLocation: UILabel!
    @IBOutlet weak var mTotalAmount: UILabel!
    var mCustomerId = ""
    
    var mUrl = ""
    var mSalespersonTransactionData = NSArray()
    var delegate:SalesPersonTransactionDelegate? = nil
    var mIndex = -1
    
    
    @IBOutlet weak var mPaymentHistoryLABEL: UILabel!
    @IBOutlet weak var mMostLocationLABEL: UILabel!
    @IBOutlet weak var mTotalQuantityLABEL: UILabel!
    @IBOutlet weak var mTotalAmountLABEL: UILabel!
    @IBOutlet weak var mHeading: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
        
        TransactionTable.showsVerticalScrollIndicator = false
        TransactionTable.showsHorizontalScrollIndicator = false
        mMostLocationLABEL.text =  "Most Location".localizedString
        mTotalQuantityLABEL.text =  "Total Quantity".localizedString
        mTotalAmountLABEL.text =  "Total Amount".localizedString
        
        
        let currentDateTime = Date()
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .medium
        
        let formatter2 = DateFormatter()
        formatter2.timeStyle = .short
        formatter2.dateStyle = .none
        
        let mMonthm = DateFormatter()
        mMonthm.dateFormat = "MMM"
        
        let mMonthInt = DateFormatter()
        mMonthInt.dateFormat = "MM"
        
        let mYeard = DateFormatter()
        mYeard.dateFormat = "yyyy"
        
        let mYearInt = DateFormatter()
        mYearInt.dateFormat = "yyyy"
        
        mGetTransactions()
        
    }
    
    @IBAction func mPrint(_ sender: Any) {
        
        if mUrl != "" {
            if let url = URL(string: mUrl) {
                UIApplication.shared.open(url)
            }
        }else{
            CommonClass.showSnackBar(message: "No print available!")
        }
    }
    
    func mGetTransactions() {
        
        mGetData(url: mGetCustomerPaymentHistory,headers: sGisHeaders,  params: ["customer_id":mCustomerId]) { response , status in
            if status {
                
                
                if let mCountData = response.value(forKey: "count") as? NSDictionary {
                    self.mMostLocation.text = "\(mCountData.value(forKey:"locationName") ?? "0" )"
                    self.mTotalAmount.text = "\(mCountData.value(forKey:"total_Amount") ?? "0" )"
                    self.mTotalQuantity.text = "\(mCountData.value(forKey:"total_Qty") ?? "0" )"
                    self.mUrl =  "\(mCountData.value(forKey:"print_url") ?? "" )"
                }
                
                if let mArr = response.value(forKey: "data") as? NSArray {
                    
                    if mArr.count > 0 {
                        self.mSalespersonTransactionData = mArr
                        self.TransactionTable.delegate = self
                        self.TransactionTable.dataSource = self
                        self.TransactionTable.reloadData()
                    }
                }
            }
        }
    }
    
    
    
    
    
    @IBAction func mBack(_ sender: Any) {
        self.dismiss(animated: true)
        
    }
    
    
    
    
    
    @IBAction func mChooseDate(_ sender: Any) {
        
    }
    
    @objc func mCancelDatePick(){
        self.view.endEditing(true)
    }
    @IBAction func mMostAmount(_ sender: Any) {
        
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return mSalespersonTransactionData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        
        let cells = UITableViewCell()
        if tableView == TransactionTable {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "CommonTransleCell") as? CommonTransleCell,
                let mData = mSalespersonTransactionData[indexPath.row] as? NSDictionary {
                
                cell.mDate.text = "\(mData.value(forKey: "year") ?? "--")"
                
                if let mCart = mData.value(forKey: "paymentList") as? NSArray {
                    if mCart.count > 0 {
                        cell.mCartData = mCart
                        cell.mParkItemsTable.delegate = cell
                        cell.mParkItemsTable.dataSource = cell
                        cell.mParkItemsTable.reloadData()
                        cell.mParkItemsTable.layoutIfNeeded()
                        cell.mParkItemsTable.isHidden = false
                        cell.mTableHeight.constant = cell.mParkItemsTable.contentSize.height + 40
                    }else{
                        cell.mParkItemsTable.isHidden = true
                        cell.mTableHeight.constant = 0
                        
                    }
                    
                }else{
                    cell.mParkItemsTable.isHidden = true
                    cell.mTableHeight.constant = 0
                }
                
                
                return cell
            }
        }
        
        
        return cells
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 90
    }
    
}
