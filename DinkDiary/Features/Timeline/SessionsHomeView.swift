import SwiftUI

/// Home timeline. M0: the empty state per components.md; the session feed
/// arrives with the data model milestone.
struct SessionsHomeView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                DD.Colors.surface.ignoresSafeArea()

                VStack(spacing: DD.Spacing.cardGap) {
                    KitchenLineMotif(dimmed: true)
                        .frame(width: 120)
                    Text("No games yet.")
                        .font(DD.Fonts.title3)
                        .foregroundStyle(DD.Colors.textPrimary)
                    Text("Go find a fourth.")
                        .font(DD.Fonts.body)
                        .foregroundStyle(DD.Colors.textSecondary)
                }
                .padding(DD.Spacing.gutter)
            }
            .navigationTitle("Your season")
            .toolbarBackground(DD.Colors.surface, for: .navigationBar)
        }
    }
}
