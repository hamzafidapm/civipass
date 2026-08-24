import SwiftUI
import SwiftData

@main
struct CiviPassApp: App {
    @State private var entitlementManager = EntitlementManager()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(entitlementManager)
        }
        .modelContainer(PersistenceController.sharedModelContainer)
    }
}
