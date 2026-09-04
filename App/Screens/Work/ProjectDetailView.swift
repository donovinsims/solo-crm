import SwiftUI
import UIKit

struct ProjectDetailView: View {
  var project: ClientProject
  @Environment(AppStore.self) private var store
  @Environment(QuickCaptureState.self) private var quickCapture
  @State private var statusSheetPresented = false

  private var client: Client? { store.client(project.clientID) }
  private var liveProject: ClientProject { store.project(project.id) ?? project }

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 26) {
        header
        pipeline
        moneyCard
        linksSection

        tasksSection
        decisionsSection
        blockersSection
        findingsSection
        recentUpdatesSection

        actionsRow
      }
      .padding(.horizontal, 20)
      .padding(.top, 8)
      .padding(.bottom, 32)
    }
    .background(Color(.systemGroupedBackground))
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Button("Status") { statusSheetPresented = true }
      }
    }
    .sheet(isPresented: $statusSheetPresented) {
      ProjectStatusSheet(project: liveProject)
    }
  }

  private var header: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(client?.name ?? "")
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(.secondary)
      Text(liveProject.name)
        .font(.largeTitle.weight(.bold))
      HStack(spacing: 6) {
        StatusDot(tint: liveProject.status.tint)
        Text(liveProject.status.rawValue)
          .font(.subheadline.weight(.medium))
          .foregroundStyle(liveProject.status.tint.color)
      }
    }
  }

  private var pipeline: some View {
    VStack(alignment: .leading, spacing: 14) {
      pipelineRow(label: "Current", value: liveProject.phase)
      if let next = liveProject.nextAction {
        pipelineRow(label: "Next", value: next)
      }
      pipelineRow(label: "After That", value: "Website launch")
    }
    .padding(16)
    .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 18))
  }

  private func pipelineRow(label: String, value: String) -> some View {
    HStack(alignment: .top) {
      Text(label.uppercased())
        .font(.caption.weight(.semibold))
        .foregroundStyle(.secondary)
        .frame(width: 80, alignment: .leading)
      Text(value)
        .font(.body.weight(.medium))
        .foregroundStyle(.primary)
      Spacer()
    }
  }

  private var moneyCard: some View {
    HStack {
      VStack(alignment: .leading, spacing: 2) {
        Text("Project")
          .font(.caption)
          .foregroundStyle(.secondary)
        Text("$\(Int(liveProject.projectValue))")
          .font(.title3.weight(.semibold))
      }
      Spacer()
      VStack(alignment: .leading, spacing: 2) {
        Text("Paid")
          .font(.caption)
          .foregroundStyle(.secondary)
        Text("$\(Int(liveProject.paidAmount))")
          .font(.title3.weight(.semibold))
      }
      Spacer()
      VStack(alignment: .leading, spacing: 2) {
        Text("Remaining")
          .font(.caption)
          .foregroundStyle(.secondary)
        Text("$\(Int(liveProject.remaining))")
          .font(.title3.weight(.semibold))
          .foregroundStyle(liveProject.remaining > 0 ? .red : .primary)
      }
    }
  }

  private var linksSection: some View {
    Group {
      if !liveProject.links.isEmpty {
        VStack(alignment: .leading, spacing: 10) {
          SectionLabel(title: "Links")
          ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
              ForEach(liveProject.links) { link in
                Button {
                  if let url = URL(string: link.urlString) {
                    UIApplication.shared.open(url)
                  }
                } label: {
                  Label(link.title, systemImage: link.systemImage)
                    .font(.subheadline.weight(.medium))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.secondarySystemGroupedBackground), in: .capsule)
                }
                .buttonStyle(.plain)
              }
            }
          }
        }
      }
    }
  }

  private var tasksSection: some View {
    let items = store.tasks(forProject: liveProject.id)
    return Group {
      if !items.isEmpty {
        VStack(alignment: .leading, spacing: 10) {
          SectionLabel(title: "Tasks")
          VStack(spacing: 4) {
            ForEach(items) { task in
              TaskRow(task: task) { store.toggleTaskCompletion(task) }
            }
          }
        }
      }
    }
  }

  private var decisionsSection: some View {
    let items = store.decisions.filter { $0.projectID == liveProject.id }
    return Group {
      if !items.isEmpty {
        VStack(alignment: .leading, spacing: 10) {
          SectionLabel(title: "Decisions")
          VStack(alignment: .leading, spacing: 10) {
            ForEach(items) { decision in
              Text(decision.text)
                .font(.body)
                .foregroundStyle(.primary)
            }
          }
        }
      }
    }
  }

  private var blockersSection: some View {
    Group {
      if liveProject.status == .blocked, let next = liveProject.nextAction {
        VStack(alignment: .leading, spacing: 10) {
          SectionLabel(title: "Blockers")
          Text(next)
            .font(.body)
            .foregroundStyle(.primary)
        }
      }
    }
  }

  private var findingsSection: some View {
    let items = store.findings.filter { $0.projectID == liveProject.id }
    return Group {
      if !items.isEmpty {
        VStack(alignment: .leading, spacing: 10) {
          SectionLabel(title: "Operational Findings")
          VStack(spacing: 4) {
            ForEach(items) { finding in
              FindingRow(finding: finding)
            }
          }
        }
      }
    }
  }

  private var recentUpdatesSection: some View {
    let items = store.activity(forProject: liveProject.id)
    return Group {
      if !items.isEmpty {
        VStack(alignment: .leading, spacing: 10) {
          SectionLabel(title: "Recent Updates")
          VStack(alignment: .leading, spacing: 12) {
            ForEach(items) { event in
              VStack(alignment: .leading, spacing: 2) {
                Text(DueDateFormatting.activityDayLabel(for: event.date))
                  .font(.footnote.weight(.semibold))
                  .foregroundStyle(.secondary)
                Text(event.text)
                  .font(.body)
                  .foregroundStyle(.primary)
              }
            }
          }
        }
      }
    }
  }

  private var actionsRow: some View {
    VStack(spacing: 10) {
      Button {
        quickCapture.present(clientID: liveProject.clientID, projectID: liveProject.id, stage: .note)
      } label: {
        Label("Add Update", systemImage: "text.badge.plus")
          .frame(maxWidth: .infinity)
      }
      .buttonStyle(.bordered)

      HStack(spacing: 10) {
        Button {
          quickCapture.present(clientID: liveProject.clientID, projectID: liveProject.id, stage: .task)
        } label: {
          Label("Add Task", systemImage: "checklist")
            .frame(maxWidth: .infinity)
        }
        Button {
          quickCapture.present(clientID: liveProject.clientID, projectID: liveProject.id, stage: .decision)
        } label: {
          Label("Log Decision", systemImage: "checkmark.seal")
            .frame(maxWidth: .infinity)
        }
      }
      .buttonStyle(.bordered)

      Button {
        quickCapture.present(clientID: liveProject.clientID, projectID: liveProject.id, stage: .finding)
      } label: {
        Label("Add Finding", systemImage: "eye")
          .frame(maxWidth: .infinity)
      }
      .buttonStyle(.bordered)
    }
    .padding(.top, 8)
  }
}
