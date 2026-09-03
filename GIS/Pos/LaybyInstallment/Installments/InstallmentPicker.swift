//
//  InstallmentPicker.swift
//  GIS
//
//  Created by Macbook Pro on 12/07/23.
//  Copyright © 2023 Hawkscode. All rights reserved.
//

import UIKit
import DropDown
import Alamofire
protocol TotalInstallmentsDelegate {
    func mGetInstallment(installments: Int)
 
}


@objc protocol FinalInstallmentDelegate {
    func mGetReceiveAmount(masterData: NSArray, selectedData: NSMutableArray, totalInstallments : Int, totalMonths : Int, receivedAmount : Double , outstanding: Double, selectedInstallments: [Int])
 
     func mCancelInstallment()
}


class InstallmentItems : UITableViewCell {
    
    @IBOutlet weak var mAmount: UILabel!
    @IBOutlet weak var mView: UIView!
    @IBOutlet weak var mDate: UILabel!
    @IBOutlet weak var mInstallment: UILabel!
    @IBOutlet weak var mCheckUncheckButton: UIButton!
    @IBOutlet weak var mCheckIcon: UIImageView!
    @IBOutlet weak var mCheckView: UIView!
}

class InstallmentPicker: UIViewController, UITableViewDelegate, UITableViewDataSource, UIViewControllerTransitioningDelegate , TotalInstallmentsDelegate {

    

    @IBOutlet weak var mHeadingLabel: UILabel!
    
    @IBOutlet weak var mInstallmentLabel: UILabel!
    @IBOutlet weak var mTermLabel: UILabel!
    
    @IBOutlet weak var mGrandTotalLabel: UILabel!
    @IBOutlet weak var mGrandTotal: UILabel!
    
    @IBOutlet weak var mTerms: UILabel!
    @IBOutlet weak var mNoOfInstallments: UILabel!
 
    @IBOutlet weak var mOutstandingAmount: UILabel!
    @IBOutlet weak var mReceiveAmount: UILabel!
  
    @IBOutlet weak var mTableView: UITableView!
    
    
     var mNoOfTermsArray = ["1 month", "2 months","3 months"]

    
    var mMasterInstallmentData = NSArray()
    var mInstallmentData = NSMutableArray()
    var mTotalAmount = 0.00
    var mTotalInstallments = 10
    var mTotalTerm = 1
    var mReceiveAmounts = Double()
    var mOutstandingAmounts = Double()

    var mSelectedIndex = [Int]()

    var delegate:FinalInstallmentDelegate? = nil
    @IBOutlet weak var mRCurrency: UILabel!
    @IBOutlet weak var mOCurrency: UILabel!

    
    @IBOutlet weak var mOutStandingLABEL: UILabel!
    @IBOutlet weak var mReceiveAmountLABEL: UILabel!
    
    @IBOutlet weak var mCancelButton: UIButton!
    @IBOutlet weak var mConfirmButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mHeadingLabel.text = "Installment".localizedString
        mGrandTotalLabel.text = "Grand Total".localizedString
        mInstallmentLabel.text = "Installments".localizedString
        mTermLabel.text = "Term".localizedString
        mOutStandingLABEL.text = "Outstanding Balance".localizedString
        mConfirmButton.setTitle("CONFIRM".localizedString, for: .normal)
        mCancelButton.setTitle("CANCEL".localizedString, for: .normal)

        self.mGrandTotal.text  = "\(UserDefaults.standard.string(forKey: "currencySymbol") ?? "$")" +
        " \(mTotalAmount)".formatPrice()
        mRCurrency.text = UserDefaults.standard.string(forKey: "currencySymbol") ?? "$"
        mOCurrency.text = UserDefaults.standard.string(forKey: "currencySymbol") ?? "$"
        mGetInstallments()
    }
    
    func mGetInstallments() {

        self.mSelectedIndex = [Int]()
        self.mOutstandingAmount.text = "\(self.mTotalAmount)".formatPrice()
        self.mReceiveAmount.text = "0.00"
        CommonClass.showFullLoader(view: self.view)
        
        mGetData(url: mGetInstallmentPlans,headers:sGisHeaders,  params: ["installment":self.mTotalInstallments, "term":self.mTotalTerm, "status_type":"pos_order", "amount":mTotalAmount]) { response , status in
            CommonClass.stopLoader()
            if status {
                if let mData = response.value(forKey: "data") as? NSArray {
                    if mData.count > 0 {
                      
                        self.mMasterInstallmentData = mData
                        self.mInstallmentData = NSMutableArray(array: mData)
                        self.mTableView.showsVerticalScrollIndicator = false
                        self.mTableView.delegate = self
                        self.mTableView.dataSource = self
                        self.mTableView.reloadData()
                    }
                    
                }


            }
        }
    }

    func mGetInstallment(installments: Int) {
        self.mNoOfInstallments.text = "x\(installments)"
         mTotalInstallments = installments
         mGetInstallments()
    }
    @IBAction func mChooseInstallments(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "laybyInstallment", bundle: nil)
        if let mNoOfInstallments = storyBoard.instantiateViewController(withIdentifier: "NoOfInstallments") as? NoOfInstallments {
            mNoOfInstallments.delegate = self
            mNoOfInstallments.mMaxAmount = mTotalAmount
            mNoOfInstallments.transitioningDelegate = self
            
            mNoOfInstallments.modalPresentationStyle = .automatic
            self.present(mNoOfInstallments,animated: true)
        }
    }
    
    @IBAction func mChooseTerm(_ sender: Any) {
        let dropdown = DropDown()
               dropdown.anchorView = self.mTerms
               dropdown.direction = .any
               dropdown.bottomOffset = CGPoint(x: 0, y: self.mTerms.frame.size.height)
               dropdown.width = 120
               dropdown.dataSource = mNoOfTermsArray
               dropdown.selectionAction = {
                       [unowned self](index:Int, item: String) in
                   self.mTerms.text  = item
                   self.mTotalTerm = index + 1
                   self.mGetInstallments()
                   }
               dropdown.show()
    }
    
    @IBAction func mCancel(_ sender: Any) {
        dismiss(animated: true)
        delegate?.mCancelInstallment()
    }
    
    @IBAction func mConfirm(_ sender: Any) {
        if mSelectedIndex.isEmpty {
            CommonClass.showSnackBar(message: "Please pick installments")
            return
        }
        self.dismiss(animated: true)
        self.mInstallmentData = NSMutableArray()
        for i in 0...(mSelectedIndex.count - 1) {
            if let mData = mMasterInstallmentData[i] as? NSDictionary {
                let mInsData = NSMutableDictionary()
                mInsData.setValue(Double("\(mData.value(forKey: "amount") ?? "")") ?? 0.00, forKey: "amount")
                mInsData.setValue("1", forKey: "paid")
                mInsData.setValue("\(mData.value(forKey: "id") ?? "")", forKey: "id")
                mInsData.setValue("\(mData.value(forKey: "date") ?? "")", forKey: "date")
                mInsData.setValue("\(mData.value(forKey: "formatted_date") ?? "")", forKey: "formatted_date")
                self.mInstallmentData.add(mInsData)
            }
        }
        

        delegate?.mGetReceiveAmount(masterData: mMasterInstallmentData, selectedData: mInstallmentData, totalInstallments: mTotalInstallments, totalMonths: mTotalTerm, receivedAmount: mReceiveAmounts, outstanding: mOutstandingAmounts, selectedInstallments: [0])
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
         if  mMasterInstallmentData.count == 0 {
             tableView.setError("No items found!")
         }else{
             tableView.clearBackground()
         }
        return mMasterInstallmentData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "InstallmentItems") as? InstallmentItems else {
            return UITableViewCell()
        }
        if let mData = mMasterInstallmentData[indexPath.row] as? NSDictionary {
            
            cell.mAmount.text = mData.value(forKey: "formatted_amount") as? String ?? "0.00"
            cell.mDate.text = mData.value(forKey: "date") as? String ?? "--"
            let mIndex = (indexPath.row + 1)
            cell.mInstallment.text = mFormatOrdinal(num: mIndex)
            cell.mCheckUncheckButton.isHidden = true
            
            cell.backgroundColor = (indexPath.row % 2 == 0) ? UIColor(named: "themeBackground") : #colorLiteral(red: 0.9568627451, green: 0.9568627451, blue: 0.9568627451, alpha: 1)
            
            if mSelectedIndex.contains(indexPath.row) {
                self.mOutstandingAmount.text =  "\((self.mTotalAmount) - (Double(self.mReceiveAmounts)))".formatPrice()
                cell.mCheckIcon.image = UIImage(named: "check_item")
            }else{
                cell.mCheckIcon.image = UIImage(named: "uncheck_item")
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        var mAmounts = [Double]()

        self.mSelectedIndex = [Int]()
        for i in 0...indexPath.row {
            self.mSelectedIndex.append(i)
            if let mData = mMasterInstallmentData[i] as? NSDictionary {
                mAmounts.append(Double("\(mData.value(forKey: "amount") ?? "0.0")") ?? 0.00)
            }
        }
      

        self.mReceiveAmount.text = " "+"\(mAmounts.reduce(0, {$0 + $1}))".formatPrice()
        self.mReceiveAmounts = mAmounts.reduce(0, {$0 + $1})

        self.mTableView.reloadData()
    }
    func mFormatOrdinal(num: Int) -> String {
        var formattedNumber = ""
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        formattedNumber = formatter.string(from: NSNumber(integerLiteral: num)) ?? "1"
        return formattedNumber
    }
}
