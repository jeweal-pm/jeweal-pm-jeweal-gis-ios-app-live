//
//  MixAndMatchCheckout.swift
//  GIS
//
//  Created by MacBook Hawkscode  on 15/02/23.
//  Copyright © 2023 Hawkscode. All rights reserved.
//
 
    import UIKit
    import Alamofire
    import DropDown
 
    class MixAndMatchCheckout: UIViewController, UITextFieldDelegate , UITableViewDelegate ,UITableViewDataSource , UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout{
       
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
            
            var mExchangeRateData = [String]()
             var mExchangeRate = ""

            var mCurrencyImageData = [String]()
            var mCurrencyNameData = [String]()
            var mCashAmounts = ""
           var mSelectedStoreCurrency = ""
            var mStoreCurrency = ""
            @IBOutlet weak var mEditCashView: UIView!
            @IBOutlet weak var mCashCurrencyImage: UIImageView!
            
            @IBOutlet weak var mCurrencyName: UILabel!
            @IBOutlet weak var mChooseCurrencyButt: UIButton!
            
            @IBOutlet weak var mCashAmount:
            UITextField!
            
            @IBOutlet weak var mExchangeRateLabel: UILabel!
            
            @IBOutlet weak var mExchangeRateValue: UITextField!
            
            @IBOutlet weak var mConvertedAmount: UILabel!
            var mConvertedAmounts = "0"

            // Cash split-payment state. `amount` is always the amount deducted
            // from the order total in STORE currency. `enteredAmount` is what
            // the customer typed in the selected payment currency.
            private struct CashPaymentPage {
                var amount: Double
                var enteredAmount: Double
                var currency: String
                var exchangeRate: Double
                var isSubmitted: Bool
            }

            private var mCashPages: [CashPaymentPage] = [
                CashPaymentPage(amount: 0, enteredAmount: 0, currency: "", exchangeRate: 1, isSubmitted: false)
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
            var mTaxType = ""
            var mTaxLabel = ""
            var mTaxPercent = ""
            var mTotalWithDiscount = ""
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
            var mPartialPayment = ""
            var mQuantity = [Int]()

            var  mCreditData = NSMutableArray()
            var  mCreditDataMerged = NSMutableArray()
            var mSelectedCustomIndex = [IndexPath]()
            var mAmountData = NSMutableArray()
            
            var mCreditCardMethod = NSMutableArray()
            var mGiftCardMethod = NSMutableArray()
            var mGiftFinalTotalAmount = ""
            
            
            
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
            
            
            var mChequePaymentId = ""
            var mCreditCardPaymentId = ""
            private var mCregisPaymentMethod = ""
            private var mCregisSlug = ""
            private var mCregisOrderID = ""
            private var mCregisTransactionID = ""
            private var mCregisOrderData: [String: Any] = [:]
            private var mCregisPollWorkItem: DispatchWorkItem?
            let mDatePicker:UIDatePicker = UIDatePicker()
            var mChequeData = NSMutableDictionary()
            var mFinalPaymentMethod = NSMutableDictionary()

            var mFTOTAL = ""
            
           
        @IBOutlet weak var mClearBUTTON: UIButton!
        @IBOutlet weak var mSubmitButtonCredit: UIButton!
            @IBOutlet weak var mCloseButtonCredit: UIButton!
            @IBOutlet weak var mCreditCardPaymentView: UIView!
            @IBOutlet weak var mCreditFillAmount: UITextField!
           
        @IBOutlet weak var mCreditCardBanksView: UIView!
        @IBOutlet weak var mStripeCardView: UIView!
            @IBOutlet weak var mCollectionView: UICollectionView!
            var mStripeIndex = 0
            var mPaymentData =  NSArray()

           
            
            
            @IBOutlet weak var mGiftCardAmount: UITextField!
            @IBOutlet weak var mApplyGiftBUTTON: UIButton!
            
            
            override func viewWillAppear(_ animated: Bool) {
                
                
                self.mCreditCardPaymentView.isHidden = true
                mVisaView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                mApplePayView.backgroundColor = .clear
                mAliPayView.backgroundColor =  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                mWeChatPayView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                
                mVisaView.borderColor =  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                mApplePayView.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                mAliPayView.borderColor =  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                mWeChatPayView.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                
                mCreditCardLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                mApplePayLabel.textColor =  #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                mAliPayLabel.textColor =  #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                mWeChatPayLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                
                
                self.mCheqBankName.text = "Choose Bank"
                self.mCheqBankImage.downlaodImageFromUrl(urlString:  "https://art.gis247.net/assets/images/icon/camera_profile.png")
                
                
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
                mApplyGiftBUTTON .setTitle("APPLY".localizedString, for: .normal)

                mSubmitButtonCredit .setTitle("SUBMIT".localizedString, for: .normal)
                mCardNumber.placeholder = "Card number".localizedString
                mGiftCardAmount.placeholder = "Gift Card number".localizedString

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
        
        override func viewDidLoad() {
                super.viewDidLoad()
            setupCashPageControl()
            mUserLoginToken = UserDefaults.standard.string(forKey: "token")
            mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")

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
               
            }
            
            override func viewDidLayoutSubviews() {
               


            }
            
        private func setupCashPageControl() {
            mPageControl.translatesAutoresizingMaskIntoConstraints = false
            mPageControl.numberOfPages = 1
            mPageControl.currentPage = 0
            mPageControl.hidesForSinglePage = false
            mPageControl.pageIndicatorTintColor = UIColor.lightGray
            mPageControl.currentPageIndicatorTintColor = UIColor.darkGray
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

    private func mStartCregisPayment() {
        guard let amount = Double((mCreditFillAmount.text ?? "").replacingOccurrences(of: ",", with: "")), amount > 0,
              !mCregisPaymentMethod.isEmpty else { CommonClass.showSnackBar(message: "Please fill valid payment details"); return }
        let customerID = UserDefaults.standard.string(forKey: "CUSTOMERID") ?? ""
        let params: [String: Any] = ["payment_id": mCregisPaymentMethod, "amount": amount, "customerId": customerID, "payment_slag": "cregis-payment"]
        print("========== MIX MATCH CREGIS REQUEST =========="); print("PARAMS =", params)
        AF.request(mGenerateCregisQRCode, method: .post, parameters: params, encoding: JSONEncoding.default, headers: sGisHeaders2).responseJSON { [weak self] response in
            guard let self, let json = response.value as? [String: Any], json["code"] as? Int == 200, let data = json["data"] as? [String: Any] else { CommonClass.showSnackBar(message: (response.value as? [String: Any])?["message"] as? String ?? "Unable to start Cregis payment"); return }
            self.mCregisTransactionID = data["client_reference_id"] as? String ?? ""
            self.mCregisOrderID = (data["cregis_id"] as? String) ?? (data["charges_id"] as? String) ?? ""
            guard let urlString = ["checkout_url", "open_url", "sessionUrl", "approvalLink"].compactMap({ data[$0] as? String }).first, let url = URL(string: urlString), !self.mCregisOrderID.isEmpty else { CommonClass.showSnackBar(message: "Invalid Cregis payment session"); return }
            let web = CregisPaymentWebViewController(url: url)
            self.present(UINavigationController(rootViewController: web), animated: true)
            self.mPollCregisPayment()
        }
    }

    private func mPollCregisPayment() {
        let params: [String: Any] = ["transactionId": mCregisTransactionID, "cregis_id": mCregisOrderID, "payment_slag": "cregis-payment"]
        AF.request(mCregisQueryOrder, method: .post, parameters: params, encoding: JSONEncoding.default, headers: sGisHeaders2).responseJSON { [weak self] response in
            guard let self, let json = response.value as? [String: Any], let data = json["data"] as? [String: Any] else { return }
            self.mCregisOrderData = data
            let status = "\(data["payment_status"] ?? data["status"] ?? "")".lowercased()
            if ["paid", "completed", "success", "succeeded"].contains(status) || data["is_paid"] as? Bool == true || data["can_complete_sale"] as? Bool == true { self.mCompleteCregisPayment(); return }
            self.mCregisPollWorkItem?.cancel(); let work = DispatchWorkItem { [weak self] in self?.mPollCregisPayment() }; self.mCregisPollWorkItem = work; DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: work)
        }
    }

    private func mCompleteCregisPayment() {
        let paymentInfo = (mCregisOrderData["payment_info"] as? [[String: Any]] ?? []).first { "\($0["receive_currency"] ?? "")".uppercased() == "USDT" && "\($0["blockchain"] ?? "")".uppercased().contains("TRON") } ?? [:]
        let amount = Double((mCreditFillAmount.text ?? "").replacingOccurrences(of: ",", with: "")) ?? 0
        let payment: NSMutableDictionary = ["name": "Cregis", "payment_method_id": mCreditCardPaymentId, "PaymentMethod": mCregisPaymentMethod, "amount": amount, "Paymentmethod_type": "Credit_Card", "payment_slag": "cregis-payment", "client_reference_id": mCregisOrderID, "transID": mCregisOrderID, "payment": true, "cryptoCurrency": paymentInfo["receive_currency"] ?? "", "cryptocurrency": paymentInfo["receive_currency"] ?? "", "crypto_currency": paymentInfo["receive_currency"] ?? "", "blockchain": paymentInfo["blockchain"] ?? "", "token_name": paymentInfo["token_name"] ?? "", "receive_currency": paymentInfo["receive_currency"] ?? "", "receive_amount": paymentInfo["receive_amount"] ?? ""]
        print("========== MIX MATCH CREGIS PAYMENT DICT =========="); print(payment)
        mCreditCardMethod.add(payment)
        let total = mCreditCardMethod.compactMap { Double("\(($0 as? NSDictionary)?.value(forKey: "amount") ?? 0)") }.reduce(0, +)
        mSubmittedCreditCard.text = String(format: "%.2f", total); refreshBalanceDue(); mCreditCardPaymentView.isHidden = true; mCreditFillAmount.text = ""
    }
        private func storeAmount(_ value: String?) -> Double {
            Double((value ?? "").replacingOccurrences(of: ",", with: "")) ?? 0
        }

        private func refreshBalanceDue() {
            let totalAmount = storeAmount(mTOTALAMOUNT.text)
            let submittedCash = totalSubmittedCash()
            let submittedCreditNote = storeAmount(mSubmittedCreditNote.text)
            let submittedBankAmount = storeAmount(mSubmittedBankAmount.text)
            let submittedCreditCard = storeAmount(mSubmittedCreditCard.text)
            let balance = max(0, totalAmount - submittedCash - submittedCreditNote - submittedBankAmount - submittedCreditCard)
            mBALANCEDUE.text = String(format: "%.2f", balance)
        }

        private func saveCurrentCashPage() {
            guard mCashPages.indices.contains(mCurrentCashPage) else { return }
            syncCurrentCashPageFromInput()
        }

        // Backend rate is used directly: entered amount x backend rate = STORE currency.
        // Example: Store USD, THB rate 0.03 => 10,000 THB = 300 USD.
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

            let convertedAmount = enteredAmount > 0 && rate > 0 ? enteredAmount * rate : 0

            mCashPages[mCurrentCashPage].enteredAmount = enteredAmount
            mCashPages[mCurrentCashPage].amount = convertedAmount
            mCashPages[mCurrentCashPage].currency = selectedCurrency
            mCashPages[mCurrentCashPage].exchangeRate = rate
            mConvertedAmounts = "\(convertedAmount)"

            if enteredAmount > 0 && rate > 0 {
                let rounded = (convertedAmount * 100).rounded() / 100
                mConvertedAmount.text = "= \(mStoreCurrency) \(String(format: "%.2f", rounded))"
            } else {
                mConvertedAmount.text = ""
            }
        }

        private func totalSubmittedCash() -> Double {
            mCashPages.filter { $0.isSubmitted }.reduce(0) { $0 + $1.amount }
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
                let value = page.enteredAmount.rounded() == page.enteredAmount
                    ? String(Int(page.enteredAmount))
                    : String(page.enteredAmount)
                mCashAmount.text = value
                mCashAmounts = value
                mConvertedAmounts = "\(page.amount)"
                let rounded = (page.amount * 100).rounded() / 100
                mConvertedAmount.text = page.amount > 0
                    ? "= \(mStoreCurrency) \(String(format: "%.2f", rounded))"
                    : ""
            }

            if !page.currency.isEmpty { mCurrencyName.text = page.currency }

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
                guard mCurrentCashPage < mCashPages.count - 1 else { return }
                mCurrentCashPage += 1
            case .right:
                guard mCurrentCashPage > 0 else { return }
                mCurrentCashPage -= 1
            default:
                return
            }
            UISelectionFeedbackGenerator().selectionChanged()
            UIView.transition(with: mEditCashView, duration: 0.22, options: [.curveEaseInOut]) {
                self.refreshCashPage()
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
                                
                                if let mCreditRow = jsonResult.value(forKey: "creditNote_row") as? NSDictionary {
                                    
                                    var isExist = false
                                    for item in mCreditNoteData {
                                        if let value = item as? NSDictionary {
                                            if "\(value.value(forKey: "creditNote_id") ?? "")" == "\(mCreditRow.value(forKey: "creditNote_id") ?? "")"{
                                                isExist = true
                                            }
                                        }
                                    }
                                    
                                    if !isExist {
                                        CommonClass.showSnackBar(message: "Gift Card Added Successfully")
                                        self.mSelectedIndex = [IndexPath]()
                                        let mNewData = NSMutableDictionary()
                                        
                                        mNewData.setValue(mCreditRow.value(forKey: "price_for"), forKey: "price_for")
                                        
                                        mNewData.setValue(mCreditRow.value(forKey: "type"), forKey: "type")
                                        mNewData.setValue(mCreditRow.value(forKey: "createdAt"), forKey: "createdAt")
                                        mNewData.setValue(mCreditRow.value(forKey: "Ref_No"), forKey: "Ref_No")
                                        mNewData.setValue(mCreditRow.value(forKey: "creditNote_id"), forKey: "creditNote_id")
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
                                            let mCData = NSMutableDictionary()
                                            if let value = item as? NSDictionary,
                                               let priceFor = value.value(forKey: "price_for"),
                                               let priceForDouble = Double("\(priceFor)") {
                                                mAmount.append(priceForDouble)
                                                mCData.setValue("\(priceFor)", forKey: "price_for")
                                            }
                                           
                                            self.mTotalCreditAmount.text = String(format:"%.02f",locale:Locale.current,mAmount.reduce(0, {$0 + $1}))
                                            
                                            
                                            self.mAmountData.add(mCData)
                                        }
                                        self.mCreditNoteTable
                                            .delegate = self
                                        self.mCreditNoteTable
                                            .dataSource = self
                                        self.mCreditNoteTable
                                            .reloadData()
                                        self.mGetTotalAmount()
                                        
                                    }else{
                                        CommonClass.showSnackBar(message: "Already Added!")
                                    }
                                } else {
                                    CommonClass.showSnackBar(message: "Invalid Card!")
                                }
                            }else {
                                
                                CommonClass.showSnackBar(message: "Invalid Card!")
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
            @IBAction func mDeleteCreditFillAmount(_ sender: Any) {
                var text = mCreditFillAmount.text ?? ""
                if text != "" {
                    text.removeLast()
                    mCreditFillAmount.text = text
                }
            }
            
            @IBAction func mCloseCreditView(_ sender: Any) {
                self.mCreditCardPaymentView.isHidden = true
            }
            
            @IBAction func mSubmitCreditAmount(_ sender: UIButton) {
                sender.showAnimation{}

                if mCregisSlug == "cregis-payment" {
                    mStartCregisPayment()
                    return
                }
              
                let cardNumber = mCardNumber.text ?? ""
                if cardNumber == "" || cardNumber.isEmptyOrSpaces() || cardNumber.count < 16 {
                    CommonClass.showSnackBar(message: "Please valid card number!")
                    return
                }
                let cardName = mCardName.text ?? ""
                if cardName == "" || cardName.isEmptyOrSpaces() {
                    CommonClass.showSnackBar(message: "Please fill card name!")
                    return
                }
                if mCreditFillAmount.text == "" {
                    CommonClass.showSnackBar(message: "Please fill valid amount")
                    return
                }
                self.mStripeCardView.isHidden = true
                self.mCreditCardBanksView.isHidden = false
                CommonClass.showSnackBar(message: "Amount added successfully")
              

                
            }
           
        func mAddCredit(cardNumber:String, cardExp:String, cardCvc:String, amount:String){
            
            CommonClass.showFullLoader(view: self.view)
            let mLocation = UserDefaults.standard.string(forKey: "location")
            
            
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
                            if let mData = jsonResult.value(forKey: "data") as? NSDictionary,
                               let mId = mData.value(forKey: "insert_id") as? String {
                                let mCreditCardOptions = NSMutableDictionary()
                                mCreditCardOptions.setValue(self.mCreditCardPaymentId, forKey: "cardPaymentId")
                                mCreditCardOptions.setValue(amount, forKey: "amount")
                                mCreditCardOptions.setValue(mId, forKey: "id")
                                self.mCreditCardMethod.add(mCreditCardOptions)
                            }
                            var mAmount = [Double]()
                            
                            for i in self.mCreditCardMethod {
                                if let mAM = i as? NSDictionary, let amount = mAM.value(forKey: "amount"), let amtDouble = Double("\(amount)") {
                                    mAmount.append(amtDouble)
                                }
                            }
                            self.mSubmittedCreditCard.text = "\( mAmount.reduce(0, {$0 + $1}))"
                            
                            self.refreshBalanceDue()
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
            
            guard let cells = collectionView.dequeueReusableCell(withReuseIdentifier: "Collect", for: indexPath) as? Collect else {
                return UICollectionViewCell()
            }
            
            if let mData = mPaymentData[indexPath.row] as? NSDictionary,
               let name = mData.value(forKey: "name") as? String,
               let id = mData.value(forKey: "id") {
                cells.mImage.downlaodImageFromUrl(urlString: "\(mData.value(forKey: "PayMethod_logo") ?? "")")
                cells.mName.text = name
                if mStripeIndex == indexPath.row {
                    
                    mCreditCardPaymentId = "\(id)"
                    cells.mView.borderColor = .systemBlue
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
            
            let cells = collectionView.dequeueReusableCell(withReuseIdentifier: "Collect",for:indexPath) as? Collect
            
            let layout = collectionViewLayout as? UICollectionViewFlowLayout
            let width = collectionView.frame.width / 2
            layout?.minimumLineSpacing = 16
            
            
            return CGSize(width: (collectionView.frame.width / 2) - 16 , height: (collectionView.frame.height / 2) - 16)
        }
            
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            mStripeIndex = indexPath.row
            if let mData = mPaymentData[indexPath.row] as? NSDictionary,
               let name = mData.value(forKey: "name") as? String,
               let id = mData.value(forKey: "id") {
                mCreditCardPaymentId = "\(id)"
                mCregisPaymentMethod = "\(mData.value(forKey: "PaymentMethod") ?? "")"
                let suppliedSlug = "\(mData.value(forKey: "payment_slag") ?? "")".lowercased()
                mCregisSlug = suppliedSlug.isEmpty && name.lowercased().contains("cregis") ? "cregis-payment" : suppliedSlug
                self.mCreditBankImage.downlaodImageFromUrl(urlString: "\(mData.value(forKey: "PayMethod_logo") ?? "")")
                self.mCreditBankName.text = name
                self.mStripeCardView.isHidden = false
                self.mCreditCardBanksView.isHidden = true
                self.mCollectionView.reloadData()
            }
        }
            
            
        func mFetchStore(key: String){
            
            let mLocation = UserDefaults.standard.string(forKey: "location") ?? ""
            
            let urlPath =  mFetchPaymentMethod
            let params = ["login_token": mUserLoginToken ?? "", "location_id":mLocation]
            guard Reachability.isConnectedToNetwork() == true else {
                CommonClass.showSnackBar(message: "No Internet Connection")
                return
            }
            
            AF.request(urlPath, method:.post, parameters:["":""], headers: sGisHeaders2).responseJSON
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
                        
                        if let mPaymentMethod = jsonResult.value(forKey: "data") as? NSDictionary,
                           let mData = mPaymentMethod.value(forKey: "Credit_Card") as? NSArray,
                           mData.count > 0 {
                            self.mPaymentData = mData
                            self.mCollectionView.delegate = self
                            self.mCollectionView.dataSource = self
                            self.mCollectionView.reloadData()
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
                    mChequeData.setValue("", forKey: "cheque_date")
                    mChequeData.setValue("", forKey: "cheque_ac_no")
                    mChequeData.setValue("", forKey: "cheque_ac_name")
                    mChequeData.setValue("", forKey: "cheque_bank")
                    mChequeData.setValue("", forKey: "cheque_ref_no")
                    mChequeData.setValue("", forKey: "cheque_date")
                    
                    
                    self.refreshBalanceDue()
                    
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
                let mDayd = DateFormatter()
                    mDayd.dateFormat = "dd"
                
                let mMonthm = DateFormatter()
                    mMonthm.dateFormat = "MM"
                      
                let mYeard = DateFormatter()
                    mYeard.dateFormat = "yyyy"
                      
                
                mCheqDate.text  = "\(mYeard.string(from: mDatePicker.date))/" +  "\(mMonthm.string(from: mDatePicker.date))/"+"\(mDayd.string(from: mDatePicker.date))"

                self.view.endEditing(true)
           
            }
            @objc func mCancelDatePick(){
                self.view.endEditing(true)
            }
            
        @IBAction func mChooseBanks(_ sender: Any) {
            
            var mBankNames = ["Choose Bank"]
            var mBankImage = ["https://art.gis247.net/assets/images/icon/camera_profile.png"]
            var mPMId = [""]
            
            if let mData = UserDefaults.standard.object(forKey: "PAYMENTMETHODID") as? NSDictionary {
                
                if let mBankData = mData.value(forKey: "Bank") as? NSArray {
                    for i in mBankData {
                        if let data = i as? NSDictionary {
                            if "\(data.value(forKey: "BankPaymenttype") ?? "")" == "Cheque" || "\(data.value(forKey: "BankPaymenttype") ?? "")" == "Bank" {
                                
                                if let name = data.value(forKey: "name"),
                                   let logo = data.value(forKey: "logo"),
                                   let id = data.value(forKey: "id") {
                                    mBankNames.append("\(name)")
                                    mBankImage.append("\(logo)")
                                    mPMId.append("\(id)")
                                }
                            }
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
                
                dropdown.customCellConfiguration = {
                    (index:Index, item:String,cell: DropDownCell) -> Void in
                    guard let cell = cell as? CurrencyCell else { return}
                    
                    cell.mCurrencyImage.downlaodImageFromUrl(urlString: "\(mBankImage[index])")
                }
                dropdown.selectionAction = {
                    [unowned self](index:Int, item: String) in
                    
                    self.mChequePaymentId = mPMId[index]
                    self.mCheqBankName.text = item
                    self.mCheqBankImage.downlaodImageFromUrl(urlString: mBankImage[index])
                    
                }
                dropdown.show()
                
            }else{
                CommonClass.showSnackBar(message: "Temporarily not available!")
            }
            
            
            
        }
            
            
            @IBAction func mSubmitCheque(_ sender: UIButton) {
                sender.showAnimation{}
                
                if mChequeAmount.text == "" || ((Double(mChequeAmount.text ?? "") ?? 0) * 1) == 0 {
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
                    //PAYMENTMETHODID
                    mChequeData = NSMutableDictionary()
                    mChequeData.setValue(mCheqDate.text ?? "", forKey: "cheque_date")
                    mChequeData.setValue(mCheqAccountNumber.text ?? "", forKey: "cheque_ac_no")
                    mChequeData.setValue(mCheqAccountName.text ?? "", forKey: "cheque_ac_name")
                    mChequeData.setValue(mChequePaymentId, forKey: "cheque_bank")
                    mChequeData.setValue(mCheqRefNumber.text ?? "", forKey: "cheque_ref_no")
                    mChequeData.setValue(mCheqInstNumber.text ?? "", forKey: "cheque_date")
                    
                    mSubmittedBankAmount.text = mChequeAmount.text
                    
                    self.refreshBalanceDue()
                     
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
              
                let mData =  mCreditNoteData[indexPath.row] as? NSDictionary
                cells.mType.text = mData?.value(forKey: "type") as? String
                cells.mRefNo.text = mData?.value(forKey: "Ref_No") as? String
                cells.mDate.text = mData?.value(forKey: "createdAt") as? String
                cells.mAmount.tag = indexPath.row
                
                if mSelectedCustomIndex.contains(indexPath) {
                    let mDataSet = mAmountData[indexPath.row] as? NSDictionary
                    cells.mAmount.text = "\(mDataSet?.value(forKey: "price_for") ?? "")"
                }else{
                    cells.mAmount.text = "\(mData?.value(forKey: "price_for") ?? "")"
                }
                
                if mSelectedIndex.contains(indexPath) {
                    cells.mCheckImage.image = UIImage(systemName: "checkmark.square" )
                }else{
                    cells.mCheckImage.image = UIImage(systemName: "square" )
                }
                
                cells.layoutSubviews()
                
                return cells
            }
            
            
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

            _ = tableView.dequeueReusableCell(withIdentifier: "CreditNoteList") as? CreditNoteList

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
            return 35
        }
            
            
        @IBAction func mAmountEdit(_ sender: UITextField) {
            
            if let mMaxData = mCreditNoteData[sender.tag] as? NSDictionary,
            let priceFor = mMaxData.value(forKey: "price_for"),
               let mMaxAmount = Double("\(priceFor)") {
                if sender.text == ""  {
                    mAddCreditAmount(text: "0", index: sender.tag)
                    return
                }
                let text = sender.text ?? "0"
                let textAmount = Double(text) ?? 0
                if textAmount > mMaxAmount   {
                    sender.text = "\(priceFor)"
                    mAddCreditAmount(text: text, index: sender.tag)
                }else{
                    mAddCreditAmount(text: text, index: sender.tag)
                }
            }
        }

            func mAddCreditAmount(text : String , index : Int ){
               
                let mIndexPath = IndexPath(row:index,section: 0)
              
                let mData = NSMutableDictionary()
                mData.setValue(text, forKey: "price_for")
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
                    if let mData = mAmountData[index] as? NSDictionary,
                       let priceFor = mData.value(forKey: "price_for"),
                       let priceForDouble = Double("\(priceFor)") {
                        mAmount.append(priceForDouble)
                        var mCData = NSMutableDictionary()
                        if let mMaxData = mCreditNoteData[index] as? NSDictionary,
                           let type = mMaxData.value(forKey: "type"),
                           let creditNoteId = mMaxData.value(forKey: "creditNote_id") {
                            
                            if "\(type)" == "Gift Card" {
                                mCData.setValue("GiftCard", forKey: "type")
                                mCData.setValue("\(priceFor)", forKey: "applyamount")
                                mCData.setValue("\(creditNoteId)", forKey: "creditNoteID")
                                mGiftCardMethod.add(mCData)
                            }else{
                                mCData.setValue("CreditNote", forKey: "type")
                                mCData.setValue("\(priceFor)", forKey: "applyamount")
                                mCData.setValue("\(creditNoteId)", forKey: "creditNoteID")
                                mCreditData.add(mCData)
                            }
                        }
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
            
            
            self.refreshBalanceDue()
        }
            
            
            
            
            @IBAction func mSubmitCredit(_ sender: Any) {
                
                mGetTotalAmount()
            }
            

          
            @IBAction func mBack(_ sender: Any) {
                
                self.navigationController?.popViewController(animated: true)
                
            }
            
        @IBAction func mAddCustomer(_ sender: Any) {
            
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            if let home = storyBoard.instantiateViewController(withIdentifier: "RegisterCustomer") as? RegisterCustomer {
                self.navigationController?.pushViewController(home, animated:true)
            }
        }
            
        
        @IBAction func mBackCreditCardForm(_ sender: Any) {
            self.mCreditCardBanksView.isHidden = false
            self.mStripeCardView.isHidden = true
                    
        }
        @IBAction func mCreditCard(_ sender: Any) {
                mPageControl.isHidden = true
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
            @IBAction func mCash(_ sender: Any) {
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
                refreshCashPage()
            }
            
            @IBAction func mBank(_ sender: Any) {
                mPageControl.isHidden = true
                mTransactionType = "Bank"
                mChequeDetailsView.isHidden = false
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
                mPageControl.isHidden = true
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
                mPageControl.isHidden = true
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
                mApplePayView.backgroundColor =  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                mAliPayView.backgroundColor =  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                mWeChatPayView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                
                mVisaView.borderColor = #colorLiteral(red: 0.1333333333, green: 0.5764705882, blue: 0.862745098, alpha: 1)
                mApplePayView.borderColor =  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                mAliPayView.borderColor =  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                mWeChatPayView.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                
                
                mCreditCardLabel.textColor = #colorLiteral(red: 0.1333333333, green: 0.5764705882, blue: 0.862745098, alpha: 1)
                mApplePayLabel.textColor =  #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                mAliPayLabel.textColor =  #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                mWeChatPayLabel.textColor = #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1)
                
                self.mCreditCardPaymentView.isHidden = false
                
             

            }
            
           
            
            @IBAction func mApplePay(_ sender: Any) {
                
                mVisaView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                mApplePayView.backgroundColor = .clear
                mAliPayView.backgroundColor =  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                mWeChatPayView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                
                mVisaView.borderColor =  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                mApplePayView.borderColor = #colorLiteral(red: 0.1333333333, green: 0.5764705882, blue: 0.862745098, alpha: 1)
                mAliPayView.borderColor =  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                mWeChatPayView.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                
                
                mCreditCardLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                mApplePayLabel.textColor =  #colorLiteral(red: 0.1333333333, green: 0.5764705882, blue: 0.862745098, alpha: 1)
                mAliPayLabel.textColor =  #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                mWeChatPayLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            }
            @IBAction func mAliPay(_ sender: Any) {
                
                mVisaView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                mApplePayView.backgroundColor =  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                mAliPayView.backgroundColor = .clear
                mWeChatPayView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                
                mVisaView.borderColor =  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                mApplePayView.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                mAliPayView.borderColor =  #colorLiteral(red: 0.1333333333, green: 0.5764705882, blue: 0.862745098, alpha: 1)
                mWeChatPayView.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                
                
                mCreditCardLabel.textColor =  #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                mApplePayLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                mAliPayLabel.textColor = #colorLiteral(red: 0.1333333333, green: 0.5764705882, blue: 0.862745098, alpha: 1)
                mWeChatPayLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            }
            
            @IBAction func mWeChatPay(_ sender: Any) {
                
                mVisaView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                mApplePayView.backgroundColor =  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                mAliPayView.backgroundColor =  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                mWeChatPayView.backgroundColor = .clear
            
                mVisaView.borderColor =  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                mApplePayView.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                mAliPayView.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                mWeChatPayView.borderColor = #colorLiteral(red: 0.1333333333, green: 0.5764705882, blue: 0.862745098, alpha: 1)
                
                mCreditCardLabel.textColor =  #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                mApplePayLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                mAliPayLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                mWeChatPayLabel.textColor =  #colorLiteral(red: 0.1333333333, green: 0.5764705882, blue: 0.862745098, alpha: 1)
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

            syncCurrentCashPageFromInput()
            let convertedAmount = mCashPages[mCurrentCashPage].amount
            guard convertedAmount > 0 else {
                CommonClass.showSnackBar(message: "Please fill valid amount!")
                return
            }

            let balance = storeAmount(mBALANCEDUE.text)
            guard convertedAmount <= balance + 0.000001 else {
                CommonClass.showSnackBar(message: "Please fill valid amount!")
                return
            }

            mCashPages[mCurrentCashPage].isSubmitted = true
            mSubmittedCash.text = String(format: "%.2f", totalSubmittedCash())
            refreshBalanceDue()

            let remainingBalance = storeAmount(mBALANCEDUE.text)
            if remainingBalance > 0.000001 {
                let nextCurrency = mCurrencyName.text ?? mStoreCurrency
                let nextRate = nextCurrency == mStoreCurrency
                    ? 1
                    : (Double(mExchangeRateValue.text ?? "") ?? 0)

                mCashPages.append(CashPaymentPage(
                    amount: 0,
                    enteredAmount: 0,
                    currency: nextCurrency,
                    exchangeRate: nextRate,
                    isSubmitted: false
                ))
                mCurrentCashPage = mCashPages.count - 1
                mCashAmount.text = ""
                mCashAmounts = ""
                mConvertedAmounts = "0"
                mConvertedAmount.text = ""
                refreshCashPage()
            }

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

        @IBAction func mCashAmountField(_ sender: Any) {}
            
            
        @IBAction func mChooseCurrency(_ sender: Any) {
            let dropdown = DropDown()
            dropdown.anchorView = self.mChooseCurrencyButt
            dropdown.direction = .bottom
            dropdown.bottomOffset = CGPoint(x: 0, y: 50)
            dropdown.width = 200
            dropdown.dataSource = self.mCurrencyNameData
            dropdown.cellNib = UINib(nibName: "Currency", bundle: nil)

            dropdown.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
                guard let cell = cell as? CurrencyCell else { return }
                guard index < self.mCurrencyImageData.count else { return }
                cell.mCurrencyImage.downlaodImageFromUrl(urlString: self.mCurrencyImageData[index])
            }

            dropdown.selectionAction = { [unowned self] (index: Int, item: String) in
                guard self.mCashPages.indices.contains(self.mCurrentCashPage) else { return }
                if self.mCashPages[self.mCurrentCashPage].isSubmitted {
                    CommonClass.showSnackBar(message: "Please use the new payment page for another currency.")
                    return
                }

                self.mCurrencyName.text = item
                self.mSelectedStoreCurrency = item
                if index < self.mCurrencyImageData.count {
                    self.mCashCurrencyImage.downlaodImageFromUrl(urlString: self.mCurrencyImageData[index])
                }

                if item == self.mStoreCurrency {
                    self.mExchangeRateLabel.isHidden = true
                    self.mExchangeRateValue.isHidden = true
                    self.mExchangeRateValue.text = ""
                    self.mCashPages[self.mCurrentCashPage].exchangeRate = 1
                } else {
                    self.mExchangeRateLabel.isHidden = false
                    self.mExchangeRateValue.isHidden = false
                    guard index < self.mExchangeRateData.count else {
                        self.mExchangeRateValue.text = ""
                        self.syncCurrentCashPageFromInput()
                        return
                    }
                    self.mExchangeRateValue.text = self.mExchangeRateData[index]
                }

                self.mCashPages[self.mCurrentCashPage].currency = item
                self.syncCurrentCashPageFromInput()
            }
            dropdown.show()
        }

        @IBAction func mExchangeRate(_ sender: UITextField!) {
            guard mTransactionType == "Cash" else { return }
            syncCurrentCashPageFromInput()
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
            mSubmittedCash.text = String(format: "%.2f", totalSubmittedCash())
            refreshBalanceDue()
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
            mSubmittedCash.text = String(format: "%.2f", totalSubmittedCash())
            refreshBalanceDue()
        }

        func mInsertAmount(num : String){
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

        @IBAction func mPayNow(_ sender: UIButton) {
            sender.showAnimation{}
            mGiftFinalTotalAmount = "0"
            var mAmount = [Double]()
            for item in mGiftCardMethod {
                if let value = item as? NSDictionary,
                   let applyAmount = value.value(forKey: "applyamount"),
                   let applyAmountDouble = Double("\(applyAmount)") {
                    mAmount.append(applyAmountDouble)
                }
            }
            self.mGiftFinalTotalAmount  = "\(mAmount.reduce(0, {$0 + $1}))"
            
            var mCreditFinalTotalAmountObj = "0"
            var mAmount2 = [Double]()
            for item in mCreditData {
                if let value = item as? NSDictionary,
                   let applyAmount = value.value(forKey: "applyamount"),
                   let applyAmountDouble = Double("\(applyAmount)") {
                    mAmount2.append(applyAmountDouble)
                }
            }
            mCreditFinalTotalAmountObj = "\(mAmount2.reduce(0, {$0 + $1}))"
            
            
            
            mFinalPaymentMethod = NSMutableDictionary()
            let mCashMethod = NSMutableDictionary()
            let mCreditNoteMethod = NSMutableDictionary()
            let mGiftCardMethods = NSMutableDictionary()
            let mBankMethod = NSMutableArray()
            let mChequeMethod = NSMutableDictionary()
            
            
            
            if (Double(mCreditFinalTotalAmountObj) ?? 0) * 1 != 0.0 {
                mCreditNoteMethod.setValue(mCreditFinalTotalAmountObj, forKey: "amount")
                mCreditNoteMethod.setValue("creditNote", forKey: "id")
            }else{
                mCreditNoteMethod.setValue("", forKey: "amount")
                mCreditNoteMethod.setValue("creditNote", forKey: "id")
            }

            if (Double(mGiftFinalTotalAmount) ?? 0) * 1 != 0.0 {
                mGiftCardMethods.setValue(mGiftFinalTotalAmount, forKey: "amount")
                mGiftCardMethods.setValue("GiftCard", forKey: "id")
            }else{
                mGiftCardMethods.setValue("", forKey: "amount")
                mGiftCardMethods.setValue("GiftCard", forKey: "id")
            }
            
            if (Double(mSubmittedCash.text ?? "") ?? 0) * 1 != 0.0 {
                mCashMethod.setValue(mSubmittedCash.text ?? "", forKey: "amount")
                mCashMethod.setValue("cash", forKey: "id")
            }else{
                mCashMethod.setValue("", forKey: "amount")
                mCashMethod.setValue("cash", forKey: "id")
            }
            
            if mChequePaymentId != "" {
                mChequeMethod.setValue(mChequeAmount.text ?? "", forKey: "amount")
                mChequeMethod.setValue(mChequePaymentId, forKey: "id")
                mBankMethod.add(mChequeMethod)
            }else{
                mChequeMethod.setValue("", forKey: "amount")
                mChequeMethod.setValue("", forKey: "id")
                mBankMethod.add(mChequeMethod)
            }
            
            
            mFinalPaymentMethod.setValue(mGiftCardMethods, forKey: "Gift_Card")
            mFinalPaymentMethod.setValue(self.mCreditCardMethod, forKey: "Credit_Card")
            mFinalPaymentMethod.setValue(mCashMethod, forKey: "Cash")
            mFinalPaymentMethod.setValue(mCreditNoteMethod, forKey: "CreditNote")
            mFinalPaymentMethod.setValue(mBankMethod, forKey: "Bank")
            
            if mOrderType == "Sales Order" {
                
                if mPartialPayment == "0" {
                    let balanceDue = mBALANCEDUE.text?.replacingOccurrences(of: ",", with: "")
                    if (Double(balanceDue ?? "") ?? 0) * 1 == 0.0 {
                        if UserDefaults.standard.string(forKey: "CUSTOMERID") != nil {
                            PayNow()
                        }else{
                            CommonClass.showSnackBar(message:"Please choose customer")
                        }
                        
                    }else {
                        CommonClass.showSnackBar(message:"Please add valid amount!")
                    }
                    
                }else{
                    let balanceDue = mBALANCEDUE.text?.replacingOccurrences(of: ",", with: "") ?? ""
                    let totalAmount = mTOTALAMOUNT.text?.replacingOccurrences(of: ",", with: "") ?? ""
                    if (Double(balanceDue) ?? 0) > (Double(totalAmount) ?? 0) || (Double(balanceDue) ?? 0) < 0.0{
                        CommonClass.showSnackBar(message:"Please add valid amount!")
                    }else {
                        if UserDefaults.standard.string(forKey: "CUSTOMERID") != nil {
                            PayNow()
                        }else{
                            CommonClass.showSnackBar(message:"Please choose customer")
                        }
                        
                    }
                }
    
            }else if mOrderType == "Custom Order" {
                let balanceDue = mBALANCEDUE.text?.replacingOccurrences(of: ",", with: "") ?? ""
                let totalAmount = mTOTALAMOUNT.text?.replacingOccurrences(of: ",", with: "") ?? ""
                if (Double(balanceDue) ?? 0) > (Double(totalAmount) ?? 0) || (Double(balanceDue) ?? 0) < 0{
                    CommonClass.showSnackBar(message:"Please add valid amount!")
                }else {
                    if UserDefaults.standard.string(forKey: "CUSTOMERID") != nil {
                        PayNow()
                    }else{
                        CommonClass.showSnackBar(message:"Please choose customer")
                    }
                    
                }
                
            }else{
                let balanceDue = mBALANCEDUE.text?.replacingOccurrences(of: ",", with: "") ?? ""
                let totalAmount = mTOTALAMOUNT.text?.replacingOccurrences(of: ",", with: "") ?? ""
                if (Double(balanceDue) ?? 0) > (Double(totalAmount) ?? 0) || (Double(balanceDue) ?? 0) < 0 {
                    CommonClass.showSnackBar(message:"Please add valid amount!")
                }else {
                    
                    if UserDefaults.standard.string(forKey: "CUSTOMERID") != nil {
                        PayNow()
                    }else{
                        CommonClass.showSnackBar(message:"Please choose customer")
                    }
                }
            }
            
        }
            
        @IBAction func mStartSearch(_ sender: Any) {}
        
        @IBAction func mEndSearch(_ sender: Any) {}
        
        @IBAction func mEditChanged(_ sender: Any) {
               
            let value  = mCustomerSearch.text?.count
            if value != 0 {} else {
                if mCustomerSearch.text  == "" {
                    mCustomerSearchTableView.removeFromSuperview()
                }
                self.view.endEditing(true)
            }

        }

        @IBAction func mValueChanged(_ sender: UITextField!) {}
        
        @IBAction func mEditCustSearch(_ sender: Any) {}
            
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
                mTotalTx.text = "\((mAmount + (Double(mTotalAm) ?? 0) ))"
                
                let totalTx = Double(mTotalTx.text ?? "") ?? 0.0
                let discountAmounts = Double(mDiscountAmounts.text ?? "") ?? 0.0
                let taxP = Double(mTaxP) ?? 0.0
                
                let taxAmount = calculateInclusiveTax(value: totalTx - discountAmounts, percent: taxP)
                mTaxAmountTx.text = String(format: "%.02f", locale: Locale.current, taxAmount)
                
                let sTotalTx = Double(mTotalTx.text?.replacingOccurrences(of: ",", with: "") ?? "") ?? 0.0
                let sDiscountAmounts = Double(mDiscountAmounts.text ?? "") ?? 0.0
                let sTaxAmount = Double(mTaxAmountTx.text?.replacingOccurrences(of: ",", with: "") ?? "") ?? 0.0
                
                mSubTotalTx.text = String(format: "%.02f", locale: Locale.current, sTotalTx - sDiscountAmounts - sTaxAmount)
                
                mFinalTaxAmount.text = mTaxAmountTx.text
                
                mTOTALAMOUNT.text = "\((mAmount + (Double(mTotalAm) ?? 0) - mDiscountA))"
                
                refreshBalanceDue()
            }else{
                mTotalDiscountTx.text = mDiscountAmounts.text
                mTotalTx.text = "\((mAmount + (Double(mTotalAm) ?? 0)))"
                
                let totalTx = Double(mTotalTx.text ?? "") ?? 0.0
                let discountAmounts = Double(mDiscountAmounts.text ?? "") ?? 0.0
                let taxP = Double(mTaxP) ?? 0.0
                
                let taxAmount = calculateExclusiveTax(value: totalTx - discountAmounts, percent: taxP)
                mTaxAmountTx.text = String(format: "%.02f", locale: Locale.current, taxAmount)
                
                let subTotal = totalTx - discountAmounts
                mSubTotalTx.text = String(format: "%.02f", locale: Locale.current, subTotal)
                mFinalTaxAmount.text = mTaxAmountTx.text ?? "0.00"
                
                let totalAmount = (Double(mSubTotalTx.text?.replacingOccurrences(of: ",", with: "") ?? "") ?? 0.0) +
                (Double(mTaxAmountTx.text?.replacingOccurrences(of: ",", with: "") ?? "") ?? 0.0)
                mTOTALAMOUNT.text = "\(totalAmount)"
                
                refreshBalanceDue()
            }
            
        }
            
        func textFieldDidEndEditing(_ textField: UITextField) {
            let value = textField.text
        }
        
        func mFetchCreditNoteData(value: String){
            
            mUserLoginToken = UserDefaults.standard.string(forKey: "token")
            mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
            let mCustomerId =  UserDefaults.standard.string(forKey: "CUSTOMERID") ?? ""
            
            let mLocation = UserDefaults.standard.string(forKey: "location") ?? ""
            
            
            let urlPath =  mPOSCreditNote
            let params = ["POS_Location_id": mLocation, "CustomerID":mCustomerId ]
            
            guard Reachability.isConnectedToNetwork() == true else {
                CommonClass.showSnackBar(message: "No Internet Connection")
                return
            }
            
            AF.request(urlPath, method:.post, parameters:params, encoding: JSONEncoding.default, headers: sGisHeaders).responseJSON { response in
                
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
                        
                        if let mData = jsonResult.value(forKey: "responce") as? NSArray {
                            
                            self.mCreditNoteData = NSMutableArray(array: mData)
                            self.mCreditNoteTable
                                .delegate = self
                            self.mCreditNoteTable
                                .dataSource = self
                            self.mCreditNoteTable
                                .reloadData()
                            var mAmount = [Double]()
                            for item in mData {
                                if let value = item as? NSDictionary ,
                                   let priceFor = value.value(forKey: "price_for"),
                                   let priceForDouble = Double("\(priceFor)") {
                                    let mCData = NSMutableDictionary()
                                    
                                    mAmount.append(priceForDouble)
                                    
                                    mCData.setValue("\(priceFor)", forKey: "price_for")
                                    self.mTotalCreditAmount.text = String(format:"%.02f",locale:Locale.current,mAmount.reduce(0, {$0 + $1}))
                                    
                                    self.mAmountData.add(mCData)
                                }
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
                          
                          "POS_Final_Bank_Amount_value":self.mSubmittedBankAmount.text ?? "",
                          
                          "POS_Final_bank_Payment_cheque_information_json": self.mChequeData,
                          "paymentMethodId":self.mFinalPaymentMethod,
                          "couponAmount":self.mGiftFinalTotalAmount,
                          "POS_Final_CreditNote_Amount_value":"",
                          
                          
                          "POS_Final_CreditNote_Amount_arr": self.mCreditDataMerged,
                          "POS_Final_CreditNote_Amount": self.mSubmittedCreditNote.text ?? "",
                          
                          
                          "finalAmountsat_side_DueAmount":self.mBALANCEDUE.text ?? "",
                          "salesPersonId":mSalesPersonId ?? "",
                          "Customer_id":mCustomerId ?? "",
                          "Order_type":"Sales Order",
                          "Remark":"",
                          "cartTableData":self.mCartTableData,
                          
                          
                ]
                
                
            }else if mOrderType == "Custom Order" {
                urlPath =  mPOSpay
                params = ["Customer_name":mCustomerName ?? "",
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
                          "POS_Final_CreditCardAmount_value":self.mSubmittedCreditCard.text ?? "",
                          
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
                    "repair_cart_data":self.mCartTableData,
                    
                ]
                
            }
            
            if (UserDefaults.standard.string(forKey: "isPinEnable") ?? "") == "1" {
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
                            if let pdfUrl = jsonResult.value(forKey: "pdf_url") {
                                UserDefaults.standard.setValue("\(pdfUrl)", forKey: "reportAPI")
                                self.mGenerateReport(id:"\(pdfUrl)" , jsonResult : jsonResult)
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

        func mGenerateReport(id : String, jsonResult : NSDictionary){
            
            mUserLoginToken = UserDefaults.standard.string(forKey: "token")
            mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
            
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
                        
                        UserDefaults.standard.setValue("\(jsonVal.value(forKey: "pdf_url") ?? "")", forKey: "report")
                        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        if let mCompletePayment = storyBoard.instantiateViewController(withIdentifier: "CompletePayment") as? CompletePayment {
                            
                            //Sales Order Custom Order Repair Order
                            
                            if self.mOrderType == "Sales Order" {
                                mCompletePayment.mType = "pos"
                            }
                            if self.mOrderType == "Custom Order" {
                                mCompletePayment.mType = "custom"
                            }
                            if self.mOrderType == "Repair Order" {
                                mCompletePayment.mType = "repair"
                            }
                            
                            
                            mCompletePayment.mDue = "\(jsonResult.value(forKey: "DueAmt") ?? "")"
                            mCompletePayment.mTotal = "\(jsonResult.value(forKey: "totalAmt") ?? "")"
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
            
        }
            
        func mGetCurrency(){
            print("1")
            mUserLoginToken = UserDefaults.standard.string(forKey: "token")
            mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
            
            
            
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
                        
                        if let data = jsonResult.value(forKey: "currency") as? NSArray {
                            
                            for i in data {
                                if let currency = i as? NSDictionary,
                                   let currecnyExchangeRate = currency.value(forKey: "rate"),
                                   let currencyValue = currency.value(forKey:"currency"),
                                   let currencyFlag = currency.value(forKey:"url") {
                                    self.mCurrencyNameData.append("\(currencyValue)")
                                        
                                    self.mCurrencyImageData.append("\(currencyFlag)")
                                    self.mExchangeRateData.append("\(currecnyExchangeRate)")
                                    print(self.mExchangeRateData,"Check 44")
                                    if "\(currencyValue)" == self.mStoreCurrency {
                                        self.mCashCurrencyImage.downlaodImageFromUrl(urlString: "\(currencyFlag)")
                                        self.mCurrencyName.text = self.mStoreCurrency
                                        self.mSelectedStoreCurrency = self.mStoreCurrency
                                        if self.mCashPages.indices.contains(self.mCurrentCashPage), !self.mCashPages[self.mCurrentCashPage].isSubmitted {
                                            self.mCashPages[self.mCurrentCashPage].currency = self.mStoreCurrency
                                            self.mCashPages[self.mCurrentCashPage].exchangeRate = 1
                                        }
                                        
                                        
                                        if self.mOrderType == "Sales Order" {
                                            self.mTOTALAMOUNT.text = self.mFTOTAL
                                            self.mBALANCEDUE.text = self.mFTOTAL
                                        }else{
                                            self.mTOTALAMOUNT.text = self.mTotalP
                                            self.mBALANCEDUE.text = self.mTotalP
                                        }
                                    }
                                    self.mTOTALAMOUNT.text = self.mTotalP
                                    self.mBALANCEDUE.text = self.mTotalP
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
