//
//  CommonServiceLabour.swift
//  GIS
//
//  Created by Macbook Pro on 24/07/23.
//  Copyright © 2023 Hawkscode. All rights reserved.
//

import UIKit
import Alamofire

protocol ServiceLabourDelegate {
    func mRemoveServiceLabour()
    func mConfirmServiceLabour(data: NSDictionary)
}
class ServiceLabourItems:UITableViewCell {

    @IBOutlet weak var mCurrency: UILabel!
    @IBOutlet weak var mCode: UILabel!
    @IBOutlet weak var mName: UILabel!
    @IBOutlet weak var mAmount: UITextField!
    @IBOutlet weak var mView: UIView!
    @IBOutlet weak var mCheckUncheckButton: UIButton!
    @IBOutlet weak var mCheckIcon: UIImageView!
    @IBOutlet weak var mCheckView: UIView!
}
class CommonServiceLabour: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var mStockId: UILabel!
    @IBOutlet weak var mProductImage: UIImageView!
    @IBOutlet weak var mSKU: UILabel!
    @IBOutlet weak var mProductName: UILabel!
    @IBOutlet weak var mMetalName: UILabel!
    @IBOutlet weak var mSizeName: UILabel!
    @IBOutlet weak var mStoneName: UILabel!
    @IBOutlet weak var mCollectionName: UILabel!
    @IBOutlet weak var mTableView: UITableView!
    @IBOutlet weak var mConfirmButton: UIButton!
    
    @IBOutlet weak var mSizeLABEL: UILabel!
    @IBOutlet weak var mCollectionLABEL: UILabel!
    @IBOutlet weak var mStoneLABEL: UILabel!
    @IBOutlet weak var mMetalLABEL: UILabel!
    @IBOutlet weak var mServiceLabourHeadingLABEL: UILabel!
    @IBOutlet weak var mServiceLabourLABEL: UILabel!
    @IBOutlet weak var mRemoveAllLABEL: UILabel!
    
    @IBOutlet weak var mRemoveLabourButton: UIButton!
    @IBOutlet weak var mRemoveView: UIView!
    @IBOutlet weak var mRemarks: UITextField!
    var mMasterData  = NSMutableArray()
    var mTempData  = NSMutableArray()

    var mSelectedIndex = [String]()
    var mSelectedAmount = [String]()
    var mResetData = NSArray()
    var mProductData = NSDictionary()
    var mProductPrice = Double()
    var mCartId = ""
    var isEnabledService = false
    var delegate:ServiceLabourDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
        mRemoveLabourButton.setTitle("REMOVE".localizedString, for: .normal)
        mConfirmButton.setTitle("CONFIRM".localizedString, for: .normal)
        mRemoveAllLABEL.text = "Remove All".localizedString
        mServiceLabourLABEL.text = "Service Labour".localizedString
        mRemarks.placeholder = "Remarks".localizedString
        mServiceLabourHeadingLABEL.text = "Service Labour".localizedString
        mMetalLABEL.text = "Metal".localizedString
        mSizeLABEL.text = "Size".localizedString
        mCollectionLABEL.text = "Collection".localizedString
        mStoneLABEL.text = "Stone".localizedString
        
        self.mRemoveView.isHidden = true
        self.mConfirmButton.isHidden = true
        mTableView.separatorColor = .clear
        if let mServiceData = UserDefaults.standard.object(forKey: "SERVICE_LABOUR") as? NSDictionary {
            if  let mResults = mServiceData.value(forKey: "data") as? NSDictionary {
                if let mData = mResults.value(forKey: "ServiceLabour") as? NSArray{
                    if mData.count > 0 {
                        self.mResetData = mData
                        self.mSetData(mData: mData)
                    }
                }
            }
        }else{
            mGetServiceLabour()
        }
        mSetJelwelryDetails()
        
        let tapGesture = UITapGestureRecognizer(
                target: self,
                action: #selector(dismissKeyboard)
            )

        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
     }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func mSetJelwelryDetails(){
        self.mProductImage.downlaodImageFromUrl(urlString: self.mProductData.value(forKey: "main_image") as? String ?? "")
        self.mProductName.text = self.mProductData.value(forKey: "name") as? String ?? "--"
        self.mCartId = self.mProductData.value(forKey: "custom_cart_id") as? String ?? "--"
        self.mSKU.text = self.mProductData.value(forKey: "SKU") as? String ?? "--"
        self.mStoneName.text = self.mProductData.value(forKey: "stone_name") as? String ?? "--"
        if(self.mStoneName.text == ""){self.mStoneName.text = "--"}
//        self.mCollectionName.text = self.mProductData.value(forKey: "") as? String ?? "--"
//        self.mCollectionName.text = self.mProductData.value(forKey: "collection_name") as? String ?? "--"
        self.mCollectionName.text = "\(self.mProductData["collection_name"] ?? self.mProductData["Collection_name"] ?? "--")"
        self.mSizeName.text = self.mProductData.value(forKey: "size_name") as? String ?? "--"
        self.mMetalName.text = self.mProductData.value(forKey: "metal_name") as? String ?? "--"
        self.mStockId.text = self.mProductData.value(forKey: "stock_id") as? String ?? "--"
        if let mServiceStatus = self.mProductData.value(forKey: "Service_labour_exsist") as? Bool {
            self.isEnabledService = mServiceStatus
            if mServiceStatus {
                self.mRemoveLabourButton.isHidden = false
                if let mServiceLabour = self.mProductData.value(forKey: "Service_labour") as? NSDictionary {
                    self.mProductPrice = Double("\(mServiceLabour.value(forKey: "product_price") ?? "0.00")") ?? 0.00
                    self.mRemarks.text = "\(mServiceLabour.value(forKey: "service_remark") ?? "")"
                    if let mServiceItem = mServiceLabour.value(forKey: "service_laburelist") as? NSArray {
                        let mMaster = self.mMasterData
                        self.mMasterData = NSMutableArray()
                        for i in mMaster
                       {
                            let mItems = NSMutableDictionary()
                             if let serviceData = i as? NSDictionary{
                                var isExist = false
                                 var mAmount = 0.0
                                 for j in mServiceItem {
                                     if let savedData = j as? NSDictionary {
                                         if savedData.value(forKey: "id") as? String ?? "" == serviceData.value(forKey: "id") as? String ?? "" {
                                                 mItems.setValue(savedData.value(forKey: "id") as? String ?? "", forKey: "id")
                                                 mItems.setValue(true, forKey: "isSelected")
                                                 mItems.setValue(savedData.value(forKey: "code") as? String ?? "", forKey: "code")
                                                 mItems.setValue(savedData.value(forKey: "name") as? String ?? "", forKey: "name")
                                                 mItems.setValue(Double("\(savedData.value(forKey: "scrviceamount") ?? "0.00")") ?? 0.00, forKey: "scrviceamount")
                                         
                                             self.mMasterData.add(mItems)
                                             isExist = true
                                             break
                                        }
                                     }
                                 }
                             
                                 if !isExist {
                                     mItems.setValue(serviceData.value(forKey: "id") as? String ?? "", forKey: "id")
                                     mItems.setValue(false, forKey: "isSelected")
                                     mItems.setValue(serviceData.value(forKey: "code") as? String ?? "", forKey: "code")
                                     mItems.setValue(serviceData.value(forKey: "name") as? String ?? "", forKey: "name")
                                     mItems.setValue("", forKey: "scrviceamount")
                                     self.mMasterData.add(mItems)
                                 }else{
                                     if self.mSelectedIndex.contains(serviceData.value(forKey: "id") as? String ?? "") {
                                         self.mSelectedIndex = mSelectedIndex.filter {$0 != serviceData.value(forKey: "id") as? String ?? "" }
                                     }else{
                                         self.mSelectedIndex.append(serviceData.value(forKey: "id") as? String ?? "")
                                     }
                                 }
                                 self.mTableView.reloadData()
                             }
                        }
                    }
                }else{
                    self.mRemoveLabourButton.isHidden = true
                    self.mProductPrice = Double("\(self.mProductData.value(forKey: "cart_price") ?? "0.00")") ?? 0.00
                }
            }else{
                self.mRemoveLabourButton.isHidden = true
                self.mProductPrice = Double("\(self.mProductData.value(forKey: "cart_price") ?? "0.00")") ?? 0.00
            }
        }else{
            self.mRemoveLabourButton.isHidden = true
            self.mProductPrice = Double("\(self.mProductData.value(forKey: "cart_price") ?? "0.00")") ?? 0.00
        }

    }
    
    func mSetData(mData: NSArray){
        
        self.mMasterData = NSMutableArray()
        for i in mData {
           let mItems = NSMutableDictionary()
            if let serviceData = i as? NSDictionary{
                mItems.setValue(serviceData.value(forKey: "id") as? String ?? "", forKey: "id")
                mItems.setValue(false, forKey: "isSelected")
                mItems.setValue(serviceData.value(forKey: "code") as? String ?? "", forKey: "code")
                mItems.setValue(serviceData.value(forKey: "name") as? String ?? "", forKey: "name")
                mItems.setValue("", forKey: "scrviceamount")
                self.mMasterData.add(mItems)
                
            }
        }
         self.mTempData = NSMutableArray(array: mData)
        self.mTableView.delegate = self
        self.mTableView.dataSource = self
        self.mTableView.reloadData()
    }
    
    func mGetServiceLabour() {
       
        let mParamService = ["query":"{ServiceLabour{id code name}}"]
        AF.request(mGrapQlUrl, method:.post,parameters: mParamService, encoding:JSONEncoding.default, headers: sGisHeaders ).responseJSON
                { response in
                    
                    guard response.error == nil else {
                        CommonClass.showSnackBar(message: "OOP's something went wrong!")
                        return
                    }
                    
                    guard let jsonData = response.data else {
                        CommonClass.showSnackBar(message: "OOP's something went wrong!")
                        return
                    }
                    
                    let json = try? JSONSerialization.jsonObject(with: jsonData, options: [])
                    
                    guard let jsonResult = json as? NSDictionary else {
                        CommonClass.showSnackBar(message: "OOP's something went wrong!")
                        return
                    }
                    
                    UserDefaults.standard.set(jsonResult, forKey: "SERVICE_LABOUR")
                    if  let mResults = jsonResult.value(forKey: "data") as? NSDictionary {
                        if let mData = mResults.value(forKey: "ServiceLabour") as? NSArray{
                            if mData.count > 0 {
                                self.mResetData = mData
                                self.mSetData(mData: mData)
                            }
                        }
                    }
            }
    }
    
    @IBAction func mBack(_ sender: Any) {
   
        self.dismiss(animated: true)
    }
    
    @IBAction func mRemove(_ sender: Any) {
        self.mSelectedIndex = [String]()
        self.mSetData(mData: mResetData)
    }
    
    
    @IBAction func mEditAmount(_ sender: UITextField) {
        let mIndex = sender.tag
        if let serviceData = mMasterData[mIndex] as? NSDictionary,
           let cells = mTableView.cellForRow(at: IndexPath(row: sender.tag , section: 0)) as? ServiceLabourItems {
            if Double(sender.text ?? "") ?? 0.00 == 0 {
                cells.mAmount.text = ""
                let mItems = NSMutableDictionary()
                mItems.setValue(serviceData.value(forKey: "id") as? String ?? "", forKey: "id")
                mItems.setValue(serviceData.value(forKey: "code") as? String ?? "", forKey: "code")
                mItems.setValue(serviceData.value(forKey: "name") as? String ?? "", forKey: "name")
                mItems.setValue(serviceData.value(forKey:"isSelected") as? Bool ?? false, forKey: "isSelected")
                mItems.setValue(Double(cells.mAmount.text ?? "") ?? 0.00, forKey: "scrviceamount")
                self.mMasterData.removeObject(at: sender.tag)
                self.mMasterData.insert(mItems, at: sender.tag)
            }else{
                let mItems = NSMutableDictionary()
                mItems.setValue(serviceData.value(forKey: "id") as? String ?? "", forKey: "id")
                mItems.setValue(serviceData.value(forKey:"isSelected") as? Bool ?? false, forKey: "isSelected")
                mItems.setValue(serviceData.value(forKey: "code") as? String ?? "", forKey: "code")
                mItems.setValue(serviceData.value(forKey: "name") as? String ?? "", forKey: "name")
                mItems.setValue(Double(cells.mAmount.text ?? "") ?? 0.00, forKey: "scrviceamount")
                self.mMasterData.removeObject(at: sender.tag)
                self.mMasterData.insert(mItems, at: sender.tag)
                
            }
        }
    }
    
    @IBAction func mCheckUncheck(_ sender: UIButton) {
        if let mData = mMasterData[sender.tag] as? NSDictionary {
            if self.mSelectedIndex.contains(mData.value(forKey: "id") as? String ?? "") {
                self.mSelectedIndex = mSelectedIndex.filter {$0 != mData.value(forKey: "id") as? String ?? "" }
                let mItems = NSMutableDictionary()
                mItems.setValue(mData.value(forKey: "id") as? String ?? "", forKey: "id")
                mItems.setValue(mData.value(forKey: "code") as? String ?? "", forKey: "code")
                mItems.setValue(mData.value(forKey: "name") as? String ?? "", forKey: "name")
                mItems.setValue("", forKey: "scrviceamount")
                mItems.setValue(false, forKey: "isSelected")
                self.mMasterData.removeObject(at: sender.tag)
                self.mMasterData.insert(mItems, at: sender.tag)
            }else{
                self.mSelectedIndex.append(mData.value(forKey: "id") as? String ?? "")
                let mItems = NSMutableDictionary()
                mItems.setValue(mData.value(forKey: "id") as? String ?? "", forKey: "id")
                mItems.setValue(true, forKey: "isSelected")
                mItems.setValue(mData.value(forKey: "code") as? String ?? "", forKey: "code")
                mItems.setValue(mData.value(forKey: "name") as? String ?? "", forKey: "name")
                mItems.setValue(mData.value(forKey: "scrviceamount") as? Double ?? 0.00, forKey: "scrviceamount")
                self.mMasterData.removeObject(at: sender.tag)
                self.mMasterData.insert(mItems, at: sender.tag)
            }
        }
        self.mTableView.reloadData()
        
    }
    
    @IBAction func mRemoveLabour(_ sender: Any) {
        
        let mServiceLabourData = NSMutableDictionary()
            mServiceLabourData.setValue("", forKey: "service_remark")
            mServiceLabourData.setValue([], forKey: "service_laburelist")
        mServiceLabourData.setValue(self.mProductPrice, forKey: "product_price")
        let mParams = [ "cart_id":self.mCartId,
                        "service_saved":false,
                        "service_labour":mServiceLabourData] as [String : Any]
        CommonClass.showFullLoader(view: self.view)
        
       
        mGetData(url: mSaveServiceLabour,headers: sGisHeaders,  params: mParams) { response , status in
            CommonClass.stopLoader()
            if status {
                self.dismiss(animated: true)
                self.delegate?.mRemoveServiceLabour()
              }
        }
    }
    @IBAction func mConfirm(_ sender: Any) {
        var mSelectedData = NSMutableArray()
        var mStatus = false
        for data in mMasterData {
            if let items = data as? NSDictionary {
                if let isSelected = items.value(forKey: "isSelected") as? Bool {
                    if isSelected {
                        if Double("\(items.value(forKey: "scrviceamount") ?? "0.00")") ?? 0.00 == 0 {
                            mSelectedData = NSMutableArray()
                            CommonClass.showSnackBar(message: "Please fill amount!")
                            break
                        }else{
                            let mItems = NSMutableDictionary()
                            mItems.setValue(items.value(forKey: "id") as? String ?? "", forKey: "id")
                            mItems.setValue(items.value(forKey: "code") as? String ?? "", forKey: "code")
                            mItems.setValue(items.value(forKey: "name") as? String ?? "", forKey: "name")
                            mItems.setValue(items.value(forKey: "scrviceamount") as? Double ?? 0.00, forKey: "scrviceamount")
                            mSelectedData.add(mItems)
                        }
                        
                        
                    }else{
                    }
                }
            }
        }
        
 
        mSelectedData.count > 0 ? (mStatus = true) : (mStatus = false)
        
        if !mStatus {
            CommonClass.showSnackBar(message: "Please select and fill valid item")
            return
        }
        let mServiceLabourData = NSMutableDictionary()
            mServiceLabourData.setValue(self.mRemarks.text ?? "", forKey: "service_remark")
            mServiceLabourData.setValue(mSelectedData, forKey: "service_laburelist")
        mServiceLabourData.setValue(self.mProductPrice, forKey: "product_price")
        
        let mParams = [ "cart_id":self.mCartId,
                        "service_saved":mStatus,
                        "service_labour":mServiceLabourData] as [String : Any]
        CommonClass.showFullLoader(view: self.view)
        
        
        mGetData(url: mSaveServiceLabour,headers: sGisHeaders,  params: mParams) { response , status in
            CommonClass.stopLoader()
            
            let mTemp = NSDictionary()
            if status {
                self.dismiss(animated: true)
                self.delegate?.mConfirmServiceLabour(data: mTemp)
            }
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         if  mMasterData.count == 0 {
             tableView.setError("No items found!")
         }else{
             tableView.clearBackground()
         }
        return mMasterData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ServiceLabourItems") as? ServiceLabourItems else {
            return UITableViewCell()
        }
        
        if let mData = mMasterData[indexPath.row] as? NSDictionary {
            cell.mCode.text = mData.value(forKey: "code") as? String ?? "--"
            cell.mName.text = mData.value(forKey: "name") as? String ?? "--"
            cell.mCurrency.text = "\(UserDefaults.standard.string(forKey: "currencySymbol") ?? "$")"
            if mData.value(forKey: "scrviceamount") as? Double ?? 0.00 == 0 {
                cell.mAmount.text = ""
            }else{
                cell.mAmount.text = "\(mData.value(forKey: "scrviceamount") as? Double ?? 0.00)"
            }
            cell.mCheckUncheckButton.tag = indexPath.row
            cell.mAmount.keyboardType = .numberPad
            cell.mAmount.tag = indexPath.row
            if (indexPath.row % 2 == 0) {
                cell.backgroundColor = UIColor(named: "themeBackground")
            }else{
                cell.backgroundColor = #colorLiteral(red: 0.9568627451, green: 0.9568627451, blue: 0.9568627451, alpha: 1)
            }
            if self.isEnabledService {
                mSelectedIndex.isEmpty ? (mRemoveLabourButton.isHidden = true)  : (mRemoveLabourButton.isHidden = false)
            }else{
                mRemoveLabourButton.isHidden = true
            }
            mSelectedIndex.isEmpty ? (mConfirmButton.isHidden = true)  : (mConfirmButton.isHidden = false)
            mSelectedIndex.isEmpty ? (mRemoveView.isHidden = true)  : (mRemoveView.isHidden = false)
            if mSelectedIndex.contains(mData.value(forKey: "id") as? String ?? "") {
                cell.mCheckIcon.image = UIImage(named: "check_item")
            }else{
                cell.mCheckIcon.image = UIImage(named: "uncheck_item")
            }
        }
        return cell
    }
    
}
