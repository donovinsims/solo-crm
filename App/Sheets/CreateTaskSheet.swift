import SwiftUI

struct CreateTaskSheet: View {
  private enum DueOption: String, CaseIterable, Identifiable {
    case today = "Today"
    case tomorrow = "Tomorrow"
    case friday = "Friday"
    case chooseDate = "Choose Date"
    case none = "None"

    var id: String { rawValue }

    var date: Date? {
      let calendar = Calendar.current
      switch self {
      case .today: return .now
      case .tomorrow: return calendar.date(byAdding: .day, value: 1, to: .now)
      case .friday:
        var components = DateComponents()
        components.weekday = 6
        return calendar.nextDate(after: .now, matching: components, matchingPolicy: .nextTime)
      case .chooseDate, .none: return nil
      }
    }
  }

  @Environment(AppStore.self) private var store
  @Environment(QuickCaptureState.self) private var quickCapture
  @State private var title = ""
  @State private var clientID: Client.ID?
  @State private var projectID: ClientProject.ID?
  @State private var dueOption: DueOption = .today
  @State private var customDate = Date.now
  @State private var detailsExpanded = false
  @State private var saved = false
  @State private var isSaving = false
  @State private var saveError: Error?
  @FocusState private var titleFocused: Bool

  var body: some View {
    Form {
      Section {
        TextField("What needs to happen?", text: $title, axis: .vertical)
          .focused($titleFocused)
          .submitLabel(.next)
      } header: {
        Text("Task")
      } footer: {
        Text("Keep it short. You can add context when it becomes useful.")
      }

      Section {
        DisclosureGroup("Add details", isExpanded: $detailsExpanded) {
          Picker("Client", selection: $clientID) {
            Text("None").tag(Client.ID?.none)
            ForEach(store.clients) { client in
              Text(client.name).tag(Optional(client.id))
            }
          }
          .pickerStyle(.menu)
          .accessibilityLabel("Select client")
          .accessibilityHint("Choose which client this task belongs to")

          if let clientID, !store.projects(for: clientID).isEmpty {
            Picker("Project", selection: $projectID) {
              Text("None").tag(ClientProject.ID?.none)
              ForEach(store.projects(for: clientID)) { project in
                Text(project.name).tag(Optional(project.id))
              }
            }
            .pickerStyle(.menu)
            .accessibilityLabel("Select project")
            .accessibilityHint("Choose which project this task belongs to")
          }

          Picker("Due", selection: $dueOption) {
            ForEach(DueOption.allCases) { option in
              Text(option.rawValue).tag(option)
            }
          }
          .pickerStyle(.menu)
          .accessibilityLabel("Due date option")
          .accessibilityHint("Select when this task is due")

          if dueOption == .chooseDate {
            DatePicker("Date", selection: $customDate, displayedComponents: .date)
              .accessibilityLabel("Custom due date")
              .accessibilityHint("Select a specific due date")
          }
        }
      } footer: {
        if let clientID, let client = store.client(clientID) {
          Text("For \(client.name).")
        } else {
          Text("Client, project, and due date are optional.")
        }
      }

      if let error = saveError {
        Section {
          HStack {
            Image(systemName: "exclamationmark.triangle.fill")
              .foregroundStyle(.red)
            Text(error.localizedDescription)
              .font(.footnote)
              .foregroundStyle(.red)
            Spacer()
            Button("Retry") { save() }
              .font(.footnote.weight(.semibold))
              .buttonStyle(.bordered)
          }
        }
      }

      Section {
        Button {
          save()
        } label: {
          if isSaving {
            ProgressView()
              .frame(maxWidth: .infinity, minHeight: 44)
          } else {
            Text("Add Task")
              .font(.body.weight(.semibold))
              .frame(maxWidth: .infinity, minHeight: 44)
          }
        }
        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty || isSaving)
      }
    }
    .navigationTitle("Task")
    .navigationBarTitleDisplayMode(.inline)
    .onAppear {
      clientID = quickCapture.prefilledClientID
      projectID = quickCapture.prefilledProjectID
      detailsExpanded = false
      titleFocused = true
    }
    .sensoryFeedback(.success, trigger: saved)
  }

  private func save() {
    let due = dueOption == .chooseDate ? customDate : dueOption.date
    isSaving = true
    saveError = nil
    defer { isSaving = false }

    do {
      store.addTask(title: title.trimmingCharacters(in: .whitespaces), clientID: clientID, projectID: projectID, dueDate: due)
      saved.toggle()
      quickCapture.dismiss()
    } catch {
      saveError = error
    }
  }
}
