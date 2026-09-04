//
//  ExtrasTests.swift
//  GISTests
//
//  Created by jeweal-pm on 9/4/26.
//

import XCTest
@testable import GIS

// NOTE: PartialPaymentDetails, PartialPaymentHistory and CustomerProfile are
// storyboard-driven massive view controllers; outlet-touching methods are
// exercised here by stubbing the specific outlet(s) they need with plain
// UIKit instances (same pattern as GISTests/ItemSearchTests.swift).
class ExtrasTests: XCTestCase {

    // MARK: - PartialPaymentDetails.mFormatOrdinal
    // Same NumberFormatter(.ordinal) pattern as LaybyInstallmentCheckout in
    // GISTests/PosTests.swift -- see that file's caveat about Locale.current
    // dependence (these assertions assume an en_US test run).

    func test_mFormatOrdinal_firstAndSecond() {
        let sut = PartialPaymentDetails()
        XCTAssertEqual(sut.mFormatOrdinal(num: 1), "1st")
        XCTAssertEqual(sut.mFormatOrdinal(num: 2), "2nd")
    }

    func test_mFormatOrdinal_teensAreAlwaysTh() {
        let sut = PartialPaymentDetails()
        XCTAssertEqual(sut.mFormatOrdinal(num: 12), "12th")
    }

    // MARK: - PartialPaymentHistory.mFilter

    func test_mFilter_keepsOnlyEntriesMatchingOrderType() {
        let sut = PartialPaymentHistory()
        sut.mTableView = UITableView()
        sut.mMasterData = NSArray(array: [
            ["order_type": "Installment", "vr_no": "VR1"],
            ["order_type": "Layby", "vr_no": "VR2"],
            ["order_type": "Installment", "vr_no": "VR3"]
        ])

        sut.mFilter(type: "Installment")

        let vrNumbers = (sut.mReceivedData as? [NSDictionary])?.compactMap { $0["vr_no"] as? String }
        XCTAssertEqual(vrNumbers, ["VR1", "VR3"])
    }

    func test_mFilter_noMatches_resultsInEmptyReceivedData() {
        let sut = PartialPaymentHistory()
        sut.mTableView = UITableView()
        sut.mMasterData = NSArray(array: [["order_type": "Layby", "vr_no": "VR2"]])

        sut.mFilter(type: "Installment")

        XCTAssertEqual(sut.mReceivedData.count, 0)
    }

    // MARK: - CustomerProfile.mGetNumberView

    func test_mGetNumberView_formatsPhoneCodeAndNumber() {
        let sut = CustomerProfile()
        let contact: NSDictionary = ["phoneCode": "66", "number": "812345678"]

        let stackView = sut.mGetNumberView(contact: contact)

        let numberLabel = stackView.arrangedSubviews.last as? UILabel
        XCTAssertEqual(numberLabel?.text, "+66-812345678")
    }

    func test_mGetNumberView_missingFields_stillProducesDashSeparatedText() {
        let sut = CustomerProfile()

        let stackView = sut.mGetNumberView(contact: [:])

        let numberLabel = stackView.arrangedSubviews.last as? UILabel
        XCTAssertEqual(numberLabel?.text, "+-")
    }
}
