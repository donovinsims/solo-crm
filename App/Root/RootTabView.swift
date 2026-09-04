import SwiftUI

struct RootTabView: View {
  @State private var store = AppStore()
  @State private var quickCapture = QuickCaptureState()
  @State private var selectedTab: RootTab = .today
  @State private var searchPresented = false

  var body: some View {
    ZStack(alignment: .bottom) {
      Group {
        switch selectedTab {
        case .today: TodayView()
        case .clients: ClientsListView()
        case .work: WorkView()
        case .more: MoreView(searchPresented: $searchPresented)
        }
      }
      .safeAreaInset(edge: .bottom, spacing: 0) {
        Color.clear.frame(height: 54)
      }

      RootTabBar(selectedTab: $selectedTab) {
        quickCapture.present()
      }
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
  }
}

private struct RootTabBar: View {
  @Binding var selectedTab: RootTab
  var onCapture: () -> Void

  private let sideTabs: [RootTab] = [.today, .clients]
  private let trailingTabs: [RootTab] = [.work, .more]

  var body: some View {
    HStack(spacing: 0) {
      ForEach(sideTabs, id: \.self) { tab in
        tabButton(tab)
      }

      Button(action: onCapture) {
        ZStack {
          Circle()
            .fill(Color.accentColor)
            .frame(width: 46, height: 46)
          Image(systemName: "plus")
            .font(.system(size: 19, weight: .semibold))
            .foregroundStyle(.white)
        }
        .shadow(color: .accentColor.opacity(0.35), radius: 8, y: 3)
      }
      .accessibilityLabel("Quick Capture")
      .frame(maxWidth: .infinity)
      .offset(y: -10)

      ForEach(trailingTabs, id: \.self) { tab in
        tabButton(tab)
      }
    }
    .padding(.horizontal, 4)
    .padding(.top, 8)
    .padding(.bottom, 0)
    .frame(height: 54)
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
      .frame(maxWidth: .infinity)
    }
    .accessibilityLabel(tab.rawValue)
  }
}
