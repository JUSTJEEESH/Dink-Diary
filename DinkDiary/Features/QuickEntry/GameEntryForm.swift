import SwiftUI
import SwiftData

/// Add one game. The format (scoring type + target) defaults to your setting and
/// can be changed here; Save is only allowed when the score is a finished
/// pickleball game (reached the target, won by the margin), with a gentle nudge
/// when it isn't. This is the same rule the watch scores by.
/// Pre-filled players for a fast re-log (rematch or a doubles swap).
struct GamePrefill {
    var partner: Player?
    var opponents: [Player] = []
}

struct GameEntryForm: View {
    let session: Session
    /// People checked in tonight; the picker floats them to the top.
    var roster: [Player] = []
    /// Optional pre-filled teams for a one-tap re-log.
    var prefill: GamePrefill? = nil
    @Environment(\.modelContext) private var context
    @Environment(SettingsStore.self) private var settings
    @Environment(\.dismiss) private var dismiss

    @State private var myScore = 11
    @State private var theirScore = 9
    @State private var scoringType: ScoringType = .sideOut
    @State private var targetPoints = 11
    @State private var partner: Player?
    @State private var opponents: [Player] = []
    @State private var activePicker: PickerKind?
    @State private var didLoadDefaults = false

    private enum PickerKind: Int, Identifiable {
        case partner, opponents
        var id: Int { rawValue }
    }

    private var format: GameFormat {
        GameFormat(scoringType: scoringType, targetPoints: targetPoints, winBy: settings.winBy)
    }
    private var isValid: Bool {
        format.isComplete(myScore: myScore, theirScore: theirScore)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DD.Spacing.gutter) {
                    HStack(spacing: DD.Spacing.cardGap) {
                        ScoreStepper(label: "You", value: $myScore)
                        ScoreStepper(label: "Them", value: $theirScore)
                    }

                    segmented(
                        options: ScoringType.allCases.map { ($0.label, AnyHashable($0)) },
                        isSelected: { ($0 as? ScoringType) == scoringType },
                        select: { if let t = $0 as? ScoringType { scoringType = t } }
                    )
                    segmented(
                        options: GameFormat.targetOptions.map { ("To \($0)", AnyHashable($0)) },
                        isSelected: { ($0 as? Int) == targetPoints },
                        select: { if let t = $0 as? Int { targetPoints = t } }
                    )

                    selectorRow(label: "Partner", value: partner?.name ?? "Add") { activePicker = .partner }
                    selectorRow(
                        label: "Opponents",
                        value: opponents.isEmpty ? "Add" : opponents.map(\.name).joined(separator: ", ")
                    ) { activePicker = .opponents }

                    resultPreview

                    PillButton(title: "Save game") { save() }
                        .disabled(!isValid)
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
                    PlayerPickerSheet(title: "Your partner", prioritized: roster, initiallySelected: partner.map { [$0] } ?? []) { result in
                        partner = result.first
                    }
                case .opponents:
                    PlayerPickerSheet(title: "Opponents", allowsMultiple: true, maxSelection: 2, prioritized: roster, initiallySelected: opponents) { result in
                        opponents = result
                    }
                }
            }
            .onAppear {
                guard !didLoadDefaults else { return }
                didLoadDefaults = true
                scoringType = settings.scoringType
                targetPoints = settings.targetPoints
                if let prefill {
                    partner = prefill.partner
                    opponents = prefill.opponents
                }
            }
        }
    }

    private var resultPreview: some View {
        VStack(spacing: DD.Spacing.rowGap) {
            WinLossPill(didWin: myScore > theirScore, score: "\(myScore)-\(theirScore)")
                .opacity(isValid ? 1 : 0.4)
            Text(format.incompleteReason(myScore: myScore, theirScore: theirScore) ?? format.label)
                .font(DD.Fonts.footnote)
                .foregroundStyle(isValid ? DD.Colors.textSecondary : DD.Colors.accentLoss)
        }
        .frame(maxWidth: .infinity)
    }

    private func segmented(
        options: [(String, AnyHashable)],
        isSelected: @escaping (AnyHashable) -> Bool,
        select: @escaping (AnyHashable) -> Void
    ) -> some View {
        HStack(spacing: 0) {
            ForEach(options, id: \.1) { title, value in
                Button {
                    select(value)
                } label: {
                    Text(title)
                        .font(DD.Fonts.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .foregroundStyle(isSelected(value) ? DD.Colors.surface : DD.Colors.textSecondary)
                        .background(isSelected(value) ? DD.Colors.accentWin : Color.clear, in: Capsule())
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
            .background(DD.Colors.surfaceElevated, in: .rect(cornerRadius: DD.Radius.gameRow, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func save() {
        guard isValid else { return }
        let game = Game(
            myScore: myScore,
            theirScore: theirScore,
            format: format,
            orderIndex: (session.games ?? []).count
        )
        game.session = session
        game.myPartner = partner
        game.opponents = opponents.isEmpty ? nil : opponents
        context.insert(game)
        dismiss()
    }
}
