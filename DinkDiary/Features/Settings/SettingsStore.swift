import Foundation
import Observation

/// The default game format, set once and used for every new game the phone and
/// (via the same rules) the watch create. Persisted in UserDefaults.
@Observable
final class SettingsStore {
    static let shared = SettingsStore()

    private let typeKey = "dd.format.scoringType"
    private let targetKey = "dd.format.target"
    private let nameKey = "dd.player.name"

    var scoringType: ScoringType {
        didSet { UserDefaults.standard.set(scoringType.rawValue, forKey: typeKey) }
    }
    var targetPoints: Int {
        didSet { UserDefaults.standard.set(targetPoints, forKey: targetKey) }
    }
    /// The reader's first name, used only to warm up the home greeting. Empty
    /// means "no name yet"; the greeting gracefully drops it.
    var playerName: String {
        didSet { UserDefaults.standard.set(playerName, forKey: nameKey) }
    }
    /// Standard pickleball; not user-adjustable in v1.
    let winBy = 2

    private init() {
        let rawType = UserDefaults.standard.string(forKey: typeKey) ?? ""
        scoringType = ScoringType(rawValue: rawType) ?? .sideOut
        let savedTarget = UserDefaults.standard.integer(forKey: targetKey)
        targetPoints = GameFormat.targetOptions.contains(savedTarget) ? savedTarget : 11
        playerName = UserDefaults.standard.string(forKey: nameKey) ?? ""
    }

    /// Just the first token, trimmed, for the greeting.
    var firstName: String {
        playerName.split(separator: " ").first.map(String.init) ?? ""
    }

    var defaultFormat: GameFormat {
        GameFormat(scoringType: scoringType, targetPoints: targetPoints, winBy: winBy)
    }
}
