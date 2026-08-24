import SwiftUI

/// Shared placeholder shown by feature screens that haven't been implemented yet.
struct PlaceholderContent: View {
    let title: String
    var message: String = "Coming soon."

    var body: some View {
        VStack(spacing: CPSpacing.sm) {
            Text(title)
                .font(CPTypography.title)
            Text(message)
                .font(CPTypography.body)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    PlaceholderContent(title: "Study")
}
