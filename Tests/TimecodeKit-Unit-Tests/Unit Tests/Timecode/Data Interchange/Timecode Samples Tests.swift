//
//  Timecode Samples Tests.swift
//  TimecodeKit • https://github.com/orchetect/TimecodeKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if shouldTestCurrentPlatform

import XCTest
@testable import TimecodeKit

class Timecode_UT_DI_Samples_Tests: XCTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    func testTimecode_init_Samples() throws {
        try Timecode.FrameRate.allCases.forEach {
            let tc = try Timecode(
                samples: 48000 * 2,
                sampleRate: 48000,
                at: $0,
                limit: ._24hours
            )
            
            // don't imperatively check each result, just make sure that a value was set;
            // samples setter logic is unit-tested elsewhere, we just want to check the Timecode.init interface here.
            XCTAssertNotEqual(tc.seconds, 0, "for \($0)")
        }
    }
    
    func testSamplesGetSet_48KHz() throws {
        // pre-computed constants
        
        // confirmed correct in PT and Cubase
        let samplesIn1DayTC_ShrunkFrameRates = 4_151_347_200.0
        let samplesIn1DayTC_BaseFrameRates = 4_147_200_000.0
        let samplesIn1DayTC_DropFrameRates = 4_147_195_853.0
        let samplesIn1DayTC_30DF = 4_143_052_800.0
        
        // allow for the over-estimate padding value that gets added in the TC->samples method
        let accuracy = 0.001
        
        // MARK: samples as Double
        func validate(
            using samplesIn1DayTC: Double,
            sRate: Int,
            fRate: Timecode.FrameRate,
            roundedForDropFrame: Bool
        ) throws {
            var tc = Timecode(at: fRate, limit: ._100days)
            
            // get
            try tc.setTimecode(exactly: TCC(d: 1))
            var sv = tc.samplesDoubleValue(sampleRate: sRate)
            if roundedForDropFrame {
                // add rounding for dropframe; DAWs seem to round using standard rounding rules (?)
                sv.round()
            }
            XCTAssertEqual(
                sv,
                samplesIn1DayTC,
                accuracy: accuracy,
                "at \(fRate)"
            )
            
            // set
            try tc.setTimecode(
                samplesValue: samplesIn1DayTC,
                sampleRate: sRate
            )
            XCTAssertEqual(
                tc.components,
                TCC(d: 1),
                "at \(fRate)"
            )
        }
        
        // MARK: samples as Int
        func validate(
            using samplesIn1DayTC: Int,
            sRate: Int,
            fRate: Timecode.FrameRate
        ) throws {
            var tc = Timecode(at: fRate, limit: ._100days)
            
            // get
            try tc.setTimecode(exactly: TCC(d: 1))
            XCTAssertEqual(
                tc.samplesValue(sampleRate: sRate),
                samplesIn1DayTC,
                "at \(fRate)"
            )
            
            // set
            try tc.setTimecode(
                samplesValue: samplesIn1DayTC,
                sampleRate: sRate
            )
            XCTAssertEqual(
                tc.components,
                TCC(d: 1),
                "at \(fRate)"
            )
        }
        
        // 48KHz ___________________________________
        
        try Timecode.FrameRate.allCases.forEach { fRate in
            let sRate = 48000
            
            var samplesIn1DayTCDouble = 0.0
            var samplesIn1DayTCInt = 0
            var roundedForDropFrame = false
            
            switch fRate {
            case ._23_976,
                 ._24_98,
                 ._29_97,
                 ._47_952,
                 ._59_94,
                 ._119_88:
                
                samplesIn1DayTCDouble = samplesIn1DayTC_ShrunkFrameRates
                samplesIn1DayTCInt = Int(samplesIn1DayTCDouble)
                roundedForDropFrame = false
                
            case ._24,
                 ._25,
                 ._30,
                 ._48,
                 ._50,
                 ._60,
                 ._100,
                 ._120:
                
                samplesIn1DayTCDouble = samplesIn1DayTC_BaseFrameRates
                samplesIn1DayTCInt = Int(samplesIn1DayTCDouble)
                roundedForDropFrame = false
                
            case ._29_97_drop,
                 ._59_94_drop,
                 ._119_88_drop:
                
                // Cubase reports 4147195853 @ 1 day - there may be rounding happening in Cubase
                // Pro Tools reports 2073597926 @ 12 hours; double this would technically be 4147195854 but Cubase shows 1 frame less
                
                samplesIn1DayTCDouble = samplesIn1DayTC_DropFrameRates
                samplesIn1DayTCInt = Int(samplesIn1DayTCDouble)
                roundedForDropFrame = true // DAWs seem to using standard rounding for DF (?)
                
            case ._30_drop,
                 ._60_drop,
                 ._120_drop:
                
                samplesIn1DayTCDouble = samplesIn1DayTC_30DF
                samplesIn1DayTCInt = Int(samplesIn1DayTCDouble)
                roundedForDropFrame = false
            }
            
            // int
            try validate(
                using: samplesIn1DayTCInt,
                sRate: sRate,
                fRate: fRate
            )
            
            // double
            try validate(
                using: samplesIn1DayTCDouble,
                sRate: sRate,
                fRate: fRate,
                roundedForDropFrame: roundedForDropFrame
            )
        }
    }
    
    func testTimecode_Samples_SubFrames() throws {
        // ensure subframes are calculated correctly
        
        // test for precision and rounding issues by iterating every subframe for each frame rate just below the timecode upper limit
        
        let logErrors = true
        
        let subFramesBase: Timecode.SubFramesBase = ._80SubFrames
        
        var frameRatesWithSetTimecodeErrors: Set<Timecode.FrameRate> = []
        var frameRatesWithSetTimecodeErrorsCount = 0
        var frameRatesWithMismatchingComponents: Set<Timecode.FrameRate> = []
        var frameRatesWithMismatchingComponentsCount = 0
        
        for subFrame in 0 ..< subFramesBase.rawValue {
            let tcc = TCC(d: 99, h: 23, sf: subFrame)
            
            try Timecode.FrameRate.allCases.forEach {
                var tc = try Timecode(
                    tcc,
                    at: $0,
                    limit: ._100days,
                    base: subFramesBase
                )
                
                let sRate = 48000
                
                // timecode to samples
                
                let samples = tc.samplesDoubleValue(sampleRate: sRate)
                
                // samples to timecode
                
                if (try? tc.setTimecode(
                    samplesValue: samples,
                    sampleRate: sRate
                )) == nil {
                    frameRatesWithSetTimecodeErrors.insert($0)
                    frameRatesWithSetTimecodeErrorsCount += 1
                    if logErrors {
                        let fr = "\($0)".padding(toLength: 8, withPad: " ", startingAt: 0)
                        print("setTimecode(fromSamplesValue:) failed @ \(fr)")
                    }
                }
                
                if tc.components != tcc {
                    frameRatesWithMismatchingComponents.insert($0)
                    frameRatesWithMismatchingComponentsCount += 1
                    if logErrors {
                        let fr = "\($0)".padding(toLength: 8, withPad: " ", startingAt: 0)
                        print(
                            "TCC match failed @ \(fr) - origin \(tcc) to \(samples) samples converted to \(tc.components)"
                        )
                    }
                }
            }
        }
        
        if !frameRatesWithSetTimecodeErrors.isEmpty {
            XCTFail(
                "These frame rates had \(frameRatesWithSetTimecodeErrorsCount) errors setting timecode from samples: \(frameRatesWithSetTimecodeErrors.sorted())"
            )
        }
        
        if !frameRatesWithMismatchingComponents.isEmpty {
            XCTFail(
                "These frame rates had \(frameRatesWithMismatchingComponentsCount) errors with mismatching timecode components after converting samples: \(frameRatesWithSetTimecodeErrors.sorted())"
            )
        }
    }
}

#endif
