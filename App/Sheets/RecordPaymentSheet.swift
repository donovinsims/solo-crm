import SwiftUI

struct RecordPaymentSheet: View {
  @Environment(AppStore.self) private var store
  @Environment(QuickCaptureState.self) private var quickCapture
  @State private var clientID: Client.ID?
  @State private var projectID: ClientProject.ID?
  @State private var amountText = ""
  @State private var method: PaymentMethod = .ach
  @State private var saved = false
  @FocusState private var amountFocused: Bool

  private var project: ClientProject? { store.project(projectID) }

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

      if let clientID {
        Section("Project") {
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

      if let project {
        Section {
          HStack {
            Text("Project value")
              .foregroundStyle(.secondary)
            Spacer()
            Text("$\(Int(project.projectValue))")
          }
          HStack {
            Text("Already paid")
              .foregroundStyle(.secondary)
            Spacer()
            Text("$\(Int(project.paidAmount))")
          }
        }
      }

      Section("Amount Received") {
        HStack {
          Text("$")
            .foregroundStyle(.secondary)
          TextField("0", text: $amountText)
            .keyboardType(.decimalPad)
            .focused($amountFocused)
        }
      }

      Section("Method") {
        Picker("Method", selection: $method) {
          ForEach(PaymentMethod.allCases) { method in
            Text(method.rawValue).tag(method)
          }
        }
        .pickerStyle(.inline)
        .labelsHidden()
      }

      Section("Date") {
        Text("Today")
          .foregroundStyle(.secondary)
      }

      Section {
        Button {
          save()
        } label: {
          Text("Record Payment")
            .font(.body.weight(.semibold))
            .frame(maxWidth: .infinity)
        }
        .disabled(project == nil || Double(amountText) == nil)
      }
    }
    .navigationTitle("Record Payment")
    .navigationBarTitleDisplayMode(.inline)
    .onAppear {
      clientID = quickCapture.prefilledClientID
      projectID = quickCapture.prefilledProjectID
      amountFocused = true
    }
    .sensoryFeedback(.success, trigger: saved)
  }

  private func save() {
    guard let clientID, let projectID, let amount = Double(amountText) else { return }
    store.recordPayment(clientID: clientID, projectID: projectID, amount: amount, method: method)
    saved.toggle()
    quickCapture.dismiss()
  }
}
