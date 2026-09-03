//
//  POSTabBarController.swift
//  GIS
//
//  Created by Apple Hawkscode on 01/04/21.
//

import UIKit

class POSTabBarController: UITabBarController,UITabBarControllerDelegate {

    var mIndex = 2
    override func viewDidLoad() {
        super.viewDidLoad()
        posTabBarInstance = self
        self.selectedIndex = mIndex
        self.delegate = self
        self.tabBar.items?[0].title = "Catalog".localizedString
        self.tabBar.items?[1].title = "Inventory".localizedString
        self.tabBar.items?[3].title = "Customer".localizedString
        self.tabBar.items?[4].title = "More".localizedString
    
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
       
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
    
        let mIndex = tabBarController.viewControllers?.firstIndex(of:viewController)!

    
    }

   
    

}
