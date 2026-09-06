import SwiftUI

struct MoneyView: View {
  @Environment(AppStore.self) private var store
  @Environment(QuickCaptureState.self) private var quickCapture
  @State private var selectedProject: ClientProject?
  @State private var isLoading = false

  var body: some View {
    List {
      Section {
        VStack(alignment: .leading, spacing: 4) {
          Text("Outstanding")
            .font(.subheadline)
            .foregroundStyle(.secondary)
          Text("$\(Int(store.outstandingBalance))")
            .font(.system(size: 40, weight: .bold))
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Outstanding balance: $\(Int(store.outstandingBalance))")

        HStack {
          Text("Collected this month")
            .foregroundStyle(.secondary)
          Spacer()
          Text("$\(Int(store.collectedThisMonth))")
            .font(.body.weight(.semibold))
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Collected this month: $\(Int(store.collectedThisMonth))")
      }

      if isLoading {
        Section("Balances") {
          ForEach(0..<3, id: \.self) { _ in
            SkeletonRow()
          }
        }
      } else {
        Section("Balances") {
          let projectsWithBalances = store.projectsWithBalances
          if projectsWithBalances.isEmpty {
            EmptyStateView(
              systemImage: "dollarsign.circle",
              title: "All Caught Up",
              message: "All caught up — no outstanding balances",
              actionTitle: nil,
              action: nil
            )
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 24, leading: 0, bottom: 24, trailing: 0))
          } else {
            ForEach(projectsWithBalances) { project in
              Button {
                selectedProject = project
              } label: {
                HStack {
                  VStack(alignment: .leading, spacing: 2) {
                    Text(store.client(project.clientID)?.name ?? "")
                      .foregroundStyle(.primary)
                    Text(project.name)
                      .font(.subheadline)
                      .foregroundStyle(.secondary)
                  }
                  Spacer()
                  Text("$\(Int(project.remaining))")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.red)
                }
              }
              .buttonStyle(.plain)
              .accessibilityElement(children: .combine)
              .accessibilityLabel("\(store.client(project.clientID)?.name ?? "Unknown client"). \(project.name). $\(Int(project.remaining)) remaining")
            }
          }
        }
      }
    }
    .navigationTitle("Money")
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Button {
          quickCapture.present(stage: .payment)
        } label: {
          Image(systemName: "plus")
        }
        .accessibilityLabel("Record payment")
      }
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
