import SwiftUI

/// A court's page: your record there and the sessions you've played on it.
struct CourtDetailView: View {
    let court: Court

    private var sessions: [Session] {
        (court.sessions ?? []).sorted { $0.startedAt > $1.startedAt }
    }
    private var record: (wins: Int, losses: Int) {
        StatsEngine.record(in: StatsEngine.games(atCourt: court))
    }
    private var isWinning: Bool { record.wins > record.losses }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DD.Spacing.cardGap) {
                HStack(alignment: .firstTextBaseline, spacing: DD.Spacing.rowGap) {
                    Text("\(record.wins)-\(record.losses)")
                        .font(DD.Fonts.statLarge)
                        .foregroundStyle(isWinning ? DD.Colors.accentWin : DD.Colors.textPrimary)
                    Text(sessions.count == 1 ? "1 session" : "\(sessions.count) sessions")
                        .font(DD.Fonts.footnote)
                        .foregroundStyle(DD.Colors.textSecondary)
                }
                .padding(.top, DD.Spacing.rowGap)

                ForEach(sessions) { session in
                    NavigationLink(value: session) {
                        SessionCardView(session: session)
                    }
                    .buttonStyle(DDCardButtonStyle())
                }
            }
            .padding(.horizontal, DD.Spacing.gutter)
            .padding(.bottom, 100)
        }
        .background(DD.Colors.surface)
        .navigationTitle(court.name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: Session.self) { session in
            SessionDetailView(session: session)
        }
    }
}
