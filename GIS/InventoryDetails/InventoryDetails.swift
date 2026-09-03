//
//  InventoryDetails.swift
//  GIS
//
//  Created by MacBook Hawkscode  on 24/06/22.
//  Copyright © 2022 Hawkscode. All rights reserved.
//

import UIKit
import Alamofire


class AllImageCollections : UICollectionViewCell {
    
    @IBOutlet weak var mView: UIView!
    @IBOutlet weak var mImage: UIImageView!
}
class InventoryStoneItems : UITableViewCell {
    
    @IBOutlet weak var mStone: UILabel!
    @IBOutlet weak var mShape: UILabel!
    
    @IBOutlet weak var mCut: UILabel!
    
    @IBOutlet weak var mClarity: UILabel!
    
    @IBOutlet weak var mColor: UILabel!
    
    
    @IBOutlet weak var mSize: UILabel!
    
    @IBOutlet weak var mWeight: UILabel!
    
    @IBOutlet weak var mPieces: UILabel!
    
    @IBOutlet weak var mCertificateType: UILabel!


    @IBOutlet weak var mCertificateNo: UILabel!
    
    @IBOutlet weak var mOpenLink: UIButton!
    
}


class InventoryDetails: UIViewController , UITableViewDelegate, UITableViewDataSource , UICollectionViewDelegate , UICollectionViewDataSource {

    @IBOutlet weak var mImage: UIImageView!
    @IBOutlet weak var mSKuName: UILabel!
    @IBOutlet weak var mMetaTag: UILabel!
    @IBOutlet weak var mLocation: UILabel!
    @IBOutlet weak var mProductStatus: UILabel!
    @IBOutlet weak var mStockId: UILabel!
    
    @IBOutlet weak var mVariantStatus: UIImageView!
    @IBOutlet weak var mCollection: UILabel!
    @IBOutlet weak var mMetal: UILabel!
    @IBOutlet weak var mStone: UILabel!
    @IBOutlet weak var mSize: UILabel!
    
    @IBOutlet weak var mMetalOne: UILabel!
    @IBOutlet weak var mColor: UILabel!
    @IBOutlet weak var mVariantView: UIStackView!
    @IBOutlet weak var mGrossWeight: UILabel!
    @IBOutlet weak var mNetWeight: UILabel!
    
    @IBOutlet weak var mStatusDot: UILabel!
   
    @IBOutlet weak var mStoneTable: UITableView!
   
    @IBOutlet weak var mCurrencyImage: UIImageView!
    @IBOutlet weak var mPrice: UILabel!
    @IBOutlet weak var mSearchField: UITextField!
    var mData =  NSDictionary()
    var mStoneData = NSArray()
    var mAllImageArray = [String]()
    
    
    var mIndex = 0
    
    @IBOutlet weak var mImageViewerStack: UIStackView!
    @IBOutlet weak var mImageViewer: UIView!
    
    @IBOutlet weak var mImageCollecction: UICollectionView!
    @IBOutlet weak var mSKUNameInView: UILabel!
    @IBOutlet weak var mStackView: UIStackView!
    
    @IBOutlet weak var mMainImage: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.mImageViewer.isHidden = true

        mStoneTable.backgroundColor = .clear
        mSKuName.text = "--"
        mMetaTag.text = "--"
        mLocation.text = "--"
        mProductStatus.text = "--"
        mStockId.text = "--"
        mPrice.text = "--"
        
        mCollection.text = "--"
        mMetal.text = "--"
        mStone.text = "--"
        mSize.text = "--"
        
        mMetalOne.text = "--"
        mColor.text = "--"
        mGrossWeight.text = "--"
        mNetWeight.text = "--"
        
        mStackView.layer.cornerRadius = 5
        
        mStackView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        
        mStoneTable.layer.cornerRadius = 5
        mStoneTable.layer.maskedCorners = [ .layerMinXMaxYCorner, .layerMaxXMaxYCorner ]
        
        mMainImage.layer.cornerRadius = 5

        
        if mData != nil {
            
            mSKuName.text = "\(mData.value(forKey: "SKU") ?? "--")"
            mSKUNameInView.text = "\(mData.value(forKey: "SKU") ?? "--")"
            mCurrencyImage.downlaodImageFromUrl(urlString: "\(mData.value(forKey: "currencyFlag") ?? "")")
            mPrice.text = "\(mData.value(forKey: "price") ?? "--")"
            mMetaTag.text = "\(mData.value(forKey: "Matatag") ?? "--")"
            mLocation.text = "\(mData.value(forKey: "location_name") ?? "--")"
            mProductStatus.text = "\(mData.value(forKey: "type") ?? "--")"
            mStockId.text = "\(mData.value(forKey: "stock_id") ?? "--")"
            mSearchField.text = "\(mData.value(forKey: "stock_id") ?? "--")"
            mCollection.text = "\(mData.value(forKey: "Collection_name") ?? "--")"
        

            mMetal.text =  "\(mData.value(forKey: "metal_name") ?? "--")"

            mStone.text = "\(mData.value(forKey: "stoneName") ?? "--")"

            mSize.text = "\(mData.value(forKey: "size_name") ?? "--")"
            mMetalOne.text = "\(mData.value(forKey: "metal_name") ?? "--")"
            mColor.text = "\(mData.value(forKey: "color_name") ?? "--")"
            mGrossWeight.text = "\(mData.value(forKey: "grossWt") ?? "--")"
            mNetWeight.text = "\(mData.value(forKey: "netWt") ?? "--")"
            
            let isVariant = (mData["is_variant"] as? Int)
                         ?? (mData["isVariant"] as? Int)
                         ?? 0

            let isDesign = (mData["is_design"] as? Int)
                        ?? (mData["isDesign"] as? Int)
                        ?? 0

            if isVariant == 1 && isDesign == 1 {
                print("isVariant == 1 && isDesign == 1")
                mVariantStatus.image = UIImage(named: "diamond_ic")
            } else if isVariant == 1 {
                print("isVariant == 1")
                mVariantStatus.image = UIImage(named: "variant")
            } else if isDesign == 1 {
                print("isDesign == 1")
                mVariantStatus.image = UIImage(named: "diamond_ic")
            } else {
                print("nilnilnil")
                mVariantStatus.image = nil
            }
            
            mImage.downlaodImageFromUrl(urlString: "\(mData.value(forKey: "main_image") ?? "--")")
            mVariantStatus.isHidden =  true
            if "\(mData.value(forKey: "variant_status") ?? "")" == "1" {
                mVariantStatus.isHidden =  false
            }
            
            if let type = mData.value(forKey: "type") as? String {
                
                if type == "Master Product" || type == "Low Stock" {
                    self.mProductStatus.textColor =  #colorLiteral(red: 0.4588235294, green: 0.8, blue: 1, alpha: 1)
                    self.mStatusDot.backgroundColor = #colorLiteral(red: 0.4588235294, green: 0.8, blue: 1, alpha: 1)
                    self.mProductStatus.text = "Stock"
                    mTransitAndWareHouse()
                    
                }else if type == "Reserved" {
                    self.mProductStatus.textColor =  #colorLiteral(red: 1, green: 0.7386777401, blue: 0.3924969435, alpha: 1)
                    self.mStatusDot.backgroundColor = #colorLiteral(red: 1, green: 0.7386777401, blue: 0.3924969435, alpha: 1)
                    self.mProductStatus.text = "Reserve"
                    mTransitAndWareHouse()
                    
                }else if type == "Sales Order" {
                    self.mProductStatus.textColor =  #colorLiteral(red: 0.9137254902, green: 0.4392156863, blue: 0.4392156863, alpha: 1)
                    self.mStatusDot.backgroundColor = #colorLiteral(red: 0.9137254902, green: 0.4392156863, blue: 0.4392156863, alpha: 1)
                    self.mProductStatus.text = "Sales Order"
                    mTransitAndWareHouse()
                    
                }else if type == "Repair Order" || type == "Repair Order Inventory" {
                    
                    self.mProductStatus.textColor =  #colorLiteral(red: 0.662745098, green: 0.6078431373, blue: 0.7411764706, alpha: 1)
                    self.mStatusDot.backgroundColor = #colorLiteral(red: 0.662745098, green: 0.6078431373, blue: 0.7411764706, alpha: 1)
                    self.mProductStatus.text = "Repair"
                    mTransitAndWareHouse()
                    
                }else if type == "Out of Stock" {
                    
                    self.mProductStatus.textColor =  #colorLiteral(red: 0.4588235294, green: 0.8, blue: 1, alpha: 1)
                    self.mStatusDot.backgroundColor = #colorLiteral(red: 0.4588235294, green: 0.8, blue: 1, alpha: 1)
                    self.mProductStatus.text = "Out Of Stock"
                }
                
                
            }else{
                
                self.mProductStatus.textColor =  #colorLiteral(red: 0.4588235294, green: 0.8, blue: 1, alpha: 1)
                self.mStatusDot.backgroundColor = #colorLiteral(red: 0.4588235294, green: 0.8, blue: 1, alpha: 1)
                self.mProductStatus.text = "Stock"
            }

            
            if let mStoneArr = mData.value(forKey: "stone_arr") as? NSArray {
                
                if mStoneArr.count > 0 {
                    mStoneData = mStoneArr
                    mStoneTable.delegate =  self
                    mStoneTable.dataSource =  self
                    mStoneTable.reloadData()
                }
            }
            
        }

    }
    
    
    @IBAction func mScanNow(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "invdata", bundle: nil)
        if let home = storyBoard.instantiateViewController(withIdentifier: "SearchInventory") as? SearchInventory {
            home.mType = "Inventory"
            home.mFrom = "1"
            self.navigationController?.pushViewController(home, animated:true)
        }
    }
    
    @IBAction func mHideImageViewer(_ sender: Any) {
    
        self.mImageViewer.isHidden = true
    }
    
    func mTransitAndWareHouse() {
        
        if "\(mData.value(forKey: "stock_transferStartendStatus") ?? "")" == "1" {
            self.mStatusDot.backgroundColor = #colorLiteral(red: 0.3803921569, green: 0.8392156863, blue: 0.8156862745, alpha: 1)
            self.mProductStatus.text = "Transit"
        }else if "\(mData.value(forKey: "warehouse_status") ?? "")" == "1" {
            self.mStatusDot.backgroundColor = #colorLiteral(red: 0.4392156863, green: 0.4392156863, blue: 0.4392156863, alpha: 1)
            self.mProductStatus.text = "Warehouse"
            
        }
    }
    
    @IBAction func mBack(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let home = storyBoard.instantiateViewController(withIdentifier: "HomePage") as? HomePage {
            self.navigationController?.pushViewController(home, animated:true)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mStoneData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false

        if let cells = tableView.dequeueReusableCell(withIdentifier: "InventoryStoneItems") as? InventoryStoneItems {
            if let mData = mStoneData[indexPath.row] as? NSDictionary {
                
                cells.mStone.text = "\(mData.value(forKey: "stone") ?? "--")"
                cells.mShape.text = "\(mData.value(forKey: "shape") ?? "--")"
                cells.mCut.text = "\(mData.value(forKey: "cut") ?? "--")"
                cells.mClarity.text = "\(mData.value(forKey: "clarity") ?? "--")"
                cells.mSize.text = "\(mData.value(forKey: "stone_size") ?? "--")"
                cells.mWeight.text = "\(mData.value(forKey: "weight") ?? "--")"
                cells.mPieces.text = "\(mData.value(forKey: "pcs") ?? "--")"
                
                cells.mCertificateNo.text = "\(mData.value(forKey: "certificate_no") ?? "--")"
                cells.mCertificateType.text = "\(mData.value(forKey: "certificate_type") ?? "--")"
                cells.mOpenLink.tag = indexPath.row
            }
            return cells
        }else {
            return UITableViewCell()
        }
    }
    
    @IBAction func mOpenLinks(_ sender: UIButton) {
        
        if let mLinkData = mStoneData[sender.tag] as? NSDictionary {
        
            if let certificateUrl = mLinkData.value(forKey: "certificate_url") as? String {
                if let url = URL(string: certificateUrl) {
                    UIApplication.shared.open(url)
                }
            }else{
                CommonClass.showSnackBar(message: "No links found!")
            }
        }
    }

    @IBAction func mSearch(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "invdata", bundle: nil)
        if let home = storyBoard.instantiateViewController(withIdentifier: "SearchInventory") as? SearchInventory {
            home.mType = "Inventory"
            home.mFrom = ""
            self.navigationController?.pushViewController(home, animated:true)
        }
    }
    
    @IBAction func mViewImage(_ sender: Any) {
   
        mIndex = 0
        self.mImageViewer.isHidden = false
        if let allImage = mData.value(forKey: "allImage") as? [String] {
            mAllImageArray = allImage
            if mAllImageArray.count > 0 {
                self.mImageCollecction.delegate = self
                self.mImageCollecction.dataSource = self
                self.mImageCollecction.reloadData()
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mAllImageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cells = collectionView.dequeueReusableCell(withReuseIdentifier: "mAllImageCollections",for:indexPath) as? AllImageCollections else {
            return UICollectionViewCell()
        }
        

        if mIndex == indexPath.row {
            self.mMainImage.downlaodImageFromUrl(urlString: "\(mAllImageArray[indexPath.row])")
            
            cells.mView.borderColor = #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)
            cells.mView.borderWidth = 1
        }else{
            cells.mView.borderColor = #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)
            cells.mView.borderWidth = 0
        }
        
        cells.mImage.contentMode = .scaleToFill
        cells.mImage.downlaodImageFromUrl(urlString: "\(mAllImageArray[indexPath.row])")
        
        return cells
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
        
        mIndex  = indexPath.row
        self.mImageCollecction.reloadData()
        
        self.mMainImage.downlaodImageFromUrl(urlString: "\(mAllImageArray[indexPath.row])")
    
        
        if UIDevice.current.userInterfaceIdiom == .pad {

            self.mMainImage.contentMode = .scaleAspectFit

        }else{
            self.mMainImage.contentMode = .scaleToFill

        }
    
    }


    
    
}
