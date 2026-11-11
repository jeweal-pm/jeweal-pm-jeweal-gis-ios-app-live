//
//  GISIntentRouter.swift
//  GIS
//
//  Bridges App Intents to the existing SceneDelegate navigation helpers.
//

import AppIntents
import UIKit

enum GISIntentError: Error, CustomLocalizedStringResourceConvertible {
    case notSignedIn

    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .notSignedIn:
            return "Please sign in to GIS first."
        }
    }
}

@MainActor
enum GISIntentRouter {
    /// The scene delegate, only when the app is signed in and showing its navigation stack.
    /// The SceneDelegate helpers assume a UINavigationController root, so refuse otherwise.
    private static func readySceneDelegate() throws -> SceneDelegate {
        guard let delegate = UIApplication.shared.connectedScenes
            .compactMap({ $0.delegate as? SceneDelegate }).first,
            delegate.window?.rootViewController is UINavigationController else {
            throw GISIntentError.notSignedIn
        }
        return delegate
    }

    static func openQuickView(id: String) throws {
        try readySceneDelegate().navigateToQuickViewSearch(with: id)
        GISRecentItems.record(id)
    }

    static func openCatalog(id: String) throws {
        try readySceneDelegate().navigateToCatelog(with: id)
        GISRecentItems.record(id)
    }

    static func openInventory(id: String) throws {
        try readySceneDelegate().navigateToInventory(with: id)
        GISRecentItems.record(id)
    }

    static func openStockTake() throws {
        try readySceneDelegate().navigateToStockTake(with: "")
    }
}
