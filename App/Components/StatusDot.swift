import SwiftUI

struct StatusDot: View {
  var tint: SemanticTint
  var label: String?

  init(tint: SemanticTint, label: String? = nil) {
    self.tint = tint
    self.label = label
  }

  var body: some View {
    Circle()
      .fill(tint.designTokenColor)
      .frame(width: 7, height: 7)
      .accessibilityLabel(label ?? "Status indicator")
      .accessibilityHidden(label == nil)
  }
}

extension SemanticTint {
  var designTokenColor: Color {
    switch self {
    case .accent: DesignTokens.accent
    case .green: DesignTokens.success
    case .amber: DesignTokens.warning
    case .red: DesignTokens.error
    case .gray: DesignTokens.textTertiary
    }
  }
}
