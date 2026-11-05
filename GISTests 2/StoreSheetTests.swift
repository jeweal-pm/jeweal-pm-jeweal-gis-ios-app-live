//
//  StoreSheetTests.swift
//  GISTests
//

import XCTest
@testable import GIS

final class StoreSheetTests: XCTestCase {

    private func makeWindow(with controller: UIViewController) -> UIWindow {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 375, height: 812))
        window.rootViewController = controller
        window.makeKeyAndVisible()
        controller.view.layoutIfNeeded()
        return window
    }

    func testStorefrontIconComesFromDesignAsset() {
        XCTAssertNotNil(UIImage(named: "building_storefront"))

        let controller = StoreSetupEmptyStateController(setupURL: nil)
        let window = makeWindow(with: controller)
        defer { window.isHidden = true }

        let expected = UIImage(named: "building_storefront")?.pngData()
        XCTAssertEqual(controller.iconView.image?.pngData(), expected)
    }

    func testNoStoresSheetIsTallLikeTheDesign() {
        let controller = StoreSetupEmptyStateController(setupURL: nil)
        let window = makeWindow(with: controller)
        defer { window.isHidden = true }
        controller.view.layoutIfNeeded()

        // Design: the sheet covers about 91% of the screen (top at 72 of 812).
        // bounds is used because the sheet is translated while it slides in.
        let ratio = controller.sheetView.bounds.height / controller.view.bounds.height
        XCTAssertGreaterThan(ratio, 0.85)
        XCTAssertLessThan(ratio, 0.95)
    }

    func testStoreSheetCannotBePresentedTwice() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle(for: LoginController.self))
        guard let login = storyboard.instantiateViewController(withIdentifier: "LoginController") as? LoginController else {
            return XCTFail("LoginController is missing from Main.storyboard")
        }
        login.loadViewIfNeeded()

        XCTAssertTrue(login.canPresentStoreSheet, "Sheet starts hidden, so it can be presented")

        login.mStoreContentView.isHidden = false
        XCTAssertFalse(login.canPresentStoreSheet, "A visible sheet must not be presented again")
    }
}
