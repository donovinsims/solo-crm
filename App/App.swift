import SwiftUI
import AppIntents

@main
struct AppDefinition: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// Ensures AppShortcutsProvider is discovered automatically (iOS 17+)
@available(iOS 17, *)
extension AppDefinition {
    static var appShortcutsProvider: RelayShortcuts.Type { RelayShortcuts.self }
}