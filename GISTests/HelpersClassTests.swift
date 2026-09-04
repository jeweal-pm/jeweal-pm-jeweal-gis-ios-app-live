//
//  HelpersClassTests.swift
//  GISTests
//
//  Created by jeweal-pm on 9/4/26.
//

import XCTest
@testable import GIS

class HelpersClassTests: XCTestCase {

    // MARK: - PriceHelper.formatPrice

    func test_formatPrice_roundsToTwoDecimalPlaces() {
        XCTAssertEqual(PriceHelper.formatPrice(1234.5), "1,234.50")
    }

    func test_formatPrice_zero_returnsZeroDotZeroZero() {
        XCTAssertEqual(PriceHelper.formatPrice(0), "0.00")
    }

    func test_formatPrice_negative_keepsSign() {
        XCTAssertEqual(PriceHelper.formatPrice(-42.1), "-42.10")
    }

    func test_formatPrice_prependsCurrencyWhenProvided() {
        XCTAssertEqual(PriceHelper.formatPrice(9.5, currency: "THB"), "THB 9.50")
    }

    func test_formatPrice_omitsCurrencyPrefixWhenEmpty() {
        let formatted = PriceHelper.formatPrice(9.5, currency: "")
        XCTAssertFalse(formatted.hasPrefix(" "))
        XCTAssertEqual(formatted, "9.50")
    }

    // MARK: - PriceHelper.unformatPrice

    func test_unformatPrice_stripsNonNumericCharacters() {
        XCTAssertEqual(PriceHelper.unformatPrice("THB 1234.50"), 1234.50, accuracy: 0.0001)
    }

    func test_unformatPrice_emptyString_returnsZero() {
        XCTAssertEqual(PriceHelper.unformatPrice(""), 0, accuracy: 0.0001)
    }

    func test_unformatPrice_onlyJunkCharacters_returnsZero() {
        // Commas are not in the allowed set for unformatPrice (unlike parsePrice),
        // so a thousands-separated string collapses to a malformed number and falls back to 0.
        XCTAssertEqual(PriceHelper.unformatPrice("1,234.50"), 0, accuracy: 0.0001)
    }

    func test_unformatPrice_negativeValue_preservesSign() {
        XCTAssertEqual(PriceHelper.unformatPrice("-99.99 THB"), -99.99, accuracy: 0.0001)
    }

    // MARK: - PriceHelper.parsePrice

    func test_parsePrice_nil_returnsZero() {
        XCTAssertEqual(PriceHelper.parsePrice(nil), 0, accuracy: 0.0001)
    }

    func test_parsePrice_removesThousandsSeparatorCommas() {
        XCTAssertEqual(PriceHelper.parsePrice("12,345.67"), 12345.67, accuracy: 0.0001)
    }

    func test_parsePrice_malformedText_returnsZero() {
        XCTAssertEqual(PriceHelper.parsePrice("N/A"), 0, accuracy: 0.0001)
    }

    func test_parsePrice_emptyString_returnsZero() {
        XCTAssertEqual(PriceHelper.parsePrice(""), 0, accuracy: 0.0001)
    }

    // MARK: - Validation.isValidEmail

    func test_isValidEmail_wellFormedAddress_returnsTrue() {
        XCTAssertTrue(Validation.isValidEmail(emailString: "customer@jeweal.co.th"))
    }

    func test_isValidEmail_missingAtSymbol_returnsFalse() {
        XCTAssertFalse(Validation.isValidEmail(emailString: "customer.jeweal.co.th"))
    }

    func test_isValidEmail_missingDomain_returnsFalse() {
        XCTAssertFalse(Validation.isValidEmail(emailString: "customer@"))
    }

    func test_isValidEmail_emptyString_returnsFalse() {
        XCTAssertFalse(Validation.isValidEmail(emailString: ""))
    }

    // MARK: - CommonClass.isValidEmail (duplicate regex used elsewhere in the app)

    func test_commonClassIsValidEmail_matchesValidationBehavior() {
        XCTAssertTrue(CommonClass.isValidEmail(emailString: "customer@jeweal.co.th"))
        XCTAssertFalse(CommonClass.isValidEmail(emailString: "not-an-email"))
    }

    // MARK: - Validation.isValidMobileNumber

    func test_isValidMobileNumber_tenPlainDigits_returnsTrue() {
        XCTAssertTrue(Validation.isValidMobileNumber(testString: "0912345678"))
    }

    func test_isValidMobileNumber_stripsFormattingPunctuationAndSpaces() {
        XCTAssertTrue(Validation.isValidMobileNumber(testString: "(091) 234-5678"))
    }

    func test_isValidMobileNumber_wrongLength_returnsFalse() {
        XCTAssertFalse(Validation.isValidMobileNumber(testString: "12345"))
    }

    func test_isValidMobileNumber_containsLetters_returnsFalse() {
        XCTAssertFalse(Validation.isValidMobileNumber(testString: "091-234-567a"))
    }

    // MARK: - Validation.isPasswordValid

    func test_isPasswordValid_meetsAllRules_returnsTrue() {
        XCTAssertTrue(Validation.isPasswordValid("Passw0rd"))
    }

    func test_isPasswordValid_missingUppercase_returnsFalse() {
        XCTAssertFalse(Validation.isPasswordValid("passw0rd"))
    }

    func test_isPasswordValid_missingDigit_returnsFalse() {
        XCTAssertFalse(Validation.isPasswordValid("Password"))
    }

    func test_isPasswordValid_shorterThanEightCharacters_returnsFalse() {
        XCTAssertFalse(Validation.isPasswordValid("Pass1"))
    }

    // MARK: - Validation.isEnterCharacter

    func test_isEnterCharacter_lettersAndSpacesOnly_returnsTrue() {
        XCTAssertTrue(Validation.isEnterCharacter(testString: "John Doe"))
    }

    func test_isEnterCharacter_containingDigits_returnsFalse() {
        XCTAssertFalse(Validation.isEnterCharacter(testString: "John123"))
    }

    // MARK: - Validation.isblank
    // NOTE: despite the name, `isblank` returns true when the trimmed string is
    // NOT empty (`!trimstring.isEmpty`) — i.e. it actually reports "is not blank".
    // These tests pin down the real, currently-shipping behavior so a future
    // refactor doesn't flip the polarity by accident.

    func test_isblank_nonEmptyString_returnsTrue() {
        XCTAssertTrue(Validation.isblank(testString: "hello"))
    }

    func test_isblank_emptyString_returnsFalse() {
        XCTAssertFalse(Validation.isblank(testString: ""))
    }

    func test_isblank_whitespaceOnlyString_returnsFalse() {
        XCTAssertFalse(Validation.isblank(testString: "   "))
    }

    // MARK: - LinkedCartContext (used by the POS linked-order-flow restore logic)

    func test_linkedCartContext_parsesStringFieldsFromDictionary() {
        let dict: NSDictionary = [
            "linked_cart_id": "cart-1",
            "linked_order_id": "order-1",
            "existing_cart_status": "open",
            "linked_order_type": "custom",
            "can_create_new_cart": true
        ]

        let context = LinkedCartContext(inventoryItem: dict)

        XCTAssertEqual(context.linkedCartId, "cart-1")
        XCTAssertEqual(context.linkedOrderId, "order-1")
        XCTAssertEqual(context.existingCartStatus, "open")
        XCTAssertEqual(context.linkedOrderType, "custom")
        XCTAssertTrue(context.canCreateNewCart)
    }

    func test_linkedCartContext_missingKeys_defaultToEmptyStringsAndTrue() {
        let context = LinkedCartContext(inventoryItem: [:])

        XCTAssertEqual(context.linkedCartId, "")
        XCTAssertEqual(context.linkedOrderId, "")
        XCTAssertEqual(context.existingCartStatus, "")
        // An absent/malformed can_create_new_cart must never trigger a restore-block,
        // so the documented default is `true`.
        XCTAssertTrue(context.canCreateNewCart)
    }

    func test_linkedCartContext_nsNullValues_treatedAsEmptyString() {
        let dict: NSDictionary = [
            "linked_cart_id": NSNull(),
            "existing_cart_status": NSNull()
        ]

        let context = LinkedCartContext(inventoryItem: dict)

        XCTAssertEqual(context.linkedCartId, "")
        XCTAssertEqual(context.existingCartStatus, "")
    }

    func test_linkedCartContext_canCreateNewCart_parsesNumericZeroAsFalse() {
        let dict: NSDictionary = ["can_create_new_cart": NSNumber(value: 0)]
        XCTAssertFalse(LinkedCartContext(inventoryItem: dict).canCreateNewCart)
    }

    func test_linkedCartContext_canCreateNewCart_parsesStringFalseVariantsAsFalse() {
        for value in ["false", "0", "no", "NO", "False"] {
            let dict: NSDictionary = ["can_create_new_cart": value]
            XCTAssertFalse(
                LinkedCartContext(inventoryItem: dict).canCreateNewCart,
                "Expected '\(value)' to parse as false"
            )
        }
    }

    func test_linkedCartContext_canCreateNewCart_unrecognizedStringDefaultsToTrue() {
        let dict: NSDictionary = ["can_create_new_cart": "maybe"]
        XCTAssertTrue(LinkedCartContext(inventoryItem: dict).canCreateNewCart)
    }

    func test_linkedCartContext_trimsWhitespaceFromStringFields() {
        let dict: NSDictionary = ["linked_cart_id": "  cart-9  "]
        XCTAssertEqual(LinkedCartContext(inventoryItem: dict).linkedCartId, "cart-9")
    }

    // MARK: - LinkedCartContextStore

    func test_linkedCartContextStore_saveThenRetrieve_roundTrips() {
        let store = LinkedCartContextStore.shared
        let context = LinkedCartContext(inventoryItem: ["linked_cart_id": "abc"])

        store.save(context, orderType: "custom", customerId: "cust-1")

        XCTAssertEqual(store.context(orderType: "custom", customerId: "cust-1")?.linkedCartId, "abc")

        store.clear(orderType: "custom", customerId: "cust-1")
    }

    func test_linkedCartContextStore_missingEntry_returnsNil() {
        let store = LinkedCartContextStore.shared
        XCTAssertNil(store.context(orderType: "nonexistent-type", customerId: "nonexistent-customer"))
    }

    func test_linkedCartContextStore_keysAreScopedByOrderTypeAndCustomerId() {
        let store = LinkedCartContextStore.shared
        let contextA = LinkedCartContext(inventoryItem: ["linked_cart_id": "A"])
        let contextB = LinkedCartContext(inventoryItem: ["linked_cart_id": "B"])

        store.save(contextA, orderType: "custom", customerId: "cust-2")
        store.save(contextB, orderType: "reserve", customerId: "cust-2")

        XCTAssertEqual(store.context(orderType: "custom", customerId: "cust-2")?.linkedCartId, "A")
        XCTAssertEqual(store.context(orderType: "reserve", customerId: "cust-2")?.linkedCartId, "B")

        store.clear(orderType: "custom", customerId: "cust-2")
        store.clear(orderType: "reserve", customerId: "cust-2")
    }

    func test_linkedCartContextStore_clear_removesEntry() {
        let store = LinkedCartContextStore.shared
        store.save(LinkedCartContext(inventoryItem: ["linked_cart_id": "temp"]), orderType: "custom", customerId: "cust-3")

        store.clear(orderType: "custom", customerId: "cust-3")

        XCTAssertNil(store.context(orderType: "custom", customerId: "cust-3"))
    }
}
