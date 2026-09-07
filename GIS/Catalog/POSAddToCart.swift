//
//  POSAddToCart.swift
//  GIS
//
//  Created by Apple Hawkscode on 12/04/21.
//

import UIKit
import DropDown
import Alamofire


class ProductImageCell :UICollectionViewCell {
    
    @IBOutlet weak var mProductImage: UIImageView!
    
}

class ProductLocationCell : UITableViewCell {
    
    @IBOutlet weak var mLocationFlag: UIImageView!

    @IBOutlet weak var mLocationName: UILabel!
    
    @IBOutlet weak var mLocationQty: UILabel!
}

var posTabBarInstance: POSTabBarController?

class POSAddToCart: UIViewController , UICollectionViewDelegate , UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate, UIViewControllerTransitioningDelegate ,UITableViewDelegate, UITableViewDataSource, GetCustomerDataDelegate{

    private var selectedSalesPersonId: String {
        return (UserDefaults.standard.string(forKey: "SALESPERSONID") ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func mCreateNewCustomer() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "reserveBoard", bundle: nil)
        if let mCreateCustomer = storyBoard.instantiateViewController(withIdentifier: "CreateCustomer") as? CreateCustomer {
            self.navigationController?.pushViewController(mCreateCustomer, animated:true)
        }
    }
    
    func mGetCustomerData(data: NSMutableDictionary) {
        
        if let id = data.value(forKey: "id") as? String {
            UserDefaults.standard.set(id, forKey: "DEFAULTCUSTOMER")
            self.mCustomerId = id
        }

//        if let profile = data.value(forKey: "profile") as? String {
//            UserDefaults.standard.set(profile, forKey: "DEFAULTCUSTOMERPICTURE")
//            self.mCustomerImage.downlaodImageFromUrl(urlString: profile)
//        }
//        self.mCustomerImage.downlaodImageFromUrl(urlString: UserDefaults.standard.string(forKey: "SALESPERSON_IMAGE") ?? "")
     
        if let name = data.value(forKey: "name") as? String {
            UserDefaults.standard.set(name, forKey: "DEFAULTCUSTOMERNAME")
        }
           
//        self.mCheckUncheckCustomer.image = UIImage(named: "selected_customer")
//        mSkipCount = 0
        
//        if !SiriID.isEmpty {
//                       mSearchField.text = SiriID
//                       print("Searching with SiriID: \(SiriID)")
////                       self.mGetCatalogs(key: SiriID)
//                        self.performSearch(SiriID)
//                   } else {
////                       self.mGetCatalogs(key: "")
//                       self.performSearch("")
//                   }

    }
    
   
    
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var mTotalCount: UILabel!
    @IBOutlet weak var mProductCollectionView: UICollectionView!
    @IBOutlet weak var mProductImage: UIImageView!
    
    @IBOutlet weak var mMetaTag: UITextView!
    @IBOutlet weak var mPageController: UIPageControl!
    @IBOutlet weak var mSize: UILabel!
    
    @IBOutlet weak var mSKUName: UITextView!
    @IBOutlet weak var mMetalView: UIView!
    
    @IBOutlet weak var mStoneView: UIView!
    @IBOutlet weak var mChooseMetalButt: UIButton!
    @IBOutlet weak var mChooseStoneButt: UIButton!
    @IBOutlet weak var mChooseSizeButt: UIButton!
    @IBOutlet weak var mProductName: UITextView!
    
    @IBOutlet weak var mReferenceNo: UILabel!
    @IBOutlet weak var mChooseShapeButton: UIButton!
    @IBOutlet weak var mChoosePointerButton: UIButton!
    @IBOutlet weak var mDescription: UITextView!
    @IBOutlet weak var mPrice: UILabel!
    @IBOutlet weak var mMetalName: UITextField!
    @IBOutlet weak var mStoneName: UITextField!
    @IBOutlet weak var mSizeName: UITextField!
    
    @IBOutlet weak var mPointerView: UIView!
    @IBOutlet weak var mShapeView: UIView!
    @IBOutlet weak var mShapeName: UITextField!
    @IBOutlet weak var mPointerName: UITextField!
    var mStoneList = [String]()
    var mMetalList = [String]()
    
    var mStoneIdList = [String]()
    var mMetalIdList = [String]()
    var mChoiceData = NSArray()

    @IBOutlet weak var mHeart: UIImageView!
    var mSizeList = [String]()
    var mSizeIdList = [String]()
    var mShapeList = [String]()
    var mShapeIdList = [String]()
    var mPointerList = [String]()
    var mPointerdIdList = [String]()
    var mMetalId = ""
    var mStoneId = ""
    var mSizeId = ""
    var mShapeId = ""
    var mPointerId = ""
    var mData = NSDictionary()
    var mImageData = NSArray()
    var mProductId = ""
    var mSKU = ""
    var mPointerdPriceList = [String]()
    var mSelectedPointerPrice = ""

    var mType = ""
    var isWishListed = ""
    var mCustomerId = ""

   
    @IBOutlet weak var mHeading: UILabel!

    @IBOutlet weak var mPStoneWeight: UILabel!
    @IBOutlet weak var mPStoneName: UILabel!
    @IBOutlet weak var mPMetalWeight: UILabel!
    @IBOutlet weak var mPMetalName: UILabel!
    @IBOutlet weak var mAddToCartBUTTON: UIButton!
    @IBOutlet weak var mSizeView: UIView!
    @IBOutlet weak var mMetalLABEL: UILabel!
    
    @IBOutlet weak var mStoneLABEL: UILabel!
    
    @IBOutlet weak var mSizeLABEL: UILabel!
    
    @IBOutlet weak var mPointerLABEL: UILabel!
    @IBOutlet weak var mShapeLABEL: UILabel!
    
    @IBOutlet weak var mDescriptionLABEL: UILabel!
    
    @IBOutlet weak var mOrderNowButton: UIButton!
    @IBOutlet weak var mProductSummaryLABEL: UILabel!
    @IBOutlet weak var mMaterialLABEL: UILabel!
    @IBOutlet weak var mPStoneLABEL: UILabel!
    @IBOutlet weak var mReferenceNoLABEL: UILabel!
    @IBOutlet weak var mCertificateLABEL: UILabel!
    @IBOutlet weak var mHeartTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var ic_infomation: UIImageView!
    
    
    var mProductIdForImage = ""
    var mSKUForImage = ""
    
    var mVarientProductId = ""
    
    // Prevent stale async responses from updating UI
    private var latestVariantRequestToken = UUID()
    private var latestSummaryRequestToken = UUID()
    
    var hasResolvedInitialVariant = false
    
    var mLocationData = NSArray()
    var mLocationNameData = NSArray()
    @IBOutlet weak var mLocationTable: UITableView!
    @IBOutlet weak var mLocationTableHeight: NSLayoutConstraint!
    
    @IBOutlet weak var mDownloadButton: UIButton!
    
    var isLocationExpanded = false
    
//    @IBOutlet weak var mLocationTableView: UITableView!
    @IBOutlet weak var mLocationHeight: NSLayoutConstraint!
    @IBOutlet weak var mLocationArrow: UIImageView!     // หรือ UIButton
    @IBOutlet weak var mLocationCount: UILabel!
    
    
    override func viewWillAppear(_ animated: Bool) {

        
        
        mProductSummaryLABEL.text = "Product Summary".localizedString
        mMaterialLABEL.text = "Material".localizedString
        mPStoneLABEL.text = "Stone".localizedString
        mReferenceNoLABEL.text = "Reference No.".localizedString
        mCertificateLABEL.text = "Certificate".localizedString

        mDescriptionLABEL.text = "Description".localizedString
        mMetalLABEL.text = "Metal".localizedString
        mStoneLABEL.text = "Stone".localizedString
        mSizeLABEL.text = "Size".localizedString

        mStoneName.placeholder = "Select".localizedString
        mMetalName.placeholder = "Select".localizedString
        mSizeName.placeholder = "Select".localizedString
        print("mHeading = \(mHeading.text!)")
        if(mHeading.text == "Catalog") {
            mAddToCartBUTTON.setTitle("ADD TO ORDER".localizedString, for: .normal)
        }
        else {
            mAddToCartBUTTON.setTitle("ADD TO CART".localizedString, for: .normal)
        }
        mOrderNowButton.setTitle("ORDER".localizedString, for: .normal)
        
        if mCustomerId == "" {
            mHeart.isHidden = true
        }else{
            mHeart.isHidden = false
        }
        
        mFetchCatalogDetails()
    }
    
    var mStoreCurrency = "$"

    func mFetchVariantProductSummary(
        variantId: String,
        variantSKU: String
    ) {

        let requestToken = UUID()
        latestSummaryRequestToken = requestToken

        let location =
            UserDefaults.standard.string(forKey: "location") ?? ""

        let params: [String: Any] = [
            "product_id": self.mProductId,
            "search": "",
            "sku": variantSKU,
            "type": self.mType,
            "metal": [],
            "size": [],
            "stone": [],
            "location": location,
            "shape": [],
            "pointer": [],
            "isWishlist": self.isWishListed
        ]

        print("========== FETCH VARIANT SUMMARY ==========")
        print("🔥 REQUEST TOKEN =", requestToken)
        print("🔥 VARIANT ID =", variantId)
        print("🔥 VARIANT SKU =", variantSKU)
        print("🔥 PARAMS =", params)
        print("===========================================")

        mGetData(
            url: mGetCatalogDetails,
            headers: sGisHeaders,
            params: params
        ) { [weak self] response, status in

            guard let self = self else {
                return
            }

            print("========== VARIANT SUMMARY RESPONSE ==========")
            print("🔥 REQUEST TOKEN =", requestToken)
            print("🔥 LATEST TOKEN =", self.latestSummaryRequestToken)
            print("🔥 VARIANT ID =", variantId)
            print("🔥 VARIANT SKU =", variantSKU)
            print("🔥 STATUS =", status)
            print("🔥 RESPONSE =", response)
            print("==============================================")

            guard requestToken == self.latestSummaryRequestToken else {
                print("🛑 IGNORE STALE SUMMARY RESPONSE")
                print("🛑 STALE SKU =", variantSKU)
                return
            }

            guard variantId == self.mVarientProductId else {
                print("🛑 IGNORE SUMMARY — VARIANT NO LONGER CURRENT")
                print("🛑 RESPONSE VARIANT =", variantId)
                print("🛑 CURRENT VARIANT =", self.mVarientProductId)
                return
            }

            guard status,
                  "\(response.value(forKey: "code") ?? "")" == "200",
                  let data =
                    response.value(forKey: "data") as? NSDictionary,
                  let productDetails =
                    data.value(forKey: "productdata_details") as? NSDictionary
            else {
                print("❌ VARIANT SUMMARY NOT FOUND")
                return
            }

            DispatchQueue.main.async {

                guard requestToken == self.latestSummaryRequestToken else {
                    print("🛑 IGNORE STALE SUMMARY ON MAIN THREAD")
                    return
                }

                guard variantId == self.mVarientProductId else {
                    print("🛑 IGNORE SUMMARY ON MAIN THREAD — VARIANT CHANGED")
                    return
                }

                self.updateVariantProductSummary(productDetails)
            }
        }
    }
    
    func updateStoneSummary(from stones: [[String: Any]]) {
        print("updateStoneSummary = \(stones)")
        var order: [String] = []
        var dict: [String:(pcs:Int, weight:Double)] = [:]

        for stone in stones {

            let name = "\(stone["stone_name"] ?? "")"
                .trimmingCharacters(in: .whitespacesAndNewlines)

            guard !name.isEmpty else { continue }

            let pcs = Int("\(stone["Pcs"] ?? "0")") ?? 0
            let wt  = Double("\(stone["Cts"] ?? "0")") ?? 0

            if var value = dict[name] {

                value.pcs += pcs
                value.weight += wt
                dict[name] = value

            } else {

                order.append(name)
                dict[name] = (pcs, wt)
            }
        }

        var names:[String] = []
        var weights:[String] = []

        for name in order {

            guard let item = dict[name] else { continue }

            names.append(name)

            weights.append(
                "\(item.pcs)        \(String(format: "%.2f", item.weight))c"
            )
        }

        mPStoneName.text = names.joined(separator: "\n")
        mPStoneWeight.text = weights.joined(separator: "\n")

        if names.isEmpty {

            mPStoneName.text = "--"
            mPStoneWeight.text = "--"

        }
    }
    
    func updateVariantProductSummary(
        _ productData: NSDictionary
    ) {

        print("========== UPDATE VARIANT SUMMARY ==========")
        print("🔥 SKU =", productData["SKU"] ?? "")
        print("🔥 STONES =", productData["stones"] ??
                             productData["Stones"] ??
                             "NO STONES")
        print("🔥 REFERENCE =", productData["referenceNo"] ?? "")
        print("🔥 GROSS WT =", productData["GrossWt"] ?? "")
        print("============================================")

//        self.mPMetalName.text =
//            "\(productData["metal_name"] ?? "--")"
        let metalCode =
            "\(productData["metal_name"] ?? productData["Metal_name"] ?? "")"
        self.mMetalName.text = self.getFullMetalName(metalCode)

        self.mPMetalWeight.text =
            "\(productData["GrossWt"] ?? "--")g"

        self.mReferenceNo.text =
            "\(productData["referenceNo"] ?? "--")"

//        if let stones = productData["stones"] as? [[String:Any]] {
//
//            updateStoneSummary(from: stones)
//
//        }
        if let stones = productData["stones"] as? [[String: Any]] {

            updateStoneSummary(from: stones)

        } else if let stones = productData["Stones"] as? [[String: Any]] {

            updateStoneSummary(from: stones)

        } else if let stones = productData["Stones"] as? NSArray {

            updateStoneSummary(from: stones as! [[String: Any]])

        } else {

            mPStoneName.text = "--"
            mPStoneWeight.text = "--"
        }
        
    }
    
    
    func getFullMetalName(_ code: String) -> String {
        switch code.uppercased() {
        case "WG":
            return "White Gold"

        case "YG":
            return "Yellow Gold"

        case "RG":
            return "Rose Gold"

        default:
            return code
        }
    }
    
    
    func mFetchCatalogDetails() {
        
        mSizeList.removeAll()
        mSizeIdList.removeAll()

        mMetalList.removeAll()
        mMetalIdList.removeAll()

        mStoneList.removeAll()
        mStoneIdList.removeAll()

        mShapeList.removeAll()
        mShapeIdList.removeAll()

        mPointerList.removeAll()
        mPointerdIdList.removeAll()
        mPointerdPriceList.removeAll()
        
        let mLocation = UserDefaults.standard.string(forKey: "location")
        
//        let params:[String: Any] = ["product_id" : mProductId, "search":"",
//                                            "sku":"\(mData.value(forKey: "SKU") ?? "")",
//                                            "type":mType,
//                                            "metal":[],
//                                            "size":[],
//                                            "stone":[],
//                                            "location":mLocation ?? "",
//                                            "shape":[],
//                                            "pointer":[],
//                                            "isWishlist":isWishListed]
            let params:[String: Any] = [
                "product_id" : mProductId,
                "search":"",
                "sku": mSKU,
                "type":mType,
                "metal":[],
                "size":[],
                "stone":[],
                "location":mLocation ?? "",
                "shape":[],
                "pointer":[],
                "isWishlist":isWishListed
            ]
                print("params = \(params)")
                CommonClass.showFullLoader(view: view)
        
                print("""
                ========== SCAN ADD CART DEBUG ==========
                TYPE = \(mType)
                PRODUCT_ID = \(mProductId)
                SKU = \(mSKU)
                =========================================
                """)
        
                print("========== FETCH DETAIL DEBUG ==========")
                print("TYPE =", self.mType)
                print("PRODUCT ID =", self.mProductId)
                print("SKU =", self.mSKU)
                print("PARAMS =", params)
                print("========================================")
                CommonClass.showFullLoader(view: self.view)
                mGetData(url: mGetCatalogDetails,headers: sGisHeaders,  params: params) { response , status in
                    DispatchQueue.main.async {
                                CommonClass.stopLoader()
                            }
                    print("🔥 CATALOG DETAILS RESPONSE =", response)
                    print("🔥 CATALOG DETAILS STATUS =", status)
                    if status {
                        
                        guard let statusCode = response.value(forKey: "code") as? Int else {
                            CommonClass.showSnackBar(message: "Oops! Something went wrong.")
                            return
                        }
                        
                        if statusCode == 200 {
                           
                            if let mData = response.value(forKey: "data") as? NSDictionary,
                               let mProductData = mData.value(forKey: "productdata_details") as? NSDictionary {
                                
                                print("========== CLEO PRODUCT SUMMARY DEBUG ==========")
                                print("🔥 PRODUCT ID =", self.mProductId)
                                print("🔥 VARIANT ID =", self.mVarientProductId)
                                print("🔥 SKU =", mProductData["SKU"] ?? "nil")
                                print("🔥 stone_name =", mProductData["stone_name"] ?? "nil")
                                print("🔥 stones =", mProductData["stones"] ?? "nil")
                                print("🔥 Stones =", mProductData["Stones"] ?? "nil")
                                print("🔥 stoneData =", mProductData["stoneData"] ?? "nil")
                                print("🔥 FULL PRODUCT DATA =", mProductData)
                                print("================================================")
                                
                                self.mProductName.text = "\(mProductData.value(forKey: "name") ?? "--" )"
                                self.mMetaTag.text = "\(mProductData.value(forKey: "Matatag") ?? "--" )"
                                self.mSKUName.text = "\(mProductData.value(forKey: "SKU") ?? "--")"
                                self.mDescription.text = "\(mProductData.value(forKey: "description") ?? "--")"
                                self.mSizeName.text = "\(mProductData.value(forKey: "size_name") ?? "--" )"
                                self.mReferenceNo.text = "\(mProductData.value(forKey: "referenceNo") ?? "--" )"
                                
//                                self.mMetalName.text = "\(mProductData.value(forKey: "metal_name") ?? "--" )"
                                let metalCode =
                                    "\(mProductData["metal_name"] ?? mProductData["Metal_name"] ?? "")"
                                self.mMetalName.text = self.getFullMetalName(metalCode)
                                self.mStoneName.text = "\(mProductData.value(forKey: "stone_name") ?? "--" )"
                                
                                self.mShapeName.text = "\(mProductData.value(forKey: "shape_name") ?? "")"
                                self.mPointerName.text = "\(mProductData.value(forKey: "pointer_name") ?? "")"
                                
                                
                                self.mPMetalName.text = self.getFullMetalName(metalCode) /*"\(mProductData.value(forKey: "metal_name") ?? "--" )"*/
                                self.mPMetalWeight.text = "\(mProductData.value(forKey: "GrossWt") ?? "--" )g"
                                
                                print("viewDidLoad DEBUG PRODUCT STONES =", mProductData["stones"] ?? "NO STONES")
                                print("viewDidLoad DEBUG GROSS WT =", mProductData["GrossWt"] ?? "NO GROSS WT")
                                print("viewDidLoad DEBUG REFERENCE =", mProductData["referenceNo"] ?? "NO REFERENCE")
                                
//                                if let stones = mProductData["stones"] as? [[String:Any]] {
//
//                                    self.updateStoneSummary(from: stones)
//
//                                }
                                if let stones = mProductData["stones"] as? [[String: Any]] {

                                    self.updateStoneSummary(from: stones)

                                } else if let stones = mProductData["Stones"] as? [[String: Any]] {

                                    self.updateStoneSummary(from: stones)

                                } else if let stones = mProductData["Stones"] as? NSArray {

                                    self.updateStoneSummary(from: stones as! [[String: Any]])

                                } else {

                                    self.mPStoneName.text = "--"
                                    self.mPStoneWeight.text = "--"
                                }
//                                let formatter = NumberFormatter()
//                                formatter.numberStyle = .decimal
//                                formatter.minimumFractionDigits = 2
//                                formatter.maximumFractionDigits = 2
//
//                                let price = Double("\(mProductData.value(forKey: "price") ?? "0")") ?? 0.0
//                                let formattedPrice = formatter.string(from: NSNumber(value: price)) ?? "0.00"
//                                print("mGetCatalogDetails \(price) self.mPrice = \(formattedPrice)")
//                                self.mPrice.text = "\(self.mStoreCurrency) \(formattedPrice)"
                                self.mPrice.text =  "\(mProductData.value(forKey: "price") ?? "0.00" )"
                                self.mSelectedPointerPrice = " \(mProductData.value(forKey: "price") ?? "0.00" )"
                                //BaseVarientId
                                self.mVarientProductId = "\(mData.value(forKey: "baseVariant_id") ?? "")"
                                
                                self.mProductImage.downlaodImageFromUrl(urlString: "\(mProductData.value(forKey: "images") ?? "")")
                                let sku = "\(mProductData.value(forKey: "SKU") ?? "")"
                                self.mSKUForImage = (!sku.isEmpty) ? sku : self.mSKUForImage
                                self.mProductIdForImage = (!self.mVarientProductId.isEmpty) ? self.mVarientProductId : self.mProductIdForImage
                                
                                if let mArr = mData.value(forKey:"Size_arr") as? NSArray, mArr.count > 0 {
                                    
                                    if "\(mProductData.value(forKey: "size_name") ?? "")" == "" {
                                        if let data = mArr[0] as? NSDictionary {
                                            self.mSizeName.text = "\(data.value(forKey: "sizeName") ?? "")"
                                            self.mSizeId = "\(data.value(forKey: "id") ?? "")"
                                        }
                                    }
                                    
                                    for i in mArr {
                                        if let sizeData = i as? NSDictionary {
                                            if let sizeName = sizeData.value(forKey:"sizeName") as? String,
                                               let sizeId = sizeData.value(forKey:"id") as? String{
                                                self.mSizeList.append(sizeName)
                                                self.mSizeIdList.append(sizeId)
                                                
                                                if "\(mProductData.value(forKey: "size_name") ?? "")" == sizeName {
                                                    self.mSizeId = sizeId
                                                    self.mSizeName.text = sizeName
                                                }
                                            }
                                        }
                                    }
                                    
                                }else{
                                    self.mSizeView.isHidden = false
                                    self.mSizeId = ""
                                }
                                
                                if let metalArr = mData.value(forKey:"metalArr") as? NSArray,
                                   metalArr.count > 0 {
                                    if let productMetalName = mProductData.value(forKey: "metal_name") as? String,
                                       productMetalName.isEmpty,
                                       let data = metalArr[0] as? NSDictionary {
//                                        self.mMetalName.text = "\(data.value(forKey: "metalName") ?? "")"
                                        let metalCode =
                                            "\(mProductData["metal_name"] ?? mProductData["Metal_name"] ?? "")"
                                        self.mMetalName.text = self.getFullMetalName(metalCode)
                                        self.mMetalId = "\(data.value(forKey: "id") ?? "")"
                                    }
                                    
                                    for i in metalArr {
                                        if let data = i as? NSDictionary,
                                           let metalName = data.value(forKey: "metalName") as? String,
                                           let metalId = data.value(forKey: "id") as? String {
                                            
                                            self.mMetalList.append("\(metalName) ")
                                            self.mMetalIdList.append("\(metalId)")
                                            
                                            if let productMetalName = mProductData.value(forKey: "metal_name") as? String,
                                               productMetalName == metalName {
                                                self.mMetalId = metalId
//                                                self.mMetalName.text = metalName
                                                self.mMetalName.text = self.getFullMetalName(metalName)
                                            }
                                        }
                                    }
                                    
                                } else {
//                                    self.mMetalView.isHidden = true
                                    self.mMetalView.isHidden = false
                                }

                                if let mArr = mData.value(forKey:"shapeArr") as? NSArray,
                                   mArr.count > 0{
                                    
                                    if "\(mProductData.value(forKey: "shape_name") ?? "")" == "" {
                                        if let data = mArr[0] as? NSDictionary {
                                            self.mShapeName.text = "\(data.value(forKey: "shapeName") ?? "")"
                                            self.mShapeId = "\(data.value(forKey: "id") ?? "")"
                                        }
                                    }
                                    
                                    for i in mArr {
                                        if let data = i as? NSDictionary {
                                            if let shapeName = data.value(forKey:"shapeName") as? String,
                                               let shapeId = data.value(forKey:"id") as? String{
                                                self.mShapeList.append(shapeName)
                                                self.mShapeIdList.append(shapeId)
                                                
                                                if "\(mProductData.value(forKey: "shape_name") ?? "")" == shapeName {
                                                    self.mShapeId = shapeId
                                                    self.mShapeName.text = shapeName
                                                }
                                            }
                                        }
                                    }
                                    
                                }else{
                                    self.mShapeView.isHidden = true
                                }
                                if let stoneArr = mData.value(forKey: "stoneArr") as? NSArray,
                                   stoneArr.count > 0 {
                                    // Clear old data first
                                    self.mStoneList.removeAll()
                                    self.mStoneIdList.removeAll()

                                    print("DEBUG stoneArr =", stoneArr)
                                    print("DEBUG PRODUCT stone_name =",
                                          mProductData.value(forKey: "stone_name") ?? "")
                                    // Build dropdown data
                                    for item in stoneArr {
                                        guard let data = item as? NSDictionary else {
                                            continue
                                        }

                                        let stoneName = "\(data.value(forKey: "stoneName") ?? "")"
                                        let stoneId = "\(data.value(forKey: "id") ?? "")"

                                        self.mStoneList.append(stoneName)
                                        self.mStoneIdList.append(stoneId)
                                    }
                                    // Keep current selected stone if it still exists.
                                    // Use first stone only for initial load.
                                    if self.mStoneId.isEmpty {
                                        if let firstStone = stoneArr.firstObject as? NSDictionary {

                                            let firstStoneName =
                                                "\(firstStone.value(forKey: "stoneName") ?? "")"

                                            let firstStoneId =
                                                "\(firstStone.value(forKey: "id") ?? "")"

                                            self.mStoneName.text = firstStoneName
                                            self.mStoneId = firstStoneId

                                            print("🔥 INITIAL STONE NAME =", firstStoneName)
                                            print("🔥 INITIAL STONE ID =", firstStoneId)
                                        }
                                    } else {
                                        // Restore currently selected stone name
                                        for item in stoneArr {

                                            guard let stone = item as? NSDictionary else {
                                                continue
                                            }

                                            let stoneId =
                                                "\(stone.value(forKey: "id") ?? "")"

                                            if stoneId == self.mStoneId {

                                                self.mStoneName.text =
                                                    "\(stone.value(forKey: "stoneName") ?? "")"

                                                print("🔥 KEEP SELECTED STONE =", self.mStoneName.text ?? "")
                                                print("🔥 KEEP SELECTED STONE ID =", self.mStoneId)

                                                break
                                            }
                                        }
                                    }
                                    self.mStoneView.isHidden = false
                                    
                                } else {

                                    self.mStoneList.removeAll()
                                    self.mStoneIdList.removeAll()

                                    self.mStoneName.text = "--"
                                    self.mStoneId = ""

                                    self.mStoneView.isHidden = true
                                }
                                
//                                if let locationArray = mData.value(forKey: "location_arr") as? [[String: Any]] {
//
//                                    var totalQty = 0
//                                    var locArr: [[String: Any]] = []
//                                        for item in locationArray {
//                                            if let name = item["location_name"] as? String {
//                                                   // totalQty += qty
//                                                    locArr.append(item)
//                                           }
//                                        }
//
//                                    self.mLocationData = locArr as NSArray
//                                    if locationArray.count != 0 {
//                                        self.mTotalCount.text = "(\(locationArray.count))"
//                                    }
//                                    let height = locArr.count * 40
//                                    self.mLocationTableHeight.constant = CGFloat(height)
//                                    self.mLocationTable.reloadData()
//
//                                } else {
//                                    self.mTotalCount.text = "(0)"
//                                }
                                
                                // =====================================================
                                // LOCATION / STOCK DATA
                                // =====================================================

                                var locationArray: [[String: Any]] = []

                                // 1. New API key
                                if let data = mData.value(forKey: "location_data") as? [[String: Any]] {

                                    print("========== LOCATION DATA ==========")
                                    print("🔥 SOURCE = location_data")
                                    print("🔥 COUNT =", data.count)
                                    print("🔥 DATA =", data)
                                    print("===================================")

                                    locationArray = data

                                }

                                // 2. Backward compatibility
                                else if let data = mData.value(forKey: "location_arr") as? [[String: Any]] {

                                    print("========== LOCATION DATA ==========")
                                    print("🔥 SOURCE = location_arr")
                                    print("🔥 COUNT =", data.count)
                                    print("🔥 DATA =", data)
                                    print("===================================")

                                    locationArray = data
                                }

                                // 3. Fallback from inventory_statistics
                                else if let inventoryStatistics =
                                            mData.value(forKey: "inventory_statistics") as? NSDictionary,
                                        let response =
                                            inventoryStatistics.value(forKey: "response") as? [[String: Any]] {

                                    print("========== LOCATION DATA ==========")
                                    print("🔥 SOURCE = inventory_statistics.response")
                                    print("🔥 COUNT =", response.count)
                                    print("🔥 DATA =", response)
                                    print("===================================")

                                    locationArray = response
                                }

                                // 4. No location data
                                else {

                                    print("========== LOCATION DATA ==========")
                                    print("❌ NO LOCATION DATA FOUND")
                                    print("🔥 AVAILABLE KEYS =", mData.allKeys)
                                    print("===================================")

                                    locationArray = []
                                }


                                // =====================================================
                                // UPDATE LOCATION UI
                                // =====================================================

                                self.mLocationData = locationArray as NSArray

                                let locationCount = locationArray.count

                                self.mTotalCount.text = "(\(locationCount))"

                                self.mLocationTableHeight.constant =
                                    CGFloat(locationCount * 40)

                                self.mLocationTable.reloadData()

                                print("========== LOCATION UI UPDATED ==========")
                                print("🔥 LOCATION COUNT =", locationCount)
                                print("🔥 TABLE HEIGHT =", self.mLocationTableHeight.constant)
                                print("🔥 TABLE HIDDEN =", self.mLocationTable.isHidden)
                                print("==========================================")
                                // =====================================================
                                // MARK: - Shape / Pointer / Choice Data
                                // =====================================================

                                let choiceData =
                                    mData.value(forKey: "choice_data") as? NSArray ?? []

                                print("========== CHOICE / VARIANT DEBUG ==========")
                                print("🔥 choice_data count =", choiceData.count)
                                print("🔥 choice_data =", choiceData)

                                print("🔥 product shape_name =",
                                      mProductData.value(forKey: "shape_name") ?? "")

                                print("🔥 product shape_id =",
                                      mProductData.value(forKey: "shape_id") ?? "")

                                print("🔥 product pointer_name =",
                                      mProductData.value(forKey: "pointer_name") ?? "")

                                print("🔥 product pointer_id =",
                                      mProductData.value(forKey: "pointer_id") ?? "")

                                print("🔥 product price =",
                                      mProductData.value(forKey: "price") ?? "")

                                print("=============================================")


                                // =====================================================
                                // CASE 1 : NON-VARIANT PRODUCT
                                // choice_data = []
                                // =====================================================

                                if choiceData.count == 0 {

                                    print("🟡 NON VARIANT PRODUCT")

                                    self.mShapeView.isHidden = true
                                    self.mPointerView.isHidden = true

                                    self.mMetalView.isHidden = false
                                    self.mStoneView.isHidden = false
                                    self.mSizeView.isHidden = false


                                    // =====================================================
                                    // DEFAULT METAL
                                    // Priority:
                                    // 1. metalArr
                                    // 2. productdata_details
                                    // =====================================================

                                    if let metalArr = mData["metalArr"] as? NSArray,
                                       metalArr.count > 0,
                                       let metal = metalArr.firstObject as? NSDictionary {


                                        let metalName =
                                        "\(metal["metalName"] ?? "")"


                                        let metalId =
                                        "\(metal["id"] ?? "")"


                                        self.mMetalName.text =
                                        self.getFullMetalName(metalName)

                                        self.mMetalId = metalId


                                        print("🔥 DEFAULT METAL FROM metalArr =",
                                              metalName)


                                    } else {


                                        let metalName =
                                        "\(mProductData["metal_name"] ?? "")"


                                        self.mMetalName.text =
                                        self.getFullMetalName(metalName)


                                        print("🔥 DEFAULT METAL FROM PRODUCT =",
                                              metalName)
                                    }



                                    // =====================================================
                                    // DEFAULT STONE
                                    // Priority:
                                    // 1. stoneArr
                                    // 2. productdata_details
                                    // =====================================================

                                    if let stoneArr = mData["stoneArr"] as? NSArray,
                                       stoneArr.count > 0,
                                       let stone = stoneArr.firstObject as? NSDictionary {


                                        let stoneName =
                                        "\(stone["stoneName"] ?? "")"


                                        let stoneId =
                                        "\(stone["id"] ?? "")"


                                        self.mStoneName.text = stoneName
                                        self.mStoneId = stoneId


                                        print("🔥 DEFAULT STONE FROM stoneArr =",
                                              stoneName)


                                    } else {


                                        let stoneName =
                                        "\(mProductData["stone_name"] ?? "")"


                                        let firstStone =
                                        stoneName
                                            .components(separatedBy: ",")
                                            .first?
                                            .trimmingCharacters(in: .whitespaces)
                                            ?? ""


                                        self.mStoneName.text = firstStone


                                        print("🔥 DEFAULT STONE FROM PRODUCT =",
                                              firstStone)
                                    }




                                    // =====================================================
                                    // DEFAULT SIZE
                                    // Priority:
                                    // 1. Size_arr
                                    // 2. productdata_details
                                    // =====================================================


                                    if let sizeArr = mData["Size_arr"] as? NSArray,
                                       sizeArr.count > 0,
                                       let size = sizeArr.firstObject as? NSDictionary {


                                        let sizeName =
                                        "\(size["sizeName"] ?? "")"


                                        let sizeId =
                                        "\(size["id"] ?? "")"


                                        self.mSizeName.text = sizeName
                                        self.mSizeId = sizeId


                                        print("🔥 DEFAULT SIZE FROM Size_arr =",
                                              sizeName)


                                    } else {


                                        let sizeName =
                                        "\(mProductData["size_name"] ?? "")"


                                        if sizeName.isEmpty {

                                            self.mSizeName.text =
                                            "Not Available"

                                            self.mSizeId = ""

                                        } else {

                                            self.mSizeName.text =
                                            sizeName
                                        }


                                        print("🔥 DEFAULT SIZE FROM PRODUCT =",
                                              self.mSizeName.text ?? "")
                                    }



                                    print("""
                                    ========= FINAL NON VARIANT =========
                                    METAL = \(self.mMetalName.text ?? "")
                                    STONE = \(self.mStoneName.text ?? "")
                                    SIZE  = \(self.mSizeName.text ?? "")
                                    =====================================
                                    """)

                                }


                                // =====================================================
                                // CASE 2 : VARIANT PRODUCT
                                // choice_data has data
                                // =====================================================

                                else {

                                    print("🟢 VARIANT PRODUCT")
                                    print("🟢 choice_data count =", choiceData.count)


                                    self.mShapeList = [String]()
                                    self.mShapeIdList = [String]()


                                    // =================================================
                                    // Build Shape List
                                    // =================================================

                                    for item in choiceData {

                                        guard let data = item as? NSDictionary else {
                                            continue
                                        }

                                        let shapeName =
                                            "\(data.value(forKey: "name") ?? "")"

                                        let shapeId =
                                            "\(data.value(forKey: "id") ?? "")"

                                        print("---------------------------------------------")
                                        print("🔥 CHOICE SHAPE NAME =", shapeName)
                                        print("🔥 CHOICE SHAPE ID   =", shapeId)
                                        print("---------------------------------------------")


                                        self.mShapeList.append(shapeName)
                                        self.mShapeIdList.append(shapeId)


                                        let productShapeName =
                                            "\(mProductData.value(forKey: "shape_name") ?? "")"


                                        // =================================================
                                        // Existing selected shape
                                        // =================================================

                                        if productShapeName == shapeName {

                                            self.mShapeId = shapeId

                                            print("✅ MATCHED SHAPE")
                                            print("✅ mShapeId =", self.mShapeId)


                                            // ---------------------------------------------
                                            // Pointer data
                                            // ---------------------------------------------

                                            if let pointerArray =
                                                data.value(forKey: "data") as? NSArray,
                                               pointerArray.count > 0 {

                                                print("🔥 POINTER COUNT =",
                                                      pointerArray.count)


                                                self.mPointerList = [String]()
                                                self.mPointerdPriceList = [String]()


                                                let productPointerName =
                                                    "\(mProductData.value(forKey: "pointer_name") ?? "")"


                                                // -----------------------------------------
                                                // No selected pointer
                                                // -----------------------------------------

                                                if productPointerName.isEmpty {

                                                    if let firstPointer =
                                                        pointerArray[0] as? NSDictionary {

                                                        let pointer =
                                                            "\(firstPointer.value(forKey: "pointer") ?? "")"

                                                        let price =
                                                            "\(firstPointer.value(forKey: "price") ?? "0.00")"


                                                        self.mPointerName.text = pointer
                                                        self.mPointerId = pointer
                                                        self.mPrice.text = price


                                                        print("🔥 DEFAULT POINTER =", pointer)
                                                        print("🔥 DEFAULT PRICE   =", price)
                                                    }
                                                }


                                                // -----------------------------------------
                                                // Build pointer list
                                                // -----------------------------------------

                                                for pointerItem in pointerArray {

                                                    guard let pointerData =
                                                        pointerItem as? NSDictionary else {
                                                        continue
                                                    }


                                                    let pointer =
                                                        "\(pointerData.value(forKey: "pointer") ?? "0.0")"

                                                    let price =
                                                        "\(pointerData.value(forKey: "price") ?? "0.00")"


                                                    self.mPointerList.append(pointer)
                                                    self.mPointerdPriceList.append(price)


                                                    print("🔥 POINTER =", pointer)
                                                    print("🔥 PRICE   =", price)


                                                    // -------------------------------------
                                                    // Match existing pointer
                                                    // -------------------------------------

                                                    if productPointerName == pointer {

                                                        self.mPointerId = pointer
                                                        self.mPointerName.text = pointer
                                                        self.mPrice.text = price


                                                        print("✅ MATCHED POINTER =", pointer)
                                                        print("✅ MATCHED PRICE   =", price)
                                                    }
                                                }


                                                self.mPointerView.isHidden = false

                                            } else {

                                                print("🟡 No pointer data for selected shape")

                                                self.mPointerView.isHidden = true
                                                self.mPointerId = ""
                                            }
                                        }


                                        // =================================================
                                        // No selected shape
                                        // =================================================

                                        if "\(mProductData.value(forKey: "shape_name") ?? "")".isEmpty {

                                            print("🟡 Product has no selected shape")
                                            print("🟡 Using first available shape")


                                            self.mShapeName.text = shapeName
                                            self.mShapeId = shapeId


                                            // ---------------------------------------------
                                            // Get pointer data from first shape
                                            // ---------------------------------------------

                                            if let pointerArray =
                                                data.value(forKey: "data") as? NSArray,
                                               pointerArray.count > 0 {

                                                self.mPointerList = [String]()
                                                self.mPointerdPriceList = [String]()


                                                if let firstPointer =
                                                    pointerArray[0] as? NSDictionary {

                                                    let pointer =
                                                        "\(firstPointer.value(forKey: "pointer") ?? "0.0")"

                                                    let price =
                                                        "\(firstPointer.value(forKey: "price") ?? "0.00")"


                                                    self.mPointerName.text = pointer
                                                    self.mPointerId = pointer
                                                    self.mPrice.text = price


                                                    print("🔥 DEFAULT SHAPE =", shapeName)
                                                    print("🔥 DEFAULT SHAPE ID =", shapeId)
                                                    print("🔥 DEFAULT POINTER =", pointer)
                                                    print("🔥 DEFAULT PRICE =", price)
                                                }


                                                for pointerItem in pointerArray {

                                                    guard let pointerData =
                                                        pointerItem as? NSDictionary else {
                                                        continue
                                                    }


                                                    let pointer =
                                                        "\(pointerData.value(forKey: "pointer") ?? "0.0")"

                                                    let price =
                                                        "\(pointerData.value(forKey: "price") ?? "0.00")"


                                                    self.mPointerList.append(pointer)
                                                    self.mPointerdPriceList.append(price)
                                                }


                                                self.mPointerView.isHidden = false

                                            } else {

                                                self.mPointerView.isHidden = true
                                                self.mPointerId = ""

                                                print("🟡 First shape has no pointer")
                                            }
                                        }
                                    }


                                    // =================================================
                                    // Show Shape UI
                                    // =================================================

                                    self.mShapeView.isHidden = false


                                    print("========== FINAL CHOICE STATE ==========")
                                    print("🔥 mShapeId =", self.mShapeId)
                                    print("🔥 mShapeName =", self.mShapeName.text ?? "")
                                    print("🔥 mPointerId =", self.mPointerId)
                                    print("🔥 mPointerName =", self.mPointerName.text ?? "")
                                    print("🔥 mPointerList =", self.mPointerList)
                                    print("🔥 mPointerPriceList =", self.mPointerdPriceList)
                                    print("🔥 mPrice =", self.mPrice.text ?? "")
                                    print("========================================")
                                }
                                
                            } else{
                                CommonClass.showSnackBar(message: "Oops! Something went wrong.")
                            }
                            
                        }else {
                            if let error = response.value(forKey: "error") as? String{
                                if error == "Authorization has been expired" {
                                    CommonClass.sessionExpired(isExpired: true, navigation: self.navigationController)
                                } else {
                                    CommonClass.showSnackBar(message: "Error \(statusCode): \(error)")
                                }
                            }
                            if let message = response.value(forKey: "message") as? String {
                                CommonClass.showSnackBar(message: "Error \(statusCode): \(message)")
                            }
                        }
                    }
                    
                }
        
    }
    
//    @objc
//    func mOpenLocation() {
//
//        isLocationExpanded.toggle()
//
//        UIView.animate(withDuration: 0.25) {
//
//            self.mLocationTable.isHidden = !self.isLocationExpanded
//
//            self.mLocationArrow.image = UIImage(named: self.isLocationExpanded ? "bottomic" :"forward_ic")
//
//
//            self.view.layoutIfNeeded()
//        }
//    }
    
    @objc
    func mOpenLocation() {

        print("")
        print("========== OPEN LOCATION ==========")
        print("🔥 BEFORE =", isLocationExpanded)
        print("🔥 LOCATION COUNT =", mLocationData.count)
        print("🔥 TABLE HIDDEN BEFORE =", mLocationTable.isHidden)
        print("🔥 TABLE HEIGHT =", mLocationTableHeight.constant)
        print("===================================")

        guard mLocationData.count > 0 else {

            print("❌ NO LOCATION DATA TO SHOW")
            print("===================================")

            return
        }

        isLocationExpanded.toggle()

        let shouldShow = isLocationExpanded

        print("🔥 AFTER =", shouldShow)

        mLocationTable.isHidden = !shouldShow

        mLocationArrow.image = UIImage(
            named: shouldShow
            ? "bottomic"
            : "forward_ic"
        )

        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }

        print("🔥 TABLE HIDDEN AFTER =", mLocationTable.isHidden)
        print("🔥 TABLE HEIGHT AFTER =", mLocationTableHeight.constant)
        print("===================================")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       print("========== POS ADD CART INIT ==========")
       print("TYPE =", mType)
       print("PRODUCT ID =", mProductId)
       print("SKU =", mSKU)
       print("=======================================")
//        mHeartTrailingConstraint.constant = 24
//        mHeart.transform = CGAffineTransform(translationX: 12, y: 0)
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTapImage))
        tap.delegate = self
        mProductImage.isUserInteractionEnabled = true
        mProductImage.addGestureRecognizer(tap)
        
        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
               
        if let mStoreCurr = UserDefaults.standard.string(forKey: "currencySymbol") {
            self.mStoreCurrency = mStoreCurr
        }
        
        if mType == "catalog" {
            mHeading.text = "Catalog".localizedString
            mOrderNowButton.isHidden = true
//            ic_infomation.image = UIImage(systemName: "eye")
        }else{
            mHeading.text = "Inventory".localizedString
//            ic_infomation.image = UIImage(named: "infomation")
        }
 
        
//        if mType == "inventory" {
//
//            let stockId =
//            "\(mData.value(forKey:"stock_id") ?? "")"
//
//            if !stockId.isEmpty {
//                self.mProductId = stockId
//            }
//
//            self.mProductId =
//            "\(mData.value(forKey:"_id") ?? mData.value(forKey:"product_id") ?? "")"
//
//        }
//        else {
//
//
//            self.mProductId =
//            "\(mData.value(forKey:"_id") ?? mData.value(forKey:"product_id") ?? "")"
//
//
//            self.mSKU =
//            "\(mData.value(forKey:"SKU") ?? mData.value(forKey:"sku") ?? "")"
//
//        }
        
        if mType == "inventory" {

            let productId =
            "\(mData.value(forKey:"product_id") ?? "")"

            let stockId =
            "\(mData.value(forKey:"stock_id") ?? "")"


            if !productId.isEmpty {

                self.mProductId = productId

                print("🔥 USE PRODUCT ID =", productId)

            } else {

                print("❌ PRODUCT ID EMPTY")
                print("STOCK ID =", stockId)

            }
        }
        else {

            self.mProductId =
            "\(mData.value(forKey:"_id") ?? mData.value(forKey:"product_id") ?? "")"


            self.mSKU =
            "\(mData.value(forKey:"SKU") ?? mData.value(forKey:"sku") ?? "")"
        }
        
//        mProductId =  "\(mData.value(forKey: "product_id") ?? "")"
//        mSKU =  "\(mData.value(forKey: "SKU") ?? "")"
        
        if mProductId.isEmpty {

            mProductId =
            "\(mData.value(forKey: "product_id") ?? "")"

        }

        if mSKU.isEmpty {

            mSKU =
            "\(mData.value(forKey: "SKU") ?? "")"

        }
        
//        self.mProductId = "\(mData["product_id"] ?? mData["mother_product_id"] ?? "")"
//
//        self.mSKU = "\(mData["SKU"] ?? mData["sku"] ?? "")"
        
        self.mSKUForImage = mSKU
        self.mProductIdForImage = mProductId
        
        mLocationTable.dataSource = self
        mLocationTable.delegate = self
        mLocationTableHeight.constant = 0
        
        isWishListed =  "\(mData.value(forKey: "isWishlist") ?? "0")"
    
        if isWishListed == "0"{
            mHeart.image = UIImage(systemName: "heart")

            mHeart.tintColor = UIColor(named: "themeExtraLightText1")
        }else{
            mHeart.image = UIImage(systemName: "heart.fill")

            mHeart.tintColor = UIColor(named: "themeLightRed")
        }
//        mProductImage.downlaodImageFromUrl(urlString: "\(mData.value(forKey: "main_image") ?? "")")
        let imageURL = "\(mData["main_image"] ?? mData["imageUrl"] ?? "")"

        mProductImage.downlaodImageFromUrl( urlString: imageURL)
        
        
        isLocationExpanded = false
        mLocationTable.isHidden = true
        mLocationHeight.constant = 50

//        mLocationArrow.image = UIImage(systemName: "chevron.right")
        self.mLocationArrow.image = UIImage(named: "forward_ic")
        
//        mLocationArrow.isUserInteractionEnabled = true
//
//        let tapp = UITapGestureRecognizer(
//            target: self,
//            action: #selector(mOpenLocation)
//        )
//
//        mLocationArrow.addGestureRecognizer(tapp)

        // =====================================================
        // LOCATION / STOCK TAP
        // =====================================================

        mLocationArrow.isUserInteractionEnabled = true

        let arrowTap = UITapGestureRecognizer(
            target: self,
            action: #selector(mOpenLocation)
        )

        mLocationArrow.addGestureRecognizer(arrowTap)


        // Allow tapping the whole location/stock container
        if let locationContainer = mLocationArrow.superview {

            locationContainer.isUserInteractionEnabled = true

            let containerTap = UITapGestureRecognizer(
                target: self,
                action: #selector(mOpenLocation)
            )

            locationContainer.addGestureRecognizer(containerTap)

            print("✅ LOCATION CONTAINER TAP ENABLED")
        }
        
//        if self.mVarientProductId.isEmpty ||
//           self.mVarientProductId == self.mProductId {
//            if !self.hasResolvedInitialVariant {
//
//                self.hasResolvedInitialVariant = true
//
//                print("========== INITIAL VARIANT RESOLVE ==========")
//                print("🔥 PRODUCT ID =", self.mProductId)
//                print("🔥 VARIANT ID BEFORE =", self.mVarientProductId)
//                print("🔥 METAL ID =", self.mMetalId)
//                print("🔥 STONE ID =", self.mStoneId)
//                print("🔥 SIZE ID =", self.mSizeId)
//                print("=============================================")
//
//                self.mUpdateData()
//            }
//        }
        
        CommonClass.stopLoader()
        
        print("")
        print("================================")
        print("🔥 POS ADD TO CART OPEN")
        print("🔥 TYPE =", mType)
        print("🔥 mData =", mData)
        print("🔥 PRODUCT ID =", mProductId)
        print("🔥 SKU =", mSKU)
        print("================================")
    }
    
    func truncateToFit(_ text: String, label: UILabel, rightLabel: UILabel) -> String {
        
        guard let font = label.font else { return text }
        
        // 👉 REAL available width
        let totalWidth = label.superview?.frame.width ?? label.frame.width
        let rightWidth = rightLabel.intrinsicContentSize.width
        
        let spacing: CGFloat = 16   // adjust if needed
        let maxWidth = totalWidth - rightWidth - spacing
        
        var finalText = text
        
        while (finalText as NSString).size(withAttributes: [.font: font]).width > maxWidth {
            finalText = String(finalText.dropLast())
            if finalText.isEmpty { break }
        }
        
        if finalText != text {
            finalText += "..."
        }
        
        return finalText
    }
    
    @IBAction func mViewImage(_ sender: Any) {
//        if mType == "catalog" {
//            mOpenGlobalImageViewer() //essindy
//        }
//        else {
            print("self.mData = \(mData)")
            print("self.mSKUForImage = \(self.mSKUForImage)")
            print("self.mProductIdForImage = \(self.mProductIdForImage)")
    //        self.mSKUForImage = mSKU
    //        self.mProductIdForImage = mProductId
    //        if let data = mStoneDataArray.firstObject as? NSDictionary,
           if let mPoProductId = mProductId as? String {
                let storyBoard: UIStoryboard = UIStoryboard(name: "common", bundle: nil)
                if let home = storyBoard.instantiateViewController(withIdentifier: "SKUProductSummary") as? SKUProductSummary{
                    print(mPoProductId)
                    home.mKey = mPoProductId
                    home.mType = mType
                    home.modalPresentationStyle = .automatic
                    home.transitioningDelegate = self
                    self.present(home,animated: true)
                }
    
            }
//        }
        
    }
    
    @objc func onTapImage(){
        mOpenGlobalImageViewer()
    }
    
    func mOpenGlobalImageViewer(){
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
 
    //Show hide views
    @IBOutlet weak var mDiscriptionDropDownImage: UIImageView!
    @IBOutlet weak var mDiscriptionDetailsView: UIView!
    @IBAction func mShowHideDiscription(_ sender: Any) {
        UIView.transition(with: mDiscriptionDetailsView, duration: 0.1, options: .transitionCrossDissolve , animations: {
            self.mDiscriptionDetailsView.isHidden = !self.mDiscriptionDetailsView.isHidden
            self.mDiscriptionDropDownImage.transform = self.mDiscriptionDetailsView.isHidden ? CGAffineTransform.init(rotationAngle: -CGFloat.pi/2) : .identity
        })
    }
    
    @IBOutlet weak var mSummaryDropDownImage: UIImageView!
    @IBOutlet weak var mProductSummeryView: UIView!
    @IBAction func mShowHideSummery(_ sender: Any) {
        UIView.transition(with: mProductSummeryView, duration: 0.1, options: .transitionCrossDissolve , animations: {
            self.mProductSummeryView.isHidden = !self.mProductSummeryView.isHidden
            self.mSummaryDropDownImage.transform = self.mProductSummeryView.isHidden ? CGAffineTransform.init(rotationAngle: -CGFloat.pi/2) : .identity
        })
    }
    
    // Back Naviagation
    @IBAction func mBack(_ sender: Any) {
        
        self.navigationController?.popViewController(animated:true)
    }
 
    
    
    @IBAction func mLikeDislike(_ sender: Any) {
        
        
        if mCustomerId == "" {
            return
        }
        
//        CommonClass.showFullLoader(view: self.view)
        let mLocation = UserDefaults.standard.string(forKey: "location") ?? ""
        let params = ["search":mSKU,"location":mLocation,"customer_id":mCustomerId, "isWishlist":isWishListed,"SKU":mSKU, "type":mType, "product_id": mProductId]
//        let params = [
//
//            "search":mSKU,
//            "location":mLocation,
//            "customer_id":mCustomerId,
//            "isWishlist":isWishListed,
//            "SKU":mSKU,
//            "type":mType,
//            "product_id":mProductId,
//            "item_id":mItemId
//
//        ]
        
        mGetData(url: mAddToFav,headers: sGisHeaders,  params: params) { response , status in
            CommonClass.stopLoader()
            if status {
                if "\(response.value(forKey: "code") ?? "")" == "200" {
                    
                    if let mData = response.value(forKey: "data") as? NSDictionary {
                        
//                        self.isWishListed = "\(mData.value(forKey: "isWishlist") ?? "0")"
                        self.isWishListed = "\(mData["isWishlist"] ?? "0")"
                        self.mHeart.image = UIImage(systemName: self.isWishListed == "0" ? "heart" : "heart.fill")
                        self.mHeart.tintColor = UIColor(named: self.isWishListed == "0" ? "themeExtraLightText1" : "themeLightRed")
                    }
                    
                }
                
            }
        }
        
    }
    @IBAction func mAddSize(_ sender: Any) {
        let count = mSize.text ?? "0"
        let mTotal =  Int(count) ?? 0 + 1
      
        mSize.text = "\(mTotal)"
        
    }
    @IBAction func mSubtractSize(_ sender: Any) {
        
        let count = mSize.text ?? "0"
       
        if(count != "0"){
            
        
            let mTotal = Int(count) ?? 0 - 1
          
            mSize.text = "\(mTotal)"
            
        }
    }
    
    
    
    @IBAction func mOrderNow(_ sender: UIButton) {
        
        mOrderNowButton.isEnabled = false
        sender.showAnimation{
            
//            CommonClass.showFullLoader(view: self.view)
            
            print("POSAddToCart mOrderNow ")
            let mParams = ["product_id":[self.mProductId], "customer_id":self.mCustomerId, "sales_person_id":self.selectedSalesPersonId, "type":self.mType, "order_type":"custom_order"] as [String : Any]
            
            let startTime = Date()
            
            print("========================================")
            print("🚨 FINAL PRODUCT BEFORE ADD TO CART")
            print("SKU =", self.mSKUName.text ?? "")
            print("Product ID =", self.mProductId)
            print("Shape ID =", self.mShapeId)
            print("Shape Name =", self.mShapeName.text ?? "")
            print("Pointer ID =", self.mPointerId)
            print("Pointer Name =", self.mPointerName.text ?? "")
            print("Price =", self.mPrice.text ?? "")
            print("choice_data =", self.mData.value(forKey: "choice_data") ?? "nil")
            print("========================================")
            
            mGetData(url: mAddCustomProduct,headers: sGisHeaders,  params: mParams) { response , status in
                CommonClass.stopLoader()
                self.mOrderNowButton.isEnabled = true
                let duration = Date().timeIntervalSince(startTime)

                    print("========== API RESPONSE ==========")
                    print("API =", mAddCustomProduct)
                    print("Status =", status)
                    print("Response Time = \(duration) sec")
                    print("Response =", response)
                    print("=================================")
                if status {
                    guard let statusCode = response.value(forKey: "code") as? Int else {
                        CommonClass.showSnackBar(message: "Oops! Something went wrong.")
                        return
                    }
                    print("POSAddToCart mAddCustomProduct response = \(response)")
                    if statusCode == 200 {
//                        let showPopup = response.value(forKey: "showPopup") as? Bool ?? false
                        var showPopup = false

                        if let value = response["showPopup"] as? Bool {
                            showPopup = value
                        } else if let value = response["showPopup"] as? Int {
                            showPopup = (value == 1)
                        }

                        print("SHOW POPUP =", showPopup)
                        let shouldShowPopup = ["repair", "reserve", "custom"].contains(self.mType.lowercased())

                        print("============================================")
                        print("🟢 SHOW POPUP =", showPopup)
                        print("============================================")

                        let openCart = {
                            let storyBoard = UIStoryboard(name: "customOrder", bundle: nil)
                            if let mCustomCart = storyBoard.instantiateViewController(withIdentifier: "CustomCart") as? CustomCart {
                                print("🔥 ADD TO CART SUCCESS1")
                                print("🔥 PRODUCT ID =", self.mProductId)
                                print("🔥 VARIANT PRODUCT ID =", self.mVarientProductId)
                                CommonClass.stopLoader()
                                self.navigationController?.pushViewController(mCustomCart, animated: true)
                            }
                        }

                        if shouldShowPopup && showPopup {
                            self.showProceedConfirmation(onProceed: openCart)
                        } else {
                            openCart()
                        }
                    }else{
                        if let error = response.value(forKey: "error") as? String{
                            if error == "Authorization has been expired" {
                                CommonClass.sessionExpired(isExpired: true, navigation: self.navigationController)
                            } else {
                                CommonClass.showSnackBar(message: "Error \(statusCode): \(error)")
                            }
                        }
                        if let message = response.value(forKey: "message") as? String {
                            CommonClass.showSnackBar(message: "Error \(statusCode): \(message)")
                        }
                    }
                }
            }
        }
    }

    func addCatalogVariantToCart(variantId: String) {

        var mParams: [String: Any] = [
            "product_id": [variantId],
            "customer_id": self.mCustomerId,
            "sales_person_id": selectedSalesPersonId,
            "type": self.mType,
            "order_type": "custom_order",
            "pointer": self.mPointerId
        ]

        if self.mType == "mix_match" {
            mParams["pointerPrice"] = self.mSelectedPointerPrice
        }

        print("")
        print("============================================")
        print("🚀 FINAL ADD TO CART REQUEST")
        print("============================================")
        print("🔥 BASE PRODUCT ID =", self.mProductId)
        print("🔥 ADD PRODUCT ID =", variantId)
        print("🔥 SKU =", self.mSKUName.text ?? "")
        print("🔥 TYPE =", self.mType)
        print("🔥 PARAMS =", mParams)
        print("============================================")

        let startTime = Date()

        mGetData(
            url: mAddCustomProduct,
            headers: sGisHeaders,
            params: mParams
        ) { response, status in

            let duration = Date().timeIntervalSince(startTime)

            print("")
            print("============================================")
            print("🚨 ADD TO CART API RESPONSE")
            print("============================================")
            print("🔥 API =", mAddCustomProduct)
            print("🔥 STATUS =", status)
            print("🔥 RESPONSE TIME =", duration, "sec")
            print("🔥 RESPONSE =", response)
            print("============================================")

            DispatchQueue.main.async {

                CommonClass.stopLoader()

                self.mAddToCartBUTTON.isEnabled = true

                guard status else {

                    print("❌ ADD TO CART API FAILED")

                    return
                }

                guard let statusCode =
                        response.value(forKey: "code") as? Int else {

                    print("❌ RESPONSE CODE MISSING")

                    CommonClass.showSnackBar(
                        message: "Oops! Something went wrong."
                    )

                    return
                }

                print("🔥 ADD TO CART STATUS CODE =", statusCode)

                if statusCode == 200 {

                    print("")
                    print("============================================")
                    print("✅ ADD TO CART SUCCESS")
                    print("============================================")
                    print("🔥 PRODUCT ID =", self.mProductId)
                    print("🔥 ADDED ID =", variantId)
                    print("🔥 SKU =", self.mSKUName.text ?? "")
                    print("============================================")

                    let storyBoard =
                        UIStoryboard(
                            name: "customOrder",
                            bundle: nil
                        )

                    if let existingCartIndex =
                        self.navigationController?
                            .viewControllers
                            .firstIndex(where: {
                                $0 is CustomCart
                            }) {

                        if let cart =
                            self.navigationController?
                                .viewControllers[existingCartIndex]
                                as? CustomCart {

                            print("🔥 EXISTING CUSTOM CART FOUND")
                            print("🔥 POP TO CUSTOM CART")
                            print("🔥 REFRESH CART")

                            self.navigationController?
                                .popToViewController(
                                    cart,
                                    animated: true
                                )

                            cart.mFetchCartItems()
                        }

                    } else {

                        print("🔥 NO EXISTING CUSTOM CART")
                        print("🔥 CREATE NEW CUSTOM CART")

                        if let mCustomCart =
                            storyBoard.instantiateViewController(
                                withIdentifier: "CustomCart"
                            ) as? CustomCart {

                            mCustomCart.mCustomerId =
                                self.mCustomerId

                            self.navigationController?
                                .pushViewController(
                                    mCustomCart,
                                    animated: true
                                )
                        }
                    }

                } else {

                    print("❌ ADD TO CART FAILED")
                    print("❌ CODE =", statusCode)

                    if let error =
                        response.value(forKey: "error") as? String {

                        if error ==
                            "Authorization has been expired" {

                            CommonClass.sessionExpired(
                                isExpired: true,
                                navigation: self.navigationController
                            )

                        } else {

                            CommonClass.showSnackBar(
                                message: "\(error)"
                            )
                        }
                    }

                    if let message =
                        response.value(forKey: "message") as? String {

                        CommonClass.showSnackBar(
                            message: "\(message)"
                        )
                    }
                }
            }
        }
    }
//    func addCatalogVariantToCart(variantId: String) {
//
////        let mParams: [String: Any] = [
////            "product_id": [variantId],
////            "customer_id": self.mCustomerId,
////            "sales_person_id": "",
////            "type": self.mType,
////            "order_type": "custom_order",
////            "pointerPrice": self.mSelectedPointerPrice,
////            "pointer": self.mPointerId
////        ]
//
//        var mParams: [String: Any] = [
//            "product_id": [variantId],
//            "customer_id": self.mCustomerId,
//            "sales_person_id": "",
//            "type": self.mType,
//            "order_type": "custom_order",
//            "pointer": self.mPointerId
//        ]
//
//        if self.mType == "mix_match" {
//            mParams["pointerPrice"] = self.mSelectedPointerPrice
//        }
//
//        print("========== FINAL ADD TO CART ==========")
//        print("🔥 BASE PRODUCT ID =", self.mProductId)
//        print("🔥 RESOLVED VARIANT ID =", variantId)
//        print("🔥 DISPLAY SKU =", self.mSKUName.text ?? "")
//        print("🔥 PARAMS =", mParams)
//        print("=======================================")
//
//        let flowStartTime = Date()
//
//        print("")
//        print("========== ADD TO CART FLOW ==========")
//        print("🚀 TAP APPLY =", flowStartTime)
//        print("🚀 PRODUCT =", variantId)
//        print("======================================")
//
//        let startTime = Date()
//        mGetData(
//            url: mAddCustomProduct,
//            headers: sGisHeaders,
//            params: mParams
//        ) { response, status in
//
//            let duration = Date().timeIntervalSince(startTime)
//
//                print("========== API RESPONSE ==========")
//                print("API =", mAddCustomProduct)
//                print("Status =", status)
//                print("Response Time = \(duration) sec")
//                let apiEndTime = Date()
//
//                print("========== API RESPONSE ==========")
//                print("API =", mAddCustomProduct)
//                print("Status =", status)
//                print("Response Time = \(duration) sec")
//                print("API END =", apiEndTime)
//                print("Response =", response)
//                print("=================================")
//                print("Response =", response)
//                print("=================================")
//            CommonClass.stopLoader()
//
//            print("========== ADD TO CART RESPONSE ==========")
//            print("🔥 STATUS =", status)
//            print("🔥 RESPONSE =", response)
//            print("==========================================")
//
//            guard status else {
//                return
//            }
//
//            guard let statusCode =
//                    response.value(forKey: "code") as? Int else {
//
//                CommonClass.showSnackBar(
//                    message: "Oops! Something went wrong."
//                )
//
//                return
//            }
//
//            if statusCode == 200 {
//
//                let storyBoard = UIStoryboard(
//                    name: "customOrder",
//                    bundle: nil
//                )
//
//                if let existingCartIndex =
//                    self.navigationController?
//                        .viewControllers
//                        .firstIndex(where: { $0 is CustomCart }) {
//
////                    if let cart =
////                        self.navigationController?
////                            .viewControllers[existingCartIndex] {
////
////                        self.navigationController?
////                            .popToViewController(
////                                cart,
////                                animated: true
////                            )
////                    }
//                    if let cart =
//                        self.navigationController?
//                            .viewControllers[existingCartIndex] as? CustomCart {
//
//                        print("🔥 EXISTING CUSTOM CART FOUND")
//                        print("🔥 REFRESHING CART AFTER ADD")
//                        print("")
//                        print("========== NAVIGATION ==========")
//                        print("➡️ POP TO CUSTOM CART")
//                        print("TIME =", Date())
//                        print("===============================")
//                        self.navigationController?
//                            .popToViewController(
//                                cart,
//                                animated: true
//                            )
//
//                        cart.mFetchCartItems()
//                    }
//
//                } else {
//
//                    if let mCustomCart =
//                        storyBoard.instantiateViewController(
//                            withIdentifier: "CustomCart"
//                        ) as? CustomCart {
//
//                        print("🔥 ADD TO CART SUCCESS")
//                        print("🔥 VARIANT ID =", variantId)
//
//                        mCustomCart.mCustomerId =
//                            self.mCustomerId
//                        print("")
//                        print("========== NAVIGATION ==========")
//                        print("➡️ PUSH CUSTOM CART")
//                        print("TIME =", Date())
//                        print("===============================")
//                        self.navigationController?
//                            .pushViewController(
//                                mCustomCart,
//                                animated: true
//                            )
//                    }
//                }
//
//            } else {
//
//                if let error =
//                    response.value(forKey: "error") as? String {
//
//                    if error == "Authorization has been expired" {
//
//                        CommonClass.sessionExpired(
//                            isExpired: true,
//                            navigation: self.navigationController
//                        )
//
//                    } else {
//
//                        CommonClass.showSnackBar(
//                            message: "\(error)"
//                        )
//                    }
//                }
//
//                if let message =
//                    response.value(forKey: "message") as? String {
//
//                    CommonClass.showSnackBar(
//                        message: "\(message)"
//                    )
//                }
//            }
//        }
//    }
    
    func resolveVariantForAddToCart(
        completion: @escaping (String?) -> Void
    ) {

        var params: [String: Any] = [
            "product_id": self.mProductId,
            "customer_id": self.mCustomerId,
            "type": self.mType,
            "isWishlist": "1"
        ]

        if !self.mMetalId.isEmpty {
            params["Metal"] = self.mMetalId
        }

        if !self.mStoneId.isEmpty {
            params["Stone"] = self.mStoneId
        }

        if !self.mSizeId.isEmpty {
            params["Size"] = self.mSizeId
        }

        if !self.mShapeId.isEmpty {
            params["Shape"] = self.mShapeId
        }

        if !self.mPointerId.isEmpty {
            params["Pointer"] = self.mPointerId
        }

        print("========== RESOLVE VARIANT FOR CART ==========")
        print("🔥 BASE PRODUCT ID =", self.mProductId)
        print("🔥 METAL ID =", self.mMetalId)
        print("🔥 STONE ID =", self.mStoneId)
        print("🔥 SIZE ID =", self.mSizeId)
        print("🔥 PARAMS =", params)
        print("================================================")
        
        let startTime = Date()
        mGetData(
            url: mGetMixAndMatchCatalogDetails,
            headers: sGisHeaders,
            params: params
        ) { response, status in

            let duration = Date().timeIntervalSince(startTime)

                print("========== API RESPONSE ==========")
                print("API =", mAddCustomProduct)
                print("Status =", status)
                print("Response Time = \(duration) sec")
                print("Response =", response)
                print("=================================")
            
            print("========== RESOLVE VARIANT RESPONSE ==========")
            print("🔥 STATUS =", status)
            print("🔥 RESPONSE =", response)
            print("==============================================")

            guard status,
                  "\(response.value(forKey: "code") ?? "")" == "200",
                  let data = response.value(forKey: "data") as? NSDictionary else {

                completion(nil)
                return
            }

            let variantId = "\(data.value(forKey: "_id") ?? "")"
            let variantSKU = "\(data.value(forKey: "SKU") ?? "")"

            print("🔥 RESOLVED VARIANT ID =", variantId)
            print("🔥 RESOLVED VARIANT SKU =", variantSKU)

            guard !variantId.isEmpty else {
                completion(nil)
                return
            }

            completion(variantId)
        }
    }
    
    func addProductDirectlyToCart(productId: String) {

        let params: [String: Any] = [
            "product_id": [productId],
            "customer_id": self.mCustomerId,
            "sales_person_id": selectedSalesPersonId,
            "type": self.mType,
            "order_type": "custom_order",
            "pointer": self.mPointerId
        ]

        print("")
        print("============================================")
        print("🚀 DIRECT ADD NON-VARIANT PRODUCT")
        print("============================================")
        print("🔥 PRODUCT ID =", productId)
        print("🔥 SKU =", self.mSKUName.text ?? "")
        print("🔥 TYPE =", self.mType)
        print("🔥 PARAMS =", params)
        print("============================================")

        let startTime = Date()

        mGetData(
            url: mAddCustomProduct,
            headers: sGisHeaders,
            params: params
        ) { [weak self] response, status in

            guard let self = self else { return }

            let duration = Date().timeIntervalSince(startTime)

            print("")
            print("========== DIRECT ADD RESPONSE ==========")
            print("🔥 API =", mAddCustomProduct)
            print("🔥 STATUS =", status)
            print("🔥 RESPONSE TIME =", duration, "sec")
            print("🔥 RESPONSE =", response)
            print("=========================================")

            DispatchQueue.main.async {
                CommonClass.stopLoader()
                self.mAddToCartBUTTON.isEnabled = true
            }

            guard status else {
                DispatchQueue.main.async {
                    CommonClass.showSnackBar(
                        message: "Failed to add product."
                    )
                }
                return
            }

            guard let statusCode =
                    response.value(forKey: "code") as? Int else {

                DispatchQueue.main.async {
                    CommonClass.showSnackBar(
                        message: "Oops! Something went wrong."
                    )
                }

                return
            }

            print("🔥 DIRECT ADD STATUS CODE =", statusCode)

            if statusCode == 200 {

                print("")
                print("✅ NON-VARIANT ADD SUCCESS")
                print("✅ PRODUCT ID =", productId)
                print("============================================")

                let storyboard = UIStoryboard(
                    name: "customOrder",
                    bundle: nil
                )

                if let existingCartIndex =
                    self.navigationController?
                        .viewControllers
                        .firstIndex(where: { $0 is CustomCart }) {

                    if let cart =
                        self.navigationController?
                            .viewControllers[existingCartIndex]
                            as? CustomCart {

                        print("🔥 EXISTING CUSTOM CART FOUND")
                        print("🔥 POP TO CUSTOM CART")

                        self.navigationController?
                            .popToViewController(
                                cart,
                                animated: true
                            )

                        // สำคัญ:
                        // ให้ Cart โหลดหลัง add API สำเร็จเท่านั้น
                        DispatchQueue.main.asyncAfter(
                            deadline: .now() + 0.1
                        ) {
                            cart.mFetchCartItems()
                        }
                    }

                } else {

                    if let cart =
                        storyboard.instantiateViewController(
                            withIdentifier: "CustomCart"
                        ) as? CustomCart {

                        cart.mCustomerId = self.mCustomerId

                        print("🔥 CREATE NEW CUSTOM CART")

                        self.navigationController?
                            .pushViewController(
                                cart,
                                animated: true
                            )
                    }
                }

            } else {

                if let error =
                    response.value(forKey: "error") as? String {

                    if error == "Authorization has been expired" {

                        self.navigationController.map {
                            CommonClass.sessionExpired(
                                isExpired: true,
                                navigation: $0
                            )
                        }

                    } else {

                        DispatchQueue.main.async {
                            CommonClass.showSnackBar(
                                message: error
                            )
                        }
                    }

                } else if let message =
                            response.value(forKey: "message") as? String {

                    DispatchQueue.main.async {
                        CommonClass.showSnackBar(
                            message: message
                        )
                    }
                }
            }
        }
    }
    
    
//    @IBAction func mAddToCart(_ sender: UIButton) {
//
//            guard !mAddToCartBUTTON.isEnabled == false else {
//                print("🛑 ADD TO CART ALREADY IN PROGRESS")
//                return
//            }
//
//            mAddToCartBUTTON.isEnabled = false
//
//            print("")
//            print("============================================")
//            print("🚀 ADD TO CART START")
//            print("============================================")
//            print("🔥 TYPE =", self.mType)
//            print("🔥 PRODUCT ID =", self.mProductId)
//            print("🔥 SKU =", self.mSKU)
//            print("🔥 CUSTOMER ID =", self.mCustomerId)
//            print("🔥 CURRENT VARIANT ID =", self.mVarientProductId)
//            print("🔥 METAL ID =", self.mMetalId)
//            print("🔥 STONE ID =", self.mStoneId)
//            print("🔥 SIZE ID =", self.mSizeId)
//            print("🔥 SHAPE ID =", self.mShapeId)
//            print("🔥 POINTER ID =", self.mPointerId)
//            print("============================================")
//
//            sender.showAnimation {
//
//                // =====================================================
//                // INVENTORY
//                // =====================================================
//
//                if self.mType == "inventory" {
//
//                    let params: [String: Any] = [
//                        "product_id": [self.mProductId],
//                        "customer_id": self.mCustomerId,
//                        "sales_person_id": "",
//                        "type": self.mType,
//                        "order_type": "pos_order"
//                    ]
//
//                    print("")
//                    print("========== INVENTORY ADD REQUEST ==========")
//                    print("🔥 PARAMS =", params)
//                    print("============================================")
//
//                    let startTime = Date()
//
//                    mGetData(
//                        url: mAddCustomProduct,
//                        headers: sGisHeaders,
//                        params: params
//                    ) { response, status in
//
//                        let duration = Date().timeIntervalSince(startTime)
//
//                        DispatchQueue.main.async {
//                            CommonClass.stopLoader()
//                            self.mAddToCartBUTTON.isEnabled = true
//                        }
//
//                        print("")
//                        print("========== INVENTORY ADD RESPONSE ==========")
//                        print("🔥 STATUS =", status)
//                        print("🔥 RESPONSE TIME =", duration, "sec")
//                        print("🔥 RESPONSE =", response)
//                        print("=============================================")
//
//                        guard status else {
//                            return
//                        }
//
//                        guard let statusCode =
//                                response.value(forKey: "code") as? Int else {
//
//                            CommonClass.showSnackBar(
//                                message: "Oops! Something went wrong."
//                            )
//
//                            return
//                        }
//
//                        if statusCode == 200 {
//
//                            print("✅ INVENTORY ADD SUCCESS")
//
//                            let storyBoard =
//                                UIStoryboard(
//                                    name: "posBoard",
//                                    bundle: nil
//                                )
//
//                            if let mHomePage =
//                                storyBoard.instantiateViewController(
//                                    withIdentifier: "POSTabBarController"
//                                ) as? POSTabBarController {
//
//                                mHomePage.mIndex = 2
//
//                                if let navigationController =
//                                    self.navigationController {
//
//                                    var controllers =
//                                        navigationController.viewControllers
//
//                                    if !controllers.isEmpty {
//                                        controllers.removeLast()
//                                    }
//
//                                    controllers.append(mHomePage)
//
//                                    navigationController.setViewControllers(
//                                        controllers,
//                                        animated: true
//                                    )
//                                }
//                            }
//
//                        } else {
//
//                            let error =
//                                response.value(forKey: "error") as? String
//
//                            let message =
//                                response.value(forKey: "message") as? String
//
//                            if let error = error {
//
//                                if error == "Authorization has been expired" {
//
//                                    CommonClass.sessionExpired(
//                                        isExpired: true,
//                                        navigation: self.navigationController
//                                    )
//
//                                } else {
//
//                                    CommonClass.showSnackBar(
//                                        message: "Error \(statusCode): \(error)"
//                                    )
//                                }
//
//                            } else if let message = message {
//
//                                CommonClass.showSnackBar(
//                                    message: "Error \(statusCode): \(message)"
//                                )
//                            }
//                        }
//                    }
//
//                    return
//                }
//
//
//                // =====================================================
//                // CATALOG
//                // =====================================================
//
//                print("")
//                print("========== CATALOG ADD FLOW ==========")
//
//                let nonVariant = self.isNonVariantProduct()
//
//                print("🔥 NON VARIANT =", nonVariant)
//                print("🔥 PRODUCT ID =", self.mProductId)
//                print("🔥 CURRENT VARIANT ID =", self.mVarientProductId)
//                print("=======================================")
//
//
//                // =====================================================
//                // NON-VARIANT PRODUCT
//                // =====================================================
//
//                if nonVariant {
//
//                    print("")
//                    print("🟢 NON-VARIANT PRODUCT")
//                    print("🟢 SKIP VARIANT RESOLVE")
//                    print("🟢 USE PRODUCT ID DIRECTLY =", self.mProductId)
//                    print("======================================")
//
//                    guard !self.mProductId.isEmpty else {
//
//                        print("❌ PRODUCT ID EMPTY")
//
//                        CommonClass.stopLoader()
//
//                        self.mAddToCartBUTTON.isEnabled = true
//
//                        CommonClass.showSnackBar(
//                            message: "Product ID not available."
//                        )
//
//                        return
//                    }
//
//                    self.mVarientProductId = self.mProductId
//
//                    // IMPORTANT:
//                    // Do NOT call resolveVariantForAddToCart()
//                    // Non-variant uses product_id directly.
//
//                    self.addCatalogVariantToCart(
//                        variantId: self.mProductId
//                    )
//
//                    // ❗ DO NOT stopLoader here.
//                    // addCatalogVariantToCart() is async.
//                    // It will stop loader after API response.
//
//                    return
//                }
//
//
//                // =====================================================
//                // VARIANT PRODUCT
//                // =====================================================
//
//                print("")
//                print("🟡 VARIANT PRODUCT")
//                print("🟡 START RESOLVE VARIANT")
//                print("======================================")
//
//                self.resolveVariantForAddToCart { variantId in
//
//                    DispatchQueue.main.async {
//
//                        print("")
//                        print("========== VARIANT RESOLVE RESULT ==========")
//                        print("🔥 RESOLVED VARIANT ID =", variantId ?? "nil")
//                        print("🔥 BASE PRODUCT ID =", self.mProductId)
//                        print("=============================================")
//
//                        guard let variantId = variantId,
//                              !variantId.isEmpty else {
//
//                            print("❌ VARIANT NOT FOUND")
//
//                            CommonClass.stopLoader()
//
//                            self.mAddToCartBUTTON.isEnabled = true
//
//                            CommonClass.showSnackBar(
//                                message: "Variant not available."
//                            )
//
//                            return
//                        }
//
//                        self.mVarientProductId = variantId
//
//                        print("✅ VARIANT READY")
//                        print("🔥 VARIANT ID =", variantId)
//                        print("🔥 NOW CALL ADD TO CART API")
//
//                        self.addCatalogVariantToCart(
//                            variantId: variantId
//                        )
//
//                        // ❗ IMPORTANT
//                        // Do NOT call stopLoader()
//                        // Do NOT enable button here.
//                        //
//                        // addCatalogVariantToCart() will do that
//                        // when its API finishes.
//                    }
//                }
//            }
//        }
//
    @IBAction func mAddToCart(_ sender: UIButton) {

        guard self.mAddToCartBUTTON.isEnabled else {
            print("🛑 ADD TO CART IGNORED - BUTTON DISABLED")
            return
        }

        // =====================================================
        // CHECK CUSTOMER FIRST
        // =====================================================

        if self.mCustomerId.isEmpty {

            print("⚠️ CUSTOMER ID EMPTY")
            print("➡️ OPEN CUSTOMER PICKER BEFORE ADD TO CART")


            let storyBoard: UIStoryboard =
                UIStoryboard(
                    name: "common",
                    bundle: nil
                )


            if let home =
                storyBoard.instantiateViewController(
                    withIdentifier: "CustomerPicker"
                ) as? CustomerPicker {


                home.delegate = self
                home.modalPresentationStyle = .automatic
                home.transitioningDelegate = self

                self.present(
                    home,
                    animated: true
                )
            }


            return
        }


            // =====================================================
            // CONTINUE ADD TO CART
            // =====================================================
        
        
        self.mAddToCartBUTTON.isEnabled = false

        print("")
        print("============================================")
        print("🚀 ADD TO CART START")
        print("============================================")
        print("🔥 TYPE =", self.mType)
        print("🔥 PRODUCT ID =", self.mProductId)
        print("🔥 SKU =", self.mSKUName.text ?? "")
        print("🔥 CUSTOMER ID =", self.mCustomerId)
        print("🔥 CURRENT VARIANT ID =", self.mVarientProductId)
        print("🔥 METAL ID =", self.mMetalId)
        print("🔥 STONE ID =", self.mStoneId)

        sender.showAnimation {

            // =====================================================
            // INVENTORY
            // =====================================================

            if self.mType == "inventory" {

                let params: [String: Any] = [
                    "product_id": [self.mProductId],
                    "customer_id": self.mCustomerId,
                    "sales_person_id": self.selectedSalesPersonId,
                    "type": self.mType,
                    "order_type": "pos_order"
                ]
                
                print("🔥 ADD CUSTOMER ID =", self.mCustomerId)

                print("")
                print("============================================")
                print("🟢 INVENTORY ADD TO CART")
                print("🔥 PARAMS =", params)
                print("============================================")

                let startTime = Date()

                mGetData(
                    url: mAddCustomProduct,
                    headers: sGisHeaders,
                    params: params
                ) { [weak self] response, status in

                    guard let self = self else { return }

                    let duration =
                        Date().timeIntervalSince(startTime)

                    print("")
                    print("========== INVENTORY ADD RESPONSE ==========")
                    print("🔥 STATUS =", status)
                    print("🔥 RESPONSE TIME =", duration, "sec")
                    print("🔥 RESPONSE =", response)
                    print("============================================")

                    DispatchQueue.main.async {
                        CommonClass.stopLoader()
                        self.mAddToCartBUTTON.isEnabled = true
                    }

                    if status,
                       "\(response.value(forKey: "code") ?? "")" == "200" {

                        print("✅ INVENTORY ADD SUCCESS")

                        DispatchQueue.main.async {

                            let storyBoard =
                                UIStoryboard(
                                    name: "posBoard",
                                    bundle: nil
                                )

                            guard let mHomePage =
                                    storyBoard.instantiateViewController(
                                        withIdentifier: "POSTabBarController"
                                    ) as? POSTabBarController
                            else {

                                print("❌ Cannot load POSTabBarController")
                                return
                            }


                            print("🔥 OPEN POS TAB")

                            mHomePage.mIndex = 2


                            guard let navigationController =
                                    self.navigationController
                            else {

                                print("❌ navigationController is nil")
                                return
                            }


                            var controllers =
                                navigationController.viewControllers


                            if !controllers.isEmpty {

                                controllers.removeLast()

                            }


                            controllers.append(mHomePage)


                            navigationController.setViewControllers(
                                controllers,
                                animated: true
                            )


                            print("✅ NAVIGATION SUCCESS")
                        }

                    } else {

                        let message =
                            "\(response.value(forKey: "message") ?? "Failed To Add.")"

                        DispatchQueue.main.async {
                            CommonClass.showSnackBar(
                                message: message
                            )
                        }
                    }
                }

                return
            }


            // =====================================================
            // CATALOG
            // =====================================================

            print("")
            print("========== CATALOG ADD FLOW ==========")

            let productVariantsEnable =
                "\(self.mData.value(forKey: "product_variants_enable") ?? "")"

            let isVariant =
                "\(self.mData.value(forKey: "is_variant") ?? "")"

            print("🔥 product_variants_enable =",
                  productVariantsEnable)

            print("🔥 is_variant =", isVariant)

            print("======================================")

            // =====================================================
            // NON-VARIANT
            // =====================================================

            let isNonVariant =
                productVariantsEnable == "0" ||
                productVariantsEnable.isEmpty &&
                isVariant.isEmpty

            if isNonVariant {

                print("")
                print("🟢 NON-VARIANT PRODUCT")
                print("🟢 SKIP resolveVariantForAddToCart")
                print("🟢 USE PRODUCT ID DIRECTLY")
                print("🟢 PRODUCT ID =", self.mProductId)
                print("======================================")

                self.addProductDirectlyToCart(
                    productId: self.mProductId
                )

                return
            }


            // =====================================================
            // VARIANT PRODUCT
            // =====================================================

            print("")
            print("🟡 VARIANT PRODUCT")
            print("🟡 START resolveVariantForAddToCart")
            print("======================================")

            self.resolveVariantForAddToCart { [weak self] variantId in

                guard let self = self else {
                    return
                }

                guard let variantId = variantId,
                      !variantId.isEmpty else {

                    print("")
                    print("❌ VARIANT RESOLVE FAILED")
                    print("======================================")

                    DispatchQueue.main.async {

                        CommonClass.stopLoader()

                        self.mAddToCartBUTTON.isEnabled = true

                        CommonClass.showSnackBar(
                            message: "Variant not available."
                        )
                    }

                    return
                }

                print("")
                print("✅ VARIANT RESOLVE SUCCESS")
                print("🔥 VARIANT ID =", variantId)
                print("======================================")

                self.mVarientProductId = variantId

                self.addCatalogVariantToCart(
                    variantId: variantId
                )
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.mLocationData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
        guard let cells = tableView.dequeueReusableCell(withIdentifier: "ProductLocationCell") as? ProductLocationCell else {
            return UITableViewCell()
        }
        
        if let mData = self.mLocationData[indexPath.row] as? NSDictionary{
//            cells.mLocationQty.text = "\(mData.value(forKey: "qty") ?? "--")"
            print("POSAddToCart mData = \(mData)")
            let qty = Int("\(mData.value(forKey: "qty") ?? "0")") ?? 0

            if qty == 0 {
                cells.mLocationQty.text = "Out of stock"
                cells.mLocationQty.textColor = .systemRed
            } else {
                cells.mLocationQty.text = "\(qty)"
                cells.mLocationQty.textColor = UIColor(named: "themeColor")
            }
            if(mHeading.text == "Catalog") {
                cells.mLocationQty.isHidden = true
            }
//            cells.mLocationName.text = "\(mData.value(forKey: "location_name") ?? "--")"

            cells.mLocationFlag.isHidden = true
            let location = "\(mData.value(forKey: "location_name") ?? "")"

//            switch location.lowercased() {
//
//            case "bangkok", "thailand":
//                cells.mLocationName.text = "🇹🇭 \(mData.value(forKey: "location_name") ?? "--")"
////                cells.mLocationFlag.text = "🇹🇭"
//
//            case "usa", "united states":
////                cells.mLocationFlag.text = "🇺🇸"
//                cells.mLocationName.text = "🇺🇸 \(mData.value(forKey: "location_name") ?? "--")"
//            case "europe":
////                cells.mLocationFlag.text = "🇪🇺"
//                cells.mLocationName.text = "🇪🇺 \(mData.value(forKey: "location_name") ?? "--")"
//            case "middle east":
////                cells.mLocationFlag.text = "🌍"
//                cells.mLocationName.text = "🌍 \(mData.value(forKey: "location_name") ?? "--")"
//            // หรือ 🇴🇲 🇸🇦 🇦🇪 แล้วแต่ประเทศจริง
//
//            default:
//                cells.mLocationName.text = "📍 \(mData.value(forKey: "location_name") ?? "--")"
////                cells.mLocationFlag.text = "📍"
//            }

            cells.mLocationName.text = location
            
        }else{
            cells.isHidden = true
        }
        
        return cells
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mImageData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
      
        guard let cells = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductImageCell",for:indexPath) as? ProductImageCell else{
            return UICollectionViewCell()
        }
        
        if let mDatas = mImageData[indexPath.row] as? NSDictionary {
            cells.mProductImage.downlaodImageFromUrl(urlString: "\(mDatas.value(forKey: "image") ?? "")")
        }
        return cells
    }


    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        if let cells = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductImageCell",for:indexPath) as? ProductImageCell,
           let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            
            return CGSize(width: view.frame.width, height: 220)
        } else {
            return CGSize(width: 0, height: 0)
        }
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = scrollView.frame.width - (scrollView.contentInset.left*2)
        let index = scrollView.contentOffset.x / width
        let roundedIndex = round(index)
        self.mPageController.currentPage = Int(roundedIndex)

    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.mPageController.currentPage = Int(scrollView.contentOffset.x)
            / Int (scrollView.frame.width)
        
    }
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.mPageController.currentPage = Int(scrollView.contentOffset.x) /  Int(scrollView.frame.width
        )
    }
    
    
    
    @IBAction func mChooseMetal(_ sender: Any) {
        
        let dropdown = DropDown()
        dropdown.anchorView = self.mChooseMetalButt
        dropdown.direction = .bottom
        dropdown.bottomOffset = CGPoint(x: 0, y: self.mChooseMetalButt.frame.size.height)
        dropdown.width = 200
        dropdown.dataSource = mMetalList
        dropdown.selectionAction = {
            [unowned self](index:Int, item: String) in
//            self.mMetalName.text  = item
            self.mMetalName.text = self.getFullMetalName(item)
            if self.mMetalId != self.mMetalIdList[index] {
                
                self.mMetalId = self.mMetalIdList[index]
                self.mUpdateData()
                
            }
        }
        dropdown.show()
        
    }

    @IBAction func mChooseStone(_ sender: Any) {

        let dropdown = DropDown()
        dropdown.anchorView = self.mChooseStoneButt
        dropdown.direction = .any
        dropdown.bottomOffset = CGPoint(
            x: 0,
            y: self.mChooseStoneButt.frame.size.height
        )
        dropdown.width = 200
        dropdown.dataSource = mStoneList

        dropdown.selectionAction = {
            [unowned self] (index: Int, item: String) in

            guard index < self.mStoneIdList.count else {
                print("❌ INVALID STONE INDEX =", index)
                return
            }

            let selectedStoneId = self.mStoneIdList[index]

            print("========== STONE SELECTED ==========")
            print("🔥 SELECTED INDEX =", index)
            print("🔥 SELECTED STONE NAME =", item)
            print("🔥 SELECTED STONE ID =", selectedStoneId)
            print("🔥 OLD STONE ID =", self.mStoneId)
            print("🔥 PRODUCT ID =", self.mProductId)
            print("🔥 CURRENT VARIANT ID =", self.mVarientProductId)
            print("====================================")

            self.mStoneName.text = item
            self.mStoneId = selectedStoneId

            print("🔥 NEW STONE ID =", self.mStoneId)
            print("🔥 CALLING mUpdateData()")

            self.mUpdateData()
        }

        dropdown.show()
    }

    @IBAction func mChooseSize(_ sender: Any) {
        
        let dropdown = DropDown()
        dropdown.anchorView = self.mChooseSizeButt
        dropdown.direction = .any
        dropdown.bottomOffset = CGPoint(x: 0, y: self.mChooseSizeButt.frame.size.height)
        dropdown.width = 200
        dropdown.dataSource = mSizeList
        dropdown.selectionAction = {
            [unowned self](index:Int, item: String) in
            self.mSizeName.text  = item
            if self.mSizeId != self.mSizeIdList[index] {
                
                self.mSizeId =  self.mSizeIdList[index]
                self.mUpdateData()
                
            }
        }
        dropdown.show()
        
    }
    
    @IBAction func mChooseShape(_ sender: Any) {
        
        let dropdown = DropDown()
        dropdown.anchorView = self.mChooseShapeButton
        dropdown.direction = .any
        dropdown.bottomOffset = CGPoint(x: 0, y: self.mChooseShapeButton.frame.size.height)
        dropdown.width = 220
        dropdown.dataSource = mShapeList
        dropdown.selectionAction = {
            [unowned self](index:Int, item: String) in
            self.mShapeName.text  = item
            
            self.mShapeId =  self.mShapeIdList[index]
           
            for data in self.mChoiceData {
                if let mData = data as? NSDictionary {
                    if mData.value(forKey: "id") as? String ?? "" == self.mShapeId {
                        if let mArr = mData.value(forKey: "data") as? NSArray,
                           mArr.count > 0 {
                            self.mPointerList = [String]()
                            self.mPointerdPriceList = [String]()

                            if let data = mArr[0] as? NSDictionary {
                                self.mPointerName.text = "\(data.value(forKey: "pointer") ?? "0.0")"
                                self.mPointerId = "\(data.value(forKey: "pointer") ?? "0.0")"
//                                let formatter = NumberFormatter()
//                                formatter.numberStyle = .decimal
//                                formatter.minimumFractionDigits = 2
//                                formatter.maximumFractionDigits = 2
//
//                                let price = Double("\(data.value(forKey: "price") ?? "0")") ?? 0.0
//                                let formattedPrice = formatter.string(from: NSNumber(value: price)) ?? "0.00"
//                                print("5mGetCatalogDetails \(price) self.mPrice = \(formattedPrice)")
//                                self.mPrice.text = "\(self.mStoreCurrency) \(formattedPrice)"
                                self.mPrice.text = "\(data.value(forKey: "price") ?? "0.00")"
                            }
                            
                            for data in mArr {
                                if let mData = data as? NSDictionary {
                                    self.mPointerList.append(mData.value(forKey: "pointer") as? String ?? "0.0")
                                    self.mPointerdPriceList.append(mData.value(forKey: "price") as? String ?? "0.00")
                                }
                            }

                        }
                    }
                }
            }
            
        }
        dropdown.show()
        
    }

    @IBAction func mChoosePointer(_ sender: Any) {
        
        let dropdown = DropDown()
        dropdown.anchorView = self.mChoosePointerButton
        dropdown.direction = .any
        dropdown.bottomOffset = CGPoint(x: 0, y: self.mChoosePointerButton.frame.size.height)
        dropdown.width = 200
        dropdown.dataSource = mPointerList
        dropdown.selectionAction = {
            [unowned self](index:Int, item: String) in
            self.mPointerName.text  = item
            
            self.mPointerId =  self.mPointerList[index]
//            let formatter = NumberFormatter()
//            formatter.numberStyle = .decimal
//            formatter.minimumFractionDigits = 2
//            formatter.maximumFractionDigits = 2
//
//            let price = Double(self.mPointerdPriceList[index]) ?? 0.0
//            let formattedPrice = formatter.string(from: NSNumber(value: price)) ?? "0.00"
//            print("0mGetCatalogDetails \(price) self.mPrice = \(formattedPrice)")
//            self.mPrice.text = "\(self.mStoreCurrency) \(formattedPrice)"
            self.mPrice.text = self.mPointerdPriceList[index]
            self.mSelectedPointerPrice = self.mPointerdPriceList[index]
        }
        dropdown.show()
        
    }
    
    @IBAction func mDownloadCatalogPDF(_ sender: UIButton) {

            let params: [String: Any] = [

                "Item_id": mProductId,
                "type": mType,
                "category_id": "Item",
                "customer_id": mCustomerId,

                "shippingInfo": [
                    "billing_address": [:],
                    "shipping_address": [:]
                ]
            ]

            CommonClass.showFullLoader(view: self.view)
            print("mDownloadCatalogPDF URL =", mGetCatalogPdf)
            print("mDownloadCatalogPDF Item_id =", mProductId)
            print("mDownloadCatalogPDF type =", mType)
            print("mDownloadCatalogPDF customer_id =", mCustomerId)
            print("mDownloadCatalogPDF params =", params)
            mGetData(url: mGetCatalogPdf,
                     headers: sGisHeaders,
                     params: params) { response, status in

                CommonClass.stopLoader()
                print("mDownloadCatalogPDF response = ",response)
                guard status,
                      "\(response["code"] ?? "")" == "200"
                else {
                    print("mDownloadCatalogPDF message = ","\(response["message"] ?? "")")
                    CommonClass.showSnackBar(message: "\(response["message"] ?? "")")
                    return
                }

                guard let pdf = response["pdf_url"] as? String,
                      let url = URL(string: pdf)
                else { return }

                UIApplication.shared.open(url)
            }
        }
    
    private func isNonVariantProduct() -> Bool {

        let variantEnabled =
            "\(mData.value(forKey: "product_variants_enable") ?? "")"

        let isVariant =
            "\(mData.value(forKey: "is_variant") ?? "")"

        print("========== PRODUCT VARIANT CHECK ==========")
        print("🔥 PRODUCT ID =", mProductId)
        print("🔥 SKU =", mSKU)
        print("🔥 product_variants_enable =", variantEnabled)
        print("🔥 is_variant =", isVariant)
        print("============================================")

        // product_variants_enable = 0 => Non-variant
        if variantEnabled == "0" {
            return true
        }

        // is_variant = 0 => Non-variant
        if isVariant == "0" {
            return true
        }

        return false
    }
    
    func mUpdateData(){
        CommonClass.showFullLoader(view: self.view)
        let requestToken = UUID()
            latestVariantRequestToken = requestToken
        
        print("\n\n")
        print("==============================================")
        print("🔥🔥🔥 mUpdateData() CALLED 🔥🔥🔥")
        print("🔥 TIME =", Date())
        print("🔥 TYPE =", self.mType)
        print("🔥 PRODUCT ID =", self.mProductId)
        print("🔥 VARIANT ID =", self.mVarientProductId)
        print("🔥 METAL =", self.mMetalName.text ?? "")
        print("🔥 METAL ID =", self.mMetalId)
        print("🔥 STONE =", self.mStoneName.text ?? "")
        print("🔥 STONE ID =", self.mStoneId)
        print("🔥 SIZE =", self.mSizeName.text ?? "")
        print("🔥 SIZE ID =", self.mSizeId)
        print("🔥 SHAPE ID =", self.mShapeId)
        print("🔥 POINTER ID =", self.mPointerId)

        print("🔥 CALL STACK =")
//        Thread.callStackSymbols.prefix(10).forEach {
//            print($0)
//        }

        print("==============================================")

        let requestedStoneId = self.mStoneId
        let requestedMetalId = self.mMetalId
        let requestedSizeId = self.mSizeId
        let requestedShapeId = self.mShapeId
        let requestedPointerId = self.mPointerId

        print("========== NEW VARIANT REQUEST TOKEN ==========")
        print("🔥 TOKEN =", requestToken)
        print("🔥 STONE =", requestedStoneId)
        print("🔥 METAL =", requestedMetalId)
        print("🔥 SIZE =", requestedSizeId)
        print("================================================")

        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")

        let mLocation = UserDefaults.standard.string(forKey: "location")
     

        if Reachability.isConnectedToNetwork() == true {
                        
            var params: [String: Any] = [
                "product_id": mProductId,
                "type": mType,
                "customer_id": mCustomerId
            ]

            // Optional fields
            if !mMetalId.isEmpty {
                params["Metal"] = mMetalId
            }

            if !mSizeId.isEmpty {
                params["Size"] = mSizeId
            }

            if !mStoneId.isEmpty {
                params["Stone"] = mStoneId
            }

            // Design (Catalog) only
            if mType.lowercased() == "catalog" {

                if !mShapeId.isEmpty {
                    params["shape"] = [mShapeId]
                }

                if !mPointerId.isEmpty {
                    params["pointer"] = [mPointerId]
                }

                params["isWishlist"] = isWishListed
            }
            
//            CommonClass.showFullLoader(view: self.view)
            
            print("========== STONE VARIANT CHANGE REQUEST ==========")
            print("🔥 SELECTED STONE NAME =", self.mStoneName.text ?? "")
            print("🔥 SELECTED STONE ID =", self.mStoneId)
            print("🔥 CURRENT PRODUCT ID =", self.mProductId)
            print("🔥 CURRENT VARIANT ID =", self.mVarientProductId)
            print("🔥 METAL ID =", self.mMetalId)
            print("🔥 SIZE ID =", self.mSizeId)
            print("🔥 SHAPE ID =", self.mShapeId)
            print("🔥 POINTER ID =", self.mPointerId)
            print("🔥 TYPE =", self.mType)
            print("🔥 REQUEST PARAMS =", params)
            print("==================================================")
            
            print("========== MIX MATCH VARIANT REQUEST ==========")
            print("🔥 REQUEST TOKEN =", requestToken)
            print("🔥 API =", mGetMixAndMatchCatalogDetails)
            print("🔥 TRIGGER TYPE =", self.mType)
            print("🔥 PRODUCT ID =", self.mProductId)
            print("🔥 METAL ID =", self.mMetalId)
            print("🔥 STONE ID =", self.mStoneId)
            print("🔥 SIZE ID =", self.mSizeId)
            print("🔥 SHAPE ID =", self.mShapeId)
            print("🔥 POINTER ID =", self.mPointerId)
            print("🔥 FULL PARAMS =", params)
            print("================================================")
            let startTime = CFAbsoluteTimeGetCurrent()

            print("🚀 START getCatalogDetail")
            mGetData(
                url: mGetMixAndMatchCatalogDetails,
                headers: sGisHeaders,
                params: params
            ) { response, status in

                CommonClass.stopLoader()
                
                let elapsed = CFAbsoluteTimeGetCurrent() - startTime

                    print("""
                    ==========================
                    API : getCatalogDetail
                    Time : \(String(format: "%.3f", elapsed)) sec
                    Status : \(response.value(forKey: "code") ?? 0)
                    ==========================
                    """)

//                print("========== VARIANT CHANGE RESPONSE ==========")
//                print("🔥 REQUEST TOKEN =", requestToken)
//                print("🔥 LATEST TOKEN =", self.latestVariantRequestToken)
//                print("🔥 REQUESTED STONE ID =", requestedStoneId)
//                print("🔥 REQUESTED METAL ID =", requestedMetalId)
//                print("🔥 REQUESTED SIZE ID =", requestedSizeId)
//                print("🔥 REQUESTED SHAPE ID =", requestedShapeId)
//                print("🔥 REQUESTED POINTER ID =", requestedPointerId)
//                print("🔥 CURRENT STONE ID =", self.mStoneId)
//                print("🔥 STATUS =", status)
//                print("🔥 RESPONSE =", response)
//                print("=============================================")

                guard requestToken == self.latestVariantRequestToken else {
                    print("🛑 IGNORE STALE VARIANT RESPONSE")
                    print("🛑 REQUESTED STONE =", requestedStoneId)
                    print("🛑 CURRENT STONE =", self.mStoneId)
                    return
                }

                guard status else {
                    print("❌ NETWORK REQUEST FAILED")
                    return
                }

                guard let statusCode = response.value(forKey: "code") as? Int else {
                    print("❌ API CODE MISSING")
                    return
                }

                guard statusCode == 200 else {
                    print("❌ VARIANT API ERROR")
                    print("❌ CODE =", statusCode)
                    print(
                        "❌ MESSAGE =",
                        response.value(forKey: "message") ?? ""
                    )
                    return
                }

                guard let mProductData =
                    response.value(forKey: "data") as? NSDictionary else {

                    print("❌ VARIANT DATA MISSING")
                    return
                }
                
                if status {
                    guard let statusCode = response.value(forKey: "code") as? Int else {
                        CommonClass.showSnackBar(message: "Oops! Something went wrong.")
                        return
                    }
                    
                if statusCode == 200 {
                    if let mData = response.value(forKey: "data") as? NSDictionary,
                       let mProductData = response.value(forKey: "data") as? NSDictionary{
                        
                        print("PRODUCT DATA =", mProductData)
                        print("PRICE =", mProductData["price"] ?? "nil")
                        print("TOTAL PRICE =", mProductData["total_price"] ?? "nil")
                        print("RETAIL =", mProductData["retailprice_Inc"] ?? "nil")
                        //Varient Product ID
                        self.mVarientProductId = "\(mProductData.value(forKey: "_id") ?? "--" )"
                        
                        let variantSKU =
                            "\(mProductData.value(forKey: "SKU") ?? "")"

                        if !self.mVarientProductId.isEmpty,
                           !variantSKU.isEmpty {

                            self.mFetchVariantProductSummary(
                                variantId: self.mVarientProductId,
                                variantSKU: variantSKU
                            )
                        }
                        
                        self.mProductName.text = "\(mProductData.value(forKey: "name") ?? "--" )"
                        self.mMetaTag.text = "\(mProductData.value(forKey: "Matatag") ?? "--" )"

                        self.mSKUName.text = "\(mProductData.value(forKey: "SKU") ?? "--")"
                        self.mDescription.text = "\(mProductData.value(forKey: "Description") ?? "--")"
//                        self.mSizeName.text = "\(mProductData.value(forKey: "size_name") ?? "--" )"
//                        self.mReferenceNo.text = "\(mProductData.value(forKey: "referenceNo") ?? "--" )"
//
//                        self.mMetalName.text = "\(mProductData.value(forKey: "metal_name") ?? "--" )"
//                        self.mStoneName.text = "\(mProductData.value(forKey: "stone_name") ?? "--" )"
                        
                    
                        self.mShapeName.text = "\(mProductData.value(forKey: "shape_name") ?? "")"
                        self.mPointerName.text = "\(mProductData.value(forKey: "pointer_name") ?? "")"
//                        self.mReferenceNo.text = "\(mProductData.value(forKey: "SKU") ?? "--")"
//                        self.mPMetalName.text = "\(mProductData.value(forKey: "metal_name") ?? "--" )"
                        self.mPMetalWeight.text = "\(mProductData.value(forKey: "GrossWt") ?? "--" )g"
                        print("mUpdateData DEBUG PRODUCT STONES =", mProductData["stones"] ?? "NO STONES")
                        print("mUpdateData DEBUG GROSS WT =", mProductData["GrossWt"] ?? "NO GROSS WT")
                        print("mUpdateData DEBUG REFERENCE =", mProductData["referenceNo"] ?? "NO REFERENCE")
                        
                        if let stones = mProductData["stones"] as? [[String:Any]] {

                            self.updateStoneSummary(from: stones)

                        }
//                        if let stones = mProductData.value(forKey: "stones") as? [[String: Any]],
//                           !stones.isEmpty {
//
//                            var stoneOrder: [String] = []
//                            var stoneDict: [String: (pcs: Int, weight: Double, unit: String)] = [:]
//
//                            for stone in stones {
//
//                                let name = "\(stone["stone_name"] ?? "")"
//                                    .trimmingCharacters(in: .whitespacesAndNewlines)
//
//                                guard !name.isEmpty else {
//                                    continue
//                                }
//
//                                let pcs = Int("\(stone["Pcs"] ?? "0")") ?? 0
//                                let weight = Double("\(stone["Cts"] ?? "0")") ?? 0.0
//                                let unit = "\(stone["Unit"] ?? "")"
//
//                                if var existing = stoneDict[name] {
//
//                                    existing.pcs += pcs
//                                    existing.weight += weight
//                                    stoneDict[name] = existing
//
//                                } else {
//
//                                    stoneOrder.append(name)
//
//                                    stoneDict[name] = (
//                                        pcs: pcs,
//                                        weight: weight,
//                                        unit: unit
//                                    )
//                                }
//                            }
//
//                            var nameLines: [String] = []
//                            var weightLines: [String] = []
//
//                            for name in stoneOrder {
//
//                                guard let data = stoneDict[name] else {
//                                    continue
//                                }
//
//                                nameLines.append(name)
//
//                                let formattedWeight = String(
//                                    format: "%.2f",
//                                    data.weight
//                                )
//
//                                weightLines.append(
//                                    "\(data.pcs)   \(formattedWeight)c"
//                                )
//                            }
//
//                            self.mPStoneName.text =
//                                nameLines.joined(separator: "\n")
//
//                            self.mPStoneWeight.text =
//                                weightLines.joined(separator: "\n")
//
//                        } else {
//
//                            print("⚠️ Variant response has no stones. Keep current Product Summary until full detail is fetched.")
//
//                        }

//                        let formatter = NumberFormatter()
//                        formatter.numberStyle = .decimal
//                        formatter.minimumFractionDigits = 2
//                        formatter.maximumFractionDigits = 2
//
//                        let price = Double("\(mProductData.value(forKey: "price") ?? "0")") ?? 0.0
//                        let formattedPrice = formatter.string(from: NSNumber(value: price)) ?? "0.00"
//                        print("6mGetCatalogDetails \(price) self.mPrice = \(formattedPrice)")
//                        self.mPrice.text = "\(self.mStoreCurrency) \(formattedPrice)"
                        self.mPrice.text = "\(mProductData.value(forKey: "price") ?? "0.00" )"
                        self.mSelectedPointerPrice = " \(mProductData.value(forKey: "price") ?? "0.00" )"
                        
                        self.mProductImage.downlaodImageFromUrl(urlString: "\(mData.value(forKey: "main_image") ?? "")")
                        let sku = "\(mProductData.value(forKey: "SKU") ?? "")"
                        self.mSKUForImage = (!sku.isEmpty) ? sku : self.mSKUForImage
                        self.mProductIdForImage = (!self.mVarientProductId.isEmpty) ? self.mVarientProductId : self.mProductIdForImage
                        
                        self.mPointerList = [String]()
                        self.mPointerdPriceList = [String]()
                        
                        self.mShapeList = [String]()
                        self.mShapeIdList = [String]()
                        
                        if let mStatistic = mData.value(forKey: "inventory_statistics") as? NSDictionary {

                            if let mTotal = mStatistic.value(forKey: "total") as? Int {
                                self.mTotalCount.text = "(\(mTotal))"
                            }else{
                                self.mTotalCount.text = "(0)"
                            }
                            if let mLocArr = mStatistic.value(forKey: "response") as? NSArray {
                                
                                let locArr = NSMutableArray()
                                for i in 0..<mLocArr.count {
                                    if let mData = mLocArr[i] as? NSDictionary , mData.value(forKey: "qty") as? Int != 0 {
                                        locArr.add(mData)
                                    }
                                }
                                
                                self.mLocationData = locArr as NSArray
                                
                                let height = self.mLocationData.count * 40
                                self.mLocationTableHeight.constant = CGFloat(integerLiteral: height)
                                self.mLocationTable.reloadData()
                            }else{
                                self.mTotalCount.text = "(0)"
                            }
                            
                        }else{
                            self.mTotalCount.text = "(0)"
                        }
                        
                        if let mArr = mData.value(forKey:"stone_value") as? NSArray {
                            
                            var isTrue = false
                            if mArr.count > 0 {
                                for i in mArr {
                                    if let data = i as? NSDictionary {

                                        if self.mStoneId == "\(data.value(forKey: "_id") ?? "")" {
                                            isTrue = true
                                            self.mStoneName.text = "\(data.value(forKey: "name") ?? "")"
                                           // self.mPStoneName.text = "\(data.value(forKey: "name") ?? "")"
                                            self.mStoneId = "\(data.value(forKey: "_id") ?? "")"
                                        }
                                    }
                                }
                                
                                if !isTrue {
                                    if let datas = mArr[0] as? NSDictionary {
                                        self.mStoneName.text = "\(datas.value(forKey: "name") ?? "")"
                                       // self.mPStoneName.text = "\(datas.value(forKey: "name") ?? "")"
                                        self.mStoneId = "\(datas.value(forKey: "_id") ?? "")"
                                    }
                                }
                            }else{
//                                self.mStoneId = ""
//                                self.mStoneView.isHidden = true
                                self.mStoneView.isHidden = false
                                self.mStoneName.text = "--"
                            }
                        }
                        
                        if let mArr  = mData.value(forKey: "choice_data") as? NSArray {
                            if mArr.count > 0 {
                                self.mChoiceData =  mArr
                            }
                        }
                        
                        if let mArr = mData.value(forKey:"size_value") as? NSArray {
                            
                            if mArr.count > 0 {
                                
                                var isTrue = false
                                for i in mArr {
                                    if let sizeData = i as? NSDictionary {
                                        
                                        if self.mSizeId == "\(sizeData.value(forKey:"_id") ?? "")" {
                                            isTrue = true
                                            self.mSizeName.text = "\(sizeData.value(forKey: "name") ?? "")"
                                            self.mSizeId = "\(sizeData.value(forKey: "_id") ?? "")"
                                        }
                                    }
                                }

                                if !isTrue {
                                    if let datas = mArr[0] as? NSDictionary {
                                        self.mSizeName.text = "\(datas.value(forKey: "name") ?? "")"
                                        self.mSizeId = "\(datas.value(forKey: "_id") ?? "")"
                                    }
                                }
                                
                            }else{
                                self.mSizeId = ""
                                self.mSizeView.isHidden = true
                            }
                        }
                        
                        if let mArr = mData.value(forKey:"metal_value") as? NSArray {
                            if mArr.count > 0 {
                                var isTrue = false
                                
                                for i in mArr {
                                    if let data = i as? NSDictionary {
                                        
                                        if self.mMetalId == "\(data.value(forKey:"_id") ?? "")" {
                                            isTrue = true
                                            self.mMetalName.text = "\(data.value(forKey: "name") ?? "")"
                                            self.mPMetalName.text = "\(data.value(forKey: "name") ?? "")"
                                            self.mMetalId = "\(data.value(forKey: "_id") ?? "")"
                                        }
                                    }
                                }
                                
                                if !isTrue {
                                    if let datas = mArr[0] as? NSDictionary {
                                        self.mMetalName.text = "\(datas.value(forKey: "name") ?? "")"
                                        self.mPMetalName.text = "\(datas.value(forKey: "name") ?? "")"
                                        self.mMetalId = "\(datas.value(forKey: "_id") ?? "")"
                                    }
                                }
                                
                            }else{
                                self.mMetalId = ""
                                self.mMetalView.isHidden = true
                                
                            }
                        }

                        if let mArr = mData.value(forKey:"choice_data") as? NSArray {
                            if mArr.count > 0 {
                                for i in mArr {
                                    if let data = i as? NSDictionary {
                                        self.mShapeList.append("\(data.value(forKey:"name") ?? "") ")
                                        self.mShapeIdList.append("\(data.value(forKey:"id") ?? "")")
                                        
                                        if "\(mProductData.value(forKey: "shape_name") ?? "")" == "\(data.value(forKey: "name") ?? "")" {
                                            self.mShapeId = "\(data.value(forKey: "id") ?? "")"
                                            
                                            if let mArr = mData.value(forKey:"data") as? NSArray {
                                                
                                                if mArr.count > 0 {
                                                    for i in mArr {
                                                        if let data = i as? NSDictionary {
                                                            
                                                            self.mPointerList.append("\(data.value(forKey:"pointer") ?? "0.0")")
                                                            self.mPointerdPriceList.append("\(data.value(forKey:"price") ?? "0.00" )")
                                                            
                                                            if "\(mProductData.value(forKey: "pointer_name") ?? "")" == "\(data.value(forKey: "pointer") ?? "")" {
                                                                self.mPointerId = "\(data.value(forKey: "pointer") ?? "")"
                                                            }
                                                            
                                                            if "\(mProductData.value(forKey: "pointer_name") ?? "")" == "" {
                                                                
                                                                if let data = mArr[0] as? NSDictionary {
                                                                    self.mPointerName.text = "\(data.value(forKey: "pointer") ?? "")"
                                                                    self.mPointerId = "\(data.value(forKey: "pointer") ?? "")"
//                                                                    let formatter = NumberFormatter()
//                                                                    formatter.numberStyle = .decimal
//                                                                    formatter.minimumFractionDigits = 2
//                                                                    formatter.maximumFractionDigits = 2
//
//                                                                    let price = Double("\(mProductData.value(forKey: "price") ?? "0")") ?? 0.0
//                                                                    let formattedPrice = formatter.string(from: NSNumber(value: price)) ?? "0.00"
//                                                                    print("7mGetCatalogDetails \(price) self.mPrice = \(formattedPrice)")
//                                                                    self.mPrice.text = "\(self.mStoreCurrency) \(formattedPrice)"
                                                                    self.mPrice.text = "\(data.value(forKey: "price") ?? "0.00")"
                                                                }
                                                            }
                                                        }
                                                    }
                                                }else{
                                                    self.mPointerView.isHidden = true
                                                }
                                            }
                                            
                                        }
                                        
                                        if "\(mProductData.value(forKey: "shape_name") ?? "")" == "" {
                                            
                                            self.mPointerList = [String]()
                                            self.mPointerdPriceList = [String]()
                                            if let mData = mArr[0] as? NSDictionary {
                                                self.mShapeName.text = "\(data.value(forKey: "name") ?? "")"
                                                self.mShapeId = "\(data.value(forKey: "id") ?? "")"
                                                if let mArr = mData.value(forKey: "data") as? NSArray {
                                                    if mArr.count > 0 {
                                                        for data in mArr {
                                                            if let mData = data as? NSDictionary {
                                                                self.mPointerList.append("\(mData.value(forKey: "pointer") ?? "0.0")")
                                                                self.mPointerdPriceList.append("\(mData.value(forKey: "price") ?? "0.00")")
                                                            }
                                                        }
                                                        
                                                        if let data = mArr[0] as? NSDictionary {
                                                            self.mPointerName.text = "\(data.value(forKey: "pointer") ?? "0.0")"
                                                            self.mPointerId = "\(data.value(forKey: "pointer") ?? "0.0")"
//                                                            let formatter = NumberFormatter()
//                                                            formatter.numberStyle = .decimal
//                                                            formatter.minimumFractionDigits = 2
//                                                            formatter.maximumFractionDigits = 2
//
//                                                            let price = Double("\(mProductData.value(forKey: "price") ?? "0")") ?? 0.0
//                                                            let formattedPrice = formatter.string(from: NSNumber(value: price)) ?? "0.00"
//                                                            print("8mGetCatalogDetails \(price) self.mPrice = \(formattedPrice)")
//                                                            self.mPrice.text = "\(self.mStoreCurrency) \(formattedPrice)"
                                                            self.mPrice.text =  "\(data.value(forKey: "price") ?? "0.00")"
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }else{
                                self.mPointerId = ""
                                self.mShapeId = ""
                                self.mShapeView.isHidden = true
                                
                            }
                        }else{
                            self.mPointerId = ""
                            self.mShapeId = ""
                            self.mShapeView.isHidden = true
                            self.mPointerView.isHidden = true
                        }
                   }
                    
                    
                }else {
                    if let error = response.value(forKey: "error") as? String{
                        if error == "Authorization has been expired" {
                            CommonClass.sessionExpired(isExpired: true, navigation: self.navigationController)
                        } else {
                            CommonClass.showSnackBar(message: "Error \(statusCode): \(error)")
                        }
                    }
                    if let message = response.value(forKey: "message") as? String {
                        CommonClass.showSnackBar(message: "Error \(statusCode): \(message)")
                    }
                }

            }
        }
        }else{
            CommonClass.showSnackBar(message: "No Internet Connection")
        }


     }
    


    private func showProceedConfirmation(onProceed: @escaping () -> Void) {
        guard let windowScene = view.window?.windowScene ??
                UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first(where: { $0.activationState == .foregroundActive }),
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            onProceed()
            return
        }

        if window.viewWithTag(98765) != nil { return }

        let overlay = UIView(frame: window.bounds)
        overlay.tag = 98765
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.55)
        overlay.alpha = 0
        overlay.translatesAutoresizingMaskIntoConstraints = false
        window.addSubview(overlay)

        NSLayoutConstraint.activate([
            overlay.leadingAnchor.constraint(equalTo: window.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: window.trailingAnchor),
            overlay.topAnchor.constraint(equalTo: window.topAnchor),
            overlay.bottomAnchor.constraint(equalTo: window.bottomAnchor)
        ])

        let popup = UIView()
        popup.translatesAutoresizingMaskIntoConstraints = false
        popup.backgroundColor = .white
        popup.layer.cornerRadius = 8
        overlay.addSubview(popup)

        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = "Confirmation"
        title.textAlignment = .center
        title.font = .systemFont(ofSize: 14, weight: .medium)

        let msg = UILabel()
        msg.translatesAutoresizingMaskIntoConstraints = false
        msg.text = "Do you want to quit the page or proceed?"
        msg.numberOfLines = 2
        msg.textAlignment = .center
        msg.font = .systemFont(ofSize: 12)

        let quit = UIButton(type: .system)
        quit.translatesAutoresizingMaskIntoConstraints = false
        quit.setTitle("Quit", for: .normal)

        let proceed = UIButton(type: .system)
        proceed.translatesAutoresizingMaskIntoConstraints = false
        proceed.setTitle("Proceed", for: .normal)
        proceed.setTitleColor(.white, for: .normal)
        proceed.backgroundColor = .systemBlue
        proceed.layer.cornerRadius = 6

        popup.addSubview(title); popup.addSubview(msg); popup.addSubview(quit); popup.addSubview(proceed)
        NSLayoutConstraint.activate([
            popup.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            popup.centerYAnchor.constraint(equalTo: overlay.centerYAnchor),
            popup.widthAnchor.constraint(equalToConstant: 320),

            title.topAnchor.constraint(equalTo: popup.topAnchor, constant: 24),
            title.leadingAnchor.constraint(equalTo: popup.leadingAnchor, constant: 12),
            title.trailingAnchor.constraint(equalTo: popup.trailingAnchor, constant: -12),

            msg.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 8),
            msg.leadingAnchor.constraint(equalTo: popup.leadingAnchor, constant: 12),
            msg.trailingAnchor.constraint(equalTo: popup.trailingAnchor, constant: -12),

            quit.topAnchor.constraint(equalTo: msg.bottomAnchor, constant: 24),
            quit.leadingAnchor.constraint(equalTo: popup.leadingAnchor, constant: 20),
            quit.bottomAnchor.constraint(equalTo: popup.bottomAnchor, constant: -20),
            quit.heightAnchor.constraint(equalToConstant: 40),

            proceed.topAnchor.constraint(equalTo: msg.bottomAnchor, constant: 24),
            proceed.trailingAnchor.constraint(equalTo: popup.trailingAnchor, constant: -20),
            proceed.leadingAnchor.constraint(equalTo: quit.trailingAnchor, constant: 12),
            proceed.widthAnchor.constraint(equalTo: quit.widthAnchor),
            proceed.heightAnchor.constraint(equalToConstant: 40)
        ])

        quit.addAction(UIAction { _ in
            overlay.removeFromSuperview()
            self.navigationController?.popViewController(animated: true)
        }, for: .touchUpInside)

        proceed.addAction(UIAction { _ in
            overlay.removeFromSuperview()
            onProceed()
        }, for: .touchUpInside)

        UIView.animate(withDuration: 0.2) { overlay.alpha = 1 }
    }

}
