//
//  StockTakeTests.swift
//  GISTests
//
//  Created by jeweal-pm on 9/4/26.
//

import XCTest
@testable import GIS

class StockTakeTests: XCTestCase {

    // MARK: - Array.removingDuplicates (Hashable element, order-preserving)

    func test_removingDuplicates_preservesFirstOccurrenceOrder() {
        XCTAssertEqual([1, 2, 2, 3, 1].removingDuplicates(), [1, 2, 3])
    }

    func test_removingDuplicates_mutatingVariant_updatesInPlace() {
        var values = ["a", "b", "a", "c"]
        values.removingDuplicates()
        XCTAssertEqual(values, ["a", "b", "c"])
    }

    // MARK: - String.hexToString
    // SUSPECTED BUG: after decoding each hex byte pair to its ASCII character,
    // the implementation trims out every character that is NOT an ASCII digit
    // (`CharacterSet(charactersIn: "0123456789").inverted`). That means any
    // decoded letter/space/punctuation is silently dropped — only decoded
    // digit characters ('0'-'9') survive. These tests pin down that real,
    // currently-shipping behavior rather than the presumably-intended one.

    func test_hexToString_bytesThatDecodeToAsciiDigits_areKept() {
        // 0x31 = '1', 0x32 = '2'
        XCTAssertEqual("3132".hexToString(), "12")
    }

    func test_hexToString_bytesThatDecodeToLetters_areDroppedByTheDigitTrim() {
        // 0x41 = 'A', 0x42 = 'B' -- neither survives the digit-only trim.
        XCTAssertEqual("4142".hexToString(), "")
    }

    // MARK: - DataProtocol.hexEncodedString / Data.hexEncodedStrings
    // Two independent hex-encoding implementations exist side by side; both
    // are pinned down here so a future edit to one doesn't silently diverge
    // from the other.

    func test_hexEncodedString_padsSingleDigitBytesWithLeadingZero() {
        let data = Data([0x00, 0xFF, 0x10])
        XCTAssertEqual(data.hexEncodedString(), "00ff10")
    }

    func test_hexEncodedString_uppercaseOption_producesUppercaseHex() {
        let data = Data([0xAB, 0xCD])
        XCTAssertEqual(data.hexEncodedString(uppercase: true), "ABCD")
    }

    func test_hexEncodedStrings_matchesHexEncodedStringLowercaseOutput() {
        let data = Data([0x00, 0xFF, 0x10])
        XCTAssertEqual(data.hexEncodedStrings(), "00ff10")
    }

    // MARK: - String.base64Decoded

    func test_base64Decoded_invalidBase64_returnsNil() {
        XCTAssertNil("not valid base64 !!!".base64Decoded())
    }

    func test_base64Decoded_validBase64_likelyReturnsNilDueToInvalidEncodingConstant() {
        // SUSPECTED BUG: `.init(rawValue: 0)` is not any of Foundation's
        // documented String.Encoding constants (they start at 1 for `.ascii`).
        // Passing an unrecognized NSStringEncoding to String(data:encoding:)
        // fails (returns nil) rather than falling back to something like
        // UTF-8, so this method likely can never successfully decode anything
        // -- flagging for whoever owns this file; confirm on a real build.
        let base64OfHello = Data("Hello".utf8).base64EncodedString()
        XCTAssertNil(base64OfHello.base64Decoded())
    }

    // MARK: - StockTakePage.uniqueElementsFrom
    // NOTE: StockTakePage is a storyboard-driven massive view controller;
    // uniqueElementsFrom doesn't touch any outlet, so a bare `StockTakePage()`
    // is safe here (same pattern as GISTests/PosTests.swift).

    func test_uniqueElementsFrom_removesDuplicatesPreservingFirstOccurrenceOrder() {
        let sut = StockTakePage()
        XCTAssertEqual(sut.uniqueElementsFrom(array: ["SKU1", "SKU2", "SKU1"]), ["SKU1", "SKU2"])
    }
}
