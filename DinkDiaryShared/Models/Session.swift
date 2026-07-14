import Foundation
import SwiftData

/// The atomic unit of Dink Diary: one outing, many games. Health numbers and
/// weather are captured *facts* copied from HealthKit/WeatherKit at ingest
/// (M3/M4), not derived stats, so timeline cards render without round-trips.
@Model
final class Session {
    var remoteID: UUID = UUID()
    var startedAt: Date = Date.now
    var endedAt: Date? = nil
    var court: Court? = nil

    var weatherSymbolName: String? = nil
    var weatherTemperatureC: Double? = nil

    var healthKitWorkoutID: UUID? = nil
    var activeMinutes: Double? = nil
    var activeCalories: Double? = nil
    var peakHeartRate: Double? = nil

    /// "phone" or "watch"; where the session originated.
    var sourceRaw: String = "phone"

    @Relationship(deleteRule: .cascade, inverse: \Game.session)
    var games: [Game]? = nil

    init(startedAt: Date = .now, sourceRaw: String = "phone") {
        self.remoteID = UUID()
        self.startedAt = startedAt
        self.sourceRaw = sourceRaw
    }

    /// Games in play order.
    var gamesInOrder: [Game] {
        (games ?? []).sorted { $0.orderIndex < $1.orderIndex }
    }
}
