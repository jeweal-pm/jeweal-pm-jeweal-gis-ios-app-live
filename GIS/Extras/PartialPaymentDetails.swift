//
//  PartialPaymentDetails.swift
//  GIS
//
//  Created by Macbook Pro on 21/07/23.
//  Copyright © 2023 Hawkscode. All rights reserved.
//

import UIKit
import Alamofire
class LaybyPaymentItems : UITableViewCell {
    
    @IBOutlet weak var mSNo: UILabel!
    
    @IBOutlet weak var mReceiveLabel: UILabel!
    
    @IBOutlet weak var mReceiveDate: UILabel!
    
    @IBOutlet weak var mAmount: UILabel!
    
}
class InstallmentPaymentItems : UITableViewCell {
    @IBOutlet weak var mDueAmount: UILabel!
    
    @IBOutlet weak var mReceiveAmount: UILabel!
    @IBOutlet weak var mReceiveDate: UILabel!
    @IBOutlet weak var mDueDate: UILabel!
    @IBOutlet weak var mReceiveLabel: UILabel!
    @IBOutlet weak var mDueLabel: UILabel!
    
    @IBOutlet weak var mSNo: UILabel!
    
}
class PartialPaymentDetails: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var mId = ""
    var mType = ""
    var mData = NSArray()
    @IBOutlet weak var mHeading: UILabel!
    @IBOutlet weak var mTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
        
        mTableView.separatorColor = .clear
        
        if mType == "lay_by" {
            mHeading.text = "LayBy".localizedString
        }else{
            mHeading.text = "Installments".localizedString
            
        }
        mGetPaymentDetails()
        
    }
    
    
    
    
    func mGetPaymentDetails() {
        CommonClass.showFullLoader(view: self.view)
        
        mGetData(url: mGetPartialPaymentDetails,headers: sGisHeaders,  params: ["id":mId, "type":mType]) { response , status in
            CommonClass.stopLoader()
            if status {
                if let mData = response.value(forKey: "data") as? NSArray {
                    if mData.count > 0 {
                        
                        self.mData = mData
                        self.mTableView.showsVerticalScrollIndicator = false
                        self.mTableView.delegate = self
                        self.mTableView.dataSource = self
                        self.mTableView.reloadData()
                    }
                    
                }
                
                
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if mData.count == 0 {
            tableView.setError("No items found!")
        }else{
            tableView.clearBackground()
        }
        return mData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LaybyPaymentItems") as? LaybyPaymentItems,
              let cell2 = tableView.dequeueReusableCell(withIdentifier: "InstallmentPaymentItems") as? InstallmentPaymentItems else {
            return UITableViewCell()
        }
        
        if let mData = mData[indexPath.row] as? NSDictionary {
            
            if mType == "lay_by" {
                let mIndex = (indexPath.row + 1)
                cell.mReceiveLabel.text = "Receive".localizedString
                cell.mSNo.text = mFormatOrdinal(num:mIndex)
                cell.mReceiveDate.text = "\(mData.value(forKey: "receive_date") ?? "--")"
                cell.mAmount.text = "\(UserDefaults.standard.string(forKey: "currencySymbol") ?? "$")"  + " \(mData.value(forKey: "payment_receive") ?? "0.00")"
                if (indexPath.row % 2 == 0) {
                    cell.backgroundColor = UIColor(named: "themeBackground")
                }else{
                    cell.backgroundColor = #colorLiteral(red: 0.9568627451, green: 0.9568627451, blue: 0.9568627451, alpha: 1)
                }
                return cell
            }else{
                let mIndex = (indexPath.row + 1)
                cell2.mSNo.text = mFormatOrdinal(num:mIndex)
                cell2.mReceiveLabel.text = "Receive".localizedString
                cell2.mDueLabel.text = "Due".localizedString
                cell2.mReceiveDate.text = "\(mData.value(forKey: "receive_date") ?? "--")"
                cell2.mDueDate.text = "\(mData.value(forKey: "receive_date") ?? "--")"
                cell2.mDueAmount.text = "\(UserDefaults.standard.string(forKey: "currencySymbol") ?? "$")"  + " \(mData.value(forKey: "outstanding") ?? "0.00")"
                cell2.mReceiveAmount.text = "\(UserDefaults.standard.string(forKey: "currencySymbol") ?? "$")"  + " \(mData.value(forKey: "payment_receive") ?? "0.00")"
                if (indexPath.row % 2 == 0) {
                    cell2.backgroundColor = UIColor(named: "themeBackground")
                }else{
                    cell2.backgroundColor = #colorLiteral(red: 0.9568627451, green: 0.9568627451, blue: 0.9568627451, alpha: 1)
                }
                
                return cell2
            }
        } else {
            return UITableViewCell()
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
