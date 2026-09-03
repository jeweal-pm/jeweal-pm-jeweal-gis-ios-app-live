//
//  PrintItem.swift
//  GIS
//
//  Created by Apple Hawkscode on 25/11/20.
//

import UIKit
import Alamofire


class InventoryDataTableCell: UITableViewCell  {
    
    @IBOutlet weak var mStockId: UILabel!
    @IBOutlet weak var mIndexNumber: UILabel!
    @IBOutlet weak var mSKUName: UILabel!
    @IBOutlet weak var mStockView: UIView!
    @IBOutlet weak var mPriceView: UIView!
    @IBOutlet weak var mPrice: UILabel!

    var mData = [String]()
    var mHeader = ["#","Status","Item" ,"Collection","Metal","Size","Qty","Price","Location",]
    
    override func awakeFromNib() {
        super.awakeFromNib()
      
      
    }
    
}
class InventoryDataTableCellHeader: UITableViewCell  {
    
    @IBOutlet weak var mIndexNumber: UILabel!
    
    @IBOutlet weak var mShape: UILabel!
    
    @IBOutlet weak var mCarat: UILabel!
    
    @IBOutlet weak var mColour: UILabel!
    
    @IBOutlet weak var mCut: UILabel!
    @IBOutlet weak var mClarity: UILabel!
    
    @IBOutlet weak var mPolish: UILabel!
    @IBOutlet weak var mSymmetry: UILabel!
    
    @IBOutlet weak var mCertificateNumber: UILabel!
    
    @IBOutlet weak var mLocation: UILabel!
    
    @IBOutlet weak var mStatus: UILabel!
    
}

class InventoryDataTableCell2: UITableViewCell  {
    
    @IBOutlet weak var mSize: UILabel!
    
    @IBOutlet weak var mLocation: UILabel!
    @IBOutlet weak var mQty: UILabel!
    @IBOutlet weak var mItem: UILabel!
    
    @IBOutlet weak var mPrice: UILabel!
    @IBOutlet weak var mCollection: UILabel!
    
    @IBOutlet weak var mMetal: UILabel!
    
    
    @IBOutlet weak var mStackView: UIStackView!
    @IBOutlet weak var mIndexNumber:UILabel!
    @IBOutlet weak var mStatus: UILabel!
    
}

class PrintItemCell: UITableViewCell {
    @IBOutlet weak var mMetalSize: UILabel!
    
    @IBOutlet weak var mSno: UILabel!
    
    @IBOutlet weak var mSize: UILabel!
    @IBOutlet weak var mAmount: UILabel!
    @IBOutlet weak var mQuantity: UILabel!
    @IBOutlet weak var mSKUStockId: UILabel!
    @IBOutlet weak var mSKUName: UILabel!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

class PrintItem: UIViewController , UITableViewDelegate , UITableViewDataSource , UIScrollViewDelegate, UIGestureRecognizerDelegate {
    
    
    
    var mTYPE = ""
    var filters:[String: Any] = [:]
    @IBOutlet weak var mHeight: NSLayoutConstraint!
    @IBOutlet weak var mDiamondTable2: UITableView!
    @IBOutlet weak var mDiamondTable: UITableView!
    var mData = NSMutableArray()
    var mDiamondData = NSMutableArray()
    
    var mCompareId = [String]()
    var mComparedData = NSMutableArray()
    var mLength = 0
    
    var mRKey = ""
    @IBOutlet weak var mResultsView: UIView!
    
    @IBOutlet weak var mPrintLABEL: UILabel!
    @IBOutlet weak var mHeading: UILabel!
    
    @IBOutlet weak var mShowMoreView: UIView!
    let mInventoryFetchLimit = 20
    var mInventorySkip = 0
    var mInventoryTotal = 0
    
    
    @IBOutlet weak var sPrintMainScrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mHeading.text = "Inventory".localizedString
        mPrintLABEL.text = "Print".localizedString
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self

    }
    
    override func viewWillAppear(_ animated: Bool) {
        sPrintMainScrollView.delegate = self
        mShowMoreView.isHidden = true
        self.mGetInventoryPrintPreview()
    }
    
    override func viewDidLayoutSubviews() {}
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return navigationController?.viewControllers.count ?? 0 > 1
    }
    
    @IBAction func mShowMore(_ sender: Any) {
        self.mGetInventoryPrintPreview()
    }
    
    
    @IBAction func mPrint(_ sender: Any) {
        
        var params = filters
        params["search"] = ""
        
        if mData.count > 1 {
            CommonClass.showFullLoader(view: self.view)
            AF.request(mNewInventoryPrint, method: .post, parameters: params, encoding: JSONEncoding.default, headers: sGisHeaders).responseJSON { response in
                CommonClass.stopLoader()
          
                    guard let jsonData = response.data else {
                        CommonClass.showSnackBar(message: "OOP's something went wrong!")
                        return
                    }

                    do {
                        if let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? NSDictionary,
                           let code = json["code"] as? Int {
                            
                            switch code {
                            case 200:
                                if let mLink = json["link"] as? String {
                                    if let url = URL(string: mLink) {
                                        UIApplication.shared.open(url)
                                    }
                                }else{
                                    CommonClass.showSnackBar(message: "No links found!")
                                }
                                break
                            case 403:
                                CommonClass.sessionExpired(isExpired: true, navigation: self.navigationController)
                                break
                            default:
                                let errorMessage = json["message"] as? String ?? "An error occurred."
                                CommonClass.showSnackBar(message: "Error \(code): \(errorMessage)")
                                break
                            }
                        } else {
                            CommonClass.showSnackBar(message: "OOP's something went wrong!")
                        }
                    } catch {
                        CommonClass.showSnackBar(message: "OOP's something went wrong!")
                    }
                }
            
        }
        
        
    }
    
    
    @IBAction func mBack(_ sender: Any) {
        self.navigationController?.popViewController(animated:true)
        
    }
    
    @IBOutlet weak var mPreview: UILabel!
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return mData.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        
        
        var cell = UITableViewCell()
        
        if tableView == mDiamondTable {
            guard let cells = tableView.dequeueReusableCell(withIdentifier: "InventoryDataTableCell") as? InventoryDataTableCell else {
                return UITableViewCell()
            }
            
            if indexPath.row == 0 {
                cells.mStockView.backgroundColor = UIColor(named: "themeExtraLightText1")
                cells.mStockId.text = "Stock Id".localizedString
                cells.mSKUName.text = "SKU".localizedString
                cells.mSKUName.isHidden = true
            }else{
                
                cells.mSKUName.isHidden = false
                if (indexPath.row % 2 == 0) {
                    cells.mStockView.backgroundColor = #colorLiteral(red: 0.9568627451, green: 0.9568627451, blue: 0.9568627451, alpha: 1)
                }else{
                    cells.mStockView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                }
                
                if let mData = mData[indexPath.row - 1] as? NSDictionary {
                    cells.mStockId.text = "\(mData.value(forKey: "stock_id") ?? "")"
                    cells.mSKUName.text = "\(mData.value(forKey: "SKU") ?? "")"
                    cells.mIndexNumber.text = "\(indexPath.row)"
                }
            }
            
            cell = cells
            
        }else if tableView == mDiamondTable2 {
            
            guard let cell1 = tableView.dequeueReusableCell(withIdentifier: "InventoryDataTableCell2") as? InventoryDataTableCell2,
            let cell2 = tableView.dequeueReusableCell(withIdentifier: "InventoryDataTableCellHeader") as? InventoryDataTableCellHeader else {
                return UITableViewCell()
            }
            
            if indexPath.row == 0 {
                
                cell2.mStatus.text = "Item".localizedString
                cell2.mShape.text = "Collection".localizedString
                cell2.mCarat.text = "Metal".localizedString
                cell2.mColour.text = "Size".localizedString
                cell2.mClarity.text = "Qty".localizedString
                cell2.mCut.text = "Price".localizedString
                cell2.mPolish.text = "Location".localizedString
                
                
                cell = cell2
            }else{
                
                if (indexPath.row % 2 == 0) {
                    cell1.backgroundColor = #colorLiteral(red: 0.9568627451, green: 0.9568627451, blue: 0.9568627451, alpha: 1)
                    
                }else{
                    cell1.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                    
                }
                
                if let mData = mData[indexPath.row - 1] as? NSDictionary {
                    
                    cell1.mItem.text = "\(mData.value(forKey: "item_name") ?? "")"
                    cell1.mCollection.text = "\(mData.value(forKey: "collection_name") ?? "")"
                    cell1.mMetal.text = "\(mData.value(forKey: "metal_name") ?? "")"
                    cell1.mSize.text = "\(mData.value(forKey: "size_name") ?? "")"
                    cell1.mQty.text = "\(mData.value(forKey: "po_QTY") ?? "")"
                    cell1.mPrice.text = "\(mData.value(forKey: "price") ?? "")"
                    cell1.mLocation.text = "\(mData.value(forKey: "location_name") ?? "")"
                    
                    if let status = mData.value(forKey: "status_type") as? String {
                        if  status == "stock" {
                            cell1.mStatus.backgroundColor = #colorLiteral(red: 0.4588235294, green: 0.8, blue: 1, alpha: 1)
                        }else if status == "reserve" {
                            cell1.mStatus.backgroundColor = #colorLiteral(red: 1, green: 0.7386777401, blue: 0.3924969435, alpha: 1)
                        }else if status == "custom_order" {
                            cell1.mStatus.backgroundColor = #colorLiteral(red: 0.9137254902, green: 0.4392156863, blue: 0.4392156863, alpha: 1)
                        }else if status == "repair_order"  {
                            cell1.mStatus.backgroundColor = #colorLiteral(red: 0.662745098, green: 0.6078431373, blue: 0.7411764706, alpha: 1)
                        }else if status == "warehouse" {
                            cell1.mStatus.backgroundColor = #colorLiteral(red: 0.4392156863, green: 0.4392156863, blue: 0.4392156863, alpha: 1)
                        }else if status == "transit" {
                            cell1.mStatus.backgroundColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
                        }
                    }
                }
                cell = cell1
                
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    
    func mGetInventoryPrintPreview(){
        let mLocation = UserDefaults.standard.string(forKey: "location")
        
        let params:[String : Any]  = ["location":mLocation ?? "",
                                      "filter": filters ,
                                      "search":"",
                                      "skip": mInventorySkip,
                                      "limit": mInventoryFetchLimit,
        ]
        
        guard Reachability.isConnectedToNetwork() == true else {
            CommonClass.showSnackBar(message: "Please connect to internet.")
            return
        }
        let urlPath = mGetInventory
        CommonClass.showFullLoader(view: self.view)
        AF.request(urlPath, method: .post, parameters: params, encoding: JSONEncoding.default, headers: sGisHeaders)
            .responseJSON { response in
                CommonClass.stopLoader()
        
                guard let jsonData = response.data else {
                    CommonClass.showSnackBar(message: "OOP's something went wrong!")
                    return
                }

                do {
                    guard let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? NSDictionary,
                          let code = json["code"] as? Int else {
                        CommonClass.showSnackBar(message: "OOP's something went wrong!")
                        return
                    }

                    switch code {
                    case 200:
                        if let mDataItems = json["data"] as? NSArray {
                            
                            if mDataItems.count == 0 {
                                if self.mData.count == 0 {
                                    CommonClass.showSnackBar(message: "Inventory is empty.")
                                } else {
                                    CommonClass.showSnackBar(message: "You have reached maximum limit.")
                                }
                                return
                            }
                            
                            self.mInventoryTotal = json["total"] as? Int ?? 0
                            
                            for i in mDataItems {
                                self.mData.add(i)
                            }
                            
                            self.mDiamondTable.delegate = self
                            self.mDiamondTable.dataSource = self
                            self.mDiamondTable.reloadData()
                            self.mDiamondTable.layoutIfNeeded()
                            self.mHeight.constant = self.mDiamondTable.contentSize.height + 50
                            
                            self.mDiamondTable2.delegate = self
                            self.mDiamondTable2.dataSource = self
                            self.mDiamondTable2.reloadData()
                            self.mInventorySkip += 20
                            
                        }
                        break
                    case 403:
                        CommonClass.sessionExpired(isExpired: true, navigation: self.navigationController)
                        break
                    default:
                        let errorMessage = json["message"] as? String ?? "An error occurred."
                        CommonClass.showSnackBar(message: "Error \(code): \(errorMessage)")
                        break
                    }
                } catch {
                    CommonClass.showSnackBar(message: "OOP's something went wrong!")
                }
            }

        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == sPrintMainScrollView{
            let contentOffsetY = scrollView.contentOffset.y
            let contentHeight = scrollView.contentSize.height
            let scrollViewHeight = scrollView.bounds.size.height
            if contentOffsetY + scrollViewHeight >= contentHeight {
                if self.mInventorySkip < self.mInventoryTotal && mData.count > 0 {
                    mShowMoreView.isHidden = false
                }
            }else{
                mShowMoreView.isHidden = true
            }
        }
    }
    
}
