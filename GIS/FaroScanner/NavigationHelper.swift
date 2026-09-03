//
//  NavigationHelper.swift
//  GIS
//
//  Created by Jeweal on 9/8/26.
//  Copyright © 2026 Hawkscode. All rights reserved.
//

import UIKit

enum NavigationHelper {

    static func topNavigationController() -> UINavigationController? {

        guard
            let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = scene.windows.first(where: { $0.isKeyWindow }),
            var root = window.rootViewController
        else {
            return nil
        }

        while let presented = root.presentedViewController {
            root = presented
        }

        if let nav = root as? UINavigationController {
            return nav
        }

        return root.navigationController
    }

}
