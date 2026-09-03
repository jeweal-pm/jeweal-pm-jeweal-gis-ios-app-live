//
//  CustomCart.swift
//  GIS
//
//  Created by MacBook Hawkscode  on 30/12/22.
//  Copyright © 2022 Hawkscode. All rights reserved.
//

import UIKit
import Alamofire
import DropDown

let mRemovePopUp = UINib(nibName:"removepopup", bundle: .main).instantiate(withOwner: nil, options: nil).first as? RemovePopUp ?? RemovePopUp()

protocol DeleteCustomCartItems {
    func mDeleteCartItems(index:Int)
}

class RemovePopUp: UIView {
    var mType = ""
    var mCustomerId = ""
    var mCartId = ""
    var index = Int()
    
    var delegate:DeleteCustomCartItems? = nil

    @IBOutlet weak var mMessage: UILabel!
    @IBOutlet weak var mConfirmButton: UIButton!
    @IBOutlet weak var mCancelButton: UIButton!
    
    var mNavigation = UINavigationController()
    static func instantiate(message: String) -> RemovePopUp {
        let view: RemovePopUp = initFromNib()
        return view
    }

    @IBAction func mCancel(_ sender: Any) {
        self.removeFromSuperview()
    }
    
    @IBAction func mConfirm(_ sender: Any) {
        if mType == "deposit" || mType == "quotation" || mType == "giftCard" || mType == "refund" || mType == "exchange" {
            self.removeFromSuperview()
            self.delegate?.mDeleteCartItems(index:self.index)
            return
        }
//        CommonClass.showFullLoader(view: self)
        let mParams = [ "customer_id":mCustomerId , "custom_cart_id":mCartId] as [String : Any]
        
        
        mGetData(url: mDeleteCartItem,headers: sGisHeaders,  params: mParams) { response , status in
//            self.hideCartLoading()
            CommonClass.stopLoader()
            if status {
            if "\(response.value(forKey: "code") ?? "")" == "200" {
                self.removeFromSuperview()
                self.delegate?.mDeleteCartItems(index:self.index)
            }else{
          
            }
        }
    }
        
    }
}

class CustomCartItems : UITableViewCell {
    
    @IBOutlet weak var mServiceLabourView: UIView!
    @IBOutlet weak var mServiceLabourCount: UILabel!
    @IBOutlet weak var mServiceLabourCharges: UILabel!
    @IBOutlet weak var mShowServiceLabourButton: UIButton!
    @IBOutlet weak var mEditServiceLabourButton: UIButton!
    @IBOutlet weak var mEditServiceLabourIcon: UIImageView!
   
    
    
    @IBOutlet weak var mRemoveButton: UIButton!
    @IBOutlet weak var mCurrency: UILabel!
    @IBOutlet weak var mEditIcon: UIImageView!
    @IBOutlet weak var mDesignButton: UIButton!
    @IBOutlet weak var mMetalColorSize: UILabel!
    @IBOutlet weak var mProductName: UILabel!
    @IBOutlet weak var mProductPrice: UITextField!
    @IBOutlet weak var mUnderlineProductPrice: UILabel!
    @IBOutlet weak var mMinusButton: UIButton!
    @IBOutlet weak var mSKUName: UILabel!
    @IBOutlet weak var mPickStockId: UIButton!
    @IBOutlet weak var mRemarks: UITextField!
    @IBOutlet weak var mChooseDateButton: UIButton!
    @IBOutlet weak var mPlusButton: UIButton!
    @IBOutlet weak var mProductImage: UIImageView!
    @IBOutlet weak var mStockId: UILabel!
    @IBOutlet weak var mDueDate: UITextField!
    @IBOutlet weak var mQuantityUnit: UILabel!
    @IBOutlet weak var mView: UIView!
    
    @IBOutlet weak var mSNView: UIView!
    
    
    @IBOutlet weak var mDiscountPercent: UITextField!
    @IBOutlet weak var mDiscountAmount: UITextField!
    @IBOutlet weak var mImageHolderView: UIView!
    @IBOutlet weak var mStockView: UIView!
    @IBOutlet weak var mQtyView: UIView!
    
    @IBOutlet weak var mOpenProductDetailsButton: UIButton!
    @IBOutlet weak var mAmountView: UIView!
    
    @IBOutlet weak var mSNo: UILabel!
    
    
    
     @IBOutlet weak var mRemarksView: UIView!
    
    
    func imageTapGesture(target: Any, action: Selector) {
        let tapGesture = UITapGestureRecognizer(target: target, action: action)
        mProductImage.isUserInteractionEnabled = true
        mProductImage.addGestureRecognizer(tapGesture)
    }
    
}
class CustomCart: UIViewController, UIViewControllerTransitioningDelegate, UIGestureRecognizerDelegate, GetCustomerDataDelegate, UITableViewDataSource, UITableViewDelegate, GetInventoryDataItemsDelegate, DeleteCustomCartItems, SearchDelegate, EditProductDelegate, ConfirmationDelegate, GetQuotationDelegate, ServiceLabourDelegate, UITextFieldDelegate {

    // MARK: - Quote Suggestions
    // Show suggestions only after the Note field is tapped.
    // After selecting a suggestion, keep them hidden until the field is cleared.
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

    // Creates the Suggestions popup and installs the text-field events.
    // IMPORTANT: this function does NOT show the popup.
    private func setupQuoteSuggestions() {
        guard let textField = mConfirmQuote.mNotes else {
            return
        }

        // Match the rounded Note field shown in the reference UI.
        // The previous version only set cornerRadius, but the field itself
        // had no visible border/background, so it appeared as plain lines.
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 6.0
        textField.layer.borderWidth = 0.5
        textField.layer.borderColor = UIColor(red: 204/255,
                                              green: 204/255,
                                              blue: 204/255,
                                              alpha: 1).cgColor
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
            title.font = quoteFont(13, weight: .bold)
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
                stack.trailingAnchor.constraint(equalTo: popup.trailingAnchor, constant: 0),
                stack.bottomAnchor.constraint(equalTo: popup.bottomAnchor, constant: -8)
            ])

            quoteSuggestionsView = popup
            quoteSuggestionsStack = stack
        }

        // Never show the popup just because the Quote dialog opened.
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

        // If a suggestion was selected, stay hidden until the user clears it.
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

        // User requested: if there is no match, hide the whole popup.
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

            // Slightly to the right so the options do not line up
            // directly underneath the "Suggestions" title.
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
        showQuoteSuggestions()
    }

    @objc private func quoteNoteEditingChanged(_ textField: UITextField) {
        let text = textField.text ?? ""

        // When the user presses X and the field becomes empty:
        // - hide Suggestions
        // - dismiss the keyboard
        // - remove focus from the Note field
        // Suggestions will be shown again only when the user taps
        // the Note field again.
        if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            quoteSuggestionsSuppressedAfterSelection = false
            hideQuoteSuggestions()
            textField.resignFirstResponder()
            mConfirmQuote.endEditing(true)
            return
        }

        // If a suggestion was already selected, keep Suggestions hidden.
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

        // Keep Suggestions hidden after selection.
        quoteSuggestionsSuppressedAfterSelection = true
        hideQuoteSuggestions()

        textField.becomeFirstResponder()
    }

    @objc private func quoteNoteEditingEnded(_ textField: UITextField) {
        hideQuoteSuggestions()
    }

    // MARK: - UITextFieldDelegate
    // Called when the user taps the built-in X clear button.
    // Clear everything immediately, close Suggestions, hide the keyboard,
    // and remove focus from the Note field.
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        guard textField === mConfirmQuote.mNotes else {
            return true
        }

        textField.text = ""
        quoteSuggestionsSuppressedAfterSelection = false

        // Close Suggestions immediately.
        hideQuoteSuggestions()

        // Remove focus and dismiss the keyboard immediately.
        textField.resignFirstResponder()
        mConfirmQuote.endEditing(true)

        return false
    }

//    func mGetSearchItems(id: String, locationId: String){
//        var mParams = [String : Any]()
//            mParams = ["product_id":[id], "customer_id":mCustomerId, "sales_person_id":"", "type":"inventory", "order_type":"reserve"]
//        print("DEBUG_GET_SEARCH_ITEM_ID =", id)
//        if !locationId.isEmpty {
//
//            mParams["crossLocationId"] = locationId
//            mParams["crosslocation"] = true
//        }
//        print("DEBUG_ADD_TO_CART_PARAMS =", mParams)
//        mGetData(url: mAddCustomProduct,headers: sGisHeaders,  params: mParams) { response , status in
//            CommonClass.stopLoader()
//            if status {
//                if "\(response.value(forKey: "code") ?? "")" == "200" {
//
//                    self.mFetchCartItems()
//
//                }else{
//
//                }
//            }
//        }
//    }
    
    func mGetSearchItems(
        id: String,
        locationId: String,
        type: String
    ) {
        print("🚨🚨🚨 mGetSearchItems CALLED 🚨🚨🚨")
            print("ID =", id)
            print("LOCATION =", locationId)
            print("TYPE =", type)
            print("CUSTOM CART =", self)
        var mParams: [String: Any] = [
            "product_id": [id],
            "customer_id": mCustomerId,
            "sales_person_id": "",
            "type": type,
            "order_type": "custom_order"
        ]

        if !locationId.isEmpty {
            mParams["crossLocationId"] = locationId
            mParams["crosslocation"] = true
        }

        print("========== SEARCH ADD REQUEST ==========")
           print("🔥 PARAMS =", mParams)
           print("========================================")

        mGetData(
            url: mAddCustomProduct,
            headers: sGisHeaders,
            params: mParams
        ) { response, status in
            self.hideCartLoading()
            CommonClass.stopLoader()

            print("========== SEARCH ADD RESPONSE ==========")
            print("🔥 STATUS =", status)
            print("🔥 RESPONSE =", response)
            print("=========================================")

            guard status else {
                return
            }

            if "\(response.value(forKey: "code") ?? "")" == "200" {
                print("✅ ADD CUSTOM PRODUCT SUCCESS")
                self.mFetchCartItems()
            } else {
                let message =
                    "\(response.value(forKey: "message") ?? "Failed To Add.")"
                print("❌ ADD CUSTOM PRODUCT FAILED =", message)
                CommonClass.showSnackBar(message: message)
            }
        }
    }
    
   

    @IBOutlet weak var mSearchField: UITextField!

    @IBOutlet weak var mTotalItems: UILabel!
    @IBOutlet weak var mGrandTotal: UILabel!
    @IBOutlet weak var mDepositAmount: UILabel!
    @IBOutlet weak var mOutstandingAmount: UILabel!
    @IBOutlet weak var mSelectedCustomerIcon: UIImageView!
    var mCustomerId = ""
    var isQuotation = false
    var mQuotationId = ""
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

    var mCartAmount = [Double]()
    var mQuantityData = [Int]()
    var mCurrentIndex = -1
    let mDatePicker:UIDatePicker = UIDatePicker()
    var isItemsAvailable =  false
    var isDeleted = false
    var mServiceAmounts = [Double]()
    @IBOutlet weak var mQuotationCount: UILabel!
    @IBOutlet weak var mQuoteButton: UIButton!
    
    @IBOutlet weak var mQuotationView: UIView!
    
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
    
    
    @IBOutlet weak var mAddressPickerIcon: UIImageView!
    @IBOutlet weak var mAddressPickerAlertIcon: UIImageView!
    
    var mPendingProducts: [NSMutableDictionary] = []
    private var isAddingProducts = false
    private var cartLoadingView: UIView?

    private func showCartLoading() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, self.isViewLoaded else { return }
            let hostView = self.view!

            if self.cartLoadingView != nil { return }

            let overlay = UIView()
            overlay.backgroundColor = UIColor.black.withAlphaComponent(0.12)
            overlay.translatesAutoresizingMaskIntoConstraints = false
            overlay.isUserInteractionEnabled = true

            let spinner = UIActivityIndicatorView(style: .large)
            spinner.translatesAutoresizingMaskIntoConstraints = false
            spinner.startAnimating()

            overlay.addSubview(spinner)
            hostView.addSubview(overlay)
            hostView.bringSubviewToFront(overlay)

            NSLayoutConstraint.activate([
                overlay.leadingAnchor.constraint(equalTo: hostView.leadingAnchor),
                overlay.trailingAnchor.constraint(equalTo: hostView.trailingAnchor),
                overlay.topAnchor.constraint(equalTo: hostView.topAnchor),
                overlay.bottomAnchor.constraint(equalTo: hostView.bottomAnchor),
                spinner.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
                spinner.centerYAnchor.constraint(equalTo: overlay.centerYAnchor)
            ])

            self.cartLoadingView = overlay
            print("🔄 CustomCart LOADING SHOW")
        }
    }

    private func hideCartLoading() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.cartLoadingView?.removeFromSuperview()
            self.cartLoadingView = nil
            print("✅ CustomCart LOADING HIDE")
        }
    }
    
    private func addPendingProducts() {
        // Show loading immediately while the selected Catalog/Inventory
        // products are being added and before the cart is fetched.
        showCartLoading()

        // Add one product at a time. The previous implementation fired every
        // request concurrently and used the index of the request to decide
        // when to fetch. Network responses are unordered, so the cart could be
        // fetched before the earlier add requests had finished.
        let pendingProducts = mPendingProducts
        mPendingProducts.removeAll()
        addPendingProduct(at: 0, from: pendingProducts)
    }

    private func addPendingProduct(
        at index: Int,
        from products: [NSMutableDictionary]
    ) {
        guard index < products.count else {
            isAddingProducts = false
            mFetchCartItems()
            return
        }

        let product = products[index]
        let productId = "\(product["product_id"] ?? "")"

        guard !productId.isEmpty else {
            addPendingProduct(at: index + 1, from: products)
            return
        }

        let locationId = "\(product["location_id"] ?? "")"
        let type = "\(product["type"] ?? "catalog")"

        addPendingProduct(
            id: productId,
            locationId: locationId,
            type: type
        ) { [weak self] in
            DispatchQueue.main.async {
                self?.addPendingProduct(at: index + 1, from: products)
            }
        }
    }

    private func addPendingProduct(
        id: String,
        locationId: String,
        type: String,
        completion: @escaping () -> Void
    ) {
        var params: [String: Any] = [
            "product_id": [id],
            "customer_id": mCustomerId,
            "sales_person_id": "",
            "type": type,
            "order_type": "custom_order"
        ]

        if !locationId.isEmpty {
            params["crossLocationId"] = locationId
            params["crosslocation"] = true
        }

        print("CustomCart.swift addPendingProduct ")
        mGetData(url: mAddCustomProduct, headers: sGisHeaders, params: params) {
            [weak self] response, status in
            guard let self else { return }

            guard status,
                  "\(response.value(forKey: "code") ?? "")" == "200"
            else {
                let message = "\(response.value(forKey: "message") ?? "Failed To Add.")"
                DispatchQueue.main.async {
                    CommonClass.showSnackBar(message: message)
                    completion()
                }
                return
            }

            completion()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {

        super.viewDidAppear(animated)
        print("CUSTOM CART APPEAR =", Date())
        print("viewDidAppear Pending =", mPendingProducts.count)
            print("isAddingProducts =", isAddingProducts)

        print("======== CustomCart ========")
        print("self =", self)
        print("navigation =", navigationController as Any)
        print("viewControllers =")
        
        print("CUSTOM NAV =", navigationController as Any)
        print("STACK =", navigationController?.viewControllers ?? [])
        
        navigationController?.viewControllers.forEach {
            print($0)
        }
        
            if isAddingProducts {
                print("❌ Skip เพราะ isAddingProducts = true")
                return
            }

            if mPendingProducts.isEmpty {
                print("❌ Skip เพราะ Pending ว่าง")
                return
            }

            isAddingProducts = true

            print("✅ addPendingProducts()")

            addPendingProducts()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mCustomerId = UserDefaults.standard.string(forKey: "DEFAULTCUSTOMER") ?? ""
        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
        self.mNotes.keyboardType = .default
        self.mCartTable.delegate = self
        self.mCartTable.dataSource = self
        self.mCartTable.reloadData()
        mCustomerId  = UserDefaults.standard.string( forKey: "DEFAULTCUSTOMER") ?? ""

        // Dismiss keyboard when tapping anywhere outside a UITextField.
        // Keep button/table interactions working.
        let dismissKeyboardTap = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboardFromTap(_:))
        )
        dismissKeyboardTap.cancelsTouchesInView = false
        dismissKeyboardTap.delegate = self
        self.view.addGestureRecognizer(dismissKeyboardTap)
        
//        self.navigationItem.setHidesBackButton(true, animated: false)
    }
    
    @objc private func dismissKeyboardFromTap(_ gesture: UITapGestureRecognizer) {
        guard gesture.state == .ended else { return }

        let location = gesture.location(in: self.view)
        let hitView = self.view.hitTest(location, with: nil)

        // If the tap is inside any UITextField, do not dismiss.
        var current: UIView? = hitView
        while let view = current {
            if view is UITextField {
                return
            }
            current = view.superview
        }

        self.view.endEditing(true)
    }

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldReceive touch: UITouch
    ) -> Bool {
        // Keep UITextField focus/editing behavior normal.
        var current: UIView? = touch.view
        while let view = current {
            if view is UITextField {
                return false
            }
            current = view.superview
        }
        return true
    }

    func mOnUpdated(data: NSDictionary) {
        mFetchCartItems()
    }
    
    @IBAction func mOpenProductStoneDetails(_ sender: UIButton) {
        let mIndex = sender.tag
        if let mData = mCartData[mIndex] as? NSDictionary,
           let customCartId = mData.value(forKey: "custom_cart_id") as? String,
           let productId = mData.value(forKey: "id") as? String {
            let storyBoard: UIStoryboard = UIStoryboard(name: "common", bundle: nil)
            if let home = storyBoard.instantiateViewController(withIdentifier: "ProductStoneEdit") as? ProductStoneEdit {
                home.modalPresentationStyle = .automatic
                home.mCartId = "\(customCartId)"
                home.mCustomerId = mCustomerId
                home.mOrderType = "custom_order"
                home.mProductIds = "\(productId)"
                home.delegate = self
                home.transitioningDelegate = self
                self.present(home, animated: true)
            }
        }
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        let mParams = [ "customer_id":mCustomerId ,"custom_data": mCartData] as [String : Any]
       
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        
        mQuoteButton.setTitle("QUOTE".localizedString, for: .normal)
        mCheckOutButton.setTitle("CHECK OUT".localizedString, for: .normal)
        mBottomQuotationLABEL.text = "Quotation".localizedString
        mBottomCatalogLABEL.text = "Catalog".localizedString
        mBottomInventoryLABEL.text = "Inventory".localizedString
        mBottomCustomerLABEL.text = "Customer".localizedString
        
        
        mHeadingLABEL.text = "Create your own".localizedString
        mNoteLABEL.text = "Note".localizedString
        mGrandTotalLABEL.text = "Grand Total".localizedString
        mDepositeLABEL.text = "Deposit".localizedString
        mOutstandingBalance.text = "Outstanding Balance".localizedString
        
        
        
        mTotalItems.text = "0 " + "Item".localizedString
        mSearchField.placeholder = "Search by SKU / Stock ID".localizedString
        mNotes.placeholder = "EX. Urgent Order".localizedString
        
        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
        print("CustomCart.swift mCartData = \(mCartData)")
        
        mGrandTotal.text = "\(UserDefaults.standard.value(forKey: "currencySymbol") ?? "$") 0.00"
        mDepositAmount.text = mGrandTotal.text
        mOutstandingAmount.text = mGrandTotal.text
        print("3 mOutstandingAmount.text =", mOutstandingAmount.text ?? "")
        
        mGetData(url: mFetchPaymentMethod,headers: sGisHeaders,  params: ["":""]) { response , status in
            if status {
                if let mData = response.value(forKey: "data") as? NSDictionary {
                    print("CustomCart.swift mData = \(mData)")
                    //Store Cash Data
                    self.mCurrency =  mData.value(forKey: "currency") as? String ?? ""
                    print("self.mCurrencyself.mCurrency = \(self.mCurrency)")
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
            self.mCheckAddresse()
        }
        
        let mParams = ["query":"{stones{id name}colors{id name}metals{id name}shapes{id name}claritys{id name}cuts{id name}sizes{id name}settingType{id name}stonecolors{id name}}"]
        AF.request(mGrapQlUrl, method:.post,parameters: mParams, encoding:JSONEncoding.default, headers: sGisHeaders).responseJSON
        { response in
            if(response.error != nil) {
                UserDefaults.standard.set(nil, forKey: "GRAPHQL")
                
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
                
                UserDefaults.standard.set(jsonResult, forKey: "GRAPHQL")
            }
        }
        
        
        AF.request(mGetShapes, method:.post,parameters: nil, headers: sGisHeaders).responseJSON
        { response in
            if(response.error != nil) {
                UserDefaults.standard.set(nil, forKey: "SHAPES")
                
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
                
                UserDefaults.standard.set(jsonResult, forKey: "SHAPES")
            }
        }
        
        mCustomerId  = UserDefaults.standard.string( forKey: "DEFAULTCUSTOMER") ?? ""
//        if !mCustomerId.isEmpty {
//            self.mSelectedCustomerIcon.image = UIImage(named: "selected_customer")
//            mFetchCartItems()
//        }
        if !mCustomerId.isEmpty {
            self.mSelectedCustomerIcon.image = UIImage(named: "selected_customer")

            // Faro products are added in viewDidAppear. Do not start an
            // independent fetch here: it can complete after the additions and
            // replace the table with the old, empty cart response.
            if mCartData.count == 0 && mPendingProducts.isEmpty {
                mFetchCartItems()
            } else {
                mCartTable.reloadData()
                calculateItemsWithAmount()
            }
        }
        
        let isQuotation = UserDefaults.standard.bool(forKey: "isQuotation")
        self.mQuotationView.isHidden = !isQuotation
        self.mQuoteButton.isHidden = !isQuotation
        
        if isQuotation {
            mFetchQuote()
        }
        
//        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationItem.hidesBackButton = true
        
        print("🔥 viewWillAppear")
        print("🔥 BEFORE FETCH =", mCartData)
    }
    
  func mFetchQuote(){
      
      
        mGetData(url: mGetAllQuotations,headers: sGisHeaders,  params: ["customer_id":self.mCustomerId]) { response , status in
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
    
    
    @IBAction func mOpenAddressPicker(_ sender: Any) {
        if !mCustomerId.isEmpty {
            let storyBoard: UIStoryboard = UIStoryboard(name: "AddressPicker", bundle: nil)
            if let addressPicker = storyBoard.instantiateViewController(withIdentifier: "AddressPicker") as? AddressPicker {
                addressPicker.mCustomerId = mCustomerId
                self.navigationController?.pushViewController(addressPicker, animated: true)
            }
        }
    }
    
    @IBAction func mBack(_ sender: Any) {

        print("===== BACK =====")
        print(navigationController?.viewControllers as Any)

        UserDefaults.standard.setValue(nil, forKey: "cRemark")

        // Pop only once: CustomCart -> previous screen
        navigationController?.popViewController(animated: true)

//        dismiss(animated: true, completion: nil)
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
    @IBAction func mCatalog(_ sender: Any) {
        self.isQuotation = false

        if mCustomerId == "" {
            CommonClass.showSnackBar(message: "Please choose customer first!")
            mOpenCustomerSheet()
            return
        }
        let storyBoard: UIStoryboard = UIStoryboard(name: "common", bundle: nil)
        if let mCommonCatalog = storyBoard.instantiateViewController(withIdentifier: "CommonCatalog") as? CommonCatalog {
            print("CustomCart.swift withIdentifier: CommonCatalog")
            mCommonCatalog.delegate =  self
            mCommonCatalog.mCustomerId = mCustomerId
            mCommonCatalog.mOrderType = "custom_order"
            self.navigationController?.pushViewController(mCommonCatalog , animated: true)
        }
    }
    
    func mGetInventoryItems(items: [String]) {
        
        print("========== CustomCart DELEGATE CALLBACK ==========")
        print("CustomCart mGetInventoryItems CALLED")
        print("CustomCart ITEMS =", items)
        print("CustomCart CUSTOMER ID =", mCustomerId)
        print("=======================================")
        self.isQuotation = false
        self.linkedCartContext = LinkedCartContextStore.shared.context(
            orderType: "custom_order",
            customerId: mCustomerId
        )
        mFetchCartItems()
    }
    
//    func mFetchCartItems() {
//
//        var mParams = [String: Any]()
//
//        if isQuotation {
//
//            mParams = [
//                "quatation_id": self.mQuotationId
//            ]
//
//        } else {
//
//            mParams = [
//                "customer_id": mCustomerId
//            ]
//        }
//
//        print("========== GET CART REQUEST DEBUG ==========")
//        print("🔥 CUSTOMER ID =", mCustomerId)
//        print("🔥 PARAMS =", mParams)
//        print("============================================")
//
//        CommonClass.showFullLoader(view: self.view)
//
//        mGetData(
//            url: mFetchCustomProduct,
//            headers: sGisHeaders,
//            params: mParams
//        ) { response, status in
//
//            CommonClass.stopLoader()
//
//            print("========== GET CART RESPONSE DEBUG ==========")
//            print("🔥 STATUS =", status)
//            print("🔥 RESPONSE =", response)
//            print("=============================================")
//
//            if status {
//
//                if "\(response.value(forKey: "code") ?? "")" == "200" {
//
//                    if let data = response.value(forKey: "data") as? NSArray {
//
//                        print("🔥 CART COUNT =", data.count)
//
//                        self.isQuotation = false
//                        self.mCartDataMaster = data
//                        self.mCartData = NSMutableArray(array: data)
//
//                        self.mCartTable.delegate = self
//                        self.mCartTable.dataSource = self
//
//                        self.mQuantityData.removeAll()
//                        self.mCartAmount.removeAll()
//
//                        for item in self.mCartData {
//
//                            if let cartItem = item as? NSDictionary {
//
//                                let qty =
//                                    Int("\(cartItem.value(forKey: "Qty") ?? "0")") ?? 0
//
//                                let price =
//                                    Double(
//                                        "\(cartItem.value(forKey: "price") ?? "0")"
//                                            .replacingOccurrences(of: ",", with: "")
//                                    ) ?? 0.0
//
//                                self.mQuantityData.append(qty)
//                                self.mCartAmount.append(price)
//                            }
//                        }
//
//                        DispatchQueue.main.async {
//
//                            self.mCartTable.reloadData()
//                            self.calculateItemsWithAmount()
//                        }
//                    }
//                }
//            }
//        }
//    }
    
    func mFetchCartItems() {

        
        var mParams = [String: Any]()

        if isQuotation {
            mParams = [
                "quatation_id": self.mQuotationId
            ]
        } else {
            mParams = [
                "customer_id": self.mCustomerId
            ]
        }

        print("========== GET CART REQUEST DEBUG ==========")
        print("🔥 CUSTOMER ID =", self.mCustomerId)
        print("🔥 PARAMS =", mParams)
        print("============================================")
        
        
        let fetchStart = Date()

        print("")
        print("========== FETCH CART ==========")
        print("START =", fetchStart)
        print("===============================")
//        showCartLoading()
        DispatchQueue.main.async {
                CommonClass.showFullLoader(view: self.view)
            }

        mGetData(
            url: mFetchCustomProduct,
            headers: sGisHeaders,
            params: mParams
        ) { response, status in

            DispatchQueue.main.async {
                self.hideCartLoading()
                CommonClass.stopLoader()
            }
            
            let fetchDuration =
                Date().timeIntervalSince(fetchStart)

            print("")
            print("========== FETCH CART ==========")
            print("END =", Date())
            print("TIME =", fetchDuration)
            print("===============================")

            print("========== GET CART ITEMS DEBUG ==========")
            print("🔥 STATUS =", status)
            print("🔥 RESPONSE =", response)
            print("==========================================")

            guard status else {
                DispatchQueue.main.async {
                    self.hideCartLoading()
                    CommonClass.stopLoader()
                }
                return
            }

            guard "\(response.value(forKey: "code") ?? "")" == "200" else {
                DispatchQueue.main.async {
                    self.hideCartLoading()
                    CommonClass.stopLoader()
                }
                return
            }

            guard let data = response.value(forKey: "data") as? NSArray else {
                DispatchQueue.main.async {
                    self.hideCartLoading()
                    CommonClass.stopLoader()
                }
                return
            }

            print("🔥 AFTER API =", data)
            print("🔥 CART COUNT =", data.count)
            print("===== API DATA =====")
            for case let item as NSDictionary in data {
                print("SKU =", item["SKU"] ?? "")
                print("price =", item["price"] ?? "")
                print("cart_price =", item["cart_price"] ?? "")
            }
            print("====================")
            for case let item as NSDictionary in data {
                print("=== API ===")
                print("SKU =", item["SKU"] ?? "")
                print("Qty =", item["Qty"] ?? "")
                print("price =", item["price"] ?? "")
                print("cart_price =", item["cart_price"] ?? "")
            }

            self.isQuotation = false
            self.mCartDataMaster = data
            self.mCartData = NSMutableArray(array: data)
            
            print("===== FETCHED CART =====")
            for case let item as NSDictionary in self.mCartData {
                print(
                    "SKU =", item["SKU"] ?? "",
                    "Qty =", item["Qty"] ?? "",
                    "price =", item["price"] ?? "",
                    "cart_price =", item["cart_price"] ?? ""
                )
            }
            print("========================")

            self.mQuantityData.removeAll()
            self.mCartAmount.removeAll()

            for item in data {
                guard let dict = item as? NSDictionary else {
                    continue
                }
                
                print("========== CART ITEM ==========")
                print("id =", dict["id"] ?? "")
                print("product_id =", dict["product_id"] ?? "")
                print("SKU =", dict["SKU"] ?? "")
                print("sku =", dict["sku"] ?? "")
                print("stock_id =", dict["stock_id"] ?? "")
                print("name =", dict["name"] ?? "")
                print("===============================")

//                let qty = Int("\(dict["Qty"] ?? 0)") ?? 0
//                let price = Double("\(dict["price"] ?? 0)") ?? 0
//
//                self.mQuantityData.append(qty)
//                self.mCartAmount.append(price)
                let qty = Int("\(dict["Qty"] ?? 0)") ?? 0
                let price = Double("\(dict["cart_price"] ?? 0)") ?? 0

                self.mQuantityData.append(qty)
                self.mCartAmount.append(price)
            }

            DispatchQueue.main.async {
                self.mCartTable.delegate = self
                self.mCartTable.dataSource = self
                print("")
                print("========== RELOAD ==========")
                print("TABLE RELOAD =", Date())
                print("===========================")
                self.mCartTable.reloadData()
                self.calculateItemsWithAmount()
                self.hideCartLoading()
                CommonClass.stopLoader()
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
        self.isQuotation = false

        if mCustomerId == "" {
            CommonClass.showSnackBar(message: "Please choose customer first!")
            mOpenCustomerSheet()
            return
        }
        let storyBoard: UIStoryboard = UIStoryboard(name: "common", bundle: nil)
        if let mInv = storyBoard.instantiateViewController(withIdentifier: "CommonInventory") as? CommonInventory {
            mInv.modalPresentationStyle = .overFullScreen
            mInv.mOrderType = "custom_order"
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
                guard let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
                      let code = json["code"] as? Int else {
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
        if let customerId = data.value(forKey: "id") as? String,
           let customerName = data.value(forKey: "name") as? String {
            UserDefaults.standard.set(customerId, forKey: "DEFAULTCUSTOMER")
            UserDefaults.standard.set(data.value(forKey: "profile") ?? "", forKey: "DEFAULTCUSTOMERPICTURE")
            UserDefaults.standard.set(customerName, forKey: "DEFAULTCUSTOMERNAME")
            
            self.mCustomerId = customerId
            self.mSelectedCustomerIcon.image = UIImage(named: "selected_customer")
            self.isQuotation = false
            
            UserDefaults.standard.setValue(nil, forKey: "CustomerBillingAddressUDID")
            UserDefaults.standard.setValue(nil, forKey: "CustomerShippingAddressUDID")
            
            if let haveAddresses = data.value(forKey: "haveAddresses") as? Bool {
                mAddressPickerIcon.image = UIImage(named: "address_pick_ic_green")
                mAddressPickerAlertIcon.isHidden = haveAddresses
            } else {
                mAddressPickerIcon.image = UIImage(named: "address_pick_ic_green")
                mAddressPickerAlertIcon.isHidden = false
            }
            
            mFetchCartItems()
            
            if UserDefaults.standard.bool(forKey: "isQuotation") {
                mFetchQuote()
            }
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
        }
        mConfirmQuote.mHeadingLabel.text = "Add Note".localizedString
        mConfirmQuote.mSubHeading.text = "Note for the order you want a quotation".localizedString
        mConfirmQuote.mDueDateLABEL.text = "Due Date".localizedString
        mConfirmQuote.mCancelButton.setTitle("CANCEL".localizedString, for: .normal)
        mConfirmQuote.mCreateQuote.setTitle("CREATE A QUOTE".localizedString, for: .normal)
        mConfirmQuote.mNewDate = Date.getCurrentDateGMT()
        mConfirmQuote.mCurrentDate.text = Date.getCurrentDate()
        self.view.addSubview(mConfirmQuote)

        // Prepare the Suggestions popup, but do not show it yet.
        // It will appear only when the user taps the Note field.
        quoteSuggestionsSuppressedAfterSelection = false
        setupQuoteSuggestions()
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
            mSellInfo.setValue("custom_order", forKey: "status_type")
            mSellInfo.setValue(Double(self.mGrandTotalAmounts) ?? 0.00, forKey: "totalamount")
        let  mFinalData = ["sell_info": mSellInfo, "totalamount":self.mGrandTotalAmounts,
                           "order_type":"custom_order",
                           "quatetime": noOfReceived ?? "Customer is interested but wants to hold for now",
                           
                           "duedate":date] as [String : Any]
        CommonClass.showFullLoader(view: self.view)
        
            mGetData(url: mSaveQuotation,headers: sGisHeaders,  params: mFinalData) { response , status in
                if status {
                    self.hideCartLoading()
                    CommonClass.stopLoader()
                    CommonClass.showSnackBar(message: "Quotation Added Successfully")
                    self.mFetchQuote()
                    self.mCartDataMaster = NSArray()
                    self.mCartData = NSMutableArray()
                    self.mQuantityData = [Int]()
                    self.mCartAmount = [Double]()
                    self.mCartTable.reloadData()
                    self.calculateItemsWithAmount()
                    
                }
        }
        
    }
    func mGetDatePicker() {
            let currentDate = Date()
            var datecomp = DateComponents()
            let min = Calendar.init(identifier: .gregorian)
            
            mDatePicker.preferredDatePickerStyle = .wheels
            mDatePicker.calendar = Calendar(identifier: .gregorian)
            mDatePicker.locale = Locale(identifier: "en_US_POSIX")
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
             let mDayd = DateFormatter()
                 mDayd.dateFormat = "dd"
             
             let mMonthm = DateFormatter()
                 mMonthm.dateFormat = "MM"
                   
             let mYeard = DateFormatter()
                 mYeard.dateFormat = "yyyy"
                 
        let calendar = Calendar(identifier: .gregorian)
        let locale = Locale(identifier: "en_US_POSIX")

        mDayd.calendar = calendar
        mMonthm.calendar = calendar
        mYeard.calendar = calendar

        mDayd.locale = locale
        mMonthm.locale = locale
        mYeard.locale = locale
        
        mConfirmQuote.mCurrentDate.text  = "\(mDayd.string(from: mDatePicker.date))/" +  "\(mMonthm.string(from: mDatePicker.date))/"+"\(mYeard.string(from: mDatePicker.date))"
        mConfirmQuote.mNewDate = mDatePicker.date
       
           self.view.endEditing(true)
        
                 
         }
         @objc func mCancelPick(){
             self.view.endEditing(true)
         }
    
    
    
    @IBAction func mCheckOut(_ sender: UIButton) {
        sender.showAnimation{ [self] in
            
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
            
            let storyBoard: UIStoryboard = UIStoryboard(name: "customOrder", bundle: nil)
            if let mCheckOut = storyBoard.instantiateViewController(withIdentifier: "CustomOrderCheckout") as? CustomOrderCheckout {
                mCheckOut.mTotalP = "\(PriceHelper.unformatPrice(self.mTotalDepositAmounts))"
                mCheckOut.mSubTotalP = ""
                mCheckOut.mTaxP = ""
                mCheckOut.mTaxAm = ""
                mCheckOut.mStoreCurrency =  self.mCurrency
                mCheckOut.mOrderType = "custom_order"
                mCheckOut.mRemark = self.mNotes.text ?? ""
                mCheckOut.mNote = self.mNotes.text ?? ""
//                mCheckOut.mRemark = self.mNotes.text ?? ""
                mCheckOut.mTaxType =  ""
                mCheckOut.mTaxLabel =  ""
                mCheckOut.mLabourPoints = Int(self.mServiceAmounts.reduce(0, {$0 + $1}))
                mCheckOut.mTotalOutstandingAm = "\(PriceHelper.unformatPrice(self.mOutStandingAmounts))"
                print("mGrandTotalCart =", self.mGrandTotalCart)
                print("mOutStandingAmounts =", self.mOutStandingAmounts)
                mCheckOut.mCurrencySymbol = self.mCurrency
//                mCheckOut.mCartTotalAmount = self.mGrandTotalCart
                mCheckOut.mCartTotalAmount = "\(PriceHelper.unformatPrice(self.mGrandTotalCart))"
                mCheckOut.mDepositPercents = self.mDepositPercents
                mCheckOut.mTotalWithDiscount =  self.mTotalDepositAmounts
                mCheckOut.mTaxPercent =  ""
                mCheckOut.mCustomerId = self.mCustomerId
                
                print("========== CUSTOM CART BEFORE CHECKOUT ==========")

                for case let item as NSDictionary in self.mCartData {
                    print(
                        "SKU =",
                        item["SKU"] ?? "",
                        "DELIVERY DATE =",
                        item["delivery_date"] ?? "nil"
                    )
                }

                print("=================================================")
                
                mCheckOut.mCartTableData =  self.mCartData
                mCheckOut.applyLinkedCartContext(self.linkedCartContext)
                self.navigationController?.pushViewController( mCheckOut, animated:true)
            }
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mCartData.count
        if mCartData.count == 0 {
            tableView.setError("No items found!")
        }else{
            tableView.clearBackground()
        }
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
        cell.mEditServiceLabourButton.tag = indexPath.row
        cell.mShowServiceLabourButton.tag = indexPath.row
        
        guard let mData = mCartData[indexPath.row] as? NSDictionary else {
            return cell
        }
        
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
                                    if let items = i as? NSDictionary,
                                       let serviceAmount = items.value(forKey: "scrviceamount") {
                                        let unFormatedAmount = "\(serviceAmount)".replacingOccurrences(of: ",", with: "")
                                        mAmounts.append(Double(unFormatedAmount) ?? 0.00)
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
            
        if let mCustomDesignStatus = mData.value(forKey: "Custom_design_status") as? Bool {
            if mCustomDesignStatus {
                cell.mEditIcon.image = UIImage(named: "edit_custom_green")
            }else{
                cell.mEditIcon.image = UIImage(named: "edit_custom")
            }
        }
        print("CustomCart.swift mData = \(mData)")
//        cell.mDueDate.text = "\(mData.value(forKey: "delivery_date") ?? "--")"
        let value2 = mData.value(forKey: "delivery_date")

        print("type =", type(of: value2))
        print("value =", value2 as Any)

        print("ROOT =", mData["delivery_date"] ?? "")

        if let product = mData["product_details"] as? NSDictionary {
            print("PRODUCT =", product["delivery_date"] ?? "")
        }
        
        let deliveryDate = mData["delivery_date"] as? String ?? ""

        var date: Date?

        // 1. ISO8601 จาก API
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        date = isoFormatter.date(from: deliveryDate)

        // 2. dd/MM/yyyy จาก DatePicker
        if date == nil {
            let formatter = DateFormatter()
            formatter.calendar = Calendar(identifier: .gregorian)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "dd/MM/yyyy"

            date = formatter.date(from: deliveryDate)
        }

        if let date = date {
            let output = DateFormatter()
            output.calendar = Calendar(identifier: .gregorian)
            output.locale = Locale(identifier: "en_US_POSIX")
            output.dateFormat = "dd/MM/yyyy"

            cell.mDueDate.text = output.string(from: date)
        } else {
            cell.mDueDate.text = "--"
        }
        
        self.mCurrency = "\(mData.value(forKey: "currency") ?? "$")"
        print("222self.mCurrencyself.mCurrency = \(self.mCurrency)")
//        self.mCurrency = "\(mData.value(forKey: "currency") ?? "$") "
        cell.mRemarks.keyboardType = .default
        cell.mRemarks.text = "\(mData.value(forKey: "remark") ?? "")"
        cell.mSKUName.text = "\(mData.value(forKey: "SKU") ?? "")"
        cell.mProductName.text = "\(mData.value(forKey: "name") ?? "")"
        cell.mMetalColorSize.text = "\(mData.value(forKey: "color_name") ?? "") " + "\(mData.value(forKey: "metal_name") ?? "") " + "\(mData.value(forKey: "size_name") ?? "")"
//        cell.mProductPrice.text = "\(mData.value(forKey: "price") ?? "")"
//        let amount = "\(mData.value(forKey: "price") ?? "")"
//        print("CustomCart.swift amount = \(amount)")
//        let raw = amount
//                .replacingOccurrences(of: ",", with: "")
//                .replacingOccurrences(of: "$", with: "")
//                .trimmingCharacters(in: .whitespaces)
//        print("CustomCart.swift raw = \(raw)")
//        let formatter = NumberFormatter()
//        formatter.numberStyle = .decimal
//        formatter.minimumFractionDigits = 2
//        formatter.maximumFractionDigits = 2
//        let price = (Double("\(mData.value(forKey: "price") ?? "0")") ?? 0.0)
//        let value = " \(mData.value(forKey: "price") ?? "0.00" )"//mData.value(forKey: "price") ?? "0"//formatter.string(from: NSNumber(value: price))
//            let value = Double(raw) ?? 0
        let price = PriceHelper.parsePrice("\(mData.value(forKey: "price") ?? "0")")

        let value = PriceHelper.formatPrice(
            price,
            currency: self.mCurrency
        )
        print("CustomCart.swift value = \(value)")
        
        let attributed = NSMutableAttributedString()

        // $
//        attributed.append(
//            NSAttributedString(
//                string: "$ ",
//                attributes: [
//                    .foregroundColor: UIColor.black,
//                    .font: UIFont(name: "SegoeUI", size: 14)! // หรือ UIFont.systemFont(ofSize: 14)
//                ]
//            )
//        )

        // จำนวนเงิน
        attributed.append(
            NSAttributedString(
                string: value,
                attributes: [
                    .foregroundColor: UIColor(named: "themeColor") ?? .systemTeal,
                    .font: UIFont(name: "SegoeUI", size: 14)!
                ]
            )
        )

        cell.mProductPrice.attributedText = attributed
        cell.mProductPrice.transform = CGAffineTransform(
            translationX: 0,
            y: 8
        )
        cell.mStockId.text = "\(mData.value(forKey: "stock_id") ?? "")"
        
        cell.mProductImage.downlaodImageFromUrl(urlString: "\(mData.value(forKey: "main_image") ?? "")")
        cell.mProductImage.tag = indexPath.row
        cell.imageTapGesture(target: self, action: #selector(handleImageTap(_:)))
        
//        calculateItemsWithAmount()
        
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
        
        if let mData = self.mCartData[sender.tag] as? NSDictionary,
           let mServiceData = mData.value(forKey: "Service_labour") as? NSDictionary {
            let storyBoard: UIStoryboard = UIStoryboard(name: "laybyInstallment", bundle: nil)
            if let mSelectedServiceLabour = storyBoard.instantiateViewController(withIdentifier: "SelectedServiceLabour") as? SelectedServiceLabour {
                mSelectedServiceLabour.modalPresentationStyle = .automatic
                mSelectedServiceLabour.mProductData = mServiceData
                print("mShowServiceLabour SERVICE PRODUCT DATA = \(mServiceData)")
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
            print("mEditServiceLabour SERVICE PRODUCT DATA = ", mCommonServiceLabour.mProductData)
            mCommonServiceLabour.transitioningDelegate = self
            self.present(mCommonServiceLabour,animated: true)
        }
    }
    
    
    func mGetSearchItems(
        id: String,
        fetchAfter: Bool = true
    ) {

        print("")
        print("==================================================")
        print("🚨🚨 mGetSearchItems START")
        print("==================================================")
        print("🔥 PRODUCT ID =", id)
        print("🔥 CUSTOMER ID =", self.mCustomerId)
        print("🔥 fetchAfter =", fetchAfter)
        print("🔥 API =", mAddCustomProduct)

        let mParams: [String: Any] = [
            "product_id": [id],
            "customer_id": self.mCustomerId,
            "sales_person_id": "",
            "type": "catalog",
            "order_type": "custom_order"
        ]

        print("🔥 REQUEST PARAMS =", mParams)
        print("🔥 CALLING mAddCustomProduct NOW...")
        print("==================================================")

        let startTime = Date()

        mGetData(
            url: mAddCustomProduct,
            headers: sGisHeaders,
            params: mParams
        ) { response, status in

            let responseTime = Date().timeIntervalSince(startTime)

            print("")
            print("==================================================")
            print("🚨🚨 mGetSearchItems RESPONSE")
            print("==================================================")
            print("🔥 API =", mAddCustomProduct)
            print("🔥 RESPONSE TIME =", responseTime, "sec")
            print("🔥 STATUS =", status)
            print("🔥 RAW RESPONSE =", response)

            let code = "\(response.value(forKey: "code") ?? "")"

            print("🔥 RESPONSE CODE =", code)

            if let message = response.value(forKey: "message") {
                print("🔥 MESSAGE =", message)
            }

            if let error = response.value(forKey: "error") {
                print("🔥 ERROR =", error)
            }

            print("==================================================")
            self.hideCartLoading()
            CommonClass.stopLoader()

            guard status else {

                print("❌ mGetSearchItems FAILED: status = false")
                print("==================================================")

                return
            }

            guard code == "200" else {

                print("❌ mGetSearchItems FAILED: code =", code)
                print("==================================================")

                return
            }

            print("✅ mGetSearchItems API SUCCESS")

            if fetchAfter {

                print("")
                print("==================================================")
                print("🚨 CALLING mFetchCartItems()")
                print("==================================================")

                self.mFetchCartItems()

            } else {

                print("⚠️ fetchAfter = false")
                print("⚠️ mFetchCartItems() WILL NOT BE CALLED")
            }

            print("==================================================")
        }
    }
    
    @IBAction func mSearchnow(_ sender: Any) {
        
        self.isQuotation = false
        let storyBoard: UIStoryboard = UIStoryboard(name: "Test", bundle: nil)
        if let mCommonSearch = storyBoard.instantiateViewController(withIdentifier: "CommonSearch") as? CommonSearch {
            mCommonSearch.modalPresentationStyle = .overFullScreen
            mCommonSearch.delegate = self
            mCommonSearch.mType = "catalog"
            mCommonSearch.mFrom = "createYourOwn"
            mCommonSearch.transitioningDelegate = self
            self.present(mCommonSearch,animated: false)
        }
    }
    
    @IBAction func mMinusButton(_ sender: UIButton) {
      

        let index = sender.tag
        guard let mInvData = mCartData[index] as? NSDictionary,
              let cells = mCartTable.cellForRow(at: IndexPath(row: index, section: 0)) as? CustomCartItems,
              let mOrgData = mCartDataMaster[index] as? NSDictionary else {
            return
        }
        
        let mMinQty = 1
        var mCurrentQty = Int(cells.mQuantityUnit.text ?? "0") ?? 0

        if mCurrentQty == mMinQty {
            // ไม่ลดต่ำกว่า 1
            return
        } else {
            mCurrentQty -= 1
            
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.minimumFractionDigits = 2
            formatter.maximumFractionDigits = 2

            
            if mCurrentQty == 1 {
                cells.mQuantityUnit.text = "\(mMinQty)"
                print("mCurrentQty == 1 cells.mProductPrice.text = \(String(describing: cells.mProductPrice.text))")
//                cells.mProductPrice.text = "\((Double("\(mInvData.value(forKey: "price") ?? "0")") ?? 0.0) - (self.mCartAmount[sender.tag]))"
                let unitPrice = Double("\(mOrgData["cart_price"] ?? 0)") ?? 0
                let totalPrice = unitPrice * Double(mCurrentQty)

                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal
                formatter.minimumFractionDigits = 2
                formatter.maximumFractionDigits = 2

//                cells.mProductPrice.text = formatter.string(from: NSNumber(value: totalPrice))
                print("CustomCart.swift mMinusButton self.mCurrency = \(self.mCurrency)")
                cells.mProductPrice.text = PriceHelper.formatPrice(
                    totalPrice,
                    currency: self.mCurrency
                )
            }else{
                cells.mQuantityUnit.text = "\(mCurrentQty)"
                print("else cells.mProductPrice.text = \(String(describing: cells.mProductPrice.text))")
//                cells.mProductPrice.text = "\((Double("\(mInvData.value(forKey: "price") ?? "0")") ?? 0.0) - (self.mCartAmount[sender.tag]))"
                let unitPrice = Double("\(mOrgData["cart_price"] ?? 0)") ?? 0
                let totalPrice = unitPrice * Double(mCurrentQty)

                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal
                formatter.minimumFractionDigits = 2
                formatter.maximumFractionDigits = 2

//                cells.mProductPrice.text = formatter.string(from: NSNumber(value: totalPrice))
                print("CustomCart.swift mMinusButton self.mCurrency = \(self.mCurrency)")
                cells.mProductPrice.text = PriceHelper.formatPrice(
                    totalPrice,
                    currency: self.mCurrency
                )
                
                
            }
        }
        
        var mData = NSMutableDictionary()
        mData.setValue("\(mInvData.value(forKey: "id") ?? "")", forKey: "id")
        mData.setValue("\(cells.mQuantityUnit.text ?? "0")", forKey: "Qty")
        mData.setValue("\(mInvData.value(forKey: "type") ?? "")", forKey: "type")
        mData.setValue("\(mInvData.value(forKey: "SKU") ?? "")", forKey: "SKU")
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
        mData.setValue("\(mInvData.value(forKey: "stock_id") ?? "")", forKey: "stock_id")
//        mData.setValue("\(cells.mProductPrice.text ?? "")", forKey: "price")
        mData.setValue(
            PriceHelper.parsePrice(cells.mProductPrice.text),
            forKey: "price"
        )
        
//        mData.setValue("\(mInvData["cart_price"] ?? "")", forKey: "cart_price")
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
        
        print("Qty =", cells.mQuantityUnit.text ?? "")
        print("Price Label =", cells.mProductPrice.text ?? "")
        print("Saving Price =", mData["price"] ?? "")
        
        mCartData.removeObject(at: index)
        mCartData.insert(mData, at: index)
        mCartTable.reloadData()
        calculateItemsWithAmount()

    }
    
    
    @IBAction func mPlusButton(_ sender: UIButton) {
        let index = sender.tag
        
        guard let mOrgData = mCartDataMaster[sender.tag] as? NSDictionary,
              let mInvData = mCartData[index] as? NSDictionary,
              let cells = mCartTable.cellForRow(at: IndexPath(row: sender.tag , section: 0)) as? CustomCartItems else {
            return
        }
//        let mMaxQty =  Int("\(mInvData.value(forKey: "po_QTY") ?? "1")") ?? 1
        let mMaxQty = 9999
        var mCurrentQty = Int(cells.mQuantityUnit.text ?? "0") ?? 0
//        print("Current Qty =", mCurrentQty)
//        print("Max Qty =", mMaxQty)
//        print("Inventory Data =", mInvData)
        if mCurrentQty == mMaxQty {
            return
        }
        
        
        
        
        mCurrentQty += 1
        cells.mQuantityUnit.text = "\(mCurrentQty)"
        
//        cells.mProductPrice.text = "\((Double("\(mInvData.value(forKey: "price") ?? "0")") ?? 0.0) + (self.mCartAmount[sender.tag] ?? 0.0) )"
        print("price =", mInvData["price"] ?? "")
        print("cart_price =", mOrgData["cart_price"] ?? "")
        print("mCartAmount =", self.mCartAmount[sender.tag])
        
        let unitPrice = Double("\(mOrgData["cart_price"] ?? 0)") ?? 0
        let totalPrice = unitPrice * Double(mCurrentQty)

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2

//        cells.mProductPrice.text = formatter.string(from: NSNumber(value: totalPrice))
        print("CustomCart.swift mPlusButton self.mCurrency = \(self.mCurrency)")
        cells.mProductPrice.text = PriceHelper.formatPrice(
            totalPrice,
            currency: self.mCurrency
        )
        print("mPlusButton cells.mProductPrice.text = \(String(describing: cells.mProductPrice.text))")

        var mData = NSMutableDictionary()
        mData.setValue("\(mInvData.value(forKey: "id") ?? "")", forKey: "id")
        mData.setValue("\(mInvData.value(forKey: "type") ?? "")", forKey: "type")
        mData.setValue("\(cells.mQuantityUnit.text ?? "")", forKey: "Qty")
        mData.setValue("\(mInvData.value(forKey: "SKU") ?? "")", forKey: "SKU")
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
        mData.setValue("\(mInvData.value(forKey: "stock_id") ?? "")", forKey: "stock_id")
//        mData.setValue("\(cells.mProductPrice.text ?? "")", forKey: "price")
        print("CustomCart.swift mPlusButton self.mCurrency = \(self.mCurrency)")
        mData.setValue(
            PriceHelper.parsePrice(cells.mProductPrice.text),
            forKey: "price"
        )
        
//        mData.setValue(mOrgData["cart_price"], forKey: "cart_price")
//        mData.setValue("\(mInvData["cart_price"] ?? "")", forKey: "cart_price")
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
    
    
    
     

    @IBAction func mChooseDate(_ sender: UIButton) {
        guard let cells = mCartTable.cellForRow(at: IndexPath(row: sender.tag , section: 0)) as? CustomCartItems else {
            return
        }

        mCurrentIndex = sender.tag
        let currentDate = Date()
        var datecomp = DateComponents()
        let min = Calendar.init(identifier: .gregorian)
        
        mDatePicker.preferredDatePickerStyle = .wheels
        mDatePicker.calendar = Calendar(identifier: .gregorian)
        mDatePicker.locale = Locale(identifier: "en_US_POSIX")
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
    
//    @objc
//    func doneDatePick(){
//        let mDayd = DateFormatter()
//        mDayd.dateFormat = "dd"
//
//        let mMonthm = DateFormatter()
//        mMonthm.dateFormat = "MM"
//
//        let mYeard = DateFormatter()
//        mYeard.dateFormat = "yyyy"
//
//        guard let cell1 = mCartTable.cellForRow(at: IndexPath(row: mCurrentIndex, section: 0)) as? CustomCartItems else {
//            return
//        }
//        cell1.mDueDate.text  = "\(mMonthm.string(from: mDatePicker.date))/" +  "\(mDayd.string(from: mDatePicker.date))/"+"\(mYeard.string(from: mDatePicker.date))"
//        guard let mInvData = mCartData[mCurrentIndex] as? NSDictionary,
//              let cells = mCartTable.cellForRow(at: IndexPath(row: mCurrentIndex , section: 0)) as? CustomCartItems else {
//            return
//        }
//
//        var mData = NSMutableDictionary()
//        mData.setValue("\(mInvData.value(forKey: "id") ?? "")", forKey: "id")
//        mData.setValue("\(mInvData.value(forKey: "type") ?? "")", forKey: "type")
//        mData.setValue("\(mInvData.value(forKey: "Qty") ?? "")", forKey: "Qty")
//        mData.setValue("\(mInvData.value(forKey: "SKU") ?? "")", forKey: "SKU")
//        mData.setValue("\(mInvData.value(forKey: "po_QTY") ?? "1")", forKey: "po_QTY")
//        mData.setValue("\(mInvData.value(forKey: "stock_id") ?? "")", forKey: "stock_id")
//        mData.setValue("\(mInvData.value(forKey: "price") ?? "")", forKey: "price")
//        mData.setValue("\(mInvData.value(forKey: "name") ?? "")", forKey: "name")
//        mData.setValue("\(mInvData.value(forKey: "main_image") ?? "")", forKey: "main_image")
//        mData.setValue("\(mInvData.value(forKey: "size_name") ?? "")", forKey: "size_name")
//        mData.setValue("\(mInvData.value(forKey: "metal_name") ?? "")", forKey: "metal_name")
//        mData.setValue("\(mInvData.value(forKey: "stone_name") ?? "")", forKey: "stone_name")
//        mData.setValue("\(mInvData.value(forKey: "collection_name") ?? "")", forKey: "collection_name")
//        mData.setValue("\(mInvData.value(forKey: "location_name") ?? "")", forKey: "location_name")
//        mData.setValue("\(mInvData.value(forKey: "custom_cart_id") ?? "")", forKey: "custom_cart_id")
//        mData.setValue("\(mInvData.value(forKey: "remark") ?? "")", forKey: "remark")
//        mData.setValue("\(mInvData.value(forKey: "currency") ?? "")", forKey: "currency")
//        mData.setValue("\(cells.mDueDate.text ?? "")", forKey: "delivery_date")
//        mData.setValue(mInvData.value(forKey: "Custom_design_status") ?? false, forKey: "Custom_design_status")
//
//        if let mServiceLabourStatus =  mInvData.value(forKey: "Service_labour_exsist") as? Bool {
//            if mServiceLabourStatus {
//                mData.setValue(mServiceLabourStatus, forKey: "Service_labour_exsist")
//                if let mServiceLabour = mInvData.value(forKey: "Service_labour") as? NSDictionary {
//                    mData.setValue(mServiceLabour, forKey: "Service_labour")
//                }
//            }else{
//                mData.setValue(false, forKey: "Service_labour_exsist")
//            }
//        }
//        mCartData.removeObject(at: mCurrentIndex)
//        mCartData.insert(mData, at: mCurrentIndex)
//
//        self.view.endEditing(true)
//
//    }
    
    @objc
    func doneDatePick() {

        guard mCurrentIndex >= 0,
              mCurrentIndex < mCartData.count,
              let item = mCartData[mCurrentIndex] as? NSDictionary,
              let updatedItem = item.mutableCopy() as? NSMutableDictionary else {
            return
        }

        //----------------------------------
        // Original ISO date from API
        //----------------------------------

        let originalISO = "\(updatedItem["delivery_date"] ?? "")"

        //----------------------------------
        // Parse original ISO
        //----------------------------------

        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds
        ]

        guard let originalDate = isoFormatter.date(from: originalISO) else {
            print("❌ Invalid original delivery_date =", originalISO)
            return
        }

        //----------------------------------
        // Keep original time
        //----------------------------------

        var calendar = Calendar(identifier: .gregorian)

        let originalTime = calendar.dateComponents(
            [.hour, .minute, .second, .nanosecond],
            from: originalDate
        )

        let selectedDay = calendar.dateComponents(
            [.year, .month, .day],
            from: mDatePicker.date
        )

        var merged = DateComponents()

        merged.year = selectedDay.year
        merged.month = selectedDay.month
        merged.day = selectedDay.day

        merged.hour = originalTime.hour
        merged.minute = originalTime.minute
        merged.second = originalTime.second
        merged.nanosecond = originalTime.nanosecond

        guard let finalDate = calendar.date(from: merged) else {
            return
        }

        //----------------------------------
        // Save ISO back to cart
        //----------------------------------

        let apiDate = isoFormatter.string(from: finalDate)

        updatedItem["delivery_date"] = apiDate

        mCartData.replaceObject(
            at: mCurrentIndex,
            with: updatedItem
        )
        print("========== mCartData AFTER PICK ==========")
        print(mCartData)
        print("==========================================")
        //----------------------------------
        // Refresh UI
        //----------------------------------

        print("OLD =", originalISO)
        print("NEW =", apiDate)

        mCartTable.reloadRows(
            at: [IndexPath(row: mCurrentIndex, section: 0)],
            with: .none
        )

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
            let mParams = [ "customer_id":mCustomerId , "custom_cart_id":mData.value(forKey: "custom_cart_id") as? String ?? ""] as [String : Any]
            
            mGetData(url: mDeleteCartItem,headers: sGisHeaders,  params: mParams) { response , status in
                self.hideCartLoading()
                CommonClass.stopLoader()
                if status {
                    if "\(response.value(forKey: "code") ?? "")" == "200" {
                        self.hideCartLoading()
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

//    func mDeleteCartItems(index: Int) {
//        self.mCartData.removeObject(at: index)
//        self.mCartTable.reloadData()
//        calculateItemsWithAmount()
//    }
    func mDeleteCartItems(index: Int) {

        print("🔥 DELETE INDEX =", index)
        print("🔥 CART COUNT BEFORE =", self.mCartData.count)

        guard index >= 0,
              index < self.mCartData.count else {

            print("❌ INVALID DELETE INDEX")
            return
        }

        self.mCartData.removeObject(at: index)

        print("🔥 CART COUNT AFTER =", self.mCartData.count)

        self.mCartTable.reloadData()

        calculateItemsWithAmount()
    }
    
    @IBAction func mRemoveCartItems(_ sender: UIButton) {
        
        guard let mData = mCartData[sender.tag] as? NSDictionary else {
            return
        }
        
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
            mData.setValue("\(mInvData.value(forKey: "Qty") ?? "")", forKey: "Qty")
            mData.setValue("\(mInvData.value(forKey: "SKU") ?? "")", forKey: "SKU")
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
            mCartData.removeObject(at: sender.tag)
            mCartData.insert(mData, at: sender.tag)
            calculateItemsWithAmount()
            return
        }
        
        
        let mData = NSMutableDictionary()
        self.mCartAmount.remove(at: sender.tag)
//        self.mCartAmount.insert(Double("\(cells.mProductPrice.text ?? "")") ?? 0.0, at: sender.tag)
        let price = PriceHelper.parsePrice(cells.mProductPrice.text)
        self.mCartAmount.insert(price, at: sender.tag)
        mData.setValue(price, forKey: "price")
//        mData.setValue(cells.mProductPrice.text ?? "", forKey: "price")
        mData.setValue("\(mInvData.value(forKey: "id") ?? "")", forKey: "id")
        mData.setValue("\(mInvData.value(forKey: "type") ?? "")", forKey: "type")
        mData.setValue("\(mInvData.value(forKey: "Qty") ?? "")", forKey: "Qty")
        mData.setValue("\(mInvData.value(forKey: "SKU") ?? "")", forKey: "SKU")
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
        mCartData.removeObject(at: sender.tag)
        mCartData.insert(mData, at: sender.tag)
        calculateItemsWithAmount()
        
    }
    
    @IBAction func mEditremarks(_ sender: UITextField) {
        
        guard let mInvData = mCartData[sender.tag] as? NSDictionary,
              let cells = mCartTable.cellForRow(at: IndexPath(row: sender.tag , section: 0)) as? CustomCartItems else {
            return
        }
        
        let mData = NSMutableDictionary()
        mData.setValue("\(mInvData.value(forKey: "id") ?? "")", forKey: "id")
        mData.setValue("\(mInvData.value(forKey: "type") ?? "")", forKey: "type")
        mData.setValue("\(mInvData.value(forKey: "Qty") ?? "")", forKey: "Qty")
        mData.setValue("\(mInvData.value(forKey: "SKU") ?? "")", forKey: "SKU")
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
        mData.setValue(mInvData.value(forKey: "Custom_design_status") ?? false, forKey: "Custom_design_status")
        
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
        mCartData.removeObject(at: sender.tag)
        mCartData.insert(mData, at: sender.tag)
        
    }
   
    @IBAction func mOpenDesign(_ sender: UIButton) {
        
        self.isQuotation = false
        UserDefaults.standard.setValue("\(mNotes.text ?? "")", forKey: "cRemark")
        let storyBoard: UIStoryboard = UIStoryboard(name: "customOrder", bundle: nil)
        if #available(iOS 14.0, *) {
            let mIndex = sender.tag
            guard let mData = mCartData[mIndex] as? NSDictionary,
                  let mCustomDesign = storyBoard.instantiateViewController(withIdentifier: "CustomDesign") as? CustomDesign else {
                return
            }
            
            mCustomDesign.mData = mData
            mCustomDesign.mCustomerId = self.mCustomerId
            
            if let mCustomDesignStatus = mData.value(forKey: "Custom_design_status") as? Bool {
                if mCustomDesignStatus {
                    mCustomDesign.mStatus = "1"
                }else{
                    mCustomDesign.mStatus = "1"
                }
            }
            
//            let index = sender.tag
//            guard let mInvData = mCartData[index] as? NSDictionary,
//                  let cells = mCartTable.cellForRow(at: IndexPath(row: index, section: 0)) as? CustomCartItems,
//                  let mOrgData = mCartDataMaster[index] as? NSDictionary else {
//                return
//            }
            print("\(mData.value(forKey: "collection_name") ?? "nil")")
            print("========== OPEN CUSTOM DESIGN ==========")
            print("FULL DATA =", mData)
            print("COLLECTION =", mData.value(forKey: "collection_name") ?? "nil")
            print("========================================")
            self.navigationController?.pushViewController(mCustomDesign, animated:true)
        } else {
            // Fallback on earlier versions
        }
    }
    
    
    func calculateItemsWithAmount(){
        var mAmounts = [Double]()
        var mQuantities = [Int]()
        mServiceAmounts = [Double]()
        
        print("calculateItemsWithAmount")
        print("Cart Count =", mCartData.count)

        for item in mCartData {
            if let data = item as? NSDictionary {
                print("SKU =", data["SKU"] ?? "")
                print("Qty =", data["Qty"] ?? "")
                print("Price =", data["price"] ?? "")
                print("Cart Price =", data["cart_price"] ?? "")
            }
        }
        
        
        print("===== CALCULATE =====")
        for case let item as NSDictionary in mCartData {
            print("==========")
            print("SKU =", item["SKU"] ?? "")
            print("Qty =", item["Qty"] ?? "")
            print("price =", item["price"] ?? "")
            print("cart_price =", item["cart_price"] ?? "")
        }
        print("=====================")
        
        for i in mCartData {
            if let mData = i as? NSDictionary {
                mQuantities.append(Int("\(mData.value(forKey: "Qty") ?? "0")") ?? 0 )
//                mAmounts.append(Double("\(mData.value(forKey: "price") ?? "0.0")".replacingOccurrences(of: ",", with: "")) ?? 0.00)
                if let cartPrice = mData["cart_price"] {
                    mAmounts.append(Double("\(cartPrice)") ?? 0.0)
                } else {
                    let priceString = "\(mData["price"] ?? "0")"
                        .replacingOccurrences(of: ",", with: "")
                        .replacingOccurrences(of: self.mCurrency, with: "")
                        .trimmingCharacters(in: .whitespaces)

                    mAmounts.append(Double(priceString) ?? 0.0)
                }
                
                if let mServiceLabourStatus =  mData.value(forKey: "Service_labour_exsist") as? Bool {
                    
                    if mServiceLabourStatus {
                        if let mServiceLabour = mData.value(forKey: "Service_labour") as? NSDictionary {
                            if let mServiceItem = mServiceLabour.value(forKey: "service_laburelist") as? NSArray {
                                if mServiceItem.count > 0 {
                                    var mAmounts = [Double]()
                                    for i in mServiceItem {
                                        if let items = i as? NSDictionary,
                                           let serviceAmount = items.value(forKey: "scrviceamount") {
                                            let serviceAmountUnformated = "\(serviceAmount)".replacingOccurrences(of: ",", with: "")
                                            mAmounts.append(Double(serviceAmountUnformated) ?? 0.00)
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
        mTotalItems.text = "\(mCartData.count) " + "Items".localizedString
        print("mTotalItems.text =", mTotalItems.text ?? "")
//        mGrandTotal.text = self.mCurrency + String(format:"%.02f",locale:Locale.current,(mAmounts.reduce(0, {$0 + $1}) + mServiceAmounts.reduce(0, {$0 + $1}) ))
        
        mGrandTotal.text = PriceHelper.formatPrice((mAmounts.reduce(0, {$0 + $1}) + mServiceAmounts.reduce(0, {$0 + $1}) ), currency: UserDefaults.standard.string(forKey: "currencySymbol") ?? "nil")
        print("mGrandTotal.text =", mGrandTotal.text ?? "")
        mGrandTotalCart = "\((mAmounts.reduce(0, {$0 + $1}) + mServiceAmounts.reduce(0, {$0 + $1}) ))"
        print("mGrandTotalCart.text =", mGrandTotalCart)
//        self.mGrandTotalAmounts = "\((mAmounts.reduce(0, {$0 + $1}) + mServiceAmounts.reduce(0, {$0 + $1}) ))"
//        self.mGrandTotalAmounts = PriceHelper.formatPrice((mAmounts.reduce(0, {$0 + $1}) + mServiceAmounts.reduce(0, {$0 + $1}) ), currency: self.mCurrency)
        self.mGrandTotalAmounts = PriceHelper.formatPrice((mAmounts.reduce(0, {$0 + $1}) + mServiceAmounts.reduce(0, {$0 + $1}) ), currency: UserDefaults.standard.string(forKey: "currencySymbol") ?? "nil")
//        "\((mAmounts.reduce(0, {$0 + $1}) + mServiceAmounts.reduce(0, {$0 + $1})))"
//        print("mGrandTotalAmounts.text =", mGrandTotalAmounts)
//        print("mCurrency =", self.mCurrency)
//        print("UserDefaults currency =", UserDefaults.standard.string(forKey: "currencySymbol") ?? "nil")
        self.mCurrency = UserDefaults.standard.string(forKey: "currencySymbol") ?? "nil"
        if mDepositPercents == "100" {
            mDepositAmount.text =  mGrandTotal.text
            mOutstandingAmount.text = self.mCurrency + " 0.00"
            self.mOutStandingAmounts = self.mCurrency + " 0.00"
            self.mTotalDepositAmounts = self.mGrandTotalAmounts
//            print("4 mOutstandingAmount.text =", mOutstandingAmount.text ?? "")
        }else{
            let mTotalValue = (mAmounts.reduce(0, {$0 + $1}) + mServiceAmounts.reduce(0, {$0 + $1}))
//            mDepositAmount.text = self.mCurrency + String(format:"%.02f",locale:Locale.current,calculatePercentage(value: mTotalValue, percent: Double(mDepositPercents) ?? 0.00))
            mDepositAmount.text = PriceHelper.formatPrice(
                calculatePercentage(
                    value: mTotalValue,
                    percent: Double(mDepositPercents) ?? 0
                ),
                currency: self.mCurrency
            )
            print("2 mDepositAmount.text =", mDepositAmount.text ?? "")
            self.mTotalDepositAmounts = "\(calculatePercentage(value: mTotalValue, percent: Double(mDepositPercents) ?? 0.00))"
            print("2 self.mTotalDepositAmounts.text =", self.mTotalDepositAmounts)
            let mOutstandingBal = mTotalValue - calculatePercentage(value: mTotalValue, percent: Double(mDepositPercents) ?? 0.00)
            self.mOutStandingAmounts = PriceHelper.formatPrice(mOutstandingBal, currency: UserDefaults.standard.string(forKey: "currencySymbol") ?? "nil")
            //"\(mOutstandingBal)"
            print("2 mOutStandingAmounts.text =", self.mOutStandingAmounts)
//            self.mOutstandingAmount.text = self.mCurrency + String(format:"%.02f",locale:Locale.current,mOutstandingBal)
            self.mOutstandingAmount.text = PriceHelper.formatPrice(
                mOutstandingBal,
                currency: self.mCurrency
            )
            print("2 mOutstandingAmount.text =", mOutstandingAmount.text ?? "")
            
        }
        
        
        
        
    }
    
    func calculatePercentage(value:Double,percent: Double) -> Double {
        let val = value * percent
        return val/100.00
    }
    
}
