//
//  ReserveTests.swift
//  GISTests
//
//  Created by jeweal-pm on 9/4/26.
//

import XCTest
@testable import GIS

// NOTE: ReserveCart and InventoryReserved are storyboard-driven massive view
// controllers; only outlet-free methods are exercised here via a bare
// `ClassName()` (same pattern as GISTests/PosTests.swift).
class ReserveTests: XCTestCase {

    // MARK: - ReserveCart.uniqueElementsFrom

    func test_uniqueElementsFrom_removesDuplicatesPreservingFirstOccurrenceOrder() {
        let sut = ReserveCart()
        XCTAssertEqual(sut.uniqueElementsFrom(array: ["Ring", "Ring", "Necklace"]), ["Ring", "Necklace"])
    }

    // MARK: - ReserveCart.calculatePercentage

    func test_reserveCart_calculatePercentage_returnsFractionOfValue() {
        let sut = ReserveCart()
        XCTAssertEqual(sut.calculatePercentage(value: 600, percent: 15), 90, accuracy: 0.0001)
    }

    // MARK: - InventoryReserved.formatReserveDate
    // This is core to the recently-added "Reserve" flows: it normalizes both
    // dd/MM/yyyy and yyyy/MM/dd inputs to dd/MM/yyyy, and converts a Buddhist
    // Era (พ.ศ.) year to Gregorian/AD (year - 543) when year > 2500. The same
    // logic is duplicated in InventoryReservedItems.formatReserveDate — see
    // GISTests/InventoryTests.swift.

    func test_formatReserveDate_gregorianDayMonthYear_passesThroughUnchanged() {
        let sut = InventoryReserved()
        XCTAssertEqual(sut.formatReserveDate("05/03/2026"), "05/03/2026")
    }

    func test_formatReserveDate_buddhistEraDayMonthYear_convertsYearToGregorian() {
        let sut = InventoryReserved()
        XCTAssertEqual(sut.formatReserveDate("05/03/2569"), "05/03/2026")
    }

    func test_formatReserveDate_gregorianYearMonthDay_reordersToDayMonthYear() {
        let sut = InventoryReserved()
        XCTAssertEqual(sut.formatReserveDate("2026/03/05"), "05/03/2026")
    }

    func test_formatReserveDate_buddhistEraYearMonthDay_reordersAndConvertsYear() {
        let sut = InventoryReserved()
        XCTAssertEqual(sut.formatReserveDate("2569/03/05"), "05/03/2026")
    }

    func test_formatReserveDate_yearExactlyTwentyFiveHundred_isNotTreatedAsBuddhistEra() {
        // The conversion only triggers when year > 2500, so a boundary year of
        // exactly 2500 is left as-is (whether or not that's the intended cutoff).
        let sut = InventoryReserved()
        XCTAssertEqual(sut.formatReserveDate("05/03/2500"), "05/03/2500")
    }

    func test_formatReserveDate_malformedInput_returnsOriginalString() {
        let sut = InventoryReserved()
        XCTAssertEqual(sut.formatReserveDate("2026-03-05"), "2026-03-05")
    }

    func test_formatReserveDate_emptyString_returnsEmptyString() {
        let sut = InventoryReserved()
        XCTAssertEqual(sut.formatReserveDate(""), "")
    }
}
