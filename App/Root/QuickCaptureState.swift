import Foundation

@Observable
final class QuickCaptureState {
  enum Stage {
    case root
    case task
    case note
    case finding
    case decision
    case payment
    case contact
    case voice
    case voiceReview
  }

  var isPresented = false
  var stage: Stage = .root
  var prefilledClientID: Client.ID?
  var prefilledProjectID: ClientProject.ID?
  var voiceTranscript: String = ""

  func present(clientID: Client.ID? = nil, projectID: ClientProject.ID? = nil, stage: Stage = .root) {
    prefilledClientID = clientID
    prefilledProjectID = projectID
    self.stage = stage
    isPresented = true
  }

  func dismiss() {
    isPresented = false
  }
}
