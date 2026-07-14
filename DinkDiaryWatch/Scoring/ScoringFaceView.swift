import SwiftUI

/// The scoring face, built to be read at arm's length: two numbers, each filling
/// its half of the screen. Tap a side and it scores, one tap, immediately.
/// Color is the identity, the bright optic number is always you (bottom), the
/// warm white one is them (top). A compact serve pill sits above, a mode chip
/// below, split by the net line. Long-press anywhere to undo. Canvas is true black.
struct ScoringFaceView: View {
    @Binding var engine: ScoreEngine
    var onGameOver: () -> Void

    var body: some View {
        ZStack {
            DD.Colors.watchCanvas.ignoresSafeArea()

            VStack(spacing: 2) {
                servePill

                Button {
                    tap(.them)
                } label: {
                    numeral(engine.themScore, color: DD.Colors.textPrimary)
                }
                .buttonStyle(.plain)

                // Net line (the mock's divider). The kitchen-line motif reads as
                // the net here; see note to the design owner.
                KitchenLineMotif()
                    .padding(.horizontal, DD.Spacing.rowGap)
                    .allowsHitTesting(false)

                Button {
                    tap(.us)
                } label: {
                    numeral(engine.usScore, color: DD.Colors.accentWin)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 2)
            .padding(.vertical, 4)
        }
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.5).onEnded { _ in undo() }
        )
    }

    /// Fills its half and scales the glyph down from an oversized base, so the
    /// number is as large as the watch allows.
    private func numeral(_ value: Int, color: Color) -> some View {
        Text("\(value)")
            .font(DD.Fonts.watchScoreFill)
            .foregroundStyle(color)
            .lineLimit(1)
            .minimumScaleFactor(0.2)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
    }

    private var servePill: some View {
        Text(serveLabel)
            .font(DD.Fonts.caption)
            .textCase(.uppercase)
            .tracking(0.5)
            .foregroundStyle(DD.Colors.surface)
            .padding(.horizontal, 10)
            .padding(.vertical, 3)
            .background(DD.Colors.accentWin, in: Capsule())
    }

    private var serveLabel: String {
        let who = engine.servingTeam == .us ? "YOU" : "THEM"
        return engine.mode == .sideOut ? "\(who) SRV \(engine.serverNumber)" : "\(who) SRV"
    }

    private func tap(_ team: Team) {
        engine.addPoint(to: team)
        WatchHaptics.tap()
        if engine.isGameOver {
            WatchHaptics.confirm()
            onGameOver()
        }
    }

    private func undo() {
        if engine.undo() {
            WatchHaptics.undo()
        }
    }
}
