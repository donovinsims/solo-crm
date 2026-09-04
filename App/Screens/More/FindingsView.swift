import SwiftUI

struct FindingsView: View {
  var clientFilter: Client?

  private enum FilterTab: String, CaseIterable, Identifiable {
    case all = "All"
    case new = "New"
    case investigating = "Investigating"
    case discussed = "Discussed"
    case approved = "Approved"
    case solved = "Solved"

    var id: String { rawValue }
  }

  @Environment(AppStore.self) private var store
  @State private var filter: FilterTab = .all

  private var items: [Finding] {
    var results = clientFilter.map { client in store.findings(for: client.id) } ?? store.findings
    if filter != .all {
      results = results.filter { $0.status.rawValue == filter.rawValue }
    }
    return results
  }

  var body: some View {
    List {
      Section {
        ScrollView(.horizontal, showsIndicators: false) {
          HStack(spacing: 8) {
            ForEach(FilterTab.allCases) { tab in
              Button {
                filter = tab
              } label: {
                Text(tab.rawValue)
                  .font(.subheadline.weight(.medium))
                  .padding(.horizontal, 14)
                  .padding(.vertical, 7)
                  .background(filter == tab ? Color.accentColor : Color(.secondarySystemGroupedBackground), in: .capsule)
                  .foregroundStyle(filter == tab ? .white : .primary)
              }
              .buttonStyle(.plain)
            }
          }
        }
        .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
      }
      .listRowBackground(Color.clear)
      .listRowSeparator(.hidden)

      Section {
        ForEach(items) { finding in
          FindingRow(finding: finding)
        }
      }
    }
    .listStyle(.insetGrouped)
    .navigationTitle(clientFilter?.name ?? "Findings")
    .navigationBarTitleDisplayMode(clientFilter == nil ? .automatic : .inline)
  }
}
