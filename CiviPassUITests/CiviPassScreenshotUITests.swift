import XCTest

/// Walks the main screens and attaches a screenshot at each stop, so CI's .xcresult
/// bundle carries a visual record of the app — useful when nobody on the team has a Mac
/// to run the app locally. Every step is resilient: a missing/renamed element is skipped
/// rather than crashing the whole run, so later screenshots still get captured.
final class CiviPassScreenshotUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = true
    }

    func testCaptureAppScreenshots() throws {
        let app = XCUIApplication()
        app.launch()

        tapButton(app.buttons, labelContains: "Get Started")
        attach(app, named: "01-today")

        tapButton(app.tabBars.buttons, labelContains: "Study")
        tapButton(app.segmentedControls.buttons, labelContains: "American Government")
        attach(app, named: "02-study")

        if tapButton(app.buttons, labelContains: "Take a Mock Quiz") {
            attach(app, named: "03-quiz-question")

            tapElement(app.buttons["answerOption0"])
            attach(app, named: "04-quiz-answered")

            tapElement(app.navigationBars.buttons.firstMatch)
        }

        tapButton(app.tabBars.buttons, labelContains: "Progress")
        attach(app, named: "05-progress")

        tapButton(app.tabBars.buttons, labelContains: "Study")
        tapButton(app.segmentedControls.buttons, labelContains: "American History")
        attach(app, named: "06-paywall")
    }

    // MARK: - Resilient navigation helpers

    @discardableResult
    private func tapButton(_ query: XCUIElementQuery, labelContains text: String, timeout: TimeInterval = 5) -> Bool {
        let match = query.matching(NSPredicate(format: "label CONTAINS[c] %@", text)).firstMatch
        return tapElement(match, timeout: timeout)
    }

    @discardableResult
    private func tapElement(_ element: XCUIElement, timeout: TimeInterval = 5) -> Bool {
        guard element.waitForExistence(timeout: timeout) else { return false }
        element.tap()
        return true
    }

    // MARK: - Screenshot capture

    private func attach(_ app: XCUIApplication, named name: String) {
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
