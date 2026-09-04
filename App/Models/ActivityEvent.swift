import Foundation

struct ActivityEvent: Identifiable, Hashable {
  var id: UUID = UUID()
  var clientID: Client.ID
  var projectID: ClientProject.ID?
  var text: String
  var date: Date = .now
}

struct Note: Identifiable, Hashable {
  var id: UUID = UUID()
  var clientID: Client.ID?
  var text: String
  var createdAt: Date = .now
}
