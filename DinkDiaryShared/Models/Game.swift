import Foundation
import SwiftData

/// One game within a session. `myScore`/`theirScore` are the final result;
/// derived stats are computed by StatsEngine, never stored here.
@Model
final class Game {
    var remoteID: UUID = UUID()
    var playedAt: Date = Date.now
    var orderIndex: Int = 0
    var myScore: Int = 0
    var theirScore: Int = 0
    var scoringTypeRaw: String = ScoringType.sideOut.rawValue
    // The format this game was played under, remembered per game (additive with
    // defaults, so existing stores migrate automatically).
    var targetPoints: Int = 11
    var winBy: Int = 2

    var session: Session? = nil
    var myPartner: Player? = nil          // nil = singles or partner not recorded
    var opponents: [Player]? = nil        // 0-2, enforced in code not schema

    init(myScore: Int = 0,
         theirScore: Int = 0,
         format: GameFormat = .standard,
         orderIndex: Int = 0,
         playedAt: Date = .now) {
        self.remoteID = UUID()
        self.playedAt = playedAt
        self.orderIndex = orderIndex
        self.myScore = myScore
        self.theirScore = theirScore
        self.scoringTypeRaw = format.scoringType.rawValue
        self.targetPoints = format.targetPoints
        self.winBy = format.winBy
    }

    var didWin: Bool { myScore > theirScore }

    var scoringType: ScoringType {
        ScoringType(rawValue: scoringTypeRaw) ?? .sideOut
    }

    var format: GameFormat {
        GameFormat(scoringType: scoringType, targetPoints: targetPoints, winBy: winBy)
    }
}
