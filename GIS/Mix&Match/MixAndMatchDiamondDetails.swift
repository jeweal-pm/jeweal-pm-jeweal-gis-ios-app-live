//
//  MixAndMatchDiamondDetails.swift
//  GIS
//
//  Created by MacBook Hawkscode  on 16/02/23.
//  Copyright © 2023 Hawkscode. All rights reserved.
//

import UIKit
import Alamofire


protocol GetSelectedDiamondDelegate {
    func mGetPickedDiamond(data:NSDictionary , type:String)
}

class MixAndMatchDiamondDetails: UIViewController , UITableViewDelegate, UITableViewDataSource, UIViewControllerTransitioningDelegate{
    var delegate:GetSelectedDiamondDelegate? = nil
    @IBOutlet weak var mCertificationImage: UIImageView!
    @IBOutlet weak var mPrice: UILabel!
    @IBOutlet weak var mCertificateNumber: UILabel!
    @IBOutlet weak var mCertificateName: UILabel!
    @IBOutlet weak var mDescription: UITextView!
    @IBOutlet weak var mDiamondName: UILabel!
    @IBOutlet weak var mProductImage: UIImageView!
    var mProductId = ""
   
    @IBOutlet weak var mStockId2: UILabel!
    @IBOutlet weak var mStockId: UILabel!
    
    @IBOutlet weak var mShape: UILabel!
    
    @IBOutlet weak var mCarat: UILabel!
    
    @IBOutlet weak var mColor: UILabel!
    
    @IBOutlet weak var mClarity: UILabel!
    
    @IBOutlet weak var mCut: UILabel!
    
    @IBOutlet weak var mPolish: UILabel!
    
    @IBOutlet weak var mMeasurement: UILabel!
    @IBOutlet weak var mSymmetry: UILabel!
    
    @IBOutlet weak var mCulet: UILabel!
    @IBOutlet weak var mFluorescence: UILabel!
    @IBOutlet weak var mDepth: UILabel!
    
    @IBOutlet weak var mGirdle: UILabel!
    @IBOutlet weak var mTable: UILabel!
    
    @IBOutlet weak var mGradedBy: UILabel!
    
    @IBOutlet weak var mCertification: UILabel!
    
 
    @IBOutlet weak var mItemsView: UIStackView!
    @IBOutlet weak var mSelectButton: UIButton!
    @IBOutlet weak var mAddToView: UIView!
    @IBOutlet weak var mBottomView: UIView!
    var mStatus = ""
    var isFirst = ""
    var  mItemTypeData = NSArray()
    
    @IBOutlet weak var mItemTable: UITableView!
    var mProductData = NSDictionary()
    
    @IBOutlet weak var mDiamondDetailsLABEL: UILabel!
    @IBOutlet weak var mHeadingLABEL: UILabel!
    @IBOutlet weak var mStokIdLABEL: UILabel!
    @IBOutlet weak var mShapeLABEL: UILabel!
    @IBOutlet weak var mCaratLABEL: UILabel!
    @IBOutlet weak var mColourLABEL: UILabel!
    @IBOutlet weak var mClarityLABEL: UILabel!
    @IBOutlet weak var mCutLABEL: UILabel!
    @IBOutlet weak var mPolishLABEL: UILabel!
    @IBOutlet weak var mSymmetryLABEL: UILabel!
    @IBOutlet weak var mFluorescenceLABEL: UILabel!
    @IBOutlet weak var mDepthLABEL: UILabel!
    @IBOutlet weak var mTableLABEL: UILabel!
    @IBOutlet weak var mGridleLABEL: UILabel!
    @IBOutlet weak var mCuletLABEL: UILabel!
    @IBOutlet weak var mMeasurementsLABEL: UILabel!
    @IBOutlet weak var mGradedByLABEL: UILabel!
    @IBOutlet weak var mCertificationLABEL: UILabel!
    
    
    @IBOutlet weak var mAddToBUTTON: UIButton!
    @IBOutlet weak var mAddToLABEL: UILabel!
    
    var mAllImages = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")

        mBottomView.layer.cornerRadius = 10
        mBottomView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        mBottomView.dropShadow()
        
        if isFirst == "1" {
            mAddToView.isHidden = false
            mSelectButton.isHidden = true
            mItemsView.layer.cornerRadius = 20
            mItemsView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
     
            mItemTypeData = UserDefaults.standard.object(forKey: "ITEMTYPE") as? NSArray ?? NSArray()
            
        }else{
            mAddToView.isHidden = true
            mSelectButton.isHidden = false
        }
    
    }
    
    @IBAction func mOpenImageViewer(_ sender: Any) {
        
        if !mAllImages.isEmpty {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Test", bundle: nil)
            if let mGlobalImageViewer = storyBoard.instantiateViewController(withIdentifier: "GlobalImageViewer") as? GlobalImageViewer {
                mGlobalImageViewer.modalPresentationStyle = .overFullScreen
                mGlobalImageViewer.mSKUName = self.mDiamondName.text ??  "--"
                mGlobalImageViewer.mAllImages = self.mAllImages
                mGlobalImageViewer.isMixMatch = true
                mGlobalImageViewer.transitioningDelegate = self
                self.present(mGlobalImageViewer,animated: false)
            }
        }
    }
    
    @IBAction func mMinimizeItemView(_ sender: Any) {
    
        mItemsView.slideTop()
        mItemsView.isHidden = true
        
    }
    
    @IBAction func mBack(_ sender: Any) {
        dismiss(animated: false)
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let params:[String: Any] = ["id" : mProductId]
        CommonClass.showFullLoader(view: self.view)
        mGetData(url: mDiamondDetailsAPI,headers: sGisHeaders,  params: params) { response , status in
            CommonClass.stopLoader()
            if status {
            if "\(response.value(forKey: "code") ?? "")" == "200" {
                if let mData = response.value(forKey: "data") as? NSDictionary {
                    
                    self.mProductData = mData
                    if let carat = mData.value(forKey: "Carat") as? String,
                        let shape = mData.value(forKey: "Shape") as? String,
                        let colour = mData.value(forKey: "Colour") as? String,
                        let clarity = mData.value(forKey: "Clarity") as? String {
                        self.mDiamondName.text = "\(carat) Carat, \(shape) - \(colour)/\(clarity)"
                    }
                    if let stockID = mData.value(forKey: "StockID") {
                        self.mStockId2.text = "\(stockID)"
                        self.mStockId.text = "\(stockID)"
                    }
                    if let shape = mData.value(forKey: "Shape") as? String {
                        self.mShape.text = shape
                    }
                    if let carat = mData.value(forKey: "Carat") as? String {
                        self.mCarat.text = carat
                    }
                    if let color = mData.value(forKey: "Colour") as? String {
                        self.mColor.text = color
                    }
                    if let clarity = mData.value(forKey: "Clarity") as? String {
                        self.mClarity.text = clarity
                    }
                    if let cut = mData.value(forKey: "Cut") as? String {
                        self.mCut.text = cut
                    }
                    if let polish = mData.value(forKey: "Polish") as? String {
                        self.mPolish.text = polish
                    }
                    if let symmetry = mData.value(forKey: "Symmetry") as? String {
                        self.mMeasurement.text = symmetry
                        self.mSymmetry.text = symmetry
                    }
                    if let culet = mData.value(forKey: "Culet") as? String {
                        self.mCulet.text = culet
                    }
                    if let fluorescence = mData.value(forKey: "Fluoresence") as? String {
                        self.mFluorescence.text = fluorescence
                    }
                    if let depth = mData.value(forKey: "Depth") as? String {
                        self.mDepth.text = depth
                    }
                    if let girdle = mData.value(forKey: "Gridle") as? String {
                        self.mGirdle.text = girdle
                    }
                    if let table = mData.value(forKey: "Table") {
                        self.mTable.text = "\(table)"
                    }
                    if let gradedBy = mData.value(forKey: "GradedBy") as? String {
                        self.mGradedBy.text = gradedBy
                    }
                    if let certification = mData.value(forKey: "Certification") {
                        self.mCertification.text = "\(certification)"
                    }
                    if let price = mData.value(forKey: "Price") as? String {
                        self.mPrice.text = price
                    }
                    if let certification = mData.value(forKey: "Certification") as? String {
                        self.mCertificateNumber.text = certification
                    }
                    if let gradedBy = mData.value(forKey: "GradedBy") as? String {
                        self.mCertificateName.text = gradedBy
                    }
                    if let status = mData.value(forKey: "Status") {
                        self.mStatus = "\(status)"
                    }
                    
                    if  let mImages = mData.value(forKey: "image") as? [String] {
                        if mImages.count > 0 {
                            self.mAllImages = mImages
                            self.mProductImage.downlaodImageFromUrl(urlString: mImages[0])
                        }

                    }
                    
                    
                    
                    
                }
                
            }else{
          
            }
        }
    }
        
        
        mDiamondDetailsLABEL.text = "Diamond Details".localizedString
        mHeadingLABEL.text = "Diamond".localizedString
        mStokIdLABEL.text = "Stock ID".localizedString
        mShapeLABEL.text = "Shape".localizedString
        mCaratLABEL.text = "Carat".localizedString
        mColourLABEL.text = "Colour".localizedString
        mClarityLABEL.text = "Clarity".localizedString
        mCutLABEL.text = "Cut".localizedString
        mPolishLABEL.text = "Polish".localizedString
        mSymmetryLABEL.text = "Symmetry".localizedString
        mFluorescenceLABEL.text = "Fluorescence".localizedString
        mDepthLABEL.text = "Depth".localizedString
        mTableLABEL.text = "Table".localizedString
        mGridleLABEL.text = "Gridle".localizedString
        mCuletLABEL.text = "Culet".localizedString
        mMeasurementsLABEL.text = "Measurements".localizedString
        mGradedByLABEL.text = "Graded By".localizedString
        mCertificationLABEL.text = "Certification".localizedString
        
        
        mAddToBUTTON.setTitle("Add To".localizedString, for: .normal)
        mSelectButton.setTitle("SELECT".localizedString, for: .normal)
        mAddToLABEL.text = "Add To".localizedString
     
    }
    
    
    
    @IBAction func mAddTo(_ sender: Any) {
    
        mItemsView.isHidden = false
        mItemsView.slideFromBottom()
        self.mItemTable.delegate = self
        self.mItemTable.dataSource = self
        self.mItemTable.reloadData()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mItemTypeData.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false

        if let cell = tableView.dequeueReusableCell(withIdentifier: "LanguageCell") as? LanguageCell {
            
            if let mData = mItemTypeData[indexPath.row] as? NSDictionary {
                cell.mName.text = "\(mData.value(forKey: "name") ?? "")"
                cell.mName.layer.cornerRadius = 0
            }
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        mItemsView.slideTop()
        mItemsView.isHidden = true
        
        if mStatus != "1" {
            CommonClass.showSnackBar(message: "This item is already reserved!");
            return
        }
        if mProductData == nil {
            CommonClass.showSnackBar(message: "Invalid Item");
            return
        }
        dismiss(animated: false)
        
        if let mData = mItemTypeData[indexPath.row] as? NSDictionary {
            delegate?.mGetPickedDiamond(data: mProductData, type: "\(mData.value(forKey: "_id") ?? "")")
        }
    }

    @IBAction func mReserveNow(_ sender: Any) {
        if mStatus != "1" {
            CommonClass.showSnackBar(message: "This item is already reserved!");
            return
        }
        if mProductData == nil {
            CommonClass.showSnackBar(message: "Invalid Item");
            return
        }
        dismiss(animated: false)
        delegate?.mGetPickedDiamond(data: mProductData, type: "")
    
    }
    
}
