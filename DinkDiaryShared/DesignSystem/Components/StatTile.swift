import SwiftUI

/// Stat tile: quiet caption label above a big rounded numeral.
/// Numeral tint: textPrimary default, accentWin for win-rate and celebration,
/// kitchenGreen for health, courtBlue for informational.
/// Empty state keeps the label and shows an en dash in textSecondary.
struct StatTile: View {
    let label: String
    /// nil renders the empty state.
    var value: String? = nil
    var tint: Color = DD.Colors.textPrimary

    var body: some View {
        VStack(alignment: .leading, spacing: DD.Spacing.grid) {
            Text(label).ddCaption()
            Text(value ?? "\u{2013}")
                .font(DD.Fonts.statMedium)
                .foregroundStyle(value == nil ? DD.Colors.textSecondary : tint)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .ddScoreRoll(value)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            DD.Colors.surfaceElevated,
            in: .rect(cornerRadius: DD.Radius.statTile, style: .continuous)
        )
    }
}
