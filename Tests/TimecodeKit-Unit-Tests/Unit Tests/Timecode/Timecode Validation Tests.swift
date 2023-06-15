//
//  Timecode Validation Tests.swift
//  TimecodeKit • https://github.com/orchetect/TimecodeKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if shouldTestCurrentPlatform

import XCTest
@testable import TimecodeKit

class Timecode_Validation_Tests: XCTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    func testValidWithinRanges() {
        // typical valid values
        
        let fr = TimecodeFrameRate._24
        let limit = Timecode.UpperLimit._24hours
        
        let tc = Timecode(.zero, at: fr, limit: limit)
        
        XCTAssertEqual(tc.invalidComponents, [])
        XCTAssertEqual(
            tc.components.invalidComponents(at: fr, base: ._80SubFrames, limit: limit),
            []
        )
        
        XCTAssertEqual(tc.validRange(of: .days), 0 ... 0)
        XCTAssertEqual(tc.validRange(of: .hours), 0 ... 23)
        XCTAssertEqual(tc.validRange(of: .minutes), 0 ... 59)
        XCTAssertEqual(tc.validRange(of: .seconds), 0 ... 59)
        XCTAssertEqual(tc.validRange(of: .frames), 0 ... 23)
        // XCTAssertThrowsError(tc.validRange(of: .subFrames)) // TODO: test
    }
    
    func testInvalidOverRanges() {
        // invalid - over ranges
        
        let fr = TimecodeFrameRate._24
        let limit = Timecode.UpperLimit._24hours
        
        var tc = Timecode(.zero, at: fr, limit: limit)
        tc.days = 5
        tc.hours = 25
        tc.minutes = 75
        tc.seconds = 75
        tc.frames = 52
        tc.subFrames = 500
        
        XCTAssertEqual(
            tc.invalidComponents,
            [.days, .hours, .minutes, .seconds, .frames, .subFrames]
        )
        XCTAssertEqual(
            tc.components.invalidComponents(at: fr, base: ._80SubFrames, limit: limit),
            [.days, .hours, .minutes, .seconds, .frames, .subFrames]
        )
    }
    
    func testInvalidUnderRanges() {
        // invalid - under ranges
        
        let fr = TimecodeFrameRate._24
        let limit = Timecode.UpperLimit._24hours
        
        var tc = Timecode(.zero, at: fr, limit: limit)
        tc.days = -1
        tc.hours = -1
        tc.minutes = -1
        tc.seconds = -1
        tc.frames = -1
        tc.subFrames = -1
        
        XCTAssertEqual(
            tc.invalidComponents,
            [.days, .hours, .minutes, .seconds, .frames, .subFrames]
        )
        XCTAssertEqual(
            tc.components.invalidComponents(at: fr, base: ._80SubFrames, limit: limit),
            [.days, .hours, .minutes, .seconds, .frames, .subFrames]
        )
    }
    
    func testDropFrame() {
        // perform a spot-check to ensure drop rate timecode validation works as expected
        
        TimecodeFrameRate.allDrop.forEach {
            let limit = Timecode.UpperLimit._24hours
            
            // every 10 minutes, no frames are skipped
            
            do {
                var tc = Timecode(.zero, at: $0, limit: limit)
                tc.minutes = 0
                tc.frames = 0
                
                XCTAssertEqual(
                    tc.invalidComponents,
                    [],
                    "for \($0)"
                )
                XCTAssertEqual(
                    tc.components.invalidComponents(
                        at: $0,
                        base: ._80SubFrames,
                        limit: limit
                    ),
                    [],
                    "for \($0)"
                )
            }
            
            // all other minutes each skip frame 0 and 1
            
            for minute in 1 ... 9 {
                var tc = Timecode(.zero, at: $0, limit: limit)
                tc.minutes = minute
                tc.frames = 0
                
                XCTAssertEqual(
                    tc.invalidComponents,
                    [.frames],
                    "for \($0) at \(minute) minutes"
                )
                XCTAssertEqual(
                    tc.components.invalidComponents(
                        at: $0,
                        base: ._80SubFrames,
                        limit: limit
                    ),
                    [.frames],
                    "for \($0) at \(minute) minutes"
                )
                
                tc = Timecode(.zero, at: $0, limit: limit)
                tc.minutes = minute
                tc.frames = 1
                
                XCTAssertEqual(
                    tc.invalidComponents,
                    [.frames],
                    "for \($0) at \(minute) minutes"
                )
                XCTAssertEqual(
                    tc.components.invalidComponents(
                        at: $0,
                        base: ._80SubFrames,
                        limit: limit
                    ),
                    [.frames],
                    "for \($0) at \(minute) minutes"
                )
            }
        }
    }
    
    func testDropFrameEdgeCases() throws {
        let comps = Timecode.Components(h: 23, m: 59, s: 59, f: 29, sf: 79)
        
        let tc = try Timecode(
            .components(comps),
            at: ._29_97_drop,
            base: ._80SubFrames,
            limit: ._24hours
        )
        
        XCTAssertEqual(tc.components, comps)
        XCTAssertEqual(tc.invalidComponents, [])
    }
    
    func testMaxFrames() {
        let subFramesBase: Timecode.SubFramesBase = ._80SubFrames
        
        let tc = Timecode(
            .zero,
            at: ._24,
            base: subFramesBase,
            limit: ._24hours
        )
        
        XCTAssertEqual(tc.validRange(of: .subFrames), 0 ... (subFramesBase.rawValue - 1))
        XCTAssertEqual(tc.subFrames, 0)
        XCTAssertEqual(tc.subFramesBase, subFramesBase)
        
        let mf = tc.maxFrameCountExpressible
        XCTAssertEqual(mf.doubleValue, 2_073_599.9875)
        
        let tcc = Timecode.components(
            of: mf,
            at: tc.frameRate
        )
        
        XCTAssertEqual(tcc, Timecode.Components(
            d: 0,
            h: 23,
            m: 59,
            s: 59,
            f: 23,
            sf: subFramesBase.rawValue - 1
        ))
    }
}

#endif
