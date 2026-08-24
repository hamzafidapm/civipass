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
            // Wait for the pop-back transition to fully settle — tapping the tab bar
            // while it was still mid-transition let the tap land on the still-visible
            // Study screen instead of switching tabs, so "05-progress" silently
            // captured the wrong screen.
            _ = app.segmentedControls.firstMatch.waitForExistence(timeout: 5)
        }

        // AppTab has 6 cases, and iOS's tab bar auto-collapses everything past the
        // first 4 into a system-generated "More" list — Progress isn't a directly
        // tappable top-level tab.
        tapButton(app.tabBars.buttons, labelContains: "More")
        tapMoreMenuProgressRow(app)
        // Confirm the actual Progress dashboard loaded (not just the More menu we came
        // from) before capturing — both its populated and empty states share this
        // navigation title, so it's a reliable signal regardless of quiz history.
        _ = app.navigationBars["Progress"].waitForExistence(timeout: 5)
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

    /// Taps the "Progress" row in iOS's auto-generated "More" overflow list. Its rows are
    /// built by UITabBarController internals, not any SwiftUI view of ours, so we can't be
    /// certain what element type XCUITest classifies them as (an earlier attempt matching
    /// app.cells / app.buttons specifically found nothing). Tries the identifier we added
    /// to the tab's Label first, then falls back to a type-agnostic label search so a
    /// classification guess can't silently strand the test on the More menu again.
    @discardableResult
    private func tapMoreMenuProgressRow(_ app: XCUIApplication) -> Bool {
        if tapElement(app.descendants(matching: .any)["moreMenuRow.progress"], timeout: 3) {
            return true
        }
        let labelMatch = NSPredicate(format: "label CONTAINS[c] %@", "Progress")
        if tapElement(app.tables.descendants(matching: .any).matching(labelMatch).firstMatch, timeout: 3) {
            return true
        }
        return tapElement(app.descendants(matching: .any).matching(labelMatch).firstMatch, timeout: 3)
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
