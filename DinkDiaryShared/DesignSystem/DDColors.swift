import SwiftUI

/// Dink Diary design tokens. `DesignSystem/` is the ONLY place in the
/// codebase allowed to hold raw color, size, or duration values.
/// Source of truth: design/tokens/*.md (locked system 1a, "Night Match, athletic").
enum DD {}

extension DD {
    enum Colors {
        /// Base canvas, court at night.
        static let surface = Color("surface")
        /// Cards, sheets, rows.
        static let surfaceElevated = Color("surfaceElevated")
        /// Pressed fill, surface +1 step.
        static let surfacePressed = Color("surfacePressed")
        /// Warm off-white, all primary copy.
        static let textPrimary = Color("textPrimary")
        /// Labels, metadata, captions.
        static let textSecondary = Color("textSecondary")
        /// Optic ball. Wins, streak-adjacent, CTAs, "us" on the watch. The brand.
        static let accentWin = Color("accentWin")
        /// Pressed fill of optic CTAs.
        static let accentWinPressed = Color("accentWinPressed")
        /// Coral. Losses and nemesis moments ONLY; never a generic error red.
        static let accentLoss = Color("accentLoss")
        /// Hot hand, milestones.
        static let streak = Color("streak")
        /// Links, informational data (weather, HR).
        static let courtBlue = Color("courtBlue")
        /// Secondary data, health stats (min, cal).
        static let kitchenGreen = Color("kitchenGreen")
        /// Dividers, borders.
        static let hairline = Color("hairline")
        /// Kitchen-line motif, active.
        static let motifLine = Color("motifLine")
        /// Kitchen-line motif on empty states.
        static let motifDimmed = Color("motifDimmed")

        /// Top of the trophy / share-card gradient (deeper blue than surface).
        static let gradientTop = Color("gradientTop")

        /// The wrist scoring canvas is true black (OLED), never `surface`.
        static let watchCanvas = Color.black
    }

    /// Locked gradients per colors.md / components.md.
    enum Gradients {
        /// Trophy recap card: #10182A -> #141A24, top to bottom.
        static let trophy = LinearGradient(
            colors: [DD.Colors.gradientTop, DD.Colors.surfaceElevated],
            startPoint: .top,
            endPoint: .bottom
        )
        /// Share-card story gradient: #10182A -> #0A0E14, so it never reads pure black.
        static let shareCard = LinearGradient(
            colors: [DD.Colors.gradientTop, DD.Colors.surface],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
