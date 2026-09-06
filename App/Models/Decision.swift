import Foundation
import SwiftData

@Model
final class Decision {
    var id: UUID
    var text: String
    var createdAt: Date
    
    @Relationship(inverse: \Client.decisions)
    var client: Client?
    
    @Relationship(inverse: \ClientProject.decisions)
    var project: ClientProject?
    
    init(client: Client, project: ClientProject?, text: String) {
        self.id = UUID()
        self.text = text
        self.createdAt = Date()
        self.client = client
        self.project = project
    }
}