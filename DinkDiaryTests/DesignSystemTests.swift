import XCTest
@testable import DinkDiary

/// M0 smoke tests: the test target links and the token layer holds its rules.
/// ScoreEngine and StatsEngine tests arrive with the data model milestone.
final class DesignSystemTests: XCTestCase {

    /// Radius steps down with nesting; a child is never rounder than its parent.
    func testRadiusNestingOrder() {
        XCTAssertGreaterThan(DD.Radius.trophy, DD.Radius.sessionCard)
        XCTAssertGreaterThan(DD.Radius.sessionCard, DD.Radius.statTile)
        XCTAssertGreaterThan(DD.Radius.statTile, DD.Radius.gameRow)
    }

    /// Hard rule from the brief: no motion token exceeds 400ms.
    func testMotionCap() {
        let durations: [TimeInterval] = [
            DD.Motion.pressIn,
            DD.Motion.pressOut,
            DD.Motion.scoreTick,
            DD.Motion.winBounce,
            DD.Motion.navFade,
        ]
        for duration in durations {
            XCTAssertLessThanOrEqual(duration, 0.40)
        }
    }
}
