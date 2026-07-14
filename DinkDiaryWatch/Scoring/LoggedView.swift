import SwiftUI

/// Between-games hub. Shows the running record and a clear choice: play the next
/// game, or end the session. Explicit buttons (rather than a silent auto-advance)
/// guarantee a reliable way out, since the scoring face is all tap targets.
struct LoggedView: View {
    let record: (wins: Int, losses: Int)
    let gameCount: Int
    var onNext: () -> Void
    var onEnd: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: DD.Spacing.cardGap) {
                Text("Logged.")
                    .font(DD.Fonts.headline)
                    .foregroundStyle(DD.Colors.accentWin)

                Text("\(record.wins)-\(record.losses)")
                    .font(DD.Fonts.watchConfirm)
                    .foregroundStyle(record.wins >= record.losses ? DD.Colors.accentWin : DD.Colors.textPrimary)

                Text(gameCount == 1 ? "1 game" : "\(gameCount) games")
                    .font(DD.Fonts.caption)
                    .foregroundStyle(DD.Colors.textSecondary)

                Button(action: onNext) {
                    Text("Next game")
                        .font(DD.Fonts.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(DDPillButtonStyle(variant: .primary))

                Button(action: onEnd) {
                    Text("End session")
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
