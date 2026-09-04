//
//  StartupTests.swift
//  GISTests
//
//  Created by jeweal-pm on 9/4/26.
//

import XCTest
@testable import GIS

// NOTE: LoginController and LoginWithPin are storyboard-driven massive view
// controllers; only outlet-free methods are exercised here via a bare
// `ClassName()` (same pattern as GISTests/PosTests.swift).
class StartupTests: XCTestCase {

    // MARK: - LoginController.formatTime

    func test_formatTime_zeroSeconds_returnsZeroZero() {
        let sut = LoginController()
        XCTAssertEqual(sut.formatTime(0), "00:00")
    }

    func test_formatTime_underOneMinute_padsSeconds() {
        let sut = LoginController()
        XCTAssertEqual(sut.formatTime(65), "01:05")
    }

    func test_formatTime_exactlyOneHour_wrapsMinutesBackToZero() {
        // minutes = (totalSeconds/60) % 60, so there's no hours component:
        // 3600s (1 hour) wraps the minutes field back to 0 instead of showing
        // "60:00" or an hours digit. Worth knowing if this is ever used for a
        // countdown longer than 59:59.
        let sut = LoginController()
        XCTAssertEqual(sut.formatTime(3600), "00:00")
    }

    // MARK: - LoginWithPin.decodeJWT

    func test_decodeJWT_validToken_decodesPayloadClaims() throws {
        let payload: [String: Any] = ["sub": "1234567890", "name": "Jeweal Test"]
        let payloadData = try JSONSerialization.data(withJSONObject: payload)
        var base64url = payloadData.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
        while base64url.hasSuffix("=") {
            base64url.removeLast()
        }
        let token = "header.\(base64url).signature"

        let sut = LoginWithPin()
        let decoded = sut.decodeJWT(token)

        XCTAssertEqual(decoded?["sub"] as? String, "1234567890")
        XCTAssertEqual(decoded?["name"] as? String, "Jeweal Test")
    }

    func test_decodeJWT_tokenWithoutDotSeparator_returnsNil() {
        let sut = LoginWithPin()
        XCTAssertNil(sut.decodeJWT("not-a-jwt-token"))
    }

    func test_decodeJWT_payloadSegmentNotValidBase64_returnsNil() {
        let sut = LoginWithPin()
        XCTAssertNil(sut.decodeJWT("header.!!!not-base64!!!.signature"))
    }

    func test_decodeJWT_emptyString_returnsNil() {
        let sut = LoginWithPin()
        XCTAssertNil(sut.decodeJWT(""))
    }
}
