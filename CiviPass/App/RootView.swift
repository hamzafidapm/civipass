import SwiftUI
import SwiftData

struct RootView: View {
    @State private var appState = AppState()

    var body: some View {
        Group {
            if appState.hasCompletedOnboarding {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .environment(appState)
    }
}

#Preview {
    RootView()
        .modelContainer(PersistenceController.previewModelContainer)
}
