import SwiftUI
import UIKit

struct ClientDetailView: View {
  var client: Client
  @Environment(AppStore.self) private var store
  @Environment(QuickCaptureState.self) private var quickCapture
  @State private var actionsPresented = false
  @State private var selectedProject: ClientProject?

  private var project: ClientProject? {
    store.projects(for: client.id).first
  }

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 26) {
        header
        quickActions

        if let project {
          activeProjectSection(project)
        }

        let needsAttention = store.tasks(for: client.id).filter { !$0.isCompleted && !$0.isWaitingOnClient }
        if !needsAttention.isEmpty {
          listSection(title: "Needs Attention", items: needsAttention.map(\.title))
        }

        let waiting = store.tasks(for: client.id).filter { $0.isWaitingOnClient }
        if !waiting.isEmpty {
          listSection(title: "Waiting", items: waiting.map(\.title))
        }

        let clientFindings = store.findings(for: client.id)
        if !clientFindings.isEmpty {
          NavigationLink {
            FindingsView(clientFilter: client)
          } label: {
            HStack {
              VStack(alignment: .leading, spacing: 4) {
                SectionLabel(title: "Findings")
                Text("\(clientFindings.count) operational opportunit\(clientFindings.count == 1 ? "y" : "ies")")
                  .font(.body)
                  .foregroundStyle(.primary)
              }
              Spacer()
              Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.tertiary)
            }
          }
          .buttonStyle(.plain)
        }

        recentActivitySection
      }
      .padding(.horizontal, 20)
      .padding(.top, 8)
      .padding(.bottom, 32)
    }
    .background(Color(.systemGroupedBackground))
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Button {
          actionsPresented = true
        } label: {
          Image(systemName: "ellipsis")
        }
        .accessibilityLabel("More actions")
      }
    }
    .navigationDestination(item: $selectedProject) { project in
      ProjectDetailView(project: project)
    }
    .sheet(isPresented: $actionsPresented) {
      ClientActionsSheet(client: client)
    }
    .onAppear { store.markVisited(client) }
  }

  private var header: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(client.name)
        .font(.largeTitle.weight(.bold))
      Text("\(client.city), \(fullStateName(client.state))")
        .font(.title3)
        .foregroundStyle(.secondary)
    }
  }

  private var quickActions: some View {
    HStack(spacing: 10) {
      actionButton(title: "Call", systemImage: "phone.fill") {
        openURL("tel://\(client.phone.filter(\.isNumber))")
      }
      actionButton(title: "Text", systemImage: "message.fill") {
        openURL("sms://\(client.phone.filter(\.isNumber))")
      }
      actionButton(title: "Email", systemImage: "envelope.fill") {
        openURL("mailto:\(client.email)")
      }
    }
  }

  private func actionButton(title: String, systemImage: String, action: @escaping () -> Void) -> some View {
    Button(action: action) {
      VStack(spacing: 6) {
        Image(systemName: systemImage)
          .font(.system(size: 17))
        Text(title)
          .font(.caption)
      }
      .frame(maxWidth: .infinity)
      .frame(minHeight: 44)
      .padding(.vertical, 8)
      .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 14))
    }
    .buttonStyle(.plain)
    .foregroundStyle(Color.accentColor)
  }

  private func activeProjectSection(_ project: ClientProject) -> some View {
    Button {
      selectedProject = project
    } label: {
      VStack(alignment: .leading, spacing: 14) {
        SectionLabel(title: "Active Project")

        Text(project.name)
          .font(.title3.weight(.semibold))
          .foregroundStyle(.primary)

        VStack(alignment: .leading, spacing: 8) {
          detailLine("Current phase", project.phase)
          HStack(spacing: 6) {
            Text("Status")
              .font(.subheadline)
              .foregroundStyle(.secondary)
            Spacer()
            StatusDot(tint: project.status.tint)
            Text(project.status.rawValue)
              .font(.subheadline.weight(.medium))
              .foregroundStyle(.primary)
          }
          if let nextAction = project.nextAction {
            detailLine("Next action", nextAction)
          }
        }

        Divider()

        HStack {
          moneyStat(title: "Project", value: project.projectValue)
          Spacer()
          moneyStat(title: "Paid", value: project.paidAmount)
          Spacer()
          moneyStat(title: "Remaining", value: project.remaining)
        }

        if !project.links.isEmpty {
          ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
              ForEach(project.links) { link in
                Label(link.title, systemImage: link.systemImage)
                  .font(.subheadline.weight(.medium))
                  .padding(.horizontal, 12)
                  .padding(.vertical, 8)
                  .background(Color(.tertiarySystemGroupedBackground), in: .capsule)
              }
            }
          }
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(16)
      .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 18))
    }
    .buttonStyle(.plain)
  }

  private func detailLine(_ title: String, _ value: String) -> some View {
    HStack {
      Text(title)
        .font(.subheadline)
        .foregroundStyle(.secondary)
      Spacer()
      Text(value)
        .font(.subheadline.weight(.medium))
        .foregroundStyle(.primary)
        .multilineTextAlignment(.trailing)
    }
  }

  private func moneyStat(title: String, value: Double) -> some View {
    VStack(alignment: .leading, spacing: 2) {
      Text(title)
        .font(.caption)
        .foregroundStyle(.secondary)
      Text("$\(Int(value))")
        .font(.body.weight(.semibold))
    }
  }

  private func listSection(title: String, items: [String]) -> some View {
    VStack(alignment: .leading, spacing: 10) {
      SectionLabel(title: title)
      VStack(alignment: .leading, spacing: 8) {
        ForEach(items, id: \.self) { item in
          HStack(alignment: .top, spacing: 8) {
            Text("–")
              .foregroundStyle(.secondary)
            Text(item)
              .foregroundStyle(.primary)
          }
          .font(.body)
        }
      }
    }
  }

  private var recentActivitySection: some View {
    VStack(alignment: .leading, spacing: 12) {
      SectionLabel(title: "Recent Activity")
      VStack(alignment: .leading, spacing: 14) {
        ForEach(store.activity(for: client.id)) { event in
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

  private func openURL(_ string: String) {
    guard let url = URL(string: string) else { return }
    UIApplication.shared.open(url)
  }

  private func fullStateName(_ abbreviation: String) -> String {
    abbreviation == "IL" ? "Illinois" : abbreviation
  }
}
