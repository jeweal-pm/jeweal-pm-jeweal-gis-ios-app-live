//
//  FaroMapper.swift
//  GIS
//
//  Created by Jeweal on 7/8/26.
//  Copyright © 2026 Hawkscode. All rights reserved.
//

class FaroMapper {

    static func mapProduct(_ product: NSDictionary) -> NSMutableDictionary {

        let mapped = NSMutableDictionary()

        mapped["product_id"] = product["mother_product_id"] ?? ""
        mapped["SKU"] = product["sku"] ?? ""
        mapped["name"] = product["name"] ?? ""
        mapped["main_image"] = product["imageUrl"] ?? ""

//        if let price = product["price"] as? NSDictionary {
//            mapped["price"] = price["formatted"] ?? ""
//        }
        
//        if let price = product["price"] as? NSDictionary {
//
//            mapped["price"] = price["formatted"] ?? ""
//
//        } else {
//
//            mapped["price"] = product["price"] ?? ""
//
//        }
        
        if let price = product["price"] as? NSDictionary {
            let amount = price["formatted"] as? String ?? ""
            let currency = price["currency"] as? String ?? "$"

            switch currency.uppercased() {
            case "THB":
                mapped["price"] = "฿ \(amount)"

            case "USD":
                mapped["price"] = "$ \(amount)"

            default:
                mapped["price"] = "\(currency) \(amount)"
            }

        } else {
            mapped["price"] = product["price"] ?? ""
        }

        mapped["variants"] = product["variants"] ?? []

        
        // MARK: - Metals
        if let metals = product["metals"] as? [NSDictionary],
           !metals.isEmpty {

            mapped["metals"] = metals

        } else if let motherMetal = product["mother_metal"] as? String,
                  !motherMetal.isEmpty {

            mapped["metals"] = [
                [
                    "label": motherMetal,
                    "value": ""
                ]
            ]

        } else {

            mapped["metals"] = []

        }

        // MARK: - Stones
        if let stones = product["stones"] as? [NSDictionary],
           !stones.isEmpty {

            mapped["stones"] = stones

        } else if let motherStone = product["mother_stone"] as? String,
                  !motherStone.isEmpty {

            mapped["stones"] = [
                [
                    "label": motherStone,
                    "value": ""
                ]
            ]

        } else {

            mapped["stones"] = []

        }

        // MARK: - Sizes
        if let sizes = product["sizes"] as? [NSDictionary],
           !sizes.isEmpty {

            mapped["sizes"] = sizes

        } else if let motherSize = product["mother_size"] as? String,
                  !motherSize.isEmpty {

            mapped["sizes"] = [
                [
                    "label": motherSize,
                    "value": ""
                ]
            ]

        } else {

            mapped["sizes"] = []

        }

        print("========== MAPPED PRODUCT ==========")
        print(mapped)
        print("====================================")
        
        return mapped
    }

}
