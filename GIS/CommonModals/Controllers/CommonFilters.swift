//
//  CommonFilters.swift
//  GIS
//
//  Created by MacBook Hawkscode  on 27/12/22.
//  Copyright © 2022 Hawkscode. All rights reserved.
//

import UIKit
import Alamofire


protocol GetInventoryFiltersDelegate {
    func mGetInventoryFilterData(itemsId : [String], metalId : [String], collectionId : [String],stoneId : [String], sizeId : [String], locationId : [String], statusId : [String] , minPrice : String , maxPrice : String)
}

class CommonFilters: UIViewController,  UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout , RangeSeekSliderDelegate, UIViewControllerTransitioningDelegate {
    
    
    
    
    @IBOutlet weak var mItemView: UIView!
    @IBOutlet weak var mCollectionView: UIView!
    @IBOutlet weak var mMetalView: UIView!
    @IBOutlet weak var mStoneView: UIView!
    @IBOutlet weak var mSizeView: UIView!
    @IBOutlet weak var mLocationView: UIView!
    @IBOutlet weak var mStatusView: UIView!
    @IBOutlet weak var mShapeView: UIView!
    @IBOutlet weak var mPointersView: UIView!
    
    
    @IBOutlet weak var mItemCollectionView: UICollectionView!
    @IBOutlet weak var mCollectCollectionView: UICollectionView!
    @IBOutlet weak var mStoneCollectionView: UICollectionView!
    @IBOutlet weak var mMetalCollectionView: UICollectionView!
    @IBOutlet weak var mLocationCollectionView: UICollectionView!
    
    @IBOutlet weak var mStatusCollectionView: UICollectionView!
    @IBOutlet weak var mSizeCollectionView: UICollectionView!
    
    @IBOutlet weak var mShapeCollectionView: UICollectionView!
    @IBOutlet weak var mPriceRange: RangeSeekSlider!
    
    @IBOutlet weak var mPointersCollectionView: UICollectionView!
    
    @IBOutlet weak var mMinPriceText: UITextField!
    
    @IBOutlet weak var mMaxPriceText: UITextField!
    
    
    var mItemsData = NSArray()
    var mItemsId = [String]()
    
    var mCollectionData = NSArray()
    var mCollectionId = [String]()
    
    var mMetalsData = NSArray()
    var mMetalsId = [String]()
    
    var mStonesData = NSArray()
    var mStonesId = [String]()
    
    var mLocationsData = NSArray()
    var mLocationsId = [String]()
    
    var mSizeData = NSArray()
    var mSizeId = [String]()
    
    var mStatusData = [String]()
    var mStatusId = [String]()
    
    var mMinPrices = ""
    var mMaxPrices = ""
    var mFilterData = NSMutableDictionary()
    var delegate:GetInventoryFiltersDelegate? = nil
    
    
    var mType = ""
    var hideLocation: Bool? = false
    
    
    @IBOutlet weak var mFilterLABEL: UILabel!
    @IBOutlet weak var mItemLABEL: UILabel!
    @IBOutlet weak var mCollectionLABEL: UILabel!
    @IBOutlet weak var mMetalLABEL: UILabel!
    @IBOutlet weak var mStoneLABEL: UILabel!
    @IBOutlet weak var mSizeLABEL: UILabel!
    @IBOutlet weak var mLocationLABEL: UILabel!
    @IBOutlet weak var mStatusLABEL: UILabel!
    @IBOutlet weak var mShapeLABEL: UILabel!
    @IBOutlet weak var mPointersLABEL: UILabel!
    @IBOutlet weak var mPriceLABEL: UILabel!
    
    @IBOutlet weak var mSelectAllItemVutton: UIButton!
    @IBOutlet weak var mSelectAllCollectionButton: UIButton!
    @IBOutlet weak var mSelectAllMetalButton: UIButton!
    @IBOutlet weak var mSelectAllStoneButton: UIButton!
    @IBOutlet weak var mSelectAllSizeButton: UIButton!
    @IBOutlet weak var mSelectAllLocationButton: UIButton!
    @IBOutlet weak var mSelectAllStatusButton: UIButton!
    @IBOutlet weak var mSelectAllShapeButton: UIButton!
    @IBOutlet weak var mSelectAllPointersButton: UIButton!
    @IBOutlet weak var mApplyFiltersButton: UIButton!
    @IBOutlet weak var mClearAllButton: UIButton!
    
    
    @IBOutlet weak var mMinPriceSymbol: UILabel!
    @IBOutlet weak var mMaxPriceSymbol: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        mFilterLABEL.text = "Filter".localizedString
        mItemLABEL.text = "Item".localizedString
        mCollectionLABEL.text = "Collection".localizedString
        mMetalLABEL.text = "Metal".localizedString
        mStoneLABEL.text = "Stone".localizedString
        mSizeLABEL.text = "Size".localizedString
        mLocationLABEL.text = "Location".localizedString
        mStatusLABEL.text = "Status".localizedString
        mShapeLABEL.text = "Shape".localizedString
        mPointersLABEL.text = "Pointer".localizedString
        mPriceLABEL.text = "Price".localizedString
        
        mSelectAllItemVutton.setTitle("Select All".localizedString, for: .normal)
        mSelectAllCollectionButton.setTitle("Select All".localizedString, for: .normal)
        mSelectAllMetalButton.setTitle("Select All".localizedString, for: .normal)
        mSelectAllStoneButton.setTitle("Select All".localizedString, for: .normal)
        mSelectAllSizeButton.setTitle("Select All".localizedString, for: .normal)
        mSelectAllLocationButton.setTitle("Select All".localizedString, for: .normal)
        mSelectAllStatusButton.setTitle("Select All".localizedString, for: .normal)
        mSelectAllShapeButton.setTitle("Select All".localizedString, for: .normal)
        mSelectAllPointersButton.setTitle("Select All".localizedString, for: .normal)
        mApplyFiltersButton.setTitle("Apply Filters".localizedString, for: .normal)
        mClearAllButton.setTitle("Clear All".localizedString, for: .normal)
        
        mMinPriceSymbol.text = "\(UserDefaults.standard.value(forKey: "currencySymbol") ?? "$")"
        mMaxPriceSymbol.text = "\(UserDefaults.standard.value(forKey: "currencySymbol") ?? "$")"
        
        //Hiding shape and pointer view
        mShapeView.isHidden = true
        mPointersView.isHidden = true
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
        
        mItemCollectionView.delegate = self
        mItemCollectionView.dataSource = self
        
        
        mCollectCollectionView.delegate = self
        mCollectCollectionView.dataSource = self
        
        
        mMetalCollectionView.delegate = self
        mMetalCollectionView.dataSource = self
        
        mStoneCollectionView.delegate = self
        mStoneCollectionView.dataSource = self
        
        mSizeCollectionView
            .delegate = self
        mSizeCollectionView.dataSource = self
        
        
        mLocationCollectionView.delegate = self
        mLocationCollectionView.dataSource = self
        
        
        mStatusCollectionView.delegate = self
        mStatusCollectionView.dataSource = self
        
        self.mMinPriceText.text = mMinPrices
        self.mMaxPriceText.text = mMaxPrices
        
        mPriceRange.delegate = self
        mGetFilterData()
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func mMinPriceUpdate(_ sender: UITextField) {
        let minValue = CGFloat(Float("\(sender.text ?? "0")") ?? 0.0)
        if (mPriceRange.minValue...mPriceRange.selectedMaxValue) ~= minValue {
            self.mPriceRange.selectedMinValue = minValue
        }
    }
    
    @IBAction func mMaxPriceUpdate(_ sender: UITextField) {
        let maxValue =  CGFloat(Float("\(sender.text ?? "10000")") ?? 10000.0)
        if (mPriceRange.selectedMinValue...mPriceRange.maxValue) ~= maxValue {
            self.mPriceRange.selectedMaxValue = maxValue
            self.mPriceRange.isSelected = true
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        var count = 0
        if collectionView == self.mItemCollectionView {
            count = mItemsData.count
            
        }else if collectionView == self.mCollectCollectionView {
            count = mCollectionData.count
            
            
        }else if collectionView == self.mMetalCollectionView {
            count = mMetalsData.count
            
        }else if collectionView == self.mStoneCollectionView {
            count = mStonesData.count
            
            
        }else if collectionView == self.mSizeCollectionView {
            count = mSizeData.count
            
            
        }else if collectionView == self.mLocationCollectionView {
            count = mLocationsData.count
            
            
        }else if collectionView == self.mStatusCollectionView {
            count = mStatusData.count
        }
        
        return count
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell = UICollectionViewCell()
        switch collectionView {
        case self.mItemCollectionView :
            if let cells = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath) as? ItemCell ,
               let mData = mItemsData[indexPath.row] as? NSDictionary,
               let name = mData.value(forKey: "name"),
               let id = mData.value(forKey: "_id") as? String {
                
                cells.mItemName.text = "\(name)"
                cells.mItemName.backgroundColor = mItemsId.contains(id) ? #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1) : #colorLiteral(red: 0.8078431373, green: 0.9333333333, blue: 0.9254901961, alpha: 1)
                cells.backgroundColor = mItemsId.contains(id) ? #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1) : #colorLiteral(red: 0.8078431373, green: 0.9333333333, blue: 0.9254901961, alpha: 1)
                
                cells.layoutSubviews()
                cell = cells
            }
            break
        case self.mCollectCollectionView :
            if let cells = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as? CollectionCell {
                if let mData = mCollectionData[indexPath.row] as? NSDictionary ,
                   let name = mData.value(forKey: "name"),
                   let id = mData.value(forKey: "_id") as? String {
                    
                    cells.mCollectionName.text = "\(name)"
                    cells.mCollectionName.backgroundColor = mCollectionId.contains(id) ? #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1) : #colorLiteral(red: 0.8078431373, green: 0.9333333333, blue: 0.9254901961, alpha: 1)
                    cells.backgroundColor = mCollectionId.contains(id) ? #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1) : #colorLiteral(red: 0.8078431373, green: 0.9333333333, blue: 0.9254901961, alpha: 1)
                }
                cells.layoutSubviews()
                cell = cells
            }
            break
        case self.mMetalCollectionView :
            if let cells = collectionView.dequeueReusableCell(withReuseIdentifier: "MetalCell", for: indexPath) as? MetalCell,
               let mData =  mMetalsData[indexPath.row] as? NSDictionary,
               let name = mData.value(forKey: "name"),
               let id = mData.value(forKey: "_id") as? String {
                cells.mMetalName.text = "\(name)"
                
                cells.mMetalName.backgroundColor = mMetalsId.contains(id) ? #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1) : #colorLiteral(red: 0.8078431373, green: 0.9333333333, blue: 0.9254901961, alpha: 1)
                cells.backgroundColor = mMetalsId.contains(id) ? #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1) : #colorLiteral(red: 0.8078431373, green: 0.9333333333, blue: 0.9254901961, alpha: 1)
                
                cells.layoutSubviews()
                cell = cells
            }
            break
        case self.mStatusCollectionView :
            if let cells = collectionView.dequeueReusableCell(withReuseIdentifier: "StatusCell", for: indexPath) as? MetalCell{
                let mData = mStatusData[indexPath.row]
                cells.mMetalName.text = mData.capitalizingFirstLetter()
                
                if mStatusId.contains(mData) {
                    cells.mMetalName.backgroundColor =  #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)
                    cells.backgroundColor =  #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)
                }else{
                    cells.mMetalName.backgroundColor =  #colorLiteral(red: 0.8078431373, green: 0.9333333333, blue: 0.9254901961, alpha: 1)
                    cells.backgroundColor =  #colorLiteral(red: 0.8078431373, green: 0.9333333333, blue: 0.9254901961, alpha: 1)
                }
                
                cells.layoutSubviews()
                cell = cells
            }
            break
        case self.mSizeCollectionView :
            if let cells = collectionView.dequeueReusableCell(withReuseIdentifier: "SizeCell", for: indexPath) as? SizeCell ,
               let mData =  mSizeData[indexPath.row] as? NSDictionary,
               let name = mData.value(forKey: "name"),
               let id = mData.value(forKey: "_id") as? String {
                
                cells.mSizeName.text = "\(name)"
                
                cells.mSizeName.backgroundColor = mSizeId.contains(id) ? #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1) : #colorLiteral(red: 0.8078431373, green: 0.9333333333, blue: 0.9254901961, alpha: 1)
                cells.backgroundColor = mSizeId.contains(id) ? #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1) : #colorLiteral(red: 0.8078431373, green: 0.9333333333, blue: 0.9254901961, alpha: 1)
                
                cells.layoutSubviews()
                cell = cells
            }
            break
        case self.mLocationCollectionView :
            if let cells = collectionView.dequeueReusableCell(withReuseIdentifier: "LocationCell", for: indexPath) as? LocationCell ,
               let mData =  mLocationsData[indexPath.row] as? NSDictionary,
               let name = mData.value(forKey: "name"),
               let id = mData.value(forKey: "_id") as? String {
                
                cells.mLocationName.text = "\(name)"
                
                cells.mLocationName.backgroundColor = mLocationsId.contains(id) ? #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1) : #colorLiteral(red: 0.8078431373, green: 0.9333333333, blue: 0.9254901961, alpha: 1)
                cells.backgroundColor = mLocationsId.contains(id) ? #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1) : #colorLiteral(red: 0.8078431373, green: 0.9333333333, blue: 0.9254901961, alpha: 1)
                
                cells.layoutSubviews()
                cell = cells
            }
            break
        case self.mStoneCollectionView :
            if let cells = collectionView.dequeueReusableCell(withReuseIdentifier: "StoneCell", for: indexPath) as? StoneCell ,
               let mData =  mStonesData[indexPath.row] as? NSDictionary,
               let name = mData.value(forKey: "name"),
               let id = mData.value(forKey: "_id") as? String {
                
                cells.mCStone.text = "\(name)"
                
                cells.mCStone.backgroundColor = mStonesId.contains(id) ? #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1) : #colorLiteral(red: 0.8078431373, green: 0.9333333333, blue: 0.9254901961, alpha: 1)
                cells.backgroundColor = mStonesId.contains(id) ? #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1) : #colorLiteral(red: 0.8078431373, green: 0.9333333333, blue: 0.9254901961, alpha: 1)
                
                cells.layoutSubviews()
                cell = cells
            }
            break
        default:
            break
        }
        
        return cell
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        return CGSize(width: view.frame.size.width/2 - 30 , height:50)
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
        case self.mStoneCollectionView:
            if let mData = mStonesData[indexPath.row] as? NSDictionary,
               let id = mData["_id"] as? String {
                if mStonesId.contains(id) {
                    mStonesId.removeAll { $0 == id }
                } else {
                    mStonesId.append(id)
                }
                self.mStoneCollectionView.reloadData()
            }
            
        case self.mLocationCollectionView:
            if let mData = mLocationsData[indexPath.row] as? NSDictionary,
               let id = mData["_id"] as? String {
                if mLocationsId.contains(id) {
                    mLocationsId.removeAll { $0 == id }
                } else {
                    mLocationsId.append(id)
                }
                self.mLocationCollectionView.reloadData()
            }
            
        case self.mMetalCollectionView:
            if let mData = mMetalsData[indexPath.row] as? NSDictionary,
               let id = mData["_id"] as? String {
                if mMetalsId.contains(id) {
                    mMetalsId.removeAll { $0 == id }
                } else {
                    mMetalsId.append(id)
                }
                self.mMetalCollectionView.reloadData()
            }
            
        case self.mItemCollectionView:
            if let mData = mItemsData[indexPath.row] as? NSDictionary,
               let id = mData["_id"] as? String {
                if mItemsId.contains(id) {
                    mItemsId.removeAll { $0 == id }
                } else {
                    mItemsId.append(id)
                }
                self.mItemCollectionView.reloadData()
            }
            
        case self.mCollectCollectionView:
            if let mData = mCollectionData[indexPath.row] as? NSDictionary,
               let id = mData["_id"] as? String {
                if mCollectionId.contains(id) {
                    mCollectionId.removeAll { $0 == id }
                } else {
                    mCollectionId.append(id)
                }
                self.mCollectCollectionView.reloadData()
            }
            
        case self.mSizeCollectionView:
            if let mData = mSizeData[indexPath.row] as? NSDictionary,
               let id = mData["_id"] as? String {
                if mSizeId.contains(id) {
                    mSizeId.removeAll { $0 == id }
                } else {
                    mSizeId.append(id)
                }
                self.mSizeCollectionView.reloadData()
            }
            
        case self.mStatusCollectionView:
            let mData = mStatusData[indexPath.row]
            if mStatusId.contains(mData) {
                mStatusId.removeAll { $0 == mData }
            } else {
                mStatusId.append(mData)
            }
            self.mStatusCollectionView.reloadData()
            
        default:
            break
        }
    }
    
    
    
    @IBAction func mClearFilters(_ sender: Any) {
        self.mItemsId.removeAll()
        self.mCollectionId.removeAll()
        self.mMetalsId.removeAll()
        self.mStonesId.removeAll()
        self.mSizeId.removeAll()
        self.mStatusId.removeAll()
        self.mLocationsId.removeAll()
        self.mItemCollectionView.reloadData()
        self.mCollectCollectionView.reloadData()
        self.mMetalCollectionView.reloadData()
        self.mStoneCollectionView.reloadData()
        self.mSizeCollectionView.reloadData()
        self.mLocationCollectionView.reloadData()
        self.mStatusCollectionView.reloadData()
        
        self.delegate?.mGetInventoryFilterData(itemsId: mItemsId, metalId: mMetalsId, collectionId: mCollectionId, stoneId: mStonesId, sizeId: mSizeId, locationId: mLocationsId, statusId: mStatusId , minPrice: mMinPrices, maxPrice: mMaxPrices)
        self.dismiss(animated: true, completion: nil)
        
        
        
    }
    
    
    @IBAction func mSelectAllItems(_ sender: UIButton) {
        
        if sender.isSelected {
            sender.isSelected = false
            
            sender.setTitle("Select All".localizedString, for: .normal)
            mItemsId.removeAll()
            
            mItemCollectionView.reloadData()
        }else{
            
            
            sender.isSelected = true
            mItemsId.removeAll()
            
            for item in mItemsData {
                if let mData = item as? NSDictionary ,
                   let itemId = mData.value(forKey: "_id") as? String {
                    mItemsId.append(itemId)
                }
            }

            sender.setTitle("Deselect".localizedString, for: .normal)
            mItemCollectionView.reloadData()
            
        }
    }
    
    @IBAction func mSelectAllCollection(_ sender: UIButton) {
        if sender.isSelected {
            sender.isSelected = false
            
            sender.setTitle("Select All".localizedString, for: .normal)
            mCollectionId.removeAll()
            
            mCollectCollectionView.reloadData()
            
        }else{
            sender.setTitle("Deselect".localizedString, for: .normal)
            sender.isSelected = true
            mCollectionId.removeAll()
            
            for item in mCollectionData {
                if let mData = item as? NSDictionary ,
                   let itemId = mData.value(forKey: "_id") as? String {
                    mCollectionId.append(itemId)
                }
            }
            
            mCollectCollectionView.reloadData()
            
        }
    }
    
    @IBAction func mSelectAllStones(_ sender: UIButton) {
        
        
        if sender.isSelected {
            sender.isSelected = false
            
            sender.setTitle("Select All".localizedString, for: .normal)
            mStonesId.removeAll()
            
            mStoneCollectionView.reloadData()
            
        }else{
            sender.setTitle("Deselect".localizedString, for: .normal)
            sender.isSelected = true
            
            mStonesId.removeAll()
            
            for item in mStonesData {
                if let mData = item as? NSDictionary ,
                   let itemId = mData.value(forKey: "_id") as? String {
                    mStonesId.append(itemId)
                }
            }
            
            mStoneCollectionView.reloadData()
            
        }
    }
    
    @IBAction func mSelectAllMetals(_ sender: UIButton) {
        
        
        if sender.isSelected {
            sender.isSelected = false
            
            sender.setTitle("Select All".localizedString, for: .normal)
            mMetalsId.removeAll()
            
            mMetalCollectionView.reloadData()
            
        }else{
            sender.setTitle("Deselect".localizedString, for: .normal)
            sender.isSelected = true
            mMetalsId.removeAll()
            
            for item in mMetalsData {
                if let mData = item as? NSDictionary ,
                   let itemId = mData.value(forKey: "_id") as? String {
                    mMetalsId.append(itemId)
                }
            }
            
            mMetalCollectionView.reloadData()
        }
    }
    
    @IBAction func mSelectAllLocation(_ sender: UIButton) {
        
        
        if sender.isSelected {
            sender.isSelected = false
            
            sender.setTitle("Select All".localizedString, for: .normal)
            mLocationsId.removeAll()
            
            mLocationCollectionView.reloadData()
            
        }else{
            
            sender.isSelected = true
            sender.setTitle("Deselect".localizedString, for: .normal)
            mLocationsId.removeAll()
            
            for item in mLocationsData {
                if let mData = item as? NSDictionary ,
                   let itemId = mData.value(forKey: "_id") as? String {
                    mLocationsId.append(itemId)
                }
            }
            
            mLocationCollectionView.reloadData()
            
        }
    }
    @IBAction func mSelectAllSize(_ sender: UIButton) {
        
        
        if sender.isSelected {
            sender.isSelected = false
            
            sender.setTitle("Select All".localizedString, for: .normal)
            mSizeId.removeAll()
            
            mSizeCollectionView.reloadData()
            
        }else{
            sender.setTitle("Deselect".localizedString, for: .normal)
            sender.isSelected = true
            mSizeId.removeAll()
            
            for item in mSizeData {
                if let mData = item as? NSDictionary ,
                   let itemId = mData.value(forKey: "_id") as? String {
                    mSizeId.append(itemId)
                }
            }

            mSizeCollectionView.reloadData()
            
        }
    }
    
    @IBAction func mSelectAllStatus(_ sender: UIButton) {
        
        
        if sender.isSelected {
            sender.isSelected = false
            
            sender.setTitle("Select All".localizedString, for: .normal)
            mStatusId.removeAll()
            
            mStatusCollectionView.reloadData()
            
        }else{
            sender.setTitle("Deselect".localizedString, for: .normal)
            sender.isSelected = true
            mStatusId.removeAll()
            
            
            for i in 0...self.mStatusData.count - 1 {
                let mData = mStatusData[i]
                mStatusId.append(mData)
                
            }
            mStatusCollectionView.reloadData()
            
        }
    }
    
    
    @IBAction func mSelectAllShape(_ sender: UIButton) {
        
        
        if sender.isSelected {
            sender.isSelected = false
            
            sender.setTitle("Select All".localizedString, for: .normal)
            mSizeId.removeAll()
            
            mSizeCollectionView.reloadData()
            
        }else{
            sender.setTitle("Deselect".localizedString, for: .normal)
            sender.isSelected = true
            mSizeId.removeAll()
            
            
            for (index, element) in self.mSizeData.enumerated(){
                if let mData = element as? NSDictionary,
                   let id = mData.value(forKey: "_id") as? String {
                    mSizeId.append(id)
                }
            }
            mSizeCollectionView.reloadData()
            
        }
    }
    
    func rangeSeekSlider(_ slider: RangeSeekSlider, didChange minValue: CGFloat, maxValue: CGFloat) {
        if slider === mPriceRange {
            self.mMinPriceText.text = "\(Int(minValue))"
            self.mMaxPriceText.text = "\(Int(maxValue))"
            self.mMinPrices = "\(Int(minValue))"
            self.mMaxPrices = "\(Int(maxValue))"
            
        }
    }
    
    @IBAction func mSelectAllPointers(_ sender: UIButton) {
        
        
        if sender.isSelected {
            sender.isSelected = false
            
            sender.setTitle("Select All".localizedString, for: .normal)
            mSizeId.removeAll()
            
            mSizeCollectionView.reloadData()
            
        }else{
            sender.setTitle("Deselect".localizedString, for: .normal)
            sender.isSelected = true
            mSizeId.removeAll()
            
            
            for (index, element) in self.mSizeData.enumerated() {
                if let mData = element as? NSDictionary,
                   let id = mData.value(forKey: "_id") as? String {
                    mSizeId.append(id)
                }
            }
            mSizeCollectionView.reloadData()
            
        }
    }
    
    
    @IBAction func mApplyFilters(_ sender: Any) {
        
        self.delegate?.mGetInventoryFilterData(itemsId: mItemsId, metalId: mMetalsId, collectionId: mCollectionId, stoneId: mStonesId, sizeId: mSizeId, locationId: mLocationsId, statusId: mStatusId , minPrice: mMinPrices, maxPrice: mMaxPrices)
        self.dismiss(animated: true, completion: nil)
        
        
    }
    
    
    
    func mGetFilterData(){
        
        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
        
        
        let urlPath =  mGetInventoryFilter
        
        let params:[String: Any] = ["type": mType, "hideLocation": hideLocation ?? false]
        
        guard Reachability.isConnectedToNetwork() == true else{
            CommonClass.showSnackBar(message: "No Internet Connection")
            return
        }
        
        CommonClass.showFullLoader(view: self.view)
        AF.request(urlPath, method:.post, parameters:params, headers: sGisHeaders2).responseJSON
        { response in
            
            CommonClass.stopLoader()
            guard response.error == nil else {
                CommonClass.showSnackBar(message: "OOP's something went wrong!")
                return
            }
            
            guard let jsonData = response.data else {
                CommonClass.showSnackBar(message: "OOP's something went wrong!")
                return
            }
            let json = try? JSONSerialization.jsonObject(with: jsonData, options: [])
            
            if let jsonResult = json as? NSDictionary {
                if jsonResult.value(forKey: "code") as? Int == 200 {
                    
                    if let mData = jsonResult.value(forKey: "data") as? NSDictionary {
                        
                        if let mPriceData = mData.value(forKey: "Price") as? NSDictionary {
                            let min = mPriceData.value(forKey: "min") ?? "0"
                            let max = mPriceData.value(forKey: "max") ?? "100000"
                            if self.mMinPriceText.text?.isEmpty == true {
                                self.mMinPriceText.text = "\(min)"
                            }
                            if self.mMaxPriceText.text?.isEmpty == true {
                                self.mMaxPriceText.text = "\(max)"
                            }
                            
                            self.mPriceRange.selectedMinValue = CGFloat(Float("\(min)") ?? 0.0)
                            self.mPriceRange.selectedMaxValue = CGFloat(Float("\(max)") ?? 10000.0)
                            self.mPriceRange.maxValue = CGFloat(Float("\(max)") ?? 10000.0)
                            self.mPriceRange.minValue = CGFloat(Float("\(mPriceData.value(forKey: "min") ?? "1000")") ?? 1000.0)
                        }
                        
                        if let mItems = mData.value(forKey: "item_name") as? NSArray, mItems.count > 0 {
                            let itemsWithID = mItems.compactMap { $0 as? NSDictionary }.filter { $0["_id"] != nil }
                            if !itemsWithID.isEmpty {
                                self.mItemsData = itemsWithID as NSArray
                                self.mItemCollectionView.reloadData()
                            } else {
                                self.mItemView.isHidden = true
                            }
                        } else {
                            self.mItemView.isHidden = true
                        }
                        
                        if let mCollection = mData.value(forKey: "Collection") as? NSArray, mCollection.count > 0 {
                            self.mCollectionData = mCollection
                            self.mCollectCollectionView.reloadData()
                        } else {
                            self.mCollectionView.isHidden = true
                        }
                        
                        if let mMetal = mData.value(forKey: "metal_name") as? NSArray, mMetal.count > 0 {
                            self.mMetalsData = mMetal
                            self.mMetalCollectionView.reloadData()
                        } else {
                            self.mMetalView.isHidden = true
                        }
                        
                        if let mStone = mData.value(forKey: "stone_name") as? NSArray, mStone.count > 0 {
                            self.mStonesData = mStone
                            self.mStoneCollectionView.reloadData()
                        } else {
                            self.mStoneView.isHidden = true
                        }
                        
                        if let mSized = mData.value(forKey: "Size") as? NSArray, mSized.count > 0 {
                            self.mSizeData = mSized
                            self.mSizeCollectionView.reloadData()
                        } else {
                            self.mSizeView.isHidden = true
                        }
                        
                        if let mLocation = mData.value(forKey: "location_name") as? NSArray, mLocation.count > 0 {
                            self.mLocationsData = mLocation
                            self.mLocationCollectionView.reloadData()
                        } else {
                            self.mLocationView.isHidden = true
                        }
                        
                        if let status = mData.value(forKey: "status_type") as? [String], status.count > 0 {
                            self.mStatusData = status
                            self.mStatusCollectionView.reloadData()
                        } else {
                            self.mStatusView.isHidden = true
                        }
                    }
                }else{
                    if let error = jsonResult.value(forKey: "error") as? String {
                        if error == "Authorization has been expired" {
                            CommonClass.sessionExpired(isExpired: true, navigation: self.navigationController)
                        } else {
                            let code = jsonResult.value(forKey: "code") as? Int ?? -1
                            CommonClass.showSnackBar(message: (code == -1) ? "OOP's something went wrong!" : "Error \(code): \(error)")
                        }
                        
                    }
                    
                }
            } else {
                CommonClass.showSnackBar(message: "OOP's something went wrong!")
            }
        }
    }
}
