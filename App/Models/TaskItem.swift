import Foundation
import SwiftData

@Model
final class TaskItem {
    var id: UUID
    var title: String
    var dueDate: Date?
    var isWaitingOnClient: Bool
    var isCompleted: Bool
    var createdAt: Date
    
    @Relationship(inverse: \Client.tasks)
    var client: Client?
    
    @Relationship(inverse: \ClientProject.tasks)
    var project: ClientProject?
    
    init(title: String, client: Client?, project: ClientProject?, dueDate: Date?, isWaitingOnClient: Bool = false, isCompleted: Bool = false) {
        self.id = UUID()
        self.title = title
        self.dueDate = dueDate
        self.isWaitingOnClient = isWaitingOnClient
        self.isCompleted = isCompleted
        self.createdAt = Date()
        self.client = client
        self.project = project
    }
}