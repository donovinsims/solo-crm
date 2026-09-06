import Foundation
import AppIntents

@available(iOS 16, *)
struct ClientEntity: AppEntity {
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Client"
    static var defaultQuery = ClientEntityQuery()
    
    let id: UUID
    let name: String
    let city: String
    let state: String
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(name)",
            subtitle: "\(city), \(state)"
        )
    }
    
    static func == (lhs: ClientEntity, rhs: ClientEntity) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

@available(iOS 16, *)
struct ClientEntityQuery: EntityQuery {
    func entities(for identifiers: [UUID]) async throws -> [ClientEntity] {
        let store = IntentAppStore.shared
        return identifiers.compactMap { id in
            store.client(id: id).map { client in
                ClientEntity(
                    id: client.id,
                    name: client.name,
                    city: client.city,
                    state: client.state
                )
            }
        }
    }
    
    func suggestedEntities() async throws -> [ClientEntity] {
        let store = IntentAppStore.shared
        return store.recentClients(limit: 10).map { client in
            ClientEntity(
                id: client.id,
                name: client.name,
                city: client.city,
                state: client.state
            )
        }
    }
    
    func defaultResult() async -> ClientEntity? {
        try? await suggestedEntities().first
    }
}