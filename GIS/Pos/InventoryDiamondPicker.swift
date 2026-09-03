//
//  InventoryDiamondPicker.swift
//  GIS
//
//  Created by MacBook Hawkscode  on 06/02/23.
//  Copyright © 2023 Hawkscode. All rights reserved.
//

import UIKit

class InventoryDiamondPicker: UIViewController, UIViewControllerTransitioningDelegate, GetInventoryDataItemsDelegate, GetCustomerDataDelegate {
    
    
    
    
    @IBOutlet weak var mDIAMONDBUTTON: UIButton!
    
    @IBOutlet weak var mDiamondView: UIView!
    @IBOutlet weak var mJewelryLABEL: UILabel!
    @IBOutlet weak var mDiamondLABEL: UILabel!
    var mCustomerId = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mCustomerId = UserDefaults.standard.string(forKey: "DEFAULTCUSTOMER") ?? ""
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        mJewelryLABEL.text = "Jewelry".localizedString
        mDiamondLABEL.text = "Diamond".localizedString
        
        self.mDiamondView.isHidden = UserDefaults.standard.bool(forKey: "isMixMatch") ? false : true
        
    }
    
    @IBAction func mJewelryInventory(_ sender: Any) {
        if mCustomerId == "" {
            CommonClass.showSnackBar(message: "Please choose customer first!")
            mOpenCustomerSheet()
            return
        }
        let storyBoard: UIStoryboard = UIStoryboard(name: "common", bundle: nil)
        if let mInv = storyBoard.instantiateViewController(withIdentifier: "CommonInventory") as? CommonInventory {
            mInv.mOrderType = "pos_order"
            mInv.modalPresentationStyle = .overFullScreen
            mInv.delegate =  self
            mInv.mCustomerId = mCustomerId
            mInv.transitioningDelegate = self
            self.present(mInv,animated: true)
        }
    }
    @IBAction func mDianmondInventory(_ sender: Any) {
        if mCustomerId == "" {
            CommonClass.showSnackBar(message: "Please choose customer first!")
            mOpenCustomerSheet()
            return
        }
        
        UserDefaults.standard.set("true", forKey: "pickDiamond")
        let storyBoard: UIStoryboard = UIStoryboard(name: "diamondModule", bundle: nil)
        if let home = storyBoard.instantiateViewController(withIdentifier: "DiamondFilters") as? DiamondFilters {
            self.navigationController?.pushViewController(home, animated:true)
        }
    }
    
    func mGetInventoryItems(items: [String]) {
        self.tabBarController?.selectedIndex = 2
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
        if let profile = data.value(forKey: "profile") as? String {
            UserDefaults.standard.set(profile, forKey: "DEFAULTCUSTOMERPICTURE")
        }
        if let name = data.value(forKey: "name") as? String {
            UserDefaults.standard.set(name, forKey: "DEFAULTCUSTOMERNAME")
        }
    }
    
}
