import SwiftUI

/// The "logged" beat, matched to the mock: an optic check badge, "Logged.", the
/// specific game just recorded, then Next game (optic) with End session below.
/// Auto-advances to the next game after ~2s; End session cancels that.
struct LoggedView: View {
    let lastGame: WatchGame?
    let gameNumber: Int
    var onNext: () -> Void
    var onEnd: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: DD.Spacing.cardGap) {
                Image(systemName: "checkmark")
                    .font(Font.system(size: 30, weight: .bold))
                    .foregroundStyle(DD.Colors.accentWin)
                    .frame(width: 72, height: 72)
                    .background(DD.Colors.accentWin.opacity(0.16), in: Circle())

                Text("Logged.")
                    .font(DD.Fonts.title3)
                    .foregroundStyle(DD.Colors.textPrimary)

                if let detail = detailLine {
                    Text(detail)
                        .font(DD.Fonts.footnote)
                        .foregroundStyle(DD.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                }

                Button(action: onNext) {
                    Text("Next game")
                        .font(DD.Fonts.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(DDPillButtonStyle(variant: .primary))

                Button(action: onEnd) {
                    Text("End session")
                        .font(DD.Fonts.headline)
                        .foregroundStyle(DD.Colors.textSecondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, DD.Spacing.rowGap)
            .padding(.vertical, DD.Spacing.cardGap)
        }
        .background(DD.Colors.watchCanvas)
        .task {
            try? await Task.sleep(for: .seconds(2))
            onNext()
        }
    }

    private var detailLine: String? {
        guard let game = lastGame else { return nil }
        let result = game.didWin ? "W" : "L"
        let score = "\(game.myScore)-\(game.theirScore)"
        let withText: String
        if let name = game.partnerName, !name.isEmpty {
            let first = name.split(separator: " ").first.map(String.init) ?? name
            withText = " with \(first)"
        } else {
            withText = ""
        }
        return "\(result) \(score)\(withText) \u{00B7} game \(gameNumber)"
    }
}
