import Foundation
import AppIntents

@available(iOS 16, *)
enum DueOption: String, AppEnum {
    case today = "Today"
    case tomorrow = "Tomorrow"
    case thisWeek = "This Week"
    case nextWeek = "Next Week"
    case custom = "Custom"
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Due"
    static var caseDisplayRepresentations: [DueOption: DisplayRepresentation] = [
        .today: "Today",
        .tomorrow: "Tomorrow",
        .thisWeek: "This Week",
        .nextWeek: "Next Week",
        .custom: "Custom Date"
    ]
}

@available(iOS 16, *)
struct ClientOptionsProvider: DynamicOptionsProvider {
    func results() async throws -> [ClientEntity] {
        try await ClientEntityQuery().suggestedEntities()
    }
}

@available(iOS 16, *)
struct AddTaskIntent: AppIntent {
    static var title: LocalizedStringResource = "Add Task"
    static var description = IntentDescription("Add a task for a client")
    static var openAppWhenRun = false
    
    @Parameter(title: "Client", optionsProvider: ClientOptionsProvider())
    var client: ClientEntity?
    
    @Parameter(title: "Task Title", requestValueDialog: "What needs to happen?")
    var title: String
    
    @Parameter(title: "Due", default: .today)
    var dueDate: DueOption?
    
    func perform() async throws -> some IntentResult {
        let due: Date?
        switch dueDate {
        case .today:
            due = Date()
        case .tomorrow:
            due = Calendar.current.date(byAdding: .day, value: 1, to: Date())
        case .thisWeek:
            due = Calendar.current.date(byAdding: .day, value: 7, to: Date())
        case .nextWeek:
            due = Calendar.current.date(byAdding: .day, value: 14, to: Date())
        case .custom, .none:
            due = nil
        }
        
        IntentAppStore.shared.addTask(
            title: title,
            clientID: client?.id,
            projectID: nil,
            dueDate: due
        )
        
        let clientName = client?.name ?? "no client"
        return .result(dialog: "Added \"\(title)\" for \(clientName)")
    }
}