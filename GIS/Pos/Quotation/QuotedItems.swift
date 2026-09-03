//
//  QuotedItems.swift
//  GIS
//
//  Created by Macbook Pro on 20/07/23.
//  Copyright © 2023 Hawkscode. All rights reserved.
//

import UIKit
import Alamofire
protocol QuotationItemDelegate {
    func mGetItems(id : String, type:String)
 
}
protocol QuotedItemDelegate {
    func mGetItems(id : String, type:String)

}
class QuotedItems: UIViewController , UITableViewDelegate, UITableViewDataSource, UIViewControllerTransitioningDelegate, QuotedItemDelegate {

    
   
   
    @IBOutlet weak var mSearchField: UITextField!
    
    
    
    @IBOutlet weak var mTableView: UITableView!
    @IBOutlet weak var mNotes: UITextView!
    
    var mData = NSArray()
    var mMasterData = NSArray()
    var mId = ""
    var mType = ""
    @IBOutlet weak var mNoteLABEL: UILabel!
    
    var delegate:QuotationItemDelegate? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        mSearchField.placeholder  = "Search by SKU / Stock ID".localizedString
        mNoteLABEL.text = "Note".localizedString
         self.mTableView.separatorStyle = .none
        mGetPurchasedItem()
     }
    
    
    @IBAction func mEditSearch(_ sender: UITextField) {
        if sender.text == "" {
            self.mData = mMasterData
            self.mTableView.reloadData()
         }else {
            var mSearchData = NSMutableArray()
            for i in mMasterData {
                if let mData = i as? NSDictionary {
                    let search = sender.text ?? ""
                    if "\(mData.value(forKey: "stock_id") ?? "")".lowercased().contains(search.lowercased()) || "\(mData.value(forKey: "price") ?? "")".lowercased().contains(search.lowercased())      {
                        mSearchData.add(mData)
                    }
                }
            }
            if mSearchData.count > 0 {
                self.mData = NSArray(array: mSearchData)
                self.mTableView.reloadData()
            }else{
                self.mData = mMasterData
                self.mTableView.reloadData()
            }
        }
 
    
    
    }
    
    func mGetPurchasedItem() {
        CommonClass.showFullLoader(view: self.view)
        print("mGetQuotedItems params: \(["quotation_id":mId])")
        mGetData(url: mGetQuotedItems,headers: sGisHeaders,  params: ["quotation_id":mId]) { response , status in
            CommonClass.stopLoader()
            print("mGetQuotedItems response: \(response)")
            if status {
                if let mObject = response.value(forKey: "data") as? NSDictionary {
                    
                    if let mRemarks =  mObject.value(forKey: "remark") as? String {
                        self.mNotes.text = mRemarks
                    }
                    if let mData = mObject.value(forKey: "response") as? NSArray {
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
   }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if mData.count == 0 {
            tableView.setError("No items Found!".localizedString)
        }else{
            tableView.clearBackground()
        }
       return mData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false

        if let cell = tableView.dequeueReusableCell(withIdentifier: "PurchasedCell") as? PurchasedCell {
            if let mData = mData[indexPath.row] as? NSDictionary {
                
                cell.mQty.text = "\(mData.value(forKey: "Qty") ?? "0")"
                cell.mSNo.text = indexPath.row == 0 ? "1" : ""
                cell.mStockId.text = "\(mData.value(forKey: "stock_id") ?? "--")"
                let price = Double("\(mData.value(forKey: "price") ?? "0")") ?? 0

                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal
                formatter.minimumFractionDigits = 2
                formatter.maximumFractionDigits = 2

                let formattedPrice = formatter.string(from: NSNumber(value: price)) ?? "0.00"

                cell.mPrice.text =
                    "\(UserDefaults.standard.string(forKey: "currencySymbol") ?? "$") \(formattedPrice)"
//                cell.mPrice.text = "\(UserDefaults.standard.string(forKey: "currencySymbol") ?? "$")" + "\(mData.value(forKey: "price") ?? "0.00")"
                cell.mProductName.text = "\(mData.value(forKey: "name") ?? "--")"
                cell.mProductImage.downlaodImageFromUrl(urlString: "\(mData.value(forKey: "main_image") ?? "")")
            }
            
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let mData = mData[indexPath.row] as? NSDictionary {
            if mType == "Custom Order" {
                let storyBoard: UIStoryboard = UIStoryboard(name: "quotation", bundle: nil)
                if let mCustomDesignModal = storyBoard.instantiateViewController(withIdentifier: "CustomDesignModal") as? CustomDesignModal {
                    mCustomDesignModal.mId = mId
                    mCustomDesignModal.delegate = self
                    mCustomDesignModal.mCartId = "\(mData.value(forKey: "cart_id") ?? "")"
                    mCustomDesignModal.transitioningDelegate = self
                    mCustomDesignModal.modalPresentationStyle = .automatic
                    self.present(mCustomDesignModal,animated: true)
                }
            }else if mType == "Repair" {
                let storyBoard: UIStoryboard = UIStoryboard(name: "quotation", bundle: nil)
                if let mRepairDesignModal = storyBoard.instantiateViewController(withIdentifier: "RepairDesignModal") as? RepairDesignModal {
                    mRepairDesignModal.mId = mId
                    mRepairDesignModal.delegate = self
                    mRepairDesignModal.mCartId = "\(mData.value(forKey: "cart_id") ?? "")"
                    mRepairDesignModal.transitioningDelegate = self
                    mRepairDesignModal.modalPresentationStyle = .automatic
                    self.present(mRepairDesignModal,animated: true)
                }
            }else{
                let storyBoard: UIStoryboard = UIStoryboard(name: "quotation", bundle: nil)
                if let mMixMatchDesignModal = storyBoard.instantiateViewController(withIdentifier: "MixMatchDesignModal") as? MixMatchDesignModal {
                    mMixMatchDesignModal.mId = mId
                    mMixMatchDesignModal.delegate = self
                    mMixMatchDesignModal.mCartId = "\(mData.value(forKey: "cart_id") ?? "")"
                    mMixMatchDesignModal.transitioningDelegate = self
                    mMixMatchDesignModal.modalPresentationStyle = .automatic
                    self.present(mMixMatchDesignModal,animated: true)
                }
            }
        }
    }
  
    func mGetItems(id: String, type: String) {
        self.dismiss(animated: true)
        self.delegate?.mGetItems(id: id, type: type)
    }
    
   
}
