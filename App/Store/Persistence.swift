import Foundation
import SwiftData

enum Persistence {
  static let sharedContainer: ModelContainer = {
    let schema = Schema([
      Client.self,
      ContactPerson.self,
      ClientProject.self,
      ProjectLink.self,
      TaskItem.self,
      Finding.self,
      Decision.self,
      PaymentRecord.self,
      ActivityEvent.self,
      Note.self,
    ])
    let configuration = ModelConfiguration(
      "RelayStore",
      schema: schema,
      isStoredInMemoryOnly: false
    )
    do {
      return try ModelContainer(for: schema, configurations: [configuration])
    } catch {
      fatalError("Failed to create Relay ModelContainer: \(error)")
    }
  }()
}
