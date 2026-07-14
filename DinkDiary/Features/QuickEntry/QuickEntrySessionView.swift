import SwiftUI
import SwiftData

/// The live session: name the court, add games one at a time, end the session.
/// An ended session with no games is discarded so accidental starts don't
/// litter the timeline.
struct QuickEntrySessionView: View {
    @Bindable var session: Session
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var courtName = ""
    @State private var checkedIn: [Player] = []
    @State private var pendingPrefill: GamePrefill?
    @State private var activeSheet: ActiveSheet?

    private enum ActiveSheet: Int, Identifiable { case game, roster; var id: Int { rawValue } }

    private var games: [Game] { session.gamesInOrder }
    private var record: (wins: Int, losses: Int) { StatsEngine.record(in: games) }

    /// Everyone on court tonight: whoever you checked in, plus anyone already in
    /// a logged game, de-duplicated in first-seen order.
    private var roster: [Player] {
        var seen = Set<UUID>()
        var result: [Player] = []
        for player in checkedIn + playedPlayers where player.isAlive && !seen.contains(player.remoteID) {
            seen.insert(player.remoteID)
            result.append(player)
        }
        return result
    }

    private var playedPlayers: [Player] {
        var seen = Set<UUID>()
        var result: [Player] = []
        for game in games {
            if let p = game.myPartner, p.isAlive, !seen.contains(p.remoteID) {
                seen.insert(p.remoteID); result.append(p)
            }
            for opponent in game.opponents ?? [] where opponent.isAlive && !seen.contains(opponent.remoteID) {
                seen.insert(opponent.remoteID); result.append(opponent)
            }
        }
        return result
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DD.Spacing.cardGap) {
                    recordHeader
                    courtField
                    rosterSection

                    if games.isEmpty {
                        gameEmptyState.padding(.vertical, DD.Spacing.gutter)
                    } else {
                        ForEach(games) { game in
                            GameRowView(game: game)
                        }
                        quickActions
                    }

                    PillButton(title: "Add a game") { pendingPrefill = nil; activeSheet = .game }
                    PillButton(title: "End session", variant: .secondary) { endSession() }
                }
                .padding(DD.Spacing.gutter)
                .padding(.bottom, 40)
            }
            .background(DD.Colors.surface)
            .navigationTitle("Tonight")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { endSession() }
                        .foregroundStyle(DD.Colors.accentWin)
                }
            }
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .game:
                    GameEntryForm(session: session, roster: roster, prefill: pendingPrefill)
                        .environment(SettingsStore.shared)
                case .roster:
                    PlayerPickerSheet(
                        title: "Who's here",
                        allowsMultiple: true,
                        prioritized: roster,
                        initiallySelected: roster
                    ) { checkedIn = $0 }
                }
            }
            .onAppear { courtName = session.court?.name ?? "" }
        }
    }

    private var recordHeader: some View {
        HStack(alignment: .firstTextBaseline, spacing: DD.Spacing.rowGap) {
            Text("\(record.wins)-\(record.losses)")
                .font(DD.Fonts.statLarge)
                .foregroundStyle(record.wins >= record.losses ? DD.Colors.accentWin : DD.Colors.textPrimary)
            Text(games.isEmpty ? "no games yet" : (games.count == 1 ? "1 game" : "\(games.count) games"))
                .font(DD.Fonts.footnote)
                .foregroundStyle(DD.Colors.textSecondary)
            Spacer()
        }
    }

    private var rosterSection: some View {
        VStack(alignment: .leading, spacing: DD.Spacing.rowGap) {
            HStack {
                Text("Who's here").ddCaption()
                Spacer()
                Button {
                    activeSheet = .roster
                } label: {
                    Label(roster.isEmpty ? "Check in" : "Edit", systemImage: "person.crop.circle.badge.plus")
                        .font(DD.Fonts.footnote)
                        .foregroundStyle(DD.Colors.accentWin)
                }
            }
            if roster.isEmpty {
                Text("Check in tonight's crew for one-tap logging.")
                    .font(DD.Fonts.footnote)
                    .foregroundStyle(DD.Colors.textSecondary)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: DD.Spacing.cardGap) {
                        ForEach(roster) { player in
                            VStack(spacing: 4) {
                                AvatarView(
                                    initials: player.initials,
                                    tint: DD.Colors.avatarTint(seed: player.tintSeed),
                                    size: 40,
                                    ringColor: DD.Colors.surface
                                )
                                Text(firstName(player.name))
                                    .font(DD.Fonts.caption)
                                    .foregroundStyle(DD.Colors.textSecondary)
                                    .lineLimit(1)
                            }
                            .frame(width: 56)
                        }
                    }
                }
            }
        }
        .padding(DD.Spacing.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DD.Colors.surfaceElevated, in: .rect(cornerRadius: DD.Radius.gameRow, style: .continuous))
    }

    private var quickActions: some View {
        HStack(spacing: DD.Spacing.cardGap) {
            if let last = games.last {
                quickChip(title: "Rematch", symbol: "arrow.counterclockwise") {
                    pendingPrefill = GamePrefill(partner: aliveOrNil(last.myPartner), opponents: aliveOpponents(last))
                    activeSheet = .game
                }
                if let rotation = DoublesRotation.next(partner: aliveOrNil(last.myPartner), opponents: aliveOpponents(last)) {
                    quickChip(title: "Swap partners", symbol: "arrow.triangle.2.circlepath") {
                        pendingPrefill = GamePrefill(partner: rotation.partner, opponents: rotation.opponents)
                        activeSheet = .game
                    }
                }
            }
        }
    }

    private func quickChip(title: String, symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: symbol)
                    .font(Font.system(size: 13, weight: .semibold))
                Text(title)
                    .font(DD.Fonts.headline)
            }
            .foregroundStyle(DD.Colors.accentWin)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(DD.Colors.accentWin.opacity(0.12), in: Capsule())
        }
        .buttonStyle(.plain)
    }

    private func aliveOrNil(_ player: Player?) -> Player? {
        guard let player, player.isAlive else { return nil }
        return player
    }

    private func aliveOpponents(_ game: Game) -> [Player] {
        (game.opponents ?? []).filter { $0.isAlive }
    }

    private func firstName(_ name: String) -> String {
        name.split(separator: " ").first.map(String.init) ?? name
    }

    private var courtField: some View {
        TextField("Court name", text: $courtName)
            .textFieldStyle(.plain)
            .font(DD.Fonts.title3)
            .foregroundStyle(DD.Colors.textPrimary)
            .padding(DD.Spacing.cardPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                DD.Colors.surfaceElevated,
                in: .rect(cornerRadius: DD.Radius.gameRow, style: .continuous)
            )
    }

    private var gameEmptyState: some View {
        VStack(spacing: DD.Spacing.rowGap) {
            Circle()
                .strokeBorder(
                    DD.Colors.textSecondary.opacity(0.30),
                    style: StrokeStyle(lineWidth: 1, dash: [4, 3])
                )
                .frame(width: 40, height: 40)
            Text("Nothing logged tonight yet.")
                .font(DD.Fonts.body)
                .foregroundStyle(DD.Colors.textSecondary)
        }
    }

    private func endSession() {
        linkCourt(named: courtName)
        session.endedAt = .now
        if games.isEmpty {
            context.delete(session)
        }
        dismiss()
    }

    /// Find-or-create a Court by name (case-insensitive) and link it.
    private func linkCourt(named raw: String) {
        let name = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else {
            session.court = nil
            return
        }
        let existing = (try? context.fetch(FetchDescriptor<Court>()))?
            .first { $0.name.caseInsensitiveCompare(name) == .orderedSame }
        if let existing {
            session.court = existing
        } else {
            let court = Court(name: name)
            context.insert(court)
            session.court = court
        }
    }
}
