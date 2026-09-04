import Foundation

enum DueDateFormatting {
  static func label(for date: Date?) -> String? {
    guard let date else { return nil }
    let calendar = Calendar.current
    if calendar.isDateInToday(date) { return "Today" }
    if calendar.isDateInTomorrow(date) { return "Tomorrow" }
    if date < .now { return "Overdue" }
    let formatter = DateFormatter()
    formatter.dateFormat = "EEEE"
    return formatter.string(from: date)
  }

  static func waitingLabel(since date: Date) -> String {
    let days = Calendar.current.dateComponents([.day], from: date, to: .now).day ?? 0
    if days <= 0 { return "Today" }
    if days == 1 { return "1 day" }
    return "\(days) days"
  }

  static func activityDayLabel(for date: Date) -> String {
    let calendar = Calendar.current
    if calendar.isDateInToday(date) { return "Today" }
    if calendar.isDateInYesterday(date) { return "Yesterday" }
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM d"
    return formatter.string(from: date)
  }
}
