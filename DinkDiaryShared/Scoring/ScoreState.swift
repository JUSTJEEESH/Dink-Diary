import Foundation

/// Which side of the net. On the watch, `us` is always the wearer.
enum Team: String, Codable, Equatable {
    case us
    case them

    var opponent: Team { self == .us ? .them : .us }
}

/// A complete snapshot of a game's scoring state. ~40 bytes, Codable, so the
/// undo stack is just an array of these and the watch can persist the whole
/// engine to disk after every tap for crash/wrist-drop recovery.
struct ScoreState: Codable, Equatable {
    var mode: ScoringType
    var usScore: Int = 0
    var themScore: Int = 0
    var servingTeam: Team = .us
    /// 1 or 2 in side-out doubles; unused (stays 1) in single-server rally.
    var serverNumber: Int = 2
    var targetPoints: Int = 11
    var winBy: Int = 2

    init(mode: ScoringType,
         servingTeam: Team = .us,
         targetPoints: Int = 11,
         winBy: Int = 2) {
        self.mode = mode
        self.servingTeam = servingTeam
        // Side-out doubles starts 0-0-2: the first serving team gets one server
        // before the first side-out. Rally is single-server, so start at 1.
        self.serverNumber = (mode == .sideOut) ? 2 : 1
        self.targetPoints = targetPoints
        self.winBy = winBy
    }
}
