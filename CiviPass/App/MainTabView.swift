import SwiftUI
import SwiftData

struct MainTabView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        @Bindable var appState = appState
        TabView(selection: $appState.selectedTab) {
            ForEach(AppTab.allCases) { tab in
                tabContent(for: tab)
                    .tabItem {
                        // Identifier goes on the tabItem's own Label (not the content view
                        // below) since this is what SwiftUI builds the tab's UITabBarItem
                        // from — the thing iOS's auto-generated "More" overflow list reads
                        // title/icon from when a tab doesn't fit in the visible bar.
                        Label(tab.title, systemImage: tab.systemImage)
                            .accessibilityIdentifier("moreMenuRow.\(tab.rawValue)")
                    }
                    .tag(tab)
                    .accessibilityIdentifier("tab.\(tab.rawValue)")
            }
        }
    }

    @ViewBuilder
    private func tabContent(for tab: AppTab) -> some View {
        switch tab {
        case .today: TodayView()
        case .study: StudyView()
        case .practice: PracticeView()
        case .mockTest: MockTestView()
        case .progress: ProgressDashboardView()
        case .settings: SettingsView()
        }
    }
}

#Preview {
    MainTabView()
        .environment(AppState())
        .environment(EntitlementManager())
        .modelContainer(PersistenceController.previewModelContainer)
}
