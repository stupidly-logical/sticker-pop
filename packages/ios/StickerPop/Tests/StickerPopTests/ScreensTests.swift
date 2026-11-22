#if os(iOS)
import SnapshotTesting
import SwiftUI
import XCTest
@testable import StickerPop

/// Screenshot tests on an iPhone-sized canvas, run with xcodebuild on an
/// iOS simulator (see .github/workflows/ci.yml). Missing reference images
/// are recorded on the first run; set SNAPSHOT_RECORD=1 to re-record all.
final class ScreensTests: XCTestCase {
    override func setUp() {
        super.setUp()
        StickerPopFonts.register()
    }

    override func invokeTest() {
        let record: SnapshotTestingConfiguration.Record =
            ProcessInfo.processInfo.environment["SNAPSHOT_RECORD"] == "1" ? .all : .missing
        withSnapshotTesting(record: record) { super.invokeTest() }
    }

    func testHomeSample() {
        let view = PopHomeSample(now: popSampleNow).frame(width: 390, height: 844)
        assertSnapshot(of: UIHostingController(rootView: view), as: .image(on: .iPhone13))
    }

    func testGallery() {
        let view = PopGallery().frame(width: 390, height: 9000)
        assertSnapshot(of: UIHostingController(rootView: view), as: .image(size: CGSize(width: 390, height: 9000)))
    }
}
#endif
