//
//  POSPark.swift
//  GIS
//
//  Created by MacBook Hawkscode  on 04/04/23.
//  Copyright © 2023 Hawkscode. All rights reserved.
//

import UIKit

import Alamofire


class ParkNestedCell : UITableViewCell{
    @IBOutlet weak var mSNo: UILabel!
    @IBOutlet weak var mProductImage: UIImageView!
    @IBOutlet weak var mProductName: UILabel!
    @IBOutlet weak var mStockId: UILabel!
    @IBOutlet weak var mQty: UILabel!
    @IBOutlet weak var mPrice: UILabel!
    
    @IBOutlet weak var mMetalSizeColor: UILabel!
    
    @IBOutlet weak var mSKUName: UILabel!
}

class ParkCell : UITableViewCell , UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var mTableHeight: NSLayoutConstraint!
    @IBOutlet weak var mNotes: UITextView!
    
    @IBOutlet weak var mCustomerImage: UIImageView!
    @IBOutlet weak var mParkItemsTable: UITableView!
    @IBOutlet weak var mCustomerName: UILabel!
    @IBOutlet weak var mView: UIView!
    @IBOutlet weak var mCheckImage: UIImageView!
    
    @IBOutlet weak var mShowHideButton: UIButton!
    @IBOutlet weak var mMobile: UILabel!
    @IBOutlet weak var mType: UILabel!
    @IBOutlet weak var mDate: UILabel!
    
    var mParkCartData = NSArray()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mParkCartData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ParkNestedCell") as? ParkNestedCell,
           let mData = mParkCartData[indexPath.row] as? NSDictionary else {
            return UITableViewCell()
        }
        
        cell.mSNo.text = "\(indexPath.row + 1)"
        cell.mProductName.text = "\(mData.value(forKey: "name") ?? "")"
        cell.mQty.text = "\(mData.value(forKey: "Qty") ?? "")"
        cell.mPrice.text = "\(mData.value(forKey: "currency") ?? "")" + "\(mData.value(forKey: "price") ?? "")"
        cell.mStockId.text = "\(mData.value(forKey: "stock_id") ?? "")"
        cell.mProductImage.downlaodImageFromUrl(urlString: "\(mData.value(forKey: "main_image") ?? "")")
        
        return cell
    }
    
    
}

class POSPark: UIViewController , UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var mParkTable: UITableView!
    
    var delegate:GetParkItems? = nil
    var mParkData = NSMutableArray()
    
    var mIndex = -1
    
    @IBOutlet weak var mHeading: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mHeading.text = "Parked".localizedString
        
        self.mParkTable.delegate = self
        self.mParkTable.dataSource = self
        self.mParkTable.reloadData()
        
        mGetData(url: mGetPark,headers: sGisHeaders,  params: ["":""]) { response , status in
            if status {
                
                if let mData = response.value(forKey: "data") as? NSArray {
                    
                    if mData.count > 0 {
                        self.mParkData = NSMutableArray(array: mData)
                        self.mParkTable.delegate = self
                        self.mParkTable.dataSource = self
                        self.mParkTable.reloadData()
                    }
                }
            }
        }
    }
    
    
    @IBAction func mBack(_ sender: Any) {
        self.dismiss(animated: true)
        delegate?.mGetParkItems(parkId: "")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return mParkData.count    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ParkCell") as? ParkCell,
              let mData = mParkData[indexPath.row] as? NSDictionary else {
            return UITableViewCell()
        }
        
        cell.mShowHideButton.tag = indexPath.row
        cell.mCustomerImage.contentMode = .scaleAspectFill
        
        cell.mCustomerImage.downlaodImageFromUrl(urlString: "\(mData.value(forKey: "customer_profile") ?? "--")")
        cell.mCustomerName.text = "\(mData.value(forKey: "customer_name") ?? "--")"
        cell.mType.text = "\(mData.value(forKey: "SO_no") ?? "--")"
        cell.mMobile.text = "\(mData.value(forKey: "customer_mobile") ?? "--")"
        cell.mDate.text = "\(mData.value(forKey: "date") ?? "--")"
        if mIndex == indexPath.row {
            cell.mCheckImage.image = UIImage(named: "bottomic")
            if let mCart = mData.value(forKey: "cart") as? NSArray {
                if mCart.count > 0 {
                    cell.mParkCartData = mCart
                    cell.mParkItemsTable.delegate = cell
                    cell.mParkItemsTable.dataSource = cell
                    cell.mParkItemsTable.reloadData()
                    cell.mParkItemsTable.layoutIfNeeded()
                    cell.mNotes.text = "\(mData.value(forKey: "ParkMessage") ?? "")"
                    UIView.animate(withDuration: 1.0) {
                        cell.mParkItemsTable.isHidden = false
                        cell.mTableHeight.constant = cell.mParkItemsTable.contentSize.height + 80
                        self.view.layoutIfNeeded()
                    }
                }
            }
            
        }else {
            cell.mCheckImage.image = UIImage(named: "forward_ic")
            
            cell.mParkItemsTable.isHidden = true
            cell.mTableHeight.constant = 0
            self.view.layoutIfNeeded()
            cell.mParkItemsTable.layoutIfNeeded()
            
            
        }
        
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: true)
        if let mData = mParkData[indexPath.row] as? NSDictionary,
           let id = mData.value(forKey: "id") as? String {
            delegate?.mGetParkItems(parkId: id)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        
        if editingStyle == .delete {
            
            guard let mData = mParkData[indexPath.row] as? NSDictionary,
                  let id = mData.value(forKey: "id") as? String else {
                return
            }
            let mParams = [ "park_id": id] as [String : Any]
            CommonClass.showFullLoader(view: self.view)
            
            mGetData(url: mRemovePark,headers: sGisHeaders,  params: mParams) { response , status in
                CommonClass.stopLoader()
                if status {
                    if "\(response.value(forKey: "code") ?? "")" == "200" {
                        if let cart = mData.value(forKey: "cart") as? NSArray {

                                var parkedIds = UserDefaults.standard.stringArray(forKey: "ParkedStockIds") ?? []

                                for item in cart {

                                    if let dict = item as? NSDictionary {

                                        let stockId = "\(dict["stock_id"] ?? "")"

                                        parkedIds.removeAll { $0 == stockId }
                                    }
                                }

                                UserDefaults.standard.set(parkedIds, forKey: "ParkedStockIds")
                            }
                        CommonClass.stopLoader()
                        self.mDeleteRow(index: indexPath.row)
                    }else{
                        
                    }
                }
            }
            
        }
    }
    func mDeleteRow(index : Int)
    {
        self.mParkData.removeObject(at: index)
        self.mParkTable.reloadData()
        
    }
    func mDeleteCartItems(index: Int) {
        self.mParkData.removeObject(at: index)
        self.mParkTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 80
    }
    
    
    @IBAction func mShowHide(_ sender: UIButton) {
        
        mIndex = sender.tag
        mParkTable.reloadData()
        self.view.layoutIfNeeded()
    }
}
