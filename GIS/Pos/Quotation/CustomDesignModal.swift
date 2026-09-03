//
//  CustomDesignModal.swift
//  GIS
//
//  Created by Macbook Pro on 27/07/23.
//  Copyright © 2023 Hawkscode. All rights reserved.
//

import UIKit
import Alamofire
class CustomDesignModal: UIViewController , UICollectionViewDelegate, UICollectionViewDataSource {
    

    
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
    

    @IBOutlet weak var mConceptLABEL: UILabel!
    
    @IBOutlet weak var mCollectionView: UICollectionView!
    @IBOutlet weak var mSketchLABEL: UILabel!
    @IBOutlet weak var mConceptText: UITextView!
    
    @IBOutlet weak var mSketchImage: UIImageView!
    
    @IBOutlet weak var mPictureLABEL: UILabel!
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
    
    
    
    var mId = ""
    var mCartId = ""
    var mType = "Custom_Order"
    var mImageData = [String]()

    var delegate:QuotedItemDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        mJMetalLABEL.text = "Metal".localizedString
        mJStoneLABEL.text = "Stone".localizedString
        mJSizeLABEL.text = "Size".localizedString
        mJCollectionLABEL.text = "Collection".localizedString
  
        mConceptLABEL.text = "Concept".localizedString
        mSketchLABEL.text = "Sketch".localizedString
        mPictureLABEL.text = "Picture".localizedString

        mEngravingLABEL.text = "Engraving".localizedString
        mText1LABEL.text = "Text".localizedString
        mTextLABEL.text = "Text".localizedString
        mEngravingFontLABEL.text = "Font".localizedString
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
            print("CustomDesignModal \(response)")
            if status {
                if "\(response.value(forKey: "code") ?? "")" == "200" {
                    
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
                            self.mJLocation.text = mProductDetails.value(forKey: "location") as? String ?? "--"
                            self.mJStoneName.text = mProductDetails.value(forKey: "stone") as? String ?? "--"
                        }
                        
                        if let mCustomDesign = mData.value(forKey: "custom_design") as? NSDictionary {
                            self.mEngravingText.text = mCustomDesign.value(forKey: "engraving_text") as? String ?? "--"
                            self.mEngravingFont.text = mCustomDesign.value(forKey: "font") as? String ?? "--"
                            let mFont = mCustomDesign.value(forKey: "font") as? String ?? "SegoeUI"
                            if self.mEngravingText.text?.isEmptyOrSpaces() == true {
                                self.mEngravingFontPreview.text = "No font selected for engraving!"
                                self.mEngravingFontPreview.font = UIFont(name: mFont, size: 18.0)
                            }else{
                                self.mEngravingFontPreview.text =  mCustomDesign.value(forKey: "engraving_text") as? String ?? ""
                                self.mEngravingFontPreview.font = UIFont(name: mFont, size: 18.0)
                            }
                            
                            self.mConceptText.text = mCustomDesign.value(forKey: "description") as? String ?? "--"
                            self.mEngravingPosition.text = mCustomDesign.value(forKey: "engraving_position") as? String ?? "--"
                            self.mEngravingLogoPosition.text = mCustomDesign.value(forKey: "logo_position") as? String ?? "--"
                            self.mEngravingLogoImage.downlaodImageFromUrl(urlString: mCustomDesign.value(forKey: "engraving_logo") as? String ?? "")
                            self.mSketchImage.downlaodImageFromUrl(urlString: mCustomDesign.value(forKey: "canvas_design") as? String ?? "")
                            
                            if let mImages = mCustomDesign.value(forKey: "image_design") as? [String] {
                                self.mImageData =  mImages
                                self.mCollectionView.delegate = self
                                self.mCollectionView.dataSource = self
                                self.mCollectionView.reloadData()
                            }
                        }
                        
                        
                    }
                    
                    
                }else{
                    
                }
            }
        }
    }
    
    
    @IBAction func mAddToCart(_ sender: Any) {
        self.dismiss(animated: true)
        self.delegate?.mGetItems(id: mId, type: "custom_order")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return mImageData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        guard let cells = collectionView.dequeueReusableCell(withReuseIdentifier: "ModalImageCell",for:indexPath) as? ModalImageCell else {
            return UICollectionViewCell()
        }
        
        cells.mImage.contentMode = .scaleAspectFill
        cells.mView.backgroundColor = .white
        cells.mImage.downlaodImageFromUrl(urlString: self.mImageData[indexPath.row])
        
        return cells
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
}
