//
//  FaroScannerViewController.swift
//  GIS
//
//  Created by Jeweal on 3/8/26.
//  Copyright © 2026 Hawkscode. All rights reserved.
//

import SwiftUI

class FaroScannerViewController:
                                    
                                    
UIHostingController<FaroScannerView> {

//    var onOpenCreateYourOwn:
//    (([NSMutableDictionary]) -> Void)?
    var onClose: (() -> Void)?

    required init?(coder: NSCoder) {

        fatalError()

    }

    init() {

        super.init(

            rootView:

                FaroScannerView(

                    onSearch: { _ in },

                    onContinue: { _ in },
                    
                    onClose: {}

                )

        )
        
        rootView = FaroScannerView(

            onSearch: { _ in },

            onContinue: { [weak self] products in

                self?.openCreateYourOwn(products)

            },

            onClose: { [weak self] in

                self?.dismiss(animated: true)

            }

        )

//        rootView = FaroScannerView(
//
//            onSearch: { _ in },
//
//            onContinue: { [weak self] products in
//
//                self?.openCreateYourOwn(products)
//
//            }
//
//        )

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        print("SELF =", self)
        print("PRESENTING =", presentingViewController as Any)
        print("NAV =", navigationController as Any)
    }
    
    private func openCreateYourOwn(
        _ products: [NSMutableDictionary]
    ) {

        let storyboard = UIStoryboard(
            name: "customOrder",
            bundle: nil
        )

        guard let cart = storyboard.instantiateViewController(
            withIdentifier: "CustomCart"
        ) as? CustomCart else {
            return
        }

        cart.mPendingProducts = products

        navigationController?.pushViewController(
            cart,
            animated: true
        )
    }

}
