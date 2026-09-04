//
//  CommonModalsTests.swift
//  GISTests
//
//  Created by jeweal-pm on 9/4/26.
//

import XCTest
@testable import GIS

// NOTE: AddressType.*Text rely on String.localizedString (GIS/HelpersClass/AppLanguage.swift),
// which falls back to returning the original English string whenever
// AppLanguage.shared.bundle hasn't been set (true by default, since nothing
// in this suite calls AppLanguage.shared.set(index:)). If some other test
// ever calls that, these assertions would need revisiting — the shared
// instance is process-global.
class CommonModalsTests: XCTestCase {

    override func tearDownWithError() throws {
        UserDefaults.standard.removeObject(forKey: "location")
    }

    // MARK: - AddressType (pure enum, no view controller needed)

    func test_addressType_editBillingAddress_titles() {
        XCTAssertEqual(AddressType.editBillingAddress.viewTitleText, "Edit Billing Address")
        XCTAssertEqual(AddressType.editBillingAddress.formTitleText, "Billing Address")
        XCTAssertEqual(AddressType.editBillingAddress.defaultAddressText, "Default Billing Address")
    }

    func test_addressType_addShippingAddress_titles() {
        XCTAssertEqual(AddressType.addShippingAddress.viewTitleText, "Add Shipping Address")
        XCTAssertEqual(AddressType.addShippingAddress.formTitleText, "Shipping Address")
        XCTAssertEqual(AddressType.addShippingAddress.defaultAddressText, "Default Shipping Address")
    }

    func test_addressType_editAndAddBillingShareTheSameFormAndDefaultText() {
        XCTAssertEqual(AddressType.editBillingAddress.formTitleText, AddressType.addBillingAddress.formTitleText)
        XCTAssertEqual(AddressType.editBillingAddress.defaultAddressText, AddressType.addBillingAddress.defaultAddressText)
    }

    // MARK: - CommonInventory.formatCTS

    func test_formatCTS_wholeNumber_dropsDecimalPlaces() {
        let sut = CommonInventory()
        XCTAssertEqual(sut.formatCTS(2.0), "2")
    }

    func test_formatCTS_fractionalValue_showsTwoDecimalPlaces() {
        let sut = CommonInventory()
        XCTAssertEqual(sut.formatCTS(2.5), "2.50")
    }

    // MARK: - CommonInventory.buildReservePayload
    // This is the payload builder behind "Reserve" from an inventory item, and
    // explicitly preserves the linked-cart fields added for the POS Linked
    // Order Flow feature (see also GISTests/HelpersClassTests.swift's
    // LinkedCartContext tests, which parse the same fields on the way in).

    func test_buildReservePayload_preservesLinkedCartFieldsWhenPresent() {
        let sut = CommonInventory()
        sut.mCustomerId = "cust-1"
        sut.mSalesPersonId = "sp-1"

        let item: NSDictionary = [
            "linked_cart_id": "cart-9",
            "linked_order_id": "order-9",
            "existing_cart_status": "open",
            "can_create_new_cart": false,
            "linked_order_type": "custom"
        ]

        let payload = sut.buildReservePayload(from: item)
        let cartItems = payload["cartItems"] as? [[String: Any]]
        let cartItem = cartItems?.first

        XCTAssertEqual(cartItem?["linked_cart_id"] as? String, "cart-9")
        XCTAssertEqual(cartItem?["linked_order_id"] as? String, "order-9")
        XCTAssertEqual(cartItem?["existing_cart_status"] as? String, "open")
        XCTAssertEqual(cartItem?["can_create_new_cart"] as? Bool, false)
        XCTAssertEqual(cartItem?["linked_order_type"] as? String, "custom")
    }

    func test_buildReservePayload_missingLinkedCartFields_defaultToEmptyAndCanCreateNewCartTrue() {
        let sut = CommonInventory()
        let payload = sut.buildReservePayload(from: [:])
        let cartItem = (payload["cartItems"] as? [[String: Any]])?.first

        XCTAssertEqual(cartItem?["linked_cart_id"] as? String, "")
        XCTAssertEqual(cartItem?["can_create_new_cart"] as? Bool, true)
    }

    func test_buildReservePayload_topLevelCustomerAndSalesPersonComeFromInstanceState() {
        let sut = CommonInventory()
        sut.mCustomerId = "cust-42"
        sut.mSalesPersonId = "sp-42"

        let payload = sut.buildReservePayload(from: [:])

        XCTAssertEqual(payload["customer_id"] as? String, "cust-42")
        XCTAssertEqual(payload["sales_person_id"] as? String, "sp-42")
        XCTAssertEqual(payload["order_type"] as? String, "reserve")
    }

    func test_buildReservePayload_missingLocationId_fallsBackToStoredLocation() {
        UserDefaults.standard.set("store-7", forKey: "location")
        let sut = CommonInventory()

        let payload = sut.buildReservePayload(from: [:])
        let cartItem = (payload["cartItems"] as? [[String: Any]])?.first

        XCTAssertEqual(cartItem?["location_id"] as? String, "store-7")
    }

    func test_buildReservePayload_itemLocationIdTakesPriorityOverStoredLocation() {
        UserDefaults.standard.set("store-7", forKey: "location")
        let sut = CommonInventory()

        let payload = sut.buildReservePayload(from: ["location_id": "store-3"])
        let cartItem = (payload["cartItems"] as? [[String: Any]])?.first

        XCTAssertEqual(cartItem?["location_id"] as? String, "store-3")
    }

    // MARK: - ProductStoneEdit.mCompareIds

    func test_mCompareIds_matchingId_returnsName() {
        let sut = ProductStoneEdit()
        let array: NSArray = [
            ["id": "1", "name": "Round"],
            ["id": "2", "name": "Princess"]
        ]
        XCTAssertEqual(sut.mCompareIds(arr: array, id: "2"), "Princess")
    }

    func test_mCompareIds_noMatchingId_returnsEmptyString() {
        let sut = ProductStoneEdit()
        let array: NSArray = [["id": "1", "name": "Round"]]
        XCTAssertEqual(sut.mCompareIds(arr: array, id: "99"), "")
    }

    func test_mCompareIds_emptyArray_returnsEmptyString() {
        let sut = ProductStoneEdit()
        XCTAssertEqual(sut.mCompareIds(arr: [], id: "1"), "")
    }
}
