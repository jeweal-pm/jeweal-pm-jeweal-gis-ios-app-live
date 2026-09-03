//
//  PurchasedItems.swift
//  GIS
//
//  Created by Macbook Pro on 17/07/23.
//  Copyright © 2023 Hawkscode. All rights reserved.
//

import UIKit
import Alamofire
class PurchasedCell : UITableViewCell {
    
    @IBOutlet weak var mPrice: UILabel!
    @IBOutlet weak var mQty: UILabel!
    @IBOutlet weak var mStockId: UILabel!
    @IBOutlet weak var mProductName: UILabel!
    @IBOutlet weak var mProductImage: UIImageView!
    @IBOutlet weak var mSNo: UILabel!
}
class PurchasedItems: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    @IBOutlet weak var mSearchField: UITextField!
    @IBOutlet weak var mTableView: UITableView!
    var mData = NSArray()
    var mMasterData = NSArray()
    var mId = ""
    var mType = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mSearchField.placeholder = "Search by SKU / Stock ID".localizedString
        mGetPurchasedItem()
        
    }
    
    @IBAction func mEditSearch(_ sender: Any) {
    }
    
    
    func mGetPurchasedItem() {
        CommonClass.showFullLoader(view: self.view)
        
        mGetData(url: mGetPurchasedItems,headers: sGisHeaders,  params: ["id":mId, "type":mType]) { response , status in
            CommonClass.stopLoader()
            if status {
                if let mData = response.value(forKey: "data") as? NSArray {
                    if mData.count > 0 {
                        
                        self.mMasterData = mData
                        self.mData = mData
                        self.mTableView.showsVerticalScrollIndicator = false
                        self.mTableView.delegate = self
                        self.mTableView.dataSource = self
                        self.mTableView.reloadData()
                    }
                    
                }
                
                
            }
        }
                 }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if mData.count == 0 {
            tableView.setError("No items found!")
        }else{
            tableView.clearBackground()
        }
       return mData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PurchasedCell") as? PurchasedCell else {
            return UITableViewCell()
        }
        
        if let mData = mData[indexPath.row] as? NSDictionary {
            
            cell.mQty.text = "\(mData.value(forKey: "Qty") ?? "0")"
            cell.mSNo.text = "\(indexPath.row + 1)"
            cell.mStockId.text = "\(mData.value(forKey: "stock_id") ?? "--")"
            cell.mPrice.text = "\(mData.value(forKey: "currency") ?? "$")" + "\(mData.value(forKey: "price") ?? "0.00")"
            cell.mProductName.text = "\(mData.value(forKey: "name") ?? "--")"
            cell.mProductImage.downlaodImageFromUrl(urlString: "\(mData.value(forKey: "main_image") ?? "")")
        }
        
        return cell
    }
    
    

}
