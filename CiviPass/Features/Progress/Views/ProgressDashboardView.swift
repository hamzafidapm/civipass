import SwiftUI
import SwiftData

// Named ProgressDashboardView (not ProgressView) to avoid colliding with SwiftUI.ProgressView.
struct ProgressDashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = ProgressViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if let errorMessage = viewModel.errorMessage {
                    ContentUnavailableView(
                        "Couldn't Load Progress",
                        systemImage: "exclamationmark.triangle",
                        description: Text(errorMessage)
                    )
                } else if viewModel.summary.totalQuizzes == 0 {
                    ContentUnavailableView(
                        "No Quizzes Yet",
                        systemImage: "chart.bar",
                        description: Text("Complete a mock quiz to start tracking your progress.")
                    )
                } else {
                    List {
                        Section {
                            statRow(title: "Quizzes Taken", value: "\(viewModel.summary.totalQuizzes)")
                            statRow(title: "Overall Accuracy", value: percentString(viewModel.summary.overallAccuracy))
                            statRow(title: "Current Streak", value: streakText)
                        }

                        if !viewModel.summary.categoryBreakdown.isEmpty {
                            Section("By Category") {
                                ForEach(viewModel.summary.categoryBreakdown) { breakdown in
                                    statRow(title: breakdown.displayName, value: percentString(breakdown.accuracy))
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Progress")
            .onAppear {
                viewModel.load(context: modelContext)
            }
            .refreshable {
                viewModel.load(context: modelContext)
            }
        }
    }

    private var streakText: String {
        let days = viewModel.summary.currentStreakDays
        return "\(days) day\(days == 1 ? "" : "s")"
    }

    private func statRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(CPTypography.body)
            Spacer()
            Text(value)
                .font(CPTypography.body.bold())
                .foregroundStyle(.secondary)
        }
    }

    private func percentString(_ value: Double) -> String {
        "\(Int((value * 100).rounded()))%"
    }
}

#Preview {
    ProgressDashboardView()
        .modelContainer(PersistenceController.previewModelContainer)
}
