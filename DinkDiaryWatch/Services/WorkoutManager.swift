import Foundation
import HealthKit

/// Wraps each session in a pickleball workout so heart rate and calories are
/// captured for free. The watch owns the workout; its UUID rides the session-end
/// payload so the phone can read the numbers back. All calls are best-effort:
/// if HealthKit is unavailable or unauthorized, scoring still works, there's just
/// no health data.
final class WorkoutManager: NSObject {
    static let shared = WorkoutManager()

    private let healthStore = HKHealthStore()
    private var session: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?

    func requestAuthorization() async {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        let share: Set = [HKObjectType.workoutType()]
        let read: Set<HKObjectType> = [
            HKQuantityType(.heartRate),
            HKQuantityType(.activeEnergyBurned),
        ]
        try? await healthStore.requestAuthorization(toShare: share, read: read)
    }

    func start() {
        guard HKHealthStore.isHealthDataAvailable(), session == nil else { return }

        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .pickleball
        configuration.locationType = .outdoor

        guard let session = try? HKWorkoutSession(healthStore: healthStore, configuration: configuration) else { return }
        let builder = session.associatedWorkoutBuilder()
        builder.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: configuration)

        self.session = session
        self.builder = builder

        let start = Date()
        session.startActivity(with: start)
        builder.beginCollection(withStart: start) { _, _ in }
    }

    /// Ends the workout and returns its UUID (nil if none was running).
    func end() async -> UUID? {
        guard let session, let builder else { return nil }
        self.session = nil
        self.builder = nil

        session.end()
        await withCheckedContinuation { continuation in
            builder.endCollection(withEnd: Date()) { _, _ in continuation.resume() }
        }
        let workout = try? await builder.finishWorkout()
        return workout?.uuid
    }
}
