import SwiftUI
import SwiftData

/// Home timeline: the streak pinned at top, one tap to start a session, and the
/// scrolling feed of session cards. Empty state per components.md.
struct SessionsHomeView: View {
    @Environment(\.modelContext) private var context
    @Environment(PremiumStore.self) private var premium
    @Environment(SettingsStore.self) private var settings
    @Query(sort: \Session.startedAt, order: .reverse) private var sessions: [Session]
    @State private var activeSession: Session?
    @State private var showingPaywall = false
    @State private var showingSettings = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DD.Spacing.cardGap) {
                    SeasonHeroView(
                        stats: seasonStats,
                        currentStreak: streak,
                        firstName: settings.firstName,
                        daySeed: daySeed,
                        hour: Calendar.current.component(.hour, from: .now)
                    )

                    PillButton(title: "Start a session") { startSession() }

                    if let memory = onThisDay {
                        NavigationLink(value: memory) {
                            OnThisDayCard(session: memory)
                        }
                        .buttonStyle(DDCardButtonStyle())
                    }

                    if displayedSessions.isEmpty {
                        emptyState.padding(.top, 40)
                    } else {
                        ForEach(visibleSessions) { session in
                            NavigationLink(value: session) {
                                SessionCardView(session: session)
                            }
                            .buttonStyle(DDCardButtonStyle())
                        }
                        if lockedSessionCount > 0 {
                            historyLockCard
                        }
                    }
                }
                .padding(.horizontal, DD.Spacing.gutter)
                .padding(.top, DD.Spacing.rowGap)
                .padding(.bottom, 100)
            }
            .background(DD.Colors.surface)
            .navigationTitle("Your season")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                            .foregroundStyle(DD.Colors.textSecondary)
                    }
                }
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
                    .environment(premium)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
                    .environment(SettingsStore.shared)
            }
            #if DEBUG
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("Seed sample season") { SampleData.seed(into: context) }
                        Button(premium.isPremium ? "Switch to free" : "Unlock premium") {
                            premium.debugSetPremium(!premium.isPremium)
                        }
                        Button("Clear all", role: .destructive) { clearAll() }
                    } label: {
                        Image(systemName: "ladybug.fill")
                            .foregroundStyle(DD.Colors.textSecondary)
                    }
                }
            }
            #endif
            .navigationDestination(for: Session.self) { session in
                SessionDetailView(session: session)
            }
            .fullScreenCover(item: $activeSession) { session in
                QuickEntrySessionView(session: session)
            }
        }
    }

    /// Hide empty orphan sessions (e.g. a start that was force-quit before any
    /// game was logged); a normally ended empty session is already discarded.
    private var displayedSessions: [Session] {
        sessions.filter { !($0.games ?? []).isEmpty }
    }

    /// Free tier sees the most recent sessions only; premium sees them all.
    private var visibleSessions: [Session] {
        premium.isPremium ? displayedSessions : Array(displayedSessions.prefix(PremiumStore.freeSessionLimit))
    }

    private var lockedSessionCount: Int {
        displayedSessions.count - visibleSessions.count
    }

    private var historyLockCard: some View {
        Button {
            showingPaywall = true
        } label: {
            VStack(spacing: DD.Spacing.rowGap) {
                Text("\(lockedSessionCount) more \(lockedSessionCount == 1 ? "session" : "sessions") back there.")
                    .font(DD.Fonts.headline)
                    .foregroundStyle(DD.Colors.textPrimary)
                    .multilineTextAlignment(.center)
                Text("Unlock your full history")
                    .font(DD.Fonts.footnote)
                    .foregroundStyle(DD.Colors.accentWin)
            }
            .frame(maxWidth: .infinity)
            .padding(DD.Spacing.cardPadding)
            .background(DD.Colors.surfaceElevated, in: .rect(cornerRadius: DD.Radius.sessionCard, style: .continuous))
        }
        .buttonStyle(DDCardButtonStyle())
    }

    /// A session from a previous year on today's calendar date (within a day).
    private var onThisDay: Session? {
        let calendar = Calendar.current
        let now = Date.now
        let month = calendar.component(.month, from: now)
        let day = calendar.component(.day, from: now)
        let thisYear = calendar.component(.year, from: now)
        return displayedSessions
            .filter { session in
                calendar.component(.year, from: session.startedAt) < thisYear
                    && calendar.component(.month, from: session.startedAt) == month
                    && abs(calendar.component(.day, from: session.startedAt) - day) <= 1
            }
            .max { $0.startedAt < $1.startedAt }
    }

    private var allGames: [Game] {
        sessions.flatMap { $0.games ?? [] }
    }

    private var allGamesNewestFirst: [Game] {
        allGames.sorted { $0.playedAt > $1.playedAt }
    }

    private var streak: Int {
        StatsEngine.currentWinStreak(in: allGamesNewestFirst)
    }

    private var seasonStats: SeasonStats {
        SeasonRecapEngine.currentStats(games: allGames, sessions: sessions, now: .now)
    }

    /// Stable per-day seed, shared by the hero's identity line and the empty copy.
    private var daySeed: Int {
        Calendar.current.ordinality(of: .day, in: .era, for: .now) ?? 0
    }

    private func startSession() {
        let session = Session()
        context.insert(session)
        activeSession = session
        let sessionID = session.remoteID
        let container = context.container
        Task { await SessionContextCapturer.capture(sessionID: sessionID, container: container) }
    }

    #if DEBUG
    private func clearAll() {
        // Delete individually (not via batch delete) so SwiftData nullifies
        // inverse relationships and leaves no dangling references behind.
        for session in sessions { context.delete(session) }
        for player in (try? context.fetch(FetchDescriptor<Player>())) ?? [] {
            context.delete(player)
        }
        for court in (try? context.fetch(FetchDescriptor<Court>())) ?? [] {
            context.delete(court)
        }
        try? context.save()
    }
    #endif

    private var emptyState: some View {
        let copy = Quips.emptyTimeline(daySeed: daySeed)
        return VStack(spacing: DD.Spacing.cardGap) {
            KitchenLineMotif(dimmed: true)
                .frame(width: 120)
            Text(copy.title)
                .font(DD.Fonts.title3)
                .foregroundStyle(DD.Colors.textPrimary)
            Text(copy.line)
                .font(DD.Fonts.body)
                .foregroundStyle(DD.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
    }
}
