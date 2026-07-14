import SwiftUI
import UIKit
import Combine

/// Year in Review as a story, the way people already know: tap the right side to
/// advance, the left to go back, hold to pause, swipe down to close. Segments at
/// the top fill as each slide plays and auto-advances. Smooth cross-fades, a
/// spring entrance on each headline. Ends on a shareable card.
struct SeasonRecapView: View {
    let stats: SeasonStats
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var index = 0
    @State private var elapsed = 0.0
    @State private var paused = false
    @State private var showingShare = false

    private let slideDuration = 3.6
    private let tick = 0.03
    private let timer = Timer.publish(every: 0.03, on: .main, in: .common).autoconnect()

    private var isLast: Bool { index >= slides.count - 1 }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                LinearGradient(colors: [DD.Colors.gradientTop, DD.Colors.surface], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                StorySlideView(slide: slides[index], reduceMotion: reduceMotion)
                    .id(index)
                    .transition(.opacity)

                VStack(spacing: DD.Spacing.cardGap) {
                    progressBar
                    Spacer()
                    if isLast {
                        PillButton(title: "Share your season") { showingShare = true }
                            .transition(.opacity)
                    }
                }
                .padding(DD.Spacing.gutter)
            }
            .contentShape(Rectangle())
            .gesture(storyGesture(width: geo.size.width))
            .animation(.easeInOut(duration: 0.28), value: index)
        }
        .onReceive(timer) { _ in advance() }
        .sheet(isPresented: $showingShare) {
            SeasonRecapShareSheet(stats: stats)
        }
    }

    private var progressBar: some View {
        HStack(spacing: 4) {
            ForEach(slides.indices, id: \.self) { i in
                GeometryReader { seg in
                    Capsule().fill(DD.Colors.textSecondary.opacity(0.3))
                        .overlay(alignment: .leading) {
                            Capsule()
                                .fill(DD.Colors.accentWin)
                                .frame(width: seg.size.width * fill(for: i))
                        }
                }
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

    private func fill(for i: Int) -> CGFloat {
        if i < index { return 1 }
        if i > index { return 0 }
        return isLast ? 1 : min(1, elapsed / slideDuration)
    }

    // MARK: Playback

    private func advance() {
        guard !paused, !isLast else { return }
        elapsed += tick
        if elapsed >= slideDuration { goNext() }
    }

    private func goNext() {
        guard index < slides.count - 1 else { return }
        index += 1
        elapsed = 0
        bump()
    }

    private func goPrev() {
        index = max(0, index - 1)
        elapsed = 0
        bump()
    }

    private func bump() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    private func storyGesture(width: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { _ in paused = true }
            .onEnded { value in
                paused = false
                if value.translation.height > 100 {
                    dismiss()
                    return
                }
                let moved = abs(value.translation.width) + abs(value.translation.height)
                if moved < 12 {
                    if value.startLocation.x < width * 0.33 { goPrev() } else { goNext() }
                }
            }
    }

    // MARK: Slides

    private var slides: [Slide] {
        var result: [Slide] = [
            Slide(kicker: "Your season", big: stats.periodLabel, tint: DD.Colors.accentWin, isNumeric: false, caption: "Buckle up. It was a year."),
            Slide(kicker: "You played", big: "\(stats.gamesPlayed)", caption: gamesCaption),
            Slide(kicker: "Your record", big: "\(stats.wins)-\(stats.losses)", tint: stats.wins >= stats.losses ? DD.Colors.accentWin : DD.Colors.textPrimary, caption: recordCaption),
        ]
        if let name = stats.topPartnerName, let record = stats.topPartnerRecord {
            result.append(Slide(kicker: "Your person", big: firstName(name), tint: DD.Colors.accentWin, isNumeric: false, caption: "\(record.wins)-\(record.losses) together. Chemistry, certified."))
        }
        if let name = stats.nemesisName, let record = stats.nemesisRecord {
            result.append(Slide(kicker: "Your rivalry", big: firstName(name), tint: DD.Colors.accentLoss, isNumeric: false, caption: "\(record.wins)-\(record.losses) against. We don't talk about it. One day."))
        }
        if let court = stats.topCourtName {
            result.append(Slide(kicker: "Your home court", big: court, isNumeric: false, caption: stats.topCourtSessions == 1 ? "One night here. A start." : "\(stats.topCourtSessions) sessions here. They should charge you rent."))
        }
        if stats.longestStreak >= 2 {
            result.append(Slide(kicker: "Your best run", big: "\(stats.longestStreak)", tint: DD.Colors.streak, caption: "wins in a row. Absolutely nobody was safe."))
        }
        if stats.totalCalories > 0 {
            result.append(Slide(kicker: "You burned", big: "\(stats.totalCalories)", tint: DD.Colors.kitchenGreen, caption: "calories. That's a lot of post-game tacos, earned."))
        }
        if stats.peopleCount > 0 {
            result.append(Slide(kicker: "Your world", big: "\(stats.peopleCount)", caption: stats.peopleCount == 1 ? "person put up with you." : "people put up with you. A whole crew."))
        }
        result.append(Slide(kicker: "That's your season", big: "\(stats.wins)-\(stats.losses)", tint: stats.wins >= stats.losses ? DD.Colors.accentWin : DD.Colors.textPrimary, caption: "Screenshot it. Flex responsibly."))
        return result
    }

    private var gamesCaption: String {
        stats.sessionsPlayed == 1 ? "games in one glorious session." : "games across \(stats.sessionsPlayed) sessions. Who has the time? You do."
    }

    private var recordCaption: String {
        stats.wins >= stats.losses ? "Every one of them, remembered." : "A losing record is just a rivalry with the whole sport."
    }

    private func firstName(_ name: String) -> String {
        name.split(separator: " ").first.map(String.init) ?? name
    }

    struct Slide: Identifiable {
        let id = UUID()
        let kicker: String
        let big: String
        var tint: Color = DD.Colors.textPrimary
        var isNumeric = true
        let caption: String
    }
}

/// One story slide, with a spring entrance on its headline.
private struct StorySlideView: View {
    let slide: SeasonRecapView.Slide
    let reduceMotion: Bool
    @State private var appeared = false

    var body: some View {
        VStack(spacing: DD.Spacing.cardGap) {
            Spacer()
            Text(slide.kicker)
                .font(DD.Fonts.caption)
                .textCase(.uppercase)
                .tracking(1)
                .foregroundStyle(DD.Colors.textSecondary)
                .opacity(appeared ? 1 : 0)
            Text(slide.big)
                .font(slide.isNumeric ? DD.Fonts.scoreboard : DD.Fonts.largeTitle)
                .foregroundStyle(slide.tint)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.4)
                .scaleEffect(appeared || reduceMotion ? 1 : 0.85)
                .opacity(appeared ? 1 : 0)
            Text(slide.caption)
                .font(DD.Fonts.title3)
                .foregroundStyle(DD.Colors.textPrimary)
                .multilineTextAlignment(.center)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared || reduceMotion ? 0 : 8)
            Spacer()
            Spacer()
        }
        .padding(.horizontal, DD.Spacing.gutter)
        .onAppear {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) { appeared = true }
        }
    }
}
