//
//  ExchangeController.swift
//  GIS
//
//  Created by Apple Hawkscode on 30/03/21.
//

import UIKit
import Alamofire
import DropDown

class PurchaseHistoryCell: UITableViewCell {
    
    @IBOutlet weak var mCheckView: UIView!
    @IBOutlet weak var mStackView: UIStackView!
    
    @IBOutlet weak var mSNo: UILabel!
    @IBOutlet weak var mDate: UILabel!
    
    @IBOutlet weak var mStockId: UILabel!
    
    @IBOutlet weak var mSKU: UILabel!
    
    @IBOutlet weak var mSize: UILabel!
    
    @IBOutlet weak var mQuantity: UILabel!
    @IBOutlet weak var mAmount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

class ExchangeCell: UITableViewCell {
    @IBOutlet weak var mAmount: UILabel!
    @IBOutlet weak var mQuantity: UILabel!
    @IBOutlet weak var mSKUName: UILabel!
    @IBOutlet weak var mStockId: UILabel!
    @IBOutlet weak var mInvoiceNo: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

class ExchangeController:  UIViewController, UIViewControllerTransitioningDelegate ,GetCustomerDataDelegate , UITableViewDataSource ,UITableViewDelegate, GetInventoryDataItemsDelegate , DeleteCustomCartItems,GetVerification , ProceedToPay {
    
    func isProceedWithStatus(status: Bool, message: String) {
        
    }
    
    var mCartAmount = [Double]()
    var totalAmount: Double = 0.0
    
    @IBOutlet weak var mSearchField: UITextField!
    
    @IBOutlet weak var mTotalItems: UILabel!
    @IBOutlet weak var mGrandTotal: UILabel!
    @IBOutlet weak var mDepositAmount: UILabel!
    @IBOutlet weak var mOutstandingAmount: UILabel!
    @IBOutlet weak var mCustomerName: UILabel!
    @IBOutlet weak var mCustomerImage: UIImageView!
    
    
    @IBOutlet weak var mSelectedCustomerIcon: UIImageView!
    var mCustomerId = ""
    
    // ✨ เพิ่มตัวแปรสำหรับเก็บข้อมูลที่อยู่ ✨
    var mSelectedBillingAddress: [String: Any] = [:]
    var mSelectedShippingAddress: [String: Any] = [:]
    
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
    
    
    var mOrderId = ""
    var mCartId = ""
    
    var mQuantityData = [Int]()
    var mCurrentIndex = -1
    let mDatePicker:UIDatePicker = UIDatePicker()
    var isItemsAvailable =  false
    var isDeleted = false
    
    @IBOutlet weak var mGrandTotalLABEL: UILabel!
    @IBOutlet weak var mCustomerLABEL: UILabel!
    @IBOutlet weak var mHeadingLABEL: UILabel!
    @IBOutlet weak var mExchangeBUTTON: UIButton!
    @IBOutlet weak var mNotesLABEL: UILabel!
    
    @IBOutlet weak var mBottomCustomerLABEL: UILabel!
    
    @IBOutlet weak var mBottomHistoryLABEL: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mCustomerName.text = ""
        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
        self.mNotes.keyboardType = .default
        self.mCartTable.delegate = self
        self.mCartTable.dataSource = self
        self.mCartTable.reloadData()
        
        mCustomerId  = UserDefaults.standard.string( forKey: "DEFAULTCUSTOMER") ?? ""
        
    }
    
    
    @IBAction func mOpenProductStoneDetails(_ sender: UIButton) {
        
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    override func viewWillAppear(_ animated: Bool) {
        
        mGrandTotalLABEL.text = "Grand Total".localizedString
        mCustomerLABEL.text = "Customer".localizedString
        mHeadingLABEL.text = "EXCHANGE".localizedString
        mExchangeBUTTON.setTitle("EXCHANGE".localizedString, for: .normal)
        mNotesLABEL.text = "Note".localizedString
        mNotes.placeholder = "Ex. Urgent Order"
        mBottomCustomerLABEL.text = "Customer".localizedString
        mBottomHistoryLABEL.text = "History".localizedString
        
        mGrandTotal.text = "\(UserDefaults.standard.value(forKey: "currencySymbol") ?? "$") 0.00"
        mDepositAmount.text = mGrandTotal.text
        mOutstandingAmount.text = mGrandTotal.text
        
        mGetData(url: mFetchPaymentMethod,headers: sGisHeaders,  params: ["":""]) { response , status in
            if status {
                if let mData = response.value(forKey: "data") as? NSDictionary {
                    
                    //Store Cash Data
                    if let mCashData = mData.value(forKey: "Cash") as? NSArray, mCashData.count > 0 {
                        if let mData = mCashData[0] as? NSDictionary {
                            UserDefaults.standard.set(mData, forKey: "CASHDATA")
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
        
        
        if UserDefaults.standard.string(forKey: "cRemark") != nil {
            self.mNotes.text = "\(UserDefaults.standard.string(forKey: "cRemark") ?? "")"
        }
        if mCustomerId == "" {
            mOpenCustomerSheet()
        }
        
        mCustomerId  = UserDefaults.standard.string( forKey: "DEFAULTCUSTOMER") ?? ""
        if !mCustomerId.isEmpty {
            
            self.mCustomerImage.contentMode = .scaleAspectFill
            self.mSelectedCustomerIcon.image = UIImage(named: "selected_customer")
            self.mCustomerImage.downlaodImageFromUrl(urlString: UserDefaults.standard.string( forKey: "DEFAULTCUSTOMERPICTURE") ?? "")
            self.mCustomerName.text = UserDefaults.standard.string( forKey: "DEFAULTCUSTOMERNAME") ?? ""
            
            // ✨ เรียกใช้ฟังก์ชันดึงที่อยู่ลูกค้า ✨
            self.getCustomerAddressList()
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
    
    @IBAction func mCatalog(_ sender: Any) {
        if mCustomerId == "" {
            CommonClass.showSnackBar(message: "Please choose customer first!")
            mOpenCustomerSheet()
            return
        }
        let storyBoard: UIStoryboard = UIStoryboard(name: "moreBoard", bundle: nil)
        if let mCommonPurchaseHistory = storyBoard.instantiateViewController(withIdentifier: "CommonPurchaseHistory") as? CommonPurchaseHistory {
            mCommonPurchaseHistory.delegate =  self
            mCommonPurchaseHistory.mOrderType = "exchange_order"
            mCommonPurchaseHistory.mCustomerId = mCustomerId
            mCommonPurchaseHistory.modalPresentationStyle = .overFullScreen
            mCommonPurchaseHistory.transitioningDelegate = self
            self.present(mCommonPurchaseHistory,animated: true)
        }
    }
    
    func mGetInventoryItems(items: [String]) {
        mOrderId = items[0]
        mCartId = items[1]
        mFetchCartItems()
    }
    
    
    
    func mFetchCartItems(){
        
        let mParams = [ "order_id":mOrderId ,"cartid":mCartId, "order_type": "pos_order"] as [String : Any]
        
        mGetData(url: mFetchCustomProduct,headers: sGisHeaders,  params: mParams) { response , status in
            CommonClass.stopLoader()
            if status {
                if "\(response.value(forKey: "code") ?? "")" == "200" {
                    if let mData = response.value(forKey: "data") as? NSArray, mData.count > 0 {
                        
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
                        if let first = self.mCartData.firstObject as? NSDictionary {
                            let itemTotal = Double("\(first.value(forKey: "totalamount") ?? "0")") ?? 0.0
                            self.totalAmount = itemTotal
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
        if mCustomerId == "" {
            CommonClass.showSnackBar(message: "Please choose customer first!")
            mOpenCustomerSheet()
            return
        }
        let storyBoard: UIStoryboard = UIStoryboard(name: "common", bundle: nil)
        if let mInv = storyBoard.instantiateViewController(withIdentifier: "CommonInventory") as? CommonInventory {
            mInv.modalPresentationStyle = .overFullScreen
            mInv.delegate =  self
            mInv.mCustomerId = mCustomerId
            mInv.transitioningDelegate = self
            self.present(mInv,animated: true)
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
        
        UserDefaults.standard.set(data.value(forKey: "id") as? String ?? "", forKey: "DEFAULTCUSTOMER")
        UserDefaults.standard.set(data.value(forKey: "profile") ?? "", forKey: "DEFAULTCUSTOMERPICTURE")
        UserDefaults.standard.set(data.value(forKey: "name") as? String ?? "", forKey: "DEFAULTCUSTOMERNAME")
        self.mCustomerName.text = data.value(forKey: "name") as? String
        self.mCustomerId = data.value(forKey: "id") as? String ?? ""
        self.mCustomerImage.contentMode = .scaleAspectFill
        self.mCustomerImage.downlaodImageFromUrl(urlString: data.value(forKey: "profile") as? String ?? "")
        self.mSelectedCustomerIcon.image = UIImage(named: "selected_customer")
        
        // ✨ เรียกใช้ฟังก์ชันดึงที่อยู่ลูกค้า ✨
        self.getCustomerAddressList()
        
        //Clear Cart
        self.mCartData.removeAllObjects()
        self.mCartTable.reloadData()
        calculateItemsWithAmount()
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
    
    
    func isProceed(status: Bool) {
            if status {
                let storyBoard: UIStoryboard = UIStoryboard(name: "common", bundle: nil)
                if let mVerifyPin = storyBoard.instantiateViewController(withIdentifier: "VerifyPin") as? VerifyPin {
                    mVerifyPin.delegate = self
                    mVerifyPin.modalPresentationStyle = .overFullScreen
                    mVerifyPin.transitioningDelegate = self
                    self.present(mVerifyPin,animated: false)
                }
            }
        }

        func isVerified(status: Bool) {
            if status {
                let mSellInfo = NSMutableDictionary()
                mSellInfo.setValue(mCartData, forKey: "cart")
                mSellInfo.setValue(totalAmount, forKey: "totalamount")
                let paymentInfo = NSMutableDictionary()
                paymentInfo.setValue(0, forKey: "balance_due")
                
                var mParams: [String: Any] = [ "order_id": mOrderId ,
                                               "sell_info": mSellInfo,
                                               "payment_info": paymentInfo,
                                               "order_type": "exchange_order",
                                               "byMobile": true,
                                               "customer_id": mCustomerId]
                
                if !self.mSelectedBillingAddress.isEmpty || !self.mSelectedShippingAddress.isEmpty {
                    mParams["shipping_info"] = [
                        "billing_address": self.mSelectedBillingAddress,
                        "shipping_address": self.mSelectedShippingAddress
                    ]
                }
                
                let mQuotationId = UserDefaults.standard.string(forKey: "quotationId") ?? ""
                if !mQuotationId.isEmpty {
                    mParams["quatation_id"] = mQuotationId
                }
                
                print("DEBUG_EXCHANGE_PAYLOAD: \(mParams)")
                
                CommonClass.showFullLoader(view: self.view)
                
                mGetData(url: mFinalCheckoutCustomOrder,headers: sGisHeaders,  params: mParams) { response , status in
                    CommonClass.stopLoader()
                    print("ExchangeController mFinalCheckoutCustomOrder  = \(response)")
                    if status {
                        if "\(response.value(forKey: "code") ?? "")" == "200" {
//                            if let mData = response.value(forKey: "data") as? NSDictionary {
//                                let storyBoard: UIStoryboard = UIStoryboard(name: "posBoard", bundle: nil)
//                                if let mCompletePayment = storyBoard.instantiateViewController(withIdentifier: "CompletePayment") as? CompletePayment {
//                                    mCompletePayment.mTotalQuantity = "\(self.mCartData.count)"
//                                    mCompletePayment.mType = "exchange_order"
//                                    mCompletePayment.mCurrency = self.mCurrency
//                                    mCompletePayment.mGrandTotalAmount = self.mGrandTotalAmounts
//                                    mCompletePayment.mUrl = "\(mData.value(forKey: "url") ?? "")"
//                                    mCompletePayment.mShippingInfo = [
//                                        "billing_address": self.mSelectedBillingAddress,
//                                        "shipping_address": self.mSelectedShippingAddress
//                                    ]
//                                    self.navigationController?.pushViewController(mCompletePayment, animated:true)
//                                }
//                            }
                            if let mData = response.value(forKey: "data") as? NSDictionary {

                                let storyBoard: UIStoryboard = UIStoryboard(
                                    name: "posBoard",
                                    bundle: nil
                                )

                                if let mCompletePayment = storyBoard.instantiateViewController(
                                    withIdentifier: "CompletePayment"
                                ) as? CompletePayment {

                                    mCompletePayment.mTotalQuantity = "\(self.mCartData.count)"
                                    mCompletePayment.mType = "exchange_order"

                                    // ✅ เพิ่มบรรทัดนี้
                                    mCompletePayment.mOrderId =
                                        "\(mData.value(forKey: "id") ?? "")"

                                    // debug
                                    print("🔥 EXCHANGE COMPLETE TYPE =", mCompletePayment.mType)
                                    print("🔥 EXCHANGE COMPLETE ORDER ID =", mCompletePayment.mOrderId)

                                    mCompletePayment.mCurrency = self.mCurrency
                                    mCompletePayment.mGrandTotalAmount = self.mGrandTotalAmounts
                                    mCompletePayment.mUrl =
                                        "\(mData.value(forKey: "url") ?? "")"

                                    mCompletePayment.mShippingInfo = [
                                        "billing_address": self.mSelectedBillingAddress,
                                        "shipping_address": self.mSelectedShippingAddress
                                    ]

                                    self.navigationController?.pushViewController(
                                        mCompletePayment,
                                        animated: true
                                    )
                                }
                            }
                        }
                    }
                }
            }
        }
    
    @IBAction func mCheckOut(_ sender: UIButton) {
        sender.showAnimation{
            
            if self.mCartData.count == 0 {
                CommonClass.showSnackBar(message: "Please add items to exchange!")
                return
            }
            
            mConfirmationPopUp.frame = self.view.bounds
            mConfirmationPopUp.delegate = self
            mConfirmationPopUp.mMessage.text = "Are you sure want to proceed ?".localizedString
            mConfirmationPopUp.mCancelButton.setTitle("CANCEL".localizedString, for: .normal)
            mConfirmationPopUp.mConfirmButton.setTitle("CONFIRM".localizedString, for: .normal)
            self.view.addSubview(mConfirmationPopUp)
            
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
        cell.mRemarks.tag = indexPath.row
        cell.mProductPrice.tag = indexPath.row
        cell.mPlusButton.tag = indexPath.row
        cell.mMinusButton.tag = indexPath.row
        cell.mChooseDateButton.tag = indexPath.row
        cell.mDesignButton.tag = indexPath.row
        
        if let mData = mCartData[indexPath.row] as? NSDictionary {
            if let mCustomDesignStatus = mData.value(forKey: "Custom_design_status") as? Bool {
                if mCustomDesignStatus {
                    cell.mEditIcon.image = UIImage(named: "edit_custom_green")
                }else{
                    cell.mEditIcon.image = UIImage(named: "edit_custom")
                }
            }
            cell.mQuantityUnit.text = "\(mData.value(forKey: "Qty") ?? "--")"
            cell.mDueDate.text = "\(mData.value(forKey: "delivery_date") ?? "--")"
            cell.mCurrency.text = "\(mData.value(forKey: "currency") ?? "$")"
            self.mCurrency = "\(mData.value(forKey: "currency") ?? "$") "
            cell.mRemarks.keyboardType = .default
            cell.mRemarks.text = "\(mData.value(forKey: "remark") ?? "")"
            cell.mSKUName.text = "\(mData.value(forKey: "SKU") ?? "")"
            cell.mProductName.text = "\(mData.value(forKey: "name") ?? "")"
            cell.mMetalColorSize.text = "\(mData.value(forKey: "color_name") ?? "") " + "\(mData.value(forKey: "metal_name") ?? "") " + "\(mData.value(forKey: "size_name") ?? "")"
//            cell.mProductPrice.text = "\(mData.value(forKey: "price") ?? "")"
            let mCurrencySymbol = "\(UserDefaults.standard.string(forKey: "currencySymbol") ?? "$")"
            let amount = Double("\(mData["price"] ?? 0)") ?? 0
            cell.mProductPrice.text = "\(mCurrencySymbol) \(amount.currencyString)"
            
            cell.mStockId.text = "\(mData.value(forKey: "stock_id") ?? "")"
            
            cell.mProductImage.downlaodImageFromUrl(urlString: "\(mData.value(forKey: "main_image") ?? "")")
            cell.mProductImage.tag = indexPath.row
            cell.imageTapGesture(target: self, action: #selector(handleImageTap(_:)))
        }
        calculateItemsWithAmount()
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 144 + 16
    }
    
    @objc func handleImageTap(_ sender: UITapGestureRecognizer) {
        guard let imageView = sender.view as? UIImageView else {
            return
        }
        let index = imageView.tag
        if let mData = mCartData[index] as? NSDictionary {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Test", bundle: nil)
            if let mGlobalImageViewer = storyBoard.instantiateViewController(withIdentifier: "GlobalImageViewer") as? GlobalImageViewer {
                mGlobalImageViewer.modalPresentationStyle = .overFullScreen
                print("handleImageTap mData = \(mData)")
                mGlobalImageViewer.mProductNameString = "\(mData.value(forKey: "name") ?? "")"
                mGlobalImageViewer.mSKUName = "\(mData.value(forKey: "SKU") ?? "")"
                mGlobalImageViewer.mAllImages = ["\(mData.value(forKey: "main_image") ?? "")"]
                mGlobalImageViewer.isMixMatch = true
                mGlobalImageViewer.transitioningDelegate = self
                self.present(mGlobalImageViewer,animated: false)
            }
        }
    }
    
    @IBAction func mMinusButton(_ sender: UIButton) {
        
        let index = sender.tag
        if let mInvData = mCartData[index] as? NSDictionary {
            if let cells = mCartTable.cellForRow(at: IndexPath(row: sender.tag , section: 0)) as? CustomCartItems {
                let mOrgData = mCartDataMaster[sender.tag] as? NSDictionary
                let mMinQty = 1
                var mCurrentQty = Int(cells.mQuantityUnit.text ?? "") ?? 0
                if  mCurrentQty == mMinQty {
                    
                } else {
                    mCurrentQty = mCurrentQty - 1
                    if  mCurrentQty == 1 {
                        cells.mQuantityUnit.text = "\(mMinQty)"
                        cells.mProductPrice.text = "\((Double("\(mInvData.value(forKey: "price") ?? "0")") ?? 0.0) - (self.mCartAmount[sender.tag]))"
                    }else{
                        cells.mQuantityUnit.text = "\(mCurrentQty)"
                        cells.mProductPrice.text = "\((Double("\(mInvData.value(forKey: "price") ?? "0")") ?? 0.0) - (self.mCartAmount[sender.tag]))"
                    }
                }
                var mData = NSMutableDictionary()
                mData.setValue("\(mInvData.value(forKey: "id") ?? "")", forKey: "id")
                mData.setValue("\(cells.mQuantityUnit.text ?? "")", forKey: "Qty")
                mData.setValue("\(mInvData.value(forKey: "order_type") ?? "")", forKey: "order_type")
                mData.setValue("\(mInvData.value(forKey: "SKU") ?? "")", forKey: "SKU")
                mData.setValue("\(mInvData.value(forKey: "stock_id") ?? "")", forKey: "stock_id")
                mData.setValue("\(cells.mProductPrice.text ?? "")", forKey: "price")
                mData.setValue("\(mInvData.value(forKey: "cart_price") ?? "")", forKey: "cart_price")
                mData.setValue("\(mInvData.value(forKey: "qtyToBe") ?? "1")", forKey: "qtyToBe")
                mData.setValue("\(mInvData.value(forKey: "name") ?? "")", forKey: "name")
                mData.setValue("\(mInvData.value(forKey: "main_image") ?? "")", forKey: "main_image")
                mData.setValue("\(mInvData.value(forKey: "size_name") ?? "")", forKey: "size_name")
                mData.setValue("\(mInvData.value(forKey: "metal_name") ?? "")", forKey: "metal_name")
                mData.setValue("\(mInvData.value(forKey: "stone_name") ?? "")", forKey: "stone_name")
                mData.setValue("\(mInvData.value(forKey: "collection_name") ?? "")", forKey: "collection_name")
                mData.setValue("\(mInvData.value(forKey: "location_name") ?? "")", forKey: "location_name")
                mData.setValue("\(mInvData.value(forKey: "custom_cart_id") ?? "")", forKey: "custom_cart_id")
                mData.setValue("\(mInvData.value(forKey: "po_product_id") ?? "")", forKey: "po_product_id")
                mData.setValue("\(mInvData.value(forKey: "remark") ?? "")", forKey: "remark")
                mData.setValue("\(mInvData.value(forKey: "currency") ?? "")", forKey: "currency")
                mData.setValue("\(mInvData.value(forKey: "delivery_date") ?? "")", forKey: "delivery_date")
                
                mCartData.removeObject(at: index)
                mCartData.insert(mData, at: index)
                mCartTable.reloadData()
            }
        }
        calculateItemsWithAmount()
    }
    
    
    @IBAction func mPlusButton(_ sender: UIButton) {
        let index = sender.tag
        
        let mOrgData = mCartDataMaster[sender.tag] as? NSDictionary
        if let mInvData = mCartData[index] as? NSDictionary {
            if let cells = mCartTable.cellForRow(at: IndexPath(row: sender.tag , section: 0)) as? CustomCartItems {
                let mMaxQty = Int("\(mInvData.value(forKey: "qtyToBe") ?? "1")") ?? 1
                var mCurrentQty = Int(cells.mQuantityUnit.text ?? "") ?? 1
                if mCurrentQty == mMaxQty {
                    return
                }
                mCurrentQty = mCurrentQty + 1
                cells.mQuantityUnit.text = "\(mCurrentQty)"
                
                cells.mProductPrice.text = "\((Double("\(mInvData.value(forKey: "price") ?? "0")") ?? 0.0) + (self.mCartAmount[sender.tag]) )"
                
                var mData = NSMutableDictionary()
                mData.setValue("\(mInvData.value(forKey: "id") ?? "")", forKey: "id")
                mData.setValue("\(mInvData.value(forKey: "order_type") ?? "")", forKey: "order_type")
                mData.setValue("\(cells.mQuantityUnit.text ?? "")", forKey: "Qty")
                mData.setValue("\(mInvData.value(forKey: "SKU") ?? "")", forKey: "SKU")
                mData.setValue("\(mInvData.value(forKey: "qtyToBe") ?? "1")", forKey: "qtyToBe")
                mData.setValue("\(mInvData.value(forKey: "stock_id") ?? "")", forKey: "stock_id")
                mData.setValue("\(cells.mProductPrice.text ?? "")", forKey: "price")
                mData.setValue("\(mInvData.value(forKey: "cart_price") ?? "")", forKey: "cart_price")
                mData.setValue("\(mInvData.value(forKey: "name") ?? "")", forKey: "name")
                mData.setValue("\(mInvData.value(forKey: "main_image") ?? "")", forKey: "main_image")
                mData.setValue("\(mInvData.value(forKey: "size_name") ?? "")", forKey: "size_name")
                mData.setValue("\(mInvData.value(forKey: "metal_name") ?? "")", forKey: "metal_name")
                mData.setValue("\(mInvData.value(forKey: "stone_name") ?? "")", forKey: "stone_name")
                mData.setValue("\(mInvData.value(forKey: "collection_name") ?? "")", forKey: "collection_name")
                mData.setValue("\(mInvData.value(forKey: "location_name") ?? "")", forKey: "location_name")
                mData.setValue("\(mInvData.value(forKey: "custom_cart_id") ?? "")", forKey: "custom_cart_id")
                mData.setValue("\(mInvData.value(forKey: "po_product_id") ?? "")", forKey: "po_product_id")
                mData.setValue("\(mInvData.value(forKey: "remark") ?? "")", forKey: "remark")
                
                mData.setValue("\(mInvData.value(forKey: "currency") ?? "")", forKey: "currency")
                mData.setValue("\(mInvData.value(forKey: "delivery_date") ?? "")", forKey: "delivery_date")
                
                mCartData.removeObject(at: index)
                mCartData.insert(mData, at: index)
            }
            mCartTable.reloadData()
        }
        calculateItemsWithAmount()
    }
    
    @IBAction func mChooseDate(_ sender: UIButton) {
        
        if let cells = mCartTable.cellForRow(at: IndexPath(row: sender.tag , section: 0)) as? CustomCartItems {
            
            mCurrentIndex = sender.tag
            let currentDate = Date()
            var datecomp = DateComponents()
            let min = Calendar.init(identifier: .gregorian)
            
            mDatePicker.preferredDatePickerStyle = .wheels
            datecomp.day = 0
            let minDates = min.date(byAdding: datecomp, to: currentDate)
            
            datecomp.year = 5
            let maxDates = min.date(byAdding: datecomp, to: currentDate)
            mDatePicker.minimumDate = minDates
            mDatePicker.maximumDate = maxDates
            mDatePicker.datePickerMode = .date
            mDatePicker.backgroundColor = .white
            //ToolBar
            let mToolBar = UIToolbar()
            mToolBar.sizeToFit()
            mToolBar.backgroundColor = .white
            mToolBar.barTintColor = .white
            let mDone = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneDatePick))
            let mSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let mCancel = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(mCancelDatePick))
            mToolBar.setItems([mCancel, mSpace,mDone], animated: false)
            cells.mDueDate.inputAccessoryView = mToolBar
            cells.mDueDate.inputView = mDatePicker
            cells.mDueDate.becomeFirstResponder()
        }
    }
    
    @objc
    func doneDatePick(){
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "dd/MM/yyyy"

        let deliveryDate = formatter.string(from: mDatePicker.date)
        
        if let cell1 = mCartTable.cellForRow(at: IndexPath(row: mCurrentIndex, section: 0)) as? CustomCartItems {
            cell1.mDueDate.text  = deliveryDate
        }
        if let mInvData = mCartData[mCurrentIndex] as? NSDictionary {
            if let cells = mCartTable.cellForRow(at: IndexPath(row: mCurrentIndex , section: 0)) as? CustomCartItems {
                var mData = NSMutableDictionary()
                mData.setValue("\(mInvData.value(forKey: "id") ?? "")", forKey: "id")
                mData.setValue("\(mInvData.value(forKey: "order_type") ?? "")", forKey: "order_type")
                mData.setValue("\(mInvData.value(forKey: "Qty") ?? "")", forKey: "Qty")
                mData.setValue("\(mInvData.value(forKey: "SKU") ?? "")", forKey: "SKU")
                mData.setValue("\(mInvData.value(forKey: "stock_id") ?? "")", forKey: "stock_id")
                mData.setValue("\(mInvData.value(forKey: "price") ?? "")", forKey: "price")
                mData.setValue("\(mInvData.value(forKey: "name") ?? "")", forKey: "name")
                mData.setValue("\(mInvData.value(forKey: "main_image") ?? "")", forKey: "main_image")
                mData.setValue("\(mInvData.value(forKey: "size_name") ?? "")", forKey: "size_name")
                mData.setValue("\(mInvData.value(forKey: "metal_name") ?? "")", forKey: "metal_name")
                mData.setValue("\(mInvData.value(forKey: "stone_name") ?? "")", forKey: "stone_name")
                mData.setValue("\(mInvData.value(forKey: "collection_name") ?? "")", forKey: "collection_name")
                mData.setValue("\(mInvData.value(forKey: "location_name") ?? "")", forKey: "location_name")
                mData.setValue("\(mInvData.value(forKey: "custom_cart_id") ?? "")", forKey: "custom_cart_id")
                mData.setValue("\(mInvData.value(forKey: "remark") ?? "")", forKey: "remark")
                mData.setValue("\(mInvData.value(forKey: "currency") ?? "")", forKey: "currency")
                mData.setValue(deliveryDate, forKey: "delivery_date")
                mData.setValue(mInvData.value(forKey: "Custom_design_status") ?? false, forKey: "Custom_design_status")
                mCartData.removeObject(at: mCurrentIndex)
                mCartData.insert(mData, at: mCurrentIndex)
            }
        }
        self.view.endEditing(true)
        
    }
    
    @objc func mCancelDatePick(){
        self.view.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        
        if editingStyle == .delete {
            self.mDeleteRow(index: indexPath.row)
            
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
            mRemovePopUp.mType = "exchange"
            mRemovePopUp.mCartId = mData.value(forKey: "custom_cart_id") as? String ?? ""
            mRemovePopUp.mMessage.text = "Are you sure want to remove ?".localizedString
            mRemovePopUp.mCancelButton.setTitle("CANCEL".localizedString, for: .normal)
            mRemovePopUp.mConfirmButton.setTitle("CONFIRM".localizedString, for: .normal)
            self.view.addSubview(mRemovePopUp)
        }
    }
    
    @IBAction func mEditAmount(_ sender: UITextField) {
        if let mInvData = mCartData[sender.tag] as? NSDictionary {
            if let mOrgData = mCartDataMaster[sender.tag] as? NSDictionary {
                
                if let cells = mCartTable.cellForRow(at: IndexPath(row: sender.tag , section: 0)) as? CustomCartItems {
                    
                    if sender.text == "" || sender.text == "0" {
                        cells.mProductPrice.text = ""
                        var mData = NSMutableDictionary()
                        mData.setValue("0", forKey: "price")
                        self.mCartAmount.remove(at: sender.tag)
                        self.mCartAmount.insert(0.0, at: sender.tag)
                        mData.setValue("\(mInvData.value(forKey: "id") ?? "")", forKey: "id")
                        mData.setValue("\(mInvData.value(forKey: "order_type") ?? "")", forKey: "order_type")
                        mData.setValue("\(mInvData.value(forKey: "Qty") ?? "")", forKey: "Qty")
                        mData.setValue("\(mInvData.value(forKey: "SKU") ?? "")", forKey: "SKU")
                        mData.setValue("\(mInvData.value(forKey: "stock_id") ?? "")", forKey: "stock_id")
                        mData.setValue("\(mInvData.value(forKey: "name") ?? "")", forKey: "name")
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
                    
                    var mData = NSMutableDictionary()
                    self.mCartAmount.remove(at: sender.tag)
                    self.mCartAmount.insert(Double("\(cells.mProductPrice.text ?? "")") ?? 0.0, at: sender.tag)
                    mData.setValue(cells.mProductPrice.text ?? "", forKey: "price")
                    mData.setValue("\(mInvData.value(forKey: "id") ?? "")", forKey: "id")
                    mData.setValue("\(mInvData.value(forKey: "order_type") ?? "")", forKey: "order_type")
                    mData.setValue("\(mInvData.value(forKey: "Qty") ?? "")", forKey: "Qty")
                    mData.setValue("\(mInvData.value(forKey: "SKU") ?? "")", forKey: "SKU")
                    mData.setValue("\(mInvData.value(forKey: "stock_id") ?? "")", forKey: "stock_id")
                    mData.setValue("\(mInvData.value(forKey: "name") ?? "")", forKey: "name")
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
            }
        }
    }
    
    @IBAction func mEditremarks(_ sender: UITextField) {
        if let mInvData = mCartData[sender.tag] as? NSDictionary {
            if let cells = mCartTable.cellForRow(at: IndexPath(row: sender.tag , section: 0)) as? CustomCartItems {
                var mData = NSMutableDictionary()
                mData.setValue("\(mInvData.value(forKey: "id") ?? "")", forKey: "id")
                mData.setValue("\(mInvData.value(forKey: "order_type") ?? "")", forKey: "order_type")
                mData.setValue("\(mInvData.value(forKey: "Qty") ?? "")", forKey: "Qty")
                mData.setValue("\(mInvData.value(forKey: "SKU") ?? "")", forKey: "SKU")
                mData.setValue("\(mInvData.value(forKey: "stock_id") ?? "")", forKey: "stock_id")
                mData.setValue("\(mInvData.value(forKey: "price") ?? "")", forKey: "price")
                mData.setValue("\(mInvData.value(forKey: "name") ?? "")", forKey: "name")
                mData.setValue("\(mInvData.value(forKey: "main_image") ?? "")", forKey: "main_image")
                mData.setValue("\(mInvData.value(forKey: "size_name") ?? "")", forKey: "size_name")
                mData.setValue("\(mInvData.value(forKey: "metal_name") ?? "")", forKey: "metal_name")
                mData.setValue("\(mInvData.value(forKey: "stone_name") ?? "")", forKey: "stone_name")
                mData.setValue("\(mInvData.value(forKey: "collection_name") ?? "")", forKey: "collection_name")
                mData.setValue("\(mInvData.value(forKey: "location_name") ?? "")", forKey: "location_name")
                mData.setValue("\(mInvData.value(forKey: "custom_cart_id") ?? "")", forKey: "custom_cart_id")
                mData.setValue(cells.mRemarks.text ?? "", forKey: "remark")
                mData.setValue(cells.mRemarks.text ?? "", forKey: "note")
                mData.setValue("\(mInvData.value(forKey: "currency") ?? "")", forKey: "currency")
                mData.setValue("\(mInvData.value(forKey: "delivery_date") ?? "")", forKey: "delivery_date")
                mData.setValue(mInvData.value(forKey: "Custom_design_status") ?? false, forKey: "Custom_design_status")
                mCartData.removeObject(at: sender.tag)
                mCartData.insert(mData, at: sender.tag)
            }
        }
    }
    
    @IBAction func mOpenDesign(_ sender: UIButton) {
        
        UserDefaults.standard.setValue("\(mNotes.text ?? "")", forKey: "cRemark")
        let storyBoard: UIStoryboard = UIStoryboard(name: "customOrder", bundle: nil)
        if #available(iOS 14.0, *) {
            let mIndex = sender.tag
            if let mData = mCartData[mIndex] as? NSDictionary {
                
                if let mCustomDesign = storyBoard.instantiateViewController(withIdentifier: "CustomDesign") as? CustomDesign {
                    
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
            }
        } else {
            
        }
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
    
    // ✨ เพิ่มฟังก์ชันดึงที่อยู่เพื่อเตรียมส่งไป API ✨
    private func getCustomerAddressList(){
        guard Reachability.isConnectedToNetwork() == true else { return }
        
        let params = ["customer_id": mCustomerId] as [String : Any]
        let urlPath =  mGetCustomerAddressList
        
        AF.request(urlPath, method:.post,parameters: params,encoding: JSONEncoding.default, headers: sGisHeaders).responseJSON { response in
            guard let jsonData = response.data else { return }
            do {
                guard let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else { return }
                guard let code = json["code"] as? Int else { return }
                
                switch code {
                case 200:
                    if let data = json["data"] as? [String: Any] {
                        if let billingAddressList = data["billing_address"] as? [[String : Any]] {
                            for address in billingAddressList {
                                if let bUDID = UserDefaults.standard.string(forKey: "CustomerBillingAddressUDID"){
                                    if let udid = address["UDID"] as? String, udid == bUDID {
                                        self.mSelectedBillingAddress = address
                                    }
                                } else {
                                    if address["is_default"] as? Int == 1 {
                                        self.mSelectedBillingAddress = address
                                    }
                                }
                            }
                        }
                        if let shippingAddressList = data["shipping_address"] as? [[String : Any]] {
                            for address in shippingAddressList {
                                if let sUDID = UserDefaults.standard.string(forKey: "CustomerShippingAddressUDID") {
                                    if let udid = address["UDID"] as? String, udid == sUDID {
                                        self.mSelectedShippingAddress = address
                                    }
                                } else {
                                    if address["is_default"] as? Int == 1 {
                                        self.mSelectedShippingAddress = address
                                    }
                                }
                            }
                        }
                    }
                default:
                    break
                }
            } catch { }
        }
    }
    
}

extension Double {

    var currencyString: String {

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2

        return formatter.string(from: NSNumber(value: self)) ?? "0.00"
    }
}
