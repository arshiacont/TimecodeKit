//
//  TimecodeTransformer Tests.swift
//  TimecodeKit • https://github.com/orchetect/TimecodeKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if shouldTestCurrentPlatform

import XCTest
@testable import TimecodeKit

class TimecodeTransformer_Tests: XCTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    func testNone() throws {
        // .none
        
        let transformer = TimecodeTransformer(.none)
        
        XCTAssertEqual(
            transformer.transform(try Timecode(.components(h: 1), at: ._24)),
            try Timecode(.components(h: 01, m: 00, s: 00, f: 00), at: ._24)
        )
    }
    
    func testOffset() throws {
        // .offset()
        
        let deltaTC = try Timecode(.components(m: 1), at: ._24)
        let delta = TimecodeInterval(deltaTC, .plus)
        
        var transformer = TimecodeTransformer(.offset(by: delta))
        
        // disabled
        
        transformer.enabled = false
        
        XCTAssertEqual(
            transformer.transform(try Timecode(.components(h: 1), at: ._24)),
            try Timecode(.components(h: 01, m: 00, s: 00, f: 00), at: ._24)
        )
        
        // enabled
        
        transformer.enabled = true
        
        XCTAssertEqual(
            transformer.transform(try Timecode(.components(h: 1), at: ._24)),
            try Timecode(.components(h: 01, m: 01, s: 00, f: 00), at: ._24)
        )
    }
    
    func testCustom() throws {
        // .custom()
        
        let transformer = TimecodeTransformer(.custom { // inputTC -> Timecode in
            $0.adding(wrapping: Timecode.Components(m: 1))
        })
        
        XCTAssertEqual(
            transformer.transform(try Timecode(.components(h: 1), at: ._24)),
            try Timecode(.components(h: 01, m: 01, s: 00, f: 00), at: ._24)
        )
    }
    
    func testEmpty() throws {
        // array init allows empty transform array
        let transformer = TimecodeTransformer([])
        
        XCTAssertEqual(
            transformer.transform(try Timecode(.components(h: 1), at: ._24)),
            try Timecode(.components(h: 01, m: 00, s: 00, f: 00), at: ._24)
        )
    }
    
    func testMultiple_Offsets() throws {
        // .offset(by:)
        
        let deltaTC1 = try Timecode(.components(m: 1), at: ._24)
        let delta1 = TimecodeInterval(deltaTC1, .plus)
        
        let deltaTC2 = try Timecode(.components(s: 1), at: ._24)
        let delta2 = TimecodeInterval(deltaTC2, .minus)
        
        let transformer = TimecodeTransformer([.offset(by: delta1), .offset(by: delta2)])
        
        XCTAssertEqual(
            transformer.transform(try Timecode(.components(h: 1), at: ._24)),
            try Timecode(.components(h: 01, m: 00, s: 59, f: 00), at: ._24)
        )
    }
    
    func testShorthand() throws {
        let delta = Timecode(.zero, at: ._24)
        _ = TimecodeTransformer(.offset(by: .positive(delta)))
    }
}

#endif
