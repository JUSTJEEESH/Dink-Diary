import SwiftUI

/// The scoring face, matched to the mock and filling the whole screen. Ignores
/// the safe area so nothing floats in a margin; the system draws the time over
/// the top corner. Each label hugs its number (THEM above its number, US below
/// its number) and the leftover space is spread evenly around those groups and
/// the net, so nothing has a lopsided gap. The serving team carries an optic dot
/// by its label. Tap a side and it scores, one tap, immediately. Color is the
/// identity: the bright optic number is always you (bottom). Long-press to undo.
struct ScoringFaceView: View {
    @Binding var engine: ScoreEngine
    var onGameOver: () -> Void

    var body: some View {
        GeometryReader { geo in
            let numberHeight = geo.size.height * 0.27

            ZStack {
                DD.Colors.watchCanvas

                VStack(spacing: 0) {
                    servePill
                    Spacer(minLength: 2)

                    VStack(spacing: 2) {
                        teamLabel(.them)
                        numeral(engine.themScore, color: DD.Colors.textPrimary, height: numberHeight)
                    }

                    Spacer(minLength: 2)
                    KitchenLineMotif()
                        .padding(.horizontal, DD.Spacing.rowGap)
                    Spacer(minLength: 2)

                    VStack(spacing: 2) {
                        numeral(engine.usScore, color: DD.Colors.accentWin, height: numberHeight)
                        teamLabel(.us)
                    }

                    Spacer(minLength: 2)
                    modeChip
                }
                .frame(width: geo.size.width, height: geo.size.height)

                // Tap zones sit over everything and split at the net: top half
                // scores them, bottom half scores us.
                VStack(spacing: 0) {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture { tap(.them) }
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture { tap(.us) }
                }
            }
        }
        .ignoresSafeArea()
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.5).onEnded { _ in undo() }
        )
    }

    private func numeral(_ value: Int, color: Color, height: CGFloat) -> some View {
        Text("\(value)")
            .font(DD.Fonts.watchScore)
            .foregroundStyle(color)
            .lineLimit(1)
            .minimumScaleFactor(0.4)
            .frame(height: height)
    }

    private func teamLabel(_ team: Team) -> some View {
        HStack(spacing: 4) {
            if engine.servingTeam == team {
                Circle()
                    .fill(DD.Colors.accentWin)
                    .frame(width: 6, height: 6)
            }
            Text(team == .us ? "US" : "THEM").ddCaption()
        }
    }

    private var servePill: some View {
        Text(serveLabel)
            .font(DD.Fonts.caption)
            .textCase(.uppercase)
            .tracking(0.5)
            .foregroundStyle(DD.Colors.surface)
            .padding(.horizontal, 12)
            .padding(.vertical, 3)
            .background(DD.Colors.accentWin, in: Capsule())
    }

    private var modeChip: some View {
        Text(engine.mode == .sideOut ? "SIDE OUT" : "RALLY")
            .font(DD.Fonts.caption)
            .tracking(0.5)
            .foregroundStyle(DD.Colors.textSecondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 3)
            .background(DD.Colors.surfaceElevated, in: Capsule())
    }

    private var serveLabel: String {
        engine.mode == .sideOut ? "SRV \(engine.serverNumber)" : "SRV"
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
