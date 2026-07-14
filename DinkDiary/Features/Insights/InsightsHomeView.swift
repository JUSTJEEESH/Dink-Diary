import SwiftUI

/// Insights. M0: empty state; the real insights arrive with the stats engine.
struct InsightsHomeView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                DD.Colors.surface.ignoresSafeArea()

                VStack(spacing: DD.Spacing.cardGap) {
                    Image(systemName: "chart.bar.fill")
                        .font(Font.system(size: 28, weight: .semibold))
                        .foregroundStyle(DD.Colors.textSecondary)
                    Text("Your story starts after a few games.")
                        .font(DD.Fonts.body)
                        .foregroundStyle(DD.Colors.textSecondary)
                }
                .padding(DD.Spacing.gutter)
            }
            .navigationTitle("Insights")
            .toolbarBackground(DD.Colors.surface, for: .navigationBar)
        }
    }
}
