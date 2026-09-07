//
//  AddDepositController.swift
//  GIS
//
//  Created by MacBook Hawkscode  on 30/03/23.
//  Copyright © 2023 Hawkscode. All rights reserved.
//

import UIKit
import Alamofire
import DropDown
import StripePaymentSheet
 
protocol AddPaymentInfoDelegate {
    func mGetPaymentInfo(items:NSMutableDictionary)
}
class AddDepositController: UIViewController, UITextFieldDelegate , UITableViewDelegate ,UITableViewDataSource , UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout ,GetVerification , ProceedToPay, UIViewControllerTransitioningDelegate, QRCodeViewDelegate {

    private var selectedSalesPersonId: String {
        return (UserDefaults.standard.string(forKey: "SALESPERSONID") ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    
    
    func isProceedWithStatus(status: Bool, message: String) {
         
    }
    
    
    //Icons and Text
    
    var delegate:AddPaymentInfoDelegate? = nil
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
    var mExchangeRateData = [String]()

    @IBOutlet weak var mEditCashView: UIView!
    @IBOutlet weak var mCashCurrencyImage: UIImageView!
    
    @IBOutlet weak var mCurrencyName: UILabel!
    @IBOutlet weak var mChooseCurrencyButt: UIButton!
    
    @IBOutlet weak var mCashAmount: UITextField!
    
    @IBOutlet weak var mExchangeRateLabel: UILabel!
    
    @IBOutlet weak var mExchangeRateValue: UITextField!
    
    @IBOutlet weak var mConvertedAmount: UILabel!
    
    @IBOutlet weak var mSelectPaymentOptionContainer: UIView!
    
    @IBOutlet weak var mSelectPaymentTab: UIView!
    
    @IBOutlet weak var mChequeSelect: UIButton!
    
    @IBOutlet weak var mIBSelect: UIButton!
    
    @IBOutlet weak var mSelectedTabIB: UILabel!
    
    @IBOutlet weak var mSelectedTabCheque: UILabel!
    let qrCodeView = QRCodeView.loadFromNib()
    var mConvertedAmounts = "0"
    
    
    var mClientReferenceID = ""
    var mClientSecreat = ""
    var mPaymentIntentID = ""
    var mPaymentID = ""
    var mStripPublishKey = ""
    var mPaymentMethod = ""
    var mSelectdPaymentMethod = ""
    
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
    var mCustomerId = ""
    var mCartTableData = NSMutableArray()
    var isQRCodeDeleted = false
    
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
    
    @IBOutlet weak var mClearBUTTON: UIButton!
    
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
    
    @IBOutlet weak var mEnterIBAmount: UITextField!
    @IBOutlet weak var mChossebackNameLabel: UITextField!
    @IBOutlet weak var mChooseIBBankImage: UIImageView!
    
    @IBOutlet weak var mCardNumberContainer: UIView!
    @IBOutlet weak var mCardNameContainer: UIStackView!
    
    
    
    var mChequePaymentId = ""
    var mCreditCardPaymentId = ""
    var mCreditCardLogo = ""
    var mCreditCardName = ""

    let mDatePicker:UIDatePicker = UIDatePicker()
    var mChequeData = NSMutableDictionary()
    var mFinalPaymentMethod = NSMutableDictionary()
    
    var mFTOTAL = ""
    
    
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
        
        if let mStoreCurr = UserDefaults.standard.string(forKey: "storeCurrency") {
             mStoreCurrency = mStoreCurr
        }
        
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
        
        mBTotalLABEL.text = "Total".localizedString
        mCreditCardLabel.text = "Credit Card".localizedString
        
        mExchangeRateLabel.text = "Exchange Rate".localizedString
        mPayNowButton.setTitle("PAY NOW".localizedString, for: .normal)
        mApplyGiftBUTTON .setTitle("APPLY".localizedString, for: .normal)
        mGiftCardAmount.placeholder = "Gift Card number".localizedString
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
    var mTaxDiscountAmount = 0
    var mTaxDiscountPercent = 0
    var mTaxTypeIE = ""
    var mOrderId = ""
    
    @IBOutlet weak var mGCurrency: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        mGCurrency.text = UserDefaults.standard.string(forKey: "currencySymbol") ?? "$"
        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")

        
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
            mCreditNoteView.isHidden = true
            mCreditNotesView.isHidden = true
        }
        
        if let mData = UserDefaults.standard.object(forKey: "CREDITCARDDATA") as? NSArray {
            if mData.count > 0 {
                self.mPaymentData = mData
                self.mCollectionView.delegate = self
                self.mCollectionView.dataSource = self
                self.mCollectionView.reloadData()
            }
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
        self.mSelectPaymentTab.isHidden = true
        self.mSelectPaymentOptionContainer.isHidden = true
 
       
    }
    
    
    @IBAction func mCancelEnterAmount(_ sender: Any) {
        if var text = mEnterIBAmount.text {
            text.removeLast()
            mEnterIBAmount.text = text
        }
        
    }
    
    @IBAction func mChosseIBBank(_ sender: Any) {
        var mBankNames = ["Choose Bank"]
            let mBankTypeFilter = "IB" // Define the filter type
            var mBankImage = ["https://art.gis247.net/assets/images/icon/camera_profile.png"]
            var mPMId = [""]
            
            if let mBankData = UserDefaults.standard.object(forKey: "BANKDATA") as? NSArray {
                if mBankData.count > 0 {
                    for i in mBankData {
                        if let data = i as? NSDictionary {
                            // Check if the BankPaymenttype matches "IB"
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
                        self.mChossebackNameLabel.text = item
                        self.mChooseIBBankImage.downlaodImageFromUrl(urlString: mBankImage[index])
                    }
                    
                    dropdown.show()
                } else {
                    CommonClass.showSnackBar(message: "Please add authorised bank!")
                }
            }
    }
    
    @IBAction func mScanQRCode(_ sender: Any) {
        if mEnterIBAmount.text?.isEmpty == true || (Double(mEnterIBAmount.text ?? "") ?? 0.0) == 0 {
           CommonClass.showSnackBar(message: "Please fill amount!")
           return
       }
      
    if mChossebackNameLabel.text == "Choose Bank" || mChossebackNameLabel.text?.isEmpty == true {
           CommonClass.showSnackBar(message: "Please choose a bank name!")
           return
       }
       mGenerateQRCode()
        
    }
    
    
    @IBAction func mTakePhoto(_ sender: Any) {
        
    }
    
    
    
    @IBAction func mIBTabSelect(_ sender: Any) {
        mSelectPaymentOptionContainer.isHidden =  false
        mChequeDetailsView.isHidden = true
         mIBSelect.isSelected = true
         mChequeSelect.isSelected = false
         
         // Update background colors
         mSelectedTabIB.backgroundColor = UIColor(named: "themeColor")
         mSelectedTabCheque.backgroundColor = UIColor(named: "themeExtraLightText")
      
    }
    
    @IBAction func mChequeTabSelect(_ sender: Any) {
        mSelectPaymentOptionContainer.isHidden = true
        mChequeDetailsView.isHidden = false
        mChequeSelect.isSelected = true
          mIBSelect.isSelected = false
          
          // Update background colors
          mSelectedTabCheque.backgroundColor = UIColor(named: "themeColor")
          mSelectedTabIB.backgroundColor = UIColor(named: "themeExtraLightText")
    }
    
    
    override func viewDidLayoutSubviews() {
        
    }
    
    @IBAction func mApplyGiftCard(_ sender: UIButton) {
        sender.showAnimation{}
        if let giftCardAmount = mGiftCardAmount.text {
            mApplyGiftCards(cardNumber: giftCardAmount)
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
                                    if "\(value.value(forKey: "id") ?? "")" == "\(mCreditRow.value(forKey: "id") ?? "")"{
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
                                        
                                        mAmount.append(Double("\(value.value(forKey: "amount") ?? "0.0")") ?? 0)
                                        
                                        mCData.setValue("\(value.value(forKey: "amount") ?? "0.0")", forKey: "amount")
                                        self.mTotalCreditAmount.text = String(format:"%.02f",locale:Locale.current,mAmount.reduce(0, {$0 + $1}))
                                        
                                        self.mAmountData.add(mCData)
                                    }
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
        if var text = mCreditFillAmount.text {
            text.removeLast()
            mCreditFillAmount.text = text
        }
    }
    
    @IBAction func mCloseCreditView(_ sender: Any) {
        self.mCreditCardPaymentView.isHidden = true
    }
    
    @IBAction func mSubmitCreditAmount(_ sender: UIButton) {
        self.mGetStripeDataBackEnd()
        
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
                            
                            if let mId = mData.value(forKey: "insert_id") as? String {
                                let mCreditCardOptions = NSMutableDictionary()
                                mCreditCardOptions.setValue(self.mCreditCardPaymentId, forKey: "cardPaymentId")
                                mCreditCardOptions.setValue(amount, forKey: "amount")
                                mCreditCardOptions.setValue(mId, forKey: "id")
                                self.mCreditCardMethod.add(mCreditCardOptions)
                                var mAmount = [Double]()
                                
                                for i in self.mCreditCardMethod {
                                    if let mAM = i as? NSDictionary {
                                        mAmount.append(Double("\(mAM.value(forKey: "amount") ?? "")") ?? 0)
                                    }
                                }
                                self.mSubmittedCreditCard.text = "\( mAmount.reduce(0, {$0 + $1}))"

                                let submittedCash = Double(mSubmittedCash.text ?? "") ?? 0
                                let submittedBankAmount = Double(mSubmittedBankAmount.text ?? "") ?? 0
                                let submittedCreditCard = Double(mSubmittedCreditCard.text ?? "") ?? 0
                                self.mTOTALAMOUNT.text  = "\(submittedCash + submittedBankAmount + submittedCreditCard)".formatPrice()
                            }
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
        // Calculate cell size
        let width = (collectionView.frame.width / 2) - 16
        let height = (collectionView.frame.height / 2) - 16
        return CGSize(width: width, height: height)
    }

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        mStripeIndex = indexPath.row
        if let mData = mPaymentData[indexPath.row] as? NSDictionary {
            mCreditCardPaymentId = mData.value(forKey: "id") as? String ?? ""
            mCreditCardName = "\(mData.value(forKey: "name") ?? "")"
            mCreditCardLogo = "\(mData.value(forKey: "PayMethod_logo") ?? "")"
            self.mCreditBankImage.downlaodImageFromUrl(urlString: "\(mData.value(forKey: "PayMethod_logo") ?? "")")
            self.mCreditBankName.text = mData.value(forKey: "name") as? String
            mPaymentID = "\(mData.value(forKey: "id") ?? "")"
            mPaymentMethod = "\(mData.value(forKey: "PaymentMethod") ?? "")"
            mStripPublishKey = "\(mData.value(forKey: "key") ?? "")"
            mSelectdPaymentMethod = "\(mData.value(forKey: "payment_slag") ?? "")"
        }
        mCardNumber.text = ""
        mCardName.text = ""
        mCreditFillAmount.text = ""
        self.mStripeCardView.isHidden = false
        self.mCreditCardBanksView.isHidden = true
        if mSelectdPaymentMethod == "stripe-payment" || mSelectdPaymentMethod == "paypal-payment" {
            
            self.mCardNumberContainer.isHidden = true
            self.mCardNameContainer.isHidden = true
        }else {
            self.mCardNumberContainer.isHidden = false
            self.mCardNameContainer.isHidden = false
        }
        self.mCollectionView.reloadData()
        
    }
    
    
    func mFetchStore(key: String){
        let mLocation = UserDefaults.standard.string(forKey: "location")
        
        let urlPath =  mFetchPaymentMethod
        _ = ["login_token": mUserLoginToken ?? "", "location_id":mLocation ?? ""]
        if Reachability.isConnectedToNetwork() == true {
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
                        
                        if let mPaymentMethod = jsonResult.value(forKey: "data") as? NSDictionary {
                            
                            if let mData = mPaymentMethod.value(forKey: "Credit_Card") as? NSArray, mData.count > 0 {
                                self.mPaymentData = mData
                                self.mCollectionView.delegate = self
                                self.mCollectionView.dataSource = self
                                self.mCollectionView.reloadData()
                            }
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
                
                self.mTOTALAMOUNT.text = "\((Double(mConvertedAmounts) ?? 0) + (Double(mSubmittedBankAmount.text ?? "") ?? 0) + (Double(mSubmittedCreditCard.text ?? "") ?? 0))".formatPrice()
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
        
        
        mCheqDate.text = deliveryDate
        
        self.view.endEditing(true)
        
    }
    @objc func mCancelDatePick(){
        self.view.endEditing(true)
    }
    
    @IBAction func mChooseBanks(_ sender: Any) {
        
//        var mBankNames = ["Choose Bank"]
//        var mBankImage = ["https://art.gis247.net/assets/images/icon/camera_profile.png"]
//        var mPMId = [""]
//        
//        
//        
//        if let mBankData = UserDefaults.standard.object(forKey: "BANKDATA") as? NSArray {
//            if mBankData.count > 0 {
//                for i in mBankData {
//                    if let data = i as? NSDictionary {
//                        mBankNames.append("\(data.value(forKey: "name") ?? "")")
//                        mBankImage.append("\(data.value(forKey: "PayMethod_logo") ?? "")")
//                        mPMId.append("\(data.value(forKey: "id") ?? "")")
//                    }
//                }
//                let dropdown = DropDown()
//                dropdown.anchorView = self.mCheqBankName
//                dropdown.direction = .bottom
//                dropdown.layer.cornerRadius = 15
//                dropdown.backgroundColor = .white
//                dropdown.bottomOffset = CGPoint(x: 0, y: 50)
//                dropdown.width = self.view.frame.width - 32
//                dropdown.dataSource = mBankNames
//                dropdown.cellNib = UINib(nibName: "Currency", bundle: nil)
//                dropdown.customCellConfiguration = {
//                    (index:Index, item:String,cell: DropDownCell) -> Void in
//                    guard let cell = cell as? CurrencyCell else { return}
//                    
//                    cell.mCurrencyImage.downlaodImageFromUrl(urlString: "\(mBankImage[index])")
//                }
//                dropdown.selectionAction = {
//                    [unowned self](index:Int, item: String) in
//
//                    self.mChequePaymentId = mPMId[index]
//                    self.mCheqBankName.text = item
//                    self.mCheqBankImage.downlaodImageFromUrl(urlString: mBankImage[index])
//                    
// 
//                }
//                dropdown.show()
//            }else{CommonClass.showSnackBar(message: "Please add authorised bank!")}
//        }
        
        var mBankNames = ["Choose Bank"]
            let mBankTypeFilter = "IB" // Define the filter type
            var mBankImage = ["https://art.gis247.net/assets/images/icon/camera_profile.png"]
            var mPMId = [""]
            
            if let mBankData = UserDefaults.standard.object(forKey: "BANKDATA") as? NSArray {
                if mBankData.count > 0 {
                    for i in mBankData {
                        if let data = i as? NSDictionary {
                            // Check if the BankPaymenttype matches "IB"
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
                    recheckBalanceDue()
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
            mChequeData.setValue("Bank", forKey: "Paymentmethod_type")

            self.mBankPayment.add(mChequeData)
            
      

            var mAmounts = [Double]()
            for i in mBankPayment {
                if let mData = i as? NSDictionary {
                    mAmounts.append(Double("\(mData.value(forKey: "amount") ?? "0.0")".replacingOccurrences(of: ",", with: "")) ?? 0.00)
                }
            }
            
            mSubmittedBankAmount.text = "\(mAmounts.reduce(0, {$0 + $1}))"
            
            let mTotalValue = (Double(mCashAmounts) ?? 0.00) + (Double(mSubmittedBankAmount.text ?? "") ?? 0.00) + (Double(mSubmittedCreditCard.text ?? "") ?? 0.0)
            
            self.mTOTALAMOUNT.text = "\(mTotalValue)".formatPrice()
            
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

        guard let cells = tableView.dequeueReusableCell(withIdentifier: "CreditNoteList") as? CreditNoteList else {
            return UITableViewCell()
        }
        
        if let mData =  mCreditNoteData[indexPath.row] as? NSDictionary {
            cells.mType.text = mData.value(forKey: "type") as? String
            cells.mRefNo.text = mData.value(forKey: "Ref_No") as? String
            cells.mDate.text = mData.value(forKey: "date") as? String
            cells.mAmount.tag = indexPath.row
            
            cells.mView.backgroundColor = (indexPath.row % 2 == 0) ? UIColor(named: "themeBackground") : #colorLiteral(red: 0.9568627451, green: 0.9568627451, blue: 0.9568627451, alpha: 1)
            
            if mSelectedCustomIndex.contains(indexPath) {
                if let mDataSet = mAmountData[indexPath.row] as? NSDictionary {
                    cells.mAmount.text = "\(mDataSet.value(forKey: "amount") ?? "0.0")"
                }
            } else {
                cells.mAmount.text = "\(mData.value(forKey: "amount") ?? "0.0")"
            }
            
            if mSelectedIndex.contains(indexPath) {
                cells.mCheckImage.image = UIImage(named: "check_item" )
            }else{
                cells.mCheckImage.image = UIImage(named: "uncheck_item" )
            }
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
        return 60
        
    }
    
    
    @IBAction func mAmountEdit(_ sender: UITextField) {
        
        if let mMaxData =  mCreditNoteData[sender.tag] as? NSDictionary {
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
                    if let mMaxData =  mCreditNoteData[index] as? NSDictionary {
                        let mCData = NSMutableDictionary()
                        
                        mCData.setValue("\(mData.value(forKey: "amount") ?? "0.0")", forKey: "amount")
                        mCData.setValue("\(mMaxData.value(forKey: "id") ?? "")", forKey: "payment_method_id")
                        mCreditData.add(mCData)
                        
                        mCreditDataMerged.add(mCData)
                    }
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
        
        let submittedCashDouble = Double(mSubmittedCash.text ?? "") ?? 0
        let submittedBankAmount = Double(mSubmittedBankAmount.text ?? "") ?? 0
        let submittedCreditCard = Double(mSubmittedCreditCard.text ?? "") ?? 0
        self.mTOTALAMOUNT.text = "\(submittedCashDouble + submittedBankAmount + submittedCreditCard)".formatPrice()
        
    }
    
    @IBAction func mSubmitCredit(_ sender: Any) {
        mGetTotalAmount()
    }
    
    @IBAction func mBack(_ sender: Any) {
        self.dismiss(animated: true)
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
        self.mSelectPaymentTab.isHidden = true
        self.mSelectPaymentOptionContainer.isHidden = true
        mChequeDetailsView.isHidden = true
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
        self.mSelectPaymentTab.isHidden = true
        self.mSelectPaymentOptionContainer.isHidden = true
        mChequeDetailsView.isHidden = true
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
        mIBSelect.isSelected = true
        mChequeSelect.isSelected = false
        mSelectPaymentTab.isHidden = false
        mSelectPaymentOptionContainer.isHidden = false
        mChequeDetailsView.isHidden = true
        
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
        self.mSelectPaymentTab.isHidden = true
        self.mSelectPaymentOptionContainer.isHidden = true
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
        print("check 1")
        mSUBLABEL.showAnimation{}
        if mTransactionType == "Cash" {
            
            if (Double(mConvertedAmounts) ?? 0.00) == 0 {
                
                CommonClass.showSnackBar(message: "Please fill valid amount!")
                return
            }
            self.mSubmittedCash.text = "\(mCashAmounts)"
            
            let mTotalValue =  (Double(mConvertedAmounts) ?? 0.00) + (Double(mSubmittedBankAmount.text ?? "") ?? 0.00) + (Double(mSubmittedCreditCard.text ?? "") ?? 0.00)
            
            self.mTOTALAMOUNT.text = "\(mTotalValue)".formatPrice()
           
            CommonClass.showSnackBar(message: "Amount Added Successfully!")

        }
        
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

                self.mCurrencyName.text = item
                self.mSelectedStoreCurrency = item
                self.mCashCurrencyImage.downlaodImageFromUrl(
                    urlString: self.mCurrencyImageData[index]
                )

                if item == self.mStoreCurrency {

                    self.mExchangeRateLabel.isHidden = true
                    self.mExchangeRateValue.isHidden = true
                    self.mExchangeRateValue.text = ""

                    if self.mCashAmount.text != "" &&
                        self.mCashAmount.text != "." {

                        self.mConvertedAmounts =
                            "\(Double(self.mCashAmounts) ?? 0)"

                        let amount =
                            Double(self.mConvertedAmounts) ?? 0

                        let rounded =
                            (amount * 100).rounded() / 100

                        self.mConvertedAmount.text =
                            "= \(item) \(rounded)"
                    }

                } else {

                    self.mExchangeRateLabel.isHidden = false
                    self.mExchangeRateValue.isHidden = false

                    guard index < self.mExchangeRateData.count else {
                        return
                    }

                    let selectedRate =
                        Double(self.mExchangeRateData[index]) ?? 1.0

                    var storeRate: Double = 1.0

                    for (i, currency) in self.mCurrencyNameData.enumerated() {

                        if currency == self.mStoreCurrency {

                            storeRate =
                                Double(self.mExchangeRateData[i]) ?? 1.0

                            break
                        }
                    }

                    guard storeRate > 0 else {
                        return
                    }

                    // Backend Formula
                    // Resultant Exchange Rate =
                    // Selected Currency Rate / Store Currency Rate

                    let resultantRate =
                        selectedRate / storeRate

                    self.mExchangeRateValue.text =
                        String(format: "%.8f", resultantRate)
                }

                self.mInsertAmount(num: "")
            }

            dropdown.show()
        
    }
    
    @IBAction func mExchangeRate(_ sender: UITextField!) {
        
        if sender.text == "" {
            mConvertedAmounts = "0"
            if mCashAmount.text != "" && mCashAmount.text != "."  {
                mConvertedAmounts = "\(Double(mCashAmounts) ?? 0)"
                let mDecimalAmount = ((Double(mConvertedAmounts) ?? 0) * 100).rounded() / 100
                
                mConvertedAmount.text = "= \(self.mCurrencyName.text ?? "") \(mDecimalAmount)"            }
        }else{
            if mTransactionType == "Cash" {
                if mExchangeRateLabel.isHidden == false {
                    if mExchangeRateValue.text != "" {
                        let mVal = Double(mExchangeRateValue.text ?? "") ?? 0
                        if mCashAmount.text != "" && mCashAmount.text != "."  {
//                            mConvertedAmounts = "\((Double(mCashAmounts) ?? 0) * mVal)"
//                            let mDecimalAmount = ((Double(mConvertedAmounts) ?? 0) * 100).rounded() / 100
//                            
//                            mConvertedAmount.text = "= \(self.mCurrencyName.text ?? "") \(mDecimalAmount)"
                            guard mVal > 0 else { return }
                            let convertedAmount = (Double(mCashAmounts) ?? 0) / mVal
                            mConvertedAmounts = "\(convertedAmount)"
                            let mDecimalAmount = (convertedAmount * 100).rounded() / 100
                            mConvertedAmount.text = "= \(self.mCurrencyName.text ?? "") \(mDecimalAmount)"
                        }
                    }
                }else{
                    if mCashAmount.text != "" && mCashAmount.text != "."  {
                        mConvertedAmounts = "\(Double(mCashAmounts) ?? 0)"
                        let mDecimalAmount = ((Double(mConvertedAmounts) ?? 0) * 100).rounded() / 100
                        
                        mConvertedAmount.text = "= \(self.mCurrencyName.text ?? "") \(mDecimalAmount)"
                    }
                }
            }
        }
    }
    
    private func recheckBalanceDue() {
        self.mBALANCEDUE.text = "\(Double(self.mTOTALAMOUNT.text!.replacingOccurrences(of: ",", with: ""))! - Double(mConvertedAmounts)! - Double(mSubmittedCreditNote.text!)! - Double(mSubmittedBankAmount.text!)! - Double(mSubmittedCreditCard.text!)! )".formatPrice()
    }
    
    @IBAction func mClear(_ sender: UIButton) {
        sender.showAnimation{}
        
        mCashAmount.text = ""
        mConvertedAmount.text = ""
        mConvertedAmounts = "0"
        mCashAmounts = ""
    }
    
    @IBAction func mDeleteCashAmount(_ sender: Any) {
        if mCashAmounts != "" {
            mCashAmounts.removeLast()
            mCashAmount.text = mCashAmounts
            if mCashAmounts == "" {
                mConvertedAmounts = "0"
                mSubmittedCash.text = "0.0"
                self.mTOTALAMOUNT.text = "\((Double(mConvertedAmounts) ?? 0) + (Double(mSubmittedBankAmount.text ?? "") ?? 0) + (Double(mSubmittedCreditCard.text ?? "") ?? 0) )".formatPrice()
            }
            
        }else{
            
            
        }
        if mCashAmounts == "" {
            mConvertedAmounts = "0"
            mConvertedAmount.text = "= \(self.mCurrencyName.text ?? "") 00.00"
        }
        if mTransactionType == "Cash" {
            if mExchangeRateLabel.isHidden == false {
                if mExchangeRateValue.text != "" {
                    let mVal = Double(mExchangeRateValue.text ?? "") ?? 0
                    if mCashAmount.text != "" {
//                        mConvertedAmounts = "\((Double(mCashAmounts) ?? 0) * mVal)"
//                        let mDecimalAmount = ((Double(mConvertedAmounts) ?? 0) * 100).rounded() / 100
//                        
//                        mConvertedAmount.text = "= \(self.mCurrencyName.text ?? "") \(mDecimalAmount)"
                        guard mVal > 0 else { return }
                        let convertedAmount = (Double(mCashAmounts) ?? 0) / mVal
                        mConvertedAmounts = "\(convertedAmount)"
                        let mDecimalAmount = (convertedAmount * 100).rounded() / 100
                        mConvertedAmount.text = "= \(self.mCurrencyName.text ?? "") \(mDecimalAmount)"
                    }
                }
            }else{
                if mCashAmounts != "" {
                    mConvertedAmounts = "\(Double(mCashAmounts) ?? 0)"
                    let mDecimalAmount = ((Double(mConvertedAmounts) ?? 0) * 100).rounded() / 100
                    
                    mConvertedAmount.text = "= \(self.mCurrencyName.text ?? "") \(mDecimalAmount)"
                }
            }
        }
    }
    
//    func mInsertAmount(num : String){
//        
//        mCashAmounts.insert(contentsOf: num, at: mCashAmounts.endIndex)
//        if mCashAmounts.filter({$0 == "."}).count > 1 {
//            mCashAmounts.removeLast()
//            return
//        }
//
//        mCashAmount.text = mCashAmounts
//    
//        if mTransactionType == "Cash" {
//            if mExchangeRateLabel.isHidden == false {
//                if mExchangeRateValue.text != "" {
//                    let mVal = Double(mExchangeRateValue.text ?? "") ?? 0
//                    if mCashAmount.text != "" && mCashAmount.text != "."  {
//                        mConvertedAmounts = "\((Double(mCashAmounts) ?? 0) * mVal)"
//                        let mDecimalAmount = ((Double(mConvertedAmounts) ?? 0) * 100).rounded() / 100
//                        
//                        mConvertedAmount.text = "= \(self.mCurrencyName.text ?? "") \(mDecimalAmount)"
//                    }
//                }
//            }else{
//                if mCashAmount.text != "" && mCashAmount.text != "."  {
//                    mConvertedAmounts = "\(Double(mCashAmounts) ?? 0)"
//                    let mDecimalAmount = ((Double(mConvertedAmounts) ?? 0) * 100).rounded() / 100
//                    
//                    mConvertedAmount.text = "= \(self.mCurrencyName.text ?? "") \(mDecimalAmount)"
//                }
//            }
//        }
//    }
    
    func mInsertAmount(num: String) {

        mCashAmounts.insert(contentsOf: num, at: mCashAmounts.endIndex)
        mCashAmount.text = mCashAmounts

        if mTransactionType == "Cash" {

            if mExchangeRateLabel.isHidden == false {

                let resultantRate =
                    Double(mExchangeRateValue.text ?? "") ?? 0

                guard resultantRate > 0 else {
                    return
                }

                if mCashAmount.text != "" &&
                    mCashAmount.text != "." {

                    let cashAmount =
                        Double(mCashAmounts) ?? 0

                    // Backend Formula
                    // Converted Amount =
                    // Store Amount / Resultant Exchange Rate

                    let convertedAmount =
                        cashAmount * resultantRate

                    mConvertedAmounts =
                        "\(convertedAmount)"

                    let rounded =
                        (convertedAmount * 100).rounded() / 100

                    mConvertedAmount.text =
                        "= \(self.mCurrencyName.text ?? "") \(rounded)"
                }

            } else {
                if mCashAmount.text != "" &&
                    mCashAmount.text != "." {

                    let cashAmount = Double(mCashAmounts) ?? 0

                    // The default currency is the store currency, so no exchange
                    // rate is required. Keep the entered cash value as the amount
                    // to submit; otherwise SUB incorrectly treats it as zero.
                    let convertedAmount = cashAmount
                    mConvertedAmounts = "\(convertedAmount)"

                    let rounded =
                        (convertedAmount * 100).rounded() / 100

                    mConvertedAmount.text =
                        "= \(self.mCurrencyName.text ?? "") \(rounded)"
                }
            }
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
        if status {

                mFinalPaymentMethod = NSMutableDictionary()
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
            
                mSummaryOrder.setValue(mCustomerId, forKey: "customer_id")
                mSummaryOrder.setValue(selectedSalesPersonId, forKey: "sales_person_id")
        
                mSummaryOrder.setValue(Int(mDepositPercents), forKey: "deposit")
                mSummaryOrder.setValue(Double(mTotalP), forKey: "deposit_amount")
        
                //Credit Note Calculations
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

                //CreditCard/Bank/Cash Addition
                mPayData.setValue(mCashMethod, forKey: "cash")
                mPayData.setValue(mBankPayment, forKey: "bank")
                mPayData.setValue([], forKey: "IB")
                mPayData.setValue(mCreditCardMethod, forKey: "credit_card")
                mPayData.setValue(mCreditNoteMethod, forKey: "credit_note")
                mPayData.setValue("", forKey: "gift_card")

                //SellInfo (Cart Data , Summary Order, Status)
                print("DEBUG_CART_DATA AddDepositController isVerified = \(mCartTableData)")
                mSellInfo.setValue(mCartTableData, forKey: "cart")
                mSellInfo.setValue(mSummaryOrder, forKey: "summary_order")
                mSellInfo.setValue(mOrderType, forKey: "status_type")
                mSellInfo.setValue(Double(mCartTotalAmount) ?? 0.00, forKey: "totalamount")

                //PaymentInfo (Debited amount, Pay Data(Card/Bank), )
                mPaymentInfo.setValue(mDebitedAmount, forKey: "debited_amount")
                mPaymentInfo.setValue(mPayData, forKey: "pay_data")
                mPaymentInfo.setValue("", forKey: "balance_due")
                mPaymentInfo.setValue("", forKey: "balance_deposit")
         
          


            mFinalPaymentMethod = ["sell_info": mSellInfo, "payment_info":mPaymentInfo,"transaction_date": "","customer_id":self.mCustomerId,"sales_person_id":selectedSalesPersonId,"order_type":self.mOrderType , "order_id":self.mOrderId]
         
        }
    }
    @IBAction func mPayNow(_ sender: UIButton) {
        sender.showAnimation{}
        
        if (Double((mTOTALAMOUNT.text ?? "").replacingOccurrences(of: ",", with: "")) ?? 0.00) != 0 {
            
            mFinalPaymentMethod = NSMutableDictionary()
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
        
            mSummaryOrder.setValue(mCustomerId, forKey: "customer_id")
            mSummaryOrder.setValue(selectedSalesPersonId, forKey: "sales_person_id")
    
            mSummaryOrder.setValue(Int(mDepositPercents), forKey: "deposit")
            mSummaryOrder.setValue(Double(mTotalP), forKey: "deposit_amount")
    
            //Credit Note Calculations
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

            //CreditCard/Bank/Cash Addition
            mPayData.setValue(mCashMethod, forKey: "cash")
            mPayData.setValue(mBankPayment, forKey: "bank")
            mPayData.setValue([], forKey: "IB")
            mPayData.setValue(mCreditCardMethod, forKey: "credit_card")
            mPayData.setValue(mCreditNoteMethod, forKey: "credit_note")
            mPayData.setValue("", forKey: "gift_card")

            //SellInfo (Cart Data , Summary Order, Status)
            print("DEBUG_CART_DATA AddDepositController mPayNow = \(mCartTableData)")
            mSellInfo.setValue(mCartTableData, forKey: "cart")
            mSellInfo.setValue(mSummaryOrder, forKey: "summary_order")
            mSellInfo.setValue(mOrderType, forKey: "status_type")
            mSellInfo.setValue(Double(mCartTotalAmount) ?? 0.00, forKey: "totalamount")

            //PaymentInfo (Debited amount, Pay Data(Card/Bank), )
            mPaymentInfo.setValue(mDebitedAmount, forKey: "debited_amount")
            mPaymentInfo.setValue(mPayData, forKey: "pay_data")
            mPaymentInfo.setValue("", forKey: "balance_due")
            mPaymentInfo.setValue("", forKey: "balance_deposit")
     
            
            var isCash = false
            var isBank = false
            var isCard = false
            
            if (Double(self.mSubmittedCash.text ?? "") ?? 0.00) != 0 {
                isCash = true
            }
            if (Double(self.mSubmittedBankAmount.text ?? "") ?? 0.00) != 0 {
                isBank = true
            }
            if (Double(self.mSubmittedCreditCard.text ?? "") ?? 0.00) != 0 {
                isCard = true
            }
            
            let mFinalData = NSMutableDictionary()
            
            mFinalData.setValue(mSellInfo, forKey: "sell_info")
            mFinalData.setValue(mPaymentInfo, forKey: "payment_info")
            mFinalData.setValue(isCash, forKey: "isCash")
            mFinalData.setValue(isBank, forKey: "isBank")
            mFinalData.setValue(isCard, forKey: "isCard")
            
            mFinalPaymentMethod = mFinalData
      
            self.dismiss(animated: true)
            self.delegate?.mGetPaymentInfo(items:mFinalPaymentMethod)
            
        }else{
            CommonClass.showSnackBar(message: "Please enter valid amount!")
        }
        
        
  
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
            self.mDiscountAmounts.text = "\(calculatePercentage(value: Double(mTotalAm) ?? 0, percent: Double(sender.text ?? "") ?? 0))"
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
        let mDiscountA = Double(self.mDiscountAmounts.text ?? "") ?? 0
        let mLabour = Double(self.mLabourCharge.text ?? "") ?? 0
        let mShipping = Double(self.mShippingCharge.text ?? "") ?? 0
        mAmount = mLabour + mShipping
        
        if mTaxType.lowercased() == "inclusive" {
            mTotalDiscountTx.text = mDiscountAmounts.text
            mTotalTx.text = "\((mAmount + (Double(mTotalAm) ?? 0)) )"
            mTaxAmountTx.text = String(format:"%.02f",locale:Locale.current,calculateInclusiveTax(value: (Double(mTotalTx.text ?? "") ?? 0) - (Double(mDiscountAmounts.text ?? "") ?? 0), percent: (Double(mTaxP) ?? 0)))
            mSubTotalTx.text = String(format:"%.02f",locale:Locale.current,(Double(mTotalTx.text ?? "") ?? 0) - (Double(mDiscountAmounts.text ?? "") ?? 0) - (Double((mTaxAmountTx.text ?? "").replacingOccurrences(of: ",", with: "")) ?? 0) )
            
            mFinalTaxAmount.text = mTaxAmountTx.text
            mTOTALAMOUNT.text = "\((mAmount + (Double(mTotalAm) ?? 0) - mDiscountA))".formatPrice()
            let totalAmount = Double(mTOTALAMOUNT.text ?? "") ?? 0
            let submittedCash = Double(mSubmittedCash.text ?? "") ?? 0
            let submittedCreditNote = Double(mSubmittedCreditNote.text ?? "") ?? 0
            let submittedBankAmount = Double(mSubmittedBankAmount.text ?? "") ?? 0
            let submittedCreditCard = Double(mSubmittedCreditCard.text ?? "") ?? 0
            mBALANCEDUE.text = "\(totalAmount - submittedCash - submittedCreditNote - submittedBankAmount - submittedCreditCard)".formatPrice()

        }else{
            mTotalDiscountTx.text = mDiscountAmounts.text
            mTotalTx.text = "\(mAmount + (Double(mTotalAm) ?? 0))"
            
            mTaxAmountTx.text = String(format:"%.02f",locale:Locale.current,calculateExclusiveTax(value: (Double(mTotalTx.text ?? "") ?? 0) - (Double(mDiscountAmounts.text ?? "") ?? 0), percent: (Double(mTaxP) ?? 0)))
            
            mSubTotalTx.text = String(format:"%.02f",locale:Locale.current,(Double(mTotalTx.text ?? "") ?? 0) - (Double(mDiscountAmounts.text ?? "") ?? 0))
            mFinalTaxAmount.text = mTaxAmountTx.text
            
            mTOTALAMOUNT.text = "\((Double((mSubTotalTx.text ?? "").replacingOccurrences(of: ",", with: "")) ?? 0) + (Double((mTaxAmountTx.text ?? "").replacingOccurrences(of: ",", with: "")) ?? 0))"
            let totalAmount = Double(mTOTALAMOUNT.text ?? "") ?? 0
            let submittedCash = Double(mSubmittedCash.text ?? "") ?? 0
            let submittedCreditNote = Double(mSubmittedCreditNote.text ?? "") ?? 0
            let submittedBankAmount = Double(mSubmittedBankAmount.text ?? "") ?? 0
            let mSubmittedCreditCard = Double(mSubmittedCreditCard.text ?? "") ?? 0
            mBALANCEDUE.text = "\(totalAmount - submittedCash - submittedCreditNote - submittedBankAmount - mSubmittedCreditCard)"
            
        }
        
    }
   
    func textFieldDidEndEditing(_ textField: UITextField) {
        _ = textField.text
    }

    func mFetchCreditNoteData(value: String){
        
        _ = UserDefaults.standard.string(forKey: "location")
        
        let urlPath =  mPOSCreditNote
        let params = ["customer_id":mCustomerId]
        
        
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
                            
                            self.mCreditNoteData =  NSMutableArray(array: mData)
                            self.mCreditNoteTable
                                .delegate = self
                            self.mCreditNoteTable
                                .dataSource = self
                            self.mCreditNoteTable
                                .reloadData()
                            var mAmount = [Double]()
                            for item in mData {
                                if let value = item as? NSDictionary {
                                    let mCData = NSMutableDictionary()
                                    
                                    mAmount.append(Double("\(value.value(forKey: "amount") ?? "")") ?? 0)
                                    
                                    mCData.setValue("\(value.value(forKey: "amount") ?? "")", forKey: "amount")
                                    self.mTotalCreditAmount.text = String(format:"%.02f",locale:Locale.current,mAmount.reduce(0, {$0 + $1}))
                                    
                                    self.mAmountData.add(mCData)
                                }
                            }
                            
                            
                        }
                    }else{
                        if let error = jsonResult.value(forKey: "error") as? String{
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
                      "POS_Final_CreditNote_Amount":"\(self.mSubmittedCreditNote.text ?? "")",
                      
                      
                      "finalAmountsat_side_DueAmount":self.mBALANCEDUE.text ?? "",
                      "salesPersonId":mSalesPersonId ?? "",
                      "Customer_id":mCustomerId ?? "",
                      "Order_type":"Sales Order",
                      "Remark":"",
                      "cartTableData":self.mCartTableData,
                      
                      
            ]
            
            
        }else if mOrderType == "custom_oreder" {
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
                      "cartTableData":self.mCartTableData,
                      
            ]
            
        }else if self.mOrderType == "Repair Order" {
            urlPath =  mSubmitRepairDesign
            
            params =    [
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
                
                self.navigationController?.pushViewController(mPin, animated:true)
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
                        
                        UserDefaults.standard.setValue("\(jsonResult.value(forKey: "pdf_url") ?? "")", forKey: "reportAPI")
                        self.mGenerateReport(id:"\(jsonResult.value(forKey: "pdf_url") ?? "")" , jsonResult : jsonResult)
                        
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
                    
                    UserDefaults.standard.setValue("\(jsonVal.value(forKey: "pdf_url") ?? "")", forKey: "report")
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
//                        mCompletePayment.mShippingInfo = [
//                            "billing_address": self.mSelectedBillingAddress,
//                            "shipping_address": self.mSelectedShippingAddress
//                        ]
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
        
        var _: [NSLayoutConstraint] = []
        
        
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
    
    // Mark-: Gernerate QR code Api -:
    
    
     func mGenerateQRCode() {
        let urlPath = mGetQRCode
        let mParams: [String: Any] = [
            "payment_id": mChequePaymentId,
            "amount": mEnterIBAmount.text ?? "0",
            "customerId": mCustomerId
        ]
        
        print(mParams, "check data")
        
        if Reachability.isConnectedToNetwork() {
            AF.request(urlPath, method: .post, parameters: mParams, headers: sGisHeaders2).responseJSON { response in
                print(response, "check response")
                
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
    
 
    
    //  MARK: Delegate method to handle cancel button action
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
        paymentSheet.present(from: self) { paymentResult in
            DispatchQueue.main.async {
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
                    mCreditCardData.setValue(self.mClientReferenceID, forKey: "client_reference_id")
                    
                    self.mCreditCardMethod.add(mCreditCardData)
                    
                    var mAmounts = [Double]()
                    for i in self.mCreditCardMethod {
                        if let mData = i as? NSDictionary {
                            mAmounts.append(Double("\(mData.value(forKey: "amount") ?? "0.0")".replacingOccurrences(of: ",", with: "")) ?? 0.00)
                        }
                    }
                    
                    self.mSubmittedCreditCard.text = "\(mAmounts.reduce(0, {$0 + $1}))"
                    let mTotalValue = (Double(self.mSubmittedCash.text ?? "") ?? 0.00) + (Double(self.mSubmittedBankAmount.text ?? "") ?? 0.00) + (Double(self.mSubmittedCreditCard.text ?? "") ?? 0.00)
                    self.mTOTALAMOUNT.text = "\(mTotalValue)".formatPrice()
                    
                    self.mCreditCardLogo = ""
                    self.mCreditCardName = ""
                    self.mCreditCardPaymentId = ""
                    self.mCardNumber.text = ""
                    self.mCardName.text = ""
                    self.mCreditFillAmount.text = ""
                    
                    
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
                                print("Client Reference: \(self.mClientReferenceID)")
                                
                                self.StripePayment()
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
    
    func mGetPayementStatus() {
        
        guard !isQRCodeDeleted else { return }
        
        let urlPath = mGetPaymentStatus
        let mParams: [String: Any] = [
            "transactionId": self.mClientReferenceID
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
                                paymentSuccessView.setAmount("Amount: \(self.mEnterIBAmount.text ?? "")")
                                
                                if let successImage = UIImage(named: "successAmount") {
                                    paymentSuccessView.setImage(successImage)
                                }
                                
                                self.view.addSubview(paymentSuccessView)
                            }
                            
                            self.qrCodeView.isHidden = true
                            if let balanceDue = self.mBALANCEDUE.text {
                                let formattedBalanceDue = balanceDue.replacingOccurrences(of: ",", with: "")
                                let balanceDueInDouble = Double(formattedBalanceDue) ?? 0.0
                                let inputAmount = Double(self.mEnterIBAmount.text ?? "") ?? 0.0
                                if (balanceDueInDouble - inputAmount) < 0 {
                                    CommonClass.showSnackBar(message: "Please fill valid amount!")
                                    return
                                }
                            }
                            
                            //PAYMENTMETHODID
                            self.mChequeData = NSMutableDictionary()
                            self.mChequeData.setValue(self.mCheqDate.text ?? "", forKey: "transaction_date")
                            self.mChequeData.setValue(self.mCheqAccountNumber.text ?? "", forKey: "ac_no")
                            self.mChequeData.setValue(self.mCheqAccountName.text ?? "", forKey: "ac_name")
                            self.mChequeData.setValue(self.mChequePaymentId, forKey: "payment_method_id")
                            self.mChequeData.setValue(self.mCheqRefNumber.text ?? "", forKey: "ref_no")
                            self.mChequeData.setValue(self.mCheqInstNumber.text ?? "", forKey: "inst_no")
                            self.mChequeData.setValue(self.mEnterIBAmount.text ?? "", forKey: "amount")
                            self.mChequeData.setValue(self.mClientReferenceID, forKey: "client_reference_id")
                            self.mChequeData.setValue("Bank", forKey: "Paymentmethod_type")
                            
                            self.mBankPayment.add(self.mChequeData)
                            
                            
                            var mAmounts = [Double]()
                            for i in self.mBankPayment {
                                let mData = i as? NSDictionary
                                mAmounts.append(Double("\(mData?.value(forKey: "amount") ?? "0.0")".replacingOccurrences(of: ",", with: "")) ?? 0.00)
                            }
                            
                            self.mSubmittedBankAmount.text = "\(mAmounts.reduce(0, {$0 + $1}))"
                            
                            let totalAmount = Double(self.mTOTALAMOUNT.text?.replacingOccurrences(of: ",", with: "") ?? "") ?? 0.00
                            let submittedCreditNote = Double(self.mSubmittedCreditNote.text ?? "") ?? 0.00
                            let submittedBankAmount = Double(self.mSubmittedBankAmount.text ?? "") ?? 0.00
                            let submittedCreditCard = Double(self.mSubmittedCreditCard.text ?? "") ?? 0.00
                            let convertedAmounts = Double(self.mCashAmount.text ?? "0.0") ?? 0.00
                            
                            let mTotalValue = totalAmount - convertedAmounts - submittedCreditNote - submittedBankAmount - submittedCreditCard
                            
                            self.mBALANCEDUE.text = "\(mTotalValue)".formatPrice()
                            
                            self.mCheqDate.text = ""
                            self.mCheqAccountNumber.text = ""
                            self.mCheqAccountName.text = ""
                            self.mChequePaymentId = ""
                            self.mCheqBankName.text = "Choose Bank"
                            self.mCheqRefNumber.text = ""
                            
                            self.mEnterIBAmount.text = ""
                            self.mCheqInstNumber.text = ""
                            
                            
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
    
    
    
    
}
