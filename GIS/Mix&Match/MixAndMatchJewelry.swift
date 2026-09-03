//
//  MixAndMatchJewelry.swift
//  GIS
//
//  Created by MacBook Hawkscode  on 13/02/23.
//  Copyright © 2023 Hawkscode. All rights reserved.
//

import UIKit
import Alamofire
import DropDown
import UIDrawer

protocol GetMInventoryDataItemsDelegate {
    func mGetInventoryItems(data:NSDictionary)
}

class MixAndMatchJewelry:UIViewController , UITableViewDelegate , UITableViewDataSource  , RangeSeekSliderDelegate, UIGestureRecognizerDelegate,UIViewControllerTransitioningDelegate, GetInventoryFiltersDelegate {
    
    var mItemTypeId = ""
    //Inventory Item Details
    var delegate:GetMInventoryDataItemsDelegate? = nil
    
    @IBOutlet weak var mReserveButtonView: UIView!
    @IBOutlet weak var mReserveButton: UIButton!
    @IBOutlet weak var mHeight: NSLayoutConstraint!
    
    @IBOutlet weak var mStockID: UILabel!
    
    @IBOutlet weak var mInventoryImage: UIImageView!
    
    @IBOutlet weak var mProductStatus: UILabel!
    
    @IBOutlet weak var mFilterSearchView: UIView!
    
    @IBOutlet weak var mMyInventoryTableView: UITableView!
    
    @IBOutlet weak var mInventoryDetailsView: UIView!
    @IBOutlet weak var mInventoryDetailsHeight: NSLayoutConstraint!
    
    @IBOutlet weak var mStatusDot: UILabel!
    @IBOutlet weak var mStockName: UILabel!
    @IBOutlet weak var mMetaTag: UILabel!
    @IBOutlet weak var mMetalName: UILabel!
    @IBOutlet weak var mStoneName: UILabel!
    @IBOutlet weak var mSize: UILabel!
    @IBOutlet weak var mCollectionName: UILabel!
    @IBOutlet weak var mLocationName: UILabel!
    
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
    
    var mInventoryData = NSArray()
    var mSummaryData = NSArray()
    
    var mIndexInv = -1
    var mIndexSum = -1
    
    var mSelectedItem = -1
    
    var mReserveData = NSMutableArray()
    var mStoneDataArray = NSMutableArray()
    var mProductId = [String]()
    
    @IBOutlet weak var mTotalReserve: UILabel!
    
    @IBOutlet weak var mSalesPersonName: UILabel!
    var mSalesManList = [String]()
    var mSalesManIDList = [String]()
    var mCustomerId = ""
    var mSalesPersonId = ""
    
    let mCustomerSearchTableView = UITableView()
    
    var mReservProductsData = NSMutableArray()
    var mSearchCustomerData = NSArray()
    
    @IBOutlet weak var mSearchFIELD: UITextField!
    @IBOutlet weak var mInventoryHeadingLABEL: UILabel!
    @IBOutlet weak var mICollectionLABEL: UILabel!
    @IBOutlet weak var mIMetalLABEL: UILabel!
    @IBOutlet weak var mIStoneLABEL: UILabel!
    @IBOutlet weak var mISizeLABEL: UILabel!
    @IBOutlet weak var mISKULABEL: UILabel!
    
    @IBOutlet weak var mIStockIdLABEL: UILabel!
    @IBOutlet weak var mIQtyLABEL: UILabel!
    
    @IBOutlet weak var mIPriceLABEL: UILabel!
    
    @IBOutlet weak var mSStockLABEL: UILabel!
    
    @IBOutlet weak var mSStockHLABEL: UILabel!
    @IBOutlet weak var mSReservedLABEL: UILabel!
    @IBOutlet weak var mSAvailableLABEL: UILabel!
    
    @IBOutlet weak var mSItemLABEL: UILabel!
    @IBOutlet weak var mSCollectionLABEL: UILabel!
    
    @IBOutlet weak var mSLocationLABEL: UILabel!
    @IBOutlet weak var mSSKULABEL: UILabel!
    @IBOutlet weak var mSalesPersonLABEL: UILabel!
    @IBOutlet weak var mReserveHeaderLABEL: UILabel!
    
    @IBOutlet weak var mSubmitReserveBUTTON: UIButton!
    
    @IBOutlet weak var mRSKULABEL: UILabel!
    @IBOutlet weak var mRStockIdLABEL: UILabel!
    @IBOutlet weak var mRPriceLABEL: UILabel!
    @IBOutlet weak var mRTotalLABEL: UILabel!
    
    @IBOutlet weak var mRCancelBUTTON: UIButton!
    @IBOutlet weak var mRQtyLABEL: UILabel!
    
    @IBOutlet weak var mRRematkLABEL: UILabel!
    
    @IBOutlet weak var mRSubmitBUTTON: UIButton!
    
    @IBOutlet weak var mFilterLABEL: UILabel!
    @IBOutlet weak var mClearAllBUTTON: UIButton!
    
    @IBOutlet weak var mFItemLABEL: UILabel!
    @IBOutlet weak var mFSelectAllBUTTON: UIButton!
    
    @IBOutlet weak var mFCollectionLABEL: UILabel!
    
    @IBOutlet weak var mFMetalLABEL: UILabel!
    @IBOutlet weak var mFStoneSelectAllBUTTON: UIButton!
    
    @IBOutlet weak var mFCollectionSelectAllBUTTON: UIButton!
    @IBOutlet weak var mFMetalSelectAllBUTTON: UIButton!
    @IBOutlet weak var mFLocationSelectAllBUTTON: UIButton!
    @IBOutlet weak var mFSizeSelcetAllBUTTON: UIButton!
    @IBOutlet weak var mFStoneLABEL: UILabel!
    
    @IBOutlet weak var mFPriceRangeLABEL: UILabel!
    @IBOutlet weak var mFPriceLABEL: UILabel!
    @IBOutlet weak var mFSizeLABEL: UILabel!
    @IBOutlet weak var mFLocationLABEL: UILabel!
    
    var mTYPE = "I"
    
    @IBOutlet weak var mHeadingLABEL: UILabel!
    
    @IBOutlet weak var mMetalLABEL: UILabel!
    @IBOutlet weak var mSizeLABEL: UILabel!
    @IBOutlet weak var mCollectionLABEL: UILabel!
    @IBOutlet weak var mStoneLABEL: UILabel!
    
    @IBOutlet weak var mProductSummaryLABEL: UILabel!
    @IBOutlet weak var mMaterialLABEL: UILabel!
    @IBOutlet weak var mPStoneLABEL: UILabel!
    @IBOutlet weak var mReferenceNoLABEL: UILabel!
    @IBOutlet weak var mCertificateLABEL: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("MixAndMatchJewelry OPEN")
        
        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
        
        mSearchFIELD.placeholder = "Search by SKU / Stock Id".localizedString
        mHeadingLABEL.text = "Inventory".localizedString
        mCollectionLABEL.text = "Collection".localizedString
        mMetalLABEL.text = "Metal".localizedString
        mStoneLABEL.text = "Stone".localizedString
        mSizeLABEL.text = "Size".localizedString
        mProductSummaryLABEL.text = "Product Summary".localizedString
        mMaterialLABEL.text = "Material".localizedString
        mPStoneLABEL.text = "Stone".localizedString
        mReferenceNoLABEL.text = "Reference No.".localizedString
        mCertificateLABEL.text = "Certificate".localizedString
        
        mMyInventoryTableView.isHidden = false
        
        mInventoryDetailsView.isHidden = false
        mShowHideButton.isSelected = false
        mShowHideSummaryIcon.image = UIImage(named: "bottomic")
        mProductSummaryView.isHidden = true
        mInventoryDetailsHeight.constant = 184.5
        
        mMyInventoryTableView.showsVerticalScrollIndicator = false
        
        mMyInventoryTableView.delegate = self
        mMyInventoryTableView.dataSource = self
        mMyInventoryTableView.reloadData()
        
        mGetInventoryData(key : "")
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTap))
        tap.delegate = self
        mStockName.isUserInteractionEnabled = true
        mStockName.addGestureRecognizer(tap)
        
    }
    
    @objc
    func onTap(){
        let mData = NSArray(array: mStoneDataArray)
        print("onTap mData = \(mData)")
        if let mPoProductId = mData.value(forKey: "product_id") as? String {
            if mPoProductId != "" {
                let storyBoard: UIStoryboard = UIStoryboard(name: "common", bundle: nil)
                if let home = storyBoard.instantiateViewController(withIdentifier: "SKUProductSummary") as? SKUProductSummary{
                    home.mKey = mPoProductId
                    home.modalPresentationStyle = .automatic
                    home.transitioningDelegate = self
                    self.present(home,animated: true)
                }
            }
        }
//        let storyBoard: UIStoryboard = UIStoryboard(name: "common", bundle: nil)
//        if let home = storyBoard.instantiateViewController(withIdentifier: "SKUProductSummary") as? SKUProductSummary {
//            home.mOriginalData = NSArray(array: mStoneDataArray)
//            home.modalPresentationStyle = .automatic
//            home.transitioningDelegate = self
//            self.present(home,animated: true)
//        }
    }
    
    override func viewDidLayoutSubviews() {
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        mReserveButton.setTitle("SELECT".localizedString, for: .normal)
        
        
        addDoneButtonOnKeyboard()
        
    }
    
    @IBAction func mScanNow(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "invdata", bundle: nil)
        if let home = storyBoard.instantiateViewController(withIdentifier: "SearchInventory") as? SearchInventory {
            home.mType = "Inventory"
            home.mFrom = "2"
            self.navigationController?.pushViewController(home, animated:true)
        }
    }
    
    @IBAction func mHome(_ sender: Any) {
        self.dismiss(animated: false)
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
            
        }else {
            self.mGetInventoryData(key: mSearchFIELD.text ?? "")
        }
        mSearchFIELD.resignFirstResponder()
    }
    
    @IBAction func mOpenCertificateLink(_ sender: Any) {
    }
    
    @IBAction func mShowHideProductSummary(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            mProductSummaryView.isHidden = false
            mShowHideSummaryIcon.image = UIImage(named: "top_ic")
            mInventoryDetailsHeight.constant = 344
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
        
        print("SELECTED =", mSelectedItem)
        print("COUNT =", mInventoryData.count)
        
        if let mIData = mInventoryData[mSelectedItem] as? NSDictionary {
            print("DEBUG_SELECTED_INVENTORY =", mIData)
            let mData = NSMutableDictionary()
            mData.setValue("\(mIData.value(forKey: "metal_id") ?? "")", forKey: "metalId")
            mData.setValue("\(mIData.value(forKey: "size_id") ?? "")", forKey: "sizeId")
            mData.setValue("\(mIData.value(forKey: "stone_id") ?? "")", forKey: "stoneId")
            mData.setValue("\(mIData.value(forKey: "pointer") ?? "")", forKey: "pointerId")
            mData.setValue("\(mIData.value(forKey: "price") ?? "")", forKey: "pointerPriceId")
            mData.setValue("\(mIData.value(forKey: "shape_id") ?? "")", forKey: "shahpeId")
            mData.setValue("", forKey: "shapeName")
            mData.setValue("\(mIData.value(forKey: "metal_name") ?? "")", forKey: "metalName")
            mData.setValue("\(mIData.value(forKey: "size_name") ?? "")", forKey: "sizeName")
            mData.setValue("\(mIData.value(forKey: "pointer") ?? "")", forKey: "stoneName")
            mData.setValue("inventory", forKey: "type")
            UserDefaults.standard.set(mData, forKey: "CATALOGDATA")
            
            self.delegate?.mGetInventoryItems(data: mIData)
        }
        dismiss(animated: false)
    }
    
    
    
    @IBAction func mSearch(_ sender: Any) {
        mFilterSearchView.isHidden =  false
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
        
        if mTYPE == "S"{
            
        }else{
            mGetInventoryData(key: "")
        }
    }
    
    @IBAction func mApplyFilter(_ sender: Any) {
          
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        if tableView == mMyInventoryTableView {
            count =  mInventoryData.count
        }
        return count

    }
    
    func updateProductSummary(with data: NSDictionary) {

        self.mStoneOne.textAlignment = .left
        self.mStoneOneWeight.textAlignment = .right
        self.mStoneTwo.textAlignment = .left
        self.mStoneTwoWeight.textAlignment = .right
        
        mMaterialName.text = data["metal_name"] as? String ?? "--"

        mReferenceName.text = data["referenceNo"] as? String ?? "--"

        mMaterialWeight.text = "\(data["NetWt"] ?? "--")"

        mCertificateName.text = data["certificate_type"] as? String ?? "--"

        mCertificateNumber.text = data["certificate_number"] as? String ?? "--"
        
        if let stones = data["stoneData"] as? [[String: Any]] {

            var stoneCTSMap: [String: Double] = [:]
            var stonePCSMap: [String: Int] = [:]
            var order: [String] = []

            for stone in stones {

                let name = stone["stone_name"] as? String ?? "--"
                let cts = Double("\(stone["Cts"] ?? 0)") ?? 0.0
                let pcs = Int("\(stone["Pcs"] ?? 0)") ?? 0
                
                if stoneCTSMap[name] == nil {
                    order.append(name)
                    stoneCTSMap[name] = 0.0
                    stonePCSMap[name] = 0
                }
                
                stoneCTSMap[name]! += cts
                stonePCSMap[name]! += pcs

            }

            let formatter = NumberFormatter()
            formatter.minimumFractionDigits = 0
            formatter.maximumFractionDigits = 3
            formatter.minimumIntegerDigits = 1
            
            if order.indices.contains(0) {
                let name = order[0]
                mStoneOne.text = name
                let pcs = stonePCSMap[name] ?? 0
                let cts = stoneCTSMap[name] ?? 0.0
                mStoneOneWeight.text = "\(pcs)        \(formatter.string(from: NSNumber(value: cts)) ?? "0") c"
//                mStoneOneWeight.text = formatter.string(from: NSNumber(value: stoneMap[name] ?? 0))
            } else {
                mStoneOne.text = "--"
                mStoneOneWeight.text = "--"
            }

            if order.indices.contains(1) {
                let name = order[1]
                mStoneTwo.text = name
                let pcs = stonePCSMap[name] ?? 0
                let cts = stoneCTSMap[name] ?? 0.0
                mStoneTwoWeight.text = "\(pcs)        \(formatter.string(from: NSNumber(value: cts)) ?? "0") c"
//                mStoneTwoWeight.text = formatter.string(from: NSNumber(value: stoneMap[name] ?? 0))
            } else {
                mStoneTwo.text = "--"
                mStoneTwoWeight.text = "--"
            }

        } else {

            mStoneOne.text = "--"
            mStoneOneWeight.text = "--"
            mStoneTwo.text = "--"
            mStoneTwoWeight.text = "--"
        }
    }
    
    func formatPrice(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2

        let symbol = UserDefaults.standard.string(forKey: "currencySymbol") ?? ""

        return "\(symbol) \(formatter.string(from: NSNumber(value: value)) ?? "0.00")"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        
        var cell  = UITableViewCell()
        if tableView == mMyInventoryTableView {
            guard let  cells = tableView.dequeueReusableCell(withIdentifier: "InventoryCell") as? InventoryCell else {
                return cell
            }
            
            cells.mView.backgroundColor = (indexPath.row % 2 == 0) ? UIColor(named: "themeBackground") : #colorLiteral(red: 0.9568627451, green: 0.9568627451, blue: 0.9568627451, alpha: 1)
            
            guard let mData = mInventoryData[indexPath.row] as? NSDictionary else {
                return cell
            }
            if let isDesign = mData.value(forKey: "isDesign") as? Bool {
                cells.mDesignView.isHidden = !isDesign
            }else{
                cells.mDesignView.isHidden = true
            }
            
            cells.mStockName.text = "\(mData.value(forKey: "SKU") ?? "--")"
            if let stockId = mData.value(forKey: "stock_id") {
                cells.mStockId.text = "\(stockId)"
            }
            cells.mQuantity.text = "\(mData.value(forKey: "po_QTY") ?? "--") Pcs"
            let price = Double("\(mData.value(forKey: "price") ?? "0")") ?? 0
            cells.mAmount.text = formatPrice(price)
//            cells.mAmount.text =  "\(mData.value(forKey: "price") ?? "--")"
            
            if mSelectedItem == -1 {
                
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
            if UIDevice.current.userInterfaceIdiom == .pad {
                let price = Double("\(mData.value(forKey: "price") ?? "0")") ?? 0
                cells.mAmount.text = formatPrice(price)
//                cells.mAmount.text =  "\(mData.value(forKey: "price") ?? "--")"
            }else{
                let price = Double("\(mData.value(forKey: "price") ?? "0")") ?? 0
                cells.mAmount.text = formatPrice(price)
//                cells.mAmount.text =  "\(mData.value(forKey: "price") ?? "--")"
            }
            
            cells.mStatusColor.textColor = .clear
            
            if let status = mData.value(forKey: "status_type") as? String {
                if status == "stock" {
                    cells.mStatusColor.backgroundColor = #colorLiteral(red: 0.4588235294, green: 0.8, blue: 1, alpha: 1)
                }else if status == "reserve" {
                    cells.mStatusColor.backgroundColor = #colorLiteral(red: 1, green: 0.7386777401, blue: 0.3924969435, alpha: 1)
                }else if status == "custom_order" {
                    cells.mStatusColor.backgroundColor = #colorLiteral(red: 0.9137254902, green: 0.4392156863, blue: 0.4392156863, alpha: 1)
                }else if status == "repair_order" {
                    cells.mStatusColor.backgroundColor = #colorLiteral(red: 0.662745098, green: 0.6078431373, blue: 0.7411764706, alpha: 1)
                }else if status == "warehouse" {
                    cells.mStatusColor.backgroundColor = #colorLiteral(red: 0.4392156863, green: 0.4392156863, blue: 0.4392156863, alpha: 1)
                }else if status == "transit" {
                    cells.mStatusColor.backgroundColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
                }
            } else {
                cells.mStatusColor.backgroundColor = #colorLiteral(red: 0.4588235294, green: 0.8, blue: 1, alpha: 1)
            }
            
            if mSelectedItem == indexPath.row {
                cells.mCheckIcon.image = UIImage(named: "check_item")
            }else{
                cells.mCheckIcon.image = UIImage(named: "uncheck_item")
            }
            
            self.updateProductSummary(with: mData)
            
            cells.layoutSubviews()
            
            if mIndexInv == indexPath.row {
                if let status = mData.value(forKey: "status_type") as? String {
                    if status == "stock" {
                        self.mProductStatus.textColor = #colorLiteral(red: 0.4588235294, green: 0.8, blue: 1, alpha: 1)
                        self.mStatusDot.backgroundColor = #colorLiteral(red: 0.4588235294, green: 0.8, blue: 1, alpha: 1)
                        self.mProductStatus.text = "Stock"
                    }else if status == "reserve" {
                        self.mProductStatus.textColor = #colorLiteral(red: 1, green: 0.7386777401, blue: 0.3924969435, alpha: 1)
                        self.mStatusDot.backgroundColor = #colorLiteral(red: 1, green: 0.7386777401, blue: 0.3924969435, alpha: 1)
                        self.mProductStatus.text = "Reserved"
                    }else if status == "custom_order" {
                        self.mProductStatus.textColor = #colorLiteral(red: 0.9137254902, green: 0.4392156863, blue: 0.4392156863, alpha: 1)
                        self.mStatusDot.backgroundColor = #colorLiteral(red: 0.9137254902, green: 0.4392156863, blue: 0.4392156863, alpha: 1)
                        self.mProductStatus.text = "Reserved"
                    }else if status == "repair_order"  {
                        self.mProductStatus.textColor = #colorLiteral(red: 0.662745098, green: 0.6078431373, blue: 0.7411764706, alpha: 1)
                        self.mStatusDot.backgroundColor = #colorLiteral(red: 0.662745098, green: 0.6078431373, blue: 0.7411764706, alpha: 1)
                        self.mProductStatus.text = "Repair"
                    }else if status == "warehouse" {
                        self.mProductStatus.textColor = #colorLiteral(red: 0.4392156863, green: 0.4392156863, blue: 0.4392156863, alpha: 1)
                        self.mStatusDot.backgroundColor = #colorLiteral(red: 0.4392156863, green: 0.4392156863, blue: 0.4392156863, alpha: 1)
                        self.mProductStatus.text = "WareHouse"
                    }else if status == "transit" {
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if tableView == mMyInventoryTableView {
            let  cells = tableView.dequeueReusableCell(withIdentifier: "InventoryCell") as? InventoryCell
            
            mIndexInv = indexPath.row
            
            if let mData = mInventoryData[indexPath.row] as? NSDictionary {
                
                print("========== SELECTED ==========")
                print("Stock ID :", mData["stock_id"] ?? "")
                print("SKU      :", mData["SKU"] ?? "")
                print("Metal    :", mData["metal_name"] ?? "")
                print("Ref      :", mData["referenceNo"] ?? "")
                print("Stone    :", mData["stone_name"] ?? "")
                print("CountCTS :", mData["CountCTS"] ?? "")
                
                if let image = mData.value(forKey: "main_image") as? String {
                    self.mInventoryImage.downlaodImageFromUrl(urlString: image)
                }
                self.mStockID.text = "\(mData.value(forKey: "stock_id") ?? "")"
                self.mStockName.text = "\(mData.value(forKey: "SKU") ?? "")"
                self.mMetaTag.text = "\(mData.value(forKey: "Matatag") ?? "")"
                self.mLocationName.text = "\(mData.value(forKey: "location_name") ?? "")"
                
//                self.mMetalName.text = "\(mData.value(forKey: "metal_name") ?? "")"
                
//                self.mStoneName.text = "\(mData.value(forKey: "stone_name") ?? "")"
                if let stones = mData["stoneData"] as? [[String: Any]] {

                    var names: [String] = []

                    for stone in stones {
                        if let name = stone["stone_name"] as? String,
                           !names.contains(name) {
                            names.append(name)
                        }
                    }

                    self.mStoneName.text = names.joined(separator: ", ")
                } else {
                    self.mStoneName.text = "--"
                }
                
                self.mSize.text = "\(mData.value(forKey: "size_name") ?? "")"
                self.mCollectionName.text = "\(mData.value(forKey: "collection_name") ?? "")"
                
                
                self.mMaterialName.text = "\(mData.value(forKey: "metal_name") ?? "--")"
//                self.mStoneOne.text = "\(mData.value(forKey: "stone_name") ?? "--")"
//                if let stoneData = mData["stoneData"] as? [[String: Any]] {
//
//                    let names = Array(Set(
//                        stoneData.compactMap { $0["stone_name"] as? String }
//                    ))
//
//                    self.mStoneOne.text = names.joined(separator: ", ")
//                } else {
//                    self.mStoneOne.text = "--"
//                }
//                self.mReferenceName.text = "\(mData.value(forKey: "referenceNo") ?? "--")"
//                self.mMaterialWeight.text = "\(mData.value(forKey: "NetWt") ?? "--")"
//                self.mStoneOneWeight.text = "\(mData.value(forKey: "Cts") ?? "--")"
//                self.mStoneOneWeight.text = "\(mData.value(forKey: "CountCTS") ?? "--")"
//                self.mCertificateName.text = "\(mData.value(forKey: "certificate_type") ?? "--")"
//                self.mCertificateNumber.text = "\(mData.value(forKey: "certificate_number") ?? "--")"
                
                print("=== DID SELECT ===")
                print(mData)
                updateProductSummary(with: mData)
                print("Material Label =", mMaterialName.text ?? "")
                print("Reference Label =", mReferenceName.text ?? "")
                print("Stone Label =", mStoneOne.text ?? "")
                
                if let status = mData.value(forKey: "status_type") as? String {
                    if status == "stock" {
                        
                        mSelectedItem = indexPath.row
                        
                        let mInvData = mInventoryData[indexPath.row] as? NSDictionary
                        
                        if mProductId.contains(mInvData?.value(forKey: "product_id") as? String ?? "") {
                            
                        }else{
                            
                        }
                        
                        if self.mSelectedInventoryIndex.contains(indexPath) {
                            
                        }else{
                            
                        }
                    }
                    
                }
                self.mStoneDataArray = NSMutableArray()
                self.mStoneDataArray.add(mData)
                self.mMyInventoryTableView.reloadData()
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
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "reserveBoard", bundle: nil)
        if let mInventoryPage = storyBoard.instantiateViewController(withIdentifier: "InventoryReservedItems") as? InventoryReservedItems {
            mInventoryPage.mType = "Inventory"
            self.navigationController?.pushViewController(mInventoryPage, animated:true)
        }
    }
    
    @IBAction func mPreview(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Test", bundle: nil)
        if let mPrint = storyBoard.instantiateViewController(withIdentifier: "PrintItem") as? PrintItem {
            mPrint.mTYPE = mTYPE
            self.navigationController?.pushViewController(mPrint, animated:true)
        }
    }
    
    func mGetInventoryData(key : String){
        
        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
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
        
        let urlPath =  mGetMixAndMatchInventroy
        let params = ["location":mLocation,"filter": mFilterData ,"search":key ] as [String : Any]
        
        if Reachability.isConnectedToNetwork() == true {
            AF.request(urlPath, method:.post,parameters: params ,encoding: JSONEncoding.default, headers: sGisHeaders2).responseJSON
            { response in
                
                print("mGetMixAndMatchInventroy response = \(response)")
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
                        
                        self.mInventoryData = NSArray()
                        if let mData = jsonResult.value(forKey: "data") as? NSArray, mData.count > 0 {
                           
                            if let data = mData[0] as? NSDictionary {
//                                self.mStoneDataArray = NSMutableArray()
//                                self.mStoneDataArray.add(data)
//                                self.mMaterialName.text = "\(data.value(forKey: "metal_name") ?? "--")"
//                                self.mStoneOne.text = "\(data.value(forKey: "stone_name") ?? "--")"
//                                self.mReferenceName.text = "\(data.value(forKey: "referenceNo") ?? "--")"
//                                self.mMaterialWeight.text = "\(data.value(forKey: "NetWt") ?? "--")"
//                                self.mStoneOneWeight.text = "\(data.value(forKey: "Cts") ?? "--")"
//                                self.mCertificateName.text = "\(data.value(forKey: "certificate_type") ?? "--")"
//                                self.mCertificateNumber.text = "\(data.value(forKey: "certificate_number") ?? "--")"
                                
                                self.updateProductSummary(with: data)
                                
                                if let status = data.value(forKey: "status_type") as? String {
                                    if status == "stock" {
                                        self.mProductStatus.textColor = #colorLiteral(red: 0.4588235294, green: 0.8, blue: 1, alpha: 1)
                                        self.mStatusDot.backgroundColor = #colorLiteral(red: 0.4588235294, green: 0.8, blue: 1, alpha: 1)
                                        self.mProductStatus.text = "Stock"
                                    }else if status == "reserve" {
                                        self.mProductStatus.textColor = #colorLiteral(red: 1, green: 0.7386777401, blue: 0.3924969435, alpha: 1)
                                        self.mStatusDot.backgroundColor = #colorLiteral(red: 1, green: 0.7386777401, blue: 0.3924969435, alpha: 1)
                                        self.mProductStatus.text = "Reserved"
                                    }else if status == "custom_order" {
                                        self.mProductStatus.textColor = #colorLiteral(red: 0.9137254902, green: 0.4392156863, blue: 0.4392156863, alpha: 1)
                                        self.mStatusDot.backgroundColor = #colorLiteral(red: 0.9137254902, green: 0.4392156863, blue: 0.4392156863, alpha: 1)
                                        self.mProductStatus.text = "Reserved"
                                    }else if status == "repair_order" {
                                        self.mProductStatus.textColor = #colorLiteral(red: 0.662745098, green: 0.6078431373, blue: 0.7411764706, alpha: 1)
                                        self.mStatusDot.backgroundColor = #colorLiteral(red: 0.662745098, green: 0.6078431373, blue: 0.7411764706, alpha: 1)
                                        self.mProductStatus.text = "Repair"
                                    }else if status == "warehouse" {
                                        self.mProductStatus.textColor = #colorLiteral(red: 0.4392156863, green: 0.4392156863, blue: 0.4392156863, alpha: 1)
                                        self.mStatusDot.backgroundColor = #colorLiteral(red: 0.4392156863, green: 0.4392156863, blue: 0.4392156863, alpha: 1)
                                        self.mProductStatus.text = "WareHouse"
                                    }else if status == "transit" {
                                        self.mProductStatus.textColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
                                        self.mStatusDot.backgroundColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
                                        self.mProductStatus.text = "Transit"
                                    }
                                    
                                }else{
                                    self.mProductStatus.textColor = #colorLiteral(red: 0.4588235294, green: 0.8, blue: 1, alpha: 1)
                                    self.mStatusDot.backgroundColor = #colorLiteral(red: 0.4588235294, green: 0.8, blue: 1, alpha: 1)
                                    self.mProductStatus.text = "Stock"
                                }
                                
                                if let image = data.value(forKey: "main_image") as? String {
                                    self.mInventoryImage.downlaodImageFromUrl(urlString: image)
                                }
                                self.mStockID.text = "\(data.value(forKey: "stock_id") ?? "")"
                                self.mStockName.text = "\(data.value(forKey: "SKU") ?? "")"
                                self.mMetaTag.text = "\(data.value(forKey: "Matatag") ?? "")"
                                self.mLocationName.text = "\(data.value(forKey: "location_name") ?? "")"
                                self.mMetalName.text = "\(data.value(forKey: "metal_name") ?? "")"
//                                self.mStoneName.text = "\(data.value(forKey: "stone_name") ?? "")"
                                if let stones = data["stoneData"] as? [[String: Any]] {

                                    var names: [String] = []

                                    for stone in stones {
                                        if let name = stone["stone_name"] as? String,
                                           !names.contains(name) {
                                            names.append(name)
                                        }
                                    }

                                    self.mStoneName.text = names.joined(separator: ", ")
                                } else {
                                    self.mStoneName.text = "--"
                                }
                                self.mSize.text = "\(data.value(forKey: "size_name") ?? "")"
                                self.mCollectionName.text = "\(data.value(forKey: "collection_name") ?? "")"
                                self.mInventoryData =  mData
                                self.mIndexInv = -1
                                
                                
                                
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
        }else{
            CommonClass.showSnackBar(message: "No Internet Connection")
        }
        
        
    }
    
}
