import Foundation

/// Top-level category a citizenship test question belongs to.
enum StudyCategory: String, Codable, CaseIterable, Identifiable {
    case americanGovernment = "American Government"
    case americanHistory = "American History"
    case integratedCivics = "Integrated Civics"

    var id: String { rawValue }
}
