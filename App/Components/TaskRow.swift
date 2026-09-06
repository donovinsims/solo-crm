import SwiftUI

struct TaskRow: View {
  var task: TaskItem
  var onToggle: () -> Void
  @Environment(AppStore.self) private var store

  var body: some View {
    HStack(alignment: .top, spacing: DesignTokens.spaceS) {
      Button(action: onToggle) {
        Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
          .font(.system(size: 21))
          .foregroundStyle(task.isCompleted ? DesignTokens.accent : DesignTokens.textSecondary.opacity(0.5))
      }
      .buttonStyle(.plain)
      .frame(width: 44, height: 44)
      .accessibilityLabel(task.isCompleted ? "Mark incomplete" : "Mark complete")
      .accessibilityHint("Toggles task completion")
      .accessibilityAddTraits(task.isCompleted ? [.isSelected] : [])

      VStack(alignment: .leading, spacing: DesignTokens.spaceXS) {
        Text(task.title)
          .font(.body)
          .foregroundStyle(task.isCompleted ? DesignTokens.textSecondary : DesignTokens.textPrimary)
          .strikethrough(task.isCompleted, color: DesignTokens.textSecondary)

        HStack(spacing: DesignTokens.spaceS) {
          if let client = task.client {
            Text(client.name)
          }
          if let project = task.project {
            Text("·")
            Text(project.name)
          }
        }
        .font(.subheadline)
        .foregroundStyle(DesignTokens.textSecondary)
        .lineLimit(1)
      }

      Spacer()

      if task.isWaitingOnClient {
        Text(DueDateFormatting.waitingLabel(since: task.createdAt))
          .font(.subheadline)
          .foregroundStyle(DesignTokens.warning)
          .accessibilityLabel("Waiting on client")
      } else if let label = DueDateFormatting.label(for: task.dueDate), !task.isCompleted {
        Text(label)
          .font(.subheadline)
          .foregroundStyle(label == "Overdue" ? DesignTokens.error : DesignTokens.textSecondary)
          .accessibilityLabel("Due: \(label)")
      }
    }
.frame(minHeight: 52)
    .padding(.vertical, DesignTokens.spaceXS)
    .accessibilityElement(children: .combine)
    .accessibilityLabel("\(task.title). \(task.isCompleted ? "Completed" : "Incomplete")\(task.isWaitingOnClient ? ". Waiting on client" : "")\(task.dueDate != nil ? ". Due \(DueDateFormatting.label(for: task.dueDate) ?? "")" : "")")
    .accessibilityAction(named: "Complete") { }
    .accessibilityAction(named: "Snooze") { }
    .accessibilityAction(named: "Mark Waiting") { }
}
}
