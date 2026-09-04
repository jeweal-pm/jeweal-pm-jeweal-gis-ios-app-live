//
//  R_900_5000Tests.swift
//  GISTests
//
//  Created by jeweal-pm on 9/4/26.
//
//  Covers GIS/R_900_5000 -- the Zebra RFID reader integration used for
//  stock-take scanning.

import XCTest
@testable import GIS

class R_900_5000Tests: XCTestCase {

    // MARK: - Utils.string(_:defaultStr:)

    func test_utilsString_intValue_returnsStringRepresentation() {
        XCTAssertEqual(Utils.string(42), "42")
    }

    func test_utilsString_stringValue_returnsSameString() {
        XCTAssertEqual(Utils.string("already a string"), "already a string")
    }

    func test_utilsString_nilValue_returnsDefault() {
        XCTAssertEqual(Utils.string(nil, defaultStr: "--"), "--")
    }

    func test_utilsString_unsupportedType_returnsDefault() {
        // Bool isn't one of the coerced types (Int/Float/Double/String), so it
        // falls through to defaultStr even though it's technically non-nil.
        XCTAssertEqual(Utils.string(true, defaultStr: "n/a"), "n/a")
    }

    // MARK: - String helpers (GIS/R_900_5000/Utils.swift)

    func test_trim_removesLeadingAndTrailingWhitespace() {
        XCTAssertEqual("  RFID-Tag-01  ".trim(), "RFID-Tag-01")
    }

    func test_contains_find_isCaseSensitive() {
        XCTAssertTrue("StockTake".contains(find: "Stock"))
        XCTAssertFalse("StockTake".contains(find: "stock"))
    }

    func test_contains_findIgnoringCase_matchesRegardlessOfCase() {
        XCTAssertTrue("StockTake".contains(findIgnoringCase: "stock"))
    }

    func test_substring_from_returnsTailFromIndex() {
        XCTAssertEqual("0123456789".substring(from: 5), "56789")
    }

    func test_substring_to_returnsHeadUpToIndex() {
        XCTAssertEqual("0123456789".substring(to: 5), "01234")
    }

    func test_substring_withRange_returnsSlice() {
        XCTAssertEqual("0123456789".substring(with: 2..<5), "234")
    }

    func test_replace_replacesAllOccurrences() {
        XCTAssertEqual("A-B-C".replace(target: "-", withString: ":"), "A:B:C")
    }

    func test_hexadecimal_validHexString_decodesToBytes() {
        XCTAssertEqual("00ff10".hexadecimal, Data([0x00, 0xFF, 0x10]))
    }

    func test_hexadecimal_emptyString_returnsNil() {
        XCTAssertNil("".hexadecimal)
    }

    // MARK: - ZebraRFIDService.decodeFromHex
    // This backs StockTakePage.decodeZebraStockScanValue, so it's the real
    // entry point for turning a scanned RFID tag's raw hex payload into text.

    func test_decodeFromHex_printableAsciiPayload_decodesToText() {
        // "AB" = 0x41 0x42
        XCTAssertEqual(ZebraRFIDService.shared.decodeFromHex("4142"), "AB")
    }

    func test_decodeFromHex_stripsLeadingAndTrailingZeroPadding() {
        XCTAssertEqual(ZebraRFIDService.shared.decodeFromHex("00004142"), "AB")
        XCTAssertEqual(ZebraRFIDService.shared.decodeFromHex("41420000"), "AB")
    }

    func test_decodeFromHex_oddLengthAfterStripping_returnsNil() {
        XCTAssertNil(ZebraRFIDService.shared.decodeFromHex("414"))
    }

    func test_decodeFromHex_nonPrintableAsciiByte_returnsNil() {
        // 0x1F (31) is below the accepted printable-ASCII range (32...126).
        XCTAssertNil(ZebraRFIDService.shared.decodeFromHex("1F"))
    }

    func test_decodeFromHex_byteAbovePrintableAsciiRange_returnsNil() {
        // 0x7F (127) is above the accepted printable-ASCII range (32...126).
        XCTAssertNil(ZebraRFIDService.shared.decodeFromHex("7F"))
    }

    func test_decodeFromHex_allZeroPayload_stripsToEmptyStringNotNil() {
        // Both the leading- and trailing-"00" strips consume the whole value,
        // leaving an empty (even-length) string -- the guard passes and the
        // decode loop simply never runs, so the result is "" rather than nil.
        XCTAssertEqual(ZebraRFIDService.shared.decodeFromHex("0000"), "")
    }
}
