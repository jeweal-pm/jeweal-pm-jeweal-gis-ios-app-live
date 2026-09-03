//
//  AppDelegate.swift
//  GIS
//
//  Created by Apple Hawkscode on 15/10/20.
//
 


import UIKit
import IQKeyboardManagerSwift
import Alamofire
import SDWebImage
import SDWebImageSVGCoder
import Intents
import ExternalAccessory

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var orientation =  UIInterfaceOrientationMask.landscape
    
    func applicationWillTerminate(_ application: UIApplication) {
        
        mLogOut()
    }
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
               
        //IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.isEnabled = true

        UIViewController.swizzleLifecycleMethods()
        UITableViewCell.swizzleAwakeFromNib()
        UICollectionViewCell.swizzleAwakeFromNib()
        
        EAAccessoryManager.shared().registerForLocalNotifications()
        
        
        let SVGCoder = SDImageSVGCoder.shared
        SDImageCodersManager.shared.addCoder(SVGCoder)
        
                INPreferences.requestSiriAuthorization { (status) in
                    if status == .authorized {
                        print("the user allows the siri authentication request")
                    }
                }
 
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
    func mLogOut(){
        
        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
        
        let urlPath = mLogOutUser
        let agent = "\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "").\(Bundle.main.infoDictionary?["CFBundleVersion"] ?? "")"
        
        let params:[String:String] = ["token": mUserLoginToken ?? "",
                                      "platform": mGetDeviceInfo() ,
                                      "agent": agent]
        
        if Reachability.isConnectedToNetwork() == true {
            
            AF.request(urlPath, method:.post, parameters: params,encoding: JSONEncoding.default).responseJSON
            { response in
                
                guard response.error == nil else {
                    CommonClass.showSnackBar(message: "OOP's something went wrong!")
                    return
                }
                
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
                    
                }
                
            }
        }else{
        }
        
        
    }
   
   
}

