//
//  POSCatalog.swift
//  GIS
//
//  Created by Apple Hawkscode on 25/03/21.
//

import UIKit
import Alamofire
import UIDrawer


public class CustomerSearchItem: UITableViewCell {
    
    @IBOutlet weak var mCustomerName: UILabel!
    @IBOutlet weak var mPlace: UILabel!
    
    @IBOutlet weak var mCustomerImage: UIImageView!
    @IBOutlet weak var mPhone: UILabel!
    @IBOutlet weak var mView: UIView!
    public override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

class CatalogCell :UICollectionViewCell {
    
    @IBOutlet weak var mDesignStatusView: UIView!
    @IBOutlet weak var mHeart: UIImageView!
    @IBOutlet weak var mDiamondStatus: UIImageView!
    @IBOutlet weak var mProductLikeButt: UIButton!
    @IBOutlet weak var mProductImage: UIImageView!
    @IBOutlet weak var mPrice: UILabel!
    @IBOutlet weak var mProductName: UITextView!
    @IBOutlet weak var mStackView: UIStackView!
    @IBOutlet weak var mAddtoCart: UIButton!
    @IBOutlet weak var mStatusDot: UILabel!
}



class POSCatalog: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout , UITableViewDelegate ,UITableViewDataSource , RangeSeekSliderDelegate, GetCustomerDataDelegate,GetInventoryFiltersDelegate, UIViewControllerTransitioningDelegate {

    private var selectedSalesPersonId: String {
        return (UserDefaults.standard.string(forKey: "SALESPERSONID") ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
//    enum FaroMode {
//        case search
//        case discover
//    }
    
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
    @IBOutlet weak var mDownloadPDFView: UIView!
    
    @IBOutlet weak var mMinPrice: UILabel!
    
    @IBOutlet weak var mMaxPrice: UILabel!
    
    
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
    var SiriID = ""
    
     
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

    private var currentFaroMode: FaroMode = .search
    
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
    
    private var mSkipCount = 0
    private var mTotalData = 0
    private let mDataFetchLimit = 20
    @IBOutlet weak var mShowMoreButton: UIView!
    
    
    
    var mSelectedBillingAddress = [String: Any]()
    var mSelectedShippingAddress = [String: Any]()
    
    private let speechRecongniger = SpeechRecognizer(localeIdentifier: "en-US")
    private var isSpeechRecongnitionOn = false
    
    var isFaroEnabled = true
    var faroMode: FaroMode = .search
    private var isSearching = false
    private var recentSearch: [String] = []
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        mSearchField.placeholder = "Search by SKU / Product name".localizedString
        mCatalogHeaderLABEL.text = "Catalog".localizedString
        
//        if !mCustomerId.isEmpty {
//            mSkipCount = 0
//            mGetCatalogs(key: "")
//        }
        
//        NotificationCenter.default.removeObserver(
//            self,
//            name: .faroSearch,
//            object: nil
//        )
        
        if openFromHome {
            print("POSCatalog.swift openFromHome mClearCart")
            mClearCart()
            openFromHome = false
        }
        
        mCheckSelectedCustomer()
        
    }
    
    var openFromHome = false
    
    @objc
    private func onFaroSearch(_ notification: Notification) {

        print("onFaroSearch CALLED")
        
        guard let keyword = notification.object as? String else {
            return
        }

        print("========== FARO ==========")
        print(keyword)

        CommonClass.showFullLoader(view: self.view)

        performSearch(keyword)
//        mGetFaroSearch(query: keyword)
    }
    
    deinit {

        NotificationCenter.default.removeObserver(
            self,
            name: .faroSearch,
            object: nil
        )

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("POSCatalog.swift viewDidLoad")
        
        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
//        mGetFaroSearch(query: "ring",
//                       mode: faroMode)
        
        if mKey == "1" {
            mBackView.isHidden = true
        }else{
            mBackView.isHidden = false
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onFaroSearch(_:)),
            name: .faroSearch,
            object: nil
        )
        
        mChooseCutomerButton.isHidden = true
        
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
        
        mSizeCollectionView.delegate = self
        mSizeCollectionView.dataSource = self
        
        mCatalogCollectionView.delegate = self
        mCatalogCollectionView.dataSource = self
        
        mShowMoreButton.isHidden = true
        
//        print(mChooseCutomerButton.frame)
//        print(mChooseCutomerButton.bounds)
//        print(mChooseCutomerButton.superview!)
        
        mCheckUncheckCustomer.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openCustomer))
        mCheckUncheckCustomer.addGestureRecognizer(tapGesture)
        
        mCustomerId = UserDefaults.standard.string(forKey: "DEFAULTCUSTOMER") ?? ""
        
        if mCustomerId == "" {
            let storyBoard: UIStoryboard = UIStoryboard(name: "common", bundle: nil)
            if let home = storyBoard.instantiateViewController(withIdentifier: "CustomerPicker") as? CustomerPicker {
                home.delegate = self
                home.modalPresentationStyle = .automatic
                home.transitioningDelegate = self
                self.present(home,animated: true)
            }
        }
        mGetCatalogs(key: "")
//        self.performSearch("")
        addDoneButtonOnKeyboard()
        self.mSearchField.text = SiriID
        mCheckSelectedCustomer()
    }
    
    @objc func openCustomer() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "common", bundle: nil)
        if let home = storyBoard.instantiateViewController(withIdentifier: "CustomerPicker") as? CustomerPicker {
            home.delegate = self
            home.modalPresentationStyle = .automatic
            home.transitioningDelegate = self
            self.present(home,animated: true)
        }
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
//            self.mCustomerImage.downlaodImageFromUrl(
//                urlString: UserDefaults.standard.string(forKey: "PROFILE_IMAGE") ?? ""
//            )
            
            self.mCustomerImage.downlaodImageFromUrl(urlString: UserDefaults.standard.string(forKey: "SALESPERSON_IMAGE") ?? "")
            
            
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    //Speech Recognition
    @IBOutlet weak var sMicImage: UIImageView!
    @IBAction func sSpeechRecognitionButton(_ sender: Any) {
        if !isSpeechRecongnitionOn {
            self.isSpeechRecongnitionOn = true
            self.sMicImage.image = UIImage(systemName: "mic.slash.fill")
            speechRecongniger.startRecognition { value in
                
                DispatchQueue.main.async {
                    self.isSpeechRecongnitionOn = false
                    self.sMicImage.image = UIImage(systemName: "mic.fill")
                    if let text = value , !text.isEmpty{
                        self.mSearchField.text = text
                        self.mSearchField.becomeFirstResponder()
                    }
                }
            }
            
        } else {
            self.sMicImage.image = UIImage(systemName: "mic.fill")
            self.isSpeechRecongnitionOn = false
            speechRecongniger.stopRecognition()
        }
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
//        mGetCatalogs(key: "")
        performSearch("")
    }
    
    private func clearCatalogScreen() {

        mCatalogData.removeAllObjects()
        mSkipCount = 0

        mCatalogCollectionView.reloadData()

//        CommonClass.showFullLoader(view: self.view)
    }
    
    
    
    @IBAction func mSwitchInvCatlog(_ sender: UIButton) {

        sender.isSelected.toggle()

        clearCatalogScreen()

        if sender.isSelected {

            mSearchType = "inventory"
            mCatalogHeaderLABEL.text = "Inventory".localizedString
            mSwitchIcon.image = UIImage(named: "catstock_ic")

        } else {

            mSearchType = "catalog"
            mCatalogHeaderLABEL.text = "Catalog".localizedString
            mSwitchIcon.image = UIImage(named: "catcatlog_ic")

        }

        let keyword = SiriID.isEmpty ? "" : SiriID
        mSearchField.text = keyword
        performSearch(keyword)
    }
    
    
    @IBAction func mOpenCustomer(_ sender: Any) {
        print("mOpenCustomer")
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
        
        if let id = data.value(forKey: "id") as? String {
            UserDefaults.standard.set(id, forKey: "DEFAULTCUSTOMER")
            self.mCustomerId = id
        }

//        if let profile = data.value(forKey: "profile") as? String {
//            UserDefaults.standard.set(profile, forKey: "DEFAULTCUSTOMERPICTURE")
//            self.mCustomerImage.downlaodImageFromUrl(urlString: profile)
//        }
        self.mCustomerImage.downlaodImageFromUrl(urlString: UserDefaults.standard.string(forKey: "SALESPERSON_IMAGE") ?? "")
     
        if let name = data.value(forKey: "name") as? String {
            UserDefaults.standard.set(name, forKey: "DEFAULTCUSTOMERNAME")
        }
           
        self.mCheckUncheckCustomer.image = UIImage(named: "selected_customer")
        mSkipCount = 0
        
        if !SiriID.isEmpty {
                       mSearchField.text = SiriID
                       print("Searching with SiriID: \(SiriID)")
//                       self.mGetCatalogs(key: SiriID)
                        self.performSearch(SiriID)
                   } else {
//                       self.mGetCatalogs(key: "")
                       self.performSearch("")
                   }

    }
    
    
    @IBAction func mMinimizeFilters(_ sender: Any) {
        self.mFilterView.slideTop()
        self.mFilterView.isHidden = true
    }
    
    @IBAction func mApplyFilter(_ sender: Any) {
        
        mFilterView.isHidden = true
        mSearchView.isHidden = true
        
        mSkipCount = 0
//        self.mGetCatalogs(key: mSearchField.text ?? "")
        self.performSearch(mSearchField.text ?? "")
        
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
    
//    @objc func doneButtonAction(){
//        mSkipCount = 0
//        self.mGetCatalogs(key: mSearchField.text ?? "")
//        mSearchField.text = ""
//        mSearchField.resignFirstResponder()
//    }
    @objc func doneButtonAction() {

        mSkipCount = 0

        performSearch(mSearchField.text ?? "")

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
//        self.mGetCatalogs(key: mSearchField.text ?? "")
        self.performSearch(mSearchField.text ?? "")
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
            
            for (index, _) in self.mItemsData.enumerated(){
                if let mData = mItemsData[index] as? NSDictionary,
                   let id = mData.value(forKey: "id") as? String {
                    mItemsId.append(id)
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
            
            
            for (index, _) in self.mCollectionData.enumerated(){
                if let mData = mCollectionData[index] as? NSDictionary,
                   let id = mData.value(forKey: "id") as? String {
                    mCollectionId.append(id)
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
            
            for (index, _) in self.mStonesData.enumerated(){
                if let mData = mStonesData[index] as? NSDictionary,
                   let id = mData.value(forKey: "id") as? String {
                    mStonesId.append(id)
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
            
            for (index, _) in self.mMetalsData.enumerated(){
                if let mData = mMetalsData[index] as? NSDictionary,
                   let id = mData.value(forKey: "id") as? String {
                    mMetalsId.append(id)
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
            
            for (index, _) in self.mLocationsData.enumerated(){
                if let mData = mLocationsData[index] as? NSDictionary,
                   let id = mData.value(forKey: "id") as? String {
                    mLocationsId.append(id)
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
            
            for (index, _) in self.mSizeData.enumerated(){
                if let mData = mSizeData[index] as? NSDictionary,
                   let id = mData.value(forKey: "id") as? String {
                    mSizeId.append(id)
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
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func mGoToWishList(_ sender: Any) {
        return
        let storyBoard: UIStoryboard = UIStoryboard(name: "catalog", bundle: nil)
        if let mWishList  = storyBoard.instantiateViewController(withIdentifier: "WishlistSearchNew") as? WishlistSearch {
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
                    if let currentText = cells.mCustomerName.text {
                        cells.mCustomerName.text = currentText + " " + lname
                    } else {
                        cells.mCustomerName.text = lname
                    }
                }

                if let phoneCode = mData.value(forKey: "phone_code") as? String {
                    cells.mPhone.text = phoneCode
                }

                if let phone = mData.value(forKey: "phone") as? String {
                    if let currentText = cells.mPhone.text {
                        cells.mPhone.text = currentText + " " + phone
                    } else {
                        cells.mPhone.text = phone
                    }
                }

                if let stateCountry = mData.value(forKey: "stateCountry") as? String {
                    cells.mPlace.text = stateCountry
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
            guard let cells = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath) as? ItemCell else {
                return cell
            }
            let mData =  mItemsData[indexPath.row] as? NSDictionary

            if let itemName = mData?.value(forKey: "name") as? String {
                cells.mItemName.text = itemName
            }

            if let itemId = mData?.value(forKey: "id") as? String {
                if mItemsId.contains(itemId) {
                    cells.mItemName.backgroundColor =  #colorLiteral(red: 0.7725490196, green: 0.6666666667, blue: 0.5058823529, alpha: 1)
                    cells.backgroundColor =  #colorLiteral(red: 0.7725490196, green: 0.6666666667, blue: 0.5058823529, alpha: 1)
                } else {
                    cells.mItemName.backgroundColor =  #colorLiteral(red: 0.9450980392, green: 0.9058823529, blue: 0.8509803922, alpha: 1)
                    cells.backgroundColor =  #colorLiteral(red: 0.9450980392, green: 0.9058823529, blue: 0.8509803922, alpha: 1)
                }
            }

            cells.layoutSubviews()
            cell = cells
        }else if collectionView == self.mCollectCollectionView {
            guard let cells = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as? CollectionCell else {
                return cell
            }

            let mData =  mCollectionData[indexPath.row] as? NSDictionary
            
            if let collectionName = mData?.value(forKey: "name") as? String {
                cells.mCollectionName.text = collectionName
            }

            if let collectionId = mData?.value(forKey: "id") as? String {
                if mCollectionId.contains(collectionId) {
                    cells.mCollectionName.backgroundColor =  #colorLiteral(red: 0.7725490196, green: 0.6666666667, blue: 0.5058823529, alpha: 1)
                    cells.backgroundColor =  #colorLiteral(red: 0.7725490196, green: 0.6666666667, blue: 0.5058823529, alpha: 1)
                } else {
                    cells.mCollectionName.backgroundColor =  #colorLiteral(red: 0.9450980392, green: 0.9058823529, blue: 0.8509803922, alpha: 1)
                    cells.backgroundColor =  #colorLiteral(red: 0.9450980392, green: 0.9058823529, blue: 0.8509803922, alpha: 1)
                }
            }

            cells.layoutSubviews()
            cell = cells
            
        }else if collectionView == self.mMetalCollectionView {
            guard let cells = collectionView.dequeueReusableCell(withReuseIdentifier: "MetalCell", for: indexPath) as? MetalCell else {
                return cell
            }

            let mData =  mMetalsData[indexPath.row] as? NSDictionary
            
            if let metalName = mData?.value(forKey: "name") as? String {
                cells.mMetalName.text = metalName
            }

            if let metalId = mData?.value(forKey: "id") as? String {
                if mMetalsId.contains(metalId) {
                    cells.mMetalName.backgroundColor =  #colorLiteral(red: 0.7725490196, green: 0.6666666667, blue: 0.5058823529, alpha: 1)
                    cells.backgroundColor =  #colorLiteral(red: 0.7725490196, green: 0.6666666667, blue: 0.5058823529, alpha: 1)
                } else {
                    cells.mMetalName.backgroundColor =  #colorLiteral(red: 0.9450980392, green: 0.9058823529, blue: 0.8509803922, alpha: 1)
                    cells.backgroundColor =  #colorLiteral(red: 0.9450980392, green: 0.9058823529, blue: 0.8509803922, alpha: 1)
                }
            }

            cells.layoutSubviews()
            cell = cells

            
        }else if collectionView == self.mSizeCollectionView {
            guard let cells = collectionView.dequeueReusableCell(withReuseIdentifier: "SizeCell", for: indexPath) as? SizeCell else {
                return cell
            }

            guard let mData = mSizeData[indexPath.row] as? NSDictionary else {
                return cell
            }
            if let sizeName = mData.value(forKey: "name") as? String {
                cells.mSizeName.text = sizeName
            }

            if let sizeId = mData.value(forKey: "id") as? String {
                if mSizeId.contains(sizeId) {
                    cells.mSizeName.backgroundColor = #colorLiteral(red: 0.7725490196, green: 0.6666666667, blue: 0.5058823529, alpha: 1)
                    cells.backgroundColor = #colorLiteral(red: 0.7725490196, green: 0.6666666667, blue: 0.5058823529, alpha: 1)
                } else {
                    cells.mSizeName.backgroundColor = #colorLiteral(red: 0.9450980392, green: 0.9058823529, blue: 0.8509803922, alpha: 1)
                    cells.backgroundColor = #colorLiteral(red: 0.9450980392, green: 0.9058823529, blue: 0.8509803922, alpha: 1)
                }
            }

            cells.layoutSubviews()
            cell = cells
            
        }
        else if collectionView == self.mStoneCollectionView {
            guard let cells = collectionView.dequeueReusableCell(withReuseIdentifier: "StoneCell", for: indexPath) as? StoneCell else {
                return cell
            }

            guard let mData = mStonesData[indexPath.row] as? NSDictionary else {
                return cell
            }
            if let stoneName = mData.value(forKey: "name") as? String {
                cells.mCStone.text = stoneName
            }

            if let stoneId = mData.value(forKey: "id") as? String {
                if mStonesId.contains(stoneId) {
                    cells.mCStone.backgroundColor = #colorLiteral(red: 0.7725490196, green: 0.6666666667, blue: 0.5058823529, alpha: 1)
                    cells.backgroundColor = #colorLiteral(red: 0.7725490196, green: 0.6666666667, blue: 0.5058823529, alpha: 1)
                } else {
                    cells.mCStone.backgroundColor = #colorLiteral(red: 0.9450980392, green: 0.9058823529, blue: 0.8509803922, alpha: 1)
                    cells.backgroundColor = #colorLiteral(red: 0.9450980392, green: 0.9058823529, blue: 0.8509803922, alpha: 1)
                }
            }

            cells.layoutSubviews()
            cell = cells
            
        } else if collectionView == self.mCatalogCollectionView {
            
            guard let cells = collectionView.dequeueReusableCell(withReuseIdentifier: "CatalogCell",for:indexPath) as? CatalogCell else {
                return cell
            }
            
            guard let mData = mCatalogData[indexPath.row] as? NSDictionary else {
                return cell
            }
            
            print("""
            ===== CELL =====
            row = \(indexPath.row)
            searchType = \(mSearchType)
            sku = \(mData["SKU"] ?? "")
            status_type = \(mData["status_type"] ?? "nil")
            status_stock_id = \(mData["status_stock_id"] ?? "nil")
            """)
            
            print("mCatalogCollectionView Index =", indexPath.row)
            print("status =", mData["status_type"] ?? "nil")
            
            if "\(mData.value(forKey: "isWishlist") ?? "")" == "0" {
                cells.mHeart.image = UIImage(systemName: "heart")
                cells.mHeart.tintColor = UIColor(named: "themeExtraLightText1")
            }else{
                cells.mHeart.image = UIImage(systemName: "heart.fill")
                cells.mHeart.tintColor = UIColor(named: "themeLightRed")
            }
            
            if let isDesign = mData.value(forKey: "is_design") as? Bool {
                if isDesign {
                    cells.mDesignStatusView.isHidden = false
                }else{
                    cells.mDesignStatusView.isHidden = true
                }
            }else{
                cells.mDesignStatusView.isHidden = true
            }
            
            if mSearchType == "catalog" {
                cells.mStatusDot.isHidden = true
            }else {
                cells.mStatusDot.isHidden = false
            }
            
            cells.mStatusDot.backgroundColor = #colorLiteral(red: 0.4588235294,green: 0.8,blue: 1,alpha: 1)
            
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
            }
            
            let skuAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14, weight: .regular),
                .foregroundColor: UIColor(named: "themeColor") ?? UIColor.black ]
            let nameAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14, weight: .regular),
                .foregroundColor: #colorLiteral(red: 0.3181298765, green: 0.3326592986, blue: 0.328506533, alpha: 1) ]
            
            let finalName = NSMutableAttributedString()
            finalName.append(NSAttributedString(string: "\(mData.value(forKey: "name")  as? String ?? "")\n", attributes: nameAttributes))
            finalName.append(NSAttributedString(string: "\(mData.value(forKey: "SKU")  as? String ?? "")", attributes: skuAttributes))
            
            cells.mProductName.attributedText = finalName
            cells.mProductLikeButt.tag = indexPath.row
            cells.mAddtoCart.tag = indexPath.row

            // Product name is a UITextView in the storyboard. Make it explicitly
            // tappable so tapping the name opens the same product detail page.
            cells.mProductName.tag = indexPath.row
            cells.mProductName.isUserInteractionEnabled = true
            cells.mProductName.gestureRecognizers?.forEach {
                cells.mProductName.removeGestureRecognizer($0)
            }
            let productNameTap = UITapGestureRecognizer(
                target: self,
                action: #selector(handleProductNameTap(_:))
            )
            productNameTap.cancelsTouchesInView = true
            cells.mProductName.addGestureRecognizer(productNameTap)

//            cells.mAddtoCart.setTitle("Add to Order".localizedString, for: .normal)
            cells.mPrice.text = "\(mData.value(forKey: "price") ?? "")"
            cells.mProductImage.downlaodImageFromUrl1(urlString: "\(mData.value(forKey: "main_image") ?? "")")
            
            print("frame =", cells.mDiamondStatus.frame)
            print("alpha =", cells.mDiamondStatus.alpha)
            print("superview hidden =", cells.mDiamondStatus.superview?.isHidden ?? false)
            print("image =", cells.mDiamondStatus.image as Any)
            print("background =", cells.mDiamondStatus.backgroundColor as Any)
            
            print("dot color =", cells.mStatusDot.backgroundColor!)
            print("diamond hidden =", cells.mDiamondStatus.isHidden)
            print("diamond image =", cells.mDiamondStatus.image)
            
            cell = cells
            
        }
        
        
        
        return cell
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == mCatalogCollectionView {
            
            if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
                if UIDevice.current.userInterfaceIdiom == .pad {
                    return CGSize(width: mCatalogCollectionView.bounds.width/3 , height: 350)
                } else {
                    layout.minimumInteritemSpacing = 0
                    return CGSize(width: mCatalogCollectionView.bounds.width/2  , height: 350)
                }
            } else {
                return CGSize(width: mCatalogCollectionView.bounds.width/2  , height: 350)
            }
        }

        return CGSize(width: view.frame.size.width/2 - 30 , height:50)

    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        print("POSCatalog collectionView didSelectItemAt")
        if collectionView == self.mStoneCollectionView {
            print("POSCatalog mStoneCollectionView")
            guard let mData = mStonesData[indexPath.row] as? NSDictionary else {
                return
            }
            
            if let stoneId = mData.value(forKey: "id") as? String {
                if mStonesId.contains(stoneId) {
                    mStonesId.removeAll { $0 == stoneId }
                } else {
                    mStonesId.append(stoneId)
                }
                
                self.mStoneCollectionView.reloadData()
            }
        }
        if collectionView == self.mLocationCollectionView {
            print("POSCatalog mLocationCollectionView")
            guard let mData = mLocationsData[indexPath.row] as? NSDictionary else {
                return
            }
            if let locationid = mData.value(forKey: "id") as? String {
                if mLocationsId.contains(locationid) {
                    mLocationsId = mLocationsId.filter {$0 != locationid }
                } else {
                    mLocationsId.append(locationid)
                }
                self.mLocationCollectionView.reloadData()
            }
        }
        
        if collectionView == self.mMetalCollectionView {
            print("POSCatalog mMetalCollectionView")
            guard let mData = mMetalsData[indexPath.row] as? NSDictionary else {
                return
            }
            if let metalId = mData.value(forKey: "id") as? String {
                if mMetalsId.contains(metalId) {
                    mMetalsId = mMetalsId.filter {$0 != metalId }
                }else{
                    mMetalsId.append(metalId)
                }
                self.mMetalCollectionView.reloadData()
            }
        }
        
        if collectionView == self.mItemCollectionView {
            print("POSCatalog mItemCollectionView")
            guard let mData = mItemsData[indexPath.row] as? NSDictionary else {
                return
            }
            if let itemId = mData.value(forKey: "id") as? String {
                if mItemsId.contains(itemId) {
                    mItemsId = mItemsId.filter {$0 != itemId }
                }else{
                    mItemsId.append(itemId)
                }
                self.mItemCollectionView.reloadData()
            }
        }
        if collectionView == self.mCollectCollectionView {
            print("POSCatalog mCollectCollectionView")
            guard let mData = mCollectionData[indexPath.row] as? NSDictionary else {
                return
            }
            if let collectionId = mData.value(forKey: "id") as? String {
                if mCollectionId.contains(collectionId) {
                    mCollectionId = mCollectionId.filter {$0 != collectionId }
                }else{
                    mCollectionId.append(collectionId)
                }
                self.mCollectCollectionView.reloadData()
            }
        }
        if collectionView == self.mSizeCollectionView {
            print("POSCatalog mSizeCollectionView")
            guard let mData = mSizeData[indexPath.row] as? NSDictionary else {
                return
            }
            if let sizeId = mData.value(forKey: "id") as? String {
                if mSizeId.contains(sizeId) {
                    mSizeId = mSizeId.filter {$0 != sizeId }
                }else{
                    mSizeId.append(sizeId)
                }
                self.mSizeCollectionView.reloadData()
            }
        }
        
        if collectionView == mCatalogCollectionView {
            openProductDetail(at: indexPath.row)
        }


    }


    @IBAction func mAddToCart(_ sender: UIButton) {
        guard mCustomerId != "" else {
            let storyBoard: UIStoryboard = UIStoryboard(name: "common", bundle: nil)
            if let home = storyBoard.instantiateViewController(withIdentifier: "CustomerPicker") as? CustomerPicker {
                home.delegate = self
                home.modalPresentationStyle = .automatic
                home.transitioningDelegate = self
                self.present(home, animated: true)
            }
            return
        }

        guard let data = mCatalogData[sender.tag] as? NSDictionary else {
            return
        }

        // IMPORTANT:
        // "+" means ADD ITEM and then GO DIRECTLY TO THE CART.
        // Do NOT open POSAddToCart here.
        addItemToOrderAndOpenCart(data: data)
    }

    // MARK: - Product detail / Add to order

    @objc private func handleProductNameTap(_ gesture: UITapGestureRecognizer) {
        guard let view = gesture.view else { return }
        openProductDetail(at: view.tag)
    }

    private func openProductDetail(at index: Int) {
        guard index >= 0, index < mCatalogData.count else {
            return
        }

        if mCustomerId == "" {
            let storyBoard: UIStoryboard = UIStoryboard(name: "common", bundle: nil)
            if let home = storyBoard.instantiateViewController(withIdentifier: "CustomerPicker") as? CustomerPicker {
                home.delegate = self
                home.modalPresentationStyle = .automatic
                home.transitioningDelegate = self
                self.present(home, animated: true)
            }
            return
        }

        guard let data = mCatalogData[index] as? NSDictionary else {
            return
        }

        // Tapping the product name opens the product/add-to-cart detail page.
        // This is intentionally different from "+".
        let storyBoard = UIStoryboard(name: "catalog", bundle: nil)
        if let mProfile = storyBoard.instantiateViewController(withIdentifier: "POSAddToCartNew") as? POSAddToCart {
            mProfile.mData = data
            mProfile.mType = mSearchType
            mProfile.mCustomerId = mCustomerId
            CommonClass.showFullLoader(view: self.view)
            self.navigationController?.pushViewController(mProfile, animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    CommonClass.stopLoader()
                }
        }
    }

    private func addItemToOrderAndOpenCart(data: NSDictionary) {
        let productId = "\(data.value(forKey: "product_id") ?? "")"
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !productId.isEmpty else {
            CommonClass.showSnackBar(message: "Product ID not available.")
            return
        }

        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")

        // Catalog -> custom order
        // Inventory -> POS order
        let isInventory = (mSearchType == "inventory")
        let orderType = isInventory ? "pos_order" : "custom_order"

        let params: [String: Any] = [
            "product_id": [productId],
            "customer_id": mCustomerId,
            "sales_person_id": selectedSalesPersonId,
            "type": mSearchType,
            "order_type": orderType,
            "pointer": ""
        ]

        print("========== POSCatalog ADD ITEM ==========")
        print("TYPE =", mSearchType)
        print("ORDER TYPE =", orderType)
        print("PRODUCT ID =", productId)
        print("CUSTOMER ID =", mCustomerId)
        print("PARAMS =", params)
        print("=========================================")

        CommonClass.showFullLoader(view: self.view)

        mGetData(
            url: mAddCustomProduct,
            headers: sGisHeaders,
            params: params
        ) { [weak self] response, status in

            guard let self = self else { return }

            DispatchQueue.main.async {
                CommonClass.stopLoader()

                guard status else {
                    CommonClass.showSnackBar(
                        message: "Oops! Something went wrong."
                    )
                    return
                }

                guard let statusCode = response.value(forKey: "code") as? Int else {
                    CommonClass.showSnackBar(
                        message: "Oops! Something went wrong."
                    )
                    return
                }

                print("========== POSCatalog ADD ITEM RESPONSE ==========")
                print("STATUS =", status)
                print("CODE =", statusCode)
                print("RESPONSE =", response)
                print("===================================================")

                guard statusCode == 200 else {
                    if let error = response.value(forKey: "error") as? String {
                        if error == "Authorization has been expired" {
                            CommonClass.sessionExpired(
                                isExpired: true,
                                navigation: self.navigationController
                            )
                            return
                        }

                        CommonClass.showSnackBar(
                            message: "Error \(statusCode): \(error)"
                        )
                        return
                    }

                    if let message = response.value(forKey: "message") as? String,
                       !message.isEmpty {
                        CommonClass.showSnackBar(message: message)
                    } else {
                        CommonClass.showSnackBar(
                            message: "Unable to add item to cart."
                        )
                    }

                    return
                }

                // =========================================================
                // ADD SUCCESS
                // IMPORTANT: Go to CART directly.
                // Do NOT push POSAddToCart.
                // =========================================================

                // Stop the loader that belongs to POSCatalog BEFORE navigation.
                // The existing navigation functions below are intentionally unchanged.
                CommonClass.stopLoader()

                if isInventory {
                    // INVENTORY:
                    // Keep the existing working navigation exactly as-is.
                    self.openInventoryCart()

                    // Show the same full loader on the newly opened POS screen.
                    DispatchQueue.main.async {
                        if let topView = self.navigationController?.topViewController?.view {
                            CommonClass.showFullLoader(view: topView)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                CommonClass.stopLoader()
                            }
                        }
                    }
                } else {
                    // CATALOG:
                    // Keep the existing working navigation exactly as-is.
                    self.openCatalogCart()

                    // Show the same full loader on the newly opened CustomCart.
                    DispatchQueue.main.async {
                        if let topView = self.navigationController?.topViewController?.view {
                            CommonClass.showFullLoader(view: topView)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                CommonClass.stopLoader()
                            }
                        }
                    }
                }
            }
        }
    }

    private func openCatalogCart() {
        let storyBoard = UIStoryboard(
            name: "customOrder",
            bundle: nil
        )

        // If CustomCart is already in the navigation stack,
        // return to that existing cart instead of creating another one.
        if let existingCartIndex =
            self.navigationController?.viewControllers.firstIndex(
                where: { $0 is CustomCart }
            ) {

            if let cart =
                self.navigationController?.viewControllers[existingCartIndex]
                as? CustomCart {

                print("✅ CATALOG ITEM ADDED")
                print("➡️ POP TO EXISTING CustomCart")

                self.navigationController?.popToViewController(
                    cart,
                    animated: true
                )

                // Refresh after returning to the cart.
                cart.mFetchCartItems()
                return
            }
        }

        guard let mCustomCart =
            storyBoard.instantiateViewController(
                withIdentifier: "CustomCart"
            ) as? CustomCart else {
            CommonClass.showSnackBar(
                message: "Unable to open cart."
            )
            return
        }

        mCustomCart.mCustomerId = self.mCustomerId

        print("✅ CATALOG ITEM ADDED")
        print("➡️ OPEN CustomCart")
        print("➡️ TYPE =", self.mSearchType)

        self.navigationController?.pushViewController(
            mCustomCart,
            animated: true
        )
    }

    private func openInventoryCart() {
        let storyBoard = UIStoryboard(
            name: "posBoard",
            bundle: nil
        )

        // Match the existing Inventory -> POS cart navigation.
        if let viewControllers = self.navigationController?.viewControllers {
            if !viewControllers.contains(where: { $0 is POSTabBarController }) {
                posTabBarInstance = nil
            }
        }

        if let mHomePage = posTabBarInstance {
            mHomePage.selectedIndex = 2

            if let newHomePage =
                storyBoard.instantiateViewController(
                    withIdentifier: "POSTabBarController"
                ) as? POSTabBarController {

                newHomePage.mIndex = 2

                if let navigationController = self.navigationController {
                    var controllers = navigationController.viewControllers
                    if !controllers.isEmpty {
                        controllers.removeLast()
                    }
                    controllers.append(newHomePage)

                    navigationController.setViewControllers(
                        controllers,
                        animated: true
                    )
                }
            }

        } else {
            guard let mHomePage =
                storyBoard.instantiateViewController(
                    withIdentifier: "POSTabBarController"
                ) as? POSTabBarController else {
                CommonClass.showSnackBar(
                    message: "Unable to open cart."
                )
                return
            }

            mHomePage.mIndex = 2

            if let navigationController = self.navigationController {
                var controllers = navigationController.viewControllers
                if !controllers.isEmpty {
                    controllers.removeLast()
                }
                controllers.append(mHomePage)

                navigationController.setViewControllers(
                    controllers,
                    animated: true
                )
            }
        }

        print("✅ INVENTORY ITEM ADDED")
        print("➡️ OPEN POS CART")
        print("➡️ TYPE = inventory")
    }

    @IBAction func mLikeDislike(_ sender: UIButton) {
        
        if mCustomerId != "" {
            guard let mData = mCatalogData[sender.tag] as? NSDictionary else {
                return
            }
            CommonClass.showFullLoader(view: self.view)
            let mLocation = UserDefaults.standard.string(forKey: "location") ?? ""
            let mSKU = "\(mData.value(forKey: "SKU") ?? "")"
            let mProductId = "\(mData.value(forKey: "product_id") ?? "")"
            let isWishListed = "\(mData.value(forKey: "isWishlist") ?? "0")"
            let mItemId = "\(mData.value(forKey: "item_id") ?? "")"
//            let params = ["location":mLocation,"customer_id":mCustomerId, "isWishlist":isWishListed,"SKU":mSKU, "type":mSearchType, "product_id": mProductId]
            
            let params = [

                "location":mLocation,
                "customer_id":mCustomerId,
                "isWishlist":isWishListed,
                "SKU":mSKU,
                "type":mSearchType,
                "product_id":mProductId,
                "item_id":mItemId

            ]
            
            mUserLoginToken = UserDefaults.standard.string(forKey: "token")
            mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
            
            mGetData(url: mAddToFav,headers: sGisHeaders,  params: params) { response , status in
                print("mAddToFav stopLoader")
                CommonClass.stopLoader()
                if status {
                    if "\(response.value(forKey: "code") ?? "")" == "200" {
                        
                        if response.value(forKey: "data") == nil {
                            return
                        }
                        
                        guard let catalogData = self.mCatalogData[sender.tag] as? NSDictionary,
                              let newData = catalogData.mutableCopy() as? NSMutableDictionary else {
                            return
                        }

                        if let isWishListed = catalogData.value(forKey: "isWishlist") as? Int {
                            newData.setValue((isWishListed == 0) ? 1 : 0, forKey: "isWishlist")
                            self.mCatalogData[sender.tag] = newData
                            self.mCatalogCollectionView.reloadData()
                        }
                    }
                    
                }
            }
            
        }else{
            
            CommonClass.showSnackBar(message: "Please choose Customer!")
        }
        
    }
    
    func mGetCatalogs(key : String){
        
        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
        
        var urlPath = mGetCatalogue
        
        
        mFilterData = [
            "price": [
                "min": mMinPrices,
                "max": mMaxPrices
            ],
            "item": mItemsId,
            "collection": mCollectionId,
            "metal": mMetalsId,
            "stone": mStonesId,
            "size": mSizeId,
            "specifiedOccasion": [] as [String],
            "gender": [] as [String],
            "consumerLifestage": [] as [String],
            "StockId": [] as [String]
        ]
        
        if mSearchType == "inventory" {
//            urlPath = mGetInventory//test 27/07/26 17:17
            mFilterData["status_type"] = mStatusId
        }
//        var params = ["search":key,"type":mSearchType, "filter" : self.mFilterData, "customer_id": mCustomerId] as [String : Any]
        
        var params = buildCatalogParams(
            keyword: key
        )
        
        if mSearchType == "inventory" && key.isEmpty{
            params["skip"] = mSkipCount
            params["limit"] = mDataFetchLimit
            let mLocation = UserDefaults.standard.string(forKey: "location") ?? ""
            params["location_id"] = mLocation //test 27/07/26 17:17
            
            print("Selected Location =", mLocation)
        }
        
        
        print("POSCatalog mGetCatalogs params = \(params)")
        if Reachability.isConnectedToNetwork() == true {
            let startTime = CFAbsoluteTimeGetCurrent()

            print("🚀 START mGetCatalogue")
            AF.request(urlPath, method:.post, parameters:params, encoding: JSONEncoding.default,headers: sGisHeaders).responseJSON
            { response in
                
                
                let elapsed = CFAbsoluteTimeGetCurrent() - startTime
                print("""
                ==========================
                API : mGetCatalogue
                Time : \(String(format: "%.3f", elapsed)) sec
                ==========================
                """)
                print("POSCatalog mGetCatalogs response = \(response)")
                guard response.error == nil else {
                    CommonClass.showSnackBar(message: "OOP's something went wrong!")
                    return
                }
                
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
                    
                    
                    self.handleCatalogResponse(
                        jsonResult,
                        keyword: key
                    )

                    
                }else{
                    if let error = jsonResult.value(forKey: "error") as? String {
                        if error == "Authorization has been expired" {
                            CommonClass.stopLoader()
                            print("Authorization has been expired stopLoader")
                            CommonClass.sessionExpired(isExpired: true, navigation: self.navigationController)
                        }
                    }
                }
                
            }
        }else{
            CommonClass.stopLoader()
            print("No Internet Connection stopLoader")
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
//        mGetCatalogs(key: "")
        self.performSearch("")
    }
    
    @IBAction func mLeft(_ sender: Any) {
        mCount = mCount - 1
        if mCount == 1 {
            mLeftView.isHidden = true
        }
        mPageNo.text = "\(mCount)"
//        mGetCatalogs(key: "")
        self.performSearch("")
    }
    @IBAction func mRight(_ sender: Any) {
        
        mCount =  mCount + 1
        mLeftView.isHidden = false
        mPageNo.text = "\(mCount)"
//        mGetCatalogs(key: "")
        self.performSearch("")
    }
            
    //Clear Cart API
    func mClearCart(){
        print("🔥 POSCatalog.swift mClearCart called")
//        print(Thread.callStackSymbols.joined(separator: "\n"))
        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
        
        let urlPath =  mClearDataApi
        
        if Reachability.isConnectedToNetwork() == true {
            AF.request(urlPath, method:.post, headers: sGisHeaders2).responseJSON
            { response in
                
                guard response.error == nil else {
                    CommonClass.showSnackBar(message: "OOP's something went wrong!")
                    return
                }
                
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
                    
                    
                }else{
                    if let error = jsonResult.value(forKey: "error") as? String {
                        if error == "Authorization has been expired" {
                            CommonClass.sessionExpired(isExpired: true, navigation: self.navigationController)
                        }
                    }
                }
            }
        }else{
        }
        
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
    
    
    private func resetSearch() {

        mSkipCount = 0

        mSearchField.text = ""

        mGetCatalogs(key: "")

    }
    
    private func searchUsingFaro(_ text: String) {
        print("START FARO SEARCH")

        FaroService.shared.search(
            query: text,
            mode: currentFaroMode
        ) { [weak self] result in

            print("SEARCH CALLBACK")
            guard let self = self else { return }

            DispatchQueue.main.async {

                self.finishSearch(
                    result: result,
                    keyword: text
                )

            }

        }
    }
    
    private func performSearch(_ keyword: String) {

        
        let text = keyword.trimmingCharacters(in: .whitespacesAndNewlines)

//        if text.isEmpty {
//
//            mGetCatalogs(key: "")
//            return
//
//        }
        guard !isSearching else { return }

        isSearching = true
        
        if !recentSearch.contains(text) {

            recentSearch.insert(text, at: 0)

        }

        if recentSearch.count > 10 {

            recentSearch.removeLast()

        }
        
        print("""
        =====================
        FARO EVENT
        Mode : \(currentFaroMode)
        Keyword : \(text)
        =====================
        """)

        CommonClass.showFullLoader(view: self.view)
        
        if FaroConfiguration.useFaro {

            switch currentFaroMode {

            case .search:
                searchUsingFaro(text)

            case .discover:
                // TODO:
                // Waiting Backend
                // intent payload
                discoverUsingFaro(text)

            }

        } else {

            mGetCatalogs(key: text)

        }

    }
    
    private func finishSearch(
        result: Result<NSArray, Error>,
        keyword: String
    ) {
        print("""
        ===================
        FINISH SEARCH
        ===================
        """)
        isSearching = false
        print("finishSearch stopLoader")
//        CommonClass.stopLoader()

        switch result {

        case .success(let products):

            if products.count > 0 {

                self.reloadCatalog(with: products)

            } else {

                print("Fallback to Catalog Search")

                self.mGetCatalogs(key: keyword)

            }

        case .failure(let error):

            print("""
            ==========================
            FARO FAILED
            Keyword : \(keyword)
            Reason  : \(error.localizedDescription)
            Fallback → Catalog Search
            ==========================
            """)

            self.mGetCatalogs(key: keyword)

        }

    }
    
    private func discoverUsingFaro(_ text: String) {

        FaroService.shared.search(
            query: text,
            mode: currentFaroMode
        ) { [weak self] result in

            guard let self = self else { return }

            DispatchQueue.main.async {

                self.finishSearch(
                    result: result,
                    keyword: text
                )

            }

        }

    }
    
    private func reloadCatalog(with products: NSArray) {

        self.mCatalogData.removeAllObjects()
        
        print("Reload Catalog =", products.count)
        
        for item in products {

            guard let product = item as? NSDictionary else {
                continue
            }

            
            let mapped = CatalogMapper.map(product)

            self.mCatalogData.add(mapped)

        }

        DispatchQueue.main.async {

            self.mCatalogCollectionView.reloadData()

        }

    }
    
    
//    func mGetFaroSearch(query: String)
//    func mGetFaroSearch(
//        query: String,
//        mode: FaroMode
//    ){
//
//        var params: [String: Any] = [
//            "distill": true,
//            "limit": 20,
//            "queryText": query
//        ]
//
//        print("========== FARO SEARCH ==========")
////        print(params)
//        let api: String
//
//        switch mode {
//
//        case .search:
//            api = mGetFaroSearchAPI
//
//        case .discover:
//            api = mGetFaroDiscoverAPI
//
//        }
//        switch mode {
//
//        case .search:
//
//            break
//
//        case .discover:
//
//            params["intent"] = ""
//
//        }
//        print("========== FARO ==========")
//        print("MODE =", mode)
//        print("API =", api)
//        print("PARAMS =", params)
////        print("sGisHeaders", sGisHeaders)
//        AF.request(
//            api,
//            method: .post,
//            parameters: params,
//            encoding: JSONEncoding.default,
//            headers: sGisHeaders
//        )
//        .responseJSON { response in
//
//            print("========== FARO RESPONSE ==========")
//            print(response)
//            guard let jsonData = response.data else { return }
//
//            do {
//
//                let json = try JSONSerialization.jsonObject(
//                    with: jsonData,
//                    options: []
//                )
//                print(json)
//                guard let jsonResult = json as? NSDictionary else {
//                    return
//                }
//
//                print("========== FARO JSON ==========")
//                print(jsonResult)
//                print("========== FARO JSON ALL KEY ==========")
//                print(jsonResult.allKeys)
//                if let products = jsonResult["products"] as? NSArray {
//
//                    self.reloadCatalog(with: products)
//
//                }
//
//            } catch {
//
//                print(error)
//
//            }
//
//        }
//    }
    
    private func handleCatalogResponse(
        _ jsonResult: NSDictionary,
        keyword: String
    ) {

        guard let data = jsonResult["data"] as? NSArray else {

            self.mCatalogData.removeAllObjects()
            self.mCatalogCollectionView.reloadData()
            return

        }

        if let total = jsonResult["totoal"] as? Int {
            self.mTotalData = total
        }

        if data.count > 0 {

            updateCatalogUI(
                products: data,
                keyword: keyword
            )

            if keyword.trimmingCharacters(in: .whitespaces).isEmpty &&
                self.mSearchType == "inventory" {

                self.mSkipCount += 20

            } else {

                self.mSkipCount = 0

            }

        } else {
            print("handleCatalogResponse stopLoader")
            CommonClass.stopLoader()
            self.mCatalogData.removeAllObjects()
            self.mCatalogCollectionView.reloadData()

        }

    }
    
    private func updateCatalogUI(
        products: NSArray,
        keyword: String
    ) {

        if !keyword.trim().isEmpty ||
            self.mSkipCount == 0 {

            self.mCatalogData.removeAllObjects()

        }

        self.mCatalogData.addObjects(
            from: products as! [Any]
        )
        print("updateCatalogUI stopLoader")
        CommonClass.stopLoader()
        self.mCatalogCollectionView.reloadData()

    }
    
    private func buildCatalogParams(
        keyword: String
    ) -> [String: Any] {

        var filter: [String: Any] = [

            "price": [
                "min": mMinPrices,
                "max": mMaxPrices
            ],

            "item": mItemsId,
            "collection": mCollectionId,
            "metal": mMetalsId,
            "stone": mStonesId,
            "size": mSizeId,
            "specifiedOccasion": [],
            "gender": [],
            "consumerLifestage": [],
            "StockId": []

        ]

        if mSearchType == "inventory" {

            filter["status_type"] = mStatusId

        }

        var params: [String: Any] = [

            "search": keyword,
            "type": mSearchType,
            "filter": filter,
            "customer_id": mCustomerId

        ]

        if mSearchType == "inventory",
           keyword.isEmpty {

            params["skip"] = mSkipCount
            params["limit"] = mDataFetchLimit
            params["location_id"] =
            UserDefaults.standard.string(
                forKey: "location"
            ) ?? ""

        }

        return params

    }
//    func mGetFaroDiscover(query: String) {
//
//        let params: [String: Any] = [
//            "distill": true,
//            "limit": 20,
//            "queryText": query
//        ]
//
//        AF.request(
//            mGetFaroDiscoverAPI,
//            method: .post,
//            parameters: params,
//            encoding: JSONEncoding.default,
//            headers: sGisHeaders
//        )
//        .responseJSON { response in
//
//            print(response)
//
//        }
//    }
    
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

                print("========== POSCATTALOG CATALOG PDF MOBILE ==========")
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

                    print("mDownloadCatalogPDF stopLoader")
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
