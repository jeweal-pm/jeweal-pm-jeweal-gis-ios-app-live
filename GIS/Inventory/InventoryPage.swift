//
//  InventoryPage.swift
//  GIS
//
//  Created by Apple Hawkscode on 21/10/20.
//

import UIKit
import Alamofire
import DropDown
import UIDrawer


public class InventoryCell: UITableViewCell {
    
    @IBOutlet weak var mView: UIView!
    @IBOutlet weak var mCheckView: UIView!
    @IBOutlet weak var mStockName: UILabel!
    @IBOutlet weak var mStockId: UILabel!

    @IBOutlet weak var mStatusColor: UILabel!
    @IBOutlet weak var mAmount: UILabel!
    @IBOutlet weak var mQuantity: UILabel!
    @IBOutlet weak var mCheckIcon: UIImageView!
    @IBOutlet weak var mCheckUnckeckButton: UIButton!
  
    @IBOutlet weak var mDesignView: UIView!
    @IBOutlet weak var mDesignIcon: UIImageView!
    
    public override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

public class SummaryCell: UITableViewCell {
    
    @IBOutlet weak var mView: UIView!
    @IBOutlet weak var mStock: UILabel!
    @IBOutlet weak var mReserve: UILabel!
    @IBOutlet weak var mAvailable: UILabel!
    @IBOutlet weak var mLocation: UILabel!
    public override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    public override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    }
    
}

public class ReserveCell: UITableViewCell {
    
    @IBOutlet weak var mStockName: UILabel!
    @IBOutlet weak var mStockId: UILabel!
    @IBOutlet weak var mQuantity: UITextField!
    @IBOutlet weak var mAmount: UILabel!
    public override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

public class ItemCell: UICollectionViewCell {
   
    @IBOutlet weak var mItemName: UILabel!
    
}

public class CollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var mCollectionName: UILabel!
    
}

public class MetalCell: UICollectionViewCell {
    
    @IBOutlet weak var mMetalName: UILabel!
    
}

public class LocationCell: UICollectionViewCell {
    
    @IBOutlet weak var mView: UIView!
    @IBOutlet weak var mCheckIcon: UIImageView!
    @IBOutlet weak var mStack: UIStackView!
    @IBOutlet weak var mLocationName: UILabel!
    
    @IBOutlet weak var mQuantity: UILabel!
}

public class SizeCell: UICollectionViewCell {
    
    @IBOutlet weak var mSizeName: UILabel!
    
}

public class StoneCell: UICollectionViewCell {
    
    @IBOutlet weak var mCStone: UILabel!
    @IBOutlet weak var mChooseStone: UIButton!
 
}

class InventoryPage: UIViewController , UITableViewDelegate , UITableViewDataSource ,UICollectionViewDelegate , UICollectionViewDataSource, UICollectionViewDelegateFlowLayout , RangeSeekSliderDelegate, UIGestureRecognizerDelegate,UIViewControllerTransitioningDelegate, GetInventoryFiltersDelegate,ScannerDelegate {
   
    @IBOutlet weak var mSummaryLabel: UILabel!
    @IBOutlet weak var mInventoryLabel: UILabel!
    @IBOutlet weak var mSummaryLine: UILabel!
    @IBOutlet weak var mInventoryLine: UILabel!
    
    //Summary Item Details
    @IBOutlet weak var mTotalSummaryView: UIView!
    @IBOutlet weak var mSummaryImage: UIImageView!
    @IBOutlet weak var mSummarySKUName: UILabel!
    @IBOutlet weak var mSummaryDescription: UILabel!
    @IBOutlet weak var mSummaryLocation: UILabel!
    @IBOutlet weak var mSummaryItemName: UILabel!
    @IBOutlet weak var mSummaryCollectionName: UILabel!
    @IBOutlet weak var mTotalStockSummary: UILabel!
    @IBOutlet weak var mTotalReservedSummary: UILabel!
    @IBOutlet weak var mTotalAvailableSummary: UILabel!

    //Inventory Item Details
    @IBOutlet weak var mReserveButtonView: UIView!
    @IBOutlet weak var mReserveButton: UIButton!
    @IBOutlet weak var mHeight: NSLayoutConstraint!
    
    @IBOutlet weak var mStockID: UILabel!
    
    @IBOutlet weak var mInventoryImage: UIImageView!
    
    @IBOutlet weak var mProductStatus: UILabel!
    
    
    let mInventoryFetchLimit = 20
    var mInventorySkip = 0
    var mInventoryTotal = 0
    var SiriID = ""
    
    @IBOutlet weak var mRefreshIcon: UIImageView!
    @IBOutlet weak var mRefreshLabel: UILabel!
    var mTimer = Timer()
    
    @IBOutlet weak var mItemsSelected: UILabel!
    @IBOutlet weak var mBottomView: UIView!
    
    @IBOutlet weak var mRefreshView: UIView!
    @IBOutlet weak var mSubFilterView: UIView!
    
    @IBOutlet weak var mApplyFilterView: UIView!
    @IBOutlet weak var mFilterView: UIView!
    
    @IBOutlet weak var mSearchButtonView: UIView!
    
    @IBOutlet weak var mFilterSearchView: UIView!
    
    @IBOutlet weak var mSummaryButton: UIButton!
    @IBOutlet weak var mSummaryView: UIView!
    
    @IBOutlet weak var mMyInventoryButton: UIButton!
    @IBOutlet weak var mMyInventoryView: UIView!
    
    @IBOutlet weak var mBottomReserveView: UIView!
    @IBOutlet weak var mMyInventoryTableView: UITableView!
    
    @IBOutlet weak var mReserveView: UIView!
    @IBOutlet weak var mReserveHeader: UIView!
    
    @IBOutlet weak var mSubmitReserve: UIButton!
    
    @IBOutlet weak var mInventoryDetailsView: UIView!
    @IBOutlet weak var mInventoryDetailsHeight: NSLayoutConstraint!
   
    @IBOutlet weak var mSummaryDetailsView: UIView!
    @IBOutlet weak var mReserveTableView: UITableView!
    @IBOutlet weak var mSummaryTableView: UITableView!
    
    @IBOutlet weak var mStatusDot: UILabel!
    @IBOutlet weak var mStockName: UILabel!
    @IBOutlet weak var mMetaTag: UILabel!
    @IBOutlet weak var mMetalName: UILabel!
    @IBOutlet weak var mStoneName: UILabel!
    @IBOutlet weak var mSize: UILabel!
    @IBOutlet weak var mCollectionName: UILabel!
    @IBOutlet weak var mLocationName: UILabel!
    @IBOutlet weak var mShareLabel: UILabel!

    //ShorSummary
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

    //Filters
    @IBOutlet weak var mItemCollectionView: UICollectionView!
    @IBOutlet weak var mCollectCollectionView: UICollectionView!
    @IBOutlet weak var mStoneCollectionView: UICollectionView!
    @IBOutlet weak var mMetalCollectionView: UICollectionView!
    @IBOutlet weak var mLocationCollectionView: UICollectionView!
    
    @IBOutlet weak var mSizeCollectionView: UICollectionView!
    
    @IBOutlet weak var mPriceRange: RangeSeekSlider!
    
    @IBOutlet weak var mMinPrice: UILabel!
    @IBOutlet weak var mMaxPrice: UILabel!
    
    var mCertificateLink = ""
    
    //Bottom view Images
    @IBOutlet weak var mSubmitReserveView: UIView!
    @IBOutlet weak var mReserveIcon: UIImageView!
    @IBOutlet weak var mPrintIcon: UIImageView!
    @IBOutlet weak var mShareIcon: UIImageView!
    @IBOutlet weak var mPrintLabel: UILabel!
    @IBOutlet weak var mReserveLabel: UILabel!
    
    @IBOutlet weak var mProductImage: UIImageView!
    
    @IBOutlet weak var mProductStatusView: UIView!
    
    /**  Filters*/
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
    
    
    /**Summary*/
    var mStoneData = ["Diamond","Ruby","Blue Sapphire","Black Onyx","Chalcedony","Aquarmarine","Lapis Lazuli","Turquoise","Topaz","Emerald","Amethyst"]
    var mSelectedIndex = [IndexPath]()
    var mSelectedData = [String]()
   
    var mSelectedInventoryIndex = [IndexPath]()
    var mSelectedInventoryData = [String]()
    
    var mInventoryData = NSMutableArray()
    var mSummaryData = NSArray()
    
    var mIndexInv = -1
    var mIndexSum = -1
    
    var mProductIdForImage = ""
    var mSKUForImage = ""
    
    var mReserveData = NSMutableArray()
    var mStoneDataArray = NSMutableArray()

    @IBOutlet weak var mTotalReserve: UILabel!

    @IBOutlet weak var mSalesPersonName: UILabel!
    var mSalesManList = [String]()
    var mSalesManIDList = [String]()
    var mCustomerId = ""
    var mSalesPersonId = ""
    @IBOutlet weak var mRemark: UITextField!
    @IBOutlet weak var mCustomerSearch: UITextField!
    
    let mCustomerSearchTableView = UITableView()
 
    var mReservProductsData = NSMutableArray()
    var mSearchCustomerData = NSArray()
    
    @IBOutlet weak var mSearchFIELD: UITextField!
    @IBOutlet weak var mInventoryHeadingLABEL: UILabel!
    @IBOutlet weak var mICollectionLABEL: UILabel!
    @IBOutlet weak var mIMetalLABEL: UILabel!
    @IBOutlet weak var mIStoneLABEL: UILabel!
    @IBOutlet weak var mISizeLABEL: UILabel!
 
    @IBOutlet weak var mSummaryStockLABEL: UILabel!
    @IBOutlet weak var mSummaryReservedLABEL: UILabel!
    @IBOutlet weak var mSummaryAvailableLABEL: UILabel!
    @IBOutlet weak var mSummaryCollectionLABEL: UILabel!
    @IBOutlet weak var mSummaryItemLABEL: UILabel!
    
    @IBOutlet weak var mProductSummaryLABEL: UILabel!
    @IBOutlet weak var mMaterialLABEL: UILabel!
    @IBOutlet weak var mPStoneLABEL: UILabel!
    @IBOutlet weak var mReferenceNoLABEL: UILabel!
    @IBOutlet weak var mCertificateLABEL: UILabel!
    
    @IBOutlet weak var mBottomReserveListLABEL: UILabel!
    
    @IBOutlet weak var mBottomPreviewLABEL: UILabel!
    @IBOutlet weak var mBottomCustomerLABEL: UILabel!
     
    @IBOutlet weak var mShowMoreInventory: UIView!
    
    var mTYPE = "S"

    override func viewDidLoad() {
        super.viewDidLoad()
        mMyInventoryTableView.isHidden = true
        mSummaryTableView.isHidden = false
        mTotalSummaryView.isHidden = false
        mSummaryDetailsView.isHidden = false
        mInventoryDetailsView.isHidden = true
        mShowHideButton.isSelected = false
        mShowHideSummaryIcon.image = UIImage(named: "bottomic")
        mProductSummaryView.isHidden = true
        mShowMoreInventory.isHidden = true
        mInventoryDetailsHeight.constant = 184.5
        mSummaryLabel.textColor = #colorLiteral(red: 0.1647058824, green: 0.1647058824, blue: 0.1647058824, alpha: 1)
        mInventoryLabel.textColor = #colorLiteral(red: 0.6431372549, green: 0.6431372549, blue: 0.6431372549, alpha: 1)
        mSummaryLine.textColor = #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)
        mInventoryLine.textColor = #colorLiteral(red: 0.6431372549, green: 0.6431372549, blue: 0.6431372549, alpha: 1)
        
        mSummaryTableView.showsVerticalScrollIndicator = false
        mMyInventoryTableView.showsVerticalScrollIndicator = false
        
        
        mGetInventorySummaryData(key : "")
        mMyInventoryTableView.delegate = self
        mMyInventoryTableView.dataSource = self
        mMyInventoryTableView.reloadData()
    
        mStoneOne.numberOfLines = 1
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTap))
        tap.delegate = self
        mStockName.isUserInteractionEnabled = true
        mStockName.addGestureRecognizer(tap)
        
        
        
    }
    
    @objc
    func onTap(){
        //OPENS SKUProductSummary at click of SKU
        print("onTap mStoneDataArray = \(mStoneDataArray)")
        for case let stone as NSDictionary in mStoneDataArray {
            print(
                stone["stone_name"] ?? "",
                "Cts =", stone["Cts"] ?? "",
                "totalStoneWt =", stone["totalStoneWt"] ?? ""
            )
        }
        if let data = mStoneDataArray.firstObject as? NSDictionary,
           let mPoProductId = data["po_product_id"] as? String {
            let storyBoard: UIStoryboard = UIStoryboard(name: "common", bundle: nil)
            if let home = storyBoard.instantiateViewController(withIdentifier: "SKUProductSummary") as? SKUProductSummary{
                print(mPoProductId)
                home.mKey = mPoProductId
                home.modalPresentationStyle = .automatic
                home.transitioningDelegate = self
                self.present(home,animated: true)
            }
            
        }
//        let storyBoard: UIStoryboard = UIStoryboard(name: "common", bundle: nil)
//        if let home = storyBoard.instantiateViewController(withIdentifier: "SKUProductSummary") as? SKUProductSummary {
//            home.mOriginalData =  NSArray(array: mStoneDataArray)
//            home.modalPresentationStyle = .automatic
//            home.transitioningDelegate = self
//            self.present(home,animated: true)
//        }
    }
    
    override func viewDidLayoutSubviews() {

 
    }
    
    override func viewWillAppear(_ animated: Bool) {
 
        mSearchFIELD.placeholder = "Search by SKU/Stock ID".localizedString
        mInventoryHeadingLABEL.text = "Inventory".localizedString
        mICollectionLABEL.text = "Collection".localizedString
        mIMetalLABEL.text = "Metal".localizedString
        mIStoneLABEL.text = "Stone".localizedString
        mISizeLABEL.text = "Size".localizedString
        mProductSummaryLABEL.text = "Product Summary".localizedString
        mMaterialLABEL.text = "Material".localizedString
        mPStoneLABEL.text = "Stone".localizedString
        mReferenceNoLABEL.text = "Reference No.".localizedString
        mCertificateLABEL.text = "Certificate".localizedString
        mBottomReserveListLABEL.text = "Reserve List".localizedString
        mBottomCustomerLABEL.text = "Customer".localizedString
        mBottomPreviewLABEL.text = "Preview".localizedString
        mSummaryStockLABEL.text = "Stock".localizedString
        mSummaryReservedLABEL.text = "Reserved".localizedString
        mSummaryAvailableLABEL.text = "Available".localizedString
        mSummaryCollectionLABEL.text = "Collection".localizedString
        mSummaryItemLABEL.text = "Item".localizedString
        mSummaryLabel.text = "Summary".localizedString
        mInventoryLabel.text = "My Inventory".localizedString
        mReserveButton.setTitle("RESERVE".localizedString, for: .normal)
 
        addDoneButtonOnKeyboard()
    
    }

    @IBAction func mScanNow(_ sender: Any) {
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "transactions", bundle: nil)
        if let mCommonScanner = storyBoard.instantiateViewController(withIdentifier: "CommonScanner") as? CommonScanner {
            mCommonScanner.delegate =  self
            mCommonScanner.mType = "Inventory"
            mCommonScanner.modalPresentationStyle = .overFullScreen
            mCommonScanner.transitioningDelegate = self
            self.present(mCommonScanner,animated: true)
        }
    }
    
    func mGetScannedData(value: String, type: String) {
        if mTYPE == "S" {
            self.mGetInventorySummaryData(key: value)
        }else {
            self.mInventorySkip = 0
            self.mGetInventoryData(key: value)
        }
    }
 
    @IBAction func mHome(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "reserveBoard", bundle: nil)
        if let home = storyBoard.instantiateViewController(withIdentifier: "HomePage1") as? HomePage {
            let transition = CATransition()
            transition.duration = 0.3
            transition.type = CATransitionType.push
            transition.subtype = CATransitionSubtype.fromLeft
            transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)

            self.navigationController?.view.layer.add(transition, forKey: kCATransition)
            self.navigationController?.pushViewController(home, animated: false)
//            self.navigationController?.pushViewController(home, animated:true)
        }
    }
    
    
    func addDoneButtonOnKeyboard(){
    let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
    doneToolbar.barStyle = .default

    let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    let done: UIBarButtonItem = UIBarButtonItem(title: "Search", style: .done, target: self, action: #selector(self.doneButtonAction))

    let items = [flexSpace, done]
    doneToolbar.items = items
    doneToolbar.sizeToFit()

        mSearchFIELD.inputAccessoryView = doneToolbar
    }

    @objc func doneButtonAction(){
        
        if mTYPE == "S" {
            self.mGetInventorySummaryData(key: mSearchFIELD.text ?? "")
        }else {
            self.mGetInventoryData(key: mSearchFIELD.text ?? "")
        }
        
        mSearchFIELD.resignFirstResponder()
    }
 
    @IBAction func mSummary(_ sender: Any) {
        
        mTYPE = "S"
        if !SiriID.isEmpty {
            mSearchFIELD.text = SiriID
            mGetInventorySummaryData(key: SiriID)
                    } else {
                        mGetInventorySummaryData(key: "")
                   }
        
         mHeight.constant = 0
        mReserveButton.isHidden = true
        mReserveButtonView.isHidden = true

        mMyInventoryTableView.isHidden = true
        mSummaryTableView.isHidden = false
        mTotalSummaryView.isHidden = false
        mSummaryDetailsView.isHidden = false
        mInventoryDetailsView.isHidden = true
        mShowHideButton.isSelected = false
        mShowHideSummaryIcon.image = UIImage(named: "bottomic")
        mProductSummaryView.isHidden = true
        mInventoryDetailsHeight.constant = 184.5
        mSummaryLabel.textColor = #colorLiteral(red: 0.1647058824, green: 0.1647058824, blue: 0.1647058824, alpha: 1)
        mInventoryLabel.textColor = #colorLiteral(red: 0.6431372549, green: 0.6431372549, blue: 0.6431372549, alpha: 1)
        mSummaryLine.backgroundColor = #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)
        mInventoryLine.backgroundColor = #colorLiteral(red: 0.6431372549, green: 0.6431372549, blue: 0.6431372549, alpha: 1)
        mSummaryLine.showAnimation{}
        mSummaryLabel.showAnimation{}
      
    }
    
    @IBAction func mMyInventrory(_ sender: Any) {
        
        if mTYPE == "S" {
            
            if !SiriID.isEmpty {
                mSearchFIELD.text = SiriID
                mGetInventoryData(key: SiriID)
                        } else {
                            mGetInventoryData(key: "")
                       }
        }
        
        mTYPE = "I"
        mMyInventoryTableView.delegate = self
        mMyInventoryTableView.dataSource = self
        mMyInventoryTableView.reloadData()
        mMyInventoryTableView.isHidden = false
        mInventoryDetailsView.isHidden = false
        mSummaryTableView.isHidden = true
        mTotalSummaryView.isHidden = true
        mSummaryDetailsView.isHidden = true
        mSummaryLabel.textColor = #colorLiteral(red: 0.6431372549, green: 0.6431372549, blue: 0.6431372549, alpha: 1)
        mInventoryLabel.textColor = #colorLiteral(red: 0.1647058824, green: 0.1647058824, blue: 0.1647058824, alpha: 1)
        mSummaryLine.backgroundColor = #colorLiteral(red: 0.6431372549, green: 0.6431372549, blue: 0.6431372549, alpha: 1)
        mInventoryLine.backgroundColor = #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)
        mInventoryLine.showAnimation{}
        mInventoryLabel.showAnimation{}

    }
    
    
    
    
    @IBAction func mOpenCertificateLink(_ sender: Any) {
        if mCertificateLink != "" {
            if let url = URL(string: mCertificateLink) {
                UIApplication.shared.open(url)
            }
        }else{
            CommonClass.showSnackBar(message: "No links found!")
        }
    }
    
    @IBAction func mShowHideProductSummary(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            mProductSummaryView.isHidden = false
            mShowHideSummaryIcon.image = UIImage(named: "top_ic")
            mInventoryDetailsHeight.constant = 360
//            mInventoryDetailsHeight.constant = 450
            UIView.animate(withDuration: 1.0) {
                self.view.layoutIfNeeded()
            }
        }else{
        
            mShowHideSummaryIcon.image = UIImage(named: "bottomic")
            mInventoryDetailsHeight.constant = 184.5
            UIView.animate(withDuration: 1.0) {
                self.mProductSummaryView.isHidden = true

                self.view.layoutIfNeeded()
            }

        }
    }
    
     
    @IBAction func mSubmitReserveItems(_ sender: Any) {

        mGetData(url: mDiamondFiltersAPI,headers: sGisHeaders,  params: ["":""]) { response , status in
            CommonClass.stopLoader()
            if status {
                if "\(response.value(forKey: "code") ?? "")" == "200" {
                    if response.value(forKey: "data") != nil {
                        
                    }
                }else{
                    if let error = response.value(forKey: "error") as? String{
                        if error == "Authorization has been expired" {
                            CommonClass.sessionExpired(isExpired: true, navigation: self.navigationController)
                        }
                    }
                }
            }
        }
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "reserveBoard", bundle: nil)
        if let mInventoryPage = storyBoard.instantiateViewController(withIdentifier: "InventoryReserveCart") as? InventoryReserveCart {
            mInventoryPage.mOriginalData =  NSArray(array: mReserveData)
            mInventoryPage.reserveSource = .myInventory
            
            print("mInventoryPage.mOriginalData = \(NSArray(array: mReserveData))")
            self.navigationController?.pushViewController(mInventoryPage, animated:true)
        }
        
    }
    
    
    @IBAction func mHideSearchFilterView(_ sender: Any) {
        mFilterSearchView.isHidden =  true
        mSearchFIELD.text = SiriID

    }
    @IBAction func mSearch(_ sender: Any) {
       
        mFilterSearchView.isHidden =  false
        mSearchFIELD.text = SiriID
     
    }
    
    @IBAction func mFilter(_ sender: Any) {
    
        view.endEditing(true)
        let storyBoard: UIStoryboard = UIStoryboard(name: "common", bundle: nil)
        if let mFilters = storyBoard.instantiateViewController(withIdentifier: "CommonFilters") as? CommonFilters {
            mFilters.delegate = self
            mFilters.mType = "inventory"
            mFilters.mItemsId = mItemsId
            mFilters.mMetalsId = mMetalsId
            mFilters.mCollectionId = mCollectionId
            mFilters.mStonesId = mStonesId
            mFilters.mSizeId = mSizeId
            mFilters.mLocationsId = mLocationsId
            mFilters.mStatusId = mStatusId
            mFilters.mMinPrices = mMinPrices
            mFilters.mMaxPrices = mMaxPrices
            mFilters.modalPresentationStyle = .automatic
            mFilters.transitioningDelegate = self
            self.present(mFilters,animated: true)
        }
    }
    
    
    
    
    
    @IBAction func mMinimizeFilter(_ sender: Any) {
        mFilterView.slideTop()
        mFilterView.isHidden = true
        mFilterSearchView.isHidden = true
        mSearchButtonView.isHidden =  false
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

        
          if mTYPE == "S"{
              mGetInventorySummaryData(key:"")

          }else{
              mInventorySkip = 0
              mGetInventoryData(key: "")
             
          }
    }
    
    @IBAction func mApplyFilter(_ sender: Any) {
       
    }
    
    @IBAction func mHideReserveView(_ sender: Any) {
        
        mReserveView.slideTop()
        mReserveView.isHidden = true
   
        mReserveIcon.image = UIImage(named: "calendaricon")
        mPrintIcon.image = UIImage(named: "printicon")
        mShareIcon.image = UIImage(named: "shareicon")
        mReserveLabel.textColor =    #colorLiteral(red: 0.6745098039, green: 0.6588235294, blue: 0.6588235294, alpha: 1)
        mPrintLabel.textColor =  #colorLiteral(red: 0.6745098039, green: 0.6588235294, blue: 0.6588235294, alpha: 1)
        mShareLabel.textColor = #colorLiteral(red: 0.6745098039, green: 0.6588235294, blue: 0.6588235294, alpha: 1)
    }
    
    
    
    @IBAction func mSearchCustomer(_ sender: Any) {
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let mPrint = storyBoard.instantiateViewController(withIdentifier: "SearchCustomer") as? SearchCustomer {
            self.navigationController?.pushViewController(mPrint, animated:true)
        }
    }
    
    
    @IBAction func mAddCustomer(_ sender: Any) {
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let mPrint = storyBoard.instantiateViewController(withIdentifier: "RegisterCustomer") as? RegisterCustomer {
            self.navigationController?.pushViewController(mPrint, animated:true)
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        if tableView == mReserveTableView {
            count = mReserveData.count
            
        }else if tableView == mMyInventoryTableView {
            count =  mInventoryData.count
        }else if tableView == mSummaryTableView
        {
            count = mSummaryData.count
        }else  if tableView == mCustomerSearchTableView {
            count = mSearchCustomerData.count
        }
       
        return count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        
        
        var cell  = UITableViewCell()
        if tableView == mMyInventoryTableView {
            guard let  cells = tableView.dequeueReusableCell(withIdentifier: "InventoryCell") as? InventoryCell else {
                return UITableViewCell()
            }
            
            cells.mView.backgroundColor = (indexPath.row % 2 == 0) ? UIColor(named: "themeBackground") : #colorLiteral(red: 0.9568627451, green: 0.9568627451, blue: 0.9568627451, alpha: 1)
            
            if let mData = mInventoryData[indexPath.row] as? NSDictionary {
                
                if let isDesign = mData.value(forKey: "isDesign") as? Bool {
                    if isDesign {
                        cells.mDesignView.isHidden = false
                    }else{
                        cells.mDesignView.isHidden = true
                    }
                }else{
                    cells.mDesignView.isHidden = true
                }
                
                if mSelectedInventoryIndex.count == 0 {
                    mHeight.constant = 0
                    mReserveButton.isHidden = true
                    mReserveButtonView.isHidden = true
                }else {
                    mHeight.constant = 90
                    mReserveButton.isHidden = false
                    mReserveButtonView.isHidden = false
                    mReserveButtonView.layer.cornerRadius = 10
                    mReserveButtonView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
                }
                
                cells.mStockName.text = "\(mData.value(forKey: "SKU") ?? "--")"
                cells.mStockId.text = "\(mData.value(forKey: "stock_id") ?? "--")"
                cells.mQuantity.text = "\(mData.value(forKey: "po_QTY") ?? "--") Pcs"
                cells.mAmount.text =  "\(mData.value(forKey: "price") ?? "--")"
                
                cells.mStatusColor.textColor = .clear
                if let statusType = mData.value(forKey: "status_type") as? String {
                    if statusType == "stock" {
                        cells.mStatusColor.backgroundColor = #colorLiteral(red: 0.4588235294, green: 0.8, blue: 1, alpha: 1)
                    }else if statusType == "reserve" {
                        cells.mStatusColor.backgroundColor = #colorLiteral(red: 1, green: 0.7386777401, blue: 0.3924969435, alpha: 1)
                    }else if statusType == "custom_order" {
                        cells.mStatusColor.backgroundColor = #colorLiteral(red: 0.9137254902, green: 0.4392156863, blue: 0.4392156863, alpha: 1)
                    }else if statusType == "repair_order" {
                        cells.mStatusColor.backgroundColor = #colorLiteral(red: 0.662745098, green: 0.6078431373, blue: 0.7411764706, alpha: 1)
                    }else if statusType == "warehouse" {
                        cells.mStatusColor.backgroundColor = #colorLiteral(red: 0.4392156863, green: 0.4392156863, blue: 0.4392156863, alpha: 1)
                    }else if statusType == "transit" {
                        cells.mStatusColor.backgroundColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
                    }
                }else{
                    cells.mStatusColor.backgroundColor = #colorLiteral(red: 0.4588235294, green: 0.8, blue: 1, alpha: 1)
                }
                
                if mSelectedInventoryIndex.contains(indexPath) {
                    cells.mCheckIcon.image = UIImage(named: "check_item")
                }else{
                    cells.mCheckIcon.image = UIImage(named: "uncheck_item")
                    
                }
                
                cells.layoutSubviews()
                
                if mIndexInv == indexPath.row   {
                    if let statusType = mData.value(forKey: "status_type") as? String {
                        if  statusType == "stock" {
                            self.mProductStatus.textColor = #colorLiteral(red: 0.4588235294, green: 0.8, blue: 1, alpha: 1)
                            self.mStatusDot.backgroundColor = #colorLiteral(red: 0.4588235294, green: 0.8, blue: 1, alpha: 1)
                            self.mProductStatus.text = "Stock"
                        }else if statusType == "reserve" {
                            self.mProductStatus.textColor = #colorLiteral(red: 1, green: 0.7386777401, blue: 0.3924969435, alpha: 1)
                            self.mStatusDot.backgroundColor = #colorLiteral(red: 1, green: 0.7386777401, blue: 0.3924969435, alpha: 1)
                            self.mProductStatus.text = "Reserved"
                        }else if statusType == "custom_order" {
                            self.mProductStatus.textColor = #colorLiteral(red: 0.9137254902, green: 0.4392156863, blue: 0.4392156863, alpha: 1)
                            self.mStatusDot.backgroundColor = #colorLiteral(red: 0.9137254902, green: 0.4392156863, blue: 0.4392156863, alpha: 1)
                            self.mProductStatus.text = "Reserved"
                        }else if statusType == "repair_order"  {
                            self.mProductStatus.textColor = #colorLiteral(red: 0.662745098, green: 0.6078431373, blue: 0.7411764706, alpha: 1)
                            self.mStatusDot.backgroundColor = #colorLiteral(red: 0.662745098, green: 0.6078431373, blue: 0.7411764706, alpha: 1)
                            self.mProductStatus.text = "Repair"
                        }else if statusType == "warehouse" {
                            self.mProductStatus.textColor = #colorLiteral(red: 0.4392156863, green: 0.4392156863, blue: 0.4392156863, alpha: 1)
                            self.mStatusDot.backgroundColor = #colorLiteral(red: 0.4392156863, green: 0.4392156863, blue: 0.4392156863, alpha: 1)
                            self.mProductStatus.text = "WareHouse"
                        }else if statusType == "transit" {
                            self.mProductStatus.textColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
                            self.mStatusDot.backgroundColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
                            self.mProductStatus.text = "Transit"
                        }
                    }else{
                        self.mProductStatus.textColor = #colorLiteral(red: 0.4588235294, green: 0.8, blue: 1, alpha: 1)
                        self.mStatusDot.backgroundColor = #colorLiteral(red: 0.4588235294, green: 0.8, blue: 1, alpha: 1)
                        self.mProductStatus.text = "Stock"
                    }
                }
            }
            cell = cells
            
        }else if tableView == mSummaryTableView {
            
            guard let cells = tableView.dequeueReusableCell(withIdentifier: "SummaryCell") as? SummaryCell else {
                return UITableViewCell()
            }
            
            cells.mView.backgroundColor = (indexPath.row % 2 == 0) ? UIColor(named: "themeBackground") : #colorLiteral(red: 0.9568627451, green: 0.9568627451, blue: 0.9568627451, alpha: 1)
            
            if let mData = mSummaryData[indexPath.row] as? NSDictionary {
                
                cells.mLocation.text = "\(mData.value(forKey: "SKU") ?? "--")"
                cells.mStock.text = "\(mData.value(forKey: "totalStock") ?? "-")"
                cells.mReserve.text = "\(mData.value(forKey: "reserveStock") ?? "-")"
                cells.mAvailable.text = "\(mData.value(forKey: "availableStock") ?? "-")"
            }
            cell = cells
 
        }
       
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
          if tableView == mCustomerSearchTableView {
            return 78
        }
        return 52
        
    }
    
    func getFullMetalName(_ code: String) -> String {
        switch code.uppercased() {
        case "WG":
            return "White Gold"

        case "YG":
            return "Yellow Gold"

        case "RG":
            return "Rose Gold"

        default:
            return code
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        
        if tableView == mReserveTableView {
            
            _ = tableView.dequeueReusableCell(withIdentifier: "ReserveCell") as? ReserveCell
            
        }else if tableView == mMyInventoryTableView {
            
            if  mTYPE != "S"{
                
                mIndexInv = indexPath.row
                
                if let mData = mInventoryData[indexPath.row] as? NSDictionary {
                    if let image = mData.value(forKey: "main_image") as? String {
                        self.mInventoryImage.downlaodImageFromUrl(urlString: image)
                    }
                    
                    self.mSKUForImage = "\(mData.value(forKey: "SKU") ?? "--")"
                    self.mProductIdForImage = "\(mData.value(forKey: "parentproduct_id") ?? "")"
                    
                    self.mStockID.text = "\(mData.value(forKey: "stock_id") ?? "")"
                    self.mStockName.text = "\(mData.value(forKey: "SKU") ?? "")"
                    self.mMetaTag.text = "\(mData.value(forKey: "Matatag") ?? "")"
                    self.mLocationName.text = "\(mData.value(forKey: "location_name") ?? "")"
                    self.mMetalName.text = "\(mData.value(forKey: "metal_name") ?? "")"
                    self.mStoneName.text = "\(mData.value(forKey: "Stone_name") ?? "")"
                    self.mSize.text = "\(mData.value(forKey: "size_name") ?? "")"
                    self.mCollectionName.text = "\(mData.value(forKey: "collection_name") ?? "")"
                    
//                    self.mMaterialName.text = "\(mData.value(forKey: "metal_name") ?? "--")"
//                    let stoneName = "\(mData.value(forKey: "stone_name") ?? "--")"
//                    self.mStoneOne.text = stoneName.replacingOccurrences(
//                        of: ",",
//                        with: "\n"
//                    )
////                    self.mStoneOne.text = "\(mData.value(forKey: "stone_name") ?? "--")"
//                    self.mReferenceName.text = "\(mData.value(forKey: "referenceNo") ?? "--")"
//                    self.mMaterialWeight.text = "\(mData.value(forKey: "NetWt") ?? "--")"
//                    self.mStoneOneWeight.text = "\(mData.value(forKey: "Cts") ?? "--")"
//                    self.mCertificateName.text = "\(mData.value(forKey: "certificate_type") ?? "--")"
//                    self.mCertificateNumber.text = "\(mData.value(forKey: "certificate_number") ?? "--")"
                    
//                    self.mMaterialName.text = "\(mData.value(forKey: "metal_name") ?? "--")"
                    let metalCode =
                        "\(mData["metal_name"] ?? mData["Metal_name"] ?? "")"

                    self.mMaterialName.text = getFullMetalName(metalCode)
                    self.mMaterialName.textAlignment = .left
                    self.mMaterialName.numberOfLines = 0

                    // ---------- Stone ----------
                    if let stoneArray = mData.value(forKey: "stoneData") as? NSArray {

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


                        // Reset ทุก label ก่อน
                        self.mStoneOne.text = ""
                        self.mStoneOneWeight.text = ""

                        self.mStoneTwo.text = ""
                        self.mStoneTwoWeight.text = ""


                        // Stone 1
                        if stoneOrder.indices.contains(0),
                           let stone1 = stoneSummary[stoneOrder[0]] {

                            self.mStoneOne.text = stone1.displayName
                            let formatter = NumberFormatter()
                            formatter.minimumFractionDigits = 0
                            formatter.maximumFractionDigits = 3

                            let ctsText = formatter.string(from: NSNumber(value: stone1.cts)) ?? "0"
                            self.mStoneOneWeight.text =
                                "\(stone1.pcs)      \(ctsText) c "
                        }


                        // Stone 2 - ใส่เฉพาะกรณีที่เป็นอีกชนิดจริง ๆ
                        if stoneOrder.indices.contains(1),
                           let stone2 = stoneSummary[stoneOrder[1]] {

                            self.mStoneTwo.text = stone2.displayName
                            let formatter = NumberFormatter()
                            formatter.minimumFractionDigits = 0
                            formatter.maximumFractionDigits = 3

                            let ctsText = formatter.string(from: NSNumber(value: stone2.cts)) ?? "0"
                            self.mStoneTwoWeight.text =
                                "\(stone2.pcs)     \(ctsText) c "
                        }

                    } else {

                        self.mStoneOne.text = ""
                        self.mStoneOneWeight.text = ""

                        self.mStoneTwo.text = ""
                        self.mStoneTwoWeight.text = ""
                    }
//                    if let stoneArray = mData.value(forKey: "stoneData") as? NSArray {
//
//                        var stoneNames: [String] = []
//                        var stoneWeights: [String] = []
//
//                        for item in stoneArray {
//
//                            guard let stone = item as? NSDictionary else { continue }
//
//                            stoneNames.append("\(stone.value(forKey: "stone") ?? "--")")
////                            stoneWeights.append("\(stone.value(forKey: "Cts") ?? "--")")
//                            let cts = "\(stone.value(forKey: "Cts") ?? "--")"
//
//                            if cts != "--" {
//
//                                stoneWeights.append("\(cts) Cts")
//
//                            } else {
//
//                                stoneWeights.append("--")
//
//                            }
//                        }
//
//                        self.mStoneOne.text = stoneNames.joined(separator: "\n")
//                        self.mStoneOneWeight.text = stoneWeights.joined(separator: "\n")
//
//                    } else {
//
//                        self.mStoneOne.text = "--"
//                        self.mStoneOneWeight.text = "--"
//                    }

                    // ---------- Other ----------
                    self.mReferenceName.text = "\(mData.value(forKey: "referenceNo") ?? "--")"
                    self.mMaterialWeight.text = "\(mData.value(forKey: "NetWt") ?? "--")"
                    let weight = "\(mData.value(forKey: "NetWt") ?? "--")"
                    if weight != "--" {

                        self.mMaterialWeight.text = "\(weight) g "

                    } else {

                        self.mMaterialWeight.text = "--"

                    }
                    self.mCertificateName.text = "\(mData.value(forKey: "certificate_type") ?? "--")"
                    self.mCertificateNumber.text = "\(mData.value(forKey: "certificate_number") ?? "--")"
                    
                    self.mStoneOne.numberOfLines = 0
                    self.mStoneOneWeight.numberOfLines = 0
                    self.mStoneTwo.numberOfLines = 0
                    self.mStoneTwoWeight.numberOfLines = 0
                    self.mStoneOne.lineBreakMode = .byWordWrapping
                    self.mStoneOneWeight.lineBreakMode = .byWordWrapping
                    self.mStoneOne.textAlignment = .left
                    self.mStoneOneWeight.textAlignment = .right
                    self.mStoneTwo.lineBreakMode = .byWordWrapping
                    self.mStoneTwoWeight.lineBreakMode = .byWordWrapping
                    self.mStoneTwo.textAlignment = .left
                    self.mStoneTwoWeight.textAlignment = .right
                    
                    if let statusType = mData.value(forKey: "status_type") as? String {
                        if statusType == "stock" || statusType == "warehouse" {
                            
                            if self.mSelectedInventoryIndex.contains(indexPath) {
                                self.mSelectedInventoryIndex = mSelectedInventoryIndex.filter {$0 != indexPath }
                                if let mInvData = mInventoryData[indexPath.row] as? NSDictionary {
                                    let mData = NSMutableDictionary()
                                    mData.setValue("\(mInvData.value(forKey: "po_product_id") ?? "")", forKey: "id")
                                    mData.setValue("1", forKey: "quantity")
//                                    mData.setValue("\(mInvData.value(forKey: "po_QTY") ?? "0")", forKey: "po_QTY")
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
                                    mData.setValue("\(mInvData.value(forKey: "price") ?? "0")", forKey: "price")
                                    mData.setValue("\(mInvData.value(forKey: "Matatag") ?? "--")", forKey: "Matatag")
                                    mData.setValue("\(mInvData.value(forKey: "main_image") ?? "")", forKey: "image")
                                    mData.setValue("\(mInvData.value(forKey: "metal_name") ?? "")", forKey: "metal")
                                    mData.setValue("\(mInvData.value(forKey: "size_name") ?? "")", forKey: "size")
                                    let currentDateTime = Date()
                                    let formatter = DateFormatter()
//                                    formatter.dateFormat = "MM/dd/yyy"
                                    formatter.dateFormat = "MM/dd/yyyy"
                                    mData.setValue("\(formatter.string(from: currentDateTime))", forKey: "dueDate")
                                    mData.setValue("", forKey: "notes")
                                    mData.setValue("\(mInvData.value(forKey: "location_id") ?? "")", forKey: "location_id")
                                    mReserveData.remove(mData)
                                }
                            }else{
                                self.mSelectedInventoryIndex.append(indexPath)
                                if let mInvData = mInventoryData[indexPath.row] as? NSDictionary {
                                    let mData = NSMutableDictionary()
                                    mData.setValue("\(mInvData.value(forKey: "po_product_id") ?? "")", forKey: "id")
                                    mData.setValue("1", forKey: "quantity")
//                                    mData.setValue("\(mInvData.value(forKey: "po_QTY") ?? "0")", forKey: "po_QTY")
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
                                    mData.setValue("\(mInvData.value(forKey: "price") ?? "0")", forKey: "price")
                                    mData.setValue("\(mInvData.value(forKey: "Matatag") ?? "")", forKey: "Matatag")
                                    mData.setValue("\(mInvData.value(forKey: "main_image") ?? "")", forKey: "image")
                                    mData.setValue("\(mInvData.value(forKey: "metal_name") ?? "")", forKey: "metal")
                                    mData.setValue("\(mInvData.value(forKey: "size_name") ?? "")", forKey: "size")
                                    let currentDateTime = Date()
                                    let formatter = DateFormatter()
//                                    formatter.dateFormat = "MM/dd/yyy"
                                    formatter.dateFormat = "MM/dd/yyyy"
                                    mData.setValue("\(formatter.string(from: currentDateTime))", forKey: "dueDate")
                                    mData.setValue("", forKey: "notes")
                                    mData.setValue("\(mInvData.value(forKey: "voucher_id") ?? "")", forKey: "voucher_id")
                                    mData.setValue("\(mInvData.value(forKey: "location_id") ?? "")", forKey: "location_id")
                                    mReserveData.add(mData)
                                }
                            }
                        }
                        
                        if statusType == "custom_order" || statusType == "reserve" || statusType == "repair_order" {
                            if let mCOData = mData.value(forKey: "pos") as? NSDictionary {
                                if self.mCustomerId != "\(mCOData.value(forKey: "customer_id") ?? "")" {
                                    CommonClass.showSnackBar(message: "This Item is reserved for \(mCOData.value(forKey: "customer_name") ?? "Other user")")
                                    return
                                }
                            }
                        }
                    }
                    self.mStoneDataArray = NSMutableArray()
                    print("InventoryPage.swift \(mData)")
                    
                    self.mStoneDataArray.add(mData)
                    self.mMyInventoryTableView.reloadData()
                }
            }
        }else if tableView == mSummaryTableView {
            
            if let mData = mSummaryData[indexPath.row] as? NSDictionary {
                self.mSummerySkuDetails(id: "\(mData.value(forKey: "po_product_id") ?? "")")
            }
        }
    }
    
    
    @IBAction func mOpenImageViewer(_ sender: Any) {
        if mProductIdForImage != "" {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Test", bundle: nil)
            if let mGlobalImageViewer = storyBoard.instantiateViewController(withIdentifier: "GlobalImageViewer") as? GlobalImageViewer {
                mGlobalImageViewer.modalPresentationStyle = .overFullScreen
                mGlobalImageViewer.mProductId =
                mProductIdForImage
                mGlobalImageViewer.mSKUName = mSKUForImage
                mGlobalImageViewer.transitioningDelegate = self
                self.present(mGlobalImageViewer,animated: false)
            }
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
         
        }else if collectionView == self.mLocationCollectionView {
            count = mLocationsData.count
       
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
            guard let cells = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath) as? ItemCell else {return cell}
            if let mData =  mItemsData[indexPath.row] as? NSDictionary {
                cells.mItemName.text = mData.value(forKey: "name") as? String
                
                if let id = mData.value(forKey: "id") as? String, mItemsId.contains(id) {
                    cells.mItemName.backgroundColor =  #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)
                    cells.backgroundColor =  #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)
                }else{
                    cells.mItemName.backgroundColor =  #colorLiteral(red: 0.8078431373, green: 0.9333333333, blue: 0.9254901961, alpha: 1)
                    cells.backgroundColor =  #colorLiteral(red: 0.8078431373, green: 0.9333333333, blue: 0.9254901961, alpha: 1)
                }
            }
            cells.layoutSubviews()
            cell = cells
        }else if collectionView == self.mCollectCollectionView {
            guard let cells = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as? CollectionCell else {return cell}
            if let mData =  mCollectionData[indexPath.row] as? NSDictionary {
                cells.mCollectionName.text = mData.value(forKey: "name") as? String
                
                if let id = mData.value(forKey: "id") as? String, mCollectionId.contains(id) {
                    cells.mCollectionName.backgroundColor =  #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)
                    cells.backgroundColor =  #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)
                }else{
                    cells.mCollectionName.backgroundColor =  #colorLiteral(red: 0.8078431373, green: 0.9333333333, blue: 0.9254901961, alpha: 1)
                    cells.backgroundColor =  #colorLiteral(red: 0.8078431373, green: 0.9333333333, blue: 0.9254901961, alpha: 1)
                }
            }
            cells.layoutSubviews()
            cell = cells
            
        }else if collectionView == self.mMetalCollectionView {
            guard let cells = collectionView.dequeueReusableCell(withReuseIdentifier: "MetalCell", for: indexPath) as? MetalCell else {return cell}
            if let mData =  mMetalsData[indexPath.row] as? NSDictionary{
                cells.mMetalName.text = mData.value(forKey: "name") as? String
                
                if let id = mData.value(forKey: "id") as? String, mMetalsId.contains(id) {
                    cells.mMetalName.backgroundColor =  #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)
                    cells.backgroundColor =  #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)
                }else{
                    cells.mMetalName.backgroundColor =  #colorLiteral(red: 0.8078431373, green: 0.9333333333, blue: 0.9254901961, alpha: 1)
                    cells.backgroundColor =  #colorLiteral(red: 0.8078431373, green: 0.9333333333, blue: 0.9254901961, alpha: 1)
                }
            }
            cells.layoutSubviews()
            cell = cells
            
        }else if collectionView == self.mSizeCollectionView {
            guard let cells = collectionView.dequeueReusableCell(withReuseIdentifier: "SizeCell", for: indexPath) as? SizeCell else {return cell}
            if let mData =  mSizeData[indexPath.row] as? NSDictionary {
                cells.mSizeName.text = mData.value(forKey: "name") as? String
                
                if let id = mData.value(forKey: "id") as? String, mSizeId.contains(id) {
                    cells.mSizeName.backgroundColor =  #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)
                    cells.backgroundColor =  #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)
                }else{
                    cells.mSizeName.backgroundColor =  #colorLiteral(red: 0.8078431373, green: 0.9333333333, blue: 0.9254901961, alpha: 1)
                    cells.backgroundColor =  #colorLiteral(red: 0.8078431373, green: 0.9333333333, blue: 0.9254901961, alpha: 1)
                }
            }
            cells.layoutSubviews()
            cell = cells
            
        }else if collectionView == self.mLocationCollectionView {
            guard let cells = collectionView.dequeueReusableCell(withReuseIdentifier: "LocationCell", for: indexPath) as? LocationCell else {return cell}
            if let mData =  mLocationsData[indexPath.row] as? NSDictionary{
                cells.mLocationName.text = mData.value(forKey: "name") as? String
                
                if let id = mData.value(forKey: "id") as? String, mLocationsId.contains(id) {
                    cells.mLocationName.backgroundColor =  #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)
                    cells.backgroundColor =  #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)
                }else{
                    cells.mLocationName.backgroundColor =  #colorLiteral(red: 0.8078431373, green: 0.9333333333, blue: 0.9254901961, alpha: 1)
                    cells.backgroundColor =  #colorLiteral(red: 0.8078431373, green: 0.9333333333, blue: 0.9254901961, alpha: 1)
                }
            }
            cells.layoutSubviews()
            cell = cells
            
        }else if collectionView == self.mStoneCollectionView {
            guard let cells = collectionView.dequeueReusableCell(withReuseIdentifier: "StoneCell", for: indexPath) as? StoneCell else {return cell}
            if let mData =  mStonesData[indexPath.row] as? NSDictionary{
                cells.mCStone.text = mData.value(forKey: "name") as? String
                
                if let id = mData.value(forKey: "id") as? String, mStonesId.contains(id) {
                    cells.mCStone.backgroundColor =  #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)
                    cells.backgroundColor =  #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)
                }else{
                    cells.mCStone.backgroundColor =  #colorLiteral(red: 0.8078431373, green: 0.9333333333, blue: 0.9254901961, alpha: 1)
                    cells.backgroundColor =  #colorLiteral(red: 0.8078431373, green: 0.9333333333, blue: 0.9254901961, alpha: 1)
                }
            }
            cells.layoutSubviews()
            cell = cells
        }
        
        return cell
    }
    

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.mStoneCollectionView {
          
            if let mData = mStonesData[indexPath.row] as? NSDictionary{
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
                        mLocationsId = mLocationsId.filter {$0 != id}
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
                        mCollectionId = mCollectionId.filter {$0 != id }
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
                        mSizeId = mSizeId.filter {$0 != id }
                    }else{
                        mSizeId.append(id)
                    }
                }
            }
            
            self.mSizeCollectionView.reloadData()
        }
       
    }

    
    
    @IBAction func mShowmore(_ sender: Any) {
        
        self.mGetInventoryData(key : "")
    }
    
    @IBAction func mClearAllFilters(_ sender: Any) {
    
        self.mItemsId.removeAll()
        self.mCollectionId.removeAll()
        self.mMetalsId.removeAll()
        self.mStonesId.removeAll()
        self.mLocationsId.removeAll()
        self.mSizeId.removeAll()
        self.mItemCollectionView.reloadData()
        self.mCollectCollectionView.reloadData()
        self.mMetalCollectionView.reloadData()
        self.mStoneCollectionView.reloadData()
        self.mLocationCollectionView.reloadData()
        self.mSizeCollectionView.reloadData()
        
        
    
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
                    if let id = mData.value(forKey: "id") as? String {
                        mItemsId.append(id)
                    }
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
                if let mData = element as? NSDictionary,
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
            
        }else {
            sender.setTitle("Deselect".localizedString, for: .normal)
            sender.isSelected = true
            
            mStonesId.removeAll()
            for element in self.mStonesData {
                if let mData = element as? NSDictionary,
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
            sender.setTitle("Deselect".localizedString, for: .normal)
            sender.isSelected = true
            mMetalsId.removeAll()
            
            for element in self.mMetalsData {
                if let mData = element as? NSDictionary,
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
    
            for element in self.mLocationsData {
                if let mData = element as? NSDictionary,
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
            
            
            for element in self.mSizeData {
                if let mData = element as? NSDictionary,
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

    @IBAction func mEditQuantity(_ sender: UITextField) {
        
        let index = sender.tag
        if let mInvData = mReserveData[index] as? NSDictionary {
            
            var qty = [Int]()
            
            if sender.text != "" {
                var mQty = Int(sender.text ?? "")
                
                if mQty == 0 || sender.text == "" {
                    sender.text = "1"
                    mQty = 1
                    let mData = NSMutableDictionary()
                    mData.setValue("\(mInvData.value(forKey: "id") ?? "")", forKey: "id")
                    mData.setValue("\(mQty ?? 1)", forKey: "reserve_qty")
                    mData.setValue("\(mInvData.value(forKey: "SKU") ?? "")", forKey: "SKU")
                    mData.setValue("\(mInvData.value(forKey: "stock_id") ?? "")", forKey: "stock_id")
                    mData.setValue("\(mInvData.value(forKey: "Retail_price") ?? "")", forKey: "Retail_price")
                    
                    mData.setValue("\(mInvData.value(forKey: "transaction_stock_id") ?? "")", forKey: "transaction_stock_id")
                    
                    mReserveData.removeObject(at: index)
                    mReserveData.insert(mData, at: index)
                    mReservProductsData = NSMutableArray()
                    for item in mReserveData {
                        if let value = item as? NSDictionary {
                            let mData = NSMutableDictionary()
                            mData.setValue("\(value.value(forKey: "id") ?? "")", forKey: "id")
                            mData.setValue("\(value.value(forKey: "reserve_qty") ?? "")", forKey: "reserve_qty")
                            mData.setValue("\(value.value(forKey: "transaction_stock_id") ?? "")", forKey: "transaction_stock_id")
                            qty.append(Int("\(value.value(forKey: "reserve_qty") ?? "1")") ?? 1)
                            
                            mReservProductsData.add(mData)
                        }
                    }
                }else {
                    let mData = NSMutableDictionary()
                    mData.setValue("\(mInvData.value(forKey: "id") ?? "")", forKey: "id")
                    mData.setValue("\(mQty ?? 1)", forKey: "reserve_qty")
                    mData.setValue("\(mInvData.value(forKey: "SKU") ?? "")", forKey: "SKU")
                    mData.setValue("\(mInvData.value(forKey: "stock_id") ?? "")", forKey: "stock_id")
                    mData.setValue("\(mInvData.value(forKey: "Retail_price") ?? "")", forKey: "Retail_price")
                    
                    mData.setValue("\(mInvData.value(forKey: "transaction_stock_id") ?? "")", forKey: "transaction_stock_id")
                    
                    mReserveData.removeObject(at: index)
                    mReserveData.insert(mData, at: index)
                    mReservProductsData = NSMutableArray()
                    for item in mReserveData {
                        if let value = item as? NSDictionary {
                            let mData = NSMutableDictionary()
                            mData.setValue("\(value.value(forKey: "id") ?? "")", forKey: "id")
                            mData.setValue("\(value.value(forKey: "reserve_qty") ?? "")", forKey: "reserve_qty")
                            mData.setValue("\(value.value(forKey: "transaction_stock_id") ?? "")", forKey: "transaction_stock_id")
                            qty.append(Int("\(value.value(forKey: "reserve_qty") ?? "0")") ?? 0)
                            
                            mReservProductsData.add(mData)
                        }
                    }
                    
                }
                mTotalReserve.text =  "\(qty.reduce(0, {$0 + $1}))"
                
            }
        }
    }
    
    
    @IBAction func mOpenCustomer(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "reserveBoard", bundle: nil)
        if let home = storyBoard.instantiateViewController(withIdentifier: "CustomerSearch") as? CustomerSearch {
            self.navigationController?.pushViewController(home, animated:true)
        }
    }
    
    @IBAction func mReserve(_ sender: Any) {
        print("InventoryPage.swift mReserve")
        let storyBoard: UIStoryboard = UIStoryboard(name: "reserveBoard", bundle: nil)
        if let mInventoryPage = storyBoard.instantiateViewController(withIdentifier: "InventoryReservedItems") as? InventoryReservedItems {
            mInventoryPage.mType = "Inventory"
            
            self.navigationController?.pushViewController(mInventoryPage, animated:true)
        }
    }
    
    
    @IBAction func mShare(_ sender: Any) {
        
        mReserveIcon.image = UIImage(named: "calendaricon")
        mPrintIcon.image = UIImage(named: "printicon")
        mShareIcon.image = UIImage(named: "shareicongreen")
        
        mReserveLabel.textColor =  #colorLiteral(red: 0.6745098039, green: 0.6588235294, blue: 0.6588235294, alpha: 1)
        mPrintLabel.textColor =  #colorLiteral(red: 0.6745098039, green: 0.6588235294, blue: 0.6588235294, alpha: 1)
        mShareLabel.textColor =  #colorLiteral(red: 0.2392156863, green: 0.7019607843, blue: 0.6196078431, alpha: 1)
    }
    
    
    @IBAction func mPreview(_ sender: Any) {
 
        let storyBoard: UIStoryboard = UIStoryboard(name: "Test", bundle: nil)
        if let mPrint = storyBoard.instantiateViewController(withIdentifier: "PrintItem") as? PrintItem {
            mPrint.mTYPE = mTYPE
            
            mPrint.filters = [
                "price": ["min": mMinPrices, "max": mMaxPrices],
                "item": mItemsId,
                "collection": mCollectionId,
                "location": mLocationsId,
                "metal": mMetalsId,
                "stone": mStonesId,
                "size": mSizeId,
                "status": mStatusId
            ]
            self.navigationController?.pushViewController(mPrint, animated:true)
        }
    }



    func mGetInventoryData(key : String){

        let mPriceData = NSMutableDictionary()
        mPriceData.setValue(mMinPrices, forKey: "min")
        mPriceData.setValue(mMaxPrices, forKey: "max")
        mFilterData.setValue(mPriceData, forKey: "price")
        mFilterData.setValue(mItemsId, forKey: "item")
        mFilterData.setValue(mCollectionId, forKey: "collection")
        mFilterData.setValue(mLocationsId, forKey: "location")
        mFilterData.setValue(mMetalsId, forKey: "metal")
        mFilterData.setValue(mStonesId, forKey: "stone")
        mFilterData.setValue(mSizeId, forKey: "size")
        mFilterData.setValue(mStatusId, forKey: "status")

        let mLocation = UserDefaults.standard.string(forKey: "location") ?? ""
        
        let urlPath =  mGetInventory
        var params = ["location":mLocation,"filter": mFilterData ,"search":key ] as [String : Any]
        
        if key.trim().isEmpty {
            params["skip"] = mInventorySkip
            params["limit"] = mInventoryFetchLimit
        }
        
        mShowMoreInventory.isHidden = true

        guard Reachability.isConnectedToNetwork() == true else {
            CommonClass.showSnackBar(message: "No Internet Connection")
            return
        }
        print("mGetInventoryData params = ",params)
        print("""
        ========== PAGINATION ==========
        skip = \(mInventorySkip)
        limit = \(mInventoryFetchLimit)
        total(before) = \(mInventoryTotal)
        ===============================
        """)
        CommonClass.showFullLoader(view: self.view)
        AF.request(urlPath, method:.post,parameters: params ,encoding: JSONEncoding.default, headers: sGisHeaders2).responseJSON
        { response in
            CommonClass.stopLoader()
            print("mGetInventoryData response = ",response)
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
                            
                if let mData = jsonResult.value(forKey: "data") as? NSArray {

                    print("""
                    ========== RESPONSE ==========
                    total = \(jsonResult["total"] ?? "")
                    count = \(jsonResult["count"] ?? "")
                    data.count = \(mData.count)
                    ==============================
                    """)
                    
                    if let skip = params["skip"] as? Int, skip > 0, mData.count == 0 {

                        // ไม่มีหน้าถัดไป
                        self.mShowMoreInventory.isHidden = true
                        return
                    }
                    
                    self.mInventoryTotal = jsonResult.value(forKey: "total") as? Int ?? 0
                    print("mGetInventoryData response = ",mData)
                    
                    guard mData.count > 0 else {

                            self.mInventoryData = NSMutableArray()
//                            self.mInventoryTableView.reloadData()
                            self.mMyInventoryTableView.reloadData()
                        
                            self.mStoneDataArray = NSMutableArray()

                            self.mMaterialName.text = "--"
                            self.mStoneOne.text = "--"
                            self.mStoneTwo.text = "--"
                            self.mReferenceName.text = "--"
                            self.mMaterialWeight.text = "--"
                            self.mStoneOneWeight.text = "--"
                            self.mStoneTwoWeight.text = "--"
                            self.mCertificateName.text = "--"
                            self.mCertificateNumber.text = "--"

                            self.mShowMoreInventory.isHidden = true

                            return
                        }
                    
                    if let data = mData[0] as? NSDictionary {
                        self.mStoneDataArray = NSMutableArray()
                        self.mStoneDataArray.add(data)
//                        self.mMaterialName.text = "\(data.value(forKey: "metal_name") ?? "--")"
//                        self.mStoneOne.text = "\(data.value(forKey: "Stone_name") ?? "--")"
//                        self.mReferenceName.text = "\(data.value(forKey: "referenceNo") ?? "--")"
//                        self.mMaterialWeight.text = "\(data.value(forKey: "NetWt") ?? "--")"
//                        self.mStoneOneWeight.text = "\(data.value(forKey: "Cts") ?? "--")"
//                        self.mCertificateName.text = "\(data.value(forKey: "certificate_type") ?? "--")"
//                        self.mCertificateNumber.text = "\(data.value(forKey: "certificate_number") ?? "--")"
//                        self.mCertificateLink = "\(data.value(forKey: "certificate_link") ?? "--")"
                        
//                        self.mMaterialName.text = "\(data.value(forKey: "metal_name") ?? "--")"
                        let metalCode =
                            "\(data["metal_name"] ?? data["Metal_name"] ?? "")"

                        self.mMaterialName.text = self.getFullMetalName(metalCode)
                        self.mMaterialName.textAlignment = .left
                        self.mMaterialName.numberOfLines = 0
                        
                        
                        // ---------- Stone ----------
                        if let stoneArray = data.value(forKey: "stoneData") as? NSArray {
                            print("==========stoneArray=========")
                            for case let stone as NSDictionary in stoneArray {
                                print(
                                    stone["stone_name"] ?? "",
                                    "Cts =", stone["Cts"] ?? "",
                                    "totalStoneWt =", stone["totalStoneWt"] ?? ""
                                )
                            }
                            print("==============================")
                            var stoneSummary: [String: (pcs: Int, cts: Double)] = [:]
                            var stoneOrder: [String] = []

                            for item in stoneArray {

                                guard let stone = item as? NSDictionary else {
                                    continue
                                }

                                let name = "\(stone.value(forKey: "stone_name") ?? "")"
                                    .trimmingCharacters(in: .whitespacesAndNewlines)

                                let cleanName = name
                                    .replacingOccurrences(of: "-", with: "")
                                    .replacingOccurrences(of: " ", with: "")

                                guard !cleanName.isEmpty,
                                      name.lowercased() != "<null>",
                                      name.lowercased() != "null" else {
                                    continue
                                }

                                let pcs = Int("\(stone.value(forKey: "Pcs") ?? "0")") ?? 0
                                let cts = Double("\(stone.value(forKey: "Cts") ?? "0")") ?? 0.0

                                if let old = stoneSummary[name] {

                                    stoneSummary[name] = (
                                        pcs: old.pcs + pcs,
                                        cts: old.cts + cts
                                    )

                                } else {

                                    stoneSummary[name] = (
                                        pcs: pcs,
                                        cts: cts
                                    )

                                    stoneOrder.append(name)
                                }
                            }


                            // Reset ก่อนทุกครั้ง ป้องกันค่าจาก product ก่อนหน้าค้าง
                            self.mStoneOne.text = ""
                            self.mStoneOneWeight.text = ""
                            self.mStoneTwo.text = ""
                            self.mStoneTwoWeight.text = ""


                            // Stone กลุ่มที่ 1
                            if stoneOrder.count > 0 {

                                let name = stoneOrder[0]

                                if let value = stoneSummary[name] {

                                    self.mStoneOne.text = name

                                    let formatter = NumberFormatter()
                                    formatter.minimumFractionDigits = 0
                                    formatter.maximumFractionDigits = 3

                                    let ctsText = formatter.string(from: NSNumber(value: value.cts)) ?? "0"

                                    self.mStoneOneWeight.text =
                                        "\(value.pcs)      \(ctsText) c "
//                                    self.mStoneOneWeight.text =
//                                        "\(value.pcs)             \(ctsText) c "
//                                    self.mStoneOneWeight.text =
//                                        "\(value.pcs)                   \(String(format: "%.3f", value.cts)) c"
                                }
                            }


                            // Stone กลุ่มที่ 2
                            if stoneOrder.count > 1 {

                                let name = stoneOrder[1]

                                if let value = stoneSummary[name] {

                                    self.mStoneTwo.text = name

                                    let formatter = NumberFormatter()
                                    formatter.minimumFractionDigits = 0
                                    formatter.maximumFractionDigits = 3

                                    let ctsText = formatter.string(from: NSNumber(value: value.cts)) ?? "0"

                                    self.mStoneTwoWeight.text =
                                        "\(value.pcs)             \(ctsText) c "
//                                    self.mStoneTwoWeight.text =
//                                        "\(value.pcs)                   \(String(format: "%.3f", value.cts)) c"
                                }
                            }

                        } else {

                            self.mStoneOne.text = ""
                            self.mStoneOneWeight.text = ""
                            self.mStoneTwo.text = ""
                            self.mStoneTwoWeight.text = ""
                        }

                        // ---------- Other ----------
                        self.mReferenceName.text = "\(data.value(forKey: "referenceNo") ?? "--")"
                        self.mMaterialWeight.text = "\(data.value(forKey: "NetWt") ?? "--")"
                        let weight = "\(data.value(forKey: "NetWt") ?? "--")"
                        if weight != "--" {

                            self.mMaterialWeight.text = "\(weight) g "

                        } else {

                            self.mMaterialWeight.text = "--"

                        }
                        self.mCertificateName.text = "\(data.value(forKey: "certificate_type") ?? "--")"
                        self.mCertificateNumber.text = "\(data.value(forKey: "certificate_number") ?? "--")"
                        
                        self.mStoneOne.numberOfLines = 1
                        self.mStoneOneWeight.numberOfLines = 1
                        self.mStoneTwo.numberOfLines = 1
                        self.mStoneTwoWeight.numberOfLines = 1
//                        self.mStoneOne.lineBreakMode = .byWordWrapping
//                        self.mStoneOneWeight.lineBreakMode = .byWordWrapping
                        self.mStoneOne.textAlignment = .left
                        self.mStoneOneWeight.textAlignment = .right
                        self.mStoneTwo.textAlignment = .left
                        self.mStoneTwoWeight.textAlignment = .right
                        
                        if let mainImage = data.value(forKey: "main_image") as? String {
                            self.mInventoryImage.downlaodImageFromUrl(urlString: mainImage)
                        }
                        self.mSKUForImage = "\(data.value(forKey: "SKU") ?? "--")"
                        if let mPId = data.value(forKey: "parentproduct_id") as? String {
                            self.mProductIdForImage = mPId
                        }
                        
                        self.mStockID.text = "\(data.value(forKey: "stock_id") ?? "")"
                        self.mStockName.text = "\(data.value(forKey: "SKU") ?? "")"
                        self.mMetaTag.text = "\(data.value(forKey: "Matatag") ?? "")"
                        self.mLocationName.text = "\(data.value(forKey: "location_name") ?? "")"
                        self.mMetalName.text = "\(data.value(forKey: "metal_name") ?? "")"
                        self.mStoneName.text = "\(data.value(forKey: "Stone_name") ?? "")"
                        self.mSize.text = "\(data.value(forKey: "size_name") ?? "")"
                        self.mCollectionName.text = "\(data.value(forKey: "collection_name") ?? "")"
                        
                        let statusProperties: [String: (textColor: UIColor, backgroundColor: UIColor, statusText: String)] = [
                            "stock": (#colorLiteral(red: 0.4588235294, green: 0.8, blue: 1, alpha: 1), #colorLiteral(red: 0.4588235294, green: 0.8, blue: 1, alpha: 1), "Stock"),
                            "reserve": (#colorLiteral(red: 1, green: 0.7386777401, blue: 0.3924969435, alpha: 1), #colorLiteral(red: 1, green: 0.7386777401, blue: 0.3924969435, alpha: 1), "Reserved"),
                            "custom_order": (#colorLiteral(red: 0.9137254902, green: 0.4392156863, blue: 0.4392156863, alpha: 1), #colorLiteral(red: 0.9137254902, green: 0.4392156863, blue: 0.4392156863, alpha: 1), "Reserved"),
                            "repair_order": (#colorLiteral(red: 0.662745098, green: 0.6078431373, blue: 0.7411764706, alpha: 1), #colorLiteral(red: 0.662745098, green: 0.6078431373, blue: 0.7411764706, alpha: 1), "Repair"),
                            "warehouse": (#colorLiteral(red: 0.4392156863, green: 0.4392156863, blue: 0.4392156863, alpha: 1), #colorLiteral(red: 0.4392156863, green: 0.4392156863, blue: 0.4392156863, alpha: 1), "Warehouse"),
                            "transit": (#colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1), #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1), "Transit")
                        ]
                        
                        if let statusType = data.value(forKey: "status_type") as? String,
                           let status = statusProperties[statusType] {
                            self.mProductStatus.textColor = status.textColor
                            self.mStatusDot.backgroundColor = status.backgroundColor
                            self.mProductStatus.text = status.statusText
                        } else {
                            self.mProductStatus.textColor = #colorLiteral(red: 0.4588235294, green: 0.8, blue: 1, alpha: 1)
                            self.mStatusDot.backgroundColor = #colorLiteral(red: 0.4588235294, green: 0.8, blue: 1, alpha: 1)
                            self.mProductStatus.text = "Stock"
                        }
                    }
                    if !key.trim().isEmpty {
                        self.mInventoryData.removeAllObjects()
                    }
                    if let skip = params["skip"] as? Int {
                        if skip == 0 {
                            self.mInventoryData.removeAllObjects()
                        }
                    }
                    let mDataAsAny = mData.compactMap { $0 as Any }
                    self.mInventoryData.addObjects(from: mDataAsAny)
                    self.mIndexInv = -1
                            
                         
                    self.mMyInventoryTableView.delegate = self
                    self.mMyInventoryTableView.dataSource = self
                    self.mMyInventoryTableView.reloadData()
                        
                    if key.trim().isEmpty {
                        self.mInventorySkip += mData.count
                    }else{
                        self.mInventorySkip = 0
                    }
                    
                }else{
                    self.mProductStatus.text = "--"
                    self.mStockID.text = "--"
                    self.mStockName.text = "--"
                    self.mMetaTag.text = "--"
                    self.mLocationName.text = "--"
                    self.mMetalName.text = "--"
                    self.mStoneName.text = "--"
                    self.mSize.text = "--"
                    self.mCollectionName.text = "--"
                    
                    self.mInventoryData.removeAllObjects()
                    self.mInventorySkip = 0
                    self.mMyInventoryTableView.delegate = self
                    self.mMyInventoryTableView.dataSource = self
                    self.mMyInventoryTableView.reloadData()
                }
            }else{
                self.mProductStatus.text = "--"
                self.mStockID.text = "--"
                self.mStockName.text = "--"
                self.mMetaTag.text = "--"
                self.mLocationName.text = "--"
                self.mMetalName.text = "--"
                self.mStoneName.text = "--"
                self.mSize.text = "--"
                self.mCollectionName.text = "--"
                
                if let error = jsonResult.value(forKey: "error") as? String {
                    if error == "Authorization has been expired" {
                        CommonClass.sessionExpired(isExpired: true, navigation: self.navigationController)
                    }
                    
                }
            }
        
        }

    }
    
    func mSubmitReserveItems(){
        
        // Reserve Order route: keep the existing payload and add only the
        // cross-location keys when the selected stock is from another location.
        let urlPath = mCreateReserveOrder//mCreateReserve.replacingOccurrences(of: "/createReserve", with: "/createReserveOrder")
        
        var params:[String:Any] = [
            "Po_products_id": self.mReservProductsData,
            "customer_id": mCustomerId,
            "sales_person_id": mSalesPersonId,
            "byMobile": true,
            "byMyInventoryMobile": true,
            "remark": mRemark.text ?? ""
        ]
        
        let currentLocationId = UserDefaults.standard.string(forKey: "location") ?? ""
        var crossLocationId = ""
        
        for item in mReserveData {
            if let data = item as? NSDictionary {
                let itemLocationId = "\(data.value(forKey: "location_id") ?? "")"
                if !itemLocationId.isEmpty &&
                    !currentLocationId.isEmpty &&
                    itemLocationId != currentLocationId {
                    crossLocationId = itemLocationId
                    break
                }
            }
        }
        
        if !crossLocationId.isEmpty {
            params["crosslocation"] = true
            params["crossLocationId"] = crossLocationId
        }
        
        print("mSubmitReserveItems URL = \(urlPath)")
        print("mSubmitReserveItems params = \(params)")
        if Reachability.isConnectedToNetwork() == true {
            AF.request(urlPath,  method:.post, parameters:params,encoding: JSONEncoding.default, headers: sGisHeaders).responseJSON
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
                        
                        self.mReserveView.isHidden = true
                        self.mCustomerId = ""
                        self.mSalesPersonId = ""
                        self.mSalesPersonName.text = "Select"
                        self.mReserveData = NSMutableArray()
                        self.mReservProductsData = NSMutableArray()
                        self.mRemark.text = ""
           
                        self.mSelectedInventoryIndex = [IndexPath]()
                        self.mSelectedInventoryData = [String]()
                        self.mMyInventoryTableView.reloadData()
                        self.mGetInventoryData(key : "")
                        self.mReserveLabel.textColor =  #colorLiteral(red: 0.6745098039, green: 0.6588235294, blue: 0.6588235294, alpha: 1)
                        self.mReserveIcon.image = UIImage(named: "calendaricon")
                        self.mPrintIcon.image = UIImage(named: "printicon")
                        self.mShareIcon.image = UIImage(named: "shareicon")
                        
                    }else{
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
    
    func mGetSalesPerson(){
        
        let mLocation = UserDefaults.standard.string(forKey: "location") ?? ""
        
        let urlPath =  mGetSalesPersonList
        let params = ["location": mLocation]
        print("mGetSalesPerson params:  \(params)")
        if Reachability.isConnectedToNetwork() == true {
            AF.request(urlPath, method:.post, parameters: params, headers: sGisHeaders2).responseJSON
            { response in
                print("mGetSalesPerson response:  \(response)")
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
                        
                        if let data = jsonResult.value(forKey: "Salesperson") as? NSArray {
                            
                            for i in data {
                                if let salesData = i as? NSDictionary {
                                    if let id = salesData.value(forKey:"id") as? String {
                                        self.mSalesManList.append("\(salesData.value(forKey:"name") ?? "") " + "\(salesData.value(forKey:"lname") ?? "")" )
                                        
                                        self.mSalesManIDList.append(id)
                                        self.mSalesPersonName.text = self.mSalesManList[0]
                                        self.mSalesPersonId =  self.mSalesManIDList[0]
                                    }
                                }
                            }
                        }
                    }else{
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
    
   
    func mSummerySkuDetails(id: String){
        
        let params:[String: Any] = ["id":id]
        
        guard Reachability.isConnectedToNetwork() == true else {
            CommonClass.showSnackBar(message: "Please connect to internet.")
            return
        }
        let urlPath = sSummerySkuDetails
        print("mSummerySkuDetails URL:  \(urlPath)")
        print("mSummerySkuDetails URL:  \(params)")
        AF.request(urlPath, method: .post, parameters: params, encoding: JSONEncoding.default, headers: sGisHeaders)
            .responseJSON { response in
                print("mSummerySkuDetails response:  \(response)")
                guard let jsonData = response.data else {
                    CommonClass.showSnackBar(message: "OOP's something went wrong!")
                    return
                }

                do {
                    guard let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? NSDictionary else {
                        CommonClass.showSnackBar(message: "OOP's something went wrong!")
                        return
                    }
                    guard let code = json["code"] as? Int else {
                        CommonClass.showSnackBar(message: "OOP's something went wrong!")
                        return
                    }

                    switch code {
                    case 200:
                        if let data = json["data"] as? NSDictionary {
                            if let image = data.value(forKey: "main_image") as? String {
                                self.mSummaryImage.downlaodImageFromUrl(urlString: image)
                            }
                            self.mSKUForImage = "\(data.value(forKey: "SKU") ?? "--")"
                            
                            if let mPId = data.value(forKey: "parentproduct_id") as? String {
                                self.mProductIdForImage = mPId
                            }
                            
                            self.mSummarySKUName.text = "\(data.value(forKey: "SKU") ?? "--")"
                            self.mSummaryDescription.text = "\(data.value(forKey: "name") ?? "--")"
                            
                            self.mSummaryLocation.text = "\(data.value(forKey: "location_name") ?? "--")"
                            self.mSummaryItemName.text = "\(data.value(forKey: "item_name") ?? "--")"
                            self.mSummaryCollectionName.text = "\(data.value(forKey: "collection_name") ?? "--")"
                        }
                        break
                    case 403:
                        CommonClass.sessionExpired(isExpired: true, navigation: self.navigationController)
                        break
                    default:
                        let errorMessage = json["message"] as? String ?? "An error occurred."
                        CommonClass.showSnackBar(message: "Error \(code): \(errorMessage)")
                        break
                    }
                } catch {
                    CommonClass.showSnackBar(message: "OOP's something went wrong!")
                }
            }

        
    }
    
    func mGetInventorySummaryData(key : String){
        
        let mPriceData = NSMutableDictionary()
        mPriceData.setValue(mMinPrices, forKey: "min")
        mPriceData.setValue(mMaxPrices, forKey: "max")
        mFilterData.setValue(mPriceData, forKey: "price")
        
        mFilterData.setValue(mItemsId, forKey: "item")
        mFilterData.setValue(mCollectionId, forKey: "collection")
        mFilterData.setValue(mLocationsId, forKey: "location")
        mFilterData.setValue(mMetalsId, forKey: "metal")
        mFilterData.setValue(mStonesId, forKey: "stone")
        mFilterData.setValue(mSizeId, forKey: "size")
        mFilterData.setValue(mStatusId, forKey: "status")
        
        let mLocation = UserDefaults.standard.string(forKey: "location") ?? ""
        
        let urlPath =  mGetInventorySummary
    
        let params = ["location":mLocation,"filter": mFilterData ,"search":key ] as [String : Any]
      
        print("mGetInventorySummaryData urlPath: \(urlPath)")
        print("mGetInventorySummaryData params: \(params)")
        if Reachability.isConnectedToNetwork() == true {
            CommonClass.showFullLoader(view: self.view)
            AF.request(urlPath, method:.post,parameters: params, encoding: JSONEncoding.default,  headers: sGisHeaders).responseJSON
            { response in
                CommonClass.stopLoader()
                print("mGetInventorySummaryData response: \(response)")
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
                    
                    if let mCode = jsonResult.value(forKey: "code") as? Int {
                        if mCode == 403 {
                            CommonClass.sessionExpired(isExpired: true, navigation: self.navigationController)
                            return
                        }
                    }
                    
                    if jsonResult.value(forKey: "code") as? Int == 200 {
                        
                        if let mValue = jsonResult.value(forKey: "count") as? NSDictionary {
                            self.mTotalStockSummary.text = "\(mValue.value(forKey: "Stock") ?? "--")"
                            self.mTotalReservedSummary.text = "\(mValue.value(forKey: "reserve") ?? "--")"
                            self.mTotalAvailableSummary.text = "\(mValue.value(forKey: "available") ?? "--")"
                        }
                        
                        if let mData = jsonResult.value(forKey: "data") as? NSArray, mData.count > 0 {
                           
                            if let data = mData[0] as? NSDictionary {
                                self.mSummerySkuDetails(id: "\(data.value(forKey: "po_product_id") ?? "")")
                                
                                self.mIndexSum = -1
                                
                                self.mSummaryData =  mData
                                self.mSummaryTableView.delegate = self
                                self.mSummaryTableView.dataSource = self
                                self.mSummaryTableView.reloadData()
                            }
                        }else{
                            self.mTotalStockSummary.text = "--"
                            self.mTotalReservedSummary.text = "--"
                            self.mTotalAvailableSummary.text = "--"
                        }
                    }else{
                        self.mTotalStockSummary.text = "--"
                        self.mTotalReservedSummary.text = "--"
                        self.mTotalAvailableSummary.text = "--"
                        
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
    
    
    @IBAction func mRefresh(_ sender: Any) {
        
        mGetInventorySummaryData(key : "")
        mGetInventoryData(key:"")
        mRefreshIcon.tintColor = #colorLiteral(red: 0.2392156863, green: 0.7019607843, blue: 0.6196078431, alpha: 1)
        mRefreshLabel.textColor =  #colorLiteral(red: 0.2392156863, green: 0.7019607843, blue: 0.6196078431, alpha: 1)
        self.mTimer = .scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.mTimerForButton), userInfo: nil, repeats: false)
    }
    
    @objc
    func mTimerForButton(){
        
        mRefreshIcon.tintColor = #colorLiteral(red: 0.6745098039, green: 0.6588235294, blue: 0.6588235294, alpha: 1)
        mRefreshLabel.textColor =  #colorLiteral(red: 0.6745098039, green: 0.6588235294, blue: 0.6588235294, alpha: 1)
        self.mTimer.invalidate()
    }
    
    
    @IBAction func mChooseSalesPerson(_ sender: Any) {
        
        let dropdown = DropDown()
        dropdown.anchorView = self.mSalesPersonName
        dropdown.direction = .bottom
        dropdown.bottomOffset = CGPoint(x: 0, y: self.mSalesPersonName.frame.size.height)
        dropdown.width = 200
        dropdown.dataSource = mSalesManList
        dropdown.selectionAction = {
            [unowned self](index:Int, item: String) in
            self.mSalesPersonName.text  = item
            
            self.mSalesPersonId =  self.mSalesManIDList[index]
            
        }
        dropdown.show()
    }
    
    @IBAction func mEditCustomer(_ sender: Any) {
        mCustomerSearch.text = ""
    }
    
    @IBAction func mEditChanged(_ sender: Any) {
        
        
        if let value = mCustomerSearch.text?.count, value != 0 {
            self.mSearchCustomerByKeys(value: mCustomerSearch.text ?? "")
        }else {
            if mCustomerSearch.text  == "" {
                mCustomerSearchTableView.removeFromSuperview()
            }
            self.view.endEditing(true)
            
        }
        
    }
    
    @IBAction func mGetCustomerProfile(_ sender: Any) {
        self.mCustomerSearch.text = ""
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let mProfInfo = storyBoard.instantiateViewController(withIdentifier: "POSProfileInfo") as? POSProfileInfo {
            self.navigationController?.pushViewController(mProfInfo, animated:true)
        }
    }
    
    
    @IBAction func mAddNewCustomer(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let mRegister = storyBoard.instantiateViewController(withIdentifier: "RegisterCustomer") as? RegisterCustomer {
            self.navigationController?.pushViewController(mRegister, animated:true)
        }
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let value = textField.text ?? ""
        mSearchCustomerByKeys(value: value)
    }
    
    func mSearchCustomerByKeys(value: String){
        
        let urlPath =  mSearchCustomerByKey
        let params = ["key": value]
        
        if Reachability.isConnectedToNetwork() == true {
            AF.request(urlPath, method:.post, parameters:params, headers: sGisHeaders2).responseJSON
            { response in
                
                if response.error != nil {
                    CommonClass.showSnackBar(message: "OOP's something went wrong!")
                } else {
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
                        self.mSearchCustomerData = NSArray()
                        if let mData = jsonResult.value(forKey: "list") as? NSArray {
                            self.mSearchCustomerData =  mData
                        }
                    }else{
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

    func mSetupTableView(frame: CGRect) {
        if mCustomerSearch.text  != "" {
            let nib = UINib(nibName: "CustomerSearchList", bundle: nil)
            
            mCustomerSearchTableView.frame = CGRect(x: 16, y:frame.origin.y + 200 ,width:self.view.frame.width - 32, height:400)
            mCustomerSearchTableView.cornerRadius = 10
            mCustomerSearchTableView.register(nib, forCellReuseIdentifier: "CustomerSearchItem")
            mCustomerSearchTableView.isHidden = false
            mCustomerSearchTableView.keyboardDismissMode = .onDrag
            self.mCustomerSearchTableView.delegate = self
            self.mCustomerSearchTableView.dataSource = self
            mCustomerSearchTableView.reloadData()
            
            self.view.addSubview(mCustomerSearchTableView)
            mCustomerSearchTableView.tag = 100
            
            mCustomerSearchTableView.translatesAutoresizingMaskIntoConstraints = false
        }else{
            mCustomerSearchTableView.removeFromSuperview()
        }
        
        var _: [NSLayoutConstraint] = []
        
    }
    
    
    func mGetFilterData(){
        
        let urlPath =  mGetInventoryFilter
        
        if Reachability.isConnectedToNetwork() == true {
            AF.request(urlPath, method:.post, headers: sGisHeaders2).responseJSON
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
                       
                        if let mData = jsonResult.value(forKey: "data") as? NSDictionary {
                            
                            self.mPriceRange.selectedMinValue = CGFloat(Float("\(mData.value(forKey: "minPrice") ?? "0")") ?? 0)
                            self.mPriceRange.selectedMaxValue = CGFloat(Float("\(mData.value(forKey: "maxPrice") ?? "0")") ?? 0)
                            
                            if  let mItems = mData.value(forKey: "Item") as? NSArray, mItems.count > 0 {
                                self.mItemsData = mItems
                                self.mItemCollectionView.reloadData()
                            }
                            
                            if let mCollection = mData.value(forKey: "Collection") as? NSArray, mCollection.count > 0 {
                                self.mCollectionData = mCollection
                                self.mCollectCollectionView.reloadData()
                            }
                            
                            if let mMetal = mData.value(forKey: "Metal") as? NSArray, mMetal.count > 0 {
                                self.mMetalsData = mMetal
                                self.mMetalCollectionView.reloadData()
                            }
                            
                            if let mStone = mData.value(forKey: "Stone") as? NSArray, mStone.count > 0 {
                                self.mStonesData = mStone
                                self.mStoneCollectionView.reloadData()
                            }
                            
                            if let mSize = mData.value(forKey: "Size") as? NSArray, mSize.count > 0 {
                                self.mSizeData = mSize
                                self.mSizeCollectionView.reloadData()
                            }
                            
                            if let mLocation = mData.value(forKey: "location_data") as? NSArray, mLocation.count > 0 {
                                self.mLocationsData = mLocation
                                self.mLocationCollectionView.reloadData()
                            }
                        }
                    }else{
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

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let scrollViewHeight = scrollView.bounds.size.height
        
        // Check if you are near the bottom of the UICollectionView
        if contentOffsetY + scrollViewHeight >= contentHeight {
            // You have reached the bottom of the UICollectionView
            // Add your code here to perform any actions when scrolled to the bottom.
            
            if self.mInventorySkip < self.mInventoryTotal && self.mTYPE != "S"{
                mShowMoreInventory.isHidden = false
            }
        }else{
            mShowMoreInventory.isHidden = true
        }
    }
    
}


extension UIView {
    func cornerRadius(usingCorners corners: UIRectCorner,cornerRadii: CGSize)
    {
        let path = UIBezierPath(roundedRect: self.bounds,byRoundingCorners: corners,cornerRadii: cornerRadii)
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        self.layer.mask = maskLayer
        
    }
    
}
extension UIView{
    func roundCornersShape(topLeft: CGFloat = 0, topRight: CGFloat = 0, bottomLeft: CGFloat = 0, bottomRight: CGFloat = 0) {
        let topLeftRadius = CGSize(width: topLeft, height: topLeft)
        let topRightRadius = CGSize(width: topRight, height: topRight)
        let bottomLeftRadius = CGSize(width: bottomLeft, height: bottomLeft)
        let bottomRightRadius = CGSize(width: bottomRight, height: bottomRight)
        let maskPath = UIBezierPath(shouldRoundRect: bounds, topLeftRadius: topLeftRadius, topRightRadius: topRightRadius, bottomLeftRadius: bottomLeftRadius, bottomRightRadius: bottomRightRadius)
        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        layer.mask = shape
    }
}
extension UIBezierPath {
    convenience init(shouldRoundRect rect: CGRect, topLeftRadius: CGSize = .zero, topRightRadius: CGSize = .zero, bottomLeftRadius: CGSize = .zero, bottomRightRadius: CGSize = .zero){

        self.init()

        let path = CGMutablePath()

        let topLeft = rect.origin
        let topRight = CGPoint(x: rect.maxX, y: rect.minY)
        let bottomRight = CGPoint(x: rect.maxX, y: rect.maxY)
        let bottomLeft = CGPoint(x: rect.minX, y: rect.maxY)

        if topLeftRadius != .zero{
            path.move(to: CGPoint(x: topLeft.x+topLeftRadius.width, y: topLeft.y))
        } else {
            path.move(to: CGPoint(x: topLeft.x, y: topLeft.y))
        }

        if topRightRadius != .zero{
            path.addLine(to: CGPoint(x: topRight.x+topRightRadius.width, y: topRight.y))
            path.addCurve(to:  CGPoint(x: topRight.x, y: topRight.y+topRightRadius.height), control1: CGPoint(x: topRight.x, y: topRight.y), control2:CGPoint(x: topRight.x, y: topRight.y+topRightRadius.height))
        } else {
             path.addLine(to: CGPoint(x: topRight.x, y: topRight.y))
        }

        if bottomRightRadius != .zero{
            path.addLine(to: CGPoint(x: bottomRight.x, y: bottomRight.y-bottomRightRadius.height))
            path.addCurve(to: CGPoint(x: bottomRight.x-bottomRightRadius.width, y: bottomRight.y), control1: CGPoint(x: bottomRight.x, y: bottomRight.y), control2: CGPoint(x: bottomRight.x-bottomRightRadius.width, y: bottomRight.y))
        } else {
            path.addLine(to: CGPoint(x: bottomRight.x, y: bottomRight.y))
        }

        if bottomLeftRadius != .zero{
            path.addLine(to: CGPoint(x: bottomLeft.x+bottomLeftRadius.width, y: bottomLeft.y))
            path.addCurve(to: CGPoint(x: bottomLeft.x, y: bottomLeft.y-bottomLeftRadius.height), control1: CGPoint(x: bottomLeft.x, y: bottomLeft.y), control2: CGPoint(x: bottomLeft.x, y: bottomLeft.y-bottomLeftRadius.height))
        } else {
            path.addLine(to: CGPoint(x: bottomLeft.x, y: bottomLeft.y))
        }

        if topLeftRadius != .zero{
            path.addLine(to: CGPoint(x: topLeft.x, y: topLeft.y+topLeftRadius.height))
            path.addCurve(to: CGPoint(x: topLeft.x+topLeftRadius.width, y: topLeft.y) , control1: CGPoint(x: topLeft.x, y: topLeft.y) , control2: CGPoint(x: topLeft.x+topLeftRadius.width, y: topLeft.y))
        } else {
            path.addLine(to: CGPoint(x: topLeft.x, y: topLeft.y))
        }

        path.closeSubpath()
        cgPath = path
    }
}
