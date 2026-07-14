import SwiftUI
import MapKit
import CoreLocation

extension Court {
    /// The court's coordinate, when we captured one.
    var coordinate: CLLocationCoordinate2D? {
        guard let latitude, let longitude else { return nil }
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

/// The full map of everywhere you've played: one tinted pin per court, each
/// tappable through to its page. A memory you can pan around. Navigation is
/// driven from this view's body (not from inside the annotation) because a Map
/// renders annotation content in its own layer, where a NavigationLink would
/// lose the navigation stack.
struct CourtsMapView: View {
    let courts: [Court]
    @State private var selected: Court?

    private var mapped: [Court] { courts.filter { $0.coordinate != nil } }

    var body: some View {
        ZStack {
            Map(initialPosition: .automatic) {
                ForEach(mapped) { court in
                    if let coordinate = court.coordinate {
                        Annotation(court.name, coordinate: coordinate) {
                            CourtPin(court: court)
                                .contentShape(Rectangle())
                                .onTapGesture { selected = court }
                        }
                    }
                }
            }
            .mapStyle(.standard(elevation: .realistic))
            .ignoresSafeArea(edges: .bottom)

            if mapped.isEmpty {
                emptyState
            }
        }
        .navigationTitle("Everywhere you've played")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $selected) { court in
            CourtDetailView(court: court)
        }
    }

    private var emptyState: some View {
        VStack(spacing: DD.Spacing.cardGap) {
            Image(systemName: "map")
                .font(Font.system(size: 28, weight: .semibold))
                .foregroundStyle(DD.Colors.textSecondary)
            Text("Courts land on the map once we know where you played.")
                .font(DD.Fonts.body)
                .foregroundStyle(DD.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(DD.Spacing.gutter)
        .background(DD.Colors.surface.opacity(0.9), in: .rect(cornerRadius: DD.Radius.sessionCard, style: .continuous))
        .padding(DD.Spacing.gutter)
    }
}

/// A map pin: a tinted teardrop with the court's win record, in the app's voice.
struct CourtPin: View {
    let court: Court

    private var record: (wins: Int, losses: Int) {
        StatsEngine.record(in: StatsEngine.games(atCourt: court))
    }
    private var isWinning: Bool { record.wins >= record.losses }
    private var tint: Color { isWinning ? DD.Colors.accentWin : DD.Colors.courtBlue }

    var body: some View {
        VStack(spacing: 2) {
            Text(court.name)
                .font(DD.Fonts.caption)
                .foregroundStyle(DD.Colors.textPrimary)
                .lineLimit(1)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(DD.Colors.surfaceElevated, in: Capsule())
                .overlay(Capsule().strokeBorder(tint.opacity(0.5), lineWidth: 1))

            Image(systemName: "mappin.circle.fill")
                .font(Font.system(size: 30, weight: .bold))
                .foregroundStyle(tint)
                .background(Circle().fill(DD.Colors.surface).padding(6))
                .shadow(color: .black.opacity(0.4), radius: 3, y: 1)
        }
    }
}
