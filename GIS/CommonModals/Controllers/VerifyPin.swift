//
//  VerifyPin.swift
//  GIS
//
//  Created by MacBook Hawkscode  on 23/02/23.
//  Copyright © 2023 Hawkscode. All rights reserved.
//

import UIKit
import Alamofire
import AVFoundation

protocol GetVerification {
    func isVerified(status:Bool)
}
class VerifyPin: UIViewController {

    var delegate:GetVerification? = nil

    @IBOutlet weak var mPinOne: UILabel!
    @IBOutlet weak var mPinTwo: UILabel!
    @IBOutlet weak var mPinThree: UILabel!
    @IBOutlet weak var mPinFour: UILabel!
    
    @IBOutlet weak var mPinSix: UILabel!
    @IBOutlet weak var mPinFive: UILabel!
    @IBOutlet weak var mLoginWIthPassButton: UIButton!
    
    var mPin = ""
    var mKey = ""
    var mTotal = ""
    var mDue = ""
    var mType = ""
    
    var mParams = [String:Any]()
    var mUrl = ""
    var mOrderType = ""
    
    
    
    @IBOutlet weak var mForgotPinButton: UIButton!
    @IBOutlet weak var mEnterPinLABEL: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
        mForgotPinButton.setTitle("Forgot your PIN?".localizedString, for: .normal)
        mEnterPinLABEL.text = "Enter Pin".localizedString
        if self.mKey != "" {
            mLoginWIthPassButton.isHidden  = true
        }
        
    }
    
    
    override func loadViewIfNeeded() {

    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        
        let g = CAGradientLayer()
        g.frame =  self.view.bounds
     
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
       
    }

    override func viewDidLayoutSubviews() {

    }

    @IBAction func mBack(_ sender: Any) {
dismiss(animated: true)
    }
    
    @IBAction func mPressOne(_ sender: UIButton) {
        sender.showAnimation{}
        if mPin.count < 7 || mPin == "" {
        
        mPin.insert(contentsOf: "1", at: mPin.endIndex)
        mInsertPin(count: mPin.count)
        }
    }
    
    
    
    @IBAction func mPressTwo(_ sender: UIButton) {
        sender.showAnimation{}
        if mPin.count < 7 || mPin == "" {
        mPin.insert(contentsOf: "2", at: mPin.endIndex)
        mInsertPin(count: mPin.count)
        }
    }
        
    
    @IBAction func mPressThree(_ sender: UIButton) {
        sender.showAnimation{}
        if mPin.count < 7 || mPin == "" {
        mPin.insert(contentsOf: "3", at: mPin.endIndex)
        mInsertPin(count: mPin.count)
        }
    }
    
    
    @IBAction func mPressFour(_ sender: UIButton) {
        sender.showAnimation{}
        if mPin.count < 7 || mPin == "" {
        mPin.insert(contentsOf: "4", at: mPin.endIndex)
        mInsertPin(count: mPin.count)
        }
    }
    
    
    
    @IBAction func mPressFive(_ sender: UIButton) {
        sender.showAnimation{}
        if mPin.count < 7 || mPin == "" {
        mPin.insert(contentsOf: "5", at: mPin.endIndex)
        mInsertPin(count: mPin.count)
        }
    }
    
    
    @IBAction func mPressSix(_ sender: UIButton) {
        sender.showAnimation{}
        if mPin.count < 7 || mPin == "" {
        mPin.insert(contentsOf: "6", at: mPin.endIndex)
        mInsertPin(count: mPin.count)
        }
    }
    
    
    @IBAction func mPressSeven(_ sender: UIButton) {
        sender.showAnimation{}
        if mPin.count < 7 || mPin == "" {
        mPin.insert(contentsOf: "7", at: mPin.endIndex)
        mInsertPin(count: mPin.count)
        }
    }
    
    @IBAction func mPressEight(_ sender: UIButton) {
        sender.showAnimation{}
        if mPin.count < 7 || mPin == "" {
        mPin.insert(contentsOf: "8", at: mPin.endIndex)
        mInsertPin(count: mPin.count)
        }
    }
    
    
    
    @IBAction func mPressNine(_ sender:  UIButton) {
        sender.showAnimation{}
        if mPin.count < 7 || mPin == "" {
        mPin.insert(contentsOf: "9", at: mPin.endIndex)
        mInsertPin(count: mPin.count)
        }
    }
    
    
    
    @IBAction func mPressZero(_ sender: UIButton) {
        sender.showAnimation{}
        if mPin.count < 7 || mPin == "" {
        mPin.insert(contentsOf: "0", at: mPin.endIndex)
        mInsertPin(count: mPin.count)
        }
    }
    
    @IBAction func mClearPin(_ sender: UIButton) {
        sender.showAnimation{}
        
        if mPin != "" {
            mPin.removeLast()
            mDelete(count: mPin.count)
        }else{
            mPin = ""
            mDelete(count: 0)
        }
        
    }
    
    
    
    @IBAction func mForgotPin(_ sender:  UIButton) {
        sender.showAnimation{
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            if let mForgotPinController = storyBoard.instantiateViewController(withIdentifier: "ForgotPinController") as? ForgotPinController {
                self.navigationController?.pushViewController(mForgotPinController, animated:true)
            }
        }
    }
    
    @IBAction func mLoginWithPass(_ sender:  UIButton) {
        sender.showAnimation{
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            if let home = storyBoard.instantiateViewController(withIdentifier: "LoginController") as? LoginController {
                self.navigationController?.pushViewController(home, animated:true)
            }
        }
    }
    
    
    
    
    
    func mInsertPin(count:Int){
        
        if(count == 1){
        mPinOne.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        }else if(count == 2){
        mPinOne.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        mPinTwo.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            
        }else if(count == 3){
        mPinOne.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        mPinTwo.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        mPinThree.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)

            
        }else if(count == 4){
        mPinOne.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        mPinTwo.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            mPinThree.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        mPinFour.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            
            
            
 
        }else if(count == 5){
            mPinOne.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            mPinTwo.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
                mPinThree.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            mPinFour.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            mPinFive.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)

                
                
     
            }else if(count == 6){
                
          
                mPinOne.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
                mPinTwo.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
                    mPinThree.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
                mPinFour.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
                mPinFive.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
                mPinSix.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)

                    
                let mParams = [ "verfypin":mPin ] as [String : Any]
                
                mGetData(url: mVerifyPin,headers: sGisHeaders,  params: mParams) { response , status in
                        if status {
                                if "\(response.value(forKey: "code") ?? "400")" == "200" {
                                    self.dismiss(animated: true)
                                    self.delegate?.isVerified(status: true)
                                }else{
                                  
                                    self.mPin = ""
                                    self.mDelete(count: 0)
                                    Animations.requireUserAtencion(on: self.mPinOne)
                                    Animations.requireUserAtencion(on: self.mPinTwo)
                                    Animations.requireUserAtencion(on: self.mPinThree)
                                    Animations.requireUserAtencion(on: self.mPinFour)
                                    Animations.requireUserAtencion(on: self.mPinFive)
                                    Animations.requireUserAtencion(on: self.mPinSix)
                                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)

                                    CommonClass.showSnackBar(message: "Invalid Pin")
                                }

                                
                            }
                        }
         
                }else{




           
           
        }
        
        
        
    }
 
 
    
    func mDelete(count:Int){
     
        if(count == 1){
            mPinTwo.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            mPinThree.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            mPinFour.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            mPinFive.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            mPinSix.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        }else if(count == 2){
            mPinThree.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            mPinFour.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            mPinFive.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            mPinSix.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            
        }else if(count == 3){
            mPinFour.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            mPinFive.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            mPinSix.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        }else if(count == 4){
            mPinFive.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            mPinSix.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        }else if(count == 5){
            mPinSix.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        }else if(count == 0){
            mPinOne.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            mPinTwo.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            mPinThree.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            mPinFour.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            mPinFive.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            mPinSix.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            
        }
      
    }
    
    
 
    
 
}
