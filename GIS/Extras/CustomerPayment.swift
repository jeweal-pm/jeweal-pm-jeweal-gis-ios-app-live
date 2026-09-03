//
//  CustomerPurchaseHistory.swift
//  GIS
//
//  Created by Apple Hawkscode on 09/02/22.
//

import UIKit
import Alamofire
import DropDown


class CustomerPayment: UIViewController , UITableViewDelegate,UITableViewDataSource{
    
    @IBOutlet weak var mHeader: UILabel!
    
    var mCustomerId = ""
    var mType = ""
    
    var mCustomerData = NSArray()
    
    @IBOutlet weak var mPaymentTable: UITableView!
    @IBOutlet weak var mLocationLABEL: UILabel!
    
    
    @IBOutlet weak var mDateLABEL: UILabel!
    @IBOutlet weak var mInvoiceLABEL: UILabel!
    @IBOutlet weak var mQtyLABEL: UILabel!
    @IBOutlet weak var mAmountLABEL: UILabel!
    
    
    override func viewWillAppear(_ animated: Bool) {
        mInvoiceLABEL.text = "Invoice".localizedString
        mLocationLABEL.text = "Location".localizedString
        mDateLABEL.text = "Date".localizedString
        mQtyLABEL.text = "Qty".localizedString
        mAmountLABEL.text = "Amount".localizedString
        mGetCustomerData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
        
        self.view.applyGradient(withColours: [#colorLiteral(red: 0.7725490196, green: 0.9019607843, blue: 0.8745098039, alpha: 1),#colorLiteral(red: 0.9207345247, green: 0.9503677487, blue: 0.978346765, alpha: 1)], gradientOrientation: .vertical)
        
    }
    
    
    
    
    
    
    
    
    
    
    @IBAction func mGotohome(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
        
        
    }
    
    
    
    
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return mCustomerData.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        
        var cell  = UITableViewCell()
        
        if tableView == mPaymentTable {
            guard let cells = tableView.dequeueReusableCell(withIdentifier: "CustomerPurchaseHistoryCell") as? CommonTransleCell,
                  let mData = mCustomerData[indexPath.row] as? NSDictionary else {
                return cell
            }
 
            cell = cells
            
        }
        

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 61
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {}
    
    func mGetCustomerData(){
        
        let urlPath =  mGetCustomerPaymentAndHistory
        let params = ["customerId":mCustomerId,"type":"payment"]
        
        if Reachability.isConnectedToNetwork() == true {
            AF.request(urlPath, method:.post,parameters: params, headers: sGisHeaders2).responseJSON
            { response in
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
                    
                    if let data = jsonResult.value(forKey: "data") as? NSArray {
                        
                        if data.count > 0 {
                            self.mCustomerData = data
                            self.mPaymentTable.delegate = self
                            self.mPaymentTable.dataSource = self
                            self.mPaymentTable.reloadData()
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
        }else{
            CommonClass.showSnackBar(message: "No Internet Connection")
        }
        
        
    }
}
