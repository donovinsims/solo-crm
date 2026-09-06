import SwiftUI

struct AddContactSheet: View {
  @Environment(AppStore.self) private var store
  @Environment(QuickCaptureState.self) private var quickCapture
  @State private var clientID: Client.ID?
  @State private var name = ""
  @State private var role = ""
  @State private var phone = ""
  @State private var email = ""
  @State private var saved = false
  @State private var isSaving = false
  @State private var saveError: Error?
  @FocusState private var nameFocused: Bool

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
        .accessibilityHint("Choose which client this contact belongs to")
      }

      Section("Contact") {
        TextField("Name", text: $name)
          .focused($nameFocused)
          .submitLabel(.next)
        TextField("Role", text: $role)
          .submitLabel(.next)
        TextField("Phone", text: $phone)
          .keyboardType(.phonePad)
          .submitLabel(.next)
        TextField("Email", text: $email)
          .keyboardType(.emailAddress)
          .textInputAutocapitalization(.never)
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
            Text("Add Contact")
              .font(.body.weight(.semibold))
              .frame(maxWidth: .infinity, minHeight: 44)
          }
        }
        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || clientID == nil || isSaving)
      }
    }
    .navigationTitle("New Contact")
    .navigationBarTitleDisplayMode(.inline)
    .onAppear {
      clientID = quickCapture.prefilledClientID
      nameFocused = true
    }
    .sensoryFeedback(.success, trigger: saved)
  }

  private func save() {
    guard let clientID else { return }
    isSaving = true
    saveError = nil
    defer { isSaving = false }

    do {
      store.addContact(name: name.trimmingCharacters(in: .whitespaces), role: role, phone: phone, email: email, clientID: clientID)
      saved.toggle()
      quickCapture.dismiss()
    } catch {
      saveError = error
    }
  }
}
