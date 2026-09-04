import SwiftUI

struct ClientRow: View {
  var client: Client
  @Environment(AppStore.self) private var store

  var body: some View {
    HStack(alignment: .top, spacing: 12) {
      Circle()
        .fill(Color.accentColor.opacity(0.15))
        .frame(width: 40, height: 40)
        .overlay {
          Text(initials)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.tint)
        }

      VStack(alignment: .leading, spacing: 3) {
        Text(client.name)
          .font(.body.weight(.medium))
          .foregroundStyle(.primary)
        Text("\(client.city), \(client.state)")
          .font(.subheadline)
          .foregroundStyle(.secondary)
        Text(store.clientStatusLine(client))
          .font(.subheadline)
          .foregroundStyle(.secondary)
      }

      Spacer()
    }
    .padding(.vertical, 4)
  }

  private var initials: String {
    let parts = client.name.split(separator: " ")
    let letters = parts.prefix(2).compactMap { $0.first }
    return String(letters).uppercased()
  }
}
