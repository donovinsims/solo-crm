import SwiftUI

struct TodayView: View {
  @Environment(AppStore.self) private var store
  @Environment(QuickCaptureState.self) private var quickCapture
  @State private var selectedClient: Client?
  @State private var selectedProject: ClientProject?
  @State private var isLoading = false

  private var dateString: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEEE, MMMM d"
    return formatter.string(from: .now)
  }

  private var focusItems: [FocusItem] {
    var items: [FocusItem] = []
    for task in store.openTasksToday where !task.isCompleted {
      guard let client = store.client(task.clientID) else { continue }
      items.append(FocusItem(client: client, project: store.project(task.projectID), detail: task.title, trailing: "Due today", trailingTint: .accent, systemImage: "checklist"))
    }
    for task in store.waitingTasks {
      guard let client = store.client(task.clientID) else { continue }
      items.append(FocusItem(client: client, project: store.project(task.projectID), detail: task.title, trailing: DueDateFormatting.waitingLabel(since: task.createdAt), trailingTint: .amber, systemImage: "hourglass"))
    }
    for project in store.projectsWithBalances {
      guard let client = store.client(project.clientID) else { continue }
      items.append(FocusItem(client: client, project: project, detail: project.name, trailing: "$\(Int(project.remaining)) outstanding", trailingTint: .red, systemImage: "dollarsign.circle"))
    }
    return items
  }

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 28) {
          header

          if isLoading {
            VStack(spacing: 12) {
              ForEach(0..<3, id: \.self) { _ in
                SkeletonCard()
              }
            }
            .padding(.horizontal, 20)
          } else {
            if !focusItems.isEmpty {
              focusSection
            } else {
              InlineEmptyState(systemImage: "checklist", message: "All caught up — nothing needs you right now")
                .padding(.horizontal, 20)
            }

            activeWorkSection
            waitingSection
            moneySection
            recentSection
          }
        }
        .padding(.top, 8)
        .padding(.bottom, 24)
      }
      .background(Color(.systemGroupedBackground))
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text("Today").font(.headline)
        }
        ToolbarItem(placement: .topBarTrailing) {
          Button {
            quickCapture.present()
          } label: {
            Image(systemName: "plus")
          }
          .accessibilityLabel("Capture new item")
        }
      }
      .navigationDestination(item: $selectedClient) { client in
        ClientDetailView(client: client)
      }
      .navigationDestination(item: $selectedProject) { project in
        ProjectDetailView(project: project)
      }
      .task {
        isLoading = true
        try? await Task.sleep(for: .milliseconds(300))
        isLoading = false
      }
    }
  }

  private var header: some View {
    VStack(alignment: .leading, spacing: 6) {
      Text(dateString)
        .font(.subheadline)
        .foregroundStyle(.secondary)
      Text("Good morning, Donovin")
        .font(.largeTitle.weight(.bold))
      if !focusItems.isEmpty {
        Text("\(focusItems.count) things need you")
          .font(.title3)
          .foregroundStyle(.secondary)
      }
    }
    .padding(.horizontal, 20)
    .accessibilityElement(children: .combine)
    .accessibilityLabel("Today, \(dateString). \(focusItems.isEmpty ? "All caught up." : "\(focusItems.count) items need attention.")")
  }

  private var focusSection: some View {
    VStack(alignment: .leading, spacing: 0) {
      HStack {
        SectionLabel(title: "Needs You")
        Spacer()
        Text("\(focusItems.count)")
          .font(.footnote.weight(.semibold))
          .foregroundStyle(.secondary)
      }
      .padding(.horizontal, 20)

      ForEach(Array(focusItems.enumerated()), id: \.offset) { index, item in
        Button {
          if let project = item.project {
            selectedProject = project
          } else {
            selectedClient = item.client
          }
        } label: {
          HStack(alignment: .top, spacing: 12) {
            Image(systemName: item.systemImage)
              .font(.body.weight(.semibold))
              .foregroundStyle(item.trailingTint.color)
              .frame(width: 28, height: 44, alignment: .top)
              .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 5) {
              Text(item.client.name)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .lineLimit(1)
              Text(item.detail)
                .font(.body.weight(.medium))
                .foregroundStyle(.primary)
                .lineLimit(2)
              Text(item.trailing)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(item.trailingTint.color)
            }

            Spacer(minLength: 8)

            Image(systemName: "chevron.right")
              .font(.footnote.weight(.semibold))
              .foregroundStyle(.secondary)
              .accessibilityHidden(true)
          }
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.vertical, 14)
          .padding(.horizontal, 20)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.client.name). \(item.detail). \(item.trailing)")
        .accessibilityHint("Opens detail")

        if index < focusItems.count - 1 {
          Divider()
            .padding(.leading, 60)
        }
      }
    }
  }

  private var activeWorkSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        SectionLabel(title: "Active Work")
        Spacer()
        Text("\(store.activeProjects.count)")
          .font(.footnote.weight(.semibold))
          .foregroundStyle(.secondary)
      }
      .padding(.horizontal, 20)

      VStack(alignment: .leading, spacing: 10) {
        if store.activeProjects.isEmpty {
          InlineEmptyState(systemImage: "square.stack.3d.up", message: "No active projects — add one from a client")
            .padding(.horizontal, 20)
        } else {
          ForEach(store.activeProjects) { project in
            Button {
              selectedProject = project
            } label: {
              HStack(spacing: 10) {
                StatusDot(tint: project.status.tint, label: project.status.rawValue)
                VStack(alignment: .leading, spacing: 2) {
                  Text(store.client(project.clientID)?.name ?? "")
                    .font(.body.weight(.medium))
                    .foregroundStyle(.primary)
                  Text("\(project.name) · \(project.phase)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                }
                Spacer()
                Image(systemName: "chevron.right")
                  .font(.footnote.weight(.semibold))
                  .foregroundStyle(.tertiary)
                  .accessibilityHidden(true)
              }
              .frame(minHeight: 44)
              .padding(.horizontal, 20)
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(store.client(project.clientID)?.name ?? "Unknown client"). \(project.name). \(project.phase). Status: \(project.status.rawValue)")
          }
        }
      }
    }
  }

  private var waitingSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      SectionLabel(title: "Waiting")
        .padding(.horizontal, 20)

      let waitingCount = store.waitingTasks.count
      let blockedCount = store.blockedProjects.count

      if waitingCount == 0 && blockedCount == 0 {
        InlineEmptyState(systemImage: "hourglass", message: "Nothing waiting on clients")
          .padding(.horizontal, 20)
      } else {
        VStack(alignment: .leading, spacing: 6) {
          if waitingCount > 0 {
            Label("\(waitingCount) waiting on client\(waitingCount == 1 ? "" : "s")", systemImage: "hourglass")
              .foregroundStyle(.primary)
              .font(.body)
          }
          if blockedCount > 0 {
            Label("\(blockedCount) blocked project\(blockedCount == 1 ? "" : "s")", systemImage: "exclamationmark.triangle")
              .foregroundStyle(.primary)
              .font(.body)
          }
        }
        .padding(.horizontal, 20)
      }
    }
  }

  private var moneySection: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        SectionLabel(title: "Money")
        Spacer()
        NavigationLink {
          MoneyView()
        } label: {
          Image(systemName: "chevron.right")
            .font(.footnote.weight(.semibold))
            .foregroundStyle(.tertiary)
            .frame(width: 44, height: 44)
        }
        .accessibilityLabel("View money details")
      }
      .padding(.horizontal, 20)

      HStack {
        Label("Outstanding", systemImage: "dollarsign.circle")
          .accessibilityLabel("Outstanding balance")
        Spacer()
        Text("$\(Int(store.outstandingBalance))")
          .font(.body.weight(.semibold))
      }
      .foregroundStyle(.primary)
      .padding(.horizontal, 20)
    }
  }

  private var recentSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      SectionLabel(title: "Recent")
        .padding(.horizontal, 20)

      if store.recentClients.isEmpty {
        InlineEmptyState(systemImage: "clock.arrow.circlepath", message: "No recent clients")
          .padding(.horizontal, 20)
      } else {
        ScrollView(.horizontal, showsIndicators: false) {
          HStack(spacing: 10) {
            ForEach(store.recentClients) { client in
              Button {
                selectedClient = client
              } label: {
                HStack(spacing: 8) {
                  Text(initials(for: client))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tint)
                    .frame(width: 28, height: 28)
                    .background(Color.accentColor.opacity(0.14), in: Circle())
                    .accessibilityHidden(true)
                  Text(client.name)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.primary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 14))
              }
              .buttonStyle(.plain)
              .accessibilityElement(children: .combine)
              .accessibilityLabel("\(client.name). Recent client.")
            }
          }
          .padding(.horizontal, 20)
        }
      }
    }
  }

  private func initials(for client: Client) -> String {
    let letters = client.name.split(separator: " ").prefix(2).compactMap { $0.first }
    return String(letters).uppercased()
  }
}

private struct FocusItem {
  var client: Client
  var project: ClientProject?
  var detail: String
  var trailing: String
  var trailingTint: SemanticTint
  var systemImage: String
}
