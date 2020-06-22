//
//  tictactoeUITests.swift
//

import XCTest

class tictactoeUITests: XCTestCase {

    // just a simple test of the UI
    func testSampleGame() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["top_left"].tap()
        XCTAssertEqual(app.staticTexts["turn"].label, "Current player: O")
        app.buttons["top_middle"].tap()
        XCTAssertEqual(app.staticTexts["turn"].label, "Current player: X")
        app.buttons["middle_left"].tap()
        XCTAssertEqual(app.staticTexts["turn"].label, "Current player: O")
        app.buttons["middle_middle"].tap()
        XCTAssertEqual(app.staticTexts["turn"].label, "Current player: X")
        app.buttons["bottom_left"].tap()
        XCTAssertTrue(app.alerts.element.staticTexts["Cross won"].waitForExistence(timeout: 1.0), "Should display cross won message")
    }
}
