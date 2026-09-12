//
//  HomePage.swift
//  GIS
//
//  Created by Apple Hawkscode on 19/10/20.
//

import UIKit
import DropDown
import Alamofire



extension UIButton {
    open override var isEnabled: Bool {
        didSet {
            alpha = isEnabled ? 1.0 : 0.5
        }
    }
}


class HomePage: UIViewController , UITableViewDelegate , UITableViewDataSource, UIViewControllerTransitioningDelegate, SearchDelegate, ScannerDelegate {

   
    
    
    
    @IBOutlet weak var mLanguageView: UIView!
    @IBOutlet weak var mLanguageTable: UITableView!
    var mLanguageData = NSArray()
    @IBOutlet weak var mView: UIView!
    
    @IBOutlet weak var mStoreContentView: UIView!
    @IBOutlet weak var mFlagImage: UIImageView!
    @IBOutlet weak var mUserName: UILabel!
    @IBOutlet weak var mStoreView: UIView!
    
    @IBOutlet weak var mStoreTableView: UITableView!
    @IBOutlet weak var mOrganizationImage: UIImageView!
    
    @IBOutlet weak var mChooseLanguage: UIButton!
    
    
    
    
    @IBOutlet weak var mInventoryLABEL: UILabel!
    
    @IBOutlet weak var mItemSearchLABEL: UILabel!
    
    @IBOutlet weak var mGraphLABEL: UILabel!
    
    @IBOutlet weak var mStockTakeLABEL: UILabel!
    
    @IBOutlet weak var mPosLABEL: UILabel!
    
    @IBOutlet weak var mLogOutBUTTON: UIButton!
    
    @IBOutlet weak var mSiriPermissionBtn: UIButton!
    
    @IBOutlet weak var mSwithcStoreBUTTON: UIButton!
    
    @IBOutlet weak var mQuickViewLABLEL: UILabel!

    @IBOutlet weak var mCatalogLABEL: UILabel!
    @IBOutlet weak var mDiamondLABEL: UILabel!
    @IBOutlet weak var mCustomerLABEL: UILabel!
    
    @IBOutlet weak var mLanguageLABEL: UILabel!
    @IBOutlet weak var mProfilePicture: UIImageView!
    @IBOutlet weak var mPView: UIView!
    
    @IBOutlet weak var mTrackingLABEL: UILabel!
    @IBOutlet weak var mGView: UIView!
    @IBOutlet weak var mSTView: UIView!
    @IBOutlet weak var mITView: UIView!
    @IBOutlet weak var mQView: UIView!
    @IBOutlet weak var mIView: UIView!
     var mLanguageName = [String]()
    var mLanguageImage = [String]()
    var mStoreData = NSArray()
    
    
    @IBOutlet weak var mStackTrailing: NSLayoutConstraint!
    @IBOutlet weak var mStackLeading: NSLayoutConstraint!
    @IBOutlet weak var mLogoWidth: NSLayoutConstraint!
    @IBOutlet weak var mLogoHeight: NSLayoutConstraint!
    
    @IBOutlet weak var mPOSBUTTON: UIButton!
    @IBOutlet weak var mQUICKVIEWBUTTON: UIButton!
    @IBOutlet weak var mINVENTORYBUTTON: UIButton!
    @IBOutlet weak var mDIAMONDBUTTON: UIButton!
    @IBOutlet weak var mCATALOGBUTTON: UIButton!
    @IBOutlet weak var mITEMSEARCHBUTTON: UIButton!
    @IBOutlet weak var mSTOCKTAKEBUTTON: UIButton!
    @IBOutlet weak var mCUSTOMERBUTTON: UIButton!
    @IBOutlet weak var mTRACEBUTTON: UIButton!
    @IBOutlet weak var mGRAPHBUTTON: UIButton!
    
    var isButtonProcessing = false
    
    private let faroButton = UIButton(type: .custom)
    private let scanQrButton = UIButton(type: .custom)
    
    override func viewWillAppear(_ animated: Bool) {
        if UIDevice.current.userInterfaceIdiom == .pad {
            mStackTrailing.constant = 124
            mStackLeading.constant = 124
            mLogoWidth.constant = 160
            mLogoHeight.constant = 118
        }


        
        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
        
        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        let mParamServices = ["query":"{generalsetup{productChoice isQuotation POS_partial_payment isPark servicelabers}}"]
        AF.request(mGrapQlUrl, method:.post,parameters: mParamServices, encoding:JSONEncoding.default, headers: sGisHeaders ).responseJSON
        { response in
            
            UserDefaults.standard.set(false, forKey: "isMixMatch")
            UserDefaults.standard.set(false, forKey: "isServiceLabour")
            UserDefaults.standard.set(false, forKey: "isQuotation")
            UserDefaults.standard.set(false, forKey: "isPartial")
            UserDefaults.standard.set(false, forKey: "isPark")
            if(response.error != nil) {
                
                UserDefaults.standard.set(nil, forKey: "SERVICE_LABOUR")
            }else{
                if let jsonData = response.data {
                    let json = try? JSONSerialization.jsonObject(with: jsonData, options: [])
                    if let jsonResult = json as? NSDictionary {
                        if let mData = jsonResult.value(forKey: "data") as? NSDictionary {
                            if let mGeneralSetup = mData.value(forKey: "generalsetup") as? NSDictionary {
                                
                                
                                if let mPartial = mGeneralSetup.value(forKey: "POS_partial_payment") as? String {
                                    if mPartial == "1" {
                                        UserDefaults.standard.set(true, forKey: "isPartial")
                                        
                                    }else{
                                        UserDefaults.standard.set(false, forKey: "isPartial")
                                        
                                    }
                                    
                                }else{
                                    UserDefaults.standard.set(false, forKey: "isPartial")
                                    
                                }
                                
                                if let mMixMatch = mGeneralSetup.value(forKey: "productChoice") as? String {
                                    if mMixMatch == "1" {
                                        UserDefaults.standard.set(true, forKey: "isMixMatch")
                                        self.mDIAMONDBUTTON.layer.cornerRadius = 12
                                        self.mDIAMONDBUTTON.backgroundColor =  .clear
                                        self.mDIAMONDBUTTON.isEnabled = true
                                    }else{
                                        UserDefaults.standard.set(false, forKey: "isMixMatch")
                                        self.mDIAMONDBUTTON.layer.cornerRadius = 12
                                        self.mDIAMONDBUTTON.backgroundColor =  #colorLiteral(red: 0.9568627451, green: 0.9568627451, blue: 0.9568627451, alpha: 0.6)
                                        self.mDIAMONDBUTTON.isEnabled = false
                                    }
                                    
                                    
                                    
                                }else{
                                    UserDefaults.standard.set(false, forKey: "isMixMatch")
                                    self.mDIAMONDBUTTON.layer.cornerRadius = 12
                                    self.mDIAMONDBUTTON.backgroundColor =  #colorLiteral(red: 0.9568627451, green: 0.9568627451, blue: 0.9568627451, alpha: 0.6)
                                    self.mDIAMONDBUTTON.isEnabled = false
                                }
                                
                                if let mQuotation = mGeneralSetup.value(forKey: "isQuotation") as? String {
                                    if mQuotation == "1" {
                                        UserDefaults.standard.set(true, forKey: "isQuotation")
                                        
                                    }else{
                                        UserDefaults.standard.set(false, forKey: "isQuotation")
                                    }
                                }else{
                                    UserDefaults.standard.set(false, forKey: "isQuotation")
                                }
                                
                                
                                if let mPark = mGeneralSetup.value(forKey: "isPark") as? String {
                                    if mPark == "1" {
                                        UserDefaults.standard.set(true, forKey: "isPark")
                                        
                                    }else{
                                        UserDefaults.standard.set(false, forKey: "isPark")
                                        
                                    }
                                    
                                }else{
                                    UserDefaults.standard.set(false, forKey: "isPark")
                                    
                                }
                                
                                if let mServiceLabour = mGeneralSetup.value(forKey: "servicelabers") as? String {
                                    if mServiceLabour == "1" {
                                        UserDefaults.standard.set(true, forKey: "isServiceLabour")
                                        
                                    }else{
                                        UserDefaults.standard.set(false, forKey: "isServiceLabour")
                                    }
                                }else{
                                    UserDefaults.standard.set(false, forKey: "isServiceLabour")
                                    
                                }
                            }else{
                                
                            }
                            
                        }
                    }
                }
            }
        }
        
        
        let mParamService = ["query":"{ServiceLabour{id code name}}"]
        AF.request(mGrapQlUrl, method:.post,parameters: mParamService, encoding:JSONEncoding.default, headers: sGisHeaders ).responseJSON
        { response in
            
            if(response.error != nil) {
                UserDefaults.standard.set(nil, forKey: "SERVICE_LABOUR")
            }else{
                if let jsonData = response.data {
                    let json = try? JSONSerialization.jsonObject(with: jsonData, options: [])
                    if let jsonResult = json as? NSDictionary {
                        UserDefaults.standard.set(jsonResult, forKey: "SERVICE_LABOUR")
                    }
                }
            }
        }
        
        let mParamRepair = ["query":"{Repair{id name}}"]
        AF.request(mGrapQlUrl, method:.post,parameters: mParamRepair, encoding:JSONEncoding.default, headers: sGisHeaders ).responseJSON
        { response in
            
            if(response.error != nil) {
                UserDefaults.standard.set(nil, forKey: "REPAIR_DESIGN")
            }else{
                if let jsonData = response.data {
                    let json = try? JSONSerialization.jsonObject(with: jsonData, options: [])
                    if let jsonResult = json as? NSDictionary {
                        UserDefaults.standard.set(jsonResult, forKey: "REPAIR_DESIGN")
                    }
                }
            }
        }
        
        
        let mParams = ["query":"{stones{id name}colors{id name}metals{id name}shapes{id name}claritys{id name}cuts{id name}sizes{id name}settingType{id name}stonecolors{id name}}"]
        AF.request(mGrapQlUrl, method:.post,parameters: mParams, encoding:JSONEncoding.default, headers: sGisHeaders).responseJSON
        { response in
            
            if(response.error != nil) {
                UserDefaults.standard.set(nil, forKey: "GRAPHQL")
            }else{
                if let jsonData = response.data {
                    let json = try? JSONSerialization.jsonObject(with: jsonData, options: [])
                    if let jsonResult = json as? NSDictionary {
                        UserDefaults.standard.set(jsonResult, forKey: "GRAPHQL")
                    }
                }
            }
        }
        
        AF.request(mGetShapes, method:.post, headers: sGisHeaders).responseJSON
        { response in
            
            if(response.error != nil) {
                UserDefaults.standard.set(nil, forKey: "SHAPES")
                
            }else{
                if let jsonData = response.data {
                    let json = try? JSONSerialization.jsonObject(with: jsonData, options: [])
                    if let jsonResult = json as? NSDictionary {
                        UserDefaults.standard.set(jsonResult, forKey: "SHAPES")
                    }
                }
            }
        }
        
        mCustomerLABEL.text = "Customer".localizedString
        mQuickViewLABLEL.text = "Quick View".localizedString
        mLanguageLABEL.text = "Language".localizedString
        mDiamondLABEL.text = "Diamond".localizedString
        mCatalogLABEL.text = "Catalog".localizedString
        mInventoryLABEL.text = "Inventory".localizedString
        mItemSearchLABEL.text = "Item Search".localizedString
        mStockTakeLABEL.text = "Stock Take".localizedString
        mTrackingLABEL.text = "Trace".localizedString
        mPosLABEL.text = "POS".localizedString
        mGraphLABEL.text = "Graph".localizedString
        mLogOutBUTTON.setTitle("Logout".localizedString, for: .normal)
        mSiriPermissionBtn.setTitle("Siri Permission".localizedString, for: .normal)
        
        mSwithcStoreBUTTON.setTitle("Switch Store".localizedString, for: .normal)
        
        AF.request(mPOSSettings, method:.post,encoding: JSONEncoding.default, headers: sGisHeaders).responseJSON
        { response in
//            print("viewWillAppear mPOSSettings response: = \(response)")
            CommonClass.stopLoader()
            if(response.error != nil) {
                
            }else{
                if let jsonData = response.data {
                    let json = try? JSONSerialization.jsonObject(with: jsonData, options: [])
                    if let jsonResult = json as? NSDictionary {
                        if let mData = jsonResult.value(forKey: "data") as? NSDictionary {
                            
                            let faroActive = "\(mData["faro_active"] ?? "0")" == "1"
                                UserDefaults.standard.set(faroActive, forKey: "faro_active")
                            
                            if let mPriceFormat = mData.value(forKey: "price_format") as? NSDictionary {
                                if let mStoreCurrency = mPriceFormat.value(forKey: "currency") as? String {
                                    UserDefaults.standard.set(mStoreCurrency, forKey: "storeCurrency")
                                    
                                }else{
                                    UserDefaults.standard.set(nil, forKey: "storeCurrency")
                                    
                                }
                                
                            }else{
                                UserDefaults.standard.set(nil, forKey: "storeCurrency")
                                
                            }
                            
                            if let mTaxData = mData.value(forKey: "tax") as? NSDictionary {
                                if let mTaxValue = mTaxData.value(forKey: "value") as? Int {
                                    UserDefaults.standard.set(mTaxValue, forKey: "taxValue")
                                }
                                if let mTaxType = mTaxData.value(forKey: "type") as? String {
                                    UserDefaults.standard.set(mTaxType, forKey: "taxType")
                                }
                                if let mCurrency = mData.value(forKey: "symbol") as? String {
                                    UserDefaults.standard.set(mCurrency, forKey: "currencySymbol")
                                }
                            }else{
                                UserDefaults.standard.set(nil, forKey: "taxType")
                                UserDefaults.standard.set(nil, forKey: "taxValue")
                            }
                            
                            if let reservDeliveryDate = mData.value(forKey: "reserve_delivery") as? String {
                                UserDefaults.standard.set(reservDeliveryDate, forKey: "reserveDeliveryDate")
                            }
                            
                        }
                    }
                }
            }
        }
        
        
        AF.request(mFetchPaymentMethod, method:.post,parameters: ["":""],encoding: JSONEncoding.default, headers: sGisHeaders).responseJSON
        { response in
            
            CommonClass.stopLoader()
            if(response.error != nil) {
                
            }else{
                if let jsonData = response.data {
                    let json = try? JSONSerialization.jsonObject(with: jsonData, options: [])
                    if let jsonResult = json as? NSDictionary {
                        
                        if let mData = jsonResult.value(forKey: "data") as? NSDictionary {
                            
                            //Store Cash Data
                            if let mCashData = mData.value(forKey: "Cash") as? NSArray {
                                if mCashData.count > 0 {
                                    if let mData = mCashData[0] as? NSDictionary {
                                        UserDefaults.standard.set(mData, forKey: "CASHDATA")
                                    }
                                }
                            }
                            
                            //Store Credit Card Data
                            if let mCreditCard = mData.value(forKey: "Credit_Card") as? NSArray {
                                if mCreditCard.count > 0 {
                                    UserDefaults.standard.set(mCreditCard, forKey: "CREDITCARDDATA")
                                }else{UserDefaults.standard.set(nil, forKey: "CREDITCARDDATA")}
                            }else{UserDefaults.standard.set(nil, forKey: "CREDITCARDDATA")}
                            
                            //Store Bank Data
                            if let mBankData = mData.value(forKey: "Bank") as? NSArray {
                                if mBankData.count > 0 {
                                    UserDefaults.standard.set(mBankData, forKey: "BANKDATA")
                                }else{UserDefaults.standard.set(nil, forKey: "BANKDATA")}
                            }else{UserDefaults.standard.set(nil, forKey: "BANKDATA")}
                            
                            
                        }
                    }
                }
            }
            
        }
        
        mClearCart()
        
        UserDefaults.standard.setValue(nil, forKey: "cRemark")
    }
    
    @objc func openSwitchStore() {

        print("🔥 LOCATION CLICKED")

        showStoreList(hideProfileActions: true)
    }
    
    func showStoreList(hideProfileActions: Bool) {

        // ซ่อน/แสดงปุ่มตามจุดที่เปิด popup
        mLogOutBUTTON.isHidden = hideProfileActions
        mSiriPermissionBtn.isHidden = hideProfileActions

        guard let jsonResult =
                UserDefaults.standard.object(forKey: "storeData")
                as? NSDictionary else {

            CommonClass.showSnackBar(
                message: "No Stores available!"
            )
            return
        }

        guard jsonResult.value(forKey: "code") as? Int == 200,
              let storeData =
                jsonResult.value(forKey: "data") as? NSArray,
              storeData.count > 0 else {

            CommonClass.showSnackBar(
                message: "No Stores available!"
            )
            return
        }

        self.mStoreData = storeData

        self.mStoreTableView.delegate = self
        self.mStoreTableView.dataSource = self
        self.mStoreTableView.reloadData()

        // เปิด content view
        self.mStoreContentView.isHidden = false

        // ต้องเปิด table ด้วย เพราะ mHide() และ flow อื่นสามารถซ่อน table ไว้ได้
        self.mStoreTableView.isHidden = false
    }
    
    func showStorePopup() {

        guard let jsonResult =
                UserDefaults.standard.object(forKey: "storeData")
                as? NSDictionary else {

            CommonClass.showSnackBar(
                message: "No Stores available!"
            )

            mStoreContentView.isHidden = false
            return
        }

        if jsonResult.value(forKey: "code") as? Int == 200 {

            if let storeData =
                jsonResult.value(forKey: "data") as? NSArray {

                if storeData.count == 0 {

                    CommonClass.showSnackBar(
                        message: "No Stores available!"
                    )

                    mStoreContentView.isHidden = false
                    return
                }

                self.mStoreData = storeData

                self.mStoreTableView.delegate = self
                self.mStoreTableView.dataSource = self
                self.mStoreTableView.reloadData()

                self.mStoreContentView.isHidden = false

            } else {

                self.mStoreContentView.isHidden = false
            }

        } else {

            CommonClass.showSnackBar(
                message: "No Stores available!"
            )

            self.mStoreContentView.isHidden = false
        }
    }

    @objc
    private func openFaro() {

        let vc = FaroScannerViewController()

        let nav = UINavigationController(rootViewController: vc)

        nav.modalPresentationStyle = .fullScreen
        nav.modalTransitionStyle = .crossDissolve

        present(nav, animated: true)

    }
    
    private func openCreateYourOwn(
        _ products: [NSMutableDictionary]
    ) {

        print("🔥 OPEN CUSTOM CART")
        print("NAV =", navigationController as Any)
        let storyBoard = UIStoryboard(
            name: "customOrder",
            bundle: nil
        )

        guard let cart = storyBoard.instantiateViewController(
            withIdentifier: "CustomCart"
        ) as? CustomCart else {

            print("❌ Instantiate CustomCart Failed")
            return
        }

        print("🔥 Pending =", products.count)

        cart.mPendingProducts = products
        print("Pending Before Push =", cart.mPendingProducts.count)
        print("🔥 Navigation =", navigationController as Any)

//        navigationController?.pushViewController(
//            cart,
//            animated: true
//        )
        if let nav = navigationController {

            print("VC Before Push =", nav.topViewController as Any)

            nav.pushViewController(cart, animated: true)

            print("VC After Push =", nav.topViewController as Any)

        } else {

            print("navigationController nil")

        }
        print("Top VC =",
              NavigationHelper.topNavigationController()?.topViewController ?? "nil")
        
        print(
            NavigationHelper
                .topNavigationController()?
                .topViewController
        )
    }
    
    func mGetScannedData(
        value: String,
        type: String
    ) {

        let scanValue = value
            .components(separatedBy: .newlines)
            .first?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? value

        print("FULL SCAN =", value)
        print("SCAN VALUE =", scanValue)

        mCheckScanItem(code: scanValue)
    }
    
    func openPOSAddCart(
        data: NSDictionary,
        type: String
    ) {


        let storyBoard: UIStoryboard =
            UIStoryboard(
                name: "catalog",
                bundle: nil
            )


        if let vc =
            storyBoard.instantiateViewController(
                withIdentifier: "POSAddToCartNew"
            ) as? POSAddToCart {


            print("========== OPEN POS ADD CART ==========")
            print("🔥 TYPE =", type)
            print("🔥 DATA =", data)
            print("=======================================")


            vc.mData = data

            vc.mType = type
            vc.mCustomerId = UserDefaults.standard.string( forKey: "DEFAULTCUSTOMER") ?? ""


            self.navigationController?
                .pushViewController(
                    vc,
                    animated: true
                )

        }

    }
    
    
    
    func mCheckScanItem(code: String) {

        // =====================================
        // SHOW LOADING
        // =====================================
        DispatchQueue.main.async {
            CommonClass.showFullLoader(view: self.view)
        }

        let params: [String: Any] = [
            "search": code,
            "type": "",
            "from": "",
            "page": 1,
            "limit": 1
        ]

        print("")
        print("========================================")
        print("🔥 SCAN CHECK ITEM START")
        print("🔥 SCAN CODE =", code)
        print("🔥 SCAN SEARCH PARAM =", params)
        print("========================================")

        AF.request(
            mCommonSearchAPI,
            method: .post,
            parameters: params,
            headers: sGisHeaders2
        )
        .responseJSON { response in

            print("🔥 COMMON SEARCH RESPONSE =", response)

            guard let json = response.value as? NSDictionary else {

                print("❌ COMMON SEARCH INVALID RESPONSE")

                DispatchQueue.main.async {
                    CommonClass.stopLoader()

                    CommonClass.showSnackBar(
                        message: "Invalid response"
                    )
                }

                return
            }

            print("🔥 COMMON SEARCH JSON =", json)

            // =====================================
            // COMMON SEARCH SUCCESS
            // =====================================
            if let data = json["data"] as? NSArray,
               let item = data.firstObject as? NSDictionary {

                print("🔥 COMMON SEARCH FOUND =", item)

                DispatchQueue.main.async {

                    // ปิด loading ก่อนเข้า item
                    CommonClass.stopLoader()

                    self.handleScanItem(item: item)
                }

                return
            }

            // =====================================
            // COMMON SEARCH NOT FOUND
            // → FALLBACK ITEM SEARCH
            // =====================================

            print("🟡 COMMON SEARCH NOT FOUND")
            print("🟡 TRY ITEM SEARCH")

            self.mSearchProductByKeys(code: code)
        }
    }
    
    func mSearchProductByKeys(
        code: String,
        searchType: String = "stock_id"
    ) {

        let params: [String: Any] = [
            "type": searchType,
            "search": code
        ]

        print("")
        print("========================================")
        print("🔥 ITEM SEARCH START")
        print("🔥 \(mSearchItems)")
        print("🔥 SEARCH TYPE =", searchType)
        print("🔥 ITEM SEARCH PARAM =", params)
        print("========================================")

        AF.request(
            mSearchItems,
            method: .post,
            parameters: params,
            headers: sGisHeaders2
        )
        .responseJSON { response in

            print("🔥 ITEM SEARCH RESPONSE =", response)

            guard let json = response.value as? NSDictionary else {

                print("❌ ITEM SEARCH INVALID")

                DispatchQueue.main.async {
                    CommonClass.stopLoader()

                    CommonClass.showSnackBar(
                        message: "Invalid response"
                    )
                }

                return
            }

            print("🔥 ITEM SEARCH JSON =", json)

            let codeValue = "\(json["code"] ?? "")"

            //--------------------------------------------------
            // SUCCESS
            //--------------------------------------------------

            if codeValue == "200",
               let data = json["data"] as? NSDictionary {

                print("🔥 ITEM SEARCH DATA =", data)

                var stockId = ""

                if let rows = data["item_searchRow"] as? NSArray,
                   let row = rows.firstObject as? NSDictionary,
                   let ids = row["ids"] as? NSArray {

                    stockId = "\(ids.firstObject ?? "")"
                }

                guard !stockId.isEmpty else {

                    DispatchQueue.main.async {
                        CommonClass.stopLoader()

                        CommonClass.showSnackBar(
                            message: "No data avalable"
                        )
                    }

                    return
                }

                DispatchQueue.main.async {

                    CommonClass.stopLoader()

                    self.openPOSAddCartForStock(
                        stockId: stockId
                    )
                }

                return
            }

            //--------------------------------------------------
            // STOCK_ID ไม่เจอ → ยิง SKU
            //--------------------------------------------------

            if searchType == "stock_id" {

                print("🟡 STOCK_ID NOT FOUND")
                print("🟡 TRY SKU SEARCH")

                self.mSearchProductByKeys(
                    code: code,
                    searchType: "SKU"
                )

                return
            }

            //--------------------------------------------------
            // SKU ก็ไม่เจอ
            //--------------------------------------------------

            let message =
                json["message"] as? String
                ?? "No data avalable"

            DispatchQueue.main.async {

                CommonClass.stopLoader()

                CommonClass.showSnackBar(
                    message: message
                )
            }
        }
    }
    
    func handleScanItem(item:NSDictionary) {


        // STOCK

        if let stockId = item["stock_id"] as? String,
           !stockId.isEmpty {


            self.openPOSAddCartForStock(
                stockId: stockId
            )

            return
        }



        // SKU

        let sku =
        "\(item["SKU"] ?? item["sku"] ?? "")"


        let productId =
        "\(item["_id"] ?? item["product_id"] ?? "")"



        self.openPOSAddCartForSKU(
            sku: sku,
            productId: productId
        )

    }
    
    func openPOSAddCartForSKU(
        sku:String,
        productId:String
    ) {


        let storyBoard: UIStoryboard = UIStoryboard(
            name: "catalog",
            bundle: nil
        )


        if let vc = storyBoard.instantiateViewController(
            withIdentifier: "POSAddToCartNew"
        ) as? POSAddToCart {


            vc.mSKU = sku
            vc.mProductId = productId
            vc.mType = "catalog"


            self.navigationController?
                .pushViewController(
                    vc,
                    animated:true
                )

        }

    }
    
    func openPOSAddCartForStock(
        stockId:String
    ) {


        let storyBoard: UIStoryboard = UIStoryboard(
            name: "catalog",
            bundle: nil
        )


        if let vc = storyBoard.instantiateViewController(
            withIdentifier: "POSAddToCartNew"
        ) as? POSAddToCart {


            print("")
            print("================================")
            print("🚀 OPEN POS ADD CART STOCK")
            print("🔥 SEND PRODUCT ID =", stockId)
            print("================================")


            vc.mProductId = stockId
            vc.mSKU = ""
            vc.mType = "inventory"


            print("AFTER SET")
            print("🔥 VC PRODUCT ID =", vc.mProductId)
            print("🔥 VC TYPE =", vc.mType)


            self.navigationController?
                .pushViewController(
                    vc,
                    animated:true
                )

        }

    }
    
    private func setupScanQrButton() {
        scanQrButton.translatesAutoresizingMaskIntoConstraints = false

        scanQrButton.setImage(
            UIImage(named: "faro_scan_qr"),
            for: .normal
        )
        
        scanQrButton.layer.shadowColor = UIColor.black.cgColor
        scanQrButton.layer.shadowOpacity = 0.2
        scanQrButton.layer.shadowRadius = 8
        scanQrButton.layer.shadowOffset = CGSize(width: 0, height: 4)

        scanQrButton.backgroundColor = .clear

        scanQrButton.addTarget(
            self,
            action: #selector(mOpenQRScanner),
            for: .touchUpInside
        )

        view.addSubview(scanQrButton)

        NSLayoutConstraint.activate([

            scanQrButton.widthAnchor.constraint(equalToConstant: 56),
            scanQrButton.heightAnchor.constraint(equalToConstant: 56),

            scanQrButton.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -20
            ),

            scanQrButton.bottomAnchor.constraint(
                equalTo: faroButton.topAnchor,
                constant: -16
            )
        ])
    }
    
    @IBAction func mOpenQRScanner(_ sender: UIButton) {

        let storyBoard = UIStoryboard(name: "transactions", bundle: nil)

        if let scanner =
            storyBoard.instantiateViewController(
                withIdentifier: "CommonScanner"
            ) as? CommonScanner {

            scanner.delegate = self
            scanner.mType = "directAddCart"

            scanner.modalPresentationStyle = .overFullScreen

            self.present(scanner, animated: true)
        }
    }
    
    private func setupFaroButton() {

        faroButton.translatesAutoresizingMaskIntoConstraints = false

        faroButton.setImage(
            UIImage(named: "faro_scan"),
            for: .normal
        )
        
        faroButton.layer.shadowColor = UIColor.black.cgColor
        faroButton.layer.shadowOpacity = 0.2
        faroButton.layer.shadowRadius = 8
        faroButton.layer.shadowOffset = CGSize(width: 0, height: 4)

        faroButton.backgroundColor = .clear

        faroButton.addTarget(
            self,
            action: #selector(openFaro),
            for: .touchUpInside
        )

        view.addSubview(faroButton)

        NSLayoutConstraint.activate([

            faroButton.widthAnchor.constraint(equalToConstant: 56),
            faroButton.heightAnchor.constraint(equalToConstant: 56),

            faroButton.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -20
            ),

            faroButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -20
            )
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.set(nil, forKey: "pickDiamond")
        UserDefaults.standard.set("",forKey: "DEFAULTCUSTOMER")
        
        let faroActive = UserDefaults.standard.bool(forKey: "faro_active")

        
        
        if(faroActive) {
            setupFaroButton()//essindy faroButton
            setupScanQrButton()
        }
        
        mProfilePicture.downlaodImageFromUrl(urlString: UserDefaults.standard.string(forKey: "SALESPERSON_IMAGE") ?? "")
        
        mGRAPHBUTTON.layer.cornerRadius = 12
        mGRAPHBUTTON.backgroundColor =  #colorLiteral(red: 0.9568627451, green: 0.9568627451, blue: 0.9568627451, alpha: 0.6)
        mGRAPHBUTTON.isEnabled = false
        
        if let isMixMax = UserDefaults.standard.bool(forKey: "isMixMatch") as? Bool {
            if isMixMax {
                mDIAMONDBUTTON.layer.cornerRadius = 12
                mDIAMONDBUTTON.backgroundColor =  .clear
                mDIAMONDBUTTON.isEnabled = true
            }else{
                mDIAMONDBUTTON.layer.cornerRadius = 12
                mDIAMONDBUTTON.backgroundColor =  #colorLiteral(red: 0.9568627451, green: 0.9568627451, blue: 0.9568627451, alpha: 0.6)
                mDIAMONDBUTTON.isEnabled = false
            }
        }else{
            mDIAMONDBUTTON.layer.cornerRadius = 12
            mDIAMONDBUTTON.backgroundColor =  #colorLiteral(red: 0.9568627451, green: 0.9568627451, blue: 0.9568627451, alpha: 0.6)
            mDIAMONDBUTTON.isEnabled = false
        }
        
        mUserName.text = UserDefaults.standard.string(forKey: "locationName") ?? "--"
        
        mStoreView.layer.cornerRadius = 20
        mStoreView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        
        mStoreTableView.delegate = self
        mStoreTableView.dataSource = self
        mStoreTableView.reloadData()
        
        self.view.backgroundColor = UIColor(named: "themeBackground")
        
        if UserDefaults.standard.string(forKey: "LANG") == "EN" {
            AppLanguage.shared.set(index: .english)
            setFlag(flag: "English")
            
            
        }else if UserDefaults.standard.string(forKey: "LANG") == "TH" {
            AppLanguage.shared.set(index: .thai)
            setFlag(flag: "Thai")
            
            
        }else if UserDefaults.standard.string(forKey: "LANG") == "JA" {
            AppLanguage.shared.set(index: .japanese)
            setFlag(flag: "Japanese")
            
        }else if UserDefaults.standard.string(forKey: "LANG") == "AR" {
            AppLanguage.shared.set(index: .arabic)
            setFlag(flag: "Arabic")
            
        }else if UserDefaults.standard.string(forKey: "LANG") == "CH" {
            AppLanguage.shared.set(index: .chinese)
            setFlag(flag: "Chinese")
            
        }else if UserDefaults.standard.string(forKey: "LANG") == "RU" {
            AppLanguage.shared.set(index: .russian)
            setFlag(flag: "Russian")
            
        }else{
            AppLanguage.shared.set(index: .english)
            setFlag(flag: "English")
        }

        
        if let mData =  UserDefaults.standard.array(forKey: "LANGUAGE") as? NSArray {
            mLanguageData = mData
        }
        
        
        
        mLanguageTable.delegate = self
        mLanguageTable.dataSource = self
        mLanguageTable.reloadData()
        
        mUserName.isUserInteractionEnabled = true

            let tapLocation = UITapGestureRecognizer(
                target: self,
                action: #selector(openSwitchStore)
            )

        mUserName.addGestureRecognizer(tapLocation)
        
//        mPView.isUserInteractionEnabled = true
//
//        let tapLocation = UITapGestureRecognizer(
//            target: self,
//            action: #selector(openSwitchStore)
//        )
//
//        mPView.addGestureRecognizer(tapLocation)
       
    }
    
    func setFlag(flag:String){
        if let mData =  UserDefaults.standard.array(forKey: "LANGUAGE") as? NSArray {
            for i in mData {
                if let language = i as? NSDictionary {
                    if let strUrl = language.value(forKey:"name") as? String, strUrl.contains(flag) {
                        let strName = language.value(forKey:"flag") as? String
                        self.mFlagImage.downlaodImageFromUrl(urlString: strName ?? "")
                    }
                }
            }
        }
    }
    
    @IBAction func mMinimize(_ sender: Any) {
        mLanguageView.slideTop()
        mLanguageView.isHidden = true
    }
    
    func setLang(){
        let storyBoard: UIStoryboard = UIStoryboard(name: "reserveBoard", bundle: nil)
        if let home = storyBoard.instantiateViewController(withIdentifier: "HomePage1") as? HomePage {
            self.navigationController?.pushViewController(home, animated:false)
        }
        
        mQuickViewLABLEL.text = "Quick View".localizedString
        mLanguageLABEL.text = "Language".localizedString
        mDiamondLABEL.text = "Diamond".localizedString
        mInventoryLABEL.text = "Inventory".localizedString
        mItemSearchLABEL.text = "Item Search".localizedString
        mStockTakeLABEL.text = "Stock Take".localizedString
        mTrackingLABEL.text = "Trace".localizedString
        mPosLABEL.text = "POS".localizedString
        mGraphLABEL.text = "Graph".localizedString
        mLogOutBUTTON.setTitle("Logout".localizedString, for: .normal)
        mSwithcStoreBUTTON.setTitle("Switch Store".localizedString, for: .normal)
        mSiriPermissionBtn.setTitle("Siri Permission".localizedString, for: .normal)
        

    }
    
    @IBAction func mHide(_ sender: Any) {
        
        
        
         mStoreTableView.slideTop()
         mStoreTableView.isHidden = true
         self.mStoreContentView.isHidden = true
    }
    
    @IBAction func mLogOut(_ sender: Any) {

        showStoreList(hideProfileActions: false)
    }
    
    @IBAction func mSiriPermission(_ sender: Any) {
        if let url = URL(string: "shortcuts://GIS") {
               if UIApplication.shared.canOpenURL(url) {
                   UIApplication.shared.open(url, options: [:], completionHandler: nil)
               } else {
                   print("Shortcuts app is not installed or accessible.")
               }
           }
   
     }
    
    private func handleButtonClicked(buttonName: String){
        guard !isButtonProcessing else { return }
        isButtonProcessing = true
        
        switch buttonName {
        case "POS":
            let storyBoard: UIStoryboard = UIStoryboard(name: "posBoard", bundle: nil)
            print("buttonName = \(buttonName)")
            if let mHomePage  = storyBoard.instantiateViewController(withIdentifier: "POSTabBarController") as? POSTabBarController {
                mHomePage.mIndex = 2
                UserDefaults.standard.setValue("mClearCart", forKey: "mClearCart")
                self.navigationController?.pushViewController(mHomePage, animated:true)
            }
            break
        case "QuickView":
            let storyBoard: UIStoryboard = UIStoryboard(name: "Test", bundle: nil)
            if let home = storyBoard.instantiateViewController(withIdentifier: "QuickViewSearch") as? QuickViewSearch{
                home.mType = "Quick View"
                self.navigationController?.pushViewController(home, animated:true)
            }
            break
        case "Inventory":
            let storyBoard: UIStoryboard = UIStoryboard(name: "reserveBoard", bundle: nil)
            if let mInventoryPage = storyBoard.instantiateViewController(withIdentifier: "InventoryPageNew") as? InventoryPage {
                self.navigationController?.pushViewController(mInventoryPage, animated:true)
            }
            break
        case "Diamond":
            let storyBoard: UIStoryboard = UIStoryboard(name: "diamondModule", bundle: nil)
            if let home = storyBoard.instantiateViewController(withIdentifier: "DiamondFilters") as? DiamondFilters {
                self.navigationController?.pushViewController(home, animated:true)
            }
            break
        case "Catalog":
            let storyBoard: UIStoryboard = UIStoryboard(name: "catalog", bundle: nil)
            if let mInventoryPage = storyBoard.instantiateViewController(withIdentifier: "POSCatalogNew") as? POSCatalog {
                mInventoryPage.openFromHome = true
                self.navigationController?.pushViewController(mInventoryPage, animated:true)
            }
            break
        case "ItemSearch":
            let storyBoard: UIStoryboard = UIStoryboard(name: "reserveBoard", bundle: nil)
            if let mInventoryPage = storyBoard.instantiateViewController(withIdentifier: "ItemSearchPageNew") as? ItemSearchPage {
                self.navigationController?.pushViewController(mInventoryPage, animated:true)
            }
            break
        case "StockTake":
            let storyBoard: UIStoryboard = UIStoryboard(name: "stockBoard", bundle: nil)
            if let mStockTakePage = storyBoard.instantiateViewController(withIdentifier: "StockTakePage") as? StockTakePage {
                self.navigationController?.pushViewController(mStockTakePage, animated:true)
            }
            break
        case "Customer":
            let storyBoard: UIStoryboard = UIStoryboard(name: "posBoard", bundle: nil)
            if let home = storyBoard.instantiateViewController(withIdentifier: "PosCustomerSearch") as? PosCustomerSearch {
                self.navigationController?.pushViewController(home, animated:false)
            }
            break
        case "Trace":
            let storyBoard: UIStoryboard = UIStoryboard(name: "tr", bundle: nil)
            if let home = storyBoard.instantiateViewController(withIdentifier: "Track") as? Track {
                self.navigationController?.pushViewController(home, animated:false)
            }
            break
        default:
            break
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isButtonProcessing = false
        }
    }
    
    @IBAction func mDiamondReserve(_ sender: Any) {
        handleButtonClicked(buttonName: "Diamond")
    }
    
    @IBAction func mCatalog(_ sender: Any) {
        handleButtonClicked(buttonName: "Catalog")
    }
    
    @IBAction func mInventory(_ sender: Any) {
        handleButtonClicked(buttonName: "Inventory")
    }
    
    @IBAction func mItemSearch(_ sender: Any) {
        handleButtonClicked(buttonName: "ItemSearch")
    }
    
    @IBAction func mQuickView(_ sender: Any) {
        handleButtonClicked(buttonName: "QuickView")
    }
    
    @IBAction func mStock(_ sender: Any) {
        handleButtonClicked(buttonName: "StockTake")
    }
    @IBAction func mPos(_ sender: Any) {
        handleButtonClicked(buttonName: "POS")
    }
    
    
    @IBAction func mTracking(_ sender: Any) {
        handleButtonClicked(buttonName: "Trace")
    }
    
//    func mGetSearchItems(id: String) {
//    func mGetSearchItems(id: String, locationId: String) {
    func mGetSearchItems(
        id: String,
        locationId: String,
        type: String
    ) {
    }
    
    @IBAction func mGraph(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "laybyInstallment", bundle: nil)
        if let mCommonServiceLabour = storyBoard.instantiateViewController(withIdentifier: "CommonServiceLabour") as? CommonServiceLabour {
            mCommonServiceLabour.modalPresentationStyle = .overFullScreen
            mCommonServiceLabour.transitioningDelegate = self
            self.present(mCommonServiceLabour,animated: true)
        }
    }
    
    
    @IBAction func mCustomer(_ sender: Any) {
        handleButtonClicked(buttonName: "Customer")
    }
    
    @IBAction func mLogoutAccount(_ sender: Any) {
        AppLanguage.shared.set(index: .english)
        mSESSION = "1"
        mLogOut()
        self.mStoreContentView.isHidden = true
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let home = storyBoard.instantiateViewController(withIdentifier: "LoginController") as? LoginController {
            self.navigationController?.pushViewController(home, animated:true)
        }
    }
    
    
    func mLogOut(){
        
        let urlPath = mLogOutUser
        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        
        guard let appToken = mUserLoginToken else{return}
        guard let bundleShortVersionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
              let bundleVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        else { return }
        
        let params:[String:String] = ["token":appToken,
                                      "platform":mGetDeviceInfo(),
                                      "agent":"\(bundleShortVersionString).\(bundleVersion)"]
        
        if Reachability.isConnectedToNetwork() == true {
            
            AF.request(urlPath, method:.post, parameters: params,encoding: JSONEncoding.default).responseJSON
            { response in
                if response.response?.statusCode == 403 {
                    CommonClass.sessionExpired(isExpired: true, navigation: self.navigationController)
                }
                
                if(response.error != nil) {
                    
                }else{
                    if let jsonData = response.data {
                        let json = try? JSONSerialization.jsonObject(with: jsonData, options: [])
                        if let jsonResult = json as? NSDictionary {
                            if jsonResult.value(forKey: "code") as? Int == 200 {
                                
                            }else{
                                if let error = jsonResult.value(forKey: "error") as? String,
                                   error == "Authorization has been expired" {
                                        CommonClass.sessionExpired(isExpired: true, navigation: self.navigationController)
                                }
                            }
                        }
                    }
                }
                
            }
        }else{
        }
        
    }
    
    @IBAction func mChooseLanguage(_ sender: Any) {
        mLanguageView.isHidden = false
        mLanguageView.slideFromBottom()
    }
    
    @IBAction func mSwitchAccount(_ sender: Any) {
        UIView.transition(with: mStoreTableView, duration: 0.1, options: .transitionCrossDissolve , animations: {
            self.mStoreTableView.isHidden = !self.mStoreTableView.isHidden
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == mLanguageTable {
            
            return mLanguageData.count
        }
       
        return mStoreData.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false

        if let cell  = tableView.dequeueReusableCell(withIdentifier: "LanguageCell") as? LanguageCell {
            if let mData = mLanguageData[indexPath.row] as? NSDictionary {
                cell.mFlag.downlaodImageFromUrl(urlString: "\(mData.value(forKey: "flag") ?? "")")
                cell.mName.text = "\(mData.value(forKey: "name") ?? "")"
                cell.mName.layer.cornerRadius = 0
            }
            return cell
        }
       
        if let cells = tableView.dequeueReusableCell(withIdentifier: "StoreItem") as? StoreItem {
            if let mData = mStoreData[indexPath.row] as? NSDictionary {
                cells.mStoreName.text = mData.value(forKey: "voucher_name") as? String
                cells.mStoreDomain.text = ""
            }
            return cells
        }else {return UITableViewCell()}
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == mLanguageTable {
            mLanguageView.slideTop()
            mLanguageView.isHidden = true
            if let mData = mLanguageData[indexPath.row] as? NSDictionary {
                self.mFlagImage.downlaodImageFromUrl(urlString: "\(mData.value(forKey: "flag") ?? "" )")
                
                let item = "\(mData.value(forKey: "name") ?? "")"
                if item.contains("English"){
                    AppLanguage.shared.set(index: .english)
                    
                    setLang()
                    
                }else if item.contains("Arabic"){
                    AppLanguage.shared.set(index: .arabic)
                    
                    setLang()
                }else if item.contains("Thai"){
                    AppLanguage.shared.set(index: .thai)
                    
                    setLang()
                }else if item.contains("Chinese"){
                    setLang()
                    AppLanguage.shared.set(index: .chinese)
                    
                    setLang()
                }else if item.contains("Japanese"){
                    AppLanguage.shared.set(index: .japanese)
                    
                    setLang()
                }else if item.contains("Russian") {
                    AppLanguage.shared.set(index: .russian)
                    setLang()
                    
                }else{
                    AppLanguage.shared.set(index: .english)
                    setLang()
                }
            }
        }else{
            if let mData = mStoreData[indexPath.row] as? NSDictionary {
//                print("before Selected Location =", UserDefaults.standard.string(forKey: "location") ?? "")
                if let location = mData.value(forKey: "location_id") as? String,
                let locationName = mData.value(forKey: "location_name") as? String {
                    UserDefaults.standard.setValue("\(location)", forKey: "location")
                    UserDefaults.standard.setValue("\(locationName)", forKey: "locationName")
                    self.mUserName.text = locationName
                }
                
//                print("after Selected Location =", UserDefaults.standard.string(forKey: "location") ?? "")
                
                let mCurrency = "\(mData.value(forKey: "currency") ?? "")"
                let mLocationId = "\(mData.value(forKey: "location_id") ?? "")"
                let mVoucherId = "\(mData.value(forKey: "voucher_id") ?? "")"
                
                UserDefaults.standard.setValue("\(mCurrency)", forKey: "posCurrency")
                UserDefaults.standard.setValue("\(mLocationId)", forKey: "posLocation")
                UserDefaults.standard.setValue("\(mVoucherId)", forKey: "posVoucher")
               
            }
            mGeneratePOSToken()
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
        
    }
    func mGeneratePOSToken(){
        
        let mCurrency = UserDefaults.standard.string(forKey: "posCurrency") ?? ""
        let mLocationId = UserDefaults.standard.string(forKey: "posLocation") ?? ""
        let mVoucherId  = UserDefaults.standard.string(forKey: "posVoucher") ?? ""
        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        guard let shortVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
              let buildVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String,
              let appToken = mUserLoginToken else{return}
        
        let sGenPosHeader:HTTPHeaders = [
            "Authorization": appToken,
            "agent" : "\(shortVersion).\(buildVersion)",
            "platform" : mGetDeviceInfo(),
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        let urlPath = mPOSAuthToken
        
        let params:[String:String] = ["currency" : mCurrency , "voucher_id":mVoucherId, "location_id":mLocationId ]
        
        if Reachability.isConnectedToNetwork() == true {
            CommonClass.showFullLoader(view: self.view)
            
            AF.request(urlPath, method:.post, parameters: params,headers: sGenPosHeader).responseJSON
            { response in
                CommonClass.stopLoader()
                print("mGeneratePOSToken mPOSAuthToken response = \(response)")
                if(response.error != nil){
                    CommonClass.showSnackBar(message: "OOP's something went wrong!")
                    
                }else{
                    if let jsonData = response.data {
                        
                        let json = try? JSONSerialization.jsonObject(with: jsonData, options: [])
                        if let jsonResult = json as? NSDictionary {
                            if jsonResult.value(forKey: "code") as? Int == 200 {
                                if jsonResult.value(forKey: "data") != nil {
                                    if let mData = jsonResult.value(forKey: "data") as? NSDictionary {
                                        UserDefaults.standard.setValue("\(mData.value(forKey: "token") ?? "")", forKey: "token_pos")
                                        //Update Headers
                                        sGisHeaders["pos-authorization"] = UserDefaults.standard.string(forKey: "token_pos") ?? ""
                                        sGisHeaders2["pos-authorization"] = UserDefaults.standard.string(forKey: "token_pos") ?? ""
                                        
                                        mSESSION = ""
                                        self.mStoreContentView.isHidden = true
                                        
                                        AF.request(mPOSSettings, method:.post,encoding: JSONEncoding.default, headers: sGisHeaders).responseJSON
                                        { response in
                                            print("mGeneratePOSToken mPOSSettings response: = \(response)")
                                            CommonClass.stopLoader()
                                            if(response.error != nil) {
                                                
                                            }else{
                                                if let jsonData = response.data {
                                                    let json = try? JSONSerialization.jsonObject(with: jsonData, options: [])
                                                    if let jsonResult = json as? NSDictionary {
                                                        if let mData = jsonResult.value(forKey: "data") as? NSDictionary {
                                                            
                                                            if let mPriceFormat = mData.value(forKey: "price_format") as? NSDictionary {
                                                                if let mStoreCurrency = mPriceFormat.value(forKey: "currency") as? String {
                                                                    UserDefaults.standard.set(mStoreCurrency, forKey: "storeCurrency")
                                                                    
                                                                }else{
                                                                    UserDefaults.standard.set(nil, forKey: "storeCurrency")
                                                                    
                                                                }
                                                                
                                                            }else{
                                                                UserDefaults.standard.set(nil, forKey: "storeCurrency")
                                                                
                                                            }
                                                            
                                                            if let mTaxData = mData.value(forKey: "tax") as? NSDictionary {
                                                                if let mTaxValue = mTaxData.value(forKey: "value") as? Int {
                                                                    UserDefaults.standard.set(mTaxValue, forKey: "taxValue")
                                                                }
                                                                if let mTaxType = mTaxData.value(forKey: "type") as? String {
                                                                    UserDefaults.standard.set(mTaxType, forKey: "taxType")
                                                                }
                                                                if let mCurrency = mData.value(forKey: "symbol") as? String {
                                                                    UserDefaults.standard.set(mCurrency, forKey: "currencySymbol")
                                                                }
                                                            }else{
                                                                UserDefaults.standard.set(nil, forKey: "taxType")
                                                                UserDefaults.standard.set(nil, forKey: "taxValue")
                                                            }
                                                            
                                                            if let reservDeliveryDate = mData.value(forKey: "reserve_delivery") as? String {
                                                                UserDefaults.standard.set(reservDeliveryDate, forKey: "reserveDeliveryDate")
                                                            }
                                                            
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        
                                }
                                }
                            } else if jsonResult.value(forKey: "code") as? Int == 400 {
                                CommonClass.showSnackBar(message: "Failed to Authenticate!")
                            }else if jsonResult.value(forKey: "code") as? Int == 403 {
                                CommonClass.showSnackBar(message: "Session Expired!! Please Re-login.")
                                self.navigationController?.popViewController(animated: true)
                            } else {
                                CommonClass.showSnackBar(message: "OOP's something went wrong!")
                            }
                        }
                    }
                }
                
            }
        }else{
            CommonClass.showSnackBar(message: "No Internet Connection!")
        }
        
        
        
    }
    
    func mClearCart(){
        let defaults = UserDefaults.standard

        // PosCart restores the linked order asynchronously when the user
        // confirms the connected-order leave popup. Do not race that request.
        if defaults.bool(forKey: "connected_order_restore_in_progress") {
            print("HomePage: defer clear cart while linked cart restore is pending")
            return
        }

        // The return to Home immediately after a successful connected-order
        // restore is not a user request to clear the backend cart. Skip only
        // this automatic call, then allow normal cart clearing again.
        let skipUntil = defaults.double(forKey: "connected_order_skip_cart_clear_until")
        if skipUntil > Date().timeIntervalSince1970 {
            print("HomePage: skip automatic clear cart after linked cart restore")
            defaults.removeObject(forKey: "connected_order_skip_cart_clear_until")
            return
        }
        defaults.removeObject(forKey: "connected_order_skip_cart_clear_until")

        print("🔥 HomePage.swift mClearCart called")
        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
        let mLocation = UserDefaults.standard.string(forKey: "location")
        
        let urlPath =  mClearDataApi
        
        if Reachability.isConnectedToNetwork() == true {
            AF.request(urlPath, method:.post, headers: sGisHeaders2).responseJSON
            { response in
                
                if(response.error != nil){
                    
                }else{
                    guard let jsonData = response.data else {return}
                    
                    let json = try? JSONSerialization.jsonObject(with: jsonData, options: [])
                    guard let jsonResult = json as? NSDictionary else {return}
                    
                    if let mCode = jsonResult.value(forKey: "code") as? Int {
                        if mCode == 403 {
                            CommonClass.sessionExpired(isExpired: true, navigation: self.navigationController)
                            return
                        }
                    }
                    
                    if jsonResult.value(forKey: "code") as? Int == 200 {
                        
                    }else{
                        if jsonResult.value(forKey: "error") != nil {
                            if "\(jsonResult.value(forKey: "error") ?? "")" == "Authorization has been expired" {
                                CommonClass.sessionExpired(isExpired: true, navigation: self.navigationController)
                            }
                            
                        }
                    }
                    
                }
                
                
            }
        }else{
        }
        
    }
}
extension UIView {

    func addShadow(offset: CGSize, color: UIColor, radius: CGFloat, opacity: Float) {
        layer.masksToBounds = false
        layer.shadowOffset = offset
        layer.shadowColor = color.cgColor
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity

        let backgroundCGColor = backgroundColor?.cgColor
        backgroundColor = nil
        layer.backgroundColor =  backgroundCGColor
    }
    
    
}
