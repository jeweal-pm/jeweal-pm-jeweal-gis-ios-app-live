//
//  POSAllCoupons.swift
//  GIS
//
//  Created by Apple Hawkscode on 21/09/21.
//

import UIKit
import SwiftUI
import Alamofire



class MyCouponList : UITableViewCell {
    
    @IBOutlet weak var mRemarks: UILabel!
    @IBOutlet weak var mQRCode: UIImageView!
    @IBOutlet weak var mDate: UILabel!
    @IBOutlet weak var mCouponCode: UILabel!
    @IBOutlet weak var mCodeLABEL: UILabel!
    @IBOutlet weak var mColorView: UIView!
    @IBOutlet weak var mCouponAmount: UILabel!
    
    @IBOutlet weak var mRemoveCoupon: UIButton!
    @IBOutlet weak var mBarCode: UIImageView!
    
}
class POSAllCoupons: UIViewController , UITableViewDelegate , UITableViewDataSource, GetCustomerDataDelegate, UIViewControllerTransitioningDelegate, DeleteCustomCartItems {
    
    
    
    @IBOutlet weak var mCustomerName: UILabel!
    @IBOutlet weak var mCustomerImage: UIImageView!
    @IBOutlet weak var mSelectedCustomerIcon: UIImageView!
    
    @IBOutlet weak var mTotalItems: UILabel!
    @IBOutlet weak var mCustomerSearch: UITextField!
    let mCustomerSearchTableView = UITableView()
    @IBOutlet weak var mCustomerSearchView: UIView!
    @IBOutlet weak var mCustomerDetailView: UIView!
    @IBOutlet weak var mCustomerAddresss: UILabel!
    @IBOutlet weak var mCustomerNumbers: UILabel!
    
    
    var mCustomerId = ""
    
    
    
    @IBOutlet weak var mTotalBUTTON: UILabel!
    
    @IBOutlet weak var mTotalAmount: UILabel!
    var mCouponData = NSArray()
    var mCouponTotal = ""
    
    var mCouponCurrencyAmount = ""
    var mCurrency = ""
    var mStoreCurrency = ""
    @IBOutlet weak var mCouponTable: UITableView!
    
    @IBOutlet weak var mAddGiftCardLABEL: UILabel!
    @IBOutlet weak var mCheckOutBUTTON: UIButton!
    @IBOutlet weak var mGrandTotalLABEL: UILabel!
    @IBOutlet weak var mCustomerLABEL: UILabel!
    @IBOutlet weak var mHeadingLABEL: UILabel!
    
    
    override func viewWillAppear(_ animated: Bool) {
        mCustomerLABEL.text = "Customer".localizedString
        
        mAddGiftCardLABEL.text = "Gift Card".localizedString
        mGrandTotalLABEL.text = "Grand Total".localizedString
        mHeadingLABEL.text = "Gift Card".localizedString
        
        mCheckOutBUTTON.setTitle("CHECK OUT".localizedString , for: .normal)
        
        mCustomerId  = UserDefaults.standard.string( forKey: "DEFAULTCUSTOMER") ?? ""
        
        if mCustomerId == "" {
            mOpenCustomerSheet()
        }else{
            self.mSelectedCustomerIcon.image = UIImage(named: "selected_customer")
            self.mCustomerImage.contentMode = .scaleAspectFill
            self.mCustomerImage.downlaodImageFromUrl(urlString: UserDefaults.standard.string( forKey: "DEFAULTCUSTOMERPICTURE") ?? "")
            self.mCustomerName.text = UserDefaults.standard.string( forKey: "DEFAULTCUSTOMERNAME") ?? ""
            self.mCustomerName.isHidden = false
            
            mGetCoupons(value: mCustomerId)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.mTotalAmount.text =  "00.00"
        mCouponTable.delegate = self
        mCouponTable.dataSource = self
    }
    
    @IBAction func mChooseCustomer(_ sender: Any) {
        mOpenCustomerSheet()
    }
    func mCreateNewCustomer() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "reserveBoard", bundle: nil)
        if let mCreateCustomer = storyBoard.instantiateViewController(withIdentifier: "CreateCustomer") as? CreateCustomer {
            self.navigationController?.pushViewController(mCreateCustomer, animated:true)
        }
    }
    func mGetCustomerData(data: NSMutableDictionary) {
        
        if let id = data.value(forKey: "id") as? String {
            UserDefaults.standard.set(id, forKey: "DEFAULTCUSTOMER")
            self.mCustomerId = id
        }
        
        let profile = data.value(forKey: "profile") as? String ?? ""
        UserDefaults.standard.set(profile, forKey: "DEFAULTCUSTOMERPICTURE")
        
        if let name = data.value(forKey: "name") as? String {
            UserDefaults.standard.set(name, forKey: "DEFAULTCUSTOMERNAME")
            self.mCustomerName.isHidden = false
            self.mCustomerName.text = name
        } else {
            self.mCustomerName.isHidden = true
        }
        
        if let profileUrl = data.value(forKey: "profile") as? String {
            self.mCustomerImage.downlaodImageFromUrl(urlString: profileUrl)
        }
        
        self.mSelectedCustomerIcon.image = UIImage(named: "selected_customer")
        self.mCustomerImage.contentMode = .scaleAspectFill
    }
    
    func mOpenCustomerSheet(){
        let storyBoard: UIStoryboard = UIStoryboard(name: "common", bundle: nil)
        if let home = storyBoard.instantiateViewController(withIdentifier: "CustomerPicker") as? CustomerPicker {
            home.delegate = self
            home.modalPresentationStyle = .automatic
            home.transitioningDelegate = self
            self.present(home,animated: true)
        }
    }
    @IBAction func mCheckOut(_ sender: UIButton) {
        sender.showAnimation{
            if Double(self.mCouponTotal) ?? 0.00 == 0.0 {
                CommonClass.showSnackBar(message: "Please fill valid amount!")
                return
            }
            
            print("POSAllCoupons mQuotationId:")
            
            let storyBoard: UIStoryboard = UIStoryboard(name: "customOrder", bundle: nil)
            if let mCheckOut = storyBoard.instantiateViewController(withIdentifier: "CustomOrderCheckout") as? CustomOrderCheckout {
                mCheckOut.mTotalP = self.mCouponTotal
                mCheckOut.mSubTotalP = ""
                mCheckOut.mTaxP = ""
                mCheckOut.mTaxAm = ""
                mCheckOut.mStoreCurrency =  self.mStoreCurrency
                mCheckOut.mOrderType = "gift_card_order"
                
                mCheckOut.mTaxType =  ""
                mCheckOut.mTaxLabel =  ""
                
                mCheckOut.mCurrencySymbol = self.mCurrency
                mCheckOut.mCartTotalAmount = self.mCouponTotal
                mCheckOut.mDepositPercents = "100"
                mCheckOut.mTaxPercent =  ""
                mCheckOut.mCustomerId = self.mCustomerId
                mCheckOut.mCartTableData =  NSMutableArray(array: self.mCouponData)
                self.navigationController?.pushViewController( mCheckOut, animated:true)
            }
        }
        
    }
    @IBAction func mBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return mCouponData.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        
        var cell =  UITableViewCell()
        
        if tableView == mCouponTable {
            guard let cells = tableView.dequeueReusableCell(withIdentifier: "MyCouponList") as? MyCouponList,
                  let mData = mCouponData[indexPath.row] as? NSDictionary else {
                return cell
            }
            
            cells.mCodeLABEL.text = "\(mData.value(forKey: "name") ?? "")"
            cells.mCouponCode.text = "\(mData.value(forKey: "card_no") ?? "")"
            cells.mCouponAmount.text =  self.mCurrency + "\(mData.value(forKey: "amount") ?? "0.0")"
            cells.mDate.text = "\(mData.value(forKey: "expire_date") ?? "")"
            cells.mRemarks.text = "\(mData.value(forKey: "remark") ?? "")"
            cells.mQRCode.downlaodImageFromUrl(urlString: "\(mData.value(forKey: "qr_code") ?? "")")
            cells.mBarCode.downlaodImageFromUrl(urlString: "\(mData.value(forKey: "barcode") ?? "")")
            
            cells.mRemoveCoupon.tag = indexPath.row
            
            cell = cells
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var height = CGFloat()
        if tableView == mCouponTable {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "MyCouponList") as? MyCouponList {
                height = 200
            }
        }
        
        return height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let mData = mCouponData[indexPath.row] as? NSDictionary {
            UserDefaults.standard.set(mData, forKey: "EDITCARD")
        }
        let storyBoard: UIStoryboard = UIStoryboard(name: "moreBoard", bundle: nil)
        if let mCoupons = storyBoard.instantiateViewController(withIdentifier: "POSCoupons") as? POSCoupons {
            mCoupons.isEdit = "1"
            self.navigationController?.pushViewController(mCoupons, animated:true)
        }
    }
    
    @IBAction func mEditCoupon(_ sender: UIButton) {
        
        
        
    }
    
    func mDeleteCartItems(index: Int) {
        if let mData = mCouponData[index] as? NSDictionary {
            self.mRemoveProducts(id:"\(mData.value(forKey: "custom_cart_id") ?? "")")
        }
    }
    
    @IBAction func mRemoveCoupon(_ sender: UIButton) {
        if let mData = mCouponData[sender.tag] as? NSDictionary {
            mRemovePopUp.frame = self.view.bounds
            mRemovePopUp.mCustomerId = mCustomerId
            mRemovePopUp.delegate = self
            mRemovePopUp.index = sender.tag
            mRemovePopUp.mType = "giftCard"
            mRemovePopUp.mCartId = mData.value(forKey: "custom_cart_id") as? String ?? ""
            mRemovePopUp.mMessage.text = "Are you sure want to remove ?".localizedString
            mRemovePopUp.mCancelButton.setTitle("CANCEL".localizedString, for: .normal)
            mRemovePopUp.mConfirmButton.setTitle("CONFIRM".localizedString, for: .normal)
            self.view.addSubview(mRemovePopUp)
        }
    }
    
    func mRemoveProducts(id:String){
        let urlPath =  mDeleteCoupons
        let params = ["custom_cart_id": id]
        
        if Reachability.isConnectedToNetwork() == true {
            AF.request(urlPath, method:.post, parameters:params, headers: sGisHeaders2).responseJSON
            { [self] response in
                
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
                        
                        self.mGetCoupons(value: mCustomerId)
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
    
    func mGetCoupons(value: String){
        
        let mParams = [ "customer_id":mCustomerId] as [String : Any]
        
        mGetData(url: mFetchCoupons, headers: sGisHeaders ,params: mParams ) { response , status in
            CommonClass.stopLoader()
            if status {
                self.mCouponData = NSArray()
                if let mData = response.value(forKey: "data") as? NSArray {
                    
                    if mData.count > 0 {
                        self.mCouponData =  mData
                        
                        self.mCouponTable.delegate = self
                        self.mCouponTable.dataSource = self
                        self.mCouponTable.reloadData()
                        self.mTotalItems.text = "\(mData.count) " + "Items".localizedString
                        self.mCurrency = "\(response.value(forKey: "currency") ?? "")"
                        self.mStoreCurrency = "\(response.value(forKey: "currency_name") ?? "")"
                        self.mTotalAmount.text =  "\(response.value(forKey: "currency") ?? "")" + "\(response.value(forKey: "total") ?? "0.0")".formatPrice()
                        self.mCouponTotal =  "\(response.value(forKey: "total") ?? "0.0")"
                    }else{
                        self.mTotalItems.text = "0 " + "Item".localizedString
                        self.mTotalAmount.text =  "0.0"
                        self.mCouponTotal = "0.0"
                        self.mCouponTable.reloadData()
                    }


                }else{
                    self.mTotalItems.text = "0 " + "Item".localizedString
                    self.mTotalAmount.text =  "0.0"
                    self.mCouponTotal = "0.0"
                    self.mCouponTable.reloadData()
                }
            }
        }

    }

    @IBAction func mAddNewCoupon(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "moreBoard", bundle: nil)
        if let mCoupons = storyBoard.instantiateViewController(withIdentifier: "POSCoupons") as? POSCoupons {
            mCoupons.mCustomerId = self.mCustomerId
            self.navigationController?.pushViewController(mCoupons, animated:true)
        }
    }

}

extension Color {
    static var random: Color {
        return Color(red: .random(in: 0...1),green: .random(in: 0...1),blue: .random(in: 0...1))
    }
}
