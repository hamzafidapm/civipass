import SwiftUI

@main
struct CiviPassApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(PersistenceController.sharedModelContainer)
    }
}
