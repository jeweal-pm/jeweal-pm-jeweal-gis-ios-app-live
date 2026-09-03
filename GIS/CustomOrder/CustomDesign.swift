//
//  CustomDesign.swift
//  GIS
//
//  Created by Apple Hawkscode on 20/06/21.
//

import UIKit
import PencilKit
import  DropDown
import Alamofire
import RSSelectionMenu
import Alamofire
import IQKeyboardManagerSwift

class PictureCell:UICollectionViewCell {
    
    @IBOutlet weak var mImageView: UIImageView!
    @IBOutlet weak var mButton: UIButton!
    
    @IBOutlet weak var mView: UIView!
    
}

@available(iOS 14.0, *)
class CustomDesign: UIViewController,
                    UIImagePickerControllerDelegate,
                    UINavigationControllerDelegate,
                    UICollectionViewDelegate,
                    UICollectionViewDataSource,
                    UITextFieldDelegate,
                    UITextViewDelegate,
                    UIGestureRecognizerDelegate {
    @IBOutlet weak var mFontSample: UITextView!
    
    
    
    @IBOutlet weak var mBackImage: UIImageView!
    @IBOutlet weak var mForwardImage: UIImageView!
    @IBOutlet weak var mPicturesCollection: UICollectionView!
    @IBOutlet weak var mBottomView: UIView!
    @IBOutlet weak var mConceptLabel: UILabel!
    @IBOutlet weak var mConceptImage: UIImageView!
    @IBOutlet weak var mConceptSeparator: UILabel!
    
    @IBOutlet weak var mSketchImage: UIImageView!
    @IBOutlet weak var mSketchLabel: UILabel!
    @IBOutlet weak var mSketchSeparator: UILabel!
    
    @IBOutlet weak var mPictureImage: UIImageView!
    @IBOutlet weak var mPictureLabel: UILabel!
    @IBOutlet weak var mPictureSeparator: UILabel!
    
    
    @IBOutlet weak var mOnTextClick: UIButton!
    @IBOutlet weak var mTextSlider: UIView!
    @IBOutlet weak var mOnClickLogo: UIButton!
    @IBOutlet weak var mLogoSlider: UIView!
    
    @IBOutlet weak var mEngraveTextView: UIStackView!
    @IBOutlet weak var mEngraveText: UITextField!
    
    @IBOutlet weak var mPosition: UITextField!
    
    @IBOutlet weak var mFont: UITextField!
    
    
    
    @IBOutlet weak var mLogoPosition: UITextField!
    
    @IBOutlet weak var mLogoImage: UIImageView!
    @IBOutlet weak var mEngraveLogoView: UIStackView!
    
    @IBOutlet weak var mEngraveImage: UIImageView!
    @IBOutlet weak var mEngraveLabel: UILabel!
    
    
    @IBOutlet weak var mWriteConceptLABEL: UILabel!
    @IBOutlet weak var mETextLABEL: UILabel!
    @IBOutlet weak var mEPositionLABEL: UILabel!
    @IBOutlet weak var mEFontLABEL: UILabel!
    @IBOutlet weak var mUploadLogoLABEL: UILabel!
    @IBOutlet weak var mLPositionLABEL: UILabel!
    @IBOutlet weak var mSelectLogoBUTTON: UIButton!
    
    var mStatus = ""
    var mImageStatus = ""
    var mKey = ""
    var mEditId = ""
    var mProductId = ""
    var mCartId = ""
    var mQty = ""
    var mPage = 0
    @IBOutlet weak var mCanvasView: PKCanvasView!
    
    var toolPicker = PKToolPicker()
    
    @IBOutlet weak var mConceptHeader: UILabel!
    @IBOutlet weak var mDesignConceptView: UIView!
    
    @IBOutlet weak var mConcept: UITextView!
    
    @IBOutlet weak var mImageUploadView: UIView!
    
    @IBOutlet weak var mEngraveView: UIView!
    
    
    var mCustomerId = ""
    var mCustomDesignData = NSDictionary()
    var mImageArray = [UIImage]()
    var mImagesArray = [String]()
    var mImageImageArray = [String]()
    var mFontsArray = [String]()
    var mFontsIdArray = [String]()
    var mCanvasImageUrl = ""
    var mLogoImageUrl = ""
    
    var mFontId = ""
    
    var mCanvasImage = UIImage()
    var imagePicker = UIImagePickerController()
    var logoPicker = UIImagePickerController()
    
    var mData = NSDictionary()
    
    
    
    @IBOutlet weak var mProductName: UILabel!
    
    
//    @IBOutlet weak var mLocationName: UILabel!
    
    @IBOutlet weak var mCollectionName: UILabel!
    @IBOutlet weak var mMetaTag: UILabel!
    @IBOutlet weak var mMetalName: UILabel!
    @IBOutlet weak var mStoneName: UILabel!
    @IBOutlet weak var mSizeName: UILabel!
    
    @IBOutlet weak var mProductImage: UIImageView!
    @IBOutlet weak var mCollectionLABEL: UILabel!
    
    @IBOutlet weak var mSizeLABEL: UILabel!
    @IBOutlet weak var mMetalLABEL: UILabel!
    
    @IBOutlet weak var mLPosition: UILabel!
    @IBOutlet weak var mStoneLABEL: UILabel!
    
    @IBOutlet weak var mCanvasViewHolder: UIView!
    @IBOutlet weak var mCanvasScreen: UIView!
    @IBOutlet weak var mCanvasPreviousImage: UIImageView!
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldReceive touch: UITouch) -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("========== CUSTOM DESIGN INPUT ==========")
            print("🔥 FULL mData =", mData)
            print("🔥 collection_name =", mData.value(forKey: "collection_name") ?? "nil")
            print("🔥 Collection =", mData.value(forKey: "Collection") ?? "nil")
            print("🔥 collection =", mData.value(forKey: "collection") ?? "nil")
            print("=========================================")
        
//        print("mConcept =", mConcept as Any)
        print("mConcept text =", mConcept?.text ?? "nil")
        print("isEditable =", mConcept.isEditable)
        print("isUserInteractionEnabled =", mConcept.isUserInteractionEnabled)
        
        // Downloading image
        mProductImage.downlaodImageFromUrl(urlString: "\(mData.value(forKey: "main_image") ?? "")")
        
        // Setting up data
        mCartId = "\(mData.value(forKey: "custom_cart_id") ?? "")"
        mProductId = "\(mData.value(forKey: "id") ?? "")"
        mQty = "\(mData.value(forKey: "mQty") ?? "1")"
        mProductName.text = "\(mData.value(forKey: "SKU") ?? "--")"
        mMetaTag.text = "\(mData.value(forKey: "name") ?? "--")"
        mMetalName.text = "\(mData.value(forKey: "metal_name") ?? "")"
        mStoneName.text = "\(mData.value(forKey: "stone_name") ?? "--")"
//        mSizeName.text = "\(mData.value(forKey: "size_name") ?? "--")"
        let size = "\(mData.value(forKey: "Size_name") ?? "")"

        mSizeName.text = size.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? "--"
            : size
        mCollectionName.text = "\(mData.value(forKey: "collection_name") ?? "--")"
//        mLocationName.text = "\(mData.value(forKey: "location_name") ?? "--" )"
        
        // Hiding and showing views
        mCanvasViewHolder.isHidden = true
        mImageUploadView.isHidden = true
        mEngraveView.isHidden = true
        mDesignConceptView.isHidden = false
        mEngraveTextView.isHidden = false
        mEngraveLogoView.isHidden = true
        
        // Configuring UI elements
        mOnTextClick.setTitleColor(UIColor(named: "theme6A"), for: .normal)
        mTextSlider.backgroundColor = UIColor(named: "themeColor")
        mLogoSlider.backgroundColor = UIColor(named: "themeExtraLightText")
        mOnClickLogo.setTitleColor(UIColor(named: "themeExtraLightText"), for: .normal)
        
        // Adding gesture recognizer
//        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
//        view.addGestureRecognizer(tap)
        let tap = UITapGestureRecognizer(target: self,
                                             action: #selector(dismissKeyboard))
            tap.delegate = self
            tap.cancelsTouchesInView = false
            view.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false
        
        // Setting up collection view
        mPicturesCollection.delegate = self
        mPicturesCollection.dataSource = self
        
        // Setting default image
        mSketchImage.image = UIImage(named: "sketchgrey")
        
        // Fetching font names
        let mFontFamilyNames = UIFont.familyNames
        for family in mFontFamilyNames {
            let fontNames = UIFont.fontNames(forFamilyName: family)
            for font in fontNames {
                mFontsArray.append(font)
            }
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        IQKeyboardManager.shared.isEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        IQKeyboardManager.shared.isEnabled = false
        print("mStatus =", mStatus)
        
        if mStatus == "1" {
            let params:[String: Any] = ["custom_cart_id":mCartId,"customer_id":mCustomerId]
            CommonClass.showFullLoader(view: self.view)
            
            mGetData(url: mCustomDesignDetails,headers: sGisHeaders,  params: params) { response , status in
                CommonClass.stopLoader()
                print("========== GET CART ITEM DETAILS ==========")
                  print("PARAMS =", params)
                  print("STATUS =", status)
                  print("FULL RESPONSE =", response)
                  print("===========================================")
                if status {
                    if "\(response.value(forKey: "code") ?? "")" == "200" {
                        self.mImageStatus = "1"
                        
                        if let mData = response.value(forKey: "data") as? NSDictionary {
                            if let productDetails = mData.value(forKey: "product_details") as? NSDictionary {

                                    self.mCollectionName.text =
                                        "\(productDetails.value(forKey: "Collection_name") ?? "--")"

                                    self.mMetalName.text =
                                        "\(productDetails.value(forKey: "Metal_name") ?? "--")"

                                    self.mStoneName.text =
                                        "\(productDetails.value(forKey: "Stone_name") ?? "--")"

//                                    self.mSizeName.text =
//                                        "\(productDetails.value(forKey: "Size_name") ?? "--")"
                                    let size = "\(productDetails.value(forKey: "Size_name") ?? "")"

                                    self.mSizeName.text = size.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                        ? "--"
                                        : size

                                    self.mProductName.text =
                                        "\(productDetails.value(forKey: "SKU") ?? "--")"

                                    self.mMetaTag.text =
                                        "\(productDetails.value(forKey: "name") ?? "--")"

                                    self.mProductImage.downlaodImageFromUrl(
                                        urlString: "\(productDetails.value(forKey: "main_image") ?? "")"
                                    )
                                }
                            if let mCustomDesignData = mData.value(forKey: "custom_design") as? NSDictionary {
                                
                                self.mConcept.text = mCustomDesignData.value(forKey: "description") as? String ?? ""
                                self.mEngraveText.text = mCustomDesignData.value(forKey: "engraving_text") as? String ?? ""
                                self.mCanvasImageUrl = "\(mCustomDesignData.value(forKey: "canvas_design") ?? "")"
                                self.addImageToCanvasView()
                                self.mPosition.text = "\(mCustomDesignData.value(forKey: "engraving_position") ?? "")"
                                self.mLogoPosition.text = "\(mCustomDesignData.value(forKey: "logo_position") ?? "")"
                                self.mLogoImage.downlaodImageFromUrl(urlString: "\(mCustomDesignData.value(forKey: "engraving_logo") ?? "")")
                                self.mFont.text = mCustomDesignData.value(forKey: "font") as? String ?? ""
                                self.mFontId = mCustomDesignData.value(forKey: "font") as? String ?? ""
                                if self.mEngraveText.text?.isEmptyOrSpaces() == true {
                                    self.mFontSample.text = "Please choose fonts for text you want to engrave"
                                    self.mFontSample.font = UIFont(name: "SegoeUI", size: 18.0)
                                }else{
                                    self.mFontSample.text =  self.mEngraveText.text
                                    if self.mFontId == "" {
                                        self.mFontSample.font = UIFont(name: "SegoeUI", size: 18.0)
                                    }else{
                                        self.mFontSample.font = UIFont(name:  self.mFontId , size: 18.0)
                                    }
                                }
                                
                                
                                if let mImageDesign = mCustomDesignData.value(forKey: "image_design") as? [String] {
                                    if mImageDesign.count > 0 {
                                        for i in mImageDesign {
                                            self.mImagesArray.append(i)
                                            self.mPicturesCollection.reloadData()
                                        }
                                    }else{
                                        self.mImageStatus = ""
                                    }
                                }else{
                                    self.mImageStatus = ""
                                }
                            }
                        }
                      
                        
                    }else{
                    }
                }
            }
            
        }
        
        
        mMetalLABEL.text = "Metal".localizedString
        mStoneLABEL.text = "Stone".localizedString
        mCollectionLABEL.text = "Collection".localizedString
        mSizeLABEL.text = "Size".localizedString
        
        
        mConceptLabel.text = "Concept".localizedString
        mSketchLabel.text = "Sketch".localizedString
        mPictureLabel.text = "Picture".localizedString
        mEngraveLabel.text = "Engraving".localizedString
        mLogoPosition.placeholder = "Which position would you like to engraving ?".localizedString
        mConceptHeader.text = "Concept Design".localizedString
        
        mPosition.placeholder = "Which position would you like to engraving ?".localizedString
        mEngraveText.placeholder = "Write text you want to engrave".localizedString
        mFont.placeholder = "Choose font".localizedString
        
        mOnTextClick.setTitle("Text".localizedString, for: .normal)
        mOnClickLogo.setTitle("Logo".localizedString, for: .normal)
        
        mWriteConceptLABEL.text = "Write your concept design".localizedString
        mETextLABEL.text = "Text".localizedString
        mEPositionLABEL.text = "Position".localizedString
        mEFontLABEL.text = "Font".localizedString
        mUploadLogoLABEL.text = "Upload Logo".localizedString
        mLPosition.text = "Position".localizedString
        
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
    }
    
    func addImageToCanvasView() {
        mCanvasPreviousImage.downlaodImageFromUrl(urlString: mCanvasImageUrl)
        mCanvasPreviousImage.isHidden = false
    }
    
    func removeImageFromCanvas(){
        mCanvasPreviousImage.image = UIImage()
        mCanvasPreviousImage.isHidden = true
    }
    
    func getSketchURL(){
        if self.mCanvasView.drawing.strokes.count != 0 && mPage == 1 {
            mCanvasImage = self.mCanvasScreen.screenShot()
            let base64EncodedPath = mCanvasImage.toBase64()
            mGetImageUrl(base64: base64EncodedPath ?? "", type: "canvas")
        }
    }
    
    @IBAction func mClearCanvasButton(_ sender: Any) {
        removeImageFromCanvas()
        mCanvasView.drawing = PKDrawing()
        addPencilKit()
    }
    
    @IBAction func mSelectConcept(_ sender: UIButton) {
        getSketchURL()
        
        mConceptImage.showAnimation {
            
        }
        mConceptHeader.text = "Concept Design".localizedString
        mConceptLabel.textColor = UIColor(named: "theme6A")
        mConceptImage.image = UIImage(named: "conceptGrey")
        mConceptSeparator.backgroundColor = .systemGray2
        
        mSketchSeparator.backgroundColor = .systemGray2
        mSketchLabel.textColor = UIColor(named: "theme6A")
        mSketchImage.image = UIImage(named: "sketchgrey")
        
        mPictureSeparator.backgroundColor =  .systemGray2
        mPictureLabel.textColor =  UIColor(named: "theme6A")
        mPictureImage.image = UIImage(named: "pictureGrey")
        
        mEngraveLabel.textColor = UIColor(named: "theme6A")
        mEngraveImage.image = UIImage(named: "engravingGrey")
        mForwardImage.tintColor =  UIColor(named: "theme6A")
        
        mDesignConceptView.isHidden = false
        mCanvasViewHolder.isHidden = true
        mImageUploadView.isHidden = true
        mEngraveView.isHidden = true
        mPage = 0
        addPencilKit()
        
    }
    @IBAction func mSelectSketch(_ sender: UIButton) {
        
        mSketchImage.showAnimation {}
        mConceptSeparator.backgroundColor = UIColor(named: "themeColor")
        mConceptLabel.textColor = UIColor(named: "themeColor")
        mConceptImage.image = UIImage(named: "conceptGreen")
        
        mConceptHeader.text = "Sketch".localizedString
        mSketchSeparator.backgroundColor = .systemGray2
        mSketchLabel.textColor = UIColor(named: "theme6A")
        mSketchImage.image = UIImage(named: "sketchgrey")
        
        mPictureSeparator.backgroundColor =  .systemGray2
        mPictureLabel.textColor =  UIColor(named: "theme6A")
        mPictureImage.image = UIImage(named: "pictureGrey")
        
        mEngraveLabel.textColor = UIColor(named: "theme6A")
        mEngraveImage.image = UIImage(named: "engravingGrey")
        
        mForwardImage.tintColor =  UIColor(named: "theme6A")

        mDesignConceptView.isHidden = true
        mCanvasViewHolder.isHidden = false
        mImageUploadView.isHidden = true
        mEngraveView.isHidden = true
        mPage = 1
        addPencilKit()
    }
    @IBAction func mSelectPicture(_ sender: UIButton) {
        getSketchURL()
        mPictureImage.showAnimation {}
        mConceptHeader.text = "Picture".localizedString
        mDesignConceptView.isHidden = true
        mCanvasViewHolder.isHidden = true
        mImageUploadView.isHidden = false
        mEngraveView.isHidden = true
        mPage = 2
        mConceptSeparator.backgroundColor = UIColor(named: "themeColor")
        mConceptLabel.textColor = UIColor(named: "themeColor")
        mConceptImage.image = UIImage(named: "conceptGreen")
        mSketchSeparator.backgroundColor =  UIColor(named: "themeColor")
        mSketchLabel.textColor = UIColor(named: "themeColor")
        mSketchImage.image = UIImage(named: "sketchGreen")
        mPictureSeparator.backgroundColor =  .systemGray2
        mPictureLabel.textColor =  UIColor(named: "theme6A")
        mPictureImage.image = UIImage(named: "pictureGrey")
        
        mEngraveLabel.textColor = UIColor(named: "theme6A")
        mEngraveImage.image = UIImage(named: "engravingGrey")
        mForwardImage.tintColor =  UIColor(named: "theme6A")
        
        addPencilKit()
    }
    @IBAction func mSelectEngraving(_ sender: UIButton) {
        getSketchURL()
        mEngraveImage.showAnimation {}
        mForwardImage.tintColor =  UIColor(named: "themeColor")
        
        mConceptHeader.text = "Engraving".localizedString
        mConceptSeparator.backgroundColor = UIColor(named: "themeColor")
        mConceptLabel.textColor = UIColor(named: "themeColor")
        mConceptImage.image = UIImage(named: "conceptGreen")
        mSketchSeparator.backgroundColor =  UIColor(named: "themeColor")
        mSketchLabel.textColor = UIColor(named: "themeColor")
        mSketchImage.image = UIImage(named: "sketchGreen")
        mPictureSeparator.backgroundColor = UIColor(named: "themeColor")
        mPictureLabel.textColor =  UIColor(named: "themeColor")
        mPictureImage.image = UIImage(named: "pictureGreen")
        mPage = 3
        mEngraveLabel.textColor = UIColor(named: "theme6A")
        mEngraveImage.image = UIImage(named: "engravingGrey")
        mDesignConceptView.isHidden = true
        mCanvasViewHolder.isHidden = true
        mImageUploadView.isHidden = true
        mEngraveView.isHidden = false
        addPencilKit()
    }
    
    
    
    
    
    @objc func keyboardWillShow(notification: Notification) {
        
    }
    @objc func keyboardWillHide(notification: Notification) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if mStatus == "1" {
            return mImagesArray.count
        }
        return mImagesArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cells = collectionView.dequeueReusableCell(withReuseIdentifier: "PictureCell",for:indexPath) as? PictureCell else {
            return UICollectionViewCell()
        }
        
        cells.mImageView.contentMode = .scaleAspectFill
        cells.mButton.tag = indexPath.row
        
        cells.mImageView.downlaodImageFromUrl(urlString: mImagesArray[indexPath.row])
        
        return cells
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    @IBAction func mRemove(_ sender: UIButton) {
        
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            let alert:UIAlertController=UIAlertController(title: "Remove Image", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
            
            let cameraAction = UIAlertAction(title: "Remove", style: UIAlertAction.Style.default) {
                UIAlertAction in
                
                if self.mStatus != "" {
                    
                    self.mImagesArray.remove(at:sender.tag)
                    self.mPicturesCollection.reloadData()
                    if self.mImagesArray.count < 1 {
                        self.mImageStatus = ""
                    }
                }else{
                    self.mImagesArray.remove(at:sender.tag)
                    self.mPicturesCollection.reloadData()
                }
                
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
                
                UIAlertAction in
            }
            alert.addAction(cameraAction)
            
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }else{
            
            let alert:UIAlertController=UIAlertController(title: "Remove Image", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
            
            let cameraAction = UIAlertAction(title: "Remove", style: UIAlertAction.Style.default) {
                UIAlertAction in
                
                if self.mStatus != "" {
                    self.mImagesArray.remove(at:sender.tag)
                    self.mPicturesCollection.reloadData()
                    if self.mImagesArray.count < 1 {
                        self.mImageStatus = ""
                    }
                }else{
                    self.mImagesArray.remove(at:sender.tag)
                    self.mPicturesCollection.reloadData()
                }
                
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
                
                UIAlertAction in
            }
            
            // Add the actions
            
            alert.addAction(cameraAction)
            
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
            
            
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
    
    
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if picker == imagePicker {
            imagePicker.dismiss(animated: true, completion: nil)
            if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                let base64EncodedPath = pickedImage.toBase64()
                mGetImageUrl(base64: base64EncodedPath ?? "", type: "images")
            }
            
        }else{
            mLogoImage.backgroundColor = .white
            mLogoImage.image = (info[UIImagePickerController.InfoKey.originalImage] as? UIImage)

            if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                let base64EncodedPath = pickedImage.toBase64()
                mGetImageUrl(base64: base64EncodedPath ?? "", type: "logo")
            }
            logoPicker.dismiss(animated: true, completion: nil)
        }
        
    }
    
    
    func mGetImageUrl(base64 : String , type: String){
        let params:[String: Any] = ["image":base64,"name":type]
        
        CommonClass.showFullLoader(view: self.view)
        
        mGetData(url: mGenerateImageUrlAPI,headers: sGisHeaders,  params: params) { response , status in
            CommonClass.stopLoader()
            if status {
                if "\(response.value(forKey: "code") ?? "")" == "200" {
                    
                    guard response.value(forKey: "data") != nil else {
                        CommonClass.showSnackBar(message: "Image uploaded Failed!")
                        return
                    }
                    guard let mData = response.value(forKey: "data") as? NSDictionary,
                          let images = mData.value(forKey: "images") as? NSDictionary,
                          let imageUrl = images.value(forKey: "url") as? String else {
                        CommonClass.showSnackBar(message: "Image uploaded Failed!")
                        return
                    }
                    
                    if type == "logo" {
                        self.mLogoImageUrl = imageUrl
                        
                    }else if type == "canvas" {
                        self.mCanvasImageUrl = imageUrl
                        
                    }else if type == "images"{
                        self.mImagesArray.append(imageUrl)
                        self.mPicturesCollection.reloadData()
                    }
                    
                    CommonClass.showSnackBar(message: "Image uploaded successfully!")
                    
                }else{
                    CommonClass.showSnackBar(message: "Image uploaded Failed!")
                }
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    private func addPencilKit() {
        if mPage == 1 {
            toolPicker.setVisible(true, forFirstResponder: mCanvasView)
            toolPicker.addObserver(mCanvasView)
            mCanvasView.becomeFirstResponder()
            
        }else{
            toolPicker.setVisible(false, forFirstResponder: mCanvasView)
        }
    }
    
    @IBAction func mChooseImage(_ sender: Any) {
        
        if  self.mImagesArray.count  < 5 {
            mKey = ""
            
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
                imagePicker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
                alert.addAction(cameraAction)
                alert.addAction(gallaryAction)
                alert.addAction(cancelAction)
                addActionSheetForiPad(actionSheet: alert)
                self.present(alert, animated: true, completion: nil)
                
                
                
                
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
                imagePicker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
                alert.addAction(cameraAction)
                alert.addAction(gallaryAction)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
                
                
                
                
            }
            
            
            
        }else{
            CommonClass.showSnackBar(message: "You can add only 4 pictures, Please remove already added pictures!")
        }
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
            self.present(alert, animated: true, completion: nil)
            
            
            
            
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
            self.present(alert, animated: true, completion: nil)
            
            
        }
        
        
    }
    
    @IBAction func mBack(_ sender: Any) {
        
        if mPage == 0 {
            self.navigationController?.popViewController(animated: true)
            mPage = 0
            
        }else if mPage == 1 {
            mConceptHeader.text = "Concept Design".localizedString
            mConceptLabel.textColor = UIColor(named: "theme6A")
            mConceptImage.image = UIImage(named: "conceptGrey")
            mConceptSeparator.backgroundColor = .systemGray2
            mForwardImage.tintColor =  UIColor(named: "theme6A")
            
            mDesignConceptView.isHidden = false
            mCanvasViewHolder.isHidden = true
            mImageUploadView.isHidden = true
            mEngraveView.isHidden = true
            mPage = 0
            addPencilKit()
        }else if mPage == 2 {
            mConceptHeader.text = "Sketch".localizedString
            mSketchSeparator.backgroundColor = .systemGray2
            mSketchLabel.textColor = UIColor(named: "theme6A")
            mSketchImage.image = UIImage(named: "sketchgrey")
            
            mForwardImage.tintColor =  UIColor(named: "theme6A")
            mPictureSeparator.backgroundColor =  .systemGray2
            mPictureLabel.textColor =  UIColor(named: "theme6A")
            mPictureImage.image = UIImage(named: "pictureGrey")
            mDesignConceptView.isHidden = true
            mCanvasViewHolder.isHidden = false
            mImageUploadView.isHidden = true
            mEngraveView.isHidden = true
            mPage = 1
            addPencilKit()
            
            
        }else if mPage == 3 {
            mConceptHeader.text = "Picture".localizedString
            mDesignConceptView.isHidden = true
            mCanvasViewHolder.isHidden = true
            mImageUploadView.isHidden = false
            mEngraveView.isHidden = true
            mPage = 2
            mForwardImage.tintColor =  UIColor(named: "theme6A")
            mPictureSeparator.backgroundColor =  .systemGray2
            mPictureLabel.textColor = UIColor(named: "theme6A")
            mPictureImage.image = UIImage(named: "pictureGrey")
            
            mEngraveLabel.textColor =  UIColor(named: "theme6A")
            mEngraveImage.image = UIImage(named: "engravingGrey")
            addPencilKit()
        }
        
    }
    
    @IBAction func mRight(_ sender: Any) {
        
        if mPage == 0 {
            
            
            
            mConceptHeader.text = "Sketch".localizedString
            mConceptSeparator.backgroundColor = UIColor(named: "themeColor")
            mConceptLabel.textColor = UIColor(named: "themeColor")
            mConceptImage.image = UIImage(named: "conceptGreen")
            
            mDesignConceptView.isHidden = true
            mCanvasViewHolder.isHidden = false
            mImageUploadView.isHidden = true
            mEngraveView.isHidden = true
            mPage = 1
            mForwardImage.tintColor =  UIColor(named: "theme6A")
            
            addPencilKit()
            
        }else if mPage == 1 {
            if self.mCanvasView.drawing.strokes.count != 0 {
                mCanvasImage = self.mCanvasScreen.screenShot()
                let base64EncodedPath = mCanvasImage.toBase64()
                mGetImageUrl(base64: base64EncodedPath ?? "", type: "canvas")
            }
            
            mConceptHeader.text = "Picture".localizedString
            mSketchSeparator.backgroundColor = UIColor(named: "themeColor")
            mSketchLabel.textColor = UIColor(named: "themeColor")
            mSketchImage.image = UIImage(named: "sketchGreen")
            
            mPictureSeparator.backgroundColor =  .systemGray2
            mPictureLabel.textColor = UIColor(named: "theme6A")
            mPictureImage.image = UIImage(named: "pictureGrey")
            
            
            mDesignConceptView.isHidden = true
            mCanvasViewHolder.isHidden = true
            mImageUploadView.isHidden = false
            mEngraveView.isHidden = true
            mPage = 2
            mForwardImage.tintColor =  UIColor(named: "theme6A")
            
            addPencilKit()
        }else if mPage == 2 {
            mConceptHeader.text = "Engraving".localizedString
            mPictureSeparator.backgroundColor =  UIColor(named: "themeColor")
            mPictureLabel.textColor = UIColor(named: "themeColor")
            mPictureImage.image = UIImage(named: "pictureGreen")
            
            mEngraveLabel.textColor = UIColor(named: "theme6A")
            mEngraveImage.image = UIImage(named: "engravingGrey")
            mDesignConceptView.isHidden = true
            mCanvasViewHolder.isHidden = true
            mImageUploadView.isHidden = true
            mEngraveView.isHidden = false
            mPage = 3
            mForwardImage.tintColor =  UIColor(named: "themeColor")
            
            addPencilKit()
        }else if mPage == 3 {
            
            if mStatus == "1"{
                for i in 0..<mImagesArray.count{
                    let mIndexPath = IndexPath(row:i,section: 0)
                    if let cell = self.mPicturesCollection.cellForItem(at: mIndexPath) as? PictureCell,
                       let image = cell.mImageView.image {
                        mImageArray.append(image)
                    }
                }
                mUploaddData()
                
            }else{
                mUploaddData()
            }
        }
        
    }
    
    
    func mUploaddData() {
        
        CommonClass.showFullLoader(view: self.view)
        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
        
        let mData = NSMutableDictionary()
        
        mData.setValue(self.mConcept.text ?? "", forKey: "description")
        mData.setValue(mEngraveText.text ?? "", forKey: "engraving_text")
        mData.setValue(mPosition.text ?? "", forKey: "engraving_position")
        mData.setValue(mLogoPosition.text ?? "", forKey: "logo_position")
        mData.setValue(mImagesArray, forKey: "image_design")
        mData.setValue(mCanvasImageUrl, forKey: "canvas_design")
        mData.setValue(mLogoImageUrl, forKey: "engraving_logo")
        mData.setValue(self.mFontId, forKey: "font")
        
        let mParams: [String:Any] = ["Qty": self.mQty,
                                     "custom_design":mData,
                                     "product_id":mProductId,
                                     "custom_cart_id":mCartId]
        
        mGetData(url: mAddConceptDesign,headers: sGisHeaders,  params: mParams) { response , status in
            CommonClass.stopLoader()
            if status {
                if "\(response.value(forKey: "code") ?? "")" == "200" {
                    if let customCartVC = self.navigationController?.viewControllers.first(where: { $0 is CustomCart }) as? CustomCart {
                        self.navigationController?.popToViewController(customCartVC, animated: true)
                    } else {
                        let storyboard = UIStoryboard(name: "customOrder", bundle: nil)
                        if let mCustomCart = storyboard.instantiateViewController(withIdentifier: "CustomCart") as? CustomCart {
                            self.navigationController?.pushViewController(mCustomCart, animated: true)
                        }
                    }
                }else{
                    
                }
            }
        }
        
        
    }
    
    
    func mGetFonts(){
        
        let urlPath = mFonts
        
        
        if Reachability.isConnectedToNetwork() == true {
            AF.request(urlPath, method:.post, parameters:nil, headers: sGisHeaders2).responseJSON
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
                    
                    if let data = jsonResult.value(forKey: "font") as? NSArray {
                        self.mFontsArray = [String]()
                        self.mFontsIdArray = [String]()
                        if data.count > 0 {
                            for i in data {
                                if let countryData = i as? NSDictionary {
                                    if self.mStatus == "" {
                                        if let id = countryData.value(forKey: "id") as? String, id == self.mCustomDesignData.value(forKey: "font") as? String {
                                            if self.mStatus == "" {
                                                if let name = countryData.value(forKey: "name") as? String {
                                                    self.mFont.text = name
                                                    self.mFontId = id
                                                }
                                            }
                                        }
                                    }
                                    
                                    if let name = countryData.value(forKey: "name") as? String, let id = countryData.value(forKey: "id") as? String {
                                        self.mFontsArray.append(name)
                                        self.mFontsIdArray.append(id)
                                    }
                                }
                            }
                            
                        }
                    }
                }
                
            }
        }else{
            CommonClass.showSnackBar(message: "No Internet Connection")
        }
        
        
    }
}

extension UIView {
    
    func screenShot() -> UIImage {
        if #available(iOS 10.0, *) {
            return UIGraphicsImageRenderer(size: bounds.size).image { _ in
                drawHierarchy(in: bounds, afterScreenUpdates: true)
            }
        } else {
            UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
            defer { UIGraphicsEndImageContext() }
            drawHierarchy(in: bounds, afterScreenUpdates: true)
            return UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        }
    }
}

extension UIViewController {
    public func addActionSheetForiPad(actionSheet: UIAlertController) {
        if let popoverPresentationController = actionSheet.popoverPresentationController {
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverPresentationController.permittedArrowDirections = []
        }
    }
}
