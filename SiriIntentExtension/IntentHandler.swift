//
//  IntentHandler.swift
//  SiriIntentExtension
//
//  Created by Sunil Sharma on 17/10/24.
//  Copyright © 2024 Hawkscode. All rights reserved.
//




import Intents
import IntentsUI
import os

// MARK: - IntentHandler Class
class IntentHandler: INExtension {
    
    // MARK: - Providing the Handler for a Specific Intent
    override func handler(for intent: INIntent) -> Any {
        os_log("IntentHandler: Checking intent type...", log: .default, type: .info)
        print("IntentHandler: Received intent: \(intent)")
        
        if intent is QuickViewSearchIntent {
            os_log("IntentHandler: Handling QuickViewSearchIntent", log: .default, type: .info)
            return self
        } else if intent is StockTakeIntent {
            os_log("IntentHandler: Handling StockTakeIntent", log: .default, type: .info)
            return self
        }else if intent is CatelogIntentIntent {
            os_log("IntentHandler: Handling CatelogIntent", log: .default, type: .info)
            return self
        }else if intent is InventoryIntent {
            os_log("IntentHandler: Handling InventoryIntent", log: .default, type: .info)
            return self
        }else if intent is BackNavigateIntent {
            os_log("IntentHandler: Handling CatelogIntent", log: .default, type: .info)
            return self
        }else if intent is FaceLoginIntent {
            os_log("IntentHandler: Handling FaceLoginIntent", log: .default, type: .info)
            return self
        }
        
        print("IntentHandler: No matching intent found.")
        return self // Handle other intents if necessary
    }
}

// MARK: - QuickViewSearchIntent Handling Extension
extension IntentHandler: QuickViewSearchIntentHandling {
    
    // MARK: - Resolve ID (Sync and Async)
    func resolveId(for intent: QuickViewSearchIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
        print("IntentHandler: resolveId() invoked with ID: \(String(describing: intent.id))")
        os_log("IntentHandler: Resolving ID...", log: .default, type: .info)
        
        if let id = intent.id, !id.isEmpty {
            print("IntentHandler: ID resolved successfully.")
            completion(.success(with: id))
        } else {
            print("IntentHandler: No ID provided, prompting for value.")
            completion(.needsValue()) // Ask Siri to prompt the user for the ID
        }
    }
        
    // MARK: - Handle Method
    func handle(intent: QuickViewSearchIntent, completion: @escaping (QuickViewSearchIntentResponse) -> Void) {
        guard let id = intent.id, !id.isEmpty else {
            let response = QuickViewSearchIntentResponse(code: .failure, userActivity: nil)
            completion(response)
            return
        }
         
        // Create user activity to pass data to the app
        let userActivity = NSUserActivity(activityType: "group.com.gis247.QuickViewSearch")
        userActivity.userInfo = ["id": id]
        userActivity.title = "Quick View"
        userActivity.isEligibleForHandoff = true
        userActivity.isEligibleForSearch = true
        userActivity.isEligibleForPublicIndexing = true
        userActivity.requiredUserInfoKeys = ["id"]
        
        // Create the continueInApp response
        let response = QuickViewSearchIntentResponse(code: .continueInApp, userActivity: userActivity)
        completion(response)
    }
    
    // MARK: - Helper Method to Add ID in quick View
    private func addBill(id: String) -> Int {
        var data: [[String: Any]] = []
        let newBill = ["id": id]
        
        print("IntentHandler: Adding new bill: \(newBill)")
        os_log("IntentHandler: Adding new bill...", log: .default, type: .info)
        
        guard let userDefaults = UserDefaults(suiteName: "group.com.gis247.SiriExtension") else {
            print("IntentHandler: Failed to access UserDefaults.")
            return 0
        }
        
        // Synchronize access to avoid desync issues
        DispatchQueue.global(qos: .userInitiated).sync {
            if let existingBills = userDefaults.array(forKey: "BillData") as? [[String: Any]] {
                data = existingBills
                print("IntentHandler: Existing bills: \(data)")
            }
            
            data.append(newBill) // Append the new bill
            userDefaults.set(data, forKey: "BillData")
            userDefaults.synchronize()  // Force write immediately (use with caution)
            print("IntentHandler: BillData saved. New data: \(data)")
        }
        
        return data.count
    }
}

// MARK: - StockTakeIntent Handling Extension
extension IntentHandler: StockTakeIntentHandling {
    
    // MARK: - Resolve ID (Sync)
    func resolveId(for intent: StockTakeIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
        print("IntentHandler: resolveId() invoked with ID: \(String(describing: intent.id))")
        os_log("IntentHandler: Resolving ID...", log: .default, type: .info)
        
        if let id = intent.id, !id.isEmpty {
            print("IntentHandler: ID resolved successfully.")
            completion(.success(with: id))
        } else {
            print("IntentHandler: No ID provided, prompting for value.")
            completion(.needsValue()) // Ask Siri to prompt the user for the ID
        }
    }
    
    // MARK: - Handle Method for StockTakeIntent
    
    
    func handle(intent: StockTakeIntent, completion: @escaping (StockTakeIntentResponse) -> Void) {
        guard let id = intent.id, !id.isEmpty else {
            let response = StockTakeIntentResponse(code: .failure, userActivity: nil)
            completion(response)
            return
        }
        
        let itemCount = addStock(id: id)
        let successMessage = "Total invoices: \(itemCount)"
        
        // Create user activity to pass data to the app
        let userActivity = NSUserActivity(activityType: "group.com.gis247.StockTake")
        userActivity.userInfo = ["id": id]
        userActivity.title = "Stock Take"
        userActivity.isEligibleForHandoff = true
        userActivity.isEligibleForSearch = true
        userActivity.isEligibleForPublicIndexing = true
        userActivity.requiredUserInfoKeys = ["id"]
        
        // Create the continueInApp response
        let response = StockTakeIntentResponse(code: .continueInApp, userActivity: userActivity)
        completion(response)
    }
    
    // MARK: - Helper Method to Add Stock
    private func addStock(id: String) -> Int {
        var data: [[String: Any]] = []
        let newBill = ["id": id]
        
        print("IntentHandler: Adding new bill: \(newBill)")
        os_log("IntentHandler: Adding new bill...", log: .default, type: .info)
        
        guard let userDefaults = UserDefaults(suiteName: "group.com.gis247.SiriExtension") else {
            print("IntentHandler: Failed to access UserDefaults.")
            return 0
        }
        
        // Synchronize access to avoid desync issues
        DispatchQueue.global(qos: .userInitiated).sync {
            if let existingBills = userDefaults.array(forKey: "BillData") as? [[String: Any]] {
                data = existingBills
                print("IntentHandler: Existing bills: \(data)")
            }
            
            data.append(newBill) // Append the new bill
            userDefaults.set(data, forKey: "BillData")
            userDefaults.synchronize()  // Force write immediately (use with caution)
            print("IntentHandler: BillData saved. New data: \(data)")
        }
        
        return data.count
    }
}

// MARK: - catelog Intent Handling Extension
extension IntentHandler: CatelogIntentIntentHandling {
    
    // MARK: - Resolve ID (Sync)
    func resolveId(for intent: CatelogIntentIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
        print("IntentHandler: resolveId() invoked with ID: \(String(describing: intent.id))")
        os_log("IntentHandler: Resolving ID...", log: .default, type: .info)
        
        if let id = intent.id, !id.isEmpty {
            print("IntentHandler: ID resolved successfully.")
            completion(.success(with: id))
        } else {
            print("IntentHandler: No ID provided, prompting for value.")
            completion(.needsValue()) // Ask Siri to prompt the user for the ID
        }
    }
    
    // MARK: - Handle Method for Catelog Intent
    
    
    func handle(intent: CatelogIntentIntent, completion: @escaping (CatelogIntentIntentResponse) -> Void) {
        guard let id = intent.id, !id.isEmpty else {
            let response = CatelogIntentIntentResponse(code: .failure, userActivity: nil)
            completion(response)
            return
        }
        
        let itemCount = addCatelog(id: id)
        let successMessage = "Total invoices: \(itemCount)"
        
        // Create user activity to pass data to the app
        let userActivity = NSUserActivity(activityType: "group.com.gis247.Catelog")
        userActivity.userInfo = ["id": id]
        userActivity.title = "Catelog"
        userActivity.isEligibleForHandoff = true
        userActivity.isEligibleForSearch = true
        userActivity.isEligibleForPublicIndexing = true
        userActivity.requiredUserInfoKeys = ["id"]
        
        // Create the continueInApp response
        let response = CatelogIntentIntentResponse(code: .continueInApp, userActivity: userActivity)
        completion(response)
    }
    
    
    // MARK: - Helper Method to Add Stock
    private func addCatelog(id: String) -> Int {
        var data: [[String: Any]] = []
        let newBill = ["id": id]
        
        print("IntentHandler: Adding new bill: \(newBill)")
        os_log("IntentHandler: Adding new bill...", log: .default, type: .info)
        
        guard let userDefaults = UserDefaults(suiteName: "group.com.gis247.SiriExtension") else {
            print("IntentHandler: Failed to access UserDefaults.")
            return 0
        }
        
        // Synchronize access to avoid desync issues
        DispatchQueue.global(qos: .userInitiated).sync {
            if let existingBills = userDefaults.array(forKey: "BillData") as? [[String: Any]] {
                data = existingBills
                print("IntentHandler: Existing bills: \(data)")
            }
            
            data.append(newBill) // Append the new bill
            userDefaults.set(data, forKey: "BillData")
            userDefaults.synchronize()  // Force write immediately (use with caution)
            print("IntentHandler: BillData saved. New data: \(data)")
        }
        
        return data.count
    }
}



// MARK: - Ineventory Intent Handling Extension
extension IntentHandler: InventoryIntentHandling {
    
    // MARK: - Resolve ID (Sync)n
    func resolveId(for intent: InventoryIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
        print("IntentHandler: resolveId() invoked with ID: \(String(describing: intent.id))")
        os_log("IntentHandler: Resolving ID...", log: .default, type: .info)
        
        if let id = intent.id, !id.isEmpty {
            print("IntentHandler: ID resolved successfully.")
            completion(.success(with: id))
        } else {
            print("IntentHandler: No ID provided, prompting for value.")
            completion(.needsValue()) // Ask Siri to prompt the user for the ID
        }
    }
    
    // MARK: - Handle Method for StockTakeIntent
    
    
    func handle(intent: InventoryIntent, completion: @escaping (InventoryIntentResponse) -> Void) {
        guard let id = intent.id, !id.isEmpty else {
            let response = InventoryIntentResponse(code: .failure, userActivity: nil)
            completion(response)
            return
        }
        
        let itemCount = addInventory(id: id)
        let successMessage = "Total invoices: \(itemCount)"
        
        // Create user activity to pass data to the app
        let userActivity = NSUserActivity(activityType: "group.com.gis247.InvenotryIntent")
        userActivity.userInfo = ["id": id]
        userActivity.title = "Inventory"
        userActivity.isEligibleForHandoff = true
        userActivity.isEligibleForSearch = true
        userActivity.isEligibleForPublicIndexing = true
        userActivity.requiredUserInfoKeys = ["id"]
        
        // Create the continueInApp response
        let response = InventoryIntentResponse(code: .continueInApp, userActivity: userActivity)
        completion(response)
    }
    
    
    // MARK: - Helper Method to Add Stock
    private func addInventory(id: String) -> Int {
        var data: [[String: Any]] = []
        let newBill = ["id": id]
        
        print("IntentHandler: Adding new bill: \(newBill)")
        os_log("IntentHandler: Adding new bill...", log: .default, type: .info)
        
        guard let userDefaults = UserDefaults(suiteName: "group.com.gis247.SiriExtension") else {
            print("IntentHandler: Failed to access UserDefaults.")
            return 0
        }
        
        // Synchronize access to avoid desync issues
        DispatchQueue.global(qos: .userInitiated).sync {
            if let existingBills = userDefaults.array(forKey: "BillData") as? [[String: Any]] {
                data = existingBills
                print("IntentHandler: Existing bills: \(data)")
            }
            
            data.append(newBill) // Append the new bill
            userDefaults.set(data, forKey: "BillData")
            userDefaults.synchronize()  // Force write immediately (use with caution)
            print("IntentHandler: BillData saved. New data: \(data)")
        }
        
        return data.count
    }
}


// MARK: - FaceLogin Intent Handling Extension

extension IntentHandler: FaceLoginIntentHandling {
    
    // MARK: - Handle Method for FaceLoginIntent
    func handle(intent: FaceLoginIntent, completion: @escaping (FaceLoginIntentResponse) -> Void) {
        print("IntentHandler: Handling FaceLoginIntent")
        
        // Create user activity to pass data to the app for navigation
        let userActivity = NSUserActivity(activityType: "group.com.gis247.FaceLogin")
        userActivity.title = "Face Login"
        userActivity.isEligibleForHandoff = true
        userActivity.isEligibleForSearch = true
        userActivity.isEligibleForPublicIndexing = true
        
        // Create the continueInApp response
        let response = FaceLoginIntentResponse(code: .continueInApp, userActivity: userActivity)
        completion(response)
        
        print("IntentHandler: FaceLoginIntent handled, navigating to the app.")
    }
}


// MARK: - Back Navigation Intent Handling Extension

extension IntentHandler: BackNavigateIntentHandling {
    
    // MARK: - Handle Method for FaceLoginIntent
    func handle(intent: BackNavigateIntent, completion: @escaping (BackNavigateIntentResponse) -> Void) {
        print("IntentHandler: Handling FaceLoginIntent")
        
        // Create user activity to pass data to the app for navigation
        let userActivity = NSUserActivity(activityType: "group.com.gis247.BackNavigation")
        userActivity.title = "Back Home"
        userActivity.isEligibleForHandoff = true
        userActivity.isEligibleForSearch = true
        userActivity.isEligibleForPublicIndexing = true
        
        // Create the continueInApp response
        let response = BackNavigateIntentResponse(code: .continueInApp, userActivity: userActivity)
        completion(response)
        
        print("IntentHandler: FaceLoginIntent handled, navigating to the app.")
    }
}
 
