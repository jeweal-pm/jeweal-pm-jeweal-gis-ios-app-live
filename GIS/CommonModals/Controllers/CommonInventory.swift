//
//  CommonInventory.swift
//  GIS
//
//  Created by MacBook Hawkscode  on 30/12/22.
//  Copyright © 2022 Hawkscode. All rights reserved.
//

import UIKit
import Alamofire
import DropDown
import UIDrawer


protocol GetInventoryDataItemsDelegate {
    func mGetInventoryItems(items: [String])
}

class CommonInventory:UIViewController , UITableViewDelegate , UITableViewDataSource  , RangeSeekSliderDelegate, UIGestureRecognizerDelegate,UIViewControllerTransitioningDelegate, GetInventoryFiltersDelegate {
      
        
      
        //Inventory Item Details

        var delegate:GetInventoryDataItemsDelegate? = nil

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
        
        var mInventoryData = NSMutableArray()
        var mSummaryData = NSArray()
        
        var mIndexInv = -1
        var mIndexSum = -1
        
        
        
        
        var mReserveData = NSMutableArray()
        var mStoneDataArray = NSMutableArray()
        var mProductId = [String]()

        @IBOutlet weak var mTotalReserve: UILabel!

        
        @IBOutlet weak var mSalesPersonName: UILabel!
        var mSalesManList = [String]()
        var mSalesManIDList = [String]()
        var mCustomerId = ""
        var mSalesPersonId = ""

        /// Use the salesperson selected for the active POS sale.  This is
        /// required by the reserve-to-cart payload and must not fall back to
        /// the logged-in user.
        private var selectedSalesPersonId: String {
            let stored = UserDefaults.standard.string(forKey: "SALESPERSONID") ?? ""
            if !stored.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return stored.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            return mSalesPersonId.trimmingCharacters(in: .whitespacesAndNewlines)
        }
  
        
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
    
    var mOrderType = "";
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
    
    var mProductIdForImage = ""
    var mSKUForImage = ""
    
    let mInventoryFetchLimit = 20
    var mInventorySkip = 0
    var mInventoryTotal = 0
    @IBOutlet weak var mShowMoreInventory: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        mReserveButton.setTitle("ADD TO CART".localizedString, for: .normal)
        
        mMyInventoryTableView.isHidden = false
        mShowMoreInventory.isHidden = true
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
        
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(onTapImage))
        tap1.delegate = self
        mInventoryImage.isUserInteractionEnabled = true
        mInventoryImage.addGestureRecognizer(tap1)
        
    }
    
    @objc
    func onTap(){
        
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
//        guard let home = storyBoard.instantiateViewController(withIdentifier: "SKUProductSummary") as? SKUProductSummary else { return }
//        home.mOriginalData =  NSArray(array: mStoneDataArray)
//        home.modalPresentationStyle = .automatic
//        home.transitioningDelegate = self
//        self.present(home,animated: true)
    }
    
    @objc
    func onTapImage(){
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
    
    override func viewWillAppear(_ animated: Bool) {
        
        addDoneButtonOnKeyboard()
        
    }

    @IBAction func mScanNow(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "invdata", bundle: nil)
        guard let home = storyBoard.instantiateViewController(withIdentifier: "SearchInventory") as? SearchInventory else { return }
        home.mType = "Inventory"
        home.mFrom = "2"
        self.navigationController?.pushViewController(home, animated:true)
        
    }
    
    @IBAction func mHome(_ sender: Any) {
        self.dismiss(animated: true)
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
        
    func buildReservePayload(from item: NSDictionary) -> [String: Any] {

        var cartItem: [String: Any] = [:]

//        cartItem["location_id"] = item["location_id"] ?? ""
        cartItem["location_id"] =
            item["location_id"]
            ?? UserDefaults.standard.string(forKey: "location")
            ?? ""
        cartItem["delivery_date"] = item["delivery_date"] ?? ""
        print("product_id =", item["product_id"] ?? "")
        print("po_product_id =", item["po_product_id"] ?? "")
        cartItem["product_id"] = item["product_id"] ?? ""
        cartItem["main_image"] = item["main_image"] ?? ""
        cartItem["po_QTY"] = item["po_QTY"] ?? 1
        cartItem["price"] = item["retailprice_Inc"] ?? 0
        cartItem["SKU"] = item["SKU"] ?? ""
        cartItem["name"] = item["name"] ?? ""

        cartItem["GrossWt"] = item["GrossWt"] ?? ""
        cartItem["NetWt"] = item["NetWt"] ?? ""

        cartItem["PriceDetails"] = item["PriceDetails"] ?? []

        cartItem["Stones"] = item["Stones"] ?? item["stoneData"] ?? []
        cartItem["status"] = item["status"] ?? [:]
        
        cartItem["ID"] = item["ID"] ?? ""
        cartItem["id"] = item["_id"] ?? ""
        cartItem["Stone"] = item["Stone"] ?? ""
        cartItem["Metal"] =
            item["Metal"] ??
            item["metal_name"] ??
            ""
        cartItem["Size"] =
            item["size_name"]
            ?? item["Size_name"]
            ?? ""

        cartItem["product_type"] = item["product_type"] ?? ""
        cartItem["is_product"] = item["is_product"] ?? 0
        cartItem["is_variant"] = item["is_variant"] ?? 0
        cartItem["is_design"] = item["is_design"] ?? 0

        cartItem["stock_id"] = item["stock_id"] ?? ""
        cartItem["retailprice_Inc"] = item["retailprice_Inc"] ?? 0
        cartItem["item_name"] = item["item_name"] ?? ""
        cartItem["collection_name"] = item["collection_name"] ?? ""
        cartItem["metal_name"] = item["metal_name"] ?? ""
        cartItem["size_name"] = item["size_name"] ?? ""
        cartItem["stone_name"] = item["stone_name"] ?? ""
        cartItem["status_type"] = item["status_type"] ?? ""
        cartItem["warehouse_location_name"] = item["warehouse_location_name"] ?? ""
        cartItem["extra_po_information"] = ""
        cartItem["pos_no"] = ""
        cartItem["customer_name"] = ""

        // Preserve the linked-cart fields while the selected inventory item is
        // converted into a reserve cart item.
        cartItem["linked_cart_id"] = item["linked_cart_id"] ?? ""
        cartItem["linked_order_id"] = item["linked_order_id"] ?? ""
        cartItem["existing_cart_status"] = item["existing_cart_status"] ?? ""
        cartItem["can_create_new_cart"] = item["can_create_new_cart"] ?? true
        cartItem["linked_order_type"] = item["linked_order_type"] ?? ""
        
        print("===== CHECK =====")
        print("ID =", cartItem["ID"] ?? "")
        print("_id =", item["_id"] ?? "")
        print("location_id =", cartItem["location_id"] ?? "")
        print("product_id =", cartItem["product_id"] ?? "")
        print("Metal =", cartItem["Metal"] ?? "")
        print("Size =", cartItem["Size"] ?? "")
        print("Stone =", cartItem["Stone"] ?? "")
        print("sales_person_id =", selectedSalesPersonId)
        print("=================")
        return [
            "cartItems":[cartItem],
            "order_type":"reserve",
            "customer_id":mCustomerId,
            "sales_person_id":selectedSalesPersonId,
            "byMobile": true,
            "byPosReserveMobile": true
        ]
    }
    
    @IBAction func mSubmitReserveItems(_ sender: Any) {

        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")

        // A linked cart can be opened from the normal POS inventory screen as
        // well as the Reserve screen.  Always honour the linked-cart flags
        // before falling through to the normal add-to-cart flow.
        let hasSelectedExistingLinkedCart: Bool = {
            guard mIndexInv >= 0,
                  let item = mInventoryData[mIndexInv] as? NSDictionary else {
                return false
            }

            let cartId = "\(item["linked_cart_id"] ?? "")"
                .trimmingCharacters(in: .whitespacesAndNewlines)
            guard !cartId.isEmpty else { return false }

            if let value = item["can_create_new_cart"] as? Bool {
                return !value
            }
            if let value = item["can_create_new_cart"] as? NSNumber {
                return !value.boolValue
            }
            let value = "\(item["can_create_new_cart"] ?? "")".lowercased()
            return value == "0" || value == "false" || value == "no"
        }()

        // ---------------- RESERVE / LINKED-CART FLOW ----------------
        if mOrderType == "reserve" || hasSelectedExistingLinkedCart {

            guard mIndexInv >= 0,
                  let inventoryItem = mInventoryData[mIndexInv] as? NSDictionary else {

                print("❌ No inventory item selected")
                return
            }

            print("========== ORDER TYPE ==========")
            print("mOrderType =", mOrderType)
            print("mProductId =", mProductId)
            print("===============================")

            // IMPORTANT:
            // POS -> Reserve -> Inventory -> select a NEW stock:
            //     /POS/reserve/reserveToCart
            //
            // POS -> Inventory -> Reserve icon -> select stock that is
            // already linked to an existing reserve cart:
            //     /Mobile/pos/customOrder/addItemToCart
            //
            // The caller can still pass mOrderType = "reserve" for both
            // screens, so the endpoint MUST be decided from the selected
            // inventory item's linked-cart fields, not mOrderType alone.
            let linkedCartId = "\(inventoryItem["linked_cart_id"] ?? "")".trimmingCharacters(in: .whitespacesAndNewlines)
            let existingCartStatus = inventoryItem["existing_cart_status"]

            let canCreateNewCart: Bool = {
                if let value = inventoryItem["can_create_new_cart"] as? Bool {
                    return value
                }
                if let value = inventoryItem["can_create_new_cart"] as? NSNumber {
                    return value.boolValue
                }
                if let value = inventoryItem["can_create_new_cart"] as? String {
                    return value == "1" || value.lowercased() == "true"
                }
                // Keep the old/new-stock behavior when the field is absent.
                return true
            }()

            let hasExistingLinkedCart = !linkedCartId.isEmpty && !canCreateNewCart

            print("========== RESERVE / EXISTING CART FLOW ==========")
            print("mOrderType =", mOrderType)
            print("mProductId =", mProductId)
            print("linked_cart_id =", linkedCartId)
            print("existing_cart_status =", existingCartStatus ?? "<null>")
            print("can_create_new_cart =", canCreateNewCart)
            print("hasExistingLinkedCart =", hasExistingLinkedCart)
            print("=================================================")

            self.mReserveButton.isEnabled = false
            CommonClass.showFullLoader(view: self.view)

            if hasExistingLinkedCart {
                // TEST 2:
                // The stock was already reserved from POS. Do NOT create
                // another reserve cart. Update the existing linked cart.
                let params: [String: Any] = [
                    "sales_person_id": selectedSalesPersonId,
                    "customer_id": mCustomerId,
                    "order_type": "pos_order",
                    "product_id": mProductId,
                    "type": "inventory"
                ]

                print("========== EXISTING RESERVED STOCK ==========")
                print("➡️ addItemToCart")
                print("URL =", mAddCustomProduct)
                print("PARAMS =", params)
                print("linked_cart_id =", linkedCartId)
                print("============================================")

                mGetData(
                    url: mAddCustomProduct,
                    headers: sGisHeaders,
                    params: params
                ) { response, status in

                    CommonClass.stopLoader()
                    self.mReserveButton.isEnabled = true

                    print("========== ADD EXISTING CART RESPONSE ==========")
                    print("STATUS =", status)
                    print("RESPONSE =", response)
                    print("================================================")

                    if status && "\(response.value(forKey: "code") ?? "")" == "200" {

                        let showPopup: String
                        if let value = response["showPopup"] as? Bool {
                            showPopup = value ? "1" : "0"
                        } else if let value = response["showPopup"] as? NSNumber {
                            showPopup = value.intValue == 1 ? "1" : "0"
                        } else if let value = response["showPopup"] as? String {
                            showPopup = value == "1" || value.lowercased() == "true" ? "1" : "0"
                        } else {
                            showPopup = "0"
                        }

                        UserDefaults.standard.set(showPopup, forKey: "reserve_show_popup")
                        UserDefaults.standard.setValue("", forKey: "mClearCart")

                        let linkedCartContext = LinkedCartContext(inventoryItem: inventoryItem)
                        let cartIdFromAddResponse: String = {
                            guard let ids = response["data"] as? [Any],
                                  let firstId = ids.first,
                                  !(firstId is NSNull) else {
                                return ""
                            }
                            return "\(firstId)".trimmingCharacters(in: .whitespacesAndNewlines)
                        }()
                        // The restore endpoint must receive the original
                        // Reserve cart from Inventory. `data[0]` can be a new
                        // POS cart created by addItemToCart, so it is only a
                        // fallback when Inventory did not provide a linked id.
                        let cartIdForRestore = linkedCartContext.linkedCartId.isEmpty
                            ? cartIdFromAddResponse
                            : linkedCartContext.linkedCartId

                        // Keep the linked cart id as a direct fallback for the
                        // Cart Details back flow. The inventory response is the
                        // source of truth and is available even if the context
                        // store cannot be read later.
                        if !cartIdForRestore.isEmpty {
                            UserDefaults.standard.set(
                                cartIdForRestore,
                                forKey: "reserve_linked_cart_id"
                            )
                            // Keep the reserve state with the cart id. The cart
                            // screen can still show its leave confirmation if it
                            // is recreated before Back is tapped.
                            UserDefaults.standard.set(
                                linkedCartContext.linkedOrderType,
                                forKey: "reserve_linked_order_type"
                            )
                            UserDefaults.standard.set(
                                linkedCartContext.canCreateNewCart,
                                forKey: "reserve_can_create_new_cart"
                            )
                            print("SAVE reserve_linked_cart_id =", cartIdForRestore)
                        }

                        // Keep the same existing Reserve cart context available to
                        // both keys used by the POS Cart screen.  The source of truth
                        // is the linked_cart_id coming from the selected inventory.
                        LinkedCartContextStore.shared.save(
                            linkedCartContext,
                            orderType: "reserve",
                            customerId: self.mCustomerId
                        )

                        LinkedCartContextStore.shared.save(
                            linkedCartContext,
                            orderType: "pos_order",
                            customerId: self.mCustomerId
                        )

                        print("SAVE EXISTING LINKED CONTEXT")
                        print("linkedCartId =", linkedCartContext.linkedCartId)
                        print("linkedOrderId =", linkedCartContext.linkedOrderId)
                        print("linkedOrderType =", linkedCartContext.linkedOrderType)

                        self.dismiss(animated: true)
                        self.delegate?.mGetInventoryItems(items: self.mProductId)

                    } else {
                        let message = "\(response.value(forKey: "message") ?? "Something went wrong")"
                        CommonClass.showSnackBar(message: message)
                    }
                }

                return
            }

            // TEST 1 / Normal POS Reserve:
            // No existing linked cart -> create the reserve cart for the first time.
            let linkedCartContext = LinkedCartContext(inventoryItem: inventoryItem)
            let payload = buildReservePayload(from: inventoryItem)

            print("========== NEW RESERVE PAYLOAD ==========")
            print(payload)
            print("URL =", mReserveToCart)
            print("=========================================")

            mGetData(
                url: mReserveToCart,
                headers: sGisHeaders,
                params: payload
            ) { response, status in

                CommonClass.stopLoader()
                self.mReserveButton.isEnabled = true

                print("========== RESERVE RESPONSE ==========")
                print("STATUS =", status)
                print("RESPONSE =", response)
                print("======================================")

                if status && "\(response.value(forKey: "code") ?? "")" == "200" {

                    print("DEBUG_RESERVE_SUCCESS")
                    print("DEBUG_PRODUCT_ID =", self.mProductId)
                    print("➡️ reserveToCart success")
                    print("➡️ NO addItemToCart call (new reserve)")

                    LinkedCartContextStore.shared.save(
                        linkedCartContext,
                        orderType: self.mOrderType,
                        customerId: self.mCustomerId
                    )

                    let showPopup: String
                    if let value = response["showPopup"] as? Bool {
                        showPopup = value ? "1" : "0"
                    } else if let value = response["showPopup"] as? NSNumber {
                        showPopup = value.intValue == 1 ? "1" : "0"
                    } else if let value = response["showPopup"] as? String {
                        showPopup = value == "1" || value.lowercased() == "true" ? "1" : "0"
                    } else {
                        showPopup = "0"
                    }

                    UserDefaults.standard.set(showPopup, forKey: "reserve_show_popup")
                    if !linkedCartContext.linkedCartId.isEmpty {
                        UserDefaults.standard.set(
                            linkedCartContext.linkedCartId,
                            forKey: "reserve_linked_cart_id"
                        )
                        UserDefaults.standard.set(
                            linkedCartContext.linkedOrderType,
                            forKey: "reserve_linked_order_type"
                        )
                        UserDefaults.standard.set(
                            linkedCartContext.canCreateNewCart,
                            forKey: "reserve_can_create_new_cart"
                        )
                    } else {
                        UserDefaults.standard.removeObject(forKey: "reserve_linked_cart_id")
                        UserDefaults.standard.removeObject(forKey: "reserve_linked_order_type")
                        UserDefaults.standard.removeObject(forKey: "reserve_can_create_new_cart")
                    }
                    UserDefaults.standard.setValue("", forKey: "mClearCart")

                    self.dismiss(animated: true)
                    self.delegate?.mGetInventoryItems(items: self.mProductId)

                } else {

                    let message = "\(response.value(forKey: "message") ?? "Something went wrong")"
                    CommonClass.showSnackBar(message: message)
                }
            }

            return
        }

        // ---------------- NORMAL ADD-TO-CART FLOW ----------------
        // This branch is intentionally kept for non-reserve order types.
        // Reserve MUST return above after calling /POS/reserve/reserveToCart.

        var mParams: [String: Any] = [
            "product_id": mProductId,
            "customer_id": mCustomerId,
            "sales_person_id": selectedSalesPersonId,
            "type": "inventory",
            "order_type": mOrderType
        ]
        print("========== ORDER TYPE ==========")
        print("mOrderType =", mOrderType)
        print("mProductId =", mProductId)
        print("===============================")
        print("DEBUG_OLD_PARAMS =", mParams)
        self.mReserveButton.isEnabled = false
        CommonClass.showFullLoader(view: self.view)

        mGetData(
            url: mAddCustomProduct,
            headers: sGisHeaders,
            params: mParams
        ) { response, status in

            CommonClass.stopLoader()
            self.mReserveButton.isEnabled = true
            print("========== ADD PRODUCT RESPONSE ==========")
            print("STATUS =", status)
            print("RESPONSE =", response)
            print("==========================================")

            if status {

                if "\(response.value(forKey: "code") ?? "")" == "200" {

                    self.dismiss(animated: true)
                    UserDefaults.standard.setValue("", forKey: "mClearCart")
                    let linkedCartContext: LinkedCartContext?
                    if self.mIndexInv >= 0,
                       let inventoryItem = self.mInventoryData[self.mIndexInv] as? NSDictionary {
                        linkedCartContext = LinkedCartContext(inventoryItem: inventoryItem)
                    } else {
                        linkedCartContext = nil
                    }
                    if let linkedCartContext {
                        LinkedCartContextStore.shared.save(
                            linkedCartContext,
                            orderType: self.mOrderType,
                            customerId: self.mCustomerId
                        )
                    }
                    self.delegate?.mGetInventoryItems(items: self.mProductId)
                } else {
                    
                    let message = "\(response.value(forKey: "message") ?? "Something went wrong")"
                    CommonClass.showSnackBar(message: message)
                }
            } else {
                
                CommonClass.showSnackBar(message: "Something went wrong")
            }
        }
    }
    
    @IBAction func mSearch(_ sender: Any) {
        mFilterSearchView.isHidden =  false
    }
    
    @IBAction func mFilter(_ sender: Any) {
        
        view.endEditing(true)
        let storyBoard: UIStoryboard = UIStoryboard(name: "common", bundle: nil)
        guard let mFilters = storyBoard.instantiateViewController(withIdentifier: "CommonFilters") as? CommonFilters else { return }
        mFilters.delegate = self
        mFilters.mType = "inventory"
        mFilters.mItemsId = mItemsId
        mFilters.mMetalsId = mMetalsId
        mFilters.mCollectionId = mCollectionId
        mFilters.mStonesId = mStonesId
        mFilters.mSizeId = mSizeId
//        mFilters.mLocationsId = mStatusId
//        mFilters.mStatusId = mLocationsId
        mFilters.mLocationsId = mLocationsId
        mFilters.mStatusId = mStatusId
        mFilters.mMinPrices = mMinPrices
        mFilters.mMaxPrices = mMaxPrices
        mFilters.modalPresentationStyle = .automatic
        mFilters.transitioningDelegate = self
        self.present(mFilters,animated: true)
        
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
            mInventorySkip = 0
            mGetInventoryData(key: "")
            
        }
    }
    
    @IBAction func mShowmore(_ sender: Any) {
        
        self.mGetInventoryData(key : "")
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
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        
        var cell  = UITableViewCell()
        if tableView == mMyInventoryTableView {
            if let  cells = tableView.dequeueReusableCell(withIdentifier: "InventoryCell") as? InventoryCell {
                
                cells.mView.backgroundColor = (indexPath.row % 2 == 0) ? UIColor(named: "themeBackground") : #colorLiteral(red: 0.9568627451, green: 0.9568627451, blue: 0.9568627451, alpha: 1)
                
                if let mData = mInventoryData[indexPath.row] as? NSDictionary {
                    
                    if let isDesign = mData.value(forKey: "isDesign") as? Bool, isDesign {
                        cells.mDesignView.isHidden = false
                    }else{
                        cells.mDesignView.isHidden = true
                    }
                    
                    cells.mStockName.text = "\(mData.value(forKey: "SKU") ?? "--")"
                    
                    cells.mStockId.text = "\(mData.value(forKey: "stock_id") ?? "--")"
                    
                    cells.mQuantity.text = "\(mData.value(forKey: "po_QTY") ?? "--") Pcs"
                    cells.mAmount.text =  "\(mData.value(forKey: "price") ?? "--")"
                    
                    
                    let isEmptyInventory = mSelectedInventoryIndex.isEmpty
                    mHeight.constant = isEmptyInventory ? 0 : 90
                    mReserveButton.isHidden = isEmptyInventory
                    mReserveButtonView.isHidden = isEmptyInventory
                    
                    if !isEmptyInventory {
                        mReserveButtonView.layer.cornerRadius = 10
                        mReserveButtonView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                    }
                    
                    cells.mStockName.text = "\(mData.value(forKey: "SKU") ?? "--")"
                    cells.mStockId.text = "\(mData.value(forKey: "stock_id") ?? "--")"
                    cells.mQuantity.text = "\(mData.value(forKey: "po_QTY") ?? "--") Pcs"
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        cells.mAmount.text =  "\(mData.value(forKey: "price") ?? "--")"
                    }else{
                        cells.mAmount.text =  "\(mData.value(forKey: "price") ?? "--")"
                        
                    }
                    
                    
                    
                    cells.mStatusColor.textColor = .clear
                    if let statusType = mData.value(forKey: "status_type") as? String {
                        switch statusType {
                            case "stock":
                                cells.mStatusColor.backgroundColor = #colorLiteral(red: 0.4588235294, green: 0.8, blue: 1, alpha: 1)
                            case "reserve":
                                cells.mStatusColor.backgroundColor = #colorLiteral(red: 1, green: 0.7386777401, blue: 0.3924969435, alpha: 1)
                            case "custom_order":
                                cells.mStatusColor.backgroundColor = #colorLiteral(red: 0.9137254902, green: 0.4392156863, blue: 0.4392156863, alpha: 1)
                            case "repair_order":
                                cells.mStatusColor.backgroundColor = #colorLiteral(red: 0.662745098, green: 0.6078431373, blue: 0.7411764706, alpha: 1)
                            case "warehouse":
                                cells.mStatusColor.backgroundColor = #colorLiteral(red: 0.4392156863, green: 0.4392156863, blue: 0.4392156863, alpha: 1)
                            case "transit":
                                cells.mStatusColor.backgroundColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
                            default:
                                break
                        }
                    } else {
                        cells.mStatusColor.backgroundColor = #colorLiteral(red: 0.4588235294, green: 0.8, blue: 1, alpha: 1)
                    }
                    
                    cells.mCheckIcon.image = mSelectedInventoryIndex.contains(indexPath) ? UIImage(named: "check_item") : UIImage(named: "uncheck_item")
                    
                    cells.layoutSubviews()
                    
                    if mIndexInv == indexPath.row {
                        if let statusType = mData.value(forKey: "status_type") as? String {
                            switch statusType {
                            case "stock":
                                let color = #colorLiteral(red: 0.4588235294, green: 0.8, blue: 1, alpha: 1)
                                self.setProductStatus(color: color, text: "Stock")
                            case "reserve":
                                let color = #colorLiteral(red: 1, green: 0.7386777401, blue: 0.3924969435, alpha: 1)
                                self.setProductStatus(color: color, text: "Reserved")
                            case "custom_order":
                                let color = #colorLiteral(red: 0.9137254902, green: 0.4392156863, blue: 0.4392156863, alpha: 1)
                                self.setProductStatus(color: color, text: "Reserved")
                            case "repair_order":
                                let color = #colorLiteral(red: 0.662745098, green: 0.6078431373, blue: 0.7411764706, alpha: 1)
                                self.setProductStatus(color: color, text: "Repair")
                            case "warehouse":
                                let color = #colorLiteral(red: 0.4392156863, green: 0.4392156863, blue: 0.4392156863, alpha: 1)
                                self.setProductStatus(color: color, text: "Warehouse")
                            case "transit":
                                let color = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
                                self.setProductStatus(color: color, text: "Transit")
                            default:
                                break
                            }
                        } else {
                            let color = #colorLiteral(red: 0.4588235294, green: 0.8, blue: 1, alpha: 1)
                            self.setProductStatus(color: color, text: "Stock")
                        }
                    }

                }
                cell = cells
            }
        }
        
        return cell
    }
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if tableView == mCustomerSearchTableView {
            return 78
        }
        return 52
        
    }
    
    func setProductStatus(color: UIColor, text: String) {
        self.mProductStatus.textColor = color
        self.mStatusDot.backgroundColor = color
        self.mProductStatus.text = text
    }
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if tableView == mMyInventoryTableView {
            
            mIndexInv = indexPath.row
            
            if let mData = mInventoryData[indexPath.row] as? NSDictionary {
                print("========== INVENTORY SELECT DEBUG ==========")
                print("SKU =", mData.value(forKey: "SKU") ?? "nil")
                print("product_id =", mData.value(forKey: "product_id") ?? "nil")
                print("po_product_id =", mData.value(forKey: "po_product_id") ?? "nil")
                print("location_id =", mData.value(forKey: "location_id") ?? "nil")
                print("status_type =", mData.value(forKey: "status_type") ?? "nil")
                // IMPORTANT:
                // Keep mOrderType from the screen that opened CommonInventory.
                // The selected item's status_type must NOT change the flow.
                //
                // POS -> Reserve -> Inventory:
                //     caller sets mOrderType = "reserve"
                //     -> /POS/reserve/reserveToCart
                //
                // POS -> Inventory -> already reserved stock:
                //     caller sets mOrderType = "pos_order"
                //     -> /Mobile/pos/customOrder/addItemToCart
                //
                // status_type only describes the selected stock.
                let statusType = "\(mData.value(forKey: "status_type") ?? "")"
                print("status_type =", statusType)
                print("🔥 caller mOrderType =", self.mOrderType)
                print("FULL ITEM =", mData)
                print("============================================")
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
                
                self.mInventoryImage.downlaodImageFromUrl(urlString: "\(mData.value(forKey: "main_image") ?? "")")
                
                self.mStockID.text = "\(mData.value(forKey: "stock_id") ?? "")"
                self.mStockName.text = "\(mData.value(forKey: "SKU") ?? "")"
                self.mMetaTag.text = "\(mData.value(forKey: "Matatag") ?? "")"
                self.mLocationName.text = "\(mData.value(forKey: "location_name") ?? "")"
                self.mMetalName.text = "\(mData.value(forKey: "metal_name") ?? "")"
//                self.mStoneName.text = "\(mData.value(forKey: "stone_name") ?? "")"
                
                if let productDetails = mData["product_details"] as? NSDictionary,
                   let stones = productDetails["Stones"] as? [[String: Any]],
                   let firstStone = stones.first {

                    self.mStoneName.text = "\(firstStone["stone_name"] ?? "--")"

                } else {

                    let stoneName = "\(mData["stone_name"] ?? "--")"
                    self.mStoneName.text = stoneName.components(separatedBy: ",").first ?? stoneName
                }
                
                self.mSize.text = "\(mData.value(forKey: "size_name") ?? "")"
                self.mCollectionName.text = "\(mData.value(forKey: "collection_name") ?? "")"
                
//                self.mMaterialName.text = "\(mData.value(forKey: "metal_name") ?? "--")"
//                self.mStoneOne.text = "\(mData.value(forKey: "stone_name") ?? "--")"
//                self.mReferenceName.text = "\(mData.value(forKey: "referenceNo") ?? "--")"
//                self.mMaterialWeight.text = "\(mData.value(forKey: "NetWt") ?? "--")"
//                self.mStoneOneWeight.text = "\(mData.value(forKey: "Cts") ?? "--")"
//                self.mCertificateName.text = "\(mData.value(forKey: "certificate_type") ?? "--")"
//                self.mCertificateNumber.text = "\(mData.value(forKey: "certificate_number") ?? "--")"
                print("========== ALL INVENTORY KEYS ==========")

                for key in mData.allKeys {
                    print("mData KEY =", key)
                }

                print("========================================")
                self.updateProductSummary(mData)
                
                if mIndexInv == indexPath.row {
                    if let statusType = mData.value(forKey: "status_type") as? String {
                        switch statusType {
                        case "stock":
                            let color = #colorLiteral(red: 0.4588235294, green: 0.8, blue: 1, alpha: 1)
                            self.setProductStatus(color: color, text: "Stock")
                        case "reserve":
                            let color = #colorLiteral(red: 1, green: 0.7386777401, blue: 0.3924969435, alpha: 1)
                            self.setProductStatus(color: color, text: "Reserved")
                        case "custom_order":
                            let color = #colorLiteral(red: 0.9137254902, green: 0.4392156863, blue: 0.4392156863, alpha: 1)
                            self.setProductStatus(color: color, text: "Reserved")
                        case "repair_order":
                            let color = #colorLiteral(red: 0.662745098, green: 0.6078431373, blue: 0.7411764706, alpha: 1)
                            self.setProductStatus(color: color, text: "Repair")
                        case "warehouse":
                            let color = #colorLiteral(red: 0.4392156863, green: 0.4392156863, blue: 0.4392156863, alpha: 1)
                            self.setProductStatus(color: color, text: "Warehouse")
                        case "transit":
                            let color = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
                            self.setProductStatus(color: color, text: "Transit")
                        default:
                            break
                        }
                    } else {
                        let color = #colorLiteral(red: 0.4588235294, green: 0.8, blue: 1, alpha: 1)
                        self.setProductStatus(color: color, text: "Stock")
                    }
                }
                
                if let statusType = mData.value(forKey: "status_type") as? String {
                    if ["stock", "reserve", "custom_order", "repair_order"].contains(statusType) {
                        
                        
                        if ["custom_order", "reserve", "repair_order"].contains(statusType) {
                            if let mInvData = mInventoryData[indexPath.row] as? NSDictionary {
                                
                                if let mCOData = mInvData.value(forKey: "pos") as? NSDictionary {
                                    if self.mCustomerId != mCOData.value(forKey: "customer_id") as? String {
                                        let msg = "This Item is reserved for \(mCOData.value(forKey: "customer_name") ?? "Other user")"
                                        CommonClass.showSnackBar(message: msg)
                                        return
                                    }
                                }
                            }
                        }
                        
                        if let poProductId = mData.value(forKey: "po_product_id") as? String {
                            if mProductId.contains(poProductId) {
                                mProductId = mProductId.filter {$0 != poProductId }
                            }else{
                                mProductId.append(poProductId)
                                print("DEBUG PRODUCT IDS AFTER SELECT poProductId =", mProductId)
                            }
                        }
                        
                        if self.mSelectedInventoryIndex.contains(indexPath) {
                            self.mSelectedInventoryIndex = mSelectedInventoryIndex.filter {$0 != indexPath }
                        }else{
                            self.mSelectedInventoryIndex.append(indexPath)
                            print("DEBUG PRODUCT IDS AFTER SELECT mSelectedInventoryIndex =", mProductId)
                        }
                    }
                    
                }
                
                self.mSKUForImage = "\(mData.value(forKey: "SKU") ?? "")"
                self.mProductIdForImage = "\(mData.value(forKey: "product_id") ?? "")"
                
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
        guard let mPrint = storyBoard.instantiateViewController(withIdentifier: "PrintItem") as? PrintItem else {return}
        mPrint.mTYPE = mTYPE
        self.navigationController?.pushViewController(mPrint, animated:true)
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
    
//    func updateProductSummary(_ data: NSDictionary) {
//
//        let metalCode =
//            "\(data["metal_name"] ?? data["Metal_name"] ?? "")"
//
//        mMaterialName.text = getFullMetalName(metalCode)
////        mMaterialName.text = "\(data["metal_name"] ?? "--")"
//        mMaterialWeight.text = "\(data["NetWt"] ?? data["totalNetWt"] ?? "--")"
//
//        mReferenceName.text = "\(data["referenceNo"] ?? "--")"
//        mCertificateName.text = "\(data["certificate_type"] ?? "--")"
//        mCertificateNumber.text = "\(data["certificate_number"] ?? "--")"
//
//        // สำคัญ: default แถวที่ 2 เป็นค่าว่าง
//        mStoneOne.text = ""
//        mStoneOneWeight.text = ""
//
//        mStoneTwo.text = ""
//        mStoneTwoWeight.text = ""
//
//        var stones: [[String: Any]] = []
//
//        if let value = data["stoneData"] as? [[String: Any]] {
//
//            stones = value
//            print("🔥 SOURCE = stoneData")
//
//        } else if let value = data["Stones"] as? [[String: Any]] {
//
//            stones = value
//            print("🔥 SOURCE = Stones")
//
//        } else if let value = data["stones"] as? [[String: Any]] {
//
//            stones = value
//            print("🔥 SOURCE = stones")
//        }
//
//        guard !stones.isEmpty else {
//
//            print("🔥 NO STONE DETAIL ARRAY")
//
//            let stoneName = "\(data["stone_name"] ?? "")"
//                .trimmingCharacters(in: .whitespacesAndNewlines)
//
//            if !stoneName.isEmpty {
//
//                mStoneOne.text = stoneName
//                mStoneOneWeight.text = "\(data["Cts"] ?? "")"
//            }
//
//            // ไม่มี Stone ที่ 2 = ว่าง
//            mStoneTwo.text = ""
//            mStoneTwoWeight.text = ""
//
//            return
//        }
//
//        var stoneOrder: [String] = []
//        var stoneSummary: [String: (pcs: Int, cts: Double)] = [:]
//
//        for stoneData in stones {
//
//            let name =
//                (stoneData["stone"] as? String) ??
//                (stoneData["stone_name"] as? String) ??
//                (stoneData["Stone_name"] as? String) ??
//                ""
//
//            let cleanName = name.trimmingCharacters(
//                in: .whitespacesAndNewlines
//            )
//
//            guard !cleanName.isEmpty else {
//                continue
//            }
//
//            let pcs = Int("\(stoneData["Pcs"] ?? "0")") ?? 0
//            let cts = Double("\(stoneData["Cts"] ?? "0")") ?? 0.0
//
//            if var existing = stoneSummary[cleanName] {
//
//                existing.pcs += pcs
//                existing.cts += cts
//
//                stoneSummary[cleanName] = existing
//
//            } else {
//
//                stoneOrder.append(cleanName)
//
//                stoneSummary[cleanName] = (
//                    pcs: pcs,
//                    cts: cts
//                )
//            }
//        }
//
//        print("🔥 STONE ORDER =", stoneOrder)
//        print("🔥 STONE SUMMARY =", stoneSummary)
//
//        // Stone แรก
//        if stoneOrder.indices.contains(0),
//           let first = stoneSummary[stoneOrder[0]] {
//
//            mStoneOne.text = stoneOrder[0]
//
//            mStoneOneWeight.text =
////                "\(first.pcs)    \(formatCTS(first.cts))c"
//            "\(first.pcs)                   \(formatCTS(first.cts))c"
//        }
//
//        // Stone ที่สอง
//        if stoneOrder.indices.contains(1),
//           let second = stoneSummary[stoneOrder[1]] {
//
//            mStoneTwo.text = stoneOrder[1]
//
//            mStoneTwoWeight.text =
////                "\(second.pcs) Pcs   \(formatCTS(second.cts))c"
//            "\(second.pcs)                   \(formatCTS(second.cts))c"
//
//        } else {
//
//            // มี Stone ชนิดเดียว
//            mStoneTwo.text = ""
//            mStoneTwoWeight.text = ""
//        }
//    }
    
    func updateProductSummary(_ data: NSDictionary) {

        let metalCode =
            "\(data["metal_name"] ?? data["Metal_name"] ?? "")"

        mMaterialName.text = getFullMetalName(metalCode)
        mMaterialName.textAlignment = .left
        mMaterialName.numberOfLines = 0
        mMaterialWeight.text = "\(data["NetWt"] ?? data["totalNetWt"] ?? "--")"
        if let weight = Double("\(data.value(forKey: "NetWt") ?? "0")") {
            self.mMaterialWeight.text = String(format: "%.2f g", weight)
        } else if let weight = Double("\(data.value(forKey: "totalNetWt") ?? "0")") {
            self.mMaterialWeight.text = String(format: "%.2f g", weight)
        }
        else {
            self.mMaterialWeight.text = "--"
        }
        mReferenceName.text = "\(data["referenceNo"] ?? "--")"
        mCertificateName.text = "\(data["certificate_type"] ?? "--")"
        mCertificateNumber.text = "\(data["certificate_number"] ?? "--")"

        // Default
        mStoneOne.text = ""
        mStoneOneWeight.text = ""

        mStoneTwo.text = ""
        mStoneTwoWeight.text = ""

        var stones: [[String: Any]] = []

        if let value = data["stoneData"] as? [[String: Any]] {

            stones = value
            print("🔥 SOURCE = stoneData")

        } else if let value = data["Stones"] as? [[String: Any]] {

            stones = value
            print("🔥 SOURCE = Stones")

        } else if let value = data["stones"] as? [[String: Any]] {

            stones = value
            print("🔥 SOURCE = stones")
        }
        
        for case let stone as NSDictionary in data {
            print(
                stone["stone_name"] ?? "",
                "Cts =", stone["Cts"] ?? "",
                "totalStoneWt =", stone["totalStoneWt"] ?? ""
            )
        }

        guard !stones.isEmpty else {

            print("🔥 NO STONE DETAIL ARRAY")

            let stoneName = "\(data["stone_name"] ?? "")"
                .trimmingCharacters(in: .whitespacesAndNewlines)

            
            if !stoneName.isEmpty {
                mStoneOne.text = stoneName
                mStoneOneWeight.text = "\(data["Cts"] ?? "")c"
//                mStoneOneWeight.text = "\(data["totalStoneWt"] ?? data["Cts"] ?? "")c"
            }

            return
        }

        var stoneOrder: [String] = []

        var stoneSummary: [String: (pcs: Int, totalWt: Double)] = [:]

        for stoneData in stones {

            let name =
                (stoneData["stone_name"] as? String) ??
                (stoneData["Stone_name"] as? String) ??
                (stoneData["stone"] as? String) ??
                ""

            let cleanName = name.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

            guard !cleanName.isEmpty else {
                continue
            }

            let pcs = Int("\(stoneData["Pcs"] ?? "0")") ?? 0

//            let totalWt = Double(
//                "\(stoneData["totalStoneWt"] ?? stoneData["Cts"] ?? "0")"
//            ) ?? 0.0
            let totalWt = Double("\(stoneData["Cts"] ?? "0")") ?? 0.0

            if var existing = stoneSummary[cleanName] {

                existing.pcs += pcs
                existing.totalWt += totalWt

                stoneSummary[cleanName] = existing

            } else {

                stoneOrder.append(cleanName)

                stoneSummary[cleanName] = (
                    pcs: pcs,
                    totalWt: totalWt
                )
            }
        }

        print("🔥 STONE ORDER =", stoneOrder)
        print("🔥 STONE SUMMARY =", stoneSummary)

        // Stone 1
        if stoneOrder.indices.contains(0),
           let first = stoneSummary[stoneOrder[0]] {

            mStoneOne.text = stoneOrder[0]

//            mStoneOneWeight.text =
//                "\(first.pcs)                   \(formatCTS(first.totalWt))c"
            mStoneOneWeight.text =
                "\(first.pcs)                   \(String(format: "%.2f", first.totalWt)) c"
        }

        // Stone 2
        if stoneOrder.indices.contains(1),
           let second = stoneSummary[stoneOrder[1]] {

            mStoneTwo.text = stoneOrder[1]

//            mStoneTwoWeight.text =
//                "\(second.pcs)                   \(formatCTS(second.totalWt))c"
            mStoneTwoWeight.text =
                "\(second.pcs)                   \(String(format: "%.2f", second.totalWt)) c"

        } else {

            mStoneTwo.text = ""
            mStoneTwoWeight.text = ""
        }
    }

    func formatCTS(_ value: Double) -> String {

        if value == floor(value) {
            return String(format: "%.0f", value)
        }

        return String(format: "%.2f", value)
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
        
        let urlPath =  mGetInventory
        var params = ["location":mLocation,"filter": mFilterData ,"search":key ] as [String : Any]
        
        if key.trim().isEmpty {
            params["skip"] = mInventorySkip
            params["limit"] = mInventoryFetchLimit
        }
        
        mShowMoreInventory.isHidden = true
        
        if Reachability.isConnectedToNetwork() == true {
            AF.request(urlPath, method:.post,parameters: params ,encoding: JSONEncoding.default, headers: sGisHeaders2).responseJSON
            { response in
                print("CommonInventory mGetInventoryData = \(response)")
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
                        
                        self.mInventoryTotal = jsonResult.value(forKey: "total") as? Int ?? 0
                        
                        if let mData = jsonResult.value(forKey: "data") as? NSArray, mData.count > 0 {
                            
                            if let data = mData[0] as? NSDictionary {
                                print("========== INVENTORY RESPONSE ==========")
                                print(data)

                                print("PriceDetails =", data["PriceDetails"] ?? "nil")
                                print("GrossWt =", data["GrossWt"] ?? "nil")
                                print("NetWt =", data["NetWt"] ?? "nil")
                                print("status =", data["status"] ?? "nil")
                                print("Stones =", data["Stones"] ?? "nil")
                                print("========================================")
                                self.mStoneDataArray = NSMutableArray()
                                self.mStoneDataArray.add(data)
                                
                                print("========== INVENTORY STONES DEBUG ==========")
                                print("INVENTORY STONES data = ", data)
                                print("SKU =", data.value(forKey: "SKU") ?? "")
                                print("stone_name =", data.value(forKey: "stone_name") ?? "nil")
                                print("Cts =", data.value(forKey: "Cts") ?? "nil")
                                print("Stones =", data.value(forKey: "Stones") ?? "nil")
                                print("stones =", data.value(forKey: "stones") ?? "nil")
                                print("============================================")
                                
//                                self.mMaterialName.text = "\(data.value(forKey: "metal_name") ?? "--")"
//                                self.mStoneOne.text = "\(data.value(forKey: "stone_name") ?? "--")"
//                                self.mReferenceName.text = "\(data.value(forKey: "referenceNo") ?? "--")"
//                                self.mMaterialWeight.text = "\(data.value(forKey: "NetWt") ?? "--")"
//                                self.mStoneOneWeight.text = "\(data.value(forKey: "Cts") ?? "--")"
//                                self.mCertificateName.text = "\(data.value(forKey: "certificate_type") ?? "--")"
//                                self.mCertificateNumber.text = "\(data.value(forKey: "certificate_number") ?? "--")"
                                print("========== ALL INVENTORY KEYS ==========")

                                for key in data.allKeys {
                                    print("data KEY =", key)
                                }

                                print("========================================")
                                self.updateProductSummary(data)
                                
                                if let statusType = data.value(forKey: "status_type") as? String {
                                    if statusType == "stock" {
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
                                    
                                } else {
                                    
                                    self.mProductStatus.textColor = #colorLiteral(red: 0.4588235294, green: 0.8, blue: 1, alpha: 1)
                                    self.mStatusDot.backgroundColor = #colorLiteral(red: 0.4588235294, green: 0.8, blue: 1, alpha: 1)
                                    self.mProductStatus.text = "Stock"
                                }
                                
                                self.mInventoryImage.downlaodImageFromUrl(urlString: "\(data.value(forKey: "main_image") ?? "")")
                                
                                self.mStockID.text = "\(data.value(forKey: "stock_id") ?? "")"
                                self.mStockName.text = "\(data.value(forKey: "SKU") ?? "")"
                                self.mMetaTag.text = "\(data.value(forKey: "Matatag") ?? "")"
                                self.mLocationName.text = "\(data.value(forKey: "location_name") ?? "")"
                                self.mMetalName.text = "\(data.value(forKey: "metal_name") ?? "")"
//                                self.mStoneName.text = "\(data.value(forKey: "stone_name") ?? "")"
                                
                                if let productDetails = data["product_details"] as? NSDictionary,
                                   let stones = productDetails["Stones"] as? [[String: Any]],
                                   let firstStone = stones.first {

                                    self.mStoneName.text = "\(firstStone["stone_name"] ?? "--")"

                                } else {

                                    let stoneName = "\(data["stone_name"] ?? "--")"
                                    self.mStoneName.text = stoneName.components(separatedBy: ",").first ?? stoneName
                                }
                                
                                self.mSize.text = "\(data.value(forKey: "size_name") ?? "")"
                                self.mCollectionName.text = "\(data.value(forKey: "collection_name") ?? "")"
                                
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
                                
                                self.mSKUForImage = "\(data.value(forKey: "SKU") ?? "")"
                                self.mProductIdForImage = "\(data.value(forKey: "product_id") ?? "")"
                                
                                
                                self.mMyInventoryTableView.delegate = self
                                self.mMyInventoryTableView.dataSource = self
                                self.mMyInventoryTableView.reloadData()
                                
                                if key.trim().isEmpty {
                                    self.mInventorySkip += 20
                                }else{
                                    self.mInventorySkip = 0
                                }
                            }
                        }else{
                            if self.mInventorySkip == 0 {
                                self.mInventoryData.removeAllObjects()
                                self.mMyInventoryTableView.delegate = self
                                self.mMyInventoryTableView.dataSource = self
                                self.mMyInventoryTableView.reloadData()
                            }
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
                        
                        if let error = jsonResult.value(forKey: "error") as? String{
                            if error == "Authorization has been expired" {
                                CommonClass.sessionExpired(isExpired: true, navigation:self.navigationController)
                            } else {
                                let code = jsonResult.value(forKey: "code") as? Int ?? -1
                                let msg = (code == -1) ? "OOP's something went wrong!" : "Error \(code): \(error)"
                                CommonClass.showSnackBar(message: msg)
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
            
            if self.mInventorySkip < self.mInventoryTotal{
                mShowMoreInventory.isHidden = false
            }
        }else{
            mShowMoreInventory.isHidden = true
        }
    }
}
