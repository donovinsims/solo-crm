import SwiftUI

struct FindingRow: View {
  var finding: Finding
  @Environment(AppStore.self) private var store
  @State private var showPromoteSheet = false

  var body: some View {
    HStack(alignment: .top, spacing: DesignTokens.spaceS) {
      StatusDot(tint: finding.impact.tint)
        .padding(.top, DesignTokens.spaceS)
        .accessibilityLabel("\(finding.impact.rawValue) impact")
        .accessibilityHidden(false)

      VStack(alignment: .leading, spacing: DesignTokens.spaceXS) {
        if let client = finding.client {
          Text(client.name)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(DesignTokens.textSecondary)
        }
        Text(finding.text)
          .font(.body)
          .foregroundStyle(DesignTokens.textPrimary)
          .lineLimit(2)

        HStack(spacing: DesignTokens.spaceS) {
          Text(finding.category.rawValue)
          Text("·")
          Text("\(finding.impact.rawValue) impact")
        }
        .font(.footnote)
        .foregroundStyle(DesignTokens.textSecondary)
      }

      Spacer()

      Text(finding.status.rawValue)
        .font(.caption.weight(.medium))
        .foregroundStyle(DesignTokens.textSecondary)
    }
    .padding(.vertical, DesignTokens.spaceXS)
    .accessibilityElement(children: .combine)
    .accessibilityLabel("\(finding.text). \(finding.category.rawValue). \(finding.impact.rawValue) impact. Status: \(finding.status.rawValue)")
    .accessibilityHint("Finding detail")
    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
      Button {
        showPromoteSheet = true
      } label: {
        Label("Promote", systemImage: "arrow.up.right.square")
      }
      .tint(DesignTokens.accent)
      .accessibilityLabel("Promote finding to project")
    }
    .sheet(isPresented: $showPromoteSheet) {
      PromoteFindingSheet(finding: finding)
        .environment(store)
    }
  }
}
