import SwiftUI
import SwiftData

/// Your people: a grid of everyone you've played with, each card showing your
/// record together. Tap through to the partner detail.
struct PeopleHomeView: View {
    @Query(sort: \Player.name) private var players: [Player]
    @Query private var allGames: [Game]

    private let columns = [
        GridItem(.flexible(), spacing: DD.Spacing.cardGap),
        GridItem(.flexible(), spacing: DD.Spacing.cardGap),
    ]

    private var people: [Player] {
        players.filter { $0.isAlive && !$0.isMe && StatsEngine.lastPlayed(with: $0, in: allGames) != nil }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                DD.Colors.surface.ignoresSafeArea()

                if people.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: DD.Spacing.cardGap) {
                            ForEach(people) { player in
                                NavigationLink(value: player) {
                                    PartnerCardView(player: player, allGames: allGames)
                                }
                                .buttonStyle(DDCardButtonStyle())
                            }
                        }
                        .padding(.horizontal, DD.Spacing.gutter)
                        .padding(.top, DD.Spacing.rowGap)
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationTitle("Your people")
            .navigationDestination(for: Player.self) { player in
                PartnerDetailView(player: player, allGames: allGames)
            }
            .toolbarBackground(DD.Colors.surface, for: .navigationBar)
        }
    }

    private var emptyState: some View {
        VStack(spacing: DD.Spacing.cardGap) {
            AvatarCluster(members: [])
        }
        .padding(DD.Spacing.gutter)
    }
}

/// One person in the grid: tinted avatar, name, record together.
struct PartnerCardView: View {
    let player: Player
    let allGames: [Game]

    private var record: (wins: Int, losses: Int) {
        StatsEngine.record(withPartner: player, in: allGames)
    }
    private var isWinning: Bool { record.wins > record.losses }

    var body: some View {
        VStack(alignment: .leading, spacing: DD.Spacing.cardGap) {
            AvatarView(
                initials: player.initials,
                tint: DD.Colors.avatarTint(seed: player.tintSeed),
                size: 44,
                ringColor: DD.Colors.surfaceElevated
            )
            Text(player.name)
                .font(DD.Fonts.headline)
                .foregroundStyle(DD.Colors.textPrimary)
                .lineLimit(1)
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text("\(record.wins)-\(record.losses)")
                    .font(DD.Fonts.statSmall)
                    .foregroundStyle(isWinning ? DD.Colors.accentWin : DD.Colors.textPrimary)
                Text("together")
                    .font(DD.Fonts.caption)
                    .foregroundStyle(DD.Colors.textSecondary)
            }
        }
        .padding(DD.Spacing.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DD.Colors.surfaceElevated, in: .rect(cornerRadius: DD.Radius.sessionCard, style: .continuous))
    }
}
