import Foundation
import SwiftData

enum FindingCategory: String, CaseIterable, Identifiable, Codable {
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

enum FindingImpact: String, CaseIterable, Identifiable, Codable {
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

enum FindingStatus: String, CaseIterable, Identifiable, Codable {
    case new = "New"
    case investigating = "Investigating"
    case discussed = "Discussed"
    case approved = "Approved"
    case solved = "Solved"

    var id: String { rawValue }
}

@Model
final class Finding {
    var id: UUID
    var text: String
    var category: FindingCategory
    var impact: FindingImpact
    var status: FindingStatus
    var createdAt: Date
    
    @Relationship(inverse: \Client.findings)
    var client: Client?
    
    @Relationship(inverse: \ClientProject.findings)
    var project: ClientProject?
    
    init(client: Client, project: ClientProject?, text: String, category: FindingCategory, impact: FindingImpact, status: FindingStatus = .new) {
        self.id = UUID()
        self.text = text
        self.category = category
        self.impact = impact
        self.status = status
        self.createdAt = Date()
        self.client = client
        self.project = project
    }
}