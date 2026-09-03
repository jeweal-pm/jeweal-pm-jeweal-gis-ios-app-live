//
//  RepeatOrderController.swift
//  GIS
//
//  Created by Apple Hawkscode on 30/03/21.
//

import UIKit
import Alamofire
import DropDown

class RepairOrderController :  UIViewController, UIViewControllerTransitioningDelegate ,GetCustomerDataDelegate , UITableViewDataSource ,UITableViewDelegate, GetInventoryDataItemsDelegate , DeleteCustomCartItems, ConfirmationDelegate , GetQuotationDelegate, ServiceLabourDelegate {
    
    @IBOutlet weak var mSearchField: UITextField!
    
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
    var mCartAmount = [Double]()
    
    var mCurrentIndex = -1
    let mDatePicker:UIDatePicker = UIDatePicker()
    var isItemsAvailable =  false
    var isDeleted = false
    
    @IBOutlet weak var mQuotationCount: UILabel!
    @IBOutlet weak var mQuoteButton: UIButton!
    var isQuotation = false
    var mQuotationId = ""
    
    
    @IBOutlet weak var mQuotationView: UIView!
    
    @IBOutlet weak var mHeadingLABEL: UILabel!
    
    @IBOutlet weak var mCustomerLABEL: UILabel!
    @IBOutlet weak var mOutstandingBalance: UILabel!
    @IBOutlet weak var mDepositeLABEL: UILabel!
    @IBOutlet weak var mGrandTotalLABEL: UILabel!
    @IBOutlet weak var mNoteLABEL: UILabel!
    
    @IBOutlet weak var mCheckOutButton: UIButton!
    
    @IBOutlet weak var mBottomQuotationLABEL: UILabel!
    
    @IBOutlet weak var mBottomHistoryLABEL: UILabel!
    @IBOutlet weak var mBottomCustomerLABEL: UILabel!
    
    
    @IBOutlet weak var mAddressPickerIcon: UIImageView!
    @IBOutlet weak var mAddressPickerAlertIcon: UIImageView!
    
    var mServiceAmounts = [Double]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
        self.mNotes.keyboardType = .default
        self.mCartTable.delegate = self
        self.mCartTable.dataSource = self
        self.mCartTable.reloadData()
       
        mCustomerId  = UserDefaults.standard.string( forKey: "DEFAULTCUSTOMER") ?? ""
        
        
    }
    
    func mGetQuotationData(status:Bool, quotationId: String) {
        self.isQuotation = status
        self.mQuotationId = quotationId
        mFetchCartItems()
    }
    
    @IBAction func mShowQuotation(_ sender: Any) {
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "quotation", bundle: nil)
        if let mCommonQuotations = storyBoard.instantiateViewController(withIdentifier: "CommonQuotations") as? CommonQuotations {
            mCommonQuotations.delegate = self
            mCommonQuotations.mCustomerId = mCustomerId
            mCommonQuotations.modalPresentationStyle = .overFullScreen
            mCommonQuotations.transitioningDelegate = self
            self.present(mCommonQuotations,animated: true)
        }
    }
    
    @IBAction func mQuoteItems(_ sender: Any) {
        if mCartData.count == 0 {
            CommonClass.showSnackBar(message: "Please add items to cart!")
            return
        }
        
        mConfirmQuote.frame = self.view.bounds
        mConfirmQuote.delegate = self
        mConfirmQuote.mNotes.text = ""
        mConfirmQuote.mNotes.placeholder = "Ex : Hold order".localizedString
        mConfirmQuote.mHeadingLabel.text = "Add Note".localizedString
        mConfirmQuote.mSubHeading.text = "Note for the order you want a quotation".localizedString
        mConfirmQuote.mDueDateLABEL.text = "Due Date".localizedString
        mConfirmQuote.mCancelButton.setTitle("CANCEL".localizedString, for: .normal)
        mConfirmQuote.mCreateQuote.setTitle("CREATE A QUOTE".localizedString, for: .normal)
        mConfirmQuote.mNewDate = Date.getCurrentDateGMT()
        mConfirmQuote.mCurrentDate.text = Date.getCurrentDate()
        self.view.addSubview(mConfirmQuote)
    }
    
    
    func mConfirmPayment(date: String, dateInGMT : Date, receiveAmount: String, outstanding: String, noOfReceived: String) {
        
        
        let mSummaryOrder = NSMutableDictionary()
        let mSellInfo = NSMutableDictionary()
        let mCustomerData = NSMutableDictionary()
        mCustomerData.setValue(self.mCustomerId, forKey: "id")
        mCustomerData.setValue(UserDefaults.standard.string(forKey:"DEFAULTCUSTOMERNAME") ?? "User", forKey: "name")
        
        mSummaryOrder.setValue(0, forKey: "labour")
        mSummaryOrder.setValue(0, forKey: "shipping")
        mSummaryOrder.setValue(0, forKey: "loyalty_points")
        mSummaryOrder.setValue(0, forKey: "tax_amount")
        mSummaryOrder.setValue(0, forKey: "tax_amount_int")
        mSummaryOrder.setValue(0, forKey: "tax_prect")
        mSummaryOrder.setValue("", forKey: "tax_type")
        mSummaryOrder.setValue(0, forKey: "discount")
        mSummaryOrder.setValue(0, forKey: "discount_percent")
        mSummaryOrder.setValue(mCustomerData, forKey: "customer_id")
        mSummaryOrder.setValue("", forKey: "sales_person_id")
        mSummaryOrder.setValue(Double(mDepositPercents) ?? 0.00, forKey: "deposit")
        mSummaryOrder.setValue(Double(self.mGrandTotalAmounts) ?? 0.00, forKey: "deposit_amount")
        mSummaryOrder.setValue(Double(self.mGrandTotalAmounts) ?? 0.00, forKey: "Sub_Total")
        
        mSellInfo.setValue(self.mCartData, forKey: "cart")
        mSellInfo.setValue(mSummaryOrder, forKey: "summary_order")
        mSellInfo.setValue("repair_order", forKey: "status_type")
        mSellInfo.setValue(Double(self.mGrandTotalAmounts) ?? 0.00, forKey: "totalamount")
        let  mFinalData = ["sell_info": mSellInfo, "totalamount":self.mGrandTotalAmounts,
                           "order_type":"repair_order",
                           "quatetime": noOfReceived,
                           
                           "duedate":date] as [String : Any]
        CommonClass.showFullLoader(view: self.view)
        
        mGetData(url: mSaveQuotation,headers: sGisHeaders,  params: mFinalData) { response , status in
            if status {
                CommonClass.stopLoader()
                self.mFetchQuote()
                self.mCartDataMaster = NSArray()
                self.mCartData = NSMutableArray()
                self.mQuantityData = [Int]()
                self.mCartAmount = [Double]()
                self.mCartTable.reloadData()
                self.calculateItemsWithAmount()
                CommonClass.showSnackBar(message: "Quotation Added Successfully")
            }
        }
        
    }
    
    
    @IBAction func mOpenAddressPicker(_ sender: Any) {
        if !mCustomerId.isEmpty {
            let storyBoard: UIStoryboard = UIStoryboard(name: "AddressPicker", bundle: nil)
            if let addressPicker = storyBoard.instantiateViewController(withIdentifier: "AddressPicker") as? AddressPicker {
                addressPicker.mCustomerId = mCustomerId
                self.navigationController?.pushViewController(addressPicker, animated: true)
            }
        }
    }
    
    func displayDate(from apiDate: String) -> String {

        let input = ISO8601DateFormatter()
        input.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds
        ]

        guard let date = input.date(from: apiDate) else {
            print("Parse failed:", apiDate)
            return apiDate
        }

        let output = DateFormatter()
        output.locale = Locale(identifier: "en_US_POSIX")
        output.dateFormat = "dd/MM/yyyy"

        return output.string(from: date)
    }
    
    func mGetDatePicker() {
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
        let mDone = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donePick))
        let mSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let mCancel = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(mCancelPick))
        mToolBar.setItems([mCancel, mSpace,mDone], animated: false)
        
        mConfirmQuote.mDueDate.inputAccessoryView = mToolBar
        mConfirmQuote.mDueDate.inputView = mDatePicker
        mConfirmQuote.mDueDate.becomeFirstResponder()
    }
    @objc
    func donePick(){
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "dd/MM/yyyy"

        mConfirmQuote.mCurrentDate.text = formatter.string(from: mDatePicker.date)
        mConfirmQuote.mNewDate = mDatePicker.date
        self.view.endEditing(true)
        
        
    }
    @objc func mCancelPick(){
        self.view.endEditing(true)
    }
    
    
    
    @IBAction func mOpenProductStoneDetails(_ sender: UIButton) {
       
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        mGrandTotal.text = "\(UserDefaults.standard.value(forKey: "currencySymbol") ?? "$") 0.00"
        mDepositAmount.text = mGrandTotal.text
        mOutstandingAmount.text = mGrandTotal.text
        
        mQuoteButton.setTitle("QUOTE".localizedString, for: .normal)
        mCheckOutButton.setTitle("CHECK OUT".localizedString, for: .normal)
        mBottomQuotationLABEL.text = "Quotation".localizedString
        mBottomHistoryLABEL.text = "History".localizedString
        mBottomCustomerLABEL.text = "Customer".localizedString
        mCustomerLABEL.text = "Customer".localizedString
        
        
        mHeadingLABEL.text = "Repair".localizedString
        mNoteLABEL.text = "Note".localizedString
        mGrandTotalLABEL.text = "Grand Total".localizedString
        mDepositeLABEL.text = "Deposit".localizedString
        mOutstandingBalance.text = "Outstanding Balance".localizedString
        
        mTotalItems.text = "0 " + "Item".localizedString
        mNotes.placeholder = "EX. Urgent Order".localizedString
        
        mGetData(url: mFetchPaymentMethod, headers: sGisHeaders,  params: ["":""]) { response , status in
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
        
        if UserDefaults.standard.string(forKey: "cRemark") != nil {
            self.mNotes.text = "\(UserDefaults.standard.string(forKey: "cRemark") ?? "")"
        }
        
        if mCustomerId == "" {
            mOpenCustomerSheet()
        } else {
            mCheckAddresse()
        }
        
        let mParams = ["query":"{stones{id name}colors{id name}metals{id name}shapes{id name}claritys{id name}cuts{id name}sizes{id name}settingType{id name}stonecolors{id name}}"]
        AF.request(mGrapQlUrl, method:.post,parameters: mParams, encoding:JSONEncoding.default, headers: sGisHeaders).responseJSON
        { response in
            if(response.error != nil) {
                UserDefaults.standard.set(nil, forKey: "GRAPHQL")
            }else{
                if let jsonData = response.data {
                    let json = try? JSONSerialization.jsonObject(with: jsonData, options: [])
                    if let jsonResult = json as? NSDictionary {
                        UserDefaults.standard.set(jsonResult, forKey: "GRAPHQL")
                    }
                }
            }
        }

        AF.request(mGetShapes, method:.post,parameters: nil, headers: sGisHeaders).responseJSON
        { response in
            if(response.error != nil) {
                UserDefaults.standard.set(nil, forKey: "SHAPES")
            }else{
                if let jsonData = response.data {
                    let json = try? JSONSerialization.jsonObject(with: jsonData, options: [])
                    if let jsonResult = json as? NSDictionary {
                        UserDefaults.standard.set(jsonResult, forKey: "SHAPES")
                    }
                }
            }
        }
        
        mCustomerId  = UserDefaults.standard.string( forKey: "DEFAULTCUSTOMER") ?? ""
        if !mCustomerId.isEmpty {
            self.mSelectedCustomerIcon.image = UIImage(named: "selected_customer")
            self.mCustomerImage.contentMode = .scaleAspectFill
            self.mCustomerImage.downlaodImageFromUrl(urlString: UserDefaults.standard.string( forKey: "DEFAULTCUSTOMERPICTURE") ?? "")
            self.mCustomerName.text = UserDefaults.standard.string( forKey: "DEFAULTCUSTOMERNAME") ?? ""
            mFetchCartItems()
        }
        
        let isQuotation = UserDefaults.standard.bool(forKey: "isQuotation")
        mQuotationView.isHidden = !isQuotation
        mQuoteButton.isHidden = !isQuotation

        if isQuotation {
            mFetchQuote()
        } else {
            self.mQuotationView.isHidden = true
            self.mQuoteButton.isHidden = true
        }
    }
    
    
    func mFetchQuote(){
        
        mGetData(url: mGetAllQuotations, headers: sGisHeaders,  params: ["customer_id":self.mCustomerId]) { response , status in
            if status {
                if let mData = response.value(forKey: "data") as? NSArray {
                    if mData.count > 0 {
                        self.mQuotationCount.text = "\(mData.count)"
                    }else{
                        self.mQuotationCount.text = "\(mData.count)"
                    }
                }
            }
        }
        
    }
    
    @IBAction func mSearchCart(_ sender: Any) {}
    
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
        self.isQuotation = false
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "moreBoard", bundle: nil)
        if let mCommonPurchaseHistory = storyBoard.instantiateViewController(withIdentifier: "CommonPurchaseHistory") as? CommonPurchaseHistory {
            mCommonPurchaseHistory.delegate =  self
            mCommonPurchaseHistory.mOrderType = "repair_order"
            mCommonPurchaseHistory.mCustomerId = mCustomerId
            mCommonPurchaseHistory.modalPresentationStyle = .overFullScreen
            mCommonPurchaseHistory.transitioningDelegate = self
            self.present(mCommonPurchaseHistory,animated: true)
        }
    }
    
    func mGetInventoryItems(items: [String]) {
        self.isQuotation = false
        mFetchCartItems()
    }
    
    
    
    func mFetchCartItems(){
        
        print("isQuotation =", isQuotation)
        print("quotationId =", self.mQuotationId)
        
        var mParams = [String:Any]()
        if isQuotation {
            mParams = ["quatation_id":self.mQuotationId] as [String : Any]
        }else{
            mParams = [ "customer_id":mCustomerId ,"order_type":"repair_order"] as [String : Any]
            
        }
        
        mGetData(url: mFetchCustomProduct, headers: sGisHeaders,  params: mParams) { response , status in
            CommonClass.stopLoader()
            if status {
                print("mFetchCartItems mFetchCustomProduct response =", response)
                if "\(response.value(forKey: "code") ?? "")" == "200" {
                    if let mData = response.value(forKey: "data") as? NSArray, mData.count > 0 {
                        
//                        self.isQuotation = false
                        self.mCartDataMaster = mData
                        self.mCartData = NSMutableArray(array: mData)
                        self.mCartTable.delegate = self
                        self.mCartTable.dataSource = self
                        self.mQuantityData = [Int]()
                        self.mCartAmount = [Double]()
                        
                        for case let item as NSDictionary in self.mCartData {

                            print("SKU =", item["SKU"] ?? "")

                            print("repair_design =")

                            print(item["repair_design"] ?? "NO REPAIR DESIGN")

                            print("--------------------------------")
                        }
                        
                        print("price =", mData.value(forKey: "price"))
                        print("cart_price =", mData.value(forKey: "cart_price"))
                        print("total_price =", mData.value(forKey: "total_price"))
                        print("cart_total =", mData.value(forKey: "cart_total"))
                        print("product_price =", mData.value(forKey: "product_price"))
                        
                        self.mCartTable.reloadData()
                        for i in self.mCartData {
                            if let mData = i as? NSDictionary {
                                self.mQuantityData.append(Int("\(mData.value(forKey: "Qty") ?? "0")") ?? 0)
                                self.mCartAmount.append(Double("\(mData.value(forKey: "price") ?? "0")") ?? 0.0)
                            }
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
            guard !set.contains($0) else {
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
        self.isQuotation = false
        
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
    
    func mCheckAddresse() {
        
        guard Reachability.isConnectedToNetwork() == true else {
            return
        }

        let params = ["id": mCustomerId] as [String : Any]
        
        AF.request(mCheckAddress, method:.post,parameters: params,encoding: JSONEncoding.default, headers: sGisHeaders).responseJSON { response in
            
            guard let jsonData = response.data else {
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
                   let code = json["code"] as? Int {
                    
                    switch code {
                    case 200:
                        if let haveAddress = json["AddressExists"] as? Bool, haveAddress {
                            self.mAddressPickerIcon.image = UIImage(named: "address_pick_ic_green")
                            self.mAddressPickerAlertIcon.isHidden = true
                        } else {
                            self.mAddressPickerIcon.image = UIImage(named: "address_pick_ic_green")
                            self.mAddressPickerAlertIcon.isHidden = false
                        }
                    case 403:
                        CommonClass.sessionExpired(isExpired: true, navigation: self.navigationController)
                    default:
                        break
                    }
                }
            } catch {
            }
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
        self.isQuotation = false
        
        UserDefaults.standard.setValue(nil, forKey: "CustomerBillingAddressUDID")
        UserDefaults.standard.setValue(nil, forKey: "CustomerShippingAddressUDID")
        
        if let haveAddresses = data.value(forKey: "haveAddresses") as? Bool, haveAddresses {
            mAddressPickerIcon.image = UIImage(named: "address_pick_ic_green")
            mAddressPickerAlertIcon.isHidden = true
        } else {
            mAddressPickerIcon.image = UIImage(named: "address_pick_ic_green")
            mAddressPickerAlertIcon.isHidden = false
        }
        
        mFetchCartItems()
        let isQuotation = UserDefaults.standard.bool(forKey: "isQuotation")
        if isQuotation {
            mFetchQuote()
        }
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
    
    
    @IBAction func mCheckOut(_ sender: UIButton) {
        sender.showAnimation{
            if self.mCartData.count == 0 {
                CommonClass.showSnackBar(message: "No items in cart!")
                return
            }
            
            guard self.mAddressPickerAlertIcon.isHidden else {
                CommonClass.showSnackBar(message: "Add Billing and Shipping address")
                return
            }

            let storyBoard: UIStoryboard = UIStoryboard(name: "customOrder", bundle: nil)
            if let mCheckOut = storyBoard.instantiateViewController(withIdentifier: "CustomOrderCheckout") as? CustomOrderCheckout {
                mCheckOut.mTotalP = self.mTotalDepositAmounts
                mCheckOut.mSubTotalP = ""
                mCheckOut.mTaxP = ""
                mCheckOut.mTaxAm = ""
                mCheckOut.mStoreCurrency =  self.mCurrency
                mCheckOut.mOrderType = "repair_order"
                mCheckOut.mNote = self.mNotes.text ?? ""
                mCheckOut.mRemark = UserDefaults.standard.string(forKey: "cRemark") ?? ""
//                mCheckOut.mRemark = self.mNotes.text ?? ""
                mCheckOut.mTaxType =  ""
                mCheckOut.mTaxLabel =  ""
                mCheckOut.mLabourPoints = Int(self.mServiceAmounts.reduce(0, {$0 + $1}))
                
                mCheckOut.mTotalOutstandingAm = self.mOutStandingAmounts
                mCheckOut.mCurrencySymbol = self.mCurrency
                mCheckOut.mCartTotalAmount = self.mGrandTotalCart
                mCheckOut.mDepositPercents = self.mDepositPercents
                mCheckOut.mTotalWithDiscount =  self.mTotalDepositAmounts
                mCheckOut.mTaxPercent =  ""
                mCheckOut.mCustomerId = self.mCustomerId
                mCheckOut.mCartTableData =  self.mCartData
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
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCartItems") as? CustomCartItems,
              let mData = mCartData[indexPath.row] as? NSDictionary else {
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
        cell.mEditServiceLabourButton.tag = indexPath.row
        cell.mShowServiceLabourButton.tag = indexPath.row
        
        let isServiceLabour = UserDefaults.standard.bool(forKey: "isServiceLabour")
        if isServiceLabour {
            
            if let mServiceLabourStatus =  mData.value(forKey: "Service_labour_exsist") as? Bool {
                mServiceLabourStatus ? (cell.mEditServiceLabourIcon.tintColor = UIColor(named:"themeColor")) : (cell.mEditServiceLabourIcon.tintColor = UIColor(named:"theme6A"))
                
                cell.mServiceLabourView.isHidden = false
                if mServiceLabourStatus {
                    if let mServiceLabour = mData.value(forKey: "Service_labour") as? NSDictionary {
                        if let mServiceItem = mServiceLabour.value(forKey: "service_laburelist") as? NSArray {
                            if mServiceItem.count > 0 {
                                
                                cell.mServiceLabourCount.text = "Service Labour".localizedString + " (\(mServiceItem.count))"
                                var mAmounts = [Double]()
                                for i in mServiceItem {
                                    if let items = i as? NSDictionary {
                                        mAmounts.append(Double("\(items.value(forKey: "scrviceamount") ?? "0.0")".replacingOccurrences(of: ",", with: "")) ?? 0.00)
                                    }
                                }
                                cell.mServiceLabourCharges.text = self.mCurrency + " " + String(format:"%.02f",locale:Locale.current,mAmounts.reduce(0, {$0 + $1}))
                                
                            }else{
                                cell.mServiceLabourCharges.text = self.mCurrency + " 0.00"
                                cell.mServiceLabourCount.text = "Service Labour".localizedString + " (0)"
                            }
                        }
                    }
                    
                }else{
                    cell.mServiceLabourCharges.text = self.mCurrency + " 0.00"
                    cell.mServiceLabourCount.text = "Service Labour".localizedString + " (0)"
                }
            }else{
                cell.mServiceLabourView.isHidden = true
            }
        }else{
            cell.mServiceLabourView.isHidden = true
        }
        
        if let mCustomDesignStatus = mData.value(forKey: "repair_editable") as? Int {
            if mCustomDesignStatus == 1 {
                cell.mEditIcon.image = UIImage(named: "repair-pliers")
                cell.mEditIcon.tintColor = UIColor(named: "themeColor")
            }else{
                cell.mEditIcon.image = UIImage(named: "repair-pliers")
                cell.mEditIcon.tintColor = UIColor(named: "themeExtraLightText")
                
            }
        }
//        cell.mDueDate.text = "\(mData.value(forKey: "delivery_date") ?? "--")"
        print("cellForRowAt delivery_date = \(mData.value(forKey: "delivery_date") ?? "")")
        let rawDate = "\(mData.value(forKey: "delivery_date") ?? "")"
        print("cellForRowAt rawDate = \(rawDate)")
        cell.mDueDate.text = displayDate(from: rawDate)
        print("cellForRowAt cell.mDueDate.text = \(String(describing: cell.mDueDate.text))")
        cell.mCurrency.text = "\(mData.value(forKey: "currency") ?? "$")"
        self.mCurrency = "\(mData.value(forKey: "currency") ?? "$") "
        cell.mRemarks.keyboardType = .default
        cell.mRemarks.text = "\(mData.value(forKey: "remark") ?? "")"
        cell.mSKUName.text = "\(mData.value(forKey: "SKU") ?? "")"
        cell.mProductName.text = "\(mData.value(forKey: "name") ?? "")"
        cell.mMetalColorSize.text = "\(mData.value(forKey: "color_name") ?? "") " + "\(mData.value(forKey: "metal_name") ?? "") " + "\(mData.value(forKey: "size_name") ?? "")"
//        cell.mProductPrice.text = "\(mData.value(forKey: "price") ?? "")"
        cell.mProductPrice.textAlignment = .right
        cell.mProductPrice.contentHorizontalAlignment = .right
        cell.mProductPrice.text = "\(mData.value(forKey: "currency") ?? "$") \(mData.value(forKey: "price") ?? "0.0")"
        cell.mCurrency.isHidden = true
        cell.mStockId.text = "\(mData.value(forKey: "stock_id") ?? "")"

        cell.mProductImage.downlaodImageFromUrl(urlString: "\(mData.value(forKey: "main_image") ?? "")")
        cell.mProductImage.tag = indexPath.row
        cell.imageTapGesture(target: self, action: #selector(handleImageTap(_:)))
        
        calculateItemsWithAmount()
        
        return cell
    }
    
    @objc func handleImageTap(_ sender: UITapGestureRecognizer) {
        guard let imageView = sender.view as? UIImageView else {
            return
        }
        let index = imageView.tag
        if let mData = mCartData[index] as? NSDictionary {
            let productId = "\(mData.value(forKey: "id") ?? "")"
            let sku = "\(mData.value(forKey: "SKU") ?? "")"
            mOpenGlobalImageViewer(mProductIdForImage: productId, mSKUForImage: sku)
        }
    }
    
    func mOpenGlobalImageViewer(mProductIdForImage: String , mSKUForImage: String){
        if mProductIdForImage != "" {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Test", bundle: nil)
            if let mGlobalImageViewer = storyBoard.instantiateViewController(withIdentifier: "GlobalImageViewer") as? GlobalImageViewer {
                mGlobalImageViewer.modalPresentationStyle = .overFullScreen
                mGlobalImageViewer.mProductId = mProductIdForImage
                mGlobalImageViewer.mSKUName = mSKUForImage
                mGlobalImageViewer.transitioningDelegate = self
                self.present(mGlobalImageViewer,animated: false)
            }
        }
    }
    
    func mRemoveServiceLabour() {
        mFetchCartItems()
    }
    func mConfirmServiceLabour(data: NSDictionary) {
        mFetchCartItems()
    }
    
    
    @IBAction func mShowServiceLabour(_ sender: UIButton) {
        if let mData = self.mCartData[sender.tag] as? NSDictionary {
            
            if let mServiceData = mData.value(forKey: "Service_labour") as? NSDictionary {
                let storyBoard: UIStoryboard = UIStoryboard(name: "laybyInstallment", bundle: nil)
                if let mSelectedServiceLabour = storyBoard.instantiateViewController(withIdentifier: "SelectedServiceLabour") as? SelectedServiceLabour {
                    mSelectedServiceLabour.modalPresentationStyle = .automatic
                    mSelectedServiceLabour.mProductData = mServiceData
                    mSelectedServiceLabour.transitioningDelegate = self
                    self.present(mSelectedServiceLabour,animated: true)
                }
            }
        }
    }

    @IBAction func mEditServiceLabour(_ sender: UIButton) {
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "laybyInstallment", bundle: nil)
        if let mCommonServiceLabour = storyBoard.instantiateViewController(withIdentifier: "CommonServiceLabour") as? CommonServiceLabour,
           let productData = self.mCartData[sender.tag] as? NSDictionary {
            mCommonServiceLabour.modalPresentationStyle = .overFullScreen
            mCommonServiceLabour.delegate = self
            mCommonServiceLabour.mProductData = productData
            mCommonServiceLabour.transitioningDelegate = self
            self.present(mCommonServiceLabour,animated: true)
        }
    }

    @IBAction func mMinusButton(_ sender: UIButton) {
        
        let index = sender.tag
        guard let mInvData = mCartData[index] as? NSDictionary,
              let cells = mCartTable.cellForRow(at: IndexPath(row: sender.tag , section: 0)) as? CustomCartItems else {
            return
        }
        
        let mOrgData = mCartDataMaster[sender.tag] as? NSDictionary
        let mMinQty = 1
        var mCurrentQty = Int(cells.mQuantityUnit.text ?? "") ?? 0
        print("mCurrentQty = \(mCurrentQty)")
        print("mMinQty = \(mMinQty)")
        if  mCurrentQty == mMinQty {
            return
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
        mData.setValue(mInvData.value(forKey: "repair_editable") ?? false, forKey: "repair_editable")
        mData.setValue(mInvData.value(forKey: "cart_price") ?? "", forKey: "cart_price")
        mData.setValue(mInvData.value(forKey: "metal_id") ?? "", forKey: "metal_id")
        mData.setValue(mInvData.value(forKey: "size_id") ?? "", forKey: "size_id")
        mData.setValue(mInvData.value(forKey: "parentCartId") ?? "", forKey: "parentCartId")
//        mData.setValue(mInvData.value(forKey: "po_QTY") ?? "", forKey: "po_QTY")
        if let productDetails = mInvData["product_details"] as? NSDictionary {

            mData.setValue(
                "\(productDetails["po_QTY"] ?? "")",
                forKey: "po_QTY"
            )

        } else {

            mData.setValue(
                "\(mInvData["po_QTY"] ?? "")",
                forKey: "po_QTY"
            )
        }
        mData.setValue(mInvData.value(forKey: "product_id") ?? "", forKey: "product_id")
        if let mStockData = mInvData.value(forKey: "stock_id_options") as? NSArray {
            mData.setValue(mStockData, forKey: "stock_id_options")
        }else{
            mData.setValue([], forKey: "stock_id_options")
        }
        
        if let mServiceLabourStatus =  mInvData.value(forKey: "Service_labour_exsist") as? Bool {
            if mServiceLabourStatus {
                mData.setValue(mServiceLabourStatus, forKey: "Service_labour_exsist")
                if let mServiceLabour = mInvData.value(forKey: "Service_labour") as? NSDictionary {
                    mData.setValue(mServiceLabour, forKey: "Service_labour")
                }
            }else{
                mData.setValue(false, forKey: "Service_labour_exsist")
            }
        }
        
        mCartData.removeObject(at: index)
        mCartData.insert(mData, at: index)
        mCartTable.reloadData()
        calculateItemsWithAmount()
        
    }
    
    
    @IBAction func mPlusButton(_ sender: UIButton) {
        let index = sender.tag
        
        let mOrgData = mCartDataMaster[sender.tag] as? NSDictionary
        guard let mInvData = mCartData[index] as? NSDictionary,
           let cells = mCartTable.cellForRow(at: IndexPath(row: sender.tag , section: 0)) as? CustomCartItems else {
            return
        }
        let mMaxQty =  Int("\(mInvData.value(forKey: "qtyToBe") ?? "1")") ?? 1
        var mCurrentQty = Int(cells.mQuantityUnit.text ?? "") ?? 0
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
        
        
        mData.setValue(mInvData.value(forKey: "repair_editable") ?? false, forKey: "repair_editable")
        
        mData.setValue(mInvData.value(forKey: "cart_price") ?? "", forKey: "cart_price")
        mData.setValue(mInvData.value(forKey: "metal_id") ?? "", forKey: "metal_id")
        mData.setValue(mInvData.value(forKey: "size_id") ?? "", forKey: "size_id")
        mData.setValue(mInvData.value(forKey: "parentCartId") ?? "", forKey: "parentCartId")
//        mData.setValue(mInvData.value(forKey: "po_QTY") ?? "", forKey: "po_QTY")
        if let productDetails = mInvData["product_details"] as? NSDictionary {

            mData.setValue(
                "\(productDetails["po_QTY"] ?? "")",
                forKey: "po_QTY"
            )

        } else {

            mData.setValue(
                "\(mInvData["po_QTY"] ?? "")",
                forKey: "po_QTY"
            )
        }
        mData.setValue(mInvData.value(forKey: "product_id") ?? "", forKey: "product_id")
        
        if let mServiceLabourStatus =  mInvData.value(forKey: "Service_labour_exsist") as? Bool {
            if mServiceLabourStatus {
                mData.setValue(mServiceLabourStatus, forKey: "Service_labour_exsist")
                if let mServiceLabour = mInvData.value(forKey: "Service_labour") as? NSDictionary {
                    mData.setValue(mServiceLabour, forKey: "Service_labour")
                }
            }else{
                mData.setValue(false, forKey: "Service_labour_exsist")
            }
        }
        if let mStockData = mInvData.value(forKey: "stock_id_options") as? NSArray {
            mData.setValue(mStockData, forKey: "stock_id_options")
        }else{
            mData.setValue([], forKey: "stock_id_options")
        }
        
        mCartData.removeObject(at: index)
        mCartData.insert(mData, at: index)
        mCartTable.reloadData()

        calculateItemsWithAmount()
    }
    
    
    
    
    
    @IBAction func mChooseDate(_ sender: UIButton) {
        guard let cells = mCartTable.cellForRow(at: IndexPath(row: sender.tag , section: 0)) as? CustomCartItems else {
            return
        }
        
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
    
    @objc
    func doneDatePick(){
//        let formatter = DateFormatter()
//        formatter.locale = Locale(identifier: "en_US_POSIX")
//        formatter.dateFormat = "dd/MM/yyyy"
        
        let displayFormatter = DateFormatter()
        displayFormatter.calendar = Calendar(identifier: .gregorian)
        displayFormatter.locale = Locale(identifier: "en_US_POSIX")
        displayFormatter.dateFormat = "dd/MM/yyyy"

//        let deliveryDate = formatter.string(from: mDatePicker.date)
        
        guard let cell1 = mCartTable.cellForRow(at: IndexPath(row: mCurrentIndex, section: 0)) as? CustomCartItems else {
            return
        }
        cell1.mDueDate.text = displayFormatter.string(from: mDatePicker.date)
        guard let mInvData = mCartData[mCurrentIndex] as? NSDictionary else {
            return
        }
        guard let cells = mCartTable.cellForRow(at: IndexPath(row: mCurrentIndex , section: 0)) as? CustomCartItems else {
            return
        }
        var mData = NSMutableDictionary()
        mData.setValue("\(mInvData.value(forKey: "id") ?? "")", forKey: "id")
        mData.setValue("\(mInvData.value(forKey: "type") ?? "")", forKey: "type")
        mData.setValue("\(mInvData.value(forKey: "qtyToBe") ?? "")", forKey: "qtyToBe")
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
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        mData.setValue(
            isoFormatter.string(from: mDatePicker.date),
            forKey: "delivery_date"
        )
//        mData.setValue(delivery_date, forKey: "delivery_date")
        mData.setValue(mInvData.value(forKey: "repair_editable") ?? false, forKey: "repair_editable")
        
        mData.setValue(mInvData.value(forKey: "cart_price") ?? "0", forKey: "cart_price")
        mData.setValue(mInvData.value(forKey: "metal_id") ?? "", forKey: "metal_id")
        mData.setValue(mInvData.value(forKey: "size_id") ?? "", forKey: "size_id")
        mData.setValue(mInvData.value(forKey: "parentCartId") ?? "", forKey: "parentCartId")
//        mData.setValue(mInvData.value(forKey: "po_QTY") ?? "", forKey: "po_QTY")
        if let productDetails = mInvData["product_details"] as? NSDictionary {

            mData.setValue(
                "\(productDetails["po_QTY"] ?? "")",
                forKey: "po_QTY"
            )

        } else {

            mData.setValue(
                "\(mInvData["po_QTY"] ?? "")",
                forKey: "po_QTY"
            )
        }
        mData.setValue(mInvData.value(forKey: "product_id") ?? "", forKey: "product_id")
        
        if let mServiceLabourStatus =  mInvData.value(forKey: "Service_labour_exsist") as? Bool {
            if mServiceLabourStatus {
                mData.setValue(mServiceLabourStatus, forKey: "Service_labour_exsist")
                if let mServiceLabour = mInvData.value(forKey: "Service_labour") as? NSDictionary {
                    mData.setValue(mServiceLabour, forKey: "Service_labour")
                }
            }else{
                mData.setValue(false, forKey: "Service_labour_exsist")
            }
        }
        
        if let mStockData = mInvData.value(forKey: "stock_id_options") as? NSArray {
            mData.setValue(mStockData, forKey: "stock_id_options")
        }else{
            mData.setValue([], forKey: "stock_id_options")
        }
        mCartData.removeObject(at: mCurrentIndex)
        mCartData.insert(mData, at: mCurrentIndex)
        
        self.view.endEditing(true)
        
        
    }
    @objc func mCancelDatePick(){
        self.view.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            guard let mData = mCartData[indexPath.row] as? NSDictionary else {
                return
            }
            CommonClass.showFullLoader(view: self.view)
            let mParams = [ "customer_id": mCustomerId , "custom_cart_id": mData.value(forKey: "custom_cart_id") as? String ?? ""] as [String : Any]
            
            mGetData(url: mDeleteCartItem, headers: sGisHeaders,  params: mParams) { response , status in
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
    
    func mDeleteRow(index : Int) {
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
        guard let mData = mCartData[sender.tag] as? NSDictionary else { return }
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
    
    @IBAction func mEditAmount(_ sender: UITextField) {
        guard let mInvData = mCartData[sender.tag] as? NSDictionary,
              let mOrgData = mCartDataMaster[sender.tag] as? NSDictionary,
              let cells = mCartTable.cellForRow(at: IndexPath(row: sender.tag , section: 0)) as? CustomCartItems else {
            return
        }
        
        cells.mQuantityUnit.text = "1"
        if sender.text == "" || sender.text == "0" {
            
            cells.mProductPrice.text = ""
            var mData = NSMutableDictionary()
            mData.setValue("0", forKey: "price")
            self.mCartAmount.remove(at: sender.tag)
            self.mCartAmount.insert(0.0, at: sender.tag)
            mData.setValue("\(mInvData.value(forKey: "id") ?? "")", forKey: "id")
            mData.setValue("\(mInvData.value(forKey: "type") ?? "")", forKey: "type")
            mData.setValue("\(mInvData.value(forKey: "qtyToBe") ?? "")", forKey: "qtyToBe")
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
            
            mData.setValue(mInvData.value(forKey: "repair_editable") ?? false, forKey: "repair_editable")
            mData.setValue(mInvData.value(forKey: "cart_price") ?? "", forKey: "cart_price")
            mData.setValue(mInvData.value(forKey: "metal_id") ?? "", forKey: "metal_id")
            mData.setValue(mInvData.value(forKey: "size_id") ?? "", forKey: "size_id")
            mData.setValue(mInvData.value(forKey: "parentCartId") ?? "", forKey: "parentCartId")
//            mData.setValue(mInvData.value(forKey: "po_QTY") ?? "", forKey: "po_QTY")
            if let productDetails = mInvData["product_details"] as? NSDictionary {

                mData.setValue(
                    "\(productDetails["po_QTY"] ?? "")",
                    forKey: "po_QTY"
                )

            } else {

                mData.setValue(
                    "\(mInvData["po_QTY"] ?? "")",
                    forKey: "po_QTY"
                )
            }
            mData.setValue(mInvData.value(forKey: "product_id") ?? "", forKey: "product_id")
            
            if let mServiceLabourStatus =  mInvData.value(forKey: "Service_labour_exsist") as? Bool {
                if mServiceLabourStatus {
                    mData.setValue(mServiceLabourStatus, forKey: "Service_labour_exsist")
                    if let mServiceLabour = mInvData.value(forKey: "Service_labour") as? NSDictionary {
                        mData.setValue(mServiceLabour, forKey: "Service_labour")
                    }
                }else{
                    mData.setValue(false, forKey: "Service_labour_exsist")
                }
            }
            if let mStockData = mInvData.value(forKey: "stock_id_options") as? NSArray {
                mData.setValue(mStockData, forKey: "stock_id_options")
            }else{
                mData.setValue([], forKey: "stock_id_options")
            }
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
        mData.setValue("\(mInvData.value(forKey: "type") ?? "")", forKey: "type")
        mData.setValue("\(mInvData.value(forKey: "Qty") ?? "")", forKey: "Qty")
        mData.setValue("\(mInvData.value(forKey: "qtyToBe") ?? "")", forKey: "qtyToBe")
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
        mData.setValue(mInvData.value(forKey: "repair_editable") ?? false, forKey: "repair_editable")
        mData.setValue(mInvData.value(forKey: "cart_price") ?? "", forKey: "cart_price")
        mData.setValue(mInvData.value(forKey: "metal_id") ?? "", forKey: "metal_id")
        mData.setValue(mInvData.value(forKey: "size_id") ?? "", forKey: "size_id")
        mData.setValue(mInvData.value(forKey: "parentCartId") ?? "", forKey: "parentCartId")
//        mData.setValue(mInvData.value(forKey: "po_QTY") ?? "", forKey: "po_QTY")
        if let productDetails = mInvData["product_details"] as? NSDictionary {

            mData.setValue(
                "\(productDetails["po_QTY"] ?? "")",
                forKey: "po_QTY"
            )

        } else {

            mData.setValue(
                "\(mInvData["po_QTY"] ?? "")",
                forKey: "po_QTY"
            )
        }
        mData.setValue(mInvData.value(forKey: "product_id") ?? "", forKey: "product_id")
        
        
        if let mServiceLabourStatus =  mInvData.value(forKey: "Service_labour_exsist") as? Bool {
            if mServiceLabourStatus {
                mData.setValue(mServiceLabourStatus, forKey: "Service_labour_exsist")
                if let mServiceLabour = mInvData.value(forKey: "Service_labour") as? NSDictionary {
                    mData.setValue(mServiceLabour, forKey: "Service_labour")
                }
            }else{
                mData.setValue(false, forKey: "Service_labour_exsist")
            }
        }
        
        if let mStockData = mInvData.value(forKey: "stock_id_options") as? NSArray {
            mData.setValue(mStockData, forKey: "stock_id_options")
        }else{
            mData.setValue([], forKey: "stock_id_options")
        }
        mCartData.removeObject(at: sender.tag)
        mCartData.insert(mData, at: sender.tag)
        calculateItemsWithAmount()
        
    }
    
    @IBAction func mEditremarks(_ sender: UITextField) {
        
        guard let mInvData = mCartData[sender.tag] as? NSDictionary,
              let cells = mCartTable.cellForRow(at: IndexPath(row: sender.tag , section: 0)) as? CustomCartItems else { return }
        
        var mData = NSMutableDictionary()
        mData.setValue("\(mInvData.value(forKey: "id") ?? "")", forKey: "id")
        mData.setValue("\(mInvData.value(forKey: "order_type") ?? "")", forKey: "order_type")
        mData.setValue("\(mInvData.value(forKey: "Qty") ?? "")", forKey: "Qty")
        mData.setValue("\(mInvData.value(forKey: "qtyToBe") ?? "")", forKey: "qtyToBe")
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
        mData.setValue("\(mInvData.value(forKey: "currency") ?? "")", forKey: "currency")
        mData.setValue("\(mInvData.value(forKey: "delivery_date") ?? "")", forKey: "delivery_date")
        mData.setValue(mInvData.value(forKey: "repair_editable") ?? false, forKey: "repair_editable")
        
        mData.setValue(mInvData.value(forKey: "cart_price") ?? "", forKey: "cart_price")
        mData.setValue(mInvData.value(forKey: "metal_id") ?? "", forKey: "metal_id")
        mData.setValue(mInvData.value(forKey: "size_id") ?? "", forKey: "size_id")
        mData.setValue(mInvData.value(forKey: "parentCartId") ?? "", forKey: "parentCartId")
//        mData.setValue(mInvData.value(forKey: "po_QTY") ?? "", forKey: "po_QTY")
        if let productDetails = mInvData["product_details"] as? NSDictionary {

            mData.setValue(
                "\(productDetails["po_QTY"] ?? "")",
                forKey: "po_QTY"
            )

        } else {

            mData.setValue(
                "\(mInvData["po_QTY"] ?? "")",
                forKey: "po_QTY"
            )
        }
        mData.setValue(mInvData.value(forKey: "product_id") ?? "", forKey: "product_id")
        
        if let mServiceLabourStatus =  mInvData.value(forKey: "Service_labour_exsist") as? Bool {
            if mServiceLabourStatus {
                mData.setValue(mServiceLabourStatus, forKey: "Service_labour_exsist")
                if let mServiceLabour = mInvData.value(forKey: "Service_labour") as? NSDictionary {
                    mData.setValue(mServiceLabour, forKey: "Service_labour")
                }
            }else{
                mData.setValue(false, forKey: "Service_labour_exsist")
            }
        }
        if let mStockData = mInvData.value(forKey: "stock_id_options") as? NSArray {
            mData.setValue(mStockData, forKey: "stock_id_options")
        }else{
            mData.setValue([], forKey: "stock_id_options")
        }
        mCartData.removeObject(at: sender.tag)
        mCartData.insert(mData, at: sender.tag)
        
    }
    
    @IBAction func mOpenDesign(_ sender: UIButton) {
        self.isQuotation = false
        
        UserDefaults.standard.setValue("\(mNotes.text ?? "")", forKey: "cRemark")
        let storyBoard: UIStoryboard = UIStoryboard(name: "moreBoard", bundle: nil)
        
        let mIndex = sender.tag
        guard let mData = mCartData[mIndex] as? NSDictionary,
              let mCustomDesign = storyBoard.instantiateViewController(withIdentifier: "RepairDesign") as? RepairDesign else { return }
        mCustomDesign.mData = mData
        mCustomDesign.mCustomerId = self.mCustomerId
        mCustomDesign.mCartId = "\(mData.value(forKey: "custom_cart_id") ?? "")"
        if let mCustomDesignStatus = mData.value(forKey: "repair_editable") as? Int {
            if mCustomDesignStatus == 1 {
                mCustomDesign.mStatus = "1"
            }else{
                mCustomDesign.mStatus = "0"
            }
        } else {
            mCustomDesign.mStatus = "0"
        }
        self.navigationController?.pushViewController(mCustomDesign, animated:true)
    }
    
    
    func calculateItemsWithAmount(){
        var mAmounts = [Double]()
        var mQuantities = [Int]()
        mServiceAmounts = [Double]()
        for i in mCartData {
            if let mData = i as? NSDictionary {
                mQuantities.append(Int("\(mData.value(forKey: "Qty") ?? "0")") ?? 0 )
                mAmounts.append(Double("\(mData.value(forKey: "price") ?? "0.0")".replacingOccurrences(of: ",", with: "")) ?? 0.00)
                
                if let mServiceLabourStatus =  mData.value(forKey: "Service_labour_exsist") as? Bool {
                    
                    if mServiceLabourStatus {
                        if let mServiceLabour = mData.value(forKey: "Service_labour") as? NSDictionary {
                            if let mServiceItem = mServiceLabour.value(forKey: "service_laburelist") as? NSArray {
                                if mServiceItem.count > 0 {
                                    var mAmounts = [Double]()
                                    for i in mServiceItem {
                                        if let items = i as? NSDictionary {
                                            let scrviceamount = items.value(forKey: "scrviceamount") ?? "0.0"
                                            mAmounts.append(Double("\(scrviceamount)".replacingOccurrences(of: ",", with: "")) ?? 0.00)
                                        }
                                    }
                                    mServiceAmounts.append(mAmounts.reduce(0, {$0 + $1}) )
                                }else{
                                }
                            }
                        }
                        
                    }
                }
            }
        }
        mTotalItems.text = "\(mCartData.count) items"
        mGrandTotal.text = self.mCurrency + String(format:"%.02f",locale:Locale.current,(mAmounts.reduce(0, {$0 + $1}) + mServiceAmounts.reduce(0, {$0 + $1}) ))
        
        mGrandTotalCart = "\((mAmounts.reduce(0, {$0 + $1}) + mServiceAmounts.reduce(0, {$0 + $1}) ))"
        self.mGrandTotalAmounts = "\((mAmounts.reduce(0, {$0 + $1}) + mServiceAmounts.reduce(0, {$0 + $1}) ))"
        if mDepositPercents == "100" {
            mDepositAmount.text = mGrandTotal.text
            mOutstandingAmount.text = self.mCurrency + "0.00"
            self.mOutStandingAmounts = "0.00"
            self.mTotalDepositAmounts = self.mGrandTotalAmounts
            
        }else{
            let mTotalValue = (mAmounts.reduce(0, {$0 + $1}) + mServiceAmounts.reduce(0, {$0 + $1}) )
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

