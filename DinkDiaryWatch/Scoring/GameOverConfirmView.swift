import SwiftUI

/// Game over. Warm, never graded: "That's a W." or "They got that one."
/// The whole screen is one tap target to keep the end-of-game flow fast.
struct GameOverConfirmView: View {
    let didWin: Bool
    let myScore: Int
    let theirScore: Int
    var onContinue: () -> Void

    var body: some View {
        ZStack {
            DD.Colors.watchCanvas.ignoresSafeArea()

            VStack(spacing: DD.Spacing.rowGap) {
                Text(didWin ? "That's a W." : "They got that one.")
                    .font(DD.Fonts.title3)
                    .foregroundStyle(didWin ? DD.Colors.accentWin : DD.Colors.textPrimary)
                    .multilineTextAlignment(.center)

                Text("\(myScore)-\(theirScore)")
                    .font(DD.Fonts.watchConfirm)
                    .foregroundStyle(didWin ? DD.Colors.accentWin : DD.Colors.textPrimary)

                Text("Tap for partner")
                    .font(DD.Fonts.caption)
                    .foregroundStyle(DD.Colors.textSecondary)
            }
            .padding(.horizontal, DD.Spacing.cardGap)
        }
        .contentShape(Rectangle())
        .onTapGesture { onContinue() }
    }
}
