import SwiftUI

/// A single stat figure (e.g. "12 Quizzes Taken") shown as a card rather than a plain text row.
struct StatCard: View {
    let title: String
    let value: String
    let systemImage: String
    var tint: Color = CPColor.brandPrimary

    var body: some View {
        VStack(alignment: .leading, spacing: CPSpacing.sm) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundStyle(tint)

            Text(value)
                .font(CPTypography.statNumber)
                .foregroundStyle(.primary)
                .minimumScaleFactor(0.7)
                .lineLimit(1)

            Text(title)
                .font(CPTypography.caption)
                .foregroundStyle(.secondary)
        }
        .padding(CPSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(CPColor.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

#Preview {
    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: CPSpacing.md) {
        StatCard(title: "Quizzes Taken", value: "12", systemImage: "checkmark.circle.fill")
        StatCard(title: "Overall Accuracy", value: "84%", systemImage: "target", tint: CPColor.success)
        StatCard(title: "Current Streak", value: "5", systemImage: "flame.fill", tint: CPColor.brandAccent)
    }
    .padding()
}
