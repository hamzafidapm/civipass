import SwiftUI

struct PracticeView: View {
    @State private var viewModel = PracticeViewModel()

    var body: some View {
        NavigationStack {
            PlaceholderContent(title: "Practice")
                .navigationTitle("Practice")
        }
    }
}

#Preview {
    PracticeView()
}
