import Foundation
import SwiftData

@Observable
@MainActor
final class AppStore {
  static let shared = AppStore()

  var clients: [Client] = []
  var contacts: [ContactPerson] = []
  var projects: [ClientProject] = []
  var tasks: [TaskItem] = []
  var findings: [Finding] = []
  var decisions: [Decision] = []
  var payments: [PaymentRecord] = []
  var activity: [ActivityEvent] = []
  var notes: [Note] = []

  private let modelContext: ModelContext

  private init(container: ModelContainer = Persistence.sharedContainer) {
    self.modelContext = ModelContext(container)
    self.modelContext.autosaveEnabled = true
    seedIfNeeded()
    refresh()
  }

  // MARK: - Persistence

  func refresh() {
    clients = (try? modelContext.fetch(FetchDescriptor<Client>(sortBy: [SortDescriptor(\.name)]))) ?? []
    contacts = (try? modelContext.fetch(FetchDescriptor<ContactPerson>(sortBy: [SortDescriptor(\.name)]))) ?? []
    projects = (try? modelContext.fetch(FetchDescriptor<ClientProject>(sortBy: [SortDescriptor(\.name)]))) ?? []
    tasks = (try? modelContext.fetch(FetchDescriptor<TaskItem>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)]))) ?? []
    findings = (try? modelContext.fetch(FetchDescriptor<Finding>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)]))) ?? []
    decisions = (try? modelContext.fetch(FetchDescriptor<Decision>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)]))) ?? []
    payments = (try? modelContext.fetch(FetchDescriptor<PaymentRecord>(sortBy: [SortDescriptor(\.date, order: .reverse)]))) ?? []
    activity = (try? modelContext.fetch(FetchDescriptor<ActivityEvent>(sortBy: [SortDescriptor(\.date, order: .reverse)]))) ?? []
    notes = (try? modelContext.fetch(FetchDescriptor<Note>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)]))) ?? []
  }

  @discardableResult
  private func save() -> Bool {
    do {
      try modelContext.save()
      refresh()
      return true
    } catch {
      print("Relay save failed: \(error)")
      refresh()
      return false
    }
  }

  private func seedIfNeeded() {
    let existing = (try? modelContext.fetchCount(FetchDescriptor<Client>())) ?? 0
    guard existing == 0 else { return }

    let pietro = Client(name: "Pietro's Pizzeria", city: "Roscoe", state: "IL", phone: "(815) 555-0142", email: "pietro@pietrospizza.com")
    let abc = Client(name: "ABC Roofing", city: "Rockford", state: "IL", phone: "(815) 555-0198", email: "office@abcroofing.com")
    let rockfordAuto = Client(name: "Rockford Auto Care", city: "Rockford", state: "IL", phone: "(815) 555-0176", email: "service@rockfordauto.com")
    let maple = Client(name: "Maple Street Dental", city: "Belvidere", state: "IL", phone: "(815) 555-0133", email: "hello@maplestreetdental.com")

    for client in [pietro, abc, rockfordAuto, maple] {
      modelContext.insert(client)
    }

    let tony = ContactPerson(client: pietro, name: "Tony Pietro", role: "Owner", phone: "(815) 555-0142", email: "tony@pietrospizza.com")
    let dana = ContactPerson(client: abc, name: "Dana Ruiz", role: "Office Manager", phone: "(815) 555-0198", email: "dana@abcroofing.com")
    modelContext.insert(tony)
    modelContext.insert(dana)

    let toast = ProjectLink(title: "Toast", systemImage: "storefront", urlString: "https://toasttab.com")
    let pietroSite = ProjectLink(title: "Website", systemImage: "globe", urlString: "https://pietrospizza.com")
    let github = ProjectLink(title: "GitHub", systemImage: "chevron.left.forwardslash.chevron.right", urlString: "https://github.com")
    let vercel = ProjectLink(title: "Vercel", systemImage: "triangle", urlString: "https://vercel.com")
    let abcSite = ProjectLink(title: "Website", systemImage: "globe", urlString: "https://abcroofing.com")
    for link in [toast, pietroSite, github, vercel, abcSite] {
      modelContext.insert(link)
    }

    let pietroProject = ClientProject(
      client: pietro,
      name: "Online Ordering + Website",
      phase: "Toast Online Ordering",
      status: .inProgress,
      nextAction: "Complete checkout test",
      projectValue: 2000,
      paidAmount: 1000,
      links: [toast, pietroSite, github, vercel]
    )
    let abcProject = ClientProject(
      client: abc,
      name: "Website Redesign",
      phase: "Design Review",
      status: .waitingOnClient,
      nextAction: "Waiting on launch approval",
      projectValue: 1400,
      paidAmount: 1400,
      links: [abcSite]
    )
    let mapleProject = ClientProject(
      client: maple,
      name: "Scheduling Automation",
      phase: "Requirements",
      status: .blocked,
      nextAction: "Waiting on staff availability list",
      projectValue: 900,
      paidAmount: 0,
      links: []
    )
    for project in [pietroProject, abcProject, mapleProject] {
      modelContext.insert(project)
    }

    let seedTasks: [TaskItem] = [
      TaskItem(title: "Finish Toast checkout testing", client: pietro, project: pietroProject, dueDate: .now),
      TaskItem(title: "Confirm modifier groups", client: pietro, project: pietroProject, dueDate: .now),
      TaskItem(title: "Review sitemap draft", client: abc, project: abcProject, dueDate: Date.now.addingTimeInterval(86400)),
      TaskItem(title: "Website launch approval", client: abc, project: abcProject, dueDate: nil, isWaitingOnClient: true, isCompleted: false),
      TaskItem(title: "Staff availability list", client: maple, project: mapleProject, dueDate: nil, isWaitingOnClient: true),
      TaskItem(title: "Send invoice reminder", client: rockfordAuto, project: nil, dueDate: Date.now.addingTimeInterval(2 * 86400)),
      TaskItem(title: "Homepage approved", client: pietro, project: pietroProject, dueDate: nil, isWaitingOnClient: false, isCompleted: true),
    ]
    // Fix createdAt for waiting/completed samples after init
    seedTasks[3].createdAt = Date.now.addingTimeInterval(-3 * 86400)
    seedTasks[6].createdAt = Date.now.addingTimeInterval(-4 * 86400)
    for task in seedTasks {
      modelContext.insert(task)
    }

    let seedFindings = [
      Finding(client: pietro, project: pietroProject, text: "They are manually answering the same customer questions repeatedly.", category: .customerExperience, impact: .high, status: .new),
      Finding(client: pietro, project: pietroProject, text: "No automated way to notify kitchen of large catering orders.", category: .operations, impact: .medium, status: .investigating),
      Finding(client: pietro, project: pietroProject, text: "Modifier pricing is inconsistent between dine-in and online menus.", category: .ordering, impact: .medium, status: .new),
      Finding(client: abc, project: abcProject, text: "Leads submitted after hours don't get a response until the next afternoon.", category: .leadHandling, impact: .high, status: .discussed),
      Finding(client: maple, project: nil, text: "Appointment reminders are sent manually via text each morning.", category: .scheduling, impact: .medium, status: .new),
    ]
    for finding in seedFindings {
      modelContext.insert(finding)
    }

    modelContext.insert(Decision(client: pietro, project: pietroProject, text: "Online ordering must be completed before launching the website."))
    modelContext.insert(Decision(client: abc, project: abcProject, text: "Launch will wait for owner sign-off on homepage copy."))

    modelContext.insert(PaymentRecord(client: pietro, project: pietroProject, amount: 1000, method: .ach, date: Date.now.addingTimeInterval(-14 * 86400)))
    modelContext.insert(PaymentRecord(client: abc, project: abcProject, amount: 1400, method: .check, date: Date.now.addingTimeInterval(-30 * 86400)))

    modelContext.insert(ActivityEvent(client: pietro, project: pietroProject, text: "Checkout configuration updated", date: .now))
    modelContext.insert(ActivityEvent(client: pietro, project: pietroProject, text: "Website deployed", date: Date.now.addingTimeInterval(-86400)))
    modelContext.insert(ActivityEvent(client: pietro, project: pietroProject, text: "Homepage approved", date: Date.now.addingTimeInterval(-4 * 86400)))
    modelContext.insert(ActivityEvent(client: abc, project: abcProject, text: "Design review sent to client", date: Date.now.addingTimeInterval(-3 * 86400)))

    save()
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
    projects.filter { $0.client?.id == clientID }
  }

  func tasks(for clientID: Client.ID) -> [TaskItem] {
    tasks.filter { $0.client?.id == clientID }
  }

  func tasks(forProject projectID: ClientProject.ID) -> [TaskItem] {
    tasks.filter { $0.project?.id == projectID }
  }

  func findings(for clientID: Client.ID) -> [Finding] {
    findings.filter { $0.client?.id == clientID }
  }

  func decisions(for clientID: Client.ID) -> [Decision] {
    decisions.filter { $0.client?.id == clientID }
  }

  func activity(for clientID: Client.ID) -> [ActivityEvent] {
    activity.filter { $0.client?.id == clientID }.sorted { $0.date > $1.date }
  }

  func activity(forProject projectID: ClientProject.ID) -> [ActivityEvent] {
    activity.filter { $0.project?.id == projectID }.sorted { $0.date > $1.date }
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
    client.lastAccessed = .now
    save()
  }

  func toggleTaskCompletion(_ task: TaskItem) {
    task.isCompleted.toggle()
    save()
  }

  func snoozeTask(_ task: TaskItem, to date: Date) {
    task.dueDate = date
    save()
  }

  func markTaskWaiting(_ task: TaskItem) {
    task.isWaitingOnClient = true
    save()
  }

  func addTask(title: String, clientID: Client.ID?, projectID: ClientProject.ID?, dueDate: Date?) {
    let task = TaskItem(
      title: title,
      client: client(clientID),
      project: project(projectID),
      dueDate: dueDate
    )
    modelContext.insert(task)
    save()
  }

  func addNote(text: String, clientID: Client.ID?) {
    let matchedClient = client(clientID)
    let note = Note(client: matchedClient, text: text)
    modelContext.insert(note)
    if let matchedClient {
      modelContext.insert(ActivityEvent(client: matchedClient, project: nil, text: text))
    }
    save()
  }

  func addFinding(text: String, clientID: Client.ID, projectID: ClientProject.ID?, category: FindingCategory, impact: FindingImpact) {
    guard let matchedClient = client(clientID) else { return }
    let finding = Finding(
      client: matchedClient,
      project: project(projectID),
      text: text,
      category: category,
      impact: impact
    )
    modelContext.insert(finding)
    save()
  }

  func addDecision(text: String, clientID: Client.ID, projectID: ClientProject.ID?) {
    guard let matchedClient = client(clientID) else { return }
    let matchedProject = project(projectID)
    modelContext.insert(Decision(client: matchedClient, project: matchedProject, text: text))
    modelContext.insert(ActivityEvent(client: matchedClient, project: matchedProject, text: "Decision: \(text)"))
    save()
  }

  func recordPayment(clientID: Client.ID, projectID: ClientProject.ID, amount: Double, method: PaymentMethod) {
    guard let matchedClient = client(clientID), let matchedProject = project(projectID) else { return }
    modelContext.insert(PaymentRecord(client: matchedClient, project: matchedProject, amount: amount, method: method))
    matchedProject.paidAmount += amount
    modelContext.insert(ActivityEvent(client: matchedClient, project: matchedProject, text: "Payment received: $\(Int(amount))"))
    save()
  }

  func addContact(name: String, role: String, phone: String, email: String, clientID: Client.ID?) {
    guard let clientID, let matchedClient = client(clientID) else { return }
    modelContext.insert(ContactPerson(client: matchedClient, name: name, role: role, phone: phone, email: email))
    save()
  }

  func updateProjectStatus(_ project: ClientProject, to status: ProjectStatus) {
    project.status = status
    if let matchedClient = project.client {
      modelContext.insert(ActivityEvent(client: matchedClient, project: project, text: "Status changed to \(status.rawValue)"))
    }
    save()
  }

  @discardableResult
  func promoteFindingToProject(_ finding: Finding, name: String, phase: String) -> ClientProject? {
    guard let matchedClient = finding.client else { return nil }
    let project = ClientProject(
      client: matchedClient,
      name: name,
      phase: phase,
      status: .inProgress,
      nextAction: "Scope automation",
      projectValue: 0,
      paidAmount: 0
    )
    modelContext.insert(project)
    finding.project = project
    finding.status = .investigating
    modelContext.insert(ActivityEvent(
      client: matchedClient,
      project: project,
      text: "Promoted finding to project: \(name)"
    ))
    modelContext.insert(Decision(
      client: matchedClient,
      project: project,
      text: "Automation opportunity identified from: \(finding.text)"
    ))
    save()
    return project
  }
}
