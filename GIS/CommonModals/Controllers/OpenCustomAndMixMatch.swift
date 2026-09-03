//
//  OpenCustomAndMixMatch.swift
//  GIS
//
//  Created by MacBook Hawkscode  on 16/02/23.
//  Copyright © 2023 Hawkscode. All rights reserved.
//

import UIKit

protocol OpenCustomerMixMatchDelegate {
    func mOnClickItem(controller:String)
}


class OpenCustomAndMixMatch: UIViewController {

    var delegate:OpenCustomerMixMatchDelegate? = nil

    @IBOutlet weak var mMixAndMatchLABEL: UILabel!
    @IBOutlet weak var mIxMatchView: UIView!
    
    @IBOutlet weak var mCustomOrderView: UIView!
    @IBOutlet weak var mCreateYourOwnLABEL: UILabel!
    @IBOutlet weak var mSelectOptionLABEL: UILabel!
    
    var disableCustomOrderView: Bool? = false
    var disableMixNmatchView: Bool? = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
        
        mSelectOptionLABEL.text = "Select your option".localizedString
        mCreateYourOwnLABEL.text = "Create your own".localizedString
        mMixAndMatchLABEL.text = "Mix & Match".localizedString

        if disableCustomOrderView == true {
            self.mCustomOrderView.addSubview(DisabledOverlayView(on: self.mCustomOrderView))
        }

        if disableMixNmatchView == true {
            self.mIxMatchView.addSubview(DisabledOverlayView(on: self.mIxMatchView))
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func mClose(_ sender: Any) {
    dismiss(animated: true)
    }
    
    @IBAction func mCustomOrder(_ sender: Any) {
        print("mCustomOrder mOnClickItem(controller: custom)")
        delegate?.mOnClickItem(controller: "custom")
        dismiss(animated: true)
    }
    @IBAction func mMixAndMatch(_ sender: Any) {
        print("mMixAndMatch mOnClickItem(controller: mixMatch)")
        delegate?.mOnClickItem(controller: "mixMatch")
        dismiss(animated: true)
    }

}
