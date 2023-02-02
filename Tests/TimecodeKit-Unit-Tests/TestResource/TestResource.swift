import Foundation
import XCTest

// MARK: - Constants

/// Resources files on disk used for unit testing.
enum TestResource: CaseIterable {
    static let timecodeTrack_23_976_Start_00_00_00_00 = TestResource.File(
        name: "TimecodeTrack_23_976_Start-00-00-00-00", ext: "mov", subFolder: "Resources"
    )
    static let timecodeTrack_23_976_Start_00_58_40_00 = TestResource.File(
        name: "TimecodeTrack_23_976_Start-00-58-40-00", ext: "mov", subFolder: "Resources"
    )
    static let timecodeTrack_24_Start_00_58_40_00 = TestResource.File(
        name: "TimecodeTrack_24_Start-00-58-40-00", ext: "mov", subFolder: "Resources"
    )
    
    static let timecodeTrack_29_97d_Start_00_00_00_00 = TestResource.File(
        name: "TimecodeTrack_29_97d_Start_00_00_00_00", ext: "mov", subFolder: "Resources"
    )
}

// MARK: - Utilities

extension TestResource {
    struct File: Equatable, Hashable {
        let name: String
        let ext: String
        let subFolder: String?
        
        var fileName: String { name + "." + ext }
    }
}

extension TestResource.File {
    func url(
        _ message: @autoclosure () -> String = "",
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> URL {
        // Bundle.module is synthesized when the package target has `resources: [...]`
        guard let url = Bundle.module.url(
            forResource: name,
            withExtension: ext,
            subdirectory: subFolder
        )
        else {
            var msg = message()
            msg = msg.isEmpty ? "" : ": \(msg)"
            XCTFail(
                "Could not form URL, possibly could not find file.\(msg)",
                file: file,
                line: line
            )
            throw XCTSkip()
        }
        return url
    }
    
    func data(
        _ message: @autoclosure () -> String = "",
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> Data {
        let url = try url()
        guard let data = try? Data(contentsOf: url)
        else {
            var msg = message()
            msg = msg.isEmpty ? "" : ": \(msg)"
            XCTFail(
                "Could not read file at URL: \(url.absoluteString).",
                file: file,
                line: line
            )
            throw XCTSkip("Aborting test.")
        }
        return data
    }
}
