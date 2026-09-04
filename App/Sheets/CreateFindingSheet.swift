import SwiftUI

struct CreateFindingSheet: View {
  @Environment(AppStore.self) private var store
  @Environment(QuickCaptureState.self) private var quickCapture
  @State private var clientID: Client.ID?
  @State private var text = ""
  @State private var category: FindingCategory = .operations
  @State private var impact: FindingImpact = .medium
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

      Section("What did you notice?") {
        TextField("They are manually answering the same customer questions repeatedly.", text: $text, axis: .vertical)
          .lineLimit(4...8)
          .focused($focused)
      }

      Section("Category") {
        Picker("Category", selection: $category) {
          ForEach(FindingCategory.allCases) { category in
            Text(category.rawValue).tag(category)
          }
        }
        .pickerStyle(.menu)
        .labelsHidden()
      }

      Section("Impact") {
        Picker("Impact", selection: $impact) {
          ForEach(FindingImpact.allCases) { impact in
            Text(impact.rawValue).tag(impact)
          }
        }
        .pickerStyle(.segmented)
        .labelsHidden()
      }

      Section("Optional") {
        Label("Add photo", systemImage: "camera")
          .foregroundStyle(.secondary)
        Label("Add voice note", systemImage: "mic")
          .foregroundStyle(.secondary)
      }

      Section {
        Button {
          save()
        } label: {
          Text("Save Finding")
            .font(.body.weight(.semibold))
            .frame(maxWidth: .infinity)
        }
        .disabled(text.trimmingCharacters(in: .whitespaces).isEmpty || clientID == nil)
      }
    }
    .navigationTitle("New Finding")
    .navigationBarTitleDisplayMode(.inline)
    .onAppear {
      clientID = quickCapture.prefilledClientID
      focused = true
    }
    .sensoryFeedback(.success, trigger: saved)
  }

  private func save() {
    guard let clientID else { return }
    store.addFinding(text: text.trimmingCharacters(in: .whitespaces), clientID: clientID, projectID: quickCapture.prefilledProjectID, category: category, impact: impact)
    saved.toggle()
    quickCapture.dismiss()
  }
}
