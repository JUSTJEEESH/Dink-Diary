import SwiftUI

extension DD.Colors {
    /// Partner avatar tints. Coral is deliberately excluded here; it is reserved
    /// for the nemesis (colors.md), assigned explicitly, never by rotation.
    static let avatarPalette: [Color] = [courtBlue, kitchenGreen, streak, accentWin]

    static func avatarTint(seed: Int) -> Color {
        avatarPalette[abs(seed) % avatarPalette.count]
    }
}
