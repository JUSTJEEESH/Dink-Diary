import SwiftUI

/// Your courts. M0: empty state; auto-detected courts arrive with CoreLocation.
struct CourtsHomeView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                DD.Colors.surface.ignoresSafeArea()

                VStack(spacing: DD.Spacing.cardGap) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(Font.system(size: 28, weight: .semibold))
                        .foregroundStyle(DD.Colors.textSecondary)
                    Text("Courts show up when you play.")
                        .font(DD.Fonts.body)
                        .foregroundStyle(DD.Colors.textSecondary)
                }
                .padding(DD.Spacing.gutter)
            }
            .navigationTitle("Your courts")
            .toolbarBackground(DD.Colors.surface, for: .navigationBar)
        }
    }
}
