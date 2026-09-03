//
//  DiscoveryModels.swift
//  GIS
//
//  Created by Jeweal on 7/8/26.
//  Copyright © 2026 Hawkscode. All rights reserved.
//

import Foundation

struct DiscoveryQuestion: Codable {

    let questionId: String

    let title: String

    let subtitle: String?

    let placeholder: String?

    let answers: [String]

}

struct DiscoveryConversation: Codable {

    let conversationId: String

    let finished: Bool

    let nextQuestion: DiscoveryQuestion?

}

struct DiscoveryAnswer {

    let questionId: String
    var answers: [String]

}
