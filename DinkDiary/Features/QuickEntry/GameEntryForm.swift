import SwiftUI
import SwiftData

/// Add one game: scores, mode, partner, opponents. Shows a live W/L pill so the
/// result reads back before saving.
struct GameEntryForm: View {
    let session: Session
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var myScore = 11
    @State private var theirScore = 9
    @State private var mode: ScoringType = .sideOut
    @State private var partner: Player?
    @State private var opponents: [Player] = []
    @State private var activePicker: PickerKind?

    private enum PickerKind: Int, Identifiable {
        case partner, opponents
        var id: Int { rawValue }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DD.Spacing.gutter) {
                    HStack(spacing: DD.Spacing.cardGap) {
                        ScoreStepper(label: "You", value: $myScore)
                        ScoreStepper(label: "Them", value: $theirScore)
                    }

                    modePicker

                    selectorRow(
                        label: "Partner",
                        value: partner?.name ?? "Add",
                        action: { activePicker = .partner }
                    )
                    selectorRow(
                        label: "Opponents",
                        value: opponents.isEmpty ? "Add" : opponents.map(\.name).joined(separator: ", "),
                        action: { activePicker = .opponents }
                    )

                    HStack {
                        Spacer()
                        WinLossPill(didWin: myScore > theirScore, score: "\(myScore)-\(theirScore)")
                        Spacer()
                    }

                    PillButton(title: "Save game") { save() }
                }
                .padding(DD.Spacing.gutter)
            }
            .background(DD.Colors.surface)
            .navigationTitle("Add a game")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(DD.Colors.textSecondary)
                }
            }
            .sheet(item: $activePicker) { kind in
                switch kind {
                case .partner:
                    PlayerPickerSheet(
                        title: "Your partner",
                        initiallySelected: partner.map { [$0] } ?? []
                    ) { result in
                        partner = result.first
                    }
                case .opponents:
                    PlayerPickerSheet(
                        title: "Opponents",
                        allowsMultiple: true,
                        maxSelection: 2,
                        initiallySelected: opponents
                    ) { result in
                        opponents = result
                    }
                }
            }
        }
    }

    private var modePicker: some View {
        HStack(spacing: 0) {
            ForEach(ScoringType.allCases) { type in
                Button {
                    mode = type
                } label: {
                    Text(type.label)
                        .font(DD.Fonts.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .foregroundStyle(mode == type ? DD.Colors.surface : DD.Colors.textSecondary)
                        .background(
                            mode == type ? DD.Colors.accentWin : Color.clear,
                            in: Capsule()
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(DD.Colors.surfaceElevated, in: Capsule())
    }

    private func selectorRow(label: String, value: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(label)
                    .font(DD.Fonts.headline)
                    .foregroundStyle(DD.Colors.textPrimary)
                Spacer()
                Text(value)
                    .font(DD.Fonts.body)
                    .foregroundStyle(DD.Colors.textSecondary)
                    .lineLimit(1)
                Image(systemName: "chevron.right")
                    .font(Font.system(size: 13, weight: .semibold))
                    .foregroundStyle(DD.Colors.textSecondary)
            }
            .padding(DD.Spacing.cardPadding)
            .background(
                DD.Colors.surfaceElevated,
                in: .rect(cornerRadius: DD.Radius.gameRow, style: .continuous)
            )
        }
        .buttonStyle(.plain)
    }

    private func save() {
        let game = Game(
            myScore: myScore,
            theirScore: theirScore,
            scoringType: mode,
            orderIndex: (session.games ?? []).count
        )
        game.session = session
        game.myPartner = partner
        game.opponents = opponents.isEmpty ? nil : opponents
        context.insert(game)
        dismiss()
    }
}
