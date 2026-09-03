//
//  CompleteInstallmentLayby.swift
//  GIS
//
//  Created by Macbook Pro on 15/07/23.
//  Copyright © 2023 Hawkscode. All rights reserved.
//

import UIKit
import Alamofire

class CompleteInstallmentLayby: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var mView : UIView!
    
    @IBOutlet weak var mGrandTotal : UILabel!
    @IBOutlet weak var mInstallments : UILabel!
    @IBOutlet weak var mTotalOutStanding : UILabel!
    @IBOutlet weak var mTableView : UITableView!
  
    @IBOutlet weak var mTotalItems: UILabel!
    
    @IBOutlet weak var mDueDate: UILabel!
    @IBOutlet weak var mDueDateView: UIStackView!
    @IBOutlet weak var mTotalReceived: UILabel!
    @IBOutlet weak var mNoOfReceive: UILabel!
    @IBOutlet weak var mReceiveView: UIStackView!
    var mGrandTotalAmount = ""
    var isRepayment = false
    var mOutstandingBalance = ""
    var mNoOfInstallments = ""
    var mInstallmentsData = NSArray()
    var mNoOfInstallmentsArray = [Int]()
    var mSelectedInstallments = [Int]()

    @IBOutlet weak var mInstallmentView: UIStackView!
    var mTotalReceivedAmounts = ""
    var mDueDates = ""
    var mNoOfReceivedAmounts = ""
    var mPaymentType = ""
 
    var mOrderId = ""
    var mEmailId = ""
    var mTotalQuantity = "1"
    var mUrl = ""
    
    
    @IBOutlet weak var mOrderSuccessfulLABEL: UILabel!
    
    
    @IBOutlet weak var mDueDateLABEL: UILabel!
    @IBOutlet weak var mBackToPOSButton: UIButton!
    @IBOutlet weak var mOutstandingLABEL: UILabel!
    @IBOutlet weak var mInstalmentLABEL: UILabel!
    @IBOutlet weak var mGrandTotalLABEL: UILabel!
    @IBOutlet weak var mOrderSummaryLABEL: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mOrderSuccessfulLABEL.text = "Order Successful".localizedString
        mBackToPOSButton.setTitle("BACK TO POS".localizedString, for: .normal)
        mOutstandingLABEL.text = "Outstanding Balance".localizedString
        mInstalmentLABEL.text = "Installments".localizedString
        mGrandTotalLABEL.text = "Grand Total".localizedString
        mOrderSummaryLABEL.text = "Order Summary".localizedString
        mDueDateLABEL.text = "Due Date".localizedString
    
        mGrandTotal.text = "\(UserDefaults.standard.string(forKey: "currencySymbol") ?? "$" ) " + mGrandTotalAmount
      
       
        if mTotalQuantity != "1"  {
            mTotalItems.text = "\(mTotalQuantity) " + "Items".localizedString
        }else{
            mTotalItems.text = "\(mTotalQuantity) " + "Item".localizedString
        }
         
         if mPaymentType == "Installment" {
             self.mTableView.isHidden = false
             self.mInstallmentView.isHidden = false
             self.mDueDateView.isHidden = true
             self.mReceiveView.isHidden = true
             mTotalOutStanding.text = "\(UserDefaults.standard.string(forKey: "currencySymbol") ?? "$" ) " + mOutstandingBalance.formatPrice()
             
             for i in 1...(mInstallmentsData.count) {
                 mNoOfInstallmentsArray.append(i)
             }
            mInstallments.text = "x\(mNoOfInstallments) "
             mTableView.showsVerticalScrollIndicator = false
             mTableView.delegate = self
             mTableView.dataSource = self
             mTableView.reloadData()
         }else{
             mTotalOutStanding.text = mOutstandingBalance
             self.mTableView.isHidden = true
             self.mInstallmentView.isHidden = true
             self.mNoOfReceive.text = self.mNoOfReceivedAmounts
             self.mTotalReceived.text =  self.mTotalReceivedAmounts
             self.mDueDate.text = self.mDueDates
             self.mDueDateView.isHidden = false
             self.mReceiveView.isHidden = false
         }
        
        
         if isRepayment {
             
         }
    
    }
    
   
    @IBAction func mConfirm(_ sender: Any) {
            
        let storyBoard: UIStoryboard = UIStoryboard(name: "reserveBoard", bundle: nil)
        if let home = storyBoard.instantiateViewController(withIdentifier: "HomePage1") as? HomePage {
            self.navigationController?.pushViewController(home, animated:true)
        }
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
                cell.mInstallment.text = mFormatOrdinal(num: mIndex)
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
    
    
    
    @IBAction func mPrint(_ sender: Any) {
        
         if mUrl != "" {
            if let url = URL(string: mUrl) {
                UIApplication.shared.open(url)
            }
        }
       
    }
    
    @IBAction func mEmail(_ sender: Any) {
        if let mEmailPopUp = UINib(nibName:"emailpopup",bundle:.main).instantiate(withOwner: nil, options: nil).first as? EmailPopUp {
            mEmailPopUp.frame = self.view.bounds
            mEmailPopUp.mOrderId = mOrderId
            mEmailPopUp.mEmail.text = mEmailId
            mEmailPopUp.mEmailConfirmationLABEL.text = "Email Confirmation".localizedString
            mEmailPopUp.mPleaseConfrimLABEL.text = "Please confirm your email address where invoice to be sent".localizedString
            mEmailPopUp.mEmail.placeholder = "example: name@mail.com"
            mEmailPopUp.mConfirmButton.setTitle("Confirm".localizedString, for: .normal)
            self.view.addSubview(mEmailPopUp)
        }
    }

    @IBAction func mShare(_ sender: Any) {
         if mUrl != "" {
            let items = [mUrl]
            let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
            present(ac, animated: true)
        }
      
    }
 
    
    func mEmailUser(type: String ){
        
        var mUrl = ""
        let mLocation = UserDefaults.standard.string(forKey: "location") ?? ""
        let urlInvoice = UserDefaults.standard.string(forKey: "reportAPI")
        if let inUrl = urlInvoice {
            mUrl = inUrl
        }
        
        let urlPath =  mEmailReport
        let params = ["location": mLocation, "type":type , "printUrl":mUrl]
        if Reachability.isConnectedToNetwork() == true {
            AF.request(urlPath, method:.post, parameters: params, headers: sGisHeaders2).responseJSON
            { response in
                
                if(response.error != nil){
                    
                    
                }else{
                    guard let jsonData = response.data else {
                        return
                    }
                    
                    let json = try? JSONSerialization.jsonObject(with: jsonData, options: [])
                    
                    guard let jsonResult = json as? NSDictionary else {
                        return
                    }
                    if jsonResult.value(forKey: "code") as? Int == 200 {
                        
                        
                        CommonClass.showSnackBar(message: "Email has been sent successfully!")
                        
                    }else{
                        if let error = jsonResult.value(forKey: "error") as? String {
                            if error == "Authorization has been expired" {
                                CommonClass.sessionExpired(isExpired: true, navigation: self.navigationController)
                            }
                            
                        }
                        
                    }
                    
                }
                
                
            }
        }else{
            CommonClass.showSnackBar(message: "No Internet Connection")
        }
        
        
    }
    
}
