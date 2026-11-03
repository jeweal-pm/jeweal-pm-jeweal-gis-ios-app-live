//
//  KycProfileBannerTests.swift
//  GISTests
//

import XCTest
@testable import GIS

final class KycProfileBannerTests: XCTestCase {
    
    func testMissingStatusShowsNoBanner() {
        XCTAssertNil(KycProfileBanner(apiValue: nil))
        XCTAssertNil(KycProfileBanner(apiValue: NSNull()))
    }
    
    func testEmptyStatusMeansNotVerified() {
        XCTAssertEqual(KycProfileBanner(apiValue: ""), .notVerified)
        XCTAssertEqual(KycProfileBanner(apiValue: "   "), .notVerified)
    }
    
    func testApiValuesMapToBanners() {
        XCTAssertEqual(KycProfileBanner(apiValue: "Expired"), .expired)
        XCTAssertEqual(KycProfileBanner(apiValue: "Completed"), .completed)
        XCTAssertEqual(KycProfileBanner(apiValue: "Approved"), .approved)
        XCTAssertEqual(KycProfileBanner(apiValue: "Rejected"), .rejected)
        XCTAssertEqual(KycProfileBanner(apiValue: "In Progress"), .inProgress)
        // The API sends "pending" while verification is in progress.
        XCTAssertEqual(KycProfileBanner(apiValue: "pending"), .inProgress)
    }
    
    func testUnknownValueShowsNoBanner() {
        XCTAssertNil(KycProfileBanner(apiValue: "something-else"))
    }
    
    func testVerifyButtonOnlyWhenKycCanBeRetried() {
        XCTAssertTrue(KycProfileBanner.notVerified.showsVerifyButton)
        XCTAssertTrue(KycProfileBanner.rejected.showsVerifyButton)
        XCTAssertTrue(KycProfileBanner.expired.showsVerifyButton)
        XCTAssertFalse(KycProfileBanner.inProgress.showsVerifyButton)
        XCTAssertFalse(KycProfileBanner.approved.showsVerifyButton)
        XCTAssertFalse(KycProfileBanner.completed.showsVerifyButton)
    }
    
    func testCompletedUsesShieldInsteadOfBanner() {
        XCTAssertFalse(KycProfileBanner.completed.showsBanner)
        XCTAssertTrue(KycProfileBanner.notVerified.showsBanner)
    }
    
    func testBannerIcons() {
        XCTAssertNil(KycProfileBanner.notVerified.iconName)
        XCTAssertEqual(KycProfileBanner.rejected.iconName, "kyc_rejected")
        XCTAssertEqual(KycProfileBanner.expired.iconName, "kyc_expired")
        XCTAssertEqual(KycProfileBanner.inProgress.iconName, "kyc_in_progress")
        XCTAssertEqual(KycProfileBanner.approved.iconName, "kyc_approved")
    }
    
    func testApprovedOrCompletedWithPastExpireDateCanVerifyAgain() {
        let today = Date(timeIntervalSince1970: 1_793_000_000) // 2026-10-26
        XCTAssertEqual(KycProfileBanner(apiValue: "Approved", expireDate: "2020-01-05", today: today), .expired)
        XCTAssertEqual(KycProfileBanner(apiValue: "Completed", expireDate: "2020-01-05", today: today), .expired)
        XCTAssertEqual(KycProfileBanner(apiValue: "Approved", expireDate: "2035-01-05", today: today), .approved)
        XCTAssertEqual(KycProfileBanner(apiValue: "Completed", expireDate: "2035-01-05", today: today), .completed)
        XCTAssertEqual(KycProfileBanner(apiValue: "Approved", expireDate: nil, today: today), .approved)
    }
    
    func testInProgressNeverVerifiesAgainEvenWithPastExpireDate() {
        let banner = KycProfileBanner(apiValue: "In Progress", expireDate: "2020-01-05")
        XCTAssertEqual(banner, .inProgress)
        XCTAssertEqual(banner?.showsVerifyButton, false)
    }
    
    func testExpireDateIsNotExpiredOnTheSameDay() {
        let noon = ISO8601DateFormatter().date(from: "2026-11-02T05:00:00Z")!
        XCTAssertFalse(KycProfileBanner.isExpired("2026-11-02", today: noon))
        XCTAssertTrue(KycProfileBanner.isExpired("2026-11-01", today: noon))
        XCTAssertFalse(KycProfileBanner.isExpired("not a date", today: noon))
    }
    
    func testVerifyURLContainsVerificationId() {
        let url = KycVerifyWebViewController.verifyURL(
            id: "01a19a57-5900-7964-bc6c-ac70ea6ba1c8", base: "https://sandbox-idv.ondato.com/")
        XCTAssertEqual(url?.absoluteString,
                       "https://sandbox-idv.ondato.com/?id=01a19a57-5900-7964-bc6c-ac70ea6ba1c8")
    }
    
    func testVerifyURLFromCreateKycResponse() {
        let response: NSDictionary = [
            "id": "01a19a6c-de13-7237-aabc-ba08b0abfe2b",
            "url": "https://sandbox-idv.ondato.com/?id=01a19a6c-de13-7237-aabc-ba08b0abfe2b"
        ]
        XCTAssertEqual(KycVerifyWebViewController.verifyURL(from: response)?.absoluteString,
                       "https://sandbox-idv.ondato.com/?id=01a19a6c-de13-7237-aabc-ba08b0abfe2b")
    }
    
    func testVerifyURLFallsBackToIdWhenUrlMissingOrNotHttps() {
        let onlyId: NSDictionary = ["id": "abc-123"]
        XCTAssertEqual(KycVerifyWebViewController.verifyURL(from: onlyId)?.query, "id=abc-123")
        let insecure: NSDictionary = ["id": "abc-123", "url": "http://evil.example/?id=abc-123"]
        XCTAssertEqual(KycVerifyWebViewController.verifyURL(from: insecure)?.host, "sandbox-idv.ondato.com")
        XCTAssertNil(KycVerifyWebViewController.verifyURL(from: [:]))
    }
    
    func testVerifyURLNeedsAnId() {
        XCTAssertNil(KycVerifyWebViewController.verifyURL(id: "  ", base: "https://sandbox-idv.ondato.com/"))
    }
    
    func testBannerIconAssetsExist() {
        for name in ["kyc_rejected", "kyc_expired", "kyc_in_progress", "kyc_approved", "kyc_completed"] {
            XCTAssertNotNil(UIImage(named: name, in: Bundle(for: CustomerProfile.self), compatibleWith: nil), name)
        }
    }
}
