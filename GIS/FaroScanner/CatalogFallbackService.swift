//
//  CatalogFallbackService.swift
//  GIS
//
//  Created by Jeweal on 9/8/26.
//  Copyright © 2026 Hawkscode. All rights reserved.
//

import Alamofire
import Foundation

final class CatalogFallbackService {

    static let shared = CatalogFallbackService()

    private init() { }

//    func search(
//        keyword: String,
//        completion: @escaping (Result<NSArray, Error>) -> Void
//    ) {
//
//        let params = buildCatalogParams(
//            keyword: keyword
//        )
//
//        AF.request(
//            mGetCatalogue,
//            method: .post,
//            parameters: params,
//            encoding: JSONEncoding.default,
//            headers: sGisHeaders
//        )
//        .responseJSON { response in
//
//            guard
//                let json = response.value as? NSDictionary
//            else {
//
//                completion(
//                    .failure(
//                        NSError(
//                            domain: "Catalog",
//                            code: -1
//                        )
//                    )
//                )
//
//                return
//            }
//
//            guard
//                json["code"] as? Int == 200
//            else {
//
//                completion(
//                    .failure(
//                        NSError(
//                            domain: "Catalog",
//                            code: -2
//                        )
//                    )
//                )
//
//                return
//            }
//
//            let data =
//                json["data"] as? NSArray
//                ?? NSArray()
//
//            completion(.success(data))
//
//        }
//
//    }

}
