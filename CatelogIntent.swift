//
//  CatelogIntent.swift
//  
//
//  Created by Sunil Sharma on 23/10/24.
//

import Foundation
import AppIntents

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
struct CatelogIntent: AppIntent, CustomIntentMigratedAppIntent, PredictableIntent {
    static let intentClassName = "CatelogIntentIntent"

    static var title: LocalizedStringResource = "Catelog Intent"
    static var description = IntentDescription("")

    @Parameter(title: "Id")
    var id: String?

    static var parameterSummary: some ParameterSummary {
        Summary("Search by \(\.$id)")
    }

    static var predictionConfiguration: some IntentPredictionConfiguration {
        IntentPrediction(parameters: (\.$id)) { id in
            DisplayRepresentation(
                title: "Search by \(id!)",
                subtitle: ""
            )
        }
    }

    func perform() async throws -> some IntentResult {
        // TODO: Place your refactored intent handler code here.
        return .result()
    }
}

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
fileprivate extension IntentDialog {
    static func idParameterDisambiguationIntro(count: Int, id: String) -> Self {
        "There are \(count) options matching ‘\(id)’."
    }
    static func idParameterConfirmation(id: String) -> Self {
        "Just to confirm, you wanted ‘\(id)’?"
    }
    static func responseSuccess(searchProduct: String) -> Self {
        "Product is \(searchProduct)"
    }
    static var responseFailure: Self {
        "Somthing wrong please try again!"
    }
}

