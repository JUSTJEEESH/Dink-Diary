import SwiftUI

/// Streak badge: pill on streak-at-14%, dot plus rounded-bold text in streak.
/// Empty state is a dashed pill inviting the first win.
struct StreakBadge: View {
    /// nil or < 2 shows nothing has started; use `empty` for the invitation state.
    let count: Int

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(DD.Colors.streak)
                .frame(width: 6, height: 6)
            Text("\(count) straight")
                .font(DD.Fonts.statBadge)
                .foregroundStyle(DD.Colors.streak)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(DD.Colors.streak.opacity(0.14), in: Capsule())
    }

    /// Empty state: "First W starts one."
    static var empty: some View {
        Text("First W starts one.")
            .font(DD.Fonts.footnote)
            .foregroundStyle(DD.Colors.textSecondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .overlay(
                Capsule()
                    .strokeBorder(
                        DD.Colors.textSecondary.opacity(0.30),
                        style: StrokeStyle(lineWidth: 1, dash: [4, 3])
                    )
            )
    }
}
