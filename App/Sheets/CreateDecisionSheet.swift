import SwiftUI

struct CreateDecisionSheet: View {
  @Environment(AppStore.self) private var store
  @Environment(QuickCaptureState.self) private var quickCapture
  @State private var clientID: Client.ID?
  @State private var projectID: ClientProject.ID?
  @State private var text = ""
  @State private var saved = false
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
      }

      Section("What was decided?") {
        TextField("Online ordering must be completed before launching the website.", text: $text, axis: .vertical)
          .lineLimit(4...8)
          .focused($focused)
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
        }
      }

      Section {
        Button {
          save()
        } label: {
          Text("Save Decision")
            .font(.body.weight(.semibold))
            .frame(maxWidth: .infinity)
        }
        .disabled(text.trimmingCharacters(in: .whitespaces).isEmpty || clientID == nil)
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
    store.addDecision(text: text.trimmingCharacters(in: .whitespaces), clientID: clientID, projectID: projectID)
    saved.toggle()
    quickCapture.dismiss()
  }
}
