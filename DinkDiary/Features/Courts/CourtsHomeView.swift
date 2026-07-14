import SwiftUI
import SwiftData

/// Your courts: a card per place you've played, with your record there. Auto
/// detection by location joins this in a later pass; for now courts come from
/// the name you give a session.
struct CourtsHomeView: View {
    @Query(sort: \Court.name) private var courts: [Court]

    private var playedCourts: [Court] {
        courts.filter { $0.isAlive && !StatsEngine.games(atCourt: $0).isEmpty }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                DD.Colors.surface.ignoresSafeArea()

                if playedCourts.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        VStack(spacing: DD.Spacing.cardGap) {
                            ForEach(playedCourts) { court in
                                NavigationLink(value: court) {
                                    CourtCardView(court: court)
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
            .navigationTitle("Your courts")
            .navigationDestination(for: Court.self) { court in
                CourtDetailView(court: court)
            }
            .toolbarBackground(DD.Colors.surface, for: .navigationBar)
        }
    }

    private var emptyState: some View {
        VStack(spacing: DD.Spacing.cardGap) {
            Image(systemName: "mappin.and.ellipse")
                .font(Font.system(size: 28, weight: .semibold))
                .foregroundStyle(DD.Colors.textSecondary)
            Text("Courts show up when you play.")
                .font(DD.Fonts.body)
                .foregroundStyle(DD.Colors.textSecondary)
        }
        .padding(DD.Spacing.gutter)
    }
}

struct CourtCardView: View {
    let court: Court

    private var record: (wins: Int, losses: Int) {
        StatsEngine.record(in: StatsEngine.games(atCourt: court))
    }
    private var sessionCount: Int { (court.sessions ?? []).count }
    private var isWinning: Bool { record.wins > record.losses }

    var body: some View {
        HStack(spacing: DD.Spacing.cardGap) {
            VStack(alignment: .leading, spacing: 4) {
                Text(court.name)
                    .font(DD.Fonts.title3)
                    .foregroundStyle(DD.Colors.textPrimary)
                    .lineLimit(1)
                Text(sessionCount == 1 ? "1 session" : "\(sessionCount) sessions")
                    .font(DD.Fonts.footnote)
                    .foregroundStyle(DD.Colors.textSecondary)
            }
            Spacer()
            Text("\(record.wins)-\(record.losses)")
                .font(DD.Fonts.statMedium)
                .foregroundStyle(isWinning ? DD.Colors.accentWin : DD.Colors.textPrimary)
        }
        .padding(DD.Spacing.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DD.Colors.surfaceElevated, in: .rect(cornerRadius: DD.Radius.sessionCard, style: .continuous))
    }
}
