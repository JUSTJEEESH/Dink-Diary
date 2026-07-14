#if DEBUG
import Foundation
import SwiftData

/// DEBUG-only sample season so any screen can be screenshotted with rich data
/// without playing 40 games. Deliberately crosses several milestone thresholds
/// (25 games, 3 courts, 10 people, a 6-game win streak) so the Moments list, the
/// season recap, storylines, and an "on this day" memory all have something to
/// show. Wired to a debug button on the Sessions tab.
enum SampleData {
    static func seed(into context: ModelContext) {
        let sarah = Player(name: "Sarah Miller")
        let mike = Player(name: "Mike Kim")
        let dave = Player(name: "Dave Lopez")
        let jen = Player(name: "Jen Ruiz")
        let alex = Player(name: "Alex Chen")
        let sam = Player(name: "Sam Patel")
        let chris = Player(name: "Chris Diaz")
        let pat = Player(name: "Pat Novak")
        let lee = Player(name: "Lee Park")
        let robin = Player(name: "Robin Shaw")
        [Player(name: "You", isMe: true), sarah, mike, dave, jen, alex, sam, chris, pat, lee, robin]
            .forEach { context.insert($0) }

        let sunset = Court(name: "Sunset Park")
        let riverside = Court(name: "Riverside Courts")
        let lakeside = Court(name: "Lakeside Rec")
        [sunset, riverside, lakeside].forEach { context.insert($0) }

        // An "on this day" memory from a year back.
        seedSession(into: context, court: riverside, daysAgo: 365, results: [
            (11, 8, dave, [sarah, mike]),
            (11, 5, sarah, [dave, jen]),
            (9, 11, jen, [dave, mike]),
        ])

        // This season, oldest to newest.
        seedSession(into: context, court: sunset, daysAgo: 40, results: [
            (11, 7, sarah, [dave, mike]),
            (8, 11, dave, [sarah, jen]),
            (11, 4, alex, [sam, chris]),
            (11, 9, sarah, [pat, lee]),
        ])
        seedSession(into: context, court: lakeside, daysAgo: 21, results: [
            (11, 6, mike, [robin, lee]),
            (9, 11, dave, [sarah, jen]),
            (11, 8, sam, [chris, pat]),
            (11, 3, sarah, [dave, mike]),
        ])
        seedSession(into: context, court: riverside, daysAgo: 12, results: [
            (11, 6, sarah, [dave, jen]),
            (11, 8, sarah, [mike, jen]),
            (7, 11, mike, [sarah, dave]),
            (11, 9, alex, [robin, lee]),
        ])
        seedSession(into: context, court: sunset, daysAgo: 5, results: [
            (11, 7, sarah, [dave, mike]),
            (9, 11, dave, [sarah, jen]),
            (11, 4, sarah, [chris, pat]),
            (11, 8, sam, [jen, mike]),
            (7, 11, jen, [sarah, dave]),
        ])
        seedSession(into: context, court: lakeside, daysAgo: 2, results: [
            (11, 5, sarah, [dave, mike]),
            (8, 11, dave, [sarah, jen]),
            (11, 9, alex, [sam, chris]),
            (6, 11, dave, [robin, lee]),
        ])
        // A statement night: six straight, for the streak milestones.
        seedSession(into: context, court: sunset, daysAgo: 1, results: [
            (11, 7, sarah, [dave, mike]),
            (11, 5, sarah, [jen, alex]),
            (11, 9, mike, [dave, sam]),
            (11, 3, sarah, [chris, pat]),
            (11, 8, alex, [lee, robin]),
            (11, 6, sarah, [dave, jen]),
        ])
        seedSession(into: context, court: sunset, daysAgo: 0, results: [
            (9, 11, mike, [dave, jen]),
            (11, 6, sarah, [dave, jen]),
            (11, 3, dave, [mike, jen]),
        ])
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
        // Plausible health so the recap and trophy tiles fill in.
        session.activeMinutes = Double(30 + results.count * 6)
        session.activeCalories = Double(120 + results.count * 130)
        session.peakHeartRate = Double(148 + (results.count % 4) * 3)
        context.insert(session)

        for (index, result) in results.enumerated() {
            let (mine, theirs, partner, opponents) = result
            let game = Game(
                myScore: mine,
                theirScore: theirs,
                format: .standard,
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
