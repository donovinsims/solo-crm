import Foundation
import AppIntents

/// Lightweight shared dependency wrapper for App Intents.
/// Uses the same in-memory AppStore logic; WS-3/5 will make this durable.
@available(iOS 16, *)
final class IntentAppStore {
    static let shared = IntentAppStore()
    
    private let store = AppStore()
    
    private init() {}
    
    // MARK: - Entity Queries
    
    func allClients() -> [Client] {
        store.clients
    }
    
    func client(id: UUID) -> Client? {
        store.client(id)
    }
    
    func recentClients(limit: Int = 10) -> [Client] {
        store.recentClients.prefix(limit).map { $0 }
    }
    
    // MARK: - Mutations
    
    func addTask(title: String, clientID: UUID?, projectID: UUID?, dueDate: Date?) {
        store.addTask(title: title, clientID: clientID, projectID: projectID, dueDate: dueDate)
    }
}