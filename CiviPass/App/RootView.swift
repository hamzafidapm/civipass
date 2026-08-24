import SwiftUI
import SwiftData

struct RootView: View {
    @State private var appState = AppState()
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        Group {
            if appState.hasCompletedOnboarding {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .environment(appState)
        .task {
            do {
                try QuestionRepository.seedIfNeeded(context: modelContext)
            } catch {
                print("RootView: failed to seed questions - \(error)")
            }
        }
    }
}

#Preview {
    RootView()
        .modelContainer(PersistenceController.previewModelContainer)
}
