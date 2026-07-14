import SwiftUI

/// The session recap rendered for sharing, per components.md share-card frame.
/// All metrics are proportional to `size.width`, so the same view renders crisp
/// at the on-screen preview size and at the 1080-wide export. Story gradient so
/// it never reads pure black in a feed; the Dink Diary mark sits bottom-left,
/// never a watermark across the content.
struct ShareCardView: View {
    let session: Session
    let size: CGSize
    var theme: ShareTheme = .midnight

    private var w: CGFloat { size.width }
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
        VStack(alignment: .leading, spacing: w * 0.03) {
            Text(headerText)
                .font(.system(size: w * 0.03, weight: .medium))
                .textCase(.uppercase)
                .tracking(w * 0.003)
                .foregroundStyle(DD.Colors.textSecondary)

            kitchenLine

            Spacer(minLength: 0)

            HStack(alignment: .firstTextBaseline, spacing: w * 0.02) {
                Text("\(record.wins)-\(record.losses)")
                    .font(.system(size: w * 0.28, weight: .heavy, design: .rounded).monospacedDigit())
                    .foregroundStyle(isWinning ? DD.Colors.accentWin : DD.Colors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            Text(games.count == 1 ? "1 game" : "\(games.count) games")
                .font(.system(size: w * 0.035, weight: .regular))
                .foregroundStyle(DD.Colors.textSecondary)

            Spacer(minLength: 0)

            HStack(spacing: w * 0.03) {
                statBlock(value: "\(games.count)", label: "Games")
                statBlock(value: "\(partners.count)", label: "Partners")
                statBlock(value: "\(StatsEngine.pointsForAgainst(in: games).scored)", label: "Points")
            }

            if !partners.isEmpty {
                avatarCluster
            }

            Spacer(minLength: 0)

            mark
        }
        .padding(w * 0.075)
        .frame(width: size.width, height: size.height, alignment: .topLeading)
        .background(theme.gradient)
    }

    private var kitchenLine: some View {
        Rectangle()
            .fill(DD.Colors.motifLine)
            .frame(height: w * 0.005)
            .overlay(alignment: .center) {
                Rectangle()
                    .fill(DD.Colors.motifLine)
                    .frame(width: w * 0.005, height: w * 0.03)
            }
    }

    private func statBlock(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: w * 0.005) {
            Text(value)
                .font(.system(size: w * 0.075, weight: .bold, design: .rounded).monospacedDigit())
                .foregroundStyle(DD.Colors.textPrimary)
            Text(label)
                .font(.system(size: w * 0.028, weight: .medium))
                .textCase(.uppercase)
                .tracking(w * 0.002)
                .foregroundStyle(DD.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, w * 0.025)
        .padding(.horizontal, w * 0.03)
        .background(DD.Colors.surface.opacity(0.55), in: .rect(cornerRadius: w * 0.03, style: .continuous))
    }

    private var avatarCluster: some View {
        HStack(spacing: -w * 0.02) {
            ForEach(partners.prefix(4), id: \.remoteID) { player in
                let tint = DD.Colors.avatarTint(seed: player.tintSeed)
                Text(player.initials)
                    .font(.system(size: w * 0.03, weight: .semibold, design: .rounded))
                    .foregroundStyle(tint)
                    .frame(width: w * 0.09, height: w * 0.09)
                    .background(tint.opacity(0.20), in: Circle())
                    .overlay(Circle().strokeBorder(DD.Colors.gradientTop, lineWidth: w * 0.005))
            }
        }
    }

    private var mark: some View {
        HStack(spacing: w * 0.02) {
            Circle()
                .fill(DD.Colors.accentWin)
                .frame(width: w * 0.02, height: w * 0.02)
            Text("Dink Diary")
                .font(.system(size: w * 0.03, weight: .semibold))
                .foregroundStyle(DD.Colors.textSecondary)
        }
    }

    private var headerText: String {
        let date = session.startedAt.formatted(.dateTime.weekday(.wide).month(.abbreviated).day())
        if let court = session.court?.name, !court.isEmpty {
            return "\(date) \u{00B7} \(court)"
        }
        return date
    }
}
