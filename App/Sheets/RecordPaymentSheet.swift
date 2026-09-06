import SwiftUI

struct RecordPaymentSheet: View {
  @Environment(AppStore.self) private var store
  @Environment(QuickCaptureState.self) private var quickCapture
  @State private var clientID: Client.ID?
  @State private var projectID: ClientProject.ID?
  @State private var amountText = ""
  @State private var method: PaymentMethod = .ach
  @State private var saved = false
  @State private var isSaving = false
  @State private var saveError: Error?
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
        .accessibilityLabel("Select client")
        .accessibilityHint("Choose which client this payment is for")
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
          .accessibilityLabel("Select project")
          .accessibilityHint("Choose which project this payment applies to")
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
      } else if clientID != nil {
        Section {
          InlineEmptyState(systemImage: "dollarsign.circle", message: "Select a project to record payment")
        }
      }

      Section("Amount Received") {
        HStack {
          Text("$")
            .foregroundStyle(.secondary)
          TextField("0", text: $amountText)
            .keyboardType(.decimalPad)
            .focused($amountFocused)
            .submitLabel(.done)
            .onSubmit { save() }
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
        .accessibilityLabel("Payment method")
        .accessibilityHint("Select how the payment was received")
      }

      Section("Date") {
        Text("Today")
          .foregroundStyle(.secondary)
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
            Text("Record Payment")
              .font(.body.weight(.semibold))
              .frame(maxWidth: .infinity, minHeight: 44)
          }
        }
        .disabled(project == nil || Double(amountText) == nil || isSaving)
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
    isSaving = true
    saveError = nil
    defer { isSaving = false }

    do {
      store.recordPayment(clientID: clientID, projectID: projectID, amount: amount, method: method)
      saved.toggle()
      quickCapture.dismiss()
    } catch {
      saveError = error
    }
  }
}
