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

    var session: Session? = nil
    var myPartner: Player? = nil          // nil = singles or partner not recorded
    var opponents: [Player]? = nil        // 0-2, enforced in code not schema

    init(myScore: Int = 0,
         theirScore: Int = 0,
         scoringType: ScoringType = .sideOut,
         orderIndex: Int = 0,
         playedAt: Date = .now) {
        self.remoteID = UUID()
        self.playedAt = playedAt
        self.orderIndex = orderIndex
        self.myScore = myScore
        self.theirScore = theirScore
        self.scoringTypeRaw = scoringType.rawValue
    }

    var didWin: Bool { myScore > theirScore }

    var scoringType: ScoringType {
        ScoringType(rawValue: scoringTypeRaw) ?? .sideOut
    }
}
