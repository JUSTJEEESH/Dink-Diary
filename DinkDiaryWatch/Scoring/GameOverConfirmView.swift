import SwiftUI

/// Game over, matched to the mock: "GAME" label, the final score big and neutral,
/// a warm one-liner, then Confirm (optic) and Fix score (secondary).
struct GameOverConfirmView: View {
    let didWin: Bool
    let myScore: Int
    let theirScore: Int
    var onConfirm: () -> Void
    var onFix: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: DD.Spacing.rowGap) {
                Text("GAME")
                    .font(DD.Fonts.caption)
                    .tracking(0.5)
                    .foregroundStyle(DD.Colors.accentWin)

                Text("\(myScore)-\(theirScore)")
                    .font(DD.Fonts.watchConfirm)
                    .foregroundStyle(DD.Colors.textPrimary)

                Text(didWin ? "That's a W." : "They got that one.")
                    .font(DD.Fonts.title3)
                    .foregroundStyle(didWin ? DD.Colors.accentWin : DD.Colors.textPrimary)
                    .multilineTextAlignment(.center)

                Button(action: onConfirm) {
                    Text("Confirm")
                        .font(DD.Fonts.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(DDPillButtonStyle(variant: .primary))
                .padding(.top, DD.Spacing.rowGap)

                Button(action: onFix) {
                    Text("Fix score")
                        .font(DD.Fonts.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(DDPillButtonStyle(variant: .secondary))
            }
            .padding(.horizontal, DD.Spacing.rowGap)
            .padding(.vertical, DD.Spacing.cardGap)
        }
        .background(DD.Colors.watchCanvas)
    }
}
