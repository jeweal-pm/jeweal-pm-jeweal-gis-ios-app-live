//
//  TraceabilityTests.swift
//  GISTests
//

import XCTest
@testable import GIS

final class TraceabilityTests: XCTestCase {

    func testMockMatchesDesign() {
        let mock = TraceabilityData.mock
        XCTAssertEqual(mock.steps.count, 9)
        XCTAssertEqual(mock.steps.first?.title, "Product Design")
        XCTAssertNil(mock.steps.first?.date)
        XCTAssertEqual(mock.steps.last?.title, "QC & Shipping")
        XCTAssertEqual(mock.steps.filter { $0.lineBelow }.count, 3)
    }

    func testStepParsesFromDictionary() {
        let step = TraceStep(dictionary: ["title": "Diamond Mine", "group": "diamond", "location": "Zimbabwe",
                                          "date": "20/04/25 11:30", "is_major": true, "line_below": false])
        XCTAssertEqual(step?.group, .diamond)
        XCTAssertEqual(step?.location, "Zimbabwe")
        XCTAssertTrue(step?.isMajor ?? false)
    }

    func testStepRejectsUnknownGroup() {
        XCTAssertNil(TraceStep(dictionary: ["title": "X", "group": "unknown"]))
        XCTAssertNil(TraceStep(dictionary: ["group": "chain"]))
    }

    func testRowHeights() {
        let steps = TraceabilityData.mock.steps
        XCTAssertEqual(TraceabilityView.rowHeight(at: 0, in: steps, isLast: false), 68) // major + line
        XCTAssertEqual(TraceabilityView.rowHeight(at: 1, in: steps, isLast: false), 45) // major -> minor
        XCTAssertEqual(TraceabilityView.rowHeight(at: 3, in: steps, isLast: false), 79) // minor + line
        XCTAssertEqual(TraceabilityView.rowHeight(at: 8, in: steps, isLast: true), 34)
    }
}
