import SwiftUI
import SwiftData

// Named ProgressDashboardView (not ProgressView) to avoid colliding with SwiftUI.ProgressView.
struct ProgressDashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = ProgressViewModel()

    private let columns = [GridItem(.flexible(), spacing: CPSpacing.md), GridItem(.flexible(), spacing: CPSpacing.md)]

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
                        systemImage: "chart.bar.xaxis",
                        description: Text("Complete a mock quiz to start tracking your progress.")
                    )
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: CPSpacing.lg) {
                            LazyVGrid(columns: columns, spacing: CPSpacing.md) {
                                StatCard(
                                    title: "Quizzes Taken",
                                    value: "\(viewModel.summary.totalQuizzes)",
                                    systemImage: "checkmark.circle.fill",
                                    tint: CPColor.brandPrimary
                                )
                                StatCard(
                                    title: "Overall Accuracy",
                                    value: percentString(viewModel.summary.overallAccuracy),
                                    systemImage: "target",
                                    tint: CPColor.success
                                )
                                StatCard(
                                    title: "Current Streak",
                                    value: "\(viewModel.summary.currentStreakDays)",
                                    systemImage: "flame.fill",
                                    tint: CPColor.brandAccent
                                )
                            }

                            VStack(alignment: .leading, spacing: CPSpacing.sm) {
                                Text("By Category")
                                    .font(CPTypography.headline)

                                VStack(spacing: CPSpacing.sm) {
                                    ForEach(categoryRows) { row in
                                        CategoryRow(title: row.title, breakdown: row.breakdown)
                                    }
                                }
                            }
                        }
                        .padding(CPSpacing.md)
                    }
                    .background(CPColor.background)
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

    /// Always shows Mixed + every StudyCategory, even ones with no attempts yet,
    /// so the screen reads as "not started" rather than silently omitting them.
    private var categoryRows: [CategoryStatRow] {
        var rows = [
            CategoryStatRow(
                id: "mixed",
                title: "Mixed Quizzes",
                breakdown: viewModel.summary.categoryBreakdown.first { $0.category == nil }
            )
        ]
        rows += StudyCategory.allCases.map { category in
            CategoryStatRow(
                id: category.rawValue,
                title: category.rawValue,
                breakdown: viewModel.summary.categoryBreakdown.first { $0.category == category }
            )
        }
        return rows
    }

    private func percentString(_ value: Double) -> String {
        "\(Int((value * 100).rounded()))%"
    }
}

private struct CategoryStatRow: Identifiable {
    let id: String
    let title: String
    let breakdown: ProgressStats.CategoryBreakdown?
}

private struct CategoryRow: View {
    let title: String
    let breakdown: ProgressStats.CategoryBreakdown?

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(CPTypography.body)
                if let breakdown {
                    Text("\(breakdown.attemptCount) quiz\(breakdown.attemptCount == 1 ? "" : "zes")")
                        .font(CPTypography.footnote)
                        .foregroundStyle(.secondary)
                } else {
                    Text("No attempts yet")
                        .font(CPTypography.footnote)
                        .foregroundStyle(.tertiary)
                }
            }
            Spacer()
            if let breakdown {
                Text(percentString(breakdown.accuracy))
                    .font(CPTypography.body.bold())
                    .foregroundStyle(.secondary)
            } else {
                Image(systemName: "circle.dashed")
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(CPSpacing.md)
        .background(CPColor.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func percentString(_ value: Double) -> String {
        "\(Int((value * 100).rounded()))%"
    }
}

#Preview {
    ProgressDashboardView()
        .modelContainer(PersistenceController.previewModelContainer)
}
