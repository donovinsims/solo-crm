import SwiftUI

struct EmptyStateView: View {
  let systemImage: String
  let title: String
  let message: String
  let actionTitle: String?
  let action: (() -> Void)?

  init(
    systemImage: String,
    title: String,
    message: String,
    actionTitle: String? = nil,
    action: (() -> Void)? = nil
  ) {
    self.systemImage = systemImage
    self.title = title
    self.message = message
    self.actionTitle = actionTitle
    self.action = action
  }

  var body: some View {
    VStack(spacing: 16) {
      Image(systemName: systemImage)
        .font(.system(size: 40))
        .foregroundStyle(.tertiary)
        .accessibilityHidden(true)

      VStack(spacing: 6) {
        Text(title)
          .font(.headline)
          .foregroundStyle(.primary)
          .multilineTextAlignment(.center)
        Text(message)
          .font(.subheadline)
          .foregroundStyle(.secondary)
          .multilineTextAlignment(.center)
      }

      if let actionTitle, let action {
        Button(action: action) {
          Text(actionTitle)
            .font(.body.weight(.semibold))
            .frame(maxWidth: 200, minHeight: 44)
        }
        .buttonStyle(.borderedProminent)
        .accessibilityHint("Tap to \(actionTitle.lowercased())")
      }
    }
    .padding(.horizontal, 32)
    .padding(.vertical, 40)
    .frame(maxWidth: .infinity)
    .accessibilityElement(children: .combine)
    .accessibilityLabel("\(title). \(message)")
  }
}

struct InlineEmptyState: View {
  let systemImage: String
  let message: String

  var body: some View {
    HStack(spacing: 10) {
      Image(systemName: systemImage)
        .font(.subheadline)
        .foregroundStyle(.tertiary)
        .frame(width: 20, height: 20)
      Text(message)
        .font(.subheadline)
        .foregroundStyle(.secondary)
    }
    .padding(.vertical, 12)
    .frame(maxWidth: .infinity, alignment: .leading)
    .accessibilityElement(children: .combine)
    .accessibilityLabel(message)
  }
}

struct SkeletonRow: View {
  let height: CGFloat
  let showAvatar: Bool
  let lineCount: Int

  init(height: CGFloat = 60, showAvatar: Bool = true, lineCount: Int = 2) {
    self.height = height
    self.showAvatar = showAvatar
    self.lineCount = lineCount
  }

  var body: some View {
    HStack(alignment: .top, spacing: 12) {
      if showAvatar {
        Circle()
          .fill(Color(.tertiarySystemFill))
          .frame(width: 40, height: 40)
          .shimmer()
      }

      VStack(alignment: .leading, spacing: 8) {
        RoundedRectangle(cornerRadius: 4)
          .fill(Color(.tertiarySystemFill))
          .frame(width: 120, height: 16)
          .shimmer()

        ForEach(0..<lineCount, id: \.self) { _ in
          RoundedRectangle(cornerRadius: 4)
            .fill(Color(.tertiarySystemFill))
            .frame(height: 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .shimmer()
        }
      }

      Spacer()
    }
    .frame(minHeight: height)
    .padding(.vertical, 4)
    .accessibilityHidden(true)
  }
}

struct SkeletonCard: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      RoundedRectangle(cornerRadius: 4)
        .fill(Color(.tertiarySystemFill))
        .frame(height: 24)
        .frame(maxWidth: 180)
        .shimmer()

      RoundedRectangle(cornerRadius: 4)
        .fill(Color(.tertiarySystemFill))
        .frame(height: 16)
        .frame(maxWidth: .infinity)
        .shimmer()

      RoundedRectangle(cornerRadius: 4)
        .fill(Color(.tertiarySystemFill))
        .frame(height: 16)
        .frame(maxWidth: .infinity)
        .shimmer()
    }
    .padding(16)
    .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 18))
    .accessibilityHidden(true)
  }
}

private struct ShimmerModifier: ViewModifier {
  @State private var phase: CGFloat = 0

  func body(content: Content) -> some View {
    content
      .overlay(
        GeometryReader { geo in
          LinearGradient(
            colors: [
              Color.clear,
              Color.white.opacity(0.4),
              Color.clear
            ],
            startPoint: .leading,
            endPoint: .trailing
          )
          .frame(width: geo.size.width * 0.6)
          .offset(x: phase * geo.size.width * 1.6 - geo.size.width * 0.8)
        }
        .mask(content)
      )
      .onAppear {
        withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
          phase = 1
        }
      }
      .accessibilityHidden(true)
  }
}

extension View {
  func shimmer() -> some View {
    modifier(ShimmerModifier())
  }
}

#Preview("Empty State") {
  EmptyStateView(
    systemImage: "person.crop.circle.badge.plus",
    title: "No Clients Yet",
    message: "Tap + to add your first client and start tracking work.",
    actionTitle: "Add Client",
    action: { print("Add client tapped") }
  )
  .padding()
}

#Preview("Inline Empty") {
  InlineEmptyState(systemImage: "checklist", message: "No tasks — add one to get started")
    .padding()
}

#Preview("Skeleton Row") {
  VStack(spacing: 0) {
    SkeletonRow()
    Divider()
    SkeletonRow()
  }
  .padding()
}

#Preview("Skeleton Card") {
  SkeletonCard()
    .padding()
}