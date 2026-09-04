import SwiftUI

struct TodayView: View {
  @Environment(AppStore.self) private var store
  @Environment(QuickCaptureState.self) private var quickCapture
  @State private var selectedClient: Client?
  @State private var selectedProject: ClientProject?

  private var dateString: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEEE, MMMM d"
    return formatter.string(from: .now)
  }

  private var focusItems: [FocusItem] {
    var items: [FocusItem] = []
    for task in store.openTasksToday where !task.isCompleted {
      guard let client = store.client(task.clientID) else { continue }
      items.append(FocusItem(client: client, project: store.project(task.projectID), headline: task.projectID.flatMap { store.project($0)?.name } ?? "Task", detail: task.title, trailing: "Due today", trailingTint: .accent))
    }
    for task in store.waitingTasks {
      guard let client = store.client(task.clientID) else { continue }
      items.append(FocusItem(client: client, project: store.project(task.projectID), headline: task.projectID.flatMap { store.project($0)?.name } ?? "Waiting", detail: task.title, trailing: DueDateFormatting.waitingLabel(since: task.createdAt), trailingTint: .amber))
    }
    for project in store.projectsWithBalances {
      guard let client = store.client(project.clientID) else { continue }
      items.append(FocusItem(client: client, project: project, headline: "Invoice", detail: "\(project.name)", trailing: "$\(Int(project.remaining)) outstanding", trailingTint: .red))
    }
    return items
  }

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 28) {
          header

          if !focusItems.isEmpty {
            focusSection
          }

          activeWorkSection
          waitingSection
          moneySection
          recentSection
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 24)
      }
      .background(Color(.systemGroupedBackground))
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text("Today").font(.headline)
        }
      }
      .navigationDestination(item: $selectedClient) { client in
        ClientDetailView(client: client)
      }
      .navigationDestination(item: $selectedProject) { project in
        ProjectDetailView(project: project)
      }
    }
  }

  private var header: some View {
    VStack(alignment: .leading, spacing: 6) {
      Text(dateString)
        .font(.subheadline)
        .foregroundStyle(.secondary)
      Text("Good morning, Donovin")
        .font(.largeTitle.weight(.bold))
      if !focusItems.isEmpty {
        Text("\(focusItems.count) things need you")
          .font(.title3)
          .foregroundStyle(.secondary)
      }
    }
  }

  private var focusSection: some View {
    VStack(alignment: .leading, spacing: 0) {
      ForEach(Array(focusItems.enumerated()), id: \.offset) { index, item in
        Button {
          if let project = item.project {
            selectedProject = project
          } else {
            selectedClient = item.client
          }
        } label: {
          VStack(alignment: .leading, spacing: 6) {
            Text(item.client.name.uppercased())
              .font(.caption.weight(.bold))
              .foregroundStyle(.secondary)
              .tracking(0.4)
            Text(item.detail)
              .font(.title3.weight(.semibold))
              .foregroundStyle(.primary)
            Text(item.trailing)
              .font(.subheadline.weight(.medium))
              .foregroundStyle(item.trailingTint.color)
          }
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.vertical, 14)
        }
        .buttonStyle(.plain)

        if index < focusItems.count - 1 {
          Divider()
        }
      }
    }
  }

  private var activeWorkSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      SectionLabel(title: "Active Work")
      VStack(alignment: .leading, spacing: 10) {
        ForEach(store.activeProjects) { project in
          Button {
            selectedProject = project
          } label: {
            HStack {
              Text(store.client(project.clientID)?.name ?? "")
                .foregroundStyle(.primary)
              Text("— \(project.phase)")
                .foregroundStyle(.secondary)
              Spacer()
            }
            .font(.body)
          }
          .buttonStyle(.plain)
        }
        if store.activeProjects.isEmpty {
          Text("Nothing active right now")
            .font(.body)
            .foregroundStyle(.secondary)
        }
      }
    }
  }

  private var waitingSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      SectionLabel(title: "Waiting")
      VStack(alignment: .leading, spacing: 6) {
        Text("\(store.waitingTasks.count) waiting on clients")
          .font(.body)
          .foregroundStyle(.primary)
        if !store.blockedProjects.isEmpty {
          Text("\(store.blockedProjects.count) blocked")
            .font(.body)
            .foregroundStyle(.primary)
        }
      }
    }
  }

  private var moneySection: some View {
    VStack(alignment: .leading, spacing: 12) {
      SectionLabel(title: "Money")
      Text("$\(Int(store.outstandingBalance)) outstanding")
        .font(.body)
        .foregroundStyle(.primary)
    }
  }

  private var recentSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      SectionLabel(title: "Recent")
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 10) {
          ForEach(store.recentClients) { client in
            Button {
              selectedClient = client
            } label: {
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
    }
  }
}

private struct FocusItem {
  var client: Client
  var project: ClientProject?
  var headline: String
  var detail: String
  var trailing: String
  var trailingTint: SemanticTint
}
