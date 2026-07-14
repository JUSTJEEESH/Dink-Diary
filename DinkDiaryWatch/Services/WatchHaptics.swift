import WatchKit

/// Wrist haptics per components.md: a click on every score tap (so you never
/// look mid-rally), success on game confirm, retry on undo.
enum WatchHaptics {
    static func tap() { WKInterfaceDevice.current().play(.click) }
    static func confirm() { WKInterfaceDevice.current().play(.success) }
    static func undo() { WKInterfaceDevice.current().play(.retry) }
}
