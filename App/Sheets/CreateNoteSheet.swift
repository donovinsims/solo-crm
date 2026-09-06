import SwiftUI

struct CreateNoteSheet: View {
  @Environment(AppStore.self) private var store
  @Environment(QuickCaptureState.self) private var quickCapture
  @State private var clientID: Client.ID?
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
        .accessibilityHint("Choose which client this note belongs to")
      }

      Section("What's worth remembering?") {
        TextField("Note", text: $text, axis: .vertical)
          .lineLimit(4...8)
          .focused($focused)
          .submitLabel(.done)
          .onSubmit { save() }
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
            Text("Save Note")
              .font(.body.weight(.semibold))
              .frame(maxWidth: .infinity, minHeight: 44)
          }
        }
        .disabled(text.trimmingCharacters(in: .whitespaces).isEmpty || isSaving)
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
    isSaving = true
    saveError = nil
    defer { isSaving = false }

    do {
      store.addNote(text: text.trimmingCharacters(in: .whitespaces), clientID: clientID)
      saved.toggle()
      quickCapture.dismiss()
    } catch {
      saveError = error
    }
  }
}
