//
//  ReserveCart.swift
//  GIS
//
//  Created by MacBook Hawkscode  on 07/04/23.
//  Copyright © 2023 Hawkscode. All rights reserved.
//

import UIKit
import Alamofire
import DropDown

class ReserveCart : UIViewController, UIViewControllerTransitioningDelegate ,GetCustomerDataDelegate , UITableViewDataSource, SearchDelegate ,UITableViewDelegate, GetInventoryDataItemsDelegate , DeleteCustomCartItems, UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var mPickerView: UIView!
    @IBOutlet weak var mSearchField: UITextField!

    @IBOutlet weak var mTotalItems: UILabel!
    @IBOutlet weak var mGrandTotal: UILabel!
    @IBOutlet weak var mDepositAmount: UILabel!
    @IBOutlet weak var mOutstandingAmount: UILabel!
    @IBOutlet weak var mSelectedCustomerIcon: UIImageView!
    var mCustomerId = ""
    
    @IBOutlet weak var mNotes: UITextField!
    
    var mDepositPercentData = ["25%","50%","75%","100%"]
    var mDepositPercentValue = ["25","50","75","100"]
    var mCurrency = ""

    var mGrandTotalCart = "0.00"
    @IBOutlet weak var mDepositePercent: UILabel!
    var mDepositPercents = "100"
    var mGrandTotalAmounts = "0.00"
    var mTotalDepositAmounts = "0.00"
    var mOutStandingAmounts = "0.00"
    @IBOutlet weak var mCartTable: UITableView!
    var mCartData = NSMutableArray()
    var mCartDataMaster = NSArray()
    private var linkedCartContext: LinkedCartContext?

    // MARK: - Reserve Note Suggestions
    private var reserveSuggestionsView: UIView?
    private var reserveSuggestionsButtons: [UIButton] = []
    private var reserveVisibleSuggestions: [String] = []
    private var reserveSuggestionSessionActive = false
    private var reserveDismissTapGesture: UITapGestureRecognizer?


    var mQuantityData = [Int]()
    var mCartAmount = [Double]()

    var mCurrentIndex = -1
    let mDatePicker:UIDatePicker = UIDatePicker()
    var isItemsAvailable =  false
    var isDeleted = false
    
    
    @IBOutlet weak var mNoteLABEL: UILabel!
    @IBOutlet weak var mHeading: UILabel!
    
    @IBOutlet weak var mCheckoutButton: UIButton!
    @IBOutlet weak var mOutstandingBalanceLABEL: UILabel!
    @IBOutlet weak var mDepositLABEL: UILabel!
    @IBOutlet weak var mGrandTotalLABEL: UILabel!
    
    @IBOutlet weak var mDiamondLABEL: UILabel!
    @IBOutlet weak var mJewelryLABEL: UILabel!
    
    @IBOutlet weak var mCustomerLABEL: UILabel!
    @IBOutlet weak var mBottomInventoryLABEL: UILabel!
    @IBOutlet weak var mBottomReserveLABEL: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")

        self.mNotes.keyboardType = .default
        self.mNotes.delegate = self
        self.mNotes.clearButtonMode = .whileEditing
        self.mNotes.addTarget(self, action: #selector(reserveNoteEditingChanged(_:)), for: .editingChanged)
        setupReserveNoteSuggestions()
        setupReserveKeyboardDismissGesture()
        hideReserveSuggestions()
        
        mPickerView.layer.cornerRadius = 10
        mPickerView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        mPickerView.dropShadow()
        
        self.mCartTable.delegate = self
        self.mCartTable.dataSource = self
        self.mCartTable.reloadData()
        
        mCustomerId  = UserDefaults.standard.string( forKey: "DEFAULTCUSTOMER") ?? ""


    }
    
     
    @IBAction func mOpenProductStoneDetails(_ sender: UIButton) {
        _ = sender.tag
    }
    
    

    override func viewWillAppear(_ animated: Bool) {
        
        mSearchField.placeholder = "Search by SKU/Stock ID".localizedString
        mNoteLABEL.text = "Note".localizedString
        mNotes.placeholder = "EX. Urgent Order".localizedString
        mHeading.text = "Reserve".localizedString
        mCheckoutButton.setTitle("CHECK OUT".localizedString, for: .normal)
        mOutstandingBalanceLABEL.text = "Outstanding Balance".localizedString
        mDepositLABEL.text = "Deposit".localizedString
        mGrandTotalLABEL.text = "Grand Total".localizedString
        mDiamondLABEL.text = "Diamond".localizedString
        mJewelryLABEL.text = "Jewelry".localizedString
        mCustomerLABEL.text = "Customer".localizedString
        mBottomInventoryLABEL.text = "Inventory".localizedString
        mBottomReserveLABEL.text = "Reserve".localizedString
        
        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
        
        mGrandTotal.text = "\(UserDefaults.standard.value(forKey: "currencySymbol") ?? "$") 0.00"
        mDepositAmount.text = mGrandTotal.text
        mOutstandingAmount.text = mGrandTotal.text
        
        mGetData(url: mFetchPaymentMethod,headers: sGisHeaders,  params: ["":""]) { response , status in
            if status {
                if let mData = response.value(forKey: "data") as? NSDictionary {
                    
                    //Store Cash Data
                    if let mCashData = mData.value(forKey: "Cash") as? NSArray {
                        if mCashData.count > 0 {
                            if let mData = mCashData[0] as? NSDictionary {
                                UserDefaults.standard.set(mData, forKey: "CASHDATA")
                            }
                        }
                    }
                    
                    //Store Credit Card Data
                    if let mCreditCard = mData.value(forKey: "Credit_Card") as? NSArray {
                        if mCreditCard.count > 0 {
                            UserDefaults.standard.set(mCreditCard, forKey: "CREDITCARDDATA")
                        }else{UserDefaults.standard.set(nil, forKey: "CREDITCARDDATA")}
                    }else{UserDefaults.standard.set(nil, forKey: "CREDITCARDDATA")}
                  
                    //Store Bank Data
                    if let mBankData = mData.value(forKey: "Bank") as? NSArray {
                        if mBankData.count > 0 {
                            UserDefaults.standard.set(mBankData, forKey: "BANKDATA")
                        }else{UserDefaults.standard.set(nil, forKey: "BANKDATA")}
                    }else{UserDefaults.standard.set(nil, forKey: "BANKDATA")}

                    
                }
            }
        }

        if let cRemark = UserDefaults.standard.string(forKey: "cRemark") {
            self.mNotes.text = cRemark
        }
        if mCustomerId == "" {
            mOpenCustomerSheet()
        }
        
        mCustomerId = UserDefaults.standard.string( forKey: "DEFAULTCUSTOMER") ?? ""
        if !mCustomerId.isEmpty {
            self.mSelectedCustomerIcon.image = UIImage(named: "selected_customer")
            mFetchCartItems()
        }
        
    }
    
    @IBAction func mSearchCart(_ sender: Any) {
    }
    
    
    @IBAction func mOpenCustomer(_ sender: Any) {
      
         mOpenCustomerSheet()
    }
    
    @IBAction func mBack(_ sender: Any) {
        UserDefaults.standard.setValue(nil, forKey: "cRemark")

        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func mPickJewelry(_ sender: Any) {
        self.mPickerView.isHidden = true
        if mCustomerId == "" {
            CommonClass.showSnackBar(message: "Please choose customer first!")
            mOpenCustomerSheet()
            return
        }
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "common", bundle: nil)
        if let mInv = storyBoard.instantiateViewController(withIdentifier: "CommonInventory") as? CommonInventory {
            mInv.modalPresentationStyle = .overFullScreen
            mInv.mOrderType = "reserve"
            mInv.delegate =  self
            mInv.mCustomerId = mCustomerId
            mInv.transitioningDelegate = self
            self.present(mInv,animated: true)
        }
    }

    @IBAction func mPickDiamond(_ sender: Any) {
        self.mPickerView.isHidden = true
        if mCustomerId == "" {
            CommonClass.showSnackBar(message: "Please choose customer first!")
            mOpenCustomerSheet()
            return
        }
        UserDefaults.standard.set("reserve", forKey: "pickDiamond")
        let storyBoard: UIStoryboard = UIStoryboard(name: "diamondModule", bundle: nil)
        if let home = storyBoard.instantiateViewController(withIdentifier: "DiamondFilters") as? DiamondFilters {
            self.navigationController?.pushViewController(home, animated:true)
        }
    }
    @IBAction func mCatalog(_ sender: Any) {
        
        if UserDefaults.standard.bool(forKey: "isMixMatch") {
                self.mPickerView.isHidden = true
                let storyBoard: UIStoryboard = UIStoryboard(name: "reserveOrderBoard", bundle: nil)
                if let mReservedJewelryDiamondItems = storyBoard.instantiateViewController(withIdentifier: "ReservedJewelryDiamondItems") as? ReservedJewelryDiamondItems {
                    self.navigationController?.pushViewController(mReservedJewelryDiamondItems, animated:true)
                }
            } else {
             
             let storyBoard: UIStoryboard = UIStoryboard(name: "reserveOrderBoard", bundle: nil)
                if let mInventoryReserved = storyBoard.instantiateViewController(withIdentifier: "InventoryReserved") as? InventoryReserved {
                    self.navigationController?.pushViewController(mInventoryReserved, animated:true)
                }
        }
        
    }
    
    func mGetInventoryItems(items: [String]) {
        print("DEBUG_GET_INVENTORY_ITEMS")
        print("DEBUG_ITEMS =", items)
        self.linkedCartContext = LinkedCartContextStore.shared.context(
            orderType: "reserve",
            customerId: mCustomerId
        )
        mFetchCartItems()
    }
    
    
  
    func mFetchCartItems(){
        let mParams = [ "customer_id":mCustomerId ,"type": "reserve"] as [String : Any]
        print("mFetchCartItems mParams = \(mParams)")
        print("mFetchCartItems mFetchCustomProduct = \(mFetchCustomProduct)")
        mGetData(url: mFetchCustomProduct,headers: sGisHeaders, params: mParams) { response , status in
            CommonClass.stopLoader()
            print("DEBUG_GET_CART_ITEMS response = ", response)
            if status {
            if "\(response.value(forKey: "code") ?? "")" == "200" {
                if let mData = response.value(forKey: "data") as? NSArray {
                    print("DEBUG_GET_CART_ITEMS =", mData)

                    if mData.count > 0 {
                        self.mCartDataMaster = mData
                        self.mCartData = NSMutableArray(array: mData)
                        self.mCartTable.delegate = self
                        self.mCartTable.dataSource = self
                        self.mQuantityData = [Int]()
                        self.mCartAmount = [Double]()
                        self.mCartTable.reloadData()

                        for i in self.mCartData {
                            if let mData = i as? NSDictionary {
                                self.mQuantityData.append(Int("\(mData.value(forKey: "Qty") ?? "0")") ?? 0)
                                self.mCartAmount.append(Double("\(mData.value(forKey: "price") ?? "0")") ?? 0.0)
                            }
                        }
                        
                    }else{
                        
                        
                    }
                }
                
                
            }else{
          
            }
        }
    }
    }
    
    func uniqueElementsFrom(array:[String]) -> [String] {
        
        var set = Set<String>()
        
        let result = array.filter {
            guard !set.contains($0)  else {
                return  false
            }
            set.insert($0)
            return true
        }
        
        return result
    }
    @IBAction func mInventory(_ sender: Any) {
        
        if UserDefaults.standard.bool(forKey: "isMixMatch") {
            
            self.mPickerView.isHidden = false
            
        }else{
            
            if mCustomerId == "" {
                CommonClass.showSnackBar(message: "Please choose customer first!")
                mOpenCustomerSheet()
                return
            }
            
            let storyBoard: UIStoryboard = UIStoryboard(name: "common", bundle: nil)
            if let mInv = storyBoard.instantiateViewController(withIdentifier: "CommonInventory") as? CommonInventory {
                mInv.modalPresentationStyle = .overFullScreen
                mInv.mOrderType = "reserve"
                mInv.delegate =  self
                mInv.mCustomerId = mCustomerId
                mInv.transitioningDelegate = self
                self.present(mInv,animated: true)
            }
        }
        
    }
    
    @IBAction func mCustomer(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "reserveBoard", bundle: nil)
        if let home = storyBoard.instantiateViewController(withIdentifier: "CustomerSearch") as? CustomerSearch {
            self.navigationController?.pushViewController(home, animated:true)
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
        self.mSelectedCustomerIcon.image = UIImage(named: "selected_customer")
        mFetchCartItems()

    }
    
    func mOpenCustomerSheet(){
        let storyBoard: UIStoryboard = UIStoryboard(name: "common", bundle: nil)
        if let home = storyBoard.instantiateViewController(withIdentifier: "CustomerPicker") as? CustomerPicker {
            home.delegate = self
            home.modalPresentationStyle = .automatic
            home.transitioningDelegate = self
            self.present(home,animated: true)
        }
    }
    
    @IBAction func mDepositeDropdown(_ sender: Any) {
        let dropdown = DropDown()
               dropdown.anchorView = self.mDepositePercent
               dropdown.direction = .any
               dropdown.bottomOffset = CGPoint(x: 0, y: self.mDepositePercent.frame.size.height)
               dropdown.width = 120
               dropdown.dataSource = mDepositPercentData
               dropdown.selectionAction = {
               [unowned self](index:Int, item: String) in
               self.mDepositePercent.text  = item
                self.mDepositPercents = self.mDepositPercentValue[index]
                   if self.mCartData.count > 0{
                   self.calculateItemsWithAmount()
                   }
                    
              }
               dropdown.show()
    }
    
//    func mGetSearchItems(id: String)
//    func mGetSearchItems(id: String, locationId: String){
    func mGetSearchItems(id: String, locationId: String, type: String) {
        var mParams = [String : Any]()
            mParams = ["product_id":[id], "customer_id":mCustomerId, "sales_person_id":"", "type":"inventory", "order_type":"reserve"]
        print("DEBUG_GET_SEARCH_ITEM_ID =", id)
        if !locationId.isEmpty {

            mParams["crossLocationId"] = locationId
            mParams["crosslocation"] = true
        }
        print("DEBUG_ADD_TO_CART_PARAMS =", mParams)
        mGetData(url: mAddCustomProduct,headers: sGisHeaders,  params: mParams) { response , status in
            CommonClass.stopLoader()
            if status {
                if "\(response.value(forKey: "code") ?? "")" == "200" {
                    
                    self.mFetchCartItems()
                    
                }else{
                    
                }
            }
        }
    }
    
    @IBAction func mSearchNow(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Test", bundle: nil)
        if let mCommonSearch = storyBoard.instantiateViewController(withIdentifier: "CommonSearch") as? CommonSearch {
            mCommonSearch.modalPresentationStyle = .overFullScreen
            mCommonSearch.delegate = self
            mCommonSearch.mType = "inventory"
            mCommonSearch.mFrom = "pos"
            
            mCommonSearch.transitioningDelegate = self
            self.present(mCommonSearch,animated: false)
        }
    }
    
    @IBAction func mCheckOut(_ sender: UIButton) {
            sender.showAnimation{
                if self.mCartData.count == 0 {
                    CommonClass.showSnackBar(message: "No items in cart!")
                    return
                }
                
                if Double(self.mGrandTotalCart) ?? 0.00 == 0.0 {
                    CommonClass.showSnackBar(message: "Please fill valid amount!")
                    return
                }
                
                // ✨ แนบ Quotation ID ลง UserDefaults ✨
                UserDefaults.standard.setValue("", forKey: "quotationId")
                print("ReserveCart mQuotationId: ")
                
                
                
                let storyBoard: UIStoryboard = UIStoryboard(name: "customOrder", bundle: nil)
                if let mCheckOut = storyBoard.instantiateViewController(withIdentifier: "CustomOrderCheckout") as? CustomOrderCheckout {
                    mCheckOut.mTotalP = self.mTotalDepositAmounts
                    mCheckOut.mSubTotalP = ""
                    mCheckOut.mTaxP = ""
                    mCheckOut.mTaxAm = ""
                    mCheckOut.mStoreCurrency =  self.mCurrency
                    mCheckOut.mOrderType = "reserve"
                    mCheckOut.mNote = self.mNotes.text ?? ""
                    mCheckOut.mRemark = UserDefaults.standard.string(forKey: "cRemark") ?? ""
//                    mCheckOut.mRemark = self.mNotes.text ?? ""
                    mCheckOut.mTaxType =  ""
                    mCheckOut.mTaxLabel =  ""
                    mCheckOut.mTotalOutstandingAm = self.mOutStandingAmounts
                    mCheckOut.mCurrencySymbol = self.mCurrency
                    mCheckOut.mCartTotalAmount = self.mGrandTotalCart
                    mCheckOut.mDepositPercents = self.mDepositPercents
                    mCheckOut.mTotalWithDiscount =  self.mTotalDepositAmounts
                    mCheckOut.mTaxPercent =  ""
                    mCheckOut.mCustomerId = self.mCustomerId
                    mCheckOut.mCartTableData =  self.mCartData
                    mCheckOut.applyLinkedCartContext(self.linkedCartContext)
                    print("DEBUG_CART_DATA =", self.mCartData)
                    print("🔥 SAVE CUSTOM ORDER TYPE =", mCheckOut.mOrderType)
                    print("🔥 SAVE CUSTOM ORDER PAYLOAD =", mCheckOut.mFinalPaymentMethod)
                    self.navigationController?.pushViewController( mCheckOut, animated:true)
                }
            }
        }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mCartData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCartItems") as? CustomCartItems else {
            return UITableViewCell()
        }
        
        cell.mSNo.text = "\(indexPath.row + 1)"
        cell.mOpenProductDetailsButton.tag = indexPath.row
        cell.mRemoveButton.tag = indexPath.row
        cell.mProductPrice.tag = indexPath.row
        cell.mPlusButton.tag = indexPath.row
        cell.mMinusButton.tag = indexPath.row
        cell.mChooseDateButton.tag = indexPath.row

        if let mData = mCartData[indexPath.row] as? NSDictionary {
            
//            cell.mDueDate.text = "\(mData.value(forKey: "delivery_date") ?? "--")"
            
            let dateString = "\(mData.value(forKey: "delivery_date") ?? "")"

            let input = ISO8601DateFormatter()
            input.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

            let output = DateFormatter()
            output.locale = Locale(identifier: "en_US_POSIX")
            output.calendar = Calendar(identifier: .gregorian)
            output.dateFormat = "dd/MM/yyyy"

            if let date = input.date(from: dateString) {
                cell.mDueDate.text = output.string(from: date)
            } else {
                cell.mDueDate.text = dateString
            }
            cell.mCurrency.text = "\(mData.value(forKey: "currency") ?? "$")"
            self.mCurrency = "\(mData.value(forKey: "currency") ?? "$") "
            
            cell.mSKUName.text = "\(mData.value(forKey: "SKU") ?? "")"
            cell.mProductName.text = "\(mData.value(forKey: "name") ?? "")"
            cell.mMetalColorSize.text = "\(mData.value(forKey: "color_name") ?? "") " + "\(mData.value(forKey: "metal_name") ?? "") " + "\(mData.value(forKey: "size_name") ?? "")"
//            cell.mProductPrice.text = "\(mData.value(forKey: "price") ?? "")"
            let price = PriceHelper.parsePrice("\(mData.value(forKey: "price") ?? "0")")
            cell.mProductPrice.text = PriceHelper.formatPrice(
                price,
                currency: self.mCurrency
            )
            cell.mStockId.text = "\(mData.value(forKey: "stock_id") ?? "")"
            if let image = mData.value(forKey: "main_image") as? String {
                cell.mProductImage.downlaodImageFromUrl(urlString: image)
            }
            calculateItemsWithAmount()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 156
    }
    
    
    @IBAction func mMinusButton(_ sender: UIButton) {
     
        let index = sender.tag
        if let mInvData = mCartData[index] as? NSDictionary,
           let cells = mCartTable.cellForRow(at: IndexPath(row: sender.tag , section: 0)) as? CustomCartItems {
            _ = mCartDataMaster[sender.tag] as? NSDictionary
            let mMinQty = 1
            var mCurrentQty = Int(cells.mQuantityUnit.text ?? "0") ?? 0
            if  mCurrentQty == mMinQty {
                return
            }else{
                mCurrentQty = mCurrentQty - 1
                if  mCurrentQty == 1 {
                    cells.mQuantityUnit.text = "\(mMinQty)"
//                    cells.mProductPrice.text = "\((Double("\(mInvData.value(forKey: "price") ?? "0")") ?? 0.0) - (self.mCartAmount[sender.tag]))"
                    let price = (Double("\(mInvData.value(forKey: "price") ?? "0")") ?? 0.0) - (self.mCartAmount[sender.tag])
                    cells.mProductPrice.text = PriceHelper.formatPrice(
                        price,
                        currency: self.mCurrency
                    )
                }else{
                    cells.mQuantityUnit.text = "\(mCurrentQty)"
                    
//                    cells.mProductPrice.text = "\((Double("\(mInvData.value(forKey: "price") ?? "0")") ?? 0.0) - (self.mCartAmount[sender.tag]))"
                    let price = (Double("\(mInvData.value(forKey: "price") ?? "0")") ?? 0.0) - (self.mCartAmount[sender.tag])
                    cells.mProductPrice.text = PriceHelper.formatPrice(
                        price,
                        currency: self.mCurrency
                    )
                }
                
            }
        
            let mData = NSMutableDictionary()
            mData.setValue("\(mInvData.value(forKey: "id") ?? "")", forKey: "id")
            mData.setValue("\(cells.mQuantityUnit.text ?? "")", forKey: "Qty")
            mData.setValue("\(mInvData.value(forKey: "type") ?? "")", forKey: "type")
            mData.setValue("\(mInvData.value(forKey: "SKU") ?? "")", forKey: "SKU")
            mData.setValue("\(mInvData.value(forKey: "stock_id") ?? "")", forKey: "stock_id")
            mData.setValue("\(cells.mProductPrice.text ?? "")", forKey: "price")
            mData.setValue("\(mInvData.value(forKey: "name") ?? "")", forKey: "name")
//            mData.setValue("\(mInvData.value(forKey: "po_QTY") ?? "1")", forKey: "po_QTY")
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
            mData.setValue("\(mInvData.value(forKey: "main_image") ?? "")", forKey: "main_image")
            mData.setValue("\(mInvData.value(forKey: "size_name") ?? "")", forKey: "size_name")
            mData.setValue("\(mInvData.value(forKey: "metal_name") ?? "")", forKey: "metal_name")
            mData.setValue("\(mInvData.value(forKey: "stone_name") ?? "")", forKey: "stone_name")
            mData.setValue("\(mInvData.value(forKey: "collection_name") ?? "")", forKey: "collection_name")
            mData.setValue("\(mInvData.value(forKey: "location_name") ?? "")", forKey: "location_name")
            mData.setValue("\(mInvData.value(forKey: "custom_cart_id") ?? "")", forKey: "custom_cart_id")
            mData.setValue("\(mInvData.value(forKey: "remark") ?? "")", forKey: "remark")
            mData.setValue("\(mInvData.value(forKey: "currency") ?? "")", forKey: "currency")
            mData.setValue("\(mInvData.value(forKey: "delivery_date") ?? "")", forKey: "delivery_date")
            mData.setValue(mInvData.value(forKey: "Custom_design_status") ?? false, forKey: "Custom_design_status")
            
            mCartData.removeObject(at: index)
            mCartData.insert(mData, at: index)
            mCartTable.reloadData()
            calculateItemsWithAmount()
        }
    }
    
    
    @IBAction func mPlusButton(_ sender: UIButton) {
        let index = sender.tag
        
        _ = mCartDataMaster[sender.tag] as? NSDictionary
        if let mInvData = mCartData[index] as? NSDictionary,
           let cells = mCartTable.cellForRow(at: IndexPath(row: sender.tag , section: 0)) as? CustomCartItems {
            let mMaxQty =  Int("\(mInvData.value(forKey: "po_QTY") ?? "1")") ?? 1
            var mCurrentQty = Int(cells.mQuantityUnit.text ?? "0") ?? 0
            if mCurrentQty == mMaxQty {
                return
            }
            mCurrentQty = mCurrentQty + 1
            cells.mQuantityUnit.text = "\(mCurrentQty)"
            
//            cells.mProductPrice.text = "\((Double("\(mInvData.value(forKey: "price") ?? "0")") ?? 0.0) + (self.mCartAmount[sender.tag]) )"
            
            let price = (Double("\(mInvData.value(forKey: "price") ?? "0")") ?? 0.0) - (self.mCartAmount[sender.tag])
            cells.mProductPrice.text = PriceHelper.formatPrice(
                price,
                currency: self.mCurrency
            )
            
            let mData = NSMutableDictionary()
            mData.setValue("\(mInvData.value(forKey: "id") ?? "")", forKey: "id")
            mData.setValue("\(mInvData.value(forKey: "type") ?? "")", forKey: "type")
            mData.setValue("\(cells.mQuantityUnit.text ?? "")", forKey: "Qty")
            mData.setValue("\(mInvData.value(forKey: "SKU") ?? "")", forKey: "SKU")
            mData.setValue("\(mInvData.value(forKey: "stock_id") ?? "")", forKey: "stock_id")
            mData.setValue("\(cells.mProductPrice.text ?? "")", forKey: "price")
            mData.setValue("\(mInvData.value(forKey: "name") ?? "")", forKey: "name")
//            mData.setValue("\(mInvData.value(forKey: "po_QTY") ?? "1")", forKey: "po_QTY")
            if let productDetails = mInvData["product_details"] as? NSDictionary {

                mData.setValue(
                    "\(productDetails["po_QTY"] ?? "1")",
                    forKey: "po_QTY"
                )

            } else {

                mData.setValue(
                    "\(mInvData["po_QTY"] ?? "1")",
                    forKey: "po_QTY"
                )
            }
            mData.setValue("\(mInvData.value(forKey: "main_image") ?? "")", forKey: "main_image")
            mData.setValue("\(mInvData.value(forKey: "size_name") ?? "")", forKey: "size_name")
            mData.setValue("\(mInvData.value(forKey: "metal_name") ?? "")", forKey: "metal_name")
            mData.setValue("\(mInvData.value(forKey: "stone_name") ?? "")", forKey: "stone_name")
            mData.setValue("\(mInvData.value(forKey: "collection_name") ?? "")", forKey: "collection_name")
            mData.setValue("\(mInvData.value(forKey: "location_name") ?? "")", forKey: "location_name")
            mData.setValue("\(mInvData.value(forKey: "custom_cart_id") ?? "")", forKey: "custom_cart_id")
            mData.setValue("\(mInvData.value(forKey: "remark") ?? "")", forKey: "remark")
            
            mData.setValue("\(mInvData.value(forKey: "currency") ?? "")", forKey: "currency")
            mData.setValue("\(mInvData.value(forKey: "delivery_date") ?? "")", forKey: "delivery_date")
            mData.setValue(mInvData.value(forKey: "Custom_design_status") ?? false, forKey: "Custom_design_status")
            
            mCartData.removeObject(at: index)
            mCartData.insert(mData, at: index)
            mCartTable.reloadData()
            
            calculateItemsWithAmount()
        }
    }

    @IBAction func mChooseDate(_ sender: UIButton) {
        if let cells = mCartTable.cellForRow(
            at: IndexPath(row: sender.tag, section: 0)
        ) as? CustomCartItems {

            mCurrentIndex = sender.tag

            let currentDate = Date()

            var calendar = Calendar(identifier: .gregorian)
            calendar.locale = Locale(identifier: "en_US_POSIX")

            // สำคัญ
            mDatePicker.calendar = calendar
            mDatePicker.locale = Locale(identifier: "en_US_POSIX")
            mDatePicker.timeZone = TimeZone.current

            mDatePicker.preferredDatePickerStyle = .wheels
            mDatePicker.datePickerMode = .date

            mDatePicker.minimumDate = currentDate

            var dateComponents = DateComponents()
            dateComponents.year = 5

            mDatePicker.maximumDate = calendar.date(
                byAdding: dateComponents,
                to: currentDate
            )

            mDatePicker.backgroundColor = .white

            let mToolBar = UIToolbar()
            mToolBar.sizeToFit()
            mToolBar.backgroundColor = .white
            mToolBar.barTintColor = .white

            let mDone = UIBarButtonItem(
                title: "Done",
                style: .plain,
                target: self,
                action: #selector(doneDatePick)
            )

            let mSpace = UIBarButtonItem(
                barButtonSystemItem: .flexibleSpace,
                target: nil,
                action: nil
            )

            let mCancel = UIBarButtonItem(
                title: "Cancel",
                style: .plain,
                target: self,
                action: #selector(mCancelDatePick)
            )

            mToolBar.setItems(
                [mCancel, mSpace, mDone],
                animated: false
            )

            cells.mDueDate.inputAccessoryView = mToolBar
            cells.mDueDate.inputView = mDatePicker
            cells.mDueDate.becomeFirstResponder()
        }
    }
    
    @objc
    func doneDatePick() {

        // -----------------------------
        // UI Date (dd/MM/yyyy)
        // -----------------------------
        let uiFormatter = DateFormatter()
        uiFormatter.locale = Locale(identifier: "en_US_POSIX")
        uiFormatter.calendar = Calendar(identifier: .gregorian)
        uiFormatter.dateFormat = "dd/MM/yyyy"

        let displayDate = uiFormatter.string(from: mDatePicker.date)

        // -----------------------------
        // API Date (ISO8601)
        // -----------------------------
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds
        ]

        let apiDate = isoFormatter.string(from: mDatePicker.date)

        print("🔥 RESERVE PICKER DATE =", mDatePicker.date)
        print("🔥 RESERVE DISPLAY DATE =", displayDate)
        print("🔥 RESERVE API DATE =", apiDate)

        if let cell = mCartTable.cellForRow(
            at: IndexPath(row: mCurrentIndex, section: 0)
        ) as? CustomCartItems {

            // แสดงบนหน้าจอ
            cell.mDueDate.text = displayDate

            if let mInvData = mCartData[mCurrentIndex] as? NSDictionary {

                let mData = NSMutableDictionary()

                mData.setValue("\(mInvData.value(forKey: "id") ?? "")", forKey: "id")
                mData.setValue("\(mInvData.value(forKey: "type") ?? "")", forKey: "type")
                mData.setValue("\(mInvData.value(forKey: "Qty") ?? "")", forKey: "Qty")
                mData.setValue("\(mInvData.value(forKey: "SKU") ?? "")", forKey: "SKU")
                mData.setValue("\(mInvData.value(forKey: "stock_id") ?? "")", forKey: "stock_id")
                mData.setValue("\(mInvData.value(forKey: "price") ?? "")", forKey: "price")
                mData.setValue("\(mInvData.value(forKey: "name") ?? "")", forKey: "name")

                if let productDetails = mInvData["product_details"] as? NSDictionary {

                    mData.setValue(
                        "\(productDetails["po_QTY"] ?? "1")",
                        forKey: "po_QTY"
                    )

                } else {

                    mData.setValue(
                        "\(mInvData["po_QTY"] ?? "1")",
                        forKey: "po_QTY"
                    )
                }

                mData.setValue("\(mInvData.value(forKey: "main_image") ?? "")", forKey: "main_image")
                mData.setValue("\(mInvData.value(forKey: "size_name") ?? "")", forKey: "size_name")
                mData.setValue("\(mInvData.value(forKey: "metal_name") ?? "")", forKey: "metal_name")
                mData.setValue("\(mInvData.value(forKey: "stone_name") ?? "")", forKey: "stone_name")
                mData.setValue("\(mInvData.value(forKey: "collection_name") ?? "")", forKey: "collection_name")
                mData.setValue("\(mInvData.value(forKey: "location_name") ?? "")", forKey: "location_name")
                mData.setValue("\(mInvData.value(forKey: "custom_cart_id") ?? "")", forKey: "custom_cart_id")
                mData.setValue("\(mInvData.value(forKey: "remark") ?? "")", forKey: "remark")
                mData.setValue("\(mInvData.value(forKey: "currency") ?? "")", forKey: "currency")

                // ✅ เก็บ ISO ลง Model
                mData.setValue(apiDate, forKey: "delivery_date")

                mData.setValue(
                    mInvData.value(forKey: "Custom_design_status") ?? false,
                    forKey: "Custom_design_status"
                )

                mCartData.replaceObject(at: mCurrentIndex, with: mData)

                print("========== mCartData AFTER PICK ==========")
                print(mCartData)
                print("==========================================")
            }
        }

        self.view.endEditing(true)
    }
    
    @objc func mCancelDatePick(){
        self.view.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {

            if let mData = mCartData[indexPath.row] as? NSDictionary {
                CommonClass.showFullLoader(view: self.view)
                let mParams = [ "customer_id":mCustomerId , "custom_cart_id":mData.value(forKey: "custom_cart_id") as? String ?? ""] as [String : Any]
                
                
                mGetData(url: mDeleteCartItem,headers: sGisHeaders,  params: mParams) { response , status in
                    CommonClass.stopLoader()
                    if status {
                        if "\(response.value(forKey: "code") ?? "")" == "200" {
                            CommonClass.stopLoader()
                            self.mDeleteRow(index: indexPath.row)
                        }else{
                            
                        }
                    }
                }
                
            }
        }
    }
    
    func mDeleteRow(index : Int)
    {
        self.mCartData.removeObject(at: index)
        self.mCartTable.reloadData()
        calculateItemsWithAmount()

    }
    func mDeleteCartItems(index: Int) {
        self.mCartData.removeObject(at: index)
        self.mCartTable.reloadData()
        calculateItemsWithAmount()

    }
    
    @IBAction func mRemoveCartItems(_ sender: UIButton) {
        
        if let mData = mCartData[sender.tag] as? NSDictionary {
            mRemovePopUp.frame = self.view.bounds
            mRemovePopUp.mCustomerId = mCustomerId
            mRemovePopUp.delegate = self
            mRemovePopUp.index = sender.tag
            mRemovePopUp.mType = ""
            mRemovePopUp.mCartId = mData.value(forKey: "custom_cart_id") as? String ?? ""
            mRemovePopUp.mMessage.text = "Are you sure want to remove ?".localizedString
            mRemovePopUp.mCancelButton.setTitle("CANCEL".localizedString, for: .normal)
            mRemovePopUp.mConfirmButton.setTitle("CONFIRM".localizedString, for: .normal)
            self.view.addSubview(mRemovePopUp)
        }
    }

    @IBAction func mEditAmount(_ sender: UITextField) {
        guard let mInvData = mCartData[sender.tag] as? NSDictionary,
              let mOrgData = mCartDataMaster[sender.tag] as? NSDictionary,
              let cells = mCartTable.cellForRow(at: IndexPath(row: sender.tag , section: 0)) as? CustomCartItems else {
            return
        }
 
        cells.mQuantityUnit.text = "1"

        if sender.text == "" || sender.text == "0" {
            cells.mProductPrice.text = ""
            let mData = NSMutableDictionary()
            mData.setValue("0", forKey: "price")
            self.mCartAmount.remove(at: sender.tag)
            self.mCartAmount.insert(0.0, at: sender.tag)
            mData.setValue("\(mInvData.value(forKey: "id") ?? "")", forKey: "id")
            mData.setValue("\(mInvData.value(forKey: "type") ?? "")", forKey: "type")
            mData.setValue("\(mInvData.value(forKey: "Qty") ?? "")", forKey: "Qty")
            mData.setValue("\(mInvData.value(forKey: "SKU") ?? "")", forKey: "SKU")
            mData.setValue("\(mInvData.value(forKey: "stock_id") ?? "")", forKey: "stock_id")
            mData.setValue("\(mInvData.value(forKey: "name") ?? "")", forKey: "name")
//            mData.setValue("\(mInvData.value(forKey: "po_QTY") ?? "1")", forKey: "po_QTY")
            if let productDetails = mInvData["product_details"] as? NSDictionary {

                mData.setValue(
                    "\(productDetails["po_QTY"] ?? "1")",
                    forKey: "po_QTY"
                )

            } else {

                mData.setValue(
                    "\(mInvData["po_QTY"] ?? "1")",
                    forKey: "po_QTY"
                )
            }
            mData.setValue("\(mInvData.value(forKey: "main_image") ?? "")", forKey: "main_image")
            mData.setValue("\(mInvData.value(forKey: "size_name") ?? "")", forKey: "size_name")
            mData.setValue("\(mInvData.value(forKey: "metal_name") ?? "")", forKey: "metal_name")
            mData.setValue("\(mInvData.value(forKey: "stone_name") ?? "")", forKey: "stone_name")
            mData.setValue("\(mInvData.value(forKey: "collection_name") ?? "")", forKey: "collection_name")
            mData.setValue("\(mInvData.value(forKey: "location_name") ?? "")", forKey: "location_name")
            mData.setValue("\(mInvData.value(forKey: "custom_cart_id") ?? "")", forKey: "custom_cart_id")
            mData.setValue("\(mInvData.value(forKey: "remark") ?? "")", forKey: "remark")
            mData.setValue("\(mInvData.value(forKey: "currency") ?? "")", forKey: "currency")
            mData.setValue("\(mInvData.value(forKey: "delivery_date") ?? "")", forKey: "delivery_date")
            mData.setValue(mInvData.value(forKey: "Custom_design_status") ?? false, forKey: "Custom_design_status")
            mCartData.removeObject(at: sender.tag)
            mCartData.insert(mData, at: sender.tag)
            calculateItemsWithAmount()
            return
        }
        
        let mData = NSMutableDictionary()
        self.mCartAmount.remove(at: sender.tag)
        self.mCartAmount.insert(Double("\(cells.mProductPrice.text ?? "")") ?? 0.0, at: sender.tag)
        mData.setValue(cells.mProductPrice.text ?? "", forKey: "price")
        mData.setValue("\(mInvData.value(forKey: "id") ?? "")", forKey: "id")
        mData.setValue("\(mInvData.value(forKey: "type") ?? "")", forKey: "type")
        mData.setValue("\(mInvData.value(forKey: "Qty") ?? "")", forKey: "Qty")
        mData.setValue("\(mInvData.value(forKey: "SKU") ?? "")", forKey: "SKU")
        mData.setValue("\(mInvData.value(forKey: "stock_id") ?? "")", forKey: "stock_id")
        mData.setValue("\(mInvData.value(forKey: "name") ?? "")", forKey: "name")
//        mData.setValue("\(mInvData.value(forKey: "po_QTY") ?? "1")", forKey: "po_QTY")
        if let productDetails = mInvData["product_details"] as? NSDictionary {

            mData.setValue(
                "\(productDetails["po_QTY"] ?? "1")",
                forKey: "po_QTY"
            )

        } else {

            mData.setValue(
                "\(mInvData["po_QTY"] ?? "1")",
                forKey: "po_QTY"
            )
        }
        mData.setValue("\(mInvData.value(forKey: "main_image") ?? "")", forKey: "main_image")
        mData.setValue("\(mInvData.value(forKey: "size_name") ?? "")", forKey: "size_name")
        mData.setValue("\(mInvData.value(forKey: "metal_name") ?? "")", forKey: "metal_name")
        mData.setValue("\(mInvData.value(forKey: "stone_name") ?? "")", forKey: "stone_name")
        mData.setValue("\(mInvData.value(forKey: "collection_name") ?? "")", forKey: "collection_name")
        mData.setValue("\(mInvData.value(forKey: "location_name") ?? "")", forKey: "location_name")
        mData.setValue("\(mInvData.value(forKey: "custom_cart_id") ?? "")", forKey: "custom_cart_id")
        mData.setValue("\(mInvData.value(forKey: "remark") ?? "")", forKey: "remark")
        mData.setValue("\(mInvData.value(forKey: "currency") ?? "")", forKey: "currency")
        mData.setValue("\(mInvData.value(forKey: "delivery_date") ?? "")", forKey: "delivery_date")
        mData.setValue(mInvData.value(forKey: "Custom_design_status") ?? false, forKey: "Custom_design_status")
        mCartData.removeObject(at: sender.tag)
        mCartData.insert(mData, at: sender.tag)
        calculateItemsWithAmount()
    
    }
    
    @IBAction func mEditremarks(_ sender: UITextField) {

        guard
            let mInvData = mCartData[sender.tag] as? NSDictionary,
            let cells = mCartTable.cellForRow(
                at: IndexPath(row: sender.tag, section: 0)
            ) as? CustomCartItems
        else {
            return
        }

        let mData = NSMutableDictionary(dictionary: mInvData)

        mData.setValue(
            cells.mRemarks.text ?? "",
            forKey: "remark"
        )

        mCartData.removeObject(at: sender.tag)
        mCartData.insert(mData, at: sender.tag)

        print(
            "🔥 ITEM REMARK =",
            cells.mRemarks.text ?? ""
        )
    }
   
    @IBAction func mOpenDesign(_ sender: UIButton) {
        
        UserDefaults.standard.setValue("\(mNotes.text ?? "")", forKey: "cRemark")
        let storyBoard: UIStoryboard = UIStoryboard(name: "customOrder", bundle: nil)
        if #available(iOS 14.0, *) {
            let mIndex = sender.tag
            if let mData = mCartData[mIndex] as? NSDictionary,
               let mCustomDesign = storyBoard.instantiateViewController(withIdentifier: "CustomDesign") as? CustomDesign {
                
                mCustomDesign.mData = mData
                mCustomDesign.mCustomerId = self.mCustomerId
                
                if let mCustomDesignStatus = mData.value(forKey: "Custom_design_status") as? Bool {
                    if mCustomDesignStatus {
                        mCustomDesign.mStatus = "1"
                    }else{
                        mCustomDesign.mStatus = "0"
                    }
                }
                self.navigationController?.pushViewController(mCustomDesign, animated:true)
            }
        } else {
            
        }
    }
    
    
    // MARK: - Reserve Note Suggestions

    private func reserveSuggestionItems() -> [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "d MMM yyyy"
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        let pickup = "Pickup on \(formatter.string(from: tomorrow)), 2:00 PM"

        return [
            pickup,
            "On hold until closing time",
            "Customer response",
            "Payment verification"
        ]
    }

    private func setupReserveNoteSuggestions() {
        guard reserveSuggestionsView == nil else { return }

        let popup = UIView()
        popup.backgroundColor = .white
        popup.layer.cornerRadius = 6
        popup.layer.masksToBounds = true
        popup.layer.shadowColor = UIColor.black.cgColor
        popup.layer.shadowOpacity = 0.14
        popup.layer.shadowRadius = 8
        popup.layer.shadowOffset = CGSize(width: 0, height: 3)
        popup.isHidden = true
        view.addSubview(popup)
        reserveSuggestionsView = popup

        let title = UILabel()
        title.text = "Suggestions"
        title.font = UIFont(name: "segoe_bold", size: 10) ?? .boldSystemFont(ofSize: 10)
        title.textColor = .label
        title.translatesAutoresizingMaskIntoConstraints = false
        popup.addSubview(title)

        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: popup.topAnchor, constant: 12),
            title.leadingAnchor.constraint(equalTo: popup.leadingAnchor, constant: 18),
            title.trailingAnchor.constraint(equalTo: popup.trailingAnchor, constant: -12),
            title.heightAnchor.constraint(equalToConstant: 20)
        ])
    }

    private func showReserveSuggestions() {
        guard reserveSuggestionSessionActive else { return }
        guard let popup = reserveSuggestionsView else { return }

        let query = (mNotes.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let allItems = reserveSuggestionItems()
        let items: [String]

        if query.isEmpty {
            items = allItems
        } else {
            items = allItems.filter {
                $0.range(of: query, options: [.caseInsensitive, .diacriticInsensitive]) != nil
            }
        }

        reserveSuggestionsButtons.forEach { $0.removeFromSuperview() }
        reserveSuggestionsButtons.removeAll()

        // If there is no matching suggestion, hide the entire popup including the title.
        guard !items.isEmpty else {
            reserveVisibleSuggestions = []
            popup.isHidden = true
            return
        }
        reserveVisibleSuggestions = items

        let titleHeight: CGFloat = 32
        let rowHeight: CGFloat = 42
        let popupWidth = min(CGFloat(306), view.bounds.width - 20)
        let popupHeight = titleHeight + CGFloat(items.count) * rowHeight + 8

        // Put the popup directly above the Note field when possible.
        let noteFrame = mNotes.convert(mNotes.bounds, to: view)
        var x = noteFrame.minX
        var y = noteFrame.minY - popupHeight - 8
        if x + popupWidth > view.bounds.width - 10 {
            x = view.bounds.width - popupWidth - 10
        }
        if x < 10 { x = 10 }

        // If the keyboard/layout leaves insufficient room above, place it just below the top safe area.
        if y < view.safeAreaInsets.top + 8 {
            y = view.safeAreaInsets.top + 8
        }

        popup.frame = CGRect(x: x, y: y, width: popupWidth, height: popupHeight)
        popup.isHidden = false

        let top = titleHeight
        for (index, item) in items.enumerated() {
            let button = UIButton(type: .system)
            button.tag = index
            button.setTitle(item, for: .normal)
            button.setTitleColor(.label, for: .normal)
            button.titleLabel?.font = UIFont(name: "segoe_regular", size: 14) ?? .systemFont(ofSize: 14)
            button.contentHorizontalAlignment = .left
            button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 10)
            button.addTarget(self, action: #selector(reserveSuggestionTapped(_:)), for: .touchUpInside)
            button.frame = CGRect(x: 0, y: top + CGFloat(index) * rowHeight, width: popupWidth, height: rowHeight)
            popup.addSubview(button)
            reserveSuggestionsButtons.append(button)
        }
    }

    private func hideReserveSuggestions() {
        reserveSuggestionsView?.isHidden = true
    }

    @objc private func reserveSuggestionTapped(_ sender: UIButton) {
        guard sender.tag >= 0, sender.tag < reserveVisibleSuggestions.count else { return }

        mNotes.text = reserveVisibleSuggestions[sender.tag]
        reserveSuggestionSessionActive = false
        hideReserveSuggestions()
        // Keep Note focused so the iOS clear button remains available after a suggestion is selected.
    }

    @objc private func reserveNoteEditingChanged(_ textField: UITextField) {
        guard reserveSuggestionSessionActive else { return }
        showReserveSuggestions()
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard textField === mNotes else { return }
        reserveSuggestionSessionActive = true
        // Dispatch to the next run loop so the keyboard has started before we calculate the popup position.
        DispatchQueue.main.async { [weak self] in
            self?.showReserveSuggestions()
        }
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        guard textField === mNotes else { return true }

        // Keep editing active after clearing so the keyboard and suggestions behave like the Note field design.
        reserveSuggestionSessionActive = true
        DispatchQueue.main.async { [weak self] in
            self?.showReserveSuggestions()
        }
        return true
    }

    private func setupReserveKeyboardDismissGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(reserveDismissKeyboardAndSuggestions(_:)))
        tap.cancelsTouchesInView = false
        tap.delegate = self
        view.addGestureRecognizer(tap)
        reserveDismissTapGesture = tap
    }

    @objc private func reserveDismissKeyboardAndSuggestions(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: view)
        let noteFrame = mNotes.convert(mNotes.bounds, to: view)

        // Tapping inside Note should keep editing and Suggestions active.
        if noteFrame.contains(point) {
            return
        }

        reserveSuggestionSessionActive = false
        hideReserveSuggestions()
        view.endEditing(true)
        mNotes.resignFirstResponder()
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard gestureRecognizer === reserveDismissTapGesture else { return true }

        // Do not dismiss when the user taps Note or a Suggestion button.
        if let touchedView = touch.view {
            if touchedView === mNotes || touchedView.isDescendant(of: mNotes) {
                return false
            }
            if let popup = reserveSuggestionsView,
               touchedView === popup || touchedView.isDescendant(of: popup) {
                return false
            }
        }
        return true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        reserveSuggestionSessionActive = false
        hideReserveSuggestions()
        view.endEditing(true)
    }

    func calculateItemsWithAmount(){
        var mAmounts = [Double]()
        var mQuantities = [Int]()
        for i in mCartData {
            if let mData = i as? NSDictionary {
                mQuantities.append(Int("\(mData.value(forKey: "Qty") ?? "0")") ?? 0 )
                mAmounts.append(Double("\(mData.value(forKey: "price") ?? "0.0")".replacingOccurrences(of: ",", with: "")) ?? 0.00)
            }
        }
        mTotalItems.text = "\(mCartData.count) " + "Items".localizedString
        
        mGrandTotal.text = self.mCurrency + String(format:"%.02f",locale:Locale.current,mAmounts.reduce(0, {$0 + $1}))

        mGrandTotalCart = "\(mAmounts.reduce(0, {$0 + $1}))"
        self.mGrandTotalAmounts = "\(mAmounts.reduce(0, {$0 + $1}))"
        if mDepositPercents == "100" {
            mDepositAmount.text =  mGrandTotal.text
            mOutstandingAmount.text = self.mCurrency + "0.00"
            self.mOutStandingAmounts = "0.00"
            self.mTotalDepositAmounts = self.mGrandTotalAmounts

        }else{
            let mTotalValue = mAmounts.reduce(0, {$0 + $1})
            mDepositAmount.text = self.mCurrency + String(format:"%.02f",locale:Locale.current,calculatePercentage(value: mTotalValue, percent: Double(mDepositPercents) ?? 0.00))
            self.mTotalDepositAmounts = "\(calculatePercentage(value: mTotalValue, percent: Double(mDepositPercents) ?? 0.00))"
            let mOutstandingBal = mTotalValue - calculatePercentage(value: mTotalValue, percent: Double(mDepositPercents) ?? 0.00)
            self.mOutStandingAmounts = "\(mOutstandingBal)"
            self.mOutstandingAmount.text = self.mCurrency + String(format:"%.02f",locale:Locale.current,mOutstandingBal)
        }
        
        
        
        
    }
    
    func calculatePercentage(value:Double,percent: Double) -> Double {
        let val = value * percent
        return val/100.00
    }
    
}
