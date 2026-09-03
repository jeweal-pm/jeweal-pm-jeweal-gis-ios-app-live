//
//  CustomOrderSearch.swift
//  GIS
//
//  Created by Apple Hawkscode on 24/05/21.
//

import UIKit
import Alamofire

public class CustomSearchCell: UITableViewCell {
    
    @IBOutlet weak var mView: UIView!
    @IBOutlet weak var mLocationQty: UILabel!
    @IBOutlet weak var mProductName: UILabel!
    @IBOutlet weak var mProductImage: UIImageView!
    @IBOutlet weak var mStockName: UILabel!
    public override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func imageTapGesture(target: Any, action: Selector) {
        let tapGesture = UITapGestureRecognizer(target: target, action: action)
        mProductImage.isUserInteractionEnabled = true
        mProductImage.addGestureRecognizer(tapGesture)
    }
    
}
class CustomOrderSearch: UIViewController, UITableViewDelegate , UITableViewDataSource {

    var mCartData = NSMutableArray()
    var mCustomerId = ""
    @IBOutlet weak var mProductSearch: UITextField!
    var mSearchData = NSMutableArray()
    @IBOutlet weak var mCustomSearchTable: UITableView!
    
    @IBOutlet weak var mHeader: UILabel!
    var mType = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        mHeader.text = mType.localizedString
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        mProductSearch.placeholder = "Search".localizedString
        
    }
    
    
    
    @IBAction func mBack(_ sender: Any) {
        self.navigationController?.popViewController(animated:true)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
       
        return mSearchData.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false

        
        var cell  = UITableViewCell()
        
        guard let cells = tableView.dequeueReusableCell(withIdentifier: "CustomSearchCell") as? CustomSearchCell else {
            return cell
        }
        cell = cells
        
        if let mData = mSearchData[indexPath.row] as? NSDictionary {
            
            cells.backgroundColor = (indexPath.row % 2 == 0) ? UIColor(named: "themeBackground") : #colorLiteral(red: 0.9568627451, green: 0.9568627451, blue: 0.9568627451, alpha: 1)
            
            cells.mProductName.text = "\(mData.value(forKey: "name") ?? "--")"
            if self.mType == "Inventory" {
                cells.mStockName.text = "\(mData.value(forKey: "stock_id") ?? "--") " + "\(mData.value(forKey: "SKU") ?? "--")"
            }else{
                cells.mStockName.text = "\(mData.value(forKey: "SKU") ?? "--")"
            }
            
            cells.mProductImage.downlaodImageFromUrl(urlString: "\(mData.value(forKey: "main_image") ?? "")")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 95
        
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let mData = mSearchData[indexPath.row] as? NSDictionary {
            if mType == "Inventory" {
                if let productId = mData.value(forKey: "product_id") as? String,
                   let poProductId = mData.value(forKey: "po_product_id") as? String {
                    
                    mAddProducts(productId: productId, po_product: poProductId)
                }
            } else if mType == "Quick View" {
                let storyBoard: UIStoryboard = UIStoryboard(name: "Test", bundle: nil)
                if let mQuickView = storyBoard.instantiateViewController(withIdentifier: "QuickView") as? QuickView {
                    
                    mQuickView.mType = "Quick View"
                    if let SKUName = mData.value(forKey: "SKU") as? String {
                        mQuickView.mSKUName = SKUName
                    }
                    if let stockIds = mData.value(forKey: "stock_id") as? String {
                        mQuickView.mStockIds = stockIds
                    }
                    if let imageData = mData.value(forKey: "main_image") as? [String] {
                        mQuickView.mImageData = imageData
                    }
                    self.navigationController?.pushViewController(mQuickView, animated: true)
                }
            } else {
                if let productId = mData.value(forKey: "products_id") as? String,
                   let poProductId = mData.value(forKey: "Po_products_id") as? String {
                    
                    mAddProducts(productId: productId, po_product: poProductId)
                }
            }
        }
    }
    
    @IBAction func mSearchNow(_ sender: Any) {
        let value = mProductSearch.text?.count
        if value != 0 {
            self.mSearchProductByKeys(value: mProductSearch.text ?? "")
        }else {

            if mProductSearch.text == "" {
                
            }
            self.view.endEditing(true)
        }
    }
    
    func mSearchProductByKeys(value: String){
        
        let mLocation = UserDefaults.standard.string(forKey: "location") ?? ""
        
        var urlPath = ""
        var params = [String:Any]()
        
        if mType == "Inventory" {
            urlPath =  mPOSSearch
            params = ["key": value,"POS_Location_id":mLocation, "type":"pos"]
            
        } else if mType == "Quick View"{
            urlPath =  mQuickViewSearch
            params = ["search": value,"posLocation_id":mLocation]
            
        }else{
            urlPath =  mSearchProductByKey
            params = ["key": value,"posLocation_id":mLocation]
            
        }
        
        print("========== COMMON SEARCH REQUEST ==========")
            print("🔥 SEARCH =", value)
            print("🔥 TYPE =", mType)
            print("🔥 VALUE =", value)
            print("🔥 LOCATION =", mLocation)
            print("🔥 PARAMS =", params)
            print("===========================================")
        
        if Reachability.isConnectedToNetwork() == true {
            AF.request(urlPath, method:.post, parameters:params, headers: sGisHeaders2).responseJSON
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
                    if let mData = jsonResult.value(forKey: "list") as? NSArray {
                        
                        if mData.count > 0 {
                            
                            if self.mType == "Inventory" {
                                self.mSearchData = NSMutableArray()
                                
                                for data in mData {
                                    if let mDatas = data as? NSDictionary {
                                        
                                        if "\(mDatas.value(forKey: "Customer_id") ?? "")" == self.mCustomerId {
                                            self.mSearchData.add(mDatas)
                                        }else{
                                            if mDatas.value(forKey: "productStatus") == nil {
                                                self.mSearchData.add(mDatas)
                                            }
                                        }
                                    }
                                }
                                
                                self.mCustomSearchTable.delegate = self
                                self.mCustomSearchTable.dataSource = self
                                self.mCustomSearchTable.reloadData()
                            }else{
                                self.mSearchData =  NSMutableArray(array: mData)
                                self.mCustomSearchTable.delegate = self
                                self.mCustomSearchTable.dataSource = self
                                self.mCustomSearchTable.reloadData()
                            }
                            
                        }else{
                            self.mSearchData = NSMutableArray()
                            self.mCustomSearchTable.reloadData()
                        }
                        
                        
                    }else{
                        self.mSearchData = NSMutableArray()
                        self.mCustomSearchTable.reloadData()
                    }
                    
                } else {
                    if let error = jsonResult.value(forKey: "error") as? String, error == "Authorization has been expired" {
                        CommonClass.sessionExpired(isExpired: true, navigation: self.navigationController)
                    } else {
                        CommonClass.showSnackBar(message: "Error! \(jsonResult.value(forKey: "code") ?? "Unknown Error")")
                    }
                }
                
            }
        }else{
        }


    }


    
    func mAddProducts(productId: String , po_product: String){

        mCartData =  NSMutableArray()
        
        let mLocation = UserDefaults.standard.string(forKey: "location") ?? ""
        var mData = NSMutableDictionary()
        mData.setValue(productId, forKey: "product_id")
        mData.setValue(po_product, forKey: "po_product_id")
        mData.setValue("", forKey: "transaction_stock_id")
        
       print("CustomOrderSearch mAddProducts")
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
                    if let message = jsonResult.value(forKey: "message") {
                        CommonClass.showSnackBar(message: "\(message)")
                    }
                    
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
