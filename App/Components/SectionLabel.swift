import SwiftUI

struct SectionLabel: View {
  var title: String

  var body: some View {
    Text(title.uppercased())
      .font(.footnote.weight(.semibold))
      .foregroundStyle(.secondary)
      .tracking(0.3)
  }
}
