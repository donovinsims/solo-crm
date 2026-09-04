import Foundation

enum PaymentMethod: String, CaseIterable, Identifiable {
  case check = "Check"
  case ach = "ACH"
  case card = "Card"
  case cash = "Cash"
  case other = "Other"

  var id: String { rawValue }
}

struct PaymentRecord: Identifiable, Hashable {
  var id: UUID = UUID()
  var clientID: Client.ID
  var projectID: ClientProject.ID
  var amount: Double
  var method: PaymentMethod
  var date: Date = .now
}
