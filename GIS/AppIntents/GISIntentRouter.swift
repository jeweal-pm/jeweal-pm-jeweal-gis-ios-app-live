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
    private static func currentSceneDelegate() -> SceneDelegate? {
        let delegates = UIApplication.shared.connectedScenes.compactMap { $0.delegate as? SceneDelegate }
        return delegates.first { delegate in
            guard let navigation = delegate.window?.rootViewController as? UINavigationController else { return false }
            // The login screens live in the same navigation stack, so being on one means nobody is signed in yet.
            let top = navigation.topViewController
            return !(top is LoginController) && !(top is LoginWithPin)
        }
    }

    /// The scene delegate, once the app shows its navigation stack (signed in).
    /// When Siri launches the app from cold, the scene is not ready yet, so wait briefly.
    /// The SceneDelegate helpers assume a UINavigationController root, so refuse otherwise.
    private static func readySceneDelegate() async throws -> SceneDelegate {
        for attempt in 0..<20 {
            if let delegate = currentSceneDelegate() { return delegate }
            print("GIS Siri: waiting for the app to be ready (\(attempt))")
            try? await Task.sleep(nanoseconds: 250_000_000)
        }
        print("GIS Siri: app not ready, probably not signed in")
        throw GISIntentError.notSignedIn
    }

    static func openQuickView(id: String) async throws {
        print("GIS Siri: open quick view for \(id)")
        try await readySceneDelegate().navigateToQuickViewSearch(with: id)
        GISRecentItems.record(id)
    }

    static func openCatalog(id: String) async throws {
        print("GIS Siri: open catalog for \(id)")
        try await readySceneDelegate().navigateToCatelog(with: id)
        GISRecentItems.record(id)
    }

    static func openInventory(id: String) async throws {
        print("GIS Siri: open inventory for \(id)")
        try await readySceneDelegate().navigateToInventory(with: id)
        GISRecentItems.record(id)
    }

    static func openStockTake() async throws {
        print("GIS Siri: open stock take")
        try await readySceneDelegate().navigateToStockTake(with: "")
    }
}
