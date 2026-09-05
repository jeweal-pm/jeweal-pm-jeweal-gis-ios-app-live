//
//  CustomOrderCheckout.swift
//  GIS
//
//  Created by MacBook Hawkscode  on 03/02/23.
//  Copyright © 2023 Hawkscode. All rights reserved.
//

import UIKit
import Alamofire
import DropDown
import Stripe
import StripePaymentSheet
import CorePayments
import PayPalWebPayments
import SwiftUI


let mConfirmationPopUp = UINib(nibName:"confirmation",bundle:.main).instantiate(withOwner: nil, options: nil).first as? ConfirmationPopUp ?? ConfirmationPopUp()

protocol ProceedToPay {
    func isProceed(status:Bool)
    func isProceedWithStatus(status:Bool, message : String)
}

class ConfirmationPopUp: UIView {
    
    var mType = ""
    var mCustomerId = ""
    var mCartId = ""
    var index = Int()
    var delegate:ProceedToPay? = nil
    @IBOutlet weak var mMessage: UILabel!
    @IBOutlet weak var mConfirmButton: UIButton!
    @IBOutlet weak var mCancelButton: UIButton!
    
    var mNavigation = UINavigationController()
    static func instantiate(message: String) -> ConfirmationPopUp {
        let view: ConfirmationPopUp = initFromNib()
        return view
    }
    
    @IBAction func mCancel(_ sender: Any) {
        self.removeFromSuperview()
        
    }
    
    @IBAction func mConfirm(_ sender: Any) {
        self.removeFromSuperview()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.delegate?.isProceed(status: true)
            
        }
        
    }
    
}

class CustomOrderCheckout: UIViewController, UITextFieldDelegate , UITableViewDelegate ,UITableViewDataSource , UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout ,GetVerification , ProceedToPay, UIViewControllerTransitioningDelegate, QRCodeViewDelegate,STPAuthenticationContext {
    
    
    
    func isProceedWithStatus(status: Bool, message: String) {}
    
    // Tab bar for select option -:
    
    private var paymentSheet: PaymentSheet?
    @IBOutlet weak var mIBLabel: UILabel!
    @IBOutlet weak var mChequeLabel: UILabel!
    
    @IBOutlet weak var mSelectedTabIB: UILabel!
    
    @IBOutlet weak var mSelectedTabCheque: UILabel!
    
    @IBOutlet weak var mIBSelect: UIButton!
    
    @IBOutlet weak var mChequeSelect: UIButton!
    
    @IBOutlet weak var mTabBarContainer: UIView!
    
    @IBOutlet weak var mSelectPaymentOptionContainer: UIView!
    
    
    @IBOutlet weak var mEnterAmountText: UITextField!
    
    @IBOutlet weak var mSelectIBBankImage: UIImageView!
    
    @IBOutlet weak var mSelectIBBank: UITextField!
    
    let qrCodeView = QRCodeView.loadFromNib()
    
    //Icons and Text
    
    @IBOutlet weak var mCashIcon: UIImageView!
    @IBOutlet weak var mCreditNoteIcon: UIImageView!
    @IBOutlet weak var mBankIcon: UIImageView!
    @IBOutlet weak var mCreditCardIcon: UIImageView!
    
    //CreditNote
    @IBOutlet weak var mCreditNoteDetailsView: UIView!
    @IBOutlet weak var mTotalCreditAmount: UILabel!
    
    @IBOutlet weak var mItemsSelected: UILabel!
    @IBOutlet weak var mTotalSelectedAmount: UILabel!
    
    @IBOutlet weak var mCreditNoteTable: UITableView!
    @IBOutlet weak var mSubmitCreditNote: UIButton!
    var mCreditNoteData = NSMutableArray()
    var mSelectedIndex = [IndexPath]()
    
    //CashView
    var mCurrencyImageData = [String]()
    var mCurrencyNameData = [String]()
    var mCashAmounts = ""
    var mSelectedStoreCurrency = ""
    var mStoreCurrency = ""
    var isQRCodeDeleted = false

    struct PaymentPage {
        // amount = amount that is actually deducted from the order total (STORE currency)
        var amount: Double
        // enteredAmount = amount typed by customer in the selected currency
        var enteredAmount: Double
        var paymentType: String
        var paymentData: NSDictionary?
        var currency: String
        var exchangeRate: Double
        var isSubmitted: Bool
    }

    var mPages:[PaymentPage] = [
        PaymentPage(
            amount: 0,
            enteredAmount: 0,
            paymentType: "Cash",
            paymentData: nil,
            currency: "",
            exchangeRate: 1,
            isSubmitted: false
        )
    ]

    var mCurrentPage = 0
    
    private let mPageControl = UIPageControl()
//    struct PaymentSplit {
//
//        var amount: Double
//
//        var paymentType: String
//
//        var paymentName: String
//
//        var paymentData: NSDictionary?
//
//    }
//
//    var mPaymentSplits:[PaymentSplit] = []
//
//    var mCurrentSplitIndex = 0
    
    @IBOutlet weak var mEditCashView: UIView!
    @IBOutlet weak var mCashCurrencyImage: UIImageView!
    
    @IBOutlet weak var mCurrencyName: UILabel!
    @IBOutlet weak var mChooseCurrencyButt: UIButton!
    
    @IBOutlet weak var mCashAmount:
    UITextField!
    
    @IBOutlet weak var mExchangeRateLabel: UILabel!
    
    @IBOutlet weak var mExchangeRateValue: UITextField!
    
    @IBOutlet weak var mConvertedAmount: UILabel!
    
    @IBOutlet weak var mCardNumberContainer: UIView!
    @IBOutlet weak var mCardNameContainer: UIStackView!
    
    var mConvertedAmounts = "0"
    
    var mExchangeRateData = [String]()
    var mClientReferenceID = ""
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
    let mCustomerSearchTableView = UITableView()
    
    @IBOutlet weak var mCustomerSearchView: UIView!
    @IBOutlet weak var mCustomerDetailView: UIView!
    @IBOutlet weak var mCustomerNames: UILabel!
    @IBOutlet weak var mCustomerAddresss: UILabel!
    @IBOutlet weak var mCustomerNumbers: UILabel!
    var mSearchCustomerData = NSArray()
    
    @IBOutlet weak var mBALANCEDUE: UILabel!
    @IBOutlet weak var mTOTALAMOUNT: UILabel!
    
    @IBOutlet weak var mSubmittedCash: UILabel!
    
    @IBOutlet weak var mSubmittedCreditCard: UILabel!
    @IBOutlet weak var mSubmittedCreditNote: UILabel!
    
    @IBOutlet weak var mCreditNotesView: UIView!
    var mTransactionType = "Cash"
    var isExchange = false
    
    var mOrderType = ""
    // Linked-cart metadata supplied by getInventoryList through ReserveCart or CustomCart.
    var linkedCartId = ""
    var linkedOrderId = ""
    var existingCartStatus = ""
    var canCreateNewCart = true
    var linkedOrderType = ""
    private var isRestoringLinkedCartStatus = false
    var mPartialPayment = ""
    var mQuantity = [Int]()
    
    var  mCreditData = NSMutableArray()
    var  mCreditDataMerged = NSMutableArray()
    var mSelectedCustomIndex = [IndexPath]()
    var mAmountData = NSMutableArray()
    
    var mCreditCardMethod = NSMutableArray()
    var mGiftCardMethod = NSMutableArray()
    var mGiftFinalTotalAmount = ""
    
    
    
    //Top
    @IBOutlet weak var mHCheckoutLABEL: UILabel!
    @IBOutlet weak var mCreditCardLABEL: UILabel!
    @IBOutlet weak var mCashLABEL: UILabel!
    @IBOutlet weak var mBankLABEL: UILabel!
    @IBOutlet weak var mCreditNoteLABEL: UILabel!
    
    
    
    @IBOutlet weak var mClearBUTTON: UIButton!
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
    
    
    var mChequePaymentId = ""
    var mChequePaymentIdNew = ""
    var paymentSlag = ""
    var mCreditCardPaymentId = ""
    var mCreditCardLogo = ""
    var mCreditCardName = ""
    var mClientSecreat = ""
    var mPaymentIntentID = ""
    var mPaymentID = ""
    var mStripPublishKey = ""
    var mPaymentMethod = ""
    var mSelectdPaymentMethod = ""
    let mDatePicker:UIDatePicker = UIDatePicker()
    var mChequeData = NSMutableDictionary()
    var mFinalPaymentMethod = [String:Any]()
    
    var mFTOTAL = ""
    
//    var mPaymentIntentID = ""
//    var mPaymentID = ""
//    var mStripPublishKey = ""
    var mPaypalClientID = ""
    var mPaypalEnvironment = "sandbox"
    
    var mPaypalSandboxData = NSDictionary()
    var mPaypalLiveData = NSDictionary()

    var mPaypalPayerID = ""
    var mPaypalOrderID = ""
    var mPaypalEncryptedPayload = ""
    
    var mSelectedPaypalMethodData: NSDictionary?
    var mPaypalTransID: String = ""

    private var payPalClient: PayPalWebCheckoutClient?
    private var payPalConfig: CoreConfig?
    
    
    
    @IBOutlet weak var mSubmitButtonCredit: UIButton!
    @IBOutlet weak var mCloseButtonCredit: UIButton!
    @IBOutlet weak var mCreditCardPaymentView: UIView!
    @IBOutlet weak var mCreditFillAmount: UITextField!
    
    var paypalHostingController: UIHostingController<PayPalCheckoutView>?
    @IBOutlet weak var mCreditCardBanksView: UIView!
    @IBOutlet weak var mStripeCardView: UIView!
    
    @IBOutlet weak var mCollectionView: UICollectionView!
    var mStripeIndex = 0
    var mPaymentData =  NSArray()
    var mBankData =  NSArray()
    
    @IBOutlet weak var mGiftCardAmount: UITextField!
    @IBOutlet weak var mApplyGiftBUTTON: UIButton!
    override func viewWillAppear(_ animated: Bool) {
        self.mCreditCardPaymentView.isHidden = true
        mVisaView.backgroundColor =  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        mApplePayView.backgroundColor = .clear
        mAliPayView.backgroundColor =   #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        mWeChatPayView.backgroundColor =  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        mVisaView.borderColor =   #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        mApplePayView.borderColor =  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        mAliPayView.borderColor =   #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        mWeChatPayView.borderColor =  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        mCreditCardLabel.textColor =  #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        mApplePayLabel.textColor =   #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        mAliPayLabel.textColor =   #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        mWeChatPayLabel.textColor =  #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        
        self.mCheqBankName.text = "Choose Bank"
        self.mCheqBankImage.downlaodImageFromUrl(urlString:  "https://art.gis247.net/assets/images/icon/camera_profile.png")
        
        
        mApplyGiftBUTTON .setTitle("APPLY".localizedString, for: .normal)
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
        mCheqSubmitBUTTON .setTitle("SUBMIT".localizedString, for: .normal)
        mSubmitButtonCredit .setTitle("SUBMIT".localizedString, for: .normal)
        mCardNumber.placeholder = "Card number".localizedString
        mCardName.placeholder = "Card name".localizedString
        mCheqAccountNoLABEL.text = "Account No.".localizedString
        mCheqAccountNameLABEL.text = "Account Name".localizedString
        mCheqRefLABEL.text = "Ref No.".localizedString
        mCheqInstLABEL.text = "Inst No.".localizedString
        
    }
    
    @IBOutlet weak var mCardNumber: UITextField!
    @IBOutlet weak var mCardName: UITextField!
    
    @IBOutlet weak var mCreditBankName: UITextField!
    @IBOutlet weak var mCreditBankImage: UIImageView!
    
    @IBOutlet weak var mTotalItemsInCart: UILabel!
    
    
    
    
    
    var mCreditCardPayment = NSMutableArray()
    var mIBPayment = NSMutableArray()
    var mBankPayment = NSMutableArray()
    var mCashPayment = NSMutableDictionary()
    var mCartTotalAmount = ""
    var mDepositPercents = "100"
    var mTotalOutstandingAm = "0.00"
    var mCurrencySymbol = "$"
    
    
    
    var mLabourPoints = 0
    var mShippingPoints = 0
    var mLoyaltyPoints = 0
    var mTaxAmount = 0
    var mTaxAmountInt = 0
    var mTaxInPercent = 0
    var mTaxDiscountAmount:Double = 0
    var mTaxDiscountPercent:Double = 0
    var mTaxTypeIE = ""
    var mOrderId = ""
    
    @IBOutlet weak var mGCurrency: UILabel!
    
    @IBOutlet weak var mBCurrency: UILabel!
    
    @IBOutlet weak var mBottomConstraint: NSLayoutConstraint!
    
    
    func removePaypalView() {

        paypalHostingController?.willMove(toParent: nil)

        paypalHostingController?.view.removeFromSuperview()

        paypalHostingController?.removeFromParent()

        paypalHostingController = nil
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

                    self.mCreditFillAmount.text =
                        "\(Double(self.mCartTotalAmount) ?? 0)"
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
                    self.mCreditFillAmount.text =
                        "\(Double(self.mCartTotalAmount) ?? 0)"
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

        mSelectdPaymentMethod =
            "\(data["payment_slag"] ?? "")"

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
    
//    func selectPayment(data: NSDictionary) {
//
//        mCreditCardPaymentId = "\(data["id"] ?? "")"
//        mCreditCardName = "\(data["name"] ?? "")"
//        mCreditCardLogo = "\(data["PayMethod_logo"] ?? "")"
//
//        mPaymentID = "\(data["id"] ?? "")"
//        mPaymentMethod = "\(data["PaymentMethod"] ?? "")"
//        mStripPublishKey = "\(data["key"] ?? "")"
//        mSelectdPaymentMethod = "\(data["payment_slag"] ?? "")"
//
//        mCreditBankName.text = mCreditCardName
//        mCreditBankImage.downlaodImageFromUrl(urlString: mCreditCardLogo)
//
//        mCollectionView.reloadData()
//    }
    
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
    
    func setupPaypalView(showCreditCardButton: Bool) {

        removePaypalView()

        let paypalView = PayPalCheckoutView(

            showCreditCardButton: showCreditCardButton,

            paypalAction: { [weak self] in

//                self?.showPaypalEnvironmentSelector()
                self?.setupPapalAllView()
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
        
//        NSLayoutConstraint.activate([
//
//            mPageControl.centerXAnchor.constraint(equalTo: mEditCashView.centerXAnchor),
//
//            mPageControl.bottomAnchor.constraint(
//                equalTo: mKeyBoardView.topAnchor,
//                constant: -12
//            )
//
//        ])

        hosting.didMove(toParent: self)

        paypalHostingController = hosting
    }
    
    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer){

        syncCurrentPageFromInput()

        switch gesture.direction {

        case .left:

            if mCurrentPage == mPages.count - 1 {

                bounce(direction: .left)
                return

            }

            mCurrentPage += 1

        case .right:

            if mCurrentPage == 0 {

                bounce(direction: .right)
                return

            }

            mCurrentPage -= 1

        default:
            return
        }

        UISelectionFeedbackGenerator().selectionChanged()

//        mPageControl.currentPage = mCurrentPage
        UIView.animate(withDuration: 0.15) {

            self.mPageControl.currentPage = self.mCurrentPage

        }

        slideToPage(direction: gesture.direction)
    }
    
//    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
//
//        // บันทึกค่าปัจจุบันก่อนเปลี่ยนหน้า
//        mPages[mCurrentPage].amount =
//            Double(mCashAmount.text ?? "") ?? 0
//
//        switch gesture.direction {
//
//        case .left:
//
//            guard mCurrentPage < mPages.count - 1 else { return }
//
//            mCurrentPage += 1
//
//        case .right:
//
//            guard mCurrentPage > 0 else { return }
//
//            mCurrentPage -= 1
//
//        default:
//            return
//        }
//
//        mPageControl.currentPage = mCurrentPage
//
////        reloadCurrentPage()
//        slideToPage(direction: gesture.direction)
//    }
    
    private func bounce(direction: UISwipeGestureRecognizer.Direction) {

        let distance: CGFloat =
            direction == .left ? -15 : 15

        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        UIView.animate(withDuration: 0.08) {

            self.mEditCashView.transform =
                CGAffineTransform(
                    translationX: distance,
                    y: 0
                )

        } completion: { _ in

            UIView.animate(withDuration: 0.16) {

                self.mEditCashView.transform = .identity

            }

        }

    }
    
    private func slideToPage(direction: UISwipeGestureRecognizer.Direction) {

        let offset: CGFloat =
            direction == .left ? -40 : 40

        mEditCashView.transform = CGAffineTransform(
            translationX: offset,
            y: 0
        )

        mEditCashView.alpha = 0.2

        reloadCurrentPage()

        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            usingSpringWithDamping: 0.82,
            initialSpringVelocity: 0.8,
            options: [.curveEaseOut],
            animations: {

                self.mEditCashView.transform = .identity

                self.mEditCashView.alpha = 1

            }
        )
    }
    
    private func animateAmountChange(direction: UISwipeGestureRecognizer.Direction) {

        let options: UIView.AnimationOptions =
            direction == .left
            ? .transitionFlipFromRight
            : .transitionFlipFromLeft

        UIView.transition(
            with: mEditCashView,
            duration: 0.22,
            options: [.curveEaseInOut, options],
            animations: {

                self.reloadCurrentPage()

            }
        )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mPageControl.translatesAutoresizingMaskIntoConstraints = false
        mPageControl.numberOfPages = 1
        mPageControl.currentPage = 0
//        mPageControl.isHidden = true
        mPageControl.isHidden = false

        view.addSubview(mPageControl)
        view.bringSubviewToFront(mPageControl)
//        mEditCashView.addSubview(mPageControl)
//        mEditCashView.bringSubviewToFront(mPageControl)
        
//        NSLayoutConstraint.activate([
//
//            mPageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//
//            mPageControl.bottomAnchor.constraint(
//                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
//                constant: -140
//            )
//        ])

        mPageControl.addTarget(
            self,
            action: #selector(pageChanged(_:)),
            for: .valueChanged
        )
        
        let swipeLeft = UISwipeGestureRecognizer(
            target: self,
            action: #selector(handleSwipe(_:))
        )
        swipeLeft.direction = .left

        let swipeRight = UISwipeGestureRecognizer(
            target: self,
            action: #selector(handleSwipe(_:))
        )
        swipeRight.direction = .right

        // ให้ปัดเฉพาะบริเวณกรอกจำนวนเงิน
        mEditCashView.addGestureRecognizer(swipeLeft)
        mEditCashView.addGestureRecognizer(swipeRight)

        // ถ้ามี TextField อยู่ด้านใน ป้องกัน Gesture ไปแย่งการแตะ
        swipeLeft.cancelsTouchesInView = false
        swipeRight.cancelsTouchesInView = false
        
        mPageControl.pageIndicatorTintColor = UIColor(hex: "#D9D9D9")
        mPageControl.currentPageIndicatorTintColor = UIColor(hex: "#2A2A2A")
        
        print("DEBUG_ORDER_TYPE: \(mOrderType)")
        print("DEBUG: หน้า Checkout ได้รับ Remark มาคือ: \(self.mRemark)")
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
        mIBSelect.isSelected = true
        
        mSelectPaymentOptionContainer.isHidden = true
        mIBLabel.text = "Internet Banking".localizedString
        mBankLABEL.text = "Cheque".localizedString
        
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        
        mCreditFillAmount.addTarget(
            self,
            action: #selector(amountChanged),
            for: .editingChanged
        )
        
        
        print("===== CHECKOUT =====")
        print("mCartTotalAmount =", mCartTotalAmount)
        print("mTotalP =", mTotalP)
        print("====================")
    }

    private func syncCurrentPageFromInput() {
        guard mCurrentPage >= 0, mCurrentPage < mPages.count else { return }

        let enteredAmount = Double(mCashAmounts) ?? 0
        let selectedCurrency = mCurrencyName.text ?? mStoreCurrency

        let rate: Double
        if selectedCurrency == mStoreCurrency || mExchangeRateLabel.isHidden {
            rate = 1
        } else {
            rate = Double(mExchangeRateValue.text ?? "") ?? 0
        }

        let convertedAmount =
            enteredAmount > 0 && rate > 0
            ? enteredAmount * rate
            : 0

        mPages[mCurrentPage].enteredAmount = enteredAmount
        mPages[mCurrentPage].amount = convertedAmount
        mPages[mCurrentPage].currency = selectedCurrency
        mPages[mCurrentPage].exchangeRate = rate

        mConvertedAmounts = "\(convertedAmount)"

        if enteredAmount > 0 && rate > 0 {
            let rounded = (convertedAmount * 100).rounded() / 100
            mConvertedAmount.text = "= \(mStoreCurrency) \(rounded)"
        } else if enteredAmount == 0 {
            mConvertedAmount.text = ""
        }
    }

    private func updateSubmittedCashTotal() {
        let totalCash = mPages
            .filter { $0.paymentType == "Cash" && $0.isSubmitted }
            .reduce(0) { $0 + $1.amount }

        mSubmittedCash.text =
            String(format: "%.2f", totalCash).formatPrice()
    }

    func reloadCurrentPage() {
        guard mCurrentPage >= 0, mCurrentPage < mPages.count else { return }

        let page = mPages[mCurrentPage]

        // Restore the ORIGINAL entered amount, not the converted/store amount.
        if page.enteredAmount == 0 {
            mCashAmount.text = ""
            mCashAmounts = ""
            mConvertedAmounts = "0"
            mConvertedAmount.text = ""
        } else {
            let value: String
            if page.enteredAmount.truncatingRemainder(dividingBy: 1) == 0 {
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

        mPageControl.numberOfPages = mPages.count
        UIView.animate(withDuration: 0.15) {
            self.mPageControl.currentPage = self.mCurrentPage
        }
    }

    @IBAction func pageChanged(_ sender: UIPageControl) {
        guard sender.currentPage < mPages.count else { return }

        syncCurrentPageFromInput()
        mCurrentPage = sender.currentPage
        reloadCurrentPage()
    }

    @objc func amountChanged() {

        let grand =
        Double(
            mTOTALAMOUNT.text?
                .replacingOccurrences(of: "$", with: "")
                .replacingOccurrences(of: ",", with: "")
                .trimmingCharacters(in: .whitespaces)
            ?? "0"
        ) ?? 0

        let value =
        Double(mCreditFillAmount.text ?? "") ?? 0

        if value > grand {

            mCreditFillAmount.text =
            String(format: "%.2f", grand)

        }

    }
    
    @objc func keyboardWillShow(_ notification: Notification) {

        guard let frame =
            notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey]
                as? CGRect else { return }

        mBottomConstraint.constant = frame.height
        

        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
        
//        mPayNowButton.isHidden = true
    }

    @objc func keyboardWillHide(_ notification: Notification) {

        mBottomConstraint.constant = 0

        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
//        mPayNowButton.isHidden = false
    }
    
    
    @IBAction func mDeleteIBAmount(_ sender: Any) {
        var text = mEnterAmountText.text ?? ""
        if text != "" {
            text.removeLast()
            mEnterAmountText.text = text
        }
        
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        mPageControl.sizeToFit()

        mPageControl.frame.origin = CGPoint(
            x: (view.bounds.width - mPageControl.frame.width) / 2,
            y: mEditCashView.frame.maxY + mEditCashView.frame.height - mPageControl.frame.height - 16
        )
        
//        mKeyBoardView.backgroundColor = UIColor.red.withAlphaComponent(0.2)
//
//        print("mEditCashView =", mEditCashView.frame)
//        print("mKeyBoardView =", mKeyBoardView.frame)
//        print("mCashView =", mCashView.frame)
//        print("view =", view.frame)
    }
    
    
    @IBAction func mIBButton(_ sender: Any) {
        
        mSelectPaymentOptionContainer.isHidden =  false
        mChequeDetailsView.isHidden = true
        mChequeDetailsView.isHidden = true
        mIBSelect.isSelected = true
        mChequeSelect.isSelected = false
        
        // Update background colors
        mSelectedTabIB.backgroundColor = UIColor(named: "themeColor")
        mSelectedTabCheque.backgroundColor = UIColor(named: "themeExtraLightText")
        
        
    }
    
    @IBAction func mChequeButton(_ sender: Any) {
        mSelectPaymentOptionContainer.isHidden = true
        mChequeDetailsView.isHidden = false
        mChequeSelect.isSelected = true
        mIBSelect.isSelected = false
        
        // Update background colors
        mSelectedTabCheque.backgroundColor = UIColor(named: "themeColor")
        mSelectedTabIB.backgroundColor = UIColor(named: "themeExtraLightText")
    }
    
    
    @IBAction func mTakePhoto(_ sender: Any) {
        
        
    }
    
    
    @IBAction func mScanQRCode(_ sender: Any) {
        if mEnterAmountText.text?.isEmpty == true || (Double(mEnterAmountText.text ?? "") ?? 0.0) == 0 {
            CommonClass.showSnackBar(message: "Please fill amount!")
            return
        }
        if let balanceDue = mBALANCEDUE.text {
            let formattedBalanceDue = balanceDue.replacingOccurrences(of: ",", with: "")
            let balanceDueInDouble = Double(formattedBalanceDue) ?? 0.0
            let inputAmount = Double(mEnterAmountText.text ?? "") ?? 0.0
            
            if (balanceDueInDouble - inputAmount) < 0 {
                CommonClass.showSnackBar(message: "Please fill valid amount!")
                return
            }
        } else {
            CommonClass.showSnackBar(message: "Balance due is not available!")
            return
        }
        if mSelectIBBank.text == "Choose Bank" || mSelectIBBank.text?.isEmpty == true {
            CommonClass.showSnackBar(message: "Please choose a bank name!")
            return
        }
        
        mGenerateQRCode()
    }
    
    
    
    
    @IBAction func mSubmitIBAmount(_ sender: Any) {
        
        if mEnterAmountText.text == "" || (Double(mEnterAmountText.text ?? "") ?? 0.0) == 0 {
            CommonClass.showSnackBar(message: "Please fill amount!")
        }else{
            
            if let balanceDue = mBALANCEDUE.text {
                let formattedBalanceDue = balanceDue.replacingOccurrences(of: ",", with: "")
                let balanceDueInDouble = Double(formattedBalanceDue) ?? 0.0
                let inputAmount = Double(mEnterAmountText.text ?? "") ?? 0.0
                if (balanceDueInDouble - inputAmount) < 0 {
                    CommonClass.showSnackBar(message: "Please fill valid amount!")
                    return
                }
            }
            
            
            
        }
        
    }
    
    
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
            AF.request(urlPath, method:.post, parameters:params, headers: sGisHeaders2).responseJSON
            { [self] response in
                
                CommonClass.stopLoader()
                
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
                    
                    if let mCreditRow = jsonResult.value(forKey: "creditNote_row") as? NSDictionary {
                        
                        var isExist = false
                        for item in mCreditNoteData {
                            if let value = item as? NSDictionary,
                               let id = value.value(forKey: "id") {
                                if "\(id)" == "\(mCreditRow.value(forKey: "id") ?? "")"{
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
                                if let value = item as? NSDictionary,
                                   let amount = value.value(forKey: "amount") {
                                    let mCData = NSMutableDictionary()
                                    
                                    mAmount.append(Double("\(amount)") ?? 0)
                                    
                                    mCData.setValue("\(amount)", forKey: "amount")
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
                    }
                } else {
                    
                    CommonClass.showSnackBar(message: "Invalid Card!")
                    if let error = jsonResult.value(forKey: "error") as? String {
                        if error == "Authorization has been expired" {
                            CommonClass.sessionExpired(isExpired: true, navigation: self.navigationController)
                        }
                    }
                }
            }
        }else{
            CommonClass.showSnackBar(message: "No Internet Connection")
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
        
//        self.mCreditCardPaymentView.isHidden = true
        removePaypalView()
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
//                    print("ORDER =", checkout.orderID)
//                    print("PAYER =", checkout.payerID)
//
//                    self.mPaypalOrderID = checkout.orderID
//                    self.mPaypalPayerID = checkout.payerID
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
//
//                    print("ORDER =", self.mPaypalOrderID)
//                    print("PAYER =", self.mPaypalPayerID)
//                    print("PAYLOAD =", self.mPaypalEncryptedPayload)
//                    self.paypalSuccess { success in
//
//                        print("CALLBACK =", success)
//
//                        DispatchQueue.main.async {
//
//                            print("INSIDE MAIN")
//
//                            guard success else {
//
//                                print("CAPTURE FAILED")
//
//                                return
//                            }
//
//                            print("ADDING PAYMENT")
//
//                            self.mCreditCardMethod.add(mCreditCardData)
//
//                            print("RECHECK")
//
//                            var totalPaid = 0.0
//
//                            for case let data as NSDictionary in self.mCreditCardMethod {
//
//                                totalPaid += Double("\(data["amount"] ?? "0")") ?? 0
//
//                            }
//
//                            self.mSubmittedCreditCard.text = String(format: "%.2f", totalPaid)
//                            self.recheckBalanceDue()
//
//                            print("DONE")
//
//                        }
//                    }
                case .success(let checkout):

                    print("PAYPAL SUCCESS")
                    print("ORDER =", checkout.orderID)
                    print("PAYER =", checkout.payerID)

                    self.mPaypalOrderID = checkout.orderID
                    self.mPaypalPayerID = checkout.payerID
                    
//                    self.paypalSuccess { success in
//
//                        print("CALLBACK =", success)
//
//                        DispatchQueue.main.async {
//
//                            guard success else {
//
//                                print("CAPTURE FAILED")
//                                return
//                            }
//
//                            guard let paypalData =
//                                    self.mSelectedPaypalMethodData else {
//
//                                print("PAYPAL METHOD DATA NOT FOUND")
//
//                                CommonClass.showSnackBar(
//                                    message: "PayPal payment method data not found"
//                                )
//
//                                return
//                            }
//
//                            let mCreditCardData = NSMutableDictionary()
//
//                            // From /getCashMethodList
//                            mCreditCardData.setValue(
//                                "\(paypalData["name"] ?? "PayPalCard")",
//                                forKey: "name"
//                            )
//
//                            mCreditCardData.setValue(
//                                "\(paypalData["PayMethod_logo"] ?? "")",
//                                forKey: "logo"
//                            )
//
//                            mCreditCardData.setValue(
//                                "",
//                                forKey: "card_name"
//                            )
//
//                            mCreditCardData.setValue(
//                                "",
//                                forKey: "card_number"
//                            )
//
//                            // IMPORTANT: Backend requires "id" here
//                            mCreditCardData.setValue(
//                                "\(paypalData["id"] ?? "")",
//                                forKey: "payment_method_id"
//                            )
//
//                            mCreditCardData.setValue(
//                                self.mCreditFillAmount.text ?? "",
//                                forKey: "amount"
//                            )
//
//                            mCreditCardData.setValue(
//                                "\(paypalData["Paymentmethod_type"] ?? "Credit_Card")",
//                                forKey: "Paymentmethod_type"
//                            )
//
//                            mCreditCardData.setValue(
//                                "\(paypalData["payment_slag"] ?? "")",
//                                forKey: "payment_slag"
//                            )
//
//                            // Separate from payment_method_id
//                            mCreditCardData.setValue(
//                                "\(paypalData["PaymentMethod"] ?? "")",
//                                forKey: "PaymentMethod"
//                            )
//
//                            mCreditCardData.setValue(
//                                "\(paypalData["key"] ?? "")",
//                                forKey: "key"
//                            )
//
//                            mCreditCardData.setValue(
//                                checkout.orderID,
//                                forKey: "client_reference_id"
//                            )
//
//                            // Must come from PayPal success webhook response
//                            mCreditCardData.setValue(
//                                self.mPaypalTransID,
//                                forKey: "transID"
//                            )
//
//                            mCreditCardData.setValue(
//                                true,
//                                forKey: "payment"
//                            )
//
//                            print("FINAL PAYPAL CREDIT CARD DATA =")
//                            print(mCreditCardData)
//
//                            self.mCreditCardMethod.add(mCreditCardData)
//
//                            var totalPaid = 0.0
//
//                            for case let data as NSDictionary
//                                in self.mCreditCardMethod {
//
//                                totalPaid +=
//                                    Double("\(data["amount"] ?? "0")") ?? 0
//                            }
//
//                            self.mSubmittedCreditCard.text =
//                                String(format: "%.2f", totalPaid)
//
//                            self.recheckBalanceDue()
//
//                            print("PAYPAL PAYMENT ADDED")
//                        }
//                    }
                    self.paypalSuccess { success, transID in

                        print("CALLBACK =", success)
                        print("CALLBACK TRANS ID =", transID)

                        DispatchQueue.main.async {

                            guard success else {

                                print("CAPTURE FAILED")
                                return
                            }

                            guard !transID.isEmpty else {

                                print("TRANS ID NOT FOUND")

                                CommonClass.showSnackBar(
                                    message: "PayPal transaction ID not found"
                                )

                                return
                            }

                            guard let paypalData =
                                    self.mSelectedPaypalMethodData else {

                                print("PAYPAL METHOD DATA NOT FOUND")

                                CommonClass.showSnackBar(
                                    message: "PayPal payment method data not found"
                                )

                                return
                            }

                            self.mPaypalTransID = transID

                            let mCreditCardData = NSMutableDictionary()

                            // name
                            mCreditCardData.setValue(
                                "\(paypalData["name"] ?? "PayPalCard")",
                                forKey: "name"
                            )

                            // logo
                            mCreditCardData.setValue(
                                "\(paypalData["PayMethod_logo"] ?? "")",
                                forKey: "logo"
                            )

                            mCreditCardData.setValue(
                                "",
                                forKey: "card_name"
                            )

                            mCreditCardData.setValue(
                                "",
                                forKey: "card_number"
                            )

                            // Backend requires id from getCashMethodList
                            mCreditCardData.setValue(
                                "\(paypalData["id"] ?? "")",
                                forKey: "payment_method_id"
                            )

                            mCreditCardData.setValue(
                                self.mCreditFillAmount.text ?? "",
                                forKey: "amount"
                            )

                            mCreditCardData.setValue(
                                "\(paypalData["Paymentmethod_type"] ?? "Credit_Card")",
                                forKey: "Paymentmethod_type"
                            )

                            mCreditCardData.setValue(
                                "\(paypalData["payment_slag"] ?? "")",
                                forKey: "payment_slag"
                            )

                            mCreditCardData.setValue(
                                "\(paypalData["PaymentMethod"] ?? "")",
                                forKey: "PaymentMethod"
                            )

                            mCreditCardData.setValue(
                                "\(paypalData["key"] ?? "")",
                                forKey: "key"
                            )

                            mCreditCardData.setValue(
                                checkout.orderID,
                                forKey: "client_reference_id"
                            )

                            // transID from webhook response
                            mCreditCardData.setValue(
                                transID,
                                forKey: "transID"
                            )

                            mCreditCardData.setValue(
                                true,
                                forKey: "payment"
                            )

                            print("FINAL PAYPAL CREDIT CARD DATA =")
                            print(mCreditCardData)

                            self.mCreditCardMethod.add(
                                mCreditCardData
                            )

                            var totalPaid = 0.0

                            for case let data as NSDictionary
                                in self.mCreditCardMethod {

                                totalPaid +=
                                    Double(
                                        "\(data["amount"] ?? "0")"
                                    ) ?? 0
                            }

                            self.mSubmittedCreditCard.text =
                                String(
                                    format: "%.2f",
                                    totalPaid
                                )

                            print("mSubmittedCash =", self.mSubmittedCash.text ?? "")
                            print("mSubmittedCreditCard =", self.mSubmittedCreditCard.text ?? "")
                            print("mSubmittedBankAmount =", self.mSubmittedBankAmount.text ?? "")
                            print("mSubmittedCreditNote =", self.mSubmittedCreditNote.text ?? "")
                            
                            self.recheckBalanceDue()

                            print("PAYPAL PAYMENT ADDED")
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
    
    func paypalSuccess(
        completion: @escaping (Bool, String) -> Void
    ) {

        guard !mPaypalEncryptedPayload.isEmpty else {
            completion(false, "")
            return
        }

        let payload =
            mPaypalEncryptedPayload.addingPercentEncoding(
                withAllowedCharacters: .urlQueryAllowed
            ) ?? ""

        let urlString =
        BaseUrl+"webhook/paypal-success-mobile?data=\(payload)&token=\(mPaypalOrderID)"

        guard let url = URL(string: urlString) else {
            completion(false, "")
            return
        }

        print("========== PAYPAL SUCCESS API ==========")
        print("SUCCESS URL =", url.absoluteString)

        URLSession.shared.dataTask(with: url) {
            data,
            response,
            error in

            if let error = error {

                print("PAYPAL SUCCESS ERROR =", error)

                completion(false, "")
                return
            }

            guard let http = response as? HTTPURLResponse else {

                completion(false, "")
                return
            }

            print(
                "PAYPAL SUCCESS STATUS =",
                http.statusCode
            )

            var transID = ""

            if let data = data {

                if let json =
                    try? JSONSerialization.jsonObject(
                        with: data
                    ) as? [String: Any] {

                    print(
                        "PAYPAL SUCCESS JSON =",
                        json
                    )

                    transID =
                        "\(json["transID"] ?? "")"

                    print(
                        "PAYPAL TRANS ID =",
                        transID
                    )

                } else if let text = String(
                    data: data,
                    encoding: .utf8
                ) {

                    print(
                        "PAYPAL SUCCESS RAW RESPONSE =",
                        text
                    )
                }
            }

            completion(
                http.statusCode == 200,
                transID
            )

        }.resume()
    }
    
//    func paypalSuccess(completion: @escaping (Bool) -> Void) {
//
//        guard !mPaypalEncryptedPayload.isEmpty else {
//            completion(false)
//            return
//        }
//
//        let payload =
//            mPaypalEncryptedPayload
//                .addingPercentEncoding(
//                    withAllowedCharacters: .urlQueryAllowed
//                ) ?? ""
//
//        let urlString =
//            "https://api2.gis247.net/api/v1/webhook/paypal-success-mobile?data=\(payload)&token=\(mPaypalOrderID)"
//
//        guard let url = URL(string: urlString) else {
//            completion(false)
//            return
//        }
//
//        print("========== PAYPAL SUCCESS API ==========")
//        print("SUCCESS URL =", url.absoluteString)
//
//        URLSession.shared.dataTask(with: url) { data, response, error in
//
//            if let error = error {
//
//                print("PAYPAL SUCCESS ERROR =", error)
//
//                completion(false)
//                return
//            }
//
//            if let http = response as? HTTPURLResponse {
//                print("PAYPAL SUCCESS STATUS =", http.statusCode)
//            }
//
//            // ===== ใส่ตรงนี้ =====
//            if let data = data {
//
//                if let json = try? JSONSerialization.jsonObject(
//                    with: data
//                ) as? [String: Any] {
//
//                    print("PAYPAL SUCCESS JSON =", json)
//
//                    if let transID = json["transID"] as? String {
//
//                        self.mPaypalTransID = transID
//
//                        print("PAYPAL TRANS ID =", transID)
//                    }
//
//                } else if let text = String(
//                    data: data,
//                    encoding: .utf8
//                ) {
//
//                    print("PAYPAL SUCCESS RAW RESPONSE =", text)
//                }
//            }
//
//            if let http = response as? HTTPURLResponse {
//
//                completion(http.statusCode == 200)
//
//            } else {
//
//                completion(false)
//            }
//
//        }.resume()
//    }
    
//    func paypalSuccess(completion: @escaping (Bool) -> Void) {
//
//        guard !mPaypalEncryptedPayload.isEmpty else {
//            completion(false)
//            return
//        }
//
////        let urlString = "https://api2.gis247.net/api/v1/webhook/paypal-success-mobile?data=\(mPaypalEncryptedPayload)"
////        let urlString = "https://api2.gis247.net/api/v1/webhook/paypal-success-mobile?data=\(mPaypalEncryptedPayload)&token=\(mPaypalOrderID)"
//        let payload =
//        mPaypalEncryptedPayload.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
//
//        let urlString =
//        "https://api2.gis247.net/api/v1/webhook/paypal-success-mobile?data=\(payload)&token=\(mPaypalOrderID)"
//
//        guard let url = URL(string: urlString) else {
//            completion(false)
//            return
//        }
//
//        print("========== PAYPAL SUCCESS API ==========")
//        print("SUCCESS URL =", url.absoluteString)
//
//        URLSession.shared.dataTask(with: url) { data, response, error in
//
//            if let error = error {
//                print(error)
//                completion(false)
//                return
//            }
//
//            if let http = response as? HTTPURLResponse {
//                print("PAYPAL SUCCESS STATUS =", http.statusCode)
//            }
//
//            if let data = data,
//               let text = String(data: data, encoding: .utf8) {
//                print("PAYPAL SUCCESS RESPONSE =")
//                print(text)
//            }
//
//            if let http = response as? HTTPURLResponse {
//                completion(http.statusCode == 200)
//            } else {
//                completion(false)
//            }
//
//        }.resume()
//    }
    
    private func checkoutAmount(_ text: String?) -> Double {
        let rawValue = text ?? ""
        let allowedCharacters = CharacterSet(charactersIn: "0123456789.-")
        let numericValue = rawValue.unicodeScalars
            .filter { allowedCharacters.contains($0) }
            .map(String.init)
            .joined()
        return Double(numericValue) ?? 0
    }
    
    private func recheckBalanceDue() {
        let totalAmount = checkoutAmount(mTOTALAMOUNT.text)
        let submittedCash = checkoutAmount(mSubmittedCash.text)
        let submittedBankAmount = checkoutAmount(mSubmittedBankAmount.text)
        let submittedCreditCard = checkoutAmount(mSubmittedCreditCard.text)
        let submittedCreditNote = checkoutAmount(mSubmittedCreditNote.text)

        print("Total =", totalAmount)
        print("Cash =", submittedCash)
        print("Bank =", submittedBankAmount)
        print("Credit Card =", submittedCreditCard)
        print("Credit Note =", submittedCreditNote)
        let mTotalValue =
            totalAmount
            - submittedCash
            - submittedCreditNote
            - submittedBankAmount
            - submittedCreditCard
        print("CustomOrderCheckout recheckBalanceDue \(mTotalValue) = \(totalAmount) - \(submittedCash) - \(submittedCreditNote) - \(submittedBankAmount) - \(submittedCreditCard)")
        let balance = max(0, mTotalValue)
        self.mBALANCEDUE.text = "\(balance)".formatPrice()
//        self.mBALANCEDUE.text = "\(mTotalValue)".formatPrice()
        self.mCreditFillAmount.text = ""
        print("========== Multiple Payment ==========")
        print("Total =", totalAmount)
        print("Cash =", submittedCash)
        print("Bank =", submittedBankAmount)
        print("Credit Card =", submittedCreditCard)
        print("Credit Note =", submittedCreditNote)
        print("Balance =", balance)
        print("======================================")
    }
    
    @IBAction func mSubmitCreditAmount(_ sender: UIButton) {
        self.view.endEditing(true)
        
        if let balanceDue = self.mBALANCEDUE.text {
            let formattedBalanceDue = balanceDue.replacingOccurrences(of: ",", with: "")
            let balanceDueInDouble = Double(formattedBalanceDue) ?? 0.0
            let inputAmount = Double(self.mCreditFillAmount.text ?? "") ?? 0.0
            print("mSubmitCreditAmount inputAmount = \(inputAmount) balanceDueInDouble = \(balanceDueInDouble) self.mCreditFillAmount.text = \(self.mCreditFillAmount.text ?? "0")")
            
            if inputAmount <= balanceDueInDouble {
//                self.mGetStripeDataBackEnd()
                if mSelectdPaymentMethod == "stripe-payment" {

                    mGetStripeDataBackEnd()

                } else if mSelectdPaymentMethod == "paypal-payment" {

                    mGetPaypalDataBackEnd()

                }
                else{
                    CommonClass.showSnackBar(message:"Please select payment method")
                }
            } else {
                CommonClass.showSnackBar(message: "Please fill a valid amount!")
                return
            }
        }
        
        
    }
    
    func mAddCredit(cardNumber:String, cardExp:String, cardCvc:String, amount:String){
        
        CommonClass.showFullLoader(view: self.view)
        
        _ = UserDefaults.standard.string(forKey: "location")
        
        let urlPath =  mCreditCardAdd
        
        let params = ["card_no": cardNumber, "card_cvc":cardCvc,"exp_month":cardExp,"card_holderName":UserDefaults.standard.string(forKey: "CUSTOMERID") ?? "" ,"method_id":mCreditCardPaymentId,"salesPerson_val": UserDefaults.standard.string(forKey: "SALESPERSONID") ?? "" ,"amount":amount]
        
        if Reachability.isConnectedToNetwork() == true {
            AF.request(urlPath, method:.post, parameters:params, headers: sGisHeaders2).responseJSON
            { [self] response in
                
                CommonClass.stopLoader()
                
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
                        if let mData = jsonResult.value(forKey: "data") as? NSDictionary {
                            
                            let mId = mData.value(forKey: "insert_id") as? String ?? ""
                            let mCreditCardOptions = NSMutableDictionary()
                            mCreditCardOptions.setValue(self.mCreditCardPaymentId, forKey: "cardPaymentId")
                            mCreditCardOptions.setValue(amount, forKey: "amount")
                            mCreditCardOptions.setValue(mId, forKey: "id")
                            self.mCreditCardMethod.add(mCreditCardOptions)
                            var mAmount = [Double]()
                            
                            for i in self.mCreditCardMethod {
                                if let mAM = i as? NSDictionary,
                                   let amount = mAM.value(forKey: "amount") {
                                    mAmount.append(Double("\(amount)") ?? 0)
                                }
                            }
                            self.mSubmittedCreditCard.text = "\( mAmount.reduce(0, {$0 + $1}))"
                            
//                            let totalAmount = Double(self.mTOTALAMOUNT.text?.replacingOccurrences(of: ",", with: "") ?? "") ?? 0.0
//                            let submittedCash = Double(mSubmittedCash.text ?? "") ?? 0.0
//                            let submittedCreditNote = Double(mSubmittedCreditNote.text ?? "") ?? 0.0
//                            let submittedBankAmount = Double(mSubmittedBankAmount.text ?? "") ?? 0.0
//                            let submittedCreditCard = Double(mSubmittedCreditCard.text ?? "") ?? 0.0
//
//                            let mTotalValue = totalAmount - submittedCash - submittedCreditNote - submittedBankAmount - submittedCreditCard
//                            self.mBALANCEDUE.text = "\(mTotalValue)".formatPrice()
//                            let totalAmount = Double(self.mTOTALAMOUNT.text?.replacingOccurrences(of: ",", with: "") ?? "") ?? 0.0
//                            let submittedCash = Double(self.mSubmittedCash.text ?? "") ?? 0.0
//                            let submittedCreditNote = Double(self.mSubmittedCreditNote.text ?? "") ?? 0.0
//                            let submittedBankAmount = Double(self.mSubmittedBankAmount.text ?? "") ?? 0.0
//                            let submittedCreditCard = Double(self.mSubmittedCreditCard.text ?? "") ?? 0.0
//
//        //                    let mTotalValue = totalAmount - submittedCash - submittedCreditNote - submittedBankAmount - submittedCreditCard
//                            let convertedAmounts = Double(self.mCashAmount.text ?? "0.0") ?? 0.00
//
//                            let mTotalValue =
//                                totalAmount
//                                - convertedAmounts
//                                - submittedCreditNote
//                                - submittedBankAmount
//                                - submittedCreditCard
//
//                            self.mBALANCEDUE.text = "\(mTotalValue)".formatPrice()
                            
                            recheckBalanceDue()
                        }
                    }else {
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mPaymentData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cells = collectionView.dequeueReusableCell(withReuseIdentifier: "Collect",for:indexPath) as? Collect else {
            return UICollectionViewCell()
        }
        
        if let mData = mPaymentData[indexPath.row] as? NSDictionary {
            cells.mImage.downlaodImageFromUrl(urlString: "\(mData.value(forKey: "PayMethod_logo") ?? "")")
            cells.mName.text = mData.value(forKey: "name") as? String
            if mStripeIndex == indexPath.row {
                
                mCreditCardPaymentId = mData.value(forKey: "id") as? String ?? ""
                mCreditCardName = "\(mData.value(forKey: "name") ?? "")"
                mCreditCardLogo = "\(mData.value(forKey: "PayMethod_logo") ?? "")"
                cells.mView.borderColor = UIColor(named: "themeColor")
                cells.mView.borderWidth = 1
                cells.mView.layer.cornerRadius = 10
                
            }else {
                cells.mView.borderWidth = 0
                cells.mView.layer.cornerRadius = 10
            }
        }
        return cells
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //        let cells = collectionView.dequeueReusableCell(withReuseIdentifier: "Collect",for:indexPath) as? Collect
        
        let layout = collectionViewLayout as? UICollectionViewFlowLayout
        let width = collectionView.frame.width / 2
        layout?.minimumLineSpacing = 16
        
        
        return CGSize(width: (collectionView.frame.width / 2) - 16 , height: (collectionView.frame.height / 2) - 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        mStripeIndex = indexPath.row
        
        
        if let mData = mPaymentData[indexPath.row] as? NSDictionary {
            print(mData,"check payment data ")
//            let env = "\(mData["environment"] ?? "")".lowercased()
//
//            mCreditFillAmount.text = "\(Double(self.mCartTotalAmount) ?? 0)"
//
//            self.selectPayment(data: mData)
//
            
            
            let env = "\(mData["environment"] ?? "")".lowercased()
            print("Selected PayPal Environment =", env)
            mCreditFillAmount.text = "\(Double(self.mCartTotalAmount) ?? 0)"

//            if env == "sandbox" {
//
//                self.selectPayment(data: self.mPaypalSandboxData)
//
//            } else {
//
//                self.selectPayment(data: self.mPaypalLiveData)
//            }
//            self.mCreditCardBanksView.isHidden = true
//            self.mStripeCardView.isHidden = false
            
            mCreditFillAmount.text = "\(Double(self.mCartTotalAmount) ?? 0)"

//            self.selectPayment(data: mData)
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
            
//            mCreditCardPaymentId = mData.value(forKey: "id") as? String ?? ""
//            mCreditCardName = "\(mData.value(forKey: "name") ?? "")"
//            mCreditCardLogo = "\(mData.value(forKey: "PayMethod_logo") ?? "")"
//            mPaymentID = "\(mData.value(forKey: "id") ?? "")"
//            mPaymentMethod = "\(mData.value(forKey: "PaymentMethod") ?? "")"
//            mStripPublishKey = "\(mData.value(forKey: "key") ?? "")"
//            mSelectdPaymentMethod = "\(mData.value(forKey: "payment_slag") ?? "")"
//            self.mCreditBankImage.downlaodImageFromUrl(urlString: "\(mData.value(forKey: "PayMethod_logo") ?? "")")
//            self.mCreditBankName.text = mData.value(forKey: "name") as? String
//            mCardNumber.text = ""
//            mCardName.text = ""
//            mCreditFillAmount.text = ""
//            self.mStripeCardView.isHidden = false
//            self.mCreditCardBanksView.isHidden = true
//            self.mStripeCardView.isHidden = false
//            print("mSelectdPaymentMethod = \(mSelectdPaymentMethod)")
//            if mSelectdPaymentMethod == "stripe-payment"
//                || mSelectdPaymentMethod == "paypal-payment" {
//
//                mCardNumberContainer.isHidden = true
//                mCardNameContainer.isHidden = true
//
//            } else {
//
//                mCardNumberContainer.isHidden = false
//                mCardNameContainer.isHidden = false
//            }
////            if mSelectdPaymentMethod == "stripe-payment" || mSelectdPaymentMethod == "paypal-payment" {
////
////                self.mCardNumberContainer.isHidden = true
////                self.mCardNameContainer.isHidden = true
////            }else {
////                self.mCardNumberContainer.isHidden = false
////                self.mCardNameContainer.isHidden = false
////            }
//            self.mCollectionView.reloadData()
        }
        
    }
    
    
//    func mFetchStore(key: String){
//
//        let mLocation = UserDefaults.standard.string(forKey: "location") ?? ""
//
//        let urlPath =  mFetchPaymentMethod
//        _ = ["login_token": mUserLoginToken ?? "", "location_id": mLocation ]
//
//        if Reachability.isConnectedToNetwork() == true {
//            AF.request(urlPath, method:.post, parameters:["secretKeysshow":"true"], headers: sGisHeaders2).responseJSON
//            { response in
//                print(response,"check bank")
//                if response.error != nil {
//
//                    CommonClass.showSnackBar(message: "OOP's something went wrong!")
//
//                }else{
//                    guard let jsonData = response.data else {
//                        CommonClass.showSnackBar(message: "OOP's something went wrong!")
//                        return
//                    }
//
//                    let json = try? JSONSerialization.jsonObject(with: jsonData, options: [])
//
//                    guard let jsonResult = json as? NSDictionary else {
//                        CommonClass.showSnackBar(message: "OOP's something went wrong!")
//                        return
//                    }
//                    if jsonResult.value(forKey: "code") as? Int == 200 {
//
//                        if let mPaymentMethod = jsonResult.value(forKey: "data") as? NSDictionary {
//
//                            if let mData = mPaymentMethod.value(forKey: "Credit_Card") as? NSArray, mData.count > 0 {
//                                self.mPaymentData = mData
//                                self.mCollectionView.delegate = self
//                                self.mCollectionView.dataSource = self
//                                self.mCollectionView.reloadData()
//                            }
//                        }
//                    }else {
//                        if let error = jsonResult.value(forKey: "error") as? String {
//                            if error == "Authorization has been expired" {
//                                CommonClass.sessionExpired(isExpired: true, navigation: self.navigationController)
//                            }
//                        }
//                    }
//
//                }
//
//            }
//        }else{
//            CommonClass.showSnackBar(message: "No Internet Connection")
//        }
//
//
//    }
    
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
//                        }
                        
                        if let mData = mPaymentMethod["Credit_Card"] as? NSArray,
                           mData.count > 0 {

                            let filterData = NSMutableArray()

                            for item in mData {

                                guard let dict = item as? NSDictionary else { continue }

                                let slug = "\(dict["payment_slag"] ?? "")"

                                if slug == "paypal-payment" {
                                    filterData.add(dict)
                                }
                            }
                            
                            self.mPaymentData = mData

                        } else {

                            self.mPaymentData = []
                        }
                        
                        if let mData = mPaymentMethod["Bank"] as? NSArray,
                                  mData.count > 0 {

                            self.mBankData = mData
                        }
                        self.mCollectionView.reloadData()
                        
//                        if let mData = mPaymentMethod["Credit_Card"] as? NSArray,
//                           mData.count > 0 {
//
//                            let filterData = NSMutableArray()
//
//                            for item in mData {
//
//                                guard let dict = item as? NSDictionary else { continue }
//
//                                let slug = "\(dict["payment_slag"] ?? "")"
//
//                                if slug == "paypal-payment" {
//                                    filterData.add(dict)
//                                }
//                            }
//
//                            self.mPaymentData = mData//filterData
//
//                        }
//                        else
                        

                        print("DEBUG_PAYMENT_COUNT =", self.mPaymentData.count)
                        
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
                mChequePaymentIdNew = ""
                paymentSlag = ""
                mChequeData = NSMutableDictionary()
                mChequeData.setValue("", forKey: "cheque_date")
                mChequeData.setValue("", forKey: "cheque_ac_no")
                mChequeData.setValue("", forKey: "cheque_ac_name")
                mChequeData.setValue("", forKey: "cheque_bank")
                mChequeData.setValue("", forKey: "cheque_ref_no")
                mChequeData.setValue("", forKey: "cheque_date")
                
//                let totalAmount = (self.mTOTALAMOUNT.text ?? "").replacingOccurrences(of: ",", with: "")
//                let totalAmountDouble = Double(totalAmount) ?? 0
//                let convertedAmounts = Double(mCashAmount.text ?? "0.0") ?? 0
//                let submittedCreditNote = Double(mSubmittedCreditNote.text ?? "") ?? 0
//                let submittedBankAmount = Double(mSubmittedBankAmount.text ?? "") ?? 0
//                let submittedCreditCard = Double(mSubmittedCreditCard.text ?? "") ?? 0
//
//                self.mBALANCEDUE.text = "\(totalAmountDouble - convertedAmounts - submittedCreditNote - submittedBankAmount - submittedCreditCard)".formatPrice()
//                let totalAmount = Double(self.mTOTALAMOUNT.text?.replacingOccurrences(of: ",", with: "") ?? "") ?? 0.0
//                let submittedCash = Double(self.mSubmittedCash.text ?? "") ?? 0.0
//                let submittedCreditNote = Double(self.mSubmittedCreditNote.text ?? "") ?? 0.0
//                let submittedBankAmount = Double(self.mSubmittedBankAmount.text ?? "") ?? 0.0
//                let submittedCreditCard = Double(self.mSubmittedCreditCard.text ?? "") ?? 0.0
//
////                    let mTotalValue = totalAmount - submittedCash - submittedCreditNote - submittedBankAmount - submittedCreditCard
//                let convertedAmounts = Double(self.mCashAmount.text ?? "0.0") ?? 0.00
//
//                let mTotalValue =
//                    totalAmount
//                    - convertedAmounts
//                    - submittedCreditNote
//                    - submittedBankAmount
//                    - submittedCreditCard
//
//                self.mBALANCEDUE.text = "\(mTotalValue)".formatPrice()
                recheckBalanceDue()
                
            }
        }else{
            
        }
    }
    
    @IBAction func mChooseCheqDate(_ sender: Any) {
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
        //ToolBar
        let mToolBar = UIToolbar()
        mToolBar.sizeToFit()
        mToolBar.backgroundColor = .white
        mToolBar.barTintColor = .white
        let mDone = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneDatePick))
        let mSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let mCancel = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(mCancelDatePick))
        mToolBar.setItems([mDone, mSpace,mCancel], animated: false)
        
        mCheqDate.inputAccessoryView = mToolBar
        mCheqDate.inputView = mDatePicker
        
    }
    @objc func doneDatePick(){
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "dd/MM/yyyy"

        let deliveryDate = formatter.string(from: mDatePicker.date)
        
        
        mCheqDate.text  = deliveryDate
        
        self.view.endEditing(true)
        
    }
    @objc func mCancelDatePick(){
        self.view.endEditing(true)
    }
    
    @IBAction func mChooseBanks(_ sender: Any) {
        
        var mBankNames = ["Choose Bank"]
        var mBankImage = ["https://art.gis247.net/assets/images/icon/camera_profile.png"]
        var mPMId = [""]
        let mBankTypeFilter = "Cheque"
        
        if let mBankData = UserDefaults.standard.object(forKey: "BANKDATA") as? NSArray {
            if mBankData.count > 0 {
                for i in mBankData {
                    if let data = i as? NSDictionary {
                        // Add condition to check for BankPaymenttype
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
    
    
    @IBAction func mChooseIBBank(_ sender: Any) {
        
        var mBankNames = ["Choose Bank"]
        let mBankTypeFilter = "IB" // Define the filter type
        var mBankImage = ["https://art.gis247.net/assets/images/icon/camera_profile.png"]
        var mPMId = [""]
        var mPMIdNew = [""]
        var mPINPaymentSlag = [""]
        
        if let mBankData = UserDefaults.standard.object(forKey: "BANKDATA") as? NSArray {
            if mBankData.count > 0 {
                for i in mBankData {
                    if let data = i as? NSDictionary {
                        // Check if the BankPaymenttype matches "IB"
                        if "\(data.value(forKey: "BankPaymenttype") ?? "")" == mBankTypeFilter {
                            mBankNames.append("\(data.value(forKey: "name") ?? "")")
                            mBankImage.append("\(data.value(forKey: "PayMethod_logo") ?? "")")
                            mPMId.append("\(data.value(forKey: "PaymentMethod") ?? "")")
                            mPMIdNew.append("\(data.value(forKey: "id") ?? "")")
                            mPINPaymentSlag.append("\(data.value(forKey: "payment_slag") ?? "")")
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
                    self.mChequePaymentIdNew = mPMIdNew[index]
                    self.mSelectIBBank.text = item
                    self.paymentSlag = mPINPaymentSlag[index]
                    self.mSelectIBBankImage.downlaodImageFromUrl(urlString: mBankImage[index])
                }
                
                dropdown.show()
            } else {
                CommonClass.showSnackBar(message: "Please add authorised bank!")
            }
        }
        
        
    }
    
    
    
    
    @IBAction func mSubmitCheque(_ sender: UIButton) {
        sender.showAnimation{}
        
        if mChequeAmount.text == "" || (Double(mChequeAmount.text ?? "") ?? 0.0) == 0 {
            CommonClass.showSnackBar(message: "Please fill amount!")
        }
        else if mCheqDate.text == "" {
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
                    return
                }
            }
            
            //PAYMENTMETHODID
            mChequeData = NSMutableDictionary()
            mChequeData.setValue(mCheqDate.text ?? "", forKey: "transaction_date")
            mChequeData.setValue(mCheqAccountNumber.text ?? "", forKey: "ac_no")
            mChequeData.setValue(mCheqAccountName.text ?? "", forKey: "ac_name")
            mChequeData.setValue(mChequePaymentId, forKey: "payment_method_id")
            mChequeData.setValue(mCheqRefNumber.text ?? "", forKey: "ref_no")
            mChequeData.setValue(mCheqInstNumber.text ?? "", forKey: "inst_no")
            mChequeData.setValue(mChequeAmount.text ?? "", forKey: "amount")
            mChequeData.setValue(mClientReferenceID, forKey: "client_reference_id")
            mChequeData.setValue("Bank", forKey: "Paymentmethod_type")
            
            self.mBankPayment.add(mChequeData)
            
            
            
            var mAmounts = [Double]()
            for i in mBankPayment {
                let mData = i as? NSDictionary
                mAmounts.append(Double("\(mData?.value(forKey: "amount") ?? "0.0")".replacingOccurrences(of: ",", with: "")) ?? 0.00)
            }
            
            mSubmittedBankAmount.text = "\(mAmounts.reduce(0, {$0 + $1}))"
            
//            let totalAmount = Double(self.mTOTALAMOUNT.text?.replacingOccurrences(of: ",", with: "") ?? "") ?? 0.00
//            let submittedCreditNote = Double(mSubmittedCreditNote.text ?? "") ?? 0.00
//            let submittedBankAmount = Double(mSubmittedBankAmount.text ?? "") ?? 0.00
//            let submittedCreditCard = Double(mSubmittedCreditCard.text ?? "") ?? 0.00
//            let convertedAmounts = Double(mCashAmount.text ?? "0.0") ?? 0.00
//
//            let mTotalValue = totalAmount - convertedAmounts - submittedCreditNote - submittedBankAmount - submittedCreditCard
//
//            self.mBALANCEDUE.text = "\(mTotalValue)".formatPrice()
//            let totalAmount = Double(self.mTOTALAMOUNT.text?.replacingOccurrences(of: ",", with: "") ?? "") ?? 0.0
//            let submittedCash = Double(self.mSubmittedCash.text ?? "") ?? 0.0
//            let submittedCreditNote = Double(self.mSubmittedCreditNote.text ?? "") ?? 0.0
//            let submittedBankAmount = Double(self.mSubmittedBankAmount.text ?? "") ?? 0.0
//            let submittedCreditCard = Double(self.mSubmittedCreditCard.text ?? "") ?? 0.0
//
////                    let mTotalValue = totalAmount - submittedCash - submittedCreditNote - submittedBankAmount - submittedCreditCard
//            let convertedAmounts = Double(self.mCashAmount.text ?? "0.0") ?? 0.00
//
//            let mTotalValue =
//                totalAmount
//                - convertedAmounts
//                - submittedCreditNote
//                - submittedBankAmount
//                - submittedCreditCard
//
//            self.mBALANCEDUE.text = "\(mTotalValue)".formatPrice()
            
            recheckBalanceDue()
            
            self.mCheqDate.text = ""
            self.mCheqAccountNumber.text = ""
            self.mCheqAccountName.text = ""
            self.mChequePaymentId = ""
            mChequePaymentIdNew = ""
            paymentSlag = ""
            mCheqBankName.text = "Choose Bank"
            self.mCheqRefNumber.text = ""
            
            self.mChequeAmount.text = ""
            self.mCheqInstNumber.text = ""
            CommonClass.showSnackBar(message: "Amount added successfully")
            recheckBalanceDue()
            
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return mCreditNoteData.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        
        guard let cells = tableView.dequeueReusableCell(withIdentifier: "CreditNoteList") as? CreditNoteList else {
            return UITableViewCell()
        }
        
        if let mData =  mCreditNoteData[indexPath.row] as? NSDictionary {
            
            cells.mType.text = mData.value(forKey: "type") as? String
            cells.mRefNo.text = mData.value(forKey: "Ref_No") as? String
            cells.mDate.text = mData.value(forKey: "date") as? String
            
            cells.mAmount.tag = indexPath.row
            
            if indexPath.row % 2 == 0 {
                cells.mView.backgroundColor = UIColor(named: "themeBackground")
            }else{
                cells.mView.backgroundColor =  #colorLiteral(red: 0.9568627451, green: 0.9568627451, blue: 0.9568627451, alpha: 1)
            }
            
            if mSelectedCustomIndex.contains(indexPath) {
                if let mDataSet = mAmountData[indexPath.row] as? NSDictionary {
                    cells.mAmount.text = "\(mDataSet.value(forKey: "amount") ?? "0.0")"
                }
            }else{
                cells.mAmount.text = "\(mData.value(forKey: "amount") ?? "0.0")"
            }
            
            if mSelectedIndex.contains(indexPath) {
                cells.mCheckImage.image = UIImage(named: "check_item" )
            }else{
                cells.mCheckImage.image = UIImage(named: "uncheck_item" )
            }
            
            cells.layoutSubviews()
        }
        
        return cells
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        _ = tableView.dequeueReusableCell(withIdentifier: "CreditNoteList") as? CreditNoteList
        print("CustomOrderCheckout didSelectRowAt mOrderType = \(mOrderType)")
        if mOrderType == "pos_order" {

            guard let mData = mCreditNoteData[indexPath.row] as? NSDictionary else {
                return
            }

            let diffCurrency = Int("\(mData["diff_currency"] ?? "0")") ?? 0

            if diffCurrency == 1 {

                CommonClass.showSnackBar(
                    message: "Apologies for the inconvenience!\nThis credit note is in a different currency and cannot be encashed here."
                )

                return
            }

            if mSelectedIndex.contains(indexPath) {
                mSelectedIndex = mSelectedIndex.filter { $0 != indexPath }
            } else {
                mSelectedIndex.append(indexPath)
            }

            self.mGetTotalAmount()
            self.mCreditNoteTable.reloadData()
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    
    @IBAction func mAmountEdit(_ sender: UITextField) {
        
        if let mMaxData = mCreditNoteData[sender.tag] as? NSDictionary {
            let mMaxAmount = Double("\(mMaxData.value(forKey: "amount") ?? "0.0")") ?? 0
            if sender.text == ""  {
                mAddCreditAmount(text: "0", index: sender.tag)
                return
            }
            
            if (Double("\(sender.text ?? "")") ?? 0) > mMaxAmount   {
                sender.text = "\(mMaxData.value(forKey: "amount") ?? "0.0")"
                mAddCreditAmount(text: sender.text ?? "", index: sender.tag)
            }else{
                mAddCreditAmount(text: sender.text ?? "", index: sender.tag)
            }
        }
    }
    
    func mAddCreditAmount(text : String , index : Int ){
        
        let mIndexPath = IndexPath(row:index,section: 0)
        
        let mData = NSMutableDictionary()
        mData.setValue(text, forKey: "amount")
        mAmountData.removeObject(at: index)
        mAmountData.insert(mData, at:  index)
        
        if self.mSelectedCustomIndex.contains(mIndexPath) {
            self.mSelectedCustomIndex = mSelectedCustomIndex.filter {$0 != mIndexPath }
            self.mSelectedCustomIndex.append(mIndexPath)
            
        }else{
            
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
                    
                    mAmount.append(Double("\(mData.value(forKey: "amount") ?? "0.0")") ?? 0)
                    let mMaxData = mCreditNoteData[index] as? NSDictionary
                    
                    let mCData = NSMutableDictionary()
                    mCData.setValue("\(mData.value(forKey: "amount") ?? "0.0")", forKey: "amount")
                    mCData.setValue("\(mMaxData?.value(forKey: "id") ?? "")", forKey: "payment_method_id")
                    
                    
                    mCreditData.add(mCData)
                    mCreditDataMerged.add(mCData)
                }
            }
            
            
        }
        
        if mSelectedIndex.count == 1 {
            mItemsSelected.text = "\(mSelectedIndex.count) " + "Item Selected".localizedString
            
        }else if mSelectedIndex.count == 0 {
            mItemsSelected.text = "0 " + "Item Selected".localizedString
        }else {
            mItemsSelected.text = "\(mSelectedIndex.count) " +  "Items Selected".localizedString
        }
        
        mTotalSelectedAmount.text = String(format:"%.02f",locale:Locale.current,mAmount.reduce(0, {$0 + $1}))
        
        self.mSubmittedCreditNote.text = mTotalSelectedAmount.text?.replacingOccurrences(of: ",", with: "")
        
        
//        let totalAmount = Double(self.mTOTALAMOUNT.text?.replacingOccurrences(of: ",", with: "") ?? "") ?? 0.0
//        let submittedCash = Double(mSubmittedCash.text ?? "") ?? 0.0
//        let submittedCreditNote = Double(mSubmittedCreditNote.text ?? "") ?? 0.0
//        let submittedBankAmount = Double(mSubmittedBankAmount.text ?? "") ?? 0.0
//        let submittedCreditCard = Double(mSubmittedCreditCard.text ?? "") ?? 0.0
//
//        let mTotalValue = totalAmount - submittedCash - submittedCreditNote - submittedBankAmount - submittedCreditCard
//
//        self.mBALANCEDUE.text = "\(mTotalValue)".formatPrice()
//        let totalAmount = Double(self.mTOTALAMOUNT.text?.replacingOccurrences(of: ",", with: "") ?? "") ?? 0.0
//        let submittedCash = Double(self.mSubmittedCash.text ?? "") ?? 0.0
//        let submittedCreditNote = Double(self.mSubmittedCreditNote.text ?? "") ?? 0.0
//        let submittedBankAmount = Double(self.mSubmittedBankAmount.text ?? "") ?? 0.0
//        let submittedCreditCard = Double(self.mSubmittedCreditCard.text ?? "") ?? 0.0
//
////                    let mTotalValue = totalAmount - submittedCash - submittedCreditNote - submittedBankAmount - submittedCreditCard
//        let convertedAmounts = Double(self.mCashAmount.text ?? "0.0") ?? 0.00
//
//        let mTotalValue =
//            totalAmount
//            - convertedAmounts
//            - submittedCreditNote
//            - submittedBankAmount
//            - submittedCreditCard
//
//        self.mBALANCEDUE.text = "\(mTotalValue)".formatPrice()
        recheckBalanceDue()
        
    }
    
    
    
    
    @IBAction func mSubmitCredit(_ sender: Any) {
        
        mGetTotalAmount()
    }
    
    
    
    func applyLinkedCartContext(_ context: LinkedCartContext?) {
        guard let context else { return }

        linkedCartId = context.linkedCartId
        linkedOrderId = context.linkedOrderId
        existingCartStatus = context.existingCartStatus
        canCreateNewCart = context.canCreateNewCart
        linkedOrderType = context.linkedOrderType

        print("========== LINKED CART CONTEXT ==========")
        print("linkedCartId =", linkedCartId)
        print("linkedOrderId =", linkedOrderId)
        print("existingCartStatus =", existingCartStatus)
        print("canCreateNewCart =", canCreateNewCart)
        print("linkedOrderType =", linkedOrderType)
        print("========================================")
    }

    private func resolveLinkedCartMetadataFromCart() {
        guard let cartItems = mCartTableData as? [Any] else { return }

        for case let item as NSDictionary in cartItems {
            func value(_ keys: [String]) -> String {
                for key in keys {
                    let raw = "\(item[key] ?? "")"
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    if !raw.isEmpty { return raw }
                }
                return ""
            }

            if linkedCartId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                linkedCartId = value(["linked_cart_id", "linkedCartId", "cart_id"])
            }
            if linkedOrderId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                linkedOrderId = value(["linked_order_id", "linkedOrderId", "order_id"])
            }
            if existingCartStatus.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                existingCartStatus = value(["existing_cart_status", "existingCartStatus"])
            }
            if linkedOrderType.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                linkedOrderType = value(["linked_order_type", "linkedOrderType"])
            }

            if let flag = item["can_create_new_cart"] {
                if let boolValue = flag as? Bool {
                    canCreateNewCart = boolValue
                } else {
                    let raw = "\(flag)".lowercased()
                    if raw == "true" || raw == "1" {
                        canCreateNewCart = true
                    } else if raw == "false" || raw == "0" {
                        canCreateNewCart = false
                    }
                }
            }

            if !linkedCartId.isEmpty {
                if item["can_create_new_cart"] == nil {
                    canCreateNewCart = false
                }
                break
            }
        }
    }

    private func appendLinkedCartMetadata(to payload: inout [String: Any]) {
        resolveLinkedCartMetadataFromCart()

        payload["linked_cart_id"] = linkedCartId
        payload["linked_order_id"] = linkedOrderId
        payload["existing_cart_status"] = existingCartStatus
        payload["can_create_new_cart"] = canCreateNewCart
        payload["linked_order_type"] = linkedOrderType

        print("========== LINKED CART PAYLOAD ==========")
        print("linked_cart_id =", linkedCartId)
        print("linked_order_id =", linkedOrderId)
        print("existing_cart_status =", existingCartStatus)
        print("can_create_new_cart =", canCreateNewCart)
        print("linked_order_type =", linkedOrderType)
        print("========================================")
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
        print("===== CustomOrderCheckout LEAVE CHECKOUT =====")
            print("linkedCartId =", linkedCartId)
            print("linkedOrderType =", linkedOrderType)
            print("canCreateNewCart =", canCreateNewCart)
        guard !isRestoringLinkedCartStatus else { return }
        let restorableOrderTypes = ["repair", "repair_order", "reserve", "custom_order", "custom order"]
        guard !linkedCartId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              canCreateNewCart == false,
              restorableOrderTypes.contains(linkedOrderType.lowercased()) else {
            navigationController?.popViewController(animated: true)
            return
        }

        isRestoringLinkedCartStatus = true
        CommonClass.showFullLoader(view: view)
        print("CALL restoreLinkedCartStatus")
        mGetData(
            url: mRestoreLinkedCartStatus,
            headers: sGisHeaders,
            params: ["cart_id": [linkedCartId]]
        ) { [weak self] response, status in
            guard let self else { return }
            CommonClass.stopLoader()
            self.isRestoringLinkedCartStatus = false

            let code = response.value(forKey: "code") as? Int ?? 0
            let message = "\(response.value(forKey: "message") ?? "Unable to restore linked cart status")"
            if status, code == 200 {
                CommonClass.showSnackBar(message: message)
            } else if code == 400,
                      message == "cart_id is required" ||
                      message == "Cart not found or previous cart status not saved" {
                CommonClass.showSnackBar(message: message)
            } else if !status {
                CommonClass.showSnackBar(message: "Unable to restore linked cart status")
            } else {
                CommonClass.showSnackBar(message: message)
            }

            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func mAddCustomer(_ sender: Any) {
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let home = storyBoard.instantiateViewController(withIdentifier: "RegisterCustomer") as? RegisterCustomer {
            self.navigationController?.pushViewController(home, animated:true)
        }
    }
    
    
    @IBAction func mBackCreditCardForm(_ sender: Any) {
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
//        guard mOrderType != "refund_order" else {
//            return
//        }
//
//        mTransactionType = "CreditCard"
//
//        mTaxInfoView.isHidden = true
//        mKeyBoardView.isHidden = true
//        mChequeDetailsView.isHidden = true
//        mCreditCardView.isHidden = true
//        mCreditNoteDetailsView.isHidden = true
//        mEditCashView.isHidden = true
//
//        // เปิด Credit Card Container
//        mCreditCardPaymentView.isHidden = false
//
//        // ซ่อน UI เดิม
//        mCreditCardBanksView.isHidden = true
//
//        // แสดง Container ที่จะฝัง SwiftUI
//        mStripeCardView.isHidden = false
//
//        // สร้าง PayPal Checkout View
//        setupPaypalView(showCreditCardButton: true)
//
//        mCardView.backgroundColor = .clear
//        mCashView.backgroundColor = UIColor(named: "themeShades")
//        mBankView.backgroundColor = UIColor(named: "themeShades")
//        mCreditNoteView.backgroundColor = UIColor(named: "themeShades")
//
//        mCashLABEL.textColor = UIColor(named: "theme6A")
//        mCreditCardLABEL.textColor = UIColor(named: "themeColor")
//        mBankLABEL.textColor = UIColor(named: "theme6A")
//        mCreditNoteLABEL.textColor = UIColor(named: "theme6A")
//
//        mCashIcon.image = UIImage(named: "cashgrey_ic")
//        mCreditNoteIcon.image = UIImage(named: "creditnotegrey_ic")
//        mCreditCardIcon.image = UIImage(named: "cardGreen")
//        mBankIcon.image = UIImage(named: "bankgrey_ic")
//
//        mCreditCardIcon.showAnimation {}
//        mCreditCardLABEL.showAnimation {}
    }
    @IBAction func mCash(_ sender: Any) {
        mPageControl.isHidden = false
        mTabBarContainer.isHidden = true
        mSelectPaymentOptionContainer.isHidden = true
        mTransactionType = "Cash"
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
        mPageControl.isHidden = true
        mChequeDetailsView.isHidden = true
        mIBSelect.isSelected = true
        mChequeSelect.isSelected = false
        mTabBarContainer.isHidden = false
        mSelectPaymentOptionContainer.isHidden = false
        mSelectedTabIB.backgroundColor = UIColor(named: "themeColor")
        mSelectedTabCheque.backgroundColor = UIColor(named: "themeExtraLightText")
        
        
        mTransactionType = "Bank"
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
        print("mCreditNot")
        mPageControl.isHidden = true
        mTabBarContainer.isHidden = true
        mSelectPaymentOptionContainer.isHidden = true
        guard mOrderType != "refund_order" else {
            return
        }
        mTransactionType = "CreditNote"
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
    
    
    
    
    
    @IBAction func mVisa(_ sender: Any) {
        mVisaView.backgroundColor = .clear
        mApplePayView.backgroundColor =   #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        mAliPayView.backgroundColor =   #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        mWeChatPayView.backgroundColor =  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        mVisaView.borderColor =  #colorLiteral(red: 0.1333333333, green: 0.5764705882, blue: 0.862745098, alpha: 1)
        mApplePayView.borderColor =   #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        mAliPayView.borderColor =   #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        mWeChatPayView.borderColor =  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        
        mCreditCardLabel.textColor =  #colorLiteral(red: 0.1333333333, green: 0.5764705882, blue: 0.862745098, alpha: 1)
        mApplePayLabel.textColor =   #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        mAliPayLabel.textColor =   #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        mWeChatPayLabel.textColor =  #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1)
        
        self.mCreditCardPaymentView.isHidden = false
        
        
        
    }
    
    
    
    @IBAction func mApplePay(_ sender: Any) {
        
        mVisaView.backgroundColor =  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        mApplePayView.backgroundColor = .clear
        mAliPayView.backgroundColor =   #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        mWeChatPayView.backgroundColor =  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        mVisaView.borderColor =   #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        mApplePayView.borderColor =  #colorLiteral(red: 0.1333333333, green: 0.5764705882, blue: 0.862745098, alpha: 1)
        mAliPayView.borderColor =   #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        mWeChatPayView.borderColor =  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        
        mCreditCardLabel.textColor =  #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        mApplePayLabel.textColor =   #colorLiteral(red: 0.1333333333, green: 0.5764705882, blue: 0.862745098, alpha: 1)
        mAliPayLabel.textColor =   #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        mWeChatPayLabel.textColor =  #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    }
    @IBAction func mAliPay(_ sender: Any) {
        
        mVisaView.backgroundColor =  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        mApplePayView.backgroundColor =   #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        mAliPayView.backgroundColor = .clear
        mWeChatPayView.backgroundColor =  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        mVisaView.borderColor =   #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        mApplePayView.borderColor =  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        mAliPayView.borderColor =   #colorLiteral(red: 0.1333333333, green: 0.5764705882, blue: 0.862745098, alpha: 1)
        mWeChatPayView.borderColor =  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        
        mCreditCardLabel.textColor =   #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        mApplePayLabel.textColor =  #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        mAliPayLabel.textColor =  #colorLiteral(red: 0.1333333333, green: 0.5764705882, blue: 0.862745098, alpha: 1)
        mWeChatPayLabel.textColor =  #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    }
    
    @IBAction func mWeChatPay(_ sender: Any) {
        
        mVisaView.backgroundColor =  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        mApplePayView.backgroundColor =   #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        mAliPayView.backgroundColor =   #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        mWeChatPayView.backgroundColor = .clear
        
        mVisaView.borderColor =   #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        mApplePayView.borderColor =  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        mAliPayView.borderColor =  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        mWeChatPayView.borderColor =  #colorLiteral(red: 0.1333333333, green: 0.5764705882, blue: 0.862745098, alpha: 1)
        
        mCreditCardLabel.textColor =   #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        mApplePayLabel.textColor =  #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        mAliPayLabel.textColor =  #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        mWeChatPayLabel.textColor =   #colorLiteral(red: 0.1333333333, green: 0.5764705882, blue: 0.862745098, alpha: 1)
    }
    
    
    
    
    
    
    @IBAction func mPressOne(_ sender: UIButton) {
        sender.showAnimation{}
        mInsertAmount(num:"1")
    }
    
    @IBAction func mPressTwo(_ sender: UIButton) {
        sender.showAnimation{}
        mInsertAmount(num:"2")
    }
    
    
    @IBAction func mPressThree(_ sender: UIButton) {
        sender.showAnimation{}
        mInsertAmount(num:"3")
    }
    
    @IBAction func mPressFour(_ sender: UIButton) {
        sender.showAnimation{}
        mInsertAmount(num:"4")
    }
    
    @IBAction func mPressFive(_ sender:UIButton) {
        sender.showAnimation{}
        mInsertAmount(num:"5")
    }
    
    @IBAction func mPressSix(_ sender: UIButton) {
        sender.showAnimation{}
        mInsertAmount(num:"6")
    }
    @IBAction func mPressSeven(_ sender: UIButton) {
        sender.showAnimation{}
        mInsertAmount(num:"7")
    }
    @IBAction func mPressEight(_ sender: UIButton) {
        sender.showAnimation{}
        mInsertAmount(num:"8")
    }
    
    @IBAction func mPressNine(_ sender: UIButton) {
        sender.showAnimation{}
        mInsertAmount(num:"9")
    }
    
    
    
    @IBAction func mPressSingleZero(_ sender: UIButton) {
        sender.showAnimation{}
        mInsertAmount(num:"0")
    }
    
    @IBAction func mPressDoubleZero(_ sender: UIButton) {
        sender.showAnimation{}
        mInsertAmount(num:"00")
    }
    
    @IBAction func mPressDot(_ sender:UIButton) {
        sender.showAnimation{}
        if mCashAmounts != "" {
            mInsertAmount(num:".")
        }
    }

    @IBAction func mSub(_ sender: Any) {
        mSUBLABEL.showAnimation{}

        guard mTransactionType == "Cash" else { return }

        // Never submit a page that has already been submitted.
        if mPages[mCurrentPage].isSubmitted {
            CommonClass.showSnackBar(message: "Amount already added!")
            return
        }

        let enteredAmount = Double(mCashAmounts) ?? 0
        guard enteredAmount > 0 else {
            CommonClass.showSnackBar(message: "Please fill valid amount!")
            return
        }

        // IMPORTANT:
        // mCashAmounts = amount typed by customer in selected currency.
        // mConvertedAmounts = amount converted to STORE currency.
        // Only the converted/store-currency amount is deducted from Balance Due.
        syncCurrentPageFromInput()

        let convertedAmount = mPages[mCurrentPage].amount
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

        mPages[mCurrentPage].isSubmitted = true
        updateSubmittedCashTotal()
        recheckBalanceDue()

        let remainingBalance =
            checkoutAmount(mBALANCEDUE.text)

        // Create the next partial-payment page only if money is still due.
        if remainingBalance > 0 {
            mPages.append(
                PaymentPage(
                    amount: 0,
                    enteredAmount: 0,
                    paymentType: "Cash",
                    paymentData: nil,
                    currency: mCurrencyName.text ?? mStoreCurrency,
                    exchangeRate: (
                        mCurrencyName.text == mStoreCurrency
                        ? 1
                        : Double(mExchangeRateValue.text ?? "") ?? 0
                    ),
                    isSubmitted: false
                )
            )

            mCurrentPage = mPages.count - 1

            UIView.animate(withDuration: 0.15,
                           animations: {
                self.mPageControl.currentPage = self.mCurrentPage
            }) { _ in
                UIView.animate(withDuration: 0.15) {
                    self.mPageControl.transform =
                        CGAffineTransform(scaleX: 1.25, y: 1.25)
                } completion: { _ in
                    UIView.animate(withDuration: 0.15) {
                        self.mPageControl.transform = .identity
                    }
                }
            }

            mCashAmount.text = ""
            mCashAmounts = ""
            mConvertedAmounts = "0"
            mConvertedAmount.text = ""
            mPageControl.isHidden = false
        }

        reloadCurrentPage()
        CommonClass.showSnackBar(message: "Amount Added Successfully!")
    }

    @IBAction func mShowTaxView(_ sender: Any) {
        mTaxCalView.isHidden = !mTaxCalView.isHidden
        
        if mTaxCalView.isHidden {
            mDropDownImage.image = UIImage(systemName: "chevron.right")
        }else{
            mDropDownImage.image = UIImage(systemName: "chevron.up")
            
        }
    }
    @IBAction func mCashAmountField(_ sender: Any) {
        
        
    }
    
    
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

            cell.mCurrencyImage.downlaodImageFromUrl(
                urlString: self.mCurrencyImageData[index]
            )
        }

        dropdown.selectionAction = { [unowned self] (index: Int, item: String) in

            // Do not modify a payment that has already been submitted.
            if self.mPages[self.mCurrentPage].isSubmitted {
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
                    self.syncCurrentPageFromInput()
                    return
                }

                // Use the backend rate directly.
                // Example: THB rate 0.03 -> 10,000 THB = 300 USD.
                self.mExchangeRateValue.text = self.mExchangeRateData[index]
            }

            self.syncCurrentPageFromInput()
        }

        dropdown.show()
    }

    @IBAction func mExchangeRate(_ sender: UITextField!) {
        guard mTransactionType == "Cash" else { return }

        // Backend rate is used directly:
        // converted amount = entered amount × exchange rate.
        syncCurrentPageFromInput()
    }

    @IBAction func mClear(_ sender: UIButton) {
        sender.showAnimation{}

        guard !mPages[mCurrentPage].isSubmitted else {
            CommonClass.showSnackBar(message: "Submitted amount cannot be cleared.")
            return
        }

        mCashAmount.text = ""
        mCashAmounts = ""
        mConvertedAmounts = "0"
        mConvertedAmount.text = ""

        syncCurrentPageFromInput()
        updateSubmittedCashTotal()
        recheckBalanceDue()
    }

    @IBAction func mDeleteCashAmount(_ sender: Any) {
        guard !mPages[mCurrentPage].isSubmitted else {
            CommonClass.showSnackBar(message: "Submitted amount cannot be edited.")
            return
        }

        guard !mCashAmounts.isEmpty else { return }

        mCashAmounts.removeLast()
        mCashAmount.text = mCashAmounts

        syncCurrentPageFromInput()

        if mCashAmounts.isEmpty {
            mConvertedAmounts = "0"
            mConvertedAmount.text = ""
        }

        updateSubmittedCashTotal()
        recheckBalanceDue()
    }

    //    func mInsertAmount(num : String){
//
//
//        mCashAmounts.insert(contentsOf: num, at: mCashAmounts.endIndex)
//        if mCashAmounts.filter({$0 == "."}).count > 1 {
//            mCashAmounts.removeLast()
//            return
//        }
//        mCashAmount.text = mCashAmounts
//
//
//
//
//        if mTransactionType == "Cash" {
//            if mExchangeRateLabel.isHidden == false {
//                if mExchangeRateValue.text != "" {
//                    let mVal = Double(mExchangeRateValue.text ?? "") ?? 0
//                    if mCashAmount.text != "" && mCashAmount.text != "."  {
//                        mConvertedAmounts = "\((Double(mCashAmounts) ?? 0) * mVal)"
//                        let mDecimalAmount = ((Double(mConvertedAmounts) ?? 0) * 100).rounded() / 100
//                        mConvertedAmount.text = "= \(self.mCurrencyName.text ?? "") \(mDecimalAmount)"
//                    }
//                }
//            }else{
//                if mCashAmount.text != "" && mCashAmount.text != "."  {
//                    mConvertedAmounts = "\(Double(mCashAmounts) ?? 0)"
//                    let mDecimalAmount = ((Double(mConvertedAmounts) ?? 0) * 100).rounded() / 100
//                    mConvertedAmount.text = "= \(self.mCurrencyName.text ?? "") \(mDecimalAmount)"
//                }
//            }
//        }
//    }

    func mInsertAmount(num: String) {
        guard !mPages[mCurrentPage].isSubmitted else {
            return
        }

        mCashAmounts.insert(contentsOf: num, at: mCashAmounts.endIndex)

        if mCashAmounts.filter({ $0 == "." }).count > 1 {
            mCashAmounts.removeLast()
            return
        }

        mCashAmount.text = mCashAmounts

        if mTransactionType == "Cash" {
            syncCurrentPageFromInput()
        }
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
        print("CustomOrderCheckout isVerified")
            if status {
                print("DEBUG_SHIPPING: Billing: \(mSelectedBillingAddress)")
                print("DEBUG_SHIPPING: Shipping: \(mSelectedShippingAddress)")
                mFinalPaymentMethod = [String: Any]()
                let mCashMethod = NSMutableDictionary()
                let mCreditNoteMethod = NSMutableDictionary()
                let mDebitedAmount = NSMutableDictionary()
                let mPayData = NSMutableDictionary()
                let mPaymentInfo = NSMutableDictionary()
                let mSummaryOrder = NSMutableDictionary()
                let mSellInfo = NSMutableDictionary()
                
                print("mSubmittedCash =", self.mSubmittedCash.text ?? "")
                print("mCreditCardMethod =", mCreditCardMethod)
                print("mIBPayment =", mIBPayment)
                
                if let mCashData = UserDefaults.standard.object(forKey: "CASHDATA") as? NSDictionary {
                    mCashMethod.setValue("\(mCashData.value(forKey: "id") ?? "")", forKey: "payment_method_id")
                    mCashMethod.setValue("cash", forKey: "Paymentmethod_type")
                    let cashText = (self.mSubmittedCash.text ?? "")
                        .replacingOccurrences(of: ",", with: "")
                        .trimmingCharacters(in: .whitespacesAndNewlines)

                    let cashAmount = Double(cashText) ?? 0.0

                    mCashMethod.setValue(cashAmount, forKey: "amount")
//                    mDebitedAmount.setValue(cashAmount, forKey: "cash")
                    mDebitedAmount.setValue(
                        checkoutAmount(mSubmittedCash.text),
                        forKey: "cash"
                    )
//                    mCashMethod.setValue(Double(self.mSubmittedCash.text ?? "") ?? 0.00, forKey: "amount")
                    print("RAW CASH =", self.mSubmittedCash.text ?? "")
                    print("PARSED CASH =", cashText)
                    print("CASH AMOUNT =", cashAmount)
                    print("===== CASH DEBUG =====")
                    print("mSubmittedCash.text =", self.mSubmittedCash.text ?? "nil")
                    print("mCashMethod amount =", self.mSubmittedCash.text ?? "nil")
                    print("mCashMethod amount =", Double(self.mSubmittedCash.text ?? "") ?? 0)
                }
                
                

                
//                mDebitedAmount.setValue(Double(self.mSubmittedCash.text ?? "") ?? 0.00, forKey: "cash")
//                mDebitedAmount.setValue(Double(self.mSubmittedBankAmount.text ?? "") ?? 0.00, forKey: "bank")
//                mDebitedAmount.setValue(Double(self.mSubmittedCreditCard.text ?? "") ?? 0.00, forKey: "credit_card")
//                mDebitedAmount.setValue(Double(self.mSubmittedCreditNote.text ?? "") ?? 0.00, forKey: "credit_notes")
                
                mDebitedAmount.setValue(
                    checkoutAmount(mSubmittedBankAmount.text),
                    forKey: "bank"
                )

                mDebitedAmount.setValue(
                    checkoutAmount(mSubmittedCash.text),
                    forKey: "cash"
                )

                mDebitedAmount.setValue(
                    checkoutAmount(mSubmittedCreditCard.text),
                    forKey: "credit_card"
                )

                mDebitedAmount.setValue(
                    checkoutAmount(mSubmittedCreditNote.text),
                    forKey: "credit_notes"
                )
                
                
                mSummaryOrder.setValue(mLabourPoints, forKey: "labour")
                mSummaryOrder.setValue(mShippingPoints, forKey: "shipping")
                mSummaryOrder.setValue(mLoyaltyPoints, forKey: "loyalty_points")
                mSummaryOrder.setValue(mTaxAmount, forKey: "tax_amount")
                mSummaryOrder.setValue(mTaxAmountInt, forKey: "tax_amount_int")
                mSummaryOrder.setValue(mTaxInPercent, forKey: "tax_prect")
                mSummaryOrder.setValue(mTaxTypeIE, forKey: "tax_type")
                mSummaryOrder.setValue(mTaxDiscountAmount, forKey: "discount")
                mSummaryOrder.setValue(mTaxDiscountPercent, forKey: "discount_percent")
                mSummaryOrder.setValue(mCustomerId, forKey: "customer_id")
                
                var itemTotal: Double = 0

                if let cartArray = mCartTableData as? [[String: Any]] {

                    for item in cartArray {

                        let qty = Double("\(item["Qty"] ?? 1)") ?? 1

                        // Exchange ใช้ perProductPrice
                        let priceKey = (mOrderType == "exchange_order") ? "perProductPrice" : "price"

                        let price = Double("\(item[priceKey] ?? 0)") ?? 0

                        itemTotal += qty * price
                    }
                }
                
                let labour = Double("\(mLabourPoints)") ?? 0
                let shipping = Double("\(mShippingPoints)") ?? 0
                let loyalty = Double("\(mLoyaltyPoints)") ?? 0
                let discount = Double("\(mTaxDiscountAmount)") ?? 0
                let taxInclusive = Double("\(mTaxAmountInt)") ?? 0

                var subTotal = itemTotal
                subTotal += labour
                subTotal += shipping
                subTotal += loyalty
                subTotal -= discount

                if mTaxTypeIE == "Inclusive" {
                    subTotal -= taxInclusive
                }
                
                mSummaryOrder.setValue(subTotal, forKey: "Sub_Total")
                mSummaryOrder.setValue("", forKey: "sales_person_id")
                
                print("subTotal =", subTotal)
                print("mCartTotalAmount =", mCartTotalAmount)
                print("mTaxAmountInt =", mTaxAmountInt)
                print("mTaxTypeIE =", mTaxTypeIE)
                print("mLabourPoints =", mLabourPoints)
                print("mShippingPoints =", mShippingPoints)
                print("mTaxDiscountAmount =", mTaxDiscountAmount)
                
                let finalRemark = self.mRemark.isEmpty ? (UserDefaults.standard.string(forKey: "cRemark") ?? "") : self.mRemark
                mSummaryOrder.setValue(finalRemark, forKey: "remark")
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
//                print("mSummaryOrder =", mSummaryOrder)
                print("mIBPayment =", mIBPayment)
                print("mBankPayment =", mBankPayment)
                print("mCreditCardMethod =", mCreditCardMethod)
                print("mCashMethod =", mCashMethod)
                mPayData.setValue(mCashMethod, forKey: "cash")
                mPayData.setValue(mIBPayment, forKey: "IB")
                mPayData.setValue(mBankPayment, forKey: "bank")
                mPayData.setValue(mCreditCardMethod, forKey: "credit_card")
                mPayData.setValue(mCreditNoteMethod, forKey: "credit_note")
                mPayData.setValue(mGiftCardMethod, forKey: "gift_card")
                
                let formatter = ISO8601DateFormatter()
                formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                let currentDateString = formatter.string(from: Date())
                
                if self.mOrderType == "gift_card_order" {
                    if let cartArray = mCartTableData as? [[String: Any]] {
                        let updatedCart = cartArray.map { item -> [String: Any] in
                            var giftCardDetails: [String: Any] = [:]
                            giftCardDetails["amount"] = item["amount_forcalculation"]
                            giftCardDetails["card_no"] = item["card_no"]
                            giftCardDetails["name"] = item["name"]
                            giftCardDetails["expire_date"] = item["expire_date"]
                            giftCardDetails["remark"] = item["remark"]
                            giftCardDetails["barcode"] = item["barcode"]
                            giftCardDetails["qr_code"] = item["qr_code"]
                            
                            return [
                                "_id": item["custom_cart_id"] ?? "",
                                "custom_cart_id": item["custom_cart_id"] ?? "",
                                "delivery_date": currentDateString,
                                "giftCard_details": giftCardDetails
                            ]
                        }
                        for item in updatedCart {
                            print("ORDER TYPE =", item["order_type"] ?? "")
                            print("STATUS TYPE =", item["status_type"] ?? "")
                        }
                        mSellInfo.setValue(updatedCart, forKey: "cart")
                    }
                } else {
                    if let cartArray = mCartTableData as? [[String: Any]] {
                        let updatedCart = cartArray.map { item -> [String: Any] in

                            var updatedItem = item

                            if let deliveryDate = item["delivery_date"] as? String,
                               !deliveryDate.isEmpty {

                                let inputFormatter = DateFormatter()
                                inputFormatter.locale = Locale(identifier: "en_US_POSIX")
                                inputFormatter.dateFormat = "dd/MM/yyyy"

                                if let date = inputFormatter.date(from: deliveryDate) {

                                    let outputFormatter = ISO8601DateFormatter()
                                    outputFormatter.timeZone = TimeZone(secondsFromGMT: 0)
                                    outputFormatter.formatOptions = [
                                        .withInternetDateTime,
                                        .withFractionalSeconds
                                    ]

                                    updatedItem["delivery_date"] = outputFormatter.string(from: date)

                                } else {

                                    updatedItem["delivery_date"] = currentDateString
                                }

                            } else {

                                updatedItem["delivery_date"] = currentDateString
                            }
                            updatedItem["status_type"] = self.mOrderType
                            updatedItem["order_type"] = self.mOrderType
                            
                            print("ISO DELIVERY DATE =", updatedItem["delivery_date"] ?? "")
                            return updatedItem
                        }
                        print("DEBUG UPDATED CART =", updatedCart)
                        for item in updatedCart {
                            print("ORDER TYPE =", item["order_type"] ?? "")
                            print("STATUS TYPE =", item["status_type"] ?? "")
                        }
                        mSellInfo.setValue(updatedCart, forKey: "cart")
                    } else {
                        
                        mSellInfo.setValue(mCartTableData, forKey: "cart")
                    }
                }
//                } else {
//                    print("DEBUG_CART_DATA CustomOrderCheckout = \(mCartTableData)")
//                    mSellInfo.setValue(mCartTableData, forKey: "cart")
//                }
                
                mSellInfo.setValue(mSummaryOrder, forKey: "summary_order")
                mSellInfo.setValue(mOrderType, forKey: "status_type")
                mSellInfo.setValue(Double(mCartTotalAmount) ?? 0.00, forKey: "totalamount")
                print("mDebitedAmount =", mDebitedAmount)
                mPaymentInfo.setValue(mDebitedAmount, forKey: "debited_amount")
                print("mPayData =", mPayData)
                mPaymentInfo.setValue(mPayData, forKey: "pay_data")
                
                print("========== FINAL PAYPAL BEFORE SAVE ==========")
                
                print("mIBPayment =", mIBPayment)
                print("mBankPayment =", mBankPayment)
                print("mCreditCardMethod =", mCreditCardMethod)
                print("mCashMethod =", mCashMethod)
                print("PAY DATA =", mPayData)
                mPaymentInfo.setValue("", forKey: "balance_due")
                mPaymentInfo.setValue("", forKey: "balance_deposit")
                
                print("PAY payment_info = \(mPaymentInfo)")
                print("========== CHECK REPAIR DESIGN ==========")

                for case let item as NSDictionary in self.mCartTableData {

                    print("SKU =", item["SKU"] ?? "")

                    print("repair_design =")

                    print(item["repair_design"] ?? "NO REPAIR DESIGN")

                    print("--------------------------------")
                }
                mFinalPaymentMethod = ["sell_info": mSellInfo, "payment_info":mPaymentInfo,"transaction_date": "","customer_id":self.mCustomerId,"sales_person_id":"","byMobile":true,"order_type":self.mOrderType , "order_id":self.mOrderId]

                // Send linked-cart state on the actual final checkout request.
                self.appendLinkedCartMetadata(to: &mFinalPaymentMethod)

                
                let mQuotationId = UserDefaults.standard.string(forKey: "quotationId") ?? ""
                if !mQuotationId.isEmpty {
                    mFinalPaymentMethod["quatation_id"] = mQuotationId
                }
                
                if !mSelectedBillingAddress.isEmpty || !mSelectedShippingAddress.isEmpty {
                    mFinalPaymentMethod["shipping_info"] = [
                        "billing_address": self.mSelectedBillingAddress,
                        "shipping_address": self.mSelectedShippingAddress
                    ]
                }
                mFinalPaymentMethod["remark"] = finalRemark
                mFinalPaymentMethod["note"] = self.mNote
                
//                if self.mOrderType == "custom_order" {
//
//                    var deliveryDate = ""
//
//                    for case let item as NSDictionary in self.mCartTableData {
//
//                        let date = "\(item.value(forKey: "delivery_date") ?? "")"
//
//                        if !date.isEmpty {
//                            deliveryDate = date
//                            break
//                        }
//                    }
//
//                    self.mFinalPaymentMethod["delivery_date"] = deliveryDate
//
//                    print("DEBUG ROOT DELIVERY DATE =", deliveryDate)
//                }

                print("========== FINAL SAVE CUSTOM ORDER PAYLOAD ==========")
                print(self.mFinalPaymentMethod)
                print("=====================================================")
                
                if self.mOrderType == "reserve" {

                    if let cartItems = self.mCartTableData as? NSArray {

                        for item in cartItems {

                            if let data = item as? NSDictionary {

                                let crossLocationId =
                                    "\(data.value(forKey: "crossLocationId") ?? "")"

                                let crosslocation =
                                    data.value(forKey: "crosslocation") as? Bool ?? false

                                if !crossLocationId.isEmpty {

                                    mFinalPaymentMethod["crossLocationId"] = crossLocationId
                                    mFinalPaymentMethod["crosslocation"] = crosslocation

                                    break
                                }
                            }
                        }
                    }
                }
                print("========== NOTE DEBUG ==========")
                print("ORDER TYPE =", self.mOrderType)
                print("mNote =", self.mNote)
                print("ROOT NOTE =", self.mFinalPaymentMethod["note"] ?? "nil")
                print("ROOT DELIVERY DATE =", self.mFinalPaymentMethod["delivery_date"] ?? "nil")
                if let sellInfo = self.mFinalPaymentMethod["sell_info"] as? NSDictionary,
                   let cart = sellInfo["cart"] as? NSArray {

                    print("========== CART ==========")

                    for case let item as NSDictionary in cart {
                        print(item)
                    }

                    print("==========================")
                }
                print("================================")
                print("DEBUG_FINAL_SAVE_CUSTOM_ORDER_PAYLOAD =")
                print(mFinalPaymentMethod)

                if mOrderType == "reserve" {
                    print("========== RESERVE LINKED CART CHECK ==========")
                    print("linked_cart_id =", mFinalPaymentMethod["linked_cart_id"] ?? "nil")
                    print("linked_order_id =", mFinalPaymentMethod["linked_order_id"] ?? "nil")
                    print("existing_cart_status =", mFinalPaymentMethod["existing_cart_status"] ?? "nil")
                    print("can_create_new_cart =", mFinalPaymentMethod["can_create_new_cart"] ?? "nil")
                    print("linked_order_type =", mFinalPaymentMethod["linked_order_type"] ?? "nil")
                    print("===============================================")
                }
                if mOrderType == "custom_order" ||  mOrderType == "mix_and_match" || mOrderType == "pos_order" ||  mOrderType == "repair_order" ||  mOrderType == "exchange_order" || mOrderType == "gift_card_order" ||  mOrderType == "refund_order" || mOrderType == "reserve" {
                    print("========== FINAL PAYLOAD ==========")
                    print(mFinalPaymentMethod)
                    print("===================================")
                    CommonClass.showFullLoader(view: self.view)
                    print("========== SAVE CUSTOM ORDER FINAL PAYLOAD ==========")
                    
                    print("FINAL PAYMENT INFO =", mPaymentInfo)
                    print("FINAL REQUEST =", mFinalPaymentMethod)
                    print(mFinalPaymentMethod)
                    mGetData(url: mFinalCheckoutCustomOrder, headers: sGisHeaders, params: mFinalPaymentMethod) { response , status in
                        CommonClass.stopLoader()
                        print("mFinalCheckoutCustomOrder  = \(response)")
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
//                                    if self.mOrderType == "refund_order" {
                                        mCompletePayment.mType = self.mOrderType
//                                    }
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
                                        "shipping_address": self.mSelectedShippingAddress
                                    ]
                                    self.navigationController?.pushViewController(mCompletePayment, animated:true)
                                }
                            }
                        }
                    }
                }
            }
        }
    @IBAction func mPayNow(_ sender: UIButton) {
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
    
    @IBAction func mStartSearch(_ sender: Any) {
        
    }
    @IBAction func mEndSearch(_ sender: Any) {
        
    }
    @IBAction func mEditChanged(_ sender: Any) {
        
        let value = mCustomerSearch.text?.count ?? 0
        if value != 0 {
            
        }else {
            
            if mCustomerSearch.text  == "" {
                mCustomerSearchTableView.removeFromSuperview()
            }
            self.view.endEditing(true)
            
        }
        
        
    }
    @IBAction func mValueChanged(_ sender: UITextField!) {
        
        
    }
    @IBAction func mEditCustSearch(_ sender: Any) {
        
    }
    
    
    @IBAction func mLabourAmount(_ sender: UITextField) {
        if sender.text == "" {
            sender.text = "0"
            calculateTax()
        }else{
            calculateTax()
            
        }
    }
    
    
    @IBAction func mShippingAmount(_ sender: UITextField) {
        
        if sender.text == "" {
            sender.text = "0"
            calculateTax()
        }else{
            calculateTax()
            
            
        }
    }
    
    @IBAction func mDiscountPercent(_ sender: UITextField) {
        var mCount = Int()
        if sender.text == "" {
            mCount = 0
        }else{
            mCount = Int(Double(sender.text ?? "") ?? 0)
        }
        if sender.text == "" || sender.text == "0"  || mCount > 100 {
            sender.text = "0"
            self.mDiscountAmounts.text = "0"
            calculateTax()
        }else {
            self.mDiscountAmounts.text = "\(calculatePercentage(value: Double(mTotalAm) ?? 0, percent: Double(sender.text ?? "") ?? 0 ))"
            calculateTax()
        }
    }
    
    @IBAction func mDiscountAmount(_ sender: UITextField) {
        if sender.text == "" {
            
            sender.text = "0"
            self.mDiscountPercents.text = "0"
            
            calculateTax()
        }else{
            
            let mPercent = (Double(sender.text ?? "") ?? 0) / (Double(mTotalAm) ?? 0) * 100
            self.mDiscountPercents.text = String(format: "%.2f", mPercent)
            calculateTax()
            
        }
    }
    
    
    func calculatePercentage(value:Double,percent: Double) -> Double {
        let val = value * percent
        return val/100.00
    }
    func calculateInclusiveTax(value:Double,percent: Double) -> Double {
        
        let val = value * percent
        return val/(100.00 + (Double(mTaxP) ?? 0))
    }
    func calculateExclusiveTax(value:Double,percent: Double) -> Double {
        let val = value * percent
        return val/100.00
    }
    
    func calculateTax(){
        var mAmount =  Double()
        
        var mDiscountA = Double(self.mDiscountAmounts.text ?? "") ?? 0
        var mLabour = Double(self.mLabourCharge.text ?? "") ?? 0
        var mShipping = Double(self.mShippingCharge.text ?? "") ?? 0
        mAmount = mLabour + mShipping
        
        if mTaxType.lowercased() == "inclusive" {
            mTotalDiscountTx.text = mDiscountAmounts.text
            mTotalTx.text = "\((mAmount + (Double(mTotalAm) ?? 0)) )"
            let totalTax = Double(mTotalTx.text ?? "") ?? 0
            let totalDiscount = Double(mDiscountAmounts.text ?? "") ?? 0
            let taxAmountTx = Double(mTaxAmountTx.text?.replacingOccurrences(of: ",", with: "") ?? "") ?? 0
            mTaxAmountTx.text = String(format:"%.02f",locale:Locale.current,calculateInclusiveTax(value: totalTax - totalDiscount, percent: Double(mTaxP) ?? 0))
            mSubTotalTx.text = String(format:"%.02f",locale:Locale.current,totalTax - totalDiscount - taxAmountTx )
            
            mFinalTaxAmount.text = mTaxAmountTx.text
            mTOTALAMOUNT.text = "\((mAmount + (Double(mTotalAm) ?? 0) - mDiscountA))"
            
//            let totalAmount = Double(self.mTOTALAMOUNT.text?.replacingOccurrences(of: ",", with: "") ?? "") ?? 0.0
//            let submittedCash = Double(mSubmittedCash.text ?? "") ?? 0.0
//            let submittedCreditNote = Double(mSubmittedCreditNote.text ?? "") ?? 0.0
//            let submittedBankAmount = Double(mSubmittedBankAmount.text ?? "") ?? 0.0
//            let submittedCreditCard = Double(mSubmittedCreditCard.text ?? "") ?? 0.0
//
//            let mTotalValue = totalAmount - submittedCash - submittedCreditNote - submittedBankAmount - submittedCreditCard
//
//            self.mBALANCEDUE.text = "\(mTotalValue)".formatPrice()
//            let totalAmount = Double(self.mTOTALAMOUNT.text?.replacingOccurrences(of: ",", with: "") ?? "") ?? 0.0
//            let submittedCash = Double(self.mSubmittedCash.text ?? "") ?? 0.0
//            let submittedCreditNote = Double(self.mSubmittedCreditNote.text ?? "") ?? 0.0
//            let submittedBankAmount = Double(self.mSubmittedBankAmount.text ?? "") ?? 0.0
//            let submittedCreditCard = Double(self.mSubmittedCreditCard.text ?? "") ?? 0.0
//
////                    let mTotalValue = totalAmount - submittedCash - submittedCreditNote - submittedBankAmount - submittedCreditCard
//            let convertedAmounts = Double(self.mCashAmount.text ?? "0.0") ?? 0.00
//
//            let mTotalValue =
//                totalAmount
//                - convertedAmounts
//                - submittedCreditNote
//                - submittedBankAmount
//                - submittedCreditCard
//
//            self.mBALANCEDUE.text = "\(mTotalValue)".formatPrice()
            recheckBalanceDue()
        }else{
            mTotalDiscountTx.text = mDiscountAmounts.text
            mTotalTx.text = "\((mAmount + (Double(mTotalAm) ?? 0)) )"
            
            let totalTx = Double(mTotalTx.text ?? "") ?? 0.0
            let discountAmounts = Double(mDiscountAmounts.text ?? "") ?? 0.0
            let taxPercent = Double(mTaxP) ?? 0.0
            
            mTaxAmountTx.text = String(format: "%.02f", locale: Locale.current, calculateExclusiveTax(value: totalTx - discountAmounts, percent: taxPercent))
            
            mSubTotalTx.text = String(format:"%.02f",locale:Locale.current, totalTx - discountAmounts)
            mFinalTaxAmount.text = mTaxAmountTx.text
            
            let subTotal = Double(mSubTotalTx.text?.replacingOccurrences(of: ",", with: "") ?? "") ?? 0.0
            let taxAmount = Double(mTaxAmountTx.text?.replacingOccurrences(of: ",", with: "") ?? "") ?? 0.0
            
            mTOTALAMOUNT.text = "\(subTotal + taxAmount)".formatPrice()
            
//            let totalAmount = Double(self.mTOTALAMOUNT.text?.replacingOccurrences(of: ",", with: "") ?? "") ?? 0.0
//            let submittedCash = Double(mSubmittedCash.text ?? "") ?? 0.0
//            let submittedCreditNote = Double(mSubmittedCreditNote.text ?? "") ?? 0.0
//            let submittedBankAmount = Double(mSubmittedBankAmount.text ?? "") ?? 0.0
//            let submittedCreditCard = Double(mSubmittedCreditCard.text ?? "") ?? 0.0
//
//            let balanceDue = totalAmount - submittedCash - submittedCreditNote - submittedBankAmount - submittedCreditCard
//            mBALANCEDUE.text = "\(balanceDue)".formatPrice()
//            let totalAmount = Double(self.mTOTALAMOUNT.text?.replacingOccurrences(of: ",", with: "") ?? "") ?? 0.0
//            let submittedCash = Double(self.mSubmittedCash.text ?? "") ?? 0.0
//            let submittedCreditNote = Double(self.mSubmittedCreditNote.text ?? "") ?? 0.0
//            let submittedBankAmount = Double(self.mSubmittedBankAmount.text ?? "") ?? 0.0
//            let submittedCreditCard = Double(self.mSubmittedCreditCard.text ?? "") ?? 0.0
//
////                    let mTotalValue = totalAmount - submittedCash - submittedCreditNote - submittedBankAmount - submittedCreditCard
//            let convertedAmounts = Double(self.mCashAmount.text ?? "0.0") ?? 0.00
//
//            let mTotalValue =
//                totalAmount
//                - convertedAmounts
//                - submittedCreditNote
//                - submittedBankAmount
//                - submittedCreditCard
//
//            self.mBALANCEDUE.text = "\(mTotalValue)".formatPrice()
            recheckBalanceDue()
            
        }
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let value = textField.text
//        let value = Double(textField.text ?? "0") ?? 0//textField.text
//        let grand = Double(self.mCartTotalAmount.replacingOccurrences(of: ",", with: "")) ?? 0
//
//            if value > grand {
//
//                textField.text =
//                    String(format: "%.2f", grand)
//
//            }
    }
    
    func mFetchCreditNoteData(value: String){
        
        let mLocation = UserDefaults.standard.string(forKey: "location")
        
        let urlPath =  mPOSCreditNote
        let params:[String:Any] = ["customer_id":mCustomerId]
        
        
        
        if Reachability.isConnectedToNetwork() == true {
            AF.request(urlPath, method:.post, parameters:params, encoding: JSONEncoding.default, headers: sGisHeaders).responseJSON
            { response in
                
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
                        self.mCreditNoteData = NSMutableArray()
                        
                        if let mData = jsonResult.value(forKey: "data") as? NSArray {
                            
                            self.mCreditNoteData = NSMutableArray(array: mData)
                            self.mCreditNoteTable.delegate = self
                            self.mCreditNoteTable.dataSource = self
                            self.mCreditNoteTable.reloadData()
                            var mAmount = [Double]()
                            for item in mData {
                                let value = item as? NSDictionary
                                let mCData = NSMutableDictionary()
                                
                                mAmount.append(Double("\(value?.value(forKey: "amount") ?? "0")") ?? 0)
                                
                                mCData.setValue("\(value?.value(forKey: "amount") ?? "0")", forKey: "amount")
                                self.mTotalCreditAmount.text = String(format:"%.02f",locale:Locale.current,mAmount.reduce(0, {$0 + $1}))
                                
                                self.mAmountData.add(mCData)
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
    
    func PayNow(){
        
        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
        
        var urlPath =  ""
        let mSalesPersonId =  UserDefaults.standard.string(forKey: "SALESPERSONID")
        let mCustomerId =  UserDefaults.standard.string(forKey: "CUSTOMERID")
        let mCustomerName =  UserDefaults.standard.string(forKey: "CUSTOMERNAME")
        let mLocation = UserDefaults.standard.string(forKey: "location")
        
        var params = [String:Any]()
        let totalCash =
        mPages
        .filter { $0.paymentType == "Cash" && $0.isSubmitted }
        .reduce(0) { $0 + $1.amount }
        
        mSubmittedCash.text = String(format: "%.2f", totalCash).formatPrice()
        
        if mOrderType == "Sales Order" {
            
            urlPath =  mPOSpay
            params = ["Customer_name":mCustomerName ?? "",
                      "tax_rate":self.mTaxVal.text ?? "",
                      "tax_type":self.mTaxType,
                      "tax_label":self.mTaxLabel,
                      "taxAmount":self.mTaxAmountTx.text ?? "",
                      "tableToptotalRowAmount":self.mTotalWithDiscount,
                      "location_id":mLocation ?? "",
                      "totalAmountsat_data":self.mTotalTx.text ?? "",
                      "totalDiscountsata":self.mTotalDiscountTx.text ?? "",
                      "SubtotalAmountsat_data":self.mSubTotalTx.text ?? "",
                      "taxAmount_value":self.mTaxAmountTx.text ?? "",
                      "finaltotalAmountsat_data":self.mTOTALAMOUNT.text ?? "",
                      "pos_Labourdata":self.mLabourCharge.text ?? "",
                      "pos_Shippingdata":self.mShippingCharge.text ?? "",
                      
                      "POS_Final_Cash_Amount_value":self.mSubmittedCash.text ?? "",
                      "POS_Final_CreditCardAmount_value":self.mSubmittedCreditCard.text ?? "",
                      "POS_Final_Bank_Amount_value":self.mSubmittedBankAmount.text ?? "" ,
                      "POS_Final_bank_Payment_cheque_information_json": self.mChequeData,
                      
                      "paymentMethodId":self.mFinalPaymentMethod,
                      "couponAmount":self.mGiftFinalTotalAmount,
                      
                      "POS_Final_CreditNote_Amount_value":"",
                      "POS_Final_CreditNote_Amount_arr": self.mCreditDataMerged,
                      "POS_Final_CreditNote_Amount":"\(self.mSubmittedCreditNote.text ?? "")",
                      
                      "finalAmountsat_side_DueAmount":self.mBALANCEDUE.text ?? "",
                      "salesPersonId":mSalesPersonId ?? "",
                      "Customer_id":mCustomerId ?? "",
                      "Order_type":"Sales Order",
                      "Remark":"",
                      "cartTableData":self.mCartTableData ]
            
            
        }else if mOrderType == "custom_oreder" {
            urlPath =  mPOSpay
            params = ["Customer_name":mCustomerName,
                      "tax_rate":"",
                      "tax_type":"",
                      "tax_label":"",
                      "taxAmount":"",
                      "tableToptotalRowAmount":self.mTotalWithDiscount,
                      "location_id":mLocation ?? "",
                      "totalAmountsat_data":"",
                      "totalDiscountsata":"",
                      "SubtotalAmountsat_data":"",
                      "taxAmount_value":"",
                      "finaltotalAmountsat_data":self.mTOTALAMOUNT.text ?? "",
                      "pos_Labourdata":"",
                      "pos_Shippingdata":"",
                      "POS_Final_Cash_Amount_value":self.mSubmittedCash.text ?? "",
                      "POS_Final_CreditCardAmount_value":self.mSubmittedCreditCard.text  ?? "",
                      
                      "POS_Final_Bank_Amount_value":self.mSubmittedBankAmount.text ?? "",
                      
                      "POS_Final_bank_Payment_cheque_information_json": self.mChequeData,
                      "paymentMethodId":self.mFinalPaymentMethod,
                      
                      "POS_Final_CreditNote_Amount_value":"",
                      
                      "finalAmountsat_side_DueAmount":self.mBALANCEDUE.text ?? "",
                      "salesPersonId":mSalesPersonId ?? "",
                      "Customer_id":mCustomerId ?? "",
                      "Order_type":"Custom Order",
                      "Remark":self.mRemark,
                      "cartTableData":self.mCartTableData]
            
        }else if self.mOrderType == "Repair Order" {
            urlPath =  mSubmitRepairDesign
            
            params = [
                "POS_Location_id":mLocation ?? "",
                "totalAmount":self.mTOTALAMOUNT.text ?? "",
                "cash_amount":self.mSubmittedCash.text ?? "",
                "creditCard_amount":"",
                "bank_amount":"",
                "dueAmount":self.mBALANCEDUE.text ?? "",
                "salesPerson_id":mSalesPersonId ?? "",
                "CustomerID":mCustomerId ?? "",
                "POS_Final_CreditCardAmount_value":self.mSubmittedCreditCard.text ?? "",
                "POS_Final_Bank_Amount_value":self.mSubmittedBankAmount.text ?? "",
                "POS_Final_bank_Payment_cheque_information_json": self.mChequeData,
                "paymentMethodId":self.mFinalPaymentMethod,
                "Remark":self.mRemark,
                "repair_cart_data":self.mCartTableData ]
            
        }
        
        if "\(UserDefaults.standard.string(forKey: "isPinEnable") ?? "")" == "1" {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            if let mPin = storyBoard.instantiateViewController(withIdentifier: "LoginWithPin") as? LoginWithPin {
                mPin.mKey = "1"
                mPin.mParams = params
                mPin.mUrl = urlPath
                if self.mOrderType == "Sales Order" {
                    mPin.mType = "pos"
                }
                if self.mOrderType == "Custom Order" {
                    mPin.mType = "custom"
                }
                if self.mOrderType == "Repair Order" {
                    mPin.mType = "repair"
                }
                self.navigationController?.pushViewController( mPin, animated:true)
            }
        }else{
            mFinalPay(urlPath: urlPath, params: params)
        }
        
    }
    
    func mFinalPay(urlPath : String , params: [String:Any]){
        
        if Reachability.isConnectedToNetwork() == true {
            AF.request(urlPath, method:.post, parameters:params, encoding :JSONEncoding.default, headers: sGisHeaders).responseJSON
            { response in
                
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
                        let pdfURl = "\(jsonResult.value(forKey: "pdf_url") ?? "")"
                        UserDefaults.standard.setValue(pdfURl, forKey: "reportAPI")
                        self.mGenerateReport(id:pdfURl , jsonResult : jsonResult)
                        
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
    
    func mGenerateReport(id : String, jsonResult : NSDictionary){
        
        CommonClass.showFullLoader(view: self.view)
        
        let urlPath =  id
        
        if Reachability.isConnectedToNetwork() == true {
            AF.request(urlPath, method:.post, parameters:nil, headers: sGisHeaders2).responseJSON
            { response in
                CommonClass.stopLoader()
                if(response.error != nil){
                    
                    CommonClass.showSnackBar(message: "OOP's something went wrong!")
                    
                    
                    
                }else{
                    guard let jsonData = response.data else {
                        CommonClass.showSnackBar(message: "OOP's something went wrong!")
                        return
                    }
                    
                    let json = try? JSONSerialization.jsonObject(with: jsonData, options: [])
                    
                    guard let jsonVal = json as? NSDictionary else {
                        CommonClass.showSnackBar(message: "OOP's something went wrong!")
                        return
                    }
                    
                    UserDefaults.standard.set("", forKey: "CUSTOMERID")
                    UserDefaults.standard.set("", forKey: "SALESPERSONID")
                    CommonClass.showSnackBar(message: "Payment Successful")
                    
                    if let email = jsonVal.value(forKey: "email") {
                        UserDefaults.standard.setValue("\(email)", forKey: "mailInvoice")
                    }
                    
                    UserDefaults.standard.setValue(jsonVal.value(forKey: "pdf_url") as? String, forKey: "report")
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    if let mCompletePayment = storyBoard.instantiateViewController(withIdentifier: "CompletePayment") as? CompletePayment {
                        
                        //Sales Order Custom Order Repair Order
                        if self.mOrderType == "Sales Order" {
                            mCompletePayment.mType = "pos_order"//"pos"
                        }
                        if self.mOrderType == "Custom Order" {
                            mCompletePayment.mType = "custom_order"//"custom"
                        }
                        if self.mOrderType == "Repair Order" {
                            mCompletePayment.mType = "repair_order"//"repair"
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
        }else{
        }
        
        
    }
    
    func mSetupTableView(frame: CGRect) {
        if mCustomerSearch.text != "" {
            let nib = UINib(nibName: "CustomerSearchList", bundle: nil)
            let tableView = nib.instantiate(withOwner: self, options: nil)[0] as? UIView
            let mBarHeight:CGFloat = UIApplication.shared.statusBarFrame.size.height
            let mDisplayWidth: CGFloat = self.view.frame.width
            let mDisplayHeight: CGFloat = self.view.frame.height
            
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
        
        var constraints: [NSLayoutConstraint] = []
        
    }
    
    func mGetCurrency(){
        
        let urlPath = mGetCurrencies
        
        
        if Reachability.isConnectedToNetwork() == true {
            AF.request(urlPath, method:.post, parameters:nil, headers: sGisHeaders2).responseJSON
            { response in
                
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
                    
                    if let data = jsonResult.value(forKey: "data") as? NSArray {
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
    
    // MARK: Generate QR Code -:
    
    func mGenerateQRCode() {
        let urlPath = mGetQRCode
        let mParams: [String: Any] = [
            "payment_id": mChequePaymentId,
            "amount": mEnterAmountText.text ?? "0",
            "customerId": mCustomerId
        ]
        
        print(mParams, "check data")
        
        if Reachability.isConnectedToNetwork() {
            AF.request(urlPath, method: .post, parameters: mParams, headers: sGisHeaders2).responseJSON { response in
                print(response, "check response")
                self.view.endEditing(true)
                switch response.result {
                case .success(let value):
                    // Ensure the response is a dictionary
                    guard let json = value as? [String: Any] else {
                        CommonClass.showSnackBar(message: "Failed to parse response.")
                        return
                    }
                    
                    if let code = json["code"] as? Int, code == 200,
                       let data = json["data"] as? [String: Any] {
                        
                        // Extract client reference ID from `data`
                        self.mClientReferenceID = data["client_reference_id"] as? String ?? ""
                        print(self.mClientReferenceID, "client reference ID")
                        
                        // Decode Base64-encoded QR code string
                        if let qrCodeString = data["qrCode"] as? String,
                           let base64String = qrCodeString.components(separatedBy: ",").last,
                           let qrCodeData = Data(base64Encoded: base64String),
                           let qrCodeImage = UIImage(data: qrCodeData) {
                            
                            print("Successfully decoded QR Code image.")
                            
                            DispatchQueue.main.async {
                                self.qrCodeView.removeFromSuperview()
                                self.qrCodeView.delegate = self
                                self.qrCodeView.mQRImage.image = qrCodeImage
                                self.view.addSubview(self.qrCodeView)
                                self.qrCodeView.startTimer()
                                self.mGetPayementStatus()
                            }
                        } else {
                            CommonClass.showSnackBar(message: "Failed to decode QR code.")
                        }
                    } else {
                        let message = json["message"] as? String ?? "Oops, something went wrong!"
                        CommonClass.showSnackBar(message: message)
                    }
                    
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                    CommonClass.showSnackBar(message: error.localizedDescription)
                }
            }
        } else {
            CommonClass.showSnackBar(message: "No Internet Connection")
        }
    }
    
    
    
    
    
    // Mark:- Stripe Calling Function -:
    
    func authenticationPresentingViewController() -> UIViewController {
        return self
    }
    
    
    func StripePayment() {
        // Configure Stripe with the publishable key
        StripeManager.shared.configureStripe(publishableKey: mStripPublishKey)
        StripeManager.shared.fetchPaymentIntentDetails(clientSecret: self.mClientSecreat)
        
        print("Client Secret: \(mClientSecreat), Publishable Key: \(mStripPublishKey)")
        
        // Configure the PaymentSheet
        var configuration = PaymentSheet.Configuration()
        
        // Create the PaymentSheet instance using the provided client secret
        let paymentSheet = PaymentSheet(paymentIntentClientSecret: mClientSecreat, configuration: configuration)
        
        // Present the PaymentSheet UI
        DispatchQueue.main.async {
        paymentSheet.present(from: self) { paymentResult in
          
                switch paymentResult {
                case .completed:
                    
                    if let paymentSuccessView = PaymentSuccessView.loadFromNib() {
                        paymentSuccessView.frame = self.view.bounds
                        paymentSuccessView.setAmount("Amount: \(self.mCreditFillAmount.text ?? "")")
                        
                        if let successImage = UIImage(named: "successAmount") {
                            paymentSuccessView.setImage(successImage)
                        }
                        
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
                    mCreditCardData.setValue(self.mPaymentIntentID, forKey: "transID")
                    mCreditCardData.setValue(self.mClientReferenceID, forKey: "client_reference_id")
                    
                    
                    self.mCreditCardMethod.add(mCreditCardData)
                    
                    var mAmounts = [Double]()
                    for i in self.mCreditCardMethod {
                        if let mData = i as? NSDictionary,
                           let amount = mData.value(forKey: "amount") {
                            let amountUnformatted = "\(amount)".replacingOccurrences(of: ",", with: "")
                            mAmounts.append(Double(amountUnformatted) ?? 0.00)
                        }
                    }
                    
                    self.mSubmittedCreditCard.text = "\(mAmounts.reduce(0, {$0 + $1}))"
                    
//                    let totalAmount = Double(self.mTOTALAMOUNT.text?.replacingOccurrences(of: ",", with: "") ?? "") ?? 0.0
//                    let submittedCash = Double(self.mSubmittedCash.text ?? "") ?? 0.0
//                    let submittedCreditNote = Double(self.mSubmittedCreditNote.text ?? "") ?? 0.0
//                    let submittedBankAmount = Double(self.mSubmittedBankAmount.text ?? "") ?? 0.0
//                    let submittedCreditCard = Double(self.mSubmittedCreditCard.text ?? "") ?? 0.0
//                    let totalAmount = Double(self.mTOTALAMOUNT.text?.replacingOccurrences(of: ",", with: "") ?? "") ?? 0.0
//                    let submittedCash = Double(self.mSubmittedCash.text ?? "") ?? 0.0
//                    let submittedCreditNote = Double(self.mSubmittedCreditNote.text ?? "") ?? 0.0
//                    let submittedBankAmount = Double(self.mSubmittedBankAmount.text ?? "") ?? 0.0
//                    let submittedCreditCard = Double(self.mSubmittedCreditCard.text ?? "") ?? 0.0
//
////                    let mTotalValue = totalAmount - submittedCash - submittedCreditNote - submittedBankAmount - submittedCreditCard
//                    let convertedAmounts = Double(self.mCashAmount.text ?? "0.0") ?? 0.00
//
//                    let mTotalValue =
//                        totalAmount
//                        - convertedAmounts
//                        - submittedCreditNote
//                        - submittedBankAmount
//                        - submittedCreditCard
//
//                    self.mBALANCEDUE.text = "\(mTotalValue)".formatPrice()
//                    let totalAmount = Double(self.mTOTALAMOUNT.text?.replacingOccurrences(of: ",", with: "") ?? "") ?? 0.0
//                    let submittedCash = Double(self.mSubmittedCash.text ?? "") ?? 0.0
//                    let submittedCreditNote = Double(self.mSubmittedCreditNote.text ?? "") ?? 0.0
//                    let submittedBankAmount = Double(self.mSubmittedBankAmount.text ?? "") ?? 0.0
//                    let submittedCreditCard = Double(self.mSubmittedCreditCard.text ?? "") ?? 0.0
//
////                    let mTotalValue = totalAmount - submittedCash - submittedCreditNote - submittedBankAmount - submittedCreditCard
//                    let convertedAmounts = Double(self.mCashAmount.text ?? "0.0") ?? 0.00
//
//                    let mTotalValue =
//                        totalAmount
//                        - convertedAmounts
//                        - submittedCreditNote
//                        - submittedBankAmount
//                        - submittedCreditCard
//
//                    self.mBALANCEDUE.text = "\(mTotalValue)".formatPrice()
                    self.recheckBalanceDue()
                    
                    self.mCreditCardLogo = ""
                    self.mCreditCardName = ""
                    self.mCreditCardPaymentId = ""
                    self.mCardNumber.text = ""
                    self.mCardName.text = ""
                    self.mCreditFillAmount.text = ""
                    self.recheckBalanceDue()
                    
                case .failed(let error):
                    
                    if let paymentSuccessView = PaymentSuccessView.loadFromNib() {
                        paymentSuccessView.frame = self.view.bounds
                        
                        paymentSuccessView.mSetAmountStatus("Payment Failed")
                        
                        if let successImage = UIImage(named: "AmountFailed") {
                            paymentSuccessView.setImage(successImage)
                        }
                        
                        self.view.addSubview(paymentSuccessView)
                    }
                    
                    StripeManager.shared.fetchPaymentIntentDetails(clientSecret: self.mClientSecreat)
                case .canceled:
                    
                    if let paymentSuccessView = PaymentSuccessView.loadFromNib() {
                        paymentSuccessView.frame = self.view.bounds
                        
                        paymentSuccessView.mSetAmountStatus("Payment Failed")
                        
                        if let successImage = UIImage(named: "AmountFailed") {
                            paymentSuccessView.setImage(successImage)
                        }
                        
                        self.view.addSubview(paymentSuccessView)
                    }
                }
            }
        }
    }
    
    
    
    // MARK: Delegate method to handle cancel button action
    func didTapCancelQRCode() {
        mCancelQRCode()
    }
    
    
    // MARK: Cancel  QR Code Api -:
    
    func mCancelQRCode() {
        let urlPath = mCancelQR
        let mParams: [String: Any] = [
            "client_reference_id": mClientReferenceID
        ]
        
        guard Reachability.isConnectedToNetwork() else {
            CommonClass.showSnackBar(message: "No Internet Connection")
            return
        }
        
        AF.request(urlPath, method: .post, parameters: mParams, headers: sGisHeaders2).responseJSON { response in
            print("Response: \(response)")
            
            switch response.result {
            case .success:
                guard let jsonData = response.data else {
                    CommonClass.showSnackBar(message: "Oops, something went wrong!")
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                        if let code = json["code"] as? Int, code == 200 {
                            let message = json["message"] as? String ?? ""
                            CommonClass.showSnackBar(message: message)
                            
                            self.isQRCodeDeleted = true // Stop polling when QR code is deleted
                        } else {
                            let errorMessage = json["message"] as? String ?? "Invalid response format."
                            CommonClass.showSnackBar(message: errorMessage)
                        }
                    } else {
                        CommonClass.showSnackBar(message: "Invalid response format.")
                    }
                } catch {
                    CommonClass.showSnackBar(message: "Failed to parse response.")
                }
                
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                CommonClass.showSnackBar(message: "Oops, something went wrong!")
            }
        }
    }
    
    // Mark-: Get Strip data from Back End Api -:
    
    func mGetStripeDataBackEnd() {
        
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
        print(mParams,"check 1")
        guard Reachability.isConnectedToNetwork() else {
            CommonClass.showSnackBar(message: "No Internet Connection")
            return
        }
        
        AF.request(urlPath, method: .post, parameters: mParams, headers: sGisHeaders2).responseJSON { response in
            print("Response: \(response)")
            
            switch response.result {
            case .success:
                guard let jsonData = response.data else {
                    CommonClass.showSnackBar(message: "OOP's something went wrong!")
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                        if let code = json["code"] as? Int, code == 200 {
                            if let data = json["data"] as? [String: Any],
                               let clientSecret = data["clientSecret"] as? String,
                               let clientRefID = data["client_reference_id"] as? String,
                               let paymentIntentId = data["payment_intent_id"] as? String {
                                self.mClientSecreat = clientSecret
                                print(clientSecret,"check data")
                                self.mPaymentIntentID = paymentIntentId
                                self.mClientReferenceID = clientRefID
                                print("Payment Intent ID: \(paymentIntentId)")
                                print("Client Secret123: \(clientSecret)")
                                print("Client Secret123555: \(self.mClientReferenceID)")
                                
                                // Mark: check Enter Amount  Valid or not According to Due Amount -:
                                
                                if let balanceDue = self.mBALANCEDUE.text {
                                    let formattedBalanceDue = balanceDue.replacingOccurrences(of: ",", with: "")
                                    let balanceDueInDouble = Double(formattedBalanceDue) ?? 0.0
                                    let inputAmount = Double(self.mCreditFillAmount.text ?? "") ?? 0.0
                                    
                                    if inputAmount <= balanceDueInDouble {
                                        // Call StripePayment if input amount is less than due amount
                                        self.StripePayment()
                                    } else {
                                        CommonClass.showSnackBar(message: "Please fill a valid amount!")
                                        return
                                    }
                                }
                                
                                
                                
                            } else {
                                let errorMessage = json["message"] as? String ?? "Invalid response format."
                                CommonClass.showSnackBar(message: errorMessage)
                            }
                        } else {
                            let errorMessage = json["message"] as? String ?? "Invalid response format."
                            CommonClass.showSnackBar(message: errorMessage)
                        }
                    } else {
                        CommonClass.showSnackBar(message: "Invalid response format.")
                    }
                } catch {
                    CommonClass.showSnackBar(message: "Failed to parse response.")
                }
                
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                CommonClass.showSnackBar(message: "OOP's something went wrong!")
            }
        }
    }
    
    
    // MARK: Get Payment status Api -:
    
    
    func mGetPayementStatus() {
        
        guard !isQRCodeDeleted else { return }
        
        let urlPath = mGetPaymentStatus
        let mParams: [String: Any] = [
            "transactionId": self.mClientReferenceID,
            "payment_slag": self.paymentSlag
        ]
        
        print(mParams, "check")
        
        guard Reachability.isConnectedToNetwork() else {
            CommonClass.showSnackBar(message: "No Internet Connection")
            return
        }
        
        AF.request(urlPath, method: .post, parameters: mParams, headers: sGisHeaders2).responseJSON { response in
            print("Response: \(response)")
            
            switch response.result {
            case .success:
                guard let jsonData = response.data else {
                    CommonClass.showSnackBar(message: "Oops, something went wrong!")
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
                       let code = json["code"] as? Int, code == 200,
                       let data = json["data"] as? [String: Any] {
                        
                        let paymentStatus = data["payment_status"] as? String ?? "pending"
                        let paymentSuccess = data["payment_success"] as? Int ?? 0
                        
                        print("Payment Status: \(paymentStatus), Payment Success: \(paymentSuccess)")
                        
                        let normalizedStatus = paymentStatus.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                        
                        if normalizedStatus == "pending" || paymentSuccess == 0 {
                            print("Still pending")
                            CommonClass.showSnackBar(message: "Payment Pending!")
                            
                            // Poll again after 0.5 seconds
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                self.mGetPayementStatus()
                            }
                        } else if normalizedStatus == "completed" || normalizedStatus == "succeeded" || paymentSuccess == 1 {
                            print("Payment Success: \(normalizedStatus)")
                            
                            if let paymentSuccessView = PaymentSuccessView.loadFromNib() {
                                paymentSuccessView.frame = self.view.bounds
                                paymentSuccessView.setAmount("Amount: \(self.mEnterAmountText.text ?? "")")
                                
                                if let successImage = UIImage(named: "successAmount") {
                                    paymentSuccessView.setImage(successImage)
                                }
                                
                                self.view.addSubview(paymentSuccessView)
                            }
                            
                            self.qrCodeView.isHidden = true
                            if let balanceDue = self.mBALANCEDUE.text {
                                let formattedBalanceDue = balanceDue.replacingOccurrences(of: ",", with: "")
                                let balanceDueInDouble = Double(formattedBalanceDue) ?? 0.0
                                let inputAmount = Double(self.mEnterAmountText.text ?? "") ?? 0.0
                                if (balanceDueInDouble - inputAmount) < 0 {
                                    CommonClass.showSnackBar(message: "Please fill valid amount!")
                                    return
                                }
                            }
                            
                            var transID = data["payment_intent_id"] as? String ?? ""
                            if transID.isEmpty {
                               transID = data["transactionID"] as? String ?? ""
                            }
                            //PAYMENTMETHODID
                            self.mChequeData = NSMutableDictionary()
                            self.mChequeData.setValue(self.mCheqDate.text ?? "", forKey: "transaction_date")
                            self.mChequeData.setValue(self.mCheqAccountNumber.text ?? "", forKey: "ac_no")
                            self.mChequeData.setValue(self.mCheqAccountName.text ?? "", forKey: "ac_name")
                            self.mChequeData.setValue(self.mChequePaymentIdNew, forKey: "payment_method_id")
                            self.mChequeData.setValue(self.mCheqRefNumber.text ?? "", forKey: "ref_no")
                            self.mChequeData.setValue(self.mCheqInstNumber.text ?? "", forKey: "inst_no")
                            self.mChequeData.setValue(self.mEnterAmountText.text ?? "", forKey: "amount")
                            self.mChequeData.setValue(self.mClientReferenceID, forKey: "client_reference_id")
                            self.mChequeData.setValue(transID, forKey: "transID")
                            self.mChequeData.setValue("IB", forKey: "Paymentmethod_type")
                            
                            self.mIBPayment.add(self.mChequeData)
                            
                            
                            var mAmounts = [Double]()
                            for i in self.mIBPayment  {
                                let mData = i as? NSDictionary
                                mAmounts.append(Double("\(mData?.value(forKey: "amount") ?? "0.0")".replacingOccurrences(of: ",", with: "")) ?? 0.00)
                            }
                            
                            self.mSubmittedBankAmount.text = "\(mAmounts.reduce(0, {$0 + $1}))"
                            
//                            let totalAmount = Double(self.mTOTALAMOUNT.text?.replacingOccurrences(of: ",", with: "") ?? "") ?? 0.00
//                            let submittedCreditNote = Double(self.mSubmittedCreditNote.text ?? "") ?? 0.00
//                            let submittedBankAmount = Double(self.mSubmittedBankAmount.text ?? "") ?? 0.00
//                            let submittedCreditCard = Double(self.mSubmittedCreditCard.text ?? "") ?? 0.00
//                            let convertedAmounts = Double(self.mCashAmount.text ?? "0.0") ?? 0.00
//
//                            let mTotalValue = totalAmount - convertedAmounts - submittedCreditNote - submittedBankAmount - submittedCreditCard
//
//                            self.mBALANCEDUE.text = "\(mTotalValue)".formatPrice()
                            
//                            let totalAmount = Double(self.mTOTALAMOUNT.text?.replacingOccurrences(of: ",", with: "") ?? "") ?? 0.0
//                            let submittedCash = Double(self.mSubmittedCash.text ?? "") ?? 0.0
//                            let submittedCreditNote = Double(self.mSubmittedCreditNote.text ?? "") ?? 0.0
//                            let submittedBankAmount = Double(self.mSubmittedBankAmount.text ?? "") ?? 0.0
//                            let submittedCreditCard = Double(self.mSubmittedCreditCard.text ?? "") ?? 0.0
//
//        //                    let mTotalValue = totalAmount - submittedCash - submittedCreditNote - submittedBankAmount - submittedCreditCard
//                            let convertedAmounts = Double(self.mCashAmount.text ?? "0.0") ?? 0.00
//
//                            let mTotalValue =
//                                totalAmount
//                                - convertedAmounts
//                                - submittedCreditNote
//                                - submittedBankAmount
//                                - submittedCreditCard
//
//                            self.mBALANCEDUE.text = "\(mTotalValue)".formatPrice()
//                            let totalAmount = Double(self.mTOTALAMOUNT.text?.replacingOccurrences(of: ",", with: "") ?? "") ?? 0.0
//                            let submittedCash = Double(self.mSubmittedCash.text ?? "") ?? 0.0
//                            let submittedCreditNote = Double(self.mSubmittedCreditNote.text ?? "") ?? 0.0
//                            let submittedBankAmount = Double(self.mSubmittedBankAmount.text ?? "") ?? 0.0
//                            let submittedCreditCard = Double(self.mSubmittedCreditCard.text ?? "") ?? 0.0
//
//        //                    let mTotalValue = totalAmount - submittedCash - submittedCreditNote - submittedBankAmount - submittedCreditCard
//                            let convertedAmounts = Double(self.mCashAmount.text ?? "0.0") ?? 0.00
//
//                            let mTotalValue =
//                                totalAmount
//                                - convertedAmounts
//                                - submittedCreditNote
//                                - submittedBankAmount
//                                - submittedCreditCard
//
//                            self.mBALANCEDUE.text = "\(mTotalValue)".formatPrice()
                            
                            self.recheckBalanceDue()
                            
                            self.mCheqDate.text = ""
                            self.mCheqAccountNumber.text = ""
                            self.mCheqAccountName.text = ""
                            self.mChequePaymentId = ""
                            self.mCheqBankName.text = "Choose Bank"
                            self.mCheqRefNumber.text = ""
                            
                            self.mEnterAmountText.text = ""
                            self.mCheqInstNumber.text = ""
                            
                            self.recheckBalanceDue()
                        } else {
                            print("Unexpected status: \(normalizedStatus), retrying...")
                            
                            // Poll again after 0.5 seconds
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                                self.mGetPayementStatus()
                            }
                        }
                    } else {
                        CommonClass.showSnackBar(message: "Invalid response format.")
                    }
                } catch {
                    CommonClass.showSnackBar(message: "Failed to parse response.")
                }
                
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                CommonClass.showSnackBar(message: "Oops, something went wrong!")
            }
        }
    }
    
    
    
    // MARK: Customer Address List
    private var mSelectedBillingAddress: [String : Any] = [:]
    private var mSelectedShippingAddress: [String : Any] = [:]
    private func getCustomerAddressList(){
        
        guard Reachability.isConnectedToNetwork() == true else {
            CommonClass.showSnackBar(message: "Please check your internet connection.")
            return
        }
        
        let params = ["customer_id": mCustomerId] as [String : Any]
        let urlPath =  mGetCustomerAddressList
        
        AF.request(urlPath, method:.post,parameters: params,encoding: JSONEncoding.default, headers: sGisHeaders).responseJSON { response in
            
            guard let jsonData = response.data else {
                CommonClass.showSnackBar(message: "Oops, something went wrong!")
                return
            }
            
            do {
                guard let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
                    CommonClass.showSnackBar(message: "Oops, something went wrong!")
                    return
                }
                guard let code = json["code"] as? Int else {
                    CommonClass.showSnackBar(message: "Oops, something went wrong!")
                    return
                }
                
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
                case 403:
                    CommonClass.sessionExpired(isExpired: true, navigation: self.navigationController)
                default:
                    let errorMessage = json["message"] as? String ?? "An error occurred."
                    CommonClass.showSnackBar(message: "Error \(code): \(errorMessage)")
                }
            } catch {
                CommonClass.showSnackBar(message: "Oops, something went wrong!")
            }
        }
        
    }
    
}

extension UIColor {

    convenience init(hex: String) {

        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexString = hexString.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgb)

        self.init(
            red: CGFloat((rgb >> 16) & 0xff) / 255,
            green: CGFloat((rgb >> 8) & 0xff) / 255,
            blue: CGFloat(rgb & 0xff) / 255,
            alpha: 1
        )
    }
}
