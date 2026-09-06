import SwiftUI

struct ClientsListView: View {
  @Environment(AppStore.self) private var store
  @Environment(QuickCaptureState.self) private var quickCapture
  @Binding var deepLinkClientID: UUID?
  @State private var searchText = ""
  @State private var actionsClient: Client?
  @State private var isLoading = false
  @State private var loadError: Error?
  @State private var navigationPath = NavigationPath()

  private var filteredClients: [Client] {
    guard !searchText.isEmpty else { return store.clients }
    return store.clients.filter { $0.name.localizedCaseInsensitiveContains(searchText) || $0.city.localizedCaseInsensitiveContains(searchText) }
  }

  var body: some View {
    NavigationStack(path: $navigationPath) {
      List {
        if searchText.isEmpty {
          Section {
            ScrollView(.horizontal, showsIndicators: false) {
              HStack(spacing: 10) {
                ForEach(store.recentClients.prefix(5)) { client in
                  NavigationLink(value: client) {
                    Text(client.name)
                      .font(.subheadline.weight(.medium))
                      .padding(.horizontal, 14)
                      .padding(.vertical, 9)
                      .background(Color(.secondarySystemGroupedBackground), in: .capsule)
                      .foregroundStyle(.primary)
                  }
                  .buttonStyle(.plain)
                }
              }
            }
            .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
          } header: {
            Text("Recent")
          }
        }

        Section {
          if isLoading {
            ForEach(0..<5, id: \.self) { _ in
              SkeletonRow()
            }
          } else if filteredClients.isEmpty {
            EmptyStateView(
              systemImage: "person.crop.circle.badge.plus",
              title: "No Clients Found",
              message: searchText.isEmpty ? "No clients yet — tap + to add your first" : "No clients match \"\(searchText)\"",
              actionTitle: searchText.isEmpty ? "Add Client" : nil,
              action: searchText.isEmpty ? { quickCapture.present(stage: .contact) } : nil
            )
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 24, leading: 0, bottom: 24, trailing: 0))
          } else {
            ForEach(filteredClients) { client in
              NavigationLink(value: client) {
                ClientRow(client: client)
              }
              .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                Button {
                  quickCapture.present(clientID: client.id, stage: .task)
                } label: {
                  Label("Task", systemImage: "checklist")
                }
                .tint(.accentColor)
                .accessibilityLabel("Add task for \(client.name)")

                Button {
                  callClient(client)
                } label: {
                  Label("Call", systemImage: "phone.fill")
                }
                .tint(.green)
                .accessibilityLabel("Call \(client.name)")
              }
              .contextMenu {
                Button("Call", systemImage: "phone") { callClient(client) }
                  .accessibilityLabel("Call \(client.name)")
                Button("Message", systemImage: "message") { messageClient(client) }
                  .accessibilityLabel("Message \(client.name)")
                Button("Add Task", systemImage: "checklist") { quickCapture.present(clientID: client.id, stage: .task) }
                  .accessibilityLabel("Add task for \(client.name)")
                Button("Add Finding", systemImage: "eye") { quickCapture.present(clientID: client.id, stage: .finding) }
                  .accessibilityLabel("Add finding for \(client.name)")
                Divider()
                Button("More Actions", systemImage: "ellipsis.circle") { actionsClient = client }
                  .accessibilityLabel("More actions for \(client.name)")
              }
            }
          }
        } header: {
          Text("Active Clients")
        }
      }
      .listStyle(.insetGrouped)
      .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search clients")
      .navigationTitle("Clients")
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button {
            quickCapture.present(stage: .contact)
          } label: {
            Image(systemName: "plus")
          }
          .accessibilityLabel("Add client")
        }
      }
      .navigationDestination(for: Client.self) { client in
        ClientDetailView(client: client)
      }
      .sheet(item: $actionsClient) { client in
        ClientActionsSheet(client: client)
      }
      .task {
        // Prepare for async loading in WS-3/WS-5
        isLoading = true
        try? await Task.sleep(for: .milliseconds(300))
        isLoading = false
      }
      .onChange(of: deepLinkClientID) { _, newID in
        guard let clientID = newID,
              let client = store.client(clientID) else { return }
        navigationPath.append(client)
        deepLinkClientID = nil
      }
    }
  }

  private func callClient(_ client: Client) {
    guard let url = URL(string: "tel://\(client.phone.filter(\.isNumber))") else { return }
    UIApplication.shared.open(url)
  }

  private func messageClient(_ client: Client) {
    guard let url = URL(string: "sms://\(client.phone.filter(\.isNumber))") else { return }
    UIApplication.shared.open(url)
  }
}
