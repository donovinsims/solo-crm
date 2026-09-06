import Foundation
import AppIntents

/// Shared dependency wrapper for App Intents — same durable AppStore as the UI.
@available(iOS 16, *)
@MainActor
final class IntentAppStore {
    static let shared = IntentAppStore()

    var store: AppStore { AppStore.shared }

    private init() {}

    // MARK: - Entity Queries

    func allClients() -> [Client] {
        store.clients
    }

    func client(id: UUID) -> Client? {
        store.client(id)
    }

    func recentClients(limit: Int = 10) -> [Client] {
        Array(store.recentClients.prefix(limit))
    }

    // MARK: - Mutations

    func addTask(title: String, clientID: UUID?, projectID: UUID?, dueDate: Date?) {
        store.addTask(title: title, clientID: clientID, projectID: projectID, dueDate: dueDate)
    }
}
