import SwiftUI

/// M0 static mock of the scoring face, proving the wrist canvas and type:
/// pure black OLED canvas, 80pt rounded-heavy numerals, bottom half is the
/// wearer in optic, serve pill pinned top, mode chip pinned bottom.
/// The real tap targets and engine arrive in the watch scoring milestone.
struct MockScoringFaceView: View {
    var body: some View {
        ZStack {
            DD.Colors.watchCanvas.ignoresSafeArea()

            VStack(spacing: 0) {
                Text("9")
                    .font(DD.Fonts.watchScore)
                    .foregroundStyle(DD.Colors.textPrimary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                Text("11")
                    .font(DD.Fonts.watchScore)
                    .foregroundStyle(DD.Colors.accentWin)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            VStack {
                Text("SRV 2")
                    .font(DD.Fonts.statBadge)
                    .foregroundStyle(DD.Colors.accentWin)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(DD.Colors.accentWin.opacity(0.14), in: Capsule())
                Spacer()
                Text("SIDE OUT")
                    .font(DD.Fonts.caption)
                    .foregroundStyle(DD.Colors.textSecondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(DD.Colors.surfaceElevated, in: Capsule())
            }
        }
    }
}
