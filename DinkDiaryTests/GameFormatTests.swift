import XCTest
@testable import DinkDiary

final class GameFormatTests: XCTestCase {

    func testStandardCompletion() {
        let format = GameFormat.standard // to 11, win by 2
        XCTAssertTrue(format.isComplete(myScore: 11, theirScore: 9))
        XCTAssertTrue(format.isComplete(myScore: 12, theirScore: 10)) // deuce
        XCTAssertTrue(format.isComplete(myScore: 9, theirScore: 11))  // a loss is still finished
        XCTAssertFalse(format.isComplete(myScore: 11, theirScore: 10)) // won by one
        XCTAssertFalse(format.isComplete(myScore: 10, theirScore: 8))  // never reached target
        XCTAssertFalse(format.isComplete(myScore: 0, theirScore: 0))
    }

    func testOtherTargets() {
        let to15 = GameFormat(scoringType: .rally, targetPoints: 15, winBy: 2)
        XCTAssertFalse(to15.isComplete(myScore: 11, theirScore: 9))
        XCTAssertTrue(to15.isComplete(myScore: 15, theirScore: 13))
    }

    func testIncompleteReason() {
        let format = GameFormat.standard
        XCTAssertEqual(format.incompleteReason(myScore: 10, theirScore: 8), "First to 11.")
        XCTAssertEqual(format.incompleteReason(myScore: 11, theirScore: 10), "Win by 2.")
        XCTAssertNil(format.incompleteReason(myScore: 11, theirScore: 9))
    }
}
