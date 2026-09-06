import SwiftUI

struct CreateFindingSheet: View {
  @Environment(AppStore.self) private var store
  @Environment(QuickCaptureState.self) private var quickCapture
  @State private var clientID: Client.ID?
  @State private var text = ""
  @State private var category: FindingCategory = .operations
  @State private var impact: FindingImpact = .medium
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
        .accessibilityHint("Choose which client this finding belongs to")
      }

      Section("What did you notice?") {
        TextField("They are manually answering the same customer questions repeatedly.", text: $text, axis: .vertical)
          .lineLimit(4...8)
          .focused($focused)
          .submitLabel(.done)
          .onSubmit { save() }
      }

      Section("Category") {
        Picker("Category", selection: $category) {
          ForEach(FindingCategory.allCases) { category in
            Text(category.rawValue).tag(category)
          }
        }
        .pickerStyle(.menu)
        .labelsHidden()
        .accessibilityLabel("Finding category")
        .accessibilityHint("Select the type of finding")
      }

      Section("Impact") {
        Picker("Impact", selection: $impact) {
          ForEach(FindingImpact.allCases) { impact in
            Text(impact.rawValue).tag(impact)
          }
        }
        .pickerStyle(.segmented)
        .labelsHidden()
        .accessibilityLabel("Impact level")
        .accessibilityHint("Select the impact level of this finding")
      }

      Section("Optional") {
        Label("Add photo", systemImage: "camera")
          .foregroundStyle(.secondary)
          .accessibilityLabel("Add photo")
          .accessibilityHint("Attach a photo to this finding")
        Label("Add voice note", systemImage: "mic")
          .foregroundStyle(.secondary)
          .accessibilityLabel("Add voice note")
          .accessibilityHint("Record a voice note for this finding")
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
            Text("Save Finding")
              .font(.body.weight(.semibold))
              .frame(maxWidth: .infinity, minHeight: 44)
          }
        }
        .disabled(text.trimmingCharacters(in: .whitespaces).isEmpty || clientID == nil || isSaving)
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
    isSaving = true
    saveError = nil
    defer { isSaving = false }

    do {
      store.addFinding(text: text.trimmingCharacters(in: .whitespaces), clientID: clientID, projectID: quickCapture.prefilledProjectID, category: category, impact: impact)
      saved.toggle()
      quickCapture.dismiss()
    } catch {
      saveError = error
    }
  }
}
