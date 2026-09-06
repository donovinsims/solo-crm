import SwiftUI
import AppIntents

struct RootTabView: View {
  @State private var store = AppStore()
  @State private var quickCapture = QuickCaptureState()
  @State private var selectedTab: RootTab = .today
  @State private var searchPresented = false
  @State private var captureTrigger = 0
  @State private var deepLinkClientID: UUID?

  var body: some View {
    ZStack(alignment: .bottom) {
      Group {
        switch selectedTab {
        case .today: TodayView()
        case .clients: ClientsListView(deepLinkClientID: $deepLinkClientID)
        case .projects: WorkView()
        case .more: MoreView(searchPresented: $searchPresented)
        }
      }
      .id(selectedTab)
      .safeAreaInset(edge: .bottom, spacing: 0) {
        Color.clear.frame(height: 60)
      }

      RootTabBar(selectedTab: $selectedTab) {
        captureTrigger += 1
        quickCapture.present()
      }
      .sensoryFeedback(.impact(weight: .light, intensity: 0.8), trigger: captureTrigger)
    }
    .environment(store)
    .environment(quickCapture)
    .sheet(isPresented: $quickCapture.isPresented) {
      QuickCaptureSheet()
        .environment(store)
        .environment(quickCapture)
    }
    .sheet(isPresented: $searchPresented) {
      SearchSheet()
        .environment(store)
    }
    .onOpenURL { url in
      handleDeepLink(url)
    }
  }

  private func handleDeepLink(_ url: URL) {
    guard url.scheme == "relay",
          url.host == "open-client",
          let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
          let clientIDString = components.queryItems?.first(where: { $0.name == "id" })?.value,
          let clientID = UUID(uuidString: clientIDString) else { return }

    deepLinkClientID = clientID
    selectedTab = .clients
  }
}

private struct RootTabBar: View {
  @Binding var selectedTab: RootTab
  var onCapture: () -> Void

  private let sideTabs: [RootTab] = [.today, .clients]
  private let trailingTabs: [RootTab] = [.projects, .more]

  var body: some View {
    HStack(spacing: 0) {
      ForEach(sideTabs, id: \.self) { tab in
        tabButton(tab)
      }

      Button(action: onCapture) {
        Image(systemName: "plus")
          .font(.system(size: 18, weight: .semibold))
          .foregroundStyle(.white)
          .frame(width: 44, height: 44)
          .background(Color.accentColor, in: Circle())
      }
      .buttonStyle(.plain)
      .accessibilityLabel("Capture")
      .accessibilityHint("Opens quick capture")
      .frame(maxWidth: .infinity)
      .frame(minHeight: 44)
      .offset(y: -7)

      ForEach(trailingTabs, id: \.self) { tab in
        tabButton(tab)
      }
    }
    .padding(.horizontal, 4)
    .padding(.top, 6)
    .padding(.bottom, 0)
    .frame(minHeight: 60)
    .background {
      Rectangle()
        .fill(.bar)
        .ignoresSafeArea(edges: .bottom)
    }
    .overlay(alignment: .top) {
      Divider()
    }
  }

  private func tabButton(_ tab: RootTab) -> some View {
    Button {
      selectedTab = tab
    } label: {
      VStack(spacing: 3) {
        Image(systemName: tab.systemImage)
          .font(.system(size: 21))
          .symbolVariant(selectedTab == tab ? .fill : .none)
        Text(tab.rawValue)
          .font(.caption2)
      }
      .foregroundStyle(selectedTab == tab ? Color.accentColor : Color.secondary)
      .frame(maxWidth: .infinity, minHeight: 44)
    }
    .accessibilityLabel(tab.rawValue)
    .accessibilityValue(selectedTab == tab ? "Selected" : "")
    .accessibilityHint("Shows \(tab.rawValue)")
  }
}
