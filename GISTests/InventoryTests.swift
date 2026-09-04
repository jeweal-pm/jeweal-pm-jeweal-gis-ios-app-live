//
//  InventoryTests.swift
//  GISTests
//
//  Created by jeweal-pm on 9/4/26.
//

import XCTest
@testable import GIS

// NOTE: InventoryPage and InventoryReservedItems are storyboard-driven massive
// view controllers; only outlet-free methods are exercised here via a bare
// `ClassName()` (same pattern as GISTests/PosTests.swift).
class InventoryTests: XCTestCase {

    // MARK: - InventoryPage.getFullMetalName

    func test_getFullMetalName_knownCodes_returnFullNames() {
        let sut = InventoryPage()
        XCTAssertEqual(sut.getFullMetalName("WG"), "White Gold")
        XCTAssertEqual(sut.getFullMetalName("YG"), "Yellow Gold")
        XCTAssertEqual(sut.getFullMetalName("RG"), "Rose Gold")
    }

    func test_getFullMetalName_isCaseInsensitiveForKnownCodes() {
        let sut = InventoryPage()
        XCTAssertEqual(sut.getFullMetalName("wg"), "White Gold")
    }

    func test_getFullMetalName_unknownCode_passesThroughOriginalCaseUnchanged() {
        // The switch matches on code.uppercased(), but the default case returns
        // the original `code` parameter rather than the uppercased copy — an
        // unknown lowercase code is NOT normalized to uppercase.
        let sut = InventoryPage()
        XCTAssertEqual(sut.getFullMetalName("pt"), "pt")
    }

    // MARK: - InventoryReservedItems.formatReserveDate
    // Duplicate of InventoryReserved.formatReserveDate (GISTests/ReserveTests.swift) —
    // same Buddhist-Era-to-Gregorian conversion, tested independently here since it's
    // a separate copy that could drift out of sync with a future fix to the other one.

    func test_formatReserveDate_buddhistEraDayMonthYear_convertsYearToGregorian() {
        let sut = InventoryReservedItems()
        XCTAssertEqual(sut.formatReserveDate("05/03/2569"), "05/03/2026")
    }

    func test_formatReserveDate_gregorianYearMonthDay_reordersToDayMonthYear() {
        let sut = InventoryReservedItems()
        XCTAssertEqual(sut.formatReserveDate("2026/03/05"), "05/03/2026")
    }

    func test_formatReserveDate_malformedInput_returnsOriginalString() {
        let sut = InventoryReservedItems()
        XCTAssertEqual(sut.formatReserveDate("not-a-date"), "not-a-date")
    }
}
