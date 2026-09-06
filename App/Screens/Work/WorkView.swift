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

        switch segment {
        case .projects: projectSections
        case .tasks: taskSections
        }
      }
      .listStyle(.insetGrouped)
      .navigationTitle("Projects")
      .navigationDestination(item: $selectedProject) { project in
        ProjectDetailView(project: project)
      }
    }
  }

  @ViewBuilder
  private var projectSections: some View {
    projectGroup(title: "Active", status: .inProgress)
    projectGroup(title: "Waiting", status: .waitingOnClient)
    projectGroup(title: "Blocked", status: .blocked)
    projectGroup(title: "Completed", status: .completed)
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

    taskGroup(title: "Today", items: today)
    taskGroup(title: "Upcoming", items: upcoming)
    taskGroup(title: "Waiting", items: waiting)
    taskGroup(title: "Completed", items: completed)
  }

  @ViewBuilder
  private func taskGroup(title: String, items: [TaskItem]) -> some View {
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
            }
            .swipeActions(edge: .leading) {
              Button {
                store.snoozeTask(task, to: Date.now.addingTimeInterval(86400))
              } label: {
                Label("Snooze", systemImage: "clock")
              }
              .tint(.orange)

              Button {
                store.markTaskWaiting(task)
              } label: {
                Label("Waiting", systemImage: "hourglass")
              }
              .tint(.gray)
            }
        }
      }
    }
  }
}

private struct ProjectRow: View {
  var project: ClientProject
  @Environment(AppStore.self) private var store

  var body: some View {
    HStack(alignment: .top, spacing: 12) {
      StatusDot(tint: project.status.tint)
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
    }
    .frame(minHeight: 44)
    .padding(.vertical, 4)
  }
}
