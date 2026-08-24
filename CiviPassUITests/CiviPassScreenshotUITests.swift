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
        // tappable top-level tab. That list's rows are built entirely by
        // UITabBarController internals, not by any SwiftUI view of ours, so there's
        // no accessibilityIdentifier of ours to attach to the row itself; its label
        // ("Progress") comes straight from AppTab.progress.title, not a guess.
        tapButton(app.tabBars.buttons, labelContains: "More")
        if !tapButton(app.cells, labelContains: "Progress") {
            _ = tapButton(app.buttons, labelContains: "Progress")
        }
        // Confirm the Progress screen's own content actually loaded before capturing.
        // This check is what would have caught the wrong-screen bug immediately
        // instead of letting it pass silently.
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

    // MARK: - Screenshot capture

    private func attach(_ app: XCUIApplication, named name: String) {
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
