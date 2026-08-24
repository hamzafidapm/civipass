import SwiftUI

struct StudyView: View {
    @State private var viewModel = StudyViewModel()

    var body: some View {
        NavigationStack {
            PlaceholderContent(title: "Study")
                .navigationTitle("Study")
        }
    }
}

#Preview {
    StudyView()
}
