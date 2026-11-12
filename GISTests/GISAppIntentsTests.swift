//
//  GISAppIntentsTests.swift
//  GISTests
//
//  Logic tests for the Siri / App Intents item entity, query and recent-items store.
//

import XCTest
@testable import GIS

final class GISAppIntentsTests: XCTestCase {

    private let recentKey = "GISRecentItemIDs"

    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: recentKey)
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: recentKey)
        super.tearDown()
    }

    // MARK: - Recent items

    func testRecordPutsNewestFirst() {
        GISRecentItems.record("A1")
        GISRecentItems.record("B2")
        XCTAssertEqual(GISRecentItems.ids, ["B2", "A1"])
    }

    func testRecordMovesDuplicateToFrontIgnoringCase() {
        GISRecentItems.record("sb025")
        GISRecentItems.record("X9")
        GISRecentItems.record("SB025")
        XCTAssertEqual(GISRecentItems.ids, ["SB025", "X9"])
    }

    func testRecordIgnoresBlankAndTrims() {
        GISRecentItems.record("   ")
        GISRecentItems.record("")
        GISRecentItems.record("  R-1024  ")
        XCTAssertEqual(GISRecentItems.ids, ["R-1024"])
    }

    func testRecordKeepsOnlyTenMostRecent() {
        for index in 1...15 { GISRecentItems.record("ITEM\(index)") }
        XCTAssertEqual(GISRecentItems.ids.count, 10)
        XCTAssertEqual(GISRecentItems.ids.first, "ITEM15")
        XCTAssertEqual(GISRecentItems.ids.last, "ITEM6")
    }

    // MARK: - Entity and query

    @available(iOS 16.0, *)
    func testEntityIdIsTheSKU() {
        XCTAssertEqual(GISItemEntity(id: "SB025").id, "SB025")
    }

    @available(iOS 16.0, *)
    func testQueryResolvesIdentifiersInOrder() async throws {
        let result = try await GISItemQuery().entities(for: ["B", "A"])
        XCTAssertEqual(result.map(\.id), ["B", "A"])
    }

    @available(iOS 16.0, *)
    func testQueryMatchingTrimsTypedText() async throws {
        let result = try await GISItemQuery().entities(matching: "  SB025 ")
        XCTAssertEqual(result.map(\.id), ["SB025"])
    }

    @available(iOS 16.0, *)
    func testQueryMatchingEmptyTextReturnsNothing() async throws {
        let result = try await GISItemQuery().entities(matching: "   ")
        XCTAssertTrue(result.isEmpty)
    }

    @available(iOS 16.0, *)
    func testSuggestionsAreTheRecentItems() async throws {
        GISRecentItems.record("A1")
        GISRecentItems.record("B2")
        let suggestions = try await GISItemQuery().suggestedEntities()
        XCTAssertEqual(suggestions.map(\.id), ["B2", "A1"])
    }

    // MARK: - Intents

    @available(iOS 16.0, *)
    func testOpenIntentsCarryTheItem() {
        let item = GISItemEntity(id: "SB025")
        XCTAssertEqual(OpenItemQuickViewIntent(item: item).item.id, "SB025")
        XCTAssertEqual(OpenItemCatalogIntent(item: item).item.id, "SB025")
        XCTAssertEqual(OpenItemInventoryIntent(item: item).item.id, "SB025")
    }

    @available(iOS 16.0, *)
    func testOpenIntentsRunInForeground() {
        XCTAssertTrue(OpenItemQuickViewIntent.openAppWhenRun)
        XCTAssertTrue(StartStockTakeIntent.openAppWhenRun)
        XCTAssertTrue(OpenGISItemIntent.openAppWhenRun)
    }

    func testNotSignedInErrorHasMessage() {
        let message = String(localized: GISIntentError.notSignedIn.localizedStringResource)
        XCTAssertEqual(message, "Please sign in to GIS first.")
    }
}
