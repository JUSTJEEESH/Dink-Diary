import SwiftUI
import SwiftData
import MapKit
import UIKit

/// Your courts: a map of everywhere you've played, then a card per place with
/// your record there. Auto detection by location fills coordinates; you can also
/// rename a court and give it a photo.
struct CourtsHomeView: View {
    @Query(sort: \Court.name) private var courts: [Court]

    private var playedCourts: [Court] {
        courts.filter { $0.isAlive && !StatsEngine.games(atCourt: $0).isEmpty }
    }

    private var mapCourts: [Court] {
        playedCourts.filter { $0.coordinate != nil }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                DD.Colors.surface.ignoresSafeArea()

                if playedCourts.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        VStack(spacing: DD.Spacing.cardGap) {
                            if !mapCourts.isEmpty { mapHeader }
                            ForEach(playedCourts) { court in
                                NavigationLink(value: court) {
                                    CourtCardView(court: court)
                                }
                                .buttonStyle(DDCardButtonStyle())
                            }
                        }
                        .padding(.horizontal, DD.Spacing.gutter)
                        .padding(.top, DD.Spacing.rowGap)
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationTitle("Your courts")
            .navigationDestination(for: Court.self) { court in
                CourtDetailView(court: court)
            }
            .toolbarBackground(DD.Colors.surface, for: .navigationBar)
        }
    }

    private var mapHeader: some View {
        NavigationLink {
            CourtsMapView(courts: playedCourts)
        } label: {
            ZStack(alignment: .bottomLeading) {
                Map(initialPosition: .automatic, interactionModes: []) {
                    ForEach(mapCourts) { court in
                        if let coordinate = court.coordinate {
                            Marker(court.name, coordinate: coordinate)
                                .tint(DD.Colors.accentWin)
                        }
                    }
                }
                .frame(height: 172)
                .allowsHitTesting(false)

                LinearGradient(
                    colors: [.clear, .black.opacity(0.55)],
                    startPoint: .center, endPoint: .bottom
                )

                HStack(spacing: DD.Spacing.rowGap) {
                    Image(systemName: "map.fill")
                        .font(Font.system(size: 15, weight: .bold))
                    Text(mapCourts.count == 1 ? "1 place on the map" : "\(mapCourts.count) places on the map")
                        .font(DD.Fonts.headline)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(Font.system(size: 13, weight: .semibold))
                }
                .foregroundStyle(.white)
                .padding(DD.Spacing.cardPadding)
            }
            .frame(height: 172)
            .clipShape(.rect(cornerRadius: DD.Radius.sessionCard, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: DD.Radius.sessionCard, style: .continuous)
                    .strokeBorder(DD.Colors.hairline, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var emptyState: some View {
        VStack(spacing: DD.Spacing.cardGap) {
            Image(systemName: "mappin.and.ellipse")
                .font(Font.system(size: 28, weight: .semibold))
                .foregroundStyle(DD.Colors.textSecondary)
            Text("Courts show up when you play.")
                .font(DD.Fonts.body)
                .foregroundStyle(DD.Colors.textSecondary)
        }
        .padding(DD.Spacing.gutter)
    }
}

struct CourtCardView: View {
    let court: Court

    private var record: (wins: Int, losses: Int) {
        StatsEngine.record(in: StatsEngine.games(atCourt: court))
    }
    private var sessionCount: Int { (court.sessions ?? []).count }
    private var isWinning: Bool { record.wins > record.losses }
    private var photo: UIImage? { court.photoData.flatMap(UIImage.init(data:)) }

    var body: some View {
        HStack(spacing: DD.Spacing.cardGap) {
            VStack(alignment: .leading, spacing: 4) {
                Text(court.name)
                    .font(DD.Fonts.title3)
                    .foregroundStyle(hasPhoto ? .white : DD.Colors.textPrimary)
                    .lineLimit(1)
                Text(sessionCount == 1 ? "1 session" : "\(sessionCount) sessions")
                    .font(DD.Fonts.footnote)
                    .foregroundStyle(hasPhoto ? Color.white.opacity(0.85) : DD.Colors.textSecondary)
            }
            Spacer()
            Text("\(record.wins)-\(record.losses)")
                .font(DD.Fonts.statMedium)
                .foregroundStyle(isWinning ? DD.Colors.accentWin : (hasPhoto ? .white : DD.Colors.textPrimary))
        }
        .padding(DD.Spacing.cardPadding)
        .frame(maxWidth: .infinity, minHeight: hasPhoto ? 100 : nil, alignment: hasPhoto ? .bottomLeading : .leading)
        .background(cardBackground)
        .clipShape(.rect(cornerRadius: DD.Radius.sessionCard, style: .continuous))
    }

    private var hasPhoto: Bool { photo != nil }

    @ViewBuilder
    private var cardBackground: some View {
        if let photo {
            ZStack {
                Image(uiImage: photo)
                    .resizable()
                    .scaledToFill()
                LinearGradient(colors: [.black.opacity(0.15), .black.opacity(0.65)], startPoint: .top, endPoint: .bottom)
            }
        } else {
            DD.Colors.surfaceElevated
        }
    }
}
