//
//  POSMain.swift
//  GIS
//
//  Created by Apple Hawkscode on 25/03/21.
//

import UIKit
import Alamofire
import DropDown

class POSProductCell: UITableViewCell {
    
    
    @IBOutlet weak var mProductPrice: UILabel!
    @IBOutlet weak var mQuantity: UILabel!
    @IBOutlet weak var mSKUName: UILabel!
    
    @IBOutlet weak var mProductImage: UIImageView!
    @IBOutlet weak var mStockId: UILabel!
    @IBOutlet weak var mDiscountPrice: UITextField!
    @IBOutlet weak var mDiscountPercent: UITextField!
    @IBOutlet weak var mQuantityUnit: UILabel!
    @IBOutlet weak var mView: UIView!
    
    @IBOutlet weak var mSNView: UIView!
    
    @IBOutlet weak var mImageHolderView: UIView!
    @IBOutlet weak var mStockView: UIView!
    @IBOutlet weak var mQtyView: UIView!
    
    @IBOutlet weak var mAmountView: UIView!
    
    @IBOutlet weak var mSNo: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
   
    }
 

    
}
class POSMain: UIViewController ,UITableViewDelegate , UITableViewDataSource {
    /**Store Details*/
    
    @IBOutlet weak var mStoreName: UILabel!
    @IBOutlet weak var mOrganizationName: UILabel!
    
    
    @IBOutlet weak var mStoreAddress: UILabel!
    
    @IBOutlet weak var mStoreImage: UIImageView!
    @IBOutlet weak var mStoreContact: UILabel!
    @IBOutlet weak var mStoreCopyRight: UILabel!
    
    var mTaxType = ""
    var mTaxLabel = ""
    var mTaxPercent = ""
    var mStoreCurrency = ""
    var mTotalWithDiscount = ""
    
    
    
    
    @IBOutlet weak var mDropDownImage: UIImageView!
    @IBOutlet weak var mCheckoutButton: UIButton!
    
    
    @IBOutlet weak var mCurrency: UILabel!
    @IBOutlet weak var mGrandTotal: UILabel!
    @IBOutlet weak var mTotalQuantity: UILabel!
    @IBOutlet weak var mTotalPrice: UILabel!
    @IBOutlet weak var mCheckoutView: UIView!
    @IBOutlet weak var mPOSProductTableView: UITableView!
  
    @IBOutlet weak var mShowTaxButton: UIButton!
    @IBOutlet weak var mTaxView: UIView!
    
    @IBOutlet weak var mTotalTx: UILabel!
    
    @IBOutlet weak var mTotalDiscountTx: UILabel!
    
    @IBOutlet weak var mSubTotalTx: UILabel!
    
    @IBOutlet weak var mTaxAmountTx: UILabel!
    @IBOutlet weak var mTaxValueTx: UILabel!
    
    @IBOutlet weak var mExchangeTx: UILabel!
    
    
    var mAmountData = NSMutableArray()
    var mCartData = NSArray()
    var mCartTableData = NSMutableArray()
    
    /**Customer Search*/
    @IBOutlet weak var mCustomerSelectView: UIView!
    
    @IBOutlet weak var mSalesPersonName: UILabel!
    var mSalesManList = [String]()
    var mSalesManIDList = [String]()
    var mCustomerId = ""
    var mSalesPersonId = ""
    @IBOutlet weak var mCustomerSearch: UITextField!
    var mSearchCustomerData = NSArray()
    @IBOutlet weak var mCustomerSearchTableView: UITableView!

    @IBOutlet weak var mCustomerSearchView: UIView!
    @IBOutlet weak var mCustomerDetailView: UIView!
    @IBOutlet weak var mCustomerNames: UILabel!
    @IBOutlet weak var mCustomerAddresss: UILabel!
    @IBOutlet weak var mCustomerNumbers: UILabel!
    
    @IBOutlet weak var mPOSHeaderLABEL: UILabel!
    @IBOutlet weak var mSearchField: UITextField!
    @IBOutlet weak var mInvoiceLABEL: UILabel!
    @IBOutlet weak var mSNoLABEL: UILabel!
    @IBOutlet weak var mStockIdLABEL: UILabel!
    @IBOutlet weak var mSKULABEL: UILabel!
    @IBOutlet weak var mQtyLABEL: UILabel!
    @IBOutlet weak var mUnitLABEL: UILabel!
    @IBOutlet weak var mDisPLABEL: UILabel!
    @IBOutlet weak var mDiscountLABEL: UILabel!
    @IBOutlet weak var mAmountLABEL: UILabel!
    @IBOutlet weak var mTTotalLABEL: UILabel!
    @IBOutlet weak var mTDiscountLABEL: UILabel!
    @IBOutlet weak var mTSubTotalLABEL: UILabel!
    @IBOutlet weak var mTExchangeLABEL: UILabel!
    @IBOutlet weak var mSalePersonLABEL: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        mSalePersonLABEL.text = "Sale Person".localizedString
        mCustomerSearch.text = "Customer Search".localizedString
        mPOSHeaderLABEL.text = "POS".localizedString
        mSearchField.placeholder = "Search".localizedString
        mInvoiceLABEL.text = "Invoice".localizedString
        mSNoLABEL.text = "SNo".localizedString
        mStockIdLABEL.text = "Stock Id".localizedString
        mSKULABEL.text = "SKU".localizedString
        mQtyLABEL.text = "Qty".localizedString
        mUnitLABEL.text = "Unit".localizedString
        mDisPLABEL.text = "Dis%".localizedString
        mDiscountLABEL.text = "Discount".localizedString
        mTExchangeLABEL.text = "Exchange".localizedString
        mAmountLABEL.text = "Amount".localizedString
        mTTotalLABEL.text = "Total".localizedString
        mTDiscountLABEL.text = "Discount".localizedString
        mTSubTotalLABEL.text = "Sub Total".localizedString
        mTExchangeLABEL.text = "Exchange".localizedString
        mCheckoutButton.setTitle("CHECK OUT", for: .normal)
        mAmountData = NSMutableArray()
        mCartData = NSArray()
        
        mFetchProducts()
        
        if UserDefaults.standard.string(forKey: "CUSTOMERID") == nil {
            UserDefaults.standard.set("", forKey: "CUSTOMERID")
        }
        
        if  UserDefaults.standard.string(forKey: "SALESPERSONID") == nil {
            UserDefaults.standard.set("", forKey: "SALESPERSONID")
        }
        
        if let mData =  UserDefaults.standard.object(forKey: "CustomerData") as? NSDictionary {
            
            if let customerID = mData.value(forKey: "Customer_id") as? String {
                mCustomerId = customerID
                UserDefaults.standard.set(mCustomerId, forKey: "CUSTOMERID")
            }
            
            if let fname = mData.value(forKey: "fname") {
                self.mCustomerNames.text = "\(fname)"
            }
            if let lname = mData.value(forKey: "lname") {
                self.mCustomerNames.text?.append(" \(lname)")
                UserDefaults.standard.set(self.mCustomerNames.text, forKey: "CUSTOMERNAME")
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
           
            self.mCustomerSearchView.isHidden = true
            self.mCustomerDetailView.isHidden = false
            self.mCustomerSearch.text = ""
            
        }
        
        mGetSalesPerson()
        
    }

    var openFromHome = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.mStoreCopyRight.text = ""
      
        let tap =  UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false
        mTaxView.layer.cornerRadius = 10
        mTaxView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        
        self.mPOSProductTableView.delegate = self
        self.mPOSProductTableView.dataSource = self

    }
    
    override func viewDidLayoutSubviews() {
        mCheckoutView.applyGradient(withColours: [#colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1),#colorLiteral(red: 0.01176470588, green: 0.2862745098, blue: 0.5568627451, alpha: 1)], gradientOrientation: .horizontal)
        self.view.applyGradient(withColours: [#colorLiteral(red: 0.7725490196, green: 0.9019607843, blue: 0.8745098039, alpha: 1),#colorLiteral(red: 0.9207345247, green: 0.9503677487, blue: 0.978346765, alpha: 1)], gradientOrientation: .vertical)
    }
    
    override func viewDidAppear(_ animated: Bool) {
       
    }
    
    @IBAction func mOpenMoreOption(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let home = storyBoard.instantiateViewController(withIdentifier: "HomePage") as? HomePage {
            self.tabBarController?.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(home, animated:true)
        }
    }
    
    @IBAction func mCheckout(_ sender: Any) {
        
        if mCartData.count > 0 {
            if UserDefaults.standard.string(forKey: "CUSTOMERID") != "" {
                mTotalWithDiscount = mTotalPrice.text ?? "0.0"
                mCartTableData = NSMutableArray()
                
                var mData = NSDictionary()
                for data in 0...mCartData.count - 1 {
                    let mIndexPath = IndexPath(row:data,section: 0)
                    if let mCData = mCartData[data] as? NSDictionary {
                        if let data = mCData.value(forKey: "product_details") as? NSDictionary {
                            mData = data
                        }
                    }
                    if let cell = self.mPOSProductTableView.cellForRow(at: mIndexPath) as? POSProductCell {
                        let mProductData = NSMutableDictionary()
                        mProductData.setValue("\(mData.value(forKey: "product_id") ?? "")", forKey: "Cartproduct_id")
                        mProductData.setValue("\(mData.value(forKey: "id") ?? "")", forKey: "Cart_tbl_id")
                        mProductData.setValue("\(mData.value(forKey: "retailprice") ?? "")", forKey: "ProductmainpriceAmountRow")
                        mProductData.setValue(cell.mDiscountPercent.text ?? "", forKey: "Posdiscount_percent")
                        mProductData.setValue(cell.mDiscountPrice.text ?? "", forKey: "Posdiscount_Amounts")
                        mProductData.setValue("1", forKey: "Qty")
                        mProductData.setValue("", forKey: "Deliverdate")

                        mCartTableData.insert(mProductData, at:data)
                    }
        
                }
                
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                if let mCheckOut = storyBoard.instantiateViewController(withIdentifier: "CheckOutPage") as? CheckOutPage {
                    mCheckOut.mTotalP = self.mTotalTx.text ?? ""
                    mCheckOut.mFTOTAL = self.mGrandTotal.text ?? ""
                    mCheckOut.mSubTotalP = self.mSubTotalTx.text ?? ""
                    mCheckOut.mTaxP = self.mTaxPercent
                    mCheckOut.mTaxAm = self.mTaxAmountTx.text ?? ""
                    mCheckOut.mStoreCurrency =  self.mStoreCurrency
                    mCheckOut.mOrderType = "Sales Order"
                    mCheckOut.mTaxType =  self.mTaxType
                    mCheckOut.mTaxLabel =  self.mTaxLabel
                    mCheckOut.mTotalWithDiscount =  self.mTotalWithDiscount
                    mCheckOut.mTaxPercent =  self.mTaxPercent
                    mCheckOut.mCartTableData =  self.mCartTableData
                    self.navigationController?.pushViewController( mCheckOut, animated:true)
                }
            }else {
                self.mCustomerSelectView.isHidden = false
                self.mCustomerSearch.text = ""
            }
        }else{
            CommonClass.showSnackBar(message: "Please add product!")
        }
    }
    
    @IBAction func mSearchProduct(_ sender: Any) {
        if UserDefaults.standard.string(forKey: "CUSTOMERID") == "" {
            CommonClass.showSnackBar(message: "Please choose Customer and Sales Person.")
            self.mCustomerSelectView.isHidden = false
            self.mCustomerSearch.text = ""
        }else{
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            if let home = storyBoard.instantiateViewController(withIdentifier: "CustomOrderSearch") as? CustomOrderSearch {
                home.mType = "Inventory"
                home.mCustomerId = mCustomerId
                self.navigationController?.pushViewController(home, animated:true)
            }
        }
    
    }
    
    @IBAction func mAddCustomers(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let home = storyBoard.instantiateViewController(withIdentifier: "RegisterCustomer") as? RegisterCustomer {
            self.navigationController?.pushViewController(home, animated:true)
        }
    }
    
    @IBAction func mProfileInfo(_ sender: Any) {
        self.mCustomerSearch.text = ""
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let mProfInfo = storyBoard.instantiateViewController(withIdentifier: "POSProfileInfo") as? POSProfileInfo {
            self.navigationController?.pushViewController(mProfInfo, animated:true)
        }
    }
    
    @IBAction func mAddNewCustomer(_ sender: Any) {
        self.mCustomerSelectView.isHidden = false
        self.mCustomerSearch.text = ""
       
    }
    @IBAction func mEditCustomer(_ sender: Any) {
        mCustomerSearch.text = ""
        mCustomerDetailView.isHidden = true
        self.mCustomerSearchView.isHidden = false

    }
    @IBAction func mEditChanged(_ sender: Any) {
       
        let value = mCustomerSearch.text?.count ?? 0
        if value != 0 {
            self.mSearchCustomerByKeys(value: mCustomerSearch.text ?? "")
        }else {
            if mCustomerSearch.text  == "" {
           
            }
            self.view.endEditing(true)
        }
    }
    
    @IBAction func mHideSearchView(_ sender: Any) {
        mCustomerSearch.text = ""
        self.mCustomerSelectView.isHidden = true
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
            
                self.mCustomerSelectView.isHidden = false
                self.mCustomerSearch.text = ""
                self.mSalesPersonId =  self.mSalesManIDList[index]
                UserDefaults.standard.set(self.mSalesPersonId , forKey: "SALESPERSONID")
                   }
               dropdown.show()
    }
    
    @IBAction func mShowProfileInfo(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let mProfInfo = storyBoard.instantiateViewController(withIdentifier: "POSProfileInfo") as? POSProfileInfo {
            self.navigationController?.pushViewController(mProfInfo, animated:true)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var mCount = 0
        
        if tableView == mCustomerSearchTableView{
           mCount = mSearchCustomerData.count
        } else if tableView == mPOSProductTableView {
            mCount = mCartData.count
        }
        return mCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        
        var cellss =  UITableViewCell()
        if tableView == mCustomerSearchTableView {
            
            guard let cells = tableView.dequeueReusableCell(withIdentifier: "CustomerSearchItem") as? CustomerSearchItem else {
                return cellss
            }
        
            if let mData = mSearchCustomerData[indexPath.row] as? NSDictionary {
                
                if let fname = mData.value(forKey: "fname") as? String {
                    cells.mCustomerName.text = fname
                }
                
                if let lname = mData.value(forKey: "lname") as? String {
                    cells.mCustomerName.text?.append(" \(lname)")
                }
                
                if let phoneCode = mData.value(forKey: "phone_code") {
                    cells.mPhone.text = "+\(phoneCode)"
                }
                
                if let phone = mData.value(forKey: "phone") as? String {
                    cells.mPhone.text?.append(" \(phone)")
                }
                
                if let stateCountry = mData.value(forKey: "stateCountry") {
                    cells.mPlace.text = (" \(stateCountry)")
                }
            }
            
            cellss = cells
            
        } else  if tableView == mPOSProductTableView {

            guard let cell = tableView.dequeueReusableCell(withIdentifier: "POSProductCell") as? POSProductCell else {
                return cellss
            }
            
            cell.mSNView.backgroundColor = (indexPath.row % 2 == 0) ? #colorLiteral(red: 0.9568627451, green: 0.9725490196, blue: 0.9843137255, alpha: 1) : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            cell.mImageHolderView.backgroundColor = (indexPath.row % 2 == 0) ? #colorLiteral(red: 0.9568627451, green: 0.9725490196, blue: 0.9843137255, alpha: 1) : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            cell.mStockView.backgroundColor = (indexPath.row % 2 == 0) ? #colorLiteral(red: 0.9568627451, green: 0.9725490196, blue: 0.9843137255, alpha: 1) : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            cell.mQtyView.backgroundColor = (indexPath.row % 2 == 0) ? #colorLiteral(red: 0.9568627451, green: 0.9725490196, blue: 0.9843137255, alpha: 1) : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            cell.mAmountView.backgroundColor = (indexPath.row % 2 == 0) ? #colorLiteral(red: 0.9568627451, green: 0.9725490196, blue: 0.9843137255, alpha: 1) : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            
            if let mData1 = mCartData[indexPath.row] as? NSDictionary {
                
                if let mData = mData1.value(forKey: "product_details") as? NSDictionary {
                    cell.mDiscountPercent.text = "0"
                    cell.mDiscountPrice.text = "0"
                    
                    cell.mSNo.text = "\(indexPath.row + 1)"
                    if let image = mData.value(forKey: "main_image") {
                        cell.mProductImage.downlaodImageFromUrl(urlString: "\(image)")
                    }
                    
                    if let sku = mData.value(forKey: "SKU") {
                        cell.mSKUName.text = "\(sku)"
                    }
                    if let stockid = mData.value(forKey: "stock_id") {
                        cell.mStockId.text = "\(stockid)"
                    }
                    
                    if let retailPrice = mData.value(forKey: "retailprice") {
                        cell.mProductPrice.text = "\(retailPrice)"
                    }
                    
                }
            }
            
            cell.mDiscountPrice.tag = indexPath.row
            cell.mDiscountPercent.tag = indexPath.row
            cellss = cell
        }
        
        return cellss
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView ==  mCustomerSearchTableView {
            return 78
        }
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "POSProductCell") as? POSProductCell {
            return cell.mView.frame.height + 2
        }
        
        return UITableView.automaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == mCustomerSearchTableView {
            
            guard let mData =  mSearchCustomerData[indexPath.row] as? NSDictionary else {
                return
            }
            
            if let cusID = mData.value(forKey: "Customer_id") {
                UserDefaults.standard.setValue(mData, forKey: "CustomerData")
                mCustomerId = "\(cusID)"
                
                if mCustomerId != UserDefaults.standard.string( forKey: "CUSTOMERID") ?? "" {
                    UserDefaults.standard.set(mCustomerId, forKey: "CUSTOMERID")
                }else{
                    UserDefaults.standard.set(mCustomerId, forKey: "CUSTOMERID")
                }
            }
            
            if let fname = mData.value(forKey: "fname") {
                self.mCustomerNames.text = "\(fname)"
            }
            
            if let lname = mData.value(forKey: "lname") {
                self.mCustomerNames.text?.append(" \(lname)")
                UserDefaults.standard.set(self.mCustomerNames.text, forKey: "CUSTOMERNAME")
            }
            
            if let phoneCode = mData.value(forKey: "phone_code") {
                self.mCustomerNumbers.text = "+\(phoneCode)"
            }
            
            if let phone = mData.value(forKey: "phone") {
                self.mCustomerNumbers.text?.append(" \(phone)")
            }
            
            if let stateCountry = mData.value(forKey: "stateCountry") {
                self.mCustomerAddresss.text = (" \(stateCountry)")
            }
            
            self.mCustomerSearchView.isHidden = true
            self.mCustomerDetailView.isHidden = false
            self.mCustomerSearch.text = ""
            self.mCustomerSelectView.isHidden = true
            
            
        }else{
            
        }
    }
    
    func mClearCart(){
        
        print("🔥 POSMain.swift mClearCart called")
        _ = UserDefaults.standard.string(forKey: "location")
        
        let urlPath =  mClearDataApi
        
        if Reachability.isConnectedToNetwork() == true {
            AF.request(urlPath, method:.post, headers: sGisHeaders2).responseJSON
            { response in
                
                if response.response?.statusCode == 403 {
                    CommonClass.sessionExpired(isExpired: true, navigation: self.navigationController)
                }
                
                if(response.error != nil){
                    
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
        }

    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if tableView == mCustomerSearchTableView {

            mCustomerSearchTableView.isEditing = false
        }else{
            if editingStyle == .delete {

                if let mData1 = mCartData[indexPath.row] as? NSDictionary,
                   let mData = mData1.value(forKey: "product_details") as? NSDictionary,
                   let id = mData.value(forKey: "id"){
                    mRemoveProducts(id:"\(id)")
                }
            }
            
        }
    }
    
    @IBAction func mShowTaxDetails(_ sender: UIButton) {
        mTaxView.isHidden = !mTaxView.isHidden
        
        if mTaxView.isHidden {
            mDropDownImage.image = UIImage(systemName: "chevron.right")
        }else{
            mDropDownImage.image = UIImage(systemName: "chevron.up")
           
        }

    }
    
    @IBAction func mDiscountPercentValue(_ sender: UITextField!) {
        let mIndexPath = IndexPath(row:sender.tag,section: 0)
        var mCount = Int()
        
        if sender.text == "" {
            mCount = 0
            sender.placeholder = "0.00"
        }else{
            mCount = Int(Double(sender.text ?? "") ?? 0.0)
            if sender.text == "" || sender.text == "0"  || mCount > 100 {
                if let cell = self.mPOSProductTableView.cellForRow(at: mIndexPath) as? POSProductCell {
                    
                    cell.mDiscountPercent.text = "0"
                    cell.mDiscountPrice.text = "0"
                    if let mData1 = mCartData[sender.tag] as? NSDictionary {
                        if mData1.value(forKey: "product_details") != nil {
                            if let mData = mData1.value(forKey: "product_details") as? NSDictionary,
                               let retailprice = mData.value(forKey: "retailprice") {
                                cell.mProductPrice.text = "\(retailprice)"
                                calculateTotalAmount(value: Double("\(retailprice)".replacingOccurrences(of: ",", with: "")) ?? 0.0, index: sender.tag)
                            }
                        }
                    }
                }
            }else {
                if let mData1 = mCartData[sender.tag] as? NSDictionary,
                   let mData = mData1.value(forKey: "product_details") as? NSDictionary {
                    
                    let mAmount = Double("\(mData.value(forKey: "retailprice") ?? "")".replacingOccurrences(of: ",", with: "")) ?? 0.0
                    
                    let mDiscountPrice = "\(calculatePercentage(value: mAmount, percent: Double(sender.text ?? "") ?? 0.0))"
                    if let cell = self.mPOSProductTableView.cellForRow(at: mIndexPath) as? POSProductCell {
                        
                        let val = String(format:"%.02f",locale:Locale.current, Double(mAmount - (Double(mDiscountPrice) ?? 0.0) ))
                        
                        cell.mDiscountPrice.text = "\(mDiscountPrice)"
                        cell.mProductPrice.text = "\(val)"
                        
                        calculateTotalAmount(value:  Double(mAmount - (Double(mDiscountPrice) ?? 0.0)), index: sender.tag)
                    }
                    
                    
                }
            }
        }

    }
    
    func calculateTotalAmount(value:Double,index:Int){
        var mAmount = [Double]()
        let mData = NSMutableDictionary()
        mData.setValue("\(value)", forKey: "retailprice")
       
        mAmountData.removeObject(at: index)
        mAmountData.insert(mData, at: index)
        for i in mAmountData {
            
            if let mRetailPrice = i as? NSDictionary,
                let retailPrice = mRetailPrice.value(forKey: "retailprice") {
                mAmount.append(Double("\(retailPrice)".replacingOccurrences(of: ",", with: "")) ?? 0.0)
            }
            
        }

     
        mTotalPrice.text = String(format:"%.02f",locale:Locale.current,mAmount.reduce(0, {$0 + $1}))
        
        mTotalTx.text = mTotalPrice.text
       
        if mTaxType.lowercased() == "inclusive" {
            mTaxAmountTx.text = String(format:"%.02f",locale:Locale.current,calculateInclusiveTax(value: Double((mTotalTx.text ?? "").replacingOccurrences(of: ",", with: "")) ?? 0.0, percent: Double(mTaxPercent) ?? 0.0))
            mSubTotalTx.text =  String(format:"%.02f",locale:Locale.current,Double((mTotalTx.text ?? "").replacingOccurrences(of: ",", with: "")) ?? 0.0 - calculateInclusiveTax(value: Double((mTotalTx.text ?? "").replacingOccurrences(of: ",", with: "")) ?? 0.0, percent: Double(mTaxPercent) ?? 0.0))
           
            mGrandTotal.text = String(format:"%.02f",locale:Locale.current,mAmount.reduce(0, {$0 + $1}))

        }else{
            mTaxAmountTx.text =   String(format:"%.02f",locale:Locale.current,calculateExclusiveTax(value: Double((mTotalTx.text ?? "").replacingOccurrences(of: ",", with: "")) ?? 0.0, percent: Double(mTaxPercent) ?? 0.0))
            mSubTotalTx.text =  String(format:"%.02f",locale:Locale.current,Double((mTotalTx.text ?? "").replacingOccurrences(of: ",", with: "")) ?? 0.0)
            
            let val = (mTotalPrice.text ?? "").replacingOccurrences(of: ",", with: "")
            let taxAmountTxDouble = Double((mTaxAmountTx.text ?? "").replacingOccurrences(of: ",", with: "")) ?? 0.0
            
            mGrandTotal.text = String(format:"%.02f",locale:Locale.current,Double(val) ?? 0.0 + taxAmountTxDouble)

        }
        


    }
    
    func calculatePercentage(value:Double,percent: Double) -> Double {
        let val = value * percent
        return val/100.00
    }
    
    func calculateInclusiveTax(value:Double,percent: Double) -> Double {
            let val = value * percent
            return val/(100.00 + (Double(mTaxPercent) ?? 0))
    }
    
    func calculateExclusiveTax(value:Double,percent: Double) -> Double {
        let val = value * percent
        return val/100.00
    }
    
    @IBAction func mDiscountPriceValue(_ sender: UITextField!) {
        
        if sender.text == "" {
            sender.placeholder = "0.00"
        }else{
            let mIndexPath = IndexPath(row:sender.tag,section: 0)
            var mCount = Int()
            if let cell = self.mPOSProductTableView.cellForRow(at: mIndexPath) as? POSProductCell {
                if let discountPercent = cell.mDiscountPercent.text, !discountPercent.isEmpty {
                    mCount = Int(Double(discountPercent) ?? 0)
                }else{
                    mCount = 0
                }
                
            }
            if sender.text == "" || sender.text == "0" || mCount > 100 {
                if let cell = self.mPOSProductTableView.cellForRow(at: mIndexPath) as? POSProductCell {
                    cell.mDiscountPercent.text = "0"
                    cell.mDiscountPrice.text = "0"
                    if let mData1 = mCartData[sender.tag] as? NSDictionary {
                        if let mData = mData1.value(forKey: "product_details") as? NSDictionary {
                            cell.mProductPrice.text = "\(mData.value(forKey: "retailprice") ?? "00.0")"
                            let productPriceDouble = Double((cell.mProductPrice.text ?? "").replacingOccurrences(of: ",", with: "")) ?? 0.0
                            calculateTotalAmount(value: productPriceDouble, index: sender.tag)
                        }
                    }
                }
            } else {
                if let mData1 = mCartData[sender.tag] as? NSDictionary {
                    if let  mData = mData1.value(forKey: "product_details") as? NSDictionary {
                        
                        if let cell = self.mPOSProductTableView.cellForRow(at: mIndexPath) as? POSProductCell {
                            
                            let mValue = Double("\(mData.value(forKey: "retailprice") ?? "")".replacingOccurrences(of: ",", with: "")) ?? 0
                            let mAmount = mValue - (Double(sender.text ?? "") ?? 0)
                            
                            let mPercent = (Double(sender.text ?? "") ?? 0) / mValue * 100
                            
                            cell.mDiscountPercent.text = String(format: "%.2f", mPercent)
                            let val = String(format:"%.02f",locale:Locale.current,mAmount)
                            cell.mProductPrice.text = "\(val)"
                            
                            calculateTotalAmount(value: mAmount, index: sender.tag)
                        }
                        
                    }
                }
            }
        }
        
    }
    
    func mFetchStore(key: String){
        
        let mLocation = UserDefaults.standard.string(forKey: "location") ?? ""
        
        
        let urlPath =  mFetchStoreData
        let params = ["login_token": mUserLoginToken ?? "", "location_id":mLocation ]
        
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

                        if let mSettings = jsonResult.value(forKey: "generalSetting") as? NSDictionary {
                            
                            if let posPartialPayment = mSettings.value(forKey: "POS_partial_payment") {
                                if "\(posPartialPayment)" == "1" {
                                    UserDefaults.standard.setValue("1", forKey: "isPartialPayment")
                                }else{
                                    UserDefaults.standard.setValue("0", forKey: "isPartialPayment")
                                }
                            }else{
                                UserDefaults.standard.setValue("0", forKey: "isPartialPayment")
                                
                            }
                            
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
                            UserDefaults.standard.setValue("0", forKey: "isPartialPayment")
                            UserDefaults.standard.setValue("0", forKey: "isPinEnable")
                        }
                        
                        var mCityStateCountry = ""
                        if let mLocationData = jsonResult.value(forKey: "location_data") as? NSDictionary {
                            
                            if let currency = mLocationData.value(forKey: "currency") {
                                self.mStoreCurrency = "\(currency)"
                            }
                            
                            if let name = mLocationData.value(forKey: "name") {
                                self.mStoreName.text =  "\(name)"
                            }
                            if let phone = mLocationData.value(forKey: "phone") {
                                self.mStoreContact.text = "\(phone)"
                            }
                            if let address = mLocationData.value(forKey: "address"){
                                self.mOrganizationName.text = "\(address)"
                            }
                            
                            if let city = mLocationData.value(forKey: "city") {
                                mCityStateCountry.append("\(city), ")
                            }
                            if let state = mLocationData.value(forKey: "state") {
                                mCityStateCountry.append("\(state), ")
                            }
                            
                            if let zipcode = mLocationData.value(forKey: "zipcode") {
                                mCityStateCountry.append("\(zipcode). ")
                            }
                            if let country = mLocationData.value(forKey: "country") {
                                mCityStateCountry.append("\(country)")
                            }
                            
                            if let logo = mLocationData.value(forKey: "location_logo") {
                                self.mStoreImage.downlaodImageFromUrl(urlString: "\(logo)")
                            }
                            if let copyRights = jsonResult.value(forKey: "copyRight") {
                                self.mStoreCopyRight.text = "\(copyRights)"
                                self.mStoreAddress.text = mCityStateCountry
                            }
                            
                            
                        }
                        
                        if let payMethod = jsonResult.value(forKey: "Payment_method") {
                            UserDefaults.standard.setValue(payMethod, forKey: "PAYMENTMETHODID")
                        }
                        
                        if let mTaxData = jsonResult.value(forKey: "tax") as? NSDictionary {
                            
                            self.mTaxValueTx.text = "Tax (\("\(mTaxData.value(forKey: "rate") ?? "0")")%)"
                            
                            self.mTaxPercent = "\(mTaxData.value(forKey: "rate")  ?? "0")"
                            self.mTaxType = "\(mTaxData.value(forKey: "type") ?? "0")"
                            self.mTaxLabel = "\(mTaxData.value(forKey: "label") ?? "0")"
                            if key != "" {
                                
                                if self.mTaxType.lowercased() == "inclusive" {
                                    let totalPrice = self.mTotalPrice.text ?? ""
                                    let totalPriceDouble = Double(totalPrice.replacingOccurrences(of: ",", with: "")) ?? 0
                                    
                                    self.mTaxAmountTx.text = String(format:"%.02f",locale:Locale.current,self.calculateInclusiveTax(value: totalPriceDouble, percent: Double(self.mTaxPercent) ?? 0))

                                    self.mSubTotalTx.text =  String(format:"%.02f",locale:Locale.current,totalPriceDouble - self.calculateInclusiveTax(value: totalPriceDouble, percent: Double(self.mTaxPercent) ?? 0))
                                    
                                    self.mTotalTx.text = self.mTotalPrice.text
                                }else{
                                    
                                    self.mTotalTx.text = self.mTotalPrice.text
                                    
                                    let totalTax = self.mTotalTx.text ?? ""
                                    let totalTaxDouble = Double(totalTax.replacingOccurrences(of: ",", with: "")) ?? 0
                                    
                                    self.mTaxAmountTx.text =   String(format:"%.02f",locale:Locale.current,self.calculateExclusiveTax(value: totalTaxDouble, percent: Double(self.mTaxPercent) ?? 0))
                                    
                                    self.mSubTotalTx.text = String(format:"%.02f",locale:Locale.current, totalTaxDouble)
                                    let val = Double((self.mTotalPrice.text ?? "").replacingOccurrences(of: ",", with: "")) ?? 0
                                    
                                    self.mGrandTotal.text = String(format:"%.02f",locale:Locale.current,val + (Double((self.mTaxAmountTx.text ?? "").replacingOccurrences(of: ",", with: "")) ?? 0))
                                    
                                }
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
    
    func mFetchProducts(){
        
        
        let mLocation = UserDefaults.standard.string(forKey: "location") ?? ""
        
        let urlPath =  mFetchCustomProduct
        let params = ["login_token": mUserLoginToken ?? "", "location":mLocation, "page_type":"Sales Order"]
        
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
                        
                        if let mData = jsonResult.value(forKey: "data") as? NSDictionary {
                            
                            if let mTotalValue = jsonResult.value(forKey: "totalFinal") as? NSDictionary {
                                self.mTotalPrice.text = "\(mTotalValue.value(forKey: "totalAmount") ?? "")"
                                self.mGrandTotal.text = "\(mTotalValue.value(forKey: "totalAmount") ?? "")"
                                self.mCurrency.text = "Grand Total (\(mTotalValue.value(forKey: "currency") ?? ""))"
                            }
                            
                            if let mData = mData.value(forKey: "custom_orderCart") as? NSArray {
                                
                                if mData.count != 0 {
                                    self.mShowTaxButton.isUserInteractionEnabled = true
                                    self.mCartData = mData
                                    print("POSMain.swift mCartData = \(self.mCartData)")
                                    self.mTotalQuantity.text = "\(self.mCartData.count)"
                                    for item in self.mCartData {
                                        if let value = item as? NSDictionary {
                                            let mData = NSMutableDictionary()
                                            if let mPData = value.value(forKey: "product_details") as? NSDictionary,
                                               let retailPrice = mPData.value(forKey: "retailprice") {
                                                mData.setValue("\(retailPrice)", forKey: "retailprice")
                                            }
                                            self.mAmountData.add(mData)
                                        }
                                    }
                                    self.mPOSProductTableView.delegate = self
                                    self.mPOSProductTableView.dataSource = self
                                    self.mPOSProductTableView.reloadData()
                                    
                                    self.mFetchStore(key: "1")
                                }
                                
                            }
                        }else{
                            self.mFetchStore(key: "")
                            self.mTotalPrice.text = "0.00"
                            
                            self.mGrandTotal.text = "0.00"
                            self.mCurrency.text = ""
                            self.mTotalQuantity.text = "0"
                            self.mShowTaxButton.isUserInteractionEnabled = false
                            self.mCartData = NSArray()
                            self.mPOSProductTableView.reloadData()
                            CommonClass.showSnackBar(message: "No items in your cart!")
                        }
                        
                    } else {
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

    func mRemoveProducts(id:String){
        
        let urlPath =  mRemoveCustomProduct
        let params = ["id": id]
        
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
                        
                        self.mFetchProducts()
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
    
    
    
    func mSearchCustomerByKeys(value: String){

        let urlPath =  mSearchCustomerByKey
        let params = ["key": value]
        
        if Reachability.isConnectedToNetwork() == true {
            AF.request(urlPath, method:.post, parameters:params, headers: sGisHeaders2).responseJSON
            { response in
                
                if response.error != nil {
                    CommonClass.showSnackBar(message: "OOP's something went wrong!")
                } else {
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
                        if jsonResult.value(forKey: "list") != nil {
                            
                            if let mData = jsonResult.value(forKey: "list") as? NSArray {
                                self.mSearchCustomerData =  mData
                                self.mCustomerSearchTableView.delegate = self
                                self.mCustomerSearchTableView.dataSource = self
                                self.mCustomerSearchTableView.reloadData()
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
    
    func mGetSalesPerson(){
        
        let mLocation = UserDefaults.standard.string(forKey: "location")
        
        
        let urlPath =  mGetSalesPersonList
        let params = ["location": mLocation ?? ""]
        if Reachability.isConnectedToNetwork() == true {
            AF.request(urlPath, method:.post, parameters: params, headers: sGisHeaders2).responseJSON
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
                        
                        if let data = jsonResult.value(forKey: "Salesperson") as? NSArray {
                            self.mSalesManList = [String]()
                            self.mSalesManIDList = [String]()
                            
                            for i in data {
                                if let salesData = i as? NSDictionary {
                                    self.mSalesManList.append("\(salesData.value(forKey:"name") ?? "") " + "\(salesData.value(forKey:"lname") ?? "")" )
                                    
                                    self.mSalesManIDList.append("\(salesData.value(forKey:"id") ?? "")")
                                    
                                    self.mSalesPersonName.text  = self.mSalesManList[0]
                                    self.mSalesPersonId =  self.mSalesManIDList[0]
                                    UserDefaults.standard.set(self.mSalesPersonId , forKey: "SALESPERSONID")
                                }
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
