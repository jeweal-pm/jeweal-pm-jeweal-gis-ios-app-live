//
//  PosProfileInfo.swift
//  GIS
//
//  Created by Apple Hawkscode on 07/04/21.
//

import UIKit
import Alamofire
import DropDown

class SalesPersonReports : UITableViewCell {
    
    @IBOutlet weak var mMonth: UILabel!
    @IBOutlet weak var mAmount: UILabel!
    @IBOutlet weak var mQuantity: UILabel!
}

class POSProfileInfo: UIViewController , UITableViewDelegate,UITableViewDataSource{

    @IBOutlet weak var mSalesPersonName: UILabel!
    var mSalesManList = [String]()
    var mSalesManIDList = [String]()
    var mCustomerId = ""
    var mSalesPersonId = ""
    
    @IBOutlet weak var mSalesPersonStack: UIStackView!
    @IBOutlet weak var mCustomerStackView: UIStackView!
    
    
    @IBOutlet weak var mSalesTabLine: UIView!
    
    @IBOutlet weak var mSalesButton: UIButton!
    
    @IBOutlet weak var mCustomerTabLine: UIView!
    
    @IBOutlet weak var mCustomerButton: UIButton!
    
    @IBOutlet weak var mUserName: UILabel!
    
    @IBOutlet weak var mDateTime: UILabel!
    
    var mReportData = NSArray()
    
    @IBOutlet weak var mSalesPersonReport: UITableView!

    @IBOutlet weak var mSalePersonLABEL: UILabel!
    @IBOutlet weak var mMonthLABEL: UILabel!
    @IBOutlet weak var mQtyLABEL: UILabel!
    @IBOutlet weak var mAmountLABEL: UILabel!
    
    @IBOutlet weak var mCProfileLABEL: UILabel!
    @IBOutlet weak var CPaymentLABEL: UILabel!
    @IBOutlet weak var mCPurchaseHistoryLABEL: UILabel!
    @IBOutlet weak var mCWishListLABEL: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        mSalePersonLABEL.text  = "Sale Person".localizedString
        mMonthLABEL.text = "Month".localizedString
        mQtyLABEL.text = "Qty".localizedString
        mAmountLABEL.text = "Amount".localizedString
        mCProfileLABEL.text = "Profile".localizedString
        mCPurchaseHistoryLABEL.text = "Purchase History".localizedString
        mCWishListLABEL.text = "Wishlist".localizedString
        CPaymentLABEL.text = "Payment".localizedString
        mSalesButton.setTitle("Sale Person".localizedString, for: .normal)
        mCustomerButton.setTitle("Customer".localizedString, for: .normal)

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.applyGradient(withColours: [#colorLiteral(red: 0.7725490196, green: 0.9019607843, blue: 0.8745098039, alpha: 1),#colorLiteral(red: 0.9207345247, green: 0.9503677487, blue: 0.978346765, alpha: 1)], gradientOrientation: .vertical)
        mUserName.text = UserDefaults.standard.string(forKey: "userName")!
        let currentDateTime = Date()

        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .medium
    
        mDateTime.text =  formatter.string(from: currentDateTime)
        mSalesButton.setTitleColor(#colorLiteral(red: 0, green: 0.5215686275, blue: 0.8588235294, alpha: 1), for: .normal)
        mSalesTabLine.backgroundColor = #colorLiteral(red: 0, green: 0.5215686275, blue: 0.8588235294, alpha: 1)
        mSalesPersonStack.isHidden =  false
        
        mCustomerButton.setTitleColor(.darkText, for: .normal)
        mCustomerTabLine.backgroundColor = .clear
        
        mCustomerStackView.isHidden = true
        mGetSalesPerson()
    }
    

    
    
    
    
    
    
    
    
    @IBAction func mGotohome(_ sender: Any) {
        if let home = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomePage") as? HomePage {
            navigationController?.pushViewController(home, animated: true)
        }
    }
    
    @IBAction func mShowPurchase(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let mProfile = storyBoard.instantiateViewController(withIdentifier: "CustomerSearch") as? CustomerSearch {
            self.navigationController?.pushViewController(mProfile, animated:true)
        }
    }
    @IBAction func mShowPayment(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let mProfile = storyBoard.instantiateViewController(withIdentifier: "CustomerSearch") as? CustomerSearch {
            self.navigationController?.pushViewController(mProfile, animated:true)
        }
    }
    @IBAction func mLogOut(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let home = storyBoard.instantiateViewController(withIdentifier: "HomePage") as? HomePage {
            tabBarController?.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(home, animated:true)
        }
    }
    
    @IBAction func mSettings(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let home = storyBoard.instantiateViewController(withIdentifier: "HomePage") as? HomePage {
            tabBarController?.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(home, animated:true)
        }
    }
    
    @IBAction func mWishList(_ sender: Any) {
    
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let mProfile = storyBoard.instantiateViewController(withIdentifier: "WishListController") as? WishListController {
            self.navigationController?.pushViewController(mProfile, animated:true)
        }
    }
    
    
    @IBAction func mSalesPerson(_ sender: Any) {
        
        
        
        mSalesButton.setTitleColor(#colorLiteral(red: 0, green: 0.5215686275, blue: 0.8588235294, alpha: 1), for: .normal)
        mSalesTabLine.backgroundColor = #colorLiteral(red: 0, green: 0.5215686275, blue: 0.8588235294, alpha: 1)
        mSalesPersonStack.isHidden =  false
        
        mCustomerButton.setTitleColor(.darkText, for: .normal)
        mCustomerTabLine.backgroundColor = .clear
        
        mCustomerStackView.isHidden = true
        
    }
    
    @IBAction func mCustomerPerson(_ sender: Any) {
        
        mCustomerButton.setTitleColor(#colorLiteral(red: 0, green: 0.5215686275, blue: 0.8588235294, alpha: 1), for: .normal)
        mCustomerTabLine.backgroundColor = #colorLiteral(red: 0, green: 0.5215686275, blue: 0.8588235294, alpha: 1)
        mCustomerStackView.isHidden =  false
        
    
        
        mSalesButton.setTitleColor(.darkText, for: .normal)
        mSalesTabLine.backgroundColor = .clear
        
        mSalesPersonStack.isHidden = true
        
       
    }
    @IBAction func mProfile(_ sender: Any) {
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let mProfile = storyBoard.instantiateViewController(withIdentifier: "CustomerSearch") as? CustomerSearch {
            tabBarController?.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(mProfile, animated:true)
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
       
        return mReportData.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false

        var cell  = UITableViewCell()
        
        if tableView == mSalesPersonReport {
            guard let cells = tableView.dequeueReusableCell(withIdentifier: "SalesPersonReports") as? SalesPersonReports,
                  let mData = mReportData[indexPath.row] as? NSDictionary else {
                return UITableViewCell()
            }
            cells.mMonth.text = "\(mData.value(forKey: "month") ?? "")"
            cells.mQuantity.text = "\(mData.value(forKey: "total_qty") ?? "")"
            cells.mAmount.text = "\(mData.value(forKey: "total_amount") ?? "")"
            cell = cells
           
        }
       
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 35
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        
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
                self.mGetSalePersonReports()
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
                    
                    
                    if let data = jsonResult.value(forKey: "Salesperson") as? NSArray {
                        for i in data {
                            if let salesData = i as? NSDictionary {
                                var name = ""
                                if let fName = salesData.value(forKey:"name") as? String {
                                    name = fName
                                    if let lName = salesData.value(forKey:"lname") as? String {
                                        name = "\(fName) \(lName)"
                                    }
                                }
                                self.mSalesManList.append(name)
                                if let id = salesData.value(forKey:"id") {
                                    self.mSalesManIDList.append("\(id)")
                                }
                                self.mSalesPersonName.text = self.mSalesManList[0]
                                self.mSalesPersonId =  self.mSalesManIDList[0]
                                self.mGetSalePersonReports()
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
        }else{
            CommonClass.showSnackBar(message: "No Internet Connection")
        }
        
        
    }
    func mGetSalePersonReports(){
        
        
        let mLocation = UserDefaults.standard.string(forKey: "location") ?? ""
        
        let urlPath =  mGetSalesReports
        let params = ["salesPerson_id":mSalesPersonId,"POS_Location_id":mLocation]
        
        if Reachability.isConnectedToNetwork() == true {
            AF.request(urlPath, method:.post,parameters: params, headers: sGisHeaders2).responseJSON
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
                        
                        
                        if let data = jsonResult.value(forKey: "salesPerson_transaction") as? NSArray {
                            
                            if data.count > 0 {
                                self.mReportData = data
                                self.mSalesPersonReport.delegate = self
                                self.mSalesPersonReport.dataSource = self
                                self.mSalesPersonReport.reloadData()
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
}
