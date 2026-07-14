import Foundation

/// Pure scoring engine for both modes. All rule logic lives in the two private
/// `apply…` functions, so the 2026 provisional rally rules being in flux is a
/// one-function change with the tests right beside it. Snapshot-stack undo:
/// one `popLast()` reverses any outcome (point, server change, side-out) with
/// no inverse-rule logic.
struct ScoreEngine: Codable, Equatable {
    private(set) var state: ScoreState
    private var history: [ScoreState] = []
    private static let maxHistory = 256

    init(mode: ScoringType,
         servingTeam: Team = .us,
         targetPoints: Int = 11,
         winBy: Int = 2) {
        self.state = ScoreState(mode: mode,
                                servingTeam: servingTeam,
                                targetPoints: targetPoints,
                                winBy: winBy)
    }

    // MARK: Read

    var usScore: Int { state.usScore }
    var themScore: Int { state.themScore }
    var servingTeam: Team { state.servingTeam }
    var serverNumber: Int { state.serverNumber }
    var mode: ScoringType { state.mode }
    var canUndo: Bool { !history.isEmpty }

    var isGameOver: Bool {
        let high = max(state.usScore, state.themScore)
        return high >= state.targetPoints && abs(state.usScore - state.themScore) >= state.winBy
    }

    var winner: Team? {
        guard isGameOver else { return nil }
        return state.usScore > state.themScore ? .us : .them
    }

    // MARK: Mutate

    /// Manual scoreboard entry: give a point directly to a team, every tap. The
    /// team that scores serves next; if they weren't already serving, they take
    /// serve as first server. This is what the watch face uses so one tap always
    /// scores. (`rallyWon` keeps the full rules engine for any future auto mode.)
    mutating func addPoint(to team: Team) {
        guard !isGameOver else { return }
        pushHistory()
        if team != state.servingTeam {
            state.servingTeam = team
            state.serverNumber = 1
        }
        score(team)
    }

    mutating func rallyWon(by team: Team) {
        guard !isGameOver else { return }
        pushHistory()
        switch state.mode {
        case .sideOut: applySideOut(rallyWonBy: team)
        case .rally: applyRally(rallyWonBy: team)
        }
    }

    @discardableResult
    mutating func undo() -> Bool {
        guard let previous = history.popLast() else { return false }
        state = previous
        return true
    }

    // MARK: Rules

    private mutating func applySideOut(rallyWonBy team: Team) {
        if team == state.servingTeam {
            // Only the serving team scores; the same server keeps serving.
            score(team)
        } else if state.serverNumber == 1 {
            // First server lost: partner (second server) now serves.
            state.serverNumber = 2
        } else {
            // Second server lost: side-out to the other team's first server.
            state.servingTeam = state.servingTeam.opponent
            state.serverNumber = 1
        }
    }

    private mutating func applyRally(rallyWonBy team: Team) {
        // Every rally scores for its winner; a receiver win also takes serve.
        score(team)
        if team != state.servingTeam {
            state.servingTeam = team
        }
    }

    private mutating func score(_ team: Team) {
        if team == .us { state.usScore += 1 } else { state.themScore += 1 }
    }

    private mutating func pushHistory() {
        history.append(state)
        if history.count > Self.maxHistory {
            history.removeFirst(history.count - Self.maxHistory)
        }
    }
}
