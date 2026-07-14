import SwiftUI

/// The free-tier lock per components.md: never a padlock on gray. The real rows
/// stay visibly alive underneath (blurred); this is the centered invitation on top.
struct LockedInsightsOverlay: View {
    var onUnlock: () -> Void

    var body: some View {
        VStack(spacing: DD.Spacing.cardGap) {
            Text("The rest of your story is waiting.")
                .font(DD.Fonts.headline)
                .foregroundStyle(DD.Colors.textPrimary)
                .multilineTextAlignment(.center)

            Button(action: onUnlock) {
                Text("Unlock all insights")
                    .font(DD.Fonts.headline)
                    .padding(.horizontal, DD.Spacing.gutter)
                    .frame(height: 48)
            }
            .buttonStyle(DDPillButtonStyle(variant: .primary))
            .fixedSize()
        }
        .padding(DD.Spacing.gutter)
    }
}
