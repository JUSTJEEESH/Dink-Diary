import SwiftUI
import SwiftData
import PhotosUI
import UIKit

/// Rename a court and give it a photo (the court, the crew, the view). The photo
/// is downscaled and compressed before it is stored.
struct CourtEditSheet: View {
    @Bindable var court: Court
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var pickerItem: PhotosPickerItem?
    @State private var working = false

    private var photo: UIImage? { court.photoData.flatMap(UIImage.init(data:)) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DD.Spacing.gutter) {
                    VStack(alignment: .leading, spacing: DD.Spacing.cardGap) {
                        Text("Name").ddCaption()
                        TextField("Court name", text: $court.name)
                            .font(DD.Fonts.headline)
                            .foregroundStyle(DD.Colors.textPrimary)
                            .padding(.horizontal, DD.Spacing.cardPadding)
                            .padding(.vertical, 12)
                            .background(DD.Colors.surfaceElevated, in: Capsule())
                    }

                    VStack(alignment: .leading, spacing: DD.Spacing.cardGap) {
                        Text("Photo").ddCaption()
                        if let photo {
                            Image(uiImage: photo)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 200)
                                .frame(maxWidth: .infinity)
                                .clipShape(.rect(cornerRadius: DD.Radius.sessionCard, style: .continuous))
                        }
                        HStack(spacing: DD.Spacing.cardGap) {
                            PhotosPicker(selection: $pickerItem, matching: .images) {
                                Label(photo == nil ? "Add a photo" : "Change photo", systemImage: "photo")
                                    .font(DD.Fonts.headline)
                                    .foregroundStyle(DD.Colors.accentWin)
                            }
                            if photo != nil {
                                Spacer()
                                Button(role: .destructive) {
                                    court.photoData = nil
                                    try? context.save()
                                } label: {
                                    Text("Remove").font(DD.Fonts.headline)
                                }
                            }
                        }
                    }
                }
                .padding(DD.Spacing.gutter)
            }
            .background(DD.Colors.surface)
            .navigationTitle("Edit court")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        try? context.save()
                        dismiss()
                    }
                    .foregroundStyle(DD.Colors.accentWin)
                }
            }
            .onChange(of: pickerItem) { _, item in
                guard let item else { return }
                working = true
                Task { await load(item) }
            }
        }
    }

    private func load(_ item: PhotosPickerItem) async {
        defer { working = false }
        guard
            let data = try? await item.loadTransferable(type: Data.self),
            let image = UIImage(data: data),
            let compressed = CourtEditSheet.downscaledJPEG(image, maxDimension: 1200)
        else { return }
        await MainActor.run {
            court.photoData = compressed
            try? context.save()
        }
    }

    /// Fit within a max dimension and JPEG-compress, so stored photos stay small.
    static func downscaledJPEG(_ image: UIImage, maxDimension: CGFloat, quality: CGFloat = 0.7) -> Data? {
        let longest = max(image.size.width, image.size.height)
        let scale = longest > maxDimension ? maxDimension / longest : 1
        let target = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: target)
        let resized = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: target))
        }
        return resized.jpegData(compressionQuality: quality)
    }
}
