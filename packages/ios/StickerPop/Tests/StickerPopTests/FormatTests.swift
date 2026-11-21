import Foundation
import XCTest
@testable import StickerPop

/// Runs the shared cases in parity/format-cases.json; every platform must
/// produce exactly these strings.
final class FormatTests: XCTestCase {
    private func cases() throws -> [String: Any] {
        var dir = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
        while !FileManager.default.fileExists(atPath: dir.appendingPathComponent("parity/format-cases.json").path) {
            let parent = dir.deletingLastPathComponent()
            if parent.path == dir.path { throw XCTSkip("parity/format-cases.json not found") }
            dir = parent
        }
        let data = try Data(contentsOf: dir.appendingPathComponent("parity/format-cases.json"))
        return try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
    }

    private func list(_ all: [String: Any], _ name: String) -> [[String: Any]] {
        (all[name] as? [[String: Any]]) ?? []
    }

    private func sign(_ c: [String: Any]) -> PopFormat.Sign {
        switch c["sign"] as? String {
        case "always": return .always
        case "none": return PopFormat.Sign.none
        default: return .auto
        }
    }

    /// "2026-11-18T13:12" as a local date, like the other platforms.
    private func local(_ s: String) -> Date {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = .current
        f.dateFormat = "yyyy-MM-dd'T'HH:mm"
        return f.date(from: s)!
    }

    private func paise(_ c: [String: Any]) -> Int64 { (c["paise"] as! NSNumber).int64Value }

    func testFormatInr() throws {
        let all = try cases()
        for c in list(all, "formatInr") {
            XCTAssertEqual(PopFormat.formatInr(paise(c), sign: sign(c), alwaysPaise: c["alwaysPaise"] as? Bool ?? false), c["out"] as? String, "\(c)")
        }
    }

    func testFormatInrCompact() throws {
        let all = try cases()
        for c in list(all, "formatInrCompact") {
            XCTAssertEqual(PopFormat.formatInrCompact(paise(c), sign: sign(c)), c["out"] as? String, "\(c)")
        }
    }

    func testFormatPopDate() throws {
        let all = try cases()
        for c in list(all, "formatPopDate") {
            XCTAssertEqual(PopFormat.formatPopDate(local(c["date"] as! String), now: local(c["now"] as! String)), c["out"] as? String, "\(c)")
        }
    }

    func testFormatPopMonthAndTime() throws {
        let all = try cases()
        for c in list(all, "formatPopMonth") {
            XCTAssertEqual(PopFormat.formatPopMonth(local(c["date"] as! String)), c["out"] as? String)
        }
        for c in list(all, "formatPopTime") {
            XCTAssertEqual(PopFormat.formatPopTime(local(c["time"] as! String)), c["out"] as? String)
        }
    }
}
