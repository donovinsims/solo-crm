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
      }

      Section("Contact") {
        TextField("Name", text: $name).focused($nameFocused)
        TextField("Role", text: $role)
        TextField("Phone", text: $phone).keyboardType(.phonePad)
        TextField("Email", text: $email).keyboardType(.emailAddress).textInputAutocapitalization(.never)
      }

      Section {
        Button {
          save()
        } label: {
          Text("Add Contact")
            .font(.body.weight(.semibold))
            .frame(maxWidth: .infinity)
        }
        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || clientID == nil)
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
    store.addContact(name: name.trimmingCharacters(in: .whitespaces), role: role, phone: phone, email: email, clientID: clientID)
    saved.toggle()
    quickCapture.dismiss()
  }
}
