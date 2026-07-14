import SwiftUI

/// Idle screen: pick the scoring mode and start the first game.
struct StartView: View {
    @Binding var mode: ScoringType
    @Binding var target: Int
    var onStart: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: DD.Spacing.cardGap) {
                Text("Dink Diary")
                    .font(DD.Fonts.headline)
                    .foregroundStyle(DD.Colors.textPrimary)

                toggle(options: ScoringType.allCases.map { ($0.label, AnyHashable($0)) },
                       isSelected: { ($0 as? ScoringType) == mode },
                       select: { if let t = $0 as? ScoringType { mode = t } })

                toggle(options: GameFormat.targetOptions.map { ("\($0)", AnyHashable($0)) },
                       isSelected: { ($0 as? Int) == target },
                       select: { if let t = $0 as? Int { target = t } })

                Button(action: onStart) {
                    Text("Start game")
                        .font(DD.Fonts.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(DDPillButtonStyle(variant: .primary))
            }
            .padding(.horizontal, DD.Spacing.rowGap)
            .padding(.vertical, DD.Spacing.cardGap)
        }
        .background(DD.Colors.watchCanvas)
    }

    private func toggle(
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
                        .font(DD.Fonts.caption)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .foregroundStyle(isSelected(value) ? DD.Colors.surface : DD.Colors.textSecondary)
                        .background(isSelected(value) ? DD.Colors.accentWin : Color.clear, in: Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(3)
        .background(DD.Colors.surfaceElevated, in: Capsule())
    }
}
