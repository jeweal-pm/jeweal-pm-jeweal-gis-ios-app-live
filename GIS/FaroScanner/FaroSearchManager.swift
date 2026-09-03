
//
//  FaroSearchManager.swift
//  GIS
//
//  Created by Jeweal on 9/8/26.
//  Copyright © 2026 Hawkscode. All rights reserved.
//

//import Foundation
//
//final class FaroSearchManager {
//
//    static let shared = FaroSearchManager()
//
//    private init() {}
//
//    func performSearch(
//        keyword: String,
//        mode: FaroMode,
//        fallback: @escaping () -> Void,
//        completion: @escaping (Result<FaroResponse, Error>) -> Void
//    ) {
//
//        let text = keyword.trimmingCharacters(
//            in: .whitespacesAndNewlines
//        )
//
//        guard !text.isEmpty else {
//
//            fallback()
//            return
//
//        }
//
//        print("""
//        =====================
//        FARO SEARCH
//        Mode : \(mode)
//        Keyword : \(text)
//        =====================
//        """)
//
//        FaroService.shared.search(
//            query: text,
//            mode: mode
//        ) { result in
//
//            switch result {
//
//            case .success(let response):
//
//                completion(.success(response))
//
//            case .failure(let error):
//
//                print("FARO ERROR :", error)
//
//                fallback()
//
//                completion(.failure(error))
//
//            }
//
//        }
//
//    }
//
//}
