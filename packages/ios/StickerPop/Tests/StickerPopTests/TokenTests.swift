import XCTest
@testable import StickerPop

final class TokenTests: XCTestCase {
    func testSpecValues() {
        XCTAssertEqual(PopRadius.card, 22)
        XCTAssertEqual(PopShadow.regular, 4)
        XCTAssertEqual(PopBorder.regular, 2.5)
        XCTAssertEqual(PopTextSpecs.heroAmount.size, 40)
        XCTAssertTrue(PopTextSpecs.heroAmount.tabular)
        XCTAssertEqual(PopTilt.addButton, -6)
    }

    func testFontIsBundled() {
        XCTAssertNotNil(Bundle.module.url(forResource: "BricolageGrotesque-Variable", withExtension: "ttf"))
    }
}
