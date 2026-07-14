import SwiftUI
import UIKit
import UniformTypeIdentifiers

/// A PNG the system share sheet can hand to Messages, Instagram, Photos, etc.
struct ShareableImage: Transferable {
    let image: UIImage
    let filename: String

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .png) { shareable in
            shareable.image.pngData() ?? Data()
        }
        .suggestedFileName { "\($0.filename).png" }
    }
}

/// Preview the recap in both frames and share it. The card renders at full
/// 1080-wide resolution for export, scaled to fit for the on-screen preview.
struct ShareCardSheet: View {
    let session: Session
    @Environment(\.dismiss) private var dismiss

    enum Frame: String, CaseIterable, Identifiable {
        case story = "Story"
        case square = "Square"
        var id: String { rawValue }
        var exportSize: CGSize {
            switch self {
            case .story: return CGSize(width: 1080, height: 1920)
            case .square: return CGSize(width: 1080, height: 1080)
            }
        }
    }

    @State private var frame: Frame = .story

    var body: some View {
        NavigationStack {
            VStack(spacing: DD.Spacing.gutter) {
                framePicker

                GeometryReader { geo in
                    let target = frame.exportSize
                    let scale = min(geo.size.width / target.width, geo.size.height / target.height)
                    ShareCardView(session: session, size: target)
                        .frame(width: target.width, height: target.height)
                        .scaleEffect(scale)
                        .frame(width: target.width * scale, height: target.height * scale)
                        .clipShape(.rect(cornerRadius: DD.Radius.sessionCard, style: .continuous))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }

                shareButton
            }
            .padding(DD.Spacing.gutter)
            .background(DD.Colors.surface)
            .navigationTitle("Share")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(DD.Colors.textSecondary)
                }
            }
        }
    }

    private var framePicker: some View {
        HStack(spacing: 0) {
            ForEach(Frame.allCases) { option in
                Button {
                    frame = option
                } label: {
                    Text(option.rawValue)
                        .font(DD.Fonts.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .foregroundStyle(frame == option ? DD.Colors.surface : DD.Colors.textSecondary)
                        .background(frame == option ? DD.Colors.accentWin : Color.clear, in: Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(DD.Colors.surfaceElevated, in: Capsule())
    }

    @ViewBuilder
    private var shareButton: some View {
        if let shareable = makeShareable() {
            ShareLink(
                item: shareable,
                preview: SharePreview("Dink Diary", image: Image(uiImage: shareable.image))
            ) {
                Text("Share")
                    .font(DD.Fonts.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
            }
            .buttonStyle(DDPillButtonStyle(variant: .primary))
        }
    }

    @MainActor
    private func makeShareable() -> ShareableImage? {
        let renderer = ImageRenderer(content: ShareCardView(session: session, size: frame.exportSize))
        renderer.scale = 1
        guard let image = renderer.uiImage else { return nil }
        return ShareableImage(image: image, filename: "dink-diary-recap")
    }
}
