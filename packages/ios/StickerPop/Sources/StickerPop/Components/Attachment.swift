import SwiftUI

/// A place to attach a file, like a receipt photo. Empty, it is a dashed
/// tile (paper, 2 dashed ink outline, radius 18) with an icon, label and
/// caption; tapping it calls `onPick`, where you present the system picker.
/// Filled (`fileName` set), it is a white sticker with a thumbnail
/// (`preview`) or a file icon, the name, an optional size and a remove button.
public struct PopAttachmentTile: View {
    var label: String
    var caption: String
    var systemImage: String
    var fileName: String?
    var fileSize: String?
    var preview: Image?
    let onPick: () -> Void
    var onRemove: (() -> Void)?

    public init(label: String = "Add a receipt", caption: String = "Photo or PDF", systemImage: String = "camera.fill",
                fileName: String? = nil, fileSize: String? = nil, preview: Image? = nil,
                onPick: @escaping () -> Void, onRemove: (() -> Void)? = nil) {
        self.label = label
        self.caption = caption
        self.systemImage = systemImage
        self.fileName = fileName
        self.fileSize = fileSize
        self.preview = preview
        self.onPick = onPick
        self.onRemove = onRemove
    }

    public var body: some View {
        if let fileName {
            HStack(spacing: PopSpace.md) {
                ZStack {
                    PopColors.paper
                    if let preview { preview.resizable().scaledToFill() }
                    else { Image(systemName: "doc.text.fill").font(.system(size: 22, weight: .bold)).foregroundStyle(PopColors.ink) }
                }
                .frame(width: 48, height: 48)
                .clipShape(RoundedRectangle(cornerRadius: PopRadius.badge, style: .continuous))
                .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 0) {
                    PopText(fileName, PopTextSpecs.rowTitle).lineLimit(1).truncationMode(.middle)
                    if let fileSize { PopText(fileSize, PopTextSpecs.caption) }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                if let onRemove {
                    Button(action: onRemove) {
                        Image(systemName: "xmark").font(.system(size: 16, weight: .heavy)).foregroundStyle(PopColors.ink)
                            .frame(width: 44, height: 44).contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Remove \(fileName)")
                }
            }
            .padding(.leading, PopSpace.md).padding(.vertical, PopSpace.md).padding(.trailing, PopSpace.xs)
            .sticker(fill: PopColors.white, radius: PopRadius.tile, shadow: PopShadow.small)
        } else {
            Button(action: onPick) {
                VStack(spacing: 0) {
                    Image(systemName: systemImage).font(.system(size: 22, weight: .bold)).foregroundStyle(PopColors.ink)
                        .padding(.bottom, PopSpace.xs)
                    PopText(label, PopTextSpecs.tileLabel).multilineTextAlignment(.center)
                    PopText(caption, PopTextSpecs.caption).multilineTextAlignment(.center)
                }
                .padding(PopSpace.lg)
                .frame(maxWidth: .infinity, minHeight: 96)
                .background(
                    RoundedRectangle(cornerRadius: PopRadius.tile, style: .continuous).fill(PopColors.paper)
                        .overlay(RoundedRectangle(cornerRadius: PopRadius.tile, style: .continuous)
                            .inset(by: PopBorder.thin / 2)
                            .stroke(PopColors.ink, style: StrokeStyle(lineWidth: PopBorder.thin, dash: [7, 5])))
                )
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(label), \(caption)")
            .accessibilityAddTraits(.isButton)
        }
    }
}
