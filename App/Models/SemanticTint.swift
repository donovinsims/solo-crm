import SwiftUI

enum SemanticTint {
  case accent
  case green
  case amber
  case red
  case gray

  var color: Color {
    switch self {
    case .accent: .accentColor
    case .green: .green
    case .amber: .orange
    case .red: .red
    case .gray: .secondary
    }
  }
}
