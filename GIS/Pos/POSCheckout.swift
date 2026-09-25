//
//  POSCheckout.swift
//  GIS
//
//  Created by Macbook Pro on 07/07/23.
//  Copyright © 2023 Hawkscode. All rights reserved.
//

import UIKit
import Alamofire
import DropDown
import StripePaymentSheet
import CorePayments
import PayPalWebPayments
import UIKit
import SwiftUI
import WebKit


protocol ConfirmLaybyDelegate {
    func mConfirmLayByPayment(date : String, receiveAmount:String,outstanding:String,noOfReceived:String)
}

protocol ConfirmationDelegate {
    func mGetDatePicker()
    func mConfirmPayment(date : String,dateInGMT: Date, receiveAmount:String,outstanding:String,noOfReceived:String)
}

let mConfirmQuote = UINib(nibName:"confirmquote",bundle:.main).instantiate(withOwner: nil, options: nil).first as? ConfirmQuote ?? ConfirmQuote()

class ConfirmQuote: UIView {
    var mType = ""
    var mNewDate = Date()
    var index = Int()
    var delegate:ConfirmationDelegate? = nil
    
    @IBOutlet weak var mDueDateLABEL: UILabel!
    @IBOutlet weak var mNotes: UITextField!
    @IBOutlet weak var mCurrentDate: UILabel!
    @IBOutlet weak var mHeadingLabel: UILabel!
    @IBOutlet weak var mSubHeading: UILabel!
    @IBOutlet weak var mCreateQuote: UIButton!
    @IBOutlet weak var mCancelButton: UIButton!
    @IBOutlet weak var mDueDate: UITextField!
    
    static func instantiate(message: String) -> ConfirmQuote {
        let view: ConfirmQuote = initFromNib()
        return view
    }
    @IBAction func mChooseDate(_ sender: Any) {
        self.delegate?.mGetDatePicker()
    }
    @IBAction func mCancel(_ sender: Any) {
        self.removeFromSuperview()
    }
    @IBAction func mConfirm(_ sender: Any) {
        self.removeFromSuperview()
        self.delegate?.mConfirmPayment(date: mCurrentDate.text ?? "", dateInGMT: mNewDate, receiveAmount: "", outstanding: "", noOfReceived: mNotes.text ?? "")
    }
}

let mPaymentConfirmation = UINib(nibName:"paymentconfirmation",bundle:.main).instantiate(withOwner: nil, options: nil).first as? PaymentConfirmation ?? PaymentConfirmation()

class PaymentConfirmation: UIView {
    var mType = ""
    
    @IBOutlet weak var mGrandTotal: UILabel!
    @IBOutlet weak var mDueDateLABEL: UILabel!
    @IBOutlet weak var mOutstandingLABEL: UILabel!
    @IBOutlet weak var mGrandTotalLABEL: UILabel!
    @IBOutlet weak var mOutstanding: UILabel!
    @IBOutlet weak var mTotalReceived: UILabel!
    var index = Int()
    var delegate:ConfirmationDelegate? = nil
    
    @IBOutlet weak var mCurrentDate: UILabel!
    @IBOutlet weak var mHeadingLabel: UILabel!
    @IBOutlet weak var mReceiveLabel: UILabel!
    @IBOutlet weak var mConfirmButton: UIButton!
    @IBOutlet weak var mCancelButton: UIButton!
    @IBOutlet weak var mDueDate: UITextField!
    
    var mGrandTotalBalance = ""
    var mOutstandingBalance = ""
    var mTotalReceivedBalance = ""
    var mNavigation = UINavigationController()
    
    static func instantiate(message: String) -> PaymentConfirmation {
        let view: PaymentConfirmation = initFromNib()
        return view
    }
    @IBAction func mChooseDate(_ sender: Any) {
        self.delegate?.mGetDatePicker()
    }
    @IBAction func mCancel(_ sender: Any) {
        self.removeFromSuperview()
    }
    @IBAction func mConfirm(_ sender: Any) {
        self.removeFromSuperview()
        if mType == "Repayment" {
            self.delegate?.mConfirmPayment(date: mCurrentDate.text ?? "",dateInGMT: Date(), receiveAmount: mTotalReceivedBalance, outstanding: mOutstandingBalance, noOfReceived: mReceiveLabel.text ?? "")
            return
        }
        self.delegate?.mConfirmPayment(date: mCurrentDate.text ?? "",dateInGMT: Date(), receiveAmount: mTotalReceived.text ?? "", outstanding: mOutstanding.text ?? "", noOfReceived: mReceiveLabel.text ?? "")
    }
}

class POSCheckout: UIViewController, UITextFieldDelegate , UITableViewDelegate ,UITableViewDataSource , UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout ,GetVerification , ProceedToPay, UIViewControllerTransitioningDelegate, ConfirmationDelegate, FinalInstallmentDelegate, ScannerDelegate, QRCodeViewDelegate {
    private var selectedSalesPersonId: String {
        return (UserDefaults.standard.string(forKey: "SALESPERSONID") ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var checkoutSalesPersons: [POSSalesPersonRow] = []
    private var checkoutSalesPersonPicker: POSSalesPersonPickerView?
    private var resumePayNowAfterSalesPersonSelection = false
    private var checkoutSalesPersonButton: UIButton?
    private var checkoutHeaderActions: UIView?


    
    // MARK: - Outlets
    @IBOutlet weak var mPartialPaymentView: UIView!
    @IBOutlet weak var mReceiveView: UIStackView!
    @IBOutlet weak var mCashIcon: UIImageView!
    @IBOutlet weak var mCreditNoteIcon: UIImageView!
    @IBOutlet weak var mBankIcon: UIImageView!
    @IBOutlet weak var mCreditCardIcon: UIImageView!
    @IBOutlet weak var mCreditNoteDetailsView: UIView!
    @IBOutlet weak var mTotalCreditAmount: UILabel!
    @IBOutlet weak var mItemsSelected: UILabel!
    @IBOutlet weak var mTotalSelectedAmount: UILabel!
    @IBOutlet weak var mCreditNoteTable: UITableView!
    @IBOutlet weak var mSubmitCreditNote: UIButton!
    
    @IBOutlet weak var mEditCashView: UIView!
    @IBOutlet weak var mCashCurrencyImage: UIImageView!
    @IBOutlet weak var mCurrencyName: UILabel!
    @IBOutlet weak var mChooseCurrencyButt: UIButton!
    @IBOutlet weak var mCashAmount: UITextField!
    @IBOutlet weak var mExchangeRateLabel: UILabel!
    @IBOutlet weak var mExchangeRateValue: UITextField!
    @IBOutlet weak var mConvertedAmount: UILabel!
    
    @IBOutlet weak var mSubmitTx: UIButton!
    @IBOutlet weak var mTaxCalView: UIView!
    @IBOutlet weak var mTotalTx: UILabel!
    @IBOutlet weak var mTotalDiscountTx: UILabel!
    @IBOutlet weak var mSubTotalTx: UILabel!
    @IBOutlet weak var mTaxVal: UITextField!
    @IBOutlet weak var mFinalTaxAmount: UITextField!
    @IBOutlet weak var mTaxAmountTx: UILabel!
    @IBOutlet weak var mTaxValueTx: UILabel!
    @IBOutlet weak var mExchangeTx: UILabel!
    @IBOutlet weak var mLabourCharge: UITextField!
    @IBOutlet weak var mShippingCharge: UITextField!
    @IBOutlet weak var mDiscountPercents: UITextField!
    @IBOutlet weak var mDiscountAmounts: UITextField!
    
    @IBOutlet weak var mPayNowButton: UIButton!
    @IBOutlet weak var mCreditCardView: UIView!
    @IBOutlet weak var mTaxInfoView: UIView!
    @IBOutlet weak var mKeyBoardView: UIView!
    @IBOutlet weak var mCardView: UIView!
    @IBOutlet weak var mCashView: UIView!
    @IBOutlet weak var mBankView: UIView!
    @IBOutlet weak var mCreditNoteView: UIView!
    @IBOutlet weak var mTaxView: UIView!
    
    @IBOutlet weak var mVisaView: UIView!
    @IBOutlet weak var mApplePayView: UIView!
    @IBOutlet weak var mAliPayView: UIView!
    @IBOutlet weak var mWeChatPayView: UIView!
    @IBOutlet weak var mCreditCardLabel: UILabel!
    @IBOutlet weak var mApplePayLabel: UILabel!
    @IBOutlet weak var mAliPayLabel: UILabel!
    @IBOutlet weak var mWeChatPayLabel: UILabel!
    @IBOutlet weak var mPayNowView: UIView!
    
    @IBOutlet weak var mCustomerSearch: UITextField!
    @IBOutlet weak var mDropDownImage: UIImageView!
    
    @IBOutlet weak var mCustomerSearchView: UIView!
    @IBOutlet weak var mCustomerDetailView: UIView!
    @IBOutlet weak var mCustomerNames: UILabel!
    @IBOutlet weak var mCustomerAddresss: UILabel!
    @IBOutlet weak var mCustomerNumbers: UILabel!
    
    @IBOutlet weak var mBALANCEDUE: UILabel!
    @IBOutlet weak var mTOTALAMOUNT: UILabel!
    @IBOutlet weak var mSubmittedCash: UILabel!
    @IBOutlet weak var mSubmittedCreditCard: UILabel!
    @IBOutlet weak var mSubmittedCreditNote: UILabel!
    @IBOutlet weak var mCreditNotesView: UIView!
    
    @IBOutlet weak var mHCheckoutLABEL: UILabel!
    @IBOutlet weak var mCreditCardLABEL: UILabel!
    @IBOutlet weak var mCashLABEL: UILabel!
    @IBOutlet weak var mBankLABEL: UILabel!
    @IBOutlet weak var mCreditNoteLABEL: UILabel!
    @IBOutlet weak var mTaxLABEL: UILabel!
    @IBOutlet weak var mCNTypeLABEL: UILabel!
    @IBOutlet weak var mCNDate: UILabel!
    @IBOutlet weak var mCNRefNoLABEL: UILabel!
    @IBOutlet weak var mCNAmountLABEL: UILabel!
    @IBOutlet weak var mCNTotalLABEL: UILabel!
    @IBOutlet weak var mSUBLABEL: UILabel!
    @IBOutlet weak var mTLabourLABEL: UILabel!
    @IBOutlet weak var mTShippingLABEL: UILabel!
    @IBOutlet weak var mLoyaltyPointLABEL: UILabel!
    @IBOutlet weak var mTDiscountPLABEL: UILabel!
    @IBOutlet weak var mTDiscountALABEL: UILabel!
    @IBOutlet weak var mTaxPLABEL: UILabel!
    @IBOutlet weak var mTaxALABEL: UILabel!
    @IBOutlet weak var mBCreditCardLABEL: UILabel!
    @IBOutlet weak var mBCashLABEL: UILabel!
    @IBOutlet weak var mBBankLABEL: UILabel!
    @IBOutlet weak var mBCreditNoteLABEL: UILabel!
    @IBOutlet weak var mTxTotalLABEL: UILabel!
    @IBOutlet weak var mTxSubTotalLABEL: UILabel!
    @IBOutlet weak var mTxExchangeLABEL: UILabel!
    @IBOutlet weak var mBTotalLABEL: UILabel!
    @IBOutlet weak var mBBalanceDueLABEL: UILabel!
    @IBOutlet weak var mTxDiscountLABEL: UILabel!
    
    @IBOutlet weak var mChequeDetailsView: UIView!
    @IBOutlet weak var mChequeAmount: UITextField!
    @IBOutlet weak var mCheqDate: UITextField!
    @IBOutlet weak var mCheqAccountNumber: UITextField!
    @IBOutlet weak var mCheqAccountName: UITextField!
    @IBOutlet weak var mCheqBankImage: UIImageView!
    @IBOutlet weak var mCheqBankName: UITextField!
    @IBOutlet weak var mCheqRefNumber: UITextField!
    @IBOutlet weak var mCheqInstNumber: UITextField!
    @IBOutlet weak var mSubmittedBankAmount: UILabel!
    
    @IBOutlet weak var mCheqDateLABEL: UILabel!
    @IBOutlet weak var mCheqAccountNoLABEL: UILabel!
    @IBOutlet weak var mCheqAccountNameLABEL: UILabel!
    @IBOutlet weak var mCheqBankLABEL: UILabel!
    @IBOutlet weak var mCheqRefLABEL: UILabel!
    @IBOutlet weak var mCheqInstLABEL: UILabel!
    @IBOutlet weak var mCheqSubmitBUTTON: UIButton!
    
    @IBOutlet weak var mSubmitButtonCredit: UIButton!
    @IBOutlet weak var mCloseButtonCredit: UIButton!
    @IBOutlet weak var mCreditCardPaymentView: UIView!
    @IBOutlet weak var mCreditFillAmount: UITextField!
    @IBOutlet weak var mCreditCardBanksView: UIView!
    @IBOutlet weak var mStripeCardView: UIView!
    @IBOutlet weak var mCollectionView: UICollectionView!
    @IBOutlet weak var mGiftCardAmount: UITextField!
    @IBOutlet weak var mApplyGiftBUTTON: UIButton!
    @IBOutlet weak var mClearBUTTON: UIButton!
    @IBOutlet weak var mReceiveAmountLABEL: UILabel!
    
    @IBOutlet weak var mCardNumber: UITextField!
    @IBOutlet weak var mCardName: UITextField!
    @IBOutlet weak var mCreditBankName: UITextField!
    @IBOutlet weak var mCreditBankImage: UIImageView!
    @IBOutlet weak var mTotalItemsInCart: UILabel!
    
    // Tab Outlets
    @IBOutlet weak var mSelectPaymentOptionContainer: UIView!
    @IBOutlet weak var mTabBarContainer: UIView!
    @IBOutlet weak var mCardNumberContainer: UIView!
    @IBOutlet weak var mCardNameContainer: UIStackView!
    @IBOutlet weak var mIBSelect: UIButton!
    @IBOutlet weak var mChequeSelect: UIButton!
    @IBOutlet weak var mIBTabSelect: UILabel!
    @IBOutlet weak var mChequeTabSelect: UILabel!
    @IBOutlet weak var mEnterAmountText: UITextField!
    @IBOutlet weak var mSelectIBBank: UITextField!
    @IBOutlet weak var mSelectIBBankImage: UIImageView!
    @IBOutlet weak var mEnterQRAmount: UITextField!
    @IBOutlet weak var mSelectedBankName: UITextField!
    @IBOutlet weak var mSelectedBankImage: UIImageView!
    @IBOutlet weak var mPaymentOptionIcon: UIImageView!
    @IBOutlet weak var mPaymentOptionView: UIView!
    @IBOutlet weak var mGCurrency: UILabel!
    @IBOutlet weak var mRCurrency: UILabel!
    @IBOutlet weak var mBCurrency: UILabel!
    
    @IBOutlet weak var mFullPaymentLabel: UILabel!

    @IBOutlet weak var mLaybyLabel: UILabel!
    @IBOutlet weak var mInstallmentLabel: UILabel!

    @IBOutlet weak var mFullPaymentOptionView: UIView!
    @IBOutlet weak var mLaybyOptionView: UIView!
    @IBOutlet weak var mInstallmentOptionView: UIView!

    @IBOutlet weak var mInstallmentDetailsButton: UIButton!
    
    @IBOutlet weak var mRECEIVEAMOUNT: UILabel!
    
    @IBOutlet weak var mPaypalSandboxView: UIView!
    @IBOutlet weak var mPaypalSandboxImage: UIImageView!
    @IBOutlet weak var mPaypalSandboxLabel: UILabel!
    
    
    // MARK: - Variables
    var mCreditNoteData = NSMutableArray()
    var mSelectedIndex = [IndexPath]()
    var mCurrencyImageData = [String]()
    var mCurrencyNameData = [String]()
    var mExchangeRateData = [String]()
    var mCashAmounts = ""
    var mSelectedStoreCurrency = ""
    var mStoreCurrency = ""
    var mConvertedAmounts = "0"

    // Cash split-payment state.
    // amount = amount deducted from the order total in STORE currency.
    // enteredAmount = amount typed by the customer in the selected currency.
    private struct CashPaymentPage {
        var amount: Double
        var enteredAmount: Double
        var currency: String
        var exchangeRate: Double
        var isSubmitted: Bool
    }
    private var mCashPages: [CashPaymentPage] = [
        CashPaymentPage(
            amount: 0,
            enteredAmount: 0,
            currency: "",
            exchangeRate: 1,
            isSubmitted: false
        )
    ]
    private var mCurrentCashPage = 0
    private let mPageControl = UIPageControl()
    var isQRCodeDeleted = false
    var mTotalP = ""
    var mTotalAm = ""
    var mSubTotalP = ""
    var mTaxP = ""
    var mTaxAm = ""
    var mRemark = ""
    var mNote = ""
    var mTaxType = ""
    var mTaxLabel = ""
    var mTaxPercent = ""
    var mTotalWithDiscount = ""
    var mCustomerId = ""
    var mCartTableData = NSMutableArray()
    let mCustomerSearchTableView = UITableView()
    var mSearchCustomerData = NSArray()
    var mTransactionType = "Cash"
    var isExchange = false
    var mOrderType = ""
    // Linked-cart metadata supplied by getInventoryList through PosCart.
    var linkedCartId = ""
    var linkedOrderId = ""
    var existingCartStatus = ""
    var canCreateNewCart = true
    var linkedOrderType = ""
    private var isRestoringLinkedCartStatus = false
    private let connectedOrderRestoreCartIDsKey = "reserve_restore_cart_ids"
    var mPartialPayment = ""
    var mQuantity = [Int]()
    var mCreditData = NSMutableArray()
    var mCreditDataMerged = NSMutableArray()
    var mSelectedCustomIndex = [IndexPath]()
    var mAmountData = NSMutableArray()
    var mCreditCardMethod = NSMutableArray()
    var mGiftCardMethod = NSMutableArray()
    var mGiftFinalTotalAmount = ""
    var mChequePaymentId = ""
    var mChequePaymentIdNew = ""
    var paymentSlag = ""
    var mCreditCardPaymentId = ""
    var mCreditCardLogo = ""
    var mCreditCardName = ""
    let mDatePicker:UIDatePicker = UIDatePicker()
    var mChequeData = NSMutableDictionary()
    var mFinalPaymentMethod = [String:Any]()
    var mFTOTAL = ""
    var mStripeIndex = 0
    var mPaymentData = NSArray()
    var mBankData = NSArray()
    var mCreditCardPayment = NSMutableArray()
    var mBankPayment = NSMutableArray()
    var mCashPayment = NSMutableDictionary()
    var mCartTotalAmount = ""
    var mDepositPercents = "100"
    var mTotalOutstandingAm = "0.00"
    var mCurrencySymbol = "$"
    var mLabourPoints = 0.0
    var mShippingPoints = 0.0
    var mLoyaltyPoints = 0.0
    var mTaxAmount = 0.0
    var mTaxAmountInt = 0.0
    var mTaxInPercent = 0.0
    var mTaxDiscountAmount = 0.0
    var mTaxDiscountPercent = 0.0
    var mTaxTypeIE = ""
    var mOrderId = ""
    var mClientReferenceID = ""
    var mClientSecreat = ""
    var mPaymentIntentID = ""
    var mPaymentID = ""
    var mStripPublishKey = ""
    var mPaypalClientID = ""
    var mPaypalEnvironment = "sandbox"
    
    var mPaypalSandboxData = NSDictionary()
    var mPaypalLiveData = NSDictionary()

    var mPaypalPayerID = ""
    var mPaypalOrderID = ""
    var mPaypalEncryptedPayload = ""
    
    var mSelectedPaypalMethodData: NSDictionary?

    private var payPalClient: PayPalWebCheckoutClient?
    private var payPalConfig: CoreConfig?
    var mPaymentMethod = ""
    var mSelectdPaymentMethod = ""
    private var cregisTransactionID = ""
    private var cregisOrderID = ""
    private var isCregisPaymentPolling = false
    private var cregisPollingWorkItem: DispatchWorkItem?
    private var cregisGenerateResponseData: [String: Any] = [:]
    private var cregisOrderResponseData: [String: Any] = [:]
    private var cregisPaidResponseData: [String: Any] = [:]
    let qrCodeView = QRCodeView.loadFromNib()
    
    var mIsCrossLocationReserve = false
    var mCrossLocationId = ""
    
    
    private var paypalHostingController:
    UIHostingController<PayPalCheckoutView>?
    
    // Address Variables
    private var mSelectedBillingAddress: [String : Any] = [:]
    private var mSelectedShippingAddress: [String : Any] = [:]
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateCheckoutSalesPersonImage()
        self.mCreditCardPaymentView.isHidden = true
        mVisaView.backgroundColor = .white
        mApplePayView.backgroundColor = .clear
        mAliPayView.backgroundColor = .white
        mWeChatPayView.backgroundColor = .white
        
        mVisaView.borderColor = .white
        mApplePayView.borderColor = .white
        mAliPayView.borderColor = .white
        mWeChatPayView.borderColor = .white
        
        mCreditCardLabel.textColor = .black
        mApplePayLabel.textColor = .black
        mAliPayLabel.textColor = .black
        mWeChatPayLabel.textColor = .black
        
        self.mCheqBankName.text = "Choose Bank"
        self.mCheqBankImage.downlaodImageFromUrl(urlString: "https://art.gis247.net/assets/images/icon/camera_profile.png")
        
        mApplyGiftBUTTON.setTitle("APPLY".localizedString, for: .normal)
        mGiftCardAmount.placeholder = "Gift Card number".localizedString
        mHCheckoutLABEL.text = "CHECK OUT".localizedString
        mCreditCardLABEL.text = "Credit Card".localizedString
        mCashLABEL.text = "Cash".localizedString
        mBankLABEL.text = "Bank".localizedString
        mCreditNoteLABEL.text = "Credit note".localizedString
        mCNTotalLABEL.text = "Total".localizedString
        mSUBLABEL.text = "SUB".localizedString
        mBCreditCardLABEL.text = "Credit Card".localizedString
        mBCashLABEL.text = "Cash".localizedString
        mBBankLABEL.text = "Bank".localizedString
        mBCreditNoteLABEL.text = "Credit Note".localizedString
        mBTotalLABEL.text = "Grand Total".localizedString
        mBBalanceDueLABEL.text = "Balance Due".localizedString
        mCreditCardLabel.text = "Credit Card".localizedString
        mExchangeRateLabel.text = "Exchange Rate".localizedString
        mItemsSelected.text = "0 " + "Item Selected".localizedString
        mPayNowButton.setTitle("PAY NOW".localizedString, for: .normal)
        mClearBUTTON.setTitle("Clear".localizedString, for: .normal)
        mCheqSubmitBUTTON.setTitle("SUBMIT".localizedString, for: .normal)
        mSubmitButtonCredit.setTitle("SUBMIT".localizedString, for: .normal)
        mCardNumber.placeholder = "Card number".localizedString
        mCardName.placeholder = "Card name".localizedString
        mCheqAccountNoLABEL.text = "Account No.".localizedString
        mCheqAccountNameLABEL.text = "Account Name".localizedString
        mCheqRefLABEL.text = "Ref No.".localizedString
        mCheqInstLABEL.text = "Inst No.".localizedString
        
        let isPartial = UserDefaults.standard.bool(forKey: "isPartial")
        self.mPartialPaymentView.isHidden = !isPartial
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        print("VIEW_APPEAR_CARD =",
              mCardNumberContainer.isHidden)

        print("VIEW_APPEAR_NAME =",
              mCardNameContainer.isHidden)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        installCheckoutSalesPersonButton()
        setupCashPageControl()
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )

        tap.cancelsTouchesInView = false

        view.addGestureRecognizer(tap)
        
        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
        
        mGCurrency.text = UserDefaults.standard.string(forKey: "currencySymbol") ?? "$"
        mBCurrency.text = UserDefaults.standard.string(forKey: "currencySymbol") ?? "$"
        
        if let mStoreCurr = UserDefaults.standard.string(forKey: "storeCurrency") as? String {
            mStoreCurrency = mStoreCurr
        }
        mCreditNoteTable.separatorStyle = .none
        
        if mCartTableData.count > 1 {
            mTotalItemsInCart.text = "\(mCartTableData.count) Items"
        }else{
            mTotalItemsInCart.text = "\(mCartTableData.count) Item"
        }
        
        if mOrderType == "Sales Order" {
            mTotalAm = mTotalP.replacingOccurrences(of: ",", with: "")
            mTotalTx.text = mTotalP
            mSubTotalTx.text = mSubTotalP
            mTaxAmountTx.text = mTaxAm
            mTaxValueTx.text = "Tax(\(mTaxP)%)"
            mTaxVal.text = mTaxP
            mFinalTaxAmount.text = mTaxAm
            self.mLabourCharge.text = "0"
            self.mShippingCharge.text = "0"
            self.mDiscountAmounts.text = "0"
            self.mDiscountPercents.text = "0"
        }else{
            mCreditNoteView.isHidden = false
            mCreditNotesView.isHidden = false
        }
        
        if let mData = UserDefaults.standard.object(forKey: "CREDITCARDDATA") as? NSArray {
            if mData.count > 0 {
                self.mPaymentData = mData
                self.mCollectionView.delegate = self
                self.mCollectionView.dataSource = self
                self.mCollectionView.reloadData()
            }
        }
        
        
        mFetchCreditNoteData(value: "")
        mCardNumber.keyboardType = .numberPad
        self.mCashLABEL.textColor = UIColor(named:"themeColor")
        self.mCreditCardLABEL.textColor = UIColor(named:"theme6A")
        self.mBankLABEL.textColor = UIColor(named:"theme6A")
        self.mCreditNoteLABEL.textColor = UIColor(named:"theme6A")
        self.mCashIcon.image = UIImage(named: "cashGreen")
        self.mCreditNoteIcon.image = UIImage(named: "creditnotegrey_ic")
        self.mCreditCardIcon.image = UIImage(named: "card_grey_ic")
        self.mBankIcon.image = UIImage(named: "bankgrey_ic")
        mTransactionType = "Cash"
        refreshCashPage()
        mChequeDetailsView.isHidden = true
        mTaxInfoView.isHidden = true
        mKeyBoardView.isHidden = false
        mCreditCardView.isHidden = true
        mEditCashView.isHidden = false
        mCreditNoteDetailsView.isHidden = true
        mCashView.backgroundColor = .clear
        mCardView.backgroundColor = UIColor(named: "themeShades")
        mBankView.backgroundColor = UIColor(named: "themeShades")
        mCreditNoteView.backgroundColor = UIColor(named: "themeShades")
        
        mShowDatePicker()
        mGetCurrency()
        mPartialPayment = UserDefaults.standard.string( forKey: "isPartialPayment") ?? "0"
        mFetchStore(key: "")
        getCustomerAddressList()
        mTabBarContainer.isHidden = true
        if let selectBtn = mIBSelect { selectBtn.isSelected = true }
        mSelectPaymentOptionContainer.isHidden = true
    }

    private func setupCashPageControl() {
        mPageControl.translatesAutoresizingMaskIntoConstraints = false
        mPageControl.numberOfPages = 1
        mPageControl.currentPage = 0
        mPageControl.hidesForSinglePage = false
        mPageControl.pageIndicatorTintColor = UIColor(red: 0.78, green: 0.78, blue: 0.78, alpha: 1)
        mPageControl.currentPageIndicatorTintColor = UIColor(red: 0.165, green: 0.165, blue: 0.165, alpha: 1) // #2A2A2A
        mPageControl.addTarget(self, action: #selector(cashPageChanged(_:)), for: .valueChanged)

        view.addSubview(mPageControl)
        view.bringSubviewToFront(mPageControl)
        NSLayoutConstraint.activate([
            mPageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mPageControl.bottomAnchor.constraint(equalTo: mKeyBoardView.topAnchor, constant: -16)
        ])

        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleCashPageSwipe(_:)))
        swipeLeft.direction = .left
        swipeLeft.cancelsTouchesInView = false

        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleCashPageSwipe(_:)))
        swipeRight.direction = .right
        swipeRight.cancelsTouchesInView = false

        mEditCashView.addGestureRecognizer(swipeLeft)
        mEditCashView.addGestureRecognizer(swipeRight)
        refreshCashPage()
    }

    private func saveCurrentCashPage() {
        guard mCashPages.indices.contains(mCurrentCashPage) else { return }
        syncCurrentCashPageFromInput()
    }

    // Convert entered amount to STORE currency using the backend rate directly.
    private func syncCurrentCashPageFromInput() {
        guard mCashPages.indices.contains(mCurrentCashPage) else { return }

        let enteredAmount = Double(mCashAmounts) ?? 0
        let selectedCurrency = mCurrencyName.text ?? mStoreCurrency

        let rate: Double
        if selectedCurrency == mStoreCurrency || mExchangeRateLabel.isHidden {
            rate = 1
        } else {
            rate = Double(mExchangeRateValue.text ?? "") ?? 0
        }

        let convertedAmount = enteredAmount > 0 && rate > 0
            ? enteredAmount * rate
            : 0

        mCashPages[mCurrentCashPage].enteredAmount = enteredAmount
        mCashPages[mCurrentCashPage].amount = convertedAmount
        mCashPages[mCurrentCashPage].currency = selectedCurrency
        mCashPages[mCurrentCashPage].exchangeRate = rate

        mConvertedAmounts = "\(convertedAmount)"

        if enteredAmount > 0 && rate > 0 {
            let rounded = (convertedAmount * 100).rounded() / 100
            mConvertedAmount.text = "= \(mStoreCurrency) \(rounded)"
        } else if enteredAmount == 0 {
            mConvertedAmount.text = ""
        }
    }

    private func totalSubmittedCash() -> Double {
        mCashPages
            .filter { $0.isSubmitted }
            .reduce(0) { $0 + $1.amount }
    }

    private func refreshCashPage() {
        guard mCashPages.indices.contains(mCurrentCashPage) else { return }

        let page = mCashPages[mCurrentCashPage]

        if page.enteredAmount == 0 {
            mCashAmount.text = ""
            mCashAmounts = ""
            mConvertedAmounts = "0"
            mConvertedAmount.text = ""
        } else {
            let value: String
            if page.enteredAmount.rounded() == page.enteredAmount {
                value = String(Int(page.enteredAmount))
            } else {
                value = String(page.enteredAmount)
            }

            mCashAmount.text = value
            mCashAmounts = value
            mConvertedAmounts = "\(page.amount)"

            if page.amount > 0 {
                let rounded = (page.amount * 100).rounded() / 100
                mConvertedAmount.text = "= \(mStoreCurrency) \(rounded)"
            } else {
                mConvertedAmount.text = ""
            }
        }

        if !page.currency.isEmpty {
            mCurrencyName.text = page.currency
        }

        if page.currency == mStoreCurrency || page.currency.isEmpty {
            mExchangeRateLabel.isHidden = true
            mExchangeRateValue.isHidden = true
            mExchangeRateValue.text = ""
        } else {
            mExchangeRateLabel.isHidden = false
            mExchangeRateValue.isHidden = false
            mExchangeRateValue.text = String(format: "%.8f", page.exchangeRate)
        }

        mPageControl.numberOfPages = mCashPages.count
        mPageControl.currentPage = mCurrentCashPage
        mPageControl.isHidden = mTransactionType != "Cash"
    }

    @objc private func cashPageChanged(_ sender: UIPageControl) {
        guard mCashPages.indices.contains(sender.currentPage) else { return }
        saveCurrentCashPage()
        mCurrentCashPage = sender.currentPage
        refreshCashPage()
    }

    @objc private func handleCashPageSwipe(_ gesture: UISwipeGestureRecognizer) {
        guard mTransactionType == "Cash" else { return }
        saveCurrentCashPage()

        switch gesture.direction {
        case .left:
            guard mCurrentCashPage < mCashPages.count - 1 else {
                bounceCashPage(direction: -14)
                return
            }
            mCurrentCashPage += 1
        case .right:
            guard mCurrentCashPage > 0 else {
                bounceCashPage(direction: 14)
                return
            }
            mCurrentCashPage -= 1
        default:
            return
        }

        UISelectionFeedbackGenerator().selectionChanged()
        UIView.transition(
            with: mEditCashView,
            duration: 0.22,
            options: [.curveEaseInOut],
            animations: {
                self.refreshCashPage()
            }
        )
    }

    private func bounceCashPage(direction: CGFloat) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        UIView.animate(withDuration: 0.08, animations: {
            self.mEditCashView.transform = CGAffineTransform(translationX: direction, y: 0)
        }) { _ in
            UIView.animate(withDuration: 0.16) {
                self.mEditCashView.transform = .identity
            }
        }
    }

    func mGetPaypalDataBackEnd() {

        guard let amountText = self.mCreditFillAmount.text,
              !amountText.isEmpty,
              let amount = Double(amountText),
              amount > 0 else {

            CommonClass.showSnackBar(message: "Please fill valid amount")
            return
        }

        let params: [String: Any] = [

            "amount": amountText,
            "slug": self.mSelectdPaymentMethod,
            "PaymentMethod": self.mPaymentMethod,
            "customerId": self.mCustomerId

        ]

        print("========== PAYPAL REQUEST ==========")
        print("URL =", mGeneratePaypalQRCode)
        print("PARAMS =", params)
        print("CLIENT ID =", mPaypalClientID)
        print("ENV =", mPaypalEnvironment)

        CommonClass.showFullLoader(view: self.view)

        AF.request(
            mGeneratePaypalQRCode,
            method: .post,
            parameters: params,
            encoding: JSONEncoding.default,
            headers: sGisHeaders2
        )
        .responseJSON { response in

            CommonClass.stopLoader()

            switch response.result {

            case .success:

                guard let jsonData = response.data,
                      let json = try? JSONSerialization.jsonObject(
                        with: jsonData
                      ) as? [String: Any] else {

                    CommonClass.showSnackBar(
                        message: "Invalid response"
                    )

                    return
                }

                print("========== PAYPAL RESPONSE ==========")
                print(json)

                guard let code = json["code"] as? Int else {

                    CommonClass.showSnackBar(
                        message: "Unknown error"
                    )

                    return
                }

                if code != 200 {

                    CommonClass.showSnackBar(
                        message: json["message"] as? String ?? "Payment failed"
                    )

                    return

                }

                guard
                    let data = json["data"] as? [String: Any]
                else {

                    CommonClass.showSnackBar(
                        message: "Invalid response"
                    )

                    return

                }

                self.mPaypalOrderID =
                    data["order_id"] as? String ?? ""

                self.mPaypalEncryptedPayload =
                    data["encryptedPayload"] as? String ?? ""

                print("PAYPAL ORDER ID =", self.mPaypalOrderID)
                print("PAYPAL PAYLOAD =", self.mPaypalEncryptedPayload)

                // PATCH 3
                 self.PayPalPayment()

            case .failure(let error):

                print(error)

                CommonClass.showSnackBar(
                    message: error.localizedDescription
                )

            }

        }

    }
    
    func PayPalPayment() {

        guard !mPaypalClientID.isEmpty else {

            CommonClass.showSnackBar(message: "PayPal Client ID not found")

            return

        }

        guard !mPaypalOrderID.isEmpty else {

            CommonClass.showSnackBar(message: "PayPal Order ID not found")

            return

        }

        let environment: CorePayments.Environment =
            mPaypalEnvironment.lowercased() == "live"
            ? .live
            : .sandbox
        
//        let environment: CorePayments.Environment = .sandbox

        print(environment)
        
        switch environment {
        case .live:
            print("SDK USING LIVE")
        case .sandbox:
            print("SDK USING SANDBOX")
        }
        
        let config = CoreConfig(

            clientID: mPaypalClientID,

            environment: environment

        )
        
        print("PAYPAL ENV =", mPaypalEnvironment)
        print("ORDER =", mPaypalOrderID)

        self.payPalConfig = config

        self.payPalClient = PayPalWebCheckoutClient(
            config: config
        )

        let request = PayPalWebCheckoutRequest(
            orderID: mPaypalOrderID
        )

        print("========== PAYPAL SDK ==========")
        print("CLIENT =", mPaypalClientID)
        print("ENV =", mPaypalEnvironment)
        print("ORDER =", mPaypalOrderID)

        payPalClient?.start(
            request: request
        ) { result in

            DispatchQueue.main.async {

                switch result {

//                case .success(let checkout):
//
//                    print("PAYPAL SUCCESS")
//
//                    print("ORDER =", checkout.orderID)
//
//                    print("PAYER =", checkout.payerID)
//
//                    self.mPaypalOrderID = checkout.orderID
//                    self.mPaypalPayerID = checkout.payerID
//                    // PATCH 3B
////                    self.paypalSuccess(
////                        orderID: checkout.orderID
////                    )
////                    self.paypalSuccess(
////                        orderID: checkout.orderID,
////                        payerID: checkout.payerID
////                    )
//                    self.paypalSuccess()
//
//
//
//                    let mCreditCardData = NSMutableDictionary()
//
//                    mCreditCardData.setValue(
//                        "PayPal",
//                        forKey: "name"
//                    )
//
//                    mCreditCardData.setValue(
//                        "",
//                        forKey: "card_number"
//                    )
//
//                    mCreditCardData.setValue(
//                        "PayPal",
//                        forKey: "card_name"
//                    )
//
//                    mCreditCardData.setValue(
//                        self.mPaymentMethod,
//                        forKey: "payment_method_id"
//                    )
//
//                    mCreditCardData.setValue(
//                        "",
//                        forKey: "logo"
//                    )
//
//                    mCreditCardData.setValue(
//                        self.mCreditFillAmount.text ?? "",
//                        forKey: "amount"
//                    )
//
//                    mCreditCardData.setValue(
//                        "Credit_Card",
//                        forKey: "Paymentmethod_type"
//                    )
//
//                    mCreditCardData.setValue(
//                        checkout.orderID,
//                        forKey: "client_reference_id"
//                    )
//
//                    self.mCreditCardMethod.add(
//                        mCreditCardData
//                    )
//
//                    DispatchQueue.main.async {
//
//                        self.recheckBalanceDue()
//
//                        self.mStripeCardView.isHidden = true
//
//                        self.mCreditCardBanksView.isHidden = false
//
//                        self.mCreditFillAmount.text = ""
//
//                        CommonClass.showSnackBar(
//                            message: "PayPal payment successful"
//                        )
//
//                    }
                    
                case .success(let checkout):

                    print("PAYPAL SUCCESS")
                    print("ORDER =", checkout.orderID)
                    print("PAYER =", checkout.payerID)

                    self.mPaypalOrderID = checkout.orderID
                    self.mPaypalPayerID = checkout.payerID

                    let mCreditCardData = NSMutableDictionary()

                    mCreditCardData.setValue(
                        "PayPal",
                        forKey: "name"
                    )

                    mCreditCardData.setValue(
                        "",
                        forKey: "card_number"
                    )

                    mCreditCardData.setValue(
                        "PayPal",
                        forKey: "card_name"
                    )

                    mCreditCardData.setValue(
                        self.mPaymentMethod,
                        forKey: "payment_method_id"
                    )

                    mCreditCardData.setValue(
                        "",
                        forKey: "logo"
                    )

                    mCreditCardData.setValue(
                        self.mCreditFillAmount.text ?? "",
                        forKey: "amount"
                    )

                    mCreditCardData.setValue(
                        "Credit_Card",
                        forKey: "Paymentmethod_type"
                    )

                    mCreditCardData.setValue(
                        checkout.orderID,
                        forKey: "client_reference_id"
                    )

                    
                    print("ORDER =", self.mPaypalOrderID)
                    print("PAYER =", self.mPaypalPayerID)
                    print("PAYLOAD =", self.mPaypalEncryptedPayload)
                    self.paypalSuccess { success in

                        print("CALLBACK =", success)

                        DispatchQueue.main.async {

                            print("INSIDE MAIN")

                            guard success else {

                                print("CAPTURE FAILED")

                                return
                            }

                            print("ADDING PAYMENT")
                            print("Credit BEFORE =", self.mCreditCardMethod)

                            self.mCreditCardMethod.add(mCreditCardData)

                            print("Credit AFTER =", self.mCreditCardMethod)
                            
                            var mAmounts = [Double]()
                            for i in self.mCreditCardMethod {
                                if let mData = i as? NSDictionary {
                                    mAmounts.append(
                                        Double("\(mData.value(forKey: "amount") ?? "0.0")"
                                            .replacingOccurrences(of: ",", with: "")) ?? 0.00
                                    )
                                }
                            }

                            self.mSubmittedCreditCard.text = "\(mAmounts.reduce(0, {$0 + $1}))"

                            print("RECHECK")
                            self.recheckBalanceDue()

                            
                        }
                    }
                    
                case .failure(let error):

                    print("PAYPAL ERROR")
                    print("========== PAYPAL FAILED ==========")
                    print(error.localizedDescription)
                    print(error)

                    CommonClass.showSnackBar(

                        message: error.localizedDescription

                    )

                }

            }

        }

    }
    
    func paypalSuccess(completion: @escaping (Bool) -> Void) {

        guard !mPaypalEncryptedPayload.isEmpty else {
            completion(false)
            return
        }

//        let urlString = "https://api2.gis247.net/api/v1/webhook/paypal-success-mobile?data=\(mPaypalEncryptedPayload)"
        let urlString = BaseUrl+"webhook/paypal-success-mobile?data=\(mPaypalEncryptedPayload)&token=\(mPaypalOrderID)"

        guard let url = URL(string: urlString) else {
            completion(false)
            return
        }

        print("========== PAYPAL SUCCESS API ==========")
        print("SUCCESS URL =", url.absoluteString)

        URLSession.shared.dataTask(with: url) { data, response, error in

            if let error = error {
                print(error)
                completion(false)
                return
            }

            if let http = response as? HTTPURLResponse {
                print("PAYPAL SUCCESS STATUS =", http.statusCode)
            }

            if let data = data,
               let text = String(data: data, encoding: .utf8) {
                print("PAYPAL SUCCESS RESPONSE =")
                print(text)
            }

            if let http = response as? HTTPURLResponse {
                completion(http.statusCode == 200)
            } else {
                completion(false)
            }

        }.resume()
    }
    
    
    
//    func paypalSuccess(completion: @escaping (Bool)->Void) {
//
//        var components = URLComponents(
//            string: "https://api2.gis247.net/api/v1/webhook/paypal-success-mobile"
//        )!
//
//        components.queryItems = [
//
//            URLQueryItem(
//                name: "data",
//                value: self.mPaypalEncryptedPayload//mPaypalOrderID//mPaypalPayload
//            )
//
//        ]
//
//        guard let url = components.url else {
//            return
//        }
//
//        URLSession.shared.dataTask(with: url) { data, response, error in
//
//            if let error = error {
//
//                print(error)
//
//                return
//
//            }
//
//            print("PAYPAL CAPTURE SUCCESS")
//
//        }.resume()
//
//    }
    
//    func paypalSuccess(orderID: String, payerID: String) {
//
//        print("ORDER =", orderID)
//        print("PAYER =", payerID)
//
//        let url = "https://api2.gis247.net/api/v1/webhook/paypal-success"
//
//        var components = URLComponents(string: url)!
//
//        components.queryItems = [
//
//            URLQueryItem(
//                name: "token",
//                value: orderID
//            ),
//
//            URLQueryItem(
//                name: "data",
//                value: mPaypalEncryptedPayload
//            )
//
//        ]
//
//        print("PAYPAL SUCCESS URL =")
//        print(components.url?.absoluteString ?? "")
//
//        URLSession.shared.dataTask(with: components.url!) { data, response, error in
//
//            if let error = error {
//
//                print(error)
//
//                return
//
//            }
//
//            print("PAYPAL CAPTURE SUCCESS")
//
//        }.resume()
//
//    }
    
    // MARK: - Delegates and Verification
    func isProceedWithStatus(status: Bool, message: String) { }
    
    func mGetDatePicker() { mShowDatePicker() }
    func mConfirmPayment(date: String, dateInGMT: Date, receiveAmount: String, outstanding: String, noOfReceived: String) {}
    func mCancelInstallment() {}
    func mGetReceiveAmount(masterData: NSArray, selectedData: NSMutableArray, totalInstallments: Int, totalMonths: Int, receivedAmount: Double, outstanding: Double, selectedInstallments: [Int]) {}
    func mGetScannedData(value: String, type: String) {
        if type == "GiftCard" { mGiftCardAmount.text = value }
    }
    func didTapCancelQRCode() { mCancelQRCode() }
    
    // The key Verify and Pay functions
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
        guard status else { return }
        submitVerifiedCheckout()
    }

    // MARK: - Verified checkout payload
    // Kept in POSCheckout so the POS storyboard continues to use this class while
    // sharing the current custom-order payload contract.
    private func checkoutAmount(_ text: String?) -> Double {
        let rawValue = text ?? ""
        let allowedCharacters = CharacterSet(charactersIn: "0123456789.-")
        let numericValue = rawValue.unicodeScalars
            .filter { allowedCharacters.contains($0) }
            .map(String.init)
            .joined()
        return Double(numericValue) ?? 0
    }

    private func checkoutCartWithDeliveryDates(currentDate: String) -> NSArray {
        let cart = NSMutableArray()

        for case let item as NSDictionary in mCartTableData {

            let updatedItem = item.mutableCopy() as! NSMutableDictionary

            // saveCustomOrder reads the salesperson from each cart item.
            // Keep this in addition to the root and summary-order values.
            updatedItem["sales_person_id"] = selectedSalesPersonId

            let deliveryDate = "\(updatedItem["delivery_date"] ?? "")"

            print("📅 delivery_date from cart =", deliveryDate)

            if deliveryDate.isEmpty {
                updatedItem["delivery_date"] = currentDate
            }

            print("📤 sending delivery_date =", updatedItem["delivery_date"] ?? "")

            cart.add(updatedItem)
        }

        return cart
    }

    private func checkoutCartWithSalesPerson() -> NSArray {
        let cart = NSMutableArray()

        for case let item as NSDictionary in mCartTableData {
            let updatedItem = item.mutableCopy() as! NSMutableDictionary
            updatedItem["sales_person_id"] = selectedSalesPersonId
            cart.add(updatedItem)
        }

        return cart
    }

    private func giftCardCheckoutCart(currentDate: String) -> NSArray {
        let cart = NSMutableArray()

        for case let item as NSDictionary in mCartTableData {
            let giftCardDetails = NSMutableDictionary()
            giftCardDetails["amount"] = item["amount_forcalculation"] ?? ""
            giftCardDetails["card_no"] = item["card_no"] ?? ""
            giftCardDetails["name"] = item["name"] ?? ""
            giftCardDetails["expire_date"] = item["expire_date"] ?? ""
            giftCardDetails["remark"] = item["remark"] ?? ""
            giftCardDetails["barcode"] = item["barcode"] ?? ""
            giftCardDetails["qr_code"] = item["qr_code"] ?? ""

            cart.add([
                "_id": item["custom_cart_id"] ?? "",
                "custom_cart_id": item["custom_cart_id"] ?? "",
                "delivery_date": currentDate,
                "giftCard_details": giftCardDetails
            ])
        }

        return cart
    }

    private func submitVerifiedCheckout() {
        print("DEBUG_SHIPPING: Billing: \(mSelectedBillingAddress)")
        print("DEBUG_SHIPPING: Shipping: \(mSelectedShippingAddress)")

        mFinalPaymentMethod = [String: Any]()

        let cashMethod = NSMutableDictionary()
        let creditNoteMethod = NSMutableDictionary()
        let debitedAmount = NSMutableDictionary()
        let payData = NSMutableDictionary()
        let paymentInfo = NSMutableDictionary()
        let summaryOrder = NSMutableDictionary()
        let sellInfo = NSMutableDictionary()

        let submittedCash = checkoutAmount(mSubmittedCash.text)
        let submittedBank = checkoutAmount(mSubmittedBankAmount.text)
        let submittedCreditCard = checkoutAmount(mSubmittedCreditCard.text)
        let submittedCreditNote = checkoutAmount(mSubmittedCreditNote.text)

        if let cashData = UserDefaults.standard.object(forKey: "CASHDATA") as? NSDictionary {
            cashMethod["payment_method_id"] = "\(cashData["id"] ?? "")"
            cashMethod["Paymentmethod_type"] = "cash"
            cashMethod["amount"] = submittedCash
        }

        debitedAmount["cash"] = submittedCash
        debitedAmount["bank"] = submittedBank
        debitedAmount["credit_card"] = submittedCreditCard
        debitedAmount["credit_notes"] = submittedCreditNote

        summaryOrder["labour"] = mLabourPoints
        summaryOrder["shipping"] = mShippingPoints
        summaryOrder["loyalty_points"] = mLoyaltyPoints
        summaryOrder["tax_amount"] = mTaxAmount
        summaryOrder["tax_amount_int"] = mTaxAmountInt
        summaryOrder["tax_prect"] = mTaxInPercent
        summaryOrder["tax_type"] = mTaxTypeIE
        summaryOrder["discount"] = mTaxDiscountAmount
        summaryOrder["discount_percent"] = mTaxDiscountPercent
        summaryOrder["customer_id"] = mCustomerId
        summaryOrder["sales_person_id"] = selectedSalesPersonId

        let fallbackRemark = UserDefaults.standard.string(forKey: "cRemark") ?? ""
        let finalRemark = mRemark.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? fallbackRemark
            : mRemark
        summaryOrder["remark"] = finalRemark
        summaryOrder["deposit"] = Int(mDepositPercents) ?? 0
        summaryOrder["deposit_amount"] = checkoutAmount(mTotalP)

//        let itemTotal = checkoutAmount(mCartTotalAmount)
//        summaryOrder["Sub_Total"] = itemTotal
        let grandTotal = checkoutAmount(mCartTotalAmount)

        let labour = mLabourPoints
        let shipping = mShippingPoints
        let discount = mTaxDiscountAmount
        var productTotal = 0.0

        for case let item as NSDictionary in mCartTableData {

            let qty = Double("\(item["Qty"] ?? "1")") ?? 1
            let price = checkoutAmount("\(item["cart_price"] ?? item["price"] ?? "0")")

            productTotal += price * qty
        }
        var subTotal = grandTotal

        if mTaxTypeIE.lowercased() == "inclusive" ||
           mTaxTypeIE.lowercased() == "exclusive" {

            subTotal = max(grandTotal - mTaxAmount, 0)
//            subTotal =
//            productTotal
//            - discount
//            + labour
//            + shipping
        }

        summaryOrder["Sub_Total"] = subTotal
        
        print("===== SUMMARY ORDER =====")
        print("Grand Total =", grandTotal)
        print("Tax Amount =", mTaxAmount)
        print("Sub Total =", subTotal)
        print("Tax Type =", mTaxTypeIE)
        
        let creditNoteTotal = mCreditData.reduce(0.0) { result, item in
            guard let value = item as? NSDictionary else { return result }
            return result + checkoutAmount("\(value["amount"] ?? "0")")
        }
        creditNoteMethod["ids"] = mCreditData
        creditNoteMethod["amount"] = creditNoteTotal
        creditNoteMethod["Paymentmethod_type"] = "CreditNote"

        payData["cash"] = cashMethod
        // POSCheckout has no separate Internet Banking collection. Preserve its
        // existing empty-IB behavior while using the newer payload shape.
        payData["IB"] = []
        payData["bank"] = mBankPayment
        payData["credit_card"] = mCreditCardMethod
        payData["credit_note"] = creditNoteMethod
        payData["gift_card"] = mGiftCardMethod

        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let currentDate = isoFormatter.string(from: Date())

        if mOrderType == "gift_card_order" {
            sellInfo["cart"] = giftCardCheckoutCart(currentDate: currentDate)
        } else {
            sellInfo["cart"] = checkoutCartWithDeliveryDates(currentDate: currentDate)
        }
        sellInfo["summary_order"] = summaryOrder
        sellInfo["status_type"] = mOrderType

        let cartTotal = checkoutAmount(mCartTotalAmount)
        sellInfo["totalamount"] = cartTotal > 0 ? cartTotal : checkoutAmount(mTotalWithDiscount)
        

        paymentInfo["debited_amount"] = debitedAmount
        paymentInfo["pay_data"] = payData
        paymentInfo["balance_due"] = ""
        paymentInfo["balance_deposit"] = ""

        mFinalPaymentMethod = [
            "sell_info": sellInfo,
            "payment_info": paymentInfo,
            "transaction_date": "",
            "customer_id": mCustomerId,
            "sales_person_id": selectedSalesPersonId,
            "byMobile": true,
            "order_type": mOrderType,
            "order_id": mOrderId,
            "remark": finalRemark,
            "note": mNote
        ]

        let quotationId = UserDefaults.standard.string(forKey: "quotationId") ?? ""
        if !quotationId.isEmpty {
            mFinalPaymentMethod["quatation_id"] = quotationId
        }

        if !mSelectedBillingAddress.isEmpty || !mSelectedShippingAddress.isEmpty {
            mFinalPaymentMethod["shipping_info"] = [
                "billing_address": mSelectedBillingAddress,
                "shipping_address": mSelectedShippingAddress
            ]
        }

        if mOrderType == "custom_order" {
            let deliveryDate = mCartTableData.compactMap { item -> String? in
                guard let item = item as? NSDictionary else { return nil }
                let date = "\(item["delivery_date"] ?? "")"
                return date.isEmpty ? nil : date
            }.first ?? ""
//            mFinalPaymentMethod["delivery_date"] = deliveryDate
        }

        if mOrderType == "reserve" {
            for case let item as NSDictionary in mCartTableData {
                let crossLocationId = "\(item["crossLocationId"] ?? "")"
                guard !crossLocationId.isEmpty else { continue }
                mFinalPaymentMethod["crossLocationId"] = crossLocationId
                mFinalPaymentMethod["crosslocation"] = item["crosslocation"] as? Bool ?? false
                break
            }
        }

        // Preserve the existing POS cross-location reserve route as a fallback.
        if mOrderType == "reserve", mIsCrossLocationReserve, !mCrossLocationId.isEmpty {
            mFinalPaymentMethod["crossLocation"] = true
            mFinalPaymentMethod["crossLocationId"] = mCrossLocationId
        }

        let eligibleOrderTypes: Set<String> = [
            "custom_order", "mix_and_match", "pos_order", "repair_order",
            "exchange_order", "gift_card_order", "refund_order", "reserve",
            "reserve_diamond", "deposit"
        ]
        guard eligibleOrderTypes.contains(mOrderType) else {
            CommonClass.showSnackBar(message: "Unsupported order type.")
            return
        }

        print("POSCheckout DEBUG_VERIFIED_PAYLOAD =", mFinalPaymentMethod)
        CommonClass.showFullLoader(view: view)

        AF.request(
            mFinalCheckoutCustomOrder,
            method: .post,
            parameters: mFinalPaymentMethod,
            encoding: JSONEncoding.default,
            headers: sGisHeaders
        ).responseJSON { response in
            CommonClass.stopLoader()

            switch response.result {
            case .success(let value):
                guard let jsonResult = value as? NSDictionary else { return }
                if let code = jsonResult["code"] as? Int, code == 400 {
                    CommonClass.showSnackBar(message: "\(jsonResult["message"] ?? "OOP's something went wrong!")")
                    return
                }
                guard let data = jsonResult["data"] as? NSDictionary else { return }
                self.showCompletedPayment(data: data)

            case .failure(let error):
                CommonClass.showSnackBar(message: error.localizedDescription)
            }
        }
    }

    private func showCompletedPayment(data: NSDictionary) {
        let storyBoard = UIStoryboard(name: "posBoard", bundle: nil)
        guard let completePayment = storyBoard.instantiateViewController(withIdentifier: "CompletePayment") as? CompletePayment else {
            return
        }

        completePayment.mType = mOrderType
        completePayment.mOrderId = "\(data["id"] ?? "")"
        completePayment.mEmailId = "\(data["email"] ?? "")"
        completePayment.mTotalQuantity = "\(mCartTableData.count)"
        completePayment.mTotalOutstandingBal = mTotalOutstandingAm
        completePayment.mCurrency = mCurrencySymbol
        completePayment.mDepositPercents = mDepositPercents
        completePayment.mDepositAmount = mTotalP
        completePayment.mGrandTotalAmount = mCartTotalAmount
        completePayment.mUrl = "\(data["url"] ?? "")"
        completePayment.mShippingInfo = [
            "billing_address": mSelectedBillingAddress,
            "shipping_address": mSelectedShippingAddress
        ]
        navigationController?.pushViewController(completePayment, animated: true)
    }
    
    func removePaypalView() {

        guard let hosting = paypalHostingController else {

                return

            }
        hosting.willMove(toParent: nil)

        hosting.view.removeFromSuperview()

        hosting.removeFromParent()

        paypalHostingController = nil
//        paypalHostingController?.view.removeFromSuperview()
//
//        paypalHostingController?.removeFromParent()
//
//        paypalHostingController = nil
    }
    
//    func setupPaypalView(showCreditCardButton: Bool) {
//
//        removePaypalView()
//
//        let paypalView = PayPalCheckoutView(
//
//            showCreditCardButton: showCreditCardButton,
//
//            paypalAction: { [weak self] in
//                guard let self = self else { return }
//
//                self.removePaypalView()
//
//                if let paypalData = self.mPaymentData.first(where: {
//
//                    guard let dict = $0 as? NSDictionary else {
//                        return false
//                    }
//
//                    return "\(dict["payment_slag"] ?? "")"
//                        == "paypal-payment"
//
//                }) as? NSDictionary {
//
//                    self.mPaymentMethod =
//                        "\(paypalData["PaymentMethod"] ?? "")"
//
//                    self.mPaymentID =
//                        "\(paypalData["id"] ?? "")"
//
//                    self.mStripPublishKey =
//                        "\(paypalData["key"] ?? "")"
//
//                    self.mPaypalClientID =
//                        "\(paypalData["key"] ?? "")"
//
//                    self.mPaypalEnvironment =
//                        "\(paypalData["environment"] ?? "sandbox")"
//                            .lowercased()
//
//                    self.mCreditBankName.text = "PayPal"
//
//                    self.mSelectdPaymentMethod = "paypal-payment"
//
//                    print("PAYPAL_METHOD =", self.mPaymentMethod)
//                    print("PAYPAL_ID =", self.mPaymentID)
//                    print("PAYPAL_CLIENT_ID =", self.mPaypalClientID)
//                    print("PAYPAL_ENV =", self.mPaypalEnvironment)
//                }
//
//                self.mCardNumberContainer.isHidden = true
//                self.mCardNameContainer.isHidden = true
//
//                self.mCreditFillAmount.text = ""
//
//                self.mCreditFillAmount.becomeFirstResponder()
//            },
//
//            creditCardAction: { [weak self] in
//
//            guard let self = self else { return }
//
//            self.removePaypalView()
//
//            if let stripeData = self.mPaymentData.first(where: {
//
//                guard let dict = $0 as? NSDictionary else {
//                    return false
//                }
//
//                return "\(dict["payment_slag"] ?? "")"
//                    == "stripe-payment"
//
//            }) as? NSDictionary {
//
//                self.mPaymentMethod =
//                    "\(stripeData["PaymentMethod"] ?? "")"
//
//                self.mPaymentID =
//                    "\(stripeData["id"] ?? "")"
//
//                self.mStripPublishKey =
//                    "\(stripeData["key"] ?? "")"
//
//                self.mCreditBankName.text =
//                    "\(stripeData["name"] ?? "")"
//
//                self.mSelectdPaymentMethod =
//                    "stripe-payment"
//            }
//
//            self.mCardNumberContainer.isHidden = true
//            self.mCardNameContainer.isHidden = true
//
//            self.mCreditFillAmount.text = ""
//
//            self.mCreditFillAmount.becomeFirstResponder()
//        }
//    )
//
//        let hosting =
//        UIHostingController(rootView: paypalView)
//
//        addChild(hosting)
//
//        hosting.view.translatesAutoresizingMaskIntoConstraints = false
//
//        mStripeCardView.addSubview(hosting.view)
//
//        NSLayoutConstraint.activate([
//
//            hosting.view.topAnchor.constraint(
//                equalTo: mStripeCardView.topAnchor),
//
//            hosting.view.bottomAnchor.constraint(
//                equalTo: mStripeCardView.bottomAnchor),
//
//            hosting.view.leadingAnchor.constraint(
//                equalTo: mStripeCardView.leadingAnchor),
//
//            hosting.view.trailingAnchor.constraint(
//                equalTo: mStripeCardView.trailingAnchor)
//        ])
//
//        hosting.didMove(toParent: self)
//
//        paypalHostingController = hosting
//    }
//
//    func selectPayment(data: NSDictionary) {
//
//        mPaymentID =
//            "\(data["id"] ?? "")"
//
//        mPaymentMethod =
//            "\(data["PaymentMethod"] ?? "")"
////
////        mStripPublishKey =
////            "\(data["key"] ?? "")"
//
//        mStripPublishKey =
//            "\(data["key"] ?? "")"
//
//        mSelectdPaymentMethod =
//            "\(data["payment_slag"] ?? "")"
//
////        if mSelectdPaymentMethod == "paypal-payment" ||
////            "\(data["payment_slag"] ?? "")" == "paypal-payment" {
////
////            mPaypalClientID =
////                "\(data["key"] ?? "")"
////
////            mPaypalEnvironment =
////                "\(data["environment"] ?? "sandbox")"
////                    .lowercased()
////        }
//
//        if mSelectdPaymentMethod == "paypal-payment" {
//
//            mPaypalClientID =
//                "\(data["key"] ?? "")"
//
//            mPaypalEnvironment =
//                "\(data["environment"] ?? "sandbox")"
//                    .lowercased()
//        }
//        print("PAYPAL CLIENT =", mPaypalClientID)
//        print("PAYPAL ENV =", mPaypalEnvironment)
//        print("PAYPAL PAYMENT METHOD =", mPaymentMethod)
//
//
//        mCreditCardPaymentId =
//            "\(data["id"] ?? "")"
//
//        mCreditCardLogo =
//            "\(data["PayMethod_logo"] ?? "")"
//
//        mCreditCardName =
//            "\(data["name"] ?? "")"
//
//        mCreditBankImage.downlaodImageFromUrl(
//            urlString: mCreditCardLogo
//        )
//
//        if mSelectdPaymentMethod == "paypal-payment" {
//
//            mCreditBankName.text = "PayPal"
//
//        } else {
//
//            mCreditBankName.text =
//                "Debit or Credit Card"
//        }
//
//        mStripeCardView.isHidden = false
//
//        mCardNumberContainer.isHidden = true
//        mCardNameContainer.isHidden = true
//
//        mCreditFillAmount.text = ""
//
//        mCreditFillAmount.becomeFirstResponder()
//    }
    
    func setupPaypalView(showCreditCardButton: Bool) {

        removePaypalView()

//        let paypalView = PayPalCheckoutView(
//
//            showCreditCardButton: showCreditCardButton,
//
//            paypalAction: { [weak self] in
//
//                self?.showPaypalEnvironmentSelector()
//
//            },
//
//            creditCardAction: { [weak self] in
//
//                guard let self = self else { return }
//
//                self.removePaypalView()
//
//                if let stripeData = self.mPaymentData.first(where: {
//
//                    guard let dict = $0 as? NSDictionary else {
//                        return false
//                    }
//
//                    return "\(dict["payment_slag"] ?? "")" == "stripe-payment"
//
//                }) as? NSDictionary {
//
//                    self.selectPayment(data: stripeData)
//                }
//            }
//        )
        
        let paypalView = PayPalCheckoutView(

            showCreditCardButton: showCreditCardButton,

            paypalAction: { [weak self] in

                self?.showPaypalEnvironmentSelector()

            },

            creditCardAction: { [weak self] in

                guard let self = self else { return }

                if let stripeData = self.mPaymentData.first(where: {

                    guard let dict = $0 as? NSDictionary else {
                        return false
                    }

                    return "\(dict["payment_slag"] ?? "")" == "stripe-payment"

                }) as? NSDictionary {

                    self.selectPayment(data: stripeData)
                }
            }
        )

        let hosting = UIHostingController(rootView: paypalView)

        addChild(hosting)

        hosting.view.translatesAutoresizingMaskIntoConstraints = false

        mStripeCardView.addSubview(hosting.view)

        NSLayoutConstraint.activate([

            hosting.view.topAnchor.constraint(equalTo: mStripeCardView.topAnchor),
            hosting.view.bottomAnchor.constraint(equalTo: mStripeCardView.bottomAnchor),
            hosting.view.leadingAnchor.constraint(equalTo: mStripeCardView.leadingAnchor),
            hosting.view.trailingAnchor.constraint(equalTo: mStripeCardView.trailingAnchor)

        ])

        hosting.didMove(toParent: self)

        paypalHostingController = hosting
    }
    
    func showPaypalEnvironmentSelector() {

        let alert = UIAlertController(
            title: "Select PayPal",
            message: nil,
            preferredStyle: .actionSheet
        )

        if mPaypalSandboxData.count > 0 {

            alert.addAction(
                UIAlertAction(
                    title: "Sandbox",
                    style: .default
                ) { _ in

                    self.selectPayment(data: self.mPaypalSandboxData)

                }
            )
        }

        if mPaypalLiveData.count > 0 {

            alert.addAction(
                UIAlertAction(
                    title: "Live",
                    style: .default
                ) { _ in

                    self.selectPayment(data: self.mPaypalLiveData)

                }
            )
        }

        alert.addAction(
            UIAlertAction(
                title: "Cancel",
                style: .cancel
            )
        )

        present(alert, animated: true)
    }
    
    func selectPayment(data: NSDictionary) {

        removePaypalView()

        mSelectedPaypalMethodData = data
        
        mPaymentID =
            "\(data["id"] ?? "")"

        mPaymentMethod =
            "\(data["PaymentMethod"] ?? "")"

        mStripPublishKey =
            "\(data["key"] ?? "")"

        let providedPaymentSlug =
            "\(data["payment_slag"] ?? "")"
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .lowercased()
        let paymentName =
            "\(data["name"] ?? "")"
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .lowercased()

        // Cregis configurations currently return an empty payment_slag.
        // Keep the API-supplied slug when present, but derive the known
        // Cregis provider slug so Submit can start its checkout flow.
        mSelectdPaymentMethod =
            providedPaymentSlug.isEmpty && paymentName.contains("cregis")
            ? "cregis-payment"
            : providedPaymentSlug

        if mSelectdPaymentMethod == "paypal-payment" {

            mPaypalClientID =
                "\(data["key"] ?? "")"

            mPaypalEnvironment =
                "\(data["environment"] ?? "sandbox")"
                    .lowercased()

            mCreditBankName.text = "PayPal"

        } else {

            mCreditBankName.text = "Debit or Credit Card"
        }

        print("========== PAYMENT SELECT ==========")
        print("NAME =", data["name"] ?? "")
        print("METHOD =", mPaymentMethod)
        print("SLUG =", mSelectdPaymentMethod)
        print("CLIENT =", mPaypalClientID)
        print("ENV =", mPaypalEnvironment)

        mCreditCardPaymentId =
            "\(data["id"] ?? "")"

        mCreditCardLogo =
            "\(data["PayMethod_logo"] ?? "")"

        mCreditCardName =
            "\(data["name"] ?? "")"

//        mCreditBankImage.downlaodImageFromUrl(
//            urlString: mCreditCardLogo
//        )
//        mCreditBankName.text = mCreditCardName
        mCreditBankImage.downlaodImageFromUrl(urlString: mCreditCardLogo)

        mStripeCardView.isHidden = false

        mCardNumberContainer.isHidden = true
        mCardNameContainer.isHidden = true

//        mCreditFillAmount.text = ""
//        mCreditFillAmount.becomeFirstResponder()
        mCreditFillAmount.text =
        mBALANCEDUE.text?
            .replacingOccurrences(of: "$", with: "")
            .replacingOccurrences(of: ",", with: "")
            .trimmingCharacters(in: .whitespaces)

        mCreditFillAmount.becomeFirstResponder()
    }
    
    
    @IBAction func mPayNow(_ sender: UIButton) {
        guard !selectedSalesPersonId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            resumePayNowAfterSalesPersonSelection = true
            showSalesPersonRequiredAlert()
            return
        }

        sender.showAnimation{}
        if mOrderType == "refund_order" {
            mPayNowAlert()
            return
        }
        if (Double(mBALANCEDUE.text?.replacingOccurrences(of: ",", with: "") ?? "") ?? 0.00) == 0 {
            mPayNowAlert()
        }else{
            CommonClass.showSnackBar(message: "Please enter valid amount!")
        }
    }
    
    func mPayNowAlert(){
        mConfirmationPopUp.frame = self.view.bounds
        mConfirmationPopUp.delegate = self
        mConfirmationPopUp.mMessage.text = "Are you sure want to proceed ?".localizedString
        mConfirmationPopUp.mCancelButton.setTitle("CANCEL".localizedString, for: .normal)
        mConfirmationPopUp.mConfirmButton.setTitle("CONFIRM".localizedString, for: .normal)
        self.view.addSubview(mConfirmationPopUp)
    }

    private func showSalesPersonRequiredAlert() {
        let alert = UIAlertController(
            title: "Salesperson Required",
            message: "Please select a Salesperson before payment.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            self?.resumePayNowAfterSalesPersonSelection = false
        })
        alert.addAction(UIAlertAction(title: "Select Salesperson", style: .default) { [weak self] _ in
            self?.fetchSalesPersonsForCheckout()
        })
        present(alert, animated: true)
    }

    private func installCheckoutSalesPersonButton() {
        guard checkoutSalesPersonButton == nil else { return }

        // The storyboard already has a menu icon at the far right.  Cover that
        // position with an explicit two-icon group so the menu and salesperson
        // controls retain the same separation as the Checkout design.
        let actions = UIView()
        actions.translatesAutoresizingMaskIntoConstraints = false
        actions.backgroundColor = .white
        view.addSubview(actions)

        let menuIcon = UIImageView(image: UIImage(systemName: "square.grid.2x2"))
        menuIcon.translatesAutoresizingMaskIntoConstraints = false
        menuIcon.tintColor = UIColor(named: "theme6A") ?? .systemGray
        menuIcon.contentMode = .scaleAspectFit
        actions.addSubview(menuIcon)

        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(
            UIImage(named: "pos_contact")?.withRenderingMode(.alwaysOriginal)
                ?? UIImage(systemName: "person.crop.circle"),
            for: .normal
        )
        button.imageView?.contentMode = .scaleAspectFit
        button.accessibilityLabel = "Choose Salesperson"
        button.addTarget(self, action: #selector(checkoutSalesPersonTapped), for: .touchUpInside)
        actions.addSubview(button)

        NSLayoutConstraint.activate([
            actions.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -12),
            actions.centerYAnchor.constraint(equalTo: mHCheckoutLABEL.centerYAnchor),
            actions.widthAnchor.constraint(equalToConstant: 72),
            actions.heightAnchor.constraint(equalToConstant: 35),

            menuIcon.leadingAnchor.constraint(equalTo: actions.leadingAnchor),
            menuIcon.centerYAnchor.constraint(equalTo: actions.centerYAnchor),
            menuIcon.widthAnchor.constraint(equalToConstant: 26),
            menuIcon.heightAnchor.constraint(equalToConstant: 26),

            button.trailingAnchor.constraint(equalTo: actions.trailingAnchor),
            button.centerYAnchor.constraint(equalTo: actions.centerYAnchor),
            button.widthAnchor.constraint(equalToConstant: 28),
            button.heightAnchor.constraint(equalToConstant: 28)
        ])
        checkoutHeaderActions = actions
        checkoutSalesPersonButton = button
        updateCheckoutSalesPersonImage()
    }

    /// Reflect the current sale's selected salesperson in the Checkout header.
    /// This intentionally reads the same values saved by PosCart and the picker
    /// below, so returning to Checkout also refreshes the avatar.
    private func updateCheckoutSalesPersonImage() {
        guard let button = checkoutSalesPersonButton else { return }

        let salesPersonId = selectedSalesPersonId.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !salesPersonId.isEmpty else {
            button.setImage(
                UIImage(named: "pos_contact")?.withRenderingMode(.alwaysOriginal)
                    ?? UIImage(systemName: "person.crop.circle"),
                for: .normal
            )
            return
        }

        let fallback = UIImage(named: "usericon")?.withRenderingMode(.alwaysOriginal)
            ?? UIImage(systemName: "person.crop.circle.fill")
        button.setImage(fallback, for: .normal)

        let imageURL = (UserDefaults.standard.string(forKey: "SALESPERSON_IMAGE") ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard let url = URL(string: imageURL), !imageURL.isEmpty else { return }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self,
                  let data,
                  let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                // Do not let a previous selection's slow request overwrite the
                // avatar of a salesperson selected afterwards.
                guard self.selectedSalesPersonId == salesPersonId else { return }
                self.checkoutSalesPersonButton?.setImage(
                    image.withRenderingMode(.alwaysOriginal),
                    for: .normal
                )
            }
        }.resume()
    }

    @objc private func checkoutSalesPersonTapped() {
        resumePayNowAfterSalesPersonSelection = false
        fetchSalesPersonsForCheckout()
    }

    private func fetchSalesPersonsForCheckout() {
        let locationID = UserDefaults.standard.string(forKey: "location")?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !locationID.isEmpty else {
            CommonClass.showSnackBar(message: "Current store location is unavailable")
            return
        }

        // Sales people belong to the active store, not a fixed location.
        let query = "{salespersons(location: \"\(locationID)\"){id name image country phone}}"
        let params: [String: Any] = ["query": query]

        CommonClass.showFullLoader(view: view)
        AF.request(
            mInventoryGrapQlUrl,
            method: .post,
            parameters: params,
            encoding: JSONEncoding.default,
            headers: sGisHeaders
        ).responseJSON { [weak self] response in
            guard let self else { return }
            CommonClass.stopLoader()

            guard response.error == nil,
                  let data = response.data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let root = json["data"] as? [String: Any],
                  let rows = root["salespersons"] as? [[String: Any]] else {
                CommonClass.showSnackBar(message: "Unable to load Sales Person list")
                return
            }

            self.checkoutSalesPersons = rows.compactMap { row in
                guard let id = row["id"] as? String,
                      !id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                    return nil
                }

                return POSSalesPersonRow(
                    id: id,
                    name: self.checkoutSalesPersonString(row["name"]).isEmpty ? id : self.checkoutSalesPersonString(row["name"]),
                    image: self.checkoutSalesPersonString(row["image"]),
                    country: self.checkoutSalesPersonString(row["country"]),
                    phone: self.checkoutSalesPersonString(row["phone"])
                )
            }

            guard !self.checkoutSalesPersons.isEmpty else {
                CommonClass.showSnackBar(message: "No Sales Person found")
                return
            }
            self.showCheckoutSalesPersonPicker()
        }
    }

    private func checkoutSalesPersonString(_ value: Any?) -> String {
        if let value = value as? String {
            return value.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        if let value = value as? NSNumber {
            return value.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return ""
    }

    private func showCheckoutSalesPersonPicker() {
        checkoutSalesPersonPicker?.removeFromSuperview()

        let picker = POSSalesPersonPickerView(
            rows: checkoutSalesPersons,
            onSelect: { [weak self] person in
                guard let self else { return }

                UserDefaults.standard.set(person.id, forKey: "sales_person_id")
                UserDefaults.standard.set(person.id, forKey: "SALESPERSONID")
                UserDefaults.standard.set(person.name, forKey: "sales_person_name")
                UserDefaults.standard.set(person.name, forKey: "SALESPERSONNAME")
                if person.image.isEmpty {
                    UserDefaults.standard.removeObject(forKey: "SALESPERSON_IMAGE")
                } else {
                    UserDefaults.standard.set(person.image, forKey: "SALESPERSON_IMAGE")
                }

                self.updateCheckoutSalesPersonImage()

                self.checkoutSalesPersonPicker?.dismissPicker()
                self.checkoutSalesPersonPicker = nil

                if self.resumePayNowAfterSalesPersonSelection {
                    self.resumePayNowAfterSalesPersonSelection = false
                    DispatchQueue.main.async {
                        self.mPayNow(self.mPayNowButton)
                    }
                }
            },
            onProfileTap: { _ in }
        )

        picker.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(picker)
        NSLayoutConstraint.activate([
            picker.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            picker.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            picker.topAnchor.constraint(equalTo: view.topAnchor),
            picker.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        checkoutSalesPersonPicker = picker
        picker.showAnimated()
    }

    // MARK: - PAY NOW
    func PayNow() {
        mFinalPaymentMethod = [String: Any]()
        let mCashMethod = NSMutableDictionary()
        let mCreditNoteMethod = NSMutableDictionary()
        let mDebitedAmount = NSMutableDictionary()
        let mPayData = NSMutableDictionary()
        let mPaymentInfo = NSMutableDictionary()
        let mSummaryOrder = NSMutableDictionary()
        let mSellInfo = NSMutableDictionary()

        if let mCashData = UserDefaults.standard.object(forKey: "CASHDATA") as? NSDictionary {
            mCashMethod.setValue("\(mCashData.value(forKey: "id") ?? "")", forKey: "payment_method_id")
            mCashMethod.setValue("cash", forKey: "Paymentmethod_type")
            mCashMethod.setValue(Double(self.mSubmittedCash.text ?? "") ?? 0.00, forKey: "amount")
        }

        mDebitedAmount.setValue(Double(self.mSubmittedCash.text ?? "") ?? 0.00, forKey: "cash")
        mDebitedAmount.setValue(Double(self.mSubmittedBankAmount.text ?? "") ?? 0.00, forKey: "bank")
        mDebitedAmount.setValue(Double(self.mSubmittedCreditCard.text ?? "") ?? 0.00, forKey: "credit_card")
        mDebitedAmount.setValue(Double(self.mSubmittedCreditNote.text ?? "") ?? 0.00, forKey: "credit_notes")

        mSummaryOrder.setValue(mLabourPoints, forKey: "labour")
        mSummaryOrder.setValue(mShippingPoints, forKey: "shipping")
        mSummaryOrder.setValue(mLoyaltyPoints, forKey: "loyalty_points")
        mSummaryOrder.setValue(mTaxAmount, forKey: "tax_amount")
        mSummaryOrder.setValue(mTaxAmountInt, forKey: "tax_amount_int")
        mSummaryOrder.setValue(mTaxInPercent, forKey: "tax_prect")
        mSummaryOrder.setValue(mTaxTypeIE, forKey: "tax_type")
        mSummaryOrder.setValue(mTaxDiscountAmount, forKey: "discount")
        mSummaryOrder.setValue(mTaxDiscountPercent, forKey: "discount_percent")
//        mSummaryOrder.setValue(self.mRemark, forKey: "remark")
        mSummaryOrder.setValue(mCustomerId, forKey: "customer_id")
        mSummaryOrder.setValue(selectedSalesPersonId, forKey: "sales_person_id")
        mSummaryOrder.setValue(Int(mDepositPercents), forKey: "deposit")
        mSummaryOrder.setValue(Double(mTotalP), forKey: "deposit_amount")

        var mCreditFinalTotalAmountObj = "0"
        var mAmount = [Double]()
        for item in mCreditData {
            if let value = item as? NSDictionary {
                mAmount.append(Double("\(value.value(forKey: "amount") ?? 0.00)") ?? 0.00)
            }
        }
        mCreditFinalTotalAmountObj = "\(mAmount.reduce(0, {$0 + $1}))"
        mCreditNoteMethod.setValue(mCreditData, forKey: "ids")
        mCreditNoteMethod.setValue(Double(mCreditFinalTotalAmountObj) ?? 0.00, forKey: "amount")
        mCreditNoteMethod.setValue("CreditNote", forKey: "Paymentmethod_type")

        mPayData.setValue(mCashMethod, forKey: "cash")
        mPayData.setValue(mBankPayment, forKey: "bank")
        mPayData.setValue([], forKey: "IB")
        mPayData.setValue(mCreditCardMethod, forKey: "credit_card")
        mPayData.setValue(mCreditNoteMethod, forKey: "credit_note")
        mPayData.setValue("", forKey: "gift_card")

        let checkoutCart = checkoutCartWithSalesPerson()
        print("DEBUG_CART_DATA POSCheckout mPayNow = \(checkoutCart)")
        mSellInfo.setValue(checkoutCart, forKey: "cart")
        mSellInfo.setValue(mSummaryOrder, forKey: "summary_order")
        mSellInfo.setValue(mOrderType, forKey: "status_type")
        mSellInfo.setValue(Double(mTotalWithDiscount) ?? 0.00, forKey: "totalamount")
        
//        mSellInfo.setValue(mCartTableData, forKey: "cart")
        
        print("========== CART ITEMS ==========")

        for case let item as NSDictionary in mCartTableData {

            print(item)

        }

        print("===============================")

        print("========== CART DATA ==========")

        for item in mCartTableData {
            print(item)
        }

        print("===============================")

        mSellInfo.setValue(mSummaryOrder, forKey: "summary_order")
        mSellInfo.setValue(mOrderType, forKey: "status_type")
        mSellInfo.setValue(Double(mTotalWithDiscount) ?? 0.00, forKey: "totalamount")

        mPaymentInfo.setValue(mDebitedAmount, forKey: "debited_amount")
        mPaymentInfo.setValue(mPayData, forKey: "pay_data")
        mPaymentInfo.setValue("", forKey: "balance_due")
        mPaymentInfo.setValue("", forKey: "balance_deposit")

        mFinalPaymentMethod = [
            "sell_info": mSellInfo,
            "payment_info": mPaymentInfo,
            "transaction_date": "",
            "customer_id": self.mCustomerId,
            "sales_person_id": selectedSalesPersonId,
            "byMobile": true,
            "order_type": self.mOrderType,
            "order_id": self.mOrderId,
            "remark": self.mRemark,
            "note": self.mNote
        ]
        
        var finalRemark = self.mRemark
        print("mSellInfo = \(mSellInfo)")
        print("mFinalPaymentMethod = \(mFinalPaymentMethod)")

        if let cartItems = self.mCartTableData as? NSArray {
            for item in cartItems {
                guard let data = item as? NSDictionary,
                      let serviceLabour = data["Service_labour"] as? NSDictionary else {
                    continue
                }

                let serviceRemark = "\(serviceLabour["service_remark"] ?? "")"
                    .trimmingCharacters(in: .whitespacesAndNewlines)

                if !serviceRemark.isEmpty {
                    finalRemark = serviceRemark
                    break
                }
            }
        }

        mFinalPaymentMethod["remark"] = finalRemark
        mFinalPaymentMethod["note"] = self.mNote
        print("DEBUG_ORDER_TYPE_API =", self.mOrderType)
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
        
        print("DEBUG_ORDER_TYPE =", mOrderType)

        if let shippingInfo = mFinalPaymentMethod["shipping_info"] {
            print("DEBUG_SHIPPING_INFO =", shippingInfo)
        } else {
            print("DEBUG_SHIPPING_INFO = NIL")
        }
        
        

//        let eligibleOrderTypes = ["custom_order", "mix_and_match", "pos_order", "repair_order", "exchange_order", "gift_card_order", "refund_order", "reserve", "deposit_order", "deposit"]
        let eligibleOrderTypes = [
            "custom_order",
            "mix_and_match",
            "pos_order",
            "repair_order",
            "exchange_order",
            "gift_card_order",
            "refund_order",
            "reserve",
            "reserve_diamond",
            "deposit"
        ]
        
        if self.mOrderType == "reserve",
           self.mIsCrossLocationReserve,
           !self.mCrossLocationId.isEmpty {

            mFinalPaymentMethod["crossLocation"] = true
            mFinalPaymentMethod["crossLocationId"] = self.mCrossLocationId
        }
        
        print("POSCheckout DEBUG_REMARK = \(self.mRemark)")
        print("POSCheckout DEBUG_PAYLOAD = \(mFinalPaymentMethod)")
        print("DEBUG_FINAL_PAYMENT POSCheckout =", mFinalPaymentMethod)
        if eligibleOrderTypes.contains(mOrderType) {
            CommonClass.showFullLoader(view: self.view)
            
            AF.request(mFinalCheckoutCustomOrder, method: .post, parameters: mFinalPaymentMethod, encoding: JSONEncoding.default, headers: sGisHeaders).responseJSON { response in
                CommonClass.stopLoader()
                
                switch response.result {
                case .success(let value):
                    guard let jsonResult = value as? NSDictionary else { return }
                    if let mCode = jsonResult.value(forKey: "code") as? Int, mCode == 400 {
                        CommonClass.showSnackBar(message: "\(jsonResult.value(forKey: "message") ?? "OOP's something went wrong!")")
                        return
                    }
                    if let mData = jsonResult.value(forKey: "data") as? NSDictionary {
                        let storyBoard: UIStoryboard = UIStoryboard(name: "posBoard", bundle: nil)
                        if let mCompletePayment = storyBoard.instantiateViewController(withIdentifier: "CompletePayment") as? CompletePayment {
                            print("====================================")
                            print("DEBUG CHECKOUT mOrderType =", self.mOrderType)
                            print("DEBUG ORDER ID =", "\(mData.value(forKey: "id") ?? "")")
                            print("====================================")
//                            if self.mOrderType == "refund_order" {
                                mCompletePayment.mType = self.mOrderType
//                            }
                            print("DEBUG COMPLETE mType =", mCompletePayment.mType)
                            mCompletePayment.mOrderId = "\(mData.value(forKey: "id") ?? "")"
                            mCompletePayment.mEmailId = "\(mData.value(forKey: "email") ?? "")"
                            mCompletePayment.mTotalQuantity = "\(self.mCartTableData.count)"
                            mCompletePayment.mTotalOutstandingBal = self.mTotalOutstandingAm
                            mCompletePayment.mCurrency = self.mCurrencySymbol
                            mCompletePayment.mDepositPercents = self.mDepositPercents
                            mCompletePayment.mDepositAmount = self.mTotalP
                            mCompletePayment.mGrandTotalAmount = self.mCartTotalAmount
                            mCompletePayment.mUrl = "\(mData.value(forKey: "url") ?? "")"
                            mCompletePayment.mShippingInfo = [
                                "billing_address": self.mSelectedBillingAddress,
                                "shipping_address":self.mSelectedShippingAddress
                            ]
                            
                            print("BILLING =", self.mSelectedBillingAddress)
                            print("SHIPPING =", self.mSelectedShippingAddress)
                            self.navigationController?.pushViewController(mCompletePayment, animated:true)
                        }
                    }
                case .failure(let error):
                    CommonClass.showSnackBar(message: error.localizedDescription)
                }
            }
        }
    }

    // MARK: - Actions
    @IBAction func mDeleteIBAmount(_ sender: Any) {
        if let text = mEnterAmountText?.text, text != "" {
            var newText = text
            newText.removeLast()
            mEnterAmountText?.text = newText
        }
    }
    
    @IBAction func mIBTabButton(_ sender: Any) {
        mSelectPaymentOptionContainer.isHidden = false
        mChequeDetailsView.isHidden = true
        if let ibBtn = mIBSelect { ibBtn.isSelected = true }
        if let chqBtn = mChequeSelect { chqBtn.isSelected = false }
        if let ibLbl = mIBTabSelect { ibLbl.backgroundColor = UIColor(named: "themeColor") }
        if let chqLbl = mChequeTabSelect { chqLbl.backgroundColor = UIColor(named: "themeExtraLightText") }
    }
    
    @IBAction func mChequeTabButton(_ sender: Any) {
        mSelectPaymentOptionContainer.isHidden = true
        mChequeDetailsView.isHidden = false
        if let chqBtn = mChequeSelect { chqBtn.isSelected = true }
        if let ibBtn = mIBSelect { ibBtn.isSelected = false }
        if let chqLbl = mChequeTabSelect { chqLbl.backgroundColor = UIColor(named: "themeColor") }
        if let ibLbl = mIBTabSelect { ibLbl.backgroundColor = UIColor(named: "themeExtraLightText") }
    }
    
    @IBAction func mBankSelect(_ sender: Any) {
        var mBankNames = ["Choose Bank"]
        let mBankTypeFilter = "IB"
        var mBankImage = ["https://art.gis247.net/assets/images/icon/camera_profile.png"]
        var mPMId = [""]
        if let mBankData = UserDefaults.standard.object(forKey: "BANKDATA") as? NSArray {
            if mBankData.count > 0 {
                for i in mBankData {
                    if let data = i as? NSDictionary {
                        if "\(data.value(forKey: "BankPaymenttype") ?? "")" == mBankTypeFilter {
                            mBankNames.append("\(data.value(forKey: "name") ?? "")")
                            mBankImage.append("\(data.value(forKey: "PayMethod_logo") ?? "")")
                            mPMId.append("\(data.value(forKey: "PaymentMethod") ?? "")")
                        }
                    }
                }
                let dropdown = DropDown()
                dropdown.anchorView = self.mCheqBankName
                dropdown.direction = .bottom
                dropdown.layer.cornerRadius = 15
                dropdown.backgroundColor = .white
                dropdown.bottomOffset = CGPoint(x: 0, y: 50)
                dropdown.width = self.view.frame.width - 32
                dropdown.dataSource = mBankNames
                dropdown.cellNib = UINib(nibName: "Currency", bundle: nil)
                dropdown.customCellConfiguration = { (index: Int, item: String, cell: DropDownCell) in
                    guard let cell = cell as? CurrencyCell else { return }
                    cell.mCurrencyImage.downlaodImageFromUrl(urlString: "\(mBankImage[index])")
                }
                dropdown.selectionAction = { [unowned self] (index: Int, item: String) in
                    self.mChequePaymentId = mPMId[index]
                    print("DEBUG_CURRENCY =", item)

                        print("DEBUG_RATE_ARRAY =",
                              self.mExchangeRateData)

                        print("DEBUG_SELECTED_RATE =",
                              index < self.mExchangeRateData.count
                              ? self.mExchangeRateData[index]
                              : "N/A")
                    if let sbn = self.mSelectedBankName { sbn.text = item }
                    if let sbi = self.mSelectedBankImage { sbi.downlaodImageFromUrl(urlString: mBankImage[index]) }
                }
                dropdown.show()
            } else {
                CommonClass.showSnackBar(message: "Please add authorised bank!")
            }
        }
    }
    
    @IBAction func mTakePhoto(_ sender: Any) {}
    
    @IBAction func mScanQRCOde(_ sender: Any) {
        if mEnterQRAmount?.text?.isEmpty == true || (Double(mEnterQRAmount?.text ?? "") ?? 0.0) == 0 {
            CommonClass.showSnackBar(message: "Please fill amount!")
            return
        }
        if let balanceDue = mBALANCEDUE.text {
            let formattedBalanceDue = balanceDue.replacingOccurrences(of: ",", with: "")
            let balanceDueInDouble = Double(formattedBalanceDue) ?? 0.0
            let inputAmount = Double(mEnterQRAmount?.text ?? "") ?? 0.0
            if (balanceDueInDouble - inputAmount) < 0 {
                CommonClass.showSnackBar(message: "Please fill valid amount!")
                return
            }
        }
        if mSelectedBankName?.text == "Choose Bank" || mSelectedBankName?.text?.isEmpty == true {
            CommonClass.showSnackBar(message: "Please choose a bank name!")
            return
        }
        mGenerateQRCode()
    }
    
    @IBAction func mGiftCardScan(_ sender: UIButton) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "transactions", bundle: nil)
        if let mCommonScanner = storyBoard.instantiateViewController(withIdentifier: "CommonScanner") as? CommonScanner {
            mCommonScanner.delegate = self
            mCommonScanner.mType = "GiftCard"
            mCommonScanner.modalPresentationStyle = .overFullScreen
            mCommonScanner.transitioningDelegate = self
            self.present(mCommonScanner,animated: true)
        }
    }
    
    @IBAction func mPaymentOptions(_ sender: UIButton) {
        mPaymentOptionIcon?.tintColor = UIColor(named: "themeColor")
        UIView.animate(withDuration: 1.0) {
            self.mPaymentOptionView?.isHidden = false
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func mFullPaymentOption(_ sender: Any) {
        mPaymentOptionIcon?.tintColor = UIColor(named: "themeExtraLightText")
        UIView.animate(withDuration: 1.0) {
            self.mPaymentOptionView?.isHidden = true
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func mLaybyOption(_ sender: Any) {
        mPaymentOptionIcon?.tintColor = UIColor(named: "themeExtraLightText")
        UIView.animate(withDuration: 1.0) {
            self.mPaymentOptionView?.isHidden = true
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func mInstallmentOption(_ sender: Any) {
        mPaymentOptionIcon?.tintColor = UIColor(named: "themeExtraLightText")
        UIView.animate(withDuration: 1.0) {
            self.mPaymentOptionView?.isHidden = true
            self.view.layoutIfNeeded()
        }
    }
    
    func mResetPricings() {
        self.mSubmittedCash.text = "0.00"
        self.mSubmittedCreditCard.text = "0.00"
        self.mSubmittedCreditNote.text = "0.00"
        self.mSubmittedBankAmount.text = "0.00"
        self.mConvertedAmounts = "0"
        self.mConvertedAmount.text = ""
        self.mCashAmounts = ""
        self.mCashAmount.text = ""
        mFetchCreditNoteData(value: "")
    }
    
    @IBAction func mInstallmentDetails(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "laybyInstallment", bundle: nil)
        if let mInstallmentPicker = storyBoard.instantiateViewController(withIdentifier: "InstallmentPicker") as? InstallmentPicker {
            mInstallmentPicker.delegate = self
            mInstallmentPicker.mTotalAmount = Double(self.mTOTALAMOUNT.text ?? "0.00") ?? 0.00
            mInstallmentPicker.modalPresentationStyle = .overFullScreen
            mInstallmentPicker.transitioningDelegate = self
            self.present(mInstallmentPicker,animated: true)
        }
    }
    
    func mShowDatePicker(){
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
        let mToolBar = UIToolbar()
        mToolBar.sizeToFit()
        mToolBar.backgroundColor = .white
        mToolBar.barTintColor = .white
        let mDone = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donePick))
        let mSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let mCancel = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(mCancelPick))
        mToolBar.setItems([mCancel, mSpace,mDone], animated: false)
        mPaymentConfirmation.mDueDate.inputAccessoryView = mToolBar
        mPaymentConfirmation.mDueDate.inputView = mDatePicker
        mPaymentConfirmation.mDueDate.becomeFirstResponder()
    }
    
    @objc func donePick(){
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "dd/MM/yyyy"

        mConfirmQuote.mCurrentDate.text = formatter.string(from: mDatePicker.date)
        self.view.endEditing(true)
    }
    @objc func mCancelPick(){ self.view.endEditing(true) }
    
    @IBAction func mApplyGiftCard(_ sender: UIButton) {
        sender.showAnimation{}
        if mGiftCardAmount.text != "" {
            mApplyGiftCards(cardNumber: mGiftCardAmount.text ?? "")
        }else{
            CommonClass.showSnackBar(message: "Please fill valid details!")
        }
    }
    
    func mApplyGiftCards(cardNumber:String){
        let mLocation = UserDefaults.standard.string(forKey: "location") ?? ""
        let urlPath =  mApplyForGiftCard
        let params = ["Giftcard_code": cardNumber, "location_id":mLocation]
        if Reachability.isConnectedToNetwork() == true {
            CommonClass.showFullLoader(view: self.view)
            AF.request(urlPath, method:.post, parameters:params, headers: sGisHeaders2).responseJSON { [self] response in
                CommonClass.stopLoader()
                if(response.error != nil){
                    CommonClass.showSnackBar(message: "OOP's something went wrong!")
                }else{
                    guard let jsonData = response.data else { return }
                    let json = try? JSONSerialization.jsonObject(with: jsonData, options: [])
                    guard let jsonResult = json as? NSDictionary else { return }
                    if jsonResult.value(forKey: "code") as? Int == 200 {
                        guard let mCreditRow = jsonResult.value(forKey: "creditNote_row") as? NSDictionary else { return }
                        var isExist = false
                        for item in mCreditNoteData {
                            if let value = item as? NSDictionary {
                                if let id = value.value(forKey: "id") , "\(id)" == "\(mCreditRow.value(forKey: "id") ?? "")"{
                                    isExist = true
                                }
                            }
                        }
                        if !isExist {
                            CommonClass.showSnackBar(message: "Gift Card Added Successfully")
                            self.mSelectedIndex = [IndexPath]()
                            let mNewData = NSMutableDictionary()
                            mNewData.setValue("\(mCreditRow.value(forKey: "amount") ?? "0.0")", forKey: "amount")
                            mNewData.setValue("\(mCreditRow.value(forKey: "type") ?? "")", forKey: "type")
                            mNewData.setValue("\(mCreditRow.value(forKey: "date") ?? "")", forKey: "date")
                            mNewData.setValue("\(mCreditRow.value(forKey: "Ref_No") ?? "")", forKey: "Ref_No")
                            mNewData.setValue("\(mCreditRow.value(forKey: "id") ?? "")", forKey: "id")
                            mNewData.setValue(
                                "\(mCreditRow["currency"] ?? "")",
                                forKey: "currency"
                            )

                            mNewData.setValue(
                                "\(mCreditRow["diff_currency"] ?? "0")",
                                forKey: "diff_currency"
                            )
                            self.mCreditNoteData.add(mNewData)
                            var mAmount = [Double]()
                            self.mAmountData = NSMutableArray()
                            for item in mCreditNoteData {
                                if let value = item as? NSDictionary {
                                    let mCData = NSMutableDictionary()
                                    mAmount.append(Double("\(value.value(forKey: "amount") ?? "0.0")") ?? 0.0)
                                    mCData.setValue("\(value.value(forKey: "amount") ?? "0.0")", forKey: "amount")
                                    self.mTotalCreditAmount.text = String(format:"%.02f",locale:Locale.current,mAmount.reduce(0, {$0 + $1}))
                                    self.mAmountData.add(mCData)
                                }
                            }
                            self.mCreditNoteTable.delegate = self
                            self.mCreditNoteTable.dataSource = self
                            self.mCreditNoteTable.reloadData()
                            self.mGetTotalAmount()
                        }else{
                            CommonClass.showSnackBar(message: "Already Added!")
                        }
                    }else {
                        CommonClass.showSnackBar(message: "Invalid Card!")
                    }
                }
            }
        }
    }
    
    @IBAction func mDeleteCreditFillAmount(_ sender: Any) {
        var text = mCreditFillAmount.text ?? ""
        if text != "" {
            text.removeLast()
            mCreditFillAmount.text = text
        }
    }
    
    @IBAction func mCloseCreditView(_ sender: Any) {
        mStopCregisPaymentPolling()
        self.mCreditCardPaymentView.isHidden = true
    }
    
    @IBAction func mSubmitCreditAmount(_ sender: UIButton) {
        print("DEBUG_SUBMIT_PAYPAL")
        print("DEBUG_TEXT =", self.mCreditFillAmount.text ?? "nil")
        print("DEBUG_DOUBLE =", Double(self.mCreditFillAmount.text ?? "") ?? -1)
//        if let balanceDue = self.mBALANCEDUE.text {
//            let formattedBalanceDue = balanceDue.replacingOccurrences(of: ",", with: "")
//            let balanceDueInDouble = Double(formattedBalanceDue) ?? 0.0
//            let inputAmount = Double(self.mCreditFillAmount.text ?? "") ?? 0.0
//
//            print("DEBUG_AMOUNT =", inputAmount)
//            print("DEBUG_PAYMENT_SLAG =", mSelectdPaymentMethod)
//
//            if inputAmount <= balanceDueInDouble {
//                self.mGetStripeDataBackEnd()
//            } else {
//                CommonClass.showSnackBar(message: "Please fill a valid amount!")
//            }
//        }
        guard let balanceDue = self.mBALANCEDUE.text else {
                return
            }

            let formattedBalanceDue =
                balanceDue.replacingOccurrences(of: ",", with: "")

            let balanceDueInDouble =
                Double(formattedBalanceDue) ?? 0.0

            let inputAmount =
                Double(self.mCreditFillAmount.text ?? "") ?? 0.0
            print("INPUT =", inputAmount)
            print("BALANCE =", balanceDueInDouble)
            if inputAmount <= 0 {

                CommonClass.showSnackBar(
                    message: "Please fill valid amount!"
                )

                return
            }

            if inputAmount > balanceDueInDouble {

                CommonClass.showSnackBar(
                    message: "Please fill valid amount!"
                )

                return
            }

            if mSelectdPaymentMethod == "cregis-payment" {
                mStartCregisPayment()
                return

            } else if mSelectdPaymentMethod == "paypal-payment" {

                print("DEBUG_SUBMIT_PAYPAL")

//                mGetStripeDataBackEnd()
//                openPayPalCheckout()
                print("PayPal selected")
//                print("Waiting for PayPal backend flow")
//
//                CommonClass.showSnackBar(
//                    message: "Waiting for PayPal integration."
//                )
                mGetPaypalDataBackEnd()

                    return

            } else if mSelectdPaymentMethod == "stripe-payment" {

                print("DEBUG_SUBMIT_STRIPE")

                mGetStripeDataBackEnd()

            }
    }
    
    func mAddCredit(cardNumber:String, cardExp:String, cardCvc:String, amount:String){
        CommonClass.showFullLoader(view: self.view)
        let urlPath =  mCreditCardAdd
        let params = ["card_no": cardNumber, "card_cvc":cardCvc,"exp_month":cardExp,"card_holderName":UserDefaults.standard.string(forKey: "CUSTOMERID") ?? "" ,"method_id":mCreditCardPaymentId,"salesPerson_val": UserDefaults.standard.string(forKey: "SALESPERSONID") ?? "" ,"amount":amount]
        if Reachability.isConnectedToNetwork() == true {
            AF.request(urlPath, method:.post, parameters:params, headers: sGisHeaders2).responseJSON { [self] response in
                CommonClass.stopLoader()
                guard let jsonData = response.data, let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? NSDictionary else { return }
                if json.value(forKey: "code") as? Int == 200 {
                    if let mData = json.value(forKey: "data") as? NSDictionary {
                        let mId = "\(mData.value(forKey: "insert_id") ?? "")"
                        let mCreditCardOptions = NSMutableDictionary()
                        mCreditCardOptions.setValue(self.mCreditCardPaymentId, forKey: "cardPaymentId")
                        mCreditCardOptions.setValue(amount, forKey: "amount")
                        mCreditCardOptions.setValue(mId, forKey: "id")
                        self.mCreditCardMethod.add(mCreditCardOptions)
                        var mAmount = [Double]()
                        for i in self.mCreditCardMethod {
                            if let mAM = i as? NSDictionary, let amt = mAM.value(forKey: "amount"), let dAmt = Double("\(amt)") {
                                mAmount.append(dAmt)
                            }
                        }
                        self.mSubmittedCreditCard.text = "\( mAmount.reduce(0, {$0 + $1}))"
                        recheckBalanceDue()
                    }
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mPaymentData.count
    }
    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        guard let cells = collectionView.dequeueReusableCell(withReuseIdentifier: "Collect",for:indexPath) as? Collect,
//              let mData = mPaymentData[indexPath.row] as? NSDictionary else { return UICollectionViewCell() }
//        cells.mImage.downlaodImageFromUrl(urlString: "\(mData.value(forKey: "PayMethod_logo") ?? "")")
//        cells.mName.text = mData.value(forKey: "name") as? String ?? ""
//        if mStripeIndex == indexPath.row {
//            mCreditCardPaymentId = "\(mData.value(forKey: "id") ?? "")"
//            mCreditCardName = "\(mData.value(forKey: "name") ?? "")"
//            mCreditCardLogo = "\(mData.value(forKey: "PayMethod_logo") ?? "")"
//            cells.mView.borderColor = UIColor(named: "themeColor")
//            cells.mView.borderWidth = 1
//            cells.mView.layer.cornerRadius = 10
//        }else {
//            cells.mView.borderWidth = 0
//            cells.mView.layer.cornerRadius = 10
//        }
//        return cells
//    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath)
    -> UICollectionViewCell {

        guard let cells = collectionView.dequeueReusableCell(
            withReuseIdentifier: "Collect",
            for: indexPath
        ) as? Collect,
        let mData = mPaymentData[indexPath.row] as? NSDictionary
        else {
            return UICollectionViewCell()
        }

        let slug = "\(mData.value(forKey: "payment_slag") ?? "")"

//        if slug == "stripe-payment" {
//
//            cells.mName.text = "Debit or Credit Card"
//
//        } else if slug == "paypal-payment" {
//
//            cells.mName.text = "PayPal"
//
//        } else {
//
//            cells.mName.text =
//                "\(mData.value(forKey: "name") ?? "")"
//        }
        if slug == "stripe-payment" {

            cells.mName.text = "Debit or Credit Card"

        } else if slug == "paypal-payment" {

            let env = "\(mData["environment"] ?? "")".lowercased()

            if env == "sandbox" {

                cells.mName.text = "PayPal Sandbox"

            } else {

                cells.mName.text = "PayPal"

            }

        } else {

            cells.mName.text =
                "\(mData["name"] ?? "")"

        }

        cells.mImage.downlaodImageFromUrl(
            urlString: "\(mData.value(forKey: "PayMethod_logo") ?? "")"
        )

        return cells
    }
     
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else { return CGSize.zero }
        layout.minimumLineSpacing = 16
        return CGSize(width: (collectionView.frame.width / 2) - 16, height: (collectionView.frame.height / 2) - 16)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        mStripeIndex = indexPath.row
        if let mData = mPaymentData[indexPath.row] as? NSDictionary {
            print(mData,"check payment data ")
            
            let env = "\(mData["environment"] ?? "")".lowercased()
            print("Selected PayPal Environment =", env)
            mCreditFillAmount.text = "\(Double(self.mCartTotalAmount) ?? 0)"
            
            mCreditFillAmount.text = "\(Double(self.mCartTotalAmount) ?? 0)"
            
            let slug = "\(mData["payment_slag"] ?? "")"
            
            if slug == "paypal-payment" {
                
                let env = "\(mData["environment"] ?? "")".lowercased()
                
                if env == "sandbox" {
                    self.selectPayment(data: self.mPaypalSandboxData)
                } else {
                    self.selectPayment(data: self.mPaypalLiveData)
                }
                
            } else {
                
                // Stripe และ Payment อื่น ๆ ใช้ตัวที่ผู้ใช้เลือก
                self.selectPayment(data: mData)
            }
            
            self.mCreditCardBanksView.isHidden = true
            self.mStripeCardView.isHidden = false
        }
//        if let mData = mPaymentData[indexPath.row] as? NSDictionary {
//            print("DEBUG_CELL =", mData)
//            mCreditCardPaymentId = "\(mData.value(forKey: "id") ?? "")"
//            mCreditCardName = "\(mData.value(forKey: "name") ?? "")"
//            mCreditCardLogo = "\(mData.value(forKey: "PayMethod_logo") ?? "")"
//            mPaymentID = "\(mData.value(forKey: "id") ?? "")"
//            mPaymentMethod = "\(mData.value(forKey: "PaymentMethod") ?? "")"
//            mStripPublishKey = "\(mData.value(forKey: "key") ?? "")"
//
//            mPaypalClientID =
//                "\(mData["key"] ?? "")"
//
//            mPaypalEnvironment =
//                "\(mData["environment"] ?? "live")"
//                    .lowercased()
//
//            print("PAYPAL CLIENT =", mPaypalClientID)
//            print("PAYPAL ENV =", mPaypalEnvironment)
//
//            print("DEBUG_SELECTED_ROW =", indexPath.row)
//            print("DEBUG_SELECTED_NAME =", mData.value(forKey: "name") ?? "")
//            print("DEBUG_SELECTED_SLAG =", mData.value(forKey: "payment_slag") ?? "")
//
//            mSelectdPaymentMethod = "\(mData.value(forKey: "payment_slag") ?? "")"
//            self.mCreditBankImage.downlaodImageFromUrl(urlString: "\(mData.value(forKey: "PayMethod_logo") ?? "")")
//            self.mCreditBankName.text = mData.value(forKey: "name") as? String
//            mCardNumber.text = ""
//            mCardName.text = ""
//            mCreditFillAmount.text = ""
//            self.mStripeCardView.isHidden = false
//            print("DEBUG_STRIPE_FRAME =", self.mStripeCardView.frame)
//            print("DEBUG_STRIPE_BOUNDS =", self.mStripeCardView.bounds)
//            self.mCreditCardBanksView.isHidden = true
////            if mSelectdPaymentMethod == "stripe-payment" || mSelectdPaymentMethod == "paypal-payment" {
////                self.mCardNumberContainer.isHidden = true
////                self.mCardNameContainer.isHidden = true
////                setupPaypalView()
////            }else {
////                self.mCardNumberContainer.isHidden = false
////                self.mCardNameContainer.isHidden = false
////            }
////            if mSelectdPaymentMethod == "stripe-payment" {
////
////                self.mCreditBankName.text = "Debit or Credit Card"
////
////            } else if mSelectdPaymentMethod == "paypal-payment" {
////
////                self.mCreditBankName.text = "PayPal"
////
////            } else {
////
////                self.mCreditBankName.text =
////                    mData.value(forKey: "name") as? String
////            }
//
//            if mSelectdPaymentMethod == "stripe-payment" {
//
//                self.mCreditBankName.text =
//                    "Debit or Credit Card"
//
//            } else if mSelectdPaymentMethod == "paypal-payment" {
//
//                if mPaypalEnvironment == "sandbox" {
//
//                    self.mCreditBankName.text =
//                        "PayPal Sandbox"
//
//                } else {
//
//                    self.mCreditBankName.text =
//                        "PayPal"
//
//                }
//
//            } else {
//
//                self.mCreditBankName.text =
//                    mData.value(forKey: "name") as? String
//            }
//
//            mCardNumber.text = ""
//            mCardName.text = ""
//            mCreditFillAmount.text = ""
//
//            self.mCreditCardBanksView.isHidden = true
//            self.mStripeCardView.isHidden = false
//
//            self.mCardNumberContainer.isHidden = true
//            self.mCardNameContainer.isHidden = true
//
//            self.mCollectionView.reloadData()
//        }
//        print("DEBUG_PAYMENT_VIEW_HIDDEN =", mCreditCardPaymentView.isHidden)
//        print("DEBUG_STRIPE_HIDDEN =", mStripeCardView.isHidden)
//        print("DEBUG_BANK_VIEW_HIDDEN =", mCreditCardBanksView.isHidden)
//
//        print("DEBUG_CARD_CONTAINER =", mCardNumberContainer.isHidden)
//        print("DEBUG_NAME_CONTAINER =", mCardNameContainer.isHidden)
//        print("DEBUG_PAYMENT_SLAG =", mSelectdPaymentMethod)
//        print("DEBUG_STRIPE_HIDDEN =", mStripeCardView.isHidden)
//        print("DEBUG_BANK_HIDDEN =", mCreditCardBanksView.isHidden)
    }
    
    func mFetchStore(key: String){
        let mLocation = UserDefaults.standard.string(forKey: "location") ?? ""
        let urlPath =  mFetchPaymentMethod
        if Reachability.isConnectedToNetwork() == true {
            AF.request(urlPath, method:.post, parameters:["login_token": mUserLoginToken ?? "", "location_id":mLocation], headers: sGisHeaders2).responseJSON { response in
                print("DEBUG_PAYMENT_RESPONSE_DATA = ", response)
                guard let jsonData = response.data, let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? NSDictionary else { return }
                if json.value(forKey: "code") as? Int == 200 {
                    if let mPaymentMethod = json.value(forKey: "data") as? NSDictionary {
                        
                        print("mFetchStore mPaymentMethod = \(mPaymentMethod)")
                        
                        
                        
//                        if let mData = mPaymentMethod["Credit_Card"] as? NSArray,
//                           mData.count > 0 {
//
//                            self.mPaymentData = mData
//
//                        } else if let mData = mPaymentMethod["Bank"] as? NSArray,
//                                  mData.count > 0 {
//
//                            self.mPaymentData = mData
//                        }
                        
                        if let mData = mPaymentMethod["Credit_Card"] as? NSArray,
                           mData.count > 0 {

                            self.mPaymentData = mData

                        } else {

                            self.mPaymentData = []
                        }
                        
                        
                        
                        self.mCollectionView.reloadData()

                        print("DEBUG_PAYMENT_COUNT =", self.mPaymentData.count)
                        print("DEBUG_PAYMENT_DATA =", self.mPaymentData)
                        
                        for item in self.mPaymentData {

                            guard let dict = item as? NSDictionary else {
                                continue
                            }

                            let slug = "\(dict["payment_slag"] ?? "")"

                            let env = "\(dict["environment"] ?? "")".lowercased()

                            if slug == "paypal-payment" {

                                if env == "sandbox" {

                                    self.mPaypalSandboxData = dict

                                } else if env == "live" {

                                    self.mPaypalLiveData = dict

                                }

                            }

                        }

                        self.mCollectionView.delegate = self
                        self.mCollectionView.dataSource = self
                        self.mCollectionView.reloadData()
                    }
                    
//                    if let mPaymentMethod = json.value(forKey: "data") as? NSDictionary, let mData = mPaymentMethod.value(forKey: "Credit_Card") as? NSArray, mData.count > 0 {
//                        self.mPaymentData = mData
//                        print("DEBUG_PAYMENT_COUNT =", self.mPaymentData.count)
//                        print("DEBUG_PAYMENT_DATA =", self.mPaymentData)
//                        self.mCollectionView.delegate = self
//                        self.mCollectionView.dataSource = self
//                        self.mCollectionView.reloadData()
//                    }
                }
            }
        }
    }
    
    @IBAction func mDeleteChequeAmount(_ sender: Any) {
        var text = mChequeAmount.text ?? ""
        if text != "" {
            text.removeLast()
            mChequeAmount.text = text
            if text == "" {
                self.mSubmittedBankAmount.text = "0.0"
                mChequePaymentId = ""
                mChequeData = NSMutableDictionary()
                recheckBalanceDue()
            }
        }
    }
    
    @IBAction func mChooseCheqDate(_ sender: Any) {}
    
    @IBAction func mChooseBanks(_ sender: Any) {
        var mBankNames = ["Choose Bank"]
        let mBankTypeFilter = "Cheque"
        var mBankImage = ["https://art.gis247.net/assets/images/icon/camera_profile.png"]
        var mPMId = [""]
        if let mBankData = UserDefaults.standard.object(forKey: "BANKDATA") as? NSArray {
            if mBankData.count > 0 {
                for i in mBankData {
                    if let data = i as? NSDictionary {
                        if "\(data.value(forKey: "BankPaymenttype") ?? "")" == mBankTypeFilter {
                            mBankNames.append("\(data.value(forKey: "name") ?? "")")
                            mBankImage.append("\(data.value(forKey: "PayMethod_logo") ?? "")")
                            mPMId.append("\(data.value(forKey: "id") ?? "")")
                        }
                    }
                }
                let dropdown = DropDown()
                dropdown.anchorView = self.mCheqBankName
                dropdown.direction = .bottom
                dropdown.layer.cornerRadius = 15
                dropdown.backgroundColor = .white
                dropdown.bottomOffset = CGPoint(x: 0, y: 50)
                dropdown.width = self.view.frame.width - 32
                dropdown.dataSource = mBankNames
                dropdown.cellNib = UINib(nibName: "Currency", bundle: nil)
                dropdown.customCellConfiguration = { (index: Int, item: String, cell: DropDownCell) in
                    guard let cell = cell as? CurrencyCell else { return }
                    cell.mCurrencyImage.downlaodImageFromUrl(urlString: "\(mBankImage[index])")
                }
                dropdown.selectionAction = { [unowned self] (index: Int, item: String) in
                    print("DEBUG_CURRENCY =", item)

                        print("DEBUG_RATE_ARRAY =",
                              self.mExchangeRateData)

                        print("DEBUG_SELECTED_RATE =",
                              index < self.mExchangeRateData.count
                              ? self.mExchangeRateData[index]
                              : "N/A")
                    self.mChequePaymentId = mPMId[index]
                    self.mCheqBankName.text = item
                    self.mCheqBankImage.downlaodImageFromUrl(urlString: mBankImage[index])
                }
                dropdown.show()
            } else {
                CommonClass.showSnackBar(message: "Please add authorised bank!")
            }
        }
    }
    
    @IBAction func mSubmitCheque(_ sender: UIButton) {
        sender.showAnimation{}
        if mChequeAmount.text == "" || (Double(mChequeAmount.text!) ?? 0.0) == 0 {
            CommonClass.showSnackBar(message: "Please fill amount!")
        } else if mCheqDate.text == "" {
            CommonClass.showSnackBar(message: "Please choose date!")
        }else if mCheqAccountNumber.text == "" {
            CommonClass.showSnackBar(message: "Please fill account number!")
        }else if mCheqAccountName.text == "" {
            CommonClass.showSnackBar(message: "Please fill acoount holder name!")
        }else if mCheqBankName.text == "Choose Bank" {
            CommonClass.showSnackBar(message: "Please choose bank name!")
        }else if mCheqRefNumber.text == "" {
            CommonClass.showSnackBar(message: "Please fill reference number!")
        }else if mCheqInstNumber.text == "" {
            CommonClass.showSnackBar(message: "Please fill Inst number!")
        }else{
            if let balanceDue = mBALANCEDUE.text {
                let formattedBalanceDue = balanceDue.replacingOccurrences(of: ",", with: "")
                let balanceDueInDouble = Double(formattedBalanceDue) ?? 0.0
                let inputAmount = Double(mChequeAmount.text ?? "") ?? 0.0
                if (balanceDueInDouble - inputAmount) < 0 {
                    CommonClass.showSnackBar(message: "Please fill valid amount!")
                    recheckBalanceDue()
                    return
                }
            }
            mChequeData = NSMutableDictionary()
            mChequeData.setValue(mCheqDate.text ?? "", forKey: "transaction_date")
            mChequeData.setValue(mCheqAccountNumber.text ?? "", forKey: "ac_no")
            mChequeData.setValue(mCheqAccountName.text ?? "", forKey: "ac_name")
            mChequeData.setValue(mChequePaymentId, forKey: "payment_method_id")
            mChequeData.setValue(mCheqRefNumber.text ?? "", forKey: "ref_no")
            mChequeData.setValue(mCheqInstNumber.text ?? "", forKey: "inst_no")
            mChequeData.setValue(mChequeAmount.text ?? "", forKey: "amount")
            mChequeData.setValue("Bank", forKey: "Paymentmethod_type")
            self.mBankPayment.add(mChequeData)

            var mAmounts = [Double]()
            for i in mBankPayment{
                if let mData = i as? NSDictionary {
                    mAmounts.append(Double("\(mData.value(forKey: "amount") ?? "0.0")".replacingOccurrences(of: ",", with: "")) ?? 0.00)
                }
            }
            mSubmittedBankAmount.text = "\(mAmounts.reduce(0, {$0 + $1}))"
            recheckBalanceDue()
            self.mCheqDate.text = ""
            self.mCheqAccountNumber.text = ""
            self.mCheqAccountName.text = ""
            self.mChequePaymentId = ""
            mCheqBankName.text = "Choose Bank"
            self.mCheqRefNumber.text = ""
            self.mChequeAmount.text = ""
            self.mCheqInstNumber.text = ""
            CommonClass.showSnackBar(message: "Amount added successfully")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mCreditNoteData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        guard let cells = tableView.dequeueReusableCell(withIdentifier: "CreditNoteList") as? CreditNoteList else { return UITableViewCell() }
        if let mData =  mCreditNoteData[indexPath.row] as? NSDictionary {
            cells.mType.text = mData.value(forKey: "type") as? String
            cells.mRefNo.text = mData.value(forKey: "Ref_No") as? String
            cells.mDate.text = mData.value(forKey: "date") as? String
            cells.mAmount.tag = indexPath.row
            cells.mView.backgroundColor = (indexPath.row % 2 == 0) ? UIColor(named: "themeBackground") : UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
            
            if mSelectedCustomIndex.contains(indexPath) {
                if let mDataSet = mAmountData[indexPath.row] as? NSDictionary {
                    cells.mAmount.text = "\(mDataSet.value(forKey: "amount") ?? "0.0")"
                }
            }else{
                cells.mAmount.text = "\(mData.value(forKey: "amount") ?? "0.0")"
            }
            cells.mCheckImage.image = UIImage(named: mSelectedIndex.contains(indexPath) ? "check_item" : "uncheck_item" )
            cells.layoutSubviews()
        }
        return cells
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let mData = mCreditNoteData[indexPath.row] as? NSDictionary else {
            return
        }

        let diffCurrency = "\(mData["diff_currency"] ?? "0")"

        if diffCurrency == "1" {

            CommonClass.showSnackBar(
                message: "Apologies for the inconvenience!\nThis credit note is in a different currency and cannot be encashed here."
            )

            return
        }
        if mSelectedIndex.contains(indexPath) {
            mSelectedIndex = mSelectedIndex.filter {$0 != indexPath }
        }else{
            mSelectedIndex.append(indexPath)
        }
        self.mGetTotalAmount()
        self.mCreditNoteTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { return 60 }
    
    @IBAction func mAmountEdit(_ sender: UITextField) {
        if let mMaxData = mCreditNoteData[sender.tag] as? NSDictionary{
            let mMaxAmount = Double("\(mMaxData.value(forKey: "amount") ?? "0.0")") ?? 0
            if sender.text == ""  {
                mAddCreditAmount(text: "0", index: sender.tag)
                return
            }
            if Double("\(sender.text ?? "")") ?? 0 > mMaxAmount   {
                sender.text = "\(mMaxData.value(forKey: "amount") ?? "0.0")"
            }
            mAddCreditAmount(text: sender.text ?? "", index: sender.tag)
        }
    }
    
    func mAddCreditAmount(text : String , index : Int ){
        let mIndexPath = IndexPath(row:index,section: 0)
        let mData = NSMutableDictionary()
        mData.setValue(text, forKey: "amount")
        mAmountData.removeObject(at: index)
        mAmountData.insert(mData, at:  index)
        if !self.mSelectedCustomIndex.contains(mIndexPath) {
            self.mSelectedCustomIndex.append(mIndexPath)
        }
        mGetTotalAmount()
    }
    
    func mGetTotalAmount(){
        var mAmount = [Double]()
        var indexPath = IndexPath()
        mCreditData = NSMutableArray()
        mCreditDataMerged = NSMutableArray()
        mGiftCardMethod =  NSMutableArray()
        for index in 0...mAmountData.count - 1 {
            indexPath = IndexPath(row:index,section: 0)
            if mSelectedIndex.contains(indexPath){
                if let mData = mAmountData[index] as? NSDictionary {
                    mAmount.append(Double("\(mData.value(forKey: "amount") ?? "0.0")") ?? 0.0)
                    let mCData = NSMutableDictionary()
                    mCData.setValue("\(mData.value(forKey: "amount") ?? "0.0")", forKey: "amount")
                    if let mMaxData =  mCreditNoteData[index] as? NSDictionary {
                        mCData.setValue("\(mMaxData.value(forKey: "id") ?? "")", forKey: "payment_method_id")
                    }
                    mCreditData.add(mCData)
                    mCreditDataMerged.add(mCData)
                }
            }
        }
        
        mItemsSelected.text = "\(mSelectedIndex.count) " + (mSelectedIndex.count == 1 ? "Item Selected".localizedString : "Items Selected".localizedString)
        mTotalSelectedAmount.text = String(format:"%.02f",locale:Locale.current,mAmount.reduce(0, {$0 + $1}))
        self.mSubmittedCreditNote.text = mTotalSelectedAmount.text?.replacingOccurrences(of: ",", with: "")
        recheckBalanceDue()
    }
    
    @IBAction func mSubmitCredit(_ sender: Any) { mGetTotalAmount() }

    func applyLinkedCartContext(_ context: LinkedCartContext?) {
        guard let context else { return }
        linkedCartId = context.linkedCartId
        linkedOrderId = context.linkedOrderId
        existingCartStatus = context.existingCartStatus
        canCreateNewCart = context.canCreateNewCart
        linkedOrderType = context.linkedOrderType
    }

    @IBAction func mBack(_ sender: Any) {
        let alert = UIAlertController(
            title: "Leave checkout?",
            message: "Your current checkout will be cancelled.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Continue Checkout", style: .cancel))
        alert.addAction(UIAlertAction(title: "Leave", style: .destructive) { [weak self] _ in
            self?.leaveCheckout()
        })
        present(alert, animated: true)
    }

    private func leaveCheckout() {
        print("===== POSCheckoutLEAVE CHECKOUT =====")
            print("linkedCartId =", linkedCartId)
            print("linkedOrderType =", linkedOrderType)
            print("canCreateNewCart =", canCreateNewCart)
        guard !isRestoringLinkedCartStatus else { return }
        let restorableOrderTypes = ["repair", "repair_order", "reserve", "custom_order", "custom order"]
        let storedCartIDs = UserDefaults.standard.stringArray(forKey: connectedOrderRestoreCartIDsKey) ?? []
        let restoreCartIDs = Array(Set(storedCartIDs.compactMap { id -> String? in
            let value = id.trimmingCharacters(in: .whitespacesAndNewlines)
            return value.isEmpty ? nil : value
        }))
        let fallbackCartIDs = (UserDefaults.standard.stringArray(forKey: "reserve_linked_cart_ids") ?? [])
            + [UserDefaults.standard.string(forKey: "reserve_linked_cart_id") ?? "", linkedCartId]
        var seenCartIDs = Set<String>()
        let validFallbackCartIDs = fallbackCartIDs.filter {
            !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        let cartIDs = (validFallbackCartIDs.isEmpty ? restoreCartIDs : validFallbackCartIDs).compactMap { rawID -> String? in
            let id = rawID.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !id.isEmpty, seenCartIDs.insert(id).inserted else { return nil }
            return id
        }
        let restoreIsRequired = "\(UserDefaults.standard.object(forKey: "reserve_show_popup") ?? "0")" == "1"
            || !restoreCartIDs.isEmpty
            || !fallbackCartIDs.allSatisfy({ $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty })

        guard !cartIDs.isEmpty,
              restoreIsRequired,
              (canCreateNewCart == false || restorableOrderTypes.contains(linkedOrderType.lowercased())) else {
            navigationController?.popViewController(animated: true)
            return
        }

        isRestoringLinkedCartStatus = true
        CommonClass.showFullLoader(view: view)
        print("CALL restoreLinkedCartStatus")
        mGetData(
            url: mRestoreLinkedCartStatus,
            headers: sGisHeaders,
            params: ["cart_id": cartIDs]
        ) { [weak self] response, status in
            guard let self else { return }
            CommonClass.stopLoader()
            self.isRestoringLinkedCartStatus = false

            let code = response.value(forKey: "code") as? Int ?? 0
            let message = "\(response.value(forKey: "message") ?? "Unable to restore linked cart status")"
            if status, code == 200 {
                CommonClass.showSnackBar(message: message)
                UserDefaults.standard.removeObject(forKey: self.connectedOrderRestoreCartIDsKey)
                UserDefaults.standard.removeObject(forKey: "reserve_show_popup")
                UserDefaults.standard.removeObject(forKey: "reserve_linked_cart_id")
                UserDefaults.standard.removeObject(forKey: "reserve_linked_cart_ids")
                self.navigationController?.popViewController(animated: true)
            } else if code == 400,
                      message == "cart_id is required" ||
                      message == "Cart not found or previous cart status not saved" {
                CommonClass.showSnackBar(message: message)
            } else if !status {
                CommonClass.showSnackBar(message: "Unable to restore linked cart status")
            } else {
                CommonClass.showSnackBar(message: message)
            }
        }
    }
    @IBAction func mAddCustomer(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let home = storyBoard.instantiateViewController(withIdentifier: "RegisterCustomer") as? RegisterCustomer {
            self.navigationController?.pushViewController(home, animated:true)
        }
    }
    
    func setupPapalAllView() {
        mTabBarContainer.isHidden = true
        mSelectPaymentOptionContainer.isHidden = true
        guard mOrderType != "refund_order" else {
            return
        }
        mTransactionType = "CreditCard"
        mTaxInfoView.isHidden = true
        mKeyBoardView.isHidden = true
        mChequeDetailsView.isHidden = true
        mCreditCardView.isHidden = true
        mCreditNoteDetailsView.isHidden = true
        mEditCashView.isHidden = true
        self.mCreditCardPaymentView.isHidden = false
        self.mCreditCardBanksView.isHidden = false
        self.mStripeCardView.isHidden = true

        mCardView.backgroundColor = .clear
        mCashView.backgroundColor = UIColor(named: "themeShades")
        mBankView.backgroundColor = UIColor(named: "themeShades")
        mCreditNoteView.backgroundColor = UIColor(named: "themeShades")

        self.mCashLABEL.textColor = UIColor(named:"theme6A")
        self.mCreditCardLABEL.textColor = UIColor(named:"themeColor")
        self.mBankLABEL.textColor = UIColor(named:"theme6A")
        self.mCreditNoteLABEL.textColor = UIColor(named:"theme6A")
        self.mCashIcon.image = UIImage(named: "cashgrey_ic")
        self.mCreditNoteIcon.image = UIImage(named: "creditnotegrey_ic")
        self.mCreditCardIcon.image = UIImage(named: "cardGreen")
        self.mBankIcon.image = UIImage(named: "bankgrey_ic")
        self.mCreditCardIcon.showAnimation {}
        self.mCreditCardLABEL.showAnimation {}
    }
    
    @IBAction func mBackCreditCardForm(_ sender: Any) {
//        self.mCreditCardBanksView.isHidden = false
//        self.mStripeCardView.isHidden = true
//        self.mCreditCardBanksView.isHidden = false
//        self.mStripeCardView.isHidden = true
        view.endEditing(true)

        mCreditFillAmount.text = ""

//        let hasStripe = mPaymentData.contains {
//
//            guard let dict = $0 as? NSDictionary else {
//                return false
//            }
//
//            return "\(dict["payment_slag"] ?? "")"
//                == "stripe-payment"
//        }
//
//        setupPaypalView(
//            showCreditCardButton: hasStripe
//        )
        
        setupPapalAllView()
    }
    
    @IBAction func mCreditCard(_ sender: Any) {
        mPageControl.isHidden = true
        mTabBarContainer.isHidden = true
        mSelectPaymentOptionContainer.isHidden = true
        guard mOrderType != "refund_order" else {
            return
        }
        mTransactionType = "CreditCard"
        mTaxInfoView.isHidden = true
        mKeyBoardView.isHidden = true
        mChequeDetailsView.isHidden = true
        mCreditCardView.isHidden = true
        mCreditNoteDetailsView.isHidden = true
        mEditCashView.isHidden = true
        self.mCreditCardPaymentView.isHidden = false
        self.mCreditCardBanksView.isHidden = false
        self.mStripeCardView.isHidden = true
        
        mCardView.backgroundColor = .clear
        mCashView.backgroundColor = UIColor(named: "themeShades")
        mBankView.backgroundColor = UIColor(named: "themeShades")
        mCreditNoteView.backgroundColor = UIColor(named: "themeShades")
        
        self.mCashLABEL.textColor = UIColor(named:"theme6A")
        self.mCreditCardLABEL.textColor = UIColor(named:"themeColor")
        self.mBankLABEL.textColor = UIColor(named:"theme6A")
        self.mCreditNoteLABEL.textColor = UIColor(named:"theme6A")
        self.mCashIcon.image = UIImage(named: "cashgrey_ic")
        self.mCreditNoteIcon.image = UIImage(named: "creditnotegrey_ic")
        self.mCreditCardIcon.image = UIImage(named: "cardGreen")
        self.mBankIcon.image = UIImage(named: "bankgrey_ic")
        self.mCreditCardIcon.showAnimation {}
        self.mCreditCardLABEL.showAnimation {}
//        mTabBarContainer.isHidden = true
//        mSelectPaymentOptionContainer.isHidden = true
//
//        guard mOrderType != "refund_order" else { return }
//
//        mTransactionType = "CreditCard"
//        mPageControl.isHidden = true
//
//        mTaxInfoView.isHidden = true
//        mKeyBoardView.isHidden = true
//        mChequeDetailsView.isHidden = true
//        mCreditCardView.isHidden = true
//        mCreditNoteDetailsView.isHidden = true
//        mEditCashView.isHidden = true
//
//        self.mCreditCardPaymentView.isHidden = false
//
//        let hasPaypal = mPaymentData.contains {
//            (($0 as? NSDictionary)?
//                .value(forKey: "payment_slag") as? String)
//                == "paypal-payment"
//        }
//
//        let hasStripe = mPaymentData.contains {
//            (($0 as? NSDictionary)?
//                .value(forKey: "payment_slag") as? String)
//                == "stripe-payment"
//        }
//
//        if hasPaypal {
//
//            mCreditCardBanksView.isHidden = true
//            mStripeCardView.isHidden = false
//
//            setupPaypalView(
//                showCreditCardButton: hasStripe
//            )
//
//        } else {
//
//            mCreditCardBanksView.isHidden = false
//            mStripeCardView.isHidden = true
//        }
//
//        mCardView.backgroundColor = .clear
//        mCashView.backgroundColor = UIColor(named: "themeShades")
//        mBankView.backgroundColor = UIColor(named: "themeShades")
//        mCreditNoteView.backgroundColor = UIColor(named: "themeShades")
//
//        mCashLABEL.textColor = UIColor(named:"theme6A")
//        mCreditCardLABEL.textColor = UIColor(named:"themeColor")
//        mBankLABEL.textColor = UIColor(named:"theme6A")
//        mCreditNoteLABEL.textColor = UIColor(named:"theme6A")
    }
    
    @IBAction func mCash(_ sender: Any) {
        mTabBarContainer.isHidden = true
        mSelectPaymentOptionContainer.isHidden = true
        mTransactionType = "Cash"
        refreshCashPage()
        mChequeDetailsView.isHidden = true
        mTaxInfoView.isHidden = true
        mKeyBoardView.isHidden = false
        mCreditCardView.isHidden = true
        mEditCashView.isHidden = false
        mCreditNoteDetailsView.isHidden = true
        self.mCreditCardPaymentView.isHidden = true
        mCashView.backgroundColor = .clear
        mCardView.backgroundColor = UIColor(named: "themeShades")
        mBankView.backgroundColor = UIColor(named: "themeShades")
        mCreditNoteView.backgroundColor = UIColor(named: "themeShades")
        self.mCashLABEL.textColor = UIColor(named:"themeColor")
        self.mCreditCardLABEL.textColor = UIColor(named:"theme6A")
        self.mBankLABEL.textColor = UIColor(named:"theme6A")
        self.mCreditNoteLABEL.textColor = UIColor(named:"theme6A")
        self.mCashIcon.image = UIImage(named: "cashGreen")
        self.mCreditNoteIcon.image = UIImage(named: "creditnotegrey_ic")
        self.mCreditCardIcon.image = UIImage(named: "card_grey_ic")
        self.mBankIcon.image = UIImage(named: "bankgrey_ic")
        self.mCashIcon.showAnimation {}
        self.mCashLABEL.showAnimation {}
    }
    
    @IBAction func mBank(_ sender: Any) {
        mChequeDetailsView.isHidden = true
        if let ibs = mIBSelect { ibs.isSelected = true }
        if let chs = mChequeSelect { chs.isSelected = false }
        mTabBarContainer.isHidden = false
        mSelectPaymentOptionContainer.isHidden = false
        mIBTabSelect?.backgroundColor = UIColor(named: "themeColor")
        mChequeTabSelect?.backgroundColor = UIColor(named: "themeExtraLightText")
        mTransactionType = "Bank"
        mPageControl.isHidden = true
        mChequeDetailsView.isHidden = true
        mCreditNoteDetailsView.isHidden = true
        mTaxInfoView.isHidden = true
        mKeyBoardView.isHidden = true
        mCreditCardView.isHidden = true
        mEditCashView.isHidden = true
        self.mCreditCardPaymentView.isHidden = true
        mBankView.backgroundColor = .clear
        mCardView.backgroundColor = UIColor(named: "themeShades")
        mCashView.backgroundColor = UIColor(named: "themeShades")
        mCreditNoteView.backgroundColor = UIColor(named: "themeShades")
        self.mCashLABEL.textColor = UIColor(named:"theme6A")
        self.mCreditCardLABEL.textColor = UIColor(named:"theme6A")
        self.mBankLABEL.textColor = UIColor(named:"themeColor")
        self.mCreditNoteLABEL.textColor = UIColor(named:"theme6A")
        self.mCashIcon.image = UIImage(named: "cashgrey_ic")
        self.mCreditNoteIcon.image = UIImage(named: "creditnotegrey_ic")
        self.mCreditCardIcon.image = UIImage(named: "card_grey_ic")
        self.mBankIcon.image = UIImage(named: "bankGreen")
        self.mBankIcon.showAnimation {}
        self.mBankLABEL.showAnimation {}
    }
    
    @IBAction func mCreditNot(_ sender: Any) {
        mTabBarContainer.isHidden = true
        mSelectPaymentOptionContainer.isHidden = true
        guard mOrderType != "refund_order" else { return }
        mTransactionType = "CreditNote"
        mPageControl.isHidden = true
        mCreditNoteDetailsView.isHidden = false
        mTaxInfoView.isHidden = true
        mChequeDetailsView.isHidden = true
        mKeyBoardView.isHidden = true
        mCreditCardView.isHidden = true
        mEditCashView.isHidden = true
        self.mCreditCardPaymentView.isHidden = true
        mCreditNoteView.backgroundColor = .clear
        mCardView.backgroundColor = UIColor(named: "themeShades")
        mCashView.backgroundColor = UIColor(named: "themeShades")
        mBankView.backgroundColor = UIColor(named: "themeShades")
        self.mCashLABEL.textColor = UIColor(named:"theme6A")
        self.mCreditCardLABEL.textColor = UIColor(named:"theme6A")
        self.mBankLABEL.textColor = UIColor(named:"theme6A")
        self.mCreditNoteLABEL.textColor = UIColor(named:"themeColor")
        self.mCashIcon.image = UIImage(named: "cashgrey_ic")
        self.mCreditNoteIcon.image = UIImage(named: "creditNoteGreen")
        self.mCreditCardIcon.image = UIImage(named: "card_grey_ic")
        self.mBankIcon.image = UIImage(named: "bankgrey_ic")
        self.mCreditNoteIcon.showAnimation {}
        self.mCreditNoteLABEL.showAnimation {}
    }
    
    @IBAction func mTax(_ sender: Any) {
        mTaxInfoView.isHidden = false
        mKeyBoardView.isHidden = true
        mCreditCardView.isHidden = true
        mEditCashView.isHidden = true
        mChequeDetailsView.isHidden = true
        mCreditNoteDetailsView.isHidden = true
        mCardView.layer.sublayers?.remove(at: 0)
        mCashView.layer.sublayers?.remove(at: 0)
        mBankView.layer.sublayers?.remove(at: 0)
        mCreditNoteView.layer.sublayers?.remove(at: 0)
    }
    
    @IBAction func mPressOne(_ sender: UIButton) { sender.showAnimation{}; mInsertAmount(num:"1") }
    @IBAction func mPressTwo(_ sender: UIButton) { sender.showAnimation{}; mInsertAmount(num:"2") }
    @IBAction func mPressThree(_ sender: UIButton) { sender.showAnimation{}; mInsertAmount(num:"3") }
    @IBAction func mPressFour(_ sender: UIButton) { sender.showAnimation{}; mInsertAmount(num:"4") }
    @IBAction func mPressFive(_ sender:UIButton) { sender.showAnimation{}; mInsertAmount(num:"5") }
    @IBAction func mPressSix(_ sender: UIButton) { sender.showAnimation{}; mInsertAmount(num:"6") }
    @IBAction func mPressSeven(_ sender: UIButton) { sender.showAnimation{}; mInsertAmount(num:"7") }
    @IBAction func mPressEight(_ sender: UIButton) { sender.showAnimation{}; mInsertAmount(num:"8") }
    @IBAction func mPressNine(_ sender: UIButton) { sender.showAnimation{}; mInsertAmount(num:"9") }
    @IBAction func mPressSingleZero(_ sender: UIButton) { sender.showAnimation{}; mInsertAmount(num:"0") }
    @IBAction func mPressDoubleZero(_ sender: UIButton) { sender.showAnimation{}; mInsertAmount(num:"00") }
    @IBAction func mPressDot(_ sender:UIButton) { sender.showAnimation{}; if mCashAmounts != "" { mInsertAmount(num:".") } }
    
    @IBAction func mSub(_ sender: Any) {
        mSUBLABEL.showAnimation{}
        guard mTransactionType == "Cash" else { return }
        guard mCashPages.indices.contains(mCurrentCashPage) else { return }

        if mCashPages[mCurrentCashPage].isSubmitted {
            CommonClass.showSnackBar(message: "Amount already added!")
            return
        }

        let enteredAmount = Double(mCashAmounts) ?? 0
        guard enteredAmount > 0 else {
            CommonClass.showSnackBar(message: "Please fill valid amount!")
            return
        }

        // Customer input is in the selected currency.
        // Only the converted STORE-currency amount is deducted from Balance Due.
        syncCurrentCashPageFromInput()
        let convertedAmount = mCashPages[mCurrentCashPage].amount
        guard convertedAmount > 0 else {
            CommonClass.showSnackBar(message: "Please fill valid amount!")
            return
        }

        let balance = checkoutAmount(mBALANCEDUE.text)

        print("========== CASH SUB DEBUG ==========")
        print("Store Currency =", mStoreCurrency)
        print("Selected Currency =", mCurrencyName.text ?? "")
        print("Input Amount =", enteredAmount)
        print("Exchange Rate =", mExchangeRateValue.text ?? "")
        print("Converted Amount (Store Currency) =", convertedAmount)
        print("Balance Due (Store Currency) =", balance)
        print("====================================")

        guard convertedAmount <= balance + 0.000001 else {
            CommonClass.showSnackBar(message: "Please fill valid amount!")
            return
        }

        mCashPages[mCurrentCashPage].isSubmitted = true
        mSubmittedCash.text = String(format: "%.2f", totalSubmittedCash()).formatPrice()
        recheckBalanceDue()

        let remainingBalance = checkoutAmount(mBALANCEDUE.text)
        if remainingBalance > 0 {
            let nextCurrency = mCurrencyName.text ?? mStoreCurrency
            let nextRate = nextCurrency == mStoreCurrency
                ? 1
                : (Double(mExchangeRateValue.text ?? "") ?? 0)

            mCashPages.append(
                CashPaymentPage(
                    amount: 0,
                    enteredAmount: 0,
                    currency: nextCurrency,
                    exchangeRate: nextRate,
                    isSubmitted: false
                )
            )
            mCurrentCashPage = mCashPages.count - 1

            UIView.animate(withDuration: 0.15, animations: {
                self.mPageControl.currentPage = self.mCurrentCashPage
                self.mPageControl.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            }) { _ in
                UIView.animate(withDuration: 0.15) {
                    self.mPageControl.transform = .identity
                }
            }

            mCashAmount.text = ""
            mCashAmounts = ""
            mConvertedAmounts = "0"
            mConvertedAmount.text = ""
            mPageControl.isHidden = false
            refreshCashPage()
        }

        CommonClass.showSnackBar(message: "Amount Added Successfully!")
    }
    
    @IBAction func mShowTaxView(_ sender: Any) {}
    @IBAction func mCashAmountField(_ sender: Any) {}
    
    @IBAction func mChooseCurrency(_ sender: Any) {
        let dropdown = DropDown()
        dropdown.anchorView = self.mChooseCurrencyButt
        dropdown.direction = .bottom
        dropdown.bottomOffset = CGPoint(x: 0, y: 50)
        dropdown.width = 200
        dropdown.dataSource = self.mCurrencyNameData
        dropdown.cellNib = UINib(nibName: "Currency", bundle: nil)

        dropdown.customCellConfiguration = {
            (index: Index, item: String, cell: DropDownCell) -> Void in
            guard let cell = cell as? CurrencyCell else { return }
            guard index < self.mCurrencyImageData.count else { return }
            cell.mCurrencyImage.downlaodImageFromUrl(
                urlString: self.mCurrencyImageData[index]
            )
        }

        dropdown.selectionAction = { [unowned self] (index: Int, item: String) in
            guard self.mCashPages.indices.contains(self.mCurrentCashPage) else { return }

            if self.mCashPages[self.mCurrentCashPage].isSubmitted {
                CommonClass.showSnackBar(
                    message: "Please use the new payment page for another currency."
                )
                return
            }

            self.mCurrencyName.text = item
            self.mSelectedStoreCurrency = item

            if index < self.mCurrencyImageData.count {
                self.mCashCurrencyImage.downlaodImageFromUrl(
                    urlString: self.mCurrencyImageData[index]
                )
            }

            if item == self.mStoreCurrency {
                self.mExchangeRateLabel.isHidden = true
                self.mExchangeRateValue.isHidden = true
                self.mExchangeRateValue.text = ""
            } else {
                self.mExchangeRateLabel.isHidden = false
                self.mExchangeRateValue.isHidden = false

                guard index < self.mExchangeRateData.count else {
                    self.mExchangeRateValue.text = ""
                    self.syncCurrentCashPageFromInput()
                    return
                }

                // Use the backend rate directly.
                // Example: THB rate 0.03 -> 10,000 THB = 300 USD.
                self.mExchangeRateValue.text = self.mExchangeRateData[index]
            }

            self.syncCurrentCashPageFromInput()
        }

        dropdown.show()
    }
    
    @IBAction func mExchangeRate(_ sender: UITextField!) {
        guard mTransactionType == "Cash" else { return }
        // Backend rate is used directly: converted STORE amount = entered amount × rate.
        syncCurrentCashPageFromInput()
    }
    
    private func recheckBalanceDue() {
        let totalAmount = checkoutAmount(mTOTALAMOUNT.text)
        let submittedCash = totalSubmittedCash()
        let submittedCreditNote = checkoutAmount(mSubmittedCreditNote.text)
        let submittedBankAmount = checkoutAmount(mSubmittedBankAmount.text)
        let submittedCreditCard = checkoutAmount(mSubmittedCreditCard.text)

        let balance = max(
            0,
            totalAmount
                - submittedCash
                - submittedCreditNote
                - submittedBankAmount
                - submittedCreditCard
        )

        self.mBALANCEDUE.text = "\(balance)".formatPrice()

        print("========== Multiple Payment ==========")
        print("Total =", totalAmount)
        print("Cash (Store Currency) =", submittedCash)
        print("Bank =", submittedBankAmount)
        print("Credit Card =", submittedCreditCard)
        print("Credit Note =", submittedCreditNote)
        print("Balance =", balance)
        print("======================================")
    }
    
    @IBAction func mClear(_ sender: UIButton) {
        sender.showAnimation{}
        guard mCashPages.indices.contains(mCurrentCashPage) else { return }
        guard !mCashPages[mCurrentCashPage].isSubmitted else {
            CommonClass.showSnackBar(message: "Submitted amount cannot be cleared.")
            return
        }

        mCashAmount.text = ""
        mConvertedAmount.text = ""
        mConvertedAmounts = "0"
        mCashAmounts = ""
        mCashPages[mCurrentCashPage].enteredAmount = 0
        mCashPages[mCurrentCashPage].amount = 0

        mSubmittedCash.text = String(format: "%.2f", totalSubmittedCash()).formatPrice()
        recheckBalanceDue()
    }
    
    @IBAction func mDeleteCashAmount(_ sender: Any) {
        guard mCashPages.indices.contains(mCurrentCashPage) else { return }
        guard !mCashPages[mCurrentCashPage].isSubmitted else {
            CommonClass.showSnackBar(message: "Submitted amount cannot be edited.")
            return
        }
        guard !mCashAmounts.isEmpty else { return }

        mCashAmounts.removeLast()
        mCashAmount.text = mCashAmounts
        syncCurrentCashPageFromInput()

        if mCashAmounts.isEmpty {
            mConvertedAmounts = "0"
            mConvertedAmount.text = ""
        }

        mSubmittedCash.text = String(format: "%.2f", totalSubmittedCash()).formatPrice()
        recheckBalanceDue()
    }
    
//    func mInsertAmount(num : String){
//        mCashAmounts.insert(contentsOf: num, at: mCashAmounts.endIndex)
//        if mCashAmounts.filter({$0 == "."}).count > 1 {
//            mCashAmounts.removeLast()
//            return
//        }
//        mCashAmount.text! = mCashAmounts
//        if mTransactionType == "Cash" {
//            if mExchangeRateLabel.isHidden == false {
//                if mExchangeRateValue.text != "" {
//                    let mVal = Double(mExchangeRateValue.text ?? "") ?? 0.0
//                    if mCashAmount.text != "" && mCashAmount.text != "."  {
//                        let cashAmount = Double(mCashAmounts) ?? 0
//                        mConvertedAmounts = "\(cashAmount * mVal)"
//                        let mDecimalAmount = ((Double(mConvertedAmounts) ?? 0) * 100).rounded() / 100
//                        print("DEBUG_STORE_CURRENCY =", mStoreCurrency)
//
//                        print("DEBUG_SELECTED_CURRENCY =",
//                              mCurrencyName.text ?? "")
//
//                        print("DEBUG_RATE =",
//                              mExchangeRateValue.text ?? "")
//
//                        print("DEBUG_CASH_AMOUNT =",
//                              mCashAmounts)
//
//                        print("DEBUG_CONVERTED =",
//                              mConvertedAmounts)
//                        mConvertedAmount.text = "=  \(self.mCurrencyName.text ?? "") \(mDecimalAmount)"
//                    }
//                }
//            }else{
//                if mCashAmount.text != "" && mCashAmount.text != "."  {
//                    mConvertedAmounts = "\(Double(mCashAmounts) ?? 0)"
//                    let mDecimalAmount = ((Double(mConvertedAmounts) ?? 0) * 100).rounded() / 100
//                    print("DEBUG_STORE_CURRENCY =", mStoreCurrency)
//
//                    print("DEBUG_SELECTED_CURRENCY =",
//                          mCurrencyName.text ?? "")
//
//                    print("DEBUG_RATE =",
//                          mExchangeRateValue.text ?? "")
//
//                    print("DEBUG_CASH_AMOUNT =",
//                          mCashAmounts)
//
//                    print("DEBUG_CONVERTED =",
//                          mConvertedAmounts)
//                    mConvertedAmount.text = "= \(self.mCurrencyName.text ?? "") \(mDecimalAmount)"
//                }
//            }
//        }
//    }
    
    func mInsertAmount(num: String) {
        guard mCashPages.indices.contains(mCurrentCashPage) else { return }
        guard !mCashPages[mCurrentCashPage].isSubmitted else { return }

        mCashAmounts.insert(contentsOf: num, at: mCashAmounts.endIndex)
        if mCashAmounts.filter({ $0 == "." }).count > 1 {
            mCashAmounts.removeLast()
            return
        }

        mCashAmount.text = mCashAmounts

        if mTransactionType == "Cash" {
            syncCurrentCashPageFromInput()
        }
    }

    @IBAction func mStartSearch(_ sender: Any) {}
    @IBAction func mEndSearch(_ sender: Any) {}
    @IBAction func mEditChanged(_ sender: Any) {
        let value  = mCustomerSearch.text?.count ?? 0
        if value == 0 && mCustomerSearch.text == "" {
            mCustomerSearchTableView.removeFromSuperview()
            self.view.endEditing(true)
        }
    }
    @IBAction func mValueChanged(_ sender: UITextField!) {}
    @IBAction func mEditCustSearch(_ sender: Any) {}
    
    @IBAction func mLabourAmount(_ sender: UITextField) {
        if sender.text == "" { sender.text = "0" }
        calculateTax()
    }
    @IBAction func mShippingAmount(_ sender: UITextField) {
        if sender.text == "" { sender.text = "0" }
        calculateTax()
    }
    @IBAction func mDiscountPercent(_ sender: UITextField) {
        var mCount = Int()
        if sender.text == "" { mCount = 0 } else { mCount = Int(Double(sender.text ?? "") ?? 0) }
        if sender.text! == "" || sender.text == "0"  || mCount > 100 {
            sender.text = "0"
            self.mDiscountAmounts.text = "0"
            calculateTax()
        }else {
            self.mDiscountAmounts.text = "\(calculatePercentage(value: (Double(mTotalAm) ?? 0), percent: Double(sender.text ?? "") ?? 0 ))"
            calculateTax()
        }
    }
    
    @IBAction func mDiscountAmount(_ sender: UITextField) {
        if sender.text == "" {
            sender.text = "0"
            self.mDiscountPercents.text = "0"
            calculateTax()
        }else{
            let mPercent = (Double(sender.text ?? "") ?? 0) / (Double(mTotalAm) ?? 0 * 100)
            self.mDiscountPercents.text = String(format: "%.2f", mPercent)
            calculateTax()
        }
    }
    
    func calculatePercentage(value:Double,percent: Double) -> Double {
        return (value * percent)/100.00
    }
    func calculateInclusiveTax(value:Double,percent: Double) -> Double {
        return (value * percent)/(100.00 + (Double(mTaxP) ?? 0))
    }
    func calculateExclusiveTax(value:Double,percent: Double) -> Double {
        return (value * percent)/100.00
    }
    
    func calculateTax(){
        var mAmount = Double()
        let mDiscountA = Double(self.mDiscountAmounts.text ?? "") ?? 0
        let mLabour = Double(self.mLabourCharge.text ?? "") ?? 0
        let mShipping = Double(self.mShippingCharge.text ?? "") ?? 0
        mAmount = mLabour + mShipping
        
        if mTaxType.lowercased() == "inclusive" {
            mTotalDiscountTx.text = mDiscountAmounts.text
            mTotalTx.text = "\((mAmount + (Double(mTotalAm) ?? 0) ))"
            let totalTx = Double(mTotalTx.text ?? "0.0") ?? 0.0
            let discountAmounts = Double(mDiscountAmounts.text ?? "0.0") ?? 0.0
            let taxPercent = Double(mTaxP) ?? 0.0
            let taxAmount = calculateInclusiveTax(value: totalTx - discountAmounts, percent: taxPercent)
            mTaxAmountTx.text = String(format: "%.02f", locale: Locale.current, taxAmount)
            let taxAmountTx = Double(mTaxAmountTx.text?.replacingOccurrences(of: ",", with: "") ?? "0.0") ?? 0.0
            let subTotal = totalTx - discountAmounts - taxAmountTx
            mSubTotalTx.text = String(format: "%.02f", locale: Locale.current, subTotal)
            mFinalTaxAmount.text = mTaxAmountTx.text
            mTOTALAMOUNT.text = "\((mAmount + (Double(mTotalAm) ?? 0) - mDiscountA))"
            recheckBalanceDue()
        }else{
            mTotalDiscountTx.text = mDiscountAmounts.text
            mTotalTx.text = "\((mAmount + (Double(mTotalAm) ?? 0 )) )"
            let totalTx = Double(mTotalTx.text ?? "0.0") ?? 0.0
            let discountAmounts = Double(mDiscountAmounts.text ?? "0.0") ?? 0.0
            let taxPercent = Double(mTaxP) ?? 0.0
            mTaxAmountTx.text = String(format: "%.02f", locale: Locale.current, calculateExclusiveTax(value: totalTx - discountAmounts, percent: taxPercent))
            mSubTotalTx.text = String(format:"%.02f",locale:Locale.current,totalTx - discountAmounts)
            mFinalTaxAmount.text = mTaxAmountTx.text
            let subTotal = Double(mSubTotalTx.text?.replacingOccurrences(of: ",", with: "") ?? "0.0") ?? 0.0
            let taxAmount = Double(mTaxAmountTx.text?.replacingOccurrences(of: ",", with: "") ?? "0.0") ?? 0.0
            mTOTALAMOUNT.text = "\(subTotal + taxAmount)"
            recheckBalanceDue()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) { _ = textField.text }
    
    func mFetchCreditNoteData(value: String){
        _ = UserDefaults.standard.string(forKey: "location")
        let urlPath = mPOSCreditNote
        let params = ["customer_id":mCustomerId]
        if Reachability.isConnectedToNetwork() == true {
            AF.request(urlPath, method:.post, parameters:params, encoding: JSONEncoding.default, headers: sGisHeaders).responseJSON { response in
                if(response.error != nil){
                    CommonClass.showSnackBar(message: "OOP's something went wrong!")
                }else{
                    guard let jsonData = response.data, let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? NSDictionary else {
                        CommonClass.showSnackBar(message: "OOP's something went wrong!")
                        return
                    }
                    if json.value(forKey: "code") as? Int == 200 {
                        self.mCreditNoteData = NSMutableArray()
                        self.mSelectedCustomIndex = [IndexPath]()
                        self.mSelectedIndex = [IndexPath]()
                        self.mAmountData = NSMutableArray()
                        self.mItemsSelected.text = "0 " + "Item Selected".localizedString
                        self.mTotalCreditAmount.text = ""
                        if let mData = json.value(forKey: "data") as? NSArray {
                            self.mCreditNoteData = NSMutableArray(array: mData)
                            self.mCreditNoteTable.delegate = self
                            self.mCreditNoteTable.dataSource = self
                            self.mCreditNoteTable.reloadData()
                            var mAmount = [Double]()
                            for item in mData {
                                if let value = item as? NSDictionary {
                                    let mCData = NSMutableDictionary()
                                    mAmount.append(Double("\(value.value(forKey: "amount") ?? "0")") ?? 0.0)
                                    mCData.setValue("\(value.value(forKey: "amount") ?? "0")", forKey: "amount")
                                    self.mTotalCreditAmount.text = String(format:"%.02f",locale:Locale.current,mAmount.reduce(0, {$0 + $1}))
                                    self.mAmountData.add(mCData)
                                }
                            }
                        }
                    } else{
                        if let error = json.value(forKey: "error") as? String {
                            if error == "Authorization has been expired" {
                                CommonClass.sessionExpired(isExpired: true, navigation: self.navigationController)
                            } else {
                                CommonClass.showSnackBar(message: error)
                            }
                        }
                        if let message = json.value(forKey: "message") as? String {
                            CommonClass.showSnackBar(message: message)
                        }
                    }
                }
            }
        }else{
            CommonClass.showSnackBar(message: "No Internet Connection")
        }
    }
    
    func mFinalPay(urlPath : String , params: [String:Any]){
        if Reachability.isConnectedToNetwork() == true {
            AF.request(urlPath, method:.post, parameters:params, encoding :JSONEncoding.default, headers: sGisHeaders).responseJSON { response in
                if(response.error != nil){
                    CommonClass.showSnackBar(message: "OOP's something went wrong!")
                }else{
                    guard let jsonData = response.data, let jsonResult = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? NSDictionary else {
                        CommonClass.showSnackBar(message: "OOP's something went wrong!")
                        return
                    }
                    if jsonResult.value(forKey: "code") as? Int == 200 {
                        UserDefaults.standard.setValue("\(jsonResult.value(forKey: "pdf_url") ?? "")", forKey: "reportAPI")
                        self.mGenerateReport(id:"\(jsonResult.value(forKey: "pdf_url") ?? "")" , jsonResult : jsonResult)
                    }else{
                        if let error = jsonResult.value(forKey: "error"){
                            if "\(error)" == "Authorization has been expired" {
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
    
    func mGenerateReport(id : String, jsonResult : NSDictionary){
        CommonClass.showFullLoader(view: self.view)
        let urlPath = id
        if Reachability.isConnectedToNetwork() == true {
            AF.request(urlPath, method:.post, parameters:nil, headers: sGisHeaders2).responseJSON { response in
                CommonClass.stopLoader()
                if(response.error != nil){
                    CommonClass.showSnackBar(message: "OOP's something went wrong!")
                }else{
                    guard let jsonData = response.data, let jsonVal = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? NSDictionary else {
                        CommonClass.showSnackBar(message: "OOP's something went wrong!")
                        return
                    }
                    
                    print("====================================")
                    print("🔥 GENERATE REPORT ORDER TYPE =", self.mOrderType)
                    print("🔥 ORIGINAL RESULT =", jsonResult)
                    print("🔥 REPORT RESPONSE =", jsonVal)
                    print("====================================")
                    
                    UserDefaults.standard.set("", forKey: "CUSTOMERID")
                    UserDefaults.standard.set("", forKey: "SALESPERSONID")
                    UserDefaults.standard.removeObject(forKey: "sales_person_id")
                    UserDefaults.standard.removeObject(forKey: "SALESPERSONNAME")
                    UserDefaults.standard.removeObject(forKey: "sales_person_name")
                    UserDefaults.standard.removeObject(forKey: "SALESPERSON_IMAGE")
                    CommonClass.showSnackBar(message: "Payment Successful")
                    if let email = jsonVal.value(forKey: "email") {
                        UserDefaults.standard.setValue("\(email)", forKey: "mailInvoice")
                    }
                    UserDefaults.standard.setValue("\(jsonVal.value(forKey: "pdf_url") ?? "")", forKey: "report")
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    if let mCompletePayment = storyBoard.instantiateViewController(withIdentifier: "CompletePayment") as? CompletePayment {
                        if self.mOrderType == "Sales Order" { mCompletePayment.mType = "pos_order"}//"pos" }
                        if self.mOrderType == "Custom Order" { mCompletePayment.mType = "custom_order"//"custom"
                        }
                        if self.mOrderType == "Repair Order" { mCompletePayment.mType = "repair_order"//"repair"
                        }
                        mCompletePayment.mDue = "\(jsonResult.value(forKey: "DueAmt") ?? "")"
                        mCompletePayment.mTotal = "\(jsonResult.value(forKey: "totalAmt") ?? "")"
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
    
    func mSetupTableView(frame: CGRect) {
        if mCustomerSearch.text != "" {
            let nib = UINib(nibName: "CustomerSearchList", bundle: nil)
            _ = nib.instantiate(withOwner: self, options: nil)[0] as? UIView
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
    }
    
    func mGetCurrency(){
        let urlPath = mGetCurrencies
        if Reachability.isConnectedToNetwork() == true {
            AF.request(urlPath, method:.post, parameters:nil, headers: sGisHeaders2).responseJSON { response in
                if(response.error != nil){
                    CommonClass.showSnackBar(message: "OOP's something went wrong!")
                }else{
                    guard let jsonData = response.data, let jsonResult = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? NSDictionary else { return }
                    if let data = jsonResult.value(forKey: "data") as? NSArray, data.count > 0 {
                        for i in data {
                            if let currency = i as? NSDictionary {
                                self.mCurrencyNameData.append("\(currency.value(forKey:"currency") ?? "")")
                                self.mCurrencyImageData.append("\(currency.value(forKey:"url") ?? "")")
                                self.mExchangeRateData.append("\(currency.value(forKey:"rate") ?? "")")
                                if "\(currency.value(forKey:"currency") ?? "")" == self.mStoreCurrency {
                                    self.mCashCurrencyImage.downlaodImageFromUrl(urlString: "\(currency.value(forKey:"url") ?? "")")
                                    self.mCurrencyName.text = self.mStoreCurrency
                                    self.mSelectedStoreCurrency = self.mStoreCurrency
                                    if self.mOrderType == "Sales Order" {
                                        self.mTOTALAMOUNT.text = self.mFTOTAL.formatPrice()
                                        self.mBALANCEDUE.text = self.mFTOTAL.formatPrice()
                                    }else{
                                        self.mTOTALAMOUNT.text = self.mTotalP.formatPrice()
                                        self.mBALANCEDUE.text = self.mTotalP.formatPrice()
                                    }
                                }
                            }
                        }
                        self.mTOTALAMOUNT.text = self.mTotalP.formatPrice()
                        self.mBALANCEDUE.text = self.mTotalP.formatPrice()
                    }
                }
            }
        }else{
            CommonClass.showSnackBar(message: "No Internet Connection")
        }
    }
    
    // MARK: Customer Address List
    private func getCustomerAddressList(){
        guard Reachability.isConnectedToNetwork() == true else { return }
        let params = ["customer_id": mCustomerId] as [String : Any]
        let urlPath = mGetCustomerAddressList
        AF.request(urlPath, method:.post,parameters: params,encoding: JSONEncoding.default, headers: sGisHeaders).responseJSON { response in
            guard let jsonData = response.data else { return }
            do {
                guard let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
                      let code = json["code"] as? Int else { return }
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
    
    // MARK: Generate QR Code
    func mGenerateQRCode() {
        let urlPath = mGetQRCode
        let mParams: [String: Any] = [
            "payment_id": mChequePaymentId,
            "amount": mEnterQRAmount?.text ?? "0",
            "customerId": mCustomerId
        ]
        if Reachability.isConnectedToNetwork() {
            AF.request(urlPath, method: .post, parameters: mParams, headers: sGisHeaders2).responseJSON { response in
                switch response.result {
                case .success(let value):
                    guard let json = value as? [String: Any] else { return }
                    if let code = json["code"] as? Int, code == 200, let data = json["data"] as? [String: Any] {
                        self.mClientReferenceID = data["client_reference_id"] as? String ?? ""
                        if let qrCodeString = data["qrCode"] as? String,
                           let base64String = qrCodeString.components(separatedBy: ",").last,
                           let qrCodeData = Data(base64Encoded: base64String),
                           let qrCodeImage = UIImage(data: qrCodeData) {
                            DispatchQueue.main.async {
                                self.qrCodeView.removeFromSuperview()
                                self.qrCodeView.delegate = self
                                self.qrCodeView.mQRImage.image = qrCodeImage
                                self.view.addSubview(self.qrCodeView)
                                self.qrCodeView.startTimer()
                                self.mGetPayementStatus()
                            }
                        }
                    } else {
                        let message = json["message"] as? String ?? "Oops, something went wrong!"
                        CommonClass.showSnackBar(message: message)
                    }
                case .failure(let error):
                    CommonClass.showSnackBar(message: error.localizedDescription)
                }
            }
        }
    }
    
    func authenticationPresentingViewController() -> UIViewController { return self }
    
    func StripePayment() {
        StripeManager.shared.configureStripe(publishableKey: mStripPublishKey)
        StripeManager.shared.fetchPaymentIntentDetails(clientSecret: self.mClientSecreat)
        var configuration = PaymentSheet.Configuration()
        let paymentSheet = PaymentSheet(paymentIntentClientSecret: mClientSecreat, configuration: configuration)
        paymentSheet.present(from: self) { paymentResult in
            DispatchQueue.main.async {
                switch paymentResult {
                case .completed:
                    if let paymentSuccessView = PaymentSuccessView.loadFromNib() {
                        paymentSuccessView.frame = self.view.bounds
                        paymentSuccessView.setAmount("Amount: \(self.mCreditFillAmount.text ?? "")")
                        if let successImage = UIImage(named: "successAmount") { paymentSuccessView.setImage(successImage) }
                        self.view.addSubview(paymentSuccessView)
                    }
                    self.mStripeCardView.isHidden = true
                    self.mCreditCardBanksView.isHidden = false
                    CommonClass.showSnackBar(message: "Amount added successfully")
                    
                    let mCreditCardData = NSMutableDictionary()
                    mCreditCardData.setValue(self.mCreditCardName, forKey: "name")
                    mCreditCardData.setValue(self.mCardNumber.text ?? "", forKey: "card_number")
                    mCreditCardData.setValue(self.mCardName.text ?? "", forKey: "card_name")
                    mCreditCardData.setValue(self.mCreditCardPaymentId, forKey: "payment_method_id")
                    mCreditCardData.setValue(self.mCreditCardLogo, forKey: "logo")
                    mCreditCardData.setValue(self.mCreditFillAmount.text ?? "", forKey: "amount")
                    mCreditCardData.setValue("Credit_Card", forKey: "Paymentmethod_type")
                    mCreditCardData.setValue(self.mClientReferenceID, forKey: "client_reference_id")
                    self.mCreditCardMethod.add(mCreditCardData)
                    
                    var mAmounts = [Double]()
                    for i in self.mCreditCardMethod {
                        if let mData = i as? NSDictionary {
                            mAmounts.append(Double("\(mData.value(forKey: "amount") ?? "0.0")".replacingOccurrences(of: ",", with: "")) ?? 0.00)
                        }
                    }
                    self.mSubmittedCreditCard.text = "\(mAmounts.reduce(0, {$0 + $1}))"
                    self.recheckBalanceDue()
                    
                    self.mCreditCardLogo = ""
                    self.mCreditCardName = ""
                    self.mCreditCardPaymentId = ""
                    self.mCardNumber.text = ""
                    self.mCardName.text = ""
                    self.mCreditFillAmount.text = ""
                    
                case .failed(_):
                    if let paymentSuccessView = PaymentSuccessView.loadFromNib() {
                        paymentSuccessView.frame = self.view.bounds
                        paymentSuccessView.mSetAmountStatus("Payment Failed")
                        if let successImage = UIImage(named: "AmountFailed") { paymentSuccessView.setImage(successImage) }
                        self.view.addSubview(paymentSuccessView)
                    }
                    StripeManager.shared.fetchPaymentIntentDetails(clientSecret: self.mClientSecreat)
                case .canceled:
                    if let paymentSuccessView = PaymentSuccessView.loadFromNib() {
                        paymentSuccessView.frame = self.view.bounds
                        paymentSuccessView.mSetAmountStatus("Payment Failed")
                        if let successImage = UIImage(named: "AmountFailed") { paymentSuccessView.setImage(successImage) }
                        self.view.addSubview(paymentSuccessView)
                    }
                }
            }
        }
    }
    
//    func didTapCancelQRCode() { mCancelQRCode() }
    
    func mCancelQRCode() {
        let urlPath = mCancelQR
        let mParams: [String: Any] = ["client_reference_id": mClientReferenceID]
        guard Reachability.isConnectedToNetwork() else { return }
        AF.request(urlPath, method: .post, parameters: mParams, headers: sGisHeaders2).responseJSON { response in
            switch response.result {
            case .success:
                guard let jsonData = response.data, let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else { return }
                if let code = json["code"] as? Int, code == 200 {
                    self.isQRCodeDeleted = true
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func mGetStripeDataBackEnd() {
        print("DEBUG_GET_STRIPE_CALLED")
        print("DEBUG_PAYMENT_SLAG =", mSelectdPaymentMethod)
        guard let creditFillAmountText = self.mCreditFillAmount.text, !creditFillAmountText.isEmpty, let creditFillAmount = Double(creditFillAmountText), creditFillAmount != 0 else {
            CommonClass.showSnackBar(message: "Please fill valid amount")
            return
        }
        let urlPath = mGetStipData
        let mParams: [String: Any] = [
            "amount":self.mCreditFillAmount.text ?? 0,
            "slug": self.mSelectdPaymentMethod,
            "PaymentMethod": mPaymentMethod,
            "customer_id": mCustomerId
        ]
        guard Reachability.isConnectedToNetwork() else { return }
        print("DEBUG_URL =", urlPath)
        print("DEBUG_HEADERS =", sGisHeaders2)
        print("DEBUG_PUBLISH_KEY =", mStripPublishKey)
        print("DEBUG_PARAMS =", mParams)
        AF.request(urlPath, method: .post, parameters: mParams, headers: sGisHeaders2).responseJSON { response in
            switch response.result {
            case .success:
                print("DEBUG_STRIPE_response.data =", response.data)
                guard let jsonData = response.data, let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else { return }
                print("DEBUG_STRIPE_RESPONSE =", json)
                if let code = json["code"] as? Int, code != 200 {

                    let message = json["message"] as? String ?? "Payment failed"

                    CommonClass.showSnackBar(message: message)

                    print("DEBUG_PAYMENT_ERROR =", json)

                    return
                }
                else if let code = json["code"] as? Int, code == 200 {
                    
                    if let data = json["data"] as? [String: Any],
                       let clientSecret = data["clientSecret"] as? String,
                       let clientRefID = data["client_reference_id"] as? String,
                       let paymentIntentId = data["payment_intent_id"] as? String {
                        self.mClientSecreat = clientSecret
                        self.mPaymentIntentID = paymentIntentId
                        self.mClientReferenceID = clientRefID
                        if let balanceDue = self.mBALANCEDUE.text {
                            let formattedBalanceDue = balanceDue.replacingOccurrences(of: ",", with: "")
                            let balanceDueInDouble = Double(formattedBalanceDue) ?? 0.0
                            let inputAmount = Double(self.mCreditFillAmount.text ?? "") ?? 0.0
                            if inputAmount <= balanceDueInDouble {
                                self.StripePayment()
                            } else {
                                CommonClass.showSnackBar(message: "Please fill a valid amount!")
                            }
                        }
                    }
                }
            case .failure(_):
                CommonClass.showSnackBar(message: "OOP's something went wrong!")
            }
        }
    }

    // MARK: Cregis payment
    // Cregis creates an external checkout session.  Keep its polling separate from
    // the bank QR flow so a pending Cregis payment can never create a local payment.
    private func mStartCregisPayment() {
        guard let text = mCreditFillAmount.text,
              let amount = Double(text.replacingOccurrences(of: ",", with: "")),
              amount > 0,
              !mPaymentMethod.isEmpty else {
            CommonClass.showSnackBar(message: "Please fill valid payment details")
            return
        }
        guard Reachability.isConnectedToNetwork() else {
            CommonClass.showSnackBar(message: "Please check your internet connection")
            return
        }

        mStopCregisPaymentPolling()
        let params: [String: Any] = [
            "payment_id": mPaymentMethod,
            "amount": amount,
            "customerId": mCustomerId,
            "payment_slag": "cregis-payment"
        ]

        print("========== CREGIS REQUEST ==========")
        print("URL =", mGenerateCregisQRCode)
        print("PARAMS =", params)
        CommonClass.showFullLoader(view: view)
        AF.request(mGenerateCregisQRCode,
                   method: .post,
                   parameters: params,
                   encoding: JSONEncoding.default,
                   headers: sGisHeaders2).responseJSON { [weak self] response in
            guard let self = self else { return }
            CommonClass.stopLoader()

            print("========== CREGIS GENERATE RESPONSE ==========")
            print("HTTP STATUS =", response.response?.statusCode ?? 0)
            print("RESULT =", response.result)
            print("BODY =", response.value ?? "<empty>")
            print("===============================================")

            guard case .success(let value) = response.result,
                  let json = value as? [String: Any],
                  json["code"] as? Int == 200,
                  let data = json["data"] as? [String: Any] else {
                let message = (response.value as? [String: Any])?["message"] as? String ?? "Unable to start Cregis payment"
                CommonClass.showSnackBar(message: message)
                return
            }

            let transactionID = data["client_reference_id"] as? String ?? ""
            let orderID = (data["cregis_id"] as? String) ?? (data["charges_id"] as? String) ?? ""
            guard !transactionID.isEmpty, !orderID.isEmpty else {
                CommonClass.showSnackBar(message: "Invalid Cregis payment session")
                return
            }

            self.cregisTransactionID = transactionID
            self.cregisOrderID = orderID
            self.cregisGenerateResponseData = data
            self.cregisOrderResponseData = [:]
            self.cregisPaidResponseData = [:]
            self.mOpenCregisCheckout(data)
            self.mBeginCregisPaymentPolling()
        }
    }

    private func mOpenCregisCheckout(_ data: [String: Any]) {
        let urlString = ["checkout_url", "open_url", "sessionUrl", "approvalLink"]
            .compactMap { data[$0] as? String }
            .first { !$0.isEmpty }

        guard let urlString = urlString, let url = URL(string: urlString) else {
            CommonClass.showSnackBar(message: "Cregis checkout URL is unavailable")
            return
        }
        DispatchQueue.main.async {
            let paymentWebView = CregisPaymentWebViewController(url: url)
            let navigation = UINavigationController(rootViewController: paymentWebView)
            navigation.modalPresentationStyle = .fullScreen
            self.present(navigation, animated: true)
        }
    }

    private func mBeginCregisPaymentPolling() {
        mStopCregisPaymentPolling()
        isCregisPaymentPolling = true
        mPollCregisPaymentStatus()
    }

    private func mPollCregisPaymentStatus() {
        guard isCregisPaymentPolling, !cregisTransactionID.isEmpty, !cregisOrderID.isEmpty else { return }
        let params: [String: Any] = [
            "transactionId": cregisTransactionID,
            "payment_slag": "cregis-payment",
            "cregis_id": cregisOrderID
        ]

        print("========== CREGIS STATUS REQUEST ==========")
        print("URL =", mGetPaymentStatus)
        print("PARAMS =", params)

        AF.request(mGetPaymentStatus,
                   method: .post,
                   parameters: params,
                   encoding: JSONEncoding.default,
                   headers: sGisHeaders2).responseJSON { [weak self] response in
            guard let self = self, self.isCregisPaymentPolling else { return }
            print("========== CREGIS STATUS RESPONSE ==========")
            print("HTTP STATUS =", response.response?.statusCode ?? 0)
            print("RESULT =", response.result)
            print("BODY =", response.value ?? "<empty>")
            print("=============================================")
            if self.mCregisResponseIsPaid(response.value) {
                if let json = response.value as? [String: Any],
                   let data = json["data"] as? [String: Any] {
                    self.cregisPaidResponseData = data
                }
                self.mCompleteCregisPayment()
            } else {
                self.mQueryCregisOrder()
            }
        }
    }

    private func mQueryCregisOrder() {
        guard isCregisPaymentPolling else { return }
        let params: [String: Any] = [
            "transactionId": cregisTransactionID,
            "payment_slag": "cregis-payment",
            "cregis_id": cregisOrderID
        ]

        print("========== CREGIS QUERY REQUEST ==========")
        print("URL =", mCregisQueryOrder)
        print("PARAMS =", params)

        AF.request(mCregisQueryOrder,
                   method: .post,
                   parameters: params,
                   encoding: JSONEncoding.default,
                   headers: sGisHeaders2).responseJSON { [weak self] response in
            guard let self = self, self.isCregisPaymentPolling else { return }
            print("========== CREGIS QUERY RESPONSE ==========")
            print("HTTP STATUS =", response.response?.statusCode ?? 0)
            print("RESULT =", response.result)
            print("BODY =", response.value ?? "<empty>")
            print("============================================")
            if let json = response.value as? [String: Any],
               let data = json["data"] as? [String: Any] {
                self.cregisOrderResponseData = data
            }
            if self.mCregisResponseIsPaid(response.value) {
                if let json = response.value as? [String: Any],
                   let data = json["data"] as? [String: Any] {
                    self.cregisPaidResponseData = data
                }
                self.mCompleteCregisPayment()
            } else {
                self.mScheduleNextCregisPoll()
            }
        }
    }

    private func mCregisResponseIsPaid(_ value: Any?) -> Bool {
        guard let json = value as? [String: Any],
              json["code"] as? Int == 200,
              let data = json["data"] as? [String: Any] else { return false }
        let status = ((data["payment_status"] as? String) ?? (data["status"] as? String) ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        if ["paid", "completed", "succeeded", "success"].contains(status) { return true }
        return (data["payment_success"] as? Bool == true)
            || (data["is_paid"] as? Bool == true)
            || (data["can_complete_sale"] as? Bool == true)
    }

    private func mScheduleNextCregisPoll() {
        cregisPollingWorkItem?.cancel()
        let work = DispatchWorkItem { [weak self] in self?.mPollCregisPaymentStatus() }
        cregisPollingWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: work)
    }

    private func mStopCregisPaymentPolling() {
        isCregisPaymentPolling = false
        cregisPollingWorkItem?.cancel()
        cregisPollingWorkItem = nil
    }

    /// Cregis can return the payment details under nested `data`, `order`, or
    /// `charge` objects. Search the complete response so the completed sale
    /// always carries the selected cryptocurrency and network metadata.
    private func mCregisStringValue(_ keys: [String], from dictionary: [String: Any]) -> String {
        for key in keys {
            if let value = dictionary[key] {
                let text = "\(value)".trimmingCharacters(in: .whitespacesAndNewlines)
                if !text.isEmpty, text != "<null>" { return text }
            }
        }
        for value in dictionary.values {
            if let nested = value as? [String: Any] {
                let text = mCregisStringValue(keys, from: nested)
                if !text.isEmpty { return text }
            } else if let nestedArray = value as? [[String: Any]] {
                for nested in nestedArray {
                    let text = mCregisStringValue(keys, from: nested)
                    if !text.isEmpty { return text }
                }
            }
        }
        return ""
    }

    private func mCregisSelectedPaymentInfo(from dictionary: [String: Any]) -> [String: Any] {
        let paymentInfo = (dictionary["payment_info"] as? [[String: Any]])
            ?? (dictionary["payment_info"] as? [NSDictionary])?.map { $0 as? [String: Any] ?? [:] }
            ?? []
        return paymentInfo.first {
            let currency = "\($0["receive_currency"] ?? $0["token_symbol"] ?? "")".uppercased()
            let chain = "\($0["blockchain"] ?? "")".uppercased()
            return currency == "USDT" && chain.contains("TRON")
        } ?? paymentInfo.first ?? [:]
    }

    private func mCompleteCregisPayment() {
        guard isCregisPaymentPolling else { return }
        mStopCregisPaymentPolling()

        print("========== CREGIS PAYMENT CONFIRMED ==========")
        print("TRANSACTION ID =", cregisTransactionID)
        print("CREGIS ORDER ID =", cregisOrderID)
        print("GENERATE DATA =", cregisGenerateResponseData)
        print("PAID DATA =", cregisPaidResponseData)
        print("================================================")

        let amountText = mCreditFillAmount.text ?? ""
        let amountValue = Double(amountText.replacingOccurrences(of: ",", with: "")) ?? 0

        // Build a merged dictionary: payment method config → generateQR response → paid response
        // Later sources override earlier ones so the most specific data wins.
        var merged: [String: Any] = [:]
        if let methodData = mSelectedPaypalMethodData as? [String: Any] {
            merged.merge(methodData) { _, new in new }
        }
        merged.merge(cregisGenerateResponseData) { _, new in new }
        merged.merge(cregisOrderResponseData) { _, new in new }
        merged.merge(cregisPaidResponseData) { _, new in new }
        merged.merge(mCregisSelectedPaymentInfo(from: merged)) { _, new in new }

        let logo = "\(merged["PayMethod_logo"] ?? merged["logo"] ?? "")"
        let paymentMethodRef = mPaymentMethod
        let cryptoCurrency = mCregisStringValue(["cryptoCurrency", "cryptocurrency", "crypto_currency", "currency", "coin"], from: merged)
        let blockchain = mCregisStringValue(["blockchain", "chain"], from: merged)
        let tokenName = mCregisStringValue(["token_name", "token", "coin_name"], from: merged)
        let networkValue = mCregisStringValue(["network", "network_name"], from: merged)
        let network = networkValue.isEmpty && blockchain == "TRON#Shasta" && tokenName.contains("TRC20#Shasta")
            ? "TRON#Shasta (TRC20#Shasta)"
            : networkValue
        let receiveCurrency = mCregisStringValue(["receive_currency", "settlement_currency", "currency"], from: merged)
        let receiveAmount = mCregisStringValue(["receive_amount", "settlement_amount", "crypto_amount"], from: merged).isEmpty
            ? amountText
            : mCregisStringValue(["receive_amount", "settlement_amount", "crypto_amount"], from: merged)

        let payment = NSMutableDictionary()
        payment.setValue("Cregis", forKey: "name")
        payment.setValue(logo, forKey: "logo")
        payment.setValue("", forKey: "card_name")
        payment.setValue("", forKey: "card_number")
        payment.setValue(mCreditCardPaymentId, forKey: "payment_method_id")
        payment.setValue(amountValue, forKey: "amount")
        payment.setValue("Credit_Card", forKey: "Paymentmethod_type")
        payment.setValue("cregis-payment", forKey: "payment_slag")
        payment.setValue(paymentMethodRef, forKey: "PaymentMethod")
        payment.setValue(cregisOrderID, forKey: "client_reference_id")
        payment.setValue(cregisOrderID, forKey: "transID")
        payment.setValue(cregisOrderID, forKey: "cregis_id")
        payment.setValue(true, forKey: "payment")
        payment.setValue(cryptoCurrency, forKey: "cryptoCurrency")
        payment.setValue(cryptoCurrency, forKey: "cryptocurrency")
        payment.setValue(cryptoCurrency, forKey: "crypto_currency")
        payment.setValue(network, forKey: "network")
        payment.setValue(blockchain, forKey: "blockchain")
        payment.setValue(tokenName, forKey: "token_name")
        payment.setValue(receiveCurrency, forKey: "receive_currency")
        payment.setValue(receiveAmount, forKey: "receive_amount")

        print("========== CREGIS PAYMENT DICT ==========")
        print(payment)
        print("==========================================")

        mCreditCardMethod.add(payment)

        var amounts = [Double]()
        for item in mCreditCardMethod {
            if let data = item as? NSDictionary {
                amounts.append(Double("\(data.value(forKey: "amount") ?? "0")".replacingOccurrences(of: ",", with: "")) ?? 0)
            }
        }
        mSubmittedCreditCard.text = "\(amounts.reduce(0, +))"
        recheckBalanceDue()
        mCreditCardPaymentView.isHidden = true
        mCreditFillAmount.text = ""
        CommonClass.showSnackBar(message: "Cregis payment successful")
    }

    deinit {
        mStopCregisPaymentPolling()
    }
    
    func mGetPayementStatus() {
        guard !isQRCodeDeleted else { return }
        let urlPath = mGetPaymentStatus
        let mParams: [String: Any] = ["transactionId": self.mClientReferenceID]
        guard Reachability.isConnectedToNetwork() else { return }
        
        AF.request(urlPath, method: .post, parameters: mParams, headers: sGisHeaders2).responseJSON { response in
            switch response.result {
            case .success:
                guard let jsonData = response.data, let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else { return }
                if let code = json["code"] as? Int, code == 200, let data = json["data"] as? [String: Any] {
                    let paymentStatus = data["payment_status"] as? String ?? "pending"
                    let paymentSuccess = data["payment_success"] as? Int ?? 0
                    let normalizedStatus = paymentStatus.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                    
                    if normalizedStatus == "pending" || paymentSuccess == 0 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { self.mGetPayementStatus() }
                    } else if normalizedStatus == "completed" || normalizedStatus == "succeeded" || paymentSuccess == 1 {
                        if let paymentSuccessView = PaymentSuccessView.loadFromNib() {
                            paymentSuccessView.frame = self.view.bounds
                            paymentSuccessView.setAmount("Amount: \(self.mEnterQRAmount?.text ?? "")")
                            if let successImage = UIImage(named: "successAmount") { paymentSuccessView.setImage(successImage) }
                            self.view.addSubview(paymentSuccessView)
                        }
                        self.qrCodeView.isHidden = true
                        
                        self.mChequeData = NSMutableDictionary()
                        self.mChequeData.setValue(self.mCheqDate.text ?? "", forKey: "transaction_date")
                        self.mChequeData.setValue(self.mCheqAccountNumber.text ?? "", forKey: "ac_no")
                        self.mChequeData.setValue(self.mCheqAccountName.text ?? "", forKey: "ac_name")
                        self.mChequeData.setValue(self.mChequePaymentId, forKey: "payment_method_id")
                        self.mChequeData.setValue(self.mCheqRefNumber.text ?? "", forKey: "ref_no")
                        self.mChequeData.setValue(self.mCheqInstNumber.text ?? "", forKey: "inst_no")
                        self.mChequeData.setValue(self.mEnterQRAmount?.text ?? "", forKey: "amount")
                        self.mChequeData.setValue(self.mClientReferenceID, forKey: "client_reference_id")
                        self.mChequeData.setValue("Bank", forKey: "Paymentmethod_type")
                        self.mBankPayment.add(self.mChequeData)
                        
                        var mAmounts = [Double]()
                        for i in self.mBankPayment {
                            let mData = i as? NSDictionary
                            mAmounts.append(Double("\(mData?.value(forKey: "amount") ?? "0.0")".replacingOccurrences(of: ",", with: "")) ?? 0.00)
                        }
                        self.mSubmittedBankAmount.text = "\(mAmounts.reduce(0, {$0 + $1}))"
                        self.recheckBalanceDue()
                        
                        self.mCheqDate.text = ""
                        self.mCheqAccountNumber.text = ""
                        self.mCheqAccountName.text = ""
                        self.mChequePaymentId = ""
                        self.mCheqBankName.text = "Choose Bank"
                        self.mCheqRefNumber.text = ""
                        self.mEnterQRAmount?.text = ""
                        self.mCheqInstNumber.text = ""
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) { self.mGetPayementStatus() }
                    }
                }
            case .failure(_): break
            }
        }
    }
}

final class CregisPaymentWebViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    private let checkoutURL: URL
    private lazy var webView: WKWebView = {
        let configuration = WKWebViewConfiguration()
        let view = WKWebView(frame: .zero, configuration: configuration)
        view.navigationDelegate = self
        view.uiDelegate = self
        view.allowsBackForwardNavigationGestures = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    init(url: URL) {
        checkoutURL = url
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Cregis Payment"
        view.backgroundColor = .systemBackground
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closePayment)
        )
        view.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        webView.load(URLRequest(url: checkoutURL))
    }

    @objc private func closePayment() {
        dismiss(animated: true)
    }

    // Cregis can use target="_blank" during checkout. Keep those pages in the
    // same in-app WebView rather than handing them to Safari.
    func webView(_ webView: WKWebView,
                 createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction,
                 windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil, let url = navigationAction.request.url {
            webView.load(URLRequest(url: url))
        }
        return nil
    }
}
