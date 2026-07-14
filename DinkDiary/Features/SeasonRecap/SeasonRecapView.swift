import SwiftUI

/// Year in Review, told as a run of full-screen slides you swipe through, ending
/// on a shareable card. Warm and celebratory; a losing record is a rivalry, a
/// season is a story.
struct SeasonRecapView: View {
    let stats: SeasonStats
    @Environment(\.dismiss) private var dismiss
    @State private var index = 0
    @State private var showingShare = false

    private struct Slide: Identifiable {
        let id = UUID()
        let kicker: String
        let big: String
        var tint: Color = DD.Colors.textPrimary
        var isNumeric = true
        let caption: String
    }

    var body: some View {
        ZStack {
            LinearGradient(colors: [DD.Colors.gradientTop, DD.Colors.surface], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            TabView(selection: $index) {
                ForEach(Array(slides.enumerated()), id: \.element.id) { offset, slide in
                    slideView(slide, active: offset == index).tag(offset)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            VStack {
                progressBar
                Spacer()
                controls
            }
            .padding(DD.Spacing.gutter)
        }
        .sheet(isPresented: $showingShare) {
            SeasonRecapShareSheet(stats: stats)
        }
    }

    private var progressBar: some View {
        HStack(spacing: 4) {
            ForEach(slides.indices, id: \.self) { i in
                Capsule()
                    .fill(i <= index ? DD.Colors.accentWin : DD.Colors.textSecondary.opacity(0.3))
                    .frame(height: 3)
            }
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(Font.system(size: 14, weight: .semibold))
                    .foregroundStyle(DD.Colors.textSecondary)
            }
            .padding(.leading, DD.Spacing.rowGap)
        }
    }

    @ViewBuilder
    private var controls: some View {
        if index == slides.count - 1 {
            PillButton(title: "Share your season") { showingShare = true }
        } else {
            PillButton(title: "Next") {
                withAnimation(.easeOut(duration: DD.Motion.navFade)) { index += 1 }
            }
        }
    }

    private func slideView(_ slide: Slide, active: Bool) -> some View {
        VStack(spacing: DD.Spacing.cardGap) {
            Spacer()
            Text(slide.kicker)
                .font(DD.Fonts.caption)
                .textCase(.uppercase)
                .tracking(1)
                .foregroundStyle(DD.Colors.textSecondary)
            Text(slide.big)
                .font(slide.isNumeric ? DD.Fonts.scoreboard : DD.Fonts.largeTitle)
                .foregroundStyle(slide.tint)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.4)
                .scaleEffect(active ? 1 : 0.92)
                .opacity(active ? 1 : 0.5)
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: active)
            Text(slide.caption)
                .font(DD.Fonts.title3)
                .foregroundStyle(DD.Colors.textPrimary)
                .multilineTextAlignment(.center)
            Spacer()
            Spacer()
        }
        .padding(.horizontal, DD.Spacing.gutter)
    }

    private var slides: [Slide] {
        var result: [Slide] = [
            Slide(kicker: "Your season", big: stats.periodLabel, tint: DD.Colors.accentWin, isNumeric: false, caption: "Here's how it went."),
            Slide(kicker: "You played", big: "\(stats.gamesPlayed)", caption: gamesCaption),
            Slide(kicker: "Your record", big: "\(stats.wins)-\(stats.losses)", tint: stats.wins >= stats.losses ? DD.Colors.accentWin : DD.Colors.textPrimary, caption: "Every one of them, remembered."),
        ]
        if let name = stats.topPartnerName, let record = stats.topPartnerRecord {
            result.append(Slide(kicker: "Your person", big: firstName(name), tint: DD.Colors.accentWin, isNumeric: false, caption: "\(record.wins)-\(record.losses) together."))
        }
        if let name = stats.nemesisName, let record = stats.nemesisRecord {
            result.append(Slide(kicker: "Your rivalry", big: firstName(name), tint: DD.Colors.accentLoss, isNumeric: false, caption: "\(record.wins)-\(record.losses) against. One day."))
        }
        if let court = stats.topCourtName {
            result.append(Slide(kicker: "Your home court", big: court, isNumeric: false, caption: stats.topCourtSessions == 1 ? "1 session here." : "\(stats.topCourtSessions) sessions here."))
        }
        if stats.longestStreak >= 2 {
            result.append(Slide(kicker: "Your best run", big: "\(stats.longestStreak)", tint: DD.Colors.streak, caption: "wins in a row. You were the problem."))
        }
        if stats.totalCalories > 0 {
            result.append(Slide(kicker: "You burned", big: "\(stats.totalCalories)", tint: DD.Colors.kitchenGreen, caption: "calories chasing the ball."))
        }
        if stats.peopleCount > 0 {
            result.append(Slide(kicker: "Your world", big: "\(stats.peopleCount)", caption: stats.peopleCount == 1 ? "person you shared the court with." : "people you shared the court with."))
        }
        result.append(Slide(kicker: "That's your season", big: "\(stats.wins)-\(stats.losses)", tint: stats.wins >= stats.losses ? DD.Colors.accentWin : DD.Colors.textPrimary, caption: "Share it, or go make next season."))
        return result
    }

    private var gamesCaption: String {
        stats.sessionsPlayed == 1 ? "games in 1 session." : "games across \(stats.sessionsPlayed) sessions."
    }

    private func firstName(_ name: String) -> String {
        name.split(separator: " ").first.map(String.init) ?? name
    }
}
