//
//  CheckOutPage.swift
//  GIS
//
//  Created by Apple Hawkscode on 16/12/20.
//

import UIKit
import Alamofire
import DropDown
import PayPalWebPayments

 
class CreditNoteList : UITableViewCell {
    
    @IBOutlet weak var mNotes: UITextView!
    @IBOutlet weak var mParkItemsTable: UITableView!
    @IBOutlet weak var mCustomerName: UILabel!
    @IBOutlet weak var mView: UIView!
    @IBOutlet weak var mCheckImage: UIImageView!
    
    @IBOutlet weak var mMobile: UILabel!
    @IBOutlet weak var mType: UILabel!
    @IBOutlet weak var mDate: UILabel!
    @IBOutlet weak var mRefNo: UILabel!
    @IBOutlet weak var mAmount: UITextField!
    
    
}
open class CurrencyCell:DropDownCell {
    
    @IBOutlet weak var mCurrencyName: UILabel!
    @IBOutlet weak var mCurrencyImage: UIImageView!
}
class CheckOutPage: UIViewController, UITextFieldDelegate , UITableViewDelegate ,UITableViewDataSource , UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout{
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

    
    var mCurrencyImageData = [String]()
    var mCurrencyNameData = [String]()
    var mCashAmounts = ""
   var mSelectedStoreCurrency = ""
    var mStoreCurrency = ""
    @IBOutlet weak var mEditCashView: UIView!
    @IBOutlet weak var mCashCurrencyImage: UIImageView!
    
    @IBOutlet weak var mCurrencyName: UILabel!
    @IBOutlet weak var mChooseCurrencyButt: UIButton!
    
    @IBOutlet weak var mCashAmount:UITextField!
    
    @IBOutlet weak var mExchangeRateLabel: UILabel!
    
    @IBOutlet weak var mExchangeRateValue: UITextField!
    
    @IBOutlet weak var mConvertedAmount: UILabel!
    var mConvertedAmounts = "0"
    
    
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
    var mTransactionType = "CreditCard"
    var isExchange = false
   
    var mOrderType = ""
    var mSelectedBillingAddress: [String: Any] = [:]
    var mSelectedShippingAddress: [String: Any] = [:]
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
//    var PayPalWeb = PayPalWeb
    
    var mChequePaymentId = ""
    var mCreditCardPaymentId = ""
    let mDatePicker:UIDatePicker = UIDatePicker()
    var mChequeData = NSMutableDictionary()
    var mFinalPaymentMethod = NSMutableDictionary()

    var mFTOTAL = ""
    
   
    @IBOutlet weak var mSubmitButtonCredit: UIButton!
    @IBOutlet weak var mCloseButtonCredit: UIButton!
    @IBOutlet weak var mCreditCardPaymentView: UIView!
    @IBOutlet weak var mCreditFillAmount: UITextField!
    @IBOutlet weak var mStripeCardView: UIView!

    @IBOutlet weak var mCollectionView: UICollectionView!
    var mStripeIndex = 0
    var mPaymentData =  NSArray()
    
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
        
        
        
        mHCheckoutLABEL.text = "CHECK OUT".localizedString
        mCreditCardLABEL.text = "Credit Card".localizedString
        mCashLABEL.text = "Cash".localizedString
        mBankLABEL.text = "Bank".localizedString
        mCreditNoteLABEL.text = "Credit note".localizedString
        mTaxLABEL.text = "Tax".localizedString
        mCNTypeLABEL.text = "Type".localizedString
        mCNDate.text = "Date".localizedString
        mCNRefNoLABEL.text = "Ref No.".localizedString
        mCNAmountLABEL.text = "Amount".localizedString
        mCNTotalLABEL.text = "Total".localizedString
        mSUBLABEL.text = "SUB".localizedString
        mTLabourLABEL.text = "Labour".localizedString
        mTShippingLABEL.text = "Shipping".localizedString
        mLoyaltyPointLABEL.text = "Loyalty point".localizedString
        mTDiscountPLABEL.text = "Discount (%)".localizedString
        mTDiscountALABEL.text = "Discount (Amount)".localizedString
        mTaxPLABEL.text = "TAX (%)".localizedString
        mTaxALABEL.text = "TAX (Amount)".localizedString
        mBCreditCardLABEL.text = "Credit Card".localizedString
        mBCashLABEL.text = "Cash".localizedString
        mBBankLABEL.text = "Bank".localizedString
        mBCreditNoteLABEL.text = "Credit Note".localizedString
        mTxTotalLABEL.text = "Total".localizedString
        mTxSubTotalLABEL.text = "Sub Total".localizedString
        mTxExchangeLABEL.text = "Exchange".localizedString
        mBTotalLABEL.text = "Total".localizedString
        mBBalanceDueLABEL.text = "Balance Due".localizedString
        mTxDiscountLABEL.text = "Discount".localizedString
        mCreditCardLabel.text = "Credit/Debit".localizedString
        mApplePayLabel.text = "Apple Pay".localizedString
        mAliPayLabel.text = "Alipay".localizedString
        mWeChatPayLabel.text = "WeChat Pay".localizedString
        mExchangeRateLabel.text = "Exchange Rate".localizedString
        mItemsSelected.text = "0 " + "Item Selected".localizedString
        mPayNowButton.setTitle("PAY NOW".localizedString, for: .normal)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
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
            
            
        mFetchCreditNoteData(value: "")
        }else{
            mTaxView.isHidden =  true
            mCreditNoteView.isHidden = true
            mCreditNotesView.isHidden = true
        }
        
        mTransactionType = "CreditCard"
        mChequeDetailsView.isHidden = true
        mTaxInfoView.isHidden = true
        mKeyBoardView.isHidden = true
        mCreditCardView.isHidden = false
        mEditCashView.isHidden = true
        mCreditNoteDetailsView.isHidden = true
        let tap =  UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
              view.addGestureRecognizer(tap)
              tap.cancelsTouchesInView = false
        
        mCardView.applyGradient(withColours: [ #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1), #colorLiteral(red: 0, green: 0.5450980392, blue: 0.7098039216, alpha: 1)], gradientOrientation: .vertical)
        mCashView.applyGradient(withColours: [ #colorLiteral(red: 0.7725490196, green: 0.9019607843, blue: 0.8745098039, alpha: 1), #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)], gradientOrientation: .vertical)
        mBankView.applyGradient(withColours: [ #colorLiteral(red: 0.7725490196, green: 0.9019607843, blue: 0.8745098039, alpha: 1), #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)], gradientOrientation: .vertical)
        mCreditNoteView.applyGradient(withColours: [ #colorLiteral(red: 0.7725490196, green: 0.9019607843, blue: 0.8745098039, alpha: 1), #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)], gradientOrientation: .vertical)
        mTaxView.applyGradient(withColours: [ #colorLiteral(red: 0.7725490196, green: 0.9019607843, blue: 0.8745098039, alpha: 1), #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)], gradientOrientation: .vertical)
    
        mShowDatePicker()
        mGetCurrency()

        mPartialPayment = UserDefaults.standard.string( forKey: "isPartialPayment") ?? "0"
 
        mFetchStore(key: "")
        
        self.getCustomerAddressList()
     
    }
    
    override func viewDidLayoutSubviews() {
        
        mApplyGiftBUTTON.applyGradient(withColours: [ #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1), #colorLiteral(red: 0.01176470588, green: 0.2862745098, blue: 0.5568627451, alpha: 1)], gradientOrientation: .horizontal)
        
        mSubmitCreditNote.applyGradient(withColours: [ #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1), #colorLiteral(red: 0.01176470588, green: 0.2862745098, blue: 0.5568627451, alpha: 1)], gradientOrientation: .horizontal)
        mCheqSubmitBUTTON.applyGradient(withColours: [ #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1), #colorLiteral(red: 0.01176470588, green: 0.2862745098, blue: 0.5568627451, alpha: 1)], gradientOrientation: .horizontal)
        
        mSubmitButtonCredit.applyGradient(withColours: [ #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1), #colorLiteral(red: 0.01176470588, green: 0.2862745098, blue: 0.5568627451, alpha: 1)], gradientOrientation: .horizontal)
      
        mPayNowView.applyGradient(withColours: [ #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1), #colorLiteral(red: 0.01176470588, green: 0.2862745098, blue: 0.5568627451, alpha: 1)], gradientOrientation: .horizontal)
        mSubmitTx.applyGradient(withColours: [ #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1), #colorLiteral(red: 0.01176470588, green: 0.2862745098, blue: 0.5568627451, alpha: 1)], gradientOrientation: .horizontal)
        self.view.applyGradient(withColours: [ #colorLiteral(red: 0.7725490196, green: 0.9019607843, blue: 0.8745098039, alpha: 1), #colorLiteral(red: 0.9207345247, green: 0.9503677487, blue: 0.978346765, alpha: 1)], gradientOrientation: .vertical)
        

    }
    
    @IBAction func mApplyGiftCard(_ sender: Any) {
        if mGiftCardAmount.text != "" {
            mApplyGiftCards(cardNumber: mGiftCardAmount.text ?? "")
        }else{
            CommonClass.showSnackBar(message: "Please fill valid details!")
        }
    }
    
    func mApplyGiftCards(cardNumber:String){
        
        CommonClass.showFullLoader(view: self.view)
        
        let mLocation = UserDefaults.standard.string(forKey: "location") ?? ""
        
        let urlPath =  mApplyForGiftCard
        
        let params = ["Giftcard_code": cardNumber, "location_id":mLocation]
        
        if Reachability.isConnectedToNetwork() == true {
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
                            if let value = item as? NSDictionary, let creditNoteid = value.value(forKey: "creditNote_id") {
                                if "\(creditNoteid)" == "\(mCreditRow.value(forKey: "creditNote_id") ?? "")"{
                                    isExist = true
                                }
                            }
                        }
                        
                        if !isExist {
                            CommonClass.showSnackBar(message: "Gift Card Added Successfully")
                            self.mSelectedIndex = [IndexPath]()
                            let mNewData = NSMutableDictionary()
                            
                            mNewData.setValue("\(mCreditRow.value(forKey: "price_for") ?? "")", forKey: "price_for")
                            mNewData.setValue("\(mCreditRow.value(forKey: "type") ?? "")", forKey: "type")
                            mNewData.setValue("\(mCreditRow.value(forKey: "createdAt") ?? "")", forKey: "createdAt")
                            mNewData.setValue("\(mCreditRow.value(forKey: "Ref_No") ?? "")", forKey: "Ref_No")
                            mNewData.setValue("\(mCreditRow.value(forKey: "creditNote_id") ?? "")", forKey: "creditNote_id")
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
                                    
                                    mAmount.append(Double("\(value.value(forKey: "price_for") ?? "")") ?? 0)
                                    
                                    mCData.setValue("\(value.value(forKey: "price_for") ?? "")", forKey: "price_for")
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
                    if let error = jsonResult.value(forKey: "error") {
                        if "\(error)" == "Authorization has been expired" {
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
        self.mCreditCardPaymentView.isHidden = true
    }
    
    
    func mAddCredit(cardNumber:String, cardExp:String, cardCvc:String, amount:String){
        
        CommonClass.showFullLoader(view: self.view)
        
        _ = UserDefaults.standard.string(forKey: "location")
    
        let urlPath =  mCreditCardAdd
        
        let params = ["card_no": cardNumber, "card_cvc":cardCvc,"exp_month":cardExp,"card_holderName":UserDefaults.standard.string(forKey: "CUSTOMERID") ?? "" ,"method_id":mCreditCardPaymentId,"salesPerson_val": UserDefaults.standard.string(forKey: "SALESPERSONID") ?? "" ,"amount":amount]
        
        if Reachability.isConnectedToNetwork() == true {
            AF.request(urlPath, method:.post, parameters:params, headers: sGisHeaders2).responseJSON { [self] response in
                
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
                        if let mAM = i as? NSDictionary {
                            mAmount.append(Double("\(mAM.value(forKey: "amount") ?? "")") ?? 0)
                        }
                    }
                    self.mSubmittedCreditCard.text = "\( mAmount.reduce(0, {$0 + $1}))"
                    
                    let totalAmount = Double(self.mTOTALAMOUNT.text?.replacingOccurrences(of: ",", with: "") ?? "0.0") ?? 0.0
                    let submittedCash = Double(mSubmittedCash.text ?? "0.0") ?? 0.0
                    let submittedCreditNote = Double(mSubmittedCreditNote.text ?? "0.0") ?? 0.0
                    let submittedBankAmount = Double(mSubmittedBankAmount.text ?? "0.0") ?? 0.0
                    let submittedCreditCard = Double(mSubmittedCreditCard.text ?? "0.0") ?? 0.0

                    let balanceDue = totalAmount - submittedCash - submittedCreditNote - submittedBankAmount - submittedCreditCard

                    self.mBALANCEDUE.text = "\(balanceDue)"
                    self.mCreditCardPaymentView.isHidden = true
                }else {
                    if let error = jsonResult.value(forKey: "error") {
                        if "\(error)" == "Authorization has been expired" {
                            CommonClass.sessionExpired(isExpired: true, navigation: self.navigationController)
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
        
        guard let cells = collectionView.dequeueReusableCell(withReuseIdentifier: "Collect",for:indexPath) as? Collect,
              let mData = mPaymentData[indexPath.row] as? NSDictionary else {
            return UICollectionViewCell()
        }
        cells.mImage.downlaodImageFromUrl(urlString: "\(mData.value(forKey: "logo") ?? "")")
        cells.mName.text = mData.value(forKey: "name") as? String
        if let id = mData.value(forKey: "id"), mStripeIndex == indexPath.row {
            mCreditCardPaymentId = "\(id)"
            cells.mView.borderColor = UIColor(named: "themeColor")
            cells.mView.borderWidth = 1
            cells.mView.layer.cornerRadius = 10
        }else {
            cells.mView.borderWidth = 0
            cells.mView.layer.cornerRadius = 10
        }
        
        return cells
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        _ = collectionView.dequeueReusableCell(withReuseIdentifier: "Collect",for:indexPath) as? Collect
        
        let layout = collectionViewLayout as? UICollectionViewFlowLayout
        _ = collectionView.frame.width / 2
        layout?.minimumLineSpacing = 16


        return CGSize(width: (collectionView.frame.width / 2) - 16 , height: (collectionView.frame.height / 2) - 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        mStripeIndex = indexPath.row
        if let mData = mPaymentData[indexPath.row] as? NSDictionary, let id = mData.value(forKey: "id"){
            mCreditCardPaymentId = "\(id)"
            self.mCollectionView.reloadData()
        }
    }
    
    
    func mFetchStore(key: String){
        
        let mLocation = UserDefaults.standard.string(forKey: "location") ?? ""
        
        let urlPath =  mFetchStoreData
        let params = ["login_token": mUserLoginToken ?? "", "location_id":mLocation]
        
        if Reachability.isConnectedToNetwork() == true {
            AF.request(urlPath, method:.post, parameters:params, headers: sGisHeaders2).responseJSON
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
                        
                        if let mPaymentMethod = jsonResult.value(forKey: "Payment_method") as? NSDictionary,
                           let mData = mPaymentMethod.value(forKey: "Credit Card") as? NSArray,
                           mData.count > 0 {
                            self.mPaymentData = mData
                            self.mCollectionView.delegate = self
                            self.mCollectionView.dataSource = self
                            self.mCollectionView.reloadData()
                        } else {
                            CommonClass.showSnackBar(message: "OOP's something went wrong!")
                        }
                    }else {
                        if let error = jsonResult.value(forKey: "error") {
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
                
                let totalAmount = Double(self.mTOTALAMOUNT.text?.replacingOccurrences(of: ",", with: "") ?? "0") ?? 0
                let convertedAmounts = Double(mConvertedAmounts) ?? 0
                let submittedCreditNote = Double(mSubmittedCreditNote.text ?? "0") ?? 0
                let submittedBankAmount = Double(mSubmittedBankAmount.text ?? "0") ?? 0
                let submittedCreditCard = Double(mSubmittedCreditCard.text ?? "0") ?? 0

                let balanceDue = totalAmount - convertedAmounts - submittedCreditNote - submittedBankAmount - submittedCreditCard
                self.mBALANCEDUE.text = "\(balanceDue)"

            }
        }else{
          
        }
    }
    
    @IBAction func mChooseCheqDate(_ sender: Any) {}
    
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
              
        
        let selectedDate = mDatePicker.date
        mCheqDate.text = deliveryDate

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
                        if data.value(forKey: "BankPaymenttype") as? String == "Cheque" || data.value(forKey: "BankPaymenttype") as? String == "Bank" {
                            
                            mBankNames.append("\(data.value(forKey: "name") ?? "")")
                            mBankImage.append("\(data.value(forKey: "logo") ?? "")")
                            mPMId.append("\(data.value(forKey: "id") ?? "")")
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
    
    
    @IBAction func mSubmitCheque(_ sender: Any) {
        
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
            let totalAmount = Double(self.mTOTALAMOUNT.text?.replacingOccurrences(of: ",", with: "") ?? "0") ?? 0
            let convertedAmounts = Double(mCashAmounts) ?? 0
            let submittedCreditNote = Double(mSubmittedCreditNote.text ?? "0") ?? 0
            let submittedBankAmount = Double(mSubmittedBankAmount.text ?? "0") ?? 0
            let submittedCreditCard = Double(mSubmittedCreditCard.text ?? "0") ?? 0

            let balanceDue = totalAmount - convertedAmounts - submittedCreditNote - submittedBankAmount - submittedCreditCard
            self.mBALANCEDUE.text = "\(balanceDue)"
          
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return mCreditNoteData.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        
        guard let cells = tableView.dequeueReusableCell(withIdentifier: "CreditNoteList") as? CreditNoteList,
              let mData = mCreditNoteData[indexPath.row] as? NSDictionary else {
            return UITableViewCell()
        }
        
        cells.mType.text = mData.value(forKey: "type") as? String
        cells.mRefNo.text = mData.value(forKey: "Ref_No") as? String
        cells.mDate.text = mData.value(forKey: "createdAt") as? String
        cells.mAmount.tag = indexPath.row
        
        if mSelectedCustomIndex.contains(indexPath) {
            if let mDataSet = mAmountData[indexPath.row] as? NSDictionary {
                cells.mAmount.text = "\(mDataSet.value(forKey: "price_for") ?? "")"
            }
        }else{
            cells.mAmount.text = "\(mData.value(forKey: "price_for") ?? "")"
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
   
        _ = mCreditNoteData[indexPath.row] as? NSDictionary
        if mSelectedIndex.contains(indexPath) {
            mSelectedIndex = mSelectedIndex.filter {$0 != indexPath }
        }else{
            mSelectedIndex.append(indexPath)
        }
        
        self.mGetTotalAmount()
        self.mCreditNoteTable.reloadData()
    
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 35
    }
    
    
    @IBAction func mAmountEdit(_ sender: UITextField) {
        
        guard let mMaxData = mCreditNoteData[sender.tag] as? NSDictionary else {
            return
        }
        
        let mMaxAmount = Double("\(mMaxData.value(forKey: "price_for") ?? "")") ?? 0
        if sender.text == "" {
            mAddCreditAmount(text: "0", index: sender.tag)
            return
        }
        
        if (Double("\(sender.text ?? "")") ?? 0) > mMaxAmount {
            sender.text = "\(mMaxData.value(forKey: "price_for") ?? "")"
            mAddCreditAmount(text: sender.text ?? "", index: sender.tag)
        }else{
            mAddCreditAmount(text: sender.text ?? "", index: sender.tag)
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
            if mSelectedIndex.contains(indexPath) {
                
                if let mData = mAmountData[index] as? NSDictionary {
                    
                    mAmount.append(Double("\(mData.value(forKey: "price_for") ?? "")") ?? 0)
                    let mMaxData = mCreditNoteData[index] as? NSDictionary
                    var mCData = NSMutableDictionary()
                    
                    if "\(mMaxData?.value(forKey: "type") ?? "")" == "Gift Card" {
                        mCData.setValue("GiftCard", forKey: "type")
                        mCData.setValue("\(mData.value(forKey: "price_for") ?? "")", forKey: "applyamount")
                        mCData.setValue("\(mMaxData?.value(forKey: "creditNote_id") ?? "")", forKey: "creditNoteID")
                        mGiftCardMethod.add(mCData)
                    }else{
                        mCData.setValue("CreditNote", forKey: "type")
                        mCData.setValue("\(mData.value(forKey: "price_for") ?? "")", forKey: "applyamount")
                        mCData.setValue("\(mMaxData?.value(forKey: "creditNote_id") ?? "")", forKey: "creditNoteID")
                        mCreditData.add(mCData)
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
        
        let totalAmount = Double(self.mTOTALAMOUNT.text?.replacingOccurrences(of: ",", with: "") ?? "") ?? 0
        let submittedCash = Double(mSubmittedCash.text ?? "") ?? 0
        let submittedCreditNote = Double(mSubmittedCreditNote.text ?? "") ?? 0
        let submittedBankAmount = Double(mSubmittedBankAmount.text ?? "") ?? 0
        let submittedCreditCard = Double(mSubmittedCreditCard.text ?? "") ?? 0
        self.mBALANCEDUE.text = "\(totalAmount - submittedCash -  submittedCreditNote - submittedBankAmount - submittedCreditCard)"
     
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
    
    @IBAction func mCreditCard(_ sender: Any) {
        mTransactionType = "CreditCard"
        mTaxInfoView.isHidden = true
        mKeyBoardView.isHidden = true
        mChequeDetailsView.isHidden = true
        mCreditCardView.isHidden = false
        mCreditNoteDetailsView.isHidden = true
        mEditCashView.isHidden = true
        mCardView.layer.sublayers?.remove(at: 0)
        mCashView.layer.sublayers?.remove(at: 0)
        mBankView.layer.sublayers?.remove(at: 0)
        mCreditNoteView.layer.sublayers?.remove(at: 0)
        mTaxView.layer.sublayers?.remove(at: 0)
        
        mCardView.applyGradient(withColours: [ #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1), #colorLiteral(red: 0, green: 0.5450980392, blue: 0.7098039216, alpha: 1)], gradientOrientation: .vertical)
        mCashView.applyGradient(withColours: [ #colorLiteral(red: 0.7725490196, green: 0.9019607843, blue: 0.8745098039, alpha: 1), #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)], gradientOrientation: .vertical)
        mBankView.applyGradient(withColours: [ #colorLiteral(red: 0.7725490196, green: 0.9019607843, blue: 0.8745098039, alpha: 1), #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)], gradientOrientation: .vertical)
        
        mCreditNoteView.applyGradient(withColours: [ #colorLiteral(red: 0.7725490196, green: 0.9019607843, blue: 0.8745098039, alpha: 1), #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)], gradientOrientation: .vertical)
        mTaxView.applyGradient(withColours: [ #colorLiteral(red: 0.7725490196, green: 0.9019607843, blue: 0.8745098039, alpha: 1), #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)], gradientOrientation: .vertical)
    }
    @IBAction func mCash(_ sender: Any) {
        mTransactionType = "Cash"
        mChequeDetailsView.isHidden = true
        mTaxInfoView.isHidden = true
        mKeyBoardView.isHidden = false
        mCreditCardView.isHidden = true
        mEditCashView.isHidden = false
        mCreditNoteDetailsView.isHidden = true
        mCardView.layer.sublayers?.remove(at: 0)
        mCashView.layer.sublayers?.remove(at: 0)
        mBankView.layer.sublayers?.remove(at: 0)
        mCreditNoteView.layer.sublayers?.remove(at: 0)
        mTaxView.layer.sublayers?.remove(at: 0)
        mCardView.applyGradient(withColours: [ #colorLiteral(red: 0.7725490196, green: 0.9019607843, blue: 0.8745098039, alpha: 1), #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)], gradientOrientation: .vertical)
        mCashView.applyGradient(withColours: [ #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1), #colorLiteral(red: 0, green: 0.5450980392, blue: 0.7098039216, alpha: 1)], gradientOrientation: .vertical)
        mBankView.applyGradient(withColours: [ #colorLiteral(red: 0.7725490196, green: 0.9019607843, blue: 0.8745098039, alpha: 1), #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)], gradientOrientation: .vertical)
        mTaxView.applyGradient(withColours: [ #colorLiteral(red: 0.7725490196, green: 0.9019607843, blue: 0.8745098039, alpha: 1), #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)], gradientOrientation: .vertical)
        mCreditNoteView.applyGradient(withColours: [ #colorLiteral(red: 0.7725490196, green: 0.9019607843, blue: 0.8745098039, alpha: 1), #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)], gradientOrientation: .vertical)
    }
    
    @IBAction func mBank(_ sender: Any) {
        mTransactionType = "Bank"
        mChequeDetailsView.isHidden = false
        mCreditNoteDetailsView.isHidden = true
        mTaxInfoView.isHidden = true
        mKeyBoardView.isHidden = true
        mCreditCardView.isHidden = true
        mEditCashView.isHidden = true
        mCardView.layer.sublayers?.remove(at: 0)
        mCashView.layer.sublayers?.remove(at: 0)
        mBankView.layer.sublayers?.remove(at: 0)
        mCreditNoteView.layer.sublayers?.remove(at: 0)
        mTaxView.layer.sublayers?.remove(at: 0)
        mCardView.applyGradient(withColours: [ #colorLiteral(red: 0.7725490196, green: 0.9019607843, blue: 0.8745098039, alpha: 1), #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)], gradientOrientation: .vertical)
        mCashView.applyGradient(withColours: [ #colorLiteral(red: 0.7725490196, green: 0.9019607843, blue: 0.8745098039, alpha: 1), #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)], gradientOrientation: .vertical)
        mBankView.applyGradient(withColours: [ #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1), #colorLiteral(red: 0, green: 0.5450980392, blue: 0.7098039216, alpha: 1)], gradientOrientation: .vertical)
        mTaxView.applyGradient(withColours: [ #colorLiteral(red: 0.7725490196, green: 0.9019607843, blue: 0.8745098039, alpha: 1), #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)], gradientOrientation: .vertical)
        mCreditNoteView.applyGradient(withColours: [ #colorLiteral(red: 0.7725490196, green: 0.9019607843, blue: 0.8745098039, alpha: 1), #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)], gradientOrientation: .vertical)
    }
    
    @IBAction func mCreditNot(_ sender: Any) {
        mTransactionType = "CreditNote"
        mCreditNoteDetailsView.isHidden = false
        mTaxInfoView.isHidden = true
        mChequeDetailsView.isHidden = true
        mKeyBoardView.isHidden = true
        mCreditCardView.isHidden = true
        mEditCashView.isHidden = true
        mCardView.layer.sublayers?.remove(at: 0)
        mCashView.layer.sublayers?.remove(at: 0)
        mBankView.layer.sublayers?.remove(at: 0)
        mCreditNoteView.layer.sublayers?.remove(at: 0)
        mTaxView.layer.sublayers?.remove(at: 0)
        mCardView.applyGradient(withColours: [ #colorLiteral(red: 0.7725490196, green: 0.9019607843, blue: 0.8745098039, alpha: 1), #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)], gradientOrientation: .vertical)
        mCashView.applyGradient(withColours: [ #colorLiteral(red: 0.7725490196, green: 0.9019607843, blue: 0.8745098039, alpha: 1), #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)], gradientOrientation: .vertical)
        mBankView.applyGradient(withColours: [ #colorLiteral(red: 0.7725490196, green: 0.9019607843, blue: 0.8745098039, alpha: 1), #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)], gradientOrientation: .vertical)
        mTaxView.applyGradient(withColours: [ #colorLiteral(red: 0.7725490196, green: 0.9019607843, blue: 0.8745098039, alpha: 1), #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)], gradientOrientation: .vertical)
        mCreditNoteView.applyGradient(withColours: [ #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1), #colorLiteral(red: 0, green: 0.5450980392, blue: 0.7098039216, alpha: 1)], gradientOrientation: .vertical)
        
     
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
        mTaxView.layer.sublayers?.remove(at: 0)
        
        mCardView.applyGradient(withColours: [ #colorLiteral(red: 0.7725490196, green: 0.9019607843, blue: 0.8745098039, alpha: 1), #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)], gradientOrientation: .vertical)
        mCashView.applyGradient(withColours: [ #colorLiteral(red: 0.7725490196, green: 0.9019607843, blue: 0.8745098039, alpha: 1), #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)], gradientOrientation: .vertical)
        mBankView.applyGradient(withColours: [ #colorLiteral(red: 0.7725490196, green: 0.9019607843, blue: 0.8745098039, alpha: 1), #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)], gradientOrientation: .vertical)
        mCreditNoteView.applyGradient(withColours: [ #colorLiteral(red: 0.7725490196, green: 0.9019607843, blue: 0.8745098039, alpha: 1), #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)], gradientOrientation: .vertical)
        mTaxView.applyGradient(withColours: [ #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1), #colorLiteral(red: 0, green: 0.5450980392, blue: 0.7098039216, alpha: 1)], gradientOrientation: .vertical)

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
    
    
    
    
    
    
    @IBAction func mPressOne(_ sender: Any) {
        
      
        mInsertAmount(num:"1")

    }
    
    @IBAction func mPressTwo(_ sender: Any) {
        
        mInsertAmount(num:"2")
    }
    
    
    @IBAction func mPressThree(_ sender: Any) {
        mInsertAmount(num:"3")
    }
    
    @IBAction func mPressFour(_ sender: Any) {
        mInsertAmount(num:"4")
    }
    
    @IBAction func mPressFive(_ sender: Any) {
        mInsertAmount(num:"5")
    }
    
    @IBAction func mPressSix(_ sender: Any) {
        mInsertAmount(num:"6")
    }
    @IBAction func mPressSeven(_ sender: Any) {
        mInsertAmount(num:"7")
    }
    @IBAction func mPressEight(_ sender: Any) {
        mInsertAmount(num:"8")
    }
    
    @IBAction func mPressNine(_ sender: Any) {
        mInsertAmount(num:"9")
    }
    
    
    
    @IBAction func mPressSingleZero(_ sender: Any) {
        mInsertAmount(num:"0")
    }
    
    @IBAction func mPressDoubleZero(_ sender: Any) {
        mInsertAmount(num:"00")
    }
    
    @IBAction func mPressDot(_ sender: Any) {
        if mCashAmounts != "" {
            mInsertAmount(num:".")
        }
    }

    @IBAction func mSub(_ sender: Any) {
        
        if mTransactionType == "Cash" {
         
            self.mSubmittedCash.text = "\(mConvertedAmounts)"
            let totalAmount = Double(self.mTOTALAMOUNT.text?.replacingOccurrences(of: ",", with: "") ?? "0") ?? 0
            let convertedAmounts = Double(mConvertedAmounts) ?? 0
            let submittedCreditNote = Double(mSubmittedCreditNote.text ?? "0") ?? 0
            let submittedBankAmount = Double(mSubmittedBankAmount.text ?? "0") ?? 0
            let submittedCreditCard = Double(mSubmittedCreditCard.text ?? "0") ?? 0

            let balanceDue = totalAmount - convertedAmounts - submittedCreditNote - submittedBankAmount - submittedCreditCard
            self.mBALANCEDUE.text = "\(balanceDue)"
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
                
                mConvertedAmount.text = "= \(self.mCurrencyName.text ?? "") \(mDecimalAmount)"
            }
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
    
    @IBAction func mDeleteCashAmount(_ sender: Any) {
        if mCashAmounts != "" {
            mCashAmounts.removeLast()
            mCashAmount.text = mCashAmounts
            if mCashAmounts == "" {
                mConvertedAmounts = "0"
                mSubmittedCash.text = "0.0"
                let totalAmount = Double(self.mTOTALAMOUNT.text?.replacingOccurrences(of: ",", with: "") ?? "0") ?? 0
                let convertedAmounts = Double(mConvertedAmounts) ?? 0
                let submittedCreditNote = Double(mSubmittedCreditNote.text ?? "0") ?? 0
                let submittedBankAmount = Double(mSubmittedBankAmount.text ?? "0") ?? 0
                let submittedCreditCard = Double(mSubmittedCreditCard.text ?? "0") ?? 0

                let balanceDue = totalAmount - convertedAmounts - submittedCreditNote - submittedBankAmount - submittedCreditCard
                self.mBALANCEDUE.text = "\(balanceDue)"
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
//        mCashAmount.text = mCashAmounts
//        
//        if mTransactionType == "Cash" {
//            if mExchangeRateLabel.isHidden == false {
//                if mExchangeRateValue.text != "" {
////                    let mVal = Double(mExchangeRateValue.text ?? "") ?? 0
////                    if mCashAmount.text != "" && mCashAmount.text != "."  {
////                        mConvertedAmounts = "\((Double(mCashAmounts) ?? 0) * mVal)"
////                        let mDecimalAmount = ((Double(mConvertedAmounts) ?? 0) * 100).rounded() / 100
////                        
////                        mConvertedAmount.text = "= \(self.mCurrencyName.text ?? "") \(mDecimalAmount)"
////                    }
//                    let resultantRate = Double(mExchangeRateValue.text ?? "") ?? 0
//
//                    if mCashAmount.text != "" &&
//                       mCashAmount.text != "." &&
//                       resultantRate > 0 {
//
//                        let cashAmount = Double(mCashAmounts) ?? 0
//
//                        let convertedAmount = cashAmount / resultantRate
//
//                        mConvertedAmounts = "\(convertedAmount)"
//
//                        let mDecimalAmount = (convertedAmount * 100).rounded() / 100
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

                    mConvertedAmounts =
                        "\(Double(mCashAmounts) ?? 0)"

                    let amount =
                        Double(mConvertedAmounts) ?? 0

                    let rounded =
                        (amount * 100).rounded() / 100

                    mConvertedAmount.text =
                        "= \(self.mCurrencyName.text ?? "") \(rounded)"
                }
            }
        }
    }

    @IBAction func mPayNow(_ sender: Any) {
        mGiftFinalTotalAmount = "0"
        var mAmount = [Double]()
        for item in mGiftCardMethod {
            if let value = item as? NSDictionary {
                mAmount.append(Double("\(value.value(forKey: "applyamount") ?? "")") ?? 0)
            }
        }

        self.mGiftFinalTotalAmount  = "\(mAmount.reduce(0, {$0 + $1}))"
        
        var mCreditFinalTotalAmountObj = "0"
        var mAmount2 = [Double]()
        for item in mCreditData {
            if let value = item as? NSDictionary {
                mAmount2.append(Double("\(value.value(forKey: "applyamount") ?? "")") ?? 0)
            }
        }
        
        mCreditFinalTotalAmountObj = "\(mAmount2.reduce(0, {$0 + $1}))"

        mFinalPaymentMethod = NSMutableDictionary()
        let mCashMethod = NSMutableDictionary()
        let mCreditNoteMethod = NSMutableDictionary()
        let mGiftCardMethods = NSMutableDictionary()
        let mBankMethod = NSMutableArray()
        let mChequeMethod = NSMutableDictionary()
        
        
        
        if ((Double(mCreditFinalTotalAmountObj) ?? 0) * 1 != 0.0) {
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
        
        if !mSelectedBillingAddress.isEmpty || !mSelectedShippingAddress.isEmpty {
                    mFinalPaymentMethod.setValue([
                        "billing_address": self.mSelectedBillingAddress,
                        "shipping_address": self.mSelectedShippingAddress
                    ], forKey: "shipping_info")
                }
        
        print("DEBUG_FINAL_PAYMENT CheckOutPage =", mFinalPaymentMethod)
        if mOrderType == "Sales Order" {
            
            if mPartialPayment == "0" {
                if ((Double(mBALANCEDUE.text?.replacingOccurrences(of: ",", with: "") ?? "") ?? 0) * 1 == 0.0) {
                    if UserDefaults.standard.string(forKey: "CUSTOMERID") != nil {
                        PayNow()
                    }else{
                        CommonClass.showSnackBar(message:"Please choose customer")
                    }
                    
                }else {
                    CommonClass.showSnackBar(message:"Please add valid amount!")
                    
                }
                
            }else{
                let balanceDue = Double(mBALANCEDUE.text?.replacingOccurrences(of: ",", with: "") ?? "") ?? 0
                let totalAmount = Double(mTOTALAMOUNT.text?.replacingOccurrences(of: ",", with: "") ?? "") ?? 0
                if balanceDue > totalAmount || balanceDue < 0.0{
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
            let balanceDue = Double(mBALANCEDUE.text?.replacingOccurrences(of: ",", with: "") ?? "") ?? 0
            let totalAmount = Double(mTOTALAMOUNT.text?.replacingOccurrences(of: ",", with: "") ?? "") ?? 0
            if balanceDue > totalAmount || balanceDue < 0{
                CommonClass.showSnackBar(message:"Please add valid amount!")
            }else {
                if UserDefaults.standard.string(forKey: "CUSTOMERID") != nil {
                    PayNow()
                }else{
                    CommonClass.showSnackBar(message:"Please choose customer")
                }
                
            }
            
        }else{
            let balanceDue = Double(mBALANCEDUE.text?.replacingOccurrences(of: ",", with: "") ?? "") ?? 0
            let totalAmount = Double(mTOTALAMOUNT.text?.replacingOccurrences(of: ",", with: "") ?? "") ?? 0
            if balanceDue > totalAmount || balanceDue < 0 {
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
        if sender.text! == "" || sender.text == "0"  || mCount > 100 {
            sender.text = "0"
            self.mDiscountAmounts.text = "0"
            calculateTax()
        }else {
            self.mDiscountAmounts.text = "\(calculatePercentage(value: Double(mTotalAm) ?? 0 , percent: Double(sender.text ?? "") ?? 0))"
            calculateTax()
        }
    }
    
    @IBAction func mDiscountAmount(_ sender: UITextField) {
        if sender.text == "" {
            
            sender.text = "0"
            self.mDiscountPercents.text = "0"
            
            calculateTax()
        }else{
            let amount = Double(sender.text ?? "") ?? 0
            let mPercent = amount / (Double(mTotalAm) ?? 0) * 100
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
            mTaxAmountTx.text =   String(format:"%.02f",locale:Locale.current,calculateInclusiveTax(value: (Double(mTotalTx.text ?? "") ?? 0) - (Double(mDiscountAmounts.text ?? "") ?? 0), percent: Double(mTaxP) ?? 0 ))
          
            let mtotaltx = Double(mTotalTx.text ?? "") ?? 0
            let mdiscountamounts = Double(mDiscountAmounts.text ?? "") ?? 0
            let mtaxamounttx = Double(mTaxAmountTx.text?.replacingOccurrences(of: ",", with: "") ?? "") ?? 0
            mSubTotalTx.text =  String(format:"%.02f", locale: Locale.current, mtotaltx - mdiscountamounts -  mtaxamounttx)
            
            mFinalTaxAmount.text = mTaxAmountTx.text
            mTOTALAMOUNT.text = "\((mAmount + (Double(mTotalAm) ?? 0) - mDiscountA))"
            
            let mtotalamount = Double(mTOTALAMOUNT.text ?? "") ?? 0
            let msubmittedcash = Double(mSubmittedCash.text ?? "") ?? 0
            let msubmittedcreditnote = Double(mSubmittedCreditNote.text ?? "") ?? 0
            let msubmittedbankamount = Double(mSubmittedBankAmount.text ?? "") ?? 0
            let msubmittedcreditcard = Double(mSubmittedCreditCard.text ?? "") ?? 0
            mBALANCEDUE.text = "\(mtotalamount - msubmittedcash - msubmittedcreditnote - msubmittedbankamount - msubmittedcreditcard)"
        }else{
            mTotalDiscountTx.text = mDiscountAmounts.text
            mTotalTx.text = "\((mAmount + (Double(mTotalAm) ?? 0)))"
            
            let totalTx = Double(mTotalTx.text ?? "0") ?? 0
            let discountAmounts = Double(mDiscountAmounts.text ?? "0") ?? 0
            let taxPercent = Double(mTaxP) ?? 0
            let taxableAmount = totalTx - discountAmounts
            let taxAmount = calculateExclusiveTax(value: taxableAmount, percent: taxPercent)
            mTaxAmountTx.text = String(format: "%.02f", locale: Locale.current, taxAmount)
            
            mSubTotalTx.text = String(format:"%.02f", locale: Locale.current, (Double(mTotalTx.text ?? "") ?? 0) - (Double(mDiscountAmounts.text ?? "") ?? 0))
            mFinalTaxAmount.text = mTaxAmountTx.text
            
            let subTotal = Double(mSubTotalTx.text?.replacingOccurrences(of: ",", with: "") ?? "0") ?? 0
            let taxAmountTx = Double(mTaxAmountTx.text?.replacingOccurrences(of: ",", with: "") ?? "0") ?? 0
            let totalAmount = subTotal + taxAmountTx
            mTOTALAMOUNT.text = "\(totalAmount)"
            
            let stotalAmount = Double(mTOTALAMOUNT.text ?? "0") ?? 0
            let submittedCash = Double(mSubmittedCash.text ?? "0") ?? 0
            let submittedCreditNote = Double(mSubmittedCreditNote.text ?? "0") ?? 0
            let submittedBankAmount = Double(mSubmittedBankAmount.text ?? "0") ?? 0
            let submittedCreditCard = Double(mSubmittedCreditCard.text ?? "0") ?? 0

            let balanceDue = stotalAmount - submittedCash - submittedCreditNote - submittedBankAmount - submittedCreditCard
            mBALANCEDUE.text = "\(balanceDue)"
        }
     }
    
    
  
    
    
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        _ = textField.text
    }
    
    func mFetchCreditNoteData(value: String){
        
        let mCustomerId =  UserDefaults.standard.string(forKey: "CUSTOMERID") ?? ""
        let mLocation = UserDefaults.standard.string(forKey: "location") ?? ""
        
        let urlPath =  mPOSCreditNote
        let params = ["POS_Location_id": mLocation, "CustomerID":mCustomerId]
        
        if Reachability.isConnectedToNetwork() == true {
            AF.request(urlPath, method:.post, parameters:params, encoding: JSONEncoding.default, headers: sGisHeaders).responseJSON { response in
                
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
                    self.mCreditNoteData = NSMutableArray()
                    
                    if let mData = jsonResult.value(forKey: "responce") as? NSArray {
                        
                        self.mCreditNoteData = NSMutableArray(array: mData)
                        self.mCreditNoteTable.delegate = self
                        self.mCreditNoteTable.dataSource = self
                        self.mCreditNoteTable.reloadData()
                        var mAmount = [Double]()
                        for item in mData {
                            if let value = item as? NSDictionary {
                                let mCData = NSMutableDictionary()
                                
                                mAmount.append(Double("\(value.value(forKey: "price_for") ?? "")") ?? 0)
                                
                                mCData.setValue("\(value.value(forKey: "price_for") ?? "")", forKey: "price_for")
                                self.mTotalCreditAmount.text = String(format:"%.02f",locale:Locale.current,mAmount.reduce(0, {$0 + $1}))
                                
                                self.mAmountData.add(mCData)
                            }
                        }

                    }
                }else{
                    if let error = jsonResult.value(forKey: "error") {
                        if "\(error)" == "Authorization has been expired" {
                            CommonClass.sessionExpired(isExpired: true, navigation: self.navigationController)
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
                      "cartTableData":self.mCartTableData,
                      
            ]
            
        }else if self.mOrderType == "Repair Order" {
            urlPath = mSubmitRepairDesign
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
        
        // ✨ เพิ่มการใส่ shippingInfo เข้าไปใน params ก่อนจะส่ง API ✨
        if !self.mSelectedBillingAddress.isEmpty || !self.mSelectedShippingAddress.isEmpty {
            params["shipping_info"] = [
                "billing_address": self.mSelectedBillingAddress,
                "shipping_address": self.mSelectedShippingAddress
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
                        
                        UserDefaults.standard.setValue("\(jsonResult.value(forKey: "pdf_url") ?? "")", forKey: "reportAPI")
                        self.mGenerateReport(id:"\(jsonResult.value(forKey: "pdf_url") ?? "")" , jsonResult : jsonResult)
                        
                    }else{
                        if let error = jsonResult.value(forKey: "error") {
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
        
        let urlPath =  id
        
        if Reachability.isConnectedToNetwork() == true {
            AF.request(urlPath, method:.post, parameters:nil, headers: sGisHeaders2).responseJSON { response in
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
                
                guard let jsonVal = json as? NSDictionary else {
                    CommonClass.showSnackBar(message: "OOP's something went wrong!")
                    return
                }
            
                UserDefaults.standard.set("", forKey: "CUSTOMERID")
                UserDefaults.standard.set("", forKey: "SALESPERSONID")
                CommonClass.showSnackBar(message: "Payment Successful")
                
                if let email = jsonVal.value(forKey: "email"){
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
                    mCompletePayment.mShippingInfo = [
                        "billing_address": self.mSelectedBillingAddress,
                        "shipping_address": self.mSelectedShippingAddress
                    ]
                    self.navigationController?.pushViewController(mCompletePayment, animated:true)
                }
            }
        }else{
        }
        
    }
    
    func mSetupTableView(frame: CGRect) {
        if mCustomerSearch.text != "" {
            let nib = UINib(nibName: "CustomerSearchList", bundle: nil)
            _ = nib.instantiate(withOwner: self, options: nil)[0] as? UIView
            let _:CGFloat = UIApplication.shared.statusBarFrame.size.height
            let _: CGFloat = self.view.frame.width
            let _: CGFloat = self.view.frame.height
            
            mCustomerSearchTableView.frame = CGRect(x: 16, y: frame.origin.y + 200 , width: self.view.frame.width - 32, height: 400)
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
        print("3")
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
                    
                    if let jsonResult = json as? NSDictionary,
                       let data = jsonResult.value(forKey: "currency") as? NSArray {
                        
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
                                    } else {
                                        self.mTOTALAMOUNT.text = self.mTotalP
                                        self.mBALANCEDUE.text = self.mTotalP
                                    }
                                }
                            }
                        }
                    }
                }
                
            }
        }else{
            CommonClass.showSnackBar(message: "No Internet Connection")
        }
        
        
    }
    
    struct CustomerAddress: Codable {
        let id: Int
        let address: String
        let isDefault: Bool
    }
    
    private func getCustomerAddressList(){
        
        guard Reachability.isConnectedToNetwork() == true else {
            CommonClass.showSnackBar(message: "Please check your internet connection.")
            return
        }
        
        let mCustomerId =  UserDefaults.standard.string(forKey: "CUSTOMERID") ?? ""
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
