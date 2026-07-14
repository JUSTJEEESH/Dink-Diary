import Foundation

/// Remembers which milestones the reader has already been shown, so a freshly
/// achieved one can pop a quiet celebration exactly once. On the very first run
/// it adopts all existing milestones silently, so we never celebrate history the
/// reader logged before the app was watching.
enum MilestoneSeenStore {
    private static let seenKey = "dd.milestones.seen"
    private static let initKey = "dd.milestones.initialized"

    /// Returns milestones not yet seen (empty on first ever run), and records
    /// everything given as seen.
    static func newlyAchieved(from milestones: [Milestone]) -> [Milestone] {
        let defaults = UserDefaults.standard
        let seen = Set(defaults.stringArray(forKey: seenKey) ?? [])
        let initialized = defaults.bool(forKey: initKey)
        let ids = milestones.map(\.id)

        defaults.set(Array(seen.union(ids)), forKey: seenKey)
        defaults.set(true, forKey: initKey)

        guard initialized else { return [] }
        return milestones.filter { !seen.contains($0.id) }
    }
}
