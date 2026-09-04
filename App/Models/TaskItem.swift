import Foundation

struct TaskItem: Identifiable, Hashable {
  var id: UUID = UUID()
  var title: String
  var clientID: Client.ID?
  var projectID: ClientProject.ID?
  var dueDate: Date?
  var isWaitingOnClient: Bool = false
  var isCompleted: Bool = false
  var createdAt: Date = .now
}
