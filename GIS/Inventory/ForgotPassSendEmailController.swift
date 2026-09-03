//
//  ForgotPassSendEmailController.swift
//  NavhooDriver
//
//  Created by Apple Hawkscode on 26/11/20.
//  Copyright © 2020 Hawkscode. All rights reserved.
//

import UIKit
import Alamofire

class ForgotPassSendEmailController: UIViewController {

    
    
    @IBOutlet weak var mEmail: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapToHide =  UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
                         view.addGestureRecognizer(tapToHide)
                         tapToHide.cancelsTouchesInView = false
      
    }
    
    @IBAction func mBack(_ sender: Any) {
    
        self.navigationController?.popViewController(animated: true)
   
    }
    
    
    @IBAction func mSubmit(_ sender: Any) {
        
        if mEmail.text  == "" {
          
            CommonClass.showSnackBar(message: "Please enter your email")
        
        }else if Validation.isValidEmail(emailString: mEmail.text!) == false {
           
            CommonClass.showSnackBar(message: "Please enter your valid email address")
            
        }else{
            
            mSendEmail()
            
        }
    }
    
    
    func mSendEmail(){
        
  
        
        
          let urlPath = mGetOneTimeCode
        let params:[String:String] = ["email" : mEmail.text!]
        
        print(params)
        
          AF.request(urlPath, method:.post, parameters: params).responseJSON
                             { response in
            
            print("Get One TimeCode = ", response)
                           
                              if(response.error != nil){
                                  
                                  
                              }else{
                                  
                                  let jsonData = response.data
                                  let jsonResult = try? JSONSerialization.jsonObject(with: jsonData!, options:JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
                                
                                if jsonResult?.value(forKey: "message") as! String == "Please check your mail" {
                                  
                                    
                                 
                                    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                    let newViewController = storyBoard.instantiateViewController(withIdentifier: "ForgotPasswordEmailVerifyController") as! ForgotPasswordEmailVerifyController
                                     newViewController.mEmail = self.mEmail.text!
                                    
                                    newViewController.mOTPs = "\(jsonResult?.value(forKey: "confirmationPin") as! Int)"
                                    
                                    self.navigationController?.pushViewController(newViewController, animated:true)
                                     
                                    
                                }else{
                                   
                                CommonClass.showSnackBar(message:"\(jsonResult?.value(forKey: "message")!)")
                                    
                                }
                                
                        
                              }
                          
                      
              }
          

      }
    
}
