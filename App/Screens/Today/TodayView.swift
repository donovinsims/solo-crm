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
      items.append(FocusItem(client: client, project: store.project(task.projectID), detail: task.title, trailing: "Due today", trailingTint: .accent, systemImage: "checklist"))
    }
    for task in store.waitingTasks {
      guard let client = store.client(task.clientID) else { continue }
      items.append(FocusItem(client: client, project: store.project(task.projectID), detail: task.title, trailing: DueDateFormatting.waitingLabel(since: task.createdAt), trailingTint: .amber, systemImage: "hourglass"))
    }
    for project in store.projectsWithBalances {
      guard let client = store.client(project.clientID) else { continue }
      items.append(FocusItem(client: client, project: project, detail: project.name, trailing: "$\(Int(project.remaining)) outstanding", trailingTint: .red, systemImage: "dollarsign.circle"))
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
      HStack {
        SectionLabel(title: "Needs You")
        Spacer()
        Text("\(focusItems.count)")
          .font(.footnote.weight(.semibold))
          .foregroundStyle(.secondary)
      }

      ForEach(Array(focusItems.enumerated()), id: \.offset) { index, item in
        Button {
          if let project = item.project {
            selectedProject = project
          } else {
            selectedClient = item.client
          }
        } label: {
          HStack(alignment: .top, spacing: 12) {
            Image(systemName: item.systemImage)
              .font(.body.weight(.semibold))
              .foregroundStyle(item.trailingTint.color)
              .frame(width: 28, height: 44, alignment: .top)

            VStack(alignment: .leading, spacing: 5) {
              Text(item.client.name)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .lineLimit(1)
              Text(item.detail)
                .font(.body.weight(.medium))
                .foregroundStyle(.primary)
                .lineLimit(2)
              Text(item.trailing)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(item.trailingTint.color)
            }

            Spacer(minLength: 8)

            Image(systemName: "chevron.right")
              .font(.footnote.weight(.semibold))
              .foregroundStyle(.secondary)
          }
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)

        if index < focusItems.count - 1 {
          Divider()
        }
      }
    }
  }

  private var activeWorkSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        SectionLabel(title: "Active Work")
        Spacer()
        Text("\(store.activeProjects.count)")
          .font(.footnote.weight(.semibold))
          .foregroundStyle(.secondary)
      }
      VStack(alignment: .leading, spacing: 10) {
        ForEach(store.activeProjects) { project in
          Button {
            selectedProject = project
          } label: {
            HStack(spacing: 10) {
              StatusDot(tint: project.status.tint)
              VStack(alignment: .leading, spacing: 2) {
                Text(store.client(project.clientID)?.name ?? "")
                  .font(.body.weight(.medium))
                  .foregroundStyle(.primary)
                Text("\(project.name) · \(project.phase)")
                  .font(.subheadline)
                  .foregroundStyle(.secondary)
                  .lineLimit(1)
              }
              Spacer()
              Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.tertiary)
            }
            .frame(minHeight: 44)
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
        Label("\(store.waitingTasks.count) waiting on clients", systemImage: "hourglass")
          .foregroundStyle(.primary)
        if !store.blockedProjects.isEmpty {
          Label("\(store.blockedProjects.count) blocked project\(store.blockedProjects.count == 1 ? "" : "s")", systemImage: "exclamationmark.triangle")
            .foregroundStyle(.primary)
        }
      }
      .font(.body)
    }
  }

  private var moneySection: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        SectionLabel(title: "Money")
        Spacer()
        NavigationLink {
          MoneyView()
        } label: {
          Image(systemName: "chevron.right")
            .font(.footnote.weight(.semibold))
            .foregroundStyle(.tertiary)
            .frame(width: 44, height: 44)
        }
        .accessibilityLabel("View money")
      }
      HStack {
        Label("Outstanding", systemImage: "dollarsign.circle")
        Spacer()
        Text("$\(Int(store.outstandingBalance))")
          .font(.body.weight(.semibold))
      }
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
              HStack(spacing: 8) {
                Text(initials(for: client))
                  .font(.caption.weight(.semibold))
                  .foregroundStyle(.tint)
                  .frame(width: 28, height: 28)
                  .background(Color.accentColor.opacity(0.14), in: Circle())
                Text(client.name)
                  .font(.subheadline.weight(.medium))
                  .foregroundStyle(.primary)
              }
              .padding(.horizontal, 10)
              .padding(.vertical, 7)
              .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 14))
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .combine)
          }
        }
      }
    }
  }

  private func initials(for client: Client) -> String {
    let letters = client.name.split(separator: " ").prefix(2).compactMap { $0.first }
    return String(letters).uppercased()
  }
}

private struct FocusItem {
  var client: Client
  var project: ClientProject?
  var detail: String
  var trailing: String
  var trailingTint: SemanticTint
  var systemImage: String
}
