import SwiftUI

/// The session on the wrist, matched to the mock: SESSION DONE, net line, big
/// record, then a 2x2 stat grid. Time comes from the session length now; cal
/// and heart rate fill in once the workout wraps the session (M3).
struct SessionSummaryView: View {
    let record: (wins: Int, losses: Int)
    let gameCount: Int
    let durationText: String?
    var onDone: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: DD.Spacing.cardGap) {
                Text("Session done")
                    .ddCaption()

                KitchenLineMotif()
                    .padding(.horizontal, DD.Spacing.rowGap)

                Text("\(record.wins)-\(record.losses)")
                    .font(DD.Fonts.statLarge)
                    .foregroundStyle(record.wins >= record.losses ? DD.Colors.accentWin : DD.Colors.textPrimary)

                Text(gameCount == 1 ? "1 game" : "\(gameCount) games")
                    .font(DD.Fonts.footnote)
                    .foregroundStyle(DD.Colors.textSecondary)

                VStack(spacing: DD.Spacing.rowGap) {
                    HStack(spacing: DD.Spacing.rowGap) {
                        WatchStatTile(value: durationText, label: "Time")
                        WatchStatTile(value: nil, label: "Cal", tint: DD.Colors.kitchenGreen)
                    }
                    HStack(spacing: DD.Spacing.rowGap) {
                        WatchStatTile(value: nil, label: "Avg HR", tint: DD.Colors.courtBlue)
                        WatchStatTile(value: nil, label: "Peak HR", tint: DD.Colors.courtBlue)
                    }
                }

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
