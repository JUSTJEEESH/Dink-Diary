import XCTest
import SwiftData
@testable import DinkDiary

final class StatsEngineTests: XCTestCase {

    /// In-memory SwiftData context so model objects and relationships behave
    /// exactly as they do in the app.
    private func makeContext() throws -> ModelContext {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: Player.self, Court.self, Session.self, Game.self,
            configurations: configuration
        )
        return ModelContext(container)
    }

    func testRecord() throws {
        let context = try makeContext()
        let wins = [Game(myScore: 11, theirScore: 7), Game(myScore: 11, theirScore: 5)]
        let losses = [Game(myScore: 9, theirScore: 11)]
        (wins + losses).forEach { context.insert($0) }

        let record = StatsEngine.record(in: wins + losses)
        XCTAssertEqual(record.wins, 2)
        XCTAssertEqual(record.losses, 1)
    }

    func testRecordWithPartner() throws {
        let context = try makeContext()
        let sarah = Player(name: "Sarah")
        context.insert(sarah)

        let g1 = Game(myScore: 11, theirScore: 7); g1.myPartner = sarah
        let g2 = Game(myScore: 8, theirScore: 11); g2.myPartner = sarah
        let g3 = Game(myScore: 11, theirScore: 3) // no partner
        [g1, g2, g3].forEach { context.insert($0) }

        let record = StatsEngine.record(withPartner: sarah, in: [g1, g2, g3])
        XCTAssertEqual(record.wins, 1)
        XCTAssertEqual(record.losses, 1)
    }

    func testRecordAgainstOpponent() throws {
        let context = try makeContext()
        let dave = Player(name: "Dave")
        context.insert(dave)

        let g1 = Game(myScore: 3, theirScore: 11); g1.opponents = [dave]
        let g2 = Game(myScore: 6, theirScore: 11); g2.opponents = [dave]
        let g3 = Game(myScore: 11, theirScore: 4) // dave not playing
        [g1, g2, g3].forEach { context.insert($0) }

        let record = StatsEngine.record(against: dave, in: [g1, g2, g3])
        XCTAssertEqual(record.wins, 0)
        XCTAssertEqual(record.losses, 2)
    }

    func testCurrentWinStreakNewestFirst() throws {
        let context = try makeContext()
        let win1 = Game(myScore: 11, theirScore: 5)
        let win2 = Game(myScore: 11, theirScore: 9)
        let loss = Game(myScore: 7, theirScore: 11)
        [win1, win2, loss].forEach { context.insert($0) }

        // Newest first: win2, win1, loss -> streak of 2.
        XCTAssertEqual(StatsEngine.currentWinStreak(in: [win2, win1, loss]), 2)
        // A leading loss means no streak.
        XCTAssertEqual(StatsEngine.currentWinStreak(in: [loss, win2, win1]), 0)
    }
}
