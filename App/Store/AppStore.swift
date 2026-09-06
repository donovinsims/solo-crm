import Foundation

@Observable
final class AppStore {
  var clients: [Client]
  var contacts: [ContactPerson]
  var projects: [ClientProject]
  var tasks: [TaskItem]
  var findings: [Finding]
  var decisions: [Decision]
  var payments: [PaymentRecord]
  var activity: [ActivityEvent]
  var notes: [Note]

  init() {
    let pietro = Client(name: "Pietro's Pizzeria", city: "Roscoe", state: "IL", phone: "(815) 555-0142", email: "pietro@pietrospizza.com")
    let abc = Client(name: "ABC Roofing", city: "Rockford", state: "IL", phone: "(815) 555-0198", email: "office@abcroofing.com")
    let rockfordAuto = Client(name: "Rockford Auto Care", city: "Rockford", state: "IL", phone: "(815) 555-0176", email: "service@rockfordauto.com")
    let maple = Client(name: "Maple Street Dental", city: "Belvidere", state: "IL", phone: "(815) 555-0133", email: "hello@maplestreetdental.com")

    clients = [pietro, abc, rockfordAuto, maple]

    contacts = [
      ContactPerson(clientID: pietro.id, name: "Tony Pietro", role: "Owner", phone: "(815) 555-0142", email: "tony@pietrospizza.com"),
      ContactPerson(clientID: abc.id, name: "Dana Ruiz", role: "Office Manager", phone: "(815) 555-0198", email: "dana@abcroofing.com"),
    ]

    let pietroProject = ClientProject(
      clientID: pietro.id,
      name: "Online Ordering + Website",
      phase: "Toast Online Ordering",
      status: .inProgress,
      nextAction: "Complete checkout test",
      projectValue: 2000,
      paidAmount: 1000,
      links: [
        ProjectLink(title: "Toast", systemImage: "storefront", urlString: "https://toasttab.com"),
        ProjectLink(title: "Website", systemImage: "globe", urlString: "https://pietrospizza.com"),
        ProjectLink(title: "GitHub", systemImage: "chevron.left.forwardslash.chevron.right", urlString: "https://github.com"),
        ProjectLink(title: "Vercel", systemImage: "triangle", urlString: "https://vercel.com"),
      ]
    )

    let abcProject = ClientProject(
      clientID: abc.id,
      name: "Website Redesign",
      phase: "Design Review",
      status: .waitingOnClient,
      nextAction: "Waiting on launch approval",
      projectValue: 1400,
      paidAmount: 1400,
      links: [
        ProjectLink(title: "Website", systemImage: "globe", urlString: "https://abcroofing.com"),
      ]
    )

    let mapleProject = ClientProject(
      clientID: maple.id,
      name: "Scheduling Automation",
      phase: "Requirements",
      status: .blocked,
      nextAction: "Waiting on staff availability list",
      projectValue: 900,
      paidAmount: 0,
      links: []
    )

    projects = [pietroProject, abcProject, mapleProject]

    tasks = [
      TaskItem(title: "Finish Toast checkout testing", clientID: pietro.id, projectID: pietroProject.id, dueDate: .now),
      TaskItem(title: "Confirm modifier groups", clientID: pietro.id, projectID: pietroProject.id, dueDate: .now),
      TaskItem(title: "Review sitemap draft", clientID: abc.id, projectID: abcProject.id, dueDate: Date.now.addingTimeInterval(86400)),
      TaskItem(title: "Website launch approval", clientID: abc.id, projectID: abcProject.id, isWaitingOnClient: true, createdAt: Date.now.addingTimeInterval(-3 * 86400)),
      TaskItem(title: "Staff availability list", clientID: maple.id, projectID: mapleProject.id, isWaitingOnClient: true),
      TaskItem(title: "Send invoice reminder", clientID: rockfordAuto.id, dueDate: Date.now.addingTimeInterval(2 * 86400)),
      TaskItem(title: "Homepage approved", clientID: pietro.id, projectID: pietroProject.id, isCompleted: true, createdAt: Date.now.addingTimeInterval(-4 * 86400)),
    ]

    findings = [
      Finding(clientID: pietro.id, projectID: pietroProject.id, text: "They are manually answering the same customer questions repeatedly.", category: .customerExperience, impact: .high, status: .new),
      Finding(clientID: pietro.id, projectID: pietroProject.id, text: "No automated way to notify kitchen of large catering orders.", category: .operations, impact: .medium, status: .investigating),
      Finding(clientID: pietro.id, projectID: pietroProject.id, text: "Modifier pricing is inconsistent between dine-in and online menus.", category: .ordering, impact: .medium, status: .new),
      Finding(clientID: abc.id, projectID: abcProject.id, text: "Leads submitted after hours don't get a response until the next afternoon.", category: .leadHandling, impact: .high, status: .discussed),
      Finding(clientID: maple.id, text: "Appointment reminders are sent manually via text each morning.", category: .scheduling, impact: .medium, status: .new),
    ]

    decisions = [
      Decision(clientID: pietro.id, projectID: pietroProject.id, text: "Online ordering must be completed before launching the website."),
      Decision(clientID: abc.id, projectID: abcProject.id, text: "Launch will wait for owner sign-off on homepage copy."),
    ]

    payments = [
      PaymentRecord(clientID: pietro.id, projectID: pietroProject.id, amount: 1000, method: .ach, date: Date.now.addingTimeInterval(-14 * 86400)),
      PaymentRecord(clientID: abc.id, projectID: abcProject.id, amount: 1400, method: .check, date: Date.now.addingTimeInterval(-30 * 86400)),
    ]

    activity = [
      ActivityEvent(clientID: pietro.id, projectID: pietroProject.id, text: "Checkout configuration updated", date: .now),
      ActivityEvent(clientID: pietro.id, projectID: pietroProject.id, text: "Website deployed", date: Date.now.addingTimeInterval(-86400)),
      ActivityEvent(clientID: pietro.id, projectID: pietroProject.id, text: "Homepage approved", date: Date.now.addingTimeInterval(-4 * 86400)),
      ActivityEvent(clientID: abc.id, projectID: abcProject.id, text: "Design review sent to client", date: Date.now.addingTimeInterval(-3 * 86400)),
    ]

    notes = []
  }

  // MARK: - Lookups

  func client(_ id: Client.ID?) -> Client? {
    guard let id else { return nil }
    return clients.first { $0.id == id }
  }

  func project(_ id: ClientProject.ID?) -> ClientProject? {
    guard let id else { return nil }
    return projects.first { $0.id == id }
  }

  func projects(for clientID: Client.ID) -> [ClientProject] {
    projects.filter { $0.clientID == clientID }
  }

  func tasks(for clientID: Client.ID) -> [TaskItem] {
    tasks.filter { $0.clientID == clientID }
  }

  func tasks(forProject projectID: ClientProject.ID) -> [TaskItem] {
    tasks.filter { $0.projectID == projectID }
  }

  func findings(for clientID: Client.ID) -> [Finding] {
    findings.filter { $0.clientID == clientID }
  }

  func decisions(for clientID: Client.ID) -> [Decision] {
    decisions.filter { $0.clientID == clientID }
  }

  func activity(for clientID: Client.ID) -> [ActivityEvent] {
    activity.filter { $0.clientID == clientID }.sorted { $0.date > $1.date }
  }

  func activity(forProject projectID: ClientProject.ID) -> [ActivityEvent] {
    activity.filter { $0.projectID == projectID }.sorted { $0.date > $1.date }
  }

  func clientStatusLine(_ client: Client) -> String {
    let clientProjects = projects(for: client.id)
    if let waiting = clientProjects.first(where: { $0.status == .waitingOnClient }) {
      return "Waiting on approval · \(waiting.name)"
    }
    if let outstanding = clientProjects.first(where: { $0.remaining > 0 }) {
      return "$\(Int(outstanding.remaining)) remaining"
    }
    if let active = clientProjects.first(where: { $0.status == .inProgress }) {
      return "Active · \(active.phase)"
    }
    if clientProjects.contains(where: { $0.status == .blocked }) {
      return "Blocked"
    }
    return "No active work"
  }

  // MARK: - Aggregates

  var outstandingBalance: Double {
    projects.reduce(0) { $0 + $1.remaining }
  }

  var collectedThisMonth: Double {
    let calendar = Calendar.current
    return payments.filter { calendar.isDate($0.date, equalTo: .now, toGranularity: .month) }
      .reduce(0) { $0 + $1.amount }
  }

  var projectsWithBalances: [ClientProject] {
    projects.filter { $0.remaining > 0 }.sorted { $0.remaining > $1.remaining }
  }

  var openTasksToday: [TaskItem] {
    tasks.filter { !$0.isCompleted && !$0.isWaitingOnClient && ($0.dueDate.map { Calendar.current.isDateInToday($0) } ?? false) }
  }

  var waitingTasks: [TaskItem] {
    tasks.filter { !$0.isCompleted && $0.isWaitingOnClient }
  }

  var blockedProjects: [ClientProject] {
    projects.filter { $0.status == .blocked }
  }

  var activeProjects: [ClientProject] {
    projects.filter { $0.status == .inProgress }
  }

  var recentClients: [Client] {
    clients.sorted { $0.lastAccessed > $1.lastAccessed }
  }

  func daysSince(_ date: Date) -> Int {
    Calendar.current.dateComponents([.day], from: date, to: .now).day ?? 0
  }

  // MARK: - Mutations

  func markVisited(_ client: Client) {
    guard let index = clients.firstIndex(where: { $0.id == client.id }) else { return }
    clients[index].lastAccessed = .now
  }

  func toggleTaskCompletion(_ task: TaskItem) {
    guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
    tasks[index].isCompleted.toggle()
  }

  func snoozeTask(_ task: TaskItem, to date: Date) {
    guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
    tasks[index].dueDate = date
  }

  func markTaskWaiting(_ task: TaskItem) {
    guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
    tasks[index].isWaitingOnClient = true
  }

  func addTask(title: String, clientID: Client.ID?, projectID: ClientProject.ID?, dueDate: Date?) {
    tasks.insert(TaskItem(title: title, clientID: clientID, projectID: projectID, dueDate: dueDate), at: 0)
  }

  func addNote(text: String, clientID: Client.ID?) {
    notes.insert(Note(clientID: clientID, text: text), at: 0)
    if let clientID {
      activity.insert(ActivityEvent(clientID: clientID, text: text), at: 0)
    }
  }

  func addFinding(text: String, clientID: Client.ID, projectID: ClientProject.ID?, category: FindingCategory, impact: FindingImpact) {
    findings.insert(Finding(clientID: clientID, projectID: projectID, text: text, category: category, impact: impact), at: 0)
  }

  func addDecision(text: String, clientID: Client.ID, projectID: ClientProject.ID?) {
    decisions.insert(Decision(clientID: clientID, projectID: projectID, text: text), at: 0)
    activity.insert(ActivityEvent(clientID: clientID, projectID: projectID, text: "Decision: \(text)"), at: 0)
  }

  func recordPayment(clientID: Client.ID, projectID: ClientProject.ID, amount: Double, method: PaymentMethod) {
    payments.insert(PaymentRecord(clientID: clientID, projectID: projectID, amount: amount, method: method), at: 0)
    if let index = projects.firstIndex(where: { $0.id == projectID }) {
      projects[index].paidAmount += amount
    }
    activity.insert(ActivityEvent(clientID: clientID, projectID: projectID, text: "Payment received: $\(Int(amount))"), at: 0)
  }

  func addContact(name: String, role: String, phone: String, email: String, clientID: Client.ID?) {
    guard let clientID else { return }
    contacts.append(ContactPerson(clientID: clientID, name: name, role: role, phone: phone, email: email))
  }

  func updateProjectStatus(_ project: ClientProject, to status: ProjectStatus) {
    guard let index = projects.firstIndex(where: { $0.id == project.id }) else { return }
    projects[index].status = status
    activity.insert(ActivityEvent(clientID: project.clientID, projectID: project.id, text: "Status changed to \(status.rawValue)"), at: 0)
  }

  // MARK: - Finding Promotion

  func promoteFindingToProject(_ finding: Finding, name: String, phase: String) -> ClientProject {
    let project = ClientProject(
      clientID: finding.clientID,
      name: name,
      phase: phase,
      status: .inProgress,
      nextAction: "Scope automation",
      projectValue: 0,
      paidAmount: 0
    )
    projects.insert(project, at: 0)

    // Update finding
    if let idx = findings.firstIndex(where: { $0.id == finding.id }) {
      findings[idx].projectID = project.id
      findings[idx].status = .investigating
    }

    // Activity
    activity.insert(ActivityEvent(
      clientID: finding.clientID,
      projectID: project.id,
      text: "Promoted finding to project: \(name)"
    ), at: 0)

    // Decision
    decisions.insert(Decision(
      clientID: finding.clientID,
      projectID: project.id,
      text: "Automation opportunity identified from: \(finding.text)"
    ), at: 0)

    return project
  }
}
