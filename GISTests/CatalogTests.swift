//
//  CatalogTests.swift
//  GISTests
//
//  Created by jeweal-pm on 9/4/26.
//

import XCTest
@testable import GIS

// NOTE: POSAddToCart is a storyboard-driven massive view controller; only
// outlet-free methods are exercised here via a bare `ClassName()` (same
// pattern as GISTests/PosTests.swift). truncateToFit takes its two UILabels
// as plain parameters rather than reading `self`'s outlets, so it's callable
// without any storyboard/nib at all.
class CatalogTests: XCTestCase {

    // MARK: - POSAddToCart.getFullMetalName
    // Same WG/YG/RG lookup as InventoryPage.getFullMetalName (GISTests/InventoryTests.swift)
    // and CommonInventory.getFullMetalName, copy-pasted per controller.

    func test_getFullMetalName_knownCode_returnsFullName() {
        let sut = POSAddToCart()
        XCTAssertEqual(sut.getFullMetalName("WG"), "White Gold")
    }

    func test_getFullMetalName_unknownCode_passesThroughUnchanged() {
        let sut = POSAddToCart()
        XCTAssertEqual(sut.getFullMetalName("PT950"), "PT950")
    }

    // MARK: - POSAddToCart.truncateToFit
    // Deliberately avoids asserting an exact truncation point, since that
    // depends on live font-metrics measurement that can vary slightly across
    // simulators/OS versions — the qualitative behavior (fits vs. doesn't,
    // ellipsis appended vs. not) is what's worth pinning down.

    func test_truncateToFit_textFitsWithinAvailableWidth_returnsTextUnchanged() {
        let sut = POSAddToCart()
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 1000, height: 20))
        label.font = UIFont.systemFont(ofSize: 14)
        let rightLabel = UILabel()

        let result = sut.truncateToFit("Ring", label: label, rightLabel: rightLabel)

        XCTAssertEqual(result, "Ring")
    }

    func test_truncateToFit_textTooLongForAvailableWidth_truncatesAndAppendsEllipsis() {
        let sut = POSAddToCart()
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 60, height: 20))
        label.font = UIFont.systemFont(ofSize: 14)
        let rightLabel = UILabel()
        let longText = "18K White Gold Diamond Solitaire Engagement Ring"

        let result = sut.truncateToFit(longText, label: label, rightLabel: rightLabel)

        XCTAssertTrue(result.hasSuffix("..."))
        XCTAssertLessThan(result.count, longText.count)
    }

    func test_truncateToFit_zeroAvailableWidth_collapsesToEllipsisOnly() {
        let sut = POSAddToCart()
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 1, height: 20))
        label.font = UIFont.systemFont(ofSize: 14)
        let rightLabel = UILabel()

        let result = sut.truncateToFit("Necklace", label: label, rightLabel: rightLabel)

        XCTAssertEqual(result, "...")
    }
}
