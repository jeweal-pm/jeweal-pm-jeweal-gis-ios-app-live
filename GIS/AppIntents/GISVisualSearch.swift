//
//  GISVisualSearch.swift
//  GIS
//
//  iOS 26+: lets Visual Intelligence (camera / screenshot search) return GIS items.
//  The system gives us descriptive labels for what it sees; we look them up with the
//  same Faro search the in-app scanner uses and return the matching stock items.
//

import AppIntents
#if canImport(VisualIntelligence)
import VisualIntelligence
#endif

// The VisualIntelligence framework is not present in every SDK slice (e.g. the simulator),
// so the query is only compiled where it can be imported.
#if canImport(VisualIntelligence)
@available(iOS 26.0, *)
struct GISVisualQuery: IntentValueQuery {
    func values(for input: SemanticContentDescriptor) async throws -> [GISItemEntity] {
        let text = input.labels.joined(separator: " ").trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return [] }

        let products = try await GISVisualSearch.search(text: text)
        var seen = Set<String>()
        return products.compactMap { product in
            guard let sku = (product["sku"] as? String) ?? (product["SKU"] as? String),
                  !sku.isEmpty, seen.insert(sku).inserted else { return nil }
            return GISItemEntity(id: sku)
        }
    }
}

#endif

enum GISVisualSearch {
    /// Bridges the callback based FaroService to async/await.
    static func search(text: String) async throws -> [NSDictionary] {
        try await withCheckedThrowingContinuation { continuation in
            FaroService.shared.search(query: text, mode: .search) { result in
                switch result {
                case .success(let products):
                    continuation.resume(returning: products.compactMap { $0 as? NSDictionary })
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

/// Makes a Visual Intelligence result tappable: opens the item in Quick View.
@available(iOS 16.0, *)
struct OpenGISItemIntent: OpenIntent {
    static var title: LocalizedStringResource = "Open Item"

    // Navigates the UI, so the app must be in the foreground (see GISForegroundIntent).
    static var openAppWhenRun: Bool { true }

    @available(iOS 26.0, *)
    static var supportedModes: IntentModes { .foreground }

    @Parameter(title: "Item")
    var target: GISItemEntity

    @MainActor
    func perform() async throws -> some IntentResult {
        try GISIntentRouter.openQuickView(id: target.id)
        return .result()
    }
}
