import SwiftUI

struct CreateDecisionSheet: View {
  @Environment(AppStore.self) private var store
  @Environment(QuickCaptureState.self) private var quickCapture
  @State private var clientID: Client.ID?
  @State private var projectID: ClientProject.ID?
  @State private var text = ""
  @State private var saved = false
  @State private var isSaving = false
  @State private var saveError: Error?
  @FocusState private var focused: Bool

  var body: some View {
    Form {
      Section("Client") {
        Picker("Client", selection: $clientID) {
          Text("None").tag(Client.ID?.none)
          ForEach(store.clients) { client in
            Text(client.name).tag(Optional(client.id))
          }
        }
        .pickerStyle(.menu)
        .labelsHidden()
        .accessibilityLabel("Select client")
        .accessibilityHint("Choose which client this decision belongs to")
      }

      Section("What was decided?") {
        TextField("Online ordering must be completed before launching the website.", text: $text, axis: .vertical)
          .lineLimit(4...8)
          .focused($focused)
          .submitLabel(.done)
          .onSubmit { save() }
      }

      if let clientID, !store.projects(for: clientID).isEmpty {
        Section("Related Project") {
          Picker("Project", selection: $projectID) {
            Text("None").tag(ClientProject.ID?.none)
            ForEach(store.projects(for: clientID)) { project in
              Text(project.name).tag(Optional(project.id))
            }
          }
          .pickerStyle(.menu)
          .labelsHidden()
          .accessibilityLabel("Select project")
          .accessibilityHint("Choose which project this decision relates to")
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
            Text("Save Decision")
              .font(.body.weight(.semibold))
              .frame(maxWidth: .infinity, minHeight: 44)
          }
        }
        .disabled(text.trimmingCharacters(in: .whitespaces).isEmpty || clientID == nil || isSaving)
      }
    }
    .navigationTitle("Log Decision")
    .navigationBarTitleDisplayMode(.inline)
    .onAppear {
      clientID = quickCapture.prefilledClientID
      projectID = quickCapture.prefilledProjectID
      focused = true
    }
    .sensoryFeedback(.success, trigger: saved)
  }

  private func save() {
    guard let clientID else { return }
    isSaving = true
    saveError = nil
    defer { isSaving = false }

    do {
      store.addDecision(text: text.trimmingCharacters(in: .whitespaces), clientID: clientID, projectID: projectID)
      saved.toggle()
      quickCapture.dismiss()
    } catch {
      saveError = error
    }
  }
}
