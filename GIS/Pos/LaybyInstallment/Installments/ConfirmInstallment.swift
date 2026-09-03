//
//  ConfirmInstallment.swift
//  GIS
//
//  Created by Macbook Pro on 13/07/23.
//  Copyright © 2023 Hawkscode. All rights reserved.
//

import UIKit

class ConfirmInstallment: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var mView : UIView!
    
    @IBOutlet weak var mGrandTotal : UILabel!
    @IBOutlet weak var mInstallments : UILabel!
    @IBOutlet weak var mTotalOutStanding : UILabel!
    @IBOutlet weak var mTableView : UITableView!

    var isRepayment = false
    var mSelectedInstallments = [Int]()
    var mGrandTotalAmount = ""
    var mOutstandingBalance = ""
    var mNoOfInstallments = ""
    var mInstallmentsData = NSArray()
    var mNoOfInstallmentsArray = [Int]()

    
    var delegate:ProceedToPay? = nil
    
    
    @IBOutlet weak var mInstallmentLABEL: UILabel!
    
    @IBOutlet weak var mGrandTotalLABEL: UILabel!
    
    @IBOutlet weak var mPaymentConfirmationLABEL: UILabel!
    
    @IBOutlet weak var mCancelButtonLABEL: UIButton!
    @IBOutlet weak var mConfirmButton: UIButton!
    @IBOutlet weak var mOutStandingAmountLABEL: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        mPaymentConfirmationLABEL.text = "Payment Confirmation".localizedString
        mGrandTotalLABEL.text = "Grand Total".localizedString
        mOutStandingAmountLABEL.text = "Outstanding Balance".localizedString
        mConfirmButton.setTitle("CONFIRM".localizedString, for: .normal)
        mCancelButtonLABEL.setTitle("CANCEL".localizedString, for: .normal)
        for i in 1...(mInstallmentsData.count) {
            mNoOfInstallmentsArray.append(i)
        }
        mGrandTotal.text = "\(UserDefaults.standard.string(forKey: "currencySymbol") ?? "$" ) " + mGrandTotalAmount.formatPrice()
        mTotalOutStanding.text = "\(UserDefaults.standard.string(forKey: "currencySymbol") ?? "$" ) " + mOutstandingBalance.formatPrice()
        mInstallments.text = "x\(mNoOfInstallments) "
        mView.layer.cornerRadius = 24
        mView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        mTableView.showsVerticalScrollIndicator = false
        mTableView.delegate = self
        mTableView.dataSource = self
        mTableView.reloadData()
        
        if isRepayment {
            
        }
        
    }
    
    @IBAction func mCancel(_ sender: Any) {
        self.dismiss(animated: true)

    }
    
    @IBAction func mConfirm(_ sender: Any) {
            
        self.dismiss(animated: true)
        self.delegate?.isProceed(status: true)
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mInstallmentsData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "InstallmentItems") as? InstallmentItems else {
            return UITableViewCell()
        }

        if let mData = mInstallmentsData[indexPath.row] as? NSDictionary {
            let mEquatedAmount = String(format:"%.02f",locale:Locale.current,Double("\(mData.value(forKey: "amount") ?? "0.00")" ) ?? 0.00)
            if isRepayment {
                cell.mInstallment.text = mFormatOrdinal(num: mSelectedInstallments[indexPath.row])

            }else{
                let mIndex = (indexPath.row + 1)
                cell.mInstallment.text = mFormatOrdinal(num:mIndex)

            }
            cell.mAmount.text = (UserDefaults.standard.string(forKey: "currencySymbol") ?? "$") + " \(mEquatedAmount)"
            
            cell.backgroundColor = (indexPath.row % 2 == 0) ? UIColor(named: "themeBackground") : #colorLiteral(red: 0.9568627451, green: 0.9568627451, blue: 0.9568627451, alpha: 1)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }

    func mFormatOrdinal(num: Int) -> String {
        var formattedNumber = ""
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        formattedNumber = formatter.string(from: NSNumber(integerLiteral: num)) ?? "1"
        return formattedNumber
    }
    
}
