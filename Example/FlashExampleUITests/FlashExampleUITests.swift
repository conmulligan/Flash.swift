//
//  FlashExampleUITests.swift
//  FlashExampleUITests
//
//  Created by Conor Mulligan on 31/05/2023.
//

import XCTest
import Flash

final class FlashExampleUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {

    }

    func testShowFlashMessage() throws {
        let app = XCUIApplication()
        app.launch()

        let buttonElement = app.buttons["show_basic_flash_view_button"]
        buttonElement.tap()

        let flashElement = app.otherElements["flash_view"]
        XCTAssert(flashElement.waitForExistence(timeout: 1))

        let predicate = NSPredicate(format: "exists == 0")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: flashElement)

        let waiter = XCTWaiter()
        let result = waiter.wait(for: [expectation], timeout: 10)
        switch result {
        case .completed:
            XCTAssertTrue(!flashElement.exists)
        case .timedOut:
            XCTFail("Flash view still exists in the view heirarchy.")
        default:
            break
        }
    }

    func testShowFlashMessages() throws {
        let app = XCUIApplication()
        app.launch()

        let buttonElement = app.buttons["show_basic_flash_view_button"]
        for _ in 0..<5 {
            buttonElement.tap()
        }

        let flashElement = app.otherElements["flash_view"]

        let predicate = NSPredicate(format: "exists == 0")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: flashElement)

        let waiter = XCTWaiter()
        let result = waiter.wait(for: [expectation], timeout: 10)
        switch result {
        case .completed:
            XCTAssertTrue(!flashElement.exists)
        case .timedOut:
            XCTFail("Flash view still exists in the view heirarchy.")
        default:
            break
        }
    }
}
