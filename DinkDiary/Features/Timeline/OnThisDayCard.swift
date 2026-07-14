import SwiftUI

/// A warm resurfacing of a session from a past year on today's date.
struct OnThisDayCard: View {
    let session: Session

    private var games: [Game] { session.gamesInOrder }
    private var record: (wins: Int, losses: Int) { StatsEngine.record(in: games) }

    private var yearsAgoText: String {
        let years = Calendar.current.dateComponents([.year], from: session.startedAt, to: .now).year ?? 1
        return years == 1 ? "1 year ago" : "\(years) years ago"
    }

    var body: some View {
        HStack(spacing: DD.Spacing.cardGap) {
            Image(systemName: "clock.arrow.circlepath")
                .font(Font.system(size: 20, weight: .semibold))
                .foregroundStyle(DD.Colors.streak)
                .frame(width: 44, height: 44)
                .background(DD.Colors.streak.opacity(0.16), in: Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text("On this day \u{00B7} \(yearsAgoText)").ddCaption()
                Text("\(record.wins)-\(record.losses)\(courtText)")
                    .font(DD.Fonts.headline)
                    .foregroundStyle(DD.Colors.textPrimary)
                    .lineLimit(1)
            }
            Spacer(minLength: DD.Spacing.rowGap)
            Image(systemName: "chevron.right")
                .font(Font.system(size: 14, weight: .semibold))
                .foregroundStyle(DD.Colors.textSecondary)
        }
        .padding(DD.Spacing.cardPadding)
        .frame(maxWidth: .infinity)
        .background(DD.Colors.surfaceElevated, in: .rect(cornerRadius: DD.Radius.sessionCard, style: .continuous))
    }

    private var courtText: String {
        if let court = session.court?.name, !court.isEmpty { return " at \(court)" }
        return ""
    }
}
