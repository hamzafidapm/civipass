import SwiftUI

struct MockTestView: View {
    @State private var viewModel = MockTestViewModel()

    var body: some View {
        NavigationStack {
            PlaceholderContent(title: "Mock Test")
                .navigationTitle("Mock Test")
        }
    }
}

#Preview {
    MockTestView()
}
