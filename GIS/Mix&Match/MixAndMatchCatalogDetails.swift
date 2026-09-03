//
//  MixAndMatchCatalogDetails.swift
//  GIS
//
//  Created by MacBook Hawkscode  on 17/02/23.
//  Copyright © 2023 Hawkscode. All rights reserved.
//

import UIKit
import UIKit
import DropDown
import Alamofire

protocol GetCatalogDetailsDelegate {
    func mGetCatalogItemDetails(data:NSDictionary)
}

class MixAndMatchCatalogDetails: UIViewController , UICollectionViewDelegate , UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate, UIViewControllerTransitioningDelegate ,UITableViewDelegate, UITableViewDataSource {
    var delegate:GetCatalogDetailsDelegate? = nil
    
    @IBOutlet weak var mHeading: UILabel!
    @IBOutlet weak var mBottomView: UIView!
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
    
    @IBOutlet weak var mHeart: UIImageView!
    var mSizeList = [String]()
    var mSizeIdList = [String]()
    var mShapeList = [String]()
    var mShapeIdList = [String]()
    var mPointerList = [String]()
    var mPointerdPriceList = [String]()
    var mChoiceData = NSArray()
    var mMetalId = ""
    var mStoneId = ""
    var mSizeId = ""
    var mShapeId = ""
    var mPointerId = ""
    var mPointerPrice = ""
    var mData = NSDictionary()
    var mImageData = NSArray()
    var mProductId = ""
    var mSKU = ""
    
    var mType = ""
    var isWishListed = ""
    var mCustomerId = ""

    private var isInitialVariantLoad = true
    private var isVariantRequestRunning = false
    private var variantRequestSequence = 0

    @IBOutlet weak var mTotalCount: UILabel!


    @IBOutlet weak var mPStoneWeight: UILabel!
    @IBOutlet weak var mPStoneName: UILabel!
    @IBOutlet weak var mPMetalWeight: UILabel!
    @IBOutlet weak var mPMetalName: UILabel!
    @IBOutlet weak var mAddToCartBUTTON: UIButton!
    @IBOutlet weak var mSelctSizeField: UITextField!
    @IBOutlet weak var mSizeView: UIView!
    @IBOutlet weak var mMetalLABEL: UILabel!
    
    @IBOutlet weak var mStoneLABEL: UILabel!
    
    @IBOutlet weak var mSizeLABEL: UILabel!
    
    var mJewelryData = NSDictionary()
    
    @IBOutlet weak var mPointerLABEL: UILabel!
    @IBOutlet weak var mShapeLABEL: UILabel!
    
    @IBOutlet weak var mDescriptionLABEL: UILabel!
    
    @IBOutlet weak var mSelectButton: UIButton!
    @IBOutlet weak var mProductSummaryLABEL: UILabel!
    @IBOutlet weak var mMaterialLABEL: UILabel!
    @IBOutlet weak var mPStoneLABEL: UILabel!
    @IBOutlet weak var mReferenceNoLABEL: UILabel!
    @IBOutlet weak var mCertificateLABEL: UILabel!
    
    var mLocationData = NSArray()
    @IBOutlet weak var mLocationTable: UITableView!
    @IBOutlet weak var mLocationTableHeight: NSLayoutConstraint!
    
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
        
        mPointerLABEL.text = "Pointer".localizedString
        mShapeLABEL.text = "Shape".localizedString
        mStoneName.placeholder = "Select".localizedString
        mMetalName.placeholder = "Select".localizedString
        mSizeName.placeholder = "Select".localizedString
        mSelectButton.setTitle("SELECT".localizedString, for: .normal)
        
        if mType == "catalog" {
            mHeading.text = "Catalog".localizedString
        }else{
            mHeading.text = "Inventory".localizedString
        }
        
        
        if mCustomerId == "" {
            mHeart.isHidden = true
        }else{
            mHeart.isHidden = true
        }
       
    }

    var mStoreCurrency = "$"
    var mProductIdForImage = ""
    var mSKUForImage = ""
    
    override func viewDidLoad() {
        

        super.viewDidLoad()

        let tap = UITapGestureRecognizer(target: self, action: #selector(onTapImage))
        tap.delegate = self
        mProductImage.isUserInteractionEnabled = true
        mProductImage.addGestureRecognizer(tap)

        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
        self.mTotalCount.text = "(0)"

        mBottomView.layer.cornerRadius = 20
        mBottomView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        mBottomView.dropShadow()
        _ = UserDefaults.standard.string(forKey: "location")
    
        if let mStoreCurr = UserDefaults.standard.string(forKey: "currencySymbol") {
            self.mStoreCurrency = mStoreCurr
        }
        mProductId =  "\(mData.value(forKey: "product_id") ?? "")"
        mSKU =  "\(mData.value(forKey: "SKU") ?? "--")"
        
        
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
        mProductImage.downlaodImageFromUrl(urlString: "\(mData.value(forKey: "main_image") ?? "")")
        
        
        
        mUpdateData()
    }
    
    @IBAction func mViewImage(_ sender: Any) {
//        mOpenGlobalImageViewer() essindy
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
    
    
    @IBAction func mBack(_ sender: Any) {
        
        dismiss(animated: false)
        
    }
    
    @IBAction func mSelectProduct(_ sender: Any) {

        let selectedData = NSMutableDictionary(dictionary: mJewelryData)

        selectedData.setValue(mMetalId, forKey: "metalId")
        selectedData.setValue(mSizeId, forKey: "sizeId")
        selectedData.setValue(mStoneId, forKey: "stoneId")
        selectedData.setValue(mPointerId, forKey: "pointerId")
        selectedData.setValue(mPointerPrice, forKey: "pointerPriceId")
        selectedData.setValue(mShapeId, forKey: "shapeId")

        selectedData.setValue(
            mShapeName.text ?? "",
            forKey: "shapeName"
        )

        selectedData.setValue(
            mMetalName.text ?? "",
            forKey: "metalName"
        )

        selectedData.setValue(
            mSizeName.text ?? "",
            forKey: "sizeName"
        )

        selectedData.setValue(
            mStoneName.text ?? "",
            forKey: "stoneName"
        )

        selectedData.setValue(mType, forKey: "type")


        print("========== SELECTED VARIANT ==========")
        print("SKU =", selectedData["SKU"] ?? "")
        print("_id =", selectedData["_id"] ?? "")
        print("product_id =", selectedData["product_id"] ?? "")
        print("metalId =", selectedData["metalId"] ?? "")
        print("stoneId =", selectedData["stoneId"] ?? "")
        print("sizeId =", selectedData["sizeId"] ?? "")
        print("======================================")


        delegate?.mGetCatalogItemDetails(data: selectedData)

        dismiss(animated: false)
    }
    
    
    @IBAction func mLikeDislike(_ sender: Any) {
        
        
        if mCustomerId == "" {
            
            return
        }
        
        CommonClass.showFullLoader(view: self.view)
        let mLocation = UserDefaults.standard.string(forKey: "location") ?? ""
//        let params = ["search":mSKU,"location":mLocation,"customer_id":mCustomerId, "isWishlist":isWishListed,"SKU":mSKU, "type":mType, "product_id": mProductId]
        let params = [
            "search":mSKU,
            "location":mLocation,
            "customer_id":mCustomerId,
            "isWishlist":isWishListed,
            "SKU":mSKU,
            "type":mType,
            "product_id":mProductId
        ]
        
        
        mGetData(url: mAddToFav,headers: sGisHeaders,  params: params) { response , status in
            CommonClass.stopLoader()
            if status {
                if "\(response.value(forKey: "code") ?? "")" == "200" {
                    
                    guard let mData = response.value(forKey: "data") as? NSDictionary else {
                        return
                    }
                    
                    self.isWishListed = "\(mData.value(forKey: "isWishlist") ?? "0")"
                    let wishListed = self.isWishListed == "0"
                    
                    self.mHeart.image = UIImage(systemName: wishListed ? "heart" : "heart.fill")
                    self.mHeart.tintColor = UIColor(named: wishListed ? "themeExtraLightText1" : "themeLightRed")
                }
                
            }
        }
        
    }
    
    @IBAction func mAddSize(_ sender: Any) {
        let count = mSize.text
        let mTotal = (Int(count ?? "") ?? 0) + 1
        
        mSize.text = "\(mTotal)"
        
    }
    
    @IBAction func mSubtractSize(_ sender: Any) {
        let count = mSize.text
        
        if(count != "0"){
            let mTotal =  (Int(count ?? "") ?? 0) - 1
            mSize.text = "\(mTotal)"
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
            cells.mLocationQty.text = "\(mData.value(forKey: "qty") ?? "--")"
            
//            cells.mLocationName.text = "\(mData.value(forKey: "location_name") ?? "--")"
            let location = "\(mData.value(forKey: "location_name") ?? "")"
            switch location.lowercased() {

            case "bangkok", "thailand":
                cells.mLocationName.text = "🇹🇭 \(mData.value(forKey: "location_name") ?? "--")"
//                cells.mLocationFlag.text = "🇹🇭"

            case "usa", "united states":
//                cells.mLocationFlag.text = "🇺🇸"
                cells.mLocationName.text = "🇺🇸 \(mData.value(forKey: "location_name") ?? "--")"
            case "europe":
//                cells.mLocationFlag.text = "🇪🇺"
                cells.mLocationName.text = "🇪🇺 \(mData.value(forKey: "location_name") ?? "--")"
            case "middle east":
//                cells.mLocationFlag.text = "🌍"
                cells.mLocationName.text = "🌍 \(mData.value(forKey: "location_name") ?? "--")"
            // หรือ 🇴🇲 🇸🇦 🇦🇪 แล้วแต่ประเทศจริง

            default:
                cells.mLocationName.text = "📍 \(mData.value(forKey: "location_name") ?? "--")"
//                cells.mLocationFlag.text = "📍"
            }
            
        }else{
            mLocationTable.isHidden = true
        }
        
        return cells
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mImageData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        guard let cells = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductImageCell",for:indexPath) as? ProductImageCell else {
            return UICollectionViewCell()
        }
        let mDatas = mImageData[indexPath.row] as? NSDictionary
        
        cells.mProductImage.downlaodImageFromUrl(urlString: "\(mDatas?.value(forKey: "image") ?? "")")
        
        return cells
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cells = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductImageCell",for:indexPath) as? ProductImageCell
        
        let layout = collectionViewLayout as? UICollectionViewFlowLayout
        
        return CGSize(width: view.frame.width, height: 220)
        
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
        dropdown.bottomOffset = CGPoint(
            x: 0,
            y: self.mChooseMetalButt.frame.size.height
        )

        dropdown.width = 200
        dropdown.dataSource = mMetalList

        dropdown.selectionAction = {
            [unowned self] (index: Int, item: String) in

            guard index < self.mMetalIdList.count else {
                return
            }

            let selectedId = self.mMetalIdList[index]

            guard self.mMetalId != selectedId else {
                return
            }

            self.mMetalName.text = item.trimmingCharacters(in: .whitespaces)
            self.mMetalId = selectedId

            print("🔥 USER SELECT METAL =", selectedId)

            self.mUpdateData()
        }

        dropdown.show()
    }
    
    @IBAction func mChooseStone(_ sender: Any) {
        
        let dropdown = DropDown()
        dropdown.anchorView = self.mChooseStoneButt
        dropdown.direction = .any
        dropdown.bottomOffset = CGPoint(x: 0, y: self.mChooseStoneButt.frame.size.height)
        dropdown.width = 200
        dropdown.dataSource = mStoneList
        dropdown.selectionAction = {
            [unowned self](index:Int, item: String) in
            
            self.mStoneName.text  = item
            if self.mStoneId != self.mStoneIdList[index] {
                self.mStoneId =  self.mStoneIdList[index]
                self.mUpdateData()
            }
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
            if self.mSizeId !=  self.mSizeIdList[index]{
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
                let mData = data as? NSDictionary
                if mData?.value(forKey: "id") as? String ?? "" == self.mShapeId {
                    if let mArr = mData?.value(forKey: "data") as? NSArray, mArr.count > 0 {
                        self.mPointerList = [String]()
                        self.mPointerdPriceList = [String]()
                        for data in mArr {
                            if let mData = data as? NSDictionary {
                                self.mPointerList.append(mData.value(forKey: "pointer") as? String ?? "0.0")
                                self.mPointerdPriceList.append(mData.value(forKey: "price") as? String ?? "0.00")
                            }
                        }
                        
                        if let data = mArr[0] as? NSDictionary {
                            self.mPointerName.text = "\(data.value(forKey: "pointer") ?? "0.0")"
                            self.mPointerId = "\(data.value(forKey: "pointer") ?? "0.0")"
                            self.mPrice.text =  self.mStoreCurrency + " \(data.value(forKey: "price") ?? "0.00")"
                            self.mPointerPrice = "\(data.value(forKey: "price") ?? "0.00")"
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
            self.mPrice.text = self.mStoreCurrency + " " + self.mPointerdPriceList[index]
            self.mPointerPrice = self.mPointerdPriceList[index]
            
            
        }
        dropdown.show()
        
        
    }
    
    
    
    func mUpdateData(){
        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
        let mLocation = UserDefaults.standard.string(forKey: "location")
        
        
        
        if Reachability.isConnectedToNetwork() == true {
            
//            let params:[String: Any] = [
//                "product_id" : mProductId,
//                "type":mType,
//                "Metal":mMetalId,
//                "Size":mSizeId,
//                "Stone":mStoneId,
//                "customer_id": mCustomerId]
            variantRequestSequence += 1
                let currentSequence = variantRequestSequence

                let params: [String: Any] = [
                    "product_id": self.mProductId,
                    "Metal": self.mMetalId,
                    "Size": self.mSizeId,
                    "Stone": self.mStoneId,
                    "type": self.mType
                ]

                print("========== VARIANT REQUEST \(currentSequence) ==========")
                print(params)

                CommonClass.showFullLoader(view: self.view)
            
            print("========== MIX MATCH VARIANT TRACE ==========")
            print("🔥 PRODUCT ID =", self.mProductId)
            print("🔥 METAL ID =", self.mMetalId)
            print("🔥 STONE ID =", self.mStoneId)
            print("🔥 SIZE ID =", self.mSizeId)
            print("🔥 PARAMS =", params)
            print("🔥 SKU LABEL BEFORE =", self.mSKUName.text ?? "")
            print("================================================")
            print("\n========== MIX MATCH DETAIL REQUEST ==========")
            print("🔥 CLASS =", String(describing: type(of: self)))
            print("🔥 FUNCTION =", #function)
            print("🔥 TIME =", Date())
            print("🔥 PARAMS =", params)
            print("================================================\n")
            mGetData(url: mGetMixAndMatchCatalogDetails,headers: sGisHeaders,  params: params) { response , status in
                CommonClass.stopLoader()
                print("\n========== MIX MATCH DETAIL RESPONSE ==========")
                    print("🔥 CLASS =", String(describing: type(of: self)))
                    print("🔥 FUNCTION =", #function)
                    print("🔥 TIME =", Date())
                    print("🔥 STATUS =", status)
                    print("🔥 CODE =", response.value(forKey: "code") ?? "")
                    print("🔥 RESPONSE =", response)
                    print("=================================================\n")
                
                guard currentSequence == self.variantRequestSequence else {
                            print("⚠️ IGNORE OLD RESPONSE =", currentSequence)
                            return
                        }

                        CommonClass.stopLoader()

                        guard status,
                              "\(response.value(forKey: "code") ?? "")" == "200",
                              let data = response.value(forKey: "data") as? NSDictionary
                        else {
                            return
                        }

                        print("✅ APPLY RESPONSE =", currentSequence)
                        print("✅ SKU =", data.value(forKey: "SKU") ?? "")

                        self.mSKUName.text =
                            "\(data.value(forKey: "SKU") ?? "--")"
                
                if status {
                    if "\(response.value(forKey: "code") ?? "")" == "200" {
                        if let data = response.value(forKey: "data") as? NSDictionary {
                            print(data)
                            let mData = data
                            let mProductData = data
                            self.mJewelryData = mData
                            
                            print("========== MIX MATCH VARIANT RESULT ==========")
                            print("🔥 RESPONSE VARIANT ID =", mData.value(forKey: "_id") ?? "")
                            print("🔥 RESPONSE SKU =", mData.value(forKey: "SKU") ?? "")
                            print("🔥 RESPONSE PRODUCT ID =", mData.value(forKey: "product_id") ?? "")
                            print("🔥 RESPONSE METAL =", mData.value(forKey: "metal_name") ?? "")
                            print("🔥 RESPONSE STONE =", mData.value(forKey: "stone_name") ?? "")
                            print("🔥 RESPONSE SIZE =", mData.value(forKey: "size_name") ?? "")
                            print("🔥 SKU LABEL BEFORE UPDATE =", self.mSKUName.text ?? "")
                            print("================================================")
                            
                            self.mProductName.text = "\(mProductData.value(forKey: "name") ?? "--" )"
                            self.mMetaTag.text = "\(mProductData.value(forKey: "Matatag") ?? "--" )"
                            
                            self.mSKUName.text = "\(mProductData.value(forKey: "SKU") ?? "--")"
                            print("🔥 SKU LABEL AFTER UPDATE =", self.mSKUName.text ?? "")
                            self.mDescription.text = "\(mProductData.value(forKey: "Description") ?? "--")"
                            self.mSizeName.text = "\(mProductData.value(forKey: "size_name") ?? "--" )"
                            self.mReferenceNo.text = "\(mProductData.value(forKey: "referenceNo") ?? "--" )"
                            
                            self.mMetalName.text = "\(mProductData.value(forKey: "metal_name") ?? "--" )"
                            self.mStoneName.text = "\(mProductData.value(forKey: "stone_name") ?? "--" )"
                            
                            
                            self.mShapeName.text = "\(mProductData.value(forKey: "shape_name") ?? "")"
                            self.mPointerName.text = "\(mProductData.value(forKey: "pointer_name") ?? "")"
                            self.mReferenceNo.text = "\(mProductData.value(forKey: "SKU") ?? "--")"
                            self.mPMetalName.text = "\(mProductData.value(forKey: "metal_name") ?? "--" )"
                            self.mPMetalWeight.text = "\(mProductData.value(forKey: "GrossWt") ?? "--" )"
                            
                            if let stones = mProductData.value(forKey: "stones") as? [[String: Any]] {
    
                                var stoneDict: [String:(pcs:Int, weight:Double, unit:String)] = [:]
                                
                                for stone in stones {
                                    
                                    let name = stone["stone_name"] as? String ?? ""
                                    let pcs = stone["Pcs"] as? Int ?? 0
                                    let weight = Double("\(stone["Cts"] ?? "0")") ?? 0
                                    let unit = stone["Unit"] as? String ?? ""
                                    
                                    if var exist = stoneDict[name] {
                                        exist.pcs += pcs
                                        exist.weight += weight
                                        stoneDict[name] = exist
                                    } else {
                                        stoneDict[name] = (pcs, weight, unit)
                                    }
                                }
                                
                                var nameLines: [String] = []
                                var weightLines: [String] = []
                                
                                for (name,data) in stoneDict {
                                    nameLines.append(name)
                                    weightLines.append("\(data.pcs) \(data.weight) \(data.unit)")
                                }
                                
                                self.mPStoneName.text = nameLines.joined(separator: "\n")
                                self.mPStoneWeight.text = weightLines.joined(separator: "\n")
                            }
                            self.mPrice.text = self.mStoreCurrency + " \(mProductData.value(forKey: "price") ?? "--" )"
                            self.mPointerPrice = "\(mProductData.value(forKey: "price") ?? "--" )"
                            
                            self.mPointerList = [String]()
                            self.mPointerdPriceList = [String]()
                            
                            self.mShapeList = [String]()
                            self.mShapeIdList = [String]()
                            
                            self.mSizeList = [String]()
                            self.mSizeIdList = [String]()
                            
                            self.mMetalList = [String]()
                            self.mMetalIdList = [String]()
                            
                            self.mStoneList = [String]()
                            self.mStoneIdList = [String]()
                            
                            
                            
                            
                            if let mStatistic = mData.value(forKey: "inventory_statistics") as? NSDictionary {
                                
                                if let mTotal = mStatistic.value(forKey: "total") as? Int {
                                    self.mTotalCount.text = "(\(mTotal))"
                                }else{
                                    self.mTotalCount.text = "(0)"
                                }
                                if let mLocArr = mStatistic.value(forKey: "response") as? NSArray {
                                    self.mLocationData = mLocArr
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
                                            self.mStoneList.append("\(data.value(forKey:"name") ?? "") ")
                                            self.mStoneIdList.append("\(data.value(forKey:"_id") ?? "")")
                                            
                                            if self.mStoneId == "\(data.value(forKey: "_id") ?? "")" {
                                                isTrue = true
                                                self.mStoneName.text = "\(data.value(forKey: "name") ?? "")"
                                                self.mPStoneName.text = "\(data.value(forKey: "name") ?? "")"
                                                self.mStoneId = "\(data.value(forKey: "_id") ?? "")"
                                            }
                                        }
                                    }
                                    if !isTrue {
                                        
                                        if let datas = mArr[0] as? NSDictionary {
                                            self.mStoneName.text = "\(datas.value(forKey: "name") ?? "")"
                                            self.mPStoneName.text = "\(datas.value(forKey: "name") ?? "")"
                                            self.mStoneId = "\(datas.value(forKey: "_id") ?? "")"
                                        }
                                    }
                                }else{
                                    self.mStoneId = ""
                                    self.mStoneView.isHidden = true
                                    
                                }
                                
                            }
                            
                            
                            
                            
                            if mData.value(forKey: "choice_data") != nil {
                                
                                if let mArr  = mData.value(forKey: "choice_data") as? NSArray {
                                    if mArr.count > 0 {
                                        self.mChoiceData =  mArr
                                    }
                                }
                            }
                            
                            if let mArr = mData.value(forKey:"size_value") as? NSArray {
                                
                                if mArr.count > 0 {
                                    var isTrue = false
                                    for i in mArr {
                                        if let sizeData = i as? NSDictionary {
                                            let name = sizeData.value(forKey: "name") as? String ?? ""
                                            let id = sizeData.value(forKey: "_id") as? String ?? ""
                                            
                                            self.mSizeList.append(name)
                                            self.mSizeIdList.append(id)
                                            
                                            if self.mSizeId == id {
                                                isTrue = true
                                                self.mSizeName.text = name
                                                self.mSizeId = id
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
                            
                            if let mArr = mData.value(forKey:"metal_value") as? NSArray,
                               mArr.count > 0 {
                                var isTrue = false
                                
                                for i in mArr {
                                    if let data = i as? NSDictionary,
                                       let name = data.value(forKey: "name"),
                                       let id = data.value(forKey: "_id") {
                                        self.mMetalList.append("\(name) ")
                                        self.mMetalIdList.append("\(id)")
                                        
                                        if self.mMetalId == "\(id)" {
                                            isTrue = true
                                            self.mMetalName.text = "\(name)"
                                            self.mPMetalName.text = "\(name)"
                                            self.mMetalId = "\(id)"
                                        }
                                    }
                                }
                                if !isTrue {
                                    if let datas = mArr[0] as? NSDictionary,
                                       let name = datas.value(forKey: "name"),
                                       let id = datas.value(forKey: "_id") {
                                        self.mMetalName.text = "\(name)"
                                        self.mPMetalName.text = "\(name)"
                                        self.mMetalId = "\(id)"
                                    }
                                }
                            }else{
                                self.mMetalId = ""
                                self.mMetalView.isHidden = true
                                
                            }
                            
                            if let mArr = mData.value(forKey:"choice_data") as? NSArray, mArr.count > 0 {
                                
                                for i in mArr {
                                    if let data = i as? NSDictionary {
                                        self.mShapeList.append("\(data.value(forKey:"name") ?? "") ")
                                        self.mShapeIdList.append("\(data.value(forKey:"id") ?? "")")
                                        
                                        if "\(mProductData.value(forKey: "shape_name") ?? "")" == "\(data.value(forKey: "name") ?? "")" {
                                            self.mShapeId = "\(data.value(forKey: "id") ?? "")"
                                            
                                            if let mArr = mData.value(forKey:"data") as? NSArray, mArr.count > 0 {
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
                                                                self.mPrice.text = self.mStoreCurrency + " \(data.value(forKey: "price") ?? "0.00")"
                                                                self.mPointerPrice = "\(data.value(forKey: "price") ?? "0.00")"
                                                            }
                                                        }
                                                    }
                                                }
                                            }else{
                                                self.mPointerView.isHidden = true
                                            }
                                            
                                        }
                                        
                                        if "\(mProductData.value(forKey: "shape_name") ?? "")" == "" {
                                            
                                            self.mPointerList = [String]()
                                            self.mPointerdPriceList = [String]()
                                            if let mData = mArr[0] as? NSDictionary {
                                                self.mShapeName.text = "\(data.value(forKey: "name") ?? "")"
                                                self.mShapeId = "\(data.value(forKey: "id") ?? "")"
                                                
                                                if let mArr = mData.value(forKey: "data") as? NSArray,
                                                   mArr.count > 0 {
                                                    for data in mArr {
                                                        if let mData = data as? NSDictionary {
                                                            self.mPointerList.append("\(mData.value(forKey: "pointer") ?? "0.0")")
                                                            self.mPointerdPriceList.append("\(mData.value(forKey: "price") ?? "0.00")")
                                                        }
                                                    }
                                                    
                                                    if let data = mArr[0] as? NSDictionary {
                                                        self.mPointerName.text = "\(data.value(forKey: "pointer") ?? "0.0")"
                                                        self.mPointerId = "\(data.value(forKey: "pointer") ?? "0.0")"
                                                        self.mPrice.text = self.mStoreCurrency + " \(data.value(forKey: "price") ?? "0.00")"
                                                        self.mPointerPrice = "\(data.value(forKey: "price") ?? "0.00")"
                                                        self.mPointerView.isHidden = false
                                                    }
                                                }
                                            }else{
                                                self.mPointerView.isHidden = true
                                            }
                                            
                                        }
                                    }
                                }
                                
                            }else {
                                self.mPointerId = ""
                                self.mPointerPrice = ""
                                
                                self.mShapeId = ""
                                self.mShapeView.isHidden = true
                                self.mPointerView.isHidden = true
                                
                            }
                            
                            
                            
                            
                            
                        }
                        
                    }else{
                        let message = "\(response.value(forKey: "message") ?? "No Data Available..")"

                        CommonClass.showSnackBar(message: message)
                    }
                }
            }
        }else{
            CommonClass.showSnackBar(message: "No Internet Connection")
        }
        
        
    }
    
}
