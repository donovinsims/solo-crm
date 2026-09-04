import SwiftUI
import UIKit

struct ClientsListView: View {
  @Environment(AppStore.self) private var store
  @Environment(QuickCaptureState.self) private var quickCapture
  @State private var searchText = ""
  @State private var actionsClient: Client?

  private var filteredClients: [Client] {
    guard !searchText.isEmpty else { return store.clients }
    return store.clients.filter { $0.name.localizedCaseInsensitiveContains(searchText) || $0.city.localizedCaseInsensitiveContains(searchText) }
  }

  var body: some View {
    NavigationStack {
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

              Button {
                callClient(client)
              } label: {
                Label("Call", systemImage: "phone.fill")
              }
              .tint(.green)
            }
            .contextMenu {
              Button("Call", systemImage: "phone") { callClient(client) }
              Button("Message", systemImage: "message") { }
              Button("Add Task", systemImage: "checklist") { quickCapture.present(clientID: client.id, stage: .task) }
              Button("Add Finding", systemImage: "eye") { quickCapture.present(clientID: client.id, stage: .finding) }
              Divider()
              Button("More Actions", systemImage: "ellipsis.circle") { actionsClient = client }
            }
          }
        } header: {
          Text("Active Clients")
        }
      }
      .listStyle(.insetGrouped)
      .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search clients")
      .navigationTitle("Clients")
      .navigationDestination(for: Client.self) { client in
        ClientDetailView(client: client)
      }
      .sheet(item: $actionsClient) { client in
        ClientActionsSheet(client: client)
      }
    }
  }

  private func callClient(_ client: Client) {
    guard let url = URL(string: "tel://\(client.phone.filter(\.isNumber))") else { return }
    UIApplication.shared.open(url)
  }
}
