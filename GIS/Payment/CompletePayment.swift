//
//  CompletePayment.swift
//  GIS
//
//  Created by Apple Hawkscode on 17/12/20.
//

import UIKit
import Alamofire

class EmailPopUp: UIView {
    var mType = ""
    @IBOutlet weak var mEmailConfirmationLABEL: UILabel!
    var mOrderId = ""
    
    @IBOutlet weak var mPleaseConfrimLABEL: UILabel!
    @IBOutlet weak var mConfirmButton: UIButton!
    @IBOutlet weak var mEmail: UITextField!
    
    
    var mNavigation = UINavigationController()
    static func instantiate(message: String) -> EmailPopUp {
        let view: EmailPopUp = initFromNib()
        return view
    }

    @IBAction func mClose(_ sender: Any) {
        self.removeFromSuperview()

    }
    
    @IBAction func mConfirm(_ sender: Any) {

        self.removeFromSuperview()

        if mEmail.text == "" {
            CommonClass.showSnackBar(message: "Please fill email!")
        }else if !CommonClass.isValidEmail(emailString: mEmail.text ?? "") {
            CommonClass.showSnackBar(message: "Please fill valid email!")
        }else{
            mEmailUser(mail: mEmail.text ?? "", orderId: mOrderId)

        }
        
       
    }
    func mEmailUser(mail : String , orderId : String ){
        
        
        CommonClass.showFullLoader(view: self)
        
        
        let urlPath =  mEmailReport
        let params = ["email":mail ,"id":orderId ]
        if Reachability.isConnectedToNetwork() == true {
            AF.request(urlPath, method:.post, parameters: params, headers: sGisHeaders2).responseJSON
            { response in
                
                CommonClass.stopLoader()
                
                if(response.error != nil){
                    
                    
                }else{
                    guard let jsonData = response.data else {
                        return
                    }
                    
                    let json = try? JSONSerialization.jsonObject(with: jsonData, options: [])
                    
                    guard let jsonResult = json as? NSDictionary else {
                        return
                    }
                    if jsonResult.value(forKey: "code") as? Int == 200 {
                        
                        
                        CommonClass.showSnackBar(message: "Email has been sent successfully!")
                        
                    }else{
                        if let error = jsonResult.value(forKey: "error") as? String {
                            if error == "Authorization has been expired" {
                                
                            }
                        }

                    }

                }


            }
        }else{
            CommonClass.showSnackBar(message: "Something went wrong!")
        }

    }


    
    
}
class CompletePayment: UIViewController {

    
    @IBOutlet weak var mCompleteLABEL: UILabel!
    @IBOutlet weak var mGoBackBUTTON: UIButton!
    
    
    
    @IBOutlet weak var mTotalItems: UILabel!
    @IBOutlet weak var mTotalOutStanding: UILabel!
    @IBOutlet weak var mTotalDeposit: UILabel!
    @IBOutlet weak var mGrandTotal: UILabel!
    
    @IBOutlet weak var mDepositePercent: UILabel!
    
    
    
    @IBOutlet weak var mOutstandingLABEL: UILabel!
    @IBOutlet weak var mGrandTotalLABEL: UILabel!
    @IBOutlet weak var mOrderSummaryLABEL: UILabel!
    @IBOutlet weak var mOrderSuccessfulLABEL: UILabel!
    @IBOutlet weak var mOutStandingView: UIStackView!

    @IBOutlet weak var mDepositView: UIStackView!
    var mTotal = ""
    var mDue = ""
    var mType = ""
    var mEmailId = ""
    var mOrderId = ""
    var mCurrency = "$"
    var mTotalQuantity = "1"
    var mTotalOutstandingBal = "0.00"
    var mDepositPercents = "100"
    var mDepositAmount = "0.00"
    var mGrandTotalAmount = "0.00"
    var mUrl = ""
    
    var mShippingInfo: [String: Any] = [:]
    
    @IBOutlet weak var mGoBackButton: UIButton!
    
    private func getPdfOrderType() -> String {

        let type = mType
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        switch type {

        case "exchange", "exchange_order":
            return "exchange_order"

        case "refund", "refund_order":
            return "refund_order"

        case "deposit", "deposit_order":
            return "deposit"
            
        case "gift card", "gift_card", "gift_card_order":
            return "gift_card_order"

        case "custom order", "custom_order":
            return "custom_order"

        case "pos", "pos order", "pos_order":
            return "pos_order"

        case "reserve", "reserve_order":
            return "reserve"

        default:
            return type
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mTotalOutStanding.text =  mCurrency + " " + mTotalOutstandingBal.formatPrice()
        mTotalDeposit.text =  mCurrency + " " + mDepositAmount.formatPrice()
        mDepositePercent.text = "Received".localizedString
        mGoBackBUTTON.setTitle("BACK TO POS".localizedString, for: .normal)
        mOutstandingLABEL.text = "Outstanding Balance".localizedString
        mGrandTotalLABEL.text = "Grand Total".localizedString
        mOrderSummaryLABEL.text = "Order Summary".localizedString
        mOrderSuccessfulLABEL.text = "Order Successful".localizedString
         if mType == "exchange_order" || mType == "refund_order" || mType == "deposit" {
            mDepositView.isHidden = true
            mOutStandingView.isHidden = true
        }
        mGrandTotal.text = mCurrency + " " + mGrandTotalAmount.formatPrice()
        if mTotalQuantity != "1"  {
            mTotalItems.text = "\(mTotalQuantity) " + "Item".localizedString
            
        }else{
            mTotalItems.text = "\(mTotalQuantity) " + "Items".localizedString
            
        }
        
        if mType == "Deposit" {
            
        }else if mType == "Refund" {
           
        }else if mType == "Exchange" {
            
        }else if mType == "Gift Card" {
            
        }else{

        }
       
    }
    
    
//    func mGenerateOrderPdf() {
//
//        CommonClass.showFullLoader(view: self.view)
//
//        
//        var params: [String: Any] = [
//
//            "order_id": mOrderId,
//
//            "order_type": mType
//        ]
//        
//        if !mShippingInfo.isEmpty {
//            params["shipping_info"] = mShippingInfo
//        }
//        
//
//        print("DEBUG_PDF_PARAMS =", params)
//
//        AF.request(
//            mGetOrderPdf,
//            method: .post,
//            parameters: params,
//            encoding: JSONEncoding.default,
//            headers: sGisHeaders2
//        )
//        .responseJSON { response in
//
//            CommonClass.stopLoader()
//
//            guard let data = response.data else {
//
//                CommonClass.showSnackBar(
//                    message: "Unable to generate PDF"
//                )
//
//                return
//            }
//
//            guard let json =
//                try? JSONSerialization.jsonObject(
//                    with: data
//                ) as? NSDictionary
//            else {
//
//                CommonClass.showSnackBar(
//                    message: "Invalid response"
//                )
//
//                return
//            }
//
//            print("DEBUG_PDF_RESPONSE =", json)
//
////            if "\(json["code"] ?? "")" == "200" {
////
////                let pdfUrl =
////                "\(json["pdf_url"] ?? "")"
////
////                if let url = URL(string: pdfUrl) {
////
////                    UIApplication.shared.open(url)
////                }
////
////            } else {
////
////                CommonClass.showSnackBar(
////                    message: "\(json["message"] ?? "Unable to generate PDF")"
////                )
////            }
//            if "\(json["code"] ?? "")" == "200" {
//
//                guard let data = json["data"] as? NSDictionary else {
//                    print("PDF ERROR: data not found")
//                    return
//                }
//
//                let pdfUrl = "\(data["url"] ?? "")"
//
//                print("DEBUG PDF URL =", pdfUrl)
//
//                guard let url = URL(string: pdfUrl),
//                      !pdfUrl.isEmpty else {
//
//                    print("PDF ERROR: Invalid URL =", pdfUrl)
//                    return
//                }
//
//                print("OPENING PDF =", url)
//
//                DispatchQueue.main.async {
//                    UIApplication.shared.open(
//                        url,
//                        options: [:],
//                        completionHandler: { success in
//                            print("PDF OPEN SUCCESS =", success)
//                        }
//                    )
//                }
//
//            } else {
//
//                CommonClass.showSnackBar(
//                    message: "\(json["message"] ?? "Unable to generate PDF")"
//                )
//            }
//        }
//    }
    
    func mGenerateOrderPdf() {

        let orderType = getPdfOrderType()

        print("========== PDF ORDER DEBUG ==========")
        print("RAW mType =", mType)
        print("MAPPED ORDER TYPE =", orderType)
        print("ORDER ID =", mOrderId)
        print("=====================================")

        guard !mOrderId.isEmpty else {
            print("❌ PDF ERROR: ORDER ID IS EMPTY")
            CommonClass.showSnackBar(message: "Order ID is missing")
            return
        }

        CommonClass.showFullLoader(view: self.view)

        var params: [String: Any] = [
            "order_id": mOrderId,
            "order_type": orderType
        ]

        if !mShippingInfo.isEmpty {
            params["shipping_info"] = mShippingInfo
        }

        print("DEBUG_PDF_PARAMS =", params)

        AF.request(
            mGetOrderPdf,
            method: .post,
            parameters: params,
            encoding: JSONEncoding.default,
            headers: sGisHeaders2
        )
        .responseJSON { response in

            CommonClass.stopLoader()

            guard let data = response.data else {
                CommonClass.showSnackBar(
                    message: "Unable to generate PDF"
                )
                return
            }

            guard let json =
                    try? JSONSerialization.jsonObject(
                        with: data
                    ) as? NSDictionary
            else {
                CommonClass.showSnackBar(
                    message: "Invalid response"
                )
                return
            }

            print("DEBUG_PDF_RESPONSE =", json)

            if "\(json["code"] ?? "")" == "200" {

                guard let data = json["data"] as? NSDictionary else {
                    print("PDF ERROR: data not found")
                    return
                }

                let pdfUrl = "\(data["url"] ?? "")"

                print("DEBUG PDF URL =", pdfUrl)

                guard let url = URL(string: pdfUrl),
                      !pdfUrl.isEmpty else {

                    print("PDF ERROR: Invalid URL =", pdfUrl)
                    return
                }

                DispatchQueue.main.async {

                    UIApplication.shared.open(
                        url,
                        options: [:],
                        completionHandler: { success in
                            print("PDF OPEN SUCCESS =", success)
                        }
                    )
                }

            } else {

                CommonClass.showSnackBar(
                    message: "\(json["message"] ?? "Unable to generate PDF")"
                )
            }
        }
    }
    
    @IBAction func mPrint(_ sender: Any) {
        
//         if mUrl != "" {
//            if let url = URL(string: mUrl) {
//                UIApplication.shared.open(url)
//            }
//        }
        mGenerateOrderPdf()
       
    }
    
    @IBAction func mEmail(_ sender: Any) {
    
        if let mEmailPopUp = UINib(nibName:"emailpopup",bundle:.main).instantiate(withOwner: nil, options: nil).first as? EmailPopUp {
            
            mEmailPopUp.frame = self.view.bounds
            mEmailPopUp.mOrderId = mOrderId
            mEmailPopUp.mEmail.text = mEmailId
            mEmailPopUp.mEmailConfirmationLABEL.text = "Email Confirmation".localizedString
            mEmailPopUp.mPleaseConfrimLABEL.text = "Please confirm your email address where invoice to be sent".localizedString
            mEmailPopUp.mEmail.placeholder = "example: name@mail.com"
            mEmailPopUp.mConfirmButton.setTitle("Confirm".localizedString, for: .normal)
            self.view.addSubview(mEmailPopUp)
            
        }
        
    }
    
    @IBAction func mShare(_ sender: Any) {
         if mUrl != "" {
            let items = [mUrl]
            let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
            present(ac, animated: true)
        }
      
    }
    
    @IBAction func mGoBack(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "reserveBoard", bundle: nil)
        if let home = storyBoard.instantiateViewController(withIdentifier: "HomePage1") as? HomePage {
            self.navigationController?.pushViewController(home, animated:true)
        }
    }
    
//    func mEmailUser(type: String ){
//
//        let mLocation = UserDefaults.standard.string(forKey: "location") ?? ""
//        let urlInvoice = UserDefaults.standard.string(forKey: "reportAPI")
//        if urlInvoice != nil {
//            mUrl = urlInvoice!
//        }
//   
//        let urlPath =  mEmailReport
//        let params = ["location": mLocation, "type":type, "printUrl":mUrl]
//        if Reachability.isConnectedToNetwork() == true {
//            AF.request(urlPath, method:.post, parameters: params, headers: sGisHeaders2).responseJSON
//            { response in
//
//                if(response.error != nil){
//
//
//                }else{
//                    guard let jsonData = response.data else {
//                        return
//                    }
//                    
//                    let json = try? JSONSerialization.jsonObject(with: jsonData, options: [])
//                    
//                    guard let jsonResult = json as? NSDictionary else {
//                        return
//                    }
//                    if jsonResult.value(forKey: "code") as? Int == 200 {
//                        
//                        CommonClass.showSnackBar(message: "Email has been sent successfully!")
//                        
//                    }else{
//                        if let error = jsonResult.value(forKey: "error") {
//                            if "\(error)" == "Authorization has been expired" {
//                                CommonClass.sessionExpired(isExpired: true, navigation: self.navigationController)
//                            }
//                        }
//
//                    }
//
//                }
//
//            }
//        }else{
//            CommonClass.showSnackBar(message: "No Internet Connection")
//        }
//
//    }


}
