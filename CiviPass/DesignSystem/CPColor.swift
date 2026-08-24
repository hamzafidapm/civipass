import SwiftUI

/// CiviPass brand and semantic color tokens. Brand colors are defined in the asset
/// catalog (BrandPrimary/BrandAccent) with distinct light/dark appearances so they
/// stay legible in both modes rather than using one fixed RGB value everywhere.
enum CPColor {
    static let brandPrimary = Color("BrandPrimary")
    static let brandAccent = Color("BrandAccent")

    static let background = Color(.systemBackground)
    static let secondaryBackground = Color(.secondarySystemBackground)
    static let cardBackground = Color(.secondarySystemGroupedBackground)

    static let success = Color.green
    static let warning = Color.orange
    static let danger = Color.red
}
