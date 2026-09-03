//
//  CommonCustomerFilters.swift
//  GIS
//
//  Created by Macbook Pro on 29/08/23.
//  Copyright © 2023 Hawkscode. All rights reserved.
//

import UIKit

import Alamofire

class CommonCustomerFilters: UIViewController,  UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout , RangeSeekSliderDelegate, UIViewControllerTransitioningDelegate {
    
    
    
    
    @IBOutlet weak var mItemView: UIView!
    @IBOutlet weak var mCollectionView: UIView!
    @IBOutlet weak var mMetalView: UIView!
    @IBOutlet weak var mLocationView: UIView!
    
    
    @IBOutlet weak var mNameCollectionView: UICollectionView!
    @IBOutlet weak var mCollectCollectionView: UICollectionView!
    @IBOutlet weak var mMetalCollectionView: UICollectionView!
    @IBOutlet weak var mLocationCollectionView: UICollectionView!
    
    
    @IBOutlet weak var mAgeRange: RangeSeekSlider!
    
    
    @IBOutlet weak var mMinPriceText: UITextField!
    
    @IBOutlet weak var mMaxPriceText: UITextField!
    
    var mNameArray = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
    var mNameArrayId = [String]()
    
    
    
    var mCollectionData = [String]()
    var mCollectionId = [String]()
    
    var mMetalsData = [String]()
    var mMetalsId = [String]()
    
    
    var mLocationsData = NSArray()
    var mLocationsId = [String]()
    
    
    var mMinAges = ""
    var mMaxAges = ""
    var mFilterData = NSMutableDictionary()
    var delegate:GetInventoryFiltersDelegate? = nil
    
    
    
    
    @IBOutlet weak var mFilterLABEL: UILabel!
    @IBOutlet weak var mItemLABEL: UILabel!
    @IBOutlet weak var mCollectionLABEL: UILabel!
    @IBOutlet weak var mMetalLABEL: UILabel!
    @IBOutlet weak var mLocationLABEL: UILabel!
    @IBOutlet weak var mPriceLABEL: UILabel!
    
    @IBOutlet weak var mSelectAllItemVutton: UIButton!
    @IBOutlet weak var mSelectAllCollectionButton: UIButton!
    @IBOutlet weak var mSelectAllMetalButton: UIButton!
    @IBOutlet weak var mSelectAllLocationButton: UIButton!
    @IBOutlet weak var mApplyFiltersButton: UIButton!
    @IBOutlet weak var mClearAllButton: UIButton!
    override func viewWillAppear(_ animated: Bool) {
        
        
        
        mFilterLABEL.text = "Filter".localizedString
        mItemLABEL.text = "Name".localizedString
        mCollectionLABEL.text = "Gender".localizedString
        mMetalLABEL.text = "Group".localizedString
        mLocationLABEL.text = "Location".localizedString
        mPriceLABEL.text = "Age".localizedString
        
        mSelectAllItemVutton.setTitle("Select All".localizedString, for: .normal)
        mSelectAllCollectionButton.setTitle("Select All".localizedString, for: .normal)
        mSelectAllMetalButton.setTitle("Select All".localizedString, for: .normal)
        mSelectAllLocationButton.setTitle("Select All".localizedString, for: .normal)
        mApplyFiltersButton.setTitle("Apply Filters".localizedString, for: .normal)
        mClearAllButton.setTitle("Clear All".localizedString, for: .normal)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
        
        mNameCollectionView.delegate = self
        mNameCollectionView.dataSource = self
        mNameCollectionView.reloadData()
        
        mCollectCollectionView.delegate = self
        mCollectCollectionView.dataSource = self
        mCollectCollectionView.reloadData()
        
        
        mMetalCollectionView.delegate = self
        mMetalCollectionView.dataSource = self
        mMetalCollectionView.reloadData()
        
        
        mLocationCollectionView.delegate = self
        mLocationCollectionView.dataSource = self
        mLocationCollectionView.reloadData()
        
        self.mMinPriceText.text = mMinAges
        self.mMaxPriceText.text = mMaxAges
        
        mAgeRange.delegate = self
        mGetFilterData()
        // Do any additional setup after loading the view.
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        var count = 0
        if collectionView == self.mNameCollectionView {
            count = mNameArray.count
            
        }else if collectionView == self.mCollectCollectionView {
            count = mCollectionData.count
            
            
        }else if collectionView == self.mMetalCollectionView {
            count = mMetalsData.count
            
        }else if collectionView == self.mLocationCollectionView {
            count = mLocationsData.count
            
            
        }
        
        return count
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell = UICollectionViewCell()
        if collectionView == self.mNameCollectionView {
            if let cells = collectionView.dequeueReusableCell(withReuseIdentifier: "NameCell", for: indexPath) as? NameCell {
                
                cells.mName.text = self.mNameArray[indexPath.row]
                
                
                if mNameArrayId.contains(self.mNameArray[indexPath.row]) {
                    cells.mName.backgroundColor = #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)
                    cells.backgroundColor =  #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)
                }else{
                    cells.mName.backgroundColor =  #colorLiteral(red: 0.8078431373, green: 0.9333333333, blue: 0.9254901961, alpha: 1)
                    cells.backgroundColor =  #colorLiteral(red: 0.8078431373, green: 0.9333333333, blue: 0.9254901961, alpha: 1)
                }
                
                cells.layoutSubviews()
                cell = cells
            }
            
        }
        else if collectionView == self.mCollectCollectionView {
            if let cells = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as? CollectionCell {
                let mData =  mCollectionData[indexPath.row]
                cells.mCollectionName.text = mCollectionData[indexPath.row]
                if mCollectionId.contains(mData) {
                    cells.mCollectionName.backgroundColor =  #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)
                    cells.backgroundColor =  #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)
                }else{
                    
                    cells.mCollectionName.backgroundColor =  #colorLiteral(red: 0.8078431373, green: 0.9333333333, blue: 0.9254901961, alpha: 1)
                    cells.backgroundColor =  #colorLiteral(red: 0.8078431373, green: 0.9333333333, blue: 0.9254901961, alpha: 1)
                }
                
                cells.layoutSubviews()
                cell = cells
            }
        }else if collectionView == self.mMetalCollectionView {
            if let cells = collectionView.dequeueReusableCell(withReuseIdentifier: "MetalCell", for: indexPath) as? MetalCell {
                let mData =  mMetalsData[indexPath.row]
                
                cells.mMetalName.text = mData
                if mMetalsId.contains(mData) {
                    cells.mMetalName.backgroundColor =  #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)
                    cells.backgroundColor =  #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)
                }else{
                    cells.mMetalName.backgroundColor =  #colorLiteral(red: 0.8078431373, green: 0.9333333333, blue: 0.9254901961, alpha: 1)
                    
                    cells.backgroundColor =  #colorLiteral(red: 0.8078431373, green: 0.9333333333, blue: 0.9254901961, alpha: 1)
                    
                }
                
                cells.layoutSubviews()
                cell = cells
            }
        }else if collectionView == self.mLocationCollectionView {
            if let cells = collectionView.dequeueReusableCell(withReuseIdentifier: "LocationCell", for: indexPath) as? LocationCell {
                if let mData =  mLocationsData[indexPath.row] as? NSDictionary {
                    cells.mLocationName.text = mData.value(forKey: "name") as? String
                    
                    if mLocationsId.contains(mData.value(forKey: "id") as? String ?? "") {
                        cells.mLocationName.backgroundColor =  #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)
                        cells.backgroundColor =  #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)
                        
                    }else{
                        cells.mLocationName.backgroundColor =  #colorLiteral(red: 0.8078431373, green: 0.9333333333, blue: 0.9254901961, alpha: 1)
                        cells.backgroundColor =  #colorLiteral(red: 0.8078431373, green: 0.9333333333, blue: 0.9254901961, alpha: 1)
                        
                    }
                }
                cells.layoutSubviews()
                cell = cells
            }
        }
        
        
        
        return cell
        
        
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        return CGSize(width: view.frame.size.width/2 - 30 , height:50)
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        if collectionView == self.mNameCollectionView {
            
            let mData = mNameArray[indexPath.row]
            if mNameArrayId.contains(mData) {
                mNameArrayId = mNameArrayId.filter {$0 != mData}
                
            }else{
                mNameArrayId.append(mData)
                
            }
            self.mNameCollectionView.reloadData()
            
        }
        
        if collectionView == self.mLocationCollectionView {
            
            if let mData = mLocationsData[indexPath.row] as? NSDictionary {
                if mLocationsId.contains(mData.value(forKey: "id") as? String ?? "") {
                    mLocationsId = mLocationsId.filter {$0 != mData.value(forKey: "id") as? String }
                    
                }else{
                    if let id = mData.value(forKey: "id") as? String {
                        mLocationsId.append(id)
                    }
                }
                self.mLocationCollectionView.reloadData()
            }
        }
        
        if collectionView == self.mMetalCollectionView {
            
            let mData = mMetalsData[indexPath.row]
            if mMetalsId.contains(mData) {
                mMetalsId = mMetalsId.filter {$0 != mData}
                
            }else{
                mMetalsId.append(mData)
                
            }
            self.mMetalCollectionView.reloadData()
            
        }
        
        
        if collectionView == self.mCollectCollectionView {
            
            let mData = mCollectionData[indexPath.row]
            if mCollectionId.contains(mData) {
                mCollectionId = mCollectionId.filter {$0 != mData }
                
            }else{
                mCollectionId.append(mData)
                
            }
            self.mCollectCollectionView.reloadData()
            
        }
        
        
        
        
        
        
    }
    
    
    
    @IBAction func mClearFilters(_ sender: Any) {
        self.mNameArrayId.removeAll()
        self.mCollectionId.removeAll()
        self.mMetalsId.removeAll()
        self.mLocationsId.removeAll()
        self.mCollectCollectionView.reloadData()
        self.mMetalCollectionView.reloadData()
        self.mLocationCollectionView.reloadData()
        
        self.delegate?.mGetInventoryFilterData(itemsId: [], metalId: mMetalsId, collectionId: mCollectionId, stoneId: [], sizeId: [], locationId: mLocationsId, statusId: [] , minPrice: "", maxPrice: "")
        self.dismiss(animated: true, completion: nil)
        
        
        
    }
    
    
    @IBAction func mSelectAllItems(_ sender: UIButton) {
        
        if sender.isSelected {
            sender.isSelected = false
            
            sender.setTitle("Select All".localizedString, for: .normal)
            mNameArrayId.removeAll()
            
            mNameCollectionView.reloadData()
            
        }else{
            
            
            sender.isSelected = true
            mNameArrayId.removeAll()
            
            for i in 0...self.mNameArray.count - 1 {
                let mData = mNameArray[i]
                mNameArrayId.append(mData)
                
            }
            sender.setTitle("Deselect".localizedString, for: .normal)
            mNameCollectionView.reloadData()
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
            
            
            for i in 0...self.mCollectionData.count - 1 {
                let mData = mCollectionData[i]
                mCollectionId.append(mData)
                
            }
            mCollectCollectionView.reloadData()
            
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
            for i in 0...self.mMetalsData.count - 1 {
                let mData = mMetalsData[i]
                mMetalsId.append(mData)
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
            
            for (index, element) in self.mLocationsData
                .enumerated(){
                if let mData = element as? NSDictionary, let id = mData.value(forKey: "id") as? String {
                    mLocationsId.append(id)
                }
            }
            mLocationCollectionView.reloadData()
            
        }
    }
    
    
    func rangeSeekSlider(_ slider: RangeSeekSlider, didChange minValue: CGFloat, maxValue: CGFloat) {
        if slider === mAgeRange {
            self.mMinPriceText.text = "\(Int(minValue))"
            self.mMaxPriceText.text = "\(Int(maxValue))"
            self.mMinAges = "\(Int(minValue))"
            self.mMaxAges = "\(Int(maxValue))"
            
        }
    }
    
    
    
    @IBAction func mApplyFilters(_ sender: Any) {
        
        
        
        self.delegate?.mGetInventoryFilterData(itemsId: mNameArrayId, metalId: mMetalsId, collectionId: mCollectionId, stoneId: [], sizeId: [], locationId: mLocationsId, statusId: [] , minPrice: mMinAges, maxPrice: mMaxAges)
        self.dismiss(animated: true, completion: nil)
        
        
    }
    
    
    
    func mGetFilterData(){
        
        let urlPath =  mGetCustomerFilter
        
        let params = ["": ""]
        
        guard Reachability.isConnectedToNetwork() == true else{
            CommonClass.showSnackBar(message: "No Internet Connection")
            return
        }
            
        CommonClass.showFullLoader(view: self.view)
        AF.request(urlPath, method:.post, parameters:params, headers: sGisHeaders2).responseJSON
        { response in
            
            CommonClass.stopLoader()
            
            if(response.error != nil){
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
                
                if let code = jsonResult.value(forKey: "code") as? Int {
                    if code == 200 {
                        if let mData = jsonResult.value(forKey: "data") as? NSDictionary {
                            
                            if self.mMinPriceText.text?.isEmpty == true {
                                self.mMinPriceText.text = "\(mData.value(forKey: "minAge") ?? "23")"
                            }
                            if self.mMaxPriceText.text?.isEmpty == true{
                                self.mMaxPriceText.text = "\(mData.value(forKey: "maxAge") ?? "53")"
                            }
                            var minAge = mData.value(forKey: "minAge") as? String ?? "23"
                            minAge = (minAge == "null") ? "23" : minAge
                            var maxAge = mData.value(forKey: "maxAge") as? String ?? "53"
                            maxAge = (maxAge == "null") ? "53" : maxAge
                            self.mAgeRange.selectedMinValue = CGFloat(Float("\(minAge)") ?? 23)
                            self.mAgeRange.selectedMaxValue = CGFloat(Float("\(maxAge)") ?? 53)
                            self.mAgeRange.maxValue = CGFloat(Float("\(maxAge)") ?? 53)
                            self.mAgeRange.minValue = CGFloat(Float("\(minAge)") ?? 23)
                            
                            
                            
                            if  let mCollection = mData.value(forKey: "gender") as? [String] {
                                
                                if mCollection.count > 0 {
                                    self.mCollectionData = mCollection
                                    self.mCollectCollectionView.reloadData()
                                }
                            } else {
                                self.mCollectionView.isHidden = false
                            }
                            
                            if  let mMetal = mData.value(forKey: "group") as? [String] {
                                
                                if mMetal.count > 0 {
                                    self.mMetalsData = mMetal
                                    self.mMetalCollectionView.reloadData()
                                }
                                
                            } else {
                                self.mMetalView.isHidden = true
                            }
                            
                            if  let mLocation = mData.value(forKey: "country") as? NSArray {
                                if mLocation.count > 0 {
                                    self.mLocationsData = mLocation
                                    self.mLocationCollectionView.reloadData()
                                }
                            } else {
                                self.mLocationView.isHidden = true
                            }
                            
                        } else {
                            CommonClass.showSnackBar(message: "OOP's something went wrong!")
                            return
                        }
                    } else {
                        if let error = jsonResult.value(forKey: "error") {
                            if "\(error)" == "Authorization has been expired" {
                                CommonClass.sessionExpired(isExpired: true, navigation: self.navigationController)
                            } else {
                                CommonClass.showSnackBar(message: "Error \(code): \(error)")
                            }
                        }
                    }
                }else{
                    CommonClass.showSnackBar(message: "OOP's something went wrong!")
                }
                
            }
            
            
        }
        
        
        
    }
}
