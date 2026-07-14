import SwiftUI

/// Pill button per components.md. Primary: optic fill, surface text, darkens to
/// accentWinPressed and scales 0.97 on press. Secondary: warm-white 8% fill,
/// textSecondary label. Disabled: surfaceElevated fill, textSecondary label.
struct PillButton: View {
    enum Variant {
        case primary
        case secondary
    }

    let title: String
    var variant: Variant = .primary
    var height: CGFloat = 52
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(DD.Fonts.headline)
                .frame(maxWidth: .infinity)
                .frame(height: height)
        }
        .buttonStyle(DDPillButtonStyle(variant: variant))
    }
}

struct DDPillButtonStyle: ButtonStyle {
    var variant: PillButton.Variant = .primary
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(foreground)
            .background(background(pressed: configuration.isPressed), in: Capsule())
            .scaleEffect(configuration.isPressed && !reduceMotion ? DD.Motion.pressScale : 1)
            .animation(
                .easeOut(duration: configuration.isPressed ? DD.Motion.pressIn : DD.Motion.pressOut),
                value: configuration.isPressed
            )
    }

    private var foreground: Color {
        if !isEnabled { return DD.Colors.textSecondary }
        switch variant {
        case .primary: return DD.Colors.surface
        case .secondary: return DD.Colors.textSecondary
        }
    }

    private func background(pressed: Bool) -> Color {
        if !isEnabled { return DD.Colors.surfaceElevated }
        switch variant {
        case .primary:
            return pressed ? DD.Colors.accentWinPressed : DD.Colors.accentWin
        case .secondary:
            return DD.Colors.textPrimary.opacity(pressed ? 0.14 : 0.08)
        }
    }
}
