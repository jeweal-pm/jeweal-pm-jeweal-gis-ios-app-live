//
//  GISOpenIntents.swift
//  GIS
//
//  App Intents that open GIS screens. They replace the legacy SiriKit custom intents;
//  the old intent definitions stay in place until these are confirmed on device.
//

import AppIntents

/// Intents in this file bring the app to the foreground before `perform()` runs.
/// `supportedModes` is the iOS 26 form; `openAppWhenRun` covers iOS 16–25.
@available(iOS 16.0, *)
protocol GISForegroundIntent: AppIntent {}

@available(iOS 16.0, *)
extension GISForegroundIntent {
    static var openAppWhenRun: Bool { true }

    @available(iOS 26.0, *)
    static var supportedModes: IntentModes { .foreground }
}

@available(iOS 16.0, *)
struct OpenItemQuickViewIntent: GISForegroundIntent {
    static var title: LocalizedStringResource = "Open Item in Quick View"
    static var description = IntentDescription("Search a stock item in Quick View.")

    @Parameter(title: "Item")
    var item: GISItemEntity

    static var parameterSummary: some ParameterSummary {
        Summary("Open \(\.$item) in Quick View")
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        try GISIntentRouter.openQuickView(id: item.id)
        return .result()
    }
}

@available(iOS 16.0, *)
struct OpenItemCatalogIntent: GISForegroundIntent {
    static var title: LocalizedStringResource = "Open Item in Catalog"
    static var description = IntentDescription("Search a stock item in the catalog.")

    @Parameter(title: "Item")
    var item: GISItemEntity

    static var parameterSummary: some ParameterSummary {
        Summary("Open \(\.$item) in Catalog")
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        try GISIntentRouter.openCatalog(id: item.id)
        return .result()
    }
}

@available(iOS 16.0, *)
struct OpenItemInventoryIntent: GISForegroundIntent {
    static var title: LocalizedStringResource = "Open Item in Inventory"
    static var description = IntentDescription("Search a stock item in inventory.")

    @Parameter(title: "Item")
    var item: GISItemEntity

    static var parameterSummary: some ParameterSummary {
        Summary("Open \(\.$item) in Inventory")
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        try GISIntentRouter.openInventory(id: item.id)
        return .result()
    }
}

@available(iOS 16.0, *)
struct StartStockTakeIntent: GISForegroundIntent {
    static var title: LocalizedStringResource = "Start Stock Take"
    static var description = IntentDescription("Open the stock take screen.")

    @MainActor
    func perform() async throws -> some IntentResult {
        try GISIntentRouter.openStockTake()
        return .result()
    }
}

@available(iOS 16.4, *)
struct GISAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: OpenItemQuickViewIntent(),
            phrases: ["Open \(\.$item) in \(.applicationName)",
                      "Quick view \(\.$item) in \(.applicationName)"],
            shortTitle: "Quick View",
            systemImageName: "magnifyingglass"
        )
        AppShortcut(
            intent: StartStockTakeIntent(),
            phrases: ["Start stock take in \(.applicationName)"],
            shortTitle: "Stock Take",
            systemImageName: "checklist"
        )
    }
}
