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
  @Environment(QuickCaptureState.self) private var quickCapture
  @State private var filter: FilterTab = .all
  @State private var isLoading = false

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
              .accessibilityLabel("Filter by \(tab.rawValue)")
              .accessibilityAddTraits(filter == tab ? [.isSelected] : [])
            }
          }
        }
        .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
      }
      .listRowBackground(Color.clear)
      .listRowSeparator(.hidden)

      if isLoading {
        Section {
          ForEach(0..<5, id: \.self) { _ in
            SkeletonRow(showAvatar: false)
          }
        }
      } else if items.isEmpty {
        Section {
          EmptyStateView(
            systemImage: "eye",
            title: clientFilter != nil ? "No Findings for \(clientFilter!.name)" : "No Findings Captured",
            message: clientFilter != nil
              ? "Add a finding from the client detail view to start tracking opportunities."
              : "No findings captured — tap + from a client to log one",
            actionTitle: clientFilter != nil ? "Add Finding" : nil,
            action: clientFilter != nil ? { quickCapture.present(clientID: clientFilter!.id, stage: .finding) } : nil
          )
          .listRowBackground(Color.clear)
          .listRowSeparator(.hidden)
          .listRowInsets(EdgeInsets(top: 24, leading: 0, bottom: 24, trailing: 0))
        }
      } else {
        Section {
          ForEach(items) { finding in
            FindingRow(finding: finding)
          }
        }
      }
    }
    .listStyle(.insetGrouped)
    .navigationTitle(clientFilter?.name ?? "Findings")
    .navigationBarTitleDisplayMode(clientFilter == nil ? .automatic : .inline)
    .toolbar {
      if clientFilter != nil {
        ToolbarItem(placement: .topBarTrailing) {
          Button {
            quickCapture.present(clientID: clientFilter!.id, stage: .finding)
          } label: {
            Image(systemName: "plus")
          }
          .accessibilityLabel("Add finding for \(clientFilter!.name)")
        }
      }
    }
    .task {
      isLoading = true
      try? await Task.sleep(for: .milliseconds(300))
      isLoading = false
    }
  }
}
