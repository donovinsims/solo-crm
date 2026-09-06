import Foundation
import SwiftData

@Model
final class Client {
    var id: UUID
    var name: String
    var city: String
    var state: String
    var phone: String
    var email: String
    var lastAccessed: Date
    
    @Relationship(deleteRule: .cascade, inverse: \ContactPerson.client)
    var contacts: [ContactPerson] = []
    
    @Relationship(deleteRule: .cascade, inverse: \ClientProject.client)
    var projects: [ClientProject] = []
    
    @Relationship(deleteRule: .cascade, inverse: \TaskItem.client)
    var tasks: [TaskItem] = []
    
    @Relationship(deleteRule: .cascade, inverse: \Finding.client)
    var findings: [Finding] = []
    
    @Relationship(deleteRule: .cascade, inverse: \Decision.client)
    var decisions: [Decision] = []
    
    @Relationship(deleteRule: .cascade, inverse: \PaymentRecord.client)
    var payments: [PaymentRecord] = []
    
    @Relationship(deleteRule: .cascade, inverse: \ActivityEvent.client)
    var activity: [ActivityEvent] = []
    
    @Relationship(deleteRule: .cascade, inverse: \Note.client)
    var notes: [Note] = []
    
    init(name: String, city: String, state: String, phone: String, email: String) {
        self.id = UUID()
        self.name = name
        self.city = city
        self.state = state
        self.phone = phone
        self.email = email
        self.lastAccessed = Date()
    }
}

@Model
final class ContactPerson {
    var id: UUID
    var name: String
    var role: String
    var phone: String
    var email: String
    
    @Relationship(inverse: \Client.contacts)
    var client: Client?
    
    init(client: Client, name: String, role: String, phone: String, email: String) {
        self.id = UUID()
        self.name = name
        self.role = role
        self.phone = phone
        self.email = email
        self.client = client
    }
}