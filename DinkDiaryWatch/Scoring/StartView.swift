import SwiftUI

/// Idle screen: pick the scoring mode and start the first game.
struct StartView: View {
    @Binding var mode: ScoringType
    var onStart: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: DD.Spacing.cardGap) {
                Text("Dink Diary")
                    .font(DD.Fonts.headline)
                    .foregroundStyle(DD.Colors.textPrimary)

                modeToggle

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

    private var modeToggle: some View {
        HStack(spacing: 0) {
            ForEach(ScoringType.allCases) { type in
                Button {
                    mode = type
                } label: {
                    Text(type.label)
                        .font(DD.Fonts.caption)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .foregroundStyle(mode == type ? DD.Colors.surface : DD.Colors.textSecondary)
                        .background(
                            mode == type ? DD.Colors.accentWin : Color.clear,
                            in: Capsule()
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(3)
        .background(DD.Colors.surfaceElevated, in: Capsule())
    }
}
