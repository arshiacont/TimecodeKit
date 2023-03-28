//
//  Timecode Rational Tests.swift
//  TimecodeKit • https://github.com/orchetect/TimecodeKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if shouldTestCurrentPlatform

import XCTest
@testable import TimecodeKit

class Timecode_Rational_Tests: XCTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    func testTimecode_init_Rational_Exactly() throws {
        try TimecodeFrameRate.allCases.forEach {
            let tc = try Timecode(
                Fraction(10, 1),
                using: $0
            )
            
            // don't imperatively check each result, just make sure that a value was set;
            // setter logic is unit-tested elsewhere, we just want to check the Timecode.init interface here.
            XCTAssertNotEqual(tc.components.seconds, 0, "for \($0)")
        }
    }
    
    func testTimecode_init_Rational() throws {
        // these rational fractions and timecodes are taken from actual FCP XML files as known truth
        
        try TimecodeFrameRate.allCases.forEach { fRate in
            switch fRate {
            case ._23_976:
                XCTAssertEqual(
                    try Timecode(Fraction(335335, 24000), using: fRate).components,
                    Timecode.Components(h: 00, m: 00, s: 13, f: 23)
                )
            case ._24:
                XCTAssertEqual(
                    try Timecode(Fraction(167500, 12000), using: fRate).components,
                    Timecode.Components(h: 00, m: 00, s: 13, f: 23)
                )
            case ._24_98:
                break // TODO: finish this
            case ._25: // same fraction is found in FCP XML for 25p and 25i video rates
                XCTAssertEqual(
                    try Timecode(Fraction(34900, 2500), using: fRate).components,
                    Timecode.Components(h: 00, m: 00, s: 13, f: 24)
                )
            case ._29_97: // same fraction is found in FCP XML for 29.97p and 29.97i video rates
                XCTAssertEqual(
                    try Timecode(Fraction(838838, 60000), using: fRate).components,
                    Timecode.Components(h: 00, m: 00, s: 13, f: 29)
                )
                XCTAssertEqual(
                    try Timecode(Fraction(1920919, 30000), using: fRate).components,
                    Timecode.Components(h: 00, m: 01, s: 03, f: 29)
                )
            case ._29_97_drop:
                XCTAssertEqual(
                    try Timecode(Fraction(419419, 30000), using: fRate).components,
                    Timecode.Components(h: 00, m: 00, s: 13, f: 29)
                )
                XCTAssertEqual(
                    try Timecode(Fraction(1918917, 30000), using: fRate).components,
                    Timecode.Components(h: 00, m: 01, s: 03, f: 29)
                )
            case ._30:
                XCTAssertEqual(
                    try Timecode(Fraction(83800, 6000), using: fRate).components,
                    Timecode.Components(h: 00, m: 00, s: 13, f: 29)
                )
            case ._30_drop:
                break // TODO: finish this
            case ._47_952:
                break // TODO: finish this
            case ._48:
                break // TODO: finish this
            case ._50:
                XCTAssertEqual(
                    try Timecode(Fraction(69900, 5000), using: fRate).components,
                    Timecode.Components(h: 00, m: 00, s: 13, f: 49)
                )
            case ._59_94:
                XCTAssertEqual(
                    try Timecode(Fraction(839839, 60000), using: fRate).components,
                    Timecode.Components(h: 00, m: 00, s: 13, f: 59)
                )
            case ._59_94_drop:
                break // TODO: finish this
            case ._60:
                XCTAssertEqual(
                    try Timecode(Fraction(83900, 6000), using: fRate).components,
                    Timecode.Components(h: 00, m: 00, s: 13, f: 59)
                )
            case ._60_drop:
                break // TODO: finish this
            case ._95_904:
                break // TODO: finish this
            case ._96:
                break // TODO: finish this
            case ._100:
                break // TODO: finish this
            case ._119_88:
                break // TODO: finish this
            case ._119_88_drop:
                break // TODO: finish this
            case ._120:
                break // TODO: finish this
            case ._120_drop:
                break // TODO: finish this
            }
        }
    }
    
    func testTimecode_init_Rational_Clamping() {
        let tc = Timecode(
            Fraction(86400 + 3600, 1), // 25 hours @ 24fps
            using: ._24,
            by: .clamping
        )
        
        XCTAssertEqual(
            tc.components,
            Timecode.Components(h: 23, m: 59, s: 59, f: 23, sf: tc.subFramesBase.rawValue - 1)
        )
    }
    
    func testTimecode_init_Rational_Clamping_Negative() {
        let tc = Timecode(
            Fraction(-2, 1),
            using: ._24,
            by: .clamping
        )
        
        XCTAssertEqual(
            tc.components,
            Timecode.Components(h: 00, m: 00, s: 00, f: 00)
        )
    }
    
    func testTimecode_init_Rational_Wrapping() {
        let tc = Timecode(
            Fraction(86400 + 3600, 1), // 25 hours @ 24fps
            using: ._24,
            by: .wrapping
        )
        
        XCTAssertEqual(
            tc.components,
            Timecode.Components(d: 00, h: 01, m: 00, s: 00, f: 00, sf: 00)
        )
    }
    
    func testTimecode_init_Rational_Wrapping_Negative() {
        let tc = Timecode(
            Fraction(-2, 1),
            using: ._24,
            by: .wrapping
        )
        
        XCTAssertEqual(
            tc.components,
            Timecode.Components(d: 00, h: 23, m: 59, s: 58, f: 00, sf: 00)
        )
    }
    
    func testTimecode_init_Rational_RawValues() {
        let tc = Timecode(
            Fraction((86400 * 2) + 3600, 1), // 2 days + 1 hour @ 24fps
            using: ._24,
            by: .allowingInvalid
        )
        
        XCTAssertEqual(
            tc.components,
            Timecode.Components(d: 02, h: 01, m: 00, s: 00, f: 00, sf: 00)
        )
    }
    
    func testTimecode_init_Rational_RawValues_Negative() {
        let tc = Timecode(
            Fraction(-(3600 + 60 + 5), 1),
            using: ._24,
            by: .allowingInvalid
        )
        
        // Negates only the largest non-zero component if input is negative
        XCTAssertEqual(
            tc.components,
            Timecode.Components(d: 00, h: -01, m: 01, s: 05, f: 00, sf: 00)
        )
    }
    
    func testTimecode_rationalValue() throws {
        // test a small range of timecodes at each frame rate
        // and ensure the fraction can re-form the same timecode
        try TimecodeFrameRate.allCases.forEach { fRate in
            let s = try Timecode.Components(m: 8, f: 20).timecode(using: fRate)
            let e = try Timecode.Components(m: 10, f: 5).timecode(using: fRate)
            
            try (s ... e).forEach { tc in
                let f = tc.rationalValue
                let reformedTC = try Timecode(f, using: fRate)
                XCTAssertEqual(tc, reformedTC)
            }
        }
    }
    
    func testTimecode_RationalValue_SpotCheck() throws {
        let tc = try Timecode.Components(h: 00, m: 00, s: 13, f: 29).timecode(using: ._29_97_drop)
        XCTAssertEqual(tc.rationalValue.numerator, 419419)
        XCTAssertEqual(tc.rationalValue.denominator, 30000)
    }
    
    func testFraction_toTimecode() throws {
        XCTAssertEqual(
            try Fraction(3600, 1).timecode(using: ._24).components,
            Timecode.Components(h: 1)
        )
    }
    
    func testTimecode_RationalValue_Subframes() throws {
        let tc = try Timecode.Components(h: 00, m: 00, s: 01, f: 11, sf: 56)
            .timecode(using: ._25, base: ._80SubFrames)
        XCTAssertEqual(tc.rationalValue, Fraction(367, 250))
    }
    
    func testTimecode_RationalSubframes() throws {
        // 00:00:01:11.56 @ 25i fps, 80sf base
        // this fraction is actually a little past 56 subframes
        // because it was from FCPXML where it was not on an exact subframe
        // FYI: when we convert it back to a fraction from timecode,
        // the fraction ends up 367/250
        let frac = Fraction(11011, 7500)
        let tc = try frac.timecode(using: ._25, base: ._80SubFrames)
        XCTAssertEqual(tc.components, Timecode.Components(h: 00, m: 00, s: 01, f: 11, sf: 56))
        XCTAssertEqual(tc.rationalValue, Fraction(367, 250))
    }
    
    func testTimecode_FrameCountOfRational() throws {
        // 00:00:01:11.56 @ 25i fps, 80sf base
        // this fraction is actually a little past 56 subframes
        // because it was from FCPXML where it was not on an exact subframe
        // FYI: when we convert it back to a fraction from timecode,
        // the fraction ends up 367/250
        let frac = Fraction(11011, 7500)
        let tc = try frac.timecode(using: ._25, base: ._80SubFrames)
        let int = tc.frameCount(of: frac)
        XCTAssertEqual(int, 36)
    }
    
    func testTimecode_FloatingFrameCountOfRational() throws {
        // 00:00:01:11.56 @ 25i fps, 80sf base
        // this fraction is actually a little past 56 subframes
        // because it was from FCPXML where it was not on an exact subframe
        // FYI: when we convert it back to a fraction from timecode,
        // the fraction ends up 367/250
        let frac = Fraction(11011, 7500)
        let tc = try frac.timecode(using: ._25, base: ._80SubFrames)
        let float = tc.floatingFrameCount(of: frac)
        XCTAssertEqual(float, 36.70333333333333)
    }
}

#endif
