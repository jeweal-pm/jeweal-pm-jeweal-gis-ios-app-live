//
//  CatalogMapper.swift
//  GIS
//
//  Created by Jeweal on 7/8/26.
//  Copyright © 2026 Hawkscode. All rights reserved.
//

import Foundation

final class CatalogMapper {

    static func map(_ data: NSDictionary) -> NSMutableDictionary {

        let product = NSMutableDictionary()

        // Product ID
        product["product_id"] =
            data["product_id"] ??
            data["mother_product_id"] ??
            ""

        // SKU
        product["SKU"] =
            data["SKU"] ??
            data["sku"] ??
            ""

        // Name
        product["name"] =
            data["name"] ??
            ""

        // Image
        product["main_image"] =
            data["main_image"] ??
            data["imageUrl"] ??
            ""

        // Price
        if let price = data["price"] as? NSDictionary {

            product["price"] =
                "\(price["formatted"] ?? "")"

        } else {

            product["price"] =
                "\(data["price"] ?? "")"

        }

        // Wishlist
        product["isWishlist"] =
            data["isWishlist"] ??
            "0"

        // Status
        product["status_type"] =
            data["status_type"] ??
            ""

        // Design
        product["is_design"] =
            data["is_design"] ??
            false

        return product

    }

}
