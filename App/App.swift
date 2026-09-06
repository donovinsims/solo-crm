import SwiftUI
import AppIntents
import SwiftData

@main
struct AppDefinition: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(AppStore.shared)
                .modelContainer(Persistence.sharedContainer)
        }
    }
}

// Ensures AppShortcutsProvider is discovered automatically (iOS 17+)
@available(iOS 17, *)
extension AppDefinition {
    static var appShortcutsProvider: RelayShortcuts.Type { RelayShortcuts.self }
}
