import SwiftUI

struct QuickCaptureSheet: View {
  @Environment(QuickCaptureState.self) private var quickCapture

  var body: some View {
    NavigationStack {
      Group {
        switch quickCapture.stage {
        case .root: QuickCaptureRootView()
        case .task: CreateTaskSheet()
        case .note: CreateNoteSheet()
        case .finding: CreateFindingSheet()
        case .decision: CreateDecisionSheet()
        case .payment: RecordPaymentSheet()
        case .contact: AddContactSheet()
        case .voice: VoiceCaptureSheet()
        case .voiceReview: VoiceReviewSheet()
        }
      }
      .transition(.opacity.combined(with: .move(edge: .trailing)))
      .toolbar {
        if quickCapture.stage != .root {
          ToolbarItem(placement: .topBarLeading) {
            Button {
              withAnimation(.snappy(duration: 0.32)) { quickCapture.stage = .root }
            } label: {
              Image(systemName: "chevron.left")
            }
            .accessibilityLabel("Back")
          }
        }

        ToolbarItem(placement: .topBarTrailing) {
          Button {
            quickCapture.dismiss()
          } label: {
            Image(systemName: "xmark")
          }
          .accessibilityLabel("Close capture")
        }
      }
    }
    .animation(.snappy(duration: 0.32), value: quickCapture.stage)
    .presentationDetents([.medium, .large])
    .presentationDragIndicator(.visible)
    .presentationCornerRadius(28)
  }
}

struct QuickCaptureRootView: View {
  @Environment(AppStore.self) private var store
  @Environment(QuickCaptureState.self) private var quickCapture
  @State private var text = ""
  @State private var saved = false
  @State private var isSaving = false
  @State private var saveError: Error?
  @FocusState private var focused: Bool

  var body: some View {
    Form {
      Section {
        TextField("Capture a thought, task, or update…", text: $text, axis: .vertical)
          .lineLimit(3...7)
          .focused($focused)
          .submitLabel(.done)
          .onSubmit { saveNote() }
      } header: {
        Text("Start with the thought")
      } footer: {
        if let clientID = quickCapture.prefilledClientID, let client = store.client(clientID) {
          Text("This will be saved to \(client.name).")
        } else {
          Text("You can organize it more precisely later.")
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
            Button("Retry") { saveNote() }
              .font(.footnote.weight(.semibold))
              .buttonStyle(.bordered)
          }
        }
      }

      Section {
        Button {
          saveNote()
        } label: {
          if isSaving {
            ProgressView()
              .frame(maxWidth: .infinity, minHeight: 44)
          } else {
            Label("Save to Today", systemImage: "arrow.down.circle.fill")
              .font(.body.weight(.semibold))
              .frame(maxWidth: .infinity, minHeight: 44)
          }
        }
        .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSaving)
      }

      Section("Add more detail") {
        captureRow(.task, title: "Task", subtitle: "Something that needs to happen", systemImage: "checklist")
        captureRow(.finding, title: "Finding", subtitle: "Something you noticed", systemImage: "eye")
        captureRow(.decision, title: "Decision", subtitle: "Something that was decided", systemImage: "checkmark.seal")
        captureRow(.payment, title: "Payment", subtitle: "Money received or outstanding", systemImage: "dollarsign.circle")
        captureRow(.contact, title: "Contact", subtitle: "Add someone new", systemImage: "person.crop.circle.badge.plus")
        captureRow(.voice, title: "Voice", subtitle: "Capture without typing", systemImage: "mic.fill")
      }
    }
    .navigationTitle("Capture")
    .navigationBarTitleDisplayMode(.inline)
    .onAppear { focused = true }
    .sensoryFeedback(.success, trigger: saved)
  }

  private func captureRow(_ stage: QuickCaptureState.Stage, title: String, subtitle: String, systemImage: String) -> some View {
    Button {
      withAnimation(.snappy(duration: 0.32)) { quickCapture.stage = stage }
    } label: {
      HStack(spacing: 14) {
        Image(systemName: systemImage)
          .font(.body.weight(.medium))
          .foregroundStyle(.tint)
          .frame(width: 32, height: 32)
          .accessibilityHidden(true)

        VStack(alignment: .leading, spacing: 2) {
          Text(title)
            .font(.body.weight(.medium))
            .foregroundStyle(.primary)
          Text(subtitle)
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }

        Spacer()

        Image(systemName: "chevron.right")
          .font(.footnote.weight(.semibold))
          .foregroundStyle(.tertiary)
          .accessibilityHidden(true)
      }
      .frame(minHeight: 44)
    }
    .buttonStyle(.plain)
    .accessibilityElement(children: .combine)
    .accessibilityLabel("\(title). \(subtitle)")
    .accessibilityHint("Opens \(title.lowercased()) capture")
  }

  private func saveNote() {
    let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmedText.isEmpty else { return }
    isSaving = true
    saveError = nil
    defer { isSaving = false }

    do {
      store.addNote(text: trimmedText, clientID: quickCapture.prefilledClientID)
      saved.toggle()
      quickCapture.dismiss()
    } catch {
      saveError = error
    }
  }
}
