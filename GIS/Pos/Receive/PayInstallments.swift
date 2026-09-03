//
//  PayInstallments.swift
//  GIS
//
//  Created by Macbook Pro on 17/07/23.
//  Copyright © 2023 Hawkscode. All rights reserved.
//

import UIKit

class PaidInstallments: UITableViewCell {
    
    
    @IBOutlet weak var mNoOfInstallmentsPaid: UILabel!
    
    @IBOutlet weak var mDate: UILabel!
    
    @IBOutlet weak var mAmount: UILabel!
}
class PayInstallments: UIViewController , UITableViewDataSource, UITableViewDelegate{

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
    
    @IBOutlet weak var mTableView: UITableView!
    
    var mInstallmentData = NSMutableArray()
 
    var mSelectedIndex = [Int]()
    var mTotalAmounts = 0.00
    @IBOutlet weak var mTotalReceivedAmount: UILabel!
    
    @IBOutlet weak var mRCurrency: UILabel!
    var mReceiveAmounts = Double()
    var mOutstandingAmounts = Double()
    
    var mOutstanding = 0.00
    var mTotalInstallments = 10
    var mTotalTerm = 1

    var mData = NSDictionary()
    var delegate:FinalInstallmentDelegate? = nil

    var mMasterInstallmentData = NSArray()
    var mSelectedInstallments = [Int]()
    @IBOutlet weak var mOCurrency: UILabel!
    @IBOutlet weak var mCheckoutButton: UIButton!
    @IBOutlet weak var mTotalOutstandingAmount: UILabel!
    
    @IBOutlet weak var mOutStandingLABEL: UILabel!
    @IBOutlet weak var mReceiveAmountLABEL: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        mTypeLAbel.text = "Type".localizedString
        mAmountLabel.text = "Amount".localizedString
        mPaymentsLabel.text = "Payments".localizedString
        mBAlanceLabel.text = "Balance".localizedString
        mReceiveAmountLABEL.text = "Receive Amount".localizedString
        mOutStandingLABEL.text = "Outstanding Balance".localizedString
        mCheckoutButton.setTitle("CHECK OUT".localizedString, for: .normal)
        mSetData()
    }
    
    func mSetData() {
        self.mRCurrency.text = UserDefaults.standard.string(forKey: "currencySymbol") ?? "$"
        self.mOCurrency.text = UserDefaults.standard.string(forKey: "currencySymbol") ?? "$"
        self.mSelectedIndex = [Int]()
        self.mTotalOutstandingAmount.text = "\(self.mOutstanding)".formatPrice()
        self.mTotalReceivedAmount.text = "0.00"
        self.mTableView.showsVerticalScrollIndicator = false
        self.mTableView.delegate = self
        self.mTableView.dataSource = self
        self.mTableView.reloadData()
        self.mDate.text = mData.value(forKey: "date") as? String ?? "--"
        self.mOrderId.text = mData.value(forKey: "vr_no") as? String ?? "--"
        
        self.mType.text = "Installment"
        if let mInstallmentData = mData.value(forKey: "installment") as? NSArray {
            if mInstallmentData.count > 0 {}
            self.mTotalReceived.text = "\(mData.value(forKey: "installment_paid") ?? 0)/\(mInstallmentData.count)"
            self.mNextDue.text = "(Next Due \(mData.value(forKey: "due_date") ?? "--"))"
        }
        self.mReceivedAmount.text = "\(UserDefaults.standard.string(forKey: "currencySymbol") ?? "$")" +  " \(mData.value(forKey: "payment") ?? "0.00")"
        self.mTotalAmount.text = "\(mData.value(forKey: "amount") ?? "0.00")"
        self.mCustomerName.text = mData.value(forKey: "customer_name") as? String ?? "--"
        self.mCusttomerImage.downlaodImageFromUrl(urlString: mData.value(forKey: "profile_picture") as? String ?? "--")
        self.mCustomerMobile.text = mData.value(forKey: "customer_contact") as? String ?? "--"
        self.mTotalBalance.text = "\(UserDefaults.standard.string(forKey: "currencySymbol") ?? "$")"  + " \(mData.value(forKey: "outstanding") ?? "0.00")"
    }
    

     
    @IBAction func mCheckout(_ sender: Any) {
        
        if mSelectedInstallments.isEmpty {
            CommonClass.showSnackBar(message: "Please pick installments")
            return
        }
        self.dismiss(animated: true)
 
        let mSelectedDataArray = NSMutableArray()

        for j in 0...(mMasterInstallmentData.count - 1) {
            if let mData = mMasterInstallmentData[j] as? NSDictionary {
                
                let mIndex = j + 1
                if  mIndex >= self.mSelectedInstallments.first ?? 0  && mIndex <= self.mSelectedInstallments.last ?? 0 {
                    let mSelectedData = NSMutableDictionary()
                    mSelectedData.setValue(Double("\(mData.value(forKey: "amount") ?? "")") ?? 0.00, forKey: "amount")
                    mSelectedData.setValue("1", forKey: "paid")
                    mSelectedData.setValue("\(mData.value(forKey: "id") ?? "")", forKey: "id")
                    mSelectedData.setValue("\(mData.value(forKey: "date") ?? "")", forKey: "date")
                    mSelectedData.setValue("\(mData.value(forKey: "formatted_date") ?? "")", forKey: "formatted_date")
                    mSelectedDataArray.add(mSelectedData)
                }
            }
        }
        let totalOutstandingAmount = mTotalOutstandingAmount.text ?? "0"
        delegate?.mGetReceiveAmount(masterData: mMasterInstallmentData, selectedData: mSelectedDataArray, totalInstallments: mSelectedDataArray.count, totalMonths: mTotalTerm, receivedAmount: mReceiveAmounts, outstanding:(Double(totalOutstandingAmount.replacingOccurrences(of: ",", with: "")) ?? 0.00), selectedInstallments: mSelectedInstallments)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mInstallmentData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        
        if let mData = mInstallmentData[indexPath.row] as? NSDictionary {
            
            let mIndex = (indexPath.row + 1)
            if mData.value(forKey: "paid") as? Int == 1 {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "PaidInstallments") as? PaidInstallments else {
                    return UITableViewCell()
                }
                cell.mAmount.text = "\(mData.value(forKey: "formatted_amount") ?? "0.00")"
                cell.mDate.text = mData.value(forKey: "date") as? String ?? ""
                cell.mNoOfInstallmentsPaid.text = mFormatOrdinal(num: mIndex)
                
                return cell
            }else{
                guard let cell2 = tableView.dequeueReusableCell(withIdentifier: "InstallmentItems") as? InstallmentItems else {
                    return UITableViewCell()
                }
                
                cell2.mAmount.text = "\(mData.value(forKey: "formatted_amount") ?? "0.00")"
                cell2.mDate.text = mData.value(forKey: "date") as? String ?? ""
                
                cell2.mInstallment.text = mFormatOrdinal(num: mIndex)
                cell2.mCheckUncheckButton.isHidden = true
                
                cell2.backgroundColor = (indexPath.row % 2 == 0) ? UIColor(named: "themeBackground") : #colorLiteral(red: 0.9568627451, green: 0.9568627451, blue: 0.9568627451, alpha: 1)
                
                if mSelectedIndex.contains(indexPath.row) {
                    self.mTotalOutstandingAmount.text =  "\((self.mOutstanding) - (Double(self.mReceiveAmounts)))".formatPrice()
                    cell2.mCheckIcon.image = UIImage(named: "check_item")
                }else{
                    cell2.mCheckIcon.image = UIImage(named: "uncheck_item")
                }
                return cell2
            }
        } else {
            return UITableViewCell()
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if let mData = mInstallmentData[indexPath.row] as? NSDictionary {
            
            if mData.value(forKey: "paid") as? Int == 0 {
                var mAmounts = [Double]()
                
                self.mSelectedInstallments = [Int]()
                self.mSelectedIndex = [Int]()
                for i in 0...indexPath.row {
                    self.mSelectedIndex.append(i)
                    if let mData = mInstallmentData[i] as? NSDictionary {
                        if mData.value(forKey: "paid") as? Int == 0 {
                            var mIndex = 0
                            mIndex = i + 1
                            self.mSelectedInstallments.append(mIndex)
                            mAmounts.append(Double("\(mData.value(forKey: "amount") ?? "0.0")") ?? 0.00)
                        }
                    }
                }
                
                
                self.mTotalReceivedAmount.text = "\(mAmounts.reduce(0, {$0 + $1}))".formatPrice()
                self.mReceiveAmounts = mAmounts.reduce(0, {$0 + $1})
                
                self.mTableView.reloadData()
            }
        }
    }

    func mFormatOrdinal(num: Int) -> String {
        var formattedNumber = ""
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        formattedNumber = formatter.string(from: NSNumber(integerLiteral: num)) ?? "1"
        return formattedNumber
    }
}
