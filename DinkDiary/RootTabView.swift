import SwiftUI

enum DDTab: String, CaseIterable, Identifiable {
    case sessions
    case people
    case courts
    case insights
    #if DEBUG
    case gallery
    #endif

    var id: String { rawValue }

    var title: String {
        switch self {
        case .sessions: return "Sessions"
        case .people: return "People"
        case .courts: return "Courts"
        case .insights: return "Insights"
        #if DEBUG
        case .gallery: return "Gallery"
        #endif
        }
    }

    var symbol: String {
        switch self {
        case .sessions: return "calendar"
        case .people: return "person.2.fill"
        case .courts: return "mappin.and.ellipse"
        case .insights: return "chart.bar.fill"
        #if DEBUG
        case .gallery: return "paintpalette.fill"
        #endif
        }
    }
}

struct RootTabView: View {
    @State private var selected: DDTab = .sessions

    var body: some View {
        ZStack(alignment: .bottom) {
            DD.Colors.surface.ignoresSafeArea()

            Group {
                switch selected {
                case .sessions: SessionsHomeView()
                case .people: PeopleHomeView()
                case .courts: CourtsHomeView()
                case .insights: InsightsHomeView()
                #if DEBUG
                case .gallery: GalleryView()
                #endif
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            tabBar
        }
    }

    /// Floating pill tab bar per components.md: surfaceElevated at 0.92 over
    /// blur, hairline border. Active item: optic glyph + label on an
    /// optic-14% pill. Inactive: textSecondary glyph.
    private var tabBar: some View {
        HStack(spacing: 2) {
            ForEach(DDTab.allCases) { tab in
                tabItem(tab)
            }
        }
        .padding(6)
        .background {
            Capsule().fill(.ultraThinMaterial)
            Capsule().fill(DD.Colors.surfaceElevated.opacity(0.92))
            Capsule().strokeBorder(DD.Colors.hairline, lineWidth: 1)
        }
        .padding(.horizontal, DD.Spacing.gutter)
        .padding(.bottom, DD.Spacing.rowGap)
    }

    private func tabItem(_ tab: DDTab) -> some View {
        Button {
            selected = tab
        } label: {
            HStack(spacing: 6) {
                Image(systemName: tab.symbol)
                    .font(Font.system(size: 16, weight: .semibold))
                if selected == tab {
                    Text(tab.title)
                        .font(DD.Fonts.footnote.weight(.semibold))
                }
            }
            .foregroundStyle(selected == tab ? DD.Colors.accentWin : DD.Colors.textSecondary)
            .padding(.horizontal, selected == tab ? 14 : 10)
            .padding(.vertical, 10)
            .background(
                selected == tab ? DD.Colors.accentWin.opacity(0.14) : Color.clear,
                in: Capsule()
            )
        }
        .buttonStyle(.plain)
        .animation(.easeOut(duration: DD.Motion.navFade), value: selected)
        .accessibilityLabel(tab.title)
    }
}
