//
//  MixAndMatchDesign.swift
//  GIS
//
//  Created by MacBook Hawkscode  on 9/02/23.
//  Copyright © 2023 Hawkscode. All rights reserved.
//

import UIKit
import PencilKit
import  DropDown
import Alamofire
import RSSelectionMenu


 class MixAndMatchDesign: UIViewController,UIImagePickerControllerDelegate ,UINavigationControllerDelegate,GetCatalogData, GetCatalogDetailsDelegate ,UIViewControllerTransitioningDelegate,GetCustomerDataDelegate,GetDiamondData, GetSelectedDiamondDelegate {
  /**Jewelry**/
     
     
     var mLogoImageUrl = ""
     var mCustomerId = ""
     var mItemTypeId = ""
     @IBOutlet weak var mJImage: UIImageView!
     @IBOutlet weak var mJStockId: UILabel!
     @IBOutlet weak var mJSKU: UILabel!
     @IBOutlet weak var mJName: UILabel!
     @IBOutlet weak var mJMetalName: UILabel!
     @IBOutlet weak var mJStoneName: UILabel!
     @IBOutlet weak var mJSize: UILabel!
     @IBOutlet weak var mJCollection: UILabel!
     /**Diamond**/
     
     @IBOutlet weak var mDiamondIcon1: UIImageView!
     @IBOutlet weak var mDiamonLabel1: UILabel!
     @IBOutlet weak var mDiamondLine1: UILabel!
     
     
     @IBOutlet weak var mSettingIcon1: UIImageView!
     @IBOutlet weak var mSettingLabel1: UILabel!
     @IBOutlet weak var mSettingLine1: UILabel!
     
     

      
    
     
     @IBOutlet weak var mDiamondIcon2: UIImageView!
     @IBOutlet weak var mDiamonLabel2: UILabel!
     @IBOutlet weak var mDiamondLine2: UILabel!
     
     
     @IBOutlet weak var mSettingIcon2: UIImageView!
     @IBOutlet weak var mSettingLabel2: UILabel!
     @IBOutlet weak var mSettingLine2: UILabel!
     
     @IBOutlet weak var mNextView: UIView!
     
     @IBOutlet weak var mTextLogoEngravingView: UIStackView!
     @IBOutlet weak var mPickerView: UIView!
     @IBOutlet weak var mDiamondPick: UIView!
     @IBOutlet weak var mJewelryPick: UIView!
    

     
     
     
     
     @IBOutlet weak var mDImage: UIImageView!
     @IBOutlet weak var mDStockId: UILabel!
     @IBOutlet weak var mDSKU: UILabel!
     @IBOutlet weak var mDName: UILabel!
     @IBOutlet weak var mDShape: UILabel!
     @IBOutlet weak var mDColor: UILabel!
     @IBOutlet weak var mDCut: UILabel!
     @IBOutlet weak var mDCarat: UILabel!
     @IBOutlet weak var mDClarity: UILabel!
     @IBOutlet weak var mDCertificate: UILabel!
     
     
     
     
     @IBOutlet weak var mEngraveTextView: UIStackView!
     @IBOutlet weak var mEngraveText: UITextField!
     
     @IBOutlet weak var mPosition: UITextField!
     
     @IBOutlet weak var mFont: UITextField!
     
     
     
     @IBOutlet weak var mLogoPosition: UITextField!

     @IBOutlet weak var mLogoImage: UIImageView!
     @IBOutlet weak var mEngraveLogoView: UIStackView!
    
     @IBOutlet weak var mEngraveImage: UIImageView!
     @IBOutlet weak var mEngraveLabel: UILabel!
     
     @IBOutlet weak var mOnTextClick: UIButton!
     @IBOutlet weak var mTextSlider: UIView!
     @IBOutlet weak var mOnClickLogo: UIButton!
     @IBOutlet weak var mLogoSlider: UIView!
 
     
     var imagePicker = UIImagePickerController()
     var logoPicker = UIImagePickerController()
     var mKey = ""
 
     
     var mJewelryData = NSDictionary()
     var mDiamondData = NSDictionary()
     var mJewelryProductId = ""
     var mCatalogProductId = ""
     var mDiamondProductId = ""
     
     
     @IBOutlet weak var mFontSample: UITextView!
     var mFontsArray = [String]()
     var mFontId = ""

     var mProductId = ""
     var mVariantId = ""
     
     @IBOutlet weak var mDiamondDetailsView: UIStackView!
     @IBOutlet weak var mJewelryDetailsView: UIStackView!
     @IBOutlet weak var mDiamondFirstView: UIStackView!
     @IBOutlet weak var mJewelryFirstView: UIStackView!
   
     @IBOutlet weak var mHeading: UILabel!
     
     @IBOutlet weak var mShapeLABEL: UILabel!
     @IBOutlet weak var mDColorLABEL: UILabel!
     @IBOutlet weak var mDCutLABEL: UILabel!
     @IBOutlet weak var mCaratLABEL: UILabel!
     @IBOutlet weak var mClarityLABEL: UILabel!
     @IBOutlet weak var mCertificateLABEL: UILabel!
     @IBOutlet weak var mJMetalLABEL: UILabel!
     @IBOutlet weak var mJStoneLABEL: UILabel!
     @IBOutlet weak var mJSizeLABEL: UILabel!
     @IBOutlet weak var mJCollectionLABEL: UILabel!
     
     
     @IBOutlet weak var mEngravingLABEL1: UILabel!
     
     @IBOutlet weak var mEngravingLABEL2: UILabel!
     
     
     
     
     
     @IBOutlet weak var mPickDiamondLABEL: UILabel!
     @IBOutlet weak var mPickJewelryLABEL: UILabel!
     
     @IBOutlet weak var mETextLABEL: UILabel!
     @IBOutlet weak var mEPositionLABEL: UILabel!
     @IBOutlet weak var mLPosition: UILabel!
     @IBOutlet weak var mUploadLOGOLABEL: UILabel!
     @IBOutlet weak var mEFontLABEL: UILabel!
     
     
     override func viewWillAppear(_ animated: Bool) {
         mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")

         mShapeLABEL.text = "Shape".localizedString
         mDColorLABEL.text = "Color".localizedString
         mDCutLABEL.text = "Cut".localizedString
         mCaratLABEL.text = "Carat".localizedString
         mClarityLABEL.text = "Clarity".localizedString
         mCertificateLABEL.text = "Certificate".localizedString
         mJMetalLABEL.text = "Metal".localizedString
         mJStoneLABEL.text = "Stone".localizedString
         mJSizeLABEL.text = "Size".localizedString
         mJCollectionLABEL.text = "Collection".localizedString
         
         
         mDiamonLabel1.text = "Diamond".localizedString
         mSettingLabel1.text = "Settings".localizedString
         mEngravingLABEL1.text = "Engraving".localizedString
         mDiamonLabel2.text = "Diamond".localizedString
         mSettingLabel2.text = "Settings".localizedString
         mEngravingLABEL2.text = "Engraving".localizedString
        
         
          mOnTextClick.setTitle("Text".localizedString, for: .normal)
          mOnClickLogo.setTitle("Logo".localizedString, for: .normal)
          mEngraveText.placeholder = "Write text you want to engrave".localizedString
          mEPositionLABEL.text = "Position".localizedString
          mPosition.placeholder = "Which position would you like to engrave?".localizedString
          mLogoPosition.placeholder = "Which position would you like to engrave?".localizedString
          mEFontLABEL.text = "Font".localizedString
          mFont.placeholder = "Choose Font".localizedString
          mLPosition.text = "Position".localizedString
          mUploadLOGOLABEL.text = "Upload Logo".localizedString
          
         mPickDiamondLABEL.text = "Pick Diamond".localizedString
         mPickJewelryLABEL.text = "Pick Jewelry".localizedString
          
         
         
         
         
     }
     override func viewDidLoad() {
         if !mJewelryProductId.isEmpty {
             mJewelryDetailsView.isHidden = false
             mJewelryFirstView.isHidden = false
             mDiamondFirstView.isHidden = true
             mDiamondDetailsView.isHidden = true
             
             
             self.mHeading.text = "Select Diamond".localizedString
             self.mJImage.downlaodImageFromUrl(urlString: "\(mJewelryData.value(forKey: "main_image") ?? "")")
             self.mJStockId.text = "\(mJewelryData.value(forKey: "stock_id") ?? "--")"
             self.mJSKU.text = "\(mJewelryData.value(forKey: "SKU") ?? "--")"
             self.mJName.text = "\(mJewelryData.value(forKey: "Matatag") ?? "--")"
             self.mJMetalName.text = "\(mJewelryData.value(forKey: "metal_name") ?? "--")"
             self.mJStoneName.text = "\(mJewelryData.value(forKey: "stone_name") ?? "--")"
             self.mJSize.text = "\(mJewelryData.value(forKey: "size_name") ?? "--")"
             self.mJCollection.text = "\(mJewelryData.value(forKey: "collection_name") ?? "--")"
            
             self.mPickerView.isHidden = false
             self.mJewelryPick.isHidden = true
             self.mDiamondPick.isHidden = false
             self.mTextLogoEngravingView.isHidden = true

             mOpenDiamond()
         }else{
             self.mPickerView.isHidden = false
             self.mJewelryPick.isHidden = false
             self.mDiamondPick.isHidden = true
             self.mTextLogoEngravingView.isHidden = true

             
             self.mHeading.text = "Select Setting".localizedString
             mJewelryDetailsView.isHidden = true
             mJewelryFirstView.isHidden = true
             mDiamondFirstView.isHidden = false
             mDiamondDetailsView.isHidden = false
             
             mOpenCatalog()
              if  let image = mDiamondData.value(forKey: "image") as? [String] {
                 self.mDImage.downlaodImageFromUrl(urlString: image[0])
             }
             self.mDSKU.text = "\(mDiamondData.value(forKey: "Carat") ?? "") Carat, \(mDiamondData.value(forKey: "Shape") ?? "") - \(mDiamondData.value(forKey: "Colour") ?? "")/\(mDiamondData.value(forKey: "Clarity") ?? "--")"
             self.mDStockId.text = "\(mDiamondData.value(forKey: "StockID") ?? "--")"
             self.mDName.text = "\(mDiamondData.value(forKey: "StockID") ?? "--")"
             self.mDShape.text = "\(mDiamondData.value(forKey: "Shape") ?? "--")"
             self.mDCarat.text = "\(mDiamondData.value(forKey: "Carat") ?? "--")"
             self.mDColor.text = "\(mDiamondData.value(forKey: "Colour") ?? "--")"
             self.mDClarity.text = "\(mDiamondData.value(forKey: "Clarity") ?? "--")"
             self.mDCut.text = "\(mDiamondData.value(forKey: "Cut") ?? "--")"
             self.mDCertificate.text = "\(mDiamondData.value(forKey: "GradedBy") ?? "--")"
         }
         mEngraveTextView.isHidden = false
         mOnTextClick.setTitleColor(UIColor(named: "theme6A"), for: .normal)
         mTextSlider.backgroundColor = UIColor(named: "themeColor")
         
         
         mEngraveLogoView.isHidden = true
         mLogoSlider.backgroundColor = UIColor(named: "themeExtraLightText")
         mOnClickLogo.setTitleColor(UIColor(named: "themeExtraLightText"), for: .normal)
         let mFontFamilyNames = UIFont.familyNames
         
         for family in mFontFamilyNames {
             let fontNames = UIFont.fontNames(forFamilyName: family)
             for font in fontNames {
                 mFontsArray.append(font)
                 
             }
         }
         
         print("MixAndMatchDesign viewDidLoad")
    }
     @IBAction func mBack(_ sender: Any) {
         self.navigationController?.popViewController(animated: false)
     }
     
     @IBAction func mNext(_ sender: Any) {
         
         
         let mEngraveData = NSMutableDictionary()
         mEngraveData.setValue(self.mEngraveText.text ?? "", forKey: "engravingText")
         mEngraveData.setValue(self.mPosition.text ?? "", forKey: "engravingPosition")
         mEngraveData.setValue(self.mFontId, forKey: "engravingFont")
         mEngraveData.setValue(self.mLogoImageUrl, forKey: "logoImage")
         mEngraveData.setValue(self.mLogoPosition.text, forKey: "logoPosition")
         
         let storyBoard: UIStoryboard = UIStoryboard(name: "mixNMatch", bundle: nil)
         if let mMixAndMatchComplete = storyBoard.instantiateViewController(withIdentifier: "MixAndMatchComplete") as? MixAndMatchComplete {

             mMixAndMatchComplete.mEngravingData = mEngraveData
             mMixAndMatchComplete.mJewelryData = mJewelryData
             mMixAndMatchComplete.mCustomerId = self.mCustomerId
             mMixAndMatchComplete.mDiamondData = mDiamondData
             self.navigationController?.pushViewController(mMixAndMatchComplete, animated: true)
         }
         
     }
     
     
     @IBAction func mChooseFont(_ sender: Any) {

             
              let mArray = [String]()
              let menu = RSSelectionMenu(selectionStyle: .single, dataSource: mFontsArray) { (cell, name, indexPath) in
              cell.textLabel?.text = name
              }
              menu.showSearchBar { [weak self] (searchText) -> ([String]) in
                  
                  return self?.mFontsArray.filter({ $0.lowercased().starts(with:      searchText.lowercased()) }) ?? []
              }
              menu.setSelectedItems(items: mArray) { (name, index, selected, selectedItems) in
                  self.mFont.text = name
                  self.mFontId = "\(name ?? "")"
                  if self.mEngraveText.text?.isEmptyOrSpaces() == true {
                      self.mFontSample.text = "Please choose fonts for text you want to engrave"
                      self.mFontSample.font = UIFont(name: name ?? "SegoeUI", size: 18.0)
                  }else{
                      self.mFontSample.text =  self.mEngraveText.text
                      self.mFontSample.font = UIFont(name: name ?? "SegoeUI", size: 18.0)
                  }
               }
          
              menu.show(from: self)
              
         
         
     }
     @IBAction func mEngraveTextButton(_ sender: Any) {
         mEngraveTextView.isHidden = false
         mOnTextClick.setTitleColor(UIColor(named: "theme6A"), for: .normal)
         mTextSlider.backgroundColor = UIColor(named: "themeColor")

         mEngraveLogoView.isHidden = true
         mLogoSlider.backgroundColor = UIColor(named: "themeExtraLightText")
         mOnClickLogo.setTitleColor(UIColor(named: "themeExtraLightText"), for: .normal)
         
     }
     
     
     @IBAction func mEngraveLogoButton(_ sender: Any) {
         
         mEngraveTextView.isHidden = true
         mOnTextClick.setTitleColor(UIColor(named: "themeExtraLightText"), for: .normal)
         mTextSlider.backgroundColor = UIColor(named: "themeExtraLightText")
         
         mEngraveLogoView.isHidden = false
         mLogoSlider.backgroundColor = UIColor(named: "themeColor")
         mOnClickLogo.setTitleColor(UIColor(named: "theme6A"), for: .normal)
         
     }
     
     @IBAction func mChooseLogoImage(_ sender: Any) {
         mKey = "1"
         if (UIDevice.current.userInterfaceIdiom == .pad) {
             let alert:UIAlertController=UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
                    let cameraAction = UIAlertAction(title: "Camera", style: UIAlertAction.Style.default) {
                        UIAlertAction in
                        self.openCamera(UIImagePickerController.SourceType.camera)
                    }
                    let gallaryAction = UIAlertAction(title: "Gallery", style: UIAlertAction.Style.default) {
                        UIAlertAction in
                        self.openCamera(UIImagePickerController.SourceType.photoLibrary)
                    }
                    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
                      
                        UIAlertAction in
                    }

                    // Add the actions
                logoPicker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
                    alert.addAction(cameraAction)
                    alert.addAction(gallaryAction)
                    alert.addAction(cancelAction)
                 addActionSheetForiPad(actionSheet: alert)
                    self.present(alert, animated: false, completion: nil)
         }else{
             let alert:UIAlertController=UIAlertController(title: "Choose Image", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
                     let cameraAction = UIAlertAction(title: "Camera", style: UIAlertAction.Style.default) {
                         UIAlertAction in
                         self.openCamera(UIImagePickerController.SourceType.camera)
                     }
                     let gallaryAction = UIAlertAction(title: "Gallery", style: UIAlertAction.Style.default) {
                         UIAlertAction in
                         self.openCamera(UIImagePickerController.SourceType.photoLibrary)
                     }
                     let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {

                         UIAlertAction in
                     }

                     // Add the actions
                     logoPicker.delegate = self
                     alert.addAction(cameraAction)
                     alert.addAction(gallaryAction)
                     alert.addAction(cancelAction)
                     self.present(alert, animated: false, completion: nil)
             }
         
     }
     
     
     func openCamera(_ sourceType: UIImagePickerController.SourceType) {
         if mKey == "" {
     imagePicker.sourceType = sourceType
      imagePicker.allowsEditing = false
     self.present(imagePicker, animated: true, completion: nil)
         }else{
             logoPicker.sourceType = sourceType
             logoPicker.allowsEditing = false
             self.present(logoPicker, animated: true, completion: nil)
         }
     }
      


     //MARK:UIImagePickerControllerDelegate

     func imagePickerController(_ picker: UIImagePickerController,
     didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
         
         if picker == imagePicker {

         }else{
             mLogoImage.backgroundColor = .white
             mLogoImage.image = (info[UIImagePickerController.InfoKey.originalImage] as? UIImage)
             
             
             let base64EncodedPath = (info[UIImagePickerController.InfoKey.originalImage] as? UIImage)?.toBase64()
             mGetImageUrl(base64: base64EncodedPath ?? "", type: "logo")
             
            logoPicker.dismiss(animated: true, completion: nil)
         }
        
     }

    
     func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
      picker.dismiss(animated: true, completion: nil)
      
     }
     
     
     func mGetImageUrl(base64 : String , type: String){
         let params:[String: Any] = ["image":base64,"name":type]

         CommonClass.showFullLoader(view: self.view)
         
         
         mGetData(url: mGenerateImageUrlAPI,headers: sGisHeaders, params: params) { response , status in
             CommonClass.stopLoader()
             if status {
                 if "\(response.value(forKey: "code") ?? "")" == "200" {
                     
                     if response.value(forKey: "data") == nil {
                         return
                     }
                     
                     if let mData = response.value(forKey: "data") as? NSDictionary {
                         if let image = mData.value(forKey: "images") as? NSDictionary {
                             if type == "logo" {
                                 self.mLogoImageUrl = image.value(forKey: "url") as? String ?? ""
                             }
                             CommonClass.showSnackBar(message: "Image uploaded successfully!")
                         }
                     }

                 }else{
                 }
             }
         }
     }
     
     func mGetCatalogItemDetails(data: NSDictionary) {

         print("========== DESIGN RECEIVED VARIANT ==========")
         print("SKU =", data.value(forKey: "SKU") ?? "")
         print("VARIANT _id =", data.value(forKey: "_id") ?? "")
         print("PRODUCT ID =", data.value(forKey: "product_id") ?? "")
         print("METAL =", data.value(forKey: "metal_name") ?? "")
         print("STONE =", data.value(forKey: "stone_name") ?? "")
         print("SIZE =", data.value(forKey: "size_name") ?? "")
         print("=============================================")

         mJewelryData = data

         mVariantId = "\(data.value(forKey: "_id") ?? "")"
         mProductId = "\(data.value(forKey: "product_id") ?? "")"

         print("SAVED VARIANT ID =", mVariantId)
         print("SAVED PRODUCT ID =", mProductId)

         self.mHeading.text = "Select Engraving".localizedString

         self.mJImage.downlaodImageFromUrl(
             urlString: "\(mJewelryData.value(forKey: "main_image") ?? "")"
         )

         self.mJStockId.text =
             "\(mJewelryData.value(forKey: "stock_id") ?? "--")"

         self.mJSKU.text =
             "\(mJewelryData.value(forKey: "SKU") ?? "--")"

         self.mJName.text =
             "\(mJewelryData.value(forKey: "Matatag") ?? "--")"

         self.mJMetalName.text =
             "\(mJewelryData.value(forKey: "metal_name") ?? "--")"

         self.mJStoneName.text =
             "\(mJewelryData.value(forKey: "stone_name") ?? "--")"

         self.mJSize.text =
             "\(mJewelryData.value(forKey: "size_name") ?? "--")"

         self.mJCollection.text =
             "\(mJewelryData.value(forKey: "collection_name") ?? "--")"

         mSettingLine1.backgroundColor = UIColor(named: "themeColor")
         mSettingLabel1.textColor = UIColor(named: "themeColor")
         mSettingIcon1.image = UIImage(named: "dgreensetting")

         mNextView.isHidden = false
         mPickerView.isHidden = true
         mTextLogoEngravingView.isHidden = false
         mDiamondDetailsView.isHidden = true
         mJewelryDetailsView.isHidden = false
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
         if mCustomerId == "" {
             CommonClass.showSnackBar(message: "Please choose customer first!")
             mOpenCustomerSheet()
             return
         }
         let storyBoard: UIStoryboard = UIStoryboard(name: "common", bundle: nil)
         if let mMixAndMatchCatalog = storyBoard.instantiateViewController(withIdentifier: "MixAndMatchCatalog") as? MixAndMatchCatalog {
             mMixAndMatchCatalog.delegate = self
             mMixAndMatchCatalog.mItemTypeId = mItemTypeId
             mMixAndMatchCatalog.modalPresentationStyle = .overFullScreen
             mMixAndMatchCatalog.transitioningDelegate = self
             self.present(mMixAndMatchCatalog,animated: false)
         }
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
         
         UserDefaults.standard.set(data.value(forKey: "profile") ?? "", forKey: "DEFAULTCUSTOMERPICTURE")
         UserDefaults.standard.set(data.value(forKey: "name") as? String ?? "", forKey: "DEFAULTCUSTOMERNAME")

     }
     
     func mGetPickedDiamond (data: NSDictionary, type : String) {
         let mData = data
         mDiamondData = mData
         self.mHeading.text = "Select Engraving".localizedString
         
         mDiamondDetailsView.isHidden = false
         mJewelryDetailsView.isHidden = true
         mDiamondLine2.backgroundColor = UIColor(named: "themeColor")
         mDiamonLabel2.textColor = UIColor(named: "themeColor")
         mDiamondIcon2.image = UIImage(named: "dgreendiamond")
         mNextView.isHidden = false
         self.mPickerView.isHidden = true
         self.mTextLogoEngravingView.isHidden = false
  
           if  let image = mDiamondData.value(forKey: "image") as? [String] {
             self.mDImage.downlaodImageFromUrl(urlString: image[0])
         }
         self.mDSKU.text = "\(mDiamondData.value(forKey: "Carat") ?? "") Carat, \(mDiamondData.value(forKey: "Shape") ?? "") - \(mDiamondData.value(forKey: "Colour") ?? "")/\(mDiamondData.value(forKey: "Clarity") ?? "--")"
         self.mDStockId.text = "\(mDiamondData.value(forKey: "StockID") ?? "--")"
         self.mDName.text = "\(mDiamondData.value(forKey: "StockID") ?? "--")"
         self.mDShape.text = "\(mDiamondData.value(forKey: "Shape") ?? "--")"
         self.mDCarat.text = "\(mDiamondData.value(forKey: "Carat") ?? "--")"
         self.mDColor.text = "\(mDiamondData.value(forKey: "Colour") ?? "--")"
         self.mDClarity.text = "\(mDiamondData.value(forKey: "Clarity") ?? "--")"
         self.mDCut.text = "\(mDiamondData.value(forKey: "Cut") ?? "--")"
         self.mDCertificate.text = "\(mDiamondData.value(forKey: "GradedBy") ?? "--")"
       
         
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
     
     
     
     @IBAction func mSelectJewelry(_ sender: Any) {
         mOpenCatalog()
     }
     
     
     @IBAction func mSelectDiamond(_ sender: Any) {
         mOpenDiamond()
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
     
     func mOpenCustomerSheet(){
         let storyBoard: UIStoryboard = UIStoryboard(name: "common", bundle: nil)
         if let home = storyBoard.instantiateViewController(withIdentifier: "CustomerPicker") as? CustomerPicker {
             home.delegate = self
             home.modalPresentationStyle = .automatic
             home.transitioningDelegate = self
             self.present(home,animated: false)
         }
     }
 }
