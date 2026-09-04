import SwiftUI

struct TaskRow: View {
  var task: TaskItem
  var onToggle: () -> Void
  @Environment(AppStore.self) private var store

  var body: some View {
    HStack(alignment: .top, spacing: 12) {
      Button(action: onToggle) {
        Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
          .font(.system(size: 21))
          .foregroundStyle(task.isCompleted ? Color.accentColor : Color.secondary.opacity(0.5))
      }
      .buttonStyle(.plain)
      .padding(.top, 1)

      VStack(alignment: .leading, spacing: 3) {
        Text(task.title)
          .font(.body)
          .foregroundStyle(task.isCompleted ? .secondary : .primary)
          .strikethrough(task.isCompleted)

        HStack(spacing: 6) {
          if let client = store.client(task.clientID) {
            Text(client.name)
          }
          if let projectID = task.projectID, let project = store.project(projectID) {
            Text("·")
            Text(project.name)
          }
        }
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .lineLimit(1)
      }

      Spacer()

      if task.isWaitingOnClient {
        Text(DueDateFormatting.waitingLabel(since: task.createdAt))
          .font(.subheadline)
          .foregroundStyle(.orange)
      } else if let label = DueDateFormatting.label(for: task.dueDate), !task.isCompleted {
        Text(label)
          .font(.subheadline)
          .foregroundStyle(label == "Overdue" ? .red : .secondary)
      }
    }
    .padding(.vertical, 4)
  }
}
