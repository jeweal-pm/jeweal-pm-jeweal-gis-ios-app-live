//
//  FaroSuggestions.swift
//  GIS
//
//  Created by Jeweal on 10/8/26.
//  Copyright © 2026 Hawkscode. All rights reserved.
//

import Foundation

enum FaroSuggestions {

    static let park = [
        "Hold for 30 minutes",
        "Parked until customer is ready",
        "Resume after customer confirmation",
        "Manager approval"
    ]

    static let quote = [
        "Valid for 1 week",
        "Price subject to design changes",
        "Review before confirmation",
        "Custom engraving included"
    ]

    static var reserve: [String] {

        let tomorrow = Calendar.current.date(
            byAdding: .day,
            value: 1,
            to: Date()
        ) ?? Date()

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "d MMM yyyy"

        let tomorrowText = formatter.string(from: tomorrow)

        return [
            "Pickup on \(tomorrowText), 2:00 PM",
            "On hold until closing time",
            "Customer response",
            "Payment verification"
        ]
    }
}
