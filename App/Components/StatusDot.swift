import SwiftUI

struct StatusDot: View {
  var tint: SemanticTint

  var body: some View {
    Circle()
      .fill(tint.color)
      .frame(width: 7, height: 7)
  }
}
