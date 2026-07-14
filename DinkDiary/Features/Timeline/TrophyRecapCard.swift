import SwiftUI

/// The session recap hero, the screenshot artifact per components.md: trophy
/// gradient, r28, 1px hairline border, 84pt record, a tile trio (min / cal /
/// peak HR), and the partner cluster with names. Health values fill in once the
/// watch wraps the session in a workout (M3b); until then they read as a dash.
struct TrophyRecapCard: View {
    let session: Session

    private var games: [Game] { session.gamesInOrder }
    private var record: (wins: Int, losses: Int) { StatsEngine.record(in: games) }
    private var isWinning: Bool { record.wins > record.losses }

    private var partners: [Player] {
        var seen = Set<UUID>()
        var result: [Player] = []
        for game in games {
            guard let p = game.myPartner, p.isAlive, !seen.contains(p.remoteID) else { continue }
            seen.insert(p.remoteID)
            result.append(p)
        }
        return result
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DD.Spacing.cardGap) {
            Text(headerText).ddCaption()

            KitchenLineMotif(lineHeight: 1, tickHeight: 7)

            HStack(alignment: .firstTextBaseline, spacing: DD.Spacing.rowGap) {
                Text("\(record.wins)-\(record.losses)")
                    .font(DD.Fonts.trophyRecord)
                    .foregroundStyle(isWinning ? DD.Colors.accentWin : DD.Colors.textPrimary)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                Text(games.count == 1 ? "1 game" : "\(games.count) games")
                    .font(DD.Fonts.footnote)
                    .foregroundStyle(DD.Colors.textSecondary)
            }

            HStack(spacing: DD.Spacing.rowGap) {
                healthTile(label: "Min", value: minutesText, tint: DD.Colors.kitchenGreen)
                healthTile(label: "Cal", value: caloriesText, tint: DD.Colors.kitchenGreen)
                healthTile(label: "Peak HR", value: peakHRText, tint: DD.Colors.courtBlue)
            }

            if !partners.isEmpty {
                HStack(spacing: DD.Spacing.cardGap) {
                    AvatarCluster(
                        members: partners.map {
                            .init(initials: $0.initials, tint: DD.Colors.avatarTint(seed: $0.tintSeed))
                        },
                        size: 32,
                        ringColor: DD.Colors.surfaceElevated
                    )
                    Text(partners.map(\.name).joined(separator: ", "))
                        .font(DD.Fonts.footnote)
                        .foregroundStyle(DD.Colors.textSecondary)
                        .lineLimit(1)
                }
            }
        }
        .padding(DD.Spacing.trophyPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DD.Gradients.trophy, in: .rect(cornerRadius: DD.Radius.trophy, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DD.Radius.trophy, style: .continuous)
                .strokeBorder(DD.Colors.hairline, lineWidth: 1)
        )
    }

    private func healthTile(label: String, value: String?, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value ?? "\u{2013}")
                .font(DD.Fonts.statSmall)
                .foregroundStyle(value == nil ? DD.Colors.textSecondary : tint)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text(label).ddCaption()
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DD.Colors.surface.opacity(0.55), in: .rect(cornerRadius: DD.Radius.gameRow, style: .continuous))
    }

    private var headerText: String {
        let date = session.startedAt.formatted(.dateTime.weekday(.wide).month(.abbreviated).day())
        if let court = session.court?.name, !court.isEmpty {
            return "\(date) \u{00B7} \(court)"
        }
        return date
    }

    private var minutesText: String? {
        session.activeMinutes.map { "\(Int($0))" }
    }
    private var caloriesText: String? {
        session.activeCalories.map { "\(Int($0))" }
    }
    private var peakHRText: String? {
        session.peakHeartRate.map { "\(Int($0))" }
    }
}
