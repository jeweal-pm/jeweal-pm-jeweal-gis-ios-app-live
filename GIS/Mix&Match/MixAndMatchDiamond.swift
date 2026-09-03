//
//  MixAndMatchDiamond.swift
//  GIS
//
//  Created by MacBook Hawkscode  on 14/02/23.
//  Copyright © 2023 Hawkscode. All rights reserved.
//

import SDWebImageSVGCoder
import SDWebImage
import SVGKit
import Alamofire
import UIKit

protocol GetDiamondData {
    func mGetSelectedDiamond(items:String)
}
class MixAndMatchDiamond: UIViewController , UITableViewDelegate , UITableViewDataSource, RangeSeekSliderDelegate ,  UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout  {
    
    var delegate:GetDiamondData? = nil

    @IBOutlet weak var mHeight: NSLayoutConstraint!
    @IBOutlet weak var mDiamondTable2: UITableView!
    @IBOutlet weak var mDiamondTable: UITableView!
    var mData = NSMutableArray()
    var mDiamondData = NSMutableArray()

    @IBOutlet weak var mCompareLine: UILabel!
    @IBOutlet weak var mResultLine: UILabel!
    @IBOutlet weak var mAdvanceOptionLabel: UILabel!
    @IBOutlet weak var mComparisonLabel: UILabel!
    @IBOutlet weak var mResultLabel: UILabel!
    @IBOutlet weak var mCompareCount: UILabel!
    @IBOutlet weak var mResultsCount: UILabel!
    @IBOutlet weak var mShapeCollection: UICollectionView!
    
    @IBOutlet weak var mPriceRange: RangeSeekSlider!
    @IBOutlet weak var mMinPrice: UITextField!
    
    @IBOutlet weak var mMaxPrice: UITextField!
    
    @IBOutlet weak var mCaratRange: RangeSeekSlider!
   
    @IBOutlet weak var mMinCarat: UITextField!
    
    @IBOutlet weak var mMaxCarat: UITextField!
    
    @IBOutlet weak var mColorCollection: UICollectionView!
    
    @IBOutlet weak var mClarityCollection: UICollectionView!
    
    @IBOutlet weak var mCutCollection: UICollectionView!
    
    @IBOutlet weak var mPolishCollection: UICollectionView!
    
    @IBOutlet weak var mSymmetryCollection: UICollectionView!
    
    @IBOutlet weak var mFluorescenceCollection: UICollectionView!
    
    @IBOutlet weak var mDepthRange: RangeSeekSlider!
    
    @IBOutlet weak var mMinDepth: UITextField!
    
    @IBOutlet weak var mMaxDepth: UITextField!
    
    @IBOutlet weak var mTableRange: RangeSeekSlider!
    
    @IBOutlet weak var mMinTable: UITextField!
    
    @IBOutlet weak var mMaxTable: UITextField!
    
    @IBOutlet weak var mLabCollection: UICollectionView!
    
    @IBOutlet weak var mStatusCollection: UICollectionView!
    
    @IBOutlet weak var mAFilterView: UIStackView!
    
    @IBOutlet weak var mAdvanceFilterView: UIStackView!
    
    var mMinPrices = ""
    var mMaxPrices = ""
    
    var mMinCarats = ""
    var mMaxCarats = ""
    
    var mMinDepths = ""
    var mMaxDepths = ""
    
    var mMinTables = ""
    var mMaxTables = ""
    
    var mShapeData = NSArray()
    var mCutData = NSArray()
    var mClarityData = NSArray()
    var mColorData = NSArray()
    var mPolishData = NSArray()
    var mSymmetryData = NSArray()
    var mFluorescenceData = NSArray()
    var mStatusData = [String]()
    var mLabData = [String]()
    
    var mShapeId = [String]()
    var mCutId = [String]()
    var mClarityId = [String]()
    var mColorId = [String]()
    var mPolishId = [String]()
    var mSymmetryId = [String]()
    var mFluoroscenceId = [String]()
    var mStatusId = [String]()
    var mLabId = [String]()
    
    var mCompareId = [String]()
    var mComparedData = NSMutableArray()
    var mLength = 0

    var mRKey = ""
    @IBOutlet weak var mCompareView: UIView!
    
    @IBOutlet weak var mCompareTable2: UITableView!
    @IBOutlet weak var mCompareTable: UITableView!
    @IBOutlet weak var mCompareHeight: NSLayoutConstraint!
    @IBOutlet weak var mResultsView: UIView!
    @IBOutlet weak var mDropDownImage: UIImageView!
    
    
    @IBOutlet weak var mDiamondSearchLABEL: UILabel!
    @IBOutlet weak var mHeadingLABEL: UILabel!
    @IBOutlet weak var mShapeLABEL: UILabel!
    @IBOutlet weak var mPriceLABEL: UILabel!
    @IBOutlet weak var mCaratLABEL: UILabel!
    @IBOutlet weak var mColorLABEL: UILabel!
    @IBOutlet weak var mPolishLABEL: UILabel!
    @IBOutlet weak var mCutLABEL: UILabel!
    @IBOutlet weak var mSymmetryLABEL: UILabel!
    @IBOutlet weak var mFluorescenceLABEL: UILabel!
    @IBOutlet weak var mDepthLABEL: UILabel!
    @IBOutlet weak var mTableLABEL: UILabel!
    @IBOutlet weak var mLabLABEL: UILabel!
    @IBOutlet weak var mStatusLABEL: UILabel!
    @IBOutlet weak var mShowMoreLABEL: UILabel!
    @IBOutlet weak var mSearchButton: UIButton!
    @IBOutlet weak var mResetButton: UIButton!
    
    @IBOutlet weak var mClarityLABEL: UILabel!
    
    var isLoadingMore = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")

        
        mClarityLABEL.text = "Clarity".localizedString
        mAdvanceOptionLabel.text = "Advance Options".localizedString
        mComparisonLabel.text = "Comparison".localizedString
        mResultLabel.text = "Result".localizedString
        mShowMoreLABEL.text = "Show More".localizedString
        mResetButton.setTitle("Reset".localizedString, for: .normal)
        mSearchButton.setTitle("Search".localizedString, for: .normal)
        mDiamondSearchLABEL.text = "Diamond Search".localizedString
        mHeadingLABEL.text = "Diamond".localizedString
        mShapeLABEL.text = "Shape".localizedString
        mPriceLABEL.text = "Price".localizedString
        mCaratLABEL.text = "Carat".localizedString
        mColorLABEL.text = "Color".localizedString
        mPolishLABEL.text = "Polish".localizedString
        mCutLABEL.text = "Cut".localizedString
        mSymmetryLABEL.text = "Symmetry".localizedString
        mFluorescenceLABEL.text = "Fluorescence".localizedString
        mDepthLABEL.text = "Depth".localizedString
        mTableLABEL.text = "Table".localizedString
        mLabLABEL.text = "Lab".localizedString
        mStatusLABEL.text = "Status".localizedString
       
        mAFilterView.isHidden = true
        
        self.mComparedData = NSMutableArray()
        
        let mFirstPos: NSDictionary = ["false":"false"]
        self.mComparedData.add(mFirstPos)
        
        self.mData = NSMutableArray()
        let mFirstPos1: NSDictionary = ["false":"false"]
        self.mData.add(mFirstPos1)
        
        mPriceRange.delegate = self
        mCaratRange.delegate = self
        mDepthRange.delegate = self
        mTableRange.delegate = self
        mDropDownImage.image = UIImage(named: "down_ic")
    
        mMinPrice.keyboardType = .numberPad
        mMaxPrice.keyboardType = .numberPad
        mMinCarat.keyboardType = .numberPad
        mMaxCarat.keyboardType = .numberPad
        mMinDepth.keyboardType = .numberPad
        mMaxDepth.keyboardType = .numberPad
        mMinTable.keyboardType = .numberPad
        mMaxTable.keyboardType = .numberPad

        self.mShapeCollection.delegate = self
        self.mShapeCollection.dataSource = self
        
        self.mColorCollection.delegate = self
        self.mColorCollection.dataSource = self
        
        self.mClarityCollection.delegate = self
        self.mClarityCollection.dataSource = self
        
        self.mCutCollection.delegate = self
        self.mCutCollection.dataSource = self
        
        self.mPolishCollection.delegate = self
        self.mPolishCollection.dataSource = self
        
        self.mSymmetryCollection.delegate = self
        self.mSymmetryCollection.dataSource = self
        
        self.mFluorescenceCollection.delegate = self
        self.mFluorescenceCollection.dataSource = self
        
        self.mLabCollection.delegate = self
        self.mLabCollection.dataSource = self
        
        self.mStatusCollection.delegate = self
        self.mStatusCollection.dataSource = self
        
//        self.mShowMoreButton.isHidden = true
        
    }
    
    override func viewDidLayoutSubviews() {
   
    }
    
    
    @IBAction func mBack(_ sender: Any) {
        dismiss(animated: false)
    }
    
    @IBAction func mReserveList(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "diamondModule", bundle: nil)
        if let mDiamondProductDetails = storyBoard.instantiateViewController(withIdentifier: "DiamondReservedItems") as? DiamondReservedItems {
            self.navigationController?.pushViewController(mDiamondProductDetails, animated:true)
        }
    }
    
    @IBAction func mCustomer(_ sender: Any) {
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "reserveBoard", bundle: nil)
        if let home = storyBoard.instantiateViewController(withIdentifier: "CustomerSearch") as? CustomerSearch {
            self.navigationController?.pushViewController(home, animated:true)
        }

    }
    @IBOutlet weak var mPreview: UILabel!
    @IBAction func mResetFilters(_ sender: UIButton) {
        sender.showAnimation{
            self.mLength = 0
            self.mGetFilters()
        }
    }
    
    @IBAction func mSearchNow(_ sender: UIButton) {
        sender.showAnimation{
            self.mLength = 0
            CommonClass.showFullLoader(view: self.view)
            self.mGetDiamondList()
        }
    }
    
    @IBAction func mShowHideFilters(_ sender: UIButton) {
    
        sender.isSelected = !sender.isSelected
       
        if sender.isSelected {
            mDropDownImage.image = UIImage(named: "forward_ic")
            mAFilterView.isHidden = true
        }else{
            mAFilterView.isHidden = false
            mDropDownImage.image = UIImage(named: "down_ic")

        }
        
    }
    
    
    @IBAction func mShowAdvanceView(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            mAdvanceFilterView.isHidden = false
            mAdvanceOptionLabel.text = "Less Options".localizedString
        }else{
            mAdvanceFilterView.isHidden = true
            mAdvanceOptionLabel.text = "Advance Options".localizedString
            
        }
        
    }
    
    
    @IBAction func mTapResults(_ sender: Any) {
        
        mRKey = ""
        mResultsView.isHidden = false
        mCompareView.isHidden = true
        mResultLine.backgroundColor = #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)
        mResultLabel.textColor = #colorLiteral(red: 0.1647058824, green: 0.1647058824, blue: 0.1647058824, alpha: 1)
        mResultsCount.textColor = #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)
        self.mDiamondTable.reloadData()
        self.mDiamondTable2.reloadData()
        self.mDiamondTable.layoutIfNeeded()
        self.mHeight.constant = self.mDiamondTable.contentSize.height + 50
        mCompareLine.backgroundColor = #colorLiteral(red: 0.6431372549, green: 0.6431372549, blue: 0.6431372549, alpha: 1)
        mCompareCount.textColor = #colorLiteral(red: 0.6431372549, green: 0.6431372549, blue: 0.6431372549, alpha: 1)
        mComparisonLabel.textColor = #colorLiteral(red: 0.6431372549, green: 0.6431372549, blue: 0.6431372549, alpha: 1)
    }
    
    @IBAction func mTapComparison(_ sender: Any) {
        
        
        if mComparedData.count == 1 || mComparedData == nil {
            return
         }
        
        mRKey = "1"
        mResultsView.isHidden = true
        mCompareView.isHidden = false
        
        mCompareLine.backgroundColor = #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)
        mComparisonLabel.textColor = #colorLiteral(red: 0.1647058824, green: 0.1647058824, blue: 0.1647058824, alpha: 1)
        mCompareCount.textColor = #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)
        
        mResultLine.backgroundColor = #colorLiteral(red: 0.6431372549, green: 0.6431372549, blue: 0.6431372549, alpha: 1)
        mResultsCount.textColor = #colorLiteral(red: 0.6431372549, green: 0.6431372549, blue: 0.6431372549, alpha: 1)
        mResultLabel.textColor = #colorLiteral(red: 0.6431372549, green: 0.6431372549, blue: 0.6431372549, alpha: 1)
        
        self.mCompareTable.delegate = self
        self.mCompareTable.dataSource = self
        self.mCompareTable.reloadData()
        self.mCompareTable.layoutIfNeeded()
        self.mCompareHeight.constant = self.mCompareTable.contentSize.height + 50

        
        self.mCompareTable2.delegate = self
        self.mCompareTable2.dataSource = self
        self.mCompareTable2.reloadData()
   
    }
    
    
    @IBAction func mShowMore(_ sender: Any) {
        
        
        CommonClass.showFullLoader(view: self.view)
        mCompareId = [String]()
        self.mComparedData = NSMutableArray()
        let mFirstPos: NSDictionary = ["false":"false"]
        self.mComparedData.add(mFirstPos)
        self.mCompareCount.text = "\(mComparedData.count - 1)"
        mLength += 20
        mGetDiamondList()
        
    }
    
    @IBAction func mMinPriceEdit(_ sender: UITextField) {
        self.mMinPrices = sender.text ?? "0"
    }
    
    @IBAction func mMaxPriceEdit(_ sender: UITextField) {
        self.mMaxPrices = sender.text ?? "10000"
    }
    
    
    @IBAction func mMinCaratEdit(_ sender: UITextField) {
        self.mMinCarats = sender.text ?? "0"
    }
    
    @IBAction func mMaxCaratEdit(_ sender: UITextField) {
        self.mMaxCarats = sender.text ?? "0"
    }
    
    
    @IBAction func mMinDepthEdit(_ sender: UITextField) {
        self.mMinDepths = sender.text ?? ""
    }
    
    
    @IBAction func mMaxDepthEdit(_ sender: UITextField) {
        self.mMaxDepths = sender.text ?? ""
    }
    
    
    @IBAction func mMinTableEdit(_ sender: UITextField) {
        self.mMinTables = sender.text ?? ""
    }
    
    @IBAction func mMaxTableEdit(_ sender: UITextField) {
        self.mMaxTables = sender.text ?? ""
    }
    

    func rangeSeekSlider(_ slider: RangeSeekSlider, didChange minValue: CGFloat, maxValue: CGFloat) {
        
        if slider == self.mPriceRange {
            self.mMinPrice.text = "\(Int(minValue))"
            self.mMaxPrice.text = "\(Int(maxValue))"
            self.mMinPrices = "\(Int(minValue))"
            self.mMaxPrices = "\(Int(maxValue))"
        }else if slider == self.mCaratRange {
            self.mMinCarat.text = "\(Int(minValue))"
            self.mMaxCarat.text = "\(Int(maxValue))"
            self.mMinCarats = "\(Int(minValue))"
            self.mMaxCarats = "\(Int(maxValue))"
        }else if slider == self.mDepthRange {
            self.mMinDepth.text = "\(Int(minValue))"
            self.mMaxDepth.text = "\(Int(maxValue))"
            self.mMinDepths = "\(Int(minValue))"
            self.mMaxDepths = "\(Int(maxValue))"
        }else if slider == self.mTableRange {
            self.mMinTable.text = "\(Int(minValue))"
            self.mMaxTable.text = "\(Int(maxValue))"
            self.mMinTables = "\(Int(minValue))"
            self.mMaxTables = "\(Int(maxValue))"
        }
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
  
        if collectionView == mShapeCollection {
            return mShapeData.count
        }else if collectionView == mColorCollection{
            return mColorData.count
        }else if collectionView == mClarityCollection{
            return mClarityData.count
        }else if collectionView == mCutCollection{
            return mCutData.count
        }else if collectionView == mPolishCollection{
            return mPolishData.count
        }else if collectionView == mSymmetryCollection{
            return mSymmetryData.count
        }else if collectionView == mFluorescenceCollection{
            return mFluorescenceData.count
        }else if collectionView == mLabCollection{
            return mLabData.count
        }else if collectionView == mStatusCollection{
            return mStatusData.count
        }else{
            return 15

        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
     
        guard let cells = collectionView.dequeueReusableCell(withReuseIdentifier: "FiltersCell", for: indexPath) as? FiltersCell else {
            return UICollectionViewCell()
        }
        
        cells.layer.cornerRadius = 6
        var mData = NSDictionary()
       
        if collectionView == mShapeCollection {
            if let mData = mShapeData[indexPath.row] as? NSDictionary {
                cells.mItemName.text = mData.value(forKey: "name") as? String ?? "--"
                
                
                if let image = mData.value(forKey: "logo") as? String {
                    print("MixAndMatchDiamond urlString",image)
                    cells.mShapeImage.downlaodImageFromUrl(urlString: image)
                }
                
                if let id = mData.value(forKey: "_id") as? String, mShapeId.contains(id) {
                    cells.mItemName.textColor =  UIColor(named: "themeLightText")
                    cells.mShapeView.borderWidth = 1
                }else{
                    cells.mItemName.textColor = .clear
                    cells.mShapeView.borderWidth = 0
                }
            }
            cells.layoutSubviews()
            
            
        }else if collectionView == mColorCollection{
            if let mData = mColorData[indexPath.row] as? NSDictionary {
                cells.mItemName.text = mData.value(forKey: "name") as? String
                if let id = mData.value(forKey: "_id") as? String, mColorId.contains(id) {
                    cells.mItemName.backgroundColor =  #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)
                    cells.backgroundColor =  #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)
                    cells.mItemView.backgroundColor = #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)
                }else{
                    cells.mItemName.backgroundColor =  #colorLiteral(red: 0.8196078431, green: 0.937254902, blue: 0.937254902, alpha: 1)
                    cells.backgroundColor = #colorLiteral(red: 0.8196078431, green: 0.937254902, blue: 0.937254902, alpha: 1)
                    cells.mItemView.backgroundColor = #colorLiteral(red: 0.8196078431, green: 0.937254902, blue: 0.937254902, alpha: 1)
                }
            }
            cells.layoutSubviews()
            
        }else if collectionView == mClarityCollection{
            if let mData = mClarityData[indexPath.row] as? NSDictionary {
                cells.mItemName.text = mData.value(forKey: "name") as? String
                if let id = mData.value(forKey: "_id") as? String, mClarityId.contains(id) {
                    cells.mItemName.backgroundColor =  #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)
                    cells.backgroundColor =  #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)
                    cells.mItemView.backgroundColor = #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)
                }else{
                    cells.mItemName.backgroundColor =  #colorLiteral(red: 0.8196078431, green: 0.937254902, blue: 0.937254902, alpha: 1)
                    cells.backgroundColor = #colorLiteral(red: 0.8196078431, green: 0.937254902, blue: 0.937254902, alpha: 1)
                    cells.mItemView.backgroundColor = #colorLiteral(red: 0.8196078431, green: 0.937254902, blue: 0.937254902, alpha: 1)
                }
            }
            cells.layoutSubviews()

        }else if collectionView == mCutCollection{
            if let mData = mCutData[indexPath.row] as? NSDictionary {
                cells.mItemName.text = mData.value(forKey: "name") as? String
                if let id = mData.value(forKey: "_id") as? String, mCutId.contains(id) {
                    cells.mItemName.backgroundColor =  #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)
                    cells.backgroundColor =  #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)
                    cells.mItemView.backgroundColor = #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)
                }else{
                    cells.mItemName.backgroundColor =  #colorLiteral(red: 0.8196078431, green: 0.937254902, blue: 0.937254902, alpha: 1)
                    cells.backgroundColor = #colorLiteral(red: 0.8196078431, green: 0.937254902, blue: 0.937254902, alpha: 1)
                    cells.mItemView.backgroundColor = #colorLiteral(red: 0.8196078431, green: 0.937254902, blue: 0.937254902, alpha: 1)
                }
            }
            cells.layoutSubviews()

        }else if collectionView == mPolishCollection{
            if let mData = mPolishData[indexPath.row] as? NSDictionary {
                cells.mItemName.text = mData.value(forKey: "name") as? String
                
                if let id = mData.value(forKey: "_id") as? String, mPolishId.contains(id) {
                    cells.mItemName.backgroundColor =  #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)
                    cells.backgroundColor =  #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)
                    cells.mItemView.backgroundColor = #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)
                }else{
                    cells.mItemName.backgroundColor =  #colorLiteral(red: 0.8196078431, green: 0.937254902, blue: 0.937254902, alpha: 1)
                    cells.backgroundColor = #colorLiteral(red: 0.8196078431, green: 0.937254902, blue: 0.937254902, alpha: 1)
                    cells.mItemView.backgroundColor = #colorLiteral(red: 0.8196078431, green: 0.937254902, blue: 0.937254902, alpha: 1)
                }
            }
            cells.layoutSubviews()

        }else if collectionView == mSymmetryCollection{
            if let mData = mSymmetryData[indexPath.row] as? NSDictionary {
                cells.mItemName.text = mData.value(forKey: "name") as? String
                if let id = mData.value(forKey: "_id") as? String, mSymmetryId.contains(id) {
                    cells.mItemName.backgroundColor =  #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)
                    cells.backgroundColor =  #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)
                    cells.mItemView.backgroundColor = #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)
                }else{
                    cells.mItemName.backgroundColor =  #colorLiteral(red: 0.8196078431, green: 0.937254902, blue: 0.937254902, alpha: 1)
                    cells.backgroundColor = #colorLiteral(red: 0.8196078431, green: 0.937254902, blue: 0.937254902, alpha: 1)
                    cells.mItemView.backgroundColor = #colorLiteral(red: 0.8196078431, green: 0.937254902, blue: 0.937254902, alpha: 1)
                }
            }
            cells.layoutSubviews()

        }else if collectionView == mFluorescenceCollection{
            if let mData = mFluorescenceData[indexPath.row] as? NSDictionary {
                cells.mItemName.text = mData.value(forKey: "name") as? String
                if let id = mData.value(forKey: "_id") as? String, mFluoroscenceId.contains(id) {
                    cells.mItemName.backgroundColor =  #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)
                    cells.backgroundColor =  #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)
                    cells.mItemView.backgroundColor = #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)
                }else{
                    cells.mItemName.backgroundColor =  #colorLiteral(red: 0.8196078431, green: 0.937254902, blue: 0.937254902, alpha: 1)
                    cells.backgroundColor = #colorLiteral(red: 0.8196078431, green: 0.937254902, blue: 0.937254902, alpha: 1)
                    cells.mItemView.backgroundColor = #colorLiteral(red: 0.8196078431, green: 0.937254902, blue: 0.937254902, alpha: 1)
                }
            }
            cells.layoutSubviews()

        }else if collectionView == mLabCollection{
            cells.mItemName.text = mLabData[indexPath.row]
            if mLabId.contains(mLabData[indexPath.row] ) {
                cells.mItemName.backgroundColor =  #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)
                cells.backgroundColor =  #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)
                cells.mItemView.backgroundColor = #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)
            }else{
                cells.mItemName.backgroundColor =  #colorLiteral(red: 0.8196078431, green: 0.937254902, blue: 0.937254902, alpha: 1)
                cells.backgroundColor = #colorLiteral(red: 0.8196078431, green: 0.937254902, blue: 0.937254902, alpha: 1)
                cells.mItemView.backgroundColor = #colorLiteral(red: 0.8196078431, green: 0.937254902, blue: 0.937254902, alpha: 1)
            }
            cells.layoutSubviews()

        }else if collectionView == mStatusCollection{
            cells.mItemName.text = mStatusData[indexPath.row]
            if mStatusId.contains(mStatusData[indexPath.row] ) {
                cells.mItemName.backgroundColor =  #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)
                cells.backgroundColor =  #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)
                cells.mItemView.backgroundColor = #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)
            }else{
                cells.mItemName.backgroundColor =  #colorLiteral(red: 0.8196078431, green: 0.937254902, blue: 0.937254902, alpha: 1)
                cells.backgroundColor = #colorLiteral(red: 0.8196078431, green: 0.937254902, blue: 0.937254902, alpha: 1)
                cells.mItemView.backgroundColor = #colorLiteral(red: 0.8196078431, green: 0.937254902, blue: 0.937254902, alpha: 1)
            }
            cells.layoutSubviews()

        }
        return cells

    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        if collectionView == mShapeCollection {
            if let mData = mShapeData[indexPath.row] as? NSDictionary {
                if let id = mData.value(forKey: "_id") as? String {
                    if mShapeId.contains(id) {
                        mShapeId = mShapeId.filter {$0 != id }
                    }else{
                        mShapeId.append(id)
                    }
                }
            }
            self.mShapeCollection.reloadData()
            
        }else if collectionView == mColorCollection{
            if let mData = mColorData[indexPath.row] as? NSDictionary {
                if let id = mData.value(forKey: "_id") as? String {
                    if mColorId.contains(id) {
                        mColorId = mColorId.filter {$0 != id }
                    }else{
                        mColorId.append(id)
                    }
                }
            }
            self.mColorCollection.reloadData()
            
        }else if collectionView == mClarityCollection{
            if let mData = mClarityData[indexPath.row] as? NSDictionary {
                if let id = mData.value(forKey: "_id") as? String {
                    if mClarityId.contains(id) {
                        mClarityId = mClarityId.filter {$0 != id}
                    }else{
                        mClarityId.append(id)
                    }
                }
            }
            self.mClarityCollection.reloadData()
            
        }else if collectionView == mCutCollection{
            if let mData = mCutData[indexPath.row] as? NSDictionary {
                if let id = mData.value(forKey: "_id") as? String {
                    if mCutId.contains(id) {
                        mCutId = mCutId.filter {$0 != id}
                    }else{
                        mCutId.append(id)
                    }
                }
            }
            self.mCutCollection.reloadData()
            
        }else if collectionView == mPolishCollection{
            
            if let mData = mPolishData[indexPath.row] as? NSDictionary {
                if let id = mData.value(forKey: "_id") as? String {
                    if mPolishId.contains(id) {
                        mPolishId = mPolishId.filter {$0 != id }
                    }else{
                        mPolishId.append(id)
                    }
                }
            }
            self.mPolishCollection.reloadData()
            
        }else if collectionView == mSymmetryCollection{
            if let mData = mSymmetryData[indexPath.row] as? NSDictionary {
                if let id = mData.value(forKey: "_id") as? String {
                    if mSymmetryId.contains(id) {
                        mSymmetryId = mSymmetryId.filter {$0 != id }
                    }else{
                        mSymmetryId.append(id)
                    }
                }
            }
            
            self.mSymmetryCollection.reloadData()
        }else if collectionView == mFluorescenceCollection{
            if let mData = mFluorescenceData[indexPath.row] as? NSDictionary {
                if let id = mData.value(forKey: "_id") as? String {
                    if mFluoroscenceId.contains(id) {
                        mFluoroscenceId = mFluoroscenceId.filter {$0 != id }
                    }else{
                        mFluoroscenceId.append(id)
                    }
                }
            }
            self.mFluorescenceCollection.reloadData()
        }else if collectionView == mLabCollection{
            if mLabId.contains(mLabData[indexPath.row] ) {
                mLabId = mLabId.filter {$0 != mLabData[indexPath.row] }
            }else{
                mLabId.append(mLabData[indexPath.row] )
            }
            
            self.mLabCollection.reloadData()
        }else if collectionView == mStatusCollection{
            
            if mStatusId.contains(mStatusData[indexPath.row] ) {
                mStatusId = mStatusId.filter {$0 != mStatusData[indexPath.row] }
            }else{
                mStatusId.append(mStatusData[indexPath.row] )
            }
            self.mStatusCollection.reloadData()
            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if mRKey == "" {
            return mData.count
        }
        return mComparedData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        
        var cell = UITableViewCell()
        
        if mRKey == "" {
            
            if tableView == mDiamondTable {
                guard let cells = tableView.dequeueReusableCell(withIdentifier: "DiamondDataTableCell") as? DiamondDataTableCell else {
                    return cell
                }
                
                if indexPath.row == 0 {
                    cells.mCheckUncheck.isHidden = true
                    cells.mPrice.isHidden = false
                    cells.mPrice.text = "Price".localizedString
                    
                    cells.mPriceView.backgroundColor = UIColor(named: "themeExtraLightText1")
                }else{
                    
                    cells.mCheckButton.tag = indexPath.row
                    cells.mCheckUncheck.isHidden = false
                    
                    cells.mPriceView.backgroundColor = (indexPath.row % 2 == 0) ? #colorLiteral(red: 0.9568627451, green: 0.9568627451, blue: 0.9568627451, alpha: 1) : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
  
                    if let mData = mData[indexPath.row] as? NSDictionary {
                        cells.mPrice.text = "\(mData.value(forKey: "Price") ?? "")"
                        
                        let status = mData.value(forKey: "Status")
                        if status as? Int ?? 0 == 3 {
                            cells.mCheckUncheck.image = UIImage(named: "unchecked_box_ic")
                            cells.mCheckUncheck.alpha = 0.5
                        } else {
                            cells.mCheckUncheck.alpha = 1.0
                            if let id = mData.value(forKey: "_id") as? String,
                               mCompareId.contains(id) {
                                cells.mCheckUncheck.image = UIImage(named: "checked_box_ic")
                            }else{
                                cells.mCheckUncheck.image = UIImage(named: "unchecked_box_ic")
                            }
                        }
                        
                        
                        
//                        if let id = mData.value(forKey: "_id") as? String, mCompareId.contains(id) {
//                            cells.mCheckUncheck.image = UIImage(named: "checked_box_ic")
//                        }else{
//                            cells.mCheckUncheck.image = UIImage(named: "unchecked_box_ic")
//                        }
                    }
                    cells.layoutSubviews()
                }
                
                cell = cells
                
            }else if tableView == mDiamondTable2 {
                
                guard let cell1 = tableView.dequeueReusableCell(withIdentifier: "DiamondDataTableCell2") as? DiamondDataTableCell2,
                      let cell2 = tableView.dequeueReusableCell(withIdentifier: "DiamondDataTableCellHeader") as? DiamondDataTableCellHeader else {
                    return cell
                }
                
                if indexPath.row == 0 {
                    cell2.mStatus.text = "Status".localizedString
                    cell2.mShape.text = "Shape".localizedString
                    cell2.mCarat.text = "Carat".localizedString
                    cell2.mColour.text = "Colour".localizedString
                    cell2.mClarity.text = "Clarity".localizedString
                    cell2.mCut.text = "Cut".localizedString
                    cell2.mPolish.text = "Polish".localizedString
                    cell2.mSymmetry.text = "Symmetry".localizedString
                    cell2.mCertificateNumber.text = "Certificate No.".localizedString
                    cell2.mLocation.text = "Location".localizedString
                    
                    cell = cell2
                }else{
                    
                    cell1.backgroundColor = (indexPath.row % 2 == 0) ? #colorLiteral(red: 0.9568627451, green: 0.9568627451, blue: 0.9568627451, alpha: 1) : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                    cell1.mShapeImage.backgroundColor = (indexPath.row % 2 == 0) ? #colorLiteral(red: 0.9568627451, green: 0.9568627451, blue: 0.9568627451, alpha: 1) : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                    
                    if let mData = mData[indexPath.row] as? NSDictionary {
                        
                        cell1.mShapeButton.isHidden = true
                        cell1.mIndexNumber.text = "\(indexPath.row)"
                        cell1.mShape.text = ""
                        cell1.mShapeImage.downlaodImageFromUrl(urlString: "\(mData.value(forKey: "Shape") ?? "")")
                        cell1.mCarat.text = "\(mData.value(forKey: "Carat") ?? "")"
                        cell1.mColour.text = "\(mData.value(forKey: "Colour") ?? "")"
                        cell1.mClarity.text = "\(mData.value(forKey: "Clarity") ?? "")"
                        cell1.mCut.text = "\(mData.value(forKey: "Cut") ?? "")"
                        cell1.mPolish.text = "\(mData.value(forKey: "Polish") ?? "")"
                        cell1.mSymmetry.text = "\(mData.value(forKey: "Symmetry") ?? "")"
                        
                        if let status = mData.value(forKey: "Status") {
                        
                        if "\(status)" == "1" {
                            cell1.mStatus.backgroundColor = #colorLiteral(red: 0.4588235294, green: 0.8, blue: 1, alpha: 1)
                        }else if "\(status)" == "2" {
                            cell1.mStatus.backgroundColor = #colorLiteral(red: 1, green: 0.7386777401, blue: 0.3924969435, alpha: 1)

                        }else if "\(status)" == "3" {
                            cell1.mStatus.backgroundColor = #colorLiteral(red: 0.9137254902, green: 0.4392156863, blue: 0.4392156863, alpha: 1)

                        }else if "\(status)" == "4" {
                            cell1.mStatus.backgroundColor = #colorLiteral(red: 0.3803921569, green: 0.8392156863, blue: 0.8156862745, alpha: 1)

                        }
                        }
                        
                        cell1.mLocation.text = "\(mData.value(forKey: "Location") ?? "")"
                        cell1.mCertificateNumber.text = "\(mData.value(forKey: "Certification") ?? "")"
                    }
                    cell = cell1
                }
            }
            
        }else{
            
            if tableView == mCompareTable {
                guard let cells = tableView.dequeueReusableCell(withIdentifier: "DiamondDataTableCell") as? DiamondDataTableCell else {
                    return cell
                }
                
                cells.mCheckUncheck.isHidden = true
                
                if indexPath.row == 0 {
                    cells.mPrice.isHidden = false
                    cells.mPrice.text = "Price".localizedString
                    
                    cells.mPriceView.backgroundColor = UIColor(named: "themeExtraLightText1")
                }else{
                    
                    
                    if (indexPath.row % 2 == 0) {
                        cells.mPriceView.backgroundColor = #colorLiteral(red: 0.9568627451, green: 0.9568627451, blue: 0.9568627451, alpha: 1)
                    }else{
                        cells.mPriceView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                    }
                    if let mData = mComparedData[indexPath.row] as? NSDictionary {
                        cells.mPrice.text = "\(mData.value(forKey: "Price") ?? "")"
                    }
                }
                
                cell = cells
                
            }else if tableView == mCompareTable2 {
                
                guard let cell1 = tableView.dequeueReusableCell(withIdentifier: "DiamondDataTableCell2") as? DiamondDataTableCell2,
                      let cell2 = tableView.dequeueReusableCell(withIdentifier: "DiamondDataTableCellHeader") as? DiamondDataTableCellHeader else {
                    return cell
                }
                
                
                if indexPath.row == 0 {
                    cell2.mStatus.text = "Status".localizedString
                    cell2.mShape.text = "Shape".localizedString
                    cell2.mCarat.text = "Carat".localizedString
                    cell2.mColour.text = "Colour".localizedString
                    cell2.mClarity.text = "Clarity".localizedString
                    cell2.mCut.text = "Cut".localizedString
                    cell2.mPolish.text = "Polish".localizedString
                    cell2.mSymmetry.text = "Symmetry".localizedString
                    cell2.mCertificateNumber.text = "Certificate No.".localizedString
                    cell2.mLocation.text = "Location".localizedString
                    
                    cell = cell2
                }else{
                    
                    cell1.backgroundColor = (indexPath.row % 2 == 0) ? #colorLiteral(red: 0.9568627451, green: 0.9568627451, blue: 0.9568627451, alpha: 1) : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                    cell1.mShapeImage.backgroundColor = (indexPath.row % 2 == 0) ? #colorLiteral(red: 0.9568627451, green: 0.9568627451, blue: 0.9568627451, alpha: 1) : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                    
                    if let mData = mComparedData[indexPath.row] as? NSDictionary {
                        
                        cell1.mShapeButton.isHidden = true
                        cell1.mIndexNumber.text = "\(indexPath.row)"
                        cell1.mShape.text = ""
                        cell1.mShapeImage.image = UIImage(named: "diamondImage")
                        cell1.mCarat.text = "\(mData.value(forKey: "Carat") ?? "")"
                        cell1.mColour.text = "\(mData.value(forKey: "Colour") ?? "")"
                        cell1.mClarity.text = "\(mData.value(forKey: "Clarity") ?? "")"
                        cell1.mCut.text = "\(mData.value(forKey: "Cut") ?? "")"
                        cell1.mPolish.text = "\(mData.value(forKey: "Polish") ?? "")"
                        cell1.mSymmetry.text = "\(mData.value(forKey: "Symmetry") ?? "")"
                        cell1.mLocation.text = "\(mData.value(forKey: "Location") ?? "")"
                        cell1.mCertificateNumber.text = "\(mData.value(forKey: "Certification") ?? "")"
                        
//                        if let status = mData.value(forKey: "Status") as? String {
//                            if status == "1" {
//                                cell1.mStatus.backgroundColor = #colorLiteral(red: 0.4588235294, green: 0.8, blue: 1, alpha: 1)
//                            }else if status == "2" {
//                                cell1.mStatus.backgroundColor = #colorLiteral(red: 1, green: 0.7386777401, blue: 0.3924969435, alpha: 1)
//                            }else if status == "3" {
//                                cell1.mStatus.backgroundColor = #colorLiteral(red: 0.9137254902, green: 0.4392156863, blue: 0.4392156863, alpha: 1)
//                            }else if status == "4" {
//                                cell1.mStatus.backgroundColor = #colorLiteral(red: 0.3803921569, green: 0.8392156863, blue: 0.8156862745, alpha: 1)
//                            }
//                        }
                        
                        if let status = mData.value(forKey: "Status") {
                        
                        if "\(status)" == "1" {
                            cell1.mStatus.backgroundColor = #colorLiteral(red: 0.4588235294, green: 0.8, blue: 1, alpha: 1)
                        }else if "\(status)" == "2" {
                            cell1.mStatus.backgroundColor = #colorLiteral(red: 1, green: 0.7386777401, blue: 0.3924969435, alpha: 1)

                        }else if "\(status)" == "3" {
                            cell1.mStatus.backgroundColor = #colorLiteral(red: 0.9137254902, green: 0.4392156863, blue: 0.4392156863, alpha: 1)

                        }else if "\(status)" == "4" {
                            cell1.mStatus.backgroundColor = #colorLiteral(red: 0.3803921569, green: 0.8392156863, blue: 0.8156862745, alpha: 1)

                        }
                        }
                        
                    }
                    cell = cell1
                    
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var mId = ""
        if indexPath.row == 0 {
            return
        }
        
        if let status = (mData[indexPath.row] as? NSDictionary)?.value(forKey: "Status")  {
            if "\(status)" == "3" {
                if let name = (mData[indexPath.row] as? NSDictionary)?.value(forKey: "customer")  {
                    CommonClass.showSnackBar(message: "This item is already reserved for \(name).");
                } else {
                    CommonClass.showSnackBar(message: "This item is already reserved!");
                }
               return
            }
        }
        
        if mRKey == "" {
            if let mData = mData[indexPath.row] as? NSDictionary {
                mId = mData.value(forKey: "_id") as? String ?? ""
            }
        }else{
            if let mData = mComparedData[indexPath.row] as? NSDictionary {
                mId = mData.value(forKey: "_id") as? String ?? ""
            }
        }
        
        dismiss(animated: false)
        delegate?.mGetSelectedDiamond(items: mId)
        
    }

    @IBAction func mClickOnShape(_ sender: Any) {
    }
    
    @IBAction func mCheckDiamond(_ sender: UIButton) {
        
        if let mRowData = mData[sender.tag] as? NSDictionary {
            
            if let id = mRowData.value(forKey: "_id") as? String {
                if mCompareId.contains(id) {
                    mCompareId = mCompareId.filter {$0 != id }
                    mComparedData.remove(mRowData.mutableCopy())
                }else{
                    mCompareId.append(id)
                    mComparedData.add(mRowData.mutableCopy())
                }
            }
        }
        self.mCompareCount.text = "(\(mComparedData.count - 1 ))"
        self.mDiamondTable.reloadData()
         
    }
    
    override func viewWillAppear(_ animated: Bool) {
        mGetFilters()
    }
    
    func mGetFilters(){
        
        self.mResultsCount.text =  "(0)"
        
        CommonClass.showFullLoader(view: self.view)
        
        mGetData(url: mDiamondFiltersAPI,headers: sGisHeaders, params: ["":""]) { response , status in
            if status {
                if "\(response.value(forKey: "code") ?? "")" == "200" {
                    if let mDataItems = response.value(forKey: "data") as? NSDictionary {
                        
                        if let mPriceData = mDataItems.value(forKey: "Price") as? NSDictionary {
                            self.mMinPrice.text = "\(mPriceData.value(forKey: "min") ?? "")"
                            self.mMaxPrice.text = "\(mPriceData.value(forKey: "max") ?? "")"
                            
                            self.mMinPrices = "\(mPriceData.value(forKey: "min") ?? "")"
                            self.mMaxPrices = "\(mPriceData.value(forKey: "max") ?? "")"
                        }
                        
                        self.mPriceRange.minValue = 0.0
                        self.mPriceRange.maxValue = 100000000.0
                        self.mPriceRange.selectedMinValue = self.mMinPrices.toCGFloat() ?? 0.0
                        self.mPriceRange.selectedMaxValue = self.mMaxPrices.toCGFloat() ?? 0.0
                        
                        if let mTableData = mDataItems.value(forKey: "Table") as? NSDictionary {
                            self.mMinTable.text = "\(mTableData.value(forKey: "min") ?? "")"
                            self.mMaxTable.text = "\(mTableData.value(forKey: "max") ?? "")"
                            
                            self.mMinTables = "\(mTableData.value(forKey: "min") ?? "")"
                            self.mMaxTables = "\(mTableData.value(forKey: "max") ?? "")"
                        }
                        
                        self.mTableRange.minValue = self.mMinTables.toCGFloat() ?? 0.0
                        self.mTableRange.maxValue = self.mMaxTables.toCGFloat() ?? 0.0
                        
                        if let mDepthData = mDataItems.value(forKey: "Depth") as? NSDictionary {
                            self.mMinDepth.text = "\(mDepthData.value(forKey: "min") ?? "")"
                            self.mMaxDepth.text = "\(mDepthData.value(forKey: "max") ?? "")"
                            
                            self.mMinDepths = "\(mDepthData.value(forKey: "min") ?? "")"
                            self.mMaxDepths = "\(mDepthData.value(forKey: "max") ?? "")"
                        }
                        
                        self.mDepthRange.minValue = self.mMinDepths.toCGFloat() ?? 0.0
                        self.mDepthRange.maxValue = self.mMaxDepths.toCGFloat() ?? 0.0
                        
                        if let mCaratData = mDataItems.value(forKey: "Carat") as? NSDictionary {
                            self.mMinCarat.text = "\(mCaratData.value(forKey: "min") ?? "")"
                            self.mMaxCarat.text = "\(mCaratData.value(forKey: "max") ?? "")"
                            
                            self.mMinCarats = "\(mCaratData.value(forKey: "min") ?? "")"
                            self.mMaxCarats = "\(mCaratData.value(forKey: "max") ?? "")"
                        }
                        
                        self.mCaratRange.minValue = self.mMinCarats.toCGFloat() ?? 0.0
                        self.mCaratRange.maxValue = self.mMaxCarats.toCGFloat() ?? 0.0
                        
                        if let mItems = mDataItems.value(forKey: "Shape") as? NSArray, mItems.count > 0 {
                            self.mShapeData = mItems
                            print("DEBUG_SHAPE_DATA = \(self.mShapeData)")
                            self.mShapeId = [String]()
                            for i in self.mShapeData {
                                if let mData = i as? NSDictionary,
                                   let id = mData.value(forKey: "_id") as? String {
                                    self.mShapeId.append(id)
                                }
                            }
                            self.mShapeCollection.reloadData()
                        }
                        if let shape = self.mShapeData.firstObject as? NSDictionary {
                            print("DEBUG_FIRST_SHAPE = \(shape)")
                        }
                        if let mItems = mDataItems.value(forKey: "Cut") as? NSArray, mItems.count > 0 {
                            self.mCutData = mItems
                            self.mCutId = [String]()
                            for i in self.mCutData {
                                if let mData = i as? NSDictionary,
                                   let id = mData.value(forKey: "_id") as? String {
                                    self.mCutId.append(id)
                                }
                            }
                            self.mCutCollection.reloadData()
                        }
                        
                        if let mItems = mDataItems.value(forKey: "Clarity") as? NSArray, mItems.count > 0{
                            self.mClarityData = mItems
                            for i in self.mClarityData {
                                if let mData = i as? NSDictionary,
                                   let id = mData.value(forKey: "_id") as? String {
                                    self.mClarityId.append(id)
                                }
                            }
                            self.mClarityCollection.reloadData()
                        }
                        
                        if let mItems = mDataItems.value(forKey: "StoneColor") as? NSArray, mItems.count > 0 {
                            self.mColorData = mItems
                            for i in self.mColorData {
                                if let mData = i as? NSDictionary,
                                   let id = mData.value(forKey: "_id") as? String {
                                    self.mColorId.append(id)
                                }
                            }
                            self.mColorCollection.reloadData()
                        }
                        
                        if let mItems = mDataItems.value(forKey: "Polish") as? NSArray, mItems.count > 0 {
                            self.mPolishData = mItems
                            self.mPolishId = [String]()
                            for i in self.mPolishData {
                                if let mData = i as? NSDictionary,
                                   let id = mData.value(forKey: "_id") as? String {
                                    self.mPolishId.append(id)
                                }
                            }
                            self.mPolishCollection.reloadData()
                        }
                        if let mItems = mDataItems.value(forKey: "Symmetry") as? NSArray, mItems.count > 0 {
                            self.mSymmetryData = mItems
                            
                            self.mSymmetryId = [String]()
                            for i in self.mSymmetryData {
                                if let mData = i as? NSDictionary,
                                   let id = mData.value(forKey: "_id") as? String {
                                    self.mSymmetryId.append(id)
                                }
                            }
                            self.mSymmetryCollection.reloadData()
                        }
                        if let mItems = mDataItems.value(forKey: "Fluorescence") as? NSArray, mItems.count > 0 {
                            self.mFluorescenceData = mItems
                            
                            self.mFluoroscenceId = [String]()
                            for i in self.mFluorescenceData {
                                if let mData = i as? NSDictionary,
                                   let id = mData.value(forKey: "_id") as? String {
                                    self.mFluoroscenceId.append(id)
                                }
                            }
                            self.mFluorescenceCollection.reloadData()
                            
                        }
                        
                        if let mItems = mDataItems.value(forKey: "Status") as? [String], mItems.count > 0 {
                            self.mStatusData = mItems
                            self.mStatusId = mItems
                            self.mStatusCollection.reloadData()
                        }
                        
                        if let mItems = mDataItems.value(forKey: "Lbs") as? [String], mItems.count > 0 {
                            self.mLabData = mItems
                            self.mLabId = mItems
                            self.mLabCollection.reloadData()
                        }
                        
                        self.mGetDiamondList()
                    }
                    
                }else{
                    
                }
            }else{
                CommonClass.stopLoader()
                self.isLoadingMore = false
            }
        }
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        guard scrollView == mDiamondTable2 else { return }

        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height

        if offsetY > contentHeight - frameHeight - 100 {

            if !isLoadingMore {

                isLoadingMore = true

                mCompareId.removeAll()
                mComparedData = NSMutableArray()
                mComparedData.add(["false":"false"])
                mCompareCount.text = "\(mComparedData.count - 1)"

                mLength += 20

                CommonClass.showFullLoader(view: self.view)

                mGetDiamondList()
            }
        }
    }
    
    func mGetDiamondList(){
        
        let mPriceItem = NSMutableDictionary()
            mPriceItem.setValue(Int(mMinPrices) ?? 0, forKey: "min")
            mPriceItem.setValue(Int(mMaxPrices) ?? 0, forKey: "max")
        let mCaratItem = NSMutableDictionary()
            mCaratItem.setValue(Double(mMinCarats) ?? 0.00, forKey: "min")
            mCaratItem.setValue(Double(mMaxCarats) ?? 0.00, forKey: "max")
            
        let mDepthItem =  NSMutableDictionary()
            mDepthItem.setValue(Int(mMinDepths) ?? 0, forKey: "min")
            mDepthItem.setValue(Int(mMaxDepths) ?? 0, forKey: "max")
        let mTableItem = NSMutableDictionary()
        mTableItem.setValue(Int(mMinTables) ?? 0, forKey: "min")
        mTableItem.setValue(Int(mMaxTables) ?? 0, forKey: "max")
        let mPriceData = NSMutableArray()
        let mCaratData = NSMutableArray()
        let mDepthData = NSMutableArray()
        let mTableData = NSMutableArray()
        
        mPriceData.add(mPriceItem)
        mCaratData.add(mCaratItem)
        mDepthData.add(mDepthItem)
        mTableData.add(mTableItem)
        
        let params:[String: Any] = ["length" : mLength,
        "CUT": mCutId,
        "Clarity": mClarityId,
        "Stonecolor":mColorId,
        "Polish":mPolishId,
        "Symmetry":mSymmetryId,
        "fluorescence":mFluoroscenceId,
        "Lbs":mLabId,
        "Shape":mShapeId,
        "Price":mPriceData,
        "Carat":mCaratData,
        "Depth":mDepthData,
        "Table":mTableData]
        
        
        
        
        mGetData(url: mDiamondListAPI ,headers: sGisHeaders,  params:params) { response , status in
            CommonClass.stopLoader()
            self.isLoadingMore = false
            if status {
            if "\(response.value(forKey: "code") ?? "")" == "200" {
                
                
                if let mDataItems = response.value(forKey: "data") as? NSArray {
                    
                    if let count = response.value(forKey: "totalResult") {
                        self.mResultsCount.text =  "(\(count))"
                    }else{
                        self.mResultsCount.text =  "(0)"
                    }
                   
                    if mDataItems.count == 0 {
                        CommonClass.showSnackBar(message: "You have reached maximum limit.")
                        return
                    }
                    
                    if self.mLength == 0 {
                        self.mData = NSMutableArray()
                        let mObj = NSMutableDictionary()
                        self.mData.add(mObj)
                        for i in mDataItems {
                            self.mData.add(i)
                        }
                     }else{
                         for i in mDataItems {
                             self.mData.add(i)
                         }
                    }
                    self.mDiamondTable.delegate = self
                    self.mDiamondTable.dataSource = self
                    self.mDiamondTable.reloadData()
                    self.mDiamondTable.layoutIfNeeded()
                    self.mHeight.constant = self.mDiamondTable.contentSize.height + 50

                    self.mDiamondTable2.delegate = self
                    self.mDiamondTable2.dataSource = self
                    self.mDiamondTable2.reloadData()
                    
                }
                
            }else{
          
            }
        }
    }
    }
    
}
