//
//  PartialPaymentHistory.swift
//  GIS
//
//  Created by Macbook Pro on 21/07/23.
//  Copyright © 2023 Hawkscode. All rights reserved.
//

import UIKit
import Alamofire
class PartialPaymentItems : UITableViewCell {
    
    @IBOutlet weak var mDate: UILabel!
    
    @IBOutlet weak var mOrderId: UILabel!
    
    @IBOutlet weak var mLocationName: UILabel!

    @IBOutlet weak var mTypeLAbel: UILabel!
    
    @IBOutlet weak var mType: UILabel!
    
    @IBOutlet weak var mAmountLabel: UILabel!
    
    
    @IBOutlet weak var mReceivedAmount: UILabel!
    
    
    @IBOutlet weak var mTotalAmount: UILabel!
    
    
    @IBOutlet weak var mPaymentsLabel: UILabel!
    
    
    @IBOutlet weak var mTotalPaidIntallmentCount: UILabel!
    @IBOutlet weak var mTotalLaybyPaymentCount: UILabel!
    @IBOutlet weak var mNoOfLaybyView: UIView!
    @IBOutlet weak var mNoOfPaymentsInstallmentView: UIView!
     
    @IBOutlet weak var mTotalInstallmentsCount: UILabel!
    @IBOutlet weak var mNextDue: UILabel!
    
    @IBOutlet weak var mBAlanceLabel: UILabel!
    
    @IBOutlet weak var mTotalBalance: UILabel!
    
    
    @IBOutlet weak var mViewItemsLabel: UILabel!
    @IBOutlet weak var mViewItems: UIButton!
    
    
}

class PartialPaymentHistory: UIViewController, UITableViewDelegate, UITableViewDataSource, UIViewControllerTransitioningDelegate  {
   
    
    
    
    
    
    
    @IBOutlet weak var mAllItems: UILabel!
    
    @IBOutlet weak var mAllLine: UILabel!
    
    @IBOutlet weak var mLaybytems: UILabel!
    
    @IBOutlet weak var mLaybyLine: UILabel!
    
    
    @IBOutlet weak var mInstallmentItems: UILabel!
    
    @IBOutlet weak var mInstallmentLine: UILabel!
    
    
    
    
    
    
    
    @IBOutlet weak var mReceiveLabel: UILabel!
    
    @IBOutlet weak var mSearchField: UITextField!
    
    
    
    
    
    var mCustomerId = ""
    
    var mReceivedData = NSArray()
    var mIndexValue = -1
    
    @IBOutlet weak var mTableView: UITableView!
    
    var mMasterData = NSArray()
    var mDataItems = NSArray()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
               
        mTableView.showsVerticalScrollIndicator = false
        mTableView.showsHorizontalScrollIndicator = false
        mReceiveLabel.text = "Partial Payment History".localizedString
        
        mSearchField.placeholder = "Search by Invoice no".localizedString
        mGetAllItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    func mGetAllItems() {
        CommonClass.showFullLoader(view: self.view)
       
        mGetData(url: mGetPartialPaymentHistory,headers: sGisHeaders, params: ["type":"ALL", "customer_id":mCustomerId, "date":""]) { response , status in
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
                    if let vrNo = mData.value(forKey: "vr_no") as? String,
                       let search = sender.text,
                       vrNo.lowercased().contains(search.lowercased()){
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
        
        self.dismiss(animated: true)
        
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
            tableView.setError("No items found!")
        }else{
            tableView.clearBackground()
        }
        return mReceivedData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false

        if let cell = tableView.dequeueReusableCell(withIdentifier: "PartialPaymentItems") as? PartialPaymentItems {
            if let mData = mReceivedData[indexPath.row] as? NSDictionary {
                
                cell.mTypeLAbel.text = "Type".localizedString
                cell.mAmountLabel.text = "Amount".localizedString
                cell.mPaymentsLabel.text = "Payments".localizedString
                cell.mBAlanceLabel.text = "Balance".localizedString
                cell.mDate.text = mData.value(forKey: "date") as? String ?? "--"
                cell.mViewItems.setTitle("View Installments".localizedString, for: .normal)
                cell.mOrderId.text = mData.value(forKey: "vr_no") as? String ?? "--"
                cell.mTotalLaybyPaymentCount.text = "\(mData.value(forKey: "payment") ?? 0 )"
                
                if mData.value(forKey: "order_type") as? String ?? "" == "lay_by" {
                    cell.mType.text = "LayBy"
                    cell.mViewItemsLabel.text = "View LayBy".localizedString
                    cell.mNextDue.text = "(Due \(mData.value(forKey: "due_date") ?? "--"))"
                }else{
                    cell.mType.text = "Installment"
                    cell.mViewItemsLabel.text = "View Installments".localizedString
                    cell.mNextDue.text = "(" + "Next Due".localizedString + " \(mData.value(forKey: "due_date") ?? "--"))"
                    
                }
                
                cell.mReceivedAmount.text = "\(UserDefaults.standard.string(forKey: "currencySymbol") ?? "$")" +  " \(mData.value(forKey: "total_receive") ?? "0.00")"
                cell.mTotalAmount.text = "\(mData.value(forKey: "amount") ?? "0.00")"
                
                
                cell.mTotalBalance.text = "\(UserDefaults.standard.string(forKey: "currencySymbol") ?? "$")"  + " \(mData.value(forKey: "outstanding") ?? "0.00")"
                cell.mViewItems.tag = indexPath.row
            }
            return cell
        } else { return UITableViewCell() }
    }
    
    
    @IBAction func mInstallmentsLaybyItems(_ sender: UIButton) {
        
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "laybyInstallment", bundle: nil)
        if let mPartialPaymentDetails = storyBoard.instantiateViewController(withIdentifier: "PartialPaymentDetails") as? PartialPaymentDetails {
            if let mData = mReceivedData[sender.tag] as? NSDictionary {
                mPartialPaymentDetails.mType = mData.value(forKey: "order_type") as? String ?? ""
                mPartialPaymentDetails.mId = mData.value(forKey: "id") as? String ?? ""
            }
            mPartialPaymentDetails.modalPresentationStyle = .automatic
            mPartialPaymentDetails.transitioningDelegate = self
            self.present(mPartialPaymentDetails,animated: true)
        }
    }
    
    
}
