//
//  ReceivedLayByInstallments.swift
//  GIS
//
//  Created by Macbook Pro on 17/07/23.
//  Copyright © 2023 Hawkscode. All rights reserved.

import UIKit
import Alamofire
class ReceivedItems : UITableViewCell {
    
    @IBOutlet weak var mDate: UILabel!
    
    @IBOutlet weak var mOrderId: UILabel!
    
    @IBOutlet weak var mCustomerName: UILabel!
    
    
    @IBOutlet weak var mCustomerMobile: UILabel!
    
    @IBOutlet weak var mCusttomerImage: UIImageView!
    
    
    @IBOutlet weak var mTypeLAbel: UILabel!
    
    @IBOutlet weak var mType: UILabel!
    
    @IBOutlet weak var mAmountLabel: UILabel!
    
    
    @IBOutlet weak var mReceivedAmount: UILabel!
    
    
    @IBOutlet weak var mTotalAmount: UILabel!
    
    
    @IBOutlet weak var mPaymentsLabel: UILabel!
    
    
    @IBOutlet weak var mTotalReceived: UILabel!
    
    @IBOutlet weak var mNextDue: UILabel!
    
    @IBOutlet weak var mBAlanceLabel: UILabel!
    
    @IBOutlet weak var mTotalBalance: UILabel!
    
    @IBOutlet weak var mPurchasedItemsLABEL: UILabel!
    
    @IBOutlet weak var mViewItems: UIButton!
    
    
}

class ReceivedLayByInstallments: UIViewController, UITableViewDelegate, UITableViewDataSource, UIViewControllerTransitioningDelegate, FinalInstallmentDelegate, GetCustomerDataDelegate, ConfirmLaybyDelegate, ScannerDelegate {
    func mCancelInstallment() {
         
    }
    

    
    
    
    
    @IBOutlet weak var mAllItems: UILabel!
    
    @IBOutlet weak var mAllLine: UILabel!
    
    @IBOutlet weak var mLaybytems: UILabel!
    
    @IBOutlet weak var mLaybyLine: UILabel!
    
    
    @IBOutlet weak var mInstallmentItems: UILabel!
    
    @IBOutlet weak var mInstallmentLine: UILabel!
    
    
    
    
    
    
    
    @IBOutlet weak var mReceiveLabel: UILabel!
    
    @IBOutlet weak var mSearchField: UITextField!
    @IBOutlet weak var mSelectedCustomerIcon: UIImageView!
   
    
    
    
    
    var mCustomerId = ""
    
    var mReceivedData = NSArray()
    var mIndexValue = -1
    
    @IBOutlet weak var mTableView: UITableView!
    
    var mMasterData = NSArray()
    var mDataItems = NSArray()
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mReceiveLabel.text = "Receive".localizedString
        mSearchField.placeholder = "Search by Invoice no / Customer".localizedString
        
        
        mGetAllItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
    

        mCustomerId  = UserDefaults.standard.string( forKey: "DEFAULTCUSTOMER") ?? ""
         if mCustomerId == "" {
        mOpenCustomerSheet()
         }else{
    
              self.mSelectedCustomerIcon.image = UIImage(named: "selected_customer")
          }
    }
    
    func mCreateNewCustomer() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "reserveBoard", bundle: nil)
        if let mCreateCustomer = storyBoard.instantiateViewController(withIdentifier: "CreateCustomer") as? CreateCustomer {
            self.navigationController?.pushViewController(mCreateCustomer, animated:true)
        }
    }
    func mGetCustomerData(data: NSMutableDictionary) {
 
         UserDefaults.standard.set(data.value(forKey: "id") ?? "", forKey: "DEFAULTCUSTOMER")
        UserDefaults.standard.set(data.value(forKey: "profile") ?? "", forKey: "DEFAULTCUSTOMERPICTURE")
        UserDefaults.standard.set(data.value(forKey: "name") ?? "", forKey: "DEFAULTCUSTOMERNAME")

        self.mCustomerId = data.value(forKey: "id") as? String ?? ""
        self.mSelectedCustomerIcon.image = UIImage(named: "selected_customer")
 
    }
    func mOpenCustomerSheet(){
        let storyBoard: UIStoryboard = UIStoryboard(name: "common", bundle: nil)
        if let home = storyBoard.instantiateViewController(withIdentifier: "CustomerPicker") as? CustomerPicker {
            home.delegate = self
            home.modalPresentationStyle = .automatic
            home.transitioningDelegate = self
            self.present(home,animated: true)
        }
    }
    func mGetAllItems() {
        CommonClass.showFullLoader(view: self.view)
        
        mGetData(url: mGetAllReceivedItems,headers: sGisHeaders,  params: ["type":"ALL"]) { response , status in
            CommonClass.stopLoader()
            if status {
                if let mData = response.value(forKey: "data") as? NSArray {
                    if mData.count > 0 {
                        
                        self.mMasterData = mData
                        self.mReceivedData = mData

                        self.mTableView.showsVerticalScrollIndicator = false
                        self.mTableView.delegate = self
                        self.mTableView.dataSource = self
                        self.mTableView.reloadData()
                        
                        var mLayby = NSMutableArray()
                        var mInstallments = NSMutableArray()
                        for i in self.mMasterData {
                            if let mData = i as? NSDictionary {
                                if mData.value(forKey: "order_type") as? String ?? "" == "lay_by" {
                                    mLayby.add(mData)
                                }else{
                                    mInstallments.add(mData)
                                }
                            }
                        }
                        
                        self.mAllItems.text = "All".localizedString + " (\(self.mMasterData.count))"
                        self.mLaybytems.text = "Layby".localizedString + " (\(mLayby.count))"
                        self.mInstallmentItems.text = "Installments".localizedString + " (\(mInstallments.count))"

                    }
                    
                }
                
                
            }
        }
                 }
    
    
    func mResetItems() {
        mAllItems.textColor = UIColor(named:"themeLightText")
        mAllLine.backgroundColor = UIColor(named:"themeColor")
        
        mLaybytems.textColor = UIColor(named:"themeExtraLightText")
        mLaybyLine.backgroundColor = UIColor(named:"themeExtraLightText")
        
        mInstallmentItems.textColor = UIColor(named:"themeExtraLightText")
        mInstallmentLine.backgroundColor = UIColor(named:"themeExtraLightText")
    }
    
    @IBAction func mEditSearch(_ sender: UITextField) {
        if sender.text == "" {
            self.mReceivedData = mMasterData
            self.mTableView.reloadData()
         }else {
            var mSearchData = NSMutableArray()
            for i in mMasterData {
                if let mData = i as? NSDictionary {
                    let vrno = mData.value(forKey: "vr_no") ?? ""
                    let text = sender.text ?? ""
                    let customerName = mData.value(forKey: "customer_name") ?? ""
                    if "\(vrno)".lowercased().contains(text.lowercased()) || "\(customerName)".lowercased().contains(text) {
                        mSearchData.add(mData)
                    }
                }
            }
            if mSearchData.count > 0 {
                self.mReceivedData = NSArray(array: mSearchData)
                self.mTableView.reloadData()
            }else{
                self.mReceivedData = mMasterData
                self.mTableView.reloadData()
            }
        }
        self.mResetItems()

    
    
    }
    
    @IBAction func mScanNow(_ sender: Any) {
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "transactions", bundle: nil)
        if let mCommonScanner = storyBoard.instantiateViewController(withIdentifier: "CommonScanner") as? CommonScanner {
            mCommonScanner.delegate =  self
            mCommonScanner.mType = "search"
            mCommonScanner.modalPresentationStyle = .overFullScreen
            mCommonScanner.transitioningDelegate = self
            self.present(mCommonScanner,animated: true)
        }
    }
    
        func mGetScannedData(value: String, type: String) {
            if value == "" {
                self.mReceivedData = mMasterData
                self.mTableView.reloadData()
             }else {
                var mSearchData = NSMutableArray()
                 for i in mMasterData {
                     if let mData = i as? NSDictionary {
                         let vrNo = (mData.value(forKey: "vr_no") as? String ?? "").lowercased()
                         let customerName = (mData.value(forKey: "customer_name") as? String ?? "").lowercased()
                         let searchValue = value.lowercased()

                         if vrNo.contains(searchValue) || customerName.contains(searchValue) {
                             mSearchData.add(mData)
                         }
                     }
                 }
                if mSearchData.count > 0 {
                    self.mReceivedData = NSArray(array: mSearchData)
                    self.mTableView.reloadData()
                }else{
                    self.mReceivedData = mMasterData
                    self.mTableView.reloadData()
                }
            }
            self.mResetItems()

        }
        
        
        
    
        
    @IBAction func mBack(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func mChooseCustomer(_ sender: Any) {
        mOpenCustomerSheet()
    }
    
    
    @IBAction func mSelectAll(_ sender: Any) {
        
        mAllItems.textColor = UIColor(named:"themeLightText")
        mAllLine.backgroundColor = UIColor(named:"themeColor")
        
        mLaybytems.textColor = UIColor(named:"themeExtraLightText")
        mLaybyLine.backgroundColor = UIColor(named:"themeExtraLightText")
        
        mInstallmentItems.textColor = UIColor(named:"themeExtraLightText")
        mInstallmentLine.backgroundColor = UIColor(named:"themeExtraLightText")
        self.mReceivedData = self.mMasterData
        self.mTableView.reloadData()
        
    }
    
    @IBAction func mSelectLayby(_ sender: Any) {
    
        mAllItems.textColor = UIColor(named:"themeExtraLightText")
        mAllLine.backgroundColor = UIColor(named:"themeExtraLightText")
        
        mLaybytems.textColor = UIColor(named:"themeLightText")
        mLaybyLine.backgroundColor = UIColor(named:"themeColor")
        
        mInstallmentItems.textColor = UIColor(named:"themeExtraLightText")
        mInstallmentLine.backgroundColor = UIColor(named:"themeExtraLightText")
        
        mFilter(type:"lay_by")

        
    }
    
    @IBAction func mSelectInstallments(_ sender: Any) {
        mAllItems.textColor = UIColor(named:"themeExtraLightText")
        mAllLine.backgroundColor = UIColor(named:"themeExtraLightText")
        mLaybytems.textColor = UIColor(named:"themeExtraLightText")
        mLaybyLine.backgroundColor = UIColor(named:"themeExtraLightText")
        mInstallmentItems.textColor = UIColor(named:"themeLightText")
        mInstallmentLine.backgroundColor = UIColor(named:"themeColor")
        mFilter(type:"Installment")
    }
    
    func mFilter(type:String) {
        var mItems = NSMutableArray()
        for i in mMasterData {
            if let mData = i as? NSDictionary {
                if mData.value(forKey: "order_type") as? String ?? "" == type {
                    mItems.add(mData)
                }
            }
        }
        self.mReceivedData = NSArray(array: mItems)
        self.mTableView.reloadData()
    }
    
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
 
         if mReceivedData.count == 0 {
             tableView.setError("No items found!".localizedString)
         }else{
             tableView.clearBackground()
         }
        return mReceivedData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ReceivedItems") as? ReceivedItems else {
            return UITableViewCell()
        }
        
        if let mData = mReceivedData[indexPath.row] as? NSDictionary {
            
            cell.mPaymentsLabel.text = "Payments".localizedString
            cell.mBAlanceLabel.text = "Balance".localizedString
            cell.mAmountLabel.text = "Amount".localizedString
            cell.mPurchasedItemsLABEL.text = "Purchased Items".localizedString
            
            cell.mTypeLAbel.text = "Type".localizedString
            cell.mDate.text = mData.value(forKey: "date") as? String ?? "--"
            cell.mOrderId.text = mData.value(forKey: "vr_no") as? String ?? "--"
            if mData.value(forKey: "order_type") as? String ?? "" == "lay_by" {
                cell.mType.text = "LayBy"
                cell.mTotalReceived.text = "\(mData.value(forKey: "total_receive") ?? 0 )"
                cell.mNextDue.text = "(Due \(mData.value(forKey: "due_date") ?? "--"))"
            }else{
                cell.mType.text = "Installment"
                if let mInstallmentData = mData.value(forKey: "installment") as? NSArray {
                    if mInstallmentData.count > 0 {}
                    cell.mTotalReceived.text = "\(mData.value(forKey: "installment_paid") ?? 0)/\(mInstallmentData.count)"
                    cell.mNextDue.text = "(Next Due \(mData.value(forKey: "due_date") ?? "--"))"
                }
            }
            
            cell.mReceivedAmount.text = "\(UserDefaults.standard.string(forKey: "currencySymbol") ?? "$")" +  " \(mData.value(forKey: "payment") ?? "0.00")"
            cell.mTotalAmount.text = "\(mData.value(forKey: "amount") ?? "0.00")"
            
            cell.mCustomerName.text = mData.value(forKey: "customer_name") as? String ?? "--"
            cell.mCusttomerImage.downlaodImageFromUrl(urlString: mData.value(forKey: "profile_picture") as? String ?? "--")
            cell.mCustomerMobile.text = mData.value(forKey: "customer_contact") as? String ?? "--"
            cell.mTotalBalance.text = "\(UserDefaults.standard.string(forKey: "currencySymbol") ?? "$")"  + " \(mData.value(forKey: "outstanding") ?? "0.00")"
            cell.mViewItems.tag = indexPath.row
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let mData = mReceivedData[indexPath.row] as? NSDictionary {
            
            self.mIndexValue = indexPath.row
            
            if let mInstallmentData = mData.value(forKey: "installment") as? NSArray {
                
                if mInstallmentData.count > 0 {}
                let storyBoard: UIStoryboard = UIStoryboard(name: "laybyInstallment", bundle: nil)
                if let mPayInstallments = storyBoard.instantiateViewController(withIdentifier: "PayInstallments") as? PayInstallments {
                    mPayInstallments.transitioningDelegate = self
                    mPayInstallments.mInstallmentData = NSMutableArray(array:mInstallmentData)
                    mPayInstallments.delegate = self
                    mPayInstallments.mMasterInstallmentData = mInstallmentData
                    mPayInstallments.mData = mData
                    
                    mPayInstallments.mOutstanding = Double("\(mData.value(forKey:"outstanding") ?? "0.00")") ?? 0.00
                    mPayInstallments.modalPresentationStyle = .automatic
                    self.present(mPayInstallments,animated: true)
                }
            }else{
                
                if let mLayByData = mData.value(forKey: "pay_layby_data") as? NSArray {
                    let storyBoard: UIStoryboard = UIStoryboard(name: "laybyInstallment", bundle: nil)
                    if let mPayLayBy = storyBoard.instantiateViewController(withIdentifier: "PayLayBy") as? PayLayBy {
                        mPayLayBy.transitioningDelegate = self
                        mPayLayBy.mData = mData
                        mPayLayBy.mLaybyData = mLayByData
                        mPayLayBy.mCustomerId = self.mCustomerId
                        mPayLayBy.delegate = self
                        mPayLayBy.modalPresentationStyle = .automatic
                        self.present(mPayLayBy,animated: true)
                    }
                }
            }
        }
    }
    
    func mConfirmLayByPayment(date: String, receiveAmount: String, outstanding: String, noOfReceived: String) {
        
        if let mData = mReceivedData[self.mIndexValue] as? NSDictionary {
            let storyBoard: UIStoryboard = UIStoryboard(name: "laybyInstallment", bundle: nil)
            if let mCheckOut = storyBoard.instantiateViewController(withIdentifier: "LaybyInstallmentCheckout") as? LaybyInstallmentCheckout {
                mCheckOut.mTotalP = "\(mData.value(forKey: "amount") ?? "0.00")"
                mCheckOut.mTotalReceived = "\(receiveAmount)"
                mCheckOut.mTaxP = ""
                mCheckOut.mTotalReceivedLayby = receiveAmount
                mCheckOut.mTotalOutStandingLayby = outstanding
                mCheckOut.mNoOfReceivedLayby = noOfReceived
                mCheckOut.mDueDateLayby = date
                if let mLayByData = mData.value(forKey: "pay_layby_data") as? NSArray {
                    mCheckOut.mPayLayByData = mLayByData
                }
                mCheckOut.mTaxAm = ""
                mCheckOut.mOrderType = "LayBy"
                mCheckOut.mInstallmentId = "\(mData.value(forKey: "order_id") ?? "")"
                mCheckOut.mLaybyId = "\(mData.value(forKey: "order_id") ?? "")"
                
                mCheckOut.mCurrencySymbol = "\(UserDefaults.standard.string(forKey: "currencySymbol") ?? "$")"
                mCheckOut.mCartTotalAmount = ""
                mCheckOut.mDepositPercents = ""
                mCheckOut.mTotalItems = Int("\(mData.value(forKey: "SKU") ?? "1")") ?? 1
                mCheckOut.mTotalWithDiscount =  ""
                mCheckOut.mLabourPoints = Double("0.0") ?? 0.0
                mCheckOut.mShippingPoints = Double("0.0") ?? 0.0
                mCheckOut.mLoyaltyPoints = Double("0.0") ?? 0.0
                mCheckOut.mTaxAmount = Double("0.0") ?? 0.0
                mCheckOut.mTaxAmountInt = Double("0.0") ?? 0.0
                mCheckOut.mTaxInPercent = Double("0.0") ?? 0.0
                
                mCheckOut.mTaxDiscountAmount = Double("0.0") ?? 0.0
                mCheckOut.mTaxDiscountPercent = Double("0.0") ?? 0.0
                mCheckOut.mTaxTypeIE = UserDefaults.standard.string(forKey: "taxType") ?? ""
                mCheckOut.mCustomerId = self.mCustomerId
                self.navigationController?.pushViewController( mCheckOut, animated:true)
            }
        }
    }
    
    
    @IBAction func mViewPurchasedItems(_ sender: UIButton) {
        if let mData = mReceivedData[sender.tag] as? NSDictionary {
            let storyBoard: UIStoryboard = UIStoryboard(name: "laybyInstallment", bundle: nil)
            if let mPurchasedItems = storyBoard.instantiateViewController(withIdentifier: "PurchasedItems") as? PurchasedItems {

                mPurchasedItems.transitioningDelegate = self
                mPurchasedItems.mId = "\(mData.value(forKey: "id") ?? "")"
                mPurchasedItems.mType = "\(mData.value(forKey: "order_type") ?? "")"
                mPurchasedItems.modalPresentationStyle = .automatic
                self.present(mPurchasedItems,animated: true)
            }
        }
    }
    
    
    func mGetReceiveAmount(masterData: NSArray, selectedData: NSMutableArray, totalInstallments: Int, totalMonths: Int, receivedAmount: Double, outstanding: Double,selectedInstallments : [Int]) {

        if let mData = mReceivedData[self.mIndexValue] as? NSDictionary {
            let storyBoard: UIStoryboard = UIStoryboard(name: "laybyInstallment", bundle: nil)
            if let mCheckOut = storyBoard.instantiateViewController(withIdentifier: "LaybyInstallmentCheckout") as? LaybyInstallmentCheckout {
                mCheckOut.mTotalP = "\(mData.value(forKey: "amount") ?? "0.00")"
                mCheckOut.mTotalReceived = "\(receivedAmount)"
                mCheckOut.mTaxP = ""
                mCheckOut.mInstallmentMasterData = masterData
                mCheckOut.mInstallmentData = NSArray(array:selectedData)
                mCheckOut.mTaxAm = ""
                mCheckOut.mOrderType = "Installment"
                mCheckOut.mNoOfInstallments = String(totalInstallments)
                mCheckOut.mSelectedInstallments = selectedInstallments
                mCheckOut.mInstallmentId = "\(mData.value(forKey: "order_id") ?? "")"
                mCheckOut.mTotalOutstandingAm = "\(outstanding)"
                mCheckOut.mCurrencySymbol = "\(UserDefaults.standard.string(forKey: "currencySymbol") ?? "$")"
                mCheckOut.mCartTotalAmount = ""
                mCheckOut.mDepositPercents = ""
                mCheckOut.mTotalItems = Int("\(mData.value(forKey: "SKU") ?? "1")") ?? 1
                mCheckOut.mTotalWithDiscount =  ""
                mCheckOut.mLabourPoints = Double("0.0") ?? 0.0
                mCheckOut.mShippingPoints = Double("0.0") ?? 0.0
                mCheckOut.mLoyaltyPoints = Double("0.0") ?? 0.0
                mCheckOut.mTaxAmount = Double("0.0") ?? 0.0
                mCheckOut.mTaxAmountInt = Double("0.0") ?? 0.0
                mCheckOut.mTaxInPercent = Double("0.0") ?? 0.0
                
                mCheckOut.mTaxDiscountAmount = Double("0.0") ?? 0.0
                mCheckOut.mTaxDiscountPercent = Double("0.0") ?? 0.0
                mCheckOut.mTaxTypeIE = UserDefaults.standard.string(forKey: "taxType") ?? ""
                mCheckOut.mCustomerId = self.mCustomerId
                self.navigationController?.pushViewController( mCheckOut, animated:true)
            }
        }
        
    }

}
