import SwiftUI
import MapKit
import CoreLocation
import UIKit

/// A court's page: an optional photo header, your record, where it sits on the
/// map, and the sessions you've played on it. Rename it or add a photo from the
/// edit button.
struct CourtDetailView: View {
    @Bindable var court: Court
    @State private var showingEdit = false

    private var sessions: [Session] {
        (court.sessions ?? []).sorted { $0.startedAt > $1.startedAt }
    }
    private var record: (wins: Int, losses: Int) {
        StatsEngine.record(in: StatsEngine.games(atCourt: court))
    }
    private var isWinning: Bool { record.wins > record.losses }
    private var photo: UIImage? { court.photoData.flatMap(UIImage.init(data:)) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DD.Spacing.cardGap) {
                if let photo {
                    Image(uiImage: photo)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                        .clipShape(.rect(cornerRadius: DD.Radius.sessionCard, style: .continuous))
                }

                HStack(alignment: .firstTextBaseline, spacing: DD.Spacing.rowGap) {
                    Text("\(record.wins)-\(record.losses)")
                        .font(DD.Fonts.statLarge)
                        .foregroundStyle(isWinning ? DD.Colors.accentWin : DD.Colors.textPrimary)
                    Text(sessions.count == 1 ? "1 session" : "\(sessions.count) sessions")
                        .font(DD.Fonts.footnote)
                        .foregroundStyle(DD.Colors.textSecondary)
                }
                .padding(.top, DD.Spacing.rowGap)

                if let coordinate = court.coordinate {
                    miniMap(coordinate)
                }

                ForEach(sessions) { session in
                    NavigationLink(value: session) {
                        SessionCardView(session: session)
                    }
                    .buttonStyle(DDCardButtonStyle())
                }
            }
            .padding(.horizontal, DD.Spacing.gutter)
            .padding(.bottom, 100)
        }
        .background(DD.Colors.surface)
        .navigationTitle(court.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingEdit = true
                } label: {
                    Image(systemName: "pencil")
                        .foregroundStyle(DD.Colors.accentWin)
                }
            }
        }
        .sheet(isPresented: $showingEdit) {
            CourtEditSheet(court: court)
        }
        .navigationDestination(for: Session.self) { session in
            SessionDetailView(session: session)
        }
    }

    private func miniMap(_ coordinate: CLLocationCoordinate2D) -> some View {
        Map(initialPosition: .region(MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        )), interactionModes: []) {
            Marker(court.name, coordinate: coordinate)
                .tint(DD.Colors.accentWin)
        }
        .frame(height: 150)
        .clipShape(.rect(cornerRadius: DD.Radius.sessionCard, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DD.Radius.sessionCard, style: .continuous)
                .strokeBorder(DD.Colors.hairline, lineWidth: 1)
        )
        .allowsHitTesting(false)
    }
}
