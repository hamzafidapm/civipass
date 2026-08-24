import SwiftUI

/// CiviPass typography tokens, built on Dynamic Type text styles.
enum CPTypography {
    static let largeTitle = Font.system(.largeTitle, design: .rounded, weight: .bold)
    static let title = Font.system(.title2, design: .rounded, weight: .semibold)
    static let subtitle = Font.system(.title3, design: .default, weight: .regular)
    static let body = Font.system(.body, design: .default, weight: .regular)
    static let caption = Font.system(.caption, design: .default, weight: .medium)
}
