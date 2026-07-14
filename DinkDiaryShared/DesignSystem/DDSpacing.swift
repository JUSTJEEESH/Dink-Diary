import SwiftUI

extension DD {
    /// 4pt base grid per components.md.
    enum Spacing {
        static let grid: CGFloat = 4
        /// Screen edge gutter.
        static let gutter: CGFloat = 20
        /// Standard card padding.
        static let cardPadding: CGFloat = 18
        /// Trophy recap card padding.
        static let trophyPadding: CGFloat = 24
        /// Gap between sibling cards.
        static let cardGap: CGFloat = 12
        /// Gap between rows.
        static let rowGap: CGFloat = 8
    }

    /// Continuous corners everywhere; radius steps down with nesting,
    /// a child is never rounder than its parent.
    enum Radius {
        static let trophy: CGFloat = 28
        static let sessionCard: CGFloat = 22
        static let statTile: CGFloat = 18
        static let gameRow: CGFloat = 16
        static let pill: CGFloat = 999
    }
}
