import SwiftUI

struct MoneyView: View {
  @Environment(AppStore.self) private var store
  @State private var selectedProject: ClientProject?

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

        HStack {
          Text("Collected this month")
            .foregroundStyle(.secondary)
          Spacer()
          Text("$\(Int(store.collectedThisMonth))")
            .font(.body.weight(.semibold))
        }
      }

      Section("Balances") {
        ForEach(store.projectsWithBalances) { project in
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
        }
      }
    }
    .navigationTitle("Money")
    .navigationDestination(item: $selectedProject) { project in
      ProjectDetailView(project: project)
    }
  }
}
