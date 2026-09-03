//
//  MixAndMatchEngravingUpdate.swift
//  GIS
//
//  Created by MacBook Hawkscode  on 22/02/23.
//  Copyright © 2023 Hawkscode. All rights reserved.
//


import UIKit
import PencilKit
import DropDown
import Alamofire
import RSSelectionMenu


protocol EngravingDelegate {
    func mGetEngraving(data:NSDictionary)
}

class MixAndMatchEngravingUpdate: UIViewController,UIImagePickerControllerDelegate ,UINavigationControllerDelegate,UIViewControllerTransitioningDelegate {
    /**Jewelry**/
    var delegate:EngravingDelegate? = nil
    
    var mLogoImageUrl = ""
    var mCustomerId = ""
    var mItemTypeId = ""
    
    @IBOutlet weak var mNextView: UIView!

    @IBOutlet weak var mTextLogoEngravingView: UIStackView!
    @IBOutlet weak var mEngraveTextView: UIStackView!
    @IBOutlet weak var mEngraveText: UITextField!
    
    @IBOutlet weak var mPosition: UITextField!
    @IBOutlet weak var mFont: UITextField!
    
    @IBOutlet weak var mLogoPosition: UITextField!
    
    @IBOutlet weak var mLogoImage: UIImageView!
    @IBOutlet weak var mEngraveLogoView: UIStackView!
    
    @IBOutlet weak var mOnTextClick: UIButton!
    @IBOutlet weak var mTextSlider: UIView!
    
    @IBOutlet weak var mOnClickLogo: UIButton!
    @IBOutlet weak var mLogoSlider: UIView!
    
    var imagePicker = UIImagePickerController()
    var logoPicker = UIImagePickerController()
    var mKey = ""
    @IBOutlet weak var mFontSample: UITextView!
    var mFontsArray = [String]()
    var mEngraveData = NSMutableDictionary()
    
    var mFontId = ""
    @IBOutlet weak var mHeading: UILabel!
    @IBOutlet weak var mETextLABEL: UILabel!
    @IBOutlet weak var mEPositionLABEL: UILabel!
    @IBOutlet weak var mLPosition: UILabel!
    @IBOutlet weak var mUploadLOGOLABEL: UILabel!
    @IBOutlet weak var mEFontLABEL: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        mHeading.text = "Select Engraving".localizedString
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
    }
    
    override func viewDidLoad() {
        
        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
        
        mEngraveText.text = mEngraveData.value(forKey: "engravingText") as? String ?? ""
        mFont.text = mEngraveData.value(forKey: "engravingFont") as? String ?? ""
        mPosition.text = mEngraveData.value(forKey: "engravingPosition") as? String ?? ""
        mLogoPosition.text = mEngraveData.value(forKey: "logoPosition") as? String ?? ""
        mLogoImage.downlaodImageFromUrl(urlString:  mEngraveData.value(forKey: "logoImage") as? String ?? "")
        
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
    }
    
    @IBAction func mBack(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func mNext(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
        let mEngraveData = NSMutableDictionary()
        mEngraveData.setValue(self.mEngraveText.text ?? "", forKey: "engravingText")
        mEngraveData.setValue(self.mPosition.text ?? "", forKey: "engravingPosition")
        mEngraveData.setValue(self.mFontId, forKey: "engravingFont")
        mEngraveData.setValue(self.mLogoImageUrl, forKey: "logoImage")
        mEngraveData.setValue(self.mLogoPosition.text, forKey: "logoPosition")
        delegate?.mGetEngraving(data: mEngraveData)
        dismiss(animated: false)
        
    }
    
    
    @IBAction func mChooseFont(_ sender: Any) {
        let mArray = [String]()
        let menu = RSSelectionMenu(selectionStyle: .single, dataSource: mFontsArray) { (cell, name, indexPath) in
            cell.textLabel?.text = name
        }
        menu.showSearchBar { [weak self] (searchText) -> ([String]) in
            
            return self?.mFontsArray.filter({ $0.lowercased().starts(with: searchText.lowercased()) }) ?? []
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
    
    func imagePickerController(_ picker: UIImagePickerController,didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
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
        
        
        mGetData(url: mGenerateImageUrlAPI,headers: sGisHeaders,  params: params) { response , status in
            CommonClass.stopLoader()
            if status {
                if "\(response.value(forKey: "code") ?? "")" == "200" {
                    
                    if response.value(forKey: "data") == nil {
                        return
                    }
                    
                    if let mData = response.value(forKey: "data") as? NSDictionary {
                        
                        if let images = mData.value(forKey: "images") as? NSDictionary {
                            if type == "logo" {
                                self.mLogoImageUrl = images.value(forKey: "url") as? String ?? ""
                                CommonClass.showSnackBar(message: "Image uploaded successfully!")
                            }
                        }

                    }

                } else {
                    
                }
            }
        }
    }
    
    
    
}

