import StickerPop
import SwiftUI

/// The gallery and Home sample as a Mac app: `swift run StickerPopDemo`.
/// On iOS, add the package to an app and show `PopGallery()`.
@main
struct StickerPopDemoApp: App {
    init() { StickerPopFonts.register() }

    var body: some Scene {
        WindowGroup("Sticker Pop") {
            DemoRoot().frame(minWidth: 400, idealWidth: 420, minHeight: 760, idealHeight: 860)
        }
    }
}

struct DemoRoot: View {
    @State private var home = false

    var body: some View {
        if home {
            PopHomeSample().overlay(alignment: .topTrailing) {
                PopTextButton("Back to gallery", underline: true) { home = false }.padding()
            }
        } else {
            PopGallery { home = true }
        }
    }
}
