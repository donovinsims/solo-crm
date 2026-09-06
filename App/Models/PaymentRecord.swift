import Foundation
import SwiftData

enum PaymentMethod: String, CaseIterable, Identifiable, Codable {
    case check = "Check"
    case ach = "ACH"
    case card = "Card"
    case cash = "Cash"
    case other = "Other"

    var id: String { rawValue }
}

@Model
final class PaymentRecord {
    var id: UUID
    var amount: Double
    var method: PaymentMethod
    var date: Date
    
    @Relationship(inverse: \Client.payments)
    var client: Client?
    
    @Relationship(inverse: \ClientProject.payments)
    var project: ClientProject?
    
    init(client: Client, project: ClientProject, amount: Double, method: PaymentMethod, date: Date = Date()) {
        self.id = UUID()
        self.amount = amount
        self.method = method
        self.date = date
        self.client = client
        self.project = project
    }
}