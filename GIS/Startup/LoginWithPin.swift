//
//  LoginWithPin.swift
//  GIS
//
//  Created by Apple Hawkscode on 16/10/20.
//

import UIKit
import Alamofire
import AVFoundation
import Intents
import AppIntents
class LoginWithPin: UIViewController {
    
    
    
    
    @IBOutlet weak var mPinOne: UILabel!
    @IBOutlet weak var mPinTwo: UILabel!
    @IBOutlet weak var mPinThree: UILabel!
    @IBOutlet weak var mPinFour: UILabel!
    @IBOutlet weak var mPinSix: UILabel!
    @IBOutlet weak var mPinFive: UILabel!
    @IBOutlet weak var mLoginWIthPassButton: UIButton!
    
    @IBOutlet weak var mFaceIdButton: UIView!
    
    private var mFaceDetected = false

    // PIN required after selecting Organization + Store.
    // Separate from mKey, which is used by transaction-payment PIN.
    var mRequiresOrganizationStorePin = false
    
    var mPin = ""
    var mKey = ""
    var mTotal = ""
    var mDue = ""
    var mType = ""
    
    var mParams = [String:Any]()
    var mUrl = ""
    var mOrderType = ""
    
    let biometricIDAuth = BiometricIdAuth()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.mKey != "" {
            mLoginWIthPassButton.isHidden  = true
            mFaceIdButton.alpha = 0
            mFaceIdButton.isUserInteractionEnabled = false
        }

        // After selecting Organization + Store, allow either normal PIN
        // or Face ID, exactly like the regular Login with PIN screen.
        if self.mRequiresOrganizationStorePin {
            mFaceIdButton.alpha = 1
            mFaceIdButton.isUserInteractionEnabled = true
        }
        
        self.biometricIDAuth.canEvaluate { (canEvaluate, _, canEvaluateError) in
            if canEvaluate {
                mDetectFace()
            } else {
                mFaceIdButton.alpha = 0
                mFaceIdButton.isUserInteractionEnabled = false
                print("Face not recognization")
            }
        }
        
        
    }
    
    
    override func loadViewIfNeeded() {

    }
    
    override func viewDidAppear(_ animated: Bool) {
        let g = CAGradientLayer()
        g.frame =  self.view.bounds
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {

    }

    override func viewDidLayoutSubviews() {

    }

    @IBAction func mBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func mPressOne(_ sender: UIButton) {
        sender.showAnimation{}
        if mPin.count < 7 || mPin == "" {
        
            mPin.insert(contentsOf: "1", at: mPin.endIndex)
            mInsertPin(count: mPin.count)
        }
    }
    
    
    
    @IBAction func mPressTwo(_ sender: UIButton) {
        sender.showAnimation{}
        if mPin.count < 7 || mPin == "" {
            mPin.insert(contentsOf: "2", at: mPin.endIndex)
            mInsertPin(count: mPin.count)
        }
    }
    
    
    @IBAction func mPressThree(_ sender: UIButton) {
        sender.showAnimation{}
        if mPin.count < 7 || mPin == "" {
            mPin.insert(contentsOf: "3", at: mPin.endIndex)
            mInsertPin(count: mPin.count)
        }
    }
    
    
    @IBAction func mPressFour(_ sender: UIButton) {
        sender.showAnimation{}
        if mPin.count < 7 || mPin == "" {
            mPin.insert(contentsOf: "4", at: mPin.endIndex)
            mInsertPin(count: mPin.count)
        }
    }
    
    
    
    @IBAction func mPressFive(_ sender: UIButton) {
        sender.showAnimation{}
        if mPin.count < 7 || mPin == "" {
            mPin.insert(contentsOf: "5", at: mPin.endIndex)
            mInsertPin(count: mPin.count)
        }
    }
    
    
    @IBAction func mPressSix(_ sender: UIButton) {
        sender.showAnimation{}
        if mPin.count < 7 || mPin == "" {
            mPin.insert(contentsOf: "6", at: mPin.endIndex)
            mInsertPin(count: mPin.count)
        }
    }
    
    
    @IBAction func mPressSeven(_ sender: UIButton) {
        sender.showAnimation{}
        if mPin.count < 7 || mPin == "" {
            mPin.insert(contentsOf: "7", at: mPin.endIndex)
            mInsertPin(count: mPin.count)
        }
    }
    
    @IBAction func mPressEight(_ sender: UIButton) {
        sender.showAnimation{}
        if mPin.count < 7 || mPin == "" {
            mPin.insert(contentsOf: "8", at: mPin.endIndex)
            mInsertPin(count: mPin.count)
        }
    }
    
    
    
    @IBAction func mPressNine(_ sender:  UIButton) {
        sender.showAnimation{}
        if mPin.count < 7 || mPin == "" {
            mPin.insert(contentsOf: "9", at: mPin.endIndex)
            mInsertPin(count: mPin.count)
        }
    }
    
    
    
    @IBAction func mPressZero(_ sender: UIButton) {
        sender.showAnimation{}
        if mPin.count < 7 || mPin == "" {
            mPin.insert(contentsOf: "0", at: mPin.endIndex)
            mInsertPin(count: mPin.count)
        }
    }
    
    @IBAction func mClearPin(_ sender: UIButton) {
        sender.showAnimation{}
        
        if mPin != "" {
            mPin.removeLast()
            mDelete(count: mPin.count)
        }else{
            mPin = ""
            mDelete(count: 0)
        }
        
    }
    
    @IBAction func mLogInWithFaceId(_ sender: UIButton) {
        sender.showAnimation {
            self.mDetectFace()
        }
    }
    
    private func mDetectFace(){
        self.biometricIDAuth.evaluate { [weak self] (success, error) in
            if success {
                self?.mFaceDetected = true
                self?.mLoginWithPin()
            }else{
                if let error = error{
                    if error.errorDescription == "\(BiometricError.biometryNotAvailable)" {
                        self?.mFaceIdButton.alpha = 0
                        self?.mFaceIdButton.isUserInteractionEnabled = false
                        CommonClass.showSnackBar(message: "Face Id is currently unavailable. Use PIN to login.")
                    }
                    
                }else{
                    
                }
            }
        }
    }
    
    @IBAction func mForgotPin(_ sender:  UIButton) {
        sender.showAnimation{
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            
            if let mForgotPinController = storyBoard.instantiateViewController(withIdentifier: "ForgotPinController") as? ForgotPinController {
                self.navigationController?.pushViewController(mForgotPinController, animated:true)
            }
        }
    }
    
    @IBAction func mLoginWithPass(_ sender:  UIButton) {
        sender.showAnimation{
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            if let home = storyBoard.instantiateViewController(withIdentifier: "LoginController") as? LoginController
            {
                self.navigationController?.pushViewController(home, animated:true)
            }
        }
    }
    
    func mInsertPin(count:Int){
        
        if(count == 1){
            mPinOne.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        }else if(count == 2){
            mPinOne.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            mPinTwo.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            
        }else if(count == 3){
            mPinOne.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            mPinTwo.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            mPinThree.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            
            
        }else if(count == 4){
            mPinOne.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            mPinTwo.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            mPinThree.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            mPinFour.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        }else if(count == 5){
            mPinOne.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            mPinTwo.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            mPinThree.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            mPinFour.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            mPinFive.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            
            
            
            
        }else if(count == 6){
            mPinOne.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            mPinTwo.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            mPinThree.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            mPinFour.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            mPinFive.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            mPinSix.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            
            if self.mRequiresOrganizationStorePin {
                // Use the normal login PIN for the Organization + Store security step.
                mLoginWithPin()
            } else if self.mKey == "" {
                mLoginWithPin()
            }else{
                if "\(UserDefaults.standard.string(forKey: "TRANSACTIONPIN") ?? "")".description == mPin {
                    mFinalPay(urlPath: mUrl, params: mParams)
                }else{
                    CommonClass.showSnackBar(message: "Invalid Pin!")
                }
            }
            
        }else{
            
        }
        
    }
    
    func mFinalPay(urlPath : String , params: [String:Any]){
        
        if Reachability.isConnectedToNetwork() == true {
            AF.request(urlPath, method:.post, parameters:params, encoding :JSONEncoding.default, headers: sGisHeaders).responseJSON
            { response in
                
                if(response.error != nil){
                    
                    CommonClass.showSnackBar(message: "OOP's something went wrong!")
                    
                }else{
                    guard let jsonData = response.data else{
                        CommonClass.showSnackBar(message: "OOP's something went wrong!")
                        return
                    }
                    
                    let json = try? JSONSerialization.jsonObject(with: jsonData, options: [])
                    
                    if let jsonResult = json as? NSDictionary, jsonResult.value(forKey: "code") as? Int == 200 {
                        if let url = jsonResult.value(forKey: "pdf_url"){
                            UserDefaults.standard.setValue("\(url)", forKey: "reportAPI")
                            self.mGenerateReport(id:"\(url)" , jsonResult : jsonResult)
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
                    
                    guard let jsonVal = json as? NSDictionary else{
                        CommonClass.showSnackBar(message: "OOP's something went wrong!")
                        return
                    }
                    
                    UserDefaults.standard.set("", forKey: "CUSTOMERID")
                    UserDefaults.standard.set("", forKey: "SALESPERSONID")
                    CommonClass.showSnackBar(message: "Payment Successful")
                    
                    if let email = jsonVal.value(forKey: "email") {
                        UserDefaults.standard.setValue("\(email)", forKey: "mailInvoice")
                    }
                    if let pdfUrl = jsonVal.value(forKey: "pdf_url") {
                        UserDefaults.standard.setValue("\(pdfUrl)", forKey: "report")
                    }
                    
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    if let mCompletePayment = storyBoard.instantiateViewController(withIdentifier: "CompletePayment") as? CompletePayment {
                        if self.mType == "Gift Card" || self.mType == "Deposit" {
                            if self.mType == "Exchange" || self.mType == "Refund" {
                                if let totalAmount = jsonResult.value(forKey: "total_amount") {
                                    mCompletePayment.mDue = "\(totalAmount)"
                                }
                            }else{
                                if let totalAmt = jsonResult.value(forKey: "totalAmt") {
                                    mCompletePayment.mDue = "\(totalAmt)"
                                }
                            }
                            
                        }else{
                            if let dueAmt = jsonResult.value(forKey: "DueAmt"),
                               let totalAmt = jsonResult.value(forKey: "totalAmt"){
                                mCompletePayment.mDue = "\(dueAmt)"
                                mCompletePayment.mTotal = "\(totalAmt)"
                            }
                        }
                        mCompletePayment.mType = self.mType
                        
                        self.navigationController?.pushViewController(mCompletePayment, animated:true)
                    }
                }
                
                
            }
        }else{
        }
        
        
    }
    
    
    func mDelete(count:Int){
        
        if(count == 1){
            mPinTwo.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            mPinThree.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            mPinFour.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            mPinFive.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            mPinSix.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        }else if(count == 2){
            mPinThree.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            mPinFour.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            mPinFive.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            mPinSix.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            
        }else if(count == 3){
            mPinFour.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            mPinFive.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            mPinSix.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        }else if(count == 4){
            mPinFive.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            mPinSix.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        }else if(count == 5){
            mPinSix.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        }else if(count == 0){
            mPinOne.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            mPinTwo.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            mPinThree.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            mPinFour.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            mPinFive.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            mPinSix.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            
        }
        
    }
    
    func decodeJWT(_ jwt: String) -> [String: Any]? {

        let segments = jwt.components(separatedBy: ".")

        guard segments.count > 1 else {
            return nil
        }

        var base64 = segments[1]

        base64 = base64
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        while base64.count % 4 != 0 {
            base64 += "="
        }

        guard let data = Data(base64Encoded: base64),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }

        return json
    }
    
    func mLoginWithPin(){
        
        let urlPath = mLoginUserWithPin
        guard let mUserName =  UserDefaults.standard.string(forKey: "email"),
              let organizationId = UserDefaults.standard.string(forKey: "organization_id"),
              let mUdid = UserDefaults.standard.string(forKey: "mobileUDID"),
              let mAuthToken = UserDefaults.standard.string(forKey: "token") else {
            CommonClass.showSnackBar(message: "Login with username and password at least once.")
            return
        }
        
        var params:[String:String] = ["username" : mUserName ,"authToken" :mAuthToken]
        
        if mFaceDetected {
            params["mobileUDID"] = mUdid
            params["pin"] = "false"
            mFaceDetected = false
        }else{
            params["pin"] = mPin
        }
        
        if Reachability.isConnectedToNetwork() == true {
            CommonClass.showFullLoader(view: self.view)
            AF.request(urlPath, method:.post, parameters: params).responseJSON
            { response in
                
                print("mLoginWithPin \(response)")
                if(response.error != nil){
                    CommonClass.stopLoader()
                    
                }else{
                    guard let jsonData = response.data else {
                        CommonClass.showSnackBar(message: "OOP's something went wrong!")
                        return
                    }
                    
                    let json = try? JSONSerialization.jsonObject(with: jsonData, options: [])
                    
                    guard let jsonResult = json as? NSDictionary else{
                        CommonClass.showSnackBar(message: "OOP's something went wrong!")
                        return
                    }
                    
                    if jsonResult.value(forKey: "code") as? Int == 200 {
                        
                        if let mData = jsonResult.value(forKey: "data") as? NSDictionary {
                            let mToken = "\(mData.value(forKey: "login_token") ?? "")"
                            UserDefaults.standard.set(mToken, forKey: "token")
                            //------------------------------------------------------
                            // Save website_url from JWT
                            //------------------------------------------------------

                            if let payload = self.decodeJWT(mToken),
                               let admin = payload["admin"] as? [String: Any],
                               let domain = admin["domain"] as? String {
                                
                                let website = domain
                                    .replacingOccurrences(of: "https://", with: "")
                                    .replacingOccurrences(of: "http://", with: "")
                                    .trimmingCharacters(in: CharacterSet(charactersIn: "/"))
                                
                                UserDefaults.standard.set(website, forKey: "website_url")
                                
                                print("website_url =", website)
                            }
                            //------------------------------------------------------
                            self.mGeneratePOSToken()
                        }
                    } else  if jsonResult.value(forKey: "code") as? Int == 400 {
                        CommonClass.stopLoader()
                        self.mPin = ""
                        self.mDelete(count: 0)
                        Animations.requireUserAtencion(on: self.mPinOne)
                        Animations.requireUserAtencion(on: self.mPinTwo)
                        Animations.requireUserAtencion(on: self.mPinThree)
                        Animations.requireUserAtencion(on: self.mPinFour)
                        Animations.requireUserAtencion(on: self.mPinFive)
                        Animations.requireUserAtencion(on: self.mPinSix)
                        
                        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                        
                        CommonClass.showSnackBar(message: "\(jsonResult.value(forKey: "message") ?? "")")
                        
                    }else if jsonResult.value(forKey: "code") as? Int == 403 {
                        CommonClass.stopLoader()
                        CommonClass.showSnackBar(message: "Session Expired!! Please Re-login.")
                        self.navigationController?.popViewController(animated: true)
                    }else{
                        CommonClass.stopLoader()
                        CommonClass.showSnackBar(message: "Something went wrong!")
                    }
                    
                }
                
            }
        }else {
            CommonClass.stopLoader()
            CommonClass.showSnackBar(message: "No Internet Connection!")
        }
        
        
    }
    
    
    func mGeneratePOSToken(){
        let mCurrency = UserDefaults.standard.string(forKey: "posCurrency") ?? ""
        let mLocationId = UserDefaults.standard.string(forKey: "posLocation") ?? ""
        let mVoucherId  = UserDefaults.standard.string(forKey: "posVoucher") ?? ""
        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        
        guard let bundleShortVersionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
              let bundleVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        else { return }
        guard let loginToken = mUserLoginToken else {
            CommonClass.showSnackBar(message: "OOP's something went wrong!")
            return
        }
        
        let sGenPosHeader:HTTPHeaders = [
            "Authorization": loginToken,
            "agent" : "\(bundleShortVersionString).\(bundleVersion)",
            "platform" : mGetDeviceInfo(),
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        let urlPath = mPOSAuthToken
        
        let params:[String:String] = ["currency" : mCurrency , "voucher_id":mVoucherId, "location_id":mLocationId ]
        
        if Reachability.isConnectedToNetwork() == true {
            AF.request(urlPath, method:.post, parameters: params,headers: sGenPosHeader).responseJSON
            { response in
                CommonClass.stopLoader()
                print("mGeneratePOSToken \(response)")
                if(response.error != nil){
                    
                    CommonClass.showSnackBar(message: "OOP's something went wrong!")
                    
                }else{
                    guard let jsonData = response.data else {
                        CommonClass.showSnackBar(message: "OOP's something went wrong!")
                        return
                    }
                    
                    let json = try? JSONSerialization.jsonObject(with: jsonData, options: [])
                    
                    guard let jsonResult = json as? NSDictionary else{
                        CommonClass.showSnackBar(message: "OOP's something went wrong!")
                        return
                    }
                    if jsonResult.value(forKey: "code") as? Int == 200 {
                        
                        if jsonResult.value(forKey: "data") != nil {
                            if let mData = jsonResult.value(forKey: "data") as? NSDictionary {
                                
                                UserDefaults.standard.setValue("\(mData.value(forKey: "token") ?? "")", forKey: "token_pos")
                                mSESSION = ""
                                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                if let mLanguageController = storyBoard.instantiateViewController(withIdentifier: "LanguageController") as? LanguageController {
                                    self.navigationController?.pushViewController(mLanguageController, animated:true)
                                }
                            }
                        }
                        
                    } else if jsonResult.value(forKey: "code") as? Int == 400 {
                        
                        CommonClass.showSnackBar(message: "Failed to Authenticate!")
                    } else if jsonResult.value(forKey: "code") as? Int == 403 {
                        CommonClass.showSnackBar(message: "Session Expired!! Please Re-login.")
                        self.navigationController?.popViewController(animated: true)
                    } else {
                        CommonClass.showSnackBar(message: "OOP's something went wrong!")
                    }
                    
                }
                
                
            }
        }else{
            CommonClass.showSnackBar(message: "No Internet Connection!")
        }
        
        
    }
    
}
//
//
//extension ViewController {
//    @available(iOS 12.0, *)
//    public var intent: BackNavigateIntent {
//        let testIntent = FaceLoginIntent()
//        testIntent.suggestedInvocationPhrase = "Test"
//        return testIntent
//    }
//}
