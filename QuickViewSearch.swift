//
//  QuickViewSearch.swift
//  
//
//  Created by Sunil Sharma on 17/10/24.
//

import Foundation
import AppIntents

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
struct QuickViewSearch: AppIntent, CustomIntentMigratedAppIntent, PredictableIntent {
    static let intentClassName = "QuickViewSearchIntent"

    static var title: LocalizedStringResource = "Quick View Search"
    static var description = IntentDescription(
        "Search products using Quick View."
    )

    @Parameter(title: "Id")
    var id: String?

    static var parameterSummary: some ParameterSummary {
        Summary("search by \(\.$id)")
    }

    static var predictionConfiguration: some IntentPredictionConfiguration {
        IntentPrediction(parameters: (\.$id)) { id in
            DisplayRepresentation(
                title: "search by \(id!)",
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
    static func idParameterPrompt(id: String) -> Self {
        "search by \(id)"
    }
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
        "Somthing Went wrong please try again "
    }
}

