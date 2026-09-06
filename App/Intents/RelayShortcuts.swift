import Foundation
import AppIntents

@available(iOS 16, *)
struct RelayShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddTaskIntent(),
            phrases: [
                "Add task to \(.applicationName)",
                "Create task for \(.applicationName)",
                "Log task in \(.applicationName)"
            ],
            shortTitle: "Add Task",
            systemImageName: "checklist"
        )
        AppShortcut(
            intent: OpenClientIntent(),
            phrases: [
                "Open \(.applicationName) client",
                "Show client in \(.applicationName)"
            ],
            shortTitle: "Open Client",
            systemImageName: "person.crop.circle"
        )
    }
}