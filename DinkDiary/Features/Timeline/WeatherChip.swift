import SwiftUI

/// The session's conditions, a tinted informational chip (courtBlue per colors.md).
/// Temperature is formatted to the viewer's locale unit.
struct WeatherChip: View {
    let symbolName: String
    let temperatureC: Double

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: symbolName)
                .font(Font.system(size: 11, weight: .medium))
            Text(Measurement(value: temperatureC, unit: UnitTemperature.celsius)
                .formatted(.measurement(width: .narrow, usage: .weather, numberFormatStyle: .number.precision(.fractionLength(0)))))
                .font(DD.Fonts.caption)
        }
        .foregroundStyle(DD.Colors.courtBlue)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(DD.Colors.courtBlue.opacity(0.14), in: Capsule())
    }
}
