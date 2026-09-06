import SwiftUI

struct ClientRow: View {
  var client: Client
  @Environment(AppStore.self) private var store

  var body: some View {
    HStack(alignment: .top, spacing: DesignTokens.spaceS) {
      Circle()
        .fill(DesignTokens.accent.opacity(0.15))
        .frame(width: 40, height: 40)
        .overlay {
          Text(initials)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(DesignTokens.accent)
        }
        .accessibilityHidden(true)

      VStack(alignment: .leading, spacing: DesignTokens.spaceXS) {
        Text(client.name)
          .font(.body.weight(.medium))
          .foregroundStyle(DesignTokens.textPrimary)
        Text("\(client.city), \(client.state)")
          .font(.subheadline)
          .foregroundStyle(DesignTokens.textSecondary)
        Text(store.clientStatusLine(client))
          .font(.subheadline)
          .foregroundStyle(DesignTokens.textSecondary)
      }

      Spacer()

      Image(systemName: "chevron.right")
        .font(.footnote.weight(.semibold))
        .foregroundStyle(DesignTokens.textTertiary)
        .accessibilityHidden(true)
    }
    .frame(minHeight: 60)
    .padding(.vertical, DesignTokens.spaceXS)
    .accessibilityElement(children: .combine)
    .accessibilityLabel("\(client.name), \(client.city), \(client.state). \(store.clientStatusLine(client))")
    .accessibilityHint("Opens client details")
    .accessibilityAction(named: "Call") { }
    .accessibilityAction(named: "Message") { }
    .accessibilityAction(named: "Add Task") { }
    .accessibilityAction(named: "Add Finding") { }
  }

  private var initials: String {
    let parts = client.name.split(separator: " ")
    let letters = parts.prefix(2).compactMap { $0.first }
    return String(letters).uppercased()
  }
}
