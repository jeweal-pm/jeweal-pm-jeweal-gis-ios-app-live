//
//  MixAndMatchComplete.swift
//  GIS
//
//  Created by MacBook Hawkscode  on 15/02/23.
//  Copyright © 2023 Hawkscode. All rights reserved.
//

import UIKit
import Alamofire
class MixAndMatchComplete: UIViewController,EngravingDelegate, UIViewControllerTransitioningDelegate, GetCatalogDetailsDelegate, GetCatalogData ,GetDiamondData ,GetSelectedDiamondDelegate {
    
    @IBOutlet weak var mAddToCartButton: UIButton!
    @IBOutlet weak var mTotalAmount: UILabel!
    @IBOutlet weak var mTotalItems: UILabel!
    var mJewelryData = NSDictionary()
    var mDiamondData = NSDictionary()
    var mEngravingData = NSMutableDictionary()
        
    var mJewelPrice = ""
    @IBOutlet weak var mImageViewer: UIImageView!
    
    
    @IBOutlet weak var mJewelryImage: UIImageView!
    @IBOutlet weak var mDiamondImage: UIImageView!
    @IBOutlet weak var mJewelryImage2: UIImageView!
    @IBOutlet weak var mJewelryName: UILabel!
    @IBOutlet weak var mJewelrySize: UITextField!

    
    
    
    @IBOutlet weak var mFontSample: UITextView!
    @IBOutlet weak var mPointerSize: UITextField!
    @IBOutlet weak var mJewelryPrice: UILabel!
    @IBOutlet weak var mDiamondImage2: UIImageView!
    @IBOutlet weak var mDiamondName: UILabel!
    @IBOutlet weak var mCarat: UILabel!
    @IBOutlet weak var mDiamondPrice: UILabel!
    
    @IBOutlet weak var mOnTextClick: UIButton!
    @IBOutlet weak var mTextSlider: UIView!
    @IBOutlet weak var mOnClickLogo: UIButton!
    @IBOutlet weak var mLogoSlider: UIView!
    
    @IBOutlet weak var mEngraveTextView: UIStackView!
    @IBOutlet weak var mEngraveLogoView: UIView!
    @IBOutlet weak var mEngraveText: UILabel!
    @IBOutlet weak var mEngravePosition: UILabel!
    @IBOutlet weak var mFontName: UILabel!
    @IBOutlet weak var mLogoPosition: UILabel!
    @IBOutlet weak var mLogoImage: UIImageView!
    
    
    var mMetalId = ""
    var mStoneId = ""
    var mSizeId = ""
    var mShapeId = ""
    var mPointerId = ""
    var mPointerPrice = ""
    var mMetalNames = ""
    var mSizeNames = ""
    var mProductId = ""
    var mDiamondId = ""
    var mProductType = ""
    var mCustomerId = ""

    private var selectedSalesPersonId: String {
        let primary = UserDefaults.standard.string(forKey: "SALESPERSONID") ?? ""
        if !primary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return primary
        }
        return UserDefaults.standard.string(forKey: "sales_person_id") ?? ""
    }

    /// Database revisions have used both camelCase and snake_case keys for a
    /// MixMatch variant. Read either format so the cart payload always reflects
    /// the option that the user selected.
    private func hydrateVariantFields(from data: NSDictionary) {
        func value(_ keys: [String]) -> String {
            for key in keys {
                let text = "\(data.value(forKey: key) ?? "")"
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                if !text.isEmpty && text != "<null>" && text != "--" {
                    return text
                }
            }
            return ""
        }

        if mProductId.isEmpty { mProductId = value(["product_id", "productId"]) }
        if mMetalId.isEmpty { mMetalId = value(["metalId", "metal_id", "metal"]) }
        if mStoneId.isEmpty { mStoneId = value(["stoneId", "stone_id", "stone"]) }
        if mSizeId.isEmpty { mSizeId = value(["sizeId", "size_id", "size"]) }
        if mPointerId.isEmpty { mPointerId = value(["pointerId", "pointer_id", "pointer"]) }
        if mMetalNames.isEmpty { mMetalNames = value(["metalName", "metal_name"]) }
        if mSizeNames.isEmpty { mSizeNames = value(["sizeName", "size_name"]) }
        if mProductType.isEmpty { mProductType = value(["type", "product_type", "productType"]) }
        if mJewelPrice.isEmpty || mJewelPrice == "0.00" || mJewelPrice == "0" {
            var raw = value(["pointerPriceId", "retailprice_Inc", "price", "formatted_price"])
            // Strip any currency symbols so we always store a raw number
            let currencySymbol = UserDefaults.standard.string(forKey: "currencySymbol") ?? "$"
            raw = raw
                .replacingOccurrences(of: currencySymbol, with: "")
                .replacingOccurrences(of: "฿", with: "")
                .replacingOccurrences(of: "$", with: "")
                .replacingOccurrences(of: ",", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            mJewelPrice = raw
        }
    }

    private func hydrateVariantFieldsFromAvailableSources() {
        hydrateVariantFields(from: mJewelryData)
        if let catalogData = UserDefaults.standard.object(forKey: "CATALOGDATA") as? NSDictionary {
            hydrateVariantFields(from: catalogData)
        }
    }

    @IBOutlet weak var mDView: UIView!
    @IBOutlet weak var mJView: UIView!
    
    var mEditStatus = ""
    
    
    @IBOutlet weak var mCompleteLABEL: UILabel!
    @IBOutlet weak var mEngravingLABEL: UILabel!
    @IBOutlet weak var mSettingsLABEL: UILabel!
    @IBOutlet weak var mDiamondLABEL: UILabel!
    @IBOutlet weak var mHeading: UILabel!
    
    
    @IBOutlet weak var mLPositionLABEL: UILabel!
    @IBOutlet weak var mEFontLABEL: UILabel!
    @IBOutlet weak var mEPositionLABEL: UILabel!
    @IBOutlet weak var mETextLABEL: UILabel!
    @IBOutlet weak var mChangeEngravingLABEL: UILabel!
    @IBOutlet weak var mHEngravingLABEL: UILabel!
    @IBOutlet weak var mChangeDiamondLABEL: UILabel!
    @IBOutlet weak var mCaratLABEL: UILabel!
    @IBOutlet weak var mChangeSettingLABEL: UILabel!
    @IBOutlet weak var mJPointerLABEL: UILabel!
    @IBOutlet weak var mJSizeLABEL: UILabel!
    
    var mAllImages = [String]()

    override func viewWillAppear(_ animated: Bool) {
        mHeading.text = "Complete".localizedString
        mCompleteLABEL.text = "Complete".localizedString
        mEngravingLABEL.text = "Engraving".localizedString
        mDiamondLABEL.text = "Diamond".localizedString
        mSettingsLABEL.text = "Settings".localizedString
        
        mAddToCartButton.setTitle("ADD TO CART".localizedString, for: .normal)
        mLPositionLABEL.text = "Position".localizedString
        mEFontLABEL.text = "Font".localizedString
        mEPositionLABEL.text = "Position".localizedString
        mETextLABEL.text = "Text".localizedString
        mChangeEngravingLABEL.text = "Change Engraving".localizedString
        mHEngravingLABEL.text = "Engraving".localizedString
        mChangeDiamondLABEL.text = "Change Diamond".localizedString
        mCaratLABEL.text = "Carat".localizedString
        mChangeSettingLABEL.text = "Change Setting".localizedString
        mJPointerLABEL.text = "Pointer".localizedString
        mJSizeLABEL.text = "Size".localizedString
        mOnTextClick.setTitle("Text".localizedString, for: .normal)
        mOnClickLogo.setTitle("Logo".localizedString, for: .normal)
    }
    
    
    var isMixMatch = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
        
        
        if mCustomerId != "" {
            
            self.mCustomerId = UserDefaults.standard.string(forKey: "DEFAULTCUSTOMER") ?? ""
        }else{
            
        }
        
        self.mCustomerId = UserDefaults.standard.string(forKey: "DEFAULTCUSTOMER") ?? ""
        
        if mCustomerId == "" {
            
        }
        
        mEngraveTextView.isHidden = false
        mOnTextClick.setTitleColor(UIColor(named: "theme6A"), for: .normal)
        mTextSlider.backgroundColor = UIColor(named: "themeColor")
        mEngraveLogoView.isHidden = true
        mLogoSlider.backgroundColor = UIColor(named: "themeExtraLightText")
        mOnClickLogo.setTitleColor(UIColor(named: "themeExtraLightText"), for: .normal)
        mJView.borderWidth = 1
        mDView.borderWidth = 0
        if mEditStatus != "" {
            self.mAddToCartButton.setTitle("UPDATE ITEMS", for: .normal)
            mGetDiamondDetails()
            return
        }
        
        if  let image = self.mDiamondData.value(forKey: "image") as? [String] {
            self.mAllImages = image
            self.mDiamondImage.downlaodImageFromUrl(urlString: image[0])
            self.mDiamondImage2.downlaodImageFromUrl(urlString: image[0])
        }
        self.mDiamondId = "\(self.mDiamondData.value(forKey: "id") ?? "--")"

        self.mDiamondName.text = "\(mDiamondData.value(forKey: "Carat") ?? "") Carat, \(mDiamondData.value(forKey: "Shape") ?? "") - \(mDiamondData.value(forKey: "Colour") ?? "")/\(mDiamondData.value(forKey: "Clarity") ?? "--")"
        self.mDiamondPrice.text = "\(mDiamondData.value(forKey: "TagPrice") ?? "--")"
        
        self.mCarat.text = "\(mDiamondData.value(forKey: "Carat") ?? "--")"
        
        self.mJewelryImage.downlaodImageFromUrl(urlString: "\(mJewelryData.value(forKey: "main_image") ?? "")")
        self.mImageViewer.downlaodImageFromUrl(urlString: "\(mJewelryData.value(forKey: "main_image") ?? "")")
        self.mJewelryImage2.downlaodImageFromUrl(urlString: "\(mJewelryData.value(forKey: "main_image") ?? "")")
        self.mJewelryName.text = "\(mJewelryData.value(forKey: "Matatag") ?? "--")"
        self.mJewelryPrice.text = "\(mJewelryData.value(forKey: "price") ?? "0.00")"
        mJewelPrice = "\(mJewelryData.value(forKey: "price") ?? "0.00")"
        
        
        self.mJewelrySize.text = "\(mJewelryData.value(forKey: "size_name") ?? "--")"
        self.mPointerSize.text = "\(mJewelryData.value(forKey: "pointer") ?? "--")"
        self.mProductId =  "\(mJewelryData.value(forKey: "product_id") ?? "")"
        
        hydrateVariantFieldsFromAvailableSources()
        
        mEngraveText.text = mEngravingData.value(forKey: "engravingText") as? String
        mFontName.text = mEngravingData.value(forKey: "engravingFont") as? String
        mEngravePosition.text = mEngravingData.value(forKey: "engravingPosition") as? String
        mLogoPosition.text = mEngravingData.value(forKey: "logoPosition") as? String
        if let logoImage = mEngravingData.value(forKey: "logoImage") as? String {
            mLogoImage.downlaodImageFromUrl(urlString: logoImage)
        }
        if self.mEngraveText.text?.isEmptyOrSpaces() == true {
            self.mFontSample.text = "No Font!"
            self.mFontSample.font = UIFont(name: "SegoeUI", size: 18.0)
        }else{
            self.mFontSample.text =  self.mEngraveText.text
            self.mFontSample.font = UIFont(name: self.mEngraveText.text ?? "SegoeUI", size: 18.0)
        }
        // Do any additional setup after loading the view.
        mSetPrice()
    }
    
    func mSetPrice(){
        let mDPrice = Double("\(self.mDiamondPrice.text ?? "0.00")") ?? 0.00
        let mJPrice = Double(self.mJewelPrice) ?? 0.00
        let mCurrency = UserDefaults.standard.string(forKey: "currencySymbol") ?? "$"
        self.mDiamondPrice.text = mCurrency + " \(mDPrice)"
        self.mJewelryPrice.text = mCurrency + " \(mJPrice)"
        self.mTotalAmount.text = mCurrency + " \(mDPrice + mJPrice)"
    }
    
    func mGetDiamondDetails(){
        let param = ["cartId":mEditStatus]
        
       
        mGetData(url: mGetMixMatchDetails,headers: sGisHeaders,  params: param) { response , status in
            if status {
                 
                if let mData = response.value(forKey: "data") as? NSDictionary {
               
                    if let mDiamondData = mData.value(forKey: "Diamond") as? NSDictionary {
                        self.mDiamondData = mDiamondData

                        self.mShapeId = "\(mDiamondData.value(forKey: "shapeId") ?? "")"
                        if  let mImages =  mDiamondData.value(forKey: "image") as? [String] {
                            if mImages.count > 0 {
                                self.mAllImages = mImages
                                self.mDiamondImage.downlaodImageFromUrl(urlString: mImages[0])
                                self.mDiamondImage2.downlaodImageFromUrl(urlString: mImages[0])
                                
                            }
                        }
                        self.mDiamondId = "\(mDiamondData.value(forKey: "id") ?? "--")"
                        self.mDiamondName.text = "\(mDiamondData.value(forKey: "Carat") ?? "") Carat, \(mDiamondData.value(forKey: "Shape") ?? "") - \(mDiamondData.value(forKey: "Colour") ?? "")/\(mDiamondData.value(forKey: "Clarity") ?? "--")"
                        self.mDiamondPrice.text = "\(mDiamondData.value(forKey: "TagPrice") ?? "--")"

                        self.mCarat.text = "\(mDiamondData.value(forKey: "Carat") ?? "--")"
                         
                        
                    }
                    if let mProductData = mData.value(forKey: "Product") as? NSDictionary {
                     
                        self.mCustomerId = "\(mProductData.value(forKey: "customer_id") ?? "")"
                        self.mJewelryImage.downlaodImageFromUrl(urlString: "\(mProductData.value(forKey: "main_image") ?? "")")
                        self.mImageViewer.downlaodImageFromUrl(urlString: "\(mProductData.value(forKey: "main_image") ?? "")")
                        self.mJewelryImage2.downlaodImageFromUrl(urlString: "\(mProductData.value(forKey: "main_image") ?? "")")
                        self.mJewelryName.text = "\(mProductData.value(forKey: "name") ?? "--")"
                         self.mJewelryPrice.text = "\(mProductData.value(forKey: "formatted_price") ?? "0.00")"
                        self.mJewelPrice = "\(mProductData.value(forKey: "retailprice_Inc") ?? "0.00")"
                        self.mJewelrySize.text = "\(mProductData.value(forKey: "size_name") ?? "--")"
                        self.mPointerSize.text = "\(mProductData.value(forKey: "pointer") ?? "--")"
                        self.mProductId =  "\(mProductData.value(forKey: "product_id") ?? "")"
                        self.mMetalNames = "\(mProductData.value(forKey: "metal_name") ?? "")"
                        self.mSizeNames = "\(mProductData.value(forKey: "size_name") ?? "")"
                        self.mJewelrySize.text = "\(mProductData.value(forKey: "size_name") ?? "--")"
                        self.mPointerSize.text = "\(mProductData.value(forKey: "pointer") ?? "--")"
                        self.mMetalId = "\(mProductData.value(forKey: "metal") ?? "")"
                        self.mSizeId = "\(mProductData.value(forKey: "size") ?? "")"
                        self.mStoneId = "\(mProductData.value(forKey: "stoneId") ?? "")"
                        self.mPointerId = "\(mProductData.value(forKey: "pointer") ?? "")"
                        self.mProductType = "\(mProductData.value(forKey: "product_type") ?? "")"
                        self.mJewelPrice = "\(mProductData.value(forKey: "retailprice_Inc") ?? "0.00")"
                        
                    }
       
                    if let mDesignData = mData.value(forKey: "custom_design") as? NSDictionary{
                        self.mEngraveText.text = mDesignData.value(forKey: "engraving_text") as? String
                        self.mFontName.text = mDesignData.value(forKey: "font") as? String
                        self.mEngravePosition.text = mDesignData.value(forKey: "engraving_position") as? String
                        self.mLogoPosition.text = mDesignData.value(forKey: "logo_position") as? String
                        self.mLogoImage.downlaodImageFromUrl(urlString:  mDesignData.value(forKey: "engraving_logo") as? String ?? "")
                        if self.mEngraveText.text?.isEmptyOrSpaces() == true {
                            self.mFontSample.text = "No Font!"
                            self.mFontSample.font = UIFont(name: "SegoeUI", size: 18.0)
                        }else{
                            self.mFontSample.text =  self.mEngraveText.text
                            self.mFontSample.font = UIFont(name: self.mEngraveText.text ?? "SegoeUI", size: 18.0)
                        }
                        
                        self.mEngravingData = NSMutableDictionary()
                        self.mEngravingData.setValue(self.mEngraveText.text, forKey: "engravingText")
                        self.mEngravingData.setValue(self.mEngravePosition.text, forKey: "engravingPosition")
                        self.mEngravingData.setValue(self.mFontName.text, forKey: "engravingFont")
                        self.mEngravingData.setValue(mDesignData.value(forKey: "engraving_logo") as? String ?? "", forKey: "logoImage")
                        self.mEngravingData.setValue(self.mLogoPosition.text, forKey: "logoPosition")
                                
                    }
                    
                  
                    self.mSetPrice()
                    
                }
            
                
                
            }
        }
    }

    @IBAction func mBack(_ sender: Any) {
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "reserveBoard", bundle: nil)
        if let home = storyBoard.instantiateViewController(withIdentifier: "HomePage1") as? HomePage {
            self.navigationController?.pushViewController(home, animated:true)
        }
    }
    
    
    @IBAction func mAddToCart(_ sender: Any) {

        // Re-read the selected variant immediately before constructing the
        // request, so this payload cannot be built from stale blank fields.
        hydrateVariantFieldsFromAvailableSources()

        print("========== ADD TO CART VARIANT CHECK ==========")
        print("JEWELRY SKU =", mJewelryData.value(forKey: "SKU") ?? "")
        print("JEWELRY _id =", mJewelryData.value(forKey: "_id") ?? "")
        print("JEWELRY product_id =", mJewelryData.value(forKey: "product_id") ?? "")
        print("mProductId SENT =", mProductId)
        print("METAL ID =", mMetalId)
        print("STONE ID =", mStoneId)
        print("SIZE ID =", mSizeId)
        print("PRODUCT TYPE =", mProductType)
        print("================================================")

        // Strip currency symbol from price so the server receives a raw number
        let rawPrice: String = {
            let cleaned = mJewelPrice
                .replacingOccurrences(of: UserDefaults.standard.string(forKey: "currencySymbol") ?? "$", with: "")
                .replacingOccurrences(of: "฿", with: "")
                .replacingOccurrences(of: "$", with: "")
                .replacingOccurrences(of: ",", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            return cleaned.isEmpty ? "0" : cleaned
        }()

        let mItems: [String: Any] = [
            "metal": mMetalId,
            "stone": mStoneId,
            "size": mSizeId,
            "pointer": mPointerId,
            "price": rawPrice,
            "metal_name": mMetalNames,
            "size_name": mSizeNames
        ]

        let mCustomDesign = [
            "engraving_text": mEngraveText.text ?? "",
            "engraving_position": mEngravePosition.text ?? "",
            "engraving_logo": mEngravingData.value(forKey: "logoImage") ?? "",
            "font": mFontName.text ?? "",
            "logo_position": mLogoPosition.text ?? ""
        ]

        let mParams: [String: Any] = [
            "items": mItems,
            "product_id": mProductId,
            "diamond_id": mDiamondId,
            "remark": "",
            "custom_design": mCustomDesign,
            "order_type": "mix_and_match",
            "sales_person_id": selectedSalesPersonId,
            "customer_id": mCustomerId,
            "product_type": mProductType,
            "cartId": self.mEditStatus
        ]

        print("🔥 ADD CART PARAMS =", mParams)
        
        print("🔥 FINAL ADD CART VALUES")
        print("product_id =", mProductId)
        print("metal =", mMetalId)
        print("stone =", mStoneId)
        print("size =", mSizeId)
        print("pointer =", mPointerId)
        print("product_type =", mProductType)
        print("price (raw) =", rawPrice)
        
        mGetData(
            url: mAddToCartMixAndMatch,
            headers: sGisHeaders,
            params: mParams
        ) { response, status in

            print("========== ADD CART RESPONSE ==========")
            print("STATUS =", status)
            print("RESPONSE =", response)
            print("=======================================")

            guard status else {
                DispatchQueue.main.async {
                    CommonClass.showSnackBar(
                        message: "Network error. Please try again."
                    )
                }
                return
            }

            let code = response.value(forKey: "code") as? Int ?? 0

            guard code == 200 else {
                DispatchQueue.main.async {
                    if let error = response.value(forKey: "error") as? String,
                       error == "Authorization has been expired" {
                        CommonClass.sessionExpired(
                            isExpired: true,
                            navigation: self.navigationController
                        )
                        return
                    }

                    let message = (response.value(forKey: "message") as? String)
                        ?? (response.value(forKey: "error") as? String)
                        ?? "Failed to add item to cart (code \(code))."
                    CommonClass.showSnackBar(message: message)
                }
                return
            }

            DispatchQueue.main.async {
                CommonClass.showSnackBar(
                    message: "Item added successfully to cart!"
                )

                let storyBoard = UIStoryboard(
                    name: "mixNMatch",
                    bundle: nil
                )

                if let cart = storyBoard.instantiateViewController(
                    withIdentifier: "MixMatchCart"
                ) as? MixMatchCart {

                    cart.mKey = "1"
                    self.navigationController?
                        .pushViewController(cart, animated: true)
                }
            }
        }
    }
    
    func mGetEngraving(data: NSDictionary) {
        
        self.mEngravingData = NSMutableDictionary()
        self.mEngravingData.setValue(data.value(forKey: "engravingText"), forKey: "engravingText")
        self.mEngravingData.setValue(data.value(forKey: "engravingPosition"), forKey: "engravingPosition")
        self.mEngravingData.setValue(data.value(forKey: "engravingFont"), forKey: "engravingFont")
        self.mEngravingData.setValue(data.value(forKey: "logoImage"), forKey: "logoImage")
        self.mEngravingData.setValue(data.value(forKey: "logoPosition"), forKey: "logoPosition")
        
        mEngraveText.text = data.value(forKey: "engravingText") as? String
        mFontName.text = data.value(forKey: "engravingFont") as? String
        mEngravePosition.text = data.value(forKey: "engravingPosition") as? String
        mLogoPosition.text = data.value(forKey: "logoPosition") as? String
        mLogoImage.downlaodImageFromUrl(urlString:  data.value(forKey: "logoImage") as? String ?? "")
        if self.mEngraveText.text?.isEmptyOrSpaces() == true {
           self.mFontSample.text = "No Font!"
           self.mFontSample.font = UIFont(name: "SegoeUI", size: 18.0)
        } else {
           self.mFontSample.text = self.mEngraveText.text ?? ""
           self.mFontSample.font = UIFont(name: self.mEngraveText.text ?? "SegoeUI", size: 18.0)
        }
    }
    
    
    @IBAction func mOpenImageViewer(_ sender: Any) {
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Test", bundle: nil)
        if let mGlobalImageViewer = storyBoard.instantiateViewController(withIdentifier: "GlobalImageViewer") as? GlobalImageViewer {
            mGlobalImageViewer.modalPresentationStyle = .overFullScreen
            
            if isMixMatch {
                if mAllImages.isEmpty {
                    return
                }
                mGlobalImageViewer.mSKUName = self.mDiamondName.text ??  "--"
                mGlobalImageViewer.mAllImages = self.mAllImages
                mGlobalImageViewer.isMixMatch = isMixMatch
            }else{
                mGlobalImageViewer.mProductId = mProductId
                mGlobalImageViewer.mSKUName = self.mJewelryName.text ??  "--"
                mGlobalImageViewer.isMixMatch = isMixMatch
            }
            
            mGlobalImageViewer.transitioningDelegate = self
            self.present(mGlobalImageViewer,animated: false)
        }
    }
    
    
    @IBAction func mClickJewelry(_ sender: Any) {

        isMixMatch = false
        mImageViewer.image = mJewelryImage.image
        mJView.borderWidth = 1
        mDView.borderWidth = 0
    }
    

    @IBAction func mClickDiaond(_ sender: Any) {
        isMixMatch = true

        mImageViewer.image = mDiamondImage.image
        mJView.borderWidth = 0
        mDView.borderWidth = 1
    }
    
    
    @IBAction func mChangejewelrySettings(_ sender: Any) {
        mOpenCatalog()
    }
    @IBAction func mChangeDiamond(_ sender: Any) {
   
        mOpenDiamond()
    }
    
    @IBAction func mChangeEngraving(_ sender: Any) {
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "mixNMatch", bundle: nil)
        if let mInv = storyBoard.instantiateViewController(withIdentifier: "MixAndMatchEngravingUpdate") as? MixAndMatchEngravingUpdate {
            mInv.modalPresentationStyle = .overFullScreen
            mInv.delegate =  self
            mInv.mEngraveData = mEngravingData
            mInv.transitioningDelegate = self
            self.present(mInv,animated: false)
        }
    }
    
   
    
    
    @IBAction func mEngravingText(_ sender: Any) {
        mEngraveTextView.isHidden = false
        mOnTextClick.setTitleColor(UIColor(named: "theme6A"), for: .normal)
        mTextSlider.backgroundColor = UIColor(named: "themeColor")

        mEngraveLogoView.isHidden = true
        mLogoSlider.backgroundColor = UIColor(named: "themeExtraLightText")
        mOnClickLogo.setTitleColor(UIColor(named: "themeExtraLightText"), for: .normal)
        
    }
    
    
    @IBAction func mEngravingLogo(_ sender: Any) {
        
        mEngraveTextView.isHidden = true
        mOnTextClick.setTitleColor(UIColor(named: "themeExtraLightText"), for: .normal)
        mTextSlider.backgroundColor = UIColor(named: "themeExtraLightText")
        
        mEngraveLogoView.isHidden = false
        mLogoSlider.backgroundColor = UIColor(named: "themeColor")
        mOnClickLogo.setTitleColor(UIColor(named: "theme6A"), for: .normal)
        
    }
    
    
    @IBAction func mOnClickLogoImage(_ sender: Any) {
        
    }
    
    
    
    func mGetCatalogItemDetails(data: NSDictionary) {
 

        self.mJewelryData = data
        self.mJewelryImage.downlaodImageFromUrl(urlString: "\(mJewelryData.value(forKey: "main_image") ?? "")")
        self.mImageViewer.downlaodImageFromUrl(urlString: "\(mJewelryData.value(forKey: "main_image") ?? "")")
        self.mJewelryImage2.downlaodImageFromUrl(urlString: "\(mJewelryData.value(forKey: "main_image") ?? "")")
        self.mJewelryName.text = "\(mJewelryData.value(forKey: "Matatag") ?? "--")"
         self.mJewelryPrice.text = "\(mJewelryData.value(forKey: "price") ?? "0.00")"
        self.mJewelPrice = "\(mJewelryData.value(forKey: "price") ?? "0.00")"


        self.mJewelrySize.text = "\(mJewelryData.value(forKey: "size_name") ?? "--")"
        self.mPointerSize.text = "\(mJewelryData.value(forKey: "pointer") ?? "--")"
        self.mProductId =  "\(mJewelryData.value(forKey: "product_id") ?? "")"
        
        hydrateVariantFieldsFromAvailableSources()
        self.mDiamondPrice.text = "\(mDiamondData.value(forKey: "TagPrice") ?? "--")"
        mSetPrice()
       
    }
    
    
    func mGetCatalogItem(data: NSDictionary, type: String) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "common", bundle: nil)
        if let mMixAndMatchCatalogDetails = storyBoard.instantiateViewController(withIdentifier: "MixAndMatchCatalogDetails") as? MixAndMatchCatalogDetails {
            mMixAndMatchCatalogDetails.mData = data
            mMixAndMatchCatalogDetails.mType = type
            mMixAndMatchCatalogDetails.delegate = self
            mMixAndMatchCatalogDetails.modalPresentationStyle = .overFullScreen
            mMixAndMatchCatalogDetails.transitioningDelegate = self
            self.present(mMixAndMatchCatalogDetails,animated: false)
        }
    }
    func mOpenCatalog() {
       
        let storyBoard: UIStoryboard = UIStoryboard(name: "common", bundle: nil)
        if let mMixAndMatchCatalog = storyBoard.instantiateViewController(withIdentifier: "MixAndMatchCatalog") as? MixAndMatchCatalog {
            mMixAndMatchCatalog.delegate = self
        
            mMixAndMatchCatalog.mItemTypeId = ""
            mMixAndMatchCatalog.modalPresentationStyle = .overFullScreen
            mMixAndMatchCatalog.transitioningDelegate = self
            self.present(mMixAndMatchCatalog,animated: false)
        }
    }
    
    
    func mGetPickedDiamond (data: NSDictionary, type : String) {
        let mData = data
        self.mDiamondData = mData

        
    
      self.mDiamondName.text = "\(self.mDiamondData.value(forKey: "Carat") ?? "") Carat, \(self.mDiamondData.value(forKey: "Shape") ?? "") - \(mDiamondData.value(forKey: "Colour") ?? "")/\(mDiamondData.value(forKey: "Clarity") ?? "--")"
        
        if  let mImages = self.mDiamondData.value(forKey: "image") as? [String] {
            if mImages.count > 0 {
                self.mAllImages = mImages
                self.mDiamondImage.downlaodImageFromUrl(urlString: mImages[0])
                self.mDiamondImage2.downlaodImageFromUrl(urlString: mImages[0])
                
            }
        }
        
        self.mDiamondId = "\(self.mDiamondData.value(forKey: "id") ?? "--")"

        self.mDiamondPrice.text = "\(self.mDiamondData.value(forKey: "TagPrice") ?? "--")"
        self.mCarat.text = "\(self.mDiamondData.value(forKey: "Carat") ?? "--")"
 
        
        mSetPrice()
    }
    func mGetSelectedDiamond(items: String) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "mixNMatch", bundle: nil)
        if let mDiamondProductDetails = storyBoard.instantiateViewController(withIdentifier: "MixAndMatchDiamondDetails") as? MixAndMatchDiamondDetails {
            mDiamondProductDetails.modalPresentationStyle = .overFullScreen
            mDiamondProductDetails.delegate =  self
            mDiamondProductDetails.isFirst = ""
            mDiamondProductDetails.mProductId = items
            mDiamondProductDetails.transitioningDelegate = self
            self.present(mDiamondProductDetails,animated: false)
        }
    }
    func mOpenDiamond(){
        let storyBoard: UIStoryboard = UIStoryboard(name: "common", bundle: nil)
        if let mInv = storyBoard.instantiateViewController(withIdentifier: "MixAndMatchDiamond") as? MixAndMatchDiamond {
            mInv.modalPresentationStyle = .overFullScreen
            mInv.delegate =  self
            mInv.transitioningDelegate = self
            self.present(mInv,animated: false)
        }
    }

}
