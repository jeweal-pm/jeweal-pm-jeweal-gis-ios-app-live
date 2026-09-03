//
//  POSInventory.swift
//  GIS
//
//  Created by Apple Hawkscode on 25/03/21.
//

import UIKit
import Alamofire
import DropDown

class InventoryListCell: UITableViewCell {
    
    @IBOutlet weak var mCheckView: UIView!
    @IBOutlet weak var mStockName: UILabel!
    @IBOutlet weak var mStockId: UILabel!
    
    @IBOutlet weak var mQuantity: UILabel!
    @IBOutlet weak var mAmount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
 
}

class POSInventory: UIViewController , UITableViewDelegate , UITableViewDataSource {

    @IBOutlet weak var mInventoryListTableView: UITableView!
    
    @IBOutlet weak var mAddToCartButton: UIButton!
    
    @IBOutlet weak var mAddTOCartView: UIView!
    
    @IBOutlet weak var mStockID: UILabel!
    @IBOutlet weak var mProductImage: UIImageView!
    
    @IBOutlet weak var mProductStatusView: UIView!
    
    @IBOutlet weak var mProductStatus: UILabel!
    @IBOutlet weak var mStatusDot: UILabel!
    
    @IBOutlet weak var mShareLabel: UILabel!
    @IBOutlet weak var mStockName: UILabel!
    @IBOutlet weak var mMetaTag: UILabel!
    @IBOutlet weak var mItemName: UILabel!
    
    @IBOutlet weak var mCollectionName: UILabel!
    @IBOutlet weak var mMetalName: UILabel!
    @IBOutlet weak var mStoneName: UILabel!
    @IBOutlet weak var mSize: UILabel!
    @IBOutlet weak var mLocationName: UILabel!
    
    @IBOutlet weak var mCustomerSelectView: UIView!
    
    @IBOutlet weak var mSalesPersonName: UILabel!
    var mSalesManList = [String]()
    var mSalesManIDList = [String]()
    var mCustomerId = ""
    var mSalesPersonId = ""
    var SiriID = ""
 
    @IBOutlet weak var mCustomerSearch: UITextField!
    var mSearchCustomerData = NSArray()
    @IBOutlet weak var mCustomerSearchTableView: UITableView!

    @IBOutlet weak var mCustomerSearchView: UIView!
    @IBOutlet weak var mCustomerDetailView: UIView!
    @IBOutlet weak var mCustomerNames: UILabel!
    @IBOutlet weak var mCustomerAddresss: UILabel!
    @IBOutlet weak var mCustomerNumbers: UILabel!
    
    var mSelectedIndex = [IndexPath]()
    var mSelectedData = [String]()

    var mSelectedInventoryIndex = [IndexPath]()
    var mSelectedInventoryData = [String]()
    var mIndexInv = -1
    var mInventroyData = NSArray()
    var mSortedInventroyData = NSMutableArray()
    var mCartData = NSMutableArray()
    
    @IBOutlet weak var mInvenoryListLABEL: UILabel!
    @IBOutlet weak var mSearchField: UITextField!
    
    @IBOutlet weak var mICollectionLABEL: UILabel!
    @IBOutlet weak var mIMetalLABEL: UILabel!
    @IBOutlet weak var mStoneLABEL: UILabel!
    @IBOutlet weak var mSizeLABEL: UILabel!

    @IBOutlet weak var mProductSummaryLABEL: UILabel!
    @IBOutlet weak var mMaterialLABEL: UILabel!
    @IBOutlet weak var mPStoneLABEL: UILabel!
    @IBOutlet weak var mReferenceNoLABEL: UILabel!
    @IBOutlet weak var mCertificateLABEL: UILabel!

    @IBOutlet weak var mViewHeight: NSLayoutConstraint!
    @IBOutlet weak var mProductSummaryView: UIStackView!
    @IBOutlet weak var mShowHideIcon: UIImageView!
    
    var mLocationsId = [String]()
    var mParkedStockIds = [String]()
    
    override func viewWillAppear(_ animated: Bool) {
        mGetInventoryData(key: "")
        mGetSalesPerson()
        mAddToCartButton.isEnabled = false
        mAddToCartButton.alpha = 0.5
        if UserDefaults.standard.string(forKey: "CUSTOMERID") == nil {
            UserDefaults.standard.set("", forKey: "CUSTOMERID")
        }
        if  UserDefaults.standard.string(forKey: "SALESPERSONID") == nil {
            UserDefaults.standard.set("", forKey: "SALESPERSONID")
        }

        mInvenoryListLABEL.text = "Jewelry".localizedString
        mSearchField.placeholder = "Search By SKU/Stock ID".localizedString
        mICollectionLABEL.text = "Collection".localizedString
        mIMetalLABEL.text = "Metal".localizedString
        mStoneLABEL.text = "Stone".localizedString
        mSizeLABEL.text = "Size".localizedString
        mProductSummaryLABEL.text = "Product Summary".localizedString
        mMaterialLABEL.text = "Material".localizedString
        mPStoneLABEL.text = "Stone".localizedString
        mReferenceNoLABEL.text = "Reference No.".localizedString
        mCertificateLABEL.text = "Certificate".localizedString
        mAddToCartButton.setTitle("ADD TO CART".localizedString, for: .normal)

        if let mData = UserDefaults.standard.object(forKey: "CustomerData") as? NSDictionary {
            
            if let cusId = mData.value(forKey: "Customer_id") as? String {
                mCustomerId = cusId
                UserDefaults.standard.set(mCustomerId, forKey: "CUSTOMERID")
            }
            
            if let fName = mData.value(forKey: "fname") as? String {
                self.mCustomerNames.text = fName
            }
            
            if let lName = mData.value(forKey: "lname") as? String {
                self.mCustomerNames.text?.append(lName)
                UserDefaults.standard.set(self.mCustomerNames.text ?? "", forKey: "CUSTOMERNAME")
            }
            
            if let phoneCode = mData.value(forKey: "phone_code") {
                self.mCustomerNumbers.text = "\(phoneCode)"
            }
            
            if let phone = mData.value(forKey: "phone") {
                self.mCustomerNumbers.text?.append(" \(phone)")
            }
            
            if let stateCountry = mData.value(forKey: "stateCountry") as? String {
                self.mCustomerAddresss.text = stateCountry
            }
            
            self.mCustomerSearchView.isHidden = true
            self.mCustomerDetailView.isHidden = false
            self.mCustomerSearch.text = ""
            
        }
        mParkedStockIds =
        UserDefaults.standard.stringArray(
            forKey: "ParkedStockIds"
        ) ?? []
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        mAddToCartButton.isEnabled = false
        mAddToCartButton.alpha = 0.5
        self.mProductStatus.text = "--"
        self.mStockID.text = "--"
        self.mStockName.text = "--"
        self.mMetaTag.text = "--"
        self.mLocationName.text = "--"
        self.mMetalName.text = "--"
        self.mStoneName.text = "--"
        self.mSize.text = "--"
        self.mCollectionName.text = "--"
        
        let tap =  UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false
        
        self.mInventoryListTableView.delegate = self
        self.mInventoryListTableView.dataSource = self
        
        mGetSalesPerson()
        if UserDefaults.standard.string(forKey: "CUSTOMERID") == nil {
            UserDefaults.standard.set("", forKey: "CUSTOMERID")
        }
        if  UserDefaults.standard.string(forKey: "SALESPERSONID") == nil {
            UserDefaults.standard.set("", forKey: "SALESPERSONID")
        }
        addDoneButtonOnKeyboard()
        print("Siri ID:\(SiriID)")
    }
    
    func addDoneButtonOnKeyboard(){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Search", style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        mSearchField.inputAccessoryView = doneToolbar
    }

    @objc func doneButtonAction(){
        self.mGetInventoryData(key: mSearchField.text ?? "")
        mSearchField.resignFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
    
    }
    
    @IBAction func mShowProductSummmary(_ sender: UIButton) {
     
    }
    
    @IBAction func mProfileInfo(_ sender: Any) {
    
        self.mCustomerSearch.text = ""
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let mProfInfo = storyBoard.instantiateViewController(withIdentifier: "POSProfileInfo") as? POSProfileInfo {
            self.navigationController?.pushViewController(mProfInfo, animated:true)
        }
    }
    
    @IBAction func mHideSearchView(_ sender: Any) {
        mCustomerSearch.text = ""
        self.mCustomerSelectView.isHidden = true
    }

    @IBAction func mAddNewCustomer(_ sender: Any) {
        self.mCustomerSelectView.isHidden = false
        self.mCustomerSearch.text = ""
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let home = storyBoard.instantiateViewController(withIdentifier: "RegisterCustomer") as? RegisterCustomer {
            self.navigationController?.pushViewController(home, animated:true)
        }
    }
    
    @IBAction func mChooseNewCustomer(_ sender: Any) {
        
        self.mCustomerSelectView.isHidden = false
        self.mCustomerSearch.text = ""
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
    
    
    @IBAction func mEditCustomer(_ sender: Any) {
        mCustomerSearch.text = ""
        mCustomerDetailView.isHidden = true
        self.mCustomerSearchView.isHidden = false
        
    }
    @IBAction func mEditChanged(_ sender: Any) {
        
        let value = mCustomerSearch.text?.count
        if value != 0 {
            
            self.mSearchCustomerByKeys(value: mCustomerSearch.text ?? "")
        }else {

            if mCustomerSearch.text  == "" {

            }
            self.view.endEditing(true)
        }
    }
    
    @IBAction func mAddToCartNow(_ sender: Any) {
        guard mIndexInv >= 0 else { return }
        guard let mData = mSortedInventroyData[mIndexInv] as? NSDictionary else {
            return
        }
        let stockId = "\(mData["stock_id"] ?? "")"

        let parkedIds = Set(UserDefaults.standard.stringArray(forKey: "ParkedStockIds") ?? [])

        if parkedIds.contains(stockId) {

            CommonClass.showSnackBar(message: "This stock is already parked")

            return
        }
        _ = UserDefaults.standard.string(forKey: "location")
        
        if mCartData.count > 0 {
            mAddProducts()
        }else{
            CommonClass.showSnackBar(message: "Please choose product")
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var mCount = 0
        
        if tableView == mCustomerSearchTableView
        {
            mCount = mSearchCustomerData.count
            
        }else  if tableView == mInventoryListTableView
        {
            mCount =  mSortedInventroyData.count
            
        }
        return mCount
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false

        var cell =  UITableViewCell()
        
        if tableView == mInventoryListTableView {
            guard let cells = tableView.dequeueReusableCell(withIdentifier: "InventoryListCell") as? InventoryListCell else {
                return cell
            }
            guard let mData = mSortedInventroyData[indexPath.row] as? NSDictionary else {
                return cell
            }
            
            let stockId = "\(mData["stock_id"] ?? "")"

            if mParkedStockIds.contains(stockId) {
//                cells.isUserInteractionEnabled = false
                cells.alpha = 0.5
            } else {
                cells.isUserInteractionEnabled = true
                cells.alpha = 1
            }
            
            cells.mStockName.text = "\(mData.value(forKey: "SKU") ?? "--")"
            cells.mStockId.text = "\(mData.value(forKey: "stock_id") ?? "--")"
            cells.mQuantity.text = "\(mData.value(forKey: "po_QTY") ?? "--")"
            if UIDevice.current.userInterfaceIdiom == .pad {
                cells.mAmount.text =  "\(mData.value(forKey: "Retail_price") ?? "--")"
            }else{
                cells.mAmount.text =  "\(mData.value(forKey: "price") ?? "--")"
            }
            
            
            if let type = mData.value(forKey: "type") as? String {
                
                if type == "Master Product" || type == "Low Stock" {
                    cells.mStockId.textColor = #colorLiteral(red: 0.4588235294, green: 0.8, blue: 1, alpha: 1)
                    cells.mQuantity.backgroundColor = #colorLiteral(red: 0.4588235294, green: 0.8, blue: 1, alpha: 1)
                }else if type == "Reserved" {
                    cells.mQuantity.backgroundColor = #colorLiteral(red: 1, green: 0.7386777401, blue: 0.3924969435, alpha: 1)
                    cells.mStockId.textColor = #colorLiteral(red: 1, green: 0.7386777401, blue: 0.3924969435, alpha: 1)
                }else if type == "Sales Order" {
                    cells.mStockId.textColor =  #colorLiteral(red: 0.9137254902, green: 0.4392156863, blue: 0.4392156863, alpha: 1)
                    cells.mQuantity.backgroundColor = #colorLiteral(red: 0.9137254902, green: 0.4392156863, blue: 0.4392156863, alpha: 1)
                }else if type == "Repair Order" || type == "Repair Order Inventory"  {
                    cells.mStockId.textColor = #colorLiteral(red: 0.662745098, green: 0.6078431373, blue: 0.7411764706, alpha: 1)
                    cells.mQuantity.backgroundColor = #colorLiteral(red: 0.662745098, green: 0.6078431373, blue: 0.7411764706, alpha: 1)
                }else if type == "warehouse" {
                    cells.mStockId.textColor = #colorLiteral(red: 0.4392156863, green: 0.4392156863, blue: 0.4392156863, alpha: 1)
                    cells.mQuantity.backgroundColor = #colorLiteral(red: 0.4392156863, green: 0.4392156863, blue: 0.4392156863, alpha: 1)
                }
                
            }else{
                cells.mStockId.textColor = #colorLiteral(red: 0.4588235294, green: 0.8, blue: 1, alpha: 1)
                cells.mQuantity.backgroundColor = #colorLiteral(red: 0.4588235294, green: 0.8, blue: 1, alpha: 1)
            }
            
            if mSelectedInventoryIndex.contains(indexPath) {
                cells.mCheckView.isHidden = false
            } else {
                cells.mCheckView.isHidden = true
            }
            
            cells.layoutSubviews()
            
            if mIndexInv == indexPath.row {
                
                cells.cornerRadius = 5
                cells.borderColor = .systemBlue
                cells.borderWidth = 1
                
                if let type = mData.value(forKey: "type") as? String {
                    
                    if type == "Master Product" || type == "Low Stock" {
                        cells.mStockId.textColor = #colorLiteral(red: 0.4588235294, green: 0.8, blue: 1, alpha: 1)
                        cells.mQuantity.backgroundColor = #colorLiteral(red: 0.4588235294, green: 0.8, blue: 1, alpha: 1)
                        self.mProductStatus.textColor = #colorLiteral(red: 0.4588235294, green: 0.8, blue: 1, alpha: 1)
                        self.mStatusDot.backgroundColor = #colorLiteral(red: 0.4588235294, green: 0.8, blue: 1, alpha: 1)
                        self.mProductStatus.text = "Stock"
                        
                    }else if type == "Reserved" {
                        cells.mQuantity.backgroundColor = #colorLiteral(red: 1, green: 0.7386777401, blue: 0.3924969435, alpha: 1)
                        cells.mStockId.textColor = #colorLiteral(red: 1, green: 0.7386777401, blue: 0.3924969435, alpha: 1)
                        self.mProductStatus.textColor = #colorLiteral(red: 1, green: 0.7386777401, blue: 0.3924969435, alpha: 1)
                        self.mStatusDot.backgroundColor = #colorLiteral(red: 1, green: 0.7386777401, blue: 0.3924969435, alpha: 1)
                        self.mProductStatus.text = "Reserved"
                    }else if type == "Sales Order" {
                        cells.mStockId.textColor = #colorLiteral(red: 0.9137254902, green: 0.4392156863, blue: 0.4392156863, alpha: 1)
                        cells.mQuantity.backgroundColor = #colorLiteral(red: 0.9137254902, green: 0.4392156863, blue: 0.4392156863, alpha: 1)
                        self.mProductStatus.textColor = #colorLiteral(red: 0.9137254902, green: 0.4392156863, blue: 0.4392156863, alpha: 1)
                        self.mStatusDot.backgroundColor = #colorLiteral(red: 0.9137254902, green: 0.4392156863, blue: 0.4392156863, alpha: 1)
                        self.mProductStatus.text = "Reserved"
                    }else if type == "Repair Order" || type == "Repair Order" {
                        cells.mStockId.textColor = #colorLiteral(red: 0.662745098, green: 0.6078431373, blue: 0.7411764706, alpha: 1)
                        cells.mQuantity.backgroundColor = #colorLiteral(red: 0.662745098, green: 0.6078431373, blue: 0.7411764706, alpha: 1)
                        self.mProductStatus.textColor = #colorLiteral(red: 0.662745098, green: 0.6078431373, blue: 0.7411764706, alpha: 1)
                        self.mStatusDot.backgroundColor = #colorLiteral(red: 0.662745098, green: 0.6078431373, blue: 0.7411764706, alpha: 1)
                        self.mProductStatus.text = "Repair"
                    }else if type == "warehouse" {
                        cells.mStockId.textColor = #colorLiteral(red: 0.4392156863, green: 0.4392156863, blue: 0.4392156863, alpha: 1)
                        cells.mQuantity.backgroundColor = #colorLiteral(red: 0.4392156863, green: 0.4392156863, blue: 0.4392156863, alpha: 1)
                        self.mProductStatus.textColor = #colorLiteral(red: 0.4392156863, green: 0.4392156863, blue: 0.4392156863, alpha: 1)
                        self.mStatusDot.backgroundColor = #colorLiteral(red: 0.4392156863, green: 0.4392156863, blue: 0.4392156863, alpha: 1)
                        self.mProductStatus.text = "WareHouse"
                    }
                    
                }else{
                    cells.mStockId.textColor = #colorLiteral(red: 0.4588235294, green: 0.8, blue: 1, alpha: 1)
                    cells.mQuantity.backgroundColor = #colorLiteral(red: 0.4588235294, green: 0.8, blue: 1, alpha: 1)
                    self.mProductStatus.textColor = #colorLiteral(red: 0.4588235294, green: 0.8, blue: 1, alpha: 1)
                    self.mStatusDot.backgroundColor = #colorLiteral(red: 0.4588235294, green: 0.8, blue: 1, alpha: 1)
                    self.mProductStatus.text = "Stock"
                }
                
                
            }else{
                cells.cornerRadius = 0
                cells.borderWidth = 0
            }
            cell = cells
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == mCustomerSearchTableView {
            
            if let mData =  mSearchCustomerData[indexPath.row] as? NSDictionary {
                
                if let customerID = mData.value(forKey: "Customer_id") as? String {
                    UserDefaults.standard.setValue(mData, forKey: "CustomerData")
                    mCustomerId = customerID
                    if mCustomerId !=  UserDefaults.standard.string( forKey: "CUSTOMERID") ?? "" {
                        UserDefaults.standard.set(mCustomerId, forKey: "CUSTOMERID")
                    }else{
                        UserDefaults.standard.set(mCustomerId, forKey: "CUSTOMERID")
                    }
                }
                if let fName = mData.value(forKey: "fname") as? String {
                    self.mCustomerNames.text = fName
                }
                if let lName = mData.value(forKey: "lname") as? String {
                    self.mCustomerNames.text?.append(" \(lName)")
                    UserDefaults.standard.set(self.mCustomerNames.text ?? "" , forKey: "CUSTOMERNAME")
                }
                if let phoneCode = mData.value(forKey: "phone_code") {
                    self.mCustomerNumbers.text = "+\(phoneCode)"
                }
                if let phone = mData.value(forKey: "phone"){
                    self.mCustomerNumbers.text?.append(" \(phone)")
                }
                if let stateCountry = mData.value(forKey: "stateCountry") as? String {
                    self.mCustomerAddresss.text = stateCountry
                }
                
                mSortedInventroyData = NSMutableArray()
                
                for data in mInventroyData {
                    if let mDatas = data as? NSDictionary {
                        
//                        let stockId = "\(mData["stock_id"] ?? "")"
//                        if mParkedStockIds.contains(stockId) {
//                            mAddToCartButton.isEnabled = false
//                            mAddToCartButton.alpha = 0.5
//
//                            CommonClass.showSnackBar(message: "This stock is already parked.")
//                            return
//                        } else {
//                            mAddToCartButton.isEnabled = true
//                            mAddToCartButton.alpha = 1.0
//                        }
                        
                        if "\(mDatas.value(forKey: "Customer_id") ?? "")" == mCustomerId {
                            mSortedInventroyData.add(mDatas)
                        }else{
                            if "\(mDatas.value(forKey: "type") ?? "")" == "Master Product" ||  "\(mDatas.value(forKey: "type") ?? "")" == "Low Stock" {
                                mSortedInventroyData.add(mDatas)
                            }
                        }
                    }
                }
                
            }
            
                
            mInventoryListTableView.reloadData()
            self.mCustomerSearchView.isHidden = true
            self.mCustomerDetailView.isHidden = false
            self.mCustomerSearch.text = ""
            self.mCustomerSelectView.isHidden = true
            
        } else if tableView == mInventoryListTableView {
            
            if UserDefaults.standard.string(forKey: "CUSTOMERID") == "" {
                CommonClass.showSnackBar(message: "Please choose Customer and Sales Person.")
                
            }else{
                mIndexInv = indexPath.row
                guard let mData = mSortedInventroyData[indexPath.row] as? NSDictionary else {
                    return
                }
                let stockId = "\(mData["stock_id"] ?? "")"

                if mParkedStockIds.contains(stockId) {
                    mAddToCartButton.isEnabled = false
                    mAddToCartButton.alpha = 0.5
                    CommonClass.showSnackBar(message: "This stock is already parked.")
                    return
                }
                
                if let image = mData.value(forKey: "main_image") as? String {
                    self.mProductImage.downlaodImageFromUrl(urlString: image)
                }
                self.mStockID.text = "\(mData.value(forKey: "stock_id") ?? "--")"
                self.mStockName.text = "\(mData.value(forKey: "SKU") ?? "--")"
                self.mMetaTag.text = "\(mData.value(forKey: "Matatag") ?? "--")"
                self.mLocationName.text = "\(mData.value(forKey: "location_name") ?? "--")"
                self.mMetalName.text = "\(mData.value(forKey: "metalName") ?? "--")"
                self.mStoneName.text = "\(mData.value(forKey: "stoneName") ?? "--")"
                self.mSize.text = "\(mData.value(forKey: "size") ?? "--")"
                self.mCollectionName.text = "\(mData.value(forKey: "Collection_name") ?? "--")"
                
                if let type = mData.value(forKey: "type") as? String {
                    
                    if type == "Master Product" || type == "Low Stock" {
                        self.mProductStatus.textColor = #colorLiteral(red: 0.4588235294, green: 0.8, blue: 1, alpha: 1)
                        self.mStatusDot.backgroundColor = #colorLiteral(red: 0.4588235294, green: 0.8, blue: 1, alpha: 1)
                        self.mProductStatus.text = "Stock"
                    }else if type == "Reserved" {
                        self.mProductStatus.textColor = #colorLiteral(red: 1, green: 0.7490196078, blue: 0.4588235294, alpha: 1)
                        self.mStatusDot.backgroundColor = #colorLiteral(red: 1, green: 0.7490196078, blue: 0.4588235294, alpha: 1)
                        self.mProductStatus.text = "Reserved"
                    }else if type == "Sales Order" {
                        self.mProductStatus.textColor = #colorLiteral(red: 0.9137254902, green: 0.4392156863, blue: 0.4392156863, alpha: 1)
                        self.mStatusDot.backgroundColor = #colorLiteral(red: 0.9137254902, green: 0.4392156863, blue: 0.4392156863, alpha: 1)
                        self.mProductStatus.text = "Reserved"
                    }else if type == "Repair Order" || type == "Repair Order Inventory" {
                        self.mProductStatus.textColor = #colorLiteral(red: 0.662745098, green: 0.6078431373, blue: 0.7411764706, alpha: 1)
                        self.mStatusDot.backgroundColor = #colorLiteral(red: 0.662745098, green: 0.6078431373, blue: 0.7411764706, alpha: 1)
                        self.mProductStatus.text = "Repair"
                    }else if type == "warehouse" {
                        self.mProductStatus.textColor = #colorLiteral(red: 0.4392156863, green: 0.4392156863, blue: 0.4392156863, alpha: 1)
                        self.mStatusDot.backgroundColor = #colorLiteral(red: 0.4392156863, green: 0.4392156863, blue: 0.4392156863, alpha: 1)
                        self.mProductStatus.text = "WareHouse"
                    }
                    
                }else {
                    self.mProductStatus.textColor = #colorLiteral(red: 0.4588235294, green: 0.8, blue: 1, alpha: 1)
                    self.mStatusDot.backgroundColor = #colorLiteral(red: 0.4588235294, green: 0.8, blue: 1, alpha: 1)
                    self.mProductStatus.text = "Stock"
                }
                
                if "\(mData.value(forKey: "type") ?? "")" != "Repair Order Inventory" {
                    if self.mSelectedInventoryIndex.contains(indexPath) {
                        self.mSelectedInventoryIndex = mSelectedInventoryIndex.filter {$0 != indexPath }
                        
                        if self.mSelectedInventoryIndex.isEmpty {
                            mAddToCartButton.isEnabled = false
                            mAddToCartButton.alpha = 0.5
                        }
                        if let mInvData = mSortedInventroyData[indexPath.row] as? NSDictionary,
                           
                           let productId = mInvData.value(forKey: "product_id") as? String {
                            let mDatas = NSMutableDictionary()
                            self.mParkedStockIds =
                            UserDefaults.standard.stringArray(forKey: "ParkedStockIds") ?? []
                            mDatas.setValue(productId, forKey: "product_id")
                            if let poProductId = mInvData.value(forKey: "Po_products_id") as? String {
                                mDatas.setValue(poProductId, forKey: "po_product_id")
                            }else{
                                mDatas.setValue("", forKey: "po_product_id")
                            }
                            if let id = mInvData.value(forKey: "transaction_stock_id") as? String {
                                mDatas.setValue(id, forKey: "transaction_stock_id")
                            }else{
                                mDatas.setValue("", forKey: "transaction_stock_id")
                            }
                            
                            mCartData.remove(mDatas)
                        }
                    }else{
                        
                        if "\(mData.value(forKey: "type") ?? "")" != "warehouse" {
                    
                            self.mSelectedInventoryIndex.append(indexPath)
                            mAddToCartButton.isEnabled = true
                            mAddToCartButton.alpha = 1.0
                            let parkedIds = Set(UserDefaults.standard.stringArray(forKey: "ParkedStockIds") ?? [])

                            let stockId = "\(mData.value(forKey: "stock_id") ?? "")"

                            mAddToCartButton.isEnabled = !parkedIds.contains(stockId)
                            mAddToCartButton.alpha = parkedIds.contains(stockId) ? 0.5 : 1.0
                            
                            if let mInvData = mSortedInventroyData[indexPath.row] as? NSDictionary,
                               let productId = mInvData.value(forKey: "product_id") as? String {
                                
                                let mDatas = NSMutableDictionary()
                                mDatas.setValue(productId, forKey: "product_id")
                                self.mParkedStockIds =
                                UserDefaults.standard.stringArray(forKey: "ParkedStockIds") ?? []
                                if let poProductsId = mInvData.value(forKey: "Po_products_id") as? String {
                                    mDatas.setValue(poProductsId, forKey: "po_product_id")
                                }else{
                                    mDatas.setValue("", forKey: "po_product_id")
                                }
                                if let transactionStockId = mInvData.value(forKey: "transaction_stock_id") as? String {
                                    mDatas.setValue(transactionStockId, forKey: "transaction_stock_id")
                                }else{
                                    mDatas.setValue("", forKey: "transaction_stock_id")
                                }
                                
                                mCartData.add(mDatas)
                            }
                        }
                        
                    }
                }
                
                
                
                self.mInventoryListTableView.reloadData()
            }
            
        }
        
    }
    func mClearCart(){
        print("🔥 POSInventory.swift mClearCart called")
        _ = UserDefaults.standard.string(forKey: "location")
        
        let urlPath =  mClearDataApi
        
        if Reachability.isConnectedToNetwork() == true {
            AF.request(urlPath, method:.post, headers: sGisHeaders2).responseJSON { response in
                
                
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if tableView ==  mCustomerSearchTableView {
            return 78
        }
        
        
        return 35
        
        
        
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
                            self.mCustomerSearchTableView.delegate = self
                            self.mCustomerSearchTableView.dataSource = self
                            self.mCustomerSearchTableView.reloadData()
                            
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
    
    
    
    func mGetInventoryData(key: String){
        
//        let mLocation = UserDefaults.standard.string(forKey: "location") ?? ""
//        "location_id": UserDefaults.standard.string(forKey: "location")
        
        let urlPath =  mGetInventory
//        
//        let params = ["location_id":mLocation, "search_key":key , "type":"pos"] as [String : Any]
        var params: [String: Any] = [
            "search_key": key,
            "type": "pos"
        ]

        if mLocationsId.count > 0 {

            params["location_id"] = mLocationsId

        } else {

            params["location_id"] =
                UserDefaults.standard.string(
                    forKey: "location"
                ) ?? ""
        }

        print("DEBUG_LOCATION_FILTER =", mLocationsId)
        print("DEBUG_PARAMS =", params)
        
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
                        
                        self.mIndexInv = -1
                        self.mSelectedInventoryIndex = [IndexPath]()
                        self.mInventroyData = NSArray()
                        
                        if let mData = jsonResult.value(forKey: "data") as? NSArray, mData.count > 0 {
                            
                            if let data = mData[0] as? NSDictionary {
                                
                                print("========== INVENTORY DETAIL ==========")
                                print(data)
                                print("PriceDetails =", data["PriceDetails"] ?? "nil")
                                print("GrossWt =", data["GrossWt"] ?? "nil")
                                print("NetWt =", data["NetWt"] ?? "nil")
                                print("status =", data["status"] ?? "nil")
                                print("Stones =", data["Stones"] ?? "nil")
                                print("======================================")
                                
                                if let type = data.value(forKey: "type") as? String {
                                    
                                    if type == "Master Product" || type == "Low Stock" {
                                        self.mProductStatus.textColor = #colorLiteral(red: 0.4588235294, green: 0.8, blue: 1, alpha: 1)
                                        self.mStatusDot.backgroundColor = #colorLiteral(red: 0.4588235294, green: 0.8, blue: 1, alpha: 1)
                                        self.mProductStatus.text = "Stock"
                                    }else if type == "Reserved" {
                                        self.mProductStatus.textColor = #colorLiteral(red: 1, green: 0.7386777401, blue: 0.3924969435, alpha: 1)
                                        self.mStatusDot.backgroundColor = #colorLiteral(red: 1, green: 0.7386777401, blue: 0.3924969435, alpha: 1)
                                        self.mProductStatus.text = "Reserved"
                                    }else if type == "Sales Order" {
                                        self.mProductStatus.textColor = #colorLiteral(red: 0.9137254902, green: 0.4392156863, blue: 0.4392156863, alpha: 1)
                                        self.mStatusDot.backgroundColor = #colorLiteral(red: 0.9137254902, green: 0.4392156863, blue: 0.4392156863, alpha: 1)
                                        self.mProductStatus.text = "Reserved"
                                    }else if type == "Repair Order" || type == "Repair Order Inventroy" {
                                        self.mProductStatus.textColor = #colorLiteral(red: 0.662745098, green: 0.6078431373, blue: 0.7411764706, alpha: 1)
                                        self.mStatusDot.backgroundColor = #colorLiteral(red: 0.662745098, green: 0.6078431373, blue: 0.7411764706, alpha: 1)
                                        self.mProductStatus.text = "Repair"
                                    }else if type == "warehouse" {
                                        self.mProductStatus.textColor = #colorLiteral(red: 0.4392156863, green: 0.4392156863, blue: 0.4392156863, alpha: 1)
                                        self.mStatusDot.backgroundColor = #colorLiteral(red: 0.4392156863, green: 0.4392156863, blue: 0.4392156863, alpha: 1)
                                        self.mProductStatus.text = "WareHouse"
                                    }
                                    
                                }else{
                                    self.mProductStatus.textColor = #colorLiteral(red: 0.4588235294, green: 0.8, blue: 1, alpha: 1)
                                    self.mStatusDot.backgroundColor = #colorLiteral(red: 0.4588235294, green: 0.8, blue: 1, alpha: 1)
                                    self.mProductStatus.text = "Stock"
                                }
                                
                                if let mainImage = data.value(forKey: "main_image") as? String {
                                    self.mProductImage.downlaodImageFromUrl(urlString: mainImage)
                                }
                                
                                self.mStockID.text = "\(data.value(forKey: "stock_id") ?? "--")"
                                self.mStockName.text = "\(data.value(forKey: "SKU") ?? "--")"
                                self.mMetaTag.text = "\(data.value(forKey: "Matatag") ?? "--")"
                                self.mLocationName.text = "\(data.value(forKey: "location_name") ?? "--")"
                                self.mMetalName.text = "\(data.value(forKey: "metalName") ?? "--")"
                                self.mStoneName.text = "\(data.value(forKey: "stoneName") ?? "--")"
                                self.mSize.text = "\(data.value(forKey: "size") ?? "--")"
                                self.mCollectionName.text = "\(data.value(forKey: "Collection_name") ?? "--")"
                                
                                self.mInventroyData =  mData
                                self.mSortedInventroyData = NSMutableArray()
                                self.mSortedInventroyData = NSMutableArray(array:mData)
                                
                                self.mInventoryListTableView.delegate = self
                                self.mInventoryListTableView.dataSource = self
                                self.mInventoryListTableView.reloadData()
                            }
                        }else{
                            self.mIndexInv = -1
                            self.mSelectedInventoryIndex = [IndexPath]()
                            self.mInventroyData = NSArray()
                            self.mSortedInventroyData = NSMutableArray()
                            self.mProductStatus.text = "--"
                            self.mStockID.text = "--"
                            self.mStockName.text = "--"
                            self.mMetaTag.text = "--"
                            self.mLocationName.text = "--"
                            self.mMetalName.text = "--"
                            self.mStoneName.text = "--"
                            self.mSize.text = "--"
                            self.mCollectionName.text = "--"
                        }
                        
                    }else{
                        self.mIndexInv = -1
                        self.mSelectedInventoryIndex = [IndexPath]()
                        self.mInventroyData = NSArray()
                        self.mSortedInventroyData = NSMutableArray()
                        self.mProductStatus.text = "--"
                        self.mStockID.text = "--"
                        self.mStockName.text = "--"
                        self.mMetaTag.text = "--"
                        self.mLocationName.text = "--"
                        self.mMetalName.text = "--"
                        self.mStoneName.text = "--"
                        self.mSize.text = "--"
                        self.mCollectionName.text = "--"
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
    func mAddProducts(){
        
        let mLocation = UserDefaults.standard.string(forKey: "location") ?? ""
        let urlPath =  mAddCustomProduct
        let params = ["login_token":mUserLoginToken ?? "","cartData": self.mCartData , "location_id":mLocation,"type":"Sales Order"] as [String : Any]
        
        if Reachability.isConnectedToNetwork() == true {
            AF.request(urlPath, method:.post, parameters:params, encoding: JSONEncoding.default, headers: sGisHeaders2).responseJSON
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
                        CommonClass.showSnackBar(message: "\(jsonResult.value(forKey: "message") ?? "")")
                        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        
                        if let mHomePage  = storyBoard.instantiateViewController(withIdentifier: "POSTabBarController") as? POSTabBarController {
                            mHomePage.mIndex = 2
                            self.navigationController?.pushViewController(mHomePage, animated:false)
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

    func uniqueElementsFrom(array:[String]) -> [String] {
        
        var set = Set<String>()
        
        let result = array.filter {
            guard !set.contains($0)  else {
                return  false
            }
            set.insert($0)
            return true
        }
        
        return result
    }

   

}
