import SwiftUI
import SwiftData

/// Insights. Free tier shows three; the rest render live underneath a lock.
struct InsightsHomeView: View {
    @Environment(PremiumStore.self) private var premium
    @Query private var allGames: [Game]
    @Query private var allSessions: [Session]
    @Query(sort: \RatingEntry.recordedAt) private var ratings: [RatingEntry]
    @State private var showingPaywall = false
    @State private var showingRecap = false
    @State private var celebrating: Milestone?
    @State private var sharing: Milestone?

    private var milestones: [Milestone] {
        MilestoneEngine.achieved(games: allGames, sessions: allSessions)
    }

    private var storylines: [Storyline] {
        StorylineEngine.seasonStorylines(in: allGames, now: .now)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                DD.Colors.surface.ignoresSafeArea()

                if allGames.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        VStack(spacing: DD.Spacing.cardGap) {
                            recapEntry
                            ratingEntry
                            if !storylines.isEmpty { storylinesSection }
                            if !milestones.isEmpty { milestonesSection }

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
            #if DEBUG
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Moment") { celebrating = milestones.first }
                        .foregroundStyle(DD.Colors.textSecondary)
                }
            }
            #endif
            .navigationDestination(for: String.self) { route in
                if route == "moments" {
                    MilestonesView(milestones: milestones)
                } else if route == "rating" {
                    RatingDetailView()
                }
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
                    .environment(premium)
            }
            .fullScreenCover(isPresented: $showingRecap) {
                SeasonRecapView(stats: SeasonRecapEngine.currentStats(games: allGames, sessions: allSessions, now: .now))
            }
            .sheet(item: $celebrating) { milestone in
                MilestoneCelebrationView(milestone: milestone)
                    .presentationDetents([.medium])
            }
            .sheet(item: $sharing) { milestone in
                MilestoneShareSheet(milestone: milestone)
            }
            .onAppear {
                celebrating = MilestoneSeenStore.newlyAchieved(from: milestones).first
            }
        }
    }

    private var recapEntry: some View {
        Button {
            showingRecap = true
        } label: {
            HStack(spacing: DD.Spacing.cardGap) {
                Image(systemName: "sparkles")
                    .font(Font.system(size: 22, weight: .bold))
                    .foregroundStyle(DD.Colors.surface)
                    .frame(width: 48, height: 48)
                    .background(DD.Colors.accentWin, in: Circle())
                VStack(alignment: .leading, spacing: 2) {
                    Text("Your season")
                        .font(DD.Fonts.title3)
                        .foregroundStyle(DD.Colors.textPrimary)
                    Text("The whole story, one tap.")
                        .font(DD.Fonts.footnote)
                        .foregroundStyle(DD.Colors.textSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(Font.system(size: 14, weight: .semibold))
                    .foregroundStyle(DD.Colors.textSecondary)
            }
            .padding(DD.Spacing.cardPadding)
            .frame(maxWidth: .infinity)
            .background(DD.Gradients.trophy, in: .rect(cornerRadius: DD.Radius.sessionCard, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: DD.Radius.sessionCard, style: .continuous)
                    .strokeBorder(DD.Colors.hairline, lineWidth: 1)
            )
        }
        .buttonStyle(DDCardButtonStyle())
    }

    private var doublesRatings: [RatingEntry] {
        ratings.filter { !$0.isSingles }
    }

    private var ratingEntry: some View {
        NavigationLink(value: "rating") {
            RatingCard(entries: doublesRatings)
        }
        .buttonStyle(DDCardButtonStyle())
    }

    private var storylinesSection: some View {
        VStack(spacing: DD.Spacing.cardGap) {
            ForEach(storylines) { story in
                StorylineCard(story: story)
            }
        }
    }

    private var milestonesSection: some View {
        InsightCard(title: "Moments") {
            VStack(spacing: DD.Spacing.rowGap) {
                ForEach(milestones.prefix(3)) { milestone in
                    Button {
                        sharing = milestone
                    } label: {
                        MilestoneRow(milestone: milestone, showsShareHint: true)
                    }
                    .buttonStyle(DDCardButtonStyle())
                }
                if milestones.count > 3 {
                    NavigationLink(value: "moments") {
                        HStack {
                            Text("See all \(milestones.count) moments")
                                .font(DD.Fonts.footnote)
                                .foregroundStyle(DD.Colors.accentWin)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(Font.system(size: 12, weight: .semibold))
                                .foregroundStyle(DD.Colors.accentWin)
                        }
                    }
                    .buttonStyle(.plain)
                }
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
                        Text(Quips.rivalryLine(seed: Quips.seed(nemesis.player.remoteID.uuidString)))
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

/// A warm, auto-written storyline about one of your people. Headline tinted by
/// tone; body in the app's voice. A losing record reads as a rivalry.
struct StorylineCard: View {
    let story: Storyline

    private var tint: Color {
        switch story.tone {
        case .chemistry: return DD.Colors.accentWin
        case .rivalry: return DD.Colors.accentLoss
        case .even: return DD.Colors.streak
        case .fresh: return DD.Colors.textSecondary
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DD.Spacing.rowGap) {
            Text(story.headline)
                .font(DD.Fonts.caption)
                .textCase(.uppercase)
                .tracking(1)
                .foregroundStyle(tint)
            Text(story.body)
                .font(DD.Fonts.body)
                .foregroundStyle(DD.Colors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(DD.Spacing.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DD.Colors.surfaceElevated, in: .rect(cornerRadius: DD.Radius.sessionCard, style: .continuous))
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(tint)
                .frame(width: 3)
                .clipShape(.rect(cornerRadius: 1.5))
        }
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
