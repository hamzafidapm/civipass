import Foundation
import Observation

@Observable
final class AppState {
    var hasCompletedOnboarding: Bool = false
    var selectedTab: AppTab = .today
}

enum AppTab: String, CaseIterable, Identifiable {
    case today
    case study
    case practice
    case mockTest
    case progress
    case settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .today: return "Today"
        case .study: return "Study"
        case .practice: return "Practice"
        case .mockTest: return "Mock Test"
        case .progress: return "Progress"
        case .settings: return "Settings"
        }
    }

    var systemImage: String {
        switch self {
        case .today: return "sun.max"
        case .study: return "book"
        case .practice: return "checkmark.circle"
        case .mockTest: return "doc.text.magnifyingglass"
        case .progress: return "chart.line.uptrend.xyaxis"
        case .settings: return "gearshape"
        }
    }
}
