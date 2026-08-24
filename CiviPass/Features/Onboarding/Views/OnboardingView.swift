import SwiftUI

struct OnboardingView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = OnboardingViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: CPSpacing.lg) {
                Spacer()

                VStack(spacing: CPSpacing.sm) {
                    Text("CiviPass")
                        .font(CPTypography.largeTitle)
                    Text("Your path to U.S. Citizenship.")
                        .font(CPTypography.subtitle)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                Spacer()

                Button("Get Started") {
                    appState.hasCompletedOnboarding = true
                }
                .buttonStyle(CPPrimaryButtonStyle())
            }
            .padding(CPSpacing.lg)
        }
    }
}

#Preview {
    OnboardingView()
        .environment(AppState())
}
