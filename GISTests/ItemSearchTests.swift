//
//  ItemSearchTests.swift
//  GISTests
//
//  Created by jeweal-pm on 9/4/26.
//

import XCTest
@testable import GIS

// NOTE: CustomOrder (GIS/Item Search/CustomOrder.swift) is a storyboard-driven
// massive view controller. calculateTotalAmount touches two UILabel outlets
// (mTotalQuantity, mTotalAmount), so they're stubbed with plain UILabel()
// instances before calling — see GISTests/PosTests.swift for the same
// bare-`ClassName()` pattern used elsewhere in this suite.
//
// UNTESTABLE WITHOUT A REFACTOR: ItemSearchPage.isAvailableForReserve(_:) — the
// "available quantity > 0" rule backing "Reserve Order from Item Search" — is
// declared `private`, so it isn't reachable via `@testable import GIS` (Swift's
// `private` stays file-scoped regardless of test-target visibility). Its only
// call sites are currently commented out. If/when this rule is re-enabled,
// dropping it to `internal` (or extracting it to a free function) would make it
// testable; until then this is the one-line note called for by that case.
class ItemSearchTests: XCTestCase {

    private func makeSut() -> CustomOrder {
        let sut = CustomOrder()
        sut.mTotalQuantity = UILabel()
        sut.mTotalAmount = UILabel()
        return sut
    }

    func test_calculateTotalAmount_singleItem_setsQuantityAndAmountLabels() {
        let sut = makeSut()
        sut.mAmountData = NSMutableArray(array: [NSDictionary()])

        sut.calculateTotalAmount(value: 100, index: 0, quantity: 2)

        XCTAssertEqual(sut.mTotalQuantity.text, "2")
        XCTAssertEqual(sut.mTotalAmount.text, "100.00")
    }

    func test_calculateTotalAmount_multipleItems_accumulatesAcrossIndices() {
        let sut = makeSut()
        sut.mAmountData = NSMutableArray(array: [NSDictionary(), NSDictionary()])

        sut.calculateTotalAmount(value: 100, index: 0, quantity: 2)
        sut.calculateTotalAmount(value: 50, index: 1, quantity: 3)

        XCTAssertEqual(sut.mTotalQuantity.text, "5")
        XCTAssertEqual(sut.mTotalAmount.text, "150.00")
    }

    func test_calculateTotalAmount_recomputingSameIndex_replacesRatherThanAdds() {
        let sut = makeSut()
        sut.mAmountData = NSMutableArray(array: [NSDictionary()])

        sut.calculateTotalAmount(value: 100, index: 0, quantity: 2)
        sut.calculateTotalAmount(value: 40, index: 0, quantity: 1)

        XCTAssertEqual(sut.mTotalQuantity.text, "1")
        XCTAssertEqual(sut.mTotalAmount.text, "40.00")
    }

    func test_calculateTotalAmount_marksIndexPathSelected() {
        let sut = makeSut()
        sut.mAmountData = NSMutableArray(array: [NSDictionary()])

        sut.calculateTotalAmount(value: 100, index: 0, quantity: 2)

        XCTAssertTrue(sut.mSelectedCustomIndex.contains(IndexPath(row: 0, section: 0)))
    }
}
