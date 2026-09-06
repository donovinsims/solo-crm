import SwiftUI

struct SectionLabel: View {
  var title: String

  var body: some View {
    Text(title.uppercased())
      .font(.footnote.weight(.semibold))
      .foregroundStyle(DesignTokens.textSecondary)
      .tracking(0.3)
      .accessibilityAddTraits(.isHeader)
      .accessibilityHeading(.h3)
  }
}
