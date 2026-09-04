//
//  PaymentTests.swift
//  GISTests
//
//  Created by jeweal-pm on 9/4/26.
//

import XCTest
@testable import GIS

// NOTE: CheckOutPage is a storyboard-driven massive view controller; only the
// outlet-free tax-math methods are exercised here via a bare `ClassName()`
// (same pattern as GISTests/PosTests.swift).
//
// UNTESTABLE WITHOUT A REFACTOR: CompletePayment.getPdfOrderType() — the
// order-type string mapping used when generating a payment PDF (e.g.
// "exchange" -> "exchange_order") — is declared `private`, so it isn't
// reachable via `@testable import GIS`. Dropping it to `internal` would make
// it directly testable.
class PaymentTests: XCTestCase {

    func test_checkOutPage_calculatePercentage_returnsFractionOfValue() {
        let sut = CheckOutPage()
        XCTAssertEqual(sut.calculatePercentage(value: 300, percent: 10), 30, accuracy: 0.0001)
    }

    func test_checkOutPage_calculateExclusiveTax_returnsFractionOfValue() {
        let sut = CheckOutPage()
        XCTAssertEqual(sut.calculateExclusiveTax(value: 300, percent: 7), 21, accuracy: 0.0001)
    }

    func test_checkOutPage_calculateInclusiveTax_withDefaultStoredTaxRate_divesByOneHundred() {
        // Freshly-constructed controller has mTaxP == "", so the denominator is 100 + 0.
        let sut = CheckOutPage()
        XCTAssertEqual(sut.calculateInclusiveTax(value: 300, percent: 7), 21, accuracy: 0.0001)
    }
}
