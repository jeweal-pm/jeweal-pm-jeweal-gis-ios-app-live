//
//  CatalogService.swift
//  GIS
//
//  Created by Jeweal on 9/8/26.
//  Copyright © 2026 Hawkscode. All rights reserved.
//

import Foundation
import Alamofire

final class CatalogService {

    static let shared = CatalogService()

    private init() {}

    func search(
        keyword: String,
        completion: @escaping (Result<[NSMutableDictionary], Error>) -> Void
    ) {

        var filter: [String: Any] = [

            "price": [
                "min": "",
                "max": ""
            ],

            "item": [],
            "collection": [],
            "metal": [],
            "stone": [],
            "size": [],
            "specifiedOccasion": [],
            "gender": [],
            "consumerLifestage": [],
            "StockId": []

        ]

        let params: [String: Any] = [

            "search": keyword,
            "type": "catalog",
            "customer_id": "",
            "filter": filter

        ]

        AF.request(
            mGetCatalogue,
            method: .post,
            parameters: params,
            encoding: JSONEncoding.default,
            headers: sGisHeaders
        )

        .responseJSON { response in

            guard response.error == nil else {

                completion(.failure(response.error!))
                return

            }

            guard
                let json = response.value as? NSDictionary,
                let data = json["data"] as? NSArray
            else {

                completion(
                    .success([])
                )
                return

            }

            let products = data.compactMap {

                ($0 as? NSDictionary)?
                    .mutableCopy() as? NSMutableDictionary

            }

            completion(.success(products))

        }

    }

}
