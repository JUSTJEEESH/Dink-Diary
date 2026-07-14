import SwiftUI

/// W/L pill per the colors.md recipe:
/// W = optic fill with surface-colored text. L = coral text on coral at 14%.
/// A loss is a rivalry, not a failure; coral never reads as "error".
struct WinLossPill: View {
    let didWin: Bool
    /// Optional score suffix, e.g. "11-7" renders as "W 11-7".
    var score: String? = nil

    private var label: String {
        let letter = didWin ? "W" : "L"
        if let score {
            return "\(letter) \(score)"
        }
        return letter
    }

    var body: some View {
        Text(label)
            .font(DD.Fonts.statBadge)
            .foregroundStyle(didWin ? DD.Colors.surface : DD.Colors.accentLoss)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                didWin ? DD.Colors.accentWin : DD.Colors.accentLoss.opacity(0.14),
                in: Capsule()
            )
    }
}
