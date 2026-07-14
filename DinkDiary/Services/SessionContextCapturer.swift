import Foundation
import SwiftData

/// When a phone session starts, quietly capture where you are and what it's like
/// out: the court (matched or created) and the current weather. Best-effort and
/// non-blocking; the user can still name the court by hand.
enum SessionContextCapturer {
    @MainActor
    static func capture(sessionID: UUID, container: ModelContainer) async {
        guard let location = await LocationManager.shared.current() else { return }

        let context = container.mainContext
        guard let session = try? context.fetch(
            FetchDescriptor<Session>(predicate: #Predicate { $0.remoteID == sessionID })
        ).first else { return }

        if session.court == nil {
            session.court = await CourtLocator.court(for: location, in: context)
        }
        if session.weatherSymbolName == nil,
           let weather = await WeatherFetcher.current(at: location) {
            session.weatherSymbolName = weather.symbolName
            session.weatherTemperatureC = weather.temperatureC
        }
        try? context.save()
    }
}
