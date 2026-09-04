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
      }
    }
    .animation(.snappy(duration: 0.32), value: quickCapture.stage)
    .presentationDetents([.medium, .large])
    .presentationDragIndicator(.visible)
    .presentationCornerRadius(28)
  }
}

struct QuickCaptureRootView: View {
  @Environment(QuickCaptureState.self) private var quickCapture

  var body: some View {
    List {
      Section {
        Text("Quick Capture")
          .font(.title2.weight(.bold))
        Text("What do you want to add?")
          .font(.subheadline)
          .foregroundStyle(.secondary)
      }
      .listRowSeparator(.hidden)
      .listRowBackground(Color.clear)

      Section {
        captureRow(.task, title: "Task", subtitle: "Something that needs to happen", systemImage: "checklist", tint: .blue)
        captureRow(.note, title: "Note", subtitle: "Something worth remembering", systemImage: "note.text", tint: .gray)
        captureRow(.finding, title: "Finding", subtitle: "Something you noticed in a business", systemImage: "eye", tint: .purple)
        captureRow(.decision, title: "Decision", subtitle: "Something that was decided", systemImage: "checkmark.seal", tint: .green)
        captureRow(.payment, title: "Payment", subtitle: "Money received or outstanding", systemImage: "dollarsign.circle", tint: .mint)
        captureRow(.contact, title: "Contact", subtitle: "Add someone new", systemImage: "person.crop.circle.badge.plus", tint: .orange)
        captureRow(.voice, title: "Voice", subtitle: "Capture without typing", systemImage: "mic.fill", tint: .red)
      }
    }
    .listStyle(.plain)
  }

  private func captureRow(_ stage: QuickCaptureState.Stage, title: String, subtitle: String, systemImage: String, tint: Color) -> some View {
    Button {
      withAnimation(.snappy(duration: 0.32)) { quickCapture.stage = stage }
    } label: {
      HStack(spacing: 14) {
        Image(systemName: systemImage)
          .font(.system(size: 17, weight: .medium))
          .foregroundStyle(tint)
          .frame(width: 32, height: 32)
          .background(tint.opacity(0.15), in: .rect(cornerRadius: 9))

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
      }
      .padding(.vertical, 4)
    }
  }
}
