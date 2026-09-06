import SwiftUI

struct WorkView: View {
  private enum Segment: String, CaseIterable {
    case projects = "Projects"
    case tasks = "Tasks"
  }

  @Environment(AppStore.self) private var store
  @Environment(QuickCaptureState.self) private var quickCapture
  @State private var segment: Segment = .projects
  @State private var selectedProject: ClientProject?
  @State private var isLoading = false

  var body: some View {
    NavigationStack {
      List {
        Section {
          Picker("View", selection: $segment) {
            ForEach(Segment.allCases, id: \.self) { Text($0.rawValue).tag($0) }
          }
          .pickerStyle(.segmented)
          .listRowInsets(EdgeInsets())
          .padding(.vertical, 6)
        }
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)

        if isLoading {
          Section {
            ForEach(0..<5, id: \.self) { _ in
              SkeletonRow()
            }
          }
        } else {
          switch segment {
          case .projects: projectSections
          case .tasks: taskSections
          }
        }
      }
      .listStyle(.insetGrouped)
      .navigationTitle("Projects")
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button {
            quickCapture.present(stage: .task)
          } label: {
            Image(systemName: "plus")
          }
          .accessibilityLabel("Add new item")
        }
      }
      .navigationDestination(item: $selectedProject) { project in
        ProjectDetailView(project: project)
      }
      .task {
        isLoading = true
        try? await Task.sleep(for: .milliseconds(300))
        isLoading = false
      }
    }
  }

  @ViewBuilder
  private var projectSections: some View {
    projectGroup(title: "Active", status: .inProgress)
    projectGroup(title: "Waiting", status: .waitingOnClient)
    projectGroup(title: "Blocked", status: .blocked)
    projectGroup(title: "Completed", status: .completed)

    if store.projects.isEmpty {
      Section {
        EmptyStateView(
          systemImage: "square.stack.3d.up",
          title: "No Projects",
          message: "Add a project from a client detail view to get started.",
          actionTitle: nil,
          action: nil
        )
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 24, leading: 0, bottom: 24, trailing: 0))
      }
    }
  }

  @ViewBuilder
  private func projectGroup(title: String, status: ProjectStatus) -> some View {
    let items = store.projects.filter { $0.status == status }
    if !items.isEmpty {
      Section(title) {
        ForEach(items) { project in
          Button {
            selectedProject = project
          } label: {
            ProjectRow(project: project)
          }
          .buttonStyle(.plain)
        }
      }
    }
  }

  @ViewBuilder
  private var taskSections: some View {
    let openTasks = store.tasks.filter { !$0.isCompleted && !$0.isWaitingOnClient }
    let today = openTasks.filter { $0.dueDate.map { Calendar.current.isDateInToday($0) } ?? false }
    let upcoming = openTasks.filter { !($0.dueDate.map { Calendar.current.isDateInToday($0) } ?? false) }
    let waiting = store.tasks.filter { !$0.isCompleted && $0.isWaitingOnClient }
    let completed = store.tasks.filter(\.isCompleted)

    taskGroup(title: "Today", items: today, emptyMessage: "No tasks due today")
    taskGroup(title: "Upcoming", items: upcoming, emptyMessage: "No upcoming tasks")
    taskGroup(title: "Waiting", items: waiting, emptyMessage: "Nothing waiting on clients")
    taskGroup(title: "Completed", items: completed, emptyMessage: "No completed tasks yet")

    if store.tasks.isEmpty {
      Section {
        EmptyStateView(
          systemImage: "checklist",
          title: "No Tasks",
          message: "Tap + to add your first task.",
          actionTitle: "Add Task",
          action: { quickCapture.present(stage: .task) }
        )
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 24, leading: 0, bottom: 24, trailing: 0))
      }
    }
  }

  @ViewBuilder
  private func taskGroup(title: String, items: [TaskItem], emptyMessage: String) -> some View {
    if !items.isEmpty {
      Section(title) {
        ForEach(items) { task in
          TaskRow(task: task) { store.toggleTaskCompletion(task) }
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
              Button {
                store.toggleTaskCompletion(task)
              } label: {
                Label("Complete", systemImage: "checkmark")
              }
              .tint(.green)
              .accessibilityLabel("Mark task complete")
            }
            .swipeActions(edge: .leading) {
              Button {
                store.snoozeTask(task, to: Date.now.addingTimeInterval(86400))
              } label: {
                Label("Snooze", systemImage: "clock")
              }
              .tint(.orange)
              .accessibilityLabel("Snooze task")

              Button {
                store.markTaskWaiting(task)
              } label: {
                Label("Waiting", systemImage: "hourglass")
              }
              .tint(.gray)
              .accessibilityLabel("Mark task as waiting")
            }
        }
      }
    } else if segment == .tasks {
      // Show inline empty state for the first empty section only
      Section(title) {
        InlineEmptyState(systemImage: "checklist", message: emptyMessage)
          .listRowBackground(Color.clear)
          .listRowSeparator(.hidden)
      }
    }
  }
}

private struct ProjectRow: View {
  var project: ClientProject
  @Environment(AppStore.self) private var store

  var body: some View {
    HStack(alignment: .top, spacing: 12) {
      StatusDot(tint: project.status.tint, label: project.status.rawValue)
        .padding(.top, 6)

      VStack(alignment: .leading, spacing: 3) {
        Text(store.client(project.clientID)?.name ?? "")
          .font(.subheadline.weight(.semibold))
          .foregroundStyle(.secondary)
        Text(project.name)
          .font(.body.weight(.medium))
          .foregroundStyle(.primary)
        Text(project.phase)
          .font(.subheadline)
          .foregroundStyle(.secondary)
        if let next = project.nextAction {
          Text(next)
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
      }

      Spacer()

      Image(systemName: "chevron.right")
        .font(.footnote.weight(.semibold))
        .foregroundStyle(.tertiary)
        .accessibilityHidden(true)
    }
    .frame(minHeight: 44)
    .padding(.vertical, 4)
    .accessibilityElement(children: .combine)
    .accessibilityLabel("\(store.client(project.clientID)?.name ?? "Unknown client"). \(project.name). \(project.phase). Status: \(project.status.rawValue)\(project.nextAction != nil ? ". Next: \(project.nextAction!)" : "")")
  }
}
