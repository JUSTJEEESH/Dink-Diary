import SwiftUI

/// The signature detail: a 1px kitchen line spanning padding-to-padding with a
/// centered 1x7 tick (the "T"). One per card, max; only on cards that summarize
/// play. Never on the watch scoring face, never as a generic divider.
struct KitchenLineMotif: View {
    /// Empty states dim the motif.
    var dimmed: Bool = false
    /// Share cards scale up: 2px line, 12px tick at 9:16 export.
    var lineHeight: CGFloat = 1
    var tickHeight: CGFloat = 7

    private var color: Color {
        dimmed ? DD.Colors.motifDimmed : DD.Colors.motifLine
    }

    var body: some View {
        Rectangle()
            .fill(color)
            .frame(height: lineHeight)
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(color)
                    .frame(width: lineHeight, height: tickHeight)
            }
            .accessibilityHidden(true)
    }
}
