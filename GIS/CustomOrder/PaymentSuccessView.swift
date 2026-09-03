//
//  PaymentSuccessView.swift
//  GIS
//
//  Created by Mayank Sharma on 25/12/24.
//  Copyright © 2024 Hawkscode. All rights reserved.
//

import Foundation
import UIKit

 
class PaymentSuccessView: UIView {
    
    @IBOutlet weak var mSuccessAmount: UILabel!
    @IBOutlet weak var mImageView: UIImageView!
    
    @IBOutlet weak var mAmountStatus: UILabel!
    
    override func awakeFromNib() {
         super.awakeFromNib()
         
     }

 
    @IBAction func mDoneButton(_ sender: Any) {
        self.removeFromSuperview()
    }
    
    func setAmount(_ amount: String) {
        mSuccessAmount.text = amount
       }
    
    func setImage(_ image: UIImage) {
        mImageView.image = image
    }
    func mSetAmountStatus(_ status: String) {
        mAmountStatus.text = status
    }
    
    static func loadFromNib() -> PaymentSuccessView? {
           return Bundle.main.loadNibNamed("PaymentSuccessView", owner: self, options: nil)?.first as? PaymentSuccessView
       }
    
   }

 
