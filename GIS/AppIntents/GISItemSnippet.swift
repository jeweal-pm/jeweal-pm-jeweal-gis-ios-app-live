//
//  GISItemSnippet.swift
//  GIS
//
//  iOS 26+: Siri result card for an item, and a "find item" intent that asks
//  where to open it.
//

import AppIntents
import SwiftUI

/// Shows a card for an item with buttons that open it in GIS.
/// The card only reads state; every action lives in the button intents.
@available(iOS 26.0, *)
struct ShowItemCardIntent: AppIntent {
    static var title: LocalizedStringResource = "Show Item Card"
    static var description = IntentDescription("Show a card for a stock item with shortcuts to open it.")

    @Parameter(title: "Item")
    var item: GISItemEntity

    init() {}
    init(item: GISItemEntity) { self.item = item }

    static var parameterSummary: some ParameterSummary {
        Summary("Show card for \(\.$item)")
    }

    func perform() async throws -> some IntentResult & ShowsSnippetIntent {
        GISRecentItems.record(item.id)
        return .result(snippetIntent: GISItemSnippetIntent(item: item))
    }
}

@available(iOS 26.0, *)
struct GISItemSnippetIntent: SnippetIntent {
    static var title: LocalizedStringResource = "Item Card"

    @Parameter(title: "Item")
    var item: GISItemEntity

    init() {}
    init(item: GISItemEntity) { self.item = item }

    func perform() async throws -> some IntentResult & ShowsSnippetView {
        .result(view: GISItemCardView(item: item))
    }
}

@available(iOS 26.0, *)
struct GISItemCardView: View {
    let item: GISItemEntity

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(item.id, systemImage: "diamond")
                .font(.headline)
            HStack {
                Button(intent: OpenItemQuickViewIntent(item: item)) {
                    Text("Quick View")
                }
                Button(intent: OpenItemInventoryIntent(item: item)) {
                    Text("Inventory")
                }
                Button(intent: OpenItemCatalogIntent(item: item)) {
                    Text("Catalog")
                }
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}

/// Asks where to open an item. Runs headless, and only brings GIS forward after the choice.
@available(iOS 26.0, *)
struct FindItemIntent: AppIntent {
    static var title: LocalizedStringResource = "Find Item"
    static var description = IntentDescription("Choose where to open a stock item.")
    static var supportedModes: IntentModes { [.background, .foreground(.dynamic)] }

    @Parameter(title: "Item")
    var item: GISItemEntity

    init() {}
    init(item: GISItemEntity) { self.item = item }

    static var parameterSummary: some ParameterSummary {
        Summary("Find \(\.$item)")
    }

    func perform() async throws -> some IntentResult {
        let quickView = IntentChoiceOption(title: "Quick View")
        let inventory = IntentChoiceOption(title: "Inventory")
        let catalog = IntentChoiceOption(title: "Catalog")

        // Selecting .cancel throws, which ends the intent.
        let choice = try await requestChoice(
            between: [quickView, inventory, catalog, .cancel],
            dialog: "Where do you want to open \(item.id)?"
        )

        guard systemContext.currentMode.canContinueInForeground else {
            throw needsToContinueInForegroundError("Open GIS to view \(item.id)")
        }
        try await continueInForeground("Open GIS?", alwaysConfirm: false)

        let id = item.id
        try await MainActor.run {
            if choice == inventory {
                try GISIntentRouter.openInventory(id: id)
            } else if choice == catalog {
                try GISIntentRouter.openCatalog(id: id)
            } else {
                try GISIntentRouter.openQuickView(id: id)
            }
        }
        return .result()
    }
}

@available(iOS 26.0, *)
#Preview("Item card") {
    GISItemCardView(item: GISItemEntity(id: "SB025"))
        .frame(width: 340)
        .background(.background)
}
