//
//  SubmitDeposit.swift
//  GIS
//
//  Created by Apple Hawkscode on 23/09/21.
//

import UIKit
import Alamofire


class DepositList: UITableViewCell {
    @IBOutlet weak var mAmount: UITextField!
    @IBOutlet weak var mRefNo: UILabel!
    
    @IBOutlet weak var mCode: UILabel!
    @IBOutlet weak var mTransaction: UILabel!
}

class SubmitDeposit: UIViewController , UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var mCustomerSearchView: UIView!
    @IBOutlet weak var mCustomerDetailView: UIView!
    @IBOutlet weak var mCustomerNames: UILabel!
    @IBOutlet weak var mCustomerAddresss: UILabel!
    @IBOutlet weak var mCustomerNumbers: UILabel!
    @IBOutlet weak var mCustomerSearch: UITextField!
    
    @IBOutlet weak var mDepositTable: UITableView!
    @IBOutlet weak var mTotalAmount: UILabel!
    
    @IBOutlet weak var mRemark: UITextField!
    var mCustomerAddress = ""
    var mCustomerName = ""
    var mCustomerNumber = ""
    var mDepositData = NSArray()
    var mCustomerId = ""
    var mSalesPersonId = ""
    var mDepositCart = [String]()
    var mTotalAm = ""
    @IBOutlet weak var mSubmitReserveView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap =  UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
              view.addGestureRecognizer(tap)
              tap.cancelsTouchesInView = false
        
        mCustomerAddresss.text = mCustomerAddress
        mCustomerNames.text = mCustomerName
        mCustomerNumbers.text = mCustomerNumber
        
        mDepositTable.delegate = self
        mDepositTable.dataSource = self
        mDepositTable.reloadData()
        mGetDetails()
        
    }
    override func viewDidLayoutSubviews() {

        self.view.applyGradient(withColours: [#colorLiteral(red: 0.7725490196, green: 0.9019607843, blue: 0.8745098039, alpha: 1),#colorLiteral(red: 0.9207345247, green: 0.9503677487, blue: 0.978346765, alpha: 1)], gradientOrientation: .vertical)
        
        
        mSubmitReserveView.layer.sublayers?.remove(at: 0)
        mSubmitReserveView.applyGradient(withColours: [#colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1),#colorLiteral(red: 0.01176470588, green: 0.2862745098, blue: 0.5568627451, alpha: 1)], gradientOrientation: .horizontal)
            }

    
    @IBAction func mBack(_ sender: Any) {
    
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func mAddMore(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let mCheckOut = storyBoard.instantiateViewController(withIdentifier: "DepositPayment") as? DepositPayment {
            mCheckOut.mOrderType = "Deposit"
            self.navigationController?.pushViewController( mCheckOut, animated:true)
        }
    }
    @IBAction func mSubmitDepositNow(_ sender: Any) {
        
        if mRemark.text == "" {
            CommonClass.showSnackBar(message: "Please Fill Remarks")
        }else{
            mDepositCart = [String]()
            for i in mDepositData {
                if let v = i as? NSDictionary,
                   let cartId = v.value(forKey: "disposit_cart_id") {
                    mDepositCart.append("\(cartId)")
                }
            }
            mSubmit(carId: mDepositCart)
        }
        
    }
    
    
    @IBAction func mEditCustomer(_ sender: Any) {
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mDepositData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DepositList") as? DepositList else {
            return UITableViewCell()
        }
        
        if let mData = mDepositData[indexPath.row] as? NSDictionary {
            cell.mAmount.text = "\(mData.value(forKey: "amounts") ?? "0.0")"
            cell.mRefNo.text = "00\(mData.value(forKey: "Ref_No") ?? "")"
            cell.mCode.text = "\(indexPath.row + 1)"
            cell.mTransaction.text = "\(mData.value(forKey: "trasctionMethod") ?? "")"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 35
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let mData1 = mDepositData[indexPath.row] as? NSDictionary,
               let cartId = mData1.value(forKey: "disposit_cart_id"){
                mRemove(id:"\(cartId)")
            }
        }
    }
    
    func mRemove(id:String){
        
        let mLocation = UserDefaults.standard.string(forKey: "location")
        
        var params = [String:Any]()
        
        params = ["disposit_cart_id":id]
        
        
        let urlPath =  mDepositRemove
        
  
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
                        self.mGetDetails()
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
    func mGetDetails(){
        
        let mLocation = UserDefaults.standard.string(forKey: "location") ?? ""
        
        var params = [String:Any]()
        
        params = ["customer_id":mCustomerId,"POS_Location_id":mLocation]
        
        let urlPath =  mDepositGet
        
    
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
                        
                        self.mTotalAm = "\(jsonResult.value(forKey: "final_total") ?? "0.0")"
                        self.mDepositData = NSArray()
                        self.mTotalAmount.text = "\(jsonResult.value(forKey: "final_total_unformate") ?? "0.0")"
                        if let mData = jsonResult.value(forKey: "data") as? NSArray {
                            
                            if mData.count > 0 {
                                self.mDepositData = mData
                                self.mDepositTable.reloadData()
                            }else{
                                self.mDepositTable.reloadData()
                            }
                        }
                        
                        
                    }else{

                        self.mTotalAmount.text = "0.0"
                        self.mDepositData = NSArray()
                        self.mDepositTable.reloadData()
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
    
    func mSubmit(carId:[String]){

        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
        
        let mLocation = UserDefaults.standard.string(forKey: "location") ?? ""

        var params = [String:Any]()

        params = ["CustomerID":mCustomerId,"disposit_cart_id":carId,"POS_Location_id":mLocation
                  ,"remark":self.mRemark.text ?? "","salesPerson_id" : mSalesPersonId]
    
        let urlPath =  mDepositSubmit
        
        if let pin = UserDefaults.standard.string( forKey: "isPinEnable"), "\(pin)" == "1" {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            if let mPin = storyBoard.instantiateViewController(withIdentifier: "LoginWithPin") as? LoginWithPin {
                mPin.mKey = "1"
                mPin.mParams = params
                mPin.mUrl = urlPath
                mPin.mType = "Deposit"
                self.navigationController?.pushViewController( mPin, animated:true)
            }
        }else{
            mFinalPay(urlPath: urlPath, params: params)
        }

    }

    func mFinalPay(urlPath : String , params: [String:Any]){
        
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
                        if let pdfUrl = jsonResult.value(forKey: "pdf_url") as? String {
                            UserDefaults.standard.setValue(pdfUrl, forKey: "reportAPI")
                            print("========== PDF API RESPONSE ==========")
                            print(jsonResult)
                            print("ORDER ID =", jsonResult["id"] ?? "nil")
                            print("======================================")
                            self.mGenerateReport(id:pdfUrl, jsonResult: jsonResult)
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
                    
                    guard let jsonResult = json as? NSDictionary else {
                        CommonClass.showSnackBar(message: "OOP's something went wrong!")
                        return
                    }
                    UserDefaults.standard.set("", forKey: "CUSTOMERID")
                    UserDefaults.standard.set("", forKey: "SALESPERSONID")
                 
                    if let email = jsonResult.value(forKey: "email") {
                        UserDefaults.standard.setValue("\(email)", forKey: "mailInvoice")
                    }
                    if let pdfUrl = jsonResult.value(forKey: "pdf_url") as? String {
                        UserDefaults.standard.setValue(pdfUrl, forKey: "report")
                    }
                
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    if let mCompletePayment = storyBoard.instantiateViewController(withIdentifier: "CompletePayment") as? CompletePayment {
                        print("========== DEPOSIT RESPONSE ==========")
                        print(jsonResult)
                        print("======================================")
                        mCompletePayment.mOrderId = "\(jsonResult.value(forKey: "id") ?? "")"
                        mCompletePayment.mType = "Deposit"
                        mCompletePayment.mDue = self.mTotalAm
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
}
