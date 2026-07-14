import SwiftUI

/// Win moment per components.md: one restrained bounce on a record numeral
/// (scale 1 -> 1.06 -> 1, ~320ms spring). Honors Reduce Motion by doing nothing.
struct WinBounce: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    var active: Bool

    @State private var scale: CGFloat = 1

    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .onAppear {
                guard active, !reduceMotion else { return }
                withAnimation(.spring(response: 0.32, dampingFraction: 0.55)) {
                    scale = 1.06
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                    withAnimation(.spring(response: 0.30, dampingFraction: 0.72)) {
                        scale = 1
                    }
                }
            }
    }
}

/// Navigation entrance per components.md: content fades in with a 10px upward
/// drift, 240ms ease-out. Reduce Motion drops the drift and just fades.
struct ContentEntrance: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var shown = false

    func body(content: Content) -> some View {
        content
            .opacity(shown ? 1 : 0)
            .offset(y: shown || reduceMotion ? 0 : 10)
            .onAppear {
                withAnimation(.easeOut(duration: DD.Motion.navFade)) { shown = true }
            }
    }
}

extension View {
    func winBounce(active: Bool) -> some View { modifier(WinBounce(active: active)) }
    func ddContentEntrance() -> some View { modifier(ContentEntrance()) }
    /// Scoreboard-style number roll for a changing value.
    func ddScoreRoll<V: Equatable>(_ value: V) -> some View {
        contentTransition(.numericText())
            .animation(.easeOut(duration: DD.Motion.scoreTick), value: value)
    }
}
