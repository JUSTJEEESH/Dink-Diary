import SwiftUI

/// A compact stat tile for the wrist summary grid: big rounded numeral over a
/// quiet caption. Empty value shows an en dash in textSecondary.
struct WatchStatTile: View {
    let value: String?
    let label: String
    var tint: Color = DD.Colors.textPrimary

    var body: some View {
        VStack(spacing: 2) {
            Text(value ?? "\u{2013}")
                .font(DD.Fonts.statSmall)
                .foregroundStyle(value == nil ? DD.Colors.textSecondary : tint)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text(label).ddCaption()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            DD.Colors.surfaceElevated,
            in: .rect(cornerRadius: DD.Radius.gameRow, style: .continuous)
        )
    }
}
