import SwiftUI

extension DD {
    /// Typography per design/tokens/typography.md.
    /// All stat styles are SF Rounded with tabular digits so score ticks never jiggle layout.
    enum Fonts {
        // Stat styles (SF Rounded, monospaced digits)
        static let scoreboard = Font.system(size: 96, weight: .heavy, design: .rounded).monospacedDigit()
        static let statLarge = Font.system(size: 64, weight: .bold, design: .rounded).monospacedDigit()
        static let statMedium = Font.system(size: 44, weight: .bold, design: .rounded).monospacedDigit()
        static let statSmall = Font.system(size: 28, weight: .bold, design: .rounded).monospacedDigit()
        /// Small rounded-bold numerals inside badges and chips.
        static let statBadge = Font.system(size: 13, weight: .bold, design: .rounded).monospacedDigit()

        // UI styles (SF Pro)
        static let largeTitle = Font.system(size: 34, weight: .bold)
        static let title1 = Font.system(size: 28, weight: .bold)
        static let title3 = Font.system(size: 20, weight: .semibold)
        static let headline = Font.system(size: 17, weight: .semibold)
        static let body = Font.system(size: 15, weight: .regular)
        static let footnote = Font.system(size: 13, weight: .regular)
        static let caption = Font.system(size: 11, weight: .medium)

        // Watch styles (actual pt, 46mm)
        static let watchScore = Font.system(size: 80, weight: .heavy, design: .rounded).monospacedDigit()
        static let watchConfirm = Font.system(size: 55, weight: .heavy, design: .rounded).monospacedDigit()
    }
}

/// Caption style per typography.md: 11pt medium, UPPERCASE, +0.08em tracking,
/// always textSecondary. Labels are never bold and never brighter than textSecondary.
struct DDCaptionStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(DD.Fonts.caption)
            .textCase(.uppercase)
            .tracking(0.88)
            .foregroundStyle(DD.Colors.textSecondary)
    }
}

extension View {
    func ddCaption() -> some View {
        modifier(DDCaptionStyle())
    }
}
