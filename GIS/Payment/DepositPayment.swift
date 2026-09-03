//
//  DepositPayment.swift
//  GIS
//
//  Created by Apple Hawkscode on 23/09/21.
//

import UIKit

import UIKit
import Alamofire
import DropDown
 

class DepositPayment: UIViewController, UITextFieldDelegate , UITableViewDelegate ,UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout{

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
    var mConvertedAmounts = "0"
        
        
    var mTotalP = ""
    var mTotalAm = ""
    var mSubTotalP = ""
    var mTaxP = ""
    var mTaxAm = ""
                                                                                                                              
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
    
    
    
    @IBOutlet weak var mSalesPersonName: UILabel!
    @IBOutlet weak var mCustomerViewHeight: NSLayoutConstraint!
    
    var mSalesManList = [String]()
    var mSalesManIDList = [String]()
    var mCustomerId = ""
    var mSalesPersonId = ""
    
    var mTransactionType = "CreditCard"
    var isExchange = false
    
    var mOrderType = ""
        
        
    @IBOutlet weak var mHDepositLABEL: UILabel!
    
    @IBOutlet weak var mSalePersonLABEL: UILabel!
    
    @IBOutlet weak var mCreditCardLABEL: UILabel!
    
    @IBOutlet weak var mCashLABEL: UILabel!
    
    @IBOutlet weak var mBankLABEL: UILabel!
    @IBOutlet weak var mSUBLABEL: UILabel!
    
    @IBOutlet weak var mTotalLABEL: UILabel!
    @IBOutlet weak var mBBankLABEL: UILabel!
    @IBOutlet weak var mBCashLABEL: UILabel!
    @IBOutlet weak var mBCreditCardLABEL: UILabel!
    
    @IBOutlet weak var mGrandTotalView: UIStackView!
    @IBOutlet weak var mGrandTotalLABEL: UILabel!
    var mCouponCurrencyAmount = ""
    var mCouponTotal = ""
        
        
        
    
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
    let mDatePicker:UIDatePicker = UIDatePicker()
    var mChequeData = NSMutableDictionary()
    var mFinalPaymentMethod = NSMutableDictionary()
        
        
        
    @IBOutlet weak var mSubmittedCreditCard: UILabel!
    @IBOutlet weak var mSubmitButtonCredit: UIButton!
    @IBOutlet weak var mCloseButtonCredit: UIButton!
    @IBOutlet weak var mCreditCardPaymentView: UIView!
    @IBOutlet weak var mCreditFillAmount: UITextField!
    @IBOutlet weak var mStripeCardView: UIView!
    @IBOutlet weak var mCollectionView: UICollectionView!
    var mStripeIndex = 0
    var mPaymentData =  NSArray()
       
    var mCreditCardMethod = NSMutableArray()
        
    override func viewWillAppear(_ animated: Bool) {
        
        
        
        self.mCreditFillAmount.keyboardType = .numberPad
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
        
        
        
        mChequeDetailsView.isHidden = true
        mCustomerSearch.tintColor = .black
        
        
        mCustomerSearch.placeholder = "Customer Search".localizedString
        if mOrderType == "Deposit" {
            mPayNowButton.setTitle("ADD NOW".localizedString, for: .normal)
        }else{
            mPayNowButton.setTitle("PAY NOW".localizedString, for: .normal)
        }
        mGrandTotalLABEL.text = "Grand Total".localizedString
        mExchangeRateLabel.text = "Exchange Rate".localizedString
        mHDepositLABEL.text = mOrderType.localizedString
        mSalePersonLABEL.text = "Sale Person".localizedString
        mCashLABEL.text = "Cash".localizedString
        mBCashLABEL.text = "Cash".localizedString
        mCreditCardLABEL.text = "Credit Card".localizedString
        mBCreditCardLABEL.text = "Credit Card".localizedString
        mBBankLABEL.text = "Bank".localizedString
        mBankLABEL.text = "Bank".localizedString
        mSUBLABEL.text = "SUB".localizedString
        mTotalLABEL.text = "Total".localizedString
        mCreditCardLabel.text = "Credit/Debit".localizedString
        mApplePayLabel.text = "Apple Pay".localizedString
        mAliPayLabel.text = "Alipay".localizedString
        mWeChatPayLabel.text = "WeChat Pay".localizedString
        
    }
        override func viewDidLoad() {
            super.viewDidLoad()
           
            mGrandTotalView.isHidden =  true

            if mOrderType == "Deposit" {
                mTOTALAMOUNT.text = "0.0"
                if let currency = UserDefaults.standard.string(forKey: "currency") {
                    mStoreCurrency = currency
                }
                UserDefaults.standard.set("", forKey: "CUSTOMERID")
                UserDefaults.standard.set("", forKey: "SALESPERSONID")
                
                mTaxView.isHidden =  true
                mCreditNoteView.isHidden = true
                mPayNowButton.setTitle("ADD NOW".localizedString, for: .normal)
            
                mTransactionType = "CreditCard"
                mTaxInfoView.isHidden = true
                mKeyBoardView.isHidden = true
                mCreditCardView.isHidden = false
                mEditCashView.isHidden = true
                mGetCurrency()
                 mGetSalesPerson()
            }else{
                
                mTOTALAMOUNT.text = "0.0"
                mGrandTotalView.isHidden =  false
                mCustomerViewHeight.constant = 0
                
                mBALANCEDUE.text = mCouponCurrencyAmount
                
                mTaxView.isHidden =  true
                mCreditNoteView.isHidden = true
                mPayNowButton.setTitle("PAY NOW".localizedString, for: .normal)
            
                mTransactionType = "CreditCard"
                mTaxInfoView.isHidden = true
                mKeyBoardView.isHidden = true
                mCreditCardView.isHidden = false
                mEditCashView.isHidden = true
                mFetchStore(key: "")
            }
           
            let tap =  UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
                  view.addGestureRecognizer(tap)
                  tap.cancelsTouchesInView = false
            
            mCardView.applyGradient(withColours: [#colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1),#colorLiteral(red: 0, green: 0.5450980392, blue: 0.7098039216, alpha: 1)], gradientOrientation: .vertical)
            mCashView.applyGradient(withColours: [#colorLiteral(red: 0.7725490196, green: 0.9019607843, blue: 0.8745098039, alpha: 1),#colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)], gradientOrientation: .vertical)
            mBankView.applyGradient(withColours: [#colorLiteral(red: 0.7725490196, green: 0.9019607843, blue: 0.8745098039, alpha: 1),#colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)], gradientOrientation: .vertical)
            mCreditNoteView.applyGradient(withColours: [#colorLiteral(red: 0.7725490196, green: 0.9019607843, blue: 0.8745098039, alpha: 1),#colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)], gradientOrientation: .vertical)
            mTaxView.applyGradient(withColours: [#colorLiteral(red: 0.7725490196, green: 0.9019607843, blue: 0.8745098039, alpha: 1),#colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)], gradientOrientation: .vertical)
        
            
            mShowDatePicker()
    
            mFetchStore1(key: "")
           
        }
        
        override func viewDidLayoutSubviews() {
            mSubmitButtonCredit.applyGradient(withColours: [#colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1),#colorLiteral(red: 0.01176470588, green: 0.2862745098, blue: 0.5568627451, alpha: 1)], gradientOrientation: .horizontal)

            mCheqSubmitBUTTON.applyGradient(withColours: [#colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1),#colorLiteral(red: 0.01176470588, green: 0.2862745098, blue: 0.5568627451, alpha: 1)], gradientOrientation: .horizontal)
            mPayNowView.applyGradient(withColours: [#colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1),#colorLiteral(red: 0.01176470588, green: 0.2862745098, blue: 0.5568627451, alpha: 1)], gradientOrientation: .horizontal)
            mSubmitTx.applyGradient(withColours: [#colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1),#colorLiteral(red: 0.01176470588, green: 0.2862745098, blue: 0.5568627451, alpha: 1)], gradientOrientation: .horizontal)
            self.view.applyGradient(withColours: [#colorLiteral(red: 0.7725490196, green: 0.9019607843, blue: 0.8745098039, alpha: 1),#colorLiteral(red: 0.9207345247, green: 0.9503677487, blue: 0.978346765, alpha: 1)], gradientOrientation: .vertical)
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
           
            let mLocation = UserDefaults.standard.string(forKey: "location")
        
             let urlPath =  mCreditCardAdd
            
            let params = ["card_no": cardNumber, "card_cvc":cardCvc,"exp_month":cardExp,"card_holderName":UserDefaults.standard.string(forKey: "CUSTOMERID") ?? "" ,"method_id":mCreditCardPaymentId,"salesPerson_val": UserDefaults.standard.string(forKey: "SALESPERSONID") ?? "" ,"amount":amount]
            
            if Reachability.isConnectedToNetwork() == true {
            AF.request(urlPath, method:.post, parameters:params, headers: sGisHeaders2).responseJSON { [self] response in
                    
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
                                    if let mAM = i as? NSDictionary {
                                        mAmount.append(Double("\(mAM.value(forKey: "amount") ?? "")") ?? 0)
                                    }
                                }
                                self.mSubmittedCreditCard.text = "\( mAmount.reduce(0, {$0 + $1}))"
                                
                                let convertedAmounts = Double(mConvertedAmounts) ?? 0
                                let submittedBankAmount = Double(mSubmittedBankAmount.text ?? "") ?? 0
                                let submittedCreditCard = Double(mSubmittedCreditCard.text ?? "") ?? 0
                                self.mTOTALAMOUNT.text = "\(convertedAmounts + submittedBankAmount + submittedCreditCard)"
                                self.mCreditCardPaymentView.isHidden = true
                            }
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

        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return mPaymentData.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
          
            guard let cells = collectionView.dequeueReusableCell(withReuseIdentifier: "Collect", for:indexPath) as? Collect else {
                return UICollectionViewCell()
            }
            
            if let mData = mPaymentData[indexPath.row] as? NSDictionary {
                cells.mImage.downlaodImageFromUrl(urlString: "\(mData.value(forKey: "logo") ?? "")")
                cells.mName.text = mData.value(forKey: "name") as? String
                if mStripeIndex == indexPath.row {
                    
                    mCreditCardPaymentId = mData.value(forKey: "id") as? String ?? ""
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
            if let mData = mPaymentData[indexPath.row] as? NSDictionary {
                mCreditCardPaymentId = mData.value(forKey: "id") as? String ?? ""
            }
            self.mCollectionView.reloadData()
        }
        
        
    func mFetchStore1(key: String){
        let mLocation = UserDefaults.standard.string(forKey: "location")
        
        let urlPath =  mFetchStoreData
        let params = ["login_token": mUserLoginToken ?? "", "location_id":mLocation ?? ""]
        
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
                        
                        let mPaymentMethod = jsonResult.value(forKey: "Payment_method") as? NSDictionary
                        if let mData = mPaymentMethod?.value(forKey: "Credit Card") as? NSArray, mData.count > 0 {
                            self.mPaymentData = mData
                            self.mCollectionView.delegate = self
                            self.mCollectionView.dataSource = self
                            self.mCollectionView.reloadData()
                        }
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
                    
                    let convertedAmounts = Double(mConvertedAmounts) ?? 0.0
                    let submittedBankAmount = Double(mSubmittedBankAmount.text ?? "") ?? 0.0
                    let submittedCreditCard = Double(mSubmittedCreditCard.text ?? "") ?? 0.0

                    self.mTOTALAMOUNT.text = "\(convertedAmounts + submittedBankAmount + submittedCreditCard)"
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
            dropdown.backgroundColor = .white
            dropdown.layer.cornerRadius = 15
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
           
            if let chequeAmountText = mChequeAmount.text,
               !chequeAmountText.isEmpty,
               let chequeAmount = Double(chequeAmountText), chequeAmount != 0 {
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

                let convertedAmounts = Double(mConvertedAmounts) ?? 0.0
                let submittedBankAmount = Double(mSubmittedBankAmount.text ?? "") ?? 0.0
                let submittedCreditCard = Double(mSubmittedCreditCard.text ?? "") ?? 0.0

                self.mTOTALAMOUNT.text = "\(convertedAmounts + submittedBankAmount + submittedCreditCard)"
            }
        }
        
      
        @IBAction func mBack(_ sender: Any) {
            
            self.navigationController?.popViewController(animated: true)
            
        }
        
        @IBAction func mEditCustomer(_ sender: Any) {
            mCustomerSearch.text = ""
            mCustomerDetailView.isHidden = true
            self.mCustomerSearchView.isHidden = false

        }
    
        @IBAction func mProfileInfo(_ sender: Any) {

        self.mCustomerSearch.text = ""
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            if let mProfInfo = storyBoard.instantiateViewController(withIdentifier: "POSProfileInfo") as? POSProfileInfo {
                self.navigationController?.pushViewController(mProfInfo, animated:true)
            }
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
            mCreditCardView.isHidden = false
            mChequeDetailsView.isHidden = true

            mEditCashView.isHidden = true
            mCardView.layer.sublayers?.remove(at: 0)
            mCashView.layer.sublayers?.remove(at: 0)
            mBankView.layer.sublayers?.remove(at: 0)
            mCreditNoteView.layer.sublayers?.remove(at: 0)
            mTaxView.layer.sublayers?.remove(at: 0)
            
            mCardView.applyGradient(withColours: [#colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1),#colorLiteral(red: 0, green: 0.5450980392, blue: 0.7098039216, alpha: 1)], gradientOrientation: .vertical)
            mCashView.applyGradient(withColours: [#colorLiteral(red: 0.7725490196, green: 0.9019607843, blue: 0.8745098039, alpha: 1),#colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)], gradientOrientation: .vertical)
            mBankView.applyGradient(withColours: [#colorLiteral(red: 0.7725490196, green: 0.9019607843, blue: 0.8745098039, alpha: 1),#colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)], gradientOrientation: .vertical)
            
            mCreditNoteView.applyGradient(withColours: [#colorLiteral(red: 0.7725490196, green: 0.9019607843, blue: 0.8745098039, alpha: 1),#colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)], gradientOrientation: .vertical)
            mTaxView.applyGradient(withColours: [#colorLiteral(red: 0.7725490196, green: 0.9019607843, blue: 0.8745098039, alpha: 1),#colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)], gradientOrientation: .vertical)
        }
        @IBAction func mCash(_ sender: Any) {
            mTransactionType = "Cash"
            mTaxInfoView.isHidden = true
            mKeyBoardView.isHidden = false
            mCreditCardView.isHidden = true
            mEditCashView.isHidden = false
            mChequeDetailsView.isHidden = true

            
            mCardView.layer.sublayers?.remove(at: 0)
            mCashView.layer.sublayers?.remove(at: 0)
            mBankView.layer.sublayers?.remove(at: 0)
            mCreditNoteView.layer.sublayers?.remove(at: 0)
            mTaxView.layer.sublayers?.remove(at: 0)
            mCardView.applyGradient(withColours: [#colorLiteral(red: 0.7725490196, green: 0.9019607843, blue: 0.8745098039, alpha: 1),#colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)], gradientOrientation: .vertical)
            mCashView.applyGradient(withColours: [#colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1),#colorLiteral(red: 0, green: 0.5450980392, blue: 0.7098039216, alpha: 1)], gradientOrientation: .vertical)
            mBankView.applyGradient(withColours: [#colorLiteral(red: 0.7725490196, green: 0.9019607843, blue: 0.8745098039, alpha: 1),#colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)], gradientOrientation: .vertical)
            mTaxView.applyGradient(withColours: [#colorLiteral(red: 0.7725490196, green: 0.9019607843, blue: 0.8745098039, alpha: 1),#colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)], gradientOrientation: .vertical)
            mCreditNoteView.applyGradient(withColours: [#colorLiteral(red: 0.7725490196, green: 0.9019607843, blue: 0.8745098039, alpha: 1),#colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)], gradientOrientation: .vertical)
        }
        
        @IBAction func mBank(_ sender: Any) {
            mTransactionType = "Bank"
            mTaxInfoView.isHidden = true
            mKeyBoardView.isHidden = true
            mCreditCardView.isHidden = true
            mEditCashView.isHidden = true
            mChequeDetailsView.isHidden = false

            mCardView.layer.sublayers?.remove(at: 0)
            mCashView.layer.sublayers?.remove(at: 0)
            mBankView.layer.sublayers?.remove(at: 0)
            mCreditNoteView.layer.sublayers?.remove(at: 0)
            mTaxView.layer.sublayers?.remove(at: 0)
            mCardView.applyGradient(withColours: [#colorLiteral(red: 0.7725490196, green: 0.9019607843, blue: 0.8745098039, alpha: 1),#colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)], gradientOrientation: .vertical)
            mCashView.applyGradient(withColours: [#colorLiteral(red: 0.7725490196, green: 0.9019607843, blue: 0.8745098039, alpha: 1),#colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)], gradientOrientation: .vertical)
            mBankView.applyGradient(withColours: [#colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1),#colorLiteral(red: 0, green: 0.5450980392, blue: 0.7098039216, alpha: 1)], gradientOrientation: .vertical)
            mTaxView.applyGradient(withColours: [#colorLiteral(red: 0.7725490196, green: 0.9019607843, blue: 0.8745098039, alpha: 1),#colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)], gradientOrientation: .vertical)
            mCreditNoteView.applyGradient(withColours: [#colorLiteral(red: 0.7725490196, green: 0.9019607843, blue: 0.8745098039, alpha: 1),#colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)], gradientOrientation: .vertical)
        }
        
        @IBAction func mCreditNot(_ sender: Any) {
            mTransactionType = "CreditNote"
            mTaxInfoView.isHidden = true
            mKeyBoardView.isHidden = true
            mCreditCardView.isHidden = true
            mEditCashView.isHidden = true
            mChequeDetailsView.isHidden = true

            mCardView.layer.sublayers?.remove(at: 0)
            mCashView.layer.sublayers?.remove(at: 0)
            mBankView.layer.sublayers?.remove(at: 0)
            mCreditNoteView.layer.sublayers?.remove(at: 0)
            mTaxView.layer.sublayers?.remove(at: 0)
            mCardView.applyGradient(withColours: [#colorLiteral(red: 0.7725490196, green: 0.9019607843, blue: 0.8745098039, alpha: 1),#colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)], gradientOrientation: .vertical)
            mCashView.applyGradient(withColours: [#colorLiteral(red: 0.7725490196, green: 0.9019607843, blue: 0.8745098039, alpha: 1),#colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)], gradientOrientation: .vertical)
            mBankView.applyGradient(withColours: [#colorLiteral(red: 0.7725490196, green: 0.9019607843, blue: 0.8745098039, alpha: 1),#colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)], gradientOrientation: .vertical)
            mTaxView.applyGradient(withColours: [#colorLiteral(red: 0.7725490196, green: 0.9019607843, blue: 0.8745098039, alpha: 1),#colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)], gradientOrientation: .vertical)
            mCreditNoteView.applyGradient(withColours: [#colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1),#colorLiteral(red: 0, green: 0.5450980392, blue: 0.7098039216, alpha: 1)], gradientOrientation: .vertical)
            
         
        }
        
        @IBAction func mTax(_ sender: Any) {
            mTaxInfoView.isHidden = false
            mKeyBoardView.isHidden = true
            mCreditCardView.isHidden = true
            mEditCashView.isHidden = true
            mChequeDetailsView.isHidden = true

            mCardView.layer.sublayers?.remove(at: 0)
            mCashView.layer.sublayers?.remove(at: 0)
            mBankView.layer.sublayers?.remove(at: 0)
            mCreditNoteView.layer.sublayers?.remove(at: 0)
            mTaxView.layer.sublayers?.remove(at: 0)
            
            mCardView.applyGradient(withColours: [#colorLiteral(red: 0.7725490196, green: 0.9019607843, blue: 0.8745098039, alpha: 1),#colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)], gradientOrientation: .vertical)
            mCashView.applyGradient(withColours: [#colorLiteral(red: 0.7725490196, green: 0.9019607843, blue: 0.8745098039, alpha: 1),#colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)], gradientOrientation: .vertical)
            mBankView.applyGradient(withColours: [#colorLiteral(red: 0.7725490196, green: 0.9019607843, blue: 0.8745098039, alpha: 1),#colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)], gradientOrientation: .vertical)
            mCreditNoteView.applyGradient(withColours: [#colorLiteral(red: 0.7725490196, green: 0.9019607843, blue: 0.8745098039, alpha: 1),#colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)], gradientOrientation: .vertical)
            mTaxView.applyGradient(withColours: [#colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1),#colorLiteral(red: 0, green: 0.5450980392, blue: 0.7098039216, alpha: 1)], gradientOrientation: .vertical)

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
            mCreditCardPaymentView.isHidden = false
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
                let convertedAmounts = Double(mConvertedAmounts) ?? 0.0
                let submittedBankAmount = Double(mSubmittedBankAmount.text ?? "") ?? 0.0
                let submittedCreditCard = Double(mSubmittedCreditCard.text ?? "") ?? 0.0

                self.mTOTALAMOUNT.text = "\(convertedAmounts + submittedBankAmount + submittedCreditCard)"
            }
        }
        
        
        @IBAction func mShowTaxView(_ sender: Any) {

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
                mConvertedAmount.text = "= \(self.mCurrencyName.text ?? "") \(mConvertedAmounts)"
                }
            }else{
                if mTransactionType == "Cash" {
                    if mExchangeRateLabel.isHidden == false {
                        if mExchangeRateValue.text != "" {
                            let mVal = Double(mExchangeRateValue.text ?? "") ?? 0
                            if mCashAmount.text != "" && mCashAmount.text != "."  {
//                                mConvertedAmounts = "\((Double(mCashAmounts) ?? 0) * mVal)"
//                                mConvertedAmount.text = "=  \(self.mCurrencyName.text ?? "") \(mConvertedAmounts)"
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
                        mConvertedAmount.text = "= \(self.mCurrencyName.text ?? "") \(mConvertedAmounts)"
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
                mConvertedAmounts = "0.0"
                mSubmittedCash.text = "0.0"
                let convertedAmounts = Double(mConvertedAmounts) ?? 0.0
                let submittedBankAmount = Double(mSubmittedBankAmount.text ?? "") ?? 0.0
                let submittedCreditCard = Double(mSubmittedCreditCard.text ?? "") ?? 0.0

                self.mTOTALAMOUNT.text = "\(convertedAmounts + submittedBankAmount + submittedCreditCard)"
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
//                        mConvertedAmount.text = "=  \(self.mCurrencyName.text ?? "") \(mConvertedAmounts)"
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
                    mConvertedAmount.text = "= \(self.mCurrencyName.text ?? "") \(mConvertedAmounts)"
                }
            }
        }
        
        
    }
//    func mInsertAmount(num : String) {
//        
//        mCashAmounts.insert(contentsOf: num, at: mCashAmounts.endIndex)
//        mCashAmount.text = mCashAmounts
//        
//        if mTransactionType == "Cash" {
//            if mExchangeRateLabel.isHidden == false {
//                if mExchangeRateValue.text != "" {
//                    let mVal = Double(mExchangeRateValue.text ?? "") ?? 0
//                    if mCashAmount.text != "" && mCashAmount.text != "."  {
//                        mConvertedAmounts = "\((Double(mCashAmounts) ?? 0) * mVal)"
//                        mConvertedAmount.text = "=  \(self.mCurrencyName.text ?? "") \(mConvertedAmounts)"
//                    }
//                }
//            }else{
//                if mCashAmount.text != "" && mCashAmount.text != "."  {
//                    mConvertedAmounts = "\(Double(mCashAmounts) ?? 0)"
//                    mConvertedAmount.text = "= \(self.mCurrencyName.text ?? "") \(mConvertedAmounts)"
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
         
            
            if mCustomerId == "" {
                CommonClass.showSnackBar(message:"Please choose Customer")
            }else if mSalesPersonId == "" {
                CommonClass.showSnackBar(message:"Please choose Sales Person")
            }else{
                
               
              

            
                mFinalPaymentMethod = NSMutableDictionary()
               
               let mCashMethod = NSMutableDictionary()
            
               
               let mBankMethod = NSMutableArray()
               let mChequeMethod = NSMutableDictionary()
              
              
                
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
               mFinalPaymentMethod.setValue(self.mCreditCardMethod, forKey: "Credit_Card")
               mFinalPaymentMethod.setValue(mCashMethod, forKey: "Cash")
               mFinalPaymentMethod.setValue(mBankMethod, forKey: "Bank")
              

            
               
              
                if mOrderType == "Deposit"{
                    
                    if (Double(mTOTALAMOUNT.text ?? "") ?? 0) * 1 != 0.0 {
                        AddNow()
                    }else{
                        CommonClass.showSnackBar(message: "Please enter valid amount!")
                    }
                    
                }else{
                    if Double(mTOTALAMOUNT.text ?? "") ==  Double(mCouponTotal) {
                        AddNow()
                    }else{
                        CommonClass.showSnackBar(message: "Please enter valid amount!")
                    }
                }
            }
            
        }
        
        @IBAction func mStartSearch(_ sender: Any) {
           
        }
        @IBAction func mEndSearch(_ sender: Any) {

        }
    @IBAction func mEditChanged(_ sender: Any) {
        
        let value = mCustomerSearch.text?.count
        if value != 0 {
            self.mSearchCustomerByKeys(value: mCustomerSearch.text ?? "")
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
        
        func calculateTax(){
            var mAmount =  Double()

            var mDiscountA = Double(self.mDiscountAmounts.text ?? "") ?? 0
            var mLabour = Double(self.mLabourCharge.text ?? "") ?? 0
            var mShipping = Double(self.mShippingCharge.text ?? "") ?? 0
            mAmount = mLabour + mShipping

            mTotalDiscountTx.text = mDiscountAmounts.text
            mTotalTx.text = "\((mAmount + (Double(mTotalAm) ?? 0)) )"
            mTOTALAMOUNT.text = "\((mAmount + (Double(mTotalAm) ?? 0) - mDiscountA) )"
            
            let totalAmount = Double(mTOTALAMOUNT.text ?? "") ?? 0.0
            let submittedCash = Double(mSubmittedCash.text ?? "") ?? 0.0
            let submittedBankAmount = Double(mSubmittedBankAmount.text ?? "") ?? 0.0
            mBALANCEDUE.text = "\(totalAmount - submittedCash - submittedBankAmount)"

            let totalTx = Double(mTotalTx.text ?? "") ?? 0.0
            let discountAmounts = Double(mDiscountAmounts.text ?? "") ?? 0.0
            let taxPercent = Double(mTaxP) ?? 0.0

            let taxAmount = calculateInclusiveTax(value: totalTx - discountAmounts, percent: taxPercent)
            mTaxAmountTx.text = String(format: "%.02f", locale: Locale.current, taxAmount)

            let subTotal = totalTx - discountAmounts - taxAmount
            mSubTotalTx.text = String(format: "%.02f", locale: Locale.current, subTotal)
            
            mFinalTaxAmount.text = mTaxAmountTx.text
     
        }
        
        
        
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            
           
            return mSearchCustomerData.count
            
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            tableView.showsVerticalScrollIndicator = false
            tableView.showsHorizontalScrollIndicator = false

           
            guard let cells = tableView.dequeueReusableCell(withIdentifier: "CustomerSearchItem") as? CustomerSearchItem else {
                return UITableViewCell()
            }
          
            if let mData =  mSearchCustomerData[indexPath.row] as? NSDictionary {
                
                if let fname = mData.value(forKey: "fname"){
                    cells.mCustomerName.text =  "\(fname)"
                }
                
                if let lname = mData.value(forKey: "lname") {
                    cells.mCustomerName.text?.append(" \(lname)")
                }
                
                if let pcode = mData.value(forKey: "phone_code") {
                    cells.mPhone.text = "+\(pcode)"
                }
                
                if let phone = mData.value(forKey: "phone") {
                    cells.mPhone.text?.append(" \(phone)")
                }
                
                if let stateCountry = mData.value(forKey: "stateCountry") {
                    cells.mPlace.text = (" \(stateCountry)")
                }
            }
            return cells
        }
        
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            
            if tableView == mCustomerSearchTableView {
                
                if let mData =  mSearchCustomerData[indexPath.row] as? NSDictionary {
                    
                    if let cusId = mData.value(forKey: "Customer_id") {
                        mCustomerId = "\(cusId)"
                        UserDefaults.standard.set(mCustomerId, forKey: "CUSTOMERID")
                    }
                    
                    if let fname = mData.value(forKey: "fname") {
                        self.mCustomerNames.text =  "\(fname)"
                    }
                    
                    if let lname = mData.value(forKey: "lname") {
                        self.mCustomerNames.text?.append(" \(lname)")
                        UserDefaults.standard.set(self.mCustomerNames.text ?? "" , forKey: "CUSTOMERNAME")
                    }
                    
                    if let phoneCode = mData.value(forKey: "phone_code") {
                        self.mCustomerNumbers.text = "\(phoneCode)"
                    }
                    
                    if let phone = mData.value(forKey: "phone") {
                        self.mCustomerNumbers.text?.append(" \(phone)")
                    }
                    
                    if let stateCountry = mData.value(forKey: "stateCountry") {
                        self.mCustomerAddresss.text = "\(stateCountry)"
                    }
                    
                }
                
                self.mCustomerSearchView.isHidden = true
                self.mCustomerDetailView.isHidden = false
                self.mCustomerSearch.text = ""
                mCustomerSearchTableView.removeFromSuperview()
                
            }
                
        }
        
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 70
            
        }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let value = textField.text ?? ""
        mSearchCustomerByKeys(value: value)
    }
    
    func mSearchCustomerByKeys(value: String){
        let urlPath =  mSearchCustomerByKey
        let params = ["key": value]
        
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
                        self.mSearchCustomerData = NSArray()
                        if let mData = jsonResult.value(forKey: "list") as? NSArray {
                            
                            self.mSearchCustomerData =  mData
                            self.mSetupTableView(frame:self.mCustomerSearchView.frame)
                            
                        }
                        
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
        
    func AddNow(){
        
        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
        
        let mLocation = UserDefaults.standard.string(forKey: "location") ?? ""
        
        var params = [String:Any]()
        var urlPath = ""
        
        if mOrderType == "Deposit" {
            urlPath =  mDepositAdd
            params = ["CustomerID":mCustomerId,
                      "transaction_type":mTransactionType,
                      "POS_Location_id":mLocation,
                      "salesPerson_id":mSalesPersonId,
                      "amounts":self.mTOTALAMOUNT.text ?? "",
                      "POS_Final_CreditCardAmount_value":self.mSubmittedCreditCard.text ?? "",
                      "POS_Final_bank_Payment_cheque_information_json": self.mChequeData,
                      "paymentMethodId":self.mFinalPaymentMethod]
            
        }else{
            
            params = ["Customer_id":self.mCustomerId,
                      "GisGiftCard":self.mCartTableData,
                      "POS_Location_id":mLocation,
                      "salesPerson_id":self.mSalesPersonId,
                      "bank_Amount_value": "0" ,
                      "creditCard_Amount_value":"0",
                      "finalAmountsat_side_DueAmount":"0",
                      "POS_Final_CreditCardAmount_value":self.mSubmittedCreditCard.text ?? "",
                      "POS_Final_Bank_Amount_value":self.mSubmittedBankAmount.text ?? "",
                      "POS_Final_bank_Payment_cheque_information_json": self.mChequeData,
                      "paymentMethodId":self.mFinalPaymentMethod,
                      "Cash_Amount_value":self.mSubmittedCash.text ?? "",
                      "final_total":self.mCouponTotal]
            urlPath =  mGiftPayment
            
        }
        
        if self.mOrderType == "Deposit" {
            mAddDeposit(urlPath: urlPath, params: params)
        }else{
            
            if "\(UserDefaults.standard.string(forKey: "isPinEnable") ?? "")" == "1" {
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                if let mPin = storyBoard.instantiateViewController(withIdentifier: "LoginWithPin") as? LoginWithPin {
                    mPin.mKey = "1"
                    mPin.mParams = params
                    mPin.mUrl = urlPath
                    mPin.mType = "Gift Card"
                    self.navigationController?.pushViewController( mPin, animated:true)
                }
            }else{
                mFinalPay(urlPath: urlPath, params: params)
            }


        }

    }
        
    func mAddDeposit(urlPath : String , params: [String:Any]){
        
        if Reachability.isConnectedToNetwork() == true {
            AF.request(urlPath, method:.post, parameters:params,encoding: JSONEncoding.default, headers: sGisHeaders2).responseJSON
            { response in
                
                if(response.error != nil){
                    
                    CommonClass.showSnackBar(message: "OOP's something went wrong!")
                    
                }else{
                    guard let jsonData = response.data else {
                        return
                    }
                    
                    let json = try? JSONSerialization.jsonObject(with: jsonData, options: [])
                    
                    guard let jsonResult = json as? NSDictionary else {
                        return
                    }
                    if jsonResult.value(forKey: "code") as? Int == 200 {
                        
                        
                        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        
                        if let mSubmitDeposit = storyBoard.instantiateViewController(withIdentifier: "SubmitDeposit") as? SubmitDeposit {
                            
                            mSubmitDeposit.mCustomerName = self.mCustomerNames.text ?? ""
                            mSubmitDeposit.mCustomerNumber = self.mCustomerNumbers.text ?? ""
                            mSubmitDeposit.mCustomerAddress = self.mCustomerAddresss.text ?? ""
                            mSubmitDeposit.mCustomerId = self.mCustomerId
                            mSubmitDeposit.mSalesPersonId =  self.mSalesPersonId
                            self.navigationController?.pushViewController(mSubmitDeposit, animated:true)
                        }
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
    func mFinalPay(urlPath : String , params: [String:Any]){
        
        if Reachability.isConnectedToNetwork() == true {
            AF.request(urlPath, method:.post, parameters:params,encoding: JSONEncoding.default, headers: sGisHeaders2).responseJSON
            { response in
                
                if response.error != nil {
                    
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
                        self.mGenerateReport(id: "\(jsonResult.value(forKey: "pdf_url") ?? "")", jsonResult: jsonResult)
                        
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
                    
                    if let email = jsonVal.value(forKey: "email") {
                        UserDefaults.standard.setValue("\(email)", forKey: "mailInvoice")
                    }
                    UserDefaults.standard.setValue("\(jsonVal.value(forKey: "pdf_url") ?? "")", forKey: "report")
                    
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    if let mCompletePayment = storyBoard.instantiateViewController(withIdentifier: "CompletePayment") as? CompletePayment {
                        print("========== DEPOSIT RESPONSE ==========")
                        print(jsonResult)
                        print("======================================")
                        mCompletePayment.mOrderId = "\(jsonResult.value(forKey: "id") ?? "")"
                        mCompletePayment.mType = "Gift Card"
                        mCompletePayment.mDue = "\(jsonResult.value(forKey: "totalAmt") ?? "")"
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
        print("4")
        let urlPath = mGetCurrencies
        
        
        if Reachability.isConnectedToNetwork() == true {
            AF.request(urlPath, method:.post, parameters:nil, headers: sGisHeaders2).responseJSON
            { response in
                
                if(response.error != nil){
                    
                    CommonClass.showSnackBar(message: "OOP's something went wrong!")
                    
                }else{
                    guard let jsonData = response.data else {
                        return
                    }
                    
                    let json = try? JSONSerialization.jsonObject(with: jsonData, options: [])
                    
                    guard let jsonResult = json as? NSDictionary else {
                        return
                    }
                    
                    if let data = jsonResult.value(forKey: "currency") as? NSArray {
                        
                        for i in data {
                            if let currency = i as? NSDictionary {
                                self.mCurrencyNameData.append("\(currency.value(forKey: "currency") ?? "")")
                                self.mCurrencyImageData.append("\(currency.value(forKey: "url") ?? "")")
                                self.mExchangeRateData.append("\(currency.value(forKey:"rate") ?? "")")

                                if "\(currency.value(forKey:"currency") ?? "")" == self.mStoreCurrency {
                                    self.mCashCurrencyImage.downlaodImageFromUrl(urlString: "\(currency.value(forKey:"url") ?? "")")
                                    self.mCurrencyName.text = self.mStoreCurrency
                                    self.mSelectedStoreCurrency = self.mStoreCurrency

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
        
        
    @IBAction func mChooseSalesPerson(_ sender: Any) {
        let dropdown = DropDown()
        dropdown.anchorView = self.mSalesPersonName
        dropdown.direction = .bottom
        dropdown.bottomOffset = CGPoint(x: 0, y: self.mSalesPersonName.frame.size.height)
        dropdown.width = 200
        dropdown.dataSource = mSalesManList
        dropdown.selectionAction = {
            [unowned self](index:Int, item: String) in
            self.mSalesPersonName.text  = item
            
            self.mSalesPersonId =  self.mSalesManIDList[index]
            UserDefaults.standard.set(self.mSalesPersonId , forKey: "SALESPERSONID")
        }
        dropdown.show()
    }
        
        
    func mGetSalesPerson(){
        let mLocation = UserDefaults.standard.string(forKey: "location") ?? ""
        
        let urlPath =  mGetSalesPersonList
        let params = ["location": mLocation]
        if Reachability.isConnectedToNetwork() == true {
            AF.request(urlPath, method:.post, parameters: params, headers: sGisHeaders2).responseJSON
            { response in
                
                if(response.error != nil){
                    
                    CommonClass.showSnackBar(message: "OOP's something went wrong!")
                    
                    
                    
                }else{
                    guard let jsonData = response.data else {
                        return
                    }
                    
                    let json = try? JSONSerialization.jsonObject(with: jsonData, options: [])
                    
                    guard let jsonResult = json as? NSDictionary else {
                        return
                    }
                    
                    if jsonResult.value(forKey: "code") as? Int == 200 {
                        
                        
                        if let data = jsonResult.value(forKey: "Salesperson") as? NSArray {
                            self.mSalesManList = [String]()
                            self.mSalesManIDList = [String]()
                            
                            for i in data {
                                if let salesData = i as? NSDictionary {
                                    self.mSalesManList.append("\(salesData.value(forKey:"name") ?? "") " + "\(salesData.value(forKey:"lname") ?? "")" )
                                    
                                    self.mSalesManIDList.append("\(salesData.value(forKey:"id") ?? "")")
                                    self.mSalesPersonName.text = self.mSalesManList[0]
                                    self.mSalesPersonId =  self.mSalesManIDList[0]
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
                
                
            }
        }else{
            CommonClass.showSnackBar(message: "No Internet Connection")
        }
        
        
    }
        
        
    func mFetchStore(key: String){
        
        let mLocation = UserDefaults.standard.string(forKey: "location")
        
        let urlPath =  mFetchStoreData
        let params = ["login_token": mUserLoginToken ?? "", "location_id":mLocation ?? ""]

        if Reachability.isConnectedToNetwork() == true {
            AF.request(urlPath, method:.post, parameters:params, headers: sGisHeaders2).responseJSON
            { response in
                

                if(response.error != nil){
                    
                    CommonClass.showSnackBar(message: "OOP's something went wrong!")
                    
                }else{
                    guard let jsonData = response.data else {
                        return
                    }
                    
                    let json = try? JSONSerialization.jsonObject(with: jsonData, options: [])
                    
                    guard let jsonResult = json as? NSDictionary else {
                        return
                    }
                    if jsonResult.value(forKey: "code") as? Int == 200 {
                        
                        if let mUserData = jsonResult.value(forKey: "user_datail") as? NSDictionary {
                            
                            if let pin = mUserData.value(forKey: "pin"){
                                UserDefaults.standard.setValue("\(pin)", forKey: "TRANSACTIONPIN")
                            }else{
                                UserDefaults.standard.setValue("9543", forKey: "TRANSACTIONPIN")
                            }
                            
                        }else{
                            UserDefaults.standard.setValue("9543", forKey: "TRANSACTIONPIN")
                        }
                        if let payMethod = jsonResult.value(forKey: "Payment_method") as? NSDictionary {
                            UserDefaults.standard.setValue(payMethod, forKey: "PAYMENTMETHODID")
                        }
                        if let mSettings = jsonResult.value(forKey: "generalSetting") as? NSDictionary {
                            
                            if let pinForEverySale = mSettings.value(forKey: "userEnter_PIN_forEverySale"){
                                
                                if "\(pinForEverySale)" == "1" {
                                    UserDefaults.standard.setValue("1", forKey: "isPinEnable")
                                }else{
                                    UserDefaults.standard.setValue("0", forKey: "isPinEnable")
                                }
                                
                            }else{
                                UserDefaults.standard.setValue("0", forKey: "isPinEnable")
                            }
                        }else{
                            UserDefaults.standard.setValue("0", forKey: "isPinEnable")
                        }
                        
                        if let mLocationData = jsonResult.value(forKey: "location_data") as? NSDictionary {
                            
                            if let currency = mLocationData.value(forKey: "currency") {
                                self.mStoreCurrency = "\(currency)"
                                UserDefaults.standard.setValue("\(currency)", forKey: "currency")
                                self.mGetCurrency()
                            }
                        }
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
        
    }
