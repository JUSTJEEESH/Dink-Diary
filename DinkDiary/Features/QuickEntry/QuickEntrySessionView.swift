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
    @State private var showingGameForm = false

    private var games: [Game] { session.gamesInOrder }
    private var record: (wins: Int, losses: Int) { StatsEngine.record(in: games) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DD.Spacing.cardGap) {
                    recordHeader
                    courtField

                    if games.isEmpty {
                        gameEmptyState.padding(.vertical, DD.Spacing.gutter)
                    } else {
                        ForEach(games) { game in
                            GameRowView(game: game)
                        }
                    }

                    PillButton(title: "Add a game") { showingGameForm = true }
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
            .sheet(isPresented: $showingGameForm) {
                GameEntryForm(session: session)
                    .environment(SettingsStore.shared)
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
