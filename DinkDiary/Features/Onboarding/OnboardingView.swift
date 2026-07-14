import SwiftUI

/// First-run intro: three pages in the brand voice, then into the app. Warm,
/// never coaching. No permission prompts here; those come in context later.
struct OnboardingView: View {
    var onDone: () -> Void

    @State private var page = 0

    private struct Page {
        let symbol: String
        let title: String
        let body: String
    }

    private let pages: [Page] = [
        Page(symbol: "", title: "Every game, remembered.", body: "Your pickleball life, on record. The sessions, the people, the courts, the streaks."),
        Page(symbol: "figure.pickleball", title: "The session, not the match.", body: "You show up, play a bunch, rotate partners, leave sweaty. Dink Diary keeps the whole night."),
        Page(symbol: "person.2.fill", title: "Your people. Your courts. Your season.", body: "Who you win with, who you chase, and where it all happens. It adds up on its own."),
    ]

    var body: some View {
        ZStack {
            LinearGradient(colors: [DD.Colors.gradientTop, DD.Colors.surface], startPoint: .top, endPoint: .center)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                TabView(selection: $page) {
                    ForEach(pages.indices, id: \.self) { index in
                        pageView(pages[index]).tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))

                PillButton(title: page == pages.count - 1 ? "Start" : "Next") {
                    if page == pages.count - 1 {
                        onDone()
                    } else {
                        withAnimation(.easeOut(duration: DD.Motion.navFade)) { page += 1 }
                    }
                }
                .padding(.horizontal, DD.Spacing.gutter)
                .padding(.bottom, DD.Spacing.gutter)
            }
        }
    }

    private func pageView(_ page: Page) -> some View {
        VStack(spacing: DD.Spacing.gutter) {
            Spacer()
            emblem(page.symbol)
            VStack(spacing: DD.Spacing.cardGap) {
                Text(page.title)
                    .font(DD.Fonts.largeTitle)
                    .foregroundStyle(DD.Colors.textPrimary)
                    .multilineTextAlignment(.center)
                Text(page.body)
                    .font(DD.Fonts.body)
                    .foregroundStyle(DD.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            Spacer()
            Spacer()
        }
        .padding(.horizontal, DD.Spacing.gutter)
    }

    @ViewBuilder
    private func emblem(_ symbol: String) -> some View {
        ZStack {
            Circle()
                .fill(DD.Colors.accentWin)
                .frame(width: 120, height: 120)
                .blur(radius: 44)
                .opacity(0.32)
            Circle()
                .fill(DD.Colors.accentWin)
                .frame(width: 96, height: 96)
            if !symbol.isEmpty {
                Image(systemName: symbol)
                    .font(Font.system(size: 40, weight: .bold))
                    .foregroundStyle(DD.Colors.surface)
            }
        }
    }
}
