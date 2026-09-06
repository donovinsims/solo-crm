import Foundation
import SwiftData

enum ProjectStatus: String, CaseIterable, Identifiable, Codable {
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

@Model
final class ProjectLink {
    var id: UUID
    var title: String
    var systemImage: String
    var urlString: String
    
    init(title: String, systemImage: String, urlString: String) {
        self.id = UUID()
        self.title = title
        self.systemImage = systemImage
        self.urlString = urlString
    }
}

@Model
final class ClientProject {
    var id: UUID
    var name: String
    var phase: String
    var status: ProjectStatus
    var nextAction: String?
    var projectValue: Double
    var paidAmount: Double
    
    @Relationship(inverse: \Client.projects)
    var client: Client?
    
    @Relationship(deleteRule: .cascade, inverse: \ProjectLink.project)
    var links: [ProjectLink] = []
    
    @Relationship(deleteRule: .cascade, inverse: \TaskItem.project)
    var tasks: [TaskItem] = []
    
    @Relationship(deleteRule: .cascade, inverse: \Finding.project)
    var findings: [Finding] = []
    
    @Relationship(deleteRule: .cascade, inverse: \Decision.project)
    var decisions: [Decision] = []
    
    @Relationship(deleteRule: .cascade, inverse: \PaymentRecord.project)
    var payments: [PaymentRecord] = []
    
    @Relationship(deleteRule: .cascade, inverse: \ActivityEvent.project)
    var activity: [ActivityEvent] = []
    
    var remaining: Double { max(projectValue - paidAmount, 0) }
    
    init(client: Client, name: String, phase: String, status: ProjectStatus, nextAction: String?, projectValue: Double, paidAmount: Double, links: [ProjectLink] = []) {
        self.id = UUID()
        self.name = name
        self.phase = phase
        self.status = status
        self.nextAction = nextAction
        self.projectValue = projectValue
        self.paidAmount = paidAmount
        self.client = client
        self.links = links
    }
}