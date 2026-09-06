import Foundation
import SwiftData

@Model
final class ActivityEvent {
    var id: UUID
    var text: String
    var date: Date
    
    @Relationship(inverse: \Client.activity)
    var client: Client?
    
    @Relationship(inverse: \ClientProject.activity)
    var project: ClientProject?
    
    init(client: Client, project: ClientProject?, text: String, date: Date = Date()) {
        self.id = UUID()
        self.text = text
        self.date = date
        self.client = client
        self.project = project
    }
}

@Model
final class Note {
    var id: UUID
    var text: String
    var createdAt: Date
    
    @Relationship(inverse: \Client.notes)
    var client: Client?
    
    init(client: Client?, text: String) {
        self.id = UUID()
        self.text = text
        self.createdAt = Date()
        self.client = client
    }
}