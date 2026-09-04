import Foundation

enum FindingCategory: String, CaseIterable, Identifiable {
  case website = "Website"
  case leadHandling = "Lead Handling"
  case customerExperience = "Customer Experience"
  case operations = "Operations"
  case ordering = "Ordering"
  case scheduling = "Scheduling"
  case payments = "Payments"
  case automation = "Automation"
  case other = "Other"

  var id: String { rawValue }
}

enum FindingImpact: String, CaseIterable, Identifiable {
  case low = "Low"
  case medium = "Medium"
  case high = "High"

  var id: String { rawValue }

  var tint: SemanticTint {
    switch self {
    case .low: .gray
    case .medium: .amber
    case .high: .red
    }
  }
}

enum FindingStatus: String, CaseIterable, Identifiable {
  case new = "New"
  case investigating = "Investigating"
  case discussed = "Discussed"
  case approved = "Approved"
  case solved = "Solved"

  var id: String { rawValue }
}

struct Finding: Identifiable, Hashable {
  var id: UUID = UUID()
  var clientID: Client.ID
  var projectID: ClientProject.ID?
  var text: String
  var category: FindingCategory
  var impact: FindingImpact
  var status: FindingStatus = .new
  var createdAt: Date = .now
}
