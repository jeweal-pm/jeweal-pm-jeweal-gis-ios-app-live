//
//  Quotations.swift
//  GIS
//
//  Created by Macbook Pro on 20/07/23.
//  Copyright © 2023 Hawkscode. All rights reserved.
//

import UIKit
import Alamofire
class QuotationItems:UITableViewCell {
    
    @IBOutlet weak var mDate: UILabel!
    
    @IBOutlet weak var mOrderId: UILabel!
    
    @IBOutlet weak var mRemove: UIButton!
    @IBOutlet weak var mCustomerName: UILabel!
    
    
    @IBOutlet weak var mCustomerMobile: UILabel!
    
    @IBOutlet weak var mCusttomerImage: UIImageView!
    
    @IBOutlet weak var mLocationName: UILabel!
    
    @IBOutlet weak var mDueDate: UILabel!
    
    @IBOutlet weak var mQuotedItemsLABEL: UILabel!
    @IBOutlet weak var mType: UILabel!
    
    
    @IBOutlet weak var mViewQuotedItems: UIButton!
}

class Quotations: UIViewController, UITableViewDelegate, UITableViewDataSource, UIViewControllerTransitioningDelegate, GetCustomerDataDelegate , ProceedToPay, DeleteCustomCartItems, QuotationItemDelegate, ScannerDelegate {
    
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
    
    var mQuotedData = NSArray()
    var mIndexValue = -1
    
    @IBOutlet weak var mTableView: UITableView!
    
    var mMasterData = NSArray()
    var mDataItems = NSArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mReceiveLabel.text = "Quotation".localizedString
        mSearchField.placeholder = "Search by Invoice no / Customer".localizedString
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        mCustomerId  = UserDefaults.standard.string( forKey: "DEFAULTCUSTOMER") ?? ""
        if mCustomerId == "" {
            mOpenCustomerSheet()
        }else{
            mGetAllItems()
            
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
        self.mGetAllItems()
        
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
        
        mGetData(url: mGetAllQuotations,headers: sGisHeaders,  params: ["customer_id":self.mCustomerId]) { response , status in
            CommonClass.stopLoader()
            if status {
                if let mData = response.value(forKey: "data") as? NSArray {
                    if mData.count > 0 {
                        
                        self.mMasterData = mData
                        self.mQuotedData = mData
                        
                        self.mTableView.showsVerticalScrollIndicator = false
                        self.mTableView.delegate = self
                        self.mTableView.dataSource = self
                        self.mTableView.reloadData()
                        
                        let mCustom = NSMutableArray()
                        let mRepair = NSMutableArray()
                        for i in self.mMasterData {
                            if let mData = i as? NSDictionary {
                                if mData.value(forKey: "type") as? String ?? "" == "custom_order" || mData.value(forKey: "type") as? String ?? "" == "mix_and_match"  {
                                    mCustom.add(mData)
                                }else{
                                    mRepair.add(mData)
                                }
                            }
                        }
                        
                        self.mAllItems.text = "All".localizedString + " (\(self.mMasterData.count))"
                        self.mLaybytems.text = "Custom Order".localizedString + " (\(mCustom.count))"
                        self.mInstallmentItems.text = "Repair".localizedString + " (\(mRepair.count))"
                        
                    }else{
                        self.mMasterData = mData
                        self.mQuotedData = mData
                        self.mTableView.showsVerticalScrollIndicator = false
                        self.mTableView.delegate = self
                        self.mTableView.dataSource = self
                        self.mTableView.reloadData()
                        self.mAllItems.text = "All".localizedString + " (0)"
                        self.mLaybytems.text = "Custom Order".localizedString + " (0)"
                        self.mInstallmentItems.text = "Repair".localizedString + " (0)"
                        
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
            self.mQuotedData = mMasterData
            self.mTableView.reloadData()
        }else {
            let mSearchData = NSMutableArray()
            for i in mMasterData {
                if let mData = i as? NSDictionary {
                    let serachKey = (sender.text ?? "").lowercased()
                    let vrNo = (mData.value(forKey: "vr_no") as? String ?? "").lowercased()
                    let customerName = (mData.value(forKey: "customer_name") as? String ?? "").lowercased()
                    if vrNo.contains(serachKey) || customerName.contains(serachKey) {
                        mSearchData.add(mData)
                    }
                }
            }
            if mSearchData.count > 0 {
                self.mQuotedData = NSArray(array: mSearchData)
                self.mTableView.reloadData()
            }else{
                self.mQuotedData = mMasterData
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
            self.mQuotedData = mMasterData
            self.mTableView.reloadData()
        }else {
            var mSearchData = NSMutableArray()
            for i in mMasterData {
                if let mData = i as? NSDictionary {
                    let searchKey = value.lowercased()
                    let vrNo = (mData.value(forKey: "vr_no") as? String ?? "").lowercased()
                    let customerName = (mData.value(forKey: "customer_name") as? String ?? "").lowercased()
                    if vrNo.contains(searchKey) || customerName.contains(searchKey) {
                        mSearchData.add(mData)
                    }
                }
            }
            if mSearchData.count > 0 {
                self.mQuotedData = NSArray(array: mSearchData)
                self.mTableView.reloadData()
            }else{
                self.mQuotedData = mMasterData
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
        self.mQuotedData = self.mMasterData
        self.mTableView.reloadData()
        
    }
    
    @IBAction func mSelectLayby(_ sender: Any) {
        
        mAllItems.textColor = UIColor(named:"themeExtraLightText")
        mAllLine.backgroundColor = UIColor(named:"themeExtraLightText")
        
        mLaybytems.textColor = UIColor(named:"themeLightText")
        mLaybyLine.backgroundColor = UIColor(named:"themeColor")
        
        mInstallmentItems.textColor = UIColor(named:"themeExtraLightText")
        mInstallmentLine.backgroundColor = UIColor(named:"themeExtraLightText")
        
        mFilterCustom(custom: "custom_order", mixMatch: "mix_and_match")
        
        
    }
    
    @IBAction func mSelectInstallments(_ sender: Any) {
        mAllItems.textColor = UIColor(named:"themeExtraLightText")
        mAllLine.backgroundColor = UIColor(named:"themeExtraLightText")
        mLaybytems.textColor = UIColor(named:"themeExtraLightText")
        mLaybyLine.backgroundColor = UIColor(named:"themeExtraLightText")
        mInstallmentItems.textColor = UIColor(named:"themeLightText")
        mInstallmentLine.backgroundColor = UIColor(named:"themeColor")
        mFilter(type:"repair_order")
    }
    
    func mFilter(type:String) {
        var mItems = NSMutableArray()
        for i in mMasterData {
            if let mData = i as? NSDictionary {
                if mData.value(forKey: "type") as? String ?? "" == type {
                    mItems.add(mData)
                }
            }
        }
        self.mQuotedData = NSArray(array: mItems)
        self.mTableView.reloadData()
    }
    
    func mFilterCustom(custom:String, mixMatch:String) {
        var mItems = NSMutableArray()
        for i in mMasterData {
            if let mData = i as? NSDictionary {
                if mData.value(forKey: "type") as? String ?? "" == custom || mData.value(forKey: "type") as? String ?? "" == mixMatch {
                    mItems.add(mData)
                }
            }
        }
        self.mQuotedData = NSArray(array: mItems)
        self.mTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if mQuotedData.count == 0 {
            tableView.setError("No items found!")
        }else{
            tableView.clearBackground()
        }
        return mQuotedData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "QuotationItems") as? QuotationItems else {
            return UITableViewCell()
        }
        
        if let mData = mQuotedData[indexPath.row] as? NSDictionary {
            cell.mDate.text = mData.value(forKey: "date") as? String ?? "--"
            cell.mOrderId.text = mData.value(forKey: "quo_no") as? String ?? "--"
            
            if mData.value(forKey: "type") as? String ?? "" == "custom_order" {
                cell.mType.text = "Custom Order".localizedString
                cell.mType.textColor = #colorLiteral(red: 0.9137254902, green: 0.4392156863, blue: 0.4392156863, alpha: 1)
            }else if mData.value(forKey: "type") as? String ?? "" == "mix_and_match" {
                cell.mType.text = "Mix & Match".localizedString
                cell.mType.textColor = #colorLiteral(red: 0.9137254902, green: 0.4392156863, blue: 0.4392156863, alpha: 1)
            }else if mData.value(forKey: "type") as? String ?? "" == "repair_order" {
                cell.mType.text = "Repair".localizedString
                cell.mType.textColor = #colorLiteral(red: 0.662745098, green: 0.6078431373, blue: 0.7411764706, alpha: 1)
                
            }
            cell.mDueDate.text = "\(mData.value(forKey: "duedate") ?? "--")"
            
            cell.mLocationName.text = "\(mData.value(forKey: "location") ?? "Siam Paragon")"
            cell.mCustomerName.text = mData.value(forKey: "customer_name") as? String ?? "--"
            cell.mCusttomerImage.downlaodImageFromUrl(urlString: mData.value(forKey: "profile") as? String ?? "--")
            cell.mCustomerMobile.text = mData.value(forKey: "customer_contact") as? String ?? "--"
            cell.mViewQuotedItems.tag = indexPath.row
            cell.mQuotedItemsLABEL.text = "Quoted Items".localizedString
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.mIndexValue = indexPath.row
        mConfirmationPopUp.frame = self.view.bounds
        mConfirmationPopUp.delegate = self
        mConfirmationPopUp.mMessage.text = "Are you sure want to add to order ?".localizedString
        
        
        mConfirmationPopUp.mCancelButton.setTitle("CANCEL".localizedString, for: .normal)
        mConfirmationPopUp.mConfirmButton.setTitle("CONFIRM".localizedString, for: .normal)
        
        self.view.addSubview(mConfirmationPopUp)
        
    }
    
    func isProceed(status: Bool) {
        if status {
            if let mData = mQuotedData[mIndexValue] as? NSDictionary {
                let mQuotationId = mData.value(forKey: "id") as? String ?? ""
                if mData.value(forKey: "type") as? String ?? "" == "custom_order" {
                    let storyBoard: UIStoryboard = UIStoryboard(name: "customOrder", bundle: nil)
                    if let mCustomCart = storyBoard.instantiateViewController(withIdentifier: "CustomCart") as? CustomCart {
                        mCustomCart.isQuotation = true
                        mCustomCart.mQuotationId = mQuotationId
                        self.navigationController?.pushViewController(mCustomCart, animated:true)
                    }
                }else if mData.value(forKey: "type") as? String ?? "" == "mix_and_match" {
                    let storyBoard: UIStoryboard = UIStoryboard(name: "mixNMatch", bundle: nil)
                    if let mMixMatchCart = storyBoard.instantiateViewController(withIdentifier: "MixMatchCart") as? MixMatchCart {
                        mMixMatchCart.mKey = "1"
                        mMixMatchCart.isQuotation = true
                        mMixMatchCart.mQuotationId = mQuotationId
                        self.navigationController?.pushViewController(mMixMatchCart, animated:true)
                    }
                }else if mData.value(forKey: "type") as? String ?? "" == "repair_order" {
                    let storyBoard: UIStoryboard = UIStoryboard(name: "moreBoard", bundle: nil)
                    if let mCustomCart = storyBoard.instantiateViewController(withIdentifier: "RepairOrderController") as? RepairOrderController {
                        mCustomCart.isQuotation = true
                        mCustomCart.mQuotationId = mQuotationId
                        self.navigationController?.pushViewController(mCustomCart, animated:true)
                    }
                }
            }
        }
        
    }
    func mGetItems(id: String, type: String) {
        let mQuotationId = id
        if type == "custom_order" {
            let storyBoard: UIStoryboard = UIStoryboard(name: "customOrder", bundle: nil)
            if let mCustomCart = storyBoard.instantiateViewController(withIdentifier: "CustomCart") as? CustomCart {
                mCustomCart.isQuotation = true
                mCustomCart.mQuotationId = mQuotationId
                self.navigationController?.pushViewController(mCustomCart, animated:true)
            }
        }else if type == "mix_and_match" {
            let storyBoard: UIStoryboard = UIStoryboard(name: "mixNMatch", bundle: nil)
            if let mMixMatchCart = storyBoard.instantiateViewController(withIdentifier: "MixMatchCart") as? MixMatchCart {
                mMixMatchCart.mKey = "1"
                mMixMatchCart.isQuotation = true
                mMixMatchCart.mQuotationId = mQuotationId
                self.navigationController?.pushViewController(mMixMatchCart, animated:true)
            }
        }else if type == "repair_order" {
            let storyBoard: UIStoryboard = UIStoryboard(name: "moreBoard", bundle: nil)
            if let mCustomCart = storyBoard.instantiateViewController(withIdentifier: "RepairOrderController") as? RepairOrderController {
                mCustomCart.isQuotation = true
                mCustomCart.mQuotationId = mQuotationId
                self.navigationController?.pushViewController(mCustomCart, animated:true)
            }
        }
        
    }

    func isProceedWithStatus(status: Bool, message: String) {
         
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            if let mData = mQuotedData[indexPath.row] as? NSDictionary {
                CommonClass.showFullLoader(view: self.view)
                let mParams = [ "quotation_id": mData.value(forKey: "id") as? String ?? "" ]

                mGetData(url: mRemoveQuotation,headers: sGisHeaders,  params: mParams) { response , status in
                    if status {
                        if "\(response.value(forKey: "code") ?? "")" == "200" {
                            CommonClass.stopLoader()
                            self.mDeleteRow(index: indexPath.row)
                        }else{
                            
                        }
                    }
                }
            }

        }
    }
    
    func mDeleteRow(index : Int)
    {
        self.mGetAllItems()
        
    }
    func mDeleteCartItems(index: Int) {
        
        if let mData = mQuotedData[index] as? NSDictionary {
            CommonClass.showFullLoader(view: self.view)
         
            let mParams = [ "quotation_id":mData.value(forKey: "id") as? String ?? "" ]
            
            mGetData(url: mRemoveQuotation,headers: sGisHeaders,  params: mParams) { response , status in
                if status {
                    if "\(response.value(forKey: "code") ?? "")" == "200" {
                        self.mDeleteRow(index: index)
                    }else{
                        
                    }
                }
            }
        }
    }
    
    @IBAction func mRemoveCartItems(_ sender: UIButton) {
        
        if let mData = mQuotedData[sender.tag] as? NSDictionary {
            mRemovePopUp.frame = self.view.bounds
            mRemovePopUp.delegate = self
            mRemovePopUp.index = sender.tag
            mRemovePopUp.mType = "quotation"
            mRemovePopUp.mMessage.text = "Are you sure want to remove ?".localizedString
            mRemovePopUp.mCancelButton.setTitle("CANCEL".localizedString, for: .normal)
            mRemovePopUp.mConfirmButton.setTitle("CONFIRM".localizedString, for: .normal)
            self.view.addSubview(mRemovePopUp)
        }
    }
    
    @IBAction func mViewQuotedItems(_ sender: UIButton) {
        if let mData = mQuotedData[sender.tag] as? NSDictionary {
            let storyBoard: UIStoryboard = UIStoryboard(name: "quotation", bundle: nil)
            if let mQuotedItems = storyBoard.instantiateViewController(withIdentifier: "QuotedItems") as? QuotedItems {
                mQuotedItems.transitioningDelegate = self
                mQuotedItems.mId = "\(mData.value(forKey: "id") ?? "")"
                mQuotedItems.delegate = self
                if mData.value(forKey: "type") as? String ?? "" == "custom_order" {
                    mQuotedItems.mType = "Custom Order"
                }else if mData.value(forKey: "type") as? String ?? "" == "mix_and_match" {
                    mQuotedItems.mType = "Mix & Match"
                }else if mData.value(forKey: "type") as? String ?? "" == "repair_order" {
                    mQuotedItems.mType = "Repair"
                    
                }
                mQuotedItems.modalPresentationStyle = .automatic
                self.present(mQuotedItems,animated: true)
            }
        }
    }
    
    
    
}
