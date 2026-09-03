//
//  NavigationRouter.swift
//  GIS
//
//  Created by Sunil Sharma on 22/10/24.
//  Copyright © 2024 Hawkscode. All rights reserved.
//

import Foundation
import UIKit

class NavigationRouter {
    static let shared = NavigationRouter()

    private init() {}

    func navigateTo(viewControllerID: String, with id: String, from rootViewController: UIViewController) {
        let storyboard = UIStoryboard(name: "Test", bundle: nil)
        guard let targetVC = storyboard.instantiateViewController(withIdentifier: viewControllerID) as? QuickViewSearch else {
            print("Failed to instantiate \(viewControllerID)")
            return
        }

        targetVC.mSiriID = id // Pass the Siri ID

        if let navigationController = rootViewController.navigationController {
            navigationController.pushViewController(targetVC, animated: true)
        } else if let presentedVC = rootViewController.presentedViewController {
            presentedVC.present(targetVC, animated: true, completion: nil)
        } else {
            rootViewController.present(targetVC, animated: true, completion: nil)
        }
    }
}
