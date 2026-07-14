import Foundation
import CoreLocation
import WeatherKit

/// Current conditions for a session, captured once at the start. Best-effort:
/// any failure (no entitlement yet, offline) just means no weather chip.
enum WeatherFetcher {
    static func current(at location: CLLocation) async -> (symbolName: String, temperatureC: Double)? {
        guard let weather = try? await WeatherService.shared.weather(for: location) else { return nil }
        let now = weather.currentWeather
        return (now.symbolName, now.temperature.converted(to: .celsius).value)
    }
}
