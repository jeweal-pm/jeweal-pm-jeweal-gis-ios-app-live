//
//  OpenDepositReceive.swift
//  GIS
//
//  Created by Macbook Pro on 21/07/23.
//  Copyright © 2023 Hawkscode. All rights reserved.
//

import UIKit

class OpenDepositReceive: UIViewController {

    var delegate:OpenCustomerMixMatchDelegate? = nil

    @IBOutlet weak var mReceiveLABEL: UILabel!
    @IBOutlet weak var mReceiveView: UIView!
    @IBOutlet weak var mDepositLABEL: UILabel!
    @IBOutlet weak var mSelectOptionLABEL: UILabel!

    @IBOutlet weak var mDepositView: UIView!
    
    var disableDepositView: Bool? = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mSelectOptionLABEL.text = "Select your option".localizedString
        mReceiveLABEL.text = "Receive".localizedString
        mDepositLABEL.text = "Deposit".localizedString
     
        if disableDepositView == true {
            mDepositView.addSubview(DisabledOverlayView(on: mDepositView))
        }
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func mClose(_ sender: Any) {
    dismiss(animated: true)
    }
    
    @IBAction func mDeposit(_ sender: Any) {
 
        delegate?.mOnClickItem(controller: "deposit")
        dismiss(animated: true)
    }
    @IBAction func mReceive(_ sender: Any) {
   
        delegate?.mOnClickItem(controller: "receive")
        dismiss(animated: true)
    }


}
