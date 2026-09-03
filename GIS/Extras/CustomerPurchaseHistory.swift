//
//  CustomerPurchaseHistory.swift
//  GIS
//
//  Created by Apple Hawkscode on 09/02/22.
//


import UIKit
import Alamofire
import DropDown

class CustomerPurchaseHistory: UIViewController , UITableViewDelegate,UITableViewDataSource {
    
    
    @IBOutlet weak var TransactionTable: UITableView!
    
    
    
    @IBOutlet weak var mTransactionView: UIStackView!
    
    @IBOutlet weak var mCurrentDate: UITextField!
    
    var mSalespersonTransactionData = NSArray()
    
    var mCustomerId = ""
    
    var delegate:SalesPersonTransactionDelegate? = nil
    var mIndex = -1
    
    
    @IBOutlet weak var mHeadingLABEL: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
        
        TransactionTable.showsVerticalScrollIndicator = false
        TransactionTable.showsHorizontalScrollIndicator = false
        mHeadingLABEL.text =  "Purchase History".localizedString
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
    
    
    func mGetTransactions() {
        
        
        mGetData(url: mGetCustomerPurchaseList,headers: sGisHeaders,  params: ["customer_id":mCustomerId]) { response , status in
            if status {
                
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        
        return mSalespersonTransactionData.count
        
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        
        let cells = UITableViewCell()
        if tableView == TransactionTable {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "CommonTransleCell") as? CommonTransleCell,
               let mData = mSalespersonTransactionData[indexPath.row] as? NSDictionary{
                cell.mOrderNo.text = "\(mData.value(forKey: "order_no") ?? "--")"
                cell.mLocation.text = "\(mData.value(forKey: "location") ?? "--"),"
                cell.mDate.text = "\(mData.value(forKey: "date") ?? "--")"
                cell.mType = "purchase"
                if let mCart = mData.value(forKey: "cart") as? NSArray {
                    if mCart.count > 0 {
                        cell.mCartData = mCart
                        cell.mParkItemsTable.delegate = cell
                        cell.mParkItemsTable.dataSource = cell
                        cell.mParkItemsTable.reloadData()
                        cell.mParkItemsTable.layoutIfNeeded()
                        cell.mParkItemsTable.isHidden = false
                        cell.mTableHeight.constant = cell.mParkItemsTable.contentSize.height + 80
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
        
        
        return 100
    }
    
    
}
