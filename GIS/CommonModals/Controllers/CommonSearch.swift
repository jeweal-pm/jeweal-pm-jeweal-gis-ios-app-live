//
//  CommonSearch.swift
//  GIS
//
//  Created by MacBook Hawkscode  on 06/04/23.
//  Copyright © 2023 Hawkscode. All rights reserved.
//

import UIKit
import Alamofire

protocol SearchDelegate {
//    func mGetSearchItems(id : String)
//    func mGetSearchItems(id: String, locationId: String)
    func mGetSearchItems(
        id: String,
        locationId: String,
        type: String
    )
}

 class CommonSearchCell: UITableViewCell {
     
    @IBOutlet weak var mStatus: UILabel!
    @IBOutlet weak var mQuantity: UILabel!
    @IBOutlet weak var mStockId: UILabel!
    @IBOutlet weak var mDesignView: UIView!
    @IBOutlet weak var mView: UIView!
    @IBOutlet weak var mStockName: UILabel!
    @IBOutlet weak var mAmount: UILabel!
    
}
 
class CommonSearch: UIViewController, UITableViewDelegate , UITableViewDataSource, ScannerDelegate, UIViewControllerTransitioningDelegate {

    var delegate: SearchDelegate? = nil
    var delegateCatalog: GetCatalogData? = nil

    
    var mCartData = NSMutableArray()
    var mCustomerId = ""
    
    @IBOutlet weak var mProductSearch: UITextField!
    
    var mSearchData = NSMutableArray()
    
    @IBOutlet weak var mCustomSearchTable: UITableView!
    
    @IBOutlet weak var mHeader: UILabel!
    var mType = ""
    var mFrom = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
        if mType == "inventory" {
            mHeader.text = "Inventory".localizedString
        }else if mType == "catalog" {
            mHeader.text = "Catalog".localizedString
        }
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        mProductSearch.placeholder = "Search by SKU / Stock Id".localizedString
        
        self.mSearchProductByKeys(value:"")

    }
    
    
    @IBAction func mOpenScanner(_ sender: Any) {
        
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
        mSearchProductByKeys(value: value)
    }
    
    
    
    
    @IBAction func mBack(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
       
        if  mSearchData.count == 0 {
            tableView.setError("No items found!")
        }else{
            tableView.clearBackground()
        }
        return mSearchData.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false

        
        var cell  = UITableViewCell()
 
        if let mData = mSearchData[indexPath.row] as? NSDictionary {
            
            if mType == "inventory" {
                
                guard let  cells = tableView.dequeueReusableCell(withIdentifier: "CommonSearchCell") as? CommonSearchCell else {
                    return cell
                }
                cell = cells
                
                if let isDesign = mData.value(forKey: "is_design") as? Bool {
                    cells.mDesignView.isHidden = !isDesign
                }else{
                    cells.mDesignView.isHidden = true
                }
                
                cells.backgroundColor = (indexPath.row % 2 == 0) ? UIColor(named: "themeBackground") : #colorLiteral(red: 0.9568627451, green: 0.9568627451, blue: 0.9568627451, alpha: 1)
                
//                let mCurrency = UserDefaults.standard.string( forKey: "currencySymbol") ?? "$"
                cells.mAmount.text = "\(mData.value(forKey: "price") ?? "0.0")"
                cells.mStockName.text = "\(mData.value(forKey: "SKU") ?? "--")"
                cells.mStockId.text = "\(mData.value(forKey: "stock_id") ?? "--") "
                cells.mStatus.backgroundColor = #colorLiteral(red: 0.4588235294, green: 0.8, blue: 1, alpha: 1)
            } else {
                guard let cells = tableView.dequeueReusableCell(withIdentifier: "CustomSearchCell") as? CustomSearchCell else {
                    return cell
                }
                cell = cells
                
                cells.backgroundColor = (indexPath.row % 2 == 0) ? UIColor(named: "themeBackground") : #colorLiteral(red: 0.9568627451, green: 0.9568627451, blue: 0.9568627451, alpha: 1)
                cells.mProductName.text = "\(mData.value(forKey: "name") ?? "--")"
                
                cells.mStockName.text =  "\(mData.value(forKey: "SKU") ?? "--")"
                
                cells.mProductImage.downlaodImageFromUrl(urlString: "\(mData.value(forKey: "main_image") ?? "")")
                
            }
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if mType == "inventory"{
            return 52

        }
        return 95
        
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if mType == "inventory"{
            return 52

        }
        return 95
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
 
        print("tableView didSelectRowAt mSearchData = \(mSearchData[indexPath.row])")
        self.dismiss(animated: false)
        if let mData = mSearchData[indexPath.row] as? NSDictionary {
            
            if self.mFrom == "mixAndMatch" {
                let mCustomData = NSMutableDictionary()

                    mCustomData.setValue(
                        mData.value(forKey: "_id") ?? "",
                        forKey: "product_id"
                    )

                    mCustomData.setValue(
                        mData.value(forKey: "main_image") ?? "",
                        forKey: "main_image"
                    )

                    // Initial display: Mother SKU
                    mCustomData.setValue(
                        mData.value(forKey: "motherSku")
                            ?? mData.value(forKey: "SKU")
                            ?? "",
                        forKey: "SKU"
                    )

                    mCustomData.setValue(
                        mData.value(forKey: "name") ?? "",
                        forKey: "name"
                    )

                    self.delegateCatalog?.mGetCatalogItem(
                        data: NSDictionary(dictionary: mCustomData),
                        type: mType
                    )

                    return
            }
//            if let mProductId = mData.value(forKey: "_id") as? String {
//                self.delegate?.mGetSearchItems(id: mProductId)
//            }
            print("tableView didSelectRowAt mProductId = \(String(describing: mData.value(forKey: "_id")))")
            if let mProductId = mData.value(forKey: "_id") as? String {

                print("🚨🚨🚨 COMMON SEARCH SELECTED 🚨🚨🚨")
                print("PRODUCT ID =", mProductId)

                let locationId =
                    "\(mData.value(forKey: "location_id") ?? "")"

                print("LOCATION ID =", locationId)
                print("SEARCH TYPE =", mType)
                print("FROM =", mFrom)

                self.delegate?.mGetSearchItems(
                    id: mProductId,
                    locationId: locationId,
                    type: mType
                )
            }
//            if let mProductId = mData.value(forKey: "_id") as? String {
//
//                print("DEBUG_SELECTED_DATA =", mData)
//
//                let locationId =
//                    "\(mData.value(forKey: "location_id") ?? "")"
//
//                print("========== SEARCH SELECTION ==========")
//                print("🔥 ID =", mProductId)
//                print("🔥 SKU =", mData.value(forKey: "SKU") ?? "")
//                print("🔥 SEARCH TYPE =", self.mType)
//                print("🔥 SEARCH FROM =", self.mFrom)
//                print("🔥 LOCATION =", locationId)
//                print("======================================")
//                self.delegate?.mGetSearchItems(
//                    id: mProductId,
//                    locationId: locationId,
//                    type: self.mType
//                )
//            }
        }
       
    }
    
    @IBAction func mSearchNow(_ sender: Any) {
        if let key = mProductSearch.text {
            self.mSearchProductByKeys(value: key)
        } else {
            if mProductSearch.text == "" {
                
            }
            self.view.endEditing(true)
        }
    }
    
    func mSearchProductByKeys(value: String){

        
        let location = UserDefaults.standard.string(forKey: "location") ?? ""

        var params = [String:Any]()
         
//        params = ["search": value, "type":mType, "from" : mFrom]
        params = [
            "search": value,
            "type": mType,
            "from": mFrom,
            "page": 1,
            "limit": 20
        ]

        
        print("========== COMMON SEARCH REQUEST ==========")
        print("🔥 SEARCH =", value)
        print("🔥 TYPE =", mType)
        print("🔥 FROM =", mFrom)
        print("🔥 LOCATION =", location)
        print("🔥 PARAMS =", params)
        print("===========================================")
        
        if Reachability.isConnectedToNetwork() == true {
            AF.request(mCommonSearchAPI, method:.post, parameters:params, headers: sGisHeaders2).responseJSON
            { response in
                
                print("========== COMMON SEARCH RESPONSE ==========")
                print("🔥 RESPONSE =", response)
                print("============================================")
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
                
                if jsonResult.value(forKey: "code") as? Int == 200 {
                    self.mSearchData = NSMutableArray()
                    if let mData = jsonResult.value(forKey: "data") as? NSArray {
                        
                        if mData.count > 0 {
                            
                            self.mSearchData =  NSMutableArray(array: mData)
                            self.mCustomSearchTable.delegate = self
                            self.mCustomSearchTable.dataSource = self
                            self.mCustomSearchTable.reloadData()
                            
                        }else{
                            self.mSearchData = NSMutableArray()
                            self.mCustomSearchTable.reloadData()
                        }
                        
                    }else{
                        self.mSearchData = NSMutableArray()
                        self.mCustomSearchTable.reloadData()
                    }
                    
                }else{
                    self.mSearchData = NSMutableArray()
                    self.mCustomSearchTable.reloadData()
                    if let error = jsonResult.value(forKey: "error") as? String {
                        if error == "Authorization has been expired" {
                            CommonClass.sessionExpired(isExpired: true, navigation: self.navigationController)
                        }
                    }
                }
                
                
            }
        }else{
        }


     }


    
    func mAddProducts(productId: String , po_product: String){

        mCartData =  NSMutableArray()
        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
        let mLocation = UserDefaults.standard.string(forKey: "location") ?? ""
        let mData = NSMutableDictionary()
        mData.setValue(productId, forKey: "product_id")
        mData.setValue(po_product, forKey: "po_product_id")
        mData.setValue("", forKey: "transaction_stock_id")
        
       
        mCartData.add(mData)
    
        
         let urlPath =  mAddCustomProduct
        var params = [String:Any]()
        
        
        if mType == "Inventory" {
            params = ["login_token":mUserLoginToken ?? "","cartData": self.mCartData , "location_id":mLocation,"type":"Sales Order"] as [String : Any]
        }else{
            
            params = ["login_token":mUserLoginToken ?? "","cartData": self.mCartData , "location_id":mLocation,"type":"Custom Order"] as [String : Any]

        }
        
        if Reachability.isConnectedToNetwork() == true {
            AF.request(urlPath, method:.post, parameters:params,encoding: JSONEncoding.default, headers: sGisHeaders2).responseJSON
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
                
                if jsonResult.value(forKey: "code") as? Int == 200 {
                    CommonClass.showSnackBar(message: "\(jsonResult.value(forKey: "message") ?? "")")
                    
                    if self.mType == "Custom Order" {
                        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        
                        if let mCustomOrder = storyBoard.instantiateViewController(withIdentifier: "CustomOrder") as? CustomOrder {

                            self.navigationController?.pushViewController(mCustomOrder, animated:true)
                        }
                    }else{
                        self.navigationController?.popViewController(animated: true)
                    }
                }else{
                    if let error = jsonResult.value(forKey: "error") as? String {
                        if error == "Authorization has been expired" {
                            CommonClass.sessionExpired(isExpired: true, navigation: self.navigationController)
                        }
                    }
                }
            }
        }else{
            CommonClass.showSnackBar(message: "No Internet Connection")
        }


     }

}
