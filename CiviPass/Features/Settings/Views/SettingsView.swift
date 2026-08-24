import SwiftUI

struct SettingsView: View {
    @State private var viewModel = SettingsViewModel()

    var body: some View {
        NavigationStack {
            PlaceholderContent(title: "Settings")
                .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
