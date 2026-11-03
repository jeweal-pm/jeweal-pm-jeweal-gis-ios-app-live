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
    
    func testBannerIconAssetsExist() {
        for name in ["kyc_rejected", "kyc_expired", "kyc_in_progress", "kyc_approved", "kyc_completed"] {
            XCTAssertNotNil(UIImage(named: name, in: Bundle(for: CustomerProfile.self), compatibleWith: nil), name)
        }
    }
}
