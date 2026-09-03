//
//  QuickViewSearch.swift
//  GIS
//
//  Created by MacBook Hawkscode  on 09/12/22.
//  Copyright © 2022 Hawkscode. All rights reserved.
//

import UIKit
import UIKit
import Alamofire


class QuickViewSearch: UIViewController, UITableViewDelegate , UITableViewDataSource , ScannerDelegate, UIViewControllerTransitioningDelegate {
    
    var mCartData = NSMutableArray()
    var mCustomerId = ""
    var mSiriID: String?
    @IBOutlet weak var mProductSearch: UITextField!
    
    var mSearchData = NSMutableArray()
    
    @IBOutlet weak var mCustomSearchTable: UITableView!
    
    @IBOutlet weak var mHeader: UILabel!
    var mType = "Quick View"
    
    private let speechRecongniger = SpeechRecognizer(localeIdentifier: "en-US")
    private var isSpeechRecongnitionOn = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
        
        mHeader.text = mType.localizedString
        mProductSearch.placeholder = "Search by SKU / Stock Id".localizedString
        mSearchProductByKeys(value: mSiriID ?? "")
        
        if let siriID = mSiriID, !siriID.isEmpty {
             mSearchProductByKeys(value: siriID)
            mProductSearch.text = siriID
             
        } else {
             mSearchProductByKeys(value: "")
            mProductSearch.text = ""
         }
        
    }
    
         override func viewWillAppear(_ animated: Bool) {
                
             if let siriID = mSiriID, !siriID.isEmpty {
                  mSearchProductByKeys(value: siriID)
                 mProductSearch.text = siriID
                  
             } else {
                  mSearchProductByKeys(value: "")
                 mProductSearch.text = ""
              }
        
    }
    
    
    @IBAction func mOpenScanner(_ sender: Any) {
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "transactions", bundle: nil)
        if let mCommonScanner = storyBoard.instantiateViewController(withIdentifier: "CommonScanner") as? CommonScanner {
            mCommonScanner.delegate =  self
            mCommonScanner.mType = "itemSearch"
            mCommonScanner.modalPresentationStyle = .overFullScreen
            mCommonScanner.transitioningDelegate = self
            self.present(mCommonScanner,animated: true)
        }
    }
    
    func mGetScannedData(value: String, type: String) {
        mSearchProductByKeys(value:value)
        
    }
    
    
    @IBAction func mBack(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "reserveBoard", bundle: nil)
        if let home = storyBoard.instantiateViewController(withIdentifier: "HomePage1") as? HomePage {
            self.navigationController?.pushViewController(home, animated:true)
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if mSearchData.count == 0 {
            tableView.setError("No items found!".localizedString)
        }else{
            tableView.clearBackground()
        }
        return mSearchData.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        
        
        var cell  = UITableViewCell()
        
        guard let  cells = tableView.dequeueReusableCell(withIdentifier: "CustomSearchCell") as? CustomSearchCell else {
            return cell
        }
        
        cell = cells
        
        let isEvenRow = indexPath.row % 2 == 0
        cells.backgroundColor = isEvenRow ? UIColor(named: "themeBackground") : #colorLiteral(red: 0.9568627451, green: 0.9568627451, blue: 0.9568627451, alpha: 1)
        
        if let mData = mSearchData[indexPath.row] as? NSDictionary {
            cells.mProductName.text = "\(mData.value(forKey: "name") ?? "--")"
            if self.mType == "Inventory" {
                cells.mStockName.text =   "\(mData.value(forKey: "stock_id") ?? "--") " + "\(mData.value(forKey: "SKU") ?? "--")"
            }else{
                cells.mStockName.text =  "\(mData.value(forKey: "SKU") ?? "--")"
            }
            
            cells.mProductImage.downlaodImageFromUrl(urlString: "\(mData.value(forKey: "main_image") ?? "")")
//            let imageURL = "\(mData.value(forKey: "main_image") ?? "")"
//
//            print("PRODUCT CELL IMAGE URL =", imageURL)
//
//            if let url = URL(string: imageURL),
//               let scheme = url.scheme,
//               scheme == "http" || scheme == "https" {
//
//                cells.mProductImage.downlaodImageFromUrl(
//                    urlString: imageURL
//                )
//
//            } else {
//
//                print("INVALID PRODUCT CELL IMAGE URL =", imageURL)
//
//                cells.mProductImage.image = UIImage(
//                    named: "placeholder"
//                )
//            }
        }
        cells.mProductImage.tag = indexPath.row
        cells.imageTapGesture(target: self, action: #selector(handleImageTap(_:)))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 95
        
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let mData = mSearchData[indexPath.row] as? NSDictionary else { return }
        
        if mType == "Inventory" {
            mAddProducts(productId: "\(mData.value(forKey: "product_id") ?? "")",po_product: "\(mData.value(forKey: "po_product_id") ?? "")")
            
            
        }else if mType == "Quick View"{
            let storyBoard: UIStoryboard = UIStoryboard(name: "Test", bundle: nil)
            if let mQuickView = storyBoard.instantiateViewController(withIdentifier: "QuickView") as? QuickView {
                
                mQuickView.mType = "Quick View"
                mQuickView.mSKUName = "\(mData.value(forKey: "SKU") ?? "")"
                mQuickView.mSKUDetails = "\(mData.value(forKey: "name") ?? "")"
                mQuickView.mStockIds = "\(mData.value(forKey: "stock_id") ?? "")"
                mQuickView.mProductIdForImage = "\(mData.value(forKey: "_id") ?? "")"
//                var mAllImage = [String]()
//                if let image = mData.value(forKey: "main_image") as? String {
//                    mAllImage.append(image)
//                }
                
                var mAllImage = [String]()

                if let image =
                    mData.value(forKey: "main_image") as? String,
                   !image.isEmpty,
                   image != "-" {

                    mAllImage.append(image)
                }

                print("QUICK VIEW SEARCH IMAGE =", mData.value(forKey: "main_image") ?? "nil")
                print("QUICK VIEW IMAGE ARRAY =", mAllImage)
                
                mQuickView.mImageData = mAllImage
                self.navigationController?.pushViewController(mQuickView, animated:true)
            }
        }else {
            mAddProducts(productId: "\(mData.value(forKey: "products_id") ?? "")", po_product: "\(mData.value(forKey: "Po_products_id") ?? "")")
        }
        
    }
    
    @objc func handleImageTap(_ sender: UITapGestureRecognizer) {
        guard let imageView = sender.view as? UIImageView else {
            return
        }
        let index = imageView.tag
        if let mData = mSearchData[index] as? NSDictionary {
            let productId = "\(mData.value(forKey: "_id") ?? "")"
//            let sku = "\(mData.value(forKey: "sku") ?? "")"
            let sku = "\(mData.value(forKey: "SKU") ?? "")"
            
            mOpenGlobalImageViewer(mProductIdForImage: productId, mSKUForImage: sku)
        }
    }
    
    func mOpenGlobalImageViewer(mProductIdForImage: String , mSKUForImage: String){
        if mProductIdForImage != "" {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Test", bundle: nil)
            if let mGlobalImageViewer = storyBoard.instantiateViewController(withIdentifier: "GlobalImageViewer") as? GlobalImageViewer {
                mGlobalImageViewer.modalPresentationStyle = .overFullScreen
                mGlobalImageViewer.mProductId = mProductIdForImage
                mGlobalImageViewer.mSKUName = mSKUForImage
                mGlobalImageViewer.transitioningDelegate = self
                self.present(mGlobalImageViewer,animated: false)
            }
        }
    }
    
    @IBAction func mSearchNow(_ sender: Any) {
        let value  = mProductSearch.text?.count
        if value != 0 {
            
            self.mSearchProductByKeys(value: mProductSearch.text ?? "")
        }else {
            
            if mProductSearch.text  == "" {
                
            }
            self.view.endEditing(true)
            
        }
    }
    
    func mSearchProductByKeys(value: String){
        
        var urlPath = ""
        var params = [String:Any]()
        
        if mType == "Inventory" {
            urlPath =  mQuickViewSearch
            params = ["search": value]
            
        } else if mType == "Quick View"{
            var isIpad = false
            if UIDevice.current.userInterfaceIdiom == .pad {
                isIpad = true
            }
            urlPath =  mQuickViewSearch
            params = ["search": value,
                      "is_ipad": isIpad]
            
        }else{
            urlPath =  mQuickViewSearch
            params = ["search": value]
            
        }
        
        if Reachability.isConnectedToNetwork() == true {
            AF.request(urlPath, method:.post, parameters:params, headers: sGisHeaders2).responseJSON
            { response in
                
                if(response.error != nil){
                } else {
                    guard let jsonData = response.data else {return}
                    
                    let json = try? JSONSerialization.jsonObject(with: jsonData, options: [])
                    
                    guard let jsonResult = json as? NSDictionary else {return}
                    
                    if let mCode =  jsonResult.value(forKey: "code") as? Int {
                        if mCode == 403 {
                            CommonClass.sessionExpired(isExpired: true, navigation: self.navigationController)
                            return
                        }
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
                
                
            }
        }else{
        }
        
    }
    
    func mAddProducts(productId: String , po_product: String){
        
        mCartData =  NSMutableArray()
        
        let mLocation = UserDefaults.standard.string(forKey: "location")
        var mData = NSMutableDictionary()
        mData.setValue(productId, forKey: "product_id")
        mData.setValue(po_product, forKey: "po_product_id")
        mData.setValue("", forKey: "transaction_stock_id")
        
        
        mCartData.add(mData)
        
        let urlPath =  mAddCustomProduct
        var params = [String:Any]()
        
        
        if mType == "Inventory" {
            params = ["login_token":mUserLoginToken ?? "","cartData": self.mCartData , "location_id":mLocation ?? "","type":"Sales Order"] as [String : Any]
        }else{
            
            params = ["login_token":mUserLoginToken ?? "","cartData": self.mCartData , "location_id":mLocation ?? "","type":"Custom Order"] as [String : Any]
            
        }
        
        
        
        if Reachability.isConnectedToNetwork() == true {
            AF.request(urlPath, method:.post, parameters:params,encoding: JSONEncoding.default, headers: sGisHeaders2).responseJSON
            { response in
                
               
                if(response.error != nil){
                    
                    CommonClass.showSnackBar(message: "OOP's something went wrong!")
                    
                    
                    
                }else{
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
                        if let message = jsonResult.value(forKey: "message") as? String {
                            CommonClass.showSnackBar(message: message)
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
                
                
            }
        }else{
            CommonClass.showSnackBar(message: "No Internet Connection")
        }
        
        
    }
    
    //Speech Recognition
    @IBOutlet weak var sMicImage: UIImageView!
    @IBAction func sSpeechRecongnitionButton(_ sender: Any) {
        if !isSpeechRecongnitionOn {
            self.isSpeechRecongnitionOn = true
            self.sMicImage.image = UIImage(systemName: "mic.slash.fill")
            speechRecongniger.startRecognition { value in
                
                DispatchQueue.main.async {
                    self.isSpeechRecongnitionOn = false
                    self.sMicImage.image = UIImage(systemName: "mic.fill")
                    if let text = value , !text.isEmpty{
                        self.mProductSearch.text = text
                        self.mSearchProductByKeys(value: text)
                        self.mProductSearch.becomeFirstResponder()
                    }
                }
            }
            
        } else {
            self.sMicImage.image = UIImage(systemName: "mic.fill")
            self.isSpeechRecongnitionOn = false
            speechRecongniger.stopRecognition()
        }
    }
}
