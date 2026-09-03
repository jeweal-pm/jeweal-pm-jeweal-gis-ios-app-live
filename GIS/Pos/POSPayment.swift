//
//  POSPayment.swift
//  GIS
//
//  Created by Apple Hawkscode on 25/03/21.
//

import UIKit
import Alamofire

class POSPayment: UIViewController {
    
    var mStoreCurrency = ""
    var mStoreSymbol = ""
    
    @IBOutlet weak var mPaymentLABEL: UILabel!
    @IBOutlet weak var mDepostiLABEL: UILabel!
    @IBOutlet weak var mGiftCardLABEL: UILabel!
    
    
    override func viewWillAppear(_ animated: Bool) {
        mPaymentLABEL.text = "Payment".localizedString
        mDepostiLABEL.text = "Deposit".localizedString
        mGiftCardLABEL.text = "Gift Card".localizedString
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

     
    }
    
    override func viewDidAppear(_ animated: Bool) {
        mFetchStore(key: "")
    }

   
    @IBAction func mDeposit(_ sender: Any) {
    
        if mStoreCurrency != "" {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            if let mCheckOut = storyBoard.instantiateViewController(withIdentifier: "DepositPayment") as? DepositPayment {
                mCheckOut.mStoreCurrency =  self.mStoreCurrency
                mCheckOut.mOrderType = "Deposit"
                self.navigationController?.pushViewController( mCheckOut, animated:true)
            }
        }
    }
    
    @IBAction func mCoupon(_ sender: Any) {
        if mStoreSymbol != "" {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            if let mPOSCoupons = storyBoard.instantiateViewController(withIdentifier: "POSCoupons") as? POSCoupons {
                mPOSCoupons.mCCouponCurrency = mStoreSymbol
                self.navigationController?.pushViewController(mPOSCoupons, animated:true)
            }
        }else{
            CommonClass.showSnackBar(message: "Please wait...")
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
                        
                        if let mUserData = jsonResult.value(forKey: "user_datail") as? NSDictionary {
                            
                            if let pin = mUserData.value(forKey: "pin") {
                                UserDefaults.standard.setValue("\(pin)", forKey: "TRANSACTIONPIN")
                            }else{
                                UserDefaults.standard.setValue("9543", forKey: "TRANSACTIONPIN")
                            }
                            
                        }else{
                            UserDefaults.standard.setValue("9543", forKey: "TRANSACTIONPIN")
                        }
                        if let payMethod = jsonResult.value(forKey: "Payment_method") {
                            UserDefaults.standard.setValue(payMethod, forKey: "PAYMENTMETHODID")
                        }
                        if let mSettings = jsonResult.value(forKey: "generalSetting") as? NSDictionary {
                            
                            if let userEnterPinForEverySale = mSettings.value(forKey: "userEnter_PIN_forEverySale") {
                                
                                if "\(userEnterPinForEverySale)" == "1" {
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
                            
                            self.mStoreSymbol = "\(mLocationData.value(forKey: "currencySymbol") ?? "")"
                            UserDefaults.standard.setValue("\(mLocationData.value(forKey: "currencySymbol") ?? "")", forKey: "currencySymbol")
                            if mLocationData.value(forKey: "currency") != nil {
                                self.mStoreCurrency = "\(mLocationData.value(forKey: "currency") ?? "")"
                                UserDefaults.standard.setValue("\(mLocationData.value(forKey: "currency") ?? "")", forKey: "currency")
   
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
}
