import SwiftUI

/// A big rounded numeral with minus/plus controls, for entering a final score.
struct ScoreStepper: View {
    let label: String
    @Binding var value: Int

    var body: some View {
        VStack(spacing: DD.Spacing.rowGap) {
            Text(label).ddCaption()

            Text("\(value)")
                .font(DD.Fonts.statMedium)
                .foregroundStyle(DD.Colors.textPrimary)

            HStack(spacing: DD.Spacing.cardGap) {
                stepButton(symbol: "minus") {
                    if value > 0 { value -= 1 }
                }
                stepButton(symbol: "plus") {
                    value += 1
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(DD.Spacing.cardPadding)
        .background(
            DD.Colors.surfaceElevated,
            in: .rect(cornerRadius: DD.Radius.statTile, style: .continuous)
        )
    }

    private func stepButton(symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(Font.system(size: 16, weight: .bold))
                .foregroundStyle(DD.Colors.textPrimary)
                .frame(width: 40, height: 40)
                .background(DD.Colors.surfacePressed, in: Circle())
        }
        .buttonStyle(.plain)
    }
}
