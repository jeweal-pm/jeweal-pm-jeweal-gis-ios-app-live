//
//  FaroService.swift
//  GIS
//
//  Created by Jeweal on 9/8/26.
//

import Foundation
import UIKit
import Alamofire

enum FaroMode {
    
    case search
    case discover
}

final class FaroService {
    
    static let shared = FaroService()
    
    private init() {}
    
    
    // MARK: - Search / Discover
    // ---------------------------------------------------------
    
    func search(
        query: String,
        mode: FaroMode,
        inStockOnly: Bool = false,
        completion: @escaping (Result<NSArray, Error>) -> Void
    ) {
        
        let api: String
        
        switch mode {
            
        case .search:
            api = FaroAPI.search
            
        case .discover:
            api = FaroAPI.discover
        }
        
        
        // -----------------------------------------------------
        // Base parameters
        // -----------------------------------------------------
        
        var params: [String: Any] = [
            "distill": FaroConfiguration.distill,
            "limit": FaroConfiguration.limit
        ]
        
        
        // -----------------------------------------------------
        // Search / Discover parameters
        // -----------------------------------------------------
        
        switch mode {
            
        case .search:
            
            params["queryText"] = query
            
        case .discover:
            
            params["intent"] = query
        }
        
        
        // -----------------------------------------------------
        // IMPORTANT
        //
        // filters.inStock MUST ONLY EXIST WHEN
        // In stock only button is ON.
        // -----------------------------------------------------
        
        if inStockOnly {
            
            params["filters"] = [
                "inStock": true
            ]
        }
        
        
        // -----------------------------------------------------
        // Debug
        // -----------------------------------------------------
        
        print("""
        
        ==========================
        FARO REQUEST
        ==========================
        Mode        : \(mode)
        Query       : \(query)
        InStockOnly : \(inStockOnly)
        Params      : \(params)
        ==========================
        
        """)
        
        
        // -----------------------------------------------------
        // Request
        // -----------------------------------------------------
        
        AF.request(
            api,
            method: .post,
            parameters: params,
            encoding: JSONEncoding.default,
            headers: sGisHeaders
        )
        .responseJSON { response in
            
            print("HTTP =", response.response?.statusCode ?? -1)
            
            guard let json = response.value as? NSDictionary else {
                
                if let error = response.error {
                    
                    completion(.failure(error))
                    
                } else {
                    
                    completion(
                        .failure(
                            NSError(
                                domain: "Faro",
                                code: -1,
                                userInfo: [
                                    NSLocalizedDescriptionKey:
                                        "Invalid response"
                                ]
                            )
                        )
                    )
                }
                
                return
            }
            
            
            print("""
            
            ==========================
            FARO RESPONSE
            ==========================
            \(json)
            ==========================
            
            """)
            
            
            // -------------------------------------------------
            // Check API code
            // -------------------------------------------------
            
            if let code = json["code"] as? Int,
               code != 200 {
                
                let message =
                    "\(json["message"] ?? "Unknown error")"
                
                print("""
                
                ==========================
                FARO FAILED
                ==========================
                \(message)
                ==========================
                
                """)
                
                let error = NSError(
                    domain: "Faro",
                    code: code,
                    userInfo: [
                        NSLocalizedDescriptionKey: message
                    ]
                )
                
                completion(.failure(error))
                
                return
            }
            
            
            // -------------------------------------------------
            // Extract products
            // -------------------------------------------------
            
            let products = self.extractProducts(from: json)
            
            print("""
            
            ==========================
            FARO SUCCESS
            ==========================
            Mode        : \(mode)
            Query       : \(query)
            InStockOnly : \(inStockOnly)
            Products    : \(products.count)
            ==========================
            
            """)
            
            completion(.success(products))
        }
    }
    
    
    // MARK: - Image Search
    // ---------------------------------------------------------
    
    func searchImage(
        image: UIImage,
        completion: @escaping (Result<NSArray, Error>) -> Void
    ) {
        
        guard let imageData = image.pngData() else {
            
            completion(
                .failure(
                    NSError(
                        domain: "Faro",
                        code: -1,
                        userInfo: [
                            NSLocalizedDescriptionKey:
                                "Unable to convert image."
                        ]
                    )
                )
            )
            
            return
        }
        
        
        let base64 =
            "data:image/png;base64," +
            imageData.base64EncodedString()
        
        
        let params: [String: Any] = [
            "distill": FaroConfiguration.distill,
            "limit": FaroConfiguration.limit,
            "queryImageBase64": base64
        ]
        
        
        print("""
        
        ==========================
        FARO IMAGE SEARCH
        ==========================
        ImageSize : \(imageData.count) bytes
        ==========================
        
        """)
        
        
        AF.request(
            FaroAPI.search,
            method: .post,
            parameters: params,
            encoding: JSONEncoding.default,
            headers: sGisHeaders
        )
        .responseJSON { response in
            
            print(
                "HTTP =",
                response.response?.statusCode ?? -1
            )
            
            
            guard let json = response.value as? NSDictionary else {
                
                if let error = response.error {
                    
                    completion(.failure(error))
                    
                } else {
                    
                    completion(
                        .failure(
                            NSError(
                                domain: "Faro",
                                code: -1,
                                userInfo: [
                                    NSLocalizedDescriptionKey:
                                        "Invalid response"
                                ]
                            )
                        )
                    )
                }
                
                return
            }
            
            
            if let code = json["code"] as? Int,
               code != 200 {
                
                let error = NSError(
                    domain: "Faro",
                    code: code,
                    userInfo: [
                        NSLocalizedDescriptionKey:
                            "\(json["message"] ?? "Unknown")"
                    ]
                )
                
                completion(.failure(error))
                return
            }
            
            
            let products = self.extractProducts(from: json)
            
            print("""
            
            ==========================
            FARO IMAGE SEARCH SUCCESS
            ==========================
            Products : \(products.count)
            ==========================
            
            """)
            
            completion(.success(products))
        }
    }
    
    
    // MARK: - Extract Products
    // ---------------------------------------------------------
    
    private func extractProducts(
        from json: NSDictionary
    ) -> NSArray {
        
        if let products = json["products"] as? NSArray {
            return products
        }
        
        if let data = json["data"] as? NSDictionary,
           let products = data["products"] as? NSArray {
            
            return products
        }
        
        if let results = json["results"] as? NSArray {
            return results
        }
        
        return []
    }
}
