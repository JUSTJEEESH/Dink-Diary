import SwiftUI
import SwiftData

/// Home timeline: the streak pinned at top, one tap to start a session, and the
/// scrolling feed of session cards. Empty state per components.md.
struct SessionsHomeView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Session.startedAt, order: .reverse) private var sessions: [Session]
    @State private var activeSession: Session?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DD.Spacing.cardGap) {
                    if streak >= 2 {
                        HStack {
                            StreakBadge(count: streak)
                            Spacer()
                        }
                    }

                    PillButton(title: "Start a session") { startSession() }

                    if displayedSessions.isEmpty {
                        emptyState.padding(.top, 40)
                    } else {
                        ForEach(displayedSessions) { session in
                            NavigationLink(value: session) {
                                SessionCardView(session: session)
                            }
                            .buttonStyle(DDCardButtonStyle())
                        }
                    }
                }
                .padding(.horizontal, DD.Spacing.gutter)
                .padding(.top, DD.Spacing.rowGap)
                .padding(.bottom, 100)
            }
            .background(DD.Colors.surface)
            .navigationTitle("Your season")
            #if DEBUG
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("Seed sample season") { SampleData.seed(into: context) }
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

    private var allGamesNewestFirst: [Game] {
        sessions.flatMap { $0.games ?? [] }.sorted { $0.playedAt > $1.playedAt }
    }

    private var streak: Int {
        StatsEngine.currentWinStreak(in: allGamesNewestFirst)
    }

    private func startSession() {
        let session = Session()
        context.insert(session)
        activeSession = session
    }

    #if DEBUG
    private func clearAll() {
        for session in sessions { context.delete(session) }
        try? context.delete(model: Player.self)
        try? context.delete(model: Court.self)
    }
    #endif

    private var emptyState: some View {
        VStack(spacing: DD.Spacing.cardGap) {
            KitchenLineMotif(dimmed: true)
                .frame(width: 120)
            Text("No games yet.")
                .font(DD.Fonts.title3)
                .foregroundStyle(DD.Colors.textPrimary)
            Text("Go find a fourth.")
                .font(DD.Fonts.body)
                .foregroundStyle(DD.Colors.textSecondary)
        }
    }
}
