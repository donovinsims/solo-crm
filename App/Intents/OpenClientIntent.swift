import Foundation
import AppIntents

@available(iOS 16, *)
struct OpenClientIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Client"
    static var openAppWhenRun = true
    
    @Parameter(title: "Client")
    var client: ClientEntity
    
    func perform() async throws -> some IntentResult {
        // The actual navigation is handled by the app via onOpenURL
        // This intent just needs to run to trigger the app launch
        return .result()
    }
}