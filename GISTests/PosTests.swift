//
//  PosTests.swift
//  GISTests
//
//  Created by jeweal-pm on 9/4/26.
//

import XCTest
@testable import GIS

// NOTE: POSCheckout, PosCart, and LaybyInstallmentCheckout are storyboard-driven
// massive view controllers with dozens of `@IBOutlet`s that are nil until loaded
// from a storyboard. The methods exercised here are the few that don't touch any
// outlet, so a bare `ClassName()` (skipping `loadView`) is safe to call them on.
// Everything else in these classes needs a storyboard-instantiated instance and
// is only reachable through a UI test.
class PosTests: XCTestCase {

    override func tearDownWithError() throws {
        UserDefaults.standard.removeObject(forKey: "taxValue")
    }

    // MARK: - POSCheckout tax/discount math
    // The same three methods are copy-pasted (with small variations) across
    // POSCheckout, PosCart, POSMain, LaybyInstallmentCheckout and several
    // GIS/Pos/More controllers — a real regression risk if one copy is fixed
    // and the others aren't. Pinning the behavior here catches that drift.

    func test_posCheckout_calculatePercentage_returnsFractionOfValue() {
        let sut = POSCheckout()
        XCTAssertEqual(sut.calculatePercentage(value: 1000, percent: 7), 70, accuracy: 0.0001)
    }

    func test_posCheckout_calculatePercentage_zeroPercent_returnsZero() {
        let sut = POSCheckout()
        XCTAssertEqual(sut.calculatePercentage(value: 1000, percent: 0), 0, accuracy: 0.0001)
    }

    func test_posCheckout_calculateExclusiveTax_ignoresStoredTaxRate() {
        // Exclusive tax is just value * percent / 100, independent of mTaxP.
        let sut = POSCheckout()
        XCTAssertEqual(sut.calculateExclusiveTax(value: 1000, percent: 7), 70, accuracy: 0.0001)
    }

    func test_posCheckout_calculateInclusiveTax_withDefaultStoredTaxRate_divesByOneHundred() {
        // A freshly-created controller has mTaxP == "" (never loaded from a form field),
        // so Double(mTaxP) ?? 0 contributes 0 to the denominator.
        let sut = POSCheckout()
        XCTAssertEqual(sut.calculateInclusiveTax(value: 1000, percent: 7), 70, accuracy: 0.0001)
    }

    // MARK: - PosCart tax math (reads a different tax source: UserDefaults, not an instance property)

    func test_posCart_calculatePercentage_returnsFractionOfValue() {
        let sut = PosCart()
        XCTAssertEqual(sut.calculatePercentage(value: 200, percent: 25), 50, accuracy: 0.0001)
    }

    func test_posCart_calculateInclusiveTax_noStoredTaxValue_treatsTaxRateAsZero() {
        UserDefaults.standard.removeObject(forKey: "taxValue")
        let sut = PosCart()
        XCTAssertEqual(sut.calculateInclusiveTax(value: 1000, percent: 7), 70, accuracy: 0.0001)
    }

    func test_posCart_calculateInclusiveTax_readsStoredTaxValueFromUserDefaults() {
        UserDefaults.standard.setValue("7", forKey: "taxValue")
        let sut = PosCart()

        // val = 1000 * 7 = 7000; denominator = 100 + 7 = 107
        XCTAssertEqual(sut.calculateInclusiveTax(value: 1000, percent: 7), 7000.0 / 107.0, accuracy: 0.0001)
    }

    // MARK: - LaybyInstallmentCheckout.mFormatOrdinal
    // Ordinal formatting has the classic "teens are always -th" exception that's
    // easy to break with a naive last-digit switch, so it's worth pinning down.
    // CAVEAT: mFormatOrdinal builds its NumberFormatter without pinning `.locale`,
    // so it renders using Locale.current. These assertions assume an en_US test
    // run (the default on CI/simulator). This app ships ar/ja/th/zh-Hans/ru
    // locales too, and NumberFormatter's `.ordinal` style does not produce an
    // English-style "1st/2nd/3rd" suffix in most of those — worth a manual check
    // if installment labels ever look wrong in a non-English build.

    func test_mFormatOrdinal_firstSecondThird() {
        let sut = LaybyInstallmentCheckout()
        XCTAssertEqual(sut.mFormatOrdinal(num: 1), "1st")
        XCTAssertEqual(sut.mFormatOrdinal(num: 2), "2nd")
        XCTAssertEqual(sut.mFormatOrdinal(num: 3), "3rd")
        XCTAssertEqual(sut.mFormatOrdinal(num: 4), "4th")
    }

    func test_mFormatOrdinal_teensAreAlwaysTh() {
        let sut = LaybyInstallmentCheckout()
        XCTAssertEqual(sut.mFormatOrdinal(num: 11), "11th")
        XCTAssertEqual(sut.mFormatOrdinal(num: 12), "12th")
        XCTAssertEqual(sut.mFormatOrdinal(num: 13), "13th")
    }

    func test_mFormatOrdinal_twentyFirst() {
        let sut = LaybyInstallmentCheckout()
        XCTAssertEqual(sut.mFormatOrdinal(num: 21), "21st")
    }
}
