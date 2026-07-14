import SwiftUI

extension DD {
    /// Motion tokens per components.md. Hard rule from the brief:
    /// nothing anywhere exceeds 0.40s.
    enum Motion {
        static let pressIn: TimeInterval = 0.12
        static let pressOut: TimeInterval = 0.18
        static let scoreTick: TimeInterval = 0.16
        static let winBounce: TimeInterval = 0.32
        static let navFade: TimeInterval = 0.24
        /// Press scale for cards and buttons.
        static let pressScale: CGFloat = 0.97
        /// Press scale for rows.
        static let rowPressScale: CGFloat = 0.98
    }
}

/// Standard press behavior: scale 0.97 (0.98 on rows), 120ms in / 180ms out,
/// ease-out both ways. Respects Reduce Motion by dropping the scale change.
struct DDPressStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    var scale: CGFloat = DD.Motion.pressScale

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && !reduceMotion ? scale : 1)
            .animation(
                .easeOut(duration: configuration.isPressed ? DD.Motion.pressIn : DD.Motion.pressOut),
                value: configuration.isPressed
            )
    }
}

/// Press style for tappable cards and rows: scale only, preserving the card's
/// own background. Use `scale: DD.Motion.rowPressScale` on rows.
struct DDCardButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    var scale: CGFloat = DD.Motion.pressScale

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && !reduceMotion ? scale : 1)
            .animation(
                .easeOut(duration: configuration.isPressed ? DD.Motion.pressIn : DD.Motion.pressOut),
                value: configuration.isPressed
            )
    }
}
