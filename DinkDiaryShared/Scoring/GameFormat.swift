import Foundation

/// The rules of a pickleball game: how you score, the target, and the win margin.
/// One shared definition so the watch's live scoring and the phone's manual entry
/// mean exactly the same thing, and every game remembers the format it was played
/// under.
struct GameFormat: Codable, Equatable {
    var scoringType: ScoringType
    var targetPoints: Int
    var winBy: Int

    static let standard = GameFormat(scoringType: .sideOut, targetPoints: 11, winBy: 2)

    /// Common rec targets. Games to 11 are standard; 15 and 21 cover longer play.
    static let targetOptions = [11, 15, 21]

    /// A valid, finished game: someone reached the target and won by the margin.
    func isComplete(myScore: Int, theirScore: Int) -> Bool {
        let high = max(myScore, theirScore)
        return high >= targetPoints && abs(myScore - theirScore) >= winBy
    }

    /// Why a score isn't a finished game yet, for a gentle nudge in entry.
    func incompleteReason(myScore: Int, theirScore: Int) -> String? {
        if isComplete(myScore: myScore, theirScore: theirScore) { return nil }
        let high = max(myScore, theirScore)
        if high < targetPoints {
            return "First to \(targetPoints)."
        }
        return "Win by \(winBy)."
    }

    var label: String {
        "\(scoringType.label) \u{00B7} to \(targetPoints)"
    }
}
