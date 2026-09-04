//
//  DiamondTests.swift
//  GISTests
//
//  Created by jeweal-pm on 9/4/26.
//

import XCTest
@testable import GIS

class DiamondTests: XCTestCase {

    // MARK: - Date.getFormattedDate(format:)
    // Unlike the ordinal formatter in Pos, this pins .calendar to gregorian and
    // .locale to en_US_POSIX explicitly, so (unlike GISTests/PosTests.swift's
    // mFormatOrdinal caveat) its output does NOT depend on the test run's locale.

    private func gregorianDate(year: Int, month: Int, day: Int) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_US_POSIX")
        let components = DateComponents(year: year, month: month, day: day)
        return calendar.date(from: components)!
    }

    func test_getFormattedDate_formatsUsingGregorianCalendarRegardlessOfCurrentLocale() {
        let date = gregorianDate(year: 2026, month: 3, day: 5)
        XCTAssertEqual(date.getFormattedDate(format: "dd/MM/yyyy"), "05/03/2026")
    }

    func test_getFormattedDate_supportsAlternateFormatStrings() {
        let date = gregorianDate(year: 2026, month: 12, day: 25)
        XCTAssertEqual(date.getFormattedDate(format: "yyyy-MM-dd"), "2026-12-25")
    }

    // MARK: - String.toCGFloat

    func test_toCGFloat_validDecimalString_returnsValue() {
        XCTAssertEqual("3.5".toCGFloat(), 3.5)
    }

    func test_toCGFloat_negativeValue_returnsValue() {
        XCTAssertEqual("-2.25".toCGFloat(), -2.25)
    }

    func test_toCGFloat_nonNumericString_returnsNil() {
        XCTAssertNil("not-a-number".toCGFloat())
    }

    func test_toCGFloat_emptyString_returnsNil() {
        XCTAssertNil("".toCGFloat())
    }
}
