//
//  PayLayBy.swift
//  GIS
//
//  Created by Macbook Pro on 17/07/23.
//  Copyright © 2023 Hawkscode. All rights reserved.
//

import UIKit



class PayLayBy:  UIViewController, UITableViewDelegate, UITableViewDataSource {
    
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
    
    var mLaybyData = NSArray()
    
    @IBOutlet weak var mTotalReceivedAmount: UILabel!
    
    @IBOutlet weak var mCheckoutButton: UIButton!
    @IBOutlet weak var mTotalOutstandingAmount: UILabel!
    
    
    
    @IBOutlet weak var mOCurrency: UILabel!
    @IBOutlet weak var mRCurrency: UILabel!
    @IBOutlet weak var mNoOfLaybyTobePaid: UILabel!
    @IBOutlet weak var mDueAmount: UITextField!
    
    @IBOutlet weak var mNextDueDate: UILabel!
    var mData = NSDictionary()
    let mDatePicker:UIDatePicker = UIDatePicker()

    var delegate:ConfirmLaybyDelegate? = nil

    @IBOutlet weak var mOutStandingLABEL: UILabel!
    @IBOutlet weak var mReceiveAmountLABEL: UILabel!
    var mCustomerId = ""
    var mOutstandingAmount = 0.00
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
        
        
        self.mTableView.showsVerticalScrollIndicator = false
        self.mTableView.delegate = self
        self.mTableView.dataSource = self
        self.mTableView.reloadData()
        self.mRCurrency.text = UserDefaults.standard.string(forKey: "currencySymbol") ?? "$"
        self.mOCurrency.text = UserDefaults.standard.string(forKey: "currencySymbol") ?? "$"
        
        self.mDueAmount.keyboardType = .numberPad
        self.mNoOfLaybyTobePaid.text = mFormatOrdinal(num: (self.mLaybyData.count + 1))
        self.mTotalOutstandingAmount.text = "0.00"
        self.mOutstandingAmount = Double("\(mData.value(forKey: "outstanding") ?? "0.00" )") ?? 0.00
        self.mTotalReceivedAmount.text = "\(mData.value(forKey: "outstanding") ?? "0.00" )".formatPrice()
        self.mDueAmount.text = "\(mData.value(forKey: "outstanding") ?? "0.00" )"
        self.mNextDueDate.text = mData.value(forKey: "due_date") as? String ?? "--"
        self.mDate.text = mData.value(forKey: "date") as? String ?? "--"
        self.mOrderId.text = mData.value(forKey: "vr_no") as? String ?? "--"
        self.mType.text = "LayBy"
        self.mTotalReceived.text = "\(mData.value(forKey: "total_receive") ?? 0 )"
        self.mNextDue.text = "(Due \(mData.value(forKey: "due_date") ?? "--"))"
        self.mReceivedAmount.text = "\(UserDefaults.standard.string(forKey: "currencySymbol") ?? "$")" +  " \(mData.value(forKey: "payment") ?? "0.00")"
        self.mTotalAmount.text = "\(mData.value(forKey: "amount") ?? "0.00")"
        self.mCustomerName.text = mData.value(forKey: "customer_name") as? String ?? "--"
        self.mCusttomerImage.downlaodImageFromUrl(urlString: mData.value(forKey: "profile_picture") as? String ?? "--")
        self.mCustomerMobile.text = mData.value(forKey: "customer_contact") as? String ?? "--"
        self.mTotalBalance.text = "\(UserDefaults.standard.string(forKey: "currencySymbol") ?? "$")"  + " \(mData.value(forKey: "outstanding") ?? "0.00")"
    }
     
    @IBAction func mEditPrice(_ sender: UITextField) {
        
        if Double(sender.text ?? "") ?? 0.00 == 0 || Double(sender.text ?? "") ?? 0.00 > mOutstandingAmount {
           
            
            sender.text = "\(mData.value(forKey: "outstanding") ?? "0.00" )"

            self.mTotalOutstandingAmount.text = "0.00"
            self.mTotalReceivedAmount.text = "\(mData.value(forKey: "outstanding") ?? "0.00" )".formatPrice()
        }else{
            let mAmount = Double(sender.text ?? "") ?? 0.00
            self.mTotalOutstandingAmount.text = "\(self.mOutstandingAmount - mAmount)".formatPrice()
            self.mTotalReceivedAmount.text = String(mAmount).formatPrice()
        }
        
    }
    
    func mGetDatePicker(){
        let currentDate = Date()
        var datecomp = DateComponents()
        let min = Calendar.init(identifier: .gregorian)
        
        mDatePicker.preferredDatePickerStyle = .wheels
        datecomp.day = 0
        let minDates = min.date(byAdding: datecomp, to: currentDate)
        
        datecomp.year = 5
        let maxDates = min.date(byAdding: datecomp, to: currentDate)
        mDatePicker.minimumDate = minDates
        mDatePicker.maximumDate = maxDates
        mDatePicker.datePickerMode = .date
        mDatePicker.backgroundColor = .white
        //ToolBar
        let mToolBar = UIToolbar()
        mToolBar.sizeToFit()
        mToolBar.backgroundColor = .white
        mToolBar.barTintColor = .white
        let mDone = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donePick))
        let mSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let mCancel = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(mCancelPick))
        mToolBar.setItems([mCancel, mSpace,mDone], animated: false)
    
    mPaymentConfirmation.mDueDate.inputAccessoryView = mToolBar
    mPaymentConfirmation.mDueDate.inputView = mDatePicker
    mPaymentConfirmation.mDueDate.becomeFirstResponder()
}
    @objc
    func donePick(){
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "dd/MM/yyyy"

        mConfirmQuote.mCurrentDate.text = formatter.string(from: mDatePicker.date)
 
           self.view.endEditing(true)
        
                 
         }
         @objc func mCancelPick(){
             self.view.endEditing(true)
         }
    
 
 
    @IBAction func mCheckout(_ sender: Any) {
        let totalRecievedAmount = mTotalReceivedAmount.text ?? ""
        let totalOutstandingAmount = mTotalOutstandingAmount.text ?? ""
        if (Double(totalRecievedAmount.replacingOccurrences(of: ",", with: "")) ?? 0.00) == 0 {            CommonClass.showSnackBar(message: "Please choose valid amount")
            return
        }
        self.dismiss(animated: true)
        delegate?.mConfirmLayByPayment(date: "", receiveAmount: "\((Double(totalRecievedAmount.replacingOccurrences(of: ",", with: "")) ?? 0.00))", outstanding: "\((Double(totalOutstandingAmount.replacingOccurrences(of: ",", with: "")) ?? 0.00))", noOfReceived: "\(mFormatOrdinal(num:(self.mLaybyData.count + 1))) Received")
    
 
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if  mLaybyData.count == 0 {
            tableView.setError("No items found!")
        }else{
            tableView.clearBackground()
        }
       return mLaybyData.count    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PaidInstallments") as? PaidInstallments,
              let mData = mLaybyData[indexPath.row] as? NSDictionary else {
            return UITableViewCell()
        }
        
        let mIndex = (indexPath.row + 1)
        cell.mNoOfInstallmentsPaid.text = mFormatOrdinal(num: mIndex)
        cell.mAmount.text = "\(UserDefaults.standard.string(forKey: "currencySymbol") ?? "$")" + " \(mData.value(forKey: "amount") ?? "0.00")"
        cell.mDate.text = mData.value(forKey: "date") as? String ?? ""
        return cell
    }
    
    func mFormatOrdinal(num: Int) -> String {
        var formattedNumber = ""
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        formattedNumber = formatter.string(from: NSNumber(integerLiteral: num)) ?? "1"
        return formattedNumber
    }
}
