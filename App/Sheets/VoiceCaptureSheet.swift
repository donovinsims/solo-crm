import SwiftUI

struct VoiceCaptureSheet: View {
  private enum RecordingState {
    case idle
    case recording
    case processing
  }

  @Environment(QuickCaptureState.self) private var quickCapture
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @State private var recordingState: RecordingState = .idle
  @State private var pulse = false

  private let sampleTranscript = "Pietro's wants online ordering finished before the website. I need to test pickup ordering. They're also manually answering common customer questions."

  var body: some View {
    VStack(spacing: 28) {
      Spacer()

      Text(headline)
        .font(.title3.weight(.semibold))
        .multilineTextAlignment(.center)
        .padding(.horizontal, 32)

      Button {
        handleTap()
      } label: {
        ZStack {
          Circle()
            .fill(Color.red.opacity(0.15))
            .frame(width: 128, height: 128)
            .scaleEffect(pulse ? 1.15 : 1)

          Circle()
            .fill(Color.red)
            .frame(width: 96, height: 96)

          if recordingState == .processing {
            ProgressView()
              .tint(.white)
          } else {
            Image(systemName: recordingState == .recording ? "stop.fill" : "mic.fill")
              .font(.system(size: 34))
              .foregroundStyle(.white)
          }
        }
      }
      .buttonStyle(.plain)
      .disabled(recordingState == .processing)
      .accessibilityLabel(accessibilityLabel)
      .accessibilityHint(accessibilityHint)
      .if(!reduceMotion) { view in
        view.animation(.smooth(duration: 0.9).repeatForever(autoreverses: true), value: pulse)
      }

      Text(subtitle)
        .font(.subheadline)
        .foregroundStyle(.secondary)

      Spacer()
      Spacer()
    }
    .navigationTitle("Voice Capture")
    .navigationBarTitleDisplayMode(.inline)
  }

  private var headline: String {
    switch recordingState {
    case .idle: "Tap to start recording"
    case .recording: "Listening…"
    case .processing: "Making sense of it…"
    }
  }

  private var subtitle: String {
    switch recordingState {
    case .idle: "Talk naturally. You can mention tasks, decisions, and things you noticed."
    case .recording: "Tap again when you're done."
    case .processing: ""
    }
  }

  private var accessibilityLabel: String {
    switch recordingState {
    case .idle: "Start recording"
    case .recording: "Stop recording"
    case .processing: "Processing recording"
    }
  }

  private var accessibilityHint: String {
    switch recordingState {
    case .idle: "Begin voice capture"
    case .recording: "End voice capture and process"
    case .processing: "Please wait while the recording is processed"
    }
  }

  private func handleTap() {
    switch recordingState {
    case .idle:
      recordingState = .recording
      pulse = true
    case .recording:
      pulse = false
      recordingState = .processing
      DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
        quickCapture.voiceTranscript = sampleTranscript
        withAnimation(.snappy(duration: 0.32)) {
          quickCapture.stage = .voiceReview
        }
      }
    case .processing:
      break
    }
  }
}

extension View {
  @ViewBuilder
  func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
    if condition {
      transform(self)
    } else {
      self
    }
  }
}

struct VoiceReviewSheet: View {
  @Environment(AppStore.self) private var store
  @Environment(QuickCaptureState.self) private var quickCapture
  @State private var saved = false
  @State private var isSaving = false
  @State private var saveError: Error?

  private var pietro: Client? { store.clients.first { $0.name.contains("Pietro") } }

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 22) {
        VStack(alignment: .leading, spacing: 6) {
          SectionLabel(title: "Transcript")
          Text(quickCapture.voiceTranscript)
            .font(.body)
            .foregroundStyle(.secondary)
            .padding(12)
            .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 12))
        }

        reviewCard(title: "Decision", systemImage: "checkmark.seal", tint: .green, text: "Online ordering remains priority.")
        reviewCard(title: "Task", systemImage: "checklist", tint: .blue, text: "Test pickup ordering.")
        reviewCard(title: "Finding", systemImage: "eye", tint: .purple, text: "Repeated customer questions handled manually.")

        if let error = saveError {
          HStack {
            Image(systemName: "exclamationmark.triangle.fill")
              .foregroundStyle(.red)
            Text(error.localizedDescription)
              .font(.footnote)
              .foregroundStyle(.red)
            Spacer()
            Button("Retry") { saveAll() }
              .font(.footnote.weight(.semibold))
              .buttonStyle(.bordered)
          }
          .padding(.horizontal, 20)
        }

        VStack(spacing: 10) {
          Button {
            saveAll()
          } label: {
            if isSaving {
              ProgressView()
                .frame(maxWidth: .infinity, minHeight: 44)
            } else {
              Text("Save All")
                .font(.body.weight(.semibold))
                .frame(maxWidth: .infinity, minHeight: 44)
            }
          }
          .buttonStyle(.borderedProminent)
          .disabled(isSaving)

          HStack(spacing: 10) {
            Button("Edit") { }
              .frame(maxWidth: .infinity)
            Button("Discard", role: .destructive) { quickCapture.dismiss() }
              .frame(maxWidth: .infinity)
          }
          .buttonStyle(.bordered)
        }
        .padding(.top, 4)
      }
      .padding(20)
    }
    .background(Color(.systemGroupedBackground))
    .navigationTitle("Review")
    .navigationBarTitleDisplayMode(.inline)
    .sensoryFeedback(.success, trigger: saved)
  }

  private func reviewCard(title: String, systemImage: String, tint: Color, text: String) -> some View {
    HStack(alignment: .top, spacing: 12) {
      Image(systemName: systemImage)
        .foregroundStyle(tint)
        .frame(width: 28, height: 28)
        .background(tint.opacity(0.15), in: .rect(cornerRadius: 8))
        .accessibilityHidden(true)

      VStack(alignment: .leading, spacing: 3) {
        Text(title.uppercased())
          .font(.caption.weight(.semibold))
          .foregroundStyle(.secondary)
        Text(text)
          .font(.body)
          .foregroundStyle(.primary)
      }
      Spacer()
    }
    .accessibilityElement(children: .combine)
    .accessibilityLabel("\(title): \(text)")
  }

  private func saveAll() {
    guard let pietro else {
      quickCapture.dismiss()
      return
    }
    isSaving = true
    saveError = nil
    defer { isSaving = false }

    do {
      let project = store.projects(for: pietro.id).first
      store.addDecision(text: "Online ordering remains priority.", clientID: pietro.id, projectID: project?.id)
      store.addTask(title: "Test pickup ordering.", clientID: pietro.id, projectID: project?.id, dueDate: Date.now)
      store.addFinding(text: "Repeated customer questions handled manually.", clientID: pietro.id, projectID: project?.id, category: .customerExperience, impact: .medium)
      saved.toggle()
      quickCapture.dismiss()
    } catch {
      saveError = error
    }
  }
}
