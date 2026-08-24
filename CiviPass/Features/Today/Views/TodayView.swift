import SwiftUI

struct TodayView: View {
    @State private var viewModel = TodayViewModel()

    var body: some View {
        NavigationStack {
            PlaceholderContent(title: "Today")
                .navigationTitle("Today")
        }
    }
}

#Preview {
    TodayView()
}
