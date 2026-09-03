//
//  MixMatchDesignModal.swift
//  GIS
//
//  Created by Macbook Pro on 27/07/23.
//  Copyright © 2023 Hawkscode. All rights reserved.
//

import UIKit
import Alamofire
class MixMatchDesignModal: UIViewController {

    
    
    
    //Jewelry
    
    @IBOutlet weak var mJStockId: UILabel!
    @IBOutlet weak var mJProductImage: UIImageView!
    @IBOutlet weak var mJSKU: UILabel!
    @IBOutlet weak var mJMetatag: UILabel!
    @IBOutlet weak var mJLocation: UILabel!
    @IBOutlet weak var mJMetalLABEL: UILabel!
    @IBOutlet weak var mJMetalName: UILabel!
    @IBOutlet weak var mJStoneLABEL: UILabel!
    @IBOutlet weak var mJStoneName: UILabel!
    @IBOutlet weak var mJSizeLABEL: UILabel!
    @IBOutlet weak var mJSizeName: UILabel!
    @IBOutlet weak var mJCollectionLABEL: UILabel!
    @IBOutlet weak var mJCollectionName: UILabel!
    
    //Diamond
    @IBOutlet weak var mDStockId: UILabel!
    @IBOutlet weak var mDProductImage: UIImageView!
    @IBOutlet weak var mDSKU: UILabel!
    @IBOutlet weak var mDMetatag: UILabel!
    @IBOutlet weak var mDLocation: UILabel!
    
    @IBOutlet weak var mDShapeLABEL: UILabel!
    @IBOutlet weak var mDShapeName: UILabel!
    @IBOutlet weak var mDColorLABEL: UILabel!
    @IBOutlet weak var mDColorName: UILabel!
    @IBOutlet weak var mDCutLABEL: UILabel!
    @IBOutlet weak var mDCutName: UILabel!
    
    @IBOutlet weak var mDCaratLABEL: UILabel!
    @IBOutlet weak var mDCaratName: UILabel!
    
    @IBOutlet weak var mDClarityLABEL: UILabel!
    @IBOutlet weak var mDClarityName: UILabel!
    
    @IBOutlet weak var mDCertificationLABEL: UILabel!
    @IBOutlet weak var mDCertificateName: UILabel!
    
    @IBOutlet weak var mText1LABEL: UILabel!
    @IBOutlet weak var mEngravingLABEL: UILabel!
    @IBOutlet weak var mTextLABEL: UILabel!
    
    @IBOutlet weak var mEngravingText: UILabel!
    @IBOutlet weak var mEngravingPositionLABEL: UILabel!
    @IBOutlet weak var mEngravingPosition: UILabel!
    @IBOutlet weak var mEngravingFontPreview: UITextView!
    @IBOutlet weak var mEngravingFontLABEL: UILabel!
    @IBOutlet weak var mEngravingFont: UILabel!
    
    @IBOutlet weak var mEngravingLogoLABEL: UILabel!
    @IBOutlet weak var mEngravingLogoImage: UIImageView!
    @IBOutlet weak var mEngravingLogoPositionLABEL: UILabel!
 
    @IBOutlet weak var mEngravingLogoPosition: UILabel!
    
    
    @IBOutlet weak var mRemarkLABEL: UILabel!
    @IBOutlet weak var mDeliveryDate: UILabel!
    @IBOutlet weak var mDeliveryDateLabel: UILabel!
    @IBOutlet weak var mRemarks: UILabel!
    
    @IBOutlet weak var mGrandTotalLABEL: UILabel!
    @IBOutlet weak var mTotalItems: UILabel!
    @IBOutlet weak var mAddToCartBUTTON: UIButton!
    @IBOutlet weak var mGrandTotal: UILabel!
    
    
    @IBOutlet weak var mJewelryView: UIView!
    @IBOutlet weak var mDiamondView: UIView!
    
    @IBOutlet weak var mSelectedItemIcon: UIImageView!
    
    @IBOutlet weak var mSelectedItemLABEL: UILabel!
    
    var mLink = ""
    var mId = ""
    var mCartId = ""
    var mType = "Mix_And_Match"
    var mImageData = [String]()
    var delegate:QuotedItemDelegate? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        mJMetalLABEL.text = "Metal".localizedString
        mJStoneLABEL.text = "Stone".localizedString
        mJSizeLABEL.text = "Size".localizedString
        mJCollectionLABEL.text = "Collection".localizedString
        
        
        mDShapeLABEL.text = "Shape".localizedString
        mDCaratLABEL.text = "Carat".localizedString
        mDClarityLABEL.text = "Clarity".localizedString
        mDColorLABEL.text = "Color".localizedString
        mDCutLABEL.text = "Cut".localizedString
        mDCertificationLABEL.text = "Certificate".localizedString
       
        mSelectedItemLABEL.text = "Jewelry Details".localizedString
        
        mEngravingLABEL.text = "Engraving".localizedString
        mText1LABEL.text = "Text".localizedString
        mTextLABEL.text = "Text".localizedString
        mEngravingFontLABEL.text = "Font".localizedString
        mDeliveryDateLabel.text = "Delivery Date".localizedString
        mRemarkLABEL.text = "Remarks".localizedString
        mGrandTotalLABEL.text = "Grand Total".localizedString
        mDeliveryDateLabel.text = "Delivery".localizedString
        mEngravingPositionLABEL.text = "Position".localizedString
        mEngravingLogoPositionLABEL.text = "Position".localizedString

        mAddToCartBUTTON.setTitle("ADD TO ORDER".localizedString, for: .normal)

        
        self.mDeliveryDate.text = "--"
        self.mRemarks.text = "--"
        CommonClass.showFullLoader(view: self.view)
        let mParams = [ "quotation_id":mId, "cart_id":mCartId, "type":mType] as [String : Any]
       
        mGetData(url: mQuotationDesign,headers: sGisHeaders,  params: mParams) { response , status in
            CommonClass.stopLoader()
            print("MixMatchDesignModal \(response)")
             if status {
            if "\(response.value(forKey: "code")!)" == "200" {
                
                if let mData = response.value(forKey: "data") as? NSDictionary {
                 
                    self.mGrandTotal.text = "\(mData.value(forKey: "grandTotal") ?? "0.0")"
                    self.mTotalItems.text = "\(mData.value(forKey: "qty") ?? "0") items"
                    
                    if let mProductDetails = mData.value(forKey: "product_details") as? NSDictionary {
                        
                        self.mJProductImage.downlaodImageFromUrl(urlString: mProductDetails.value(forKey: "main_image") as? String ?? "")
                        self.mJMetatag.text = mProductDetails.value(forKey: "name") as? String ?? "--"
                        self.mJSKU.text = mProductDetails.value(forKey: "SKU") as? String ?? "--"
                        self.mJStockId.text = mProductDetails.value(forKey: "stock_id") as? String ?? "--"
                        self.mJMetalName.text = mProductDetails.value(forKey: "metal") as? String ?? "--"
                        self.mJSizeName.text = mProductDetails.value(forKey: "size") as? String ?? "--"
                        self.mJCollectionName.text = mProductDetails.value(forKey: "collection") as? String ?? "--"
                        self.mJLocation.text = mData.value(forKey: "location") as? String ?? "--"
                        self.mJStoneName.text = mProductDetails.value(forKey: "stone") as? String ?? "--"
                    }
                    if let mDiamondDetails = mData.value(forKey: "diamond_details") as? NSDictionary {
    
                        self.mDProductImage.downlaodImageFromUrl(urlString: mDiamondDetails.value(forKey: "main_image") as? String ?? "")
                        self.mDMetatag.text = mDiamondDetails.value(forKey: "name") as? String ?? "--"
                        self.mDSKU.text = mDiamondDetails.value(forKey: "SKU") as? String ?? "--"
                        self.mDStockId.text = mDiamondDetails.value(forKey: "stock_id") as? String ?? "--"
                        self.mDCaratName.text = "\(mDiamondDetails.value(forKey: "Carat") ?? "--")"
                        self.mDClarityName.text = mDiamondDetails.value(forKey: "Clarity") as? String ?? "--"
                        self.mDCutName.text = mDiamondDetails.value(forKey: "Cut") as? String ?? "--"
                        self.mDLocation.text = mData.value(forKey: "location") as? String ?? "--"
                        self.mDShapeName.text = mDiamondDetails.value(forKey: "shape") as? String ?? "--"
                        self.mDColorName.text = mDiamondDetails.value(forKey: "Colour") as? String ?? "--"
                        self.mDCertificateName.text = mDiamondDetails.value(forKey: "GradedBy") as? String ?? "--"
                        self.mLink = mDiamondDetails.value(forKey: "CertificationUrl") as? String ?? ""
                    }
                    
                    
                    if let mMixAndMatchDesign = mData.value(forKey: "mixAndMatch_design") as? NSDictionary {
                        self.mEngravingText.text = mMixAndMatchDesign.value(forKey: "engraving_text") as? String ?? "--"
                        self.mEngravingFont.text = mMixAndMatchDesign.value(forKey: "font") as? String ?? "--"
                        
                        let mFont = mMixAndMatchDesign.value(forKey: "font") as? String ?? "SegoeUI"
                        if self.mEngravingText.text?.isEmptyOrSpaces() == true {
                            self.mEngravingFontPreview.text = "No font selected for engraving!"
                            self.mEngravingFontPreview.font = UIFont(name: mFont ?? "SegoeUI", size: 18.0)
                        }else{
                            self.mEngravingFontPreview.text =  mMixAndMatchDesign.value(forKey: "engraving_text") as? String ?? ""
                            self.mEngravingFontPreview.font = UIFont(name: mFont ?? "SegoeUI", size: 18.0)
                        }
                        self.mEngravingPosition.text = mMixAndMatchDesign.value(forKey: "engraving_position") as? String ?? "--"
                        self.mEngravingLogoPosition.text = mMixAndMatchDesign.value(forKey: "logo_position") as? String ?? "--"
                        self.mEngravingLogoImage.downlaodImageFromUrl(urlString: mMixAndMatchDesign.value(forKey: "engraving_logo") as? String ?? "")
                       
 
                    }
                    
                    
                }
                
                
             }else{
          
            }
        }
    }
     }
    @IBAction func mAddToCart(_ sender: Any) {
        self.dismiss(animated: true)
           self.delegate?.mGetItems(id: mId, type: "mix_and_match")
    }
    

    @IBAction func mSwitchItems(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            mSelectedItemLABEL.text = "Diamond Details".localizedString
            mSelectedItemIcon.image = UIImage(named: "dgreendiamond")
            UIView.animate(withDuration: 1.0) {
                self.mDiamondView.isHidden = false
                self.mJewelryView.isHidden = true

                self.view.layoutIfNeeded()
            }
        }else{
            mSelectedItemLABEL.text = "Jewelry Details".localizedString
            mSelectedItemIcon.image = UIImage(named: "dgreensetting")
             UIView.animate(withDuration: 1.0) {
                self.mJewelryView.isHidden = false
                 self.mDiamondView.isHidden = true
                 self.view.layoutIfNeeded()
            }
        }
    }
    @IBAction func mOpenLink(_ sender: Any) {
        
    }
    

}
