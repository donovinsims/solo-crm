import Foundation
import AppIntents
import UIKit

@available(iOS 16, *)
struct OpenClientIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Client"
    static var openAppWhenRun = true

    @Parameter(title: "Client")
    var client: ClientEntity

    func perform() async throws -> some IntentResult {
        if let url = URL(string: "relay://open-client?id=\(client.id.uuidString)") {
            await MainActor.run {
                UIApplication.shared.open(url)
            }
        }
        return .result()
    }
}
