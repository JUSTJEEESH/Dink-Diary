import Foundation
import HealthKit
import SwiftData

/// Reads the numbers off a watch workout and writes them onto the session.
/// HealthKit syncs watch to phone with a delay, so a session's workout may not be
/// readable the instant its end payload arrives; `enrichPending` re-tries any
/// session that still has a workout ID but no stats (call it on app launch/active).
enum HealthEnricher {
    private static let store = HKHealthStore()

    static func requestAuthorization() async {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        let read: Set<HKObjectType> = [
            HKObjectType.workoutType(),
            HKQuantityType(.heartRate),
            HKQuantityType(.activeEnergyBurned),
        ]
        try? await store.requestAuthorization(toShare: [], read: read)
    }

    @MainActor
    static func enrichPending(container: ModelContainer) async {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        let context = container.mainContext
        let descriptor = FetchDescriptor<Session>(
            predicate: #Predicate { $0.healthKitWorkoutID != nil && $0.activeMinutes == nil }
        )
        guard let pending = try? context.fetch(descriptor) else { return }

        for session in pending {
            guard let workoutID = session.healthKitWorkoutID,
                  let stats = await stats(forWorkout: workoutID) else { continue }
            session.activeMinutes = stats.minutes
            session.activeCalories = stats.calories
            session.peakHeartRate = stats.peakHeartRate
        }
        try? context.save()
    }

    private static func stats(forWorkout id: UUID) async -> (minutes: Double, calories: Double?, peakHeartRate: Double?)? {
        guard let workout = await workout(with: id) else { return nil }

        let minutes = workout.duration / 60
        let calories = workout.statistics(for: HKQuantityType(.activeEnergyBurned))?
            .sumQuantity()?
            .doubleValue(for: .kilocalorie())
        let peak = await peakHeartRate(from: workout.startDate, to: workout.endDate)
        return (minutes, calories, peak)
    }

    private static func workout(with id: UUID) async -> HKWorkout? {
        await withCheckedContinuation { continuation in
            let predicate = HKQuery.predicateForObjects(with: [id])
            let query = HKSampleQuery(
                sampleType: .workoutType(),
                predicate: predicate,
                limit: 1,
                sortDescriptors: nil
            ) { _, samples, _ in
                continuation.resume(returning: samples?.first as? HKWorkout)
            }
            store.execute(query)
        }
    }

    private static func peakHeartRate(from start: Date, to end: Date) async -> Double? {
        await withCheckedContinuation { continuation in
            let predicate = HKQuery.predicateForSamples(withStart: start, end: end)
            let query = HKStatisticsQuery(
                quantityType: HKQuantityType(.heartRate),
                quantitySamplePredicate: predicate,
                options: .discreteMax
            ) { _, statistics, _ in
                let unit = HKUnit.count().unitDivided(by: .minute())
                let bpm = statistics?.maximumQuantity()?.doubleValue(for: unit)
                continuation.resume(returning: bpm)
            }
            store.execute(query)
        }
    }
}
