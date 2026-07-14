import SwiftUI

/// The face of the home tab: a personal portrait of your season the moment you
/// open the app. A warm greeting, your record as the hero number, your streak,
/// how much you have played, your person, and one identity line drawn from real
/// history. Everything here is derived by StatsEngine/SeasonRecapEngine; nothing
/// is stored. Copy obeys the brand rules; a down record is a rivalry, never a
/// failure.
struct SeasonHeroView: View {
    let stats: SeasonStats
    let currentStreak: Int
    let firstName: String
    /// A stable per-day seed so the identity line does not reshuffle on scroll.
    let daySeed: Int
    /// Hour of day for the greeting; passed in so the view stays testable.
    let hour: Int

    private var winning: Bool { stats.wins >= stats.losses }
    private var recordTint: Color { winning ? DD.Colors.accentWin : DD.Colors.textPrimary }

    private var winRate: Int {
        let total = stats.wins + stats.losses
        guard total > 0 else { return 0 }
        return Int((Double(stats.wins) / Double(total) * 100).rounded())
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DD.Spacing.cardGap) {
            greetingRow
            if stats.hasData {
                recordBlock
                personRow
                identityLine
            } else {
                welcomeBlock
            }
        }
        .padding(DD.Spacing.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DD.Gradients.trophy, in: .rect(cornerRadius: DD.Radius.sessionCard, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DD.Radius.sessionCard, style: .continuous)
                .strokeBorder(DD.Colors.hairline, lineWidth: 1)
        )
    }

    // MARK: Greeting + streak chip

    private var greetingRow: some View {
        HStack(alignment: .center) {
            Text(greetingText)
                .font(DD.Fonts.caption)
                .textCase(.uppercase)
                .tracking(1)
                .foregroundStyle(DD.Colors.textSecondary)
            Spacer()
            if currentStreak >= 2 {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(Font.system(size: 11, weight: .bold))
                    Text("\(currentStreak)")
                        .font(DD.Fonts.statBadge)
                }
                .foregroundStyle(DD.Colors.streak)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(DD.Colors.streak.opacity(0.14), in: Capsule())
            }
        }
    }

    private var greetingText: String {
        let base = Quips.greeting(hour: hour)
        return firstName.isEmpty ? base : "\(base), \(firstName)"
    }

    // MARK: Record

    private var recordBlock: some View {
        HStack(alignment: .lastTextBaseline, spacing: DD.Spacing.cardGap) {
            Text("\(stats.wins)-\(stats.losses)")
                .font(DD.Fonts.statLarge)
                .foregroundStyle(recordTint)
                .contentTransition(.numericText())
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            VStack(alignment: .leading, spacing: 1) {
                Text(stats.periodLabel == "All time" ? "All time" : "This season")
                    .ddCaption()
                Text(supportingLine)
                    .font(DD.Fonts.footnote)
                    .foregroundStyle(DD.Colors.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            Spacer(minLength: 0)
        }
    }

    /// "62% won · 24 games · 7 nights", trimmed of anything that reads as zero.
    private var supportingLine: String {
        let nights = stats.sessionsPlayed
        let nightWord = nights == 1 ? "night" : "nights"
        return "\(winRate)% won \u{00B7} \(stats.gamesPlayed) games \u{00B7} \(nights) \(nightWord)"
    }

    // MARK: Your person

    @ViewBuilder
    private var personRow: some View {
        if let name = stats.topPartnerName, let record = stats.topPartnerRecord {
            let first = name.split(separator: " ").first.map(String.init) ?? name
            HStack(spacing: DD.Spacing.rowGap) {
                AvatarView(initials: initials(name), tint: DD.Colors.avatarTint(seed: Quips.seed(name)), size: 28, ringColor: DD.Colors.surfaceElevated)
                Text("You + \(first)")
                    .font(DD.Fonts.footnote)
                    .foregroundStyle(DD.Colors.textPrimary)
                Spacer(minLength: DD.Spacing.rowGap)
                Text("\(record.wins)-\(record.losses)")
                    .font(DD.Fonts.statBadge)
                    .foregroundStyle(record.wins >= record.losses ? DD.Colors.accentWin : DD.Colors.textSecondary)
            }
            .padding(.top, 2)
        }
    }

    // MARK: Identity line

    private var identityLine: some View {
        Text(pickIdentityLine())
            .font(DD.Fonts.footnote)
            .foregroundStyle(DD.Colors.textSecondary)
            .fixedSize(horizontal: false, vertical: true)
    }

    /// Builds every true-for-you identity statement, then picks one by the day
    /// seed so it is stable within a day and rotates across days.
    private func pickIdentityLine() -> String {
        var lines: [String] = []
        if currentStreak >= 3 {
            lines.append(Quips.streak(count: currentStreak))
        }
        if let court = stats.topCourtName, stats.topCourtSessions >= 2 {
            lines.append("\(court) is your home court.")
        }
        if let nemesis = stats.nemesisName, let r = stats.nemesisRecord {
            let first = nemesis.split(separator: " ").first.map(String.init) ?? nemesis
            lines.append("\(first) leads you \(r.losses)-\(r.wins). One day.")
        }
        if stats.peopleCount >= 4 {
            lines.append("\(stats.peopleCount) people in your pickleball world.")
        }
        if stats.longestStreak >= 3 {
            lines.append("Your best run this season: \(stats.longestStreak) straight.")
        }
        if lines.isEmpty {
            lines.append("Every game, remembered.")
        }
        return lines[abs(daySeed) % lines.count]
    }

    // MARK: New player

    private var welcomeBlock: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("0-0")
                .font(DD.Fonts.statLarge)
                .foregroundStyle(DD.Colors.textPrimary)
            Text("Your season starts with one game.")
                .font(DD.Fonts.footnote)
                .foregroundStyle(DD.Colors.textSecondary)
        }
    }

    private func initials(_ name: String) -> String {
        let parts = name.split(separator: " ")
        let letters = parts.prefix(2).compactMap { $0.first }
        return letters.isEmpty ? "?" : String(letters).uppercased()
    }
}
