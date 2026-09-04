import SwiftUI

struct MoreView: View {
  @Binding var searchPresented: Bool
  @Environment(AppStore.self) private var store

  var body: some View {
    NavigationStack {
      List {
        Section {
          Button {
            searchPresented = true
          } label: {
            Label("Search", systemImage: "magnifyingglass")
          }
        }

        Section("Operations") {
          NavigationLink {
            FindingsView(clientFilter: nil)
          } label: {
            Label("Findings", systemImage: "eye")
          }
          NavigationLink {
            MoneyView()
          } label: {
            Label("Money", systemImage: "dollarsign.circle")
          }
          NavigationLink {
            RecentActivityView()
          } label: {
            Label("Recent Activity", systemImage: "clock.arrow.circlepath")
          }
        }

        Section("Tools") {
          Label("Workflows", systemImage: "bolt.fill")
          Label("All Objects", systemImage: "square.stack.3d.up")
        }

        Section {
          Label("Settings", systemImage: "gearshape")
        }
      }
      .navigationTitle("More")
    }
  }
}

private struct RecentActivityView: View {
  @Environment(AppStore.self) private var store

  var body: some View {
    List {
      ForEach(store.activity.sorted { $0.date > $1.date }) { event in
        VStack(alignment: .leading, spacing: 3) {
          if let client = store.client(event.clientID) {
            Text(client.name)
              .font(.subheadline.weight(.semibold))
              .foregroundStyle(.secondary)
          }
          Text(event.text)
            .font(.body)
          Text(DueDateFormatting.activityDayLabel(for: event.date))
            .font(.caption)
            .foregroundStyle(.secondary)
        }
      }
    }
    .navigationTitle("Recent Activity")
  }
}
