import XCTest
@testable import DinkDiary

final class ScoreEngineTests: XCTestCase {

    // MARK: Side-out

    /// Only the serving team scores; a receiver win never adds a point.
    func testSideOutOnlyServerScores() {
        var engine = ScoreEngine(mode: .sideOut, servingTeam: .us)
        engine.rallyWon(by: .them) // receiver wins: side-out, no point (started 0-0-2)
        XCTAssertEqual(engine.usScore, 0)
        XCTAssertEqual(engine.themScore, 0)
        XCTAssertEqual(engine.servingTeam, .them)
        engine.rallyWon(by: .them) // serving team wins: point
        XCTAssertEqual(engine.themScore, 1)
    }

    /// Server 1 -> server 2 (same team) -> side-out to the other team's server 1.
    func testSideOutServerProgression() {
        var engine = ScoreEngine(mode: .sideOut, servingTeam: .us) // starts server 2
        engine.rallyWon(by: .them) // us server 2 loses -> side out to them, server 1
        XCTAssertEqual(engine.servingTeam, .them)
        XCTAssertEqual(engine.serverNumber, 1)
        engine.rallyWon(by: .us)   // them server 1 loses -> them server 2
        XCTAssertEqual(engine.servingTeam, .them)
        XCTAssertEqual(engine.serverNumber, 2)
        engine.rallyWon(by: .us)   // them server 2 loses -> side out to us, server 1
        XCTAssertEqual(engine.servingTeam, .us)
        XCTAssertEqual(engine.serverNumber, 1)
    }

    // MARK: Rally

    /// Every rally scores for its winner; a receiver win also takes serve.
    func testRallyEveryRallyScores() {
        var engine = ScoreEngine(mode: .rally, servingTeam: .us)
        engine.rallyWon(by: .them)
        XCTAssertEqual(engine.themScore, 1)
        XCTAssertEqual(engine.servingTeam, .them)
        engine.rallyWon(by: .them)
        XCTAssertEqual(engine.themScore, 2)
    }

    // MARK: Undo

    func testUndoReversesAnyOutcome() {
        var engine = ScoreEngine(mode: .rally, servingTeam: .us)
        engine.rallyWon(by: .us)
        engine.rallyWon(by: .them)
        let us = engine.usScore, them = engine.themScore, serving = engine.servingTeam
        engine.rallyWon(by: .them)
        XCTAssertTrue(engine.undo())
        XCTAssertEqual(engine.usScore, us)
        XCTAssertEqual(engine.themScore, them)
        XCTAssertEqual(engine.servingTeam, serving)
    }

    func testUndoOnFreshGameReturnsFalse() {
        var engine = ScoreEngine(mode: .sideOut)
        XCTAssertFalse(engine.canUndo)
        XCTAssertFalse(engine.undo())
    }

    // MARK: Game over

    func testGameOverAtTargetWithLead() {
        var engine = ScoreEngine(mode: .rally, servingTeam: .us, targetPoints: 11, winBy: 2)
        for _ in 0..<10 { engine.rallyWon(by: .us) } // 10-0
        XCTAssertFalse(engine.isGameOver)
        engine.rallyWon(by: .us) // 11-0
        XCTAssertTrue(engine.isGameOver)
        XCTAssertEqual(engine.winner, .us)
    }

    func testMustWinByTwo() {
        var engine = ScoreEngine(mode: .rally, servingTeam: .us, targetPoints: 11, winBy: 2)
        for _ in 0..<10 { engine.rallyWon(by: .us) }   // 10-0
        for _ in 0..<10 { engine.rallyWon(by: .them) } // 10-10
        XCTAssertFalse(engine.isGameOver)
        engine.rallyWon(by: .us) // 11-10
        XCTAssertFalse(engine.isGameOver)
        engine.rallyWon(by: .us) // 12-10
        XCTAssertTrue(engine.isGameOver)
        XCTAssertEqual(engine.winner, .us)
    }

    /// No scoring past game over.
    func testFrozenAfterGameOver() {
        var engine = ScoreEngine(mode: .rally, servingTeam: .us, targetPoints: 11, winBy: 2)
        for _ in 0..<11 { engine.rallyWon(by: .us) } // 11-0, over
        engine.rallyWon(by: .them)
        XCTAssertEqual(engine.themScore, 0)
    }
}
