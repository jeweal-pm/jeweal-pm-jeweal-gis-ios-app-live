//
//  PriceHelper.swift
//  GIS
//
//  Created by Jeweal on 20/7/26.
//  Copyright © 2026 Hawkscode. All rights reserved.
//

import Foundation

final class PriceHelper {

    static func formatPrice(_ price: Double, currency: String = "") -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2

        let formatted = formatter.string(from: NSNumber(value: price)) ?? "0.00"

        return currency.isEmpty ? formatted : "\(currency) \(formatted)"
    }

    static func unformatPrice(_ text: String) -> Double {

        let allowed = "0123456789.-"

        let cleaned = text.filter {
            allowed.contains($0)
        }

        return Double(cleaned) ?? 0
    }
    
    static func parsePrice(_ text: String?) -> Double {

        guard let text = text else {
            return 0
        }

        let cleaned = text.filter {
            "0123456789.-,".contains($0)
        }
        .replacingOccurrences(of: ",", with: "")

        return Double(cleaned) ?? 0
    }
}
