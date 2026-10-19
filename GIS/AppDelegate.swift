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
import FirebaseCore
import FirebaseRemoteConfig

private enum GISMinimumVersionGate {
    private static let remoteConfig = RemoteConfig.remoteConfig()
    private static var isPresenting = false

    private static let defaults: [String: NSObject] = [
        // Safe fallback: a Firebase outage must never lock out GIS users.
        "min_supported_version_ios": "0.0.0" as NSString,
        "force_update_ios": false as NSNumber,
        // Set this to GIS's App Store URL in Firebase Remote Config.
        "ios_store_url": "" as NSString,
        "update_title": "Update available" as NSString,
        "update_message": "A newer version of GIS is available. Please update to continue." as NSString,
        "update_remind_days": 3 as NSNumber
    ]

    static func check() {
        remoteConfig.setDefaults(defaults)
        let settings = RemoteConfigSettings()
        // Fetch on each app launch so an urgent minimum version takes effect
        // as soon as it is published in Firebase.
        settings.minimumFetchInterval = 0
        settings.fetchTimeout = 10
        remoteConfig.configSettings = settings

        remoteConfig.fetchAndActivate { _, _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                presentIfRequired()
            }
        }
    }

    private static func presentIfRequired() {
        guard !isPresenting else { return }

        let minimumVersion = remoteConfig["min_supported_version_ios"].stringValue
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let storeURL = remoteConfig["ios_store_url"].stringValue
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.0.0"

        print("minimumVersion = \(minimumVersion)")
        print("currentVersion = \(currentVersion)")
        
        guard !minimumVersion.isEmpty,
              !storeURL.isEmpty,
              compare(currentVersion, to: minimumVersion) == .orderedAscending,
              let url = URL(string: storeURL)
        else { return }

        print("storeURL = \(storeURL)")
        
        let forceUpdate = remoteConfig["force_update_ios"].boolValue
        let reminderDays = max(1, remoteConfig["update_remind_days"].numberValue.intValue)
        let reminderKey = "GISMinimumVersionPrompt.\(minimumVersion)"

        if !forceUpdate,
           let lastPrompt = UserDefaults.standard.object(forKey: reminderKey) as? Date,
           Date().timeIntervalSince(lastPrompt) < Double(reminderDays * 24 * 60 * 60) {
            return
        }

        guard let presenter = topViewController() else { return }
        isPresenting = true
        let title = remoteConfig["update_title"].stringValue.isEmpty
            ? "Update available"
            : remoteConfig["update_title"].stringValue
        let message = remoteConfig["update_message"].stringValue.isEmpty
            ? "A newer version of GIS is available. Please update to continue."
            : remoteConfig["update_message"].stringValue
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        if !forceUpdate {
            alert.addAction(UIAlertAction(title: "Later", style: .cancel) { _ in
                UserDefaults.standard.set(Date(), forKey: reminderKey)
                isPresenting = false
            })
        }
        alert.addAction(UIAlertAction(title: "Update now", style: .default) { _ in
            UIApplication.shared.open(url)
            isPresenting = false
        })
        presenter.present(alert, animated: true)
    }

    private static func compare(_ current: String, to required: String) -> ComparisonResult {
        let parts: (String) -> [Int] = { value in
            value
                .split(whereSeparator: { !$0.isNumber })
                .map { Int($0) ?? 0 }
        }
        let currentParts = parts(current)
        let requiredParts = parts(required)
        let count = max(currentParts.count, requiredParts.count)
        for index in 0..<count {
            let lhs = index < currentParts.count ? currentParts[index] : 0
            let rhs = index < requiredParts.count ? requiredParts[index] : 0
            if lhs != rhs { return lhs < rhs ? .orderedAscending : .orderedDescending }
        }
        return .orderedSame
    }

    private static func topViewController() -> UIViewController? {
        let root = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .rootViewController
        return visibleViewController(from: root)
    }

    private static func visibleViewController(from controller: UIViewController?) -> UIViewController? {
        if let navigation = controller as? UINavigationController {
            return visibleViewController(from: navigation.visibleViewController)
        }
        if let tab = controller as? UITabBarController {
            return visibleViewController(from: tab.selectedViewController)
        }
        if let presented = controller?.presentedViewController {
            return visibleViewController(from: presented)
        }
        return controller
    }
}

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var orientation =  UIInterfaceOrientationMask.landscape
    
    func applicationWillTerminate(_ application: UIApplication) {
        
        mLogOut()
    }
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        GISMinimumVersionGate.check()
               
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

