enum RootTab: String, CaseIterable {
  case today = "Today"
  case clients = "Clients"
  case work = "Work"
  case more = "More"

  var systemImage: String {
    switch self {
    case .today: "sun.max.fill"
    case .clients: "person.2.fill"
    case .work: "square.stack.3d.up.fill"
    case .more: "ellipsis.circle.fill"
    }
  }
}
