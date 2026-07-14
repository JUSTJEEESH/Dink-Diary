import SwiftUI

/// The session on the wrist: record and games. Time and heart rate join this in
/// M3 once the workout wraps the session. The kitchen line is allowed here (a
/// wrist summary is one of the play-summarizing surfaces).
struct SessionSummaryView: View {
    let record: (wins: Int, losses: Int)
    let gameCount: Int
    var onDone: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: DD.Spacing.cardGap) {
                Text("Session")
                    .font(DD.Fonts.caption)
                    .textCase(.uppercase)
                    .foregroundStyle(DD.Colors.textSecondary)

                Text("\(record.wins)-\(record.losses)")
                    .font(DD.Fonts.watchScore)
                    .foregroundStyle(record.wins >= record.losses ? DD.Colors.accentWin : DD.Colors.textPrimary)

                KitchenLineMotif()
                    .frame(width: 90)

                Text(gameCount == 1 ? "1 game" : "\(gameCount) games")
                    .font(DD.Fonts.footnote)
                    .foregroundStyle(DD.Colors.textSecondary)

                Button(action: onDone) {
                    Text("Done")
                        .font(DD.Fonts.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(DDPillButtonStyle(variant: .primary))
                .padding(.top, DD.Spacing.rowGap)
            }
            .padding(.horizontal, DD.Spacing.rowGap)
            .padding(.vertical, DD.Spacing.cardGap)
        }
        .background(DD.Colors.watchCanvas)
    }
}
