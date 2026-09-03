//
//  CustomOrder.swift
//  GIS
//
//  Created by Apple Hawkscode on 15/12/20.
//

import UIKit
import Alamofire
import DropDown
class CustomOrderCell: UITableViewCell {
    
    
    @IBOutlet weak var mEditStatus: UIImageView!
    @IBOutlet weak var mStackView: UIStackView!
    @IBOutlet weak var mProductName: UILabel!
    @IBOutlet weak var mRemarks: UILabel!
    @IBOutlet weak var mQuantity: UITextField!
    @IBOutlet weak var mVariant: UILabel!
    @IBOutlet weak var mTapEditButton: UIButton!
    @IBOutlet weak var mPrice: UITextField!
    @IBOutlet weak var mDropDownImage: UIImageView!
    @IBOutlet weak var mTapDropDown: UIButton!
    
    @IBOutlet weak var mProductImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
   
    }
    override func prepareForReuse() {
        super.prepareForReuse()
     
    }
 

    
}
class CustomOrder: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var mSelectedCustomIndex = [IndexPath]()
    var mSelectedInventoryData = [String]()
    var mRefresh =  true
    @IBOutlet weak var mTotalQuantity: UILabel!
    @IBOutlet weak var mTotalAmount: UILabel!
    @IBOutlet weak var mCustomOrderTable: UITableView!
    
    @IBOutlet weak var mTableBottomView: UIView!
    
    @IBOutlet weak var mBottomView: UIView!
    
    
    @IBOutlet weak var mCheckOutView: UIView!
    
    @IBOutlet weak var mCheckOutButton: UIButton!
    
    @IBOutlet weak var mCustomerSearch: UITextField!
    
    let mCustomerSearchTableView = UITableView()

    @IBOutlet weak var mCustomerSearchView: UIView!
    @IBOutlet weak var mCustomerDetailView: UIView!
    @IBOutlet weak var mCustomerNames: UILabel!
    @IBOutlet weak var mCustomerAddresss: UILabel!
    @IBOutlet weak var mCustomerNumbers: UILabel!
    @IBOutlet weak var mSalesPersonName: UILabel!
    var mSalesManList = [String]()
    var mSalesManIDList = [String]()
    var mCustomerId = ""
    var mSalesPersonId = ""
    
    
    @IBOutlet weak var mRemarksField: UITextField!
    
    
    var mTotalWithDiscount = ""
    var mCartTableData = NSMutableArray()
    
    var mCurrency = ""
    var mQuantity = [Int]()
    var mAmountData = NSMutableArray()
    var mSearchCustomerData = NSArray()
    var mProductsData = NSArray()
    var mIndex = -1
    
    
    
    
    @IBOutlet weak var mHCustomOrderLABEL: UILabel!
    
    @IBOutlet weak var mSalePersonLABEL: UILabel!
    
    
    @IBOutlet weak var mCreateOwnDesLABEL: UILabel!
    
    @IBOutlet weak var mCreateOwnJewLABEL: UILabel!
    
    @IBOutlet weak var mSearchField: UITextField!
    
    
    
    @IBOutlet weak var mRemarkLABEL: UILabel!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        UserDefaults.standard.set("", forKey: "CUSTOMERID")
        UserDefaults.standard.set("", forKey: "SALESPERSONID")
        
        let tap =  UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
              view.addGestureRecognizer(tap)
              tap.cancelsTouchesInView = false
        mTableBottomView.layer.cornerRadius = 5
        mTableBottomView.layer.maskedCorners = [.layerMaxXMaxYCorner,.layerMinXMaxYCorner]
     
        mBottomView.layer.cornerRadius = 20
        mBottomView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        
      
        mGetSalesPerson()
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        mCustomerSearch.tintColor = .black
        if let remark = UserDefaults.standard.string(forKey: "cRemark") {
            mRemarksField.text = remark
        }
        mCustomerSearch.placeholder = "Customer Search".localizedString

        mSearchField.placeholder = "Search".localizedString
        mCustomerSearch.placeholder = "Customer Search".localizedString
        mRemarkLABEL.text = "Remark".localizedString
        mSalePersonLABEL.text = "Sale Person".localizedString
        mHCustomOrderLABEL.text = "Custom Order".localizedString
        mCreateOwnDesLABEL.text = "Create your own design".localizedString
        mCreateOwnJewLABEL.text = "Create your jewelry by your own design".localizedString
        
        mCheckOutButton.setTitle("CHECK OUT".localizedString, for: .normal)
        
        
        if let mData =  UserDefaults.standard.object(forKey: "CustomerData") as? NSDictionary {
            
            if let customerId = mData.value(forKey: "Customer_id") {
                mCustomerId = "\(customerId)"
                UserDefaults.standard.set(mCustomerId, forKey: "CUSTOMERID")
            }
            if let fname = mData.value(forKey: "fname") {
                self.mCustomerNames.text =  "\(fname)"
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
            
            if let state = mData.value(forKey: "stateCountry") {
                self.mCustomerAddresss.text = (" \(state)")
            }
           
            self.mCustomerSearchView.isHidden = true
            self.mCustomerDetailView.isHidden = false
            self.mCustomerSearch.text = ""
            
        }
      
    }
    
    override func viewDidAppear(_ animated: Bool) {
        mQuantity = [Int]()
        mAmountData = NSMutableArray()
        mFetchProducts()
    }
    
    override func viewDidLayoutSubviews() {
        mCheckOutView.applyGradient(withColours: [#colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1),#colorLiteral(red: 0.01176470588, green: 0.2862745098, blue: 0.5568627451, alpha: 1)], gradientOrientation: .horizontal)
        self.view.applyGradient(withColours: [#colorLiteral(red: 0.7725490196, green: 0.9019607843, blue: 0.8745098039, alpha: 1),#colorLiteral(red: 0.9207345247, green: 0.9503677487, blue: 0.978346765, alpha: 1)], gradientOrientation: .vertical)
    }
    
    @IBAction func mEdit(_ sender: Any) {
    }
    
    @IBAction func mBack(_ sender: Any) {
        UserDefaults.standard.setValue(nil, forKey: "cRemark")
        UserDefaults.standard.setValue(nil, forKey: "CustomerData")
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let mInventoryPage = storyBoard.instantiateViewController(withIdentifier: "ItemSearchPage") as? ItemSearchPage {
            self.navigationController?.pushViewController(mInventoryPage, animated:true)
        }
    }
    
    @IBAction func mSearchProduct(_ sender: Any) {
        
        UserDefaults.standard.setValue("\(mRemarksField.text ?? "")", forKey: "cRemark")

        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let home = storyBoard.instantiateViewController(withIdentifier: "CustomOrderSearch") as? CustomOrderSearch {
            home.mType = "Custom Order"
            self.navigationController?.pushViewController(home, animated:true)
        }
    }
    @IBAction func mSearchCustomer(_ sender: Any) {
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let mSearchCust = storyBoard.instantiateViewController(withIdentifier: "SearchCustomer") as? SearchCustomer {
            self.navigationController?.pushViewController(mSearchCust, animated:true)
        }
    }
    
    @IBAction func mAddCustomer(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let mRegister = storyBoard.instantiateViewController(withIdentifier: "RegisterCustomer") as? RegisterCustomer {
            self.navigationController?.pushViewController(mRegister, animated:true)
        }
    }
    
    @IBAction func mCheckout(_ sender: Any) {
        
        
        if mProductsData.count > 0 {
            
            if mCustomerId == "" {
                CommonClass.showSnackBar(message: "Please choose Customer!")
            }else if mSalesPersonId == "" {
                CommonClass.showSnackBar(message: "Please choose Sales Person!")
            }else if mRemarksField.text == "" {
                CommonClass.showSnackBar(message: "Please fill Remarks!")
            } else {
                mTotalWithDiscount = mTotalAmount.text ?? "0.0"
                mCartTableData = NSMutableArray()
                
                var mData = NSDictionary()
                
                
                for data in 0..<mProductsData.count {
                    let mIndexPath = IndexPath(row: data, section: 0)
                    if let mCData = mProductsData[data] as? NSDictionary,
                       let productDetails = mCData.value(forKey: "product_details") as? NSDictionary {
                        
                        let mData = productDetails
                        
                        if let cell = self.mCustomOrderTable.cellForRow(at: mIndexPath) as? CustomOrderCell {
                            let mProductData = NSMutableDictionary()
                            
                            if let productId = mData.value(forKey: "product_id") as? String {
                                mProductData.setValue(productId, forKey: "Cartproduct_id")
                            }
                            if let id = mData.value(forKey: "id") as? String {
                                mProductData.setValue(id, forKey: "Cart_tbl_id")
                            }
                            if let retailPrice = mData.value(forKey: "retailprice") as? String {
                                mProductData.setValue(retailPrice, forKey: "ProductmainpriceAmountRow")
                            }
                            
                            mProductData.setValue("", forKey: "Posdiscount_percent")
                            mProductData.setValue("", forKey: "Posdiscount_Amounts")
                            mProductData.setValue("\(self.mQuantity[data])", forKey: "Qty")
                            mProductData.setValue("", forKey: "Deliverdate")
                            
                            mCartTableData.insert(mProductData, at: data)
                        }
                    }
                }
                
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                if let mCheckOut = storyBoard.instantiateViewController(withIdentifier: "CheckOutPage") as? CheckOutPage {
                    mCheckOut.mTotalP = self.mTotalAmount.text ?? "0.0"
                    mCheckOut.mSubTotalP = ""
                    mCheckOut.mTaxP = ""
                    mCheckOut.mTaxAm = ""
                    mCheckOut.mStoreCurrency =  self.mCurrency
                    mCheckOut.mOrderType = "Custom Order"
                    mCheckOut.mRemark = mRemarksField.text ?? ""
                    mCheckOut.mTaxType =  ""
                    mCheckOut.mTaxLabel =  ""
                    mCheckOut.mTotalWithDiscount = self.mTotalWithDiscount
                    mCheckOut.mTaxPercent =  ""
                    mCheckOut.mCartTableData =  self.mCartTableData
                    
                    self.navigationController?.pushViewController( mCheckOut, animated:true)
                }
            }
        }else{
            CommonClass.showSnackBar(message: "Please add product!")
        }
    }
    
    
    @IBAction func mLikeDislike(_ sender: Any) {
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        mCustomOrderTable.endUpdates()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var mCount = 0
        
        if tableView == mCustomerSearchTableView
        {
           mCount = mSearchCustomerData.count
        
        }else  if tableView == mCustomOrderTable
        {
            mCount =  mProductsData.count
        }
        return mCount
    
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        
        var cell1 =  UITableViewCell()
        if tableView == mCustomerSearchTableView {
            
            guard let cells = tableView.dequeueReusableCell(withIdentifier: "CustomerSearchItem") as? CustomerSearchItem,
                  let mData =  mSearchCustomerData[indexPath.row] as? NSDictionary else {
                return cell1
            }
            
            if let fname = mData.value(forKey: "fname") as? String {
                cells.mCustomerName.text = fname
            }
            if let lname = mData.value(forKey: "lname") as? String {
                cells.mCustomerName.text?.append(" \(lname)")
            }
            if let phoneCode = mData.value(forKey: "phone_code") as? String {
                cells.mPhone.text = phoneCode
            }
            if let phone = mData.value(forKey: "phone") as? String {
                cells.mPhone.text?.append(" \(phone)")
            }
            if let stateCountry = mData.value(forKey: "stateCountry") as? String {
                cells.mPlace.text = stateCountry
            }
            
            cell1 = cells
            
        }else if tableView == mCustomOrderTable {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier:"CustomOrderCell") as? CustomOrderCell else {
                return cell1
            }
            
            tableView.beginUpdates()
            tableView.endUpdates()
            
            if mIndex == indexPath.row {
                
                cell.mStackView.borderWidth = 1
                cell.mStackView.borderColor = #colorLiteral(red: 0.2392156863, green: 0.7019607843, blue: 0.6196078431, alpha: 1)
                
            }else{
                cell.mStackView.borderWidth = 0
                cell.mStackView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            }
            
            if let mData1 = mProductsData[indexPath.row] as? NSDictionary,
               let mData = mData1.value(forKey: "product_details") as? NSDictionary {
                
                
                if let customDesign = mData1.value(forKey: "Custom_design") as? String, customDesign == "0" {
                    cell.mEditStatus.isHidden = true
                } else {
                    cell.mEditStatus.isHidden = false
                }
                
                cell.mQuantity.tag = indexPath.row
                cell.mPrice.tag = indexPath.row
                
                if let mainImage = mData.value(forKey: "main_image") as? String {
                    cell.mProductImage.downlaodImageFromUrl(urlString: mainImage)
                }

                if let name = mData.value(forKey: "name") as? String {
                    cell.mProductName.text = name
                }

                if let qty = mData.value(forKey: "Qty") as? String {
                    cell.mQuantity.text = qty
                }

                if let metalName = mData.value(forKey: "metal_name") as? String,
                   let sizeName = mData.value(forKey: "size_name") as? String {
                    cell.mVariant.text = "\(metalName) Size \(sizeName)"
                }

                if let retailPrice = mData.value(forKey: "retailprice") as? String {
                    cell.mPrice.text = retailPrice
                }

                if mSelectedCustomIndex.contains(indexPath) {
                    if let mDataSet = mAmountData[indexPath.row] as? NSDictionary,
                       let customQty = mDataSet.value(forKey: "Qty") as? String,
                       let customRetailPrice = mDataSet.value(forKey: "retailprice") as? String {
                        cell.mQuantity.text = customQty
                        cell.mPrice.text = customRetailPrice
                    }
                } else {
                    if let qty = mData.value(forKey: "Qty") as? String {
                        cell.mQuantity.text = qty
                    }
                    if let retailPrice = mData.value(forKey: "retailprice") as? String {
                        cell.mPrice.text = retailPrice
                    }
                }
            }
            
            cell.layoutSubviews()
            
            cell1 =  cell
            
        }
        
        
        return cell1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == mCustomerSearchTableView {
            return 78
        }

        if let cell = tableView.dequeueReusableCell(withIdentifier: "CustomOrderCell") as? CustomOrderCell {
            return cell.mStackView.frame.height + 8
        }

        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == mCustomOrderTable {
           
            mIndex = indexPath.row
            mCustomOrderTable.reloadData()
            
        } else if tableView == mCustomerSearchTableView {
            
            if let mData = mSearchCustomerData[indexPath.row] as? NSDictionary {
                
                if let customerId = mData.value(forKey: "Customer_id") as? String {
                    UserDefaults.standard.setValue(mData, forKey: "CustomerData")
                    mCustomerId = customerId
                    UserDefaults.standard.set(mCustomerId, forKey: "CUSTOMERID")
                }

                if let fname = mData.value(forKey: "fname") as? String {
                    self.mCustomerNames.text = fname
                }

                if let lname = mData.value(forKey: "lname") as? String {
                    if self.mCustomerNames.text != nil {
                        self.mCustomerNames.text?.append(" \(lname)")
                    } else {
                        self.mCustomerNames.text = lname
                    }
                    UserDefaults.standard.set(self.mCustomerNames.text ?? "", forKey: "CUSTOMERNAME")
                }

                if let phoneCode = mData.value(forKey: "phone_code") as? String {
                    self.mCustomerNumbers.text = phoneCode
                }

                if let phone = mData.value(forKey: "phone") as? String {
                    if self.mCustomerNumbers.text != nil {
                        self.mCustomerNumbers.text?.append(" \(phone)")
                    } else {
                        self.mCustomerNumbers.text = phone
                    }
                }

                if let stateCountry = mData.value(forKey: "stateCountry") as? String {
                    self.mCustomerAddresss.text = stateCountry
                }
            }

            self.mCustomerSearchView.isHidden = true
            self.mCustomerDetailView.isHidden = false
            self.mCustomerSearch.text = ""
            mCustomerSearchTableView.removeFromSuperview()
            
        }
        
    }
    
    @IBAction func mDesign(_ sender: Any) {
        
        if mIndex != -1 {
            UserDefaults.standard.setValue("\(mRemarksField.text ?? "")", forKey: "cRemark")
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            
            if #available(iOS 14.0, *) {
                if let mData1 = mProductsData[mIndex] as? NSDictionary,
                   let mData = mData1.value(forKey: "product_details") as? NSDictionary,
                   let mCustomDesign = storyBoard.instantiateViewController(withIdentifier: "CustomDesign") as? CustomDesign {
                    
                    if let id = mData.value(forKey: "id") as? String {
                        mCustomDesign.mEditId = id
                    }

                    if let productId = mData.value(forKey: "product_id") as? String {
                        mCustomDesign.mProductId = productId
                    }
                    
                    mCustomDesign.mData = mData
                    
                    if let customDesign = mData1.value(forKey: "Custom_design") as? String {
                        if customDesign == "1" {
                            mCustomDesign.mCustomDesignData = mData1
                            mCustomDesign.mStatus = "1"                            
                        } else {
                            mCustomDesign.mStatus = "0"
                        }
                    } else {
                        mCustomDesign.mStatus = "0"
                    }
                    print("========== CustomOrder OPEN CUSTOM DESIGN ==========")
                    print("CustomOrder FULL DATA =", mData)
                    print("CustomOrder COLLECTION =", mData.value(forKey: "collection_name") ?? "nil")
                    print("========================================")
                    self.navigationController?.pushViewController(mCustomDesign, animated:true)
                }
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if tableView == mCustomOrderTable {
            if editingStyle == .delete {
                
                if let mData1 = mProductsData[indexPath.row] as? NSDictionary,
                   let mData = mData1.value(forKey: "product_details") as? NSDictionary,
                   let id = mData.value(forKey: "id") {
                    mRemoveProducts(id:"\(id)")
                }
            }
        }else{
            
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
    
    @IBAction func mEditCustomer(_ sender: Any) {
        mCustomerSearch.text = ""
        mCustomerDetailView.isHidden = true
        self.mCustomerSearchView.isHidden = false

    }
    
    @IBAction func mEditChanged(_ sender: Any) {
        let value = mCustomerSearch.text?.count
        if value != 0 {
            self.mSearchCustomerByKeys(value: mCustomerSearch.text ?? "")
        } else {
            
            if mCustomerSearch.text == "" {
                mCustomerSearchTableView.removeFromSuperview()
            }
            self.view.endEditing(true)
        }
    }
    
    func mSetupTableView(frame: CGRect) {
        if mCustomerSearch.text != "" {
        let nib = UINib(nibName: "CustomerSearchList", bundle: nil)
       
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
    
    }
    
    func mSearchCustomerByKeys(value: String){
        
        let urlPath =  mSearchCustomerByKey
        let params = ["key": value]
        
        
        if Reachability.isConnectedToNetwork() == true {
            AF.request(urlPath, method:.post, parameters:params, headers: sGisHeaders2).responseJSON
            { response in
                
                if (response.error != nil) {
                    
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
                            
                            if mData.count > 0 {
                                self.mSearchCustomerData =  mData
                                self.mSetupTableView(frame:self.mCustomerSearchView.frame)
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
    
    @IBAction func mQuantityChange(_ sender: UITextField!) {
        
        let mIndexPath = IndexPath(row:sender.tag,section: 0)
        var mCount = Double()
        
        if sender.text != "" && sender.text != "0" {
            
            if let cell = self.mCustomOrderTable.cellForRow(at: mIndexPath) as? CustomOrderCell {
                mCount = Double(cell.mQuantity.text ?? "") ?? 0
                
                if let mData1 = mProductsData[sender.tag] as? NSDictionary,
                   let mData = mData1.value(forKey: "product_details") as? NSDictionary {
                    
                    let mProductPrice = Double("\(mData.value(forKey: "retailprice") ?? "0.00")".replacingOccurrences(of: ",", with: ""))
                    
                    cell.mPrice.text = String(format:"%.02f",locale:Locale.current,(mCount * (mProductPrice ?? 0.00)))
                    if let price = Double(cell.mPrice.text?.replacingOccurrences(of: ",", with: "") ?? ""),
                       let quantity = Int(cell.mQuantity.text ?? "") {
                        calculateTotalAmount(value: price, index: sender.tag, quantity: quantity)
                    }
                }
            }
            
        }else{
            if let cell = self.mCustomOrderTable.cellForRow(at: mIndexPath) as? CustomOrderCell {
                cell.mQuantity.text = "0"

                if let mData1 = mProductsData[sender.tag] as? NSDictionary,
                   let productDetails = mData1.value(forKey: "product_details") as? NSDictionary,
                   let retailPriceString = productDetails.value(forKey: "retailprice") as? String,
                   let mProductPrice = Double(retailPriceString.replacingOccurrences(of: ",", with: "")) {
                   
                    cell.mPrice.text = String(format: "%.02f", locale: Locale.current, 0.0 * mProductPrice)

                    let pos = cell.mQuantity.beginningOfDocument
                    cell.mQuantity.selectedTextRange = cell.mQuantity.textRange(from: pos, to: pos)

                    if let priceText = cell.mPrice.text?.replacingOccurrences(of: ",", with: ""),
                       let priceValue = Double(priceText),
                       let quantityText = cell.mQuantity.text,
                       let quantityValue = Int(quantityText) {
                        calculateTotalAmount(value: priceValue, index: sender.tag, quantity: quantityValue)
                    }
                }
            }
        }
    }
    
    
    @IBAction func mPriceChange(_ sender: UITextField!) {
        
        let mIndexPath = IndexPath(row:sender.tag,section: 0)
        
        if sender.text != "" && sender.text != "0" {
            
            if let cell = self.mCustomOrderTable.cellForRow(at: mIndexPath) as? CustomOrderCell,
               let currentPriceText = cell.mPrice.text,
               let currentQuantityText = cell.mQuantity.text,
               let currentPrice = Double(currentPriceText.replacingOccurrences(of: ",", with: "")),
               let currentQuantity = Int(currentQuantityText),
               let newPriceText = sender.text,
               let newPrice = Double(newPriceText.replacingOccurrences(of: ",", with: "")) {
                
                cell.mPrice.text = newPriceText
                calculateTotalAmount(value: newPrice - currentPrice, index: sender.tag, quantity: currentQuantity)
            }
            
        }else {
            if let cell = self.mCustomOrderTable.cellForRow(at: mIndexPath) as? CustomOrderCell {
        
                cell.mPrice.text = "0"
                let pos = cell.mPrice.beginningOfDocument
               
                cell.mPrice.selectedTextRange = cell.mPrice.textRange(from: pos, to: pos)

                if let priceText = cell.mPrice.text,
                   let quantityText = cell.mQuantity.text,
                   let priceValue = Double(priceText.replacingOccurrences(of: ",", with: "")),
                   let quantityValue = Int(quantityText) {
                    
                    calculateTotalAmount(value: priceValue, index: sender.tag, quantity: quantityValue)
                }
            }
        }
       
    }
    
    
    func calculateTotalAmount(value:Double,index:Int,quantity: Int){
        var mAmount = [Double]()
        let mIndexPath = IndexPath(row:index,section: 0)
        mQuantity = [Int]()
        let mData = NSMutableDictionary()
        mData.setValue("\(value)", forKey: "retailprice")
        mData.setValue("\(quantity)",forKey: "Qty")
        mAmountData.removeObject(at: index)
        mAmountData.insert(mData, at: index)
        for i in mAmountData {
            if let mRetailPrice = i as? NSDictionary,
               let qtyString = mRetailPrice.value(forKey: "Qty") as? String,
               let qty = Int(qtyString),
               let retailPriceString = mRetailPrice.value(forKey: "retailprice") as? String,
               let retailPrice = Double(retailPriceString.replacingOccurrences(of: ",", with: "")) {
                
                mQuantity.append(qty)
                mAmount.append(retailPrice)
            }
           
        }
        
        if self.mSelectedCustomIndex.contains(mIndexPath) {
        
            self.mSelectedCustomIndex = mSelectedCustomIndex.filter {$0 != mIndexPath }
            self.mSelectedCustomIndex.append(mIndexPath)
      
        } else {
            self.mSelectedCustomIndex.append(mIndexPath)
        }

        mTotalQuantity.text = "\(mQuantity.reduce(0, {$0 + $1}))"
        mTotalAmount.text = String(format:"%.02f",locale:Locale.current,mAmount.reduce(0, {$0 + $1}))
      
        
        
       
    }
    
    
    func mFetchProducts(){


        let mLocation = UserDefaults.standard.string(forKey: "location")
 
        let urlPath =  mFetchCustomProduct
        let params = ["login_token": mUserLoginToken ?? "", "location":mLocation ?? "", "page_type":"Custom Order"]
          
        if Reachability.isConnectedToNetwork() == true {
            AF.request(urlPath, method:.post, parameters:params, encoding: JSONEncoding.default,headers: sGisHeaders2).responseJSON
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
                        
                        self.mProductsData = NSArray()
                        if jsonResult.value(forKey: "message") as? String != nil && jsonResult.value(forKey: "message") as? String == "Empty Cart" {
                            self.mCustomOrderTable.reloadData()
                            self.mTotalAmount.text = "0.00"
                            self.mTotalQuantity.text = "0"
                            CommonClass.showSnackBar(message: "No Items in your Cart!")
                        }else{
                            if let mData = jsonResult.value(forKey:"data") as? NSDictionary,
                               let mCustomData = mData.value(forKey: "custom_orderCart") as? NSArray {
                                
                                if mCustomData.count != 0 {
                                    
                                    self.mProductsData = mCustomData
                                    
                                    self.mCustomOrderTable.delegate = self
                                    self.mCustomOrderTable.dataSource = self
                                    self.mCustomOrderTable.reloadData()
                                    
                                    if let mTotalValue = jsonResult.value(forKey: "totalFinal") as? NSDictionary,
                                       let totalAmount = mTotalValue.value(forKey: "totalAmount") as? String,
                                       let currency = mTotalValue.value(forKey: "currency") as? String {
                                        
                                        self.mTotalAmount.text = totalAmount
                                        self.mCurrency = currency
                                    }
                                    
                                    self.mQuantity = [Int]()
                                    for item in self.mProductsData {
                                        if let value = item as? NSDictionary,
                                           let mPData = value.value(forKey: "product_details") as? NSDictionary,
                                           let qtyString = mPData.value(forKey: "Qty") as? String,
                                           let qty = Int(qtyString),
                                           let retailPriceString = mPData.value(forKey: "retailprice") as? String {
                                            
                                            self.mQuantity.append(qty)
                                            
                                            let mData = NSMutableDictionary()
                                            mData.setValue(retailPriceString, forKey: "retailprice")
                                            mData.setValue(qtyString, forKey: "Qty")
                                            
                                            self.mAmountData.add(mData)
                                        }
                                    }
                                    
                                    self.mTotalQuantity.text = "\(self.mQuantity.reduce(0, {$0 + $1}))"
                                }else{
                                    self.mTotalAmount.text = "0.00"
                                    self.mTotalQuantity.text = "0"
                                    
                                }
                                
                            }else{
                                self.mTotalAmount.text = "0.00"
                                self.mTotalQuantity.text = "0"
                                
                            }
                        }
                        
                    }else{
                        if let error = jsonResult.value(forKey: "error") as? String, error == "Authorization has been expired" {
                            CommonClass.sessionExpired(isExpired: true, navigation: self.navigationController)
                        } else {
                            CommonClass.showSnackBar(message: "Error! \(jsonResult.value(forKey: "code") ?? "Unknown Error")")
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
                        self.mIndex = -1
                        self.mFetchProducts()
                    }else{
                        if let error = jsonResult.value(forKey: "error") as? String, error == "Authorization has been expired" {
                            CommonClass.sessionExpired(isExpired: true, navigation: self.navigationController)
                        } else {
                            CommonClass.showSnackBar(message: "Error! \(jsonResult.value(forKey: "code") ?? "Unknown Error")")
                        }
                    }
                    
                    
                    
                }
                
                
            }
        }else{
            CommonClass.showSnackBar(message: "No Internet Connection")
        }
        
        
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
                        
                        if let data = jsonResult.value(forKey: "Salesperson") as? NSArray {
                            self.mSalesManList = [String]()
                            self.mSalesManIDList = [String]()
                            
                            for i in data {
                                if let salesData = i as? NSDictionary{
                                    
                                    if let name = salesData.value(forKey: "name") as? String,
                                       let lname = salesData.value(forKey: "lname") as? String {
                                        let fullName = "\(name) \(lname)"
                                        self.mSalesManList.append(fullName)
                                    }
                                    if let id = salesData.value(forKey: "id") as? String {
                                        self.mSalesManIDList.append(id)
                                    }
                                    
                                    self.mSalesPersonName.text = self.mSalesManList[0]
                                    self.mSalesPersonId = self.mSalesManIDList[0]
                                    UserDefaults.standard.set(self.mSalesPersonId, forKey: "SALESPERSONID")
                                }
                            }
                        }
                    }else{
                        if let error = jsonResult.value(forKey: "error") as? String, error == "Authorization has been expired" {
                            CommonClass.sessionExpired(isExpired: true, navigation: self.navigationController)
                        } else {
                            CommonClass.showSnackBar(message: "Error! \(jsonResult.value(forKey: "code") ?? "Unknown Error")")
                        }
                    }
                    
                }
                
                
            }
        }else{
            CommonClass.showSnackBar(message: "No Internet Connection")
        }
        
        
    }
}
