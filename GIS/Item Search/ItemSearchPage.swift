//
//  ItemSearchPage.swift
//  GIS
//
//  Created by Apple Hawkscode on 11/12/20.
//

import UIKit
import Alamofire
import DropDown
import AVFoundation

public class ItemSearchCell: UITableViewCell {
    
    
    @IBOutlet weak var mView: UIView!
    @IBOutlet weak var mAvailable: UILabel!
    @IBOutlet weak var mSold: UILabel!
    @IBOutlet weak var mReserve: UILabel!
    @IBOutlet weak var mStock: UILabel!
    @IBOutlet weak var mLocation: UILabel!
    @IBOutlet weak var mCheckVIew: UIView!
    @IBOutlet weak var mCheckIcon: UIImageView!
    
    @IBOutlet weak var mStockButton: UIButton!
    @IBOutlet weak var mReserveButton: UIButton!
    @IBOutlet weak var mSoldButton: UIButton!
    @IBOutlet weak var mAvailableButton: UIButton!
    
    public override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
    }
    
    
    
    
}

public class SuggestionsSearchCell: UITableViewCell {
    
    @IBOutlet weak var sSuggestionLabel: UILabel!
}

class ReserveCells: UITableViewCell {
    
    @IBOutlet weak var mSKUName: UILabel!
    @IBOutlet weak var mStockId: UILabel!
    
    @IBOutlet weak var mQuantity: UITextField!
    @IBOutlet weak var mPrice: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}

class ItemSearchPage: UIViewController ,  UITableViewDelegate , UITableViewDataSource ,UICollectionViewDelegate , UICollectionViewDataSource, UICollectionViewDelegateFlowLayout , UITextFieldDelegate, AVCaptureMetadataOutputObjectsDelegate, ScannerDelegate, UIViewControllerTransitioningDelegate, GetCustomerDataDelegate, UIGestureRecognizerDelegate {

    private var selectedSalesPersonId: String {
        return (UserDefaults.standard.string(forKey: "SALESPERSONID") ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    
    
    /**Bottom ReserveOrder View*/
    var mSelectedRows = [String]()
    @IBOutlet weak var mParentView: UIView!
    
    @IBOutlet weak var mReserveOrderListView: UIView!
    @IBOutlet weak var mItemsTableView: UITableView!
    
    @IBOutlet weak var mListType: UILabel!
    
    @IBOutlet weak var mLocation: UILabel!
    var mReserveOrderData = NSArray()
    var mCurrentLocation = ""
    @IBOutlet weak var mConfirmButton: UIButton!
    
    
    @IBOutlet weak var mOrderNowButton: UIButton!
    
    @IBOutlet weak var mReserveNowButton: UIButton!
    
    @IBOutlet weak var mBottomReserveView: UIView!
    
    @IBOutlet weak var mBottomViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var mSKUName: UILabel!
    
    @IBOutlet weak var mMetaTag: UILabel!
    
    @IBOutlet weak var mLocationName: UILabel!
    @IBOutlet weak var mMetalName: UILabel!
    @IBOutlet weak var mStoneName: UILabel!
    @IBOutlet weak var mSizeName: UILabel!
    @IBOutlet weak var mCollectionName: UILabel!
    
    /**Short Summary*/
    @IBOutlet weak var mMaterialName: UILabel!
    @IBOutlet weak var mMaterialWeight: UILabel!
    
    @IBOutlet weak var mStoneOne: UILabel!
    @IBOutlet weak var mStoneOneWeight: UILabel!
    @IBOutlet weak var mStoneTwo: UILabel!
    @IBOutlet weak var mStoneTwoWeight: UILabel!
    
    @IBOutlet weak var mCertificateName: UILabel!
    @IBOutlet weak var mCertificateNumber: UILabel!
    @IBOutlet weak var mReferenceName: UILabel!
    @IBOutlet weak var mProductSummaryView: UIStackView!
    
    @IBOutlet weak var mShowHideButton: UIButton!
    @IBOutlet weak var mShowHideSummaryIcon: UIImageView!
    
    @IBOutlet weak var mSwitchIcon: UIImageView!
    
    
    let shape = CAShapeLayer()
    let layer = CAGradientLayer()
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    @IBOutlet weak var mProductImage: UIImageView!
    @IBOutlet weak var mTotalAvailable: UILabel!
    @IBOutlet weak var mTotalSold: UILabel!
    @IBOutlet weak var mTotalReserve: UILabel!
    @IBOutlet weak var mTotalStock: UILabel!
    var mSearchType = "catalog"
    var mSearchData = NSArray()
    @IBOutlet weak var mStockImage: UIImageView!
    
    @IBOutlet weak var mSKUImage: UIImageView!
    
    @IBOutlet weak var mReserveHeader: UIView!
    @IBOutlet weak var mSearchField: UITextField!
    
    @IBOutlet weak var mSubmitReserveView: UIView!
    
    
    @IBOutlet weak var mReserveTableView: UITableView!
    @IBOutlet weak var mSubmitReserve: UIButton!
    
    @IBOutlet weak var mFilterView: UIView!
    
    @IBOutlet weak var mSubFilterView: UIView!
    
    @IBOutlet weak var mApplyFilterButton: UIButton!
    
    @IBOutlet weak var mBottomView: UIView!
    @IBOutlet weak var mItemSearchTableView: UITableView!
    
    
    @IBOutlet weak var mOrderIcon: UIImageView!
    @IBOutlet weak var mReserveIcon: UIImageView!
    @IBOutlet weak var mPrintIcon: UIImageView!
    @IBOutlet weak var mShareIcon: UIImageView!
    @IBOutlet weak var mPrintLabel: UILabel!
    @IBOutlet weak var mReserveLabel: UILabel!
    @IBOutlet weak var mShareLabel: UILabel!
    @IBOutlet weak var mOrderLabel: UILabel!
    
    
    @IBOutlet weak var mItemCollectionView: UICollectionView!
    @IBOutlet weak var mCollectCollectionView: UICollectionView!
    @IBOutlet weak var mMetalCollectionView: UICollectionView!
    @IBOutlet weak var mStoneCollectionView: UICollectionView!
    
    @IBOutlet weak var mLocationCollectionView: UICollectionView!
    
    
    
    var mReservProductsData = NSMutableArray()
    var mIndex = -1
    var mSelectedItems = [String]()
    var mSelectedData = [String]()
    
    var mReserveData = NSMutableArray()
    
    @IBOutlet weak var mReserveTotal: UILabel!
    var mLocationData = NSMutableArray()
    var mSearchKeys = ""
    var mSearchTypes = ""
    
    var isOrder = false

    // Prevent multiple CONFIRM taps while the request/navigation is in progress.
    private var isConfirmProcessing = false

    @IBOutlet weak var mCustomerSearch: UITextField!
    var mSearchCustomerData = NSArray()
    let mCustomerSearchTableView = UITableView()
    @IBOutlet weak var mCustomerSearchView: UIView!
    @IBOutlet weak var mCustomerDetailView: UIView!
    @IBOutlet weak var mCustomerNames: UILabel!
    @IBOutlet weak var mCustomerAddresss: UILabel!
    @IBOutlet weak var mCustomerNumbers: UILabel!
    @IBOutlet weak var mSalesPersonName: UILabel!
    var mSalesManList = [String]()
    var mSalesManIDList = [String]()
    var mCustomerId = ""
    var mSalesPersonId = ""
    
    
    @IBOutlet weak var mItemSearchLABEL: UILabel!
    
    
    @IBOutlet weak var mChooseStockBUTTON: UIButton!
    
    @IBOutlet weak var mChooseSKUBUTTON: UIButton!
    @IBOutlet weak var mMetalLABEL: UILabel!
    @IBOutlet weak var mStoneLABEL: UILabel!
    
    @IBOutlet weak var mCollectionLABEL: UILabel!
    
    @IBOutlet weak var mProductSummaryLABEL: UILabel!
    @IBOutlet weak var mMaterialLABEL: UILabel!
    @IBOutlet weak var mPStoneLABEL: UILabel!
    @IBOutlet weak var mReferenceNoLABEL: UILabel!
    @IBOutlet weak var mCertificateLABEL: UILabel!
    
    @IBOutlet weak var mBottomReserveListLABEL: UILabel!
    
    @IBOutlet weak var mBottomPreviewLABEL: UILabel!
    @IBOutlet weak var mBottomCustomerLABEL: UILabel!
    
    @IBOutlet weak var mSizeLABEL: UILabel!
    @IBOutlet weak var mHStockLABEL: UILabel!
    @IBOutlet weak var mHReserveLABEL: UILabel!
    @IBOutlet weak var mHSoldLABEL: UILabel!
    @IBOutlet weak var mHAvailabelLABEL: UILabel!
    
    
    
    
    @IBOutlet weak var mReserveRecordsLABEL: UILabel!
    
    @IBOutlet weak var mRCancelBUTTON: UIButton!
    
    @IBOutlet weak var mRSalesPersonLABEL: UILabel!
    @IBOutlet weak var mRSubmitBUTTON: UIButton!
    
    @IBOutlet weak var mRSKULABEL: UILabel!
    
    @IBOutlet weak var mRStockIdLABEL: UILabel!
    @IBOutlet weak var mRPriceLABEL: UILabel!
    
    @IBOutlet weak var mRQtyLABEL: UILabel!
    
    @IBOutlet weak var mRTotalLABEL: UILabel!
    @IBOutlet weak var mRRemarkLABEL: UILabel!
    
    var mProductIdForImage = ""
    var mSKUForImage = ""
    
    @IBOutlet weak var sSuggestionsView: UIView!
    @IBOutlet weak var sSuggestionsTable: UITableView!
    var sSuggestionsList: [[String: Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ItemSearchPage.swift viewDidLoad")
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTapImage))
        tap.delegate = self
        mProductImage.isUserInteractionEnabled = true
        mProductImage.addGestureRecognizer(tap)
        
        mBottomView.layer.cornerRadius = 10
        mBottomView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        mBottomView.dropShadow()
        
        mBottomReserveView.layer.cornerRadius = 10
        mBottomReserveView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        mBottomReserveView.dropShadow()
        
        mReserveOrderListView.layer.cornerRadius = 20
        mReserveOrderListView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        mReserveOrderListView.dropShadow()
        mReserveOrderListView.isHidden =  true
        
        mSearchType = "catalog"
        mSearchField.placeholder = "Search by SKU".localizedString
        mSwitchIcon.image = UIImage(named: "sku_id_ic")
        
        mSearchField.delegate = self
        sSuggestionsTable.delegate = self
        sSuggestionsTable.dataSource = self
    }
    
    @objc
    func onTapImage() {
        if mProductIdForImage != "" {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Test", bundle: nil)
            guard let mGlobalImageViewer = storyBoard.instantiateViewController(withIdentifier: "GlobalImageViewer") as? GlobalImageViewer else { return }
            mGlobalImageViewer.modalPresentationStyle = .overFullScreen
            mGlobalImageViewer.mProductId = mProductIdForImage
            mGlobalImageViewer.mSKUName = mSKUForImage
            mGlobalImageViewer.transitioningDelegate = self
            self.present(mGlobalImageViewer,animated: false)
        }
    }
    override func viewDidLayoutSubviews() {
        
    }
    
    @IBAction func mGoToSearch(_ sender: Any) {
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        guard let home = storyBoard.instantiateViewController(withIdentifier: "CustomOrderSearch") as? CustomOrderSearch else { return }
        home.mType = "Quick View"
        self.navigationController?.pushViewController(home, animated:true)
    }
    override func viewWillAppear(_ animated: Bool) {
        
        mCollectionLABEL.text = "Collection".localizedString
        
        mProductSummaryLABEL.text = "Product Summary".localizedString
        mMaterialLABEL.text = "Material".localizedString
        mPStoneLABEL.text = "Stone".localizedString
        mReferenceNoLABEL.text = "Reference No.".localizedString
        mCertificateLABEL.text = "Certificate".localizedString
        
        mBottomReserveListLABEL.text = "Reserve List".localizedString
        mBottomCustomerLABEL.text = "Customer".localizedString
        mBottomPreviewLABEL.text = "Preview".localizedString
        mSearchField.placeholder = "Search by SKU".localizedString
        mItemSearchLABEL.text = "Item Search".localizedString
        
        mOrderNowButton.setTitle("ORDER".localizedString, for: .normal)
        mReserveNowButton.setTitle("RESERVE".localizedString, for: .normal)
        mConfirmButton.setTitle("CONFIRM".localizedString, for: .normal)
        
        mMetalLABEL.text = "Metal".localizedString
        mStoneLABEL.text = "Stone".localizedString
        mSizeLABEL.text = "Size".localizedString
        mHStockLABEL.text = "Stock".localizedString
        mHReserveLABEL.text = "Reserved".localizedString
        mHSoldLABEL.text = "Sold".localizedString
        mHAvailabelLABEL.text = "Available".localizedString
        // viewWillAppear is called again when returning from Checkout.
        // Keep the header consistent with the current search type.
        mListType.text = (mSearchType == "catalog" ? "SKU" : "stock_id").localizedString
        
        
        
        
        addDoneButtonOnKeyboard()
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
        mSearchField.resignFirstResponder()
        if mSearchField.text != "" {
            mSearchProductByKeys(value:mSearchField.text ?? "")
        } else {
            clearItemSearchPage()
        }
        sSuggestionsView.isHidden = true
        sSuggestionsList.removeAll()
        
    }
    
    
    
    
    @IBAction func mOrderNow(_ sender: Any) {
        isOrder = true
        mFetchData(type: "Order")
        
    }
    
    
    @IBAction func mReserveNow(_ sender: Any) {
        isOrder = false
        
        mFetchData(type: "Reserve")
        
        
    }
    
    /// Returns true only when this location has stock available for a new Reserve.
    private func isAvailableForReserve(_ data: NSDictionary) -> Bool {
        if let available = data.value(forKey: "available") as? Int {
            return available > 0
        }
        if let available = data.value(forKey: "available") as? NSNumber {
            return available.intValue > 0
        }
        if let available = data.value(forKey: "available") as? String,
           let value = Int(available) {
            return value > 0
        }
        return false
    }

    func mFetchData(type: String) {
        
        if mSelectedItems.isEmpty {
            CommonClass.showSnackBar(message: "Please select items.")
            return
        }
        mSelectedRows = [String]()
        
        CommonClass.showFullLoader(view: self.view)
        let type = mSearchType == "catalog" ? "SKU" : "stock_id"


        let params:[String: Any] = ["search" : mSearchField.text ?? "", "location_id":mSelectedItems, "type":type]
        // Start API timer
        let apiStartTime = Date()
        print("========== mOrderNow API START ==========")
        print("mGetItemSearchReserveOrderData START: \(apiStartTime)")
        mGetData(url: mGetItemSearchReserveOrderData,headers: sGisHeaders,  params: params) { response , status in
            // End API timer
           let apiEndTime = Date()
           let elapsedTime = apiEndTime.timeIntervalSince(apiStartTime)
            print("mGetItemSearchReserveOrderData END: \(apiEndTime)")
            print(String(format: "API RESPONSE TIME: %.3f seconds", elapsedTime))
            print("================================")
            CommonClass.stopLoader()
            print("ItemSearchPage mGetItemSearchReserveOrderData = \(response)")
            if status {
                if "\(response.value(forKey: "code") ?? "")" == "200" {
                    if let mData = response.value(forKey: "data") as? NSArray {
                        
                        self.mReserveOrderData = mData
                        
                        self.mParentView.isHidden = false
                        self.mReserveOrderListView.isHidden =  false
                        self.mReserveOrderListView.slideFromBottom()
                        
                        self.mListType.text = type.localizedString
                        self.mLocation.text = ""
                        
                        
                        self.mItemsTableView.delegate = self
                        self.mItemsTableView.dataSource = self
                        self.mItemsTableView.reloadData()
                    }
                    
                } else if "\(response.value(forKey: "code") ?? "")" == "403"{
                    CommonClass.sessionExpired(isExpired: true, navigation: self.navigationController)
                }else{
                    CommonClass.showSnackBar(message: "Oops! Something went wrong.")
                }
            }
        }
    }
    
    func mCreateNewCustomer() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "reserveBoard", bundle: nil)
        guard let mCreateCustomer = storyBoard.instantiateViewController(withIdentifier: "CreateCustomer") as? CreateCustomer else { return }
        self.navigationController?.pushViewController(mCreateCustomer, animated:true)
    }
    
    func mGetCustomerData(data: NSMutableDictionary) {
        if let cusId = data.value(forKey: "id") as? String,
           let cusProfilePic = data.value(forKey: "profile") as? String,
           let cusName = data.value(forKey: "name") as? String {
            UserDefaults.standard.set(cusId, forKey: "DEFAULTCUSTOMER")
            UserDefaults.standard.set(cusProfilePic, forKey: "DEFAULTCUSTOMERPICTURE")
            UserDefaults.standard.set(cusName, forKey: "DEFAULTCUSTOMERNAME")
            self.mCustomerId = cusId
        }
    }
    
    func mOpenCustomerPopup(){
        let storyBoard: UIStoryboard = UIStoryboard(name: "common", bundle: nil)
        guard let home = storyBoard.instantiateViewController(withIdentifier: "CustomerPicker") as? CustomerPicker else {return}
        home.delegate = self
        home.modalPresentationStyle = .automatic
        home.transitioningDelegate = self
        self.present(home,animated: true)
    }
    
    @IBAction func mConfirmButt(_ sender: Any) {
        if isConfirmProcessing {
            print("⚠️ CONFIRM ignored: request already in progress")
            return
        }

        if mSelectedRows.isEmpty {
            CommonClass.showSnackBar(message: "Please select items.")
            return
        }

        if isOrder == true {
            if mCustomerId == "" {
                mOpenCustomerPopup()
                return
            }

            // Lock CONFIRM immediately so rapid taps cannot create
            // multiple add-to-cart requests.
            isConfirmProcessing = true
            mConfirmButton.isEnabled = false
            CommonClass.showFullLoader(view: self.view)

            let mParams = [
                "product_id": self.mSelectedRows,
                "customer_id": mCustomerId,
                "sales_person_id": selectedSalesPersonId,
                "type": "inventory",
                "order_type": "custom_order"
            ] as [String: Any]

            print("========== CONFIRM ADD TO CART ==========")
            print("PARAMS =", mParams)
            print("=========================================")

            mGetData(
                url: mAddCustomProduct,
                headers: sGisHeaders,
                params: mParams
            ) { response, status in

                DispatchQueue.main.async {
                    CommonClass.stopLoader()
                    self.isConfirmProcessing = false
                    self.mConfirmButton.isEnabled = true
                }

                print("========== CONFIRM RESPONSE ==========")
                print("STATUS =", status)
                print("RESPONSE =", response)
                print("======================================")

                guard status else {
                    DispatchQueue.main.async {
                        CommonClass.showSnackBar(message: "Oops! Something went wrong.")
                    }
                    return
                }

                guard let code = response.value(forKey: "code") as? Int else {
                    DispatchQueue.main.async {
                        CommonClass.showSnackBar(message: "Oops! Something went wrong.")
                    }
                    return
                }

                if code == 200 {
                    DispatchQueue.main.async {
                        let storyBoard = UIStoryboard(
                            name: "customOrder",
                            bundle: nil
                        )

                        if let mCustomCart = storyBoard.instantiateViewController(
                            withIdentifier: "CustomCart"
                        ) as? CustomCart {
                            self.navigationController?.pushViewController(
                                mCustomCart,
                                animated: true
                            )
                        }
                    }
                } else if code == 403 {
                    DispatchQueue.main.async {
                        CommonClass.sessionExpired(
                            isExpired: true,
                            navigation: self.navigationController
                        )
                    }
                } else {
                    DispatchQueue.main.async {
                        CommonClass.showSnackBar(
                            message: "Oops! Something went wrong."
                        )
                    }
                }
            }

            return
        }

        // Reserve flow does not make an API request here, but still lock
        // the button during the navigation transition to prevent double push.
        isConfirmProcessing = true
        mConfirmButton.isEnabled = false
        CommonClass.showFullLoader(view: self.view)

        let storyBoard = UIStoryboard(name: "reserveBoard", bundle: nil)
        guard let mInventoryPage = storyBoard.instantiateViewController(
            withIdentifier: "InventoryReserveCart"
        ) as? InventoryReserveCart else {
            CommonClass.stopLoader()
            isConfirmProcessing = false
            mConfirmButton.isEnabled = true
            return
        }

        mInventoryPage.mOriginalData = NSArray(array: mReserveData)
        mInventoryPage.reserveSource = .itemSearch

        DispatchQueue.main.async {
            CommonClass.stopLoader()
            self.isConfirmProcessing = false
            self.mConfirmButton.isEnabled = true
            self.navigationController?.pushViewController(
                mInventoryPage,
                animated: true
            )
        }
    }

    @IBAction func mHideBottomSheet(_ sender: Any) {
        self.mParentView.isHidden = true
        mReserveData.removeAllObjects()
        mSelectedRows.removeAll()
        self.mReserveOrderListView.isHidden =  true
    }
    
    @IBAction func mOpenLink(_ sender: Any) {
    }
    
    @IBAction func mShowHideProductSummary(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            mShowHideSummaryIcon.image = UIImage(named: "top_ic")
            UIView.animate(withDuration: 1.0) {
                self.mProductSummaryView.isHidden = false
                self.view.layoutIfNeeded()
            }
        }else{
            
            mShowHideSummaryIcon.image = UIImage(named: "bottomic")
            UIView.animate(withDuration: 1.0) {
                self.mProductSummaryView.isHidden = true
                self.view.layoutIfNeeded()
            }
        }
    }
    
    
    
    @IBAction func mSwitchSearch(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            mSearchType = "inventory"
            mSearchField.placeholder = "Search by Stock ID".localizedString
            mSwitchIcon.image = UIImage(named: "stock_id_ic")
        }else{
            mSearchType = "catalog"
            mSearchField.placeholder = "Search by SKU".localizedString
            mSwitchIcon.image = UIImage(named: "sku_id_ic")
        }
        self.mSearchField.text = ""
        self.sSuggestionsView.isHidden = true
        self.sSuggestionsList.removeAll()
    }
    
    func mSearchProductByKeys(value: String){
        
        let urlPath = mSearchItems
        let type = mSearchType == "catalog" ? "SKU" : "stock_id"

        let params: [String: Any] = [
            "search": value,
            "type": type
        ]
        
        print("mSearchProductByKeys endpoint = \(mSearchItems)")
        print("mSearchProductByKeys headers = \(sGisHeaders2)")
        print("mSearchProductByKeys params = \(params)")
        
        
        if Reachability.isConnectedToNetwork() == true {
            CommonClass.showFullLoader(view: self.view)
            let apiStartTime = Date()
            print("========== mSearchProductByKeys API START ==========")
            print("mGetItemSearchReserveOrderData START: \(apiStartTime)")
            AF.request(urlPath, method:.post, parameters:params, headers: sGisHeaders2).responseJSON
            { response in
                let apiEndTime = Date()
                let elapsedTime = apiEndTime.timeIntervalSince(apiStartTime)
                 print("mGetItemSearchReserveOrderData END: \(apiEndTime)")
                 print(String(format: "API RESPONSE TIME: %.3f seconds", elapsedTime))
                 print("================================")
                CommonClass.stopLoader()
                print("mSearchItems Response : \(response)")
                if(response.error != nil){
                    
                    CommonClass.showSnackBar(message: "Something went wrong!")
                }else{
                    guard let jsonData = response.data else {
                        CommonClass.showSnackBar(message: "Something went wrong!")
                        return
                    }
                    
                    let json = try? JSONSerialization.jsonObject(with: jsonData, options: [])
                    guard let jsonResult = json as? NSDictionary else {
                        CommonClass.showSnackBar(message: "Something went wrong!")
                        return
                    }
                    
                    if let mCode =  jsonResult.value(forKey: "code") as? Int {
                        if mCode == 403 {
                            CommonClass.sessionExpired(isExpired: true, navigation: self.navigationController)
                            return
                        }
                    }
                    if jsonResult.value(forKey: "code") as? Int == 200 {
                        self.mSearchData = NSArray()
                        
                        if let mValue = jsonResult.value(forKey: "data") as? NSDictionary {
                            
                            if let mData = mValue.value(forKey: "item_searchRow") as? NSArray {
                                
                                self.mSelectedItems = [String]()
                                self.mIndex = -1
                                self.mBottomViewHeight.constant = 0
                                self.mReserveNowButton.isHidden = true
                                self.mOrderNowButton.isHidden = true
                                if mData.count != 0 {
                                    self.mSearchData =  mData
                                    self.mItemSearchTableView.delegate = self
                                    self.mItemSearchTableView.dataSource = self
                                    self.mItemSearchTableView.reloadData()
                                    
                                }
                            }
                            
                            self.mTotalAvailable.text = "\(mValue.value(forKey: "finalAvailable") as? Int ?? 0)"
                            self.mTotalStock.text = "\(mValue.value(forKey: "final_qty") as? Int ?? 0)"
                            self.mTotalReserve.text = "\(mValue.value(forKey: "finalReserve") as? Int ?? 0)"
                            self.mTotalSold.text = "\(mValue.value(forKey: "finalSold") as? Int ?? 0)"
                            
                            self.mMetaTag.text = "\(mValue.value(forKey: "name") ?? "--")"
                            self.mMetalName.text = "\(mValue.value(forKey: "metalname") ?? "--")"
                            self.mSizeName.text = "\(mValue.value(forKey: "sizename") ?? "--")"
                            self.mStoneName.text = "\(mValue.value(forKey: "stone_name") ?? "--")"
                            self.mCollectionName.text = "\(mValue.value(forKey: "Collection") ?? "--")"
                            self.mSKUName.text = "\(mValue.value(forKey: "SKU") ?? "--")"
                            
                            self.mMaterialName.text = "\(mValue.value(forKey: "metalname") ?? "--" )"
//                            self.mStoneOne.text = "\(mValue.value(forKey: "stone_name") ?? "--")"
                            self.mReferenceName.text = "\(mValue.value(forKey: "SKU") ?? "--")"
//                            self.mMaterialWeight.text = "\(mValue.value(forKey: "NetWt") ?? "--")"
                            if let weight = Double("\(mValue.value(forKey: "NetWt") ?? "0")") {
                                self.mMaterialWeight.text = String(format: "%.2f g", weight)
                            } else {
                                self.mMaterialWeight.text = "--"
                            }
//                            self.mStoneOneWeight.text = "\(mValue.value(forKey: "Cts") ?? "--")"
                            if let stones = mValue["Stones"] as? NSArray,
                               let firstStone = stones.firstObject as? NSDictionary,
                               let certificate = firstStone["certificate"] as? NSDictionary {

                                self.mCertificateNumber.text =
                                    "\(certificate["number"] ?? "--")"

                                self.mCertificateName.text =
                                    "\(certificate["type"] ?? "--")"

                                print("Certificate =", certificate)

                            } else {

                                self.mCertificateNumber.text = "--"
                                self.mCertificateName.text = "--"
                            }
//                            self.mCertificateName.text = "\(mValue.value(forKey: "certificate_type") ?? "--")"
//                            self.mCertificateNumber.text = "\(mValue.value(forKey: "certificate_number") ?? "--")"
                            
                            self.mStoneOne.numberOfLines = 1
                            self.mStoneOneWeight.numberOfLines = 1
                            self.mStoneTwo.numberOfLines = 1
                            self.mStoneTwoWeight.numberOfLines = 1
                            self.mStoneOne.textAlignment = .left
                            self.mStoneOneWeight.textAlignment = .right
                            self.mStoneTwo.textAlignment = .left
                            self.mStoneTwoWeight.textAlignment = .right
                            
                            // ---------- Stone ----------
                            if let stoneArray = mValue.value(forKey: "Stones") as? NSArray {

                                var stoneSummary: [String: (displayName: String, pcs: Int, cts: Double)] = [:]
                                var stoneOrder: [String] = []

                                for item in stoneArray {

                                    guard let stone = item as? NSDictionary else {
                                        continue
                                    }

                                    let rawName = "\(stone.value(forKey: "stone_name") ?? "")"
                                        .trimmingCharacters(in: .whitespacesAndNewlines)

                                    let key = rawName
                                        .lowercased()
                                        .replacingOccurrences(of: " ", with: "")

                                    let cleanName = rawName
                                        .replacingOccurrences(of: "-", with: "")
                                        .replacingOccurrences(of: " ", with: "")

                                    guard !cleanName.isEmpty,
                                          rawName.lowercased() != "null",
                                          rawName.lowercased() != "<null>" else {
                                        continue
                                    }

                                    let pcs = Int("\(stone.value(forKey: "Pcs") ?? "0")") ?? 0
                                    let cts = Double("\(stone.value(forKey: "Cts") ?? "0")") ?? 0.0

                                    if let old = stoneSummary[key] {

                                        stoneSummary[key] = (
                                            displayName: old.displayName,
                                            pcs: old.pcs + pcs,
                                            cts: old.cts + cts
                                        )

                                    } else {

                                        stoneSummary[key] = (
                                            displayName: rawName,
                                            pcs: pcs,
                                            cts: cts
                                        )

                                        stoneOrder.append(key)
                                    }
                                }

                                self.mStoneOne.text = ""
                                self.mStoneOneWeight.text = ""
                                self.mStoneTwo.text = ""
                                self.mStoneTwoWeight.text = ""

                                if stoneOrder.indices.contains(0),
                                   let stone1 = stoneSummary[stoneOrder[0]] {

                                    self.mStoneOne.text = stone1.displayName

                                    let formatter = NumberFormatter()
                                    formatter.minimumFractionDigits = 0
                                    formatter.maximumFractionDigits = 3

                                    let ctsText = formatter.string(from: NSNumber(value: stone1.cts)) ?? "0"

                                    self.mStoneOneWeight.text =
                                        "\(stone1.pcs)       \(ctsText) c"
                                }

                                if stoneOrder.indices.contains(1),
                                   let stone2 = stoneSummary[stoneOrder[1]] {

                                    self.mStoneTwo.text = stone2.displayName

                                    let formatter = NumberFormatter()
                                    formatter.minimumFractionDigits = 0
                                    formatter.maximumFractionDigits = 3

                                    let ctsText = formatter.string(from: NSNumber(value: stone2.cts)) ?? "0"

                                    self.mStoneTwoWeight.text =
                                        "\(stone2.pcs)       \(ctsText) c"
                                }

                            } else {

                                self.mStoneOne.text = ""
                                self.mStoneOneWeight.text = ""
                                self.mStoneTwo.text = ""
                                self.mStoneTwoWeight.text = ""
                            }
                            
                            
                            self.mProductImage.downlaodImageFromUrl(urlString: "\(mValue.value(forKey: "images") ?? "")")
                            
                            
                            self.mProductIdForImage = "\(mValue.value(forKey: "product_id") ?? "" )"
                            self.mSKUForImage = "\(mValue.value(forKey: "SKU") ?? "" )"
                            
                        }
                        
                        self.mSelectedItems = [String]()
                        self.mIndex = -1
                        self.mItemSearchTableView.delegate = self
                        self.mItemSearchTableView.dataSource = self
                        self.mItemSearchTableView.reloadData()
                        
                    }else {
                        
                        self.mMaterialName.text =  "--"
                        self.mStoneOne.text =  "--"
                        self.mReferenceName.text =  "--"
                        self.mMaterialWeight.text =  "--"
                        self.mStoneOneWeight.text =  "--"
                        self.mCertificateName.text =  "--"
                        self.mCertificateNumber.text =  "--"
                        self.mCollectionName.text = "--"
                        
                        self.mSKUName.text = "--"
                        self.mMetaTag.text = "--"
                        self.mMetalName.text = "--"
                        self.mSizeName.text = "--"
                        self.mStoneName.text = "--"
                        self.mSelectedItems = [String]()
                        self.mIndex = -1
                        
                        self.mSearchData = NSArray()
                        self.mTotalAvailable.text = "--"
                        self.mTotalStock.text = "--"
                        self.mTotalReserve.text = "--"
                        self.mTotalSold.text = "--"
                        self.mItemSearchTableView.delegate = self
                        self.mItemSearchTableView.dataSource = self
                        self.mItemSearchTableView.reloadData()
                        
                        if let error = jsonResult.value(forKey: "error") as? String {
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
    
    @IBAction func mHome(_ sender: Any) {
        // This is a back action, not a Home shortcut. Keep it consistent with
        // the chevron used by the other list screens.
        if let navigationController = navigationController,
           navigationController.viewControllers.count > 1 {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
    
    @IBAction func mSync(_ sender: Any) {
    }
    
    @IBAction func mOpenScanner(_ sender: Any) {
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "transactions", bundle: nil)
        guard let mCommonScanner = storyBoard.instantiateViewController(withIdentifier: "CommonScanner") as? CommonScanner else {return}
        mCommonScanner.delegate =  self
        mCommonScanner.mType = "itemSearch"
        mCommonScanner.modalPresentationStyle = .overFullScreen
        mCommonScanner.transitioningDelegate = self
        self.present(mCommonScanner,animated: true)
    }
    
//    func mGetScannedData(value: String, type: String) {
//        mSearchProductByKeys(value:value)
//
//    }
    func mGetScannedData(value: String, type: String) {
        print("SCANNED VALUE =", value)
        print("SCANNED TYPE =", type)

        // Keep scanned value for Reserve / Order API
        self.mSearchField.text = value

        mSearchProductByKeys(value: value)
    }
    
    
    @IBAction func mReserve(_ sender: Any) {
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "reserveBoard", bundle: nil)
        guard let mInventoryPage = storyBoard.instantiateViewController(withIdentifier: "InventoryReservedItems") as? InventoryReservedItems else {return}
        mInventoryPage.mType = "ItemSearch"
        self.navigationController?.pushViewController(mInventoryPage, animated:true)
        
    }
    
    @IBAction func mOpenCustomer(_ sender: Any) {
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "reserveBoard", bundle: nil)
        guard let home = storyBoard.instantiateViewController(withIdentifier: "CustomerSearch") as? CustomerSearch else {return}
        self.navigationController?.pushViewController(home, animated:true)
        
        
    }
    
    @IBAction func mPreview(_ sender: Any) {
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Test", bundle: nil)
        if let mPrint = storyBoard.instantiateViewController(withIdentifier: "PrintItem") as? PrintItem {
            self.navigationController?.pushViewController(mPrint, animated:true)
        }
    }
    
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == mItemsTableView {
            return mReserveOrderData.count
        }
        if tableView == sSuggestionsTable {
            return sSuggestionsList.count
        }
        return mSearchData.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        
        var cell  = UITableViewCell()
        
//        if tableView == mItemSearchTableView {
//            if let  cells = tableView.dequeueReusableCell(withIdentifier: "ItemSearchCell") as? ItemSearchCell {
//
//                if let mData = mSearchData[indexPath.row] as? NSDictionary {
//                    print("DEBUG_LOCATION_ROW =", mData)
//                    cells.mLocation.text  = "\(mData.value(forKey: "location") ?? "--")"
//                    cells.mStock.text  = "\(mData.value(forKey: "total_qty") ?? "--")"
//                    cells.mReserve.text  = "\(mData.value(forKey: "reserve") ?? "--")"
//                    cells.mSold.text  = "\(mData.value(forKey: "sold") ?? "--")"
//                    cells.mAvailable.text  = "\(mData.value(forKey: "available") ?? "--")"
//                    cells.mSoldButton.tag = indexPath.row
//                    cells.mReserveButton.tag = indexPath.row
//                    cells.mStockButton.tag = indexPath.row
//                    cells.mAvailableButton.tag = indexPath.row
//                    cells.mCheckVIew.isHidden = false
//
//                    if mIndex == indexPath.row {}else{
//
//                    }
//
//                    if (indexPath.row % 2 == 0) {
//                        cells.mView.backgroundColor = UIColor(named: "themeBackground")
//                    }else{
//                        cells.mView.backgroundColor = #colorLiteral(red: 0.9568627451, green: 0.9568627451, blue: 0.9568627451, alpha: 1)
//
//                    }
//
//                    if mSelectedItems.isEmpty {
//                        cells.mCheckIcon.image = UIImage(named: "uncheck_item")
//                        mBottomViewHeight.constant = 0
//                        mReserveNowButton.isHidden = true
//                        mOrderNowButton.isHidden = true
//                    }else{
//                        cells.mCheckIcon.image = UIImage(named: "check_item")
//                        mBottomViewHeight.constant = 80
//                        mReserveNowButton.isHidden = false
//                        mOrderNowButton.isHidden = false
//                    }
//
//                    // available == 0 means this stock cannot be reserved again.
//                    let canReserve = self.isAvailableForReserve(mData)
//                    cells.mCheckVIew.alpha = canReserve ? 1.0 : 0.4
//                    cells.selectionStyle = canReserve ? .default : .none
//
//                    if canReserve,
//                       let location = mData.value(forKey: "location_id") as? String,
//                       mSelectedItems.contains(location) {
//                        cells.mCheckIcon.image = UIImage(named: "check_item")
//                    }else{
//                        cells.mCheckIcon.image = UIImage(named: "uncheck_item")
//                    }
//
//                    cells.layoutSubviews()
//                }
//                cell = cells
//            }
//        }
        if tableView == mItemSearchTableView {
            if let  cells = tableView.dequeueReusableCell(withIdentifier: "ItemSearchCell") as? ItemSearchCell {
                
                if let mData = mSearchData[indexPath.row] as? NSDictionary {
                    print("DEBUG_LOCATION_ROW =", mData)
                    cells.mLocation.text  = "\(mData.value(forKey: "location") ?? "--")"
                    cells.mStock.text  = "\(mData.value(forKey: "total_qty") ?? "--")"
                    cells.mReserve.text  = "\(mData.value(forKey: "reserve") ?? "--")"
                    cells.mSold.text  = "\(mData.value(forKey: "sold") ?? "--")"
                    cells.mAvailable.text  = "\(mData.value(forKey: "available") ?? "--")"
                    cells.mSoldButton.tag = indexPath.row
                    cells.mReserveButton.tag = indexPath.row
                    cells.mStockButton.tag = indexPath.row
                    cells.mAvailableButton.tag = indexPath.row
                    cells.mCheckVIew.isHidden = false

                    // If this stock is already reserved, it must not be selectable.
                    let isReserved = "\(mData.value(forKey: "status_type") ?? "")"
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                        .lowercased() == "reserve"

                    cells.selectionStyle = isReserved ? .none : .default
                    
                    if mIndex == indexPath.row {}else{
                        
                    }
                    
                    if (indexPath.row % 2 == 0) {
                        cells.mView.backgroundColor = UIColor(named: "themeBackground")
                    }else{
                        cells.mView.backgroundColor = #colorLiteral(red: 0.9568627451, green: 0.9568627451, blue: 0.9568627451, alpha: 1)
                        
                    }
                    
                    if mSelectedItems.isEmpty {
                        cells.mCheckIcon.image = UIImage(named: "uncheck_item")
                        mBottomViewHeight.constant = 0
                        mReserveNowButton.isHidden = true
                        mOrderNowButton.isHidden = true
                    }else{
                        cells.mCheckIcon.image = UIImage(named: "check_item")
                        mBottomViewHeight.constant = 80
                        mReserveNowButton.isHidden = false
                        mOrderNowButton.isHidden = false
                    }
                    if let location = mData.value(forKey: "location_id") as? String,
                       mSelectedItems.contains(location) {
                        cells.mCheckIcon.image = UIImage(named: "check_item")
                    }else{
                        cells.mCheckIcon.image = UIImage(named: "uncheck_item")
                    }
                    
                    cells.layoutSubviews()
                }
                cell = cells
            }
        }
        if tableView == mItemsTableView {
            if let  cells = tableView.dequeueReusableCell(withIdentifier: "ReserveOrderCell") as? ReserveOrderCell {
                
                let statusProperties: [String: (textColor: UIColor, backgroundColor: UIColor, statusText: String)] = [
                    "stock": (#colorLiteral(red: 0.4588235294, green: 0.8, blue: 1, alpha: 1), #colorLiteral(red: 0.4588235294, green: 0.8, blue: 1, alpha: 1), "Stock"),
                    "reserve": (#colorLiteral(red: 1, green: 0.7386777401, blue: 0.3924969435, alpha: 1), #colorLiteral(red: 1, green: 0.7386777401, blue: 0.3924969435, alpha: 1), "Reserved"),
                    "custom_order": (#colorLiteral(red: 0.9137254902, green: 0.4392156863, blue: 0.4392156863, alpha: 1), #colorLiteral(red: 0.9137254902, green: 0.4392156863, blue: 0.4392156863, alpha: 1), "Reserved"),
                    "repair_order": (#colorLiteral(red: 0.662745098, green: 0.6078431373, blue: 0.7411764706, alpha: 1), #colorLiteral(red: 0.662745098, green: 0.6078431373, blue: 0.7411764706, alpha: 1), "Repair"),
                    "warehouse": (#colorLiteral(red: 0.4392156863, green: 0.4392156863, blue: 0.4392156863, alpha: 1), #colorLiteral(red: 0.4392156863, green: 0.4392156863, blue: 0.4392156863, alpha: 1), "Warehouse"),
                    "transit": (#colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1), #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1), "Transit")
                ]
                
                if let mData = mReserveOrderData[indexPath.row] as? NSDictionary {
                    
                    if let statusType = mData.value(forKey: "status_type") as? String,
                       let status = statusProperties[statusType] {
                        cells.mStatusDot.backgroundColor = status.backgroundColor
                    } else {
                        cells.mStatusDotView.isHidden = false
                    }
                    
                    cells.mStockName.text  = "\(mData.value(forKey: "SKU") ?? "--")"
                    cells.mStockId.text  = "\(mData.value(forKey: "stock_id") ?? "--")"
                    cells.mQuantity.text  = "\(mData.value(forKey: "po_QTY") ?? "--")"
                    cells.mAmount.text  = "\(mData.value(forKey: "price") ?? "--")"
                    cells.mLocationName.text  = "\(mData.value(forKey: "location_name") ?? "--")"
                    
                    if (indexPath.row % 2 == 0) {
                        cells.mView.backgroundColor = UIColor(named: "themeBackground")
                    }else{
                        cells.mView.backgroundColor = #colorLiteral(red: 0.9568627451, green: 0.9568627451, blue: 0.9568627451, alpha: 1)
                    }
                    
                    
                    if let poProId = mData.value(forKey: "po_product_id") as? String,
                       mSelectedRows.contains(poProId) {
                        cells.mCheckIcon.image = UIImage(named: "check_item")
                    }else{
                        cells.mCheckIcon.image = UIImage(named: "uncheck_item")
                    }
                    
//                    if let mData = mSearchData[indexPath.row] as? NSDictionary {
//                    if !self.isAvailableForReserve(mData) {
//                        cells.mCheckIcon.isHidden = true
//                    }
//                    }
                    
                    
                    cells.layoutSubviews()
                }
                
                cell = cells
            }
        }
        //Suggestions table
        if tableView == sSuggestionsTable {
            if let cells = tableView.dequeueReusableCell(withIdentifier: "SuggestionsSearchCell") as? SuggestionsSearchCell {
                let data = sSuggestionsList[indexPath.row]
                
                if let sku = data["SKU"] as? String, let searchKey = data["search_key"] as? String {
                    cells.sSuggestionLabel.text = "\(sku) (\(searchKey))"
                } else if let searchKey = data["search_key"] as? String {
                    cells.sSuggestionLabel.text = "\(searchKey)"
                } else if let sku = data["SKU"] as? String {
                    cells.sSuggestionLabel.text = "\(sku)"
                }
                
                cell = cells
            }
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
//        if tableView == mItemsTableView {
//            guard let resrveOrderData = mReserveOrderData[indexPath.row] as? NSDictionary else {
//                return
//            }
//            if "\(resrveOrderData.value(forKey: "po_product_id") ?? "0")" == "0" {
//                return
//            }
//
//            guard let mData = mSearchData[indexPath.row] as? NSDictionary else {
//                return
//            }
//            if !self.isAvailableForReserve(mData) {
//                print("DEBUG_RESERVE_SELECTION_BLOCKED =", mData)
//                CommonClass.showSnackBar(message: "This item is not available to reserve.")
//                return
//            }
//
//            if mSelectedRows.contains(resrveOrderData.value(forKey: "po_product_id") as? String ?? "") {
//                mSelectedRows = mSelectedRows.filter {$0 != resrveOrderData.value(forKey: "po_product_id") as? String ?? "" }
//
//                if let mInvData = mReserveOrderData[indexPath.row] as? NSDictionary {
//
//                    print("DEBUG_RESERVE_ITEM =", mInvData)
//
//                    let mData = NSMutableDictionary()
//                    mData.setValue("\(mInvData.value(forKey: "po_product_id") ?? "")", forKey: "id")
//                    mData.setValue("1", forKey: "quantity")
//                    mData.setValue("\(mInvData.value(forKey: "po_QTY") ?? "0")", forKey: "po_QTY")
//                    mData.setValue("\(mInvData.value(forKey: "SKU") ?? "--")", forKey: "sku")
//                    mData.setValue("\(mInvData.value(forKey: "stock_id") ?? "--")", forKey: "stockId")
//                    mData.setValue("\(mInvData.value(forKey: "price") ?? "--")", forKey: "price")
//                    mData.setValue("\(mInvData.value(forKey: "Matatag") ?? "--")", forKey: "Matatag")
//                    mData.setValue("\(mInvData.value(forKey: "main_image") ?? "--")", forKey: "image")
//                    mData.setValue("\(mInvData.value(forKey: "metal_name") ?? "--")", forKey: "metal")
//                    mData.setValue("\(mInvData.value(forKey: "size_name") ?? "--")", forKey: "size")
//                    let currentDateTime = Date()
//                    let formatter = DateFormatter()
////                    formatter.dateFormat = "MM/dd/yyy"
//                    formatter.dateFormat = "MM/dd/yyyy"
//                    mData.setValue("\(formatter.string(from: currentDateTime))", forKey: "dueDate")
//                    mData.setValue("", forKey: "notes")
//                    mData.setValue(
//                        "\(mInvData.value(forKey: "location_id") ?? "")",
//                        forKey: "crossLocationId"
//                    )
//                    mData.setValue(true, forKey: "crosslocation")
//
//                    mReserveData.remove(mData)
//                }
//
//            }else{
//                mSelectedRows.append(resrveOrderData.value(forKey: "po_product_id") as? String ?? "")
//
//                if let mInvData = mReserveOrderData[indexPath.row] as? NSDictionary {
//                    let mData = NSMutableDictionary()
//                    mData.setValue("\(mInvData.value(forKey: "po_product_id") ?? "")", forKey: "id")
//                    mData.setValue("1", forKey: "quantity")
//                    mData.setValue("\(mInvData.value(forKey: "po_QTY") ?? "0")", forKey: "po_QTY")
//                    mData.setValue("\(mInvData.value(forKey: "SKU") ?? "--")", forKey: "sku")
//                    mData.setValue("\(mInvData.value(forKey: "stock_id") ?? "--")", forKey: "stockId")
//                    mData.setValue("\(mInvData.value(forKey: "price") ?? "--")", forKey: "price")
//                    mData.setValue("\(mInvData.value(forKey: "Matatag") ?? "--")", forKey: "Matatag")
//                    mData.setValue("\(mInvData.value(forKey: "main_image") ?? "--")", forKey: "image")
//                    mData.setValue("\(mInvData.value(forKey: "metal_name") ?? "--")", forKey: "metal")
//                    mData.setValue("\(mInvData.value(forKey: "size_name") ?? "--")", forKey: "size")
//                    let currentDateTime = Date()
//                    let formatter = DateFormatter()
////                    formatter.dateFormat = "MM/dd/yyy"
//                    formatter.dateFormat = "MM/dd/yyyy"
//                    mData.setValue("\(formatter.string(from: currentDateTime))", forKey: "dueDate")
//                    mData.setValue("", forKey: "notes")
//                    mData.setValue(
//                        "\(mInvData.value(forKey: "location_id") ?? "")",
//                        forKey: "crossLocationId"
//                    )
//                    mData.setValue(true, forKey: "crosslocation")
//
//                    mReserveData.add(mData)
//                }
//            }
//            print("DEBUG_RESERVE_ITEM =", resrveOrderData)
//            self.mItemsTableView.reloadData()
//
//        }
        if tableView == mItemsTableView {

            guard let resrveOrderData = mReserveOrderData[indexPath.row] as? NSDictionary else {
                return
            }

            if "\(resrveOrderData.value(forKey: "po_product_id") ?? "0")" == "0" {
                return
            }

            print("DEBUG_RESERVE_SELECTION =", resrveOrderData)

            if mSelectedRows.contains(
                resrveOrderData.value(forKey: "po_product_id") as? String ?? ""
            ) {

                mSelectedRows = mSelectedRows.filter {
                    $0 != (resrveOrderData.value(forKey: "po_product_id") as? String ?? "")
                }

                if let mInvData = mReserveOrderData[indexPath.row] as? NSDictionary {

                    print("DEBUG_RESERVE_ITEM =", mInvData)

                    let mData = NSMutableDictionary()

                    mData.setValue(
                        "\(mInvData.value(forKey: "po_product_id") ?? "")",
                        forKey: "id"
                    )

                    mData.setValue("1", forKey: "quantity")

                    mData.setValue(
                        "\(mInvData.value(forKey: "po_QTY") ?? "0")",
                        forKey: "po_QTY"
                    )

                    mData.setValue(
                        "\(mInvData.value(forKey: "SKU") ?? "--")",
                        forKey: "sku"
                    )

                    mData.setValue(
                        "\(mInvData.value(forKey: "stock_id") ?? "--")",
                        forKey: "stockId"
                    )

                    mData.setValue(
                        "\(mInvData.value(forKey: "price") ?? "--")",
                        forKey: "price"
                    )

                    mData.setValue(
                        "\(mInvData.value(forKey: "Matatag") ?? "--")",
                        forKey: "Matatag"
                    )

                    mData.setValue(
                        "\(mInvData.value(forKey: "main_image") ?? "--")",
                        forKey: "image"
                    )

                    mData.setValue(
                        "\(mInvData.value(forKey: "metal_name") ?? "--")",
                        forKey: "metal"
                    )

                    mData.setValue(
                        "\(mInvData.value(forKey: "size_name") ?? "--")",
                        forKey: "size"
                    )

                    let currentDateTime = Date()
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MM/dd/yyyy"

                    mData.setValue(
                        formatter.string(from: currentDateTime),
                        forKey: "dueDate"
                    )

                    mData.setValue("", forKey: "notes")

                    mData.setValue(
                        "\(mInvData.value(forKey: "location_id") ?? "")",
                        forKey: "crossLocationId"
                    )

                    mData.setValue(true, forKey: "crosslocation")

                    mReserveData.remove(mData)
                }

            } else {

                mSelectedRows.append(
                    resrveOrderData.value(forKey: "po_product_id") as? String ?? ""
                )

                if let mInvData = mReserveOrderData[indexPath.row] as? NSDictionary {

                    let mData = NSMutableDictionary()

                    mData.setValue(
                        "\(mInvData.value(forKey: "po_product_id") ?? "")",
                        forKey: "id"
                    )

                    mData.setValue("1", forKey: "quantity")

                    mData.setValue(
                        "\(mInvData.value(forKey: "po_QTY") ?? "0")",
                        forKey: "po_QTY"
                    )

                    mData.setValue(
                        "\(mInvData.value(forKey: "SKU") ?? "--")",
                        forKey: "sku"
                    )

                    mData.setValue(
                        "\(mInvData.value(forKey: "stock_id") ?? "--")",
                        forKey: "stockId"
                    )

                    mData.setValue(
                        "\(mInvData.value(forKey: "price") ?? "--")",
                        forKey: "price"
                    )

                    mData.setValue(
                        "\(mInvData.value(forKey: "Matatag") ?? "--")",
                        forKey: "Matatag"
                    )

                    mData.setValue(
                        "\(mInvData.value(forKey: "main_image") ?? "--")",
                        forKey: "image"
                    )

                    mData.setValue(
                        "\(mInvData.value(forKey: "metal_name") ?? "--")",
                        forKey: "metal"
                    )

                    mData.setValue(
                        "\(mInvData.value(forKey: "size_name") ?? "--")",
                        forKey: "size"
                    )

                    let currentDateTime = Date()
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MM/dd/yyyy"

                    mData.setValue(
                        formatter.string(from: currentDateTime),
                        forKey: "dueDate"
                    )

                    mData.setValue("", forKey: "notes")

                    mData.setValue(
                        "\(mInvData.value(forKey: "location_id") ?? "")",
                        forKey: "crossLocationId"
                    )

                    mData.setValue(true, forKey: "crosslocation")

                    mReserveData.add(mData)
                }
            }

            print("DEBUG_RESERVE_ITEM =", resrveOrderData)

            self.mItemsTableView.reloadData()
        }
        
        if tableView == mItemSearchTableView {
            
            guard let mData = mSearchData[indexPath.row] as? NSDictionary else {
                return
            }

            // Do not allow selecting a location with no available stock.
            // Example from the API: available = 0, reserve = 1.
//            if !self.isAvailableForReserve(mData) {
//                print("DEBUG_RESERVE_SELECTION_BLOCKED =", mData)
//                CommonClass.showSnackBar(message: "This item is not available to reserve.")
//                return
//            }
            print("\(mData.value(forKey: "location_id") ?? "no data")")
            print("\(mSelectedItems)")
            mIndex = indexPath.row
            if let locId = mData.value(forKey: "location_id") as? String {
                if mSelectedItems.contains(locId) {
                    mSelectedItems = mSelectedItems.filter {$0 != locId }
                }else{
                    mSelectedItems.append(locId)
                }
            }
            print("\(mSelectedItems)")
            self.mItemSearchTableView.reloadData()
            
            
        }
        
        if tableView == sSuggestionsTable {
            mSearchField.text = sSuggestionsList[indexPath.row]["search_key"] as? String ?? ""
            sSuggestionsView.isHidden = true
            sSuggestionsList.removeAll()
        }
        
        
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if tableView == mItemsTableView {
            return 60
        }
        if tableView == sSuggestionsTable {
            return 40
        }
        return 43
    }
    
    @IBAction func mViewAvailableStocks(_ sender: UIButton) {
    }
    
    @IBAction func mViewAllStocks(_ sender: UIButton) {
    }
    @IBAction func mViewReserveStocks(_ sender: UIButton) {
        guard let mData = mSearchData[sender.tag] as? NSDictionary else { return }
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Test", bundle: nil)
        guard let mRSI = storyBoard.instantiateViewController(withIdentifier: "ItemSearchSoldReserved") as? ItemSearchSoldReserved else {return}
        mRSI.mType = "reserve"
        mRSI.mLocationId = "\(mData.value(forKey:"location_id") ?? "" )"
        mRSI.mSearchKey = ""
        mRSI.mSKUKey = "\(mData.value(forKey:"searchSKU") ?? "" )"
        self.navigationController?.pushViewController(mRSI, animated:true)
    }
    
    @IBAction func mSoldStock(_ sender: UIButton) {
        guard let mData = mSearchData[sender.tag] as? NSDictionary else { return }
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Test", bundle: nil)
        guard let mRSI = storyBoard.instantiateViewController(withIdentifier: "ItemSearchSoldReserved") as? ItemSearchSoldReserved else {return}
        mRSI.mType = "sold"
        
        if let mIds = mData.value(forKey: "ids") as? [String] {
            if !mIds.isEmpty {
                mRSI.mIds = mIds
            }else{
                CommonClass.showSnackBar(message: "No Items Found!")
                return
            }
        }else{
            CommonClass.showSnackBar(message: "No Items Found!")
            return
            
        }
        mRSI.mLocationId = "\(mData.value(forKey:"location_id") ?? "" )"
        mRSI.mSearchKey = ""
        mRSI.mSKUKey = "\(mData.value(forKey:"searchSKU") ?? "" )"
        self.navigationController?.pushViewController(mRSI, animated:true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count = 0
        if collectionView == self.mItemCollectionView {
            count = 10
            
        }else if collectionView == self.mCollectCollectionView {
            count = 9
            
            
        }else if collectionView == self.mMetalCollectionView {
            count = 8
            
        }else if collectionView == self.mLocationCollectionView {
            count = 7
            
            
        }else if collectionView == self.mStoneCollectionView {
            count = 9
            
            
        }
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell = UICollectionViewCell()
        if collectionView == self.mItemCollectionView {
            if let cells = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath) as? ItemCell {
                cell = cells
            }
        }else if collectionView == self.mCollectCollectionView {
            if let cells = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as? CollectionCell {
                cell = cells
            }
        }else if collectionView == self.mMetalCollectionView {
            if let cells = collectionView.dequeueReusableCell(withReuseIdentifier: "MetalCell", for: indexPath) as? MetalCell {
                cell = cells
            }
        }else if collectionView == self.mLocationCollectionView {
            if let cells = collectionView.dequeueReusableCell(withReuseIdentifier: "LocationCell", for: indexPath) as? LocationCell {
                cell = cells
            }
        }else if collectionView == self.mStoneCollectionView {
            if let cells = collectionView.dequeueReusableCell(withReuseIdentifier: "StoneCell", for: indexPath) as? StoneCell {
                cell = cells
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.size.width/2 - 30 , height:35)
    }
    
    //SearchField onchange
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField == self.mSearchField {
            if let searchKey = textField.text , !searchKey.isEmpty {
                self.mSearchSuggestions(key: searchKey)
            } else {
                self.sSuggestionsView.isHidden = true
                self.sSuggestionsList.removeAll()
            }
        }
    }
    
    //SearchField Clear button pressed
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if textField == self.mSearchField {
            mSearchField.text = ""
            sSuggestionsView.isHidden = true
            sSuggestionsList.removeAll()
            clearItemSearchPage()
        }
        return true
    }
    
    private func clearItemSearchPage(){
        // Clearing ItemSearch View
        mSearchData = NSArray()
        mItemSearchTableView.reloadData()
        mTotalAvailable.text = "0"
        mTotalStock.text = "0"
        mTotalReserve.text = "0"
        mTotalSold.text = "0"
        mMetaTag.text = "--"
        mMetalName.text = "--"
        mSizeName.text = "--"
        mStoneName.text = "--"
        mCollectionName.text = "--"
        mSKUName.text = "--"
        mMaterialName.text = "--"
        mStoneOne.text = "--"
        mReferenceName.text = "--"
        mMaterialWeight.text = "--"
        mStoneOneWeight.text = "--"
        mCertificateName.text = "--"
        mCertificateNumber.text = "--"
        mProductIdForImage = ""
        mSKUForImage = ""
        mProductImage.image = UIImage(named: "dring")
    }
    
    
    // Search Suggestion List API
    func mSearchSuggestions(key: String) {
        
        
        
        let type = mSearchType == "catalog" ? "SKU" : "stock_id"

        let params: [String: Any] = [
            "search": key,
            "type": type
        ]
        
        guard !key.isEmpty else {
            return
        }
        
        guard Reachability.isConnectedToNetwork() else {
            CommonClass.showSnackBar(message: "Please connect to the internet.")
            return
        }
        
        let urlPath = mItemKeySearch
        AF.request(urlPath, method: .post, parameters: params, encoding: JSONEncoding.default, headers: sGisHeaders)
            .responseJSON { response in
                guard let jsonData = response.data else {
                    CommonClass.showSnackBar(message: "Oops, something went wrong!")
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                        guard let code = json["code"] as? Int else {
                            CommonClass.showSnackBar(message: "Oops, something went wrong!")
                            return
                        }
                        
                        switch code {
                        case 200:
                            if let data = json["data"] as? [[String: Any]] , data.count > 0{
                                if self.mSearchField.text == data[0]["search_key"] as? String && data.count == 1 { return }
                                self.sSuggestionsList = data
                                self.sSuggestionsView.isHidden = false
                                self.sSuggestionsTable.reloadData()
                            } else {
                                self.sSuggestionsList.removeAll()
                                self.sSuggestionsView.isHidden = true
                            }
                        case 403:
                            CommonClass.sessionExpired(isExpired: true, navigation: self.navigationController)
                        default:
                            let errorMessage = json["message"] as? String ?? "An error occurred."
                            CommonClass.showSnackBar(message: "Error \(code): \(errorMessage)")
                        }
                    }
                } catch {
                    CommonClass.showSnackBar(message: "Oops, something went wrong!")
                }
            }
    }
    
    
}
