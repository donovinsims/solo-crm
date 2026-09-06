import SwiftUI

struct ClientDetailView: View {
  var client: Client
  @Environment(AppStore.self) private var store
  @Environment(QuickCaptureState.self) private var quickCapture
  @State private var actionsPresented = false
  @State private var selectedProject: ClientProject?
  @State private var isLoading = false

  private var project: ClientProject? {
    store.projects(for: client.id).first
  }

  private var needsAttentionTasks: [TaskItem] {
    store.tasks(for: client.id).filter { !$0.isCompleted && !$0.isWaitingOnClient }
  }

  private var waitingTasks: [TaskItem] {
    store.tasks(for: client.id).filter { $0.isWaitingOnClient }
  }

  private var clientFindings: [Finding] {
    store.findings(for: client.id)
  }

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 26) {
        header
        quickActions

        if isLoading {
          VStack(spacing: 12) {
            ForEach(0..<3, id: \.self) { _ in
              SkeletonCard()
            }
          }
        } else {
          if let project {
            activeProjectSection(project)
          } else {
            InlineEmptyState(systemImage: "square.stack.3d.up", message: "No active project for this client")
              .padding(.horizontal, 20)
          }

          if !needsAttentionTasks.isEmpty {
            taskSection(title: "Needs Attention", tasks: needsAttentionTasks)
          } else {
            InlineEmptyState(systemImage: "checklist", message: "No tasks needing attention")
              .padding(.horizontal, 20)
          }

          if !waitingTasks.isEmpty {
            taskSection(title: "Waiting", tasks: waitingTasks)
          } else {
            InlineEmptyState(systemImage: "hourglass", message: "Nothing waiting on this client")
              .padding(.horizontal, 20)
          }

          if !clientFindings.isEmpty {
            NavigationLink {
              FindingsView(clientFilter: client)
            } label: {
              HStack {
                VStack(alignment: .leading, spacing: 4) {
                  SectionLabel(title: "Findings")
                  Text("\(clientFindings.count) finding\(clientFindings.count == 1 ? "" : "s")")
                    .font(.body)
                    .foregroundStyle(.primary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                  .font(.footnote.weight(.semibold))
                  .foregroundStyle(.tertiary)
                  .accessibilityHidden(true)
              }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("\(clientFindings.count) findings. Tap to view all.")
            .padding(.horizontal, 20)
          } else {
            InlineEmptyState(systemImage: "eye", message: "No findings captured — tap + from a client to log one")
              .padding(.horizontal, 20)
          }

          recentActivitySection
        }
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
        .accessibilityLabel("More actions for \(client.name)")
      }
    }
    .navigationDestination(item: $selectedProject) { project in
      ProjectDetailView(project: project)
    }
    .sheet(isPresented: $actionsPresented) {
      ClientActionsSheet(client: client)
    }
    .onAppear { store.markVisited(client) }
    .task {
      isLoading = true
      try? await Task.sleep(for: .milliseconds(300))
      isLoading = false
    }
  }

  private var header: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(client.name)
        .font(.largeTitle.weight(.bold))
      Text("\(client.city), \(fullStateName(client.state))")
        .font(.title3)
        .foregroundStyle(.secondary)
    }
    .accessibilityElement(children: .combine)
    .accessibilityLabel("\(client.name). \(client.city), \(fullStateName(client.state))")
  }

  private var quickActions: some View {
    HStack(spacing: 10) {
      actionButton(title: "Call", systemImage: "phone.fill") {
        openURL("tel://\(client.phone.filter(\.isNumber))")
      }
      .accessibilityLabel("Call \(client.name)")

      actionButton(title: "Text", systemImage: "message.fill") {
        openURL("sms://\(client.phone.filter(\.isNumber))")
      }
      .accessibilityLabel("Text \(client.name)")

      actionButton(title: "Email", systemImage: "envelope.fill") {
        openURL("mailto:\(client.email)")
      }
      .accessibilityLabel("Email \(client.name)")
    }
  }

  private func actionButton(title: String, systemImage: String, action: @escaping () -> Void) -> some View {
    Button(action: action) {
      VStack(spacing: 6) {
        Image(systemName: systemImage)
          .font(.system(size: 17))
          .accessibilityHidden(true)
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
    .accessibilityElement(children: .combine)
    .accessibilityLabel(title)
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
            StatusDot(tint: project.status.tint, label: project.status.rawValue)
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
                Button {
                  if let url = URL(string: link.urlString) {
                    UIApplication.shared.open(url)
                  }
                } label: {
                  Label(link.title, systemImage: link.systemImage)
                    .font(.subheadline.weight(.medium))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.tertiarySystemGroupedBackground), in: .capsule)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Open \(link.title)")
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
    .accessibilityElement(children: .combine)
    .accessibilityLabel("Active project: \(project.name). Phase: \(project.phase). Status: \(project.status.rawValue). Value: $\(Int(project.projectValue)). Paid: $\(Int(project.paidAmount)). Remaining: $\(Int(project.remaining))")
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

  private func taskSection(title: String, tasks: [TaskItem]) -> some View {
    VStack(alignment: .leading, spacing: 10) {
      SectionLabel(title: title)
        .padding(.horizontal, 20)
      VStack(spacing: 4) {
        ForEach(tasks) { task in
          TaskRow(task: task) { store.toggleTaskCompletion(task) }
            .padding(.horizontal, 20)
        }
      }
    }
  }

  private var recentActivitySection: some View {
    VStack(alignment: .leading, spacing: 12) {
      SectionLabel(title: "Recent Activity")
        .padding(.horizontal, 20)
      let activity = store.activity(for: client.id)
      if activity.isEmpty {
        InlineEmptyState(systemImage: "clock.arrow.circlepath", message: "No recent activity")
          .padding(.horizontal, 20)
      } else {
        VStack(alignment: .leading, spacing: 14) {
          ForEach(activity) { event in
            VStack(alignment: .leading, spacing: 2) {
              Text(DueDateFormatting.activityDayLabel(for: event.date))
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
              Text(event.text)
                .font(.body)
                .foregroundStyle(.primary)
            }
            .padding(.horizontal, 20)
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
