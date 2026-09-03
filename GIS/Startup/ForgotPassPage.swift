//
//  ForgotPassPage.swift
//  GIS
//
//  Created by Apple Hawkscode on 18/11/20.
//

import UIKit
import Alamofire

class ForgotPassPage: UIViewController {
    @IBOutlet weak var mCheckMailMessage: UILabel!
    
    @IBOutlet weak var mEmail: UITextField!
    @IBOutlet weak var mSubmitButton: UIButton!
    
    @IBOutlet weak var mStoreName: UITextField!
    
    @IBOutlet weak var mQuickLoginText: UILabel!
    @IBOutlet weak var mLoginWithPinButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mEmail.autocorrectionType = UITextAutocorrectionType.no
        
        if(UserDefaults.standard.string(forKey: "email") == nil){
            UserDefaults.standard.set("", forKey: "email")
            mQuickLoginText.text = "Login with password!"
            mQuickLoginText.isHidden = false
            mLoginWithPinButton.isHidden = false
        }else{
            if(UserDefaults.standard.string(forKey: "email") != "" ){
                
                mQuickLoginText.isHidden = false
                mLoginWithPinButton.isHidden = false
            }else{
                mQuickLoginText.text = "Login with password!"
                mQuickLoginText.isHidden = false
                mLoginWithPinButton.isHidden = false
            }
            
        }
        
        mSubmitButton.applyGradient(withColours: [#colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1),#colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)], gradientOrientation: .horizontal)
        
        let tap =  UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    override func viewDidLayoutSubviews() {
        
    }
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    @IBAction func mSubmit(_ sender: UIButton) {
        sender.showAnimation{}
        if mStoreName.text == "" {
            
            CommonClass.showSnackBar(message: "Please enter your store name!")
            
        }else if mEmail.text == ""{
            
            CommonClass.showSnackBar(message: "Please enter your email!")
            
        }else if mEmail.text?.isValidEmail == false {
            
            CommonClass.showSnackBar(message: "Please enter valid email!")
            
        }else{
            mCheckMailMessage.isHidden = false
            mSubmitButton.setTitle("Resend", for: .normal)
            
            mSendLinkResetPass()
            
        }
    }
    
    @IBAction func mBack(_ sender: Any) {
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        if let home = storyBoard.instantiateViewController(withIdentifier: "LoginController") as? LoginController {
            self.navigationController?.pushViewController(home, animated:true)
        }
    }
    
    @IBAction func mGoToLogin(_ sender:  UIButton) {
        sender.showAnimation{
            
            if   self.mQuickLoginText.text == "Login with password!" {
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                
                if let home = storyBoard.instantiateViewController(withIdentifier: "LoginController") as? LoginController {
                    self.navigationController?.pushViewController(home, animated:true)
                }
            }else{
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                
                if let home = storyBoard.instantiateViewController(withIdentifier: "LoginWithPin") as? LoginWithPin {
                    self.navigationController?.pushViewController(home, animated:true)
                }
            }
        }
    }
    
    func mSendLinkResetPass(){
        
        let urlPath = mResetPassword
        
        guard let email = mEmail.text, let store = mStoreName.text else {
            CommonClass.showSnackBar(message: "Please enter your store and user name!")
            return
        }
        
        let params:[String:String] = ["username" : email,"storeName": store]
        
        if Reachability.isConnectedToNetwork() == true {
            
            AF.request(urlPath, method:.post, parameters: params).responseJSON
            { response in
                
                if response.error != nil {
                    CommonClass.showSnackBar(message: "OOP's something went wrong!")

                }else{
                    guard let jsonData = response.data else {
                        CommonClass.showSnackBar(message: "OOP's something went wrong!")
                        return
                    }
                    
                    let json = try? JSONSerialization.jsonObject(with: jsonData, options: [])
                    
                    guard let jsonResult = json as? NSDictionary else {
                        CommonClass.showSnackBar(message: "OOP's something went wrong!")
                        return
                    }
                    
                    if jsonResult.value(forKey: "code") as? Int == 200 {
                        
                        CommonClass.showSnackBar(message: "Please check your email!")
                        
                        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        if let mLoginController = storyBoard.instantiateViewController(withIdentifier: "LoginController") as? LoginController {
                            self.navigationController?.pushViewController(mLoginController, animated:true)
                        }
                        
                    }else if jsonResult.value(forKey: "code") as? Int == 400 {
                        let message = jsonResult.value(forKey: "message") ?? "OOPS! Something went wrong"
                        self.mCheckMailMessage.text =  "\(message)!"
                        CommonClass.showSnackBar(message: "\(message)!")
                        
                    }else{
                        
                        CommonClass.showSnackBar(message: "Something went wrong!")
                    }
                    
                }
                
            }
        }else {
            CommonClass.showSnackBar(message: "No Internet Connection!")
        }
        
        
    }
    
}
