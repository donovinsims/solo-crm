import SwiftUI

struct PromoteFindingSheet: View {
  let finding: Finding
  @Environment(AppStore.self) private var store
  @Environment(\.dismiss) private var dismiss
  @State private var projectName = ""
  @State private var phase = ""
  @State private var saved = false
  @State private var isSaving = false
  @State private var saveError: String?
  @FocusState private var nameFocused: Bool

  private var suggestedName: String {
    let words = finding.text.split(separator: " ").prefix(5).joined(separator: " ")
    return words.capitalized
  }

  private var suggestedPhase: String {
    switch finding.category {
    case .website: return "Website"
    case .leadHandling: return "Lead Automation"
    case .customerExperience: return "CX Improvement"
    case .operations: return "Operations"
    case .ordering: return "Ordering System"
    case .scheduling: return "Scheduling"
    case .payments: return "Payments"
    case .automation: return "Automation"
    case .other: return "Discovery"
    }
  }

  var body: some View {
    NavigationStack {
      Form {
        Section("Project Name") {
          TextField("Online Ordering + Website", text: $projectName)
            .focused($nameFocused)
            .submitLabel(.next)
            .onSubmit { nameFocused = false }
          Text("Short, clear name for the new project")
            .font(.caption)
            .foregroundStyle(DesignTokens.textTertiary)
        }

        Section("Initial Phase") {
          TextField("Toast Online Ordering", text: $phase)
            .submitLabel(.done)
            .onSubmit { save() }
          Text("Current phase or milestone")
            .font(.caption)
            .foregroundStyle(DesignTokens.textTertiary)
        }

        Section("Source Finding") {
          VStack(alignment: .leading, spacing: DesignTokens.spaceXS) {
            Text(finding.text)
              .font(.body)
              .foregroundStyle(DesignTokens.textPrimary)
              .lineLimit(3)
            HStack(spacing: DesignTokens.spaceS) {
              Label(finding.category.rawValue, systemImage: "tag")
              Label("\(finding.impact.rawValue) impact", systemImage: "exclamationmark.triangle")
            }
            .font(.caption)
            .foregroundStyle(DesignTokens.textSecondary)
          }
          .padding(.vertical, DesignTokens.spaceXS)
        }

        if let error = saveError {
          Section {
            HStack {
              Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.red)
              Text(error)
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
              Text("Create Project")
                .font(.body.weight(.semibold))
                .frame(maxWidth: .infinity, minHeight: 44)
            }
          }
          .disabled(projectName.trimmingCharacters(in: .whitespaces).isEmpty || phase.trimmingCharacters(in: .whitespaces).isEmpty || isSaving)
        }
      }
      .navigationTitle("Promote to Project")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") { dismiss() }
        }
      }
      .onAppear {
        projectName = suggestedName
        phase = suggestedPhase
        nameFocused = true
      }
      .sensoryFeedback(.success, trigger: saved)
    }
    .presentationDetents([.medium, .large])
    .presentationDragIndicator(.visible)
  }

  private func save() {
    let trimmedName = projectName.trimmingCharacters(in: .whitespaces)
    let trimmedPhase = phase.trimmingCharacters(in: .whitespaces)
    guard !trimmedName.isEmpty, !trimmedPhase.isEmpty else { return }

    isSaving = true
    saveError = nil
    defer { isSaving = false }

    if store.promoteFindingToProject(finding, name: trimmedName, phase: trimmedPhase) == nil {
      saveError = "Finding is missing a client link."
      return
    }
    saved.toggle()
    dismiss()
  }
}
