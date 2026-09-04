import Foundation

struct Decision: Identifiable, Hashable {
  var id: UUID = UUID()
  var clientID: Client.ID
  var projectID: ClientProject.ID?
  var text: String
  var createdAt: Date = .now
}
