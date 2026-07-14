import SwiftUI
import SwiftData

/// Insights. Free tier shows three; the rest render live underneath a lock.
struct InsightsHomeView: View {
    @Environment(PremiumStore.self) private var premium
    @Query private var allGames: [Game]
    @State private var showingPaywall = false

    var body: some View {
        NavigationStack {
            ZStack {
                DD.Colors.surface.ignoresSafeArea()

                if allGames.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        VStack(spacing: DD.Spacing.cardGap) {
                            streakCard
                            chemistryCard
                            nemesisCard

                            if premium.isPremium {
                                dayTimeCard
                                pointsCard
                            } else {
                                lockedSection
                            }
                        }
                        .padding(.horizontal, DD.Spacing.gutter)
                        .padding(.top, DD.Spacing.rowGap)
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationTitle("Insights")
            .toolbarBackground(DD.Colors.surface, for: .navigationBar)
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
                    .environment(premium)
            }
        }
    }

    // MARK: Free insights

    private var streakCard: some View {
        let current = StatsEngine.currentWinStreak(in: allGames.sorted { $0.playedAt > $1.playedAt })
        let longest = StatsEngine.longestWinStreak(in: allGames)
        return InsightCard(title: "Win streaks") {
            HStack(spacing: DD.Spacing.cardGap) {
                bigStat(value: "\(current)", label: "Current", tint: current >= 2 ? DD.Colors.streak : DD.Colors.textPrimary)
                bigStat(value: "\(longest)", label: "Longest", tint: DD.Colors.textPrimary)
            }
        }
    }

    private var chemistryCard: some View {
        let ranking = StatsEngine.chemistryRanking(in: allGames)
        return InsightCard(title: "Chemistry") {
            if ranking.isEmpty {
                hint("Play a few games with someone to see your chemistry.")
            } else {
                VStack(spacing: DD.Spacing.rowGap) {
                    ForEach(ranking.prefix(3)) { record in
                        partnerRow(record, tint: DD.Colors.avatarTint(seed: record.player.tintSeed))
                    }
                }
            }
        }
    }

    private var nemesisCard: some View {
        let nemesis = StatsEngine.nemesis(in: allGames)
        return InsightCard(title: "Nemesis") {
            if let nemesis {
                HStack(spacing: DD.Spacing.cardGap) {
                    AvatarView(initials: nemesis.player.initials, tint: DD.Colors.accentLoss, size: 44, ringColor: DD.Colors.surfaceElevated)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(nemesis.player.name)
                            .font(DD.Fonts.headline)
                            .foregroundStyle(DD.Colors.textPrimary)
                        Text("One day.")
                            .font(DD.Fonts.footnote)
                            .foregroundStyle(DD.Colors.textSecondary)
                    }
                    Spacer()
                    Text("\(nemesis.wins)-\(nemesis.losses)")
                        .font(DD.Fonts.statMedium)
                        .foregroundStyle(DD.Colors.accentLoss)
                }
            } else {
                hint("No nemesis yet. Keep playing the same faces.")
            }
        }
    }

    // MARK: Locked insights

    private var lockedSection: some View {
        ZStack {
            VStack(spacing: DD.Spacing.cardGap) {
                dayTimeCard
                pointsCard
            }
            .blur(radius: 6)
            .opacity(0.55)
            .allowsHitTesting(false)

            LockedInsightsOverlay { showingPaywall = true }
        }
    }

    private var dayTimeCard: some View {
        let buckets = StatsEngine.timeBuckets(in: allGames)
        return InsightCard(title: "Day and time") {
            VStack(spacing: DD.Spacing.rowGap) {
                ForEach(buckets) { bucket in
                    HStack {
                        Text(bucket.time.label)
                            .font(DD.Fonts.headline)
                            .foregroundStyle(DD.Colors.textPrimary)
                        Spacer()
                        Text("\(bucket.wins)-\(bucket.losses)")
                            .font(DD.Fonts.statSmall)
                            .foregroundStyle(bucket.wins > bucket.losses ? DD.Colors.accentWin : DD.Colors.textPrimary)
                    }
                }
            }
        }
    }

    private var pointsCard: some View {
        let points = StatsEngine.pointsForAgainst(in: allGames)
        return InsightCard(title: "Points") {
            HStack(spacing: DD.Spacing.cardGap) {
                bigStat(value: "\(points.scored)", label: "Scored", tint: DD.Colors.accentWin)
                bigStat(value: "\(points.allowed)", label: "Allowed", tint: DD.Colors.textPrimary)
            }
        }
    }

    // MARK: Pieces

    private func bigStat(value: String, label: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(DD.Fonts.statMedium)
                .foregroundStyle(tint)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text(label).ddCaption()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func partnerRow(_ record: StatsEngine.PlayerRecord, tint: Color) -> some View {
        HStack(spacing: DD.Spacing.cardGap) {
            AvatarView(initials: record.player.initials, tint: tint, size: 32, ringColor: DD.Colors.surfaceElevated)
            Text(record.player.name)
                .font(DD.Fonts.headline)
                .foregroundStyle(DD.Colors.textPrimary)
                .lineLimit(1)
            Spacer()
            Text("\(record.wins)-\(record.losses)")
                .font(DD.Fonts.statSmall)
                .foregroundStyle(record.wins > record.losses ? DD.Colors.accentWin : DD.Colors.textPrimary)
        }
    }

    private func hint(_ text: String) -> some View {
        Text(text)
            .font(DD.Fonts.body)
            .foregroundStyle(DD.Colors.textSecondary)
    }

    private var emptyState: some View {
        VStack(spacing: DD.Spacing.cardGap) {
            Image(systemName: "chart.bar.fill")
                .font(Font.system(size: 28, weight: .semibold))
                .foregroundStyle(DD.Colors.textSecondary)
            Text("Your story starts after a few games.")
                .font(DD.Fonts.body)
                .foregroundStyle(DD.Colors.textSecondary)
        }
        .padding(DD.Spacing.gutter)
    }
}

/// A titled insight container.
struct InsightCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: DD.Spacing.cardGap) {
            Text(title).ddCaption()
            content()
        }
        .padding(DD.Spacing.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DD.Colors.surfaceElevated, in: .rect(cornerRadius: DD.Radius.sessionCard, style: .continuous))
    }
}
