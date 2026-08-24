import XCTest

final class CiviPassUITests: XCTestCase {
    func testAppLaunches() throws {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.staticTexts["CiviPass"].waitForExistence(timeout: 5))
    }
}
