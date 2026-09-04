import Foundation

struct Client: Identifiable, Hashable {
  var id: UUID = UUID()
  var name: String
  var city: String
  var state: String
  var phone: String
  var email: String
  var lastAccessed: Date = .now
}

struct ContactPerson: Identifiable, Hashable {
  var id: UUID = UUID()
  var clientID: Client.ID
  var name: String
  var role: String
  var phone: String
  var email: String
}
