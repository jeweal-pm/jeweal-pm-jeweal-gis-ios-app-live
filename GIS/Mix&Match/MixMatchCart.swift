//
//  MixMatchCart.swift
//  GIS
//
//  Created by MacBook Hawkscode  on 9/02/23.
//  Copyright © 2023 Hawkscode. All rights reserved.
//

import UIKit
import Alamofire
import DropDown

class DiamondCartItems : UITableViewCell {
    
    @IBOutlet weak var mCarats: UILabel!
    @IBOutlet weak var mRemoveButton: UIButton!
    @IBOutlet weak var mCurrency: UILabel!
    @IBOutlet weak var mProductName: UILabel!
    @IBOutlet weak var mProductPrice: UITextField!

    @IBOutlet weak var mProductImage: UIImageView!
    @IBOutlet weak var mStockId: UILabel!
 
    @IBOutlet weak var mView: UIView!
    @IBOutlet weak var mSNView: UIView!
    @IBOutlet weak var mImageHolderView: UIView!
    @IBOutlet weak var mSNo: UILabel!
    @IBOutlet weak var mShapeName: UILabel!
    @IBOutlet weak var mPickStockId: UIButton!
    @IBOutlet weak var mRemarksView: UIView!
    
    func diamondImageTapGesture(target: Any, action: Selector) {
        let tapGesture = UITapGestureRecognizer(target: target, action: action)
        mProductImage.isUserInteractionEnabled = true
        mProductImage.addGestureRecognizer(tapGesture)
    }
    
}

class MixMatchCart: UIViewController, UIViewControllerTransitioningDelegate, UIGestureRecognizerDelegate ,GetCustomerDataDelegate , UITableViewDataSource ,UITableViewDelegate, GetMInventoryDataItemsDelegate , DeleteCustomCartItems, OpenCustomerMixMatchDelegate,GetDiamondData, GetSelectedDiamondDelegate , GetCatalogData, GetCatalogDetailsDelegate, EditProductDelegate , SearchDelegate, ConfirmationDelegate , GetQuotationDelegate, ServiceLabourDelegate, UITextFieldDelegate {
    
    var mServiceAmounts = [Double]()


    // MARK: - Quote Suggestions
    // Suggestions are shown only after the user taps the Quote Note field.
    // After selecting a suggestion, the list stays hidden until the user
    // clears the field with the built-in X button.
    private let quoteSuggestions = [
        "Valid for 1 week",
        "Price subject to design changes",
        "Review before confirmation",
        "Custom engraving included"
    ]

    private var quoteSuggestionsView: UIView?
    private var quoteSuggestionsStack: UIStackView?
    private var quoteSuggestionsTargetsInstalled = false
    private var quoteSuggestionsSuppressedAfterSelection = false

    private func quoteFont(_ size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        if weight == .bold {
            return UIFont(name: "segoe_bold", size: size)
                ?? UIFont.systemFont(ofSize: size, weight: weight)
        }

        return UIFont(name: "segoe_regular", size: size)
            ?? UIFont.systemFont(ofSize: size, weight: weight)
    }

    // Creates the Suggestions popup and installs Note-field events.
    // IMPORTANT: this function does NOT show the popup.
    private func setupQuoteSuggestions() {
        guard let textField = mConfirmQuote.mNotes else {
            return
        }

        // Note field styling.
        // Design requested a small radius rather than a heavily rounded field.
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 3
        textField.layer.borderWidth = 0.5
        textField.layer.borderColor = UIColor(
            red: 204.0 / 255.0,
            green: 204.0 / 255.0,
            blue: 204.0 / 255.0,
            alpha: 1.0
        ).cgColor
        textField.layer.masksToBounds = true

        textField.clearButtonMode = .whileEditing
        textField.delegate = self

        if !quoteSuggestionsTargetsInstalled {
            textField.addTarget(
                self,
                action: #selector(quoteNoteEditingChanged(_:)),
                for: .editingChanged
            )
            textField.addTarget(
                self,
                action: #selector(quoteNoteEditingBegan(_:)),
                for: .editingDidBegin
            )
            textField.addTarget(
                self,
                action: #selector(quoteNoteEditingEnded(_:)),
                for: .editingDidEnd
            )
            quoteSuggestionsTargetsInstalled = true
        }

        // Create the popup only once.
        if quoteSuggestionsView == nil {
            let popup = UIView()
            popup.backgroundColor = .white
            popup.layer.cornerRadius = 8
            popup.layer.masksToBounds = false
            popup.layer.shadowColor = UIColor.black.cgColor
            popup.layer.shadowOpacity = 0.12
            popup.layer.shadowRadius = 8
            popup.layer.shadowOffset = CGSize(width: 0, height: 2)
            popup.translatesAutoresizingMaskIntoConstraints = false
            popup.isHidden = true

            let title = UILabel()
            title.text = "Suggestions"
            title.textColor = .black
            title.font = quoteFont(10, weight: .bold)
            title.translatesAutoresizingMaskIntoConstraints = false

            let stack = UIStackView()
            stack.axis = .vertical
            stack.alignment = .fill
            stack.distribution = .fill
            stack.spacing = 0
            stack.translatesAutoresizingMaskIntoConstraints = false

            popup.addSubview(title)
            popup.addSubview(stack)
            mConfirmQuote.addSubview(popup)

            NSLayoutConstraint.activate([
                popup.leadingAnchor.constraint(equalTo: textField.leadingAnchor),
                popup.trailingAnchor.constraint(equalTo: textField.trailingAnchor),
                popup.bottomAnchor.constraint(equalTo: textField.topAnchor, constant: -8),

                title.topAnchor.constraint(equalTo: popup.topAnchor, constant: 12),
                title.leadingAnchor.constraint(equalTo: popup.leadingAnchor, constant: 16),
                title.trailingAnchor.constraint(equalTo: popup.trailingAnchor, constant: -16),
                title.heightAnchor.constraint(equalToConstant: 18),

                stack.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 4),
                stack.leadingAnchor.constraint(equalTo: popup.leadingAnchor, constant: 8),
                stack.trailingAnchor.constraint(equalTo: popup.trailingAnchor),
                stack.bottomAnchor.constraint(equalTo: popup.bottomAnchor, constant: -8)
            ])

            quoteSuggestionsView = popup
            quoteSuggestionsStack = stack
        }

        // Do not show Suggestions when the Quote dialog first opens.
        quoteSuggestionsView?.isHidden = true
    }

    private func showQuoteSuggestions() {
        guard let textField = mConfirmQuote.mNotes else {
            return
        }

        guard !quoteSuggestionsSuppressedAfterSelection else {
            quoteSuggestionsView?.isHidden = true
            return
        }

        updateQuoteSuggestions(for: textField.text ?? "")
    }

    private func updateQuoteSuggestions(for text: String) {
        guard let popup = quoteSuggestionsView,
              let stack = quoteSuggestionsStack else {
            return
        }

        // Once a suggestion has been selected, keep the popup hidden
        // until the user clears the Note field.
        if quoteSuggestionsSuppressedAfterSelection {
            popup.isHidden = true
            return
        }

        stack.arrangedSubviews.forEach {
            stack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        let query = text.trimmingCharacters(in: .whitespacesAndNewlines)

        // Empty text = show all suggestions.
        // Typed text = show only matching suggestions.
        let filtered = query.isEmpty
            ? quoteSuggestions
            : quoteSuggestions.filter {
                $0.localizedCaseInsensitiveContains(query)
            }

        // No match = hide the entire popup, including the title.
        guard !filtered.isEmpty else {
            popup.isHidden = true
            return
        }

        for suggestion in filtered {
            let button = UIButton(type: .system)
            button.setTitle(suggestion, for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.titleLabel?.font = quoteFont(13)
            button.contentHorizontalAlignment = .left

            // Move options slightly to the right so they do not line up
            // directly under the "Suggestions" title.
            button.contentEdgeInsets = UIEdgeInsets(
                top: 0,
                left: 16,
                bottom: 0,
                right: 16
            )

            button.backgroundColor = .white
            button.heightAnchor.constraint(equalToConstant: 40).isActive = true
            button.addTarget(
                self,
                action: #selector(quoteSuggestionTapped(_:)),
                for: .touchUpInside
            )

            stack.addArrangedSubview(button)
        }

        popup.isHidden = false
        mConfirmQuote.layoutIfNeeded()
        mConfirmQuote.bringSubviewToFront(popup)
    }

    private func hideQuoteSuggestions() {
        quoteSuggestionsView?.isHidden = true
    }

    @objc private func quoteNoteEditingBegan(_ textField: UITextField) {
        // First tap into Note = show Suggestions.
        showQuoteSuggestions()
    }

    @objc private func quoteNoteEditingChanged(_ textField: UITextField) {
        let text = textField.text ?? ""

        // When the field becomes empty, hide Suggestions immediately.
        // The field also resigns so the keyboard disappears.
        if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            quoteSuggestionsSuppressedAfterSelection = false
            hideQuoteSuggestions()
            textField.resignFirstResponder()
            mConfirmQuote.endEditing(true)
            return
        }

        // Keep Suggestions hidden after a suggestion was selected.
        if quoteSuggestionsSuppressedAfterSelection {
            hideQuoteSuggestions()
            return
        }

        updateQuoteSuggestions(for: text)
    }

    @objc private func quoteSuggestionTapped(_ sender: UIButton) {
        guard let textField = mConfirmQuote.mNotes else {
            return
        }

        textField.text = sender.currentTitle ?? ""

        // Selection closes Suggestions and keeps them closed until X clears it.
        quoteSuggestionsSuppressedAfterSelection = true
        hideQuoteSuggestions()

        // Keep the keyboard active so the user can continue editing the note.
        textField.becomeFirstResponder()
    }

    @objc private func quoteNoteEditingEnded(_ textField: UITextField) {
        hideQuoteSuggestions()
    }

    // Built-in UITextField clear (X) handler.
    // Clear immediately, close Suggestions, hide keyboard and remove focus.
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        guard textField === mConfirmQuote.mNotes else {
            return true
        }

        textField.text = ""
        quoteSuggestionsSuppressedAfterSelection = false

        hideQuoteSuggestions()
        textField.resignFirstResponder()
        mConfirmQuote.endEditing(true)

        // Return false because we already cleared the text ourselves.
        return false
    }

    var isQuotation = false
    var mQuotationId = ""
    @IBOutlet weak var mQuotationCount: UILabel!
    @IBOutlet weak var mQuoteButton: UIButton!
    @IBOutlet weak var mQuotationView: UIView!

    var mGrandTotalCart = "0.00"

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
    var mKey = ""
    

    @IBOutlet weak var mDepositePercent: UILabel!
    var mDepositPercents = "100"
    var mGrandTotalAmounts = "0.00"
    var mTotalDepositAmounts = "0.00"
    var mOutStandingAmounts = "0.00"
    @IBOutlet weak var mCartTable: UITableView!
    var mCartData = NSMutableArray()
    var mCartDataMaster = NSArray()

    
    var mCount = 0

    var mQuantityData = [Int]()
    var mCurrentIndex = -1
    let mDatePicker:UIDatePicker = UIDatePicker()
    var isItemsAvailable =  false
    var isDeleted = false
    
    
    //Address Selection
    @IBOutlet weak var mAddressPickerIcon: UIImageView!
    @IBOutlet weak var mAddressPickerAlertIcon: UIImageView!
    
    
    @IBOutlet weak var mHeadingLABEL: UILabel!
    
    @IBOutlet weak var mOutstandingBalance: UILabel!
    @IBOutlet weak var mDepositeLABEL: UILabel!
    @IBOutlet weak var mGrandTotalLABEL: UILabel!
    @IBOutlet weak var mNoteLABEL: UILabel!
    
    @IBOutlet weak var mCheckOutButton: UIButton!
    
    @IBOutlet weak var mBottomQuotationLABEL: UILabel!
    
    @IBOutlet weak var mBottomCustomerLABEL: UILabel!
    @IBOutlet weak var mBottomCatalogLABEL: UILabel!
    @IBOutlet weak var mBottomInventoryLABEL: UILabel!
    
    // MARK: - Keyboard / Quote Suggestions Dismiss

    @objc private func dismissKeyboardOnTap(_ gesture: UITapGestureRecognizer) {
        // The Quote dialog is an overlay, so explicitly dismiss both the
        // keyboard and the Suggestions popup.
        hideQuoteSuggestions()
        mConfirmQuote.mNotes?.resignFirstResponder()
        mConfirmQuote.endEditing(true)
        self.view.endEditing(true)
    }

    private func installKeyboardDismissGesture(on view: UIView) {
        if view.gestureRecognizers?.contains(where: {
            $0.name == "MixMatchKeyboardDismissTap"
        }) == true {
            return
        }

        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboardOnTap(_:))
        )
        tap.name = "MixMatchKeyboardDismissTap"
        tap.cancelsTouchesInView = false
        tap.delegate = self
        view.addGestureRecognizer(tap)
        view.isUserInteractionEnabled = true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // Tapping inside the Note field must keep editing active.
        var currentView: UIView? = touch.view
        while let view = currentView {
            if view is UITextField {
                return false
            }
            currentView = view.superview
        }

        // Do not interfere with buttons. Blank UIView/UILabel/TableView areas
        // are still handled by the dismiss gesture.
        if touch.view is UIButton {
            return false
        }

        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Main page: tap blank space to hide keyboard + Suggestions.
        installKeyboardDismissGesture(on: self.view)
        
        mGrandTotal.text = "\(UserDefaults.standard.value(forKey: "currencySymbol") ?? "$") 0.00"
        mDepositAmount.text = mGrandTotal.text
        mOutstandingAmount.text = mGrandTotal.text

        self.mNotes.keyboardType = .default
        self.mCartTable.delegate = self
        self.mCartTable.dataSource = self
        self.mCartTable.reloadData()
        
        UserDefaults.standard.setValue(self.mQuotationId, forKey: "quotationId")
        print("MixMatchCart viewDidLoad mQuotationId: \(self.mQuotationId)")
        
        mCustomerId  = UserDefaults.standard.string( forKey: "DEFAULTCUSTOMER") ?? ""
        if !mCustomerId.isEmpty {
            self.mSelectedCustomerIcon.image = UIImage(named: "selected_customer")
        }
        
        let mParams:[String: Any] = ["type": "mixAndMatch"]
        
        mGetData(url: mGetItemType,headers:sGisHeaders, params: mParams) { response , status in
             if status {
                if "\(response.value(forKey: "code") ?? "400")" == "200" {
                 
                    if let mData = response.value(forKey: "data") as? NSArray {
                        
                    UserDefaults.standard.setValue(mData, forKey: "ITEMTYPE")

                    }
                    
                }else{
          
            }
        }
    }

        if mKey == "1"{
 
             mFetchCartItems()
        }
        if mCustomerId != "" {
             mFetchCartItems()
        }
        
        
    }
     
    // ✨ รับและแนบ Quotation ID ลง UserDefaults เลย ป้องกันบั๊กค่าตกหล่น ✨
    func mGetQuotationData(status:Bool, quotationId: String) {
        self.isQuotation = status
        self.mQuotationId = quotationId
        UserDefaults.standard.setValue(self.mQuotationId, forKey: "quotationId")
        print("DEBUG: หน้า MixMatchCart ได้รับ QuotationID มาแล้วคือ: \(self.mQuotationId)")
        mFetchCartItems()
    }
    
    @IBAction func mOpenAddressPicker(_ sender: Any) {
        mOpenAddressPicker()
    }
    
    func mOpenAddressPicker(){
        if !mCustomerId.isEmpty {
            let storyBoard: UIStoryboard = UIStoryboard(name: "AddressPicker", bundle: nil)
            if let addressPicker = storyBoard.instantiateViewController(withIdentifier: "AddressPicker") as? AddressPicker {
                addressPicker.mCustomerId = mCustomerId
                self.navigationController?.pushViewController(addressPicker, animated: true)
            }
        }
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

        if let quoteNoteField = mConfirmQuote.mNotes {
            quoteNoteField.text = ""
            quoteNoteField.placeholder = "Ex : Hold order".localizedString
            quoteNoteField.resignFirstResponder()
        }

        // Reset the Quote Suggestions state for a new Quote dialog.
        quoteSuggestionsSuppressedAfterSelection = false

        mConfirmQuote.mHeadingLabel.text = "Add Note".localizedString
        mConfirmQuote.mSubHeading.text = "Note for the order you want a quotation".localizedString
        mConfirmQuote.mDueDateLABEL.text = "Due Date".localizedString
        mConfirmQuote.mCancelButton.setTitle("CANCEL".localizedString, for: .normal)
        mConfirmQuote.mCreateQuote.setTitle("CREATE A QUOTE".localizedString, for: .normal)
        mConfirmQuote.mNewDate = Date.getCurrentDateGMT()
        mConfirmQuote.mCurrentDate.text = Date.getCurrentDate()
        self.view.addSubview(mConfirmQuote)

        // mConfirmQuote is added as an overlay after viewDidLoad. Install a
        // second gesture directly on it so blank areas inside the Quote dialog
        // also dismiss the keyboard and Suggestions immediately.
        installKeyboardDismissGesture(on: mConfirmQuote)

        // Prepare the Suggestions popup, but do NOT show it and do NOT
        // activate the Note field until the user taps the Note field.
        setupQuoteSuggestions()
        hideQuoteSuggestions()
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
            mSellInfo.setValue("mix_and_match", forKey: "status_type")
            mSellInfo.setValue(Double(self.mGrandTotalAmounts) ?? 0.00, forKey: "totalamount")
        let  mFinalData = ["sell_info": mSellInfo, "totalamount":self.mGrandTotalAmounts,
                           "order_type":"mix_and_match",
                           "quatetime": noOfReceived,"duedate":date] as [String : Any]
        CommonClass.showFullLoader(view: self.view)
        
        
            mGetData(url: mSaveQuotation,headers: sGisHeaders, params: mFinalData) { response , status in
                if status {
                    CommonClass.stopLoader()
                    self.mFetchQuote()
                    self.mCartDataMaster = NSArray()
                    self.mCartData = NSMutableArray()
                    self.mQuantityData = [Int]()
                     self.mCartTable.reloadData()
                    self.calculateItemsWithAmount()
                    CommonClass.showSnackBar(message: "Quotation Added Successfully")

                }
        }
        
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
    
    
//    func mGetSearchItems(id: String) {
//    func mGetSearchItems(id: String, locationId: String) {
    func mGetSearchItems(id: String, locationId: String, type: String) {
 
        self.isQuotation = false

    }
    
    @IBAction func mSearchnow(_ sender: Any) {
        self.isQuotation = false
        let storyBoard: UIStoryboard = UIStoryboard(name: "Test", bundle: nil)
        if let mCommonSearch = storyBoard.instantiateViewController(withIdentifier: "CommonSearch") as? CommonSearch {
            mCommonSearch.modalPresentationStyle = .overFullScreen
            mCommonSearch.delegateCatalog = self
            mCommonSearch.mType = "catalog"
            mCommonSearch.mFrom = "mixAndMatch"
            
            mCommonSearch.transitioningDelegate = self
            self.present(mCommonSearch,animated: false)
        }
    }
    
    
    @IBAction func mOpenProductStoneDetails(_ sender: UIButton) {
        let mIndex = sender.tag
        
        if let mData = mCartData[mIndex] as? NSDictionary {
            let storyBoard: UIStoryboard = UIStoryboard(name: "common", bundle: nil)
            if let home = storyBoard.instantiateViewController(withIdentifier: "ProductStoneEdit") as? ProductStoneEdit {
                
                home.modalPresentationStyle = .automatic
                home.mCartId = "\(mData.value(forKey: "custom_cart_id") ?? "")"
                home.mCustomerId = mCustomerId
                home.mOrderType = "mix_and_match"
                home.mProductIds = "\(mData.value(forKey: "product_id") ?? "")"
                home.delegate = self
                home.transitioningDelegate = self
                self.present(home,animated: true)
            }
        }
    }
    
    func mOnUpdated(data: NSDictionary) {
        self.isQuotation = false

        mFetchCartItems()

    }

    override func viewWillDisappear(_ animated: Bool) {
   
    }
    override func viewWillAppear(_ animated: Bool) {
            
          
        
        
        mQuoteButton.setTitle("QUOTE".localizedString, for: .normal)
        mCheckOutButton.setTitle("CHECK OUT".localizedString, for: .normal)
        mBottomQuotationLABEL.text = "Quotation".localizedString
        mBottomCatalogLABEL.text = "Catalog".localizedString
        mBottomInventoryLABEL.text = "Inventory".localizedString
        mBottomCustomerLABEL.text = "Customer".localizedString

        
        mHeadingLABEL.text = "Mix & Match".localizedString
        mNoteLABEL.text = "Note".localizedString
        mGrandTotalLABEL.text = "Grand Total".localizedString
        mDepositeLABEL.text = "Deposit".localizedString
        mOutstandingBalance.text = "Outstanding Balance".localizedString
        
        mTotalItems.text = "0 " + "Item".localizedString
        mSearchField.placeholder = "Search by SKU / Stock ID".localizedString
        mNotes.placeholder = "EX. Urgent Order".localizedString
        
        
        

        mGetData(url: mFetchPaymentMethod,headers: sGisHeaders, params: ["":""]) { response , status in
            if status {
                if let mData = response.value(forKey: "data") as? NSDictionary {
                    print("DEBUG_PAYMENT_DATA mGetData(url: mFetchPaymentMethod =", mData)
                    //Store Cash Data
                    if let mCashData = mData.value(forKey: "Cash") as? NSArray,
                       mCashData.count > 0,
                       let mData = mCashData[0] as? NSDictionary {
                        UserDefaults.standard.set(mData, forKey: "CASHDATA")
                    }
                    
                    //Store Credit Card Data
                    if let mCreditCard = mData.value(forKey: "Credit_Card") as? NSArray,
                       mCreditCard.count > 0 {
                            UserDefaults.standard.set(mCreditCard, forKey: "CREDITCARDDATA")
                    } else {
                        UserDefaults.standard.set(nil, forKey: "CREDITCARDDATA")
                    }
                  
                    //Store Bank Data
                    if let mBankData = mData.value(forKey: "Bank") as? NSArray,
                       mBankData.count > 0 {
                            UserDefaults.standard.set(mBankData, forKey: "BANKDATA")
                    } else {
                        UserDefaults.standard.set(nil, forKey: "BANKDATA")
                    }
                    
                    
                }
            }
        }
        
        if UserDefaults.standard.string(forKey: "cRemark") != nil {
            self.mNotes.text = "\(UserDefaults.standard.string(forKey: "cRemark") ?? "")"
        }
        if mCustomerId == "" {
            mOpenCustomerSheet()
        } else {
            self.mCheckAddresse()
        }
        
        
        
        let mParams = ["query":"{stones{id name}colors{id name}metals{id name}shapes{id name}claritys{id name}cuts{id name}sizes{id name}settingType{id name}stonecolors{id name}}"]
        
        
        AF.request(mGrapQlUrl, method:.post,parameters: mParams,encoding:JSONEncoding.default, headers: sGisHeaders).responseJSON
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
        
        let isQuotation = UserDefaults.standard.bool(forKey: "isQuotation")
        self.mQuotationView.isHidden = !isQuotation
        self.mQuoteButton.isHidden = !isQuotation
        if isQuotation {
            mFetchQuote()
        }
        
    }
    
    func mFetchQuote(){
        
          mGetData(url: mGetAllQuotations,headers: sGisHeaders, params: ["customer_id":self.mCustomerId]) { response , status in
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
    @IBAction func mSearchCart(_ sender: Any) {
    }
    
    
    @IBAction func mOpenCustomer(_ sender: Any) {
      
         mOpenCustomerSheet()
    }
    
    @IBAction func mBack(_ sender: Any) {
        if mKey.isEmpty {
            self.navigationController?.popViewController(animated: true)
        }else{
            let storyBoard: UIStoryboard = UIStoryboard(name: "reserveBoard", bundle: nil)
            if let home = storyBoard.instantiateViewController(withIdentifier: "HomePage1") as? HomePage {
                self.navigationController?.pushViewController(home, animated:true)
            }
        }
    }
    
    func mGetCatalogItemDetails(data: NSDictionary) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "mixNMatch", bundle: nil)
        if let mMixAndMatchDesign = storyBoard.instantiateViewController(withIdentifier: "MixAndMatchDesign") as? MixAndMatchDesign {
            mMixAndMatchDesign.mJewelryProductId = "\(data.value(forKey: "product_id") ?? "")"
            mMixAndMatchDesign.mJewelryData = data
            self.navigationController?.pushViewController(mMixAndMatchDesign, animated:false)
        }
    }
    
    func mGetCatalogItem(data: NSDictionary, type: String) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "common", bundle: nil)
        if let mMixAndMatchCatalogDetails = storyBoard.instantiateViewController(withIdentifier: "MixAndMatchCatalogDetails") as? MixAndMatchCatalogDetails {
            mMixAndMatchCatalogDetails.mData = data
            mMixAndMatchCatalogDetails.mType = type
            mMixAndMatchCatalogDetails.delegate = self
            mMixAndMatchCatalogDetails.modalPresentationStyle = .overFullScreen
            mMixAndMatchCatalogDetails.transitioningDelegate = self
            self.present(mMixAndMatchCatalogDetails,animated: false)
        }
    }

    @IBAction func mCatalog(_ sender: Any) {
        if mCustomerId == "" {
            CommonClass.showSnackBar(message: "Please choose customer first!")
            mOpenCustomerSheet()
            return
        }
        let storyBoard: UIStoryboard = UIStoryboard(name: "common", bundle: nil)
        if  let mMixAndMatchCatalog = storyBoard.instantiateViewController(withIdentifier: "MixAndMatchCatalog") as? MixAndMatchCatalog {
            mMixAndMatchCatalog.delegate = self
            mMixAndMatchCatalog.modalPresentationStyle = .overFullScreen
            mMixAndMatchCatalog.transitioningDelegate = self
            self.present(mMixAndMatchCatalog,animated: false)
        }
    }

    func mFetchCartItems(){
 
         var mParams = [String:Any]()
        if isQuotation {
            mParams = ["quatation_id":self.mQuotationId] as [String : Any]
        }else{
            mParams = [ "customer_id":mCustomerId ,"custom_data": mCartData] as [String : Any]
        }
        
        mGetData(url: mFetchCustomProduct,headers: sGisHeaders, params: mParams) { response , status in
            CommonClass.stopLoader()
            if status {
                if "\(response.value(forKey: "code") ?? "")" == "200" {
                    if let mData = response.value(forKey: "data") as? NSArray, mData.count > 0 {
                        print("DEBUG_CART_RESPONSE MixMatchCart.swift = \(mData)")
                        self.isQuotation = mParams["quatation_id"] != nil
                        self.mCount = 0
                        self.mCartDataMaster = mData
                        self.mCartData = NSMutableArray(array: mData)
                        self.mCartTable.delegate = self
                        self.mCartTable.dataSource = self
                        self.mQuantityData = [Int]()
                        self.mCartTable.reloadData()
                        
                    }else{
                        self.mCartData = NSMutableArray()
                        self.mCartTable.reloadData()
                        self.calculateItemsWithAmount()
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
    
//    func mGetInventoryItems(data: NSDictionary) {
//
//        let storyBoard: UIStoryboard = UIStoryboard(name: "mixNMatch", bundle: nil)
//        if let mMixAndMatchDesign = storyBoard.instantiateViewController(withIdentifier: "MixAndMatchDesign") as? MixAndMatchDesign {
//            mMixAndMatchDesign.mJewelryProductId = "\(data.value(forKey: "product_id") ?? "")"
//            mMixAndMatchDesign.mJewelryData = data
//            mMixAndMatchDesign.mCustomerId = mCustomerId
//            self.navigationController?.pushViewController(mMixAndMatchDesign, animated:false)
//        }
//    }
    
    func mGetInventoryItems(data: NSDictionary) {

        print("ENTER mGetInventoryItems")
        print("DATA =", data)

        let storyBoard = UIStoryboard(name: "mixNMatch", bundle: nil)

        guard let mMixAndMatchDesign =
            storyBoard.instantiateViewController(
                withIdentifier: "MixAndMatchDesign"
            ) as? MixAndMatchDesign else {

            print("Cannot create MixAndMatchDesign")
            return
        }

        print("CREATE VC OK")

        mMixAndMatchDesign.mJewelryProductId =
            "\(data.value(forKey: "product_id") ?? "")"

        mMixAndMatchDesign.mJewelryData = data
        mMixAndMatchDesign.mCustomerId = mCustomerId

        print("PUSH VC")

        self.navigationController?.pushViewController(
            mMixAndMatchDesign,
            animated: false
        )

        print("PUSH FINISH")
    }
    
    func mGetPickedDiamond (data: NSDictionary, type: String) {
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "mixNMatch", bundle: nil)
        if let mMixAndMatchDesign = storyBoard.instantiateViewController(withIdentifier: "MixAndMatchDesign") as? MixAndMatchDesign {
            mMixAndMatchDesign.mCustomerId = mCustomerId
            mMixAndMatchDesign.mDiamondProductId = "\(data.value(forKey: "id") ?? "")"
            mMixAndMatchDesign.mDiamondData = data
            mMixAndMatchDesign.mItemTypeId = type
            self.navigationController?.pushViewController(mMixAndMatchDesign, animated:false)
        }
    }
    
    func mGetSelectedDiamond(items: String) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "mixNMatch", bundle: nil)
        if let mDiamondProductDetails = storyBoard.instantiateViewController(withIdentifier: "MixAndMatchDiamondDetails") as? MixAndMatchDiamondDetails {
            mDiamondProductDetails.modalPresentationStyle = .overFullScreen
            mDiamondProductDetails.delegate =  self
            mDiamondProductDetails.isFirst = "1"
            mDiamondProductDetails.mProductId = items
            mDiamondProductDetails.transitioningDelegate = self
            self.present(mDiamondProductDetails,animated: false)
        }
    }
    
    func mOnClickItem(controller: String) {
        print("ENTER mOnClickItem :", controller)
        if controller == "jewelry" {
            print("CREATE STORYBOARD")
            let storyBoard: UIStoryboard = UIStoryboard(name: "common", bundle: nil)
            if let mMixAndMatchJewelry = storyBoard.instantiateViewController(withIdentifier: "MixAndMatchJewelry") as? MixAndMatchJewelry {
                print("PRESENT VC")
                mMixAndMatchJewelry.modalPresentationStyle = .overFullScreen
                mMixAndMatchJewelry.delegate =  self
                mMixAndMatchJewelry.mCustomerId = mCustomerId
                mMixAndMatchJewelry.transitioningDelegate = self
                self.present(mMixAndMatchJewelry,animated: false)
                print("PRESENT FINISH")
            }
            else {
                       print("VC NIL")
                   }
        }else{
            let storyBoard: UIStoryboard = UIStoryboard(name: "common", bundle: nil)
            
            if let mInv = storyBoard.instantiateViewController(withIdentifier: "MixAndMatchDiamond") as? MixAndMatchDiamond {
                mInv.modalPresentationStyle = .overFullScreen
                mInv.delegate =  self
                mInv.transitioningDelegate = self
                self.present(mInv,animated: false)
            }
        }
    }
    @IBAction func mInventory(_ sender: Any) {
        if mCustomerId == "" {
            CommonClass.showSnackBar(message: "Please choose customer first!")
            mOpenCustomerSheet()
            return
        }
        let storyBoard: UIStoryboard = UIStoryboard(name: "mixNMatch", bundle: nil)
        if let mOpenCustomAndMixMatch = storyBoard.instantiateViewController(withIdentifier: "OpenJewelryAndDiamond") as? OpenJewelryAndDiamond {
            mOpenCustomAndMixMatch.modalPresentationStyle = .overFullScreen
            mOpenCustomAndMixMatch.delegate = self
            print("MixMatchCart AFTER SET =", mOpenCustomAndMixMatch.delegate as Any)
            mOpenCustomAndMixMatch.transitioningDelegate = self
            self.present(mOpenCustomAndMixMatch,animated: false)
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
                guard let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
                    return
                }
                guard let code = json["code"] as? Int else {
                    return
                }

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
            } catch {
            }
        }
        
    }
    
    func mGetCustomerData(data: NSMutableDictionary) {
        
        UserDefaults.standard.set(data.value(forKey: "id") as? String ?? "", forKey: "DEFAULTCUSTOMER")
        UserDefaults.standard.set(data.value(forKey: "profile") ?? "", forKey: "DEFAULTCUSTOMERPICTURE")
        UserDefaults.standard.set(data.value(forKey: "name") as? String ?? "", forKey: "DEFAULTCUSTOMERNAME")
        
        self.mCustomerId = data.value(forKey: "id") as? String ?? ""
        self.mSelectedCustomerIcon.image = UIImage(named: "selected_customer")
        
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
            if Double(self.mGrandTotalCart) ?? 0.00 == 0.0 {
                CommonClass.showSnackBar(message: "Please fill valid amount!")
                return
            }
            
            guard self.mAddressPickerAlertIcon.isHidden else {
                CommonClass.showSnackBar(message: "Add Billing and Shipping address")
                return
            }
            
            // ✨ แนบ Quotation ID ลง UserDefaults ยืนยันอีกรอบก่อนเปิดหน้า Checkout ✨
            UserDefaults.standard.setValue(self.mQuotationId, forKey: "quotationId")
            print("MixMatchCart.swift mQuotationId: \(self.mQuotationId)")
            
            let storyBoard: UIStoryboard = UIStoryboard(name: "customOrder", bundle: nil)
            if let mCheckOut = storyBoard.instantiateViewController(withIdentifier: "CustomOrderCheckout") as? CustomOrderCheckout {
                mCheckOut.mTotalP = self.mTotalDepositAmounts
                mCheckOut.mSubTotalP = ""
                mCheckOut.mTaxP = ""
                mCheckOut.mTaxAm = ""
                mCheckOut.mStoreCurrency =  self.mCurrency
                mCheckOut.mOrderType = "mix_and_match"
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
        let cell = UITableViewCell()
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
     
        guard let mData = mCartData[indexPath.row] as? NSDictionary else {
            return cell
        }
        if let isMixMatch = mData.value(forKey: "order_type") as? String {
            var mSNoIndex = ""
            mSNoIndex = "\(indexPath)"
            if (indexPath.row) == 0 {
                mCount = indexPath.row
                mSNoIndex = "1"
                mCount = 1
            }else{
                mCount = (indexPath.row - mCount) + 1
                mSNoIndex = "\(mCount)"
            }
            if isMixMatch == "diamond" {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "DiamondCartItems") as? DiamondCartItems {
                    cell.mSNo.text = mSNoIndex
                    cell.mPickStockId.tag = indexPath.row
                    cell.mProductPrice.tag = indexPath.row
                    
                    cell.mRemoveButton.tag = indexPath.row
                    cell.mCurrency.text = "\(mData.value(forKey: "currency") ?? "$")"
                    self.mCurrency = "\(mData.value(forKey: "currency") ?? "$") "
                    cell.mShapeName.text = "\(mData.value(forKey: "Shape") ?? "--")"
                    cell.mProductName.text = "\(mData.value(forKey: "name") ?? "--")"
                    cell.mStockId.text = "\(mData.value(forKey: "stock_id") ?? "--")"
                    cell.mCarats.text = "\(mData.value(forKey: "Carats") ?? "--")"
//                    cell.mProductPrice.text = "\(mData.value(forKey: "price") ?? "0.0")"
                    
                    if let currency = UserDefaults.standard.string(forKey: "currency") {
                        cell.mProductPrice.text = "\(currency)  \(mData.value(forKey: "price") ?? "0.0")"
                    }
                    else {
                        cell.mProductPrice.text = "\(mData.value(forKey: "currency") ?? "$") \(mData.value(forKey: "price") ?? "0.0")"
                    }
                    cell.mCurrency.isHidden = true
                    
                    cell.mProductImage.downlaodImageFromUrl(urlString: "\(mData.value(forKey: "main_image") ?? "")")
                    cell.mProductImage.tag = indexPath.row
                    cell.diamondImageTapGesture(target: self, action: #selector(handleImageTap(_:)))
                    
                    cell.mProductPrice.textAlignment = .right
                    cell.mProductPrice.contentHorizontalAlignment = .right
                    
                    calculateItemsWithAmount()
                    return cell
                }
            }else{
                if let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCartItems") as? CustomCartItems {
                    
                    cell.mDesignButton.tag = indexPath.row
                    cell.mChooseDateButton.tag = indexPath.row
                    cell.mPickStockId.tag = indexPath.row
                    cell.mProductPrice.tag = indexPath.row
                    cell.mRemarks.tag = indexPath.row
                    
                    cell.mEditServiceLabourButton.tag = indexPath.row
                    cell.mShowServiceLabourButton.tag = indexPath.row
                    
                    let isServiceLabour = UserDefaults.standard.bool(forKey: "isServiceLabour")
                    if isServiceLabour {
                        if let mServiceLabourStatus = mData.value(forKey: "Service_labour_exsist") as? Bool {
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
                    if let dateString = mData.value(forKey: "delivery_date") as? String,
                       !dateString.isEmpty {

                        let inputFormatter = ISO8601DateFormatter()
                        inputFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

                        if let date = inputFormatter.date(from: dateString) {

                            let outputFormatter = DateFormatter()
                            outputFormatter.calendar = Calendar(identifier: .gregorian)
                            outputFormatter.locale = Locale(identifier: "en_US_POSIX")
                            outputFormatter.dateFormat = "dd/MM/yyyy"

                            cell.mDueDate.text = outputFormatter.string(from: date)

                        } else {
                            cell.mDueDate.text = dateString
                        }

                    } else {
                        cell.mDueDate.text = "--"
                    }
//                    cell.mDueDate.text = "\(mData.value(forKey: "delivery_date") ?? "--")"
                    cell.mCurrency.text = "\(mData.value(forKey: "currency") ?? "$")"
                    self.mCurrency = "\(mData.value(forKey: "currency") ?? "$") "
                    cell.mRemarks.keyboardType = .default
                    cell.mRemarks.text = "\(mData.value(forKey: "remark") ?? "")"
                    cell.mSKUName.text = "\(mData.value(forKey: "SKU") ?? "")"
                    
                    cell.mProductName.text = "\(mData.value(forKey: "name") ?? "")"
                    cell.mMetalColorSize.text = "\(mData.value(forKey: "color_name") ?? "") " + "\(mData.value(forKey: "metal_name") ?? "") " + "\(mData.value(forKey: "size_name") ?? "")"
//                    cell.mProductPrice.text = "\(mData.value(forKey: "price") ?? "0.0")"
                    cell.mProductPrice.textAlignment = .right
                    cell.mProductPrice.contentHorizontalAlignment = .right
                    if let currency = UserDefaults.standard.string(forKey: "currency") {
                        cell.mProductPrice.text = "\(currency)  \(mData.value(forKey: "price") ?? "0.0")"
                    }
                    else {
                        cell.mProductPrice.text = "\(mData.value(forKey: "currency") ?? "$") \(mData.value(forKey: "price") ?? "0.0")"
                    }
                    cell.mCurrency.isHidden = true
                    cell.mStockId.text = "\(mData.value(forKey: "stock_id") ?? "")"
                    
                    cell.mProductImage.downlaodImageFromUrl(urlString: "\(mData.value(forKey: "main_image") ?? "")")
                    cell.mProductImage.tag = indexPath.row
                    cell.imageTapGesture(target: self, action: #selector(handleImageTap(_:)))
                    
                    calculateItemsWithAmount()
                    
                    return cell
                }
            }
            
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
     }

    @objc func handleImageTap(_ sender: UITapGestureRecognizer) {
        guard let imageView = sender.view as? UIImageView else {
            return
        }
        let index = imageView.tag
        if let mData = mCartData[index] as? NSDictionary {
            
            if let isMixMatch = mData.value(forKey: "order_type") as? String , isMixMatch == "diamond"{
                let storyBoard: UIStoryboard = UIStoryboard(name: "Test", bundle: nil)
                if let mGlobalImageViewer = storyBoard.instantiateViewController(withIdentifier: "GlobalImageViewer") as? GlobalImageViewer {
                    mGlobalImageViewer.modalPresentationStyle = .overFullScreen
                    mGlobalImageViewer.mSKUName = "\(mData.value(forKey: "name") ?? "--")"
                    mGlobalImageViewer.mAllImages = ["\(mData.value(forKey: "main_image") ?? "")"]
                    mGlobalImageViewer.isMixMatch = true
                    mGlobalImageViewer.transitioningDelegate = self
                    self.present(mGlobalImageViewer,animated: false)
                }
            }else{
                let sku = "\(mData.value(forKey: "SKU") ?? "")"
                let productId = "\(mData.value(forKey: "id") ?? "")"
                mOpenGlobalImageViewer(mProductIdForImage: productId, mSKUForImage: sku)
            }
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
        
        
        let mData = self.mCartData[sender.tag] as? NSDictionary
        
        if let mServiceData = mData?.value(forKey: "Service_labour") as? NSDictionary {
            let storyBoard: UIStoryboard = UIStoryboard(name: "laybyInstallment", bundle: nil)
            if let mSelectedServiceLabour = storyBoard.instantiateViewController(withIdentifier: "SelectedServiceLabour") as? SelectedServiceLabour {
                mSelectedServiceLabour.modalPresentationStyle = .automatic
                mSelectedServiceLabour.mProductData = mServiceData
                mSelectedServiceLabour.transitioningDelegate = self
                self.present(mSelectedServiceLabour,animated: true)
            }
        }
    }

    @IBAction func mEditServiceLabour(_ sender: UIButton) {
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "laybyInstallment", bundle: nil)
        if let mCommonServiceLabour = storyBoard.instantiateViewController(withIdentifier: "CommonServiceLabour") as? CommonServiceLabour {
            mCommonServiceLabour.modalPresentationStyle = .overFullScreen
            mCommonServiceLabour.delegate = self
            mCommonServiceLabour.mProductData = self.mCartData[sender.tag] as? NSDictionary ?? NSDictionary()
            mCommonServiceLabour.transitioningDelegate = self
            self.present(mCommonServiceLabour,animated: true)
        }
    }
    
    @IBAction func mPickStockId(_ sender: UIButton) {
        if let mCartDatas = mCartData[sender.tag] as? NSDictionary {
            if let mCartItems = mCartDatas.value(forKey: "stock_id_options") as? NSArray {
                if mCartItems.count < 1 {
                    return
                }
                var mStockIds = [String]()
                for i in mCartItems {
                    if let data = i as? NSDictionary {
                        mStockIds.append("\(data.value(forKey: "value") ?? "")")
                    }
                }
                let dropdown = DropDown()
                dropdown.anchorView = sender
                dropdown.direction = .any
                dropdown.bottomOffset = CGPoint(x: 0, y: sender.frame.size.height)
                dropdown.width = 200
                dropdown.dataSource = mStockIds
                dropdown.selectionAction = {
                    [unowned self](index:Int, item: String) in
                    if let cell1 = mCartTable.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as? CustomCartItems {
                        cell1.mStockId.text = item
                    }
                    if let mInvData = self.mCartData[sender.tag] as? NSDictionary {
                        var mData = NSMutableDictionary()
                        mData.setValue("\(mInvData.value(forKey: "price") ?? "")", forKey: "price")
                        mData.setValue("\(mInvData.value(forKey: "metal_id") ?? "")", forKey: "metal_id")
                        mData.setValue("\(mInvData.value(forKey: "size_id") ?? "")", forKey: "size_id")
                        mData.setValue("\(mInvData.value(forKey: "SKU") ?? "")", forKey: "SKU")
                        mData.setValue("\(mInvData.value(forKey: "remark") ?? "")", forKey: "remark")
                        mData.setValue("\(mInvData.value(forKey: "custom_cart_id") ?? "")", forKey: "custom_cart_id")
                        mData.setValue("\(mInvData.value(forKey: "currency") ?? "")", forKey: "currency")
                        mData.setValue("\(mInvData.value(forKey: "diamond_id") ?? "")", forKey: "diamond_id")
                        mData.setValue("\(mInvData.value(forKey: "main_image") ?? "")", forKey: "main_image")
                        mData.setValue("\(mInvData.value(forKey: "name") ?? "")", forKey: "name")
                        mData.setValue("\(mInvData.value(forKey: "product_id") ?? "")", forKey: "product_id")
                        mData.setValue("\(mInvData.value(forKey: "product_type") ?? "")", forKey: "product_type")
                        mData.setValue("\(mInvData.value(forKey: "size_name") ?? "")", forKey: "size_name")
                        mData.setValue(item, forKey: "stock_id")
                        mData.setValue("\(mInvData.value(forKey: "delivery_date") ?? "")", forKey: "delivery_date")
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
                        self.mCartData.removeObject(at: sender.tag)
                        self.mCartData.insert(mData, at: sender.tag)
                        self.calculateItemsWithAmount()
                    }
                }
                dropdown.show()
            }
        }
    }

    @IBAction func mPickDiamondStock(_ sender: UIButton) {
        
        if let mCartDatas = mCartData[sender.tag] as? NSDictionary {
            if let mCartItems = mCartDatas.value(forKey: "stock_id_options") as? NSArray {
                
                if mCartItems.count < 1 {
                    return
                }
                var mStockIds = [String]()
                for i in mCartItems {
                    if let data = i as? NSDictionary {
                        mStockIds.append("\(data.value(forKey: "value") ?? "")")
                    }
                }
                
                let dropdown = DropDown()
                dropdown.anchorView = sender
                dropdown.direction = .any
                dropdown.bottomOffset = CGPoint(x: 0, y: sender.frame.size.height)
                dropdown.width = 200
                dropdown.dataSource = mStockIds
                dropdown.selectionAction = {
                    [unowned self](index:Int, item: String) in
                    if let cell1 = mCartTable.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as? DiamondCartItems {
                        cell1.mStockId.text = item
                    }
                    if let mInvData = self.mCartData[sender.tag] as? NSDictionary {
                        var mData = NSMutableDictionary()
                        mData.setValue("\(mInvData.value(forKey: "Carats") ?? "")", forKey: "Carats")
                        mData.setValue("\(mInvData.value(forKey: "SKU") ?? "")", forKey: "SKU")
                        mData.setValue("\(mInvData.value(forKey: "Shape") ?? "")", forKey: "Shape")
                        mData.setValue("\(mInvData.value(forKey: "custom_cart_id") ?? "")", forKey: "custom_cart_id")
                        mData.setValue("\(mInvData.value(forKey: "currency") ?? "")", forKey: "currency")
                        mData.setValue("\(mInvData.value(forKey: "diamond_id") ?? "")", forKey: "diamond_id")
                        mData.setValue("\(mInvData.value(forKey: "main_image") ?? "")", forKey: "main_image")
                        mData.setValue("\(mInvData.value(forKey: "name") ?? "")", forKey: "name")
                        mData.setValue("\(mInvData.value(forKey: "price") ?? "")", forKey: "price")
                        mData.setValue("\(mInvData.value(forKey: "product_id") ?? "")", forKey: "product_id")
                        mData.setValue("\(mInvData.value(forKey: "product_type") ?? "")", forKey: "product_type")
                        mData.setValue("\(mInvData.value(forKey: "size_name") ?? "")", forKey: "size_name")
                        mData.setValue(item, forKey: "stock_id")
                        mData.setValue("\(mInvData.value(forKey: "delivery_date") ?? "")", forKey: "delivery_date")
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
                        self.mCartData.removeObject(at: sender.tag)
                        self.mCartData.insert(mData, at: sender.tag)
                        
                        self.calculateItemsWithAmount()
                    }
                }
                dropdown.show()
            }
        }
    }
    
    @IBAction func mChooseDate(_ sender: UIButton) {

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
        
        if let cells = mCartTable.cellForRow(at: IndexPath(row: sender.tag , section: 0)) as? CustomCartItems {
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
            cell1.mDueDate.text = deliveryDate
        }
        
        if let mInvData = mCartData[mCurrentIndex] as? NSDictionary {
            var mData = NSMutableDictionary()
            
            if let cells = mCartTable.cellForRow(at: IndexPath(row: mCurrentIndex , section: 0)) as? CustomCartItems {
                mData.setValue(deliveryDate, forKey: "delivery_date")
            }
            mData.setValue("\(mInvData.value(forKey: "metal_id") ?? "")", forKey: "metal_id")
            mData.setValue("\(mInvData.value(forKey: "size_id") ?? "")", forKey: "size_id")
            mData.setValue("\(mInvData.value(forKey: "SKU") ?? "")", forKey: "SKU")
            mData.setValue("\(mInvData.value(forKey: "price") ?? "")", forKey: "price")
            mData.setValue("\(mInvData.value(forKey: "custom_cart_id") ?? "")", forKey: "custom_cart_id")
            mData.setValue("\(mInvData.value(forKey: "currency") ?? "")", forKey: "currency")
            mData.setValue("\(mInvData.value(forKey: "diamond_id") ?? "")", forKey: "diamond_id")
            mData.setValue("\(mInvData.value(forKey: "main_image") ?? "")", forKey: "main_image")
            mData.setValue("\(mInvData.value(forKey: "name") ?? "")", forKey: "name")
            mData.setValue("\(mInvData.value(forKey: "product_id") ?? "")", forKey: "product_id")
            mData.setValue("\(mInvData.value(forKey: "product_type") ?? "")", forKey: "product_type")
            mData.setValue("\(mInvData.value(forKey: "size_name") ?? "")", forKey: "size_name")
            mData.setValue("\(mInvData.value(forKey: "stock_id") ?? "")", forKey: "stock_id")
            mData.setValue("\(mInvData.value(forKey: "remark") ?? "")", forKey: "remark")
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
        }
        
        self.view.endEditing(true)

    }
    
    @objc func mCancelDatePick(){
        self.view.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let mData = mCartData[indexPath.row] as? NSDictionary
            CommonClass.showFullLoader(view: self.view)
            let mParams = [ "customer_id":mCustomerId , "custom_cart_id":mData?.value(forKey: "custom_cart_id") as? String ?? ""] as [String : Any]
            
            if isQuotation{
                mCartData.removeAllObjects()
                mCartTable.reloadData()
                CommonClass.stopLoader()
            }else{
                mGetData(url: mDeleteCartItem,headers: sGisHeaders, params: mParams) { response , status in
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
        mFetchCartItems()

    }
    func mDeleteCartItems(index: Int) {
         mFetchCartItems()

        self.mCartTable.reloadData()
     }
    
    @IBAction func mRemoveCartItems(_ sender: UIButton) {
        if isQuotation{
            mCartData.removeAllObjects()
            mCartTable.reloadData()
        }else{
            let mData = mCartData[sender.tag] as? NSDictionary
            mRemovePopUp.frame = self.view.bounds
            mRemovePopUp.mCustomerId = mCustomerId
            mRemovePopUp.delegate = self
            mRemovePopUp.index = sender.tag
            mRemovePopUp.mType = ""
            
            mRemovePopUp.mCartId = mData?.value(forKey: "custom_cart_id") as? String ?? ""
    
            mRemovePopUp.mMessage.text = "Are you sure want to remove ?".localizedString
            mRemovePopUp.mCancelButton.setTitle("CANCEL".localizedString, for: .normal)
            mRemovePopUp.mConfirmButton.setTitle("CONFIRM".localizedString, for: .normal)
            self.view.addSubview(mRemovePopUp)
        }
        
    }

    
    
    @IBAction func mEditDiamondAmount(_ sender: UITextField) {
        guard let mInvData = mCartData[sender.tag] as? NSDictionary else {
            return
        }
        
        let mOrgData = mCartDataMaster[sender.tag] as? NSDictionary
        
        if sender.text == "" || sender.text == "0" {
            if let cells = mCartTable.cellForRow(at: IndexPath(row: sender.tag , section: 0)) as? DiamondCartItems {
                cells.mProductPrice.text = ""
            }
            var mData = NSMutableDictionary()
            mData.setValue("\(mInvData.value(forKey: "Carats") ?? "")", forKey: "Carats")
            mData.setValue("\(mInvData.value(forKey: "SKU") ?? "")", forKey: "SKU")
            mData.setValue("\(mInvData.value(forKey: "Shape") ?? "")", forKey: "Shape")
            mData.setValue("\(mInvData.value(forKey: "custom_cart_id") ?? "")", forKey: "custom_cart_id")
            mData.setValue("\(mInvData.value(forKey: "currency") ?? "")", forKey: "currency")
            mData.setValue("\(mInvData.value(forKey: "diamond_id") ?? "")", forKey: "diamond_id")
            mData.setValue("\(mInvData.value(forKey: "main_image") ?? "")", forKey: "main_image")
            mData.setValue("\(mInvData.value(forKey: "name") ?? "")", forKey: "name")
            mData.setValue("0", forKey: "price")
            mData.setValue("\(mInvData.value(forKey: "product_id") ?? "")", forKey: "product_id")
            mData.setValue("\(mInvData.value(forKey: "product_type") ?? "")", forKey: "product_type")
            mData.setValue("\(mInvData.value(forKey: "size_name") ?? "")", forKey: "size_name")
            mData.setValue("\(mInvData.value(forKey: "stock_id") ?? "")", forKey: "stock_id")
            mData.setValue("\(mInvData.value(forKey: "delivery_date") ?? "")", forKey: "delivery_date")
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
        mData.setValue("\(mInvData.value(forKey: "Carats") ?? "")", forKey: "Carats")
        mData.setValue("\(mInvData.value(forKey: "SKU") ?? "")", forKey: "SKU")
        mData.setValue("\(mInvData.value(forKey: "Shape") ?? "")", forKey: "Shape")
        mData.setValue("\(mInvData.value(forKey: "custom_cart_id") ?? "")", forKey: "custom_cart_id")
        mData.setValue("\(mInvData.value(forKey: "currency") ?? "")", forKey: "currency")
        mData.setValue("\(mInvData.value(forKey: "diamond_id") ?? "")", forKey: "diamond_id")
        mData.setValue("\(mInvData.value(forKey: "main_image") ?? "")", forKey: "main_image")
        mData.setValue("\(mInvData.value(forKey: "name") ?? "")", forKey: "name")
        if let cells = mCartTable.cellForRow(at: IndexPath(row: sender.tag , section: 0)) as? DiamondCartItems {
            mData.setValue(cells.mProductPrice.text ?? "", forKey: "price")
        }
        mData.setValue("\(mInvData.value(forKey: "product_id") ?? "")", forKey: "product_id")
        mData.setValue("\(mInvData.value(forKey: "product_type") ?? "")", forKey: "product_type")
        mData.setValue("\(mInvData.value(forKey: "size_name") ?? "")", forKey: "size_name")
        mData.setValue("\(mInvData.value(forKey: "stock_id") ?? "")", forKey: "stock_id")
        mData.setValue("\(mInvData.value(forKey: "delivery_date") ?? "")", forKey: "delivery_date")
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
    
    
    @IBAction func mEditAmount(_ sender: UITextField) {
        guard let mInvData = mCartData[sender.tag] as? NSDictionary else {
            return
        }
        let mOrgData = mCartDataMaster[sender.tag] as? NSDictionary
        
        if sender.text == "" || sender.text == "0" {
            if let cells = mCartTable.cellForRow(at: IndexPath(row: sender.tag , section: 0)) as? CustomCartItems {
                cells.mProductPrice.text = ""
            }
            var mData = NSMutableDictionary()
            mData.setValue("0", forKey: "price")
            mData.setValue("\(mInvData.value(forKey: "metal_id") ?? "")", forKey: "metal_id")
            mData.setValue("\(mInvData.value(forKey: "size_id") ?? "")", forKey: "size_id")
            mData.setValue("\(mInvData.value(forKey: "SKU") ?? "")", forKey: "SKU")
            mData.setValue("\(mInvData.value(forKey: "remark") ?? "")", forKey: "remark")
            mData.setValue("\(mInvData.value(forKey: "custom_cart_id") ?? "")", forKey: "custom_cart_id")
            mData.setValue("\(mInvData.value(forKey: "currency") ?? "")", forKey: "currency")
            mData.setValue("\(mInvData.value(forKey: "diamond_id") ?? "")", forKey: "diamond_id")
            mData.setValue("\(mInvData.value(forKey: "main_image") ?? "")", forKey: "main_image")
            mData.setValue("\(mInvData.value(forKey: "name") ?? "")", forKey: "name")
            mData.setValue("\(mInvData.value(forKey: "product_id") ?? "")", forKey: "product_id")
            mData.setValue("\(mInvData.value(forKey: "product_type") ?? "")", forKey: "product_type")
            mData.setValue("\(mInvData.value(forKey: "size_name") ?? "")", forKey: "size_name")
            mData.setValue("\(mInvData.value(forKey: "stock_id") ?? "")", forKey: "stock_id")
            mData.setValue("\(mInvData.value(forKey: "delivery_date") ?? "")", forKey: "delivery_date")
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
        if let cells = mCartTable.cellForRow(at: IndexPath(row: sender.tag , section: 0)) as? CustomCartItems {
            mData.setValue(cells.mProductPrice.text, forKey: "price")
        }
        mData.setValue("\(mInvData.value(forKey: "metal_id") ?? "")", forKey: "metal_id")
        mData.setValue("\(mInvData.value(forKey: "size_id") ?? "")", forKey: "size_id")
        mData.setValue("\(mInvData.value(forKey: "SKU") ?? "")", forKey: "SKU")
        mData.setValue("\(mInvData.value(forKey: "remark") ?? "")", forKey: "remark")
        mData.setValue("\(mInvData.value(forKey: "custom_cart_id") ?? "")", forKey: "custom_cart_id")
        mData.setValue("\(mInvData.value(forKey: "currency") ?? "")", forKey: "currency")
        mData.setValue("\(mInvData.value(forKey: "diamond_id") ?? "")", forKey: "diamond_id")
        mData.setValue("\(mInvData.value(forKey: "main_image") ?? "")", forKey: "main_image")
        mData.setValue("\(mInvData.value(forKey: "name") ?? "")", forKey: "name")
        mData.setValue("\(mInvData.value(forKey: "product_id") ?? "")", forKey: "product_id")
        mData.setValue("\(mInvData.value(forKey: "product_type") ?? "")", forKey: "product_type")
        mData.setValue("\(mInvData.value(forKey: "size_name") ?? "")", forKey: "size_name")
        mData.setValue("\(mInvData.value(forKey: "stock_id") ?? "")", forKey: "stock_id")
        mData.setValue("\(mInvData.value(forKey: "delivery_date") ?? "")", forKey: "delivery_date")
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
        
        guard let mInvData = mCartData[sender.tag] as? NSDictionary else {
            return
        }
        
        var mData = NSMutableDictionary()
        
        if let cells = mCartTable.cellForRow(at: IndexPath(row: sender.tag , section: 0)) as? CustomCartItems {
            mData.setValue(cells.mRemarks.text ?? "", forKey: "remark")
            mData.setValue(cells.mRemarks.text ?? "", forKey: "note")
        }
        mData.setValue("\(mInvData.value(forKey: "metal_id") ?? "")", forKey: "metal_id")
        mData.setValue("\(mInvData.value(forKey: "size_id") ?? "")", forKey: "size_id")
        mData.setValue("\(mInvData.value(forKey: "SKU") ?? "")", forKey: "SKU")
        mData.setValue("\(mInvData.value(forKey: "price") ?? "")", forKey: "price")
        mData.setValue("\(mInvData.value(forKey: "custom_cart_id") ?? "")", forKey: "custom_cart_id")
        mData.setValue("\(mInvData.value(forKey: "currency") ?? "")", forKey: "currency")
        mData.setValue("\(mInvData.value(forKey: "diamond_id") ?? "")", forKey: "diamond_id")
        mData.setValue("\(mInvData.value(forKey: "main_image") ?? "")", forKey: "main_image")
        mData.setValue("\(mInvData.value(forKey: "name") ?? "")", forKey: "name")
        mData.setValue("\(mInvData.value(forKey: "product_id") ?? "")", forKey: "product_id")
        mData.setValue("\(mInvData.value(forKey: "product_type") ?? "")", forKey: "product_type")
        mData.setValue("\(mInvData.value(forKey: "size_name") ?? "")", forKey: "size_name")
        mData.setValue("\(mInvData.value(forKey: "stock_id") ?? "")", forKey: "stock_id")
        mData.setValue("\(mInvData.value(forKey: "delivery_date") ?? "")", forKey: "delivery_date")
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
        
        let mData = mCartData[sender.tag] as? NSDictionary
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "mixNMatch", bundle: nil)
        if let mMixAndMatchComplete = storyBoard.instantiateViewController(withIdentifier: "MixAndMatchComplete") as? MixAndMatchComplete {
            mMixAndMatchComplete.mEditStatus = mData?.value(forKey: "custom_cart_id") as? String ?? ""
            mMixAndMatchComplete.mCustomerId = self.mCustomerId
            self.navigationController?.pushViewController(mMixAndMatchComplete, animated: true)
        }
    }
    
    
    func calculateItemsWithAmount(){
        var mAmounts = [Double]()
        var mQuantities = [Int]()
        mServiceAmounts = [Double]()
        
        for i in mCartData {
            if let mData = i as? NSDictionary {
                mQuantities.append(Int("\(mData.value(forKey: "Qty") ?? "0")") ?? 0 )
                mAmounts.append(Double("\(mData.value(forKey: "price") ?? "0.0")".replacingOccurrences(of: ",", with: "")) ?? 0.00)
                
                if let mServiceLabourStatus = mData.value(forKey: "Service_labour_exsist") as? Bool {
                    
                    if mServiceLabourStatus {
                        if let mServiceLabour = mData.value(forKey: "Service_labour") as? NSDictionary {
                            if let mServiceItem = mServiceLabour.value(forKey: "service_laburelist") as? NSArray {
                                if mServiceItem.count > 0 {
                                    var mAmounts = [Double]()
                                    for i in mServiceItem {
                                        if let items = i as? NSDictionary {
                                            mAmounts.append(Double("\(items.value(forKey: "scrviceamount") ?? "0.0")".replacingOccurrences(of: ",", with: "")) ?? 0.00)
                                        }
                                    }
                                    mServiceAmounts.append(mAmounts.reduce(0, {$0 + $1}))
                                }else{
                                }
                            }
                        }
                        
                    }
                }
            }
        }
        
        mTotalItems.text = "\(mCartData.count) items"
        mGrandTotal.text = self.mCurrency + String(format:"%.02f",locale:Locale.current,(mAmounts.reduce(0, {$0 + $1}) + mServiceAmounts.reduce(0, {$0 + $1})))
        
        self.mGrandTotalCart = "\((mAmounts.reduce(0, {$0 + $1}) + mServiceAmounts.reduce(0, {$0 + $1})))"
        self.mGrandTotalAmounts = "\((mAmounts.reduce(0, {$0 + $1}) + mServiceAmounts.reduce(0, {$0 + $1})))"
        if mDepositPercents == "100" {
            mDepositAmount.text = mGrandTotal.text
            mOutstandingAmount.text = self.mCurrency + "0.00"
            self.mOutStandingAmounts = "0.00"
            self.mTotalDepositAmounts = self.mGrandTotalAmounts
            
        }else{
            let mTotalValue = (mAmounts.reduce(0, {$0 + $1}) + mServiceAmounts.reduce(0, {$0 + $1}))
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
