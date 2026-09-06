import SwiftUI
import UIKit

struct SearchSheet: View {
  @Environment(AppStore.self) private var store
  @Environment(\.dismiss) private var dismiss
  @Environment(QuickCaptureState.self) private var quickCapture
  @State private var query = ""
  @State private var selectedClient: Client?
  @State private var selectedProject: ClientProject?
  @FocusState private var focused: Bool

  // Recent actions/clients for empty query
  private var recentClients: [Client] {
    store.clients.sorted { $0.lastAccessed > $1.lastAccessed }.prefix(5).map { $0 }
  }

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

  // Action items based on query and matched clients
  private var actionItems: [SearchAction] {
    var actions: [SearchAction] = []

    // If query matches a client name or is empty with recent clients
    let targetClients = matchingClients.isEmpty && query.isEmpty ? recentClients : matchingClients

    for client in targetClients.prefix(3) {
      actions.append(SearchAction(
        title: "Add task for \(client.name)",
        systemImage: "checklist",
        accessibilityHint: "Create a new task for \(client.name)",
        action: { quickCapture.present(clientID: client.id, stage: .task); dismiss() }
      ))
      actions.append(SearchAction(
        title: "Record payment for \(client.name)",
        systemImage: "dollarsign.circle",
        accessibilityHint: "Record a payment for \(client.name)",
        action: { quickCapture.present(clientID: client.id, stage: .payment); dismiss() }
      ))
      actions.append(SearchAction(
        title: "Call \(client.name)",
        systemImage: "phone",
        accessibilityHint: "Call \(client.name)",
        action: { open("tel://\(client.phone.filter(\.isNumber))"); dismiss() }
      ))
      actions.append(SearchAction(
        title: "Add finding for \(client.name)",
        systemImage: "eye",
        accessibilityHint: "Log a finding for \(client.name)",
        action: { quickCapture.present(clientID: client.id, stage: .finding); dismiss() }
      ))
      actions.append(SearchAction(
        title: "Log decision for \(client.name)",
        systemImage: "checkmark.seal",
        accessibilityHint: "Log a decision for \(client.name)",
        action: { quickCapture.present(clientID: client.id, stage: .decision); dismiss() }
      ))
    }

    // Open project actions
    for project in matchingProjects.prefix(3) {
      actions.append(SearchAction(
        title: "Open \(project.name)",
        systemImage: "square.stack.3d.up",
        accessibilityHint: "View project details",
        action: { selectedProject = project; dismiss() }
      ))
    }

    return actions
  }

  var body: some View {
    NavigationStack {
      List {
        // Actions section - always first when query has content or recent items exist
        if !actionItems.isEmpty {
          Section("Actions") {
            ForEach(actionItems) { action in
              Button(action: action.action) {
                Label(action.title, systemImage: action.systemImage)
              }
              .accessibilityLabel(action.title)
              .accessibilityHint(action.accessibilityHint)
              .contentShape(Rectangle())
            }
          }
        }

        // Empty state with recent clients when no query
        if query.isEmpty && matchingClients.isEmpty && matchingProjects.isEmpty && matchingTasks.isEmpty && matchingFindings.isEmpty {
          if !recentClients.isEmpty {
            Section("Recent Clients") {
              ForEach(recentClients) { client in
                Button { selectedClient = client } label: {
                  Label(client.name, systemImage: "person.crop.circle")
                }
                .accessibilityLabel("Open \(client.name)")
                .accessibilityHint("View client details")
              }
            }
          } else {
            Section {
              InlineEmptyState(systemImage: "magnifyingglass", message: "Search or do anything")
            }
          }
        }

        // Search results
        if !query.isEmpty {
          if !matchingClients.isEmpty {
            Section("Clients") {
              ForEach(matchingClients) { client in
                Button { selectedClient = client } label: {
                  Label(client.name, systemImage: "person.crop.circle")
                }
                .accessibilityLabel("Open \(client.name)")
                .accessibilityHint("View client details")
              }
            }
          }
          if !matchingProjects.isEmpty {
            Section("Projects") {
              ForEach(matchingProjects) { project in
                Button { selectedProject = project } label: {
                  Label(project.name, systemImage: "square.stack.3d.up")
                }
                .accessibilityLabel("Open \(project.name)")
                .accessibilityHint("View project details")
              }
            }
          }
          if !matchingTasks.isEmpty {
            Section("Tasks") {
              ForEach(matchingTasks) { task in
                Label(task.title, systemImage: "checklist")
                  .accessibilityLabel("Task: \(task.title)")
              }
            }
          }
          if !matchingFindings.isEmpty {
            Section("Findings") {
              ForEach(matchingFindings) { finding in
                Label(finding.text, systemImage: "eye")
                  .lineLimit(1)
                  .accessibilityLabel("Finding: \(finding.text)")
              }
            }
          }
          if matchingClients.isEmpty && matchingProjects.isEmpty && matchingTasks.isEmpty && matchingFindings.isEmpty {
            Section {
              InlineEmptyState(systemImage: "magnifyingglass", message: "No results for \"\(query)\"")
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

private struct SearchAction: Identifiable {
  let id = UUID()
  let title: String
  let systemImage: String
  let accessibilityHint: String
  let action: () -> Void
}
