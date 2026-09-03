//
//  SceneDelegate.swift
//  GIS
//
//  Created by Apple Hawkscode on 15/10/20.
//m
// 
 

import UIKit
import Intents
import IntentsUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        print("Received user activity: \(userActivity.activityType)")

        if let userInfo = userActivity.userInfo {
            print("User Info: \(userInfo)")
        } else {
            print("No userInfo found in user activity.")
        }

        switch userActivity.activityType {
        case "group.com.gis247.QuickViewSearch":
            handleQuickViewSearch(userActivity)
        case "group.com.gis247.StockTake":
            handleStockTake(userActivity)
        case "group.com.gis247.Catelog":
            handleCatelog(userActivity)
        case "group.com.gis247.FaceLogin":
            handleFaceLogin(userActivity)
        case "group.com.gis247.BackNavigation":
            handleBackNavigation(userActivity)
        case "group.com.gis247.InvenotryIntent":
            handleInventory(userActivity)
        default:
            print("Unknown user activity type: \(userActivity.activityType)")
        }
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        print("Scene became active.")
        // Uncomment and implement if you have a trigger for donating intents.
        // triggerQuickViewSearchIntent(with: "SB025")
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Bool) -> Bool {
        print("Received user activity: \(userActivity.activityType)")

        switch userActivity.activityType {
        case "group.com.gis247.SiriExtension":
            // Handle Siri extension activity if needed.
            print("Processing Siri extension user activity.")
        default:
            print("Unknown user activity type: \(userActivity.activityType)")
        }

        return true
    }

    private func handleQuickViewSearch(_ userActivity: NSUserActivity) {
        if let id = userActivity.userInfo?["id"] as? String {
            print("Found ID for QuickViewSearch: \(id)")
            navigateToQuickViewSearch(with: id)
        } else {
            print("No ID found in QuickViewSearch user activity.")
        }
    }

    private func handleStockTake(_ userActivity: NSUserActivity) {
        if let id = userActivity.userInfo?["id"] as? String {
            print("Found ID for StockTake: \(id)")
            navigateToStockTake(with: id)
        } else {
            print("No ID found in StockTake user activity.")
        }
    }

    private func handleCatelog(_ userActivity: NSUserActivity) {
        if let id = userActivity.userInfo?["id"] as? String {
            print("Found ID for Catelog: \(id)")
            navigateToCatelog(with: id)
        } else {
            print("No ID found in Catelog user activity.")
        }
    }

    private func handleFaceLogin(_ userActivity: NSUserActivity) {
        print("Handling FaceLogin user activity.")
        navigateToFaceLogin()
    }

    private func handleBackNavigation(_ userActivity: NSUserActivity) {
        print("Handling BackNavigation user activity.")
        navigateToBack()
    }
    
    private func handleInventory(_ userActivity: NSUserActivity) {
        if let id = userActivity.userInfo?["id"] as? String {
            print("Found ID for Catelog: \(id)")
            navigateToInventory(with: id)
        } else {
            print("No ID found in Catelog user activity.")
        }
    }

    func navigateToQuickViewSearch(with id: String) {
        let storyboard = UIStoryboard(name: "Test", bundle: nil)

        // Ensure rootViewController is present
        precondition(window?.rootViewController is UINavigationController, "Root view controller is not a UINavigationController or is nil")

        let navController = window!.rootViewController as! UINavigationController

        if let quickViewSearchVC = storyboard.instantiateViewController(withIdentifier: "QuickViewSearch") as? QuickViewSearch {
            quickViewSearchVC.mSiriID = id
            navController.pushViewController(quickViewSearchVC, animated: true)
        } else {
            print("Error: Could not instantiate QuickViewSearch view controller")
        }
    }

    func navigateToStockTake(with id: String) {
        let storyboard = UIStoryboard(name: "stockBoard", bundle: nil)

        // Ensure rootViewController is present
        precondition(window?.rootViewController is UINavigationController, "Root view controller is not a UINavigationController or is nil")

        let navController = window!.rootViewController as! UINavigationController

        if let stockTakeVC = storyboard.instantiateViewController(withIdentifier: "StockTakePage") as? StockTakePage {
            stockTakeVC.SiriID = id
            navController.pushViewController(stockTakeVC, animated: true)
        } else {
            print("Error: Could not instantiate StockTake view controller")
        }
    }
    
    func navigateToInventory(with id: String) {
        let storyboard = UIStoryboard(name: "reserveBoard", bundle: nil)

        // Ensure rootViewController is present
        precondition(window?.rootViewController is UINavigationController, "Root view controller is not a UINavigationController or is nil")

        let navController = window!.rootViewController as! UINavigationController

        if let stockTakeVC = storyboard.instantiateViewController(withIdentifier: "InventoryPageNew") as? InventoryPage {
            stockTakeVC.SiriID = id
            navController.pushViewController(stockTakeVC, animated: true)
        } else {
            print("Error: Could not instantiate StockTake view controller")
        }
    }

    func navigateToCatelog(with id: String) {
        let storyboard = UIStoryboard(name: "catalog", bundle: nil)

        // Ensure rootViewController is present
        precondition(window?.rootViewController is UINavigationController, "Root view controller is not a UINavigationController or is nil")

        let navController = window!.rootViewController as! UINavigationController

        if let catelogVC = storyboard.instantiateViewController(withIdentifier: "POSCatalogNew") as? POSCatalog {
            catelogVC.SiriID = id // Assuming CatelogViewController has a property called catelogId
            navController.pushViewController(catelogVC, animated: true)
        } else {
            print("Error: Could not instantiate Catelog view controller")
        }
    }

    func navigateToFaceLogin() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        // Ensure rootViewController is present
        precondition(window?.rootViewController is UINavigationController, "Root view controller is not a UINavigationController or is nil")

        let navController = window!.rootViewController as! UINavigationController

        if let faceLoginVC = storyboard.instantiateViewController(withIdentifier: "LoginWithPin") as? LoginWithPin {
            navController.pushViewController(faceLoginVC, animated: true)
        } else {
            print("Error: Could not instantiate FaceLogin view controller")
        }
    }
    
    
    func navigateToBack() {
        let storyboard = UIStoryboard(name: "reserveBoard", bundle: nil)

        // Ensure rootViewController is present
        precondition(window?.rootViewController is UINavigationController, "Root view controller is not a UINavigationController or is nil")

        let navController = window!.rootViewController as! UINavigationController

        if let faceLoginVC = storyboard.instantiateViewController(withIdentifier: "HomePage1") as? HomePage {
            navController.pushViewController(faceLoginVC, animated: true)
        } else {
            print("Error: Could not instantiate FaceLogin view controller")
        }
    }

     
    // Ensure the navigateBack method is correct
 
    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
}
