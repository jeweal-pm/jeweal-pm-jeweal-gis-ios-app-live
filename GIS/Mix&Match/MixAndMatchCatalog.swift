//
//  MixAndMatchCatalog.swift
//  GIS
//
//  Created by MacBook Hawkscode  on 14/02/23.
//  Copyright © 2023 Hawkscode. All rights reserved.
//

import UIKit
import Alamofire
import UIDrawer

protocol GetCatalogData {
    func mGetCatalogItem(data:NSDictionary , type : String)
}

class MixAndMatchCatalog: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout , UITableViewDelegate ,UITableViewDataSource , RangeSeekSliderDelegate, GetCustomerDataDelegate,GetInventoryFiltersDelegate, UIViewControllerTransitioningDelegate {
    var delegate:GetCatalogData? = nil
    
    @IBOutlet weak var mSubFilterView: UIView!
    
    @IBOutlet weak var mApplyFilterView: UIView!
    @IBOutlet weak var mFilterView: UIView!
    

    @IBOutlet weak var mItemCollectionView: UICollectionView!
    @IBOutlet weak var mCollectCollectionView: UICollectionView!
    @IBOutlet weak var mStoneCollectionView: UICollectionView!
    @IBOutlet weak var mMetalCollectionView: UICollectionView!
    @IBOutlet weak var mLocationCollectionView: UICollectionView!
    
    @IBOutlet weak var mSizeCollectionView: UICollectionView!
    
    @IBOutlet weak var mPriceRange: RangeSeekSlider!
    
    @IBOutlet weak var mCustomerImage: UIImageView!
    
    @IBOutlet weak var mMinPrice: UILabel!
    
    @IBOutlet weak var mMaxPrice: UILabel!
    
    var mItemTypeId = ""
    
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
    var mStatusId = [String]()
    
    var mMinPrices = ""
    var mMaxPrices = ""
    var mFilterData = NSMutableDictionary()
    
    
    
    
    
    @IBOutlet weak var mCustomerSearch: UITextField!
    var mCustomerSearchTableView = UITableView()
    @IBOutlet weak var mCustomerSearchView: UIView!
    @IBOutlet weak var mCustomerDetailView: UIView!
    @IBOutlet weak var mCustomerNames: UILabel!
    @IBOutlet weak var mCustomerAddresss: UILabel!
    @IBOutlet weak var mCustomerNumbers: UILabel!
    
    var mSearchCustomerData = NSArray()
    var mSalesManList = [String]()
    var mSalesManIDList = [String]()
    var mCustomerId = ""
    var mSalesPersonId = ""
    
    var mCustomerName = ""
    var mCustomerAddress = ""
    var mCustomerNumber = ""
    
    var mSearchType = "catalog"
    var isWishlist = "0"
    
    @IBOutlet weak var mCheckUncheckCustomer: UIImageView!
    @IBOutlet weak var mBackView: UIView!
    @IBOutlet weak var mCatalogCollectionView: UICollectionView!
    
    @IBOutlet weak var mChooseCutomerButton: UIButton!
    @IBOutlet weak var mSearchField: UITextField!
    
    @IBOutlet weak var mSearchView: UIView!
    
    @IBOutlet weak var mLeftView: UIView!
    @IBOutlet weak var mRightView: UIView!
    var mCount = 1
    @IBOutlet weak var mPageNo: UILabel!
    var mCatalogData = NSMutableArray()
    
    var mKey = ""
    var mScroll = ""
    @IBOutlet weak var mSwitchIcon: UIImageView!
    
    var mSelectedBillingAddress = [String: Any]()
    var mSelectedShippingAddress = [String: Any]()
    
    
    @IBOutlet weak var mCatalogHeaderLABEL: UILabel!
    @IBOutlet weak var mFFilterLABEL: UILabel!
    @IBOutlet weak var mFClearAllBUTTON: UIButton!
    @IBOutlet weak var mFItemLABEL: UILabel!
    @IBOutlet weak var mFISelectAllBUTTON: UIButton!
    @IBOutlet weak var mFCollectionLABEL: UILabel!
    @IBOutlet weak var mFCSelectAllBUTTON: UIButton!
    @IBOutlet weak var mFMetalLABEL: UILabel!
    @IBOutlet weak var mFMSelectAllBUTTON: UIButton!
    @IBOutlet weak var mFStoneLABEL: UILabel!
    @IBOutlet weak var mFSSelectAllBUTTON: UIButton!
    @IBOutlet weak var mFLocationLABEL: UILabel!
    @IBOutlet weak var mFLSelectAllBUTTON: UIButton!
    @IBOutlet weak var mFSizeLABEL: UILabel!
    @IBOutlet weak var mFSZSelectAllBUTTON: UIButton!
    @IBOutlet weak var mFPriceLABEL: UILabel!
    @IBOutlet weak var mFPriceRangeLABEL: UILabel!
    @IBOutlet weak var mFSubmitBUTTON: UIButton!
    
    //SHOWMORE
    private var mSkipCount = 0
    private var mTotalData = 0
    private let mDataFetchLimit = 20
    @IBOutlet weak var mShowMoreButton: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
        
        mSearchField.placeholder = "Search by SKU / Product name".localizedString
        mCatalogHeaderLABEL.text = "Catalog".localizedString
        
        if mKey == "1" {
            mBackView.isHidden = true
        }else{
            mBackView.isHidden = false
            
        }
        
        mSubFilterView.layer.cornerRadius = 20
        mSubFilterView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        
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
        
       // mCatalogCollectionView.delegate = self
       // mCatalogCollectionView.dataSource = self
        
        mShowMoreButton.isHidden = true
        
        mCheckSelectedCustomer()
        mGetCatalogs(key: "")
        
        addDoneButtonOnKeyboard()
    }
    
    func mCheckSelectedCustomer(){
        mCustomerId = UserDefaults.standard.string( forKey: "DEFAULTCUSTOMER") ?? ""
        
        if mCustomerId == "" {
            let storyBoard: UIStoryboard = UIStoryboard(name: "common", bundle: nil)
            if let home = storyBoard.instantiateViewController(withIdentifier: "CustomerPicker") as? CustomerPicker {
                home.delegate = self
                home.modalPresentationStyle = .automatic
                home.transitioningDelegate = self
                self.present(home,animated: true)
            }
        } else {
            self.mCustomerImage.contentMode = .scaleAspectFill
            self.mCheckUncheckCustomer.image = UIImage(named: "selected_customer")
//            self.mCustomerImage.downlaodImageFromUrl(urlString: UserDefaults.standard.string( forKey: "DEFAULTCUSTOMERPICTURE") ?? "")
            self.mCustomerImage.downlaodImageFromUrl(urlString: UserDefaults.standard.string(forKey: "SALESPERSON_IMAGE") ?? "")
        }
    }
    
    
    
    override func viewDidLayoutSubviews() {
        
        
    }
    
    
    
    
    @IBAction func mShowSearchFilters(_ sender: Any) {
        
    }
    
    @IBAction func mShowFilters(_ sender: Any) {
        
        view.endEditing(true)
        let storyBoard: UIStoryboard = UIStoryboard(name: "common", bundle: nil)
        if let mFilters = storyBoard.instantiateViewController(withIdentifier: "CommonFilters") as? CommonFilters {
            mFilters.delegate = self
            mFilters.mType = mSearchType
            mFilters.mItemsId = mItemsId
            mFilters.mMetalsId = mMetalsId
            mFilters.mCollectionId = mCollectionId
            mFilters.mStonesId = mStonesId
            mFilters.mSizeId = mSizeId
//            mFilters.mLocationsId = mStatusId
//            mFilters.mStatusId = mLocationsId
            mFilters.mLocationsId = mLocationsId
            mFilters.mStatusId = mStatusId
            mFilters.mMinPrices = mMinPrices
            mFilters.mMaxPrices = mMaxPrices
            mFilters.modalPresentationStyle = .automatic
            mFilters.transitioningDelegate = self
            self.present(mFilters,animated: true)
        }
    }
    
    func mGetInventoryFilterData(itemsId: [String], metalId: [String], collectionId: [String], stoneId: [String], sizeId: [String], locationId: [String], statusId: [String], minPrice: String, maxPrice: String) {
        
        mItemsId = itemsId
        mMetalsId = metalId
        mCollectionId = collectionId
        mStonesId = stoneId
        mSizeId = sizeId
        mStatusId = statusId
        mLocationsId = locationId
        mMinPrices = minPrice
        mMaxPrices = maxPrice
        
        mSkipCount = 0
        mGetCatalogs(key: "")
    }
    
    
    @IBAction func mSwitchInvCatlog(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        mSkipCount = 0
        
        if sender.isSelected {
            
            self.mMetalsId.removeAll()
            self.mStonesId.removeAll()
            self.mLocationsId.removeAll()
            self.mSizeId.removeAll()
            self.mMetalsData = NSArray()
            self.mStonesData = NSArray()
            self.mLocationsData = NSArray()
            self.mSizeData = NSArray()
            
            mSearchType = "inventory"
            self.mCatalogHeaderLABEL.text = "Inventory".localizedString
            mSwitchIcon.image = UIImage(named: "catstock_ic")
            mGetCatalogs(key: "")
            
        }else{
            mSearchType = "catalog"
            self.mMetalsId.removeAll()
            self.mStonesId.removeAll()
            self.mLocationsId.removeAll()
            self.mSizeId.removeAll()
            self.mMetalsData = NSArray()
            self.mStonesData = NSArray()
            self.mLocationsData = NSArray()
            self.mSizeData = NSArray()
            mSwitchIcon.image = UIImage(named: "catcatlog_ic")
            self.mCatalogHeaderLABEL.text = "Catalog".localizedString
            mGetCatalogs(key: "")
        }
    }
    
    
    @IBAction func mOpenCustomer(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "common", bundle: nil)
        if let home = storyBoard.instantiateViewController(withIdentifier: "CustomerPicker") as? CustomerPicker {
            home.delegate = self
            home.modalPresentationStyle = .automatic
            home.transitioningDelegate = self
            self.present(home,animated: true)
        }
    }
    
    func mOpenCstomerPopup(){
        let storyBoard: UIStoryboard = UIStoryboard(name: "common", bundle: nil)
        if let home = storyBoard.instantiateViewController(withIdentifier: "CustomerPicker") as? CustomerPicker {
            home.delegate = self
            home.modalPresentationStyle = .automatic
            home.transitioningDelegate = self
            self.present(home,animated: true)
        }
    }
    
    func mCreateNewCustomer() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "reserveBoard", bundle: nil)
        if let mCreateCustomer = storyBoard.instantiateViewController(withIdentifier: "CreateCustomer") as? CreateCustomer {
            self.navigationController?.pushViewController(mCreateCustomer, animated:true)
        }
    }
    
    func mGetCustomerData(data: NSMutableDictionary) {
        
        UserDefaults.standard.set(data.value(forKey: "id") as? String ?? "", forKey: "DEFAULTCUSTOMER")
        UserDefaults.standard.set(data.value(forKey: "profile") ?? "", forKey: "DEFAULTCUSTOMERPICTURE")
        UserDefaults.standard.set(data.value(forKey: "name") as? String ?? "", forKey: "DEFAULTCUSTOMERNAME")
        
//        if let image = data.value(forKey: "profile") as? String {
//            self.mCustomerImage.downlaodImageFromUrl(urlString: image)
//        }
        self.mCustomerImage.downlaodImageFromUrl(urlString: UserDefaults.standard.string(forKey: "SALESPERSON_IMAGE") ?? "")
        self.mCustomerId = data.value(forKey: "id") as? String ?? ""
        self.mCheckUncheckCustomer.image = UIImage(named: "selected_customer")
        mSkipCount = 0
        mGetCatalogs(key:"")
        
    }
    
    
    @IBAction func mMinimizeFilters(_ sender: Any) {
        
        
        self.mFilterView.slideTop()
        self.mFilterView.isHidden = true
    }
    @IBAction func mApplyFilter(_ sender: Any) {
        
        mFilterView.isHidden = true
        mSearchView.isHidden = true
        
        mSkipCount = 0
        self.mGetCatalogs(key: mSearchField.text ?? "")
        
    }
    
    
    
    func addDoneButtonOnKeyboard(){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Search", style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        mSearchField.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction(){
        
        mSkipCount = 0
        self.mGetCatalogs(key: mSearchField.text ?? "")
        mSearchField.text = ""
        mSearchField.resignFirstResponder()
    }
    
    @IBAction func mClearFilters(_ sender: Any) {
        self.mItemsId.removeAll()
        self.mCollectionId.removeAll()
        self.mMetalsId.removeAll()
        self.mStonesId.removeAll()
        self.mSizeId.removeAll()
        self.mItemCollectionView.reloadData()
        self.mCollectCollectionView.reloadData()
        self.mMetalCollectionView.reloadData()
        self.mStoneCollectionView.reloadData()
        
        self.mSizeCollectionView.reloadData()
        mSkipCount = 0
        self.mGetCatalogs(key: mSearchField.text ?? "")
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
            
            for element in self.mItemsData {
                if let mData = element as? NSDictionary {
                    mItemsId.append(mData.value(forKey: "id") as? String ?? "")
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
            
            for element in self.mCollectionData {
                if let mData = element as? NSDictionary {
                    mCollectionId.append(mData.value(forKey: "id") as? String ?? "")
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
            sender.setTitle("Deselect", for: .normal)
            sender.isSelected = true
            
            mStonesId.removeAll()
            
            for element in self.mStonesData {
                if let mData = element as? NSDictionary {
                    mStonesId.append(mData.value(forKey: "id") as? String ?? "")
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
            sender.setTitle("Deselect", for: .normal)
            sender.isSelected = true
            mMetalsId.removeAll()
            
            
            for element in self.mMetalsData {
                if let mData = element as? NSDictionary {
                    mMetalsId.append(mData.value(forKey: "id") as? String ?? "")
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
            
            
            for element in self.mLocationsData {
                if let mData = element as? NSDictionary {
                    mLocationsId.append(mData.value(forKey: "id") as? String ?? "")
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
            
            
            for element in self.mSizeData {
                if let mData = element as? NSDictionary {
                    mSizeId.append(mData.value(forKey: "id") as? String ?? "")
                }
            }
            mSizeCollectionView.reloadData()
            
        }
    }
    
    func rangeSeekSlider(_ slider: RangeSeekSlider, didChange minValue: CGFloat, maxValue: CGFloat) {
        if slider === mPriceRange {
            
            self.mMinPrice.text = "\(Int(minValue))"
            self.mMaxPrice.text = "\(Int(maxValue))"
            self.mMinPrices = "\(Int(minValue))"
            self.mMaxPrices = "\(Int(maxValue))"
            
        }
    }
    
    @IBAction func mBack(_ sender: Any) {
        
        self.dismiss(animated: false)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func mGoToWishList(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "catalog", bundle: nil)
        if let mWishList = storyBoard.instantiateViewController(withIdentifier: "WishlistSearchNew") as? WishlistSearch {
            self.navigationController?.pushViewController(mWishList, animated:true)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mSearchCustomerData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        
        var cell =  UITableViewCell()
        
        if tableView == mCustomerSearchTableView {
            
            guard let cells = tableView.dequeueReusableCell(withIdentifier: "CustomerSearchItem") as? CustomerSearchItem else {
                return cell
            }
            
            if let mData =  mSearchCustomerData[indexPath.row] as? NSDictionary {
                
                if let fname = mData.value(forKey: "fname") as? String {
                    cells.mCustomerName.text = fname
                }
                
                if let lname = mData.value(forKey: "lname") as? String {
                    cells.mCustomerName.text?.append(" \(lname)")
                }
                
                if let phoneCode = mData.value(forKey: "phone_code") {
                    cells.mPhone.text = "\(phoneCode)"
                }
                
                if let phone = mData.value(forKey: "phone") {
                    cells.mPhone.text?.append(" \(phone)")
                }
                
                if let stateCountry = mData.value(forKey: "stateCountry") {
                    cells.mPlace.text = (" \(stateCountry)")
                }
            }
            cell = cells
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 78
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        var count = 0
        if collectionView == self.mItemCollectionView {
            count = mItemsData.count
            
        }else if collectionView == self.mCollectCollectionView {
            count = mCollectionData.count
            
            
            
        }else if collectionView == self.mMetalCollectionView {
            count = mMetalsData.count
            
        }else if collectionView == self.mCatalogCollectionView {
            count = mCatalogData.count
            if count == 0 {
                collectionView.setError("No items available!")
            }else{
                collectionView.clearBackground()
            }
            
        }else if collectionView == self.mStoneCollectionView {
            count = mStonesData.count
            
            
        }else if collectionView == self.mSizeCollectionView {
            count = mSizeData.count
            
            
        }
        
        return count
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell = UICollectionViewCell()
        if collectionView == self.mItemCollectionView {
            if let cells = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath) as? ItemCell {
                if let mData = mItemsData[indexPath.row] as? NSDictionary {
                    cells.mItemName.text = mData.value(forKey: "name") as? String
                    if let id = mData.value(forKey: "id") as? String, mItemsId.contains(id) {
                        cells.mItemName.backgroundColor =  #colorLiteral(red: 0.7725490196, green: 0.6666666667, blue: 0.5058823529, alpha: 1)
                        cells.backgroundColor =  #colorLiteral(red: 0.7725490196, green: 0.6666666667, blue: 0.5058823529, alpha: 1)
                    }else{
                        cells.mItemName.backgroundColor =  #colorLiteral(red: 0.9450980392, green: 0.9058823529, blue: 0.8509803922, alpha: 1)
                        cells.backgroundColor =  #colorLiteral(red: 0.9450980392, green: 0.9058823529, blue: 0.8509803922, alpha: 1)
                    }
                }
                cells.layoutSubviews()
                cell = cells
            }
        }else if collectionView == self.mCollectCollectionView {
            if let cells = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as? CollectionCell {
                if let mData = mCollectionData[indexPath.row] as? NSDictionary {
                    cells.mCollectionName.text = mData.value(forKey: "name") as? String
                    if let id = mData.value(forKey: "id") as? String, mCollectionId.contains(id) {
                        cells.mCollectionName.backgroundColor =  #colorLiteral(red: 0.7725490196, green: 0.6666666667, blue: 0.5058823529, alpha: 1)
                        cells.backgroundColor =  #colorLiteral(red: 0.7725490196, green: 0.6666666667, blue: 0.5058823529, alpha: 1)
                    }else{
                        cells.mCollectionName.backgroundColor =  #colorLiteral(red: 0.9450980392, green: 0.9058823529, blue: 0.8509803922, alpha: 1)
                        cells.backgroundColor =  #colorLiteral(red: 0.9450980392, green: 0.9058823529, blue: 0.8509803922, alpha: 1)
                    }
                }
                cells.layoutSubviews()
                cell = cells
            }
        }else if collectionView == self.mMetalCollectionView {
            if let cells = collectionView.dequeueReusableCell(withReuseIdentifier: "MetalCell", for: indexPath) as? MetalCell {
                if let mData =  mMetalsData[indexPath.row] as? NSDictionary {
                    cells.mMetalName.text = mData.value(forKey: "name") as? String
                    if let id = mData.value(forKey: "id") as? String, mMetalsId.contains(id) {
                        cells.mMetalName.backgroundColor =  #colorLiteral(red: 0.7725490196, green: 0.6666666667, blue: 0.5058823529, alpha: 1)
                        cells.backgroundColor =  #colorLiteral(red: 0.7725490196, green: 0.6666666667, blue: 0.5058823529, alpha: 1)
                    }else{
                        cells.mMetalName.backgroundColor =  #colorLiteral(red: 0.9450980392, green: 0.9058823529, blue: 0.8509803922, alpha: 1)
                        cells.backgroundColor =  #colorLiteral(red: 0.9450980392, green: 0.9058823529, blue: 0.8509803922, alpha: 1)
                    }
                }
                cells.layoutSubviews()
                cell = cells
            }
        }else if collectionView == self.mSizeCollectionView {
            if let cells = collectionView.dequeueReusableCell(withReuseIdentifier: "SizeCell", for: indexPath) as? SizeCell {
                if let mData =  mSizeData[indexPath.row] as? NSDictionary {
                    cells.mSizeName.text = mData.value(forKey: "name") as? String
                    if let id = mData.value(forKey: "id") as? String, mSizeId.contains(id) {
                        cells.mSizeName.backgroundColor = #colorLiteral(red: 0.7725490196, green: 0.6666666667, blue: 0.5058823529, alpha: 1)
                        cells.backgroundColor = #colorLiteral(red: 0.7725490196, green: 0.6666666667, blue: 0.5058823529, alpha: 1)
                    }else{
                        cells.mSizeName.backgroundColor =  #colorLiteral(red: 0.9450980392, green: 0.9058823529, blue: 0.8509803922, alpha: 1)
                        cells.backgroundColor =  #colorLiteral(red: 0.9450980392, green: 0.9058823529, blue: 0.8509803922, alpha: 1)
                    }
                }
                cells.layoutSubviews()
                cell = cells
            }
        }else if collectionView == self.mStoneCollectionView {
            if let cells = collectionView.dequeueReusableCell(withReuseIdentifier: "StoneCell", for: indexPath) as? StoneCell {
                if let mData =  mStonesData[indexPath.row] as? NSDictionary {
                    cells.mCStone.text = mData.value(forKey: "name") as? String
                    if let id = mData.value(forKey: "id") as? String, mStonesId.contains(id) {
                        cells.mCStone.backgroundColor =  #colorLiteral(red: 0.7725490196, green: 0.6666666667, blue: 0.5058823529, alpha: 1)
                        cells.backgroundColor =  #colorLiteral(red: 0.7725490196, green: 0.6666666667, blue: 0.5058823529, alpha: 1)
                    }else{
                        cells.mCStone.backgroundColor =  #colorLiteral(red: 0.9450980392, green: 0.9058823529, blue: 0.8509803922, alpha: 1)
                        cells.backgroundColor =  #colorLiteral(red: 0.9450980392, green: 0.9058823529, blue: 0.8509803922, alpha: 1)
                    }
                    
                    cells.layoutSubviews()
                    cell = cells
                }
            }
        }else if collectionView == self.mCatalogCollectionView {
            guard let cells = collectionView.dequeueReusableCell(withReuseIdentifier: "CatalogCell",for:indexPath) as? CatalogCell else {
                return cell
            }
            
            if let mData = mCatalogData[indexPath.row] as? NSDictionary {
                
                cells.mHeart.isHidden = true
                
                cells.mStatusDot.isHidden = mSearchType == "catalog"
                
                if let status = mData.value(forKey: "status_type") as? String {
                    switch status {
                    case "transit" :
                        cells.mStatusDot.backgroundColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
                    case "warehouse" :
                        cells.mStatusDot.backgroundColor = #colorLiteral(red: 0.4392156863, green: 0.4392156863, blue: 0.4392156863, alpha: 1)
                    case "reserve" :
                        cells.mStatusDot.backgroundColor = #colorLiteral(red: 1, green: 0.7386777401, blue: 0.3924969435, alpha: 1)
                    case "repair_order" :
                        cells.mStatusDot.backgroundColor = #colorLiteral(red: 0.662745098, green: 0.6078431373, blue: 0.7411764706, alpha: 1)
                    case "custom_order" :
                        cells.mStatusDot.backgroundColor = #colorLiteral(red: 0.9137254902, green: 0.4392156863, blue: 0.4392156863, alpha: 1)
                    case "stock" :
                        cells.mStatusDot.backgroundColor = #colorLiteral(red: 0.4588235294, green: 0.8, blue: 1, alpha: 1)
                    default :
                        cells.mStatusDot.backgroundColor = #colorLiteral(red: 0.4588235294, green: 0.8, blue: 1, alpha: 1)
                    }
                }else {
                    cells.mStatusDot.isHidden = true
                }
                
                let skuAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 14, weight: .regular),
                    .foregroundColor: UIColor(named: "themeColor") ?? UIColor.black ]
                let nameAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 14, weight: .regular),
                    .foregroundColor: #colorLiteral(red: 0.3181298765, green: 0.3326592986, blue: 0.328506533, alpha: 1) ]
                
                let finalName = NSMutableAttributedString()
                finalName.append(NSAttributedString(string: "\(mData.value(forKey: "name")  as? String ?? "") \n", attributes: nameAttributes))
                finalName.append(NSAttributedString(string: "\(mData.value(forKey: "SKU")  as? String ?? "")", attributes: skuAttributes))
                
                cells.mProductName.attributedText = finalName
                cells.mProductLikeButt.tag = indexPath.row
                cells.mPrice.text = "\(mData.value(forKey: "price") ?? "0.00")"
                if let image = mData.value(forKey: "main_image") as? String {
                    cells.mProductImage.downlaodImageFromUrl(urlString: image)
                }
            }
            
            cell = cells
        }
        
        return cell
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == mCatalogCollectionView {
            
            let layout = collectionViewLayout as? UICollectionViewFlowLayout
            if UIDevice.current.userInterfaceIdiom == .pad {
                return CGSize(width: mCatalogCollectionView.bounds.width/3 , height: 350)
            }else{
                layout?.minimumInteritemSpacing = 0
                return CGSize(width: mCatalogCollectionView.bounds.width/2  , height: 350)
            }
            
        }
        
        return CGSize(width: view.frame.size.width/2 - 30 , height:50)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == self.mStoneCollectionView {
            if let mData = mStonesData[indexPath.row] as? NSDictionary {
                if let id = mData.value(forKey: "id") as? String {
                    if mStonesId.contains(id) {
                        mStonesId = mStonesId.filter {$0 != id }
                    }else{
                        mStonesId.append(id)
                    }
                }
            }
            self.mStoneCollectionView.reloadData()
        }
        
        if collectionView == self.mLocationCollectionView {
            if let mData = mLocationsData[indexPath.row] as? NSDictionary {
                if let id = mData.value(forKey: "id") as? String {
                    if mLocationsId.contains(id) {
                        mLocationsId = mLocationsId.filter {$0 != id }
                    }else{
                        mLocationsId.append(id)
                    }
                }
            }
            self.mLocationCollectionView.reloadData()
        }
        
        if collectionView == self.mMetalCollectionView {
            if let mData = mMetalsData[indexPath.row] as? NSDictionary {
                if let id = mData.value(forKey: "id") as? String {
                    if mMetalsId.contains(id) {
                        mMetalsId = mMetalsId.filter {$0 != id }
                    }else{
                        mMetalsId.append(id)
                    }
                }
            }
            self.mMetalCollectionView.reloadData()
        }
        
        if collectionView == self.mItemCollectionView {
            if let mData = mItemsData[indexPath.row] as? NSDictionary {
                if let id = mData.value(forKey: "id") as? String {
                    if mItemsId.contains(id) {
                        mItemsId = mItemsId.filter {$0 != id }
                    }else{
                        mItemsId.append(id)
                    }
                }
            }
            self.mItemCollectionView.reloadData()
        }
        
        if collectionView == self.mCollectCollectionView {
            if let mData = mCollectionData[indexPath.row] as? NSDictionary {
                if let id = mData.value(forKey: "id") as? String {
                    if mCollectionId.contains(id) {
                        mCollectionId = mCollectionId.filter {$0 != id}
                    }else{
                        mCollectionId.append(id)
                    }
                }
            }
            
            self.mCollectCollectionView.reloadData()
        }
        
        if collectionView == self.mSizeCollectionView {
            if let mData = mSizeData[indexPath.row] as? NSDictionary {
                if let id = mData.value(forKey: "id") as? String {
                    if mSizeId.contains(id) {
                        mSizeId = mSizeId.filter {$0 != id}
                    }else{
                        mSizeId.append(id)
                    }
                }
            }
            
            self.mSizeCollectionView.reloadData()
        }
        
        if collectionView == mCatalogCollectionView {
            if mCustomerId == "" {
                mOpenCstomerPopup()
                return
            }
            
            if let catalogData = mCatalogData[indexPath.row] as? NSDictionary {
                dismiss(animated: false)
                self.delegate?.mGetCatalogItem(data: catalogData, type :self.mSearchType)
            }
        }
        
    }
    
    @IBAction func mAddToCart(_ sender: UIButton) {
        
    }
    
    
    //Catalog/productsList
    
    @IBAction func mLikeDislike(_ sender: UIButton) {
        print("MixAndMatchCatalog mLikeDislike")
        print("MixAndMatchCatalog sender = \(sender)")
        print("MixAndMatchCatalog sender.tag = \(sender.tag)")
        print("MixAndMatchCatalog sender.currentImage = \(String(describing: sender.currentImage))")
        
        
        if mCustomerId != "" {
            let mData = mCatalogData[sender.tag] as? NSDictionary
//            CommonClass.showFullLoader(view: self.view)
            let mLocation = UserDefaults.standard.string(forKey: "location") ?? ""
            let mSKU = "\(mData?.value(forKey: "SKU") ?? "")"
            let mProductId = "\(mData?.value(forKey: "product_id") ?? "")"
            let isWishListed = "\(mData?.value(forKey: "isWishlist") ?? "0")"
            let mItemId = "\(mData?.value(forKey: "item_id") ?? "")"
//            let params = ["location":mLocation,"customer_id":mCustomerId, "isWishlist":isWishListed,"SKU":mSKU, "type":mSearchType, "product_id": mProductId]
            
            let params = [
                "location": mLocation,
                "customer_id": mCustomerId,
                "isWishlist": isWishListed,
                "SKU": mSKU,
                "type": mSearchType,
                "product_id": mProductId,
                "item_id": mItemId
            ]
            
            mGetData(url: mAddToFav,headers: sGisHeaders, params: params) { response , status in
                CommonClass.stopLoader()
                if status {
                    if "\(response.value(forKey: "code") ?? "")" == "200" {
                        
                        if response.value(forKey: "data") == nil {
                            return
                        }
                        self.mGetCatalogs(key: "")
                    }
                    
                }
            }
            
        }else{
            
            CommonClass.showSnackBar(message: "Please choose Customer!")
        }
        
    }
    
    func mAddToWish(id : String){
        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
        _ = UserDefaults.standard.string(forKey: "location")
        
        let urlPath = mAddToFav
        
        let params = ["products_id":id, "Customer_id":mCustomerId]
        
        if Reachability.isConnectedToNetwork() == true {
            AF.request(urlPath, method:.post, parameters:params, encoding: JSONEncoding.default,headers: sGisHeaders).responseJSON
            { response in
                
                if response.error != nil {
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
                    
                    if jsonResult.value(forKey: "code") as? Int == 200 {
                        CommonClass.showSnackBar(message : "Added to wishlist!")
                        self.mGetCatalogs(key : "")
                    }else{
                        if let error = jsonResult.value(forKey: "error") as? String{
                            if error == "Authorization has been expired" {
                                CommonClass.sessionExpired(isExpired: true, navigation: self.navigationController)
                            }
                        }
                        
                    }
                }
                
            }
        }else{
            CommonClass.showSnackBar(message: "No Internet Connection")
        }
        
        
    }
    
    
    func mGetCatalogs(key : String){
        
        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
        let mLocation = UserDefaults.standard.string(forKey: "location") ?? ""
        
        
        
        let urlPath = mGetMixAndMatchCatalog
        
        let mPriceData = NSMutableDictionary()
        mPriceData.setValue(mMinPrices, forKey: "min")
        mPriceData.setValue(mMaxPrices, forKey: "max")
        mFilterData.setValue(mPriceData, forKey: "price")
        
        mFilterData.setValue(mItemsId, forKey: "item")
        mFilterData.setValue(mCollectionId, forKey: "collection")
        mFilterData.setValue([], forKey: "specifiedOccasion")
        mFilterData.setValue([], forKey: "gender")
        mFilterData.setValue([], forKey: "consumerLifestage")
        mFilterData.setValue(mMetalsId, forKey: "metal")
        mFilterData.setValue(mStonesId, forKey: "stone")
        mFilterData.setValue(mSizeId, forKey: "size")
        mFilterData.setValue([], forKey: "StockId")
        if mSearchType == "inventory" {
            mFilterData.setValue(mStatusId, forKey: "status_type")
        }
        
        var params = ["type":mSearchType, "item":mItemTypeId, "search":key , "filter":mFilterData] as [String : Any]
        
//        if mSearchType == "inventory" && key.isEmpty{
//            params["skip"] = mSkipCount
//            params["limit"] = mDataFetchLimit
//        }
        
        if key.isEmpty {
            params["skip"] = mSkipCount
            params["limit"] = mDataFetchLimit
        }
        
//        CommonClass.showFullLoader(view: self.view)
        if Reachability.isConnectedToNetwork() == true {
            AF.request(urlPath, method:.post, parameters:params, encoding: JSONEncoding.default,headers: sGisHeaders).responseJSON
            { response in
                print("CommonClass.stopLoader() 11111111")
                CommonClass.stopLoader()
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
                    
                    if jsonResult.value(forKey: "code") as? Int == 200 {
                        
                        
                        if let total = jsonResult.value(forKey: "totoal") as? Int {
                            self.mTotalData = total
                        }
                        
                        if let data = jsonResult.value(forKey: "data") as? NSArray, data.count > 0 {
                            if !key.trim().isEmpty || self.mSkipCount == 0 {
                                self.mCatalogData.removeAllObjects()
                            }
                            
                            let mDataAsAny = data.compactMap { $0 as Any }
                            self.mCatalogData.addObjects(from: mDataAsAny)
                            
                            self.mCatalogCollectionView.delegate = self
                            self.mCatalogCollectionView.dataSource = self
                            self.mCatalogCollectionView.reloadData()
                            
//                            if key.trim().isEmpty && self.mSearchType == "inventory"{
//                                self.mSkipCount += 20
//                            }else{
//                                self.mSkipCount = 0
//                            }
                            
                            if key.trim().isEmpty {

                                self.mSkipCount += 20//mDataFetchLimit

                            } else {

                                self.mSkipCount = 0

                            }
                            
                        }else{
                            self.mCatalogData = NSMutableArray()
                            self.mCatalogCollectionView.reloadData()
                        }
                        
                    }else{
                        CommonClass.stopLoader()
                        self.mCatalogData = NSMutableArray()
                        self.mCatalogCollectionView.reloadData()
                        if let error = jsonResult.value(forKey: "error") as? String{
                            if error == "Authorization has been expired" {
                                CommonClass.sessionExpired(isExpired: true, navigation: self.navigationController)
                            }
                        }
                        
                    }
                }
                print("CommonClass.stopLoader() 222222")
                CommonClass.stopLoader()
            }
            print("CommonClass.stopLoader() 3333333")
            CommonClass.stopLoader()
        }else{
            print("CommonClass.stopLoader() 44444444")
            CommonClass.stopLoader()
            CommonClass.showSnackBar(message: "No Internet Connection")
        }
        
        
    }
    
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let scrollViewHeight = scrollView.bounds.size.height
        
        // Check if you are near the bottom of the UICollectionView
        if contentOffsetY + scrollViewHeight >= contentHeight && mSearchType == "inventory"{
            // You have reached the bottom of the UICollectionView
            // Add your code here to perform any actions when scrolled to the bottom.
            
            if self.mSkipCount < self.mTotalData{
                mShowMoreButton.isHidden = false
            }
        }else{
            mShowMoreButton.isHidden = true
        }
    }
    
    
    
    
    @IBAction func mShowMore(_ sender: Any) {
        mShowMoreButton.isHidden = true
        mGetCatalogs(key: "")
    }
    
    @IBAction func mLeft(_ sender: Any) {
        mCount = mCount - 1
        if mCount == 1 {
            mLeftView.isHidden = true
        }
        mPageNo.text = "\(mCount)"
        mGetCatalogs(key: "")
    }
    @IBAction func mRight(_ sender: Any) {
        
        mCount =  mCount + 1
        mLeftView.isHidden = false
        mPageNo.text = "\(mCount)"
        mGetCatalogs(key: "")
    }
    
    private func getCustomerAddressList(completion: @escaping () -> Void) {

        guard Reachability.isConnectedToNetwork() == true else {
            completion()
            return
        }

        let params = ["customer_id": mCustomerId] as [String: Any]

        AF.request(
            mGetCustomerAddressList,
            method: .post,
            parameters: params,
            encoding: JSONEncoding.default,
            headers: sGisHeaders
        ).responseJSON { response in

            guard let jsonData = response.data else {
                completion()
                return
            }

            do {
                guard let json = try JSONSerialization.jsonObject(
                    with: jsonData,
                    options: []
                ) as? [String: Any],
                let data = json["data"] as? [String: Any] else {
                    completion()
                    return
                }

                if let billingList = data["billing_address"] as? [[String: Any]] {

                    let selectedUDID = UserDefaults.standard.string(
                        forKey: "CustomerBillingAddressUDID"
                    )

                    if let selectedUDID = selectedUDID {
                        self.mSelectedBillingAddress =
                            billingList.first {
                                ($0["UDID"] as? String) == selectedUDID
                            } ?? [:]
                    }

                    if self.mSelectedBillingAddress.isEmpty {
                        self.mSelectedBillingAddress =
                            billingList.first {
                                ($0["is_default"] as? Int) == 1
                            } ?? [:]
                    }
                }

                if let shippingList = data["shipping_address"] as? [[String: Any]] {

                    let selectedUDID = UserDefaults.standard.string(
                        forKey: "CustomerShippingAddressUDID"
                    )

                    if let selectedUDID = selectedUDID {
                        self.mSelectedShippingAddress =
                            shippingList.first {
                                ($0["UDID"] as? String) == selectedUDID
                            } ?? [:]
                    }

                    if self.mSelectedShippingAddress.isEmpty {
                        self.mSelectedShippingAddress =
                            shippingList.first {
                                ($0["is_default"] as? Int) == 1
                            } ?? [:]
                    }
                }

                print("🔥 BILLING =", self.mSelectedBillingAddress)
                print("🔥 SHIPPING =", self.mSelectedShippingAddress)

                completion()

            } catch {
                completion()
            }
        }
    }
    
    @IBAction func mDownloadCatalogPDF(_ sender: Any) {

            getCustomerAddressList {

                let shippingInfo: [String: Any] = [
                    "billing_address": self.mSelectedBillingAddress,
                    "shipping_address": self.mSelectedShippingAddress
                ]

//                let params: [String: Any] = [
//                    "type": self.mSearchType.lowercased(),
//                    "customer_id": self.mCustomerId,
//                    "shippingInfo": shippingInfo,
//                    "website_url": UserDefaults.standard.string(forKey: "website_url") ?? "",
//                    "Item": self.mItemsId,
//                    "Collection": self.mCollectionId
//                ]
                
                let itemValue: Any = self.mItemsId.isEmpty ? "All" : self.mItemsId

                let params: [String: Any] = [

                    "Item_id": itemValue,
                    "type": self.mSearchType.lowercased(),
                    "category_id": "Item",
                    "customer_id": self.mCustomerId,
                    "shippingInfo": shippingInfo,
                    "website_url": UserDefaults.standard.string(forKey: "website_url") ?? ""

                ]

                print("========== MIXANDMATCH CATALOG PDF MOBILE ==========")
                print("website_url =", UserDefaults.standard.string(forKey: "website_url") ?? "nil")
                print("TYPE =", self.mSearchType)
                print("ITEM FILTER =", self.mItemsId)
                print("COLLECTION FILTER =", self.mCollectionId)
                print("PARAMS =", params)

                CommonClass.showFullLoader(view: self.view)

                mGetData(
                    url: mGetCatalogPdf,
                    headers: sGisHeaders,
                    params: params
                ) { response, status in

                    CommonClass.stopLoader()

                    print("🔥 PDF RESPONSE =", response)
                    print("🔥 PDF STATUS =", status)

                    if status,
                       "\(response.value(forKey: "code") ?? "")" == "200",
                       let pdfUrl = response.value(forKey: "url") as? String,
                       let url = URL(string: pdfUrl) {

                        UIApplication.shared.open(url)

                    } else {

                        CommonClass.showSnackBar(
                            message: "\(response.value(forKey: "message") ?? "Failed to generate PDF")"
                        )
                    }
                }
            }
        }

}
