#if DEBUG
import Foundation
import SwiftData

/// DEBUG-only sample season so any screen can be screenshotted with rich data
/// without playing 40 games. Wired to a debug button on the Sessions tab.
enum SampleData {
    static func seed(into context: ModelContext) {
        let me = Player(name: "You", isMe: true)
        let sarah = Player(name: "Sarah Miller")
        let mike = Player(name: "Mike Kim")
        let dave = Player(name: "Dave Lopez")
        let jen = Player(name: "Jen Ruiz")
        [me, sarah, mike, dave, jen].forEach { context.insert($0) }

        let sunset = Court(name: "Sunset Park")
        context.insert(sunset)

        // Two nights, most recent first when sorted by startedAt.
        seedSession(
            into: context,
            court: sunset,
            daysAgo: 2,
            results: [
                (11, 7, sarah, [dave, mike]),
                (9, 11, mike, [sarah, dave]),
                (11, 4, dave, [sarah, mike]),
                (11, 8, sarah, [jen, mike]),
                (7, 11, jen, [sarah, dave]),
            ]
        )
        seedSession(
            into: context,
            court: sunset,
            daysAgo: 0,
            results: [
                (11, 9, mike, [dave, jen]),
                (11, 6, sarah, [dave, jen]),
                (11, 3, dave, [mike, jen]),
            ]
        )
    }

    private static func seedSession(
        into context: ModelContext,
        court: Court,
        daysAgo: Int,
        results: [(Int, Int, Player, [Player])]
    ) {
        let start = Date.now.addingTimeInterval(TimeInterval(-daysAgo * 86_400))
        let session = Session(startedAt: start)
        session.court = court
        context.insert(session)

        for (index, result) in results.enumerated() {
            let (mine, theirs, partner, opponents) = result
            let game = Game(
                myScore: mine,
                theirScore: theirs,
                scoringType: .sideOut,
                orderIndex: index,
                playedAt: start.addingTimeInterval(TimeInterval(index * 600))
            )
            game.session = session
            game.myPartner = partner
            game.opponents = opponents
            context.insert(game)
        }
        session.endedAt = start.addingTimeInterval(TimeInterval(results.count * 600))
    }
}
#endif
