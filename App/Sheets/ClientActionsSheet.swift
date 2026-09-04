import SwiftUI
import UIKit

struct ClientActionsSheet: View {
  var client: Client
  @Environment(AppStore.self) private var store
  @Environment(QuickCaptureState.self) private var quickCapture
  @Environment(\.dismiss) private var dismiss

  private var project: ClientProject? { store.projects(for: client.id).first }

  var body: some View {
    NavigationStack {
      List {
        Section {
          Text(client.name)
            .font(.title3.weight(.bold))
        }
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)

        Section {
          Button { open("tel://\(client.phone.filter(\.isNumber))") } label: {
            Label("Call", systemImage: "phone")
          }
          Button { open("sms://\(client.phone.filter(\.isNumber))") } label: {
            Label("Text", systemImage: "message")
          }
          Button { open("mailto:\(client.email)") } label: {
            Label("Email", systemImage: "envelope")
          }
        }

        Section {
          captureButton("Add Task", "checklist", .task)
          captureButton("Add Note", "note.text", .note)
          captureButton("Add Finding", "eye", .finding)
          captureButton("Log Decision", "checkmark.seal", .decision)
          captureButton("Record Payment", "dollarsign.circle", .payment)
        }

        if let project {
          Section {
            NavigationLink {
              ProjectDetailView(project: project)
            } label: {
              Label("Open Active Project", systemImage: "square.stack.3d.up")
            }
            ForEach(project.links) { link in
              Button {
                open(link.urlString)
              } label: {
                Label("Open \(link.title)", systemImage: link.systemImage)
              }
            }
          }
        }

        Section {
          Button("More Actions") { }
            .foregroundStyle(.secondary)
        }
      }
      .listStyle(.insetGrouped)
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button("Done") { dismiss() }
        }
      }
    }
    .presentationDetents([.medium, .large])
    .presentationDragIndicator(.visible)
    .presentationCornerRadius(28)
  }

  private func captureButton(_ title: String, _ systemImage: String, _ stage: QuickCaptureState.Stage) -> some View {
    Button {
      dismiss()
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
        quickCapture.present(clientID: client.id, projectID: project?.id, stage: stage)
      }
    } label: {
      Label(title, systemImage: systemImage)
    }
  }

  private func open(_ string: String) {
    guard let url = URL(string: string) else { return }
    UIApplication.shared.open(url)
  }
}
