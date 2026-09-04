//
//  MixAndMatchTests.swift
//  GISTests
//
//  Created by jeweal-pm on 9/4/26.
//

import XCTest
@testable import GIS

// NOTE: MixMatchCart, MixAndMatchCheckout and MixAndMatchJewelry are
// storyboard-driven massive view controllers. Only methods that don't touch
// an `@IBOutlet` are exercised here via a bare `ClassName()` (same pattern as
// GISTests/PosTests.swift and GISTests/CustomOrderTests.swift).
class MixAndMatchTests: XCTestCase {

    override func tearDownWithError() throws {
        UserDefaults.standard.removeObject(forKey: "currencySymbol")
    }

    // MARK: - MixMatchCart.uniqueElementsFrom

    func test_uniqueElementsFrom_removesDuplicatesPreservingFirstOccurrenceOrder() {
        let sut = MixMatchCart()
        let result = sut.uniqueElementsFrom(array: ["Ruby", "Sapphire", "Ruby", "Emerald"])
        XCTAssertEqual(result, ["Ruby", "Sapphire", "Emerald"])
    }

    func test_uniqueElementsFrom_emptyArray_returnsEmptyArray() {
        let sut = MixMatchCart()
        XCTAssertEqual(sut.uniqueElementsFrom(array: []), [])
    }

    // MARK: - MixMatchCart.calculatePercentage

    func test_mixMatchCart_calculatePercentage_returnsFractionOfValue() {
        let sut = MixMatchCart()
        XCTAssertEqual(sut.calculatePercentage(value: 400, percent: 25), 100, accuracy: 0.0001)
    }

    // MARK: - MixAndMatchCheckout tax math (same copy-pasted formula as POSCheckout)

    func test_mixAndMatchCheckout_calculateExclusiveTax_returnsFractionOfValue() {
        let sut = MixAndMatchCheckout()
        XCTAssertEqual(sut.calculateExclusiveTax(value: 900, percent: 7), 63, accuracy: 0.0001)
    }

    func test_mixAndMatchCheckout_calculateInclusiveTax_withDefaultStoredTaxRate_divesByOneHundred() {
        // Freshly-constructed controller has mTaxP == "", so the denominator is 100 + 0.
        let sut = MixAndMatchCheckout()
        XCTAssertEqual(sut.calculateInclusiveTax(value: 900, percent: 7), 63, accuracy: 0.0001)
    }

    // MARK: - MixAndMatchJewelry.formatPrice

    func test_formatPrice_prependsCurrencySymbolFromUserDefaults() {
        UserDefaults.standard.set("THB", forKey: "currencySymbol")
        let sut = MixAndMatchJewelry()
        XCTAssertEqual(sut.formatPrice(1234.5), "THB 1,234.50")
    }

    func test_formatPrice_noStoredCurrencySymbol_omitsSymbolButKeepsLeadingSpace() {
        // The implementation always interpolates "\(symbol) \(formatted)", so a missing
        // symbol still leaves a leading space rather than trimming it — pinning down the
        // real (slightly odd) current behavior.
        UserDefaults.standard.removeObject(forKey: "currencySymbol")
        let sut = MixAndMatchJewelry()
        XCTAssertEqual(sut.formatPrice(1234.5), " 1,234.50")
    }

    func test_formatPrice_roundsToTwoDecimalPlaces() {
        UserDefaults.standard.set("$", forKey: "currencySymbol")
        let sut = MixAndMatchJewelry()
        XCTAssertEqual(sut.formatPrice(9.996), "$ 10.00")
    }
}
