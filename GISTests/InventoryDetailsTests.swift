//
//  InventoryDetailsTests.swift
//  GISTests
//
//  Created by jeweal-pm on 9/4/26.
//

import XCTest
@testable import GIS

// NOTE: InventoryDetails is a storyboard-driven massive view controller.
// mTransitAndWareHouse() writes to two UILabel outlets (mStatusDot,
// mProductStatus), so they're stubbed with plain UILabel() instances before
// calling — same bare-`ClassName()` pattern as GISTests/PosTests.swift.
class InventoryDetailsTests: XCTestCase {

    private func makeSut() -> InventoryDetails {
        let sut = InventoryDetails()
        sut.mStatusDot = UILabel()
        sut.mProductStatus = UILabel()
        return sut
    }

    func test_mTransitAndWareHouse_transferInProgress_showsTransitStatus() {
        let sut = makeSut()
        sut.mData = ["stock_transferStartendStatus": "1"]

        sut.mTransitAndWareHouse()

        XCTAssertEqual(sut.mProductStatus.text, "Transit")
    }

    func test_mTransitAndWareHouse_warehouseFlagSet_showsWarehouseStatus() {
        let sut = makeSut()
        sut.mData = ["warehouse_status": "1"]

        sut.mTransitAndWareHouse()

        XCTAssertEqual(sut.mProductStatus.text, "Warehouse")
    }

    func test_mTransitAndWareHouse_neitherFlagSet_leavesStatusUnset() {
        let sut = makeSut()
        sut.mData = [:]

        sut.mTransitAndWareHouse()

        XCTAssertNil(sut.mProductStatus.text)
    }

    func test_mTransitAndWareHouse_bothFlagsSet_transitTakesPriority() {
        // Implemented as if/else-if, so a transfer-in-progress item always wins
        // over a stale warehouse_status flag on the same record.
        let sut = makeSut()
        sut.mData = ["stock_transferStartendStatus": "1", "warehouse_status": "1"]

        sut.mTransitAndWareHouse()

        XCTAssertEqual(sut.mProductStatus.text, "Transit")
    }

    func test_mTransitAndWareHouse_flagValueOtherThanOne_isIgnored() {
        let sut = makeSut()
        sut.mData = ["stock_transferStartendStatus": "0", "warehouse_status": "2"]

        sut.mTransitAndWareHouse()

        XCTAssertNil(sut.mProductStatus.text)
    }
}
