//
//  ReservedJewelryDiamondItems.swift
//  GIS
//
//  Created by MacBook Hawkscode  on 07/04/23.
//  Copyright © 2023 Hawkscode. All rights reserved.
//

import UIKit

class ReservedJewelryDiamondItems: UIViewController {
    
    
    @IBOutlet weak var mJewelryLABEL: UILabel!
    
    @IBOutlet weak var mHeading: UILabel!
    @IBOutlet weak var mDiamondLABEL: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
        
        mDiamondLABEL.text = "Diamond".localizedString
        mJewelryLABEL.text = "Jewelry".localizedString
        mHeading.text = "Reserved Items".localizedString
    }
    
    
    @IBAction func mBack(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func mDiamondReserveList(_ sender: Any) {
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "reserveOrderBoard", bundle: nil)
        if let mDiamondReserved = storyBoard.instantiateViewController(withIdentifier: "DiamondReserved") as? DiamondReserved {
            self.navigationController?.pushViewController(mDiamondReserved, animated:true)
        }
    }
    
    @IBAction func mInventoryReserveList(_ sender: Any) {
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "reserveOrderBoard", bundle: nil)
        if let mInventoryReserved = storyBoard.instantiateViewController(withIdentifier: "InventoryReserved") as? InventoryReserved {
            self.navigationController?.pushViewController(mInventoryReserved, animated:true)
        }
    }
    
}

