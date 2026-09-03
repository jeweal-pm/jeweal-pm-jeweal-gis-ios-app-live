//
//  OpenJewelryAndDiamond.swift
//  GIS
//
//  Created by MacBook Hawkscode  on 16/02/23.
//  Copyright © 2023 Hawkscode. All rights reserved.
//

import UIKit

class OpenJewelryAndDiamond: UIViewController {

    var delegate:OpenCustomerMixMatchDelegate? = nil

    @IBOutlet weak var mDiamondLABEL: UILabel!
    
    @IBOutlet weak var mJewelryLABEL: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
        mJewelryLABEL.text = "Jewelry".localizedString
        mDiamondLABEL.text = "Diamond".localizedString

        // Do any additional setup after loading the view.
    }
    


    @IBAction func mClose(_ sender: Any) {
    dismiss(animated: false)
    }
    
    @IBAction func mJewelry(_ sender: Any) {
 
//        dismiss(animated: false)
//        delegate?.mOnClickItem(controller: "jewelry")
        print("delegate =", delegate as Any)
        dismiss(animated: false) {
            print("CALL DELEGATE")
                self.delegate?.mOnClickItem(controller: "jewelry")
            }
    }
    @IBAction func mDiamond(_ sender: Any) {
   
//        dismiss(animated: false)
//
//        delegate?.mOnClickItem(controller: "diamond")
        dismiss(animated: false) {
                self.delegate?.mOnClickItem(controller: "diamond")
            }
    }

    
}
