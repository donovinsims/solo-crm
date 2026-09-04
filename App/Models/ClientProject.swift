import Foundation

enum ProjectStatus: String, CaseIterable, Identifiable {
  case inProgress = "In Progress"
  case waitingOnClient = "Waiting on Client"
  case blocked = "Blocked"
  case completed = "Completed"

  var id: String { rawValue }

  var tint: SemanticTint {
    switch self {
    case .inProgress: .accent
    case .waitingOnClient: .amber
    case .blocked: .red
    case .completed: .green
    }
  }
}

struct ProjectLink: Identifiable, Hashable {
  var id: UUID = UUID()
  var title: String
  var systemImage: String
  var urlString: String
}

struct ClientProject: Identifiable, Hashable {
  var id: UUID = UUID()
  var clientID: Client.ID
  var name: String
  var phase: String
  var status: ProjectStatus
  var nextAction: String?
  var projectValue: Double
  var paidAmount: Double
  var links: [ProjectLink] = []

  var remaining: Double { max(projectValue - paidAmount, 0) }
}
