//
//  Hashable Tests.swift
//  TimecodeKit • https://github.com/orchetect/TimecodeKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if shouldTestCurrentPlatform

import XCTest
@testable import TimecodeKit

class Timecode_Hashable_Tests: XCTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    func testHashValue() {
        // hashValues should be equal
        
        XCTAssertEqual(
            try "01:00:00:00".timecode(using: ._23_976).hashValue,
            try "01:00:00:00".timecode(using: ._23_976).hashValue
        )
        XCTAssertNotEqual(
            try "01:00:00:01".timecode(using: ._23_976).hashValue,
            try "01:00:00:00".timecode(using: ._23_976).hashValue
        )
        
        XCTAssertNotEqual(
            try "01:00:00:00".timecode(using: ._23_976).hashValue,
            try "01:00:00:00".timecode(using: ._24).hashValue
        )
        XCTAssertNotEqual(
            try "01:00:00:00".timecode(using: ._23_976).hashValue,
            try "01:00:00:00".timecode(using: ._29_97).hashValue
        )
    }
    
    func testDictionary() throws {
        // Dictionary / Set
        
        var dict: [Timecode: String] = [:]
        dict[try "01:00:00:00".timecode(using: ._23_976)] = "A Spot Note Here"
        dict[try "01:00:00:06".timecode(using: ._23_976)] = "A Spot Note Also Here"
        XCTAssertEqual(dict.count, 2)
        dict[try "01:00:00:00".timecode(using: ._24)] = "This should not replace"
        XCTAssertEqual(dict.count, 3)
        
        XCTAssertEqual(dict[try "01:00:00:00".timecode(using: ._23_976)], "A Spot Note Here")
        XCTAssertEqual(dict[try "01:00:00:00".timecode(using: ._24)], "This should not replace")
    }
    
    func testSet() throws {
        // unique timecodes are based on frame counts, irrespective of frame rate
        
        let tcSet: Set<Timecode> = try [
            "01:00:00:00".timecode(using: ._23_976),
            "01:00:00:00".timecode(using: ._24),
            "01:00:00:00".timecode(using: ._25),
            "01:00:00:00".timecode(using: ._29_97),
            "01:00:00:00".timecode(using: ._29_97_drop),
            "01:00:00:00".timecode(using: ._30),
            "01:00:00:00".timecode(using: ._59_94),
            "01:00:00:00".timecode(using: ._59_94_drop),
            "01:00:00:00".timecode(using: ._60)
        ]
        
        XCTAssertNotEqual(
            tcSet.count,
            1
        ) // doesn't matter what frame rate it is, the same total elapsed frames matters
    }
}

#endif
