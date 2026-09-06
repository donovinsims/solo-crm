import Foundation
import SwiftUI

enum SemanticTint: String, CaseIterable, Identifiable, Codable {
    case accent
    case amber
    case red
    case green
    case gray

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .accent: .accentColor
        case .amber: .orange
        case .red: .red
        case .green: .green
        case .gray: .gray
        }
    }
}