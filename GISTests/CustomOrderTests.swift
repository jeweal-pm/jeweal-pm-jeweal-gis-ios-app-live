//
//  CustomOrderTests.swift
//  GISTests
//
//  Created by jeweal-pm on 9/4/26.
//

import XCTest
@testable import GIS

// NOTE: CustomCart and CustomOrderCheckout are storyboard-driven massive view
// controllers. Only methods that don't touch an `@IBOutlet` are exercised here
// via a bare `ClassName()` (see GISTests/PosTests.swift for the same pattern
// and rationale — this app copy-pastes the tax-calculation helpers verbatim
// across many controllers).
class CustomOrderTests: XCTestCase {

    // MARK: - CustomCart.uniqueElementsFrom

    func test_uniqueElementsFrom_removesDuplicatesPreservingFirstOccurrenceOrder() {
        let sut = CustomCart()
        let result = sut.uniqueElementsFrom(array: ["Ring", "Necklace", "Ring", "Bracelet", "Necklace"])
        XCTAssertEqual(result, ["Ring", "Necklace", "Bracelet"])
    }

    func test_uniqueElementsFrom_emptyArray_returnsEmptyArray() {
        let sut = CustomCart()
        XCTAssertEqual(sut.uniqueElementsFrom(array: []), [])
    }

    func test_uniqueElementsFrom_noDuplicates_returnsSameElements() {
        let sut = CustomCart()
        XCTAssertEqual(sut.uniqueElementsFrom(array: ["A", "B", "C"]), ["A", "B", "C"])
    }

    func test_uniqueElementsFrom_allSameElement_collapsesToSingleEntry() {
        let sut = CustomCart()
        XCTAssertEqual(sut.uniqueElementsFrom(array: ["Gold", "Gold", "Gold"]), ["Gold"])
    }

    // MARK: - CustomCart.calculatePercentage

    func test_customCart_calculatePercentage_returnsFractionOfValue() {
        let sut = CustomCart()
        XCTAssertEqual(sut.calculatePercentage(value: 500, percent: 10), 50, accuracy: 0.0001)
    }

    // MARK: - CustomOrderCheckout tax math (same copy-pasted formula as POSCheckout)

    func test_customOrderCheckout_calculateExclusiveTax_returnsFractionOfValue() {
        let sut = CustomOrderCheckout()
        XCTAssertEqual(sut.calculateExclusiveTax(value: 800, percent: 7), 56, accuracy: 0.0001)
    }

    func test_customOrderCheckout_calculateInclusiveTax_withDefaultStoredTaxRate_divesByOneHundred() {
        // Freshly-constructed controller has mTaxP == "", so the denominator is 100 + 0.
        let sut = CustomOrderCheckout()
        XCTAssertEqual(sut.calculateInclusiveTax(value: 800, percent: 7), 56, accuracy: 0.0001)
    }
}
