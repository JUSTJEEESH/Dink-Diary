import SwiftUI

/// A partner's page: your record together and against, games played, last
/// played, and a warm chemistry line per the brief's voice. A losing record is
/// framed as a rivalry, never a failure.
struct PartnerDetailView: View {
    let player: Player
    let allGames: [Game]

    private var together: (wins: Int, losses: Int) {
        StatsEngine.record(withPartner: player, in: allGames)
    }
    private var against: (wins: Int, losses: Int) {
        StatsEngine.record(against: player, in: allGames)
    }
    private var gamesTogether: Int {
        StatsEngine.gamesCount(withPartner: player, in: allGames)
    }
    private var lastPlayed: Date? {
        StatsEngine.lastPlayed(with: player, in: allGames)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DD.Spacing.cardGap) {
                header

                HStack(spacing: DD.Spacing.cardGap) {
                    StatTile(
                        label: "Together",
                        value: "\(together.wins)-\(together.losses)",
                        tint: together.wins > together.losses ? DD.Colors.accentWin : DD.Colors.textPrimary
                    )
                    StatTile(
                        label: "Against",
                        value: "\(against.wins)-\(against.losses)"
                    )
                }

                HStack(spacing: DD.Spacing.cardGap) {
                    StatTile(label: "Games", value: "\(gamesTogether)")
                    StatTile(label: "Last played", value: lastPlayedText)
                }

                storylineCard
                    .padding(.top, DD.Spacing.rowGap)
            }
            .padding(.horizontal, DD.Spacing.gutter)
            .padding(.top, DD.Spacing.rowGap)
            .padding(.bottom, 100)
        }
        .background(DD.Colors.surface)
        .navigationTitle(player.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        HStack(spacing: DD.Spacing.cardGap) {
            AvatarView(
                initials: player.initials,
                tint: DD.Colors.avatarTint(seed: player.tintSeed),
                size: 56,
                ringColor: DD.Colors.surface
            )
            Text(player.name)
                .font(DD.Fonts.title1)
                .foregroundStyle(DD.Colors.textPrimary)
        }
    }

    private var lastPlayedText: String? {
        lastPlayed.map { $0.formatted(.dateTime.month(.abbreviated).day()) }
    }

    private var storyline: Storyline {
        StorylineEngine.narrative(for: player, in: allGames, now: .now)
    }

    private var storylineCard: some View {
        VStack(alignment: .leading, spacing: DD.Spacing.rowGap) {
            Text(storyline.headline).ddCaption()
            Text(storyline.body)
                .font(DD.Fonts.body)
                .foregroundStyle(DD.Colors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(DD.Spacing.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DD.Colors.surfaceElevated, in: .rect(cornerRadius: DD.Radius.sessionCard, style: .continuous))
    }
}
