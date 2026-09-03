//
//  RepairDesignModal.swift
//  GIS
//
//  Created by Macbook Pro on 27/07/23.
//  Copyright © 2023 Hawkscode. All rights reserved.
//

import UIKit
import Alamofire
class ModalImageCell: UICollectionViewCell {
    @IBOutlet weak var mImage: UIImageView!
    
    @IBOutlet weak var mView: UIView!
}

class RepairDesignModal: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
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
    
    @IBOutlet weak var mRepairItemsLABEL: UILabel!
    @IBOutlet weak var mRepairItems: UITextView!
    @IBOutlet weak var mCollectionView: UICollectionView!
    @IBOutlet weak var mPictureLABEL: UILabel!
    @IBOutlet weak var mProcessText: UITextView!
    @IBOutlet weak var mProcessLABEL: UILabel!
    
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
    var mType = "Repair"
    var mImageData = [String]()
    var mRepairData = [String]()
    var delegate:QuotedItemDelegate? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        mJMetalLABEL.text = "Metal".localizedString
        mJStoneLABEL.text = "Stone".localizedString
        mJSizeLABEL.text = "Size".localizedString
        mJCollectionLABEL.text = "Collection".localizedString
  
        mProcessLABEL.text = "Process".localizedString
        mRepairItemsLABEL.text = "Repair Items".localizedString
        mPictureLABEL.text = "Picture".localizedString

        mRemarkLABEL.text = "Remarks".localizedString
        mGrandTotalLABEL.text = "Grand Total".localizedString
        mDeliveryDateLabel.text = "Delivery".localizedString
        mAddToCartBUTTON.setTitle("ADD TO ORDER".localizedString, for: .normal)
        self.mDeliveryDate.text = "--"
        self.mRemarks.text = "--"
        CommonClass.showFullLoader(view: self.view)
        let mParams = [ "quotation_id":mId, "cart_id":mCartId, "type":mType] as [String : Any]
        
        mGetData(url: mQuotationDesign,headers:sGisHeaders,  params: mParams) { response , status in
            CommonClass.stopLoader()
            print("RepairDesignModal \(response)")
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
                        self.mJLocation.text = mData.value(forKey: "location") as? String ?? "--"
                        self.mJStoneName.text = mProductDetails.value(forKey: "stone") as? String ?? "--"
                    }
                    
                    if let mRepairDesign = mData.value(forKey: "repair_design") as? NSDictionary {
                        self.mProcessText.text = mRepairDesign.value(forKey: "description") as? String ?? "--"
                        if let mImages = mRepairDesign.value(forKey: "image_design") as? [String] {
                            self.mImageData =  mImages
                            self.mCollectionView.delegate = self
                            self.mCollectionView.dataSource = self
                            self.mCollectionView.reloadData()
                        }
                        
                        if let mRepairItem = mRepairDesign.value(forKey: "repair_list") as? [String] {
                            if !mRepairItem.isEmpty {
                                self.mRepairItems.text = mRepairItem.joined(separator: ", ")
                            }else{
                                self.mRepairItems.text = "No repair items yet!"
                            }
                        } else {
                            self.mRepairItems.text = "No repair items yet!"
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
        self.delegate?.mGetItems(id: mId, type: "repair_order")
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       
        return mImageData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if let cells = collectionView.dequeueReusableCell(withReuseIdentifier: "ModalImageCell",for:indexPath) as? ModalImageCell {
            
            cells.mImage.contentMode = .scaleAspectFill
            cells.mView.backgroundColor = .white
            cells.mImage.downlaodImageFromUrl(urlString: self.mImageData[indexPath.row])
            
            return cells
        } else {
            return UICollectionViewCell()
        }
    }


    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
    }
    

}
