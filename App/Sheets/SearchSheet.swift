import SwiftUI
import UIKit

struct SearchSheet: View {
  @Environment(AppStore.self) private var store
  @Environment(\.dismiss) private var dismiss
  @State private var query = ""
  @State private var selectedClient: Client?
  @State private var selectedProject: ClientProject?
  @FocusState private var focused: Bool

  private var matchingClients: [Client] {
    guard !query.isEmpty else { return [] }
    return store.clients.filter { $0.name.localizedCaseInsensitiveContains(query) }
  }

  private var matchingProjects: [ClientProject] {
    guard !query.isEmpty else { return [] }
    return store.projects.filter { $0.name.localizedCaseInsensitiveContains(query) }
  }

  private var matchingTasks: [TaskItem] {
    guard !query.isEmpty else { return [] }
    return store.tasks.filter { $0.title.localizedCaseInsensitiveContains(query) }
  }

  private var matchingFindings: [Finding] {
    guard !query.isEmpty else { return [] }
    return store.findings.filter { $0.text.localizedCaseInsensitiveContains(query) }
  }

  var body: some View {
    NavigationStack {
      List {
        if query.isEmpty {
          Section {
            Text("Search or do anything")
              .foregroundStyle(.secondary)
          }
        } else {
          if !matchingClients.isEmpty {
            Section("Clients") {
              ForEach(matchingClients) { client in
                Button { selectedClient = client } label: {
                  Label(client.name, systemImage: "person.crop.circle")
                }
              }
            }
          }
          if !matchingProjects.isEmpty {
            Section("Projects") {
              ForEach(matchingProjects) { project in
                Button { selectedProject = project } label: {
                  Label(project.name, systemImage: "square.stack.3d.up")
                }
              }
            }
          }
          if !matchingTasks.isEmpty {
            Section("Tasks") {
              ForEach(matchingTasks) { task in
                Label(task.title, systemImage: "checklist")
              }
            }
          }
          if !matchingFindings.isEmpty {
            Section("Findings") {
              ForEach(matchingFindings) { finding in
                Label(finding.text, systemImage: "eye")
                  .lineLimit(1)
              }
            }
          }
          if let firstClient = matchingClients.first {
            Section("Actions") {
              Label("Add task for \(firstClient.name)", systemImage: "checklist")
              Label("Record payment", systemImage: "dollarsign.circle")
              Button {
                open("tel://\(firstClient.phone.filter(\.isNumber))")
              } label: {
                Label("Call \(firstClient.name)", systemImage: "phone")
              }
            }
          }
          if matchingClients.isEmpty && matchingProjects.isEmpty && matchingTasks.isEmpty && matchingFindings.isEmpty {
            Section {
              Text("No results for \"\(query)\"")
                .foregroundStyle(.secondary)
            }
          }
        }
      }
      .listStyle(.insetGrouped)
      .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search or do anything")
      .searchFocused($focused)
      .navigationTitle("Search")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button("Cancel") { dismiss() }
        }
      }
      .navigationDestination(item: $selectedClient) { client in
        ClientDetailView(client: client)
      }
      .navigationDestination(item: $selectedProject) { project in
        ProjectDetailView(project: project)
      }
      .onAppear { focused = true }
    }
    .presentationDetents([.large])
    .presentationDragIndicator(.visible)
  }

  private func open(_ string: String) {
    guard let url = URL(string: string) else { return }
    UIApplication.shared.open(url)
  }
}
