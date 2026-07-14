import Foundation
import CoreLocation
import SwiftData

/// Finds the court you're at, or creates one. Reuses an existing court within
/// ~150m; otherwise names a new one from the place (park, street, or locality).
enum CourtLocator {
    private static let matchRadius: CLLocationDistance = 150

    @MainActor
    static func court(for location: CLLocation, in context: ModelContext) async -> Court {
        let courts = ((try? context.fetch(FetchDescriptor<Court>())) ?? []).filter { $0.isAlive }

        var nearest: (court: Court, distance: CLLocationDistance)?
        for court in courts {
            guard let lat = court.latitude, let lon = court.longitude else { continue }
            let distance = location.distance(from: CLLocation(latitude: lat, longitude: lon))
            if distance <= matchRadius, nearest == nil || distance < nearest!.distance {
                nearest = (court, distance)
            }
        }
        if let nearest {
            return nearest.court
        }

        let court = Court(name: await placeName(for: location) ?? "New Court")
        court.latitude = location.coordinate.latitude
        court.longitude = location.coordinate.longitude
        context.insert(court)
        return court
    }

    private static func placeName(for location: CLLocation) async -> String? {
        guard let placemark = try? await CLGeocoder().reverseGeocodeLocation(location).first else { return nil }
        if let poi = placemark.name, !poi.isEmpty {
            return poi
        }
        if let locality = placemark.locality {
            return "Court in \(locality)"
        }
        return nil
    }
}
