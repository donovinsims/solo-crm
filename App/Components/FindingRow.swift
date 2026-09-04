import SwiftUI

struct FindingRow: View {
  var finding: Finding
  @Environment(AppStore.self) private var store

  var body: some View {
    HStack(alignment: .top, spacing: 12) {
      StatusDot(tint: finding.impact.tint)
        .padding(.top, 6)

      VStack(alignment: .leading, spacing: 4) {
        if let client = store.client(finding.clientID) {
          Text(client.name)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.secondary)
        }
        Text(finding.text)
          .font(.body)
          .foregroundStyle(.primary)
          .lineLimit(2)

        HStack(spacing: 6) {
          Text(finding.category.rawValue)
          Text("·")
          Text("\(finding.impact.rawValue) impact")
        }
        .font(.footnote)
        .foregroundStyle(.secondary)
      }

      Spacer()

      Text(finding.status.rawValue)
        .font(.caption.weight(.medium))
        .foregroundStyle(.secondary)
    }
    .padding(.vertical, 4)
  }
}
