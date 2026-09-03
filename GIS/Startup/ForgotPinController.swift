//
//  ForgotPinController.swift
//  GIS
//
//  Created by Apple Hawkscode on 19/01/21.
//

import UIKit
import Alamofire

class ForgotPinController: UIViewController {
    @IBOutlet weak var mCheckMailMessage: UILabel!
    
    @IBOutlet weak var mEmail: UITextField!
    @IBOutlet weak var mPassword: UITextField!
    
    @IBOutlet weak var mSubmitButton: UIButton!
    
    @IBOutlet weak var mStoreName: UITextField!
    
    @IBOutlet weak var mQuickLoginText: UILabel!
    @IBOutlet weak var mLoginWithPinButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    @IBAction func mSubmit(_ sender: Any) {
        if mStoreName.text == "" || mStoreName.text?.isEmptyOrSpaces() == true {
            
            CommonClass.showSnackBar(message: "Please enter your store name!")
            
        }else if mEmail.text == "" || mEmail.text?.isEmptyOrSpaces() == true {
            
            CommonClass.showSnackBar(message: "Please enter your email!")
            
        }else if mPassword.text == "" || mPassword.text?.isEmptyOrSpaces() == true {
            
            CommonClass.showSnackBar(message: "Please enter your password!")
            
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
    
    
    @IBAction func mShowHidePassword(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            
            mPassword.isSecureTextEntry = false
        }else{
            mPassword.isSecureTextEntry = true
            
        }
        
    }
    
    
    
    func mSendLinkResetPass(){
        
        let urlPath = mResetPin
        
        guard let email = mEmail.text, let store = mStoreName.text, let password = mPassword.text else {
            CommonClass.showSnackBar(message: "Please fill all fields.")
            return
        }
        
        let params:[String:String] = ["username" : email,"storeName" : store,"password" : password]
        
        if Reachability.isConnectedToNetwork() == true {
            
            AF.request(urlPath, method:.post, parameters: params).responseJSON
            { response in
                
                if(response.error != nil){
                    
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
