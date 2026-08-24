import SwiftUI
import SwiftData

@main
struct CiviPassApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(PersistenceController.sharedModelContainer)
    }
}
