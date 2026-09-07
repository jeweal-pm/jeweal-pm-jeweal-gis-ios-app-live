//
//  DepositController.swift
//  GIS
//

import UIKit
import Alamofire
import DropDown

class DepositController : UIViewController, UIViewControllerTransitioningDelegate ,GetCustomerDataDelegate , UITableViewDataSource ,UITableViewDelegate, GetInventoryDataItemsDelegate , DeleteCustomCartItems, AddPaymentInfoDelegate ,GetVerification , ProceedToPay{

    private var selectedSalesPersonId: String {
        return (UserDefaults.standard.string(forKey: "SALESPERSONID") ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func cartWithSelectedSalesPerson() -> NSMutableArray {
        let updatedCart = NSMutableArray()

        for case let item as NSDictionary in mCartData {
            let updatedItem = NSMutableDictionary(dictionary: item)
            updatedItem["sales_person_id"] = selectedSalesPersonId
            updatedCart.add(updatedItem)
        }

        return updatedCart
    }
    func isProceedWithStatus(status: Bool, message: String) { }
    
    @IBOutlet weak var mSearchField: UITextField!
    var mFinalPaymentMethod = [String:Any]()
    @IBOutlet weak var mTotalItems: UILabel!
    @IBOutlet weak var mGrandTotal: UILabel!
    @IBOutlet weak var mDepositAmount: UILabel!
    @IBOutlet weak var mOutstandingAmount: UILabel!
    @IBOutlet weak var mCustomerName: UILabel!
    @IBOutlet weak var mCustomerImage: UIImageView!
    @IBOutlet weak var mSelectedCustomerIcon: UIImageView!
    
    var mCustomerId = ""
    @IBOutlet weak var mNotes: UITextField!
    
    var mDepositPercentData = ["25%","50%","75%","100%"]
    var mDepositPercentValue = ["25","50","75","100"]
    var mCurrency = ""
    var mOrderId = ""
    var mGrandTotalCart = "0.00"
    @IBOutlet weak var mDepositePercent: UILabel!
    var mDepositPercents = "100"
    var mGrandTotalAmounts = "0.00"
    var mTotalDepositAmounts = "0.00"
    var mOutStandingAmounts = "0.00"
    
    @IBOutlet weak var mCartTable: UITableView!
    var mCartData = NSMutableArray()
    var mCartDataMaster = NSArray()
    var mQuantityData = [Int]()
    var mCurrentIndex = -1
    let mDatePicker:UIDatePicker = UIDatePicker()
    var isItemsAvailable =  false
    var isDeleted = false
    var mCartTotalAmount = ""
    
    @IBOutlet weak var mSubmitBUTTON: UIButton!
    @IBOutlet weak var mGrandTotalLABEL: UILabel!
    @IBOutlet weak var mAddDepositLABEL: UILabel!
    @IBOutlet weak var mCustomerLABEL: UILabel!
    @IBOutlet weak var mHeadingLABEL: UILabel!
    
    // Address Selection Variables
    var mSelectedBillingAddress: [String: Any] = [:]
    var mSelectedShippingAddress: [String: Any] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
        self.mCartTable.delegate = self
        self.mCartTable.dataSource = self
        self.mCartTable.reloadData()
        mCustomerId  = UserDefaults.standard.string( forKey: "DEFAULTCUSTOMER") ?? ""
        mCurrency = UserDefaults.standard.string( forKey: "currencySymbol") ?? "$"
        mGrandTotal.text = self.mCurrency + "0.00"
    }
    
    @IBAction func mOpenProductStoneDetails(_ sender: UIButton) { }
    override func viewWillDisappear(_ animated: Bool) { }
    
    override func viewWillAppear(_ animated: Bool) {
        mGrandTotal.text = "\(UserDefaults.standard.value(forKey: "currencySymbol") ?? "$") 0.00"
        mDepositAmount.text = mGrandTotal.text
        mOutstandingAmount.text = mGrandTotal.text
        mSubmitBUTTON.setTitle("SUBMIT".localizedString, for: .normal)
        mGrandTotalLABEL.text = "Grand Total".localizedString
        mAddDepositLABEL.text = "Deposit".localizedString
        mCustomerLABEL.text = "Customer".localizedString
        mHeadingLABEL.text = "Deposit".localizedString

        mGetData(url: mFetchPaymentMethod, headers:sGisHeaders,  params: ["":""]) { response , status in
            if status {
                if let mData = response.value(forKey: "data") as? NSDictionary {
                    if let mCashData = mData.value(forKey: "Cash") as? NSArray {
                        if mCashData.count > 0 {
                            if let mData = mCashData[0] as? NSDictionary {
                                UserDefaults.standard.set(mData, forKey: "CASHDATA")
                            }
                        }
                    }
                    if let mCreditCard = mData.value(forKey: "Credit_Card") as? NSArray {
                        if mCreditCard.count > 0 {
                            UserDefaults.standard.set(mCreditCard, forKey: "CREDITCARDDATA")
                        }else{UserDefaults.standard.set(nil, forKey: "CREDITCARDDATA")}
                    }else{UserDefaults.standard.set(nil, forKey: "CREDITCARDDATA")}
                    
                    if let mBankData = mData.value(forKey: "Bank") as? NSArray {
                        if mBankData.count > 0 {
                            UserDefaults.standard.set(mBankData, forKey: "BANKDATA")
                        }else{UserDefaults.standard.set(nil, forKey: "BANKDATA")}
                    }else{UserDefaults.standard.set(nil, forKey: "BANKDATA")}
                }
            }
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
            self.getCustomerAddressList()
        }
    }
    
    @IBAction func mSearchCart(_ sender: Any) { }
    
    func mGetPaymentInfo(items: NSMutableDictionary) {
        if let mCartItems = UserDefaults.standard.object(forKey: "TEMPDATA") as? NSMutableArray {
            mAddItems(items: items)
        }else{
            mAddItems(items: items)
        }
    }
    
    func mAddItems(items: NSMutableDictionary){
        let mData = items
        if let isCash = mData.value(forKey: "isCash") as? Bool {
            if isCash{
                if let mSellData = mData.value(forKey: "payment_info") as? NSDictionary {
                    if let mPayData = mSellData.value(forKey: "pay_data") as? NSDictionary {
                        if let mCashData = mPayData.value(forKey: "cash") as? NSDictionary {
                            self.mCartData.add(mCashData)
                        }
                    }
                }
            }
        }
        if let isBank = mData.value(forKey: "isBank") as? Bool {
            if isBank {
                if let mSellData = mData.value(forKey: "payment_info") as? NSDictionary {
                    if let mPayData = mSellData.value(forKey: "pay_data") as? NSDictionary {
                        if let mBankData = mPayData.value(forKey: "bank") as? NSArray, mBankData.count > 0 {
                            for i in mBankData {
                                if let item = i as? NSDictionary {
                                    self.mCartData.add(item)
                                }
                            }
                        }
                    }
                }
            }
        }
        
        if let isCard = mData.value(forKey: "isCard") as? Bool {
            if isCard {
                if let mSellData = mData.value(forKey: "payment_info") as? NSDictionary {
                    if let mPayData = mSellData.value(forKey: "pay_data") as? NSDictionary {
                        if let mCardData = mPayData.value(forKey: "credit_card") as? NSArray, mCardData.count > 0 {
                            for i in mCardData {
                                if let item = i as? NSDictionary {
                                    self.mCartData.add(item)
                                }
                            }
                        }
                    }
                }
            }
        }
        UserDefaults.standard.set(self.mCartData, forKey: "TEMPDATA")
        self.mCartTable.delegate = self
        self.mCartTable.dataSource = self
        self.mCartTable.reloadData()
    }
    
    @IBAction func mAddMoreDeposit(_ sender: Any) {
        if mCustomerId.isEmpty {
            mOpenCustomerSheet()
            return
        }
        let storyBoard: UIStoryboard = UIStoryboard(name: "customOrder", bundle: nil)
        if let mCheckOut = storyBoard.instantiateViewController(withIdentifier: "AddDepositController") as? AddDepositController {
            mCheckOut.mTotalP = "0.00"
            mCheckOut.mSubTotalP = ""
            mCheckOut.mTaxP = ""
            mCheckOut.mTaxAm = ""
            mCheckOut.mStoreCurrency =  self.mCurrency
            mCheckOut.mOrderType = "deposit"
            mCheckOut.mTaxType =  ""
            mCheckOut.mTotalOutstandingAm = "0.00"
            mCheckOut.mCurrencySymbol = self.mCurrency
            mCheckOut.mCartTotalAmount = "0.00"
            mCheckOut.mDepositPercents = "0"
            mCheckOut.mTotalWithDiscount = "0.00"
            mCheckOut.mTaxPercent =  ""
            mCheckOut.mCustomerId = self.mCustomerId
            mCheckOut.modalPresentationStyle = .overFullScreen
            mCheckOut.delegate = self
            mCheckOut.transitioningDelegate = self
            self.present(mCheckOut,animated: true)
        }
    }
    
    @IBAction func mOpenCustomer(_ sender: Any) { mOpenCustomerSheet() }
    
    @IBAction func mBack(_ sender: Any) {
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
            mCommonPurchaseHistory.mOrderType = "refund_order"
            mCommonPurchaseHistory.mCustomerId = mCustomerId
            mCommonPurchaseHistory.modalPresentationStyle = .overFullScreen
            mCommonPurchaseHistory.transitioningDelegate = self
            self.present(mCommonPurchaseHistory,animated: true)
        }
    }
    
    func mGetInventoryItems(items: [String]) {
        mOrderId = items[0]
        mFetchCartItems()
    }
        
    func mFetchCartItems(){
        let mParams = [ "order_id":mOrderId ,"order_type": "pos_order"] as [String : Any]
        mGetData(url: mFetchCustomProduct, headers: sGisHeaders, params: mParams) { response , status in
            CommonClass.stopLoader()
            if status {
                if "\(response.value(forKey: "code") ?? "")" == "200" {
                    if let mData = response.value(forKey: "data") as? NSArray, mData.count > 0 {
                        self.mCartDataMaster = mData
                        self.mCartData = NSMutableArray(array: mData)
                        self.mCartTable.delegate = self
                        self.mCartTable.dataSource = self
                        self.mQuantityData = [Int]()
                        self.mCartTable.reloadData()
                        for i in self.mCartData {
                            if let mData = i as? NSDictionary,
                               let qty = Int("\(mData.value(forKey: "Qty") ?? "0")") {
                                self.mQuantityData.append(qty)
                            }
                        }
                    }
                }
            }
        }
    }
        
    func uniqueElementsFrom(array:[String]) -> [String] {
        var set = Set<String>()
        let result = array.filter {
            guard !set.contains($0)  else { return  false }
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
        self.getCustomerAddressList()
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
            let mGiftCardMethods = NSMutableDictionary()
            let mBankMethod = NSMutableArray()
            let mChequeMethod = NSMutableDictionary()
            
            self.mFinalPaymentMethod = [String: Any]()
            let mCashMethod = NSMutableDictionary()
            let mCreditNoteMethod = NSMutableDictionary()
            let mDebitedAmount = NSMutableDictionary()
            let mPayData = NSMutableDictionary()
            let mPaymentInfo = NSMutableDictionary()
            let mSummaryOrder = NSMutableDictionary()
            let mSellInfo = NSMutableDictionary()
            
            var mCAmounts = [Double]()
            var mBAmounts = [Double]()
            var mCaAmounts = [Double]()
            
            var mCreditCardFinalData = NSMutableArray()
            var mBankFinalData = NSMutableArray()
            for i in self.mCartData {
                if let mData = i as? NSDictionary {
                    if "\(mData.value(forKey: "Paymentmethod_type") ?? "")" == "cash"{
                        mCAmounts.append(Double("\(mData.value(forKey: "amount") ?? "0.0")".replacingOccurrences(of: ",", with: "")) ?? 0.00)
                    }
                    if "\(mData.value(forKey: "Paymentmethod_type") ?? "")" == "Credit_Card"{
                        mCaAmounts.append(Double("\(mData.value(forKey: "amount") ?? "0.0")".replacingOccurrences(of: ",", with: "")) ?? 0.00)
                        mCreditCardFinalData.add(mData)
                    }
                    if "\(mData.value(forKey: "Paymentmethod_type") ?? "")" == "Bank"{
                        mBAmounts.append(Double("\(mData.value(forKey: "amount") ?? "0.0")".replacingOccurrences(of: ",", with: "")) ?? 0.00)
                        mBankFinalData.add(mData)
                    }
                }
            }
            if let mCashData = UserDefaults.standard.object(forKey: "CASHDATA") as? NSDictionary {
                mCashMethod.setValue("\(mCashData.value(forKey: "id") ?? "")", forKey: "payment_method_id")
                mCashMethod.setValue("cash", forKey: "Paymentmethod_type")
                mCashMethod.setValue(Double("\(mCAmounts.reduce(0, {$0 + $1}))") ?? 0.00, forKey: "amount")
            }
            
            mDebitedAmount.setValue(Double("\(mCAmounts.reduce(0, {$0 + $1}))") ?? 0.00, forKey: "cash")
            mDebitedAmount.setValue(Double("\(mBAmounts.reduce(0, {$0 + $1}))") ?? 0.00, forKey: "bank")
            mDebitedAmount.setValue(Double("\(mCaAmounts.reduce(0, {$0 + $1}))") ?? 0.00, forKey: "credit_card")
            mDebitedAmount.setValue(Double("0") ?? 0.00, forKey: "credit_notes")
            
            mSummaryOrder.setValue(0, forKey: "labour")
            mSummaryOrder.setValue(0, forKey: "shipping")
            mSummaryOrder.setValue(0, forKey: "loyalty_points")
            mSummaryOrder.setValue(0, forKey: "tax_amount")
            mSummaryOrder.setValue(0, forKey: "tax_amount_int")
            mSummaryOrder.setValue(0, forKey: "tax_prect")
            mSummaryOrder.setValue(0, forKey: "tax_type")
            mSummaryOrder.setValue(0, forKey: "discount")
            mSummaryOrder.setValue(0, forKey: "discount_percent")
            
            mSummaryOrder.setValue(self.mCustomerId, forKey: "customer_id")
            mSummaryOrder.setValue(selectedSalesPersonId, forKey: "sales_person_id")
            
            mSummaryOrder.setValue(Int(100), forKey: "deposit")
            mSummaryOrder.setValue(Double(self.mGrandTotalAmounts), forKey: "deposit_amount")
            
            mSummaryOrder.setValue(
                Double(self.mGrandTotalAmounts),
                forKey: "Sub_Total"
            )
            
            mPayData.setValue(mCashMethod, forKey: "cash")
            mPayData.setValue(mBankFinalData, forKey: "bank")
            mPayData.setValue([], forKey: "IB")
            mPayData.setValue(mCreditCardFinalData, forKey: "credit_card")
            mPayData.setValue([], forKey: "credit_note")
            mPayData.setValue("", forKey: "gift_card")
            
            // The Deposit endpoint reads the salesperson from each cart item.
            mSellInfo.setValue(cartWithSelectedSalesPerson(), forKey: "cart")
            mSellInfo.setValue(mSummaryOrder, forKey: "summary_order")
            mSellInfo.setValue("deposit", forKey: "status_type")
            mSellInfo.setValue(Double(self.mGrandTotalAmounts), forKey: "totalamount")
            
            mPaymentInfo.setValue(mDebitedAmount, forKey: "debited_amount")
            mPaymentInfo.setValue(mPayData, forKey: "pay_data")
            mPaymentInfo.setValue(0.0, forKey: "balance_due")
            mPaymentInfo.setValue(Double(self.mGrandTotalAmounts), forKey: "balance_deposit")
            
            let currentDateTime = Date()
            let formatter = DateFormatter()
            formatter.timeStyle = .medium
            formatter.dateStyle = .medium
            
            self.mFinalPaymentMethod = ["sell_info": mSellInfo, "payment_info":mPaymentInfo,"transaction_date": formatter.string(from: currentDateTime),"customer_id":self.mCustomerId,"sales_person_id":selectedSalesPersonId,"byMobile":true,"order_type":"deposit"]
            
            let mQuotationId = UserDefaults.standard.string(forKey: "quotationId") ?? ""
            if !mQuotationId.isEmpty {
                self.mFinalPaymentMethod["quatation_id"] = mQuotationId
            }
            if !mSelectedBillingAddress.isEmpty || !mSelectedShippingAddress.isEmpty {
                self.mFinalPaymentMethod["shipping_info"] = [
                    "billing_address": self.mSelectedBillingAddress,
                    "shipping_address": self.mSelectedShippingAddress
                ]
            }

            CommonClass.showFullLoader(view: self.view)
            print("DEBUG_Deposit_PAYLOAD: \(self.mFinalPaymentMethod)")
            mGetData(url: mFinalCheckoutCustomOrder,headers: sGisHeaders,  params: self.mFinalPaymentMethod) { response , status in
                CommonClass.stopLoader()
                print("DepositController mFinalCheckoutCustomOrder  = \(response)")
                if status {
                    if let mCode =  response.value(forKey: "code") as? Int {
                        if mCode == 400 {
                            CommonClass.showSnackBar(message: "\(response.value(forKey: "message") ?? "OOP's something went wrong!")")
                            return
                        }
                    }
                    if let mData = response.value(forKey: "data") as? NSDictionary {
                        let storyBoard: UIStoryboard = UIStoryboard(name: "posBoard", bundle: nil)
                        if let mCompletePayment = storyBoard.instantiateViewController(withIdentifier: "CompletePayment") as? CompletePayment {
                            mCompletePayment.mTotalQuantity = "\(self.mCartData.count)"
                            mCompletePayment.mCurrency = self.mCurrency
                            mCompletePayment.mDepositPercents = "100"
                            mCompletePayment.mType = "deposit"
                            mCompletePayment.mOrderId =
                                "\(mData.value(forKey: "id") ?? "")"
                            mCompletePayment.mGrandTotalAmount = self.mGrandTotalAmounts
                            mCompletePayment.mUrl = "\(mData.value(forKey: "url") ?? "")"
                            mCompletePayment.mShippingInfo = [
                                "billing_address": self.mSelectedBillingAddress,
                                "shipping_address": self.mSelectedShippingAddress
                            ]
                            self.navigationController?.pushViewController(mCompletePayment, animated:true)
                        }
                    }
                }
            }
        }
    }
        
    @IBAction func mCheckOut(_ sender: UIButton) {
        sender.showAnimation{
            if Double(self.mGrandTotalCart) ?? 0.00 == 0.0 {
                CommonClass.showSnackBar(message: "Please fill valid amount!")
                return
            }
            UserDefaults.standard.setValue("", forKey: "quotationId")
            
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
        
        cell.mRemoveButton.tag = indexPath.row
        if let mData = mCartData[indexPath.row] as? NSDictionary {
            if "\(mData.value(forKey: "Paymentmethod_type") ?? "")" == "Bank"{
                cell.mProductName.text = "Bank"
                cell.mStockId.text = "\(mData.value(forKey: "ref_no") ?? "")"
                cell.mProductImage.image = UIImage(named: "bankGreen")
            }
            if "\(mData.value(forKey: "Paymentmethod_type") ?? "")" == "cash"{
                cell.mProductName.text = "Cash"
                cell.mStockId.text = "--"
                cell.mProductImage.image = UIImage(named: "cashGreen")
            }
            if "\(mData.value(forKey: "Paymentmethod_type") ?? "")" == "Credit_Card"{
                cell.mProductName.text = "Card"
                cell.mStockId.text = "--"
                cell.mProductImage.image = UIImage(named: "cardGreen")
            }
            cell.mCurrency.text = self.mCurrency
            cell.mProductPrice.text = "\(mData.value(forKey: "amount") ?? "")"
        }
        calculateItemsWithAmount()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
        
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.mDeleteRow(index: indexPath.row)
        }
    }
        
    func mDeleteRow(index : Int) {
        self.mCartData.removeObject(at: index)
        self.mCartTable.reloadData()
        UserDefaults.standard.set(self.mCartData, forKey: "TEMPDATA")
        calculateItemsWithAmount()
    }
    
    func mDeleteCartItems(index: Int) {
        self.mCartData.removeObject(at: index)
        self.mCartTable.reloadData()
        UserDefaults.standard.set(self.mCartData, forKey: "TEMPDATA")
        calculateItemsWithAmount()
    }
        
    @IBAction func mRemoveCartItems(_ sender: UIButton) {
        if let mData = mCartData[sender.tag] as? NSDictionary {
            mRemovePopUp.frame = self.view.bounds
            mRemovePopUp.mCustomerId = mCustomerId
            mRemovePopUp.delegate = self
            mRemovePopUp.mType = "deposit"
            mRemovePopUp.index = sender.tag
            mRemovePopUp.mMessage.text = "Are you sure want to remove ?".localizedString
            mRemovePopUp.mCancelButton.setTitle("CANCEL".localizedString, for: .normal)
            mRemovePopUp.mConfirmButton.setTitle("CONFIRM".localizedString, for: .normal)
            self.view.addSubview(mRemovePopUp)
        }
    }

    @IBAction func mEditAmount(_ sender: UITextField) { }
          
    func calculateItemsWithAmount(){
        var mAmounts = [Double]()
        var mQuantities = [Int]()
        for i in mCartData {
            if let mData = i as? NSDictionary {
                let amount = "\(mData.value(forKey: "amount") ?? "0.0")".replacingOccurrences(of: ",", with: "")
                mAmounts.append(Double(amount) ?? 0.00)
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
                default: break
                }
            } catch { }
        }
    }
}
