import Foundation
import Observation

/// The default game format, set once and used for every new game the phone and
/// (via the same rules) the watch create. Persisted in UserDefaults.
@Observable
final class SettingsStore {
    static let shared = SettingsStore()

    private let typeKey = "dd.format.scoringType"
    private let targetKey = "dd.format.target"

    var scoringType: ScoringType {
        didSet { UserDefaults.standard.set(scoringType.rawValue, forKey: typeKey) }
    }
    var targetPoints: Int {
        didSet { UserDefaults.standard.set(targetPoints, forKey: targetKey) }
    }
    /// Standard pickleball; not user-adjustable in v1.
    let winBy = 2

    private init() {
        let rawType = UserDefaults.standard.string(forKey: typeKey) ?? ""
        scoringType = ScoringType(rawValue: rawType) ?? .sideOut
        let savedTarget = UserDefaults.standard.integer(forKey: targetKey)
        targetPoints = GameFormat.targetOptions.contains(savedTarget) ? savedTarget : 11
    }

    var defaultFormat: GameFormat {
        GameFormat(scoringType: scoringType, targetPoints: targetPoints, winBy: winBy)
    }
}
