import SwiftUI

// Named ProgressDashboardView (not ProgressView) to avoid colliding with SwiftUI.ProgressView.
struct ProgressDashboardView: View {
    @State private var viewModel = ProgressViewModel()

    var body: some View {
        NavigationStack {
            PlaceholderContent(title: "Progress")
                .navigationTitle("Progress")
        }
    }
}

#Preview {
    ProgressDashboardView()
}
