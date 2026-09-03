//
//  AppLanguage.swift
//  GIS
//
//  Created by admin on 15/11/21.
//

import Foundation



import UIKit

// Enumeration to represent supported languages
enum Languages {
    case english, arabic, japanese , chinese , thai , russian
}

class AppLanguage {
    
    static let shared = AppLanguage()
    private init() { }
    
    // Bundle for the selected language
    var bundle: Bundle?
    
    // Set the app's language
    func set(index: Languages) {
        switch index {
        case .english:
            // For English Language set LTR
            UserDefaults.standard.setValue("EN", forKey: "LANG")
            selectBundleForResource(forResource: "en", isRTL: false)
            
        case .thai:
            // For English Language set LTR
            UserDefaults.standard.setValue("TH", forKey: "LANG")
            selectBundleForResource(forResource: "th", isRTL: false)
            
        case .chinese:
            // For English Language set LTR
            UserDefaults.standard.setValue("CH", forKey: "LANG")
            
            selectBundleForResource(forResource: "zh-Hans", isRTL: false)
        case .arabic:
            // For RTL Language set RTL
            UserDefaults.standard.setValue("AR", forKey: "LANG")
            
            selectBundleForResource(forResource: "ar", isRTL: true)
            
        case .japanese:
            // For Japanese Language set LTR
            UserDefaults.standard.setValue("JA", forKey: "LANG")
            
            selectBundleForResource(forResource: "ja", isRTL: false)
            
        case .russian:
            // For Russian Language set LTR
            UserDefaults.standard.setValue("RU", forKey: "LANG")
            selectBundleForResource(forResource: "ru", isRTL: false)
            
        }
        
    }
    
    // Select appropriate localization bundle
    private func selectBundleForResource(forResource: String, isRTL: Bool) {
        // Attempt to find the bundle for the specified language resource
        guard let path = Bundle.main.path(forResource: forResource, ofType: "lproj") else {
            // If the bundle is not found, log an error and return
            print("Error: Could not find bundle for language resource: \(String(describing: forResource))")
            return
        }
        self.bundle = Bundle.init(path: path)
        // Update the semantic content attribute based on language direction
        switchViewControllers(isRTL: isRTL)
    }
    
    private func setKeyWindowFromAppDelegate(isRTL: Bool) {
        
        
    }
    
    private func switchViewControllers(isRTL rtl : Bool){
        if rtl {
            // If RTL language, set semantic content attribute to right-to-left
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
        }else{
            // If LTR language, set semantic content attribute to left-to-right
            UIView.appearance().semanticContentAttribute =  .forceLeftToRight
        }
    }
    
    // Get the current language's direction (RTL or LTR)
    func getForceRTL() -> Bool {
        // Retrieve the current language code from user defaults
        let lang = UserDefaults.standard.string(forKey: "LANG")
        // Check if the language code corresponds to an RTL language
        return lang == "AR"
    }
}

public extension String {
    var localizedString : String {
        get {
            // Get localized string for the current language
            return self.toLocal()
        }
    }
}

private extension String {
    func toLocal() -> String {
        // Check if the localization bundle is available
        if let bundle = AppLanguage.shared.bundle {
            // If available, use NSLocalizedString with the bundle
            return NSLocalizedString(self, tableName: "Localization", bundle: bundle, value: "", comment: "")
        }
        // If bundle is not available, return the original string
        return self
    }
}


private var hasSwizzled = false

// Swizzling methods for UIViewController
extension UIViewController {
    
    // Swizzle viewDidLoad to update text alignment
    static func swizzleLifecycleMethods() {
        guard !hasSwizzled else { return }
        hasSwizzled = true
        
        let originalSelector = #selector(UIViewController.viewDidLoad)
        let swizzledSelector = #selector(UIViewController.customViewDidLoad)
        
        guard let originalMethod = class_getInstanceMethod(UIViewController.self, originalSelector),
              let swizzledMethod = class_getInstanceMethod(UIViewController.self, swizzledSelector) else { return }
        
        let didAddMethod = class_addMethod(UIViewController.self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
        
        if didAddMethod {
            class_replaceMethod(UIViewController.self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }
    
    // Custom implementation of viewDidLoad
    @objc func customViewDidLoad() {
        self.customViewDidLoad()
        updateTextAlignment()
    }
    
    // Update text alignment based on language direction
    func updateTextAlignment() {
        view.changeTextAlignmentForLabels(isRTL: AppLanguage.shared.getForceRTL())
    }
}

// Extension for UITableViewCell
extension UITableViewCell {
    private static var hasSwizzled: Bool = false
    
    // Swizzle awakeFromNib to update text alignment
    static func swizzleAwakeFromNib() {
        guard !hasSwizzled else { return }
        hasSwizzled = true
        
        let originalSelector = #selector(UITableViewCell.awakeFromNib)
        let swizzledSelector = #selector(UITableViewCell.customAwakeFromNib)
        
        guard let originalMethod = class_getInstanceMethod(UITableViewCell.self, originalSelector),
              let swizzledMethod = class_getInstanceMethod(UITableViewCell.self, swizzledSelector) else { return }
        
        let didAddMethod = class_addMethod(UITableViewCell.self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
        
        if didAddMethod {
            class_replaceMethod(UITableViewCell.self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }
    
    // Custom implementation of awakeFromNib
    @objc private func customAwakeFromNib() {
        self.customAwakeFromNib()
        self.plainView.changeTextAlignmentForLabels(isRTL: AppLanguage.shared.getForceRTL())
    }
}

// Extension for UICollectionViewCell
extension UICollectionViewCell {
    private static var hasSwizzled: Bool = false
    
    // Swizzle awakeFromNib to update text alignment
    static func swizzleAwakeFromNib() {
        guard !hasSwizzled else { return }
        hasSwizzled = true
        
        let originalSelector = #selector(UICollectionViewCell.awakeFromNib)
        let swizzledSelector = #selector(UICollectionViewCell.customAwakeFromNib)
        
        guard  let originalMethod = class_getInstanceMethod(UICollectionViewCell.self, originalSelector),
               let swizzledMethod = class_getInstanceMethod(UICollectionViewCell.self, swizzledSelector) else { return }
        
        let didAddMethod = class_addMethod(UICollectionViewCell.self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
        
        if didAddMethod {
            class_replaceMethod(UICollectionViewCell.self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }
    // Custom implementation of awakeFromNib
    @objc private func customAwakeFromNib() {
        self.customAwakeFromNib()
        self.plainView.changeTextAlignmentForLabels(isRTL: AppLanguage.shared.getForceRTL())
    }
}

// Extension for UIView to change text alignment
extension UIView {
    // Recursively update text alignment for subviews
    func changeTextAlignmentForLabels(isRTL rtl: Bool) {
        for subview in subviews {
            if let label = subview as? UILabel {
                if rtl {
                    if label.textAlignment == .left {
                        label.textAlignment = .right
                    } else if label.textAlignment == .right {
                        label.textAlignment = .left
                    }
                }
            }else {
                subview.changeTextAlignmentForLabels(isRTL: rtl)
            }
        }
    }
}
