import SwiftUI

/// Session card per components.md: surfaceElevated r22 p18, caption header,
/// kitchen line, record (optic if winning else textPrimary), partner cluster.
/// Weather chip and min/cal appear once the watch feeds health data (M3/M4).
struct SessionCardView: View {
    let session: Session

    private var games: [Game] { session.gamesInOrder }
    private var record: (wins: Int, losses: Int) { StatsEngine.record(in: games) }
    private var isWinning: Bool { record.wins > record.losses }

    private var partners: [AvatarCluster.Member] {
        var seen = Set<UUID>()
        var members: [AvatarCluster.Member] = []
        for game in games {
            guard let p = game.myPartner, !seen.contains(p.remoteID) else { continue }
            seen.insert(p.remoteID)
            members.append(.init(initials: p.initials, tint: DD.Colors.avatarTint(seed: p.tintSeed)))
        }
        return members
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DD.Spacing.cardGap) {
            Text(headerText).ddCaption()

            KitchenLineMotif(dimmed: games.isEmpty)

            HStack(alignment: .firstTextBaseline, spacing: DD.Spacing.rowGap) {
                Text("\(record.wins)-\(record.losses)")
                    .font(DD.Fonts.sessionRecord)
                    .foregroundStyle(isWinning ? DD.Colors.accentWin : DD.Colors.textPrimary)
                Text(games.count == 1 ? "1 game" : "\(games.count) games")
                    .font(DD.Fonts.footnote)
                    .foregroundStyle(DD.Colors.textSecondary)
            }

            if !partners.isEmpty {
                AvatarCluster(members: partners, size: 32, ringColor: DD.Colors.surfaceElevated)
            }
        }
        .padding(DD.Spacing.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            DD.Colors.surfaceElevated,
            in: .rect(cornerRadius: DD.Radius.sessionCard, style: .continuous)
        )
    }

    private var headerText: String {
        let date = session.startedAt.formatted(
            .dateTime.weekday(.abbreviated).month(.abbreviated).day()
        )
        if let court = session.court?.name, !court.isEmpty {
            return "\(date) \u{00B7} \(court)"
        }
        return date
    }
}
