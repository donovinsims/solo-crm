import SwiftUI

struct ProjectStatusSheet: View {
  var project: ClientProject
  @Environment(AppStore.self) private var store
  @Environment(QuickCaptureState.self) private var quickCapture
  @Environment(\.dismiss) private var dismiss
  @State private var selectedStatus: ProjectStatus

  init(project: ClientProject) {
    self.project = project
    _selectedStatus = State(initialValue: project.status)
  }

  var body: some View {
    NavigationStack {
      List {
        Section {
          Text(project.name)
            .font(.title3.weight(.bold))
        }
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)

        Section("Update Status") {
          ForEach(ProjectStatus.allCases) { status in
            Button {
              selectedStatus = status
              store.updateProjectStatus(project, to: status)
            } label: {
              HStack {
                StatusDot(tint: status.tint)
                Text(status.rawValue)
                  .foregroundStyle(.primary)
                Spacer()
                if selectedStatus == status {
                  Image(systemName: "checkmark")
                    .foregroundStyle(Color.accentColor)
                }
              }
            }
            .accessibilityLabel("Set status to \(status.rawValue)")
            .accessibilityHint(selectedStatus == status ? "Currently selected" : "Tap to change status")
          }
        }

        Section {
          captureButton("Add Update", "text.badge.plus", .note)
          captureButton("Add Task", "checklist", .task)
          captureButton("Log Decision", "checkmark.seal", .decision)
          captureButton("Add Finding", "eye", .finding)
        }
      }
      .listStyle(.insetGrouped)
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button("Done") { dismiss() }
        }
      }
    }
    .presentationDetents([.medium, .large])
    .presentationDragIndicator(.visible)
    .presentationCornerRadius(28)
  }

  private func captureButton(_ title: String, _ systemImage: String, _ stage: QuickCaptureState.Stage) -> some View {
    Button {
      dismiss()
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
        quickCapture.present(clientID: project.client?.id, projectID: project.id, stage: stage)
      }
    } label: {
      Label(title, systemImage: systemImage)
    }
    .accessibilityLabel(title)
    .accessibilityHint("Opens \(title.lowercased()) capture")
  }
}
