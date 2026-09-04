import SwiftUI

struct CreateNoteSheet: View {
  @Environment(AppStore.self) private var store
  @Environment(QuickCaptureState.self) private var quickCapture
  @State private var clientID: Client.ID?
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

      Section("What's worth remembering?") {
        TextField("Note", text: $text, axis: .vertical)
          .lineLimit(4...8)
          .focused($focused)
      }

      Section {
        Button {
          save()
        } label: {
          Text("Save Note")
            .font(.body.weight(.semibold))
            .frame(maxWidth: .infinity)
        }
        .disabled(text.trimmingCharacters(in: .whitespaces).isEmpty)
      }
    }
    .navigationTitle("New Note")
    .navigationBarTitleDisplayMode(.inline)
    .onAppear {
      clientID = quickCapture.prefilledClientID
      focused = true
    }
    .sensoryFeedback(.success, trigger: saved)
  }

  private func save() {
    store.addNote(text: text.trimmingCharacters(in: .whitespaces), clientID: clientID)
    saved.toggle()
    quickCapture.dismiss()
  }
}
