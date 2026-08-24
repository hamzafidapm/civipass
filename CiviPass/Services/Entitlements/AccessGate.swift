import Foundation

/// Pure free/premium access decision, deliberately independent of StoreKit so it can
/// be unit tested with a plain injected Bool instead of a real EntitlementManager.
enum AccessGate {
    static let freeCategory: StudyCategory = .americanGovernment

    /// Whether `category` requires premium access. `nil` (the "All" filter) is never
    /// itself locked — callers filter its *contents* to the free category separately.
    static func isLocked(_ category: StudyCategory?, hasPremiumAccess: Bool) -> Bool {
        guard let category else { return false }
        if hasPremiumAccess { return false }
        return category != freeCategory
    }
}
