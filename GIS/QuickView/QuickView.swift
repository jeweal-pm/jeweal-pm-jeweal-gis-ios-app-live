//
//  QuickViewViewController.swift
//  GIS
//
//  Created by Apple Hawkscode on 04/01/22.
//

import UIKit
import Alamofire
class ReserveOrderCell : UITableViewCell {
    
    @IBOutlet weak var mLocationName: UILabel!
    @IBOutlet weak var mView: UIView!
    @IBOutlet weak var mQuantity: UILabel!
    @IBOutlet weak var mAmount: UILabel!
    @IBOutlet weak var mStockName: UILabel!
    @IBOutlet weak var mStockId: UILabel!
    @IBOutlet weak var mCheckIcon: UIImageView!
    @IBOutlet weak var mStatusDot: UILabel!
    @IBOutlet weak var mStatusDotView: UIView!
    
}

class QuickViewLocationCell : UITableViewCell {
    @IBOutlet weak var mView: UIView!
    @IBOutlet weak var mCheckIcon: UIImageView!
    @IBOutlet weak var mLocationName: UILabel!
    @IBOutlet weak var mQuantity: UILabel!
}

class QuickView: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout , UITableViewDelegate, UITableViewDataSource, GetCustomerDataDelegate, UIViewControllerTransitioningDelegate {
    
    /**Bottom ReserveOrder View*/
    var mSiriID: String?
    @IBOutlet weak var mParentView: UIView!
    
    @IBOutlet weak var mReserveOrderListView: UIView!
    @IBOutlet weak var mItemsTableView: UITableView!
    
    @IBOutlet weak var mListType: UILabel!
    
    @IBOutlet weak var mLocation: UILabel!
    var mReserveOrderData = NSArray()
    var mReserveData = NSMutableArray()
    var mCurrentLocation = ""
    var mSelectedReserveLocationId = ""
    var mIsCrossLocationReserve = false
    
    @IBOutlet weak var mConfirmButton: UIButton!
    
    @IBOutlet weak var mStoneViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var mLocationTableView: UITableView!
    @IBOutlet weak var mSearchField: UITextField!
    @IBOutlet weak var mProductCollectionView: UICollectionView!
    @IBOutlet weak var mPageController: UIPageControl!
    @IBOutlet weak var mProductName: UITextView!
    @IBOutlet weak var mStockIdName: UILabel!
    @IBOutlet weak var mSelectAllBUTTON: UIButton!
    
    @IBOutlet weak var mBottomViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var mReserveOrderView: UIView!
    
    @IBOutlet weak var mOrderButton: UIButton!
    @IBOutlet weak var mReserveButton: UIButton!
    @IBOutlet weak var mLocationCount: UILabel!
    @IBOutlet weak var mStoneCollectionView: UICollectionView!
    @IBOutlet weak var mMetalCollectionView: UICollectionView!
    @IBOutlet weak var mSizeCollectionView: UICollectionView!
    @IBOutlet weak var mMetalLABEL: UILabel!
    @IBOutlet weak var mStoneLABEL: UILabel!
    @IBOutlet weak var mSizeLABEL: UILabel!
    @IBOutlet weak var mLocaitonLABEL: UILabel!
    
    @IBOutlet weak var mSwitchIcon: UIImageView!
    var mSearchType = "inventory"

    // API: true means the product has no selectable variants.
    private var mNonVariant = false

    var mMetalsData = NSArray()
    var mSelectedItems = NSArray()
    
    var mSelectedRows = [String]()
    
    var mMetalsId = [String]()
    
    var mStonesData = NSArray()
    var mStonesId = [String]()
    
    var mLocationsData = NSArray()
    var mLocationsId = [String]()
    
    var mSizeData = NSArray()
    var mSizeId = [String]()
    
    var mFilterData = NSMutableDictionary()
    
    var mImageData = [String]()
    
    var mType = ""
    var mSKUName = ""
    var mSKUDetails = ""
    var mStockIds = ""
    
    @IBOutlet weak var mHeading: UILabel!
    var mProductIds = [String]()
    var mCustomerId = ""
    @IBOutlet weak var mLocationViewHeight: NSLayoutConstraint!
    
    var mProductIdForImage = ""
    // Add this
    private var isQuickViewLoaded = false

    private var isConfirmProcessing = false
    //new imageview
    
    @IBOutlet weak var sPreviewImage: UIImageView!
    
    
    private func loadPreviewImage(at index: Int = 0) {

        guard index < mImageData.count else {

            print("❌ QUICK VIEW: ALL IMAGE URLS FAILED")

            sPreviewImage.image = UIImage(
                named: "placeholder"
            )

            return
        }

        let imageString = mImageData[index]
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard
            !imageString.isEmpty,
            let url = URL(string: imageString),
            let scheme = url.scheme?.lowercased(),
            scheme == "http" || scheme == "https"
        else {

            print(
                "⚠️ QUICK VIEW SKIP INVALID URL index =",
                index,
                imageString
            )

            loadPreviewImage(at: index + 1)
            return
        }

        print(
            "🔄 QUICK VIEW TRY IMAGE index =",
            index,
            imageString
        )

        sPreviewImage.sd_setImage(
            with: url,
            placeholderImage: nil
        ) { [weak self] image, error, _, imageURL in

            guard let self = self else {
                return
            }

            if let image = image {

                self.sPreviewImage.image = image

                print(
                    "✅ QUICK VIEW IMAGE SUCCESS =",
                    imageURL?.absoluteString ?? imageString
                )

            } else {

                print(
                    "❌ QUICK VIEW IMAGE FAILED index =",
                    index,
                    imageString,
                    error?.localizedDescription ?? "UNKNOWN ERROR"
                )

                self.loadPreviewImage(
                    at: index + 1
                )
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("NAV DEBUG QuickView viewDidLoad")
        mCustomerId = UserDefaults.standard.string(forKey: "DEFAULTCUSTOMER") ?? ""
        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
        
        mSearchField.text = mSKUName
        mProductName.text = mSKUDetails
        mStockIdName.text = mSKUName
        mPageController.numberOfPages =  mImageData.count
        self.mProductCollectionView.isPagingEnabled = false
        self.mProductCollectionView.decelerationRate = .fast
        self.mProductCollectionView.delegate = self
        self.mProductCollectionView.dataSource = self
        self.mMetalCollectionView.delegate = self
        self.mMetalCollectionView.dataSource = self
        self.mSizeCollectionView.delegate = self
        self.mSizeCollectionView.dataSource = self
        self.mStoneCollectionView.delegate = self
        self.mStoneCollectionView.dataSource = self
        self.mLocationTableView.delegate = self
        self.mLocationTableView.dataSource = self
        mReserveOrderView.layer.cornerRadius = 10
        mReserveOrderView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        mReserveOrderView.dropShadow()
        mReserveOrderListView.layer.cornerRadius = 20
        mReserveOrderListView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        mReserveOrderListView.dropShadow()
        mReserveOrderListView.isHidden = true
        mConfirmButton.isHidden = true
        mConfirmButton.isEnabled = false
        mConfirmButton.alpha = 0.5

        if let layout = mSizeCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.estimatedItemSize = .zero
                layout.scrollDirection = .vertical
            }
    }
    
    @IBAction func mBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func mViewImage(_ sender: Any) {
        if mProductIdForImage != "" {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Test", bundle: nil)
            if let mGlobalImageViewer = storyBoard.instantiateViewController(withIdentifier: "GlobalImageViewer") as? GlobalImageViewer {
                mGlobalImageViewer.modalPresentationStyle = .overFullScreen
                mGlobalImageViewer.mProductId = mProductIdForImage
                mGlobalImageViewer.mSKUName = mSKUName
                mGlobalImageViewer.transitioningDelegate = self
                self.present(mGlobalImageViewer,animated: false)
            }
        }
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        mGetQuickView()
//        mSelectAllBUTTON.setTitleColor(#colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1), for: .normal)
//        mSelectAllBUTTON.setTitleColor(#colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1), for: .selected)
//
//        mReserveButton.setTitle("RESERVE".localizedString, for: .normal)
//        mOrderButton.setTitle("ORDER".localizedString, for: .normal)
//        mConfirmButton.setTitle("CONFIRM".localizedString, for: .normal)
//        mSelectAllBUTTON.setTitle("Select All".localizedString, for: .normal)
//        mMetalLABEL.text = "Metal".localizedString
//        mStoneLABEL.text = "Stone".localizedString
//        mSizeLABEL.text = "Size".localizedString
//        mHeading.text = "Quick View".localizedString
//        mSearchField.placeholder = "Search by SKU / Stock Id".localizedString
//
//        //setPreviewImage
//        if mImageData.count > 0 {
//            sPreviewImage.downlaodImageFromUrl(urlString: self.mImageData[0])
//        }
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("NAV DEBUG QuickView viewWillAppear")
        print("===== VIEW WILL APPEAR =====")
        print("searchType =", mSearchType)
        print("selectedLocation =", mSelectedReserveLocationId)
        print("locationsId =", mLocationsId)
        print("orderEnabled =", mOrderButton.isEnabled)
        updateActionButtons()
        print("============================")
        CommonClass.stopLoader()
        if !isQuickViewLoaded {
            isQuickViewLoaded = true
            mGetQuickView()
        }

        mSelectAllBUTTON.setTitleColor(#colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1), for: .normal)
        mSelectAllBUTTON.setTitleColor(#colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1), for: .selected)

        mReserveButton.setTitle(
            "RESERVE".localizedString,
            for: .normal
        )

        mOrderButton.setTitle(
            mSearchType == "inventory" ? "ADD TO ORDER".localizedString : "ADD TO ORDER".localizedString,
            for: .normal
        )

        mConfirmButton.setTitle(
            "CONFIRM".localizedString,
            for: .normal
        )

        mSelectAllBUTTON.setTitle(
            "Select All".localizedString,
            for: .normal
        )

        mMetalLABEL.text = "Metal".localizedString
        mStoneLABEL.text = "Stone".localizedString
        mSizeLABEL.text = "Size".localizedString
        mHeading.text = "Quick View".localizedString

        mSearchField.placeholder =
            "Search by SKU / Stock Id".localizedString

        loadPreviewImage()
//        if let firstImage = mImageData.first,
//           !firstImage.isEmpty {
//
//            print("QUICK VIEW IMAGE URL =", firstImage)
//
//            sPreviewImage.downlaodImageFromUrl(
//                urlString: firstImage
//            )
//        } else {
//
//            print("QUICK VIEW IMAGE EMPTY")
//
//            sPreviewImage.image = UIImage(
//                named: "placeholder"
//            )
//        }
        
//        if let firstImage = mImageData.first,
//           !firstImage.isEmpty,
//           let url = URL(string: firstImage),
//           let scheme = url.scheme,
//           scheme == "http" || scheme == "https" {
//
//            print("QUICK VIEW IMAGE URL =", firstImage)
//
//            sPreviewImage.downlaodImageFromUrl(
//                urlString: firstImage
//            )
//
//        } else {
//
//            print(
//                "QUICK VIEW INVALID IMAGE URL =",
//                mImageData.first ?? "EMPTY"
//            )
//
//            sPreviewImage.image = UIImage(
//                named: "placeholder"
//            )
//        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        CommonClass.stopLoader()
        print("NAV DEBUG QuickView viewDidAppear")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        CommonClass.stopLoader()
        print("NAV DEBUG QuickView viewWillDisappear")
    }

    deinit {
        print("NAV DEBUG QuickView DEINIT")
    }
    
    
    // MARK: - Quick View UI State

    func updateVariantControls() {
        let enabled = !mNonVariant

        mMetalCollectionView.isUserInteractionEnabled = enabled
        mStoneCollectionView.isUserInteractionEnabled = enabled
        mSizeCollectionView.isUserInteractionEnabled = enabled

        mMetalCollectionView.alpha = 1.0
        mStoneCollectionView.alpha = 1.0
        mSizeCollectionView.alpha = 1.0
    }

    private func updateActionButtons() {
        let hasLocation = !mLocationsId.isEmpty

        // Catalog: Location is display-only. ADD TO ORDER must always
        // remain visible and available; it must not depend on Location.
        if mSearchType == "catalog" {
            mOrderButton.setTitle("ADD TO ORDER".localizedString, for: .normal)
            mOrderButton.isHidden = false
            mOrderButton.isEnabled = true
            mOrderButton.alpha = 1.0

            mReserveButton.isHidden = true
            mReserveButton.isEnabled = false
            mReserveButton.alpha = 0.5

            mBottomViewHeight.constant = 120
        } else {
            // Inventory: keep the existing Location selection flow.
            mOrderButton.setTitle("ADD TO ORDER".localizedString, for: .normal)
            mOrderButton.isHidden = !hasLocation
            mOrderButton.isEnabled = hasLocation
            mOrderButton.alpha = hasLocation ? 1.0 : 0.5

            mReserveButton.isHidden = !hasLocation
            mReserveButton.isEnabled = hasLocation
            mReserveButton.alpha = hasLocation ? 1.0 : 0.5

            mBottomViewHeight.constant = hasLocation ? 120 : 0
        }

        // Catalog Location list is informational only; Inventory remains selectable.
        mLocationTableView.isUserInteractionEnabled = (mSearchType == "inventory")

        mConfirmButton.isHidden = true
        self.view.layoutIfNeeded()
    }

    private func updateConfirmButton() {
        // The item-selection bottom sheet needs a second step:
        // 1) select an item
        // 2) press Confirm/Submit to continue to the next screen.
        //
        // mConfirmButton is inside the bottom-sheet flow, so do not let
        // updateActionButtons() hide it permanently.
        let hasSelectedItem = !mSelectedRows.isEmpty

        mConfirmButton.setTitle("CONFIRM".localizedString, for: .normal)
        mConfirmButton.isHidden = false
        mConfirmButton.isEnabled = hasSelectedItem
        mConfirmButton.alpha = hasSelectedItem ? 1.0 : 0.5

        self.view.layoutIfNeeded()
    }

    @IBAction func mSwitchInvCatlog(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            
            self.mMetalsId.removeAll()
            self.mStonesId.removeAll()
            self.mLocationsId.removeAll()
            self.mSizeId.removeAll()
            self.mMetalsData = NSArray()
            self.mStonesData = NSArray()
            self.mLocationsData = NSArray()
            self.mSizeData = NSArray()
            self.mNonVariant = false
            self.updateVariantControls()
            
            mSearchType = "catalog"
            mSwitchIcon.image = UIImage(named: "quickViewCat")
            
            mGetQuickView()
        }else{
            mSearchType = "inventory"
            self.mMetalsId.removeAll()
            self.mStonesId.removeAll()
            self.mLocationsId.removeAll()
            self.mSizeId.removeAll()
            self.mMetalsData = NSArray()
            self.mStonesData = NSArray()
            self.mLocationsData = NSArray()
            self.mSizeData = NSArray()
            self.mNonVariant = false
            self.updateVariantControls()
            
            mSwitchIcon.image = UIImage(named: "quickViewInv")
            mGetQuickView()
            
        }
    }
    
    @IBAction func mOrderNow(_ sender: Any) {
        mSelectedRows = [String]()
        print("mOrderNow")
        if mSearchType == "inventory" {
            mGetInventory(type:"Order")
            return
        }

        // Catalog/Home mode does NOT require Location selection.
        // Locations are display-only; ADD TO ORDER can be pressed directly.
        CommonClass.showFullLoader(view: self.view)
        let params:[String: Any] = ["ids" :mProductIds]
        
        print("===== ORDER LIST REQUEST =====")
        print("Sending ids =", mProductIds)
        print("==============================")
        
        let apiStartTime = CFAbsoluteTimeGetCurrent()
        let apiStartDate = Date()

        print("========== ORDER LIST API START ==========")
        print("API URL =", mAllGetCatalogItems)
        print("API BODY =", params)
        print("API START TIME =", apiStartDate)

        mGetData(url: mAllGetCatalogItems,headers: sGisHeaders,  params: params) { response , status in
            let apiEndTime = Date()
            let apiDuration = CFAbsoluteTimeGetCurrent() - apiStartTime

            print("========== ORDER LIST API END ==========")
            print("API URL =", mAllGetCatalogItems)
            print("API END TIME =", apiEndTime)
            print(String(format: "⏱ ORDER LIST API DURATION = %.3f seconds (%.0f ms)",
                         apiDuration,
                         apiDuration * 1000))
            print("API SUCCESS =", status)
            print("========================================")

            CommonClass.stopLoader()
            if status {
                if "\(response.value(forKey: "code") ?? "")" == "200" {
                    if let mData = response.value(forKey: "data") as? NSArray {
                        print("===== ORDER LIST RESPONSE =====")
                        print(mData)
                        print("===============================")
                        self.mReserveOrderData = mData
                        print("mOrderNow self.mReserveOrderData = \(self.mReserveOrderData)")
                        self.mParentView.isHidden = false
                        self.mReserveOrderListView.isHidden =  false
                        self.mReserveOrderListView.slideFromBottom()
                        
                        if self.mSearchType == "inventory" {
                            self.mListType.text = "Reserve"
                            self.mLocation.text = ""
                        }else{
                            self.mListType.text = "Catalog"
                            self.mLocation.text = ""
                        }
                        
                        self.mItemsTableView.delegate = self
                        self.mItemsTableView.dataSource = self
                        self.mItemsTableView.reloadData()
                        
                    }
                    
                }else{
                    
                }
            }
        }
    }
    
    @IBAction func mReserveNow(_ sender: Any) {
        
        mSelectedRows = [String]()
        mGetInventory(type:"")
        
    }
    
    func mGetInventory(type: String){
        CommonClass.showFullLoader(view: self.view)
        let params:[String: Any] = ["search" : mSKUName, "metal": mMetalsId, "size": mSizeId, "stone":mStonesId, "location":mLocationsId, "type":mSearchType]
        
        let apiStartTime = CFAbsoluteTimeGetCurrent()
        let apiStartDate = Date()

        print("========== ORDER / RESERVE API START ==========")
        print("API URL =", mGetQuickViewOrderReserveData)
        print("API BODY =", params)
        print("API START TIME =", apiStartDate)

        mGetData(url: mGetQuickViewOrderReserveData,headers: sGisHeaders,  params: params) { response , status in
            let apiEndTime = Date()
            let apiDuration = CFAbsoluteTimeGetCurrent() - apiStartTime

            print("========== ORDER / RESERVE API END ==========")
            print("API URL =", mGetQuickViewOrderReserveData)
            print("API END TIME =", apiEndTime)
            print(String(format: "⏱ ORDER / RESERVE API DURATION = %.3f seconds (%.0f ms)",
                         apiDuration,
                         apiDuration * 1000))
            print("API SUCCESS =", status)
            print("=============================================")

            CommonClass.stopLoader()
            if status {
                if let code = response.value(forKey: "code") as? Int {
                    
                    switch code {
                    case 200:
                        if let mData = response.value(forKey: "data") as? NSArray {
                            
                            self.mReserveOrderData = mData
                            
                            self.mParentView.isHidden = false
                            self.mReserveOrderListView.isHidden =  false
                            self.mReserveOrderListView.slideFromBottom()
                            
                            if !type.isEmpty {
                                self.mListType.text = "Inventory"
                                self.mLocation.text = ""
                            }else{
                                self.mListType.text = "Reserve"
                                self.mLocation.text = ""
                            }
                            
                            self.mItemsTableView.delegate = self
                            self.mItemsTableView.dataSource = self
                            self.mItemsTableView.reloadData()

                            // Step 2: select the item, then press Confirm to continue.
                            self.updateConfirmButton()
                            
                        }
                        break
                    case 403:
                        CommonClass.sessionExpired(isExpired: true, navigation: self.navigationController)
                        break
                    default:
                        let errorMessage = response.value(forKey: "message") as? String ?? "An error occurred."
                        CommonClass.showSnackBar(message: "Error \(code): \(errorMessage)")
                        break
                    }
                } else {
                    CommonClass.showSnackBar(message: "OOP's something went wrong!")
                }
            }
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
        UserDefaults.standard.set(data.value(forKey: "profile") ?? "", forKey: "DEFAULTCUSTOMERPICTURE")
        if let name = data.value(forKey: "name") as? String {
            UserDefaults.standard.set(name, forKey: "DEFAULTCUSTOMERNAME")
        }
    }
    
    func mOpenCustomerPopup(){
        let storyBoard: UIStoryboard = UIStoryboard(name: "common", bundle: nil)
        if let home = storyBoard.instantiateViewController(withIdentifier: "CustomerPicker") as? CustomerPicker {
            home.delegate = self
            home.modalPresentationStyle = .automatic
            home.transitioningDelegate = self
            self.present(home,animated: true)
        }
    }
    
    @IBAction func mConfirmButt(_ sender: Any) {
        print("isConfirmProcessing = \(isConfirmProcessing)")

        if isConfirmProcessing {
            return
        }

        isConfirmProcessing = true

        if let button = sender as? UIButton {
            button.isEnabled = false
        }

        if mSelectedRows.isEmpty {
            isConfirmProcessing = false

            if let button = sender as? UIButton {
                button.isEnabled = true
            }

            mConfirmButton.isEnabled = false
            mConfirmButton.alpha = 0.5
            CommonClass.showSnackBar(message: "Please select items.")
            return
        }

        // ============================================================
        // INVENTORY MODE
        // ============================================================
        if mSearchType == "inventory" {

            // --------------------------------------------------------
            // Inventory -> Add to Cart
            // --------------------------------------------------------
            if self.mListType.text == "Inventory" {

                if mCustomerId == "" {
                    mOpenCustomerPopup()
                    isConfirmProcessing = false

                    if let button = sender as? UIButton {
                        button.isEnabled = true
                    }
                    return
                }

                let mParams = [
                    "product_id": self.mSelectedRows,
                    "customer_id": mCustomerId,
                    "sales_person_id": "",
                    "type": mSearchType,
                    "order_type": "custom_order"
                ] as [String: Any]

                // IMPORTANT:
                // Show loader BEFORE starting the Add to Cart request.
                CommonClass.showFullLoader(view: self.view)

                let apiStartTime = CFAbsoluteTimeGetCurrent()
                let apiStartDate = Date()

                print("========== CONFIRM ADD TO CART API START ==========")
                print("API URL =", mAddCustomProduct)
                print("API BODY =", mParams)
                print("API START TIME =", apiStartDate)
                print("=================================================")

                mGetData(url: mAddCustomProduct, headers: sGisHeaders, params: mParams) { response, status in

                    DispatchQueue.main.async {

                        CommonClass.stopLoader()
                        self.isConfirmProcessing = false

                        if let button = sender as? UIButton {
                            button.isEnabled = true
                        }

                        guard status else {
                            CommonClass.showSnackBar(
                                message: "Unable to add product to cart."
                            )
                            return
                        }

                        let responseCode = Int("\(response.value(forKey: "code") ?? "")") ?? 0
                        let responseMessage =
                            "\(response.value(forKey: "message") ?? "Unknown error")"

                        print("========== ADD TO CART RESPONSE ==========")
                        print("CODE =", responseCode)
                        print("MESSAGE =", responseMessage)
                        print("==========================================")

                        if responseCode == 200 {

                            let storyBoard = UIStoryboard(
                                name: "customOrder",
                                bundle: nil
                            )

                            if let mCustomCart =
                                storyBoard.instantiateViewController(
                                    withIdentifier: "CustomCart"
                                ) as? CustomCart {

                                self.navigationController?.pushViewController(
                                    mCustomCart,
                                    animated: true
                                )

                                self.mParentView.isHidden = true
                                self.mReserveOrderListView.isHidden = true
                                self.mConfirmButton.isHidden = true
                            }

                        } else {

                            // API error เช่น
                            // Product already exists in cart: HR4140
                            CommonClass.showSnackBar(
                                message: "Error \(responseCode): \(responseMessage)"
                            )
                        }
                    }
                }

            // --------------------------------------------------------
            // Inventory -> Reserve
            // --------------------------------------------------------
            } else {
                let storyBoard: UIStoryboard = UIStoryboard(
                    name: "reserveBoard",
                    bundle: nil
                )

                if let mInventoryPage = storyBoard.instantiateViewController(
                    withIdentifier: "InventoryReserveCart"
                ) as? InventoryReserveCart {

                    // ----------------------------------------------------
                    // IMPORTANT: Preserve the selected Quick View location
                    // all the way to InventoryReserveCart.
                    //
                    // Quick View already knows the destination location from
                    // mSelectedReserveLocationId.  Put the same information
                    // into the reserve item dictionaries as well, so the
                    // next screen can build the createReserveOrder payload
                    // without losing cross-location information.
                    // ----------------------------------------------------
                    let loginLocationId =
                        UserDefaults.standard.string(forKey: "location") ?? ""

                    let selectedLocationId =
                        self.mSelectedReserveLocationId.trimmingCharacters(in: .whitespacesAndNewlines)

                    let isCrossLocation =
                        !selectedLocationId.isEmpty &&
                        !loginLocationId.isEmpty &&
                        selectedLocationId != loginLocationId

                    self.mIsCrossLocationReserve = isCrossLocation

                    let reserveDataForInventory = NSMutableArray()

                    for case let item as NSDictionary in self.mReserveData {
                        let mutableItem = NSMutableDictionary(
                            dictionary: item as! [AnyHashable: Any]
                        )

                        // Always preserve the selected destination location.
                        // For a cross-location reserve, explicitly mark the
                        // item so InventoryReserveCart can use it as a fallback.
                        if !selectedLocationId.isEmpty {
                            mutableItem["crossLocationId"] = selectedLocationId
                        }

                        if isCrossLocation {
                            mutableItem["crosslocation"] = true
                        }

                        reserveDataForInventory.add(mutableItem)
                    }

                    mInventoryPage.mOriginalData =
                        NSArray(array: reserveDataForInventory)
                    mInventoryPage.reserveSource = .quickView

                    mInventoryPage.mIsCrossLocationReserve =
                        isCrossLocation

                    mInventoryPage.mCrossLocationId =
                        selectedLocationId

                    print("========== QUICK VIEW RESERVE DEBUG ==========")
                    print("LOGIN LOCATION ID =", loginLocationId)
                    print("SELECTED LOCATION ID =", selectedLocationId)
                    print("IS CROSS LOCATION =", isCrossLocation)
                    print("CROSS LOCATION ID =", selectedLocationId)
                    print("RESERVE DATA BEFORE =", self.mReserveData)
                    print("RESERVE DATA SENT =", reserveDataForInventory)
                    print("==============================================")

                    self.navigationController?.pushViewController(
                        mInventoryPage,
                        animated: true
                    )

                    self.mParentView.isHidden = true
                    self.mReserveOrderListView.isHidden = true
                    self.mConfirmButton.isHidden = true
                }

                self.isConfirmProcessing = false

                if let button = sender as? UIButton {
                    button.isEnabled = true
                }
            }

        // ============================================================
        // OTHER MODE -> Add to Cart
        // ============================================================
        } else {

            if mCustomerId == "" {
                mOpenCustomerPopup()
                isConfirmProcessing = false

                if let button = sender as? UIButton {
                    button.isEnabled = true
                }
                return
            }

            let mParams = [
                "product_id": self.mSelectedRows,
                "customer_id": mCustomerId,
                "sales_person_id": "",
                "type": mSearchType,
                "order_type": "custom_order"
            ] as [String: Any]

            // IMPORTANT:
            // Show loader BEFORE starting the Add to Cart request.
            CommonClass.showFullLoader(view: self.view)

            let apiStartTime = CFAbsoluteTimeGetCurrent()
            let apiStartDate = Date()

            print("========== CONFIRM ADD TO CART API START ==========")
            print("API URL =", mAddCustomProduct)
            print("API BODY =", mParams)
            print("API START TIME =", apiStartDate)
            print("=================================================")

            mGetData(url: mAddCustomProduct, headers: sGisHeaders, params: mParams) { response, status in

                DispatchQueue.main.async {

                    CommonClass.stopLoader()
                    self.isConfirmProcessing = false

                    if let button = sender as? UIButton {
                        button.isEnabled = true
                    }

                    guard status else {
                        CommonClass.showSnackBar(
                            message: "Unable to add product to cart."
                        )
                        return
                    }

                    let responseCode = Int("\(response.value(forKey: "code") ?? "")") ?? 0
                    let responseMessage =
                        "\(response.value(forKey: "message") ?? "Unknown error")"

                    print("========== ADD TO CART RESPONSE ==========")
                    print("CODE =", responseCode)
                    print("MESSAGE =", responseMessage)
                    print("==========================================")

                    if responseCode == 200 {

                        let storyBoard = UIStoryboard(
                            name: "customOrder",
                            bundle: nil
                        )

                        if let mCustomCart =
                            storyBoard.instantiateViewController(
                                withIdentifier: "CustomCart"
                            ) as? CustomCart {

                            self.navigationController?.pushViewController(
                                mCustomCart,
                                animated: true
                            )

                            self.mParentView.isHidden = true
                            self.mReserveOrderListView.isHidden = true
                            self.mConfirmButton.isHidden = true
                        }

                    } else {

                        // API error เช่น
                        // Product already exists in cart: HR4140
                        CommonClass.showSnackBar(
                            message: "Error \(responseCode): \(responseMessage)"
                        )
                    }
                }
            }
        }
    }

    @IBAction func mHideBottomSheet(_ sender: Any) {
        self.mParentView.isHidden = true
        self.mReserveOrderListView.isHidden = true

        mSelectedRows.removeAll()
        mReserveData.removeAllObjects()

        mConfirmButton.isHidden = true
        mConfirmButton.isEnabled = false
        mConfirmButton.alpha = 0.5
    }

    @IBAction func mSearchNow(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Test", bundle: nil)
        if let home = storyBoard.instantiateViewController(withIdentifier: "QuickViewSearch") as? QuickViewSearch {
            home.mType = "Quick View"
            self.navigationController?.pushViewController(home, animated:true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count = 0
        
        if collectionView == self.mMetalCollectionView {
            count = mMetalsData.count
            
        } else if collectionView == self.mStoneCollectionView {
            count = mStonesData.count
            
            
        }else if collectionView == self.mSizeCollectionView {
            count = mSizeData.count
            
            
        }
        
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell = UICollectionViewCell()
        
        if collectionView == self.mMetalCollectionView {
            guard let cells = collectionView.dequeueReusableCell(withReuseIdentifier: "MetalCell", for: indexPath) as? MetalCell,
                  let mData = mMetalsData[indexPath.row] as? NSDictionary else {
                return cell
            }
            cells.mMetalName.text = mData.value(forKey: "name") as? String
            
            if "\(mData.value(forKey: "select") ?? "")" == "0" {
                
                cells.mMetalName.backgroundColor =  #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
                cells.backgroundColor =  #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
                cells.mMetalName.textColor = #colorLiteral(red: 0.6784313725, green: 0.6784313725, blue: 0.6784313725, alpha: 1)
                
            }else{
                cells.mMetalName.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                if "\(mData.value(forKey: "exsits") ?? "")" == "0" {
                    cells.backgroundColor =  #colorLiteral(red: 0.8078431373, green: 0.9333333333, blue: 0.9254901961, alpha: 1)
                    cells.mMetalName.backgroundColor =  #colorLiteral(red: 0.8078431373, green: 0.9333333333, blue: 0.9254901961, alpha: 1)
                }else{
                    cells.mMetalName.backgroundColor =  #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)
                    cells.backgroundColor =  #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)
                }
                
            }
            
//            cells.layoutSubviews()
            cell = cells
            
        }else if collectionView == self.mSizeCollectionView {
            guard let cells = collectionView.dequeueReusableCell(withReuseIdentifier: "SizeCell", for: indexPath) as? SizeCell,
                  let mData = mSizeData[indexPath.row] as? NSDictionary else {
                return cell
            }
            
            cells.mSizeName.text = mData.value(forKey: "name") as? String
            
            if "\(mData.value(forKey: "select") ?? "")" == "0" {
                cells.backgroundColor =  #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
                cells.mSizeName.backgroundColor =  #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
                cells.mSizeName.textColor = #colorLiteral(red: 0.6784313725, green: 0.6784313725, blue: 0.6784313725, alpha: 1)
            }else{
                cells.mSizeName.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                if "\(mData.value(forKey: "exsits") ?? "")" == "0" {
                    cells.mSizeName.backgroundColor =  #colorLiteral(red: 0.8078431373, green: 0.9333333333, blue: 0.9254901961, alpha: 1)
                    cells.backgroundColor =  #colorLiteral(red: 0.8078431373, green: 0.9333333333, blue: 0.9254901961, alpha: 1)
                }else{
                    cells.mSizeName.backgroundColor =  #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)
                    cells.backgroundColor =  #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)
                }
            }
            
//            cells.layoutSubviews()
            cell = cells
            
        }else if collectionView == self.mStoneCollectionView {
            guard let cells = collectionView.dequeueReusableCell(withReuseIdentifier: "StoneCell", for: indexPath) as? StoneCell,
                  let mData =  mStonesData[indexPath.row] as? NSDictionary else {
                return cell
            }
            
            cells.mCStone.text = mData.value(forKey: "name") as? String
            
            if "\(mData.value(forKey: "select") ?? "")" == "0" {
                cells.backgroundColor =  #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
                cells.mCStone.backgroundColor =  #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
                cells.mCStone.textColor = #colorLiteral(red: 0.6784313725, green: 0.6784313725, blue: 0.6784313725, alpha: 1)
            }else{
                cells.mCStone.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                if "\(mData.value(forKey: "exsits") ?? "")" == "0" {
                    cells.backgroundColor =  #colorLiteral(red: 0.8078431373, green: 0.9333333333, blue: 0.9254901961, alpha: 1)
                    cells.mCStone.backgroundColor =  #colorLiteral(red: 0.8078431373, green: 0.9333333333, blue: 0.9254901961, alpha: 1)
                }else{
                    cells.backgroundColor =  #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)
                    cells.mCStone.backgroundColor =  #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)
                }
                
            }
            
//            cells.layoutSubviews()
            cell = cells
            
        }
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("didSelect =", collectionView, indexPath.row)
        print("Stone Cell Clicked =", indexPath.row)

        if mNonVariant && (collectionView == self.mStoneCollectionView || collectionView == self.mMetalCollectionView || collectionView == self.mSizeCollectionView) {
            print("⚠️ VARIANT SELECTION BLOCKED: nonVariant = true")
            return
        }

        if collectionView == self.mStoneCollectionView {
            
            if let mData = mStonesData[indexPath.row] as? NSDictionary {
                print("Stone Data =", mData)

                print("select =", mData["select"] ?? "nil")
                print("id =", mData["id"] ?? "nil")
                print("type =", type(of: mData["id"]))
                if "\(mData.value(forKey: "select") ?? "")" == "1" {
                    if let id = mData.value(forKey: "id") as? String {
                        print("Stone ID =", id)
                        if mStonesId.contains(id) {
                            mStonesId = mStonesId.filter {$0 != id }
                        }else{
                            mStonesId.append(id)
                        }
                        print("mStonesId =", mStonesId)
                    }
                    if mSearchType == "inventory" {
                       // self.mMetalsId.removeAll()
                        self.mSizeId.removeAll()
                    }
                    mGetQuickView()
                }
            }
        }
        
        
        if collectionView == self.mMetalCollectionView {
            
            if let mData = mMetalsData[indexPath.row] as? NSDictionary {
                if "\(mData.value(forKey: "select") ?? "")" == "1" {
                    if let id = mData.value(forKey: "id") as? String {
                        if mMetalsId.contains(id) {
                            mMetalsId = mMetalsId.filter {$0 != id }
                        }else{
                            mMetalsId.append(id)
                        }
                    }
                    if mSearchType == "inventory" {
                        self.mStonesId.removeAll()
                        self.mSizeId.removeAll()
                    }
                    mGetQuickView()
                }
            }
        }
        
        if collectionView == self.mSizeCollectionView {
            
            if let mData = mSizeData[indexPath.row] as? NSDictionary {
                if "\(mData.value(forKey: "select") ?? "")" == "1" {
                    if let id = mData.value(forKey: "id") as? String {
                        if mSizeId.contains(id) {
                            mSizeId = mSizeId.filter {$0 != id }
                        }else{
                            mSizeId.append(id)
                        }
                    }
                    
                    if mSearchType == "inventory" {
                        //self.mMetalsId.removeAll()
                        //self.mStonesId.removeAll()
                    }
                    mGetQuickView()
                }
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == mItemsTableView {
            return mReserveOrderData.count
        }
        return mLocationsData.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        
        var cell = UITableViewCell()
        
        if tableView == mItemsTableView {
            if let  cells = tableView.dequeueReusableCell(withIdentifier: "ReserveOrderCell") as? ReserveOrderCell {
                
                if let mData = mReserveOrderData[indexPath.row] as? NSDictionary {
                    
                    let statusProperties: [String: (textColor: UIColor, backgroundColor: UIColor, statusText: String)] = [
                        "stock": (#colorLiteral(red: 0.4588235294, green: 0.8, blue: 1, alpha: 1), #colorLiteral(red: 0.4588235294, green: 0.8, blue: 1, alpha: 1), "Stock"),
                        "reserve": (#colorLiteral(red: 1, green: 0.7386777401, blue: 0.3924969435, alpha: 1), #colorLiteral(red: 1, green: 0.7386777401, blue: 0.3924969435, alpha: 1), "Reserved"),
                        "custom_order": (#colorLiteral(red: 0.9137254902, green: 0.4392156863, blue: 0.4392156863, alpha: 1), #colorLiteral(red: 0.9137254902, green: 0.4392156863, blue: 0.4392156863, alpha: 1), "Reserved"),
                        "repair_order": (#colorLiteral(red: 0.662745098, green: 0.6078431373, blue: 0.7411764706, alpha: 1), #colorLiteral(red: 0.662745098, green: 0.6078431373, blue: 0.7411764706, alpha: 1), "Repair"),
                        "warehouse": (#colorLiteral(red: 0.4392156863, green: 0.4392156863, blue: 0.4392156863, alpha: 1), #colorLiteral(red: 0.4392156863, green: 0.4392156863, blue: 0.4392156863, alpha: 1), "Warehouse"),
                        "transit": (#colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1), #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1), "Transit")
                    ]
                    
                    if mSearchType == "inventory" {
                      
//                        if let statusType = mData.value(forKey: "status_type") as? String,
//                           let status = statusProperties[statusType] {
//
//                            cells.mStatusDot.backgroundColor = status.backgroundColor
//                        } else {
//
//                            cells.mStatusDotView.isHidden = true
//                        }
                        
                        if let statusType = mData.value(forKey: "status_type") as? String {
                            
                            if let status = statusProperties[statusType] {
                                cells.mStatusDot.backgroundColor = status.backgroundColor
                                cells.mStatusDotView.isHidden = false
                            } else {
                                cells.mStatusDotView.isHidden = true
                            }
                        } else {
                            cells.mStatusDotView.isHidden = true
                        }
                        cells.mStockName.text  = "\(mData.value(forKey: "SKU") ?? "--")"
                        cells.mStockId.text  = "\(mData.value(forKey: "stock_id") ?? "--")"
                        cells.mQuantity.text  = "\(mData.value(forKey: "po_QTY") ?? "--")"
                        cells.mAmount.text  = "\(mData.value(forKey: "formattedPrice") ?? "--")"
                        cells.mLocationName.text  = "\(mData.value(forKey: "location_name") ?? "--")"
                        cells.mStockId.isHidden = false
                        cells.mQuantity.isHidden = false
                        cells.mLocationName.isHidden = false
                        
                        if let id = mData.value(forKey: "po_product_id") as? String {
                            if mSelectedRows.contains(id) {
                                cells.mCheckIcon.image = UIImage(named: "check_item")
                            }else{
                                cells.mCheckIcon.image = UIImage(named: "uncheck_item")
                            }
                        }
                    }else{
                        print("statusProperties = \(statusProperties)")
                        print("statusType = \(mData.value(forKey: "status_type") as? String)")
                        
                        if let statusType = mData.value(forKey: "status_type") as? String,
                           let status = statusProperties[statusType] {
                            cells.mStatusDot.backgroundColor = status.backgroundColor
                            cells.mStatusDotView.isHidden = false
                        } else {
                            cells.mStatusDotView.isHidden = true
                        }
                        cells.mStockName.text  = "\(mData.value(forKey: "SKU") ?? "--")"
                        cells.mStockId.isHidden = true
                        cells.mQuantity.isHidden = true
                        cells.mAmount.text  = "\(mData.value(forKey: "formattedPrice") ?? "--")"
                        cells.mLocationName.isHidden = true
                        
                        if let id = mData.value(forKey: "id") as? String , mSelectedRows.contains(id) {
                            cells.mCheckIcon.image = UIImage(named: "check_item")
                        }else{
                            cells.mCheckIcon.image = UIImage(named: "uncheck_item")
                        }
                        
                    }
                    
                    if (indexPath.row % 2 == 0) {
                        cells.mView.backgroundColor = UIColor(named: "themeBackground")
                    }else{
                        cells.mView.backgroundColor = #colorLiteral(red: 0.9568627451, green: 0.9568627451, blue: 0.9568627451, alpha: 1)
                        
                    }
                    
//                    cells.layoutSubviews()
                }
                cell = cells
            }
        }else {
            
            guard let  cells = tableView.dequeueReusableCell(withIdentifier: "QuickViewLocationCell") as? QuickViewLocationCell,
                  let mData = mLocationsData[indexPath.row] as? NSDictionary else {
                return cell
            }
            
            cells.mView.backgroundColor = UIColor(named: "themeBackground")

            // Catalog: Location is display-only. Hide the radio/check icon
            // and disable row interaction. Inventory keeps the selectable UI.
            if mSearchType == "catalog" {
                cells.mCheckIcon.isHidden = true
                cells.selectionStyle = .none
                cells.isUserInteractionEnabled = false
            } else {
                cells.mCheckIcon.isHidden = false
                cells.selectionStyle = .default
                cells.isUserInteractionEnabled = true
            }
            
            cells.mLocationName.text = mData.value(forKey: "name") as? String
            
            cells.mQuantity.text = "\(mData.value(forKey: "qty") ?? "0")"
            
            cells.mLocationName.backgroundColor =  #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            cells.mQuantity.backgroundColor =  #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            if "\(mData.value(forKey: "qty") ?? "1")" == "0" {
                
                cells.mLocationName.textColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
                cells.mQuantity.textColor =  #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
                
            }else{
                cells.mQuantity.textColor = UIColor(named: "themeColor")
                cells.mLocationName.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            }
            
//            if mSearchType == "inventory" {
//                if mLocationsId.isEmpty {
//                    mBottomViewHeight.constant = 0
//                    mReserveButton.isHidden = true
//                    mOrderButton.isHidden = true
//                }else{
//                    mBottomViewHeight.constant = 120
//                    self.view.layoutIfNeeded()
//                    mReserveButton.isHidden = false
//                    mOrderButton.isHidden = false
//                }
//            }
            if mSearchType == "inventory" {
                print("mLocationsId.contains(\(mData.value(forKey: "id") as! String)) = \(mLocationsId.contains(mData.value(forKey: "id") as! String))")
                print("mLocationsId = \(mLocationsId)")
                
                if let id = mData.value(forKey: "id") as? String ,mLocationsId.contains(id) {
                    cells.mCheckIcon.image = UIImage(named: "check_item")
                }else{
                    cells.mCheckIcon.image = UIImage(named: "uncheck_item")
                }
            }
            
//            cells.layoutSubviews()
            cell = cells
        }
        
        
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == mItemsTableView {
            
            if let mData = mReserveOrderData[indexPath.row] as? NSDictionary {
                print("===== SELECTED ITEM =====")
                print(mData)
                print("=========================")
                if let id = mData["id"] as? String {
                    print("Selected id =", id)
                }
                if mSearchType == "inventory" {
                    
                    guard let poProductId = mData.value(forKey: "po_product_id") as? String else {
                        return
                    }
                    if poProductId == "0" {
                        return
                    }
                    
                    if mSelectedRows.contains(poProductId) {
                        mSelectedRows = mSelectedRows.filter {$0 != poProductId }
                        
                        if let mInvData = mReserveOrderData[indexPath.row] as? NSDictionary {
                            
                            let mData = NSMutableDictionary()
                            mData.setValue("\(mInvData.value(forKey: "po_product_id") ?? "")", forKey: "id")
                            mData.setValue("1", forKey: "quantity")
//                            mData.setValue("\(mInvData.value(forKey: "po_QTY") ?? "0")", forKey: "po_QTY")
                            if let productDetails = mInvData["product_details"] as? NSDictionary {

                                mData.setValue(
                                    "\(productDetails["po_QTY"] ?? "0")",
                                    forKey: "po_QTY"
                                )

                            } else {

                                mData.setValue(
                                    "\(mInvData["po_QTY"] ?? "0")",
                                    forKey: "po_QTY"
                                )
                            }
                            mData.setValue("\(mInvData.value(forKey: "SKU") ?? "")", forKey: "sku")
                            mData.setValue("\(mInvData.value(forKey: "stock_id") ?? "")", forKey: "stockId")
                            mData.setValue("\(mInvData.value(forKey: "formattedPrice") ?? "")", forKey: "formattedPrice")
                            mData.setValue("\(mInvData.value(forKey: "price") ?? "")", forKey: "price")
                            mData.setValue("\(mInvData.value(forKey: "Matatag") ?? "")", forKey: "Matatag")
                            mData.setValue("\(mInvData.value(forKey: "main_image") ?? "")", forKey: "image")
                            mData.setValue("\(mInvData.value(forKey: "metal_name") ?? "")", forKey: "metal")
                            mData.setValue("\(mInvData.value(forKey: "size_name") ?? "")", forKey: "size")
                            let currentDateTime = Date()
                            let formatter = DateFormatter()
//                            formatter.dateFormat = "MM/dd/yyy"
                            formatter.dateFormat = "MM/dd/yyyy"
                            mData.setValue("\(formatter.string(from: currentDateTime))", forKey: "dueDate")
                            mData.setValue("", forKey: "notes")
                            mReserveData.remove(mData)
                        }
                    }else{
                        
                        mSelectedRows.append(poProductId)
                        
                        if let mInvData = mReserveOrderData[indexPath.row] as? NSDictionary {
                            let mData = NSMutableDictionary()
                            mData.setValue("\(mInvData.value(forKey: "po_product_id") ?? "")", forKey: "id")
                            mData.setValue("1", forKey: "quantity")
//                            mData.setValue("\(mInvData.value(forKey: "po_QTY") ?? "0")", forKey: "po_QTY")
                            if let productDetails = mInvData["product_details"] as? NSDictionary {

                                mData.setValue(
                                    "\(productDetails["po_QTY"] ?? "0")",
                                    forKey: "po_QTY"
                                )

                            } else {

                                mData.setValue(
                                    "\(mInvData["po_QTY"] ?? "0")",
                                    forKey: "po_QTY"
                                )
                            }
                            mData.setValue("\(mInvData.value(forKey: "SKU") ?? "")", forKey: "sku")
                            mData.setValue("\(mInvData.value(forKey: "stock_id") ?? "")", forKey: "stockId")
                            mData.setValue("\(mInvData.value(forKey: "price") ?? "0.0")", forKey: "price")
                            mData.setValue("\(mInvData.value(forKey: "formattedPrice") ?? "")", forKey: "formattedPrice")
                            mData.setValue("\(mInvData.value(forKey: "Matatag") ?? "")", forKey: "Matatag")
                            mData.setValue("\(mInvData.value(forKey: "main_image") ?? "")", forKey: "image")
                            mData.setValue("\(mInvData.value(forKey: "metal_name") ?? "")", forKey: "metal")
                            mData.setValue("\(mInvData.value(forKey: "size_name") ?? "")", forKey: "size")
                            let currentDateTime = Date()
                            let formatter = DateFormatter()
//                            formatter.dateFormat = "MM/dd/yyy"
                            formatter.dateFormat = "MM/dd/yyyy"
                            mData.setValue("\(formatter.string(from: currentDateTime))", forKey: "dueDate")
                            mData.setValue("", forKey: "notes")
                            mReserveData.add(mData)
                            
                        }
                    }
                }else{
                    // Catalog/Home item list: keep item selection separate from Location selection.
                    // Location IDs must never be inserted into mSelectedRows.
                    if let id = mData.value(forKey: "id") as? String {
                        if mSelectedRows.contains(id) {
                            mSelectedRows = mSelectedRows.filter { $0 != id }
                        } else {
                            mSelectedRows.append(id)
                        }
                    }
                }
                
                self.mItemsTableView.reloadData()
                self.updateConfirmButton()
                
                return
            }
        }
        
        if tableView == mLocationTableView {

            // Catalog Location rows are display-only. They must not be
            // selectable and must not change mLocationsId.
            guard mSearchType == "inventory" else {
                return
            }

            guard let mData = mLocationsData[indexPath.row] as? NSDictionary else {
                return
            }

            if "\(mData.value(forKey: "qty") ?? "0")" == "0" {
                return
            }

            let id = "\(mData.value(forKey: "id") ?? "")"
                .trimmingCharacters(in: .whitespacesAndNewlines)

            if !id.isEmpty {
                if mLocationsId.contains(id) {
                    mLocationsId.removeAll()
                    mSelectedReserveLocationId = ""
                    mIsCrossLocationReserve = false
                } else {
                    // Quick View selects one Location at a time.
                    mLocationsId = [id]
                    mSelectedReserveLocationId = id

                    let currentLocationId =
                        UserDefaults.standard.string(forKey: "location") ?? ""

                    mIsCrossLocationReserve =
                        !currentLocationId.isEmpty &&
                        currentLocationId != mSelectedReserveLocationId

                    print("LOGIN LOCATION =", currentLocationId)
                    print("RESERVE LOCATION =", mSelectedReserveLocationId)
                    print("CROSS LOCATION =", mIsCrossLocationReserve)
                }

                updateActionButtons()

                print("===== LOCATION SELECTED =====")
                print("SEARCH TYPE =", mSearchType)
                print("SELECTED LOCATION =", mSelectedReserveLocationId)
                print("LOCATIONS ID =", mLocationsId)
                print("ORDER HIDDEN =", mOrderButton.isHidden)
                print("ORDER ENABLED =", mOrderButton.isEnabled)
                print("ORDER TITLE =", mOrderButton.title(for: .normal) ?? "nil")
                print("================================")
            }

            mLocationTableView.reloadData()
            return
        }
//        if let mData = mLocationsData[indexPath.row] as? NSDictionary {
//            if "\(mData.value(forKey: "qty") ?? "0")" == "0" {
//                return
//            }
//            if let id = mData.value(forKey: "id") as? String {
//                if mLocationsId.contains(id) {
//                    mLocationsId = mLocationsId.filter {$0 != id }
//                }else{
//                    mLocationsId.append(id)
//                }
//            }
//            self.mLocationTableView.reloadData()
//        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if tableView == mItemsTableView {
            return 60
        }
        return 43
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if scrollView == self.mProductCollectionView {
            var currentCellOffset = self.mProductCollectionView.contentOffset
            currentCellOffset.x += self.mProductCollectionView.frame.width / 2
            if let indexPath = self.mProductCollectionView.indexPathForItem(at: currentCellOffset) {
                self.mPageController.currentPage = indexPath.row
                self.mProductCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            }
        }
    }
    
//    private func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
//                                sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
//
//        let numberOfSets = CGFloat(1)
//
//        let width = (collectionView.frame.size.width - (numberOfSets * view.frame.size.width / 15))/numberOfSets
//
//        let height = collectionView.frame.size.height - 32
//
//        return CGSize(width: width, height: height)
//    }
    
//    func collectionView(
//        _ collectionView: UICollectionView,
//        layout collectionViewLayout: UICollectionViewLayout,
//        sizeForItemAt indexPath: IndexPath
//    ) -> CGSize {
//
//        let numberOfSets: CGFloat = 1
//
//        let width =
//            (collectionView.frame.size.width
//            - (numberOfSets * view.frame.size.width / 15))
//            / numberOfSets
//
//        let height = collectionView.frame.size.height - 32
//
//        print(
//            "LAYOUT DEBUG:",
//            collectionView,
//            "width =", width,
//            "height =", height
//        )
//
//        return CGSize(
//            width: width,
//            height: height
//        )
//    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {

        if collectionView == mMetalCollectionView {
            return CGSize(width: 90, height: 48)
        }

        if collectionView == mStoneCollectionView {
            return CGSize(width: 120, height: 48)
        }

        if collectionView == mSizeCollectionView {

            let spacing: CGFloat = 10
            let totalSpacing = spacing * 2

            let width = (collectionView.bounds.width - totalSpacing) / 3

            return CGSize(width: floor(width), height: 48)
        }

        return CGSize(width: 50, height: 50)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return collectionView == mSizeCollectionView ? 10 : 8
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return collectionView == mSizeCollectionView ? 10 : 8
    }
    
//    func collectionView(
//        _ collectionView: UICollectionView,
//        layout collectionViewLayout: UICollectionViewLayout,
//        sizeForItemAt indexPath: IndexPath
//    ) -> CGSize {
//
//        if collectionView == mMetalCollectionView {
//
//            return CGSize(width: 90, height: 36)
//
//        } else if collectionView == mStoneCollectionView {
//
//            return CGSize(width: 120, height: 36)
//
//        } else if collectionView == mSizeCollectionView {
//
//            return CGSize(width: 90, height: 36)
//        }
//
//        return CGSize(width: 50, height: 50)
//    }
    
    
    @IBAction func mClearAllFilters(_ sender: Any) {
        
        
        self.mMetalsId.removeAll()
        self.mStonesId.removeAll()
        self.mLocationsId.removeAll()
        self.mSizeId.removeAll()
        
        mGetQuickView()
        
        
        
    }
    
    @IBAction func mSelectAll(_ sender: UIButton) {
        mMetalsId.removeAll()
        mSizeId.removeAll()
        mStonesId.removeAll()
        mGetQuickView()
    }
    
    func mGetQuickView(){
        mReserveData = NSMutableArray()
        
        
        var mUrl = ""
        var params = [String: Any]()
        if mSearchType == "catalog" {
            mUrl =  mGetQuickViewCatalogData
            params = ["search": mSKUName ,"metal": self.mMetalsId, "stone": self.mStonesId,"size": self.mSizeId,  "type": mSearchType] as [String : Any]
            
        }else{
            mUrl = mGetQuickViewData
            params = ["search": mSKUName ,"metal": self.mMetalsId, "stone": self.mStonesId,"size": self.mSizeId,  "type": mSearchType] as [String : Any]
        }
        print("========== SELECTED FILTER ==========")
        print("Selected Stone =", self.mStonesId)
        print("Selected Metal =", self.mMetalsId)
        print("Selected Size =", self.mSizeId)
        print("=====================================")
        
        print("URL =", mUrl)
        print("BODY =", params)
        if Reachability.isConnectedToNetwork() == true {
            CommonClass.showFullLoader(view: self.view)
            let apiStartTime = CFAbsoluteTimeGetCurrent()
            let apiStartDate = Date()

            print("========== QUICK VIEW API START ==========")
            print("API URL =", mUrl)
            print("API BODY =", params)
            print("API START TIME =", apiStartDate)

            AF.request(mUrl, method:.post,parameters: params,encoding: JSONEncoding.default, headers: sGisHeaders).responseJSON
            { response in
                let apiEndTime = Date()
                let apiDuration = CFAbsoluteTimeGetCurrent() - apiStartTime

                print("========== QUICK VIEW API END ==========")
                print("API URL =", mUrl)
                print("API END TIME =", apiEndTime)
                print(String(format: "⏱ QUICK VIEW API DURATION = %.3f seconds (%.0f ms)",
                             apiDuration,
                             apiDuration * 1000))
                print("HTTP STATUS =", response.response?.statusCode ?? 0)
                print("=========================================")

                print(response.response?.statusCode ?? 0)
                print(String(data: response.data ?? Data(), encoding: .utf8) ?? "")
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
                    
                    if let mCode =  jsonResult.value(forKey: "code") as? Int {
                        if mCode == 403 {
                            CommonClass.sessionExpired(isExpired: true, navigation: self.navigationController)
                            return
                        }
                    }
                    
                    if jsonResult.value(forKey: "code") as? Int == 200 {
                        
                        self.mBottomViewHeight.constant = 0
                        self.mReserveButton.isHidden = true
                        self.mOrderButton.isHidden = true
                        
                        if jsonResult.value(forKey: "productList") == nil {
                            CommonClass.showSnackBar(message: "No Data Found!")
                            return
                        }
                        
                        if let mData = jsonResult.value(forKey: "productList") as? NSDictionary {
                            print("========== PRODUCT LIST ==========")
                            print(mData)
                            print("==================================")
                            print("===== RESULT CATALOG =====")
                            print("main_id =", mData["main_id"] ?? "nil")
                            print("product_ids =", mData["product_ids"] ?? [])
                            print("==========================")
                            self.mLocationCount.text = "(\(mData.value(forKey: "total_qty") ?? "0"))"

                            self.mNonVariant = (mData.value(forKey: "nonVariant") as? Bool) ??
                                               (mData.value(forKey: "nonvariant") as? Bool) ?? false

                            if self.mNonVariant {
                                // No variants: clear any previously selected variant IDs as well.
                                self.mMetalsId.removeAll()
                                self.mStonesId.removeAll()
                                self.mSizeId.removeAll()
                            }

                            self.updateVariantControls()

                            self.mMetalsData = (mData.value(forKey: "metal") as? NSArray) ?? NSArray()
                            self.mStonesData = (mData.value(forKey: "Stone") as? NSArray) ?? NSArray()
                            self.mSizeData = (mData.value(forKey: "size") as? NSArray) ?? NSArray()

                            self.mMetalCollectionView.reloadData()
                            self.mStoneCollectionView.reloadData()
                            self.mSizeCollectionView.reloadData()
                            
                            if let mMetal = mData.value(forKey: "metal") as? NSArray {
                                if mMetal.count > 0 {
                                    self.mMetalsData = mMetal
                                    self.mMetalCollectionView.reloadData()
                                }else{
                                    self.mMetalCollectionView.reloadData()
                                }
                            }

                            if let mStone = mData.value(forKey: "Stone") as? NSArray {
                                if mStone.count > 0 {
                                    self.mStonesData = mStone
                                    self.mStoneCollectionView.reloadData()
                                    self.mStoneCollectionView.layoutIfNeeded()
                                    //self.mStoneViewHeight.constant = self.mStoneCollectionView.contentSize.height + 60

                                }else{
                                    self.mStoneCollectionView.reloadData()
                                    
                                }
                            }
                            
                            if let mSized = mData.value(forKey: "size") as? NSArray {
                                if mSized.count > 0 {
                                    self.mSizeData = mSized
                                    self.mSizeCollectionView.reloadData()
                                }else{
                                    self.mSizeCollectionView.reloadData()
                                    
                                }
                            }
                            
                            
                            print("===== QUICK VIEW CATALOG =====")
                            print("product_ids =", mData.value(forKey: "product_ids") ?? "nil")
                            print("==============================")
                            
                            print("========== QUICK VIEW API ==========")
                            print("SEARCH TYPE =", self.mSearchType)
                            print("PRODUCT IDS =", mData.value(forKey: "product_ids") ?? "nil")
                            print("LOCATION =", mData.value(forKey: "lcoation") ?? "nil")
                            print("====================================")
                            
                            if let mainId = mData["main_id"] as? String {
                                // New API response uses main_id for the mother product.
                                // product_ids may be nil, so always use main_id when available.
                                self.mProductIds = [mainId]
                            } else if let ids = mData["product_ids"] as? [String] {
                                // Backward compatibility for older responses.
                                self.mProductIds = ids
                            } else {
                                self.mProductIds.removeAll()
                            }

                            // Inventory: ADD TO CART + RESERVE after Location.
                            // Catalog/Home: ADD TO ORDER is available immediately;
                            // Location rows are display-only.
                            self.updateActionButtons()
                            
//                            if let mProductId = mData.value(forKey: "product_ids") as? [String] {
//                                print("✅ PRODUCT IDS COUNT =", mProductId.count)
//                                self.mProductIds = mProductId
//
//                                self.mBottomViewHeight.constant = 120
//                                self.view.layoutIfNeeded()
//                                if self.mSearchType == "catalog" {
//
//                                    // Catalog
//                                    self.mReserveButton.isHidden = true
//                                    self.mOrderButton.isHidden = false
//
//                                } else {
//
//                                    // Inventory
//                                    self.mReserveButton.isHidden = false
//                                    self.mOrderButton.isHidden = false
//
//                                }
//
//
//                            }else{
//                                print("❌ product_ids is nil")
//                                self.mProductIds = [String]()
//                            }
                            
                            self.mLocationsData = NSArray()
                            
                            if let mLocation = mData.value(forKey: "lcoation") as? NSArray {
                                
                                if mLocation.count > 0 {
                                    let finalLocations = NSMutableArray()
                                    for obj in mLocation {
                                        if let item = obj as? NSDictionary, let qty = item.value(forKey: "qty") as? Int, qty != 0 {
                                            finalLocations.add(obj)
                                        }
                                    }
                                    
                                    self.mLocationsData = finalLocations as NSArray

                                    let validLocationIds = finalLocations.compactMap {
                                        ($0 as? NSDictionary)?.value(forKey: "id") as? String
                                    }
                                    if !self.mSelectedReserveLocationId.isEmpty && !validLocationIds.contains(self.mSelectedReserveLocationId) {
                                        self.mSelectedReserveLocationId = ""
                                        self.mLocationsId.removeAll()
                                    } else if !self.mSelectedReserveLocationId.isEmpty {
                                        self.mLocationsId = [self.mSelectedReserveLocationId]
                                    }

                                    self.updateActionButtons()
                                    print("===== BEFORE RELOAD =====")
                                    print("product_ids =", self.mProductIds)
                                    print("locations =", self.mLocationsData.count)
                                    print("selectedLocation =", self.mSelectedReserveLocationId)
                                    print("=========================")
                                    self.mLocationTableView.reloadData()
                                    self.mLocationTableView.layoutIfNeeded()
                                    self.mLocationViewHeight.constant = self.mLocationTableView.contentSize.height + 60
                                    print("===== AFTER RELOAD =====")
                                    print("orderEnabled =", self.mOrderButton.isEnabled)
                                    print("hidden =",self.mOrderButton.isHidden)
                                    print("========================")
                                    
                                }else{
                                    self.mLocationsData = NSArray()
                                    self.mLocationsId.removeAll()
                                    self.mSelectedReserveLocationId = ""
                                    self.updateActionButtons()
                                    self.mLocationTableView.reloadData()
                                }
                            }
                        }
                        self.mLocationTableView.reloadData()
                        
                        
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
}
