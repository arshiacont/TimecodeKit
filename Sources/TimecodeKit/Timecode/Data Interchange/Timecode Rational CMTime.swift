//
//  Timecode Rational CMTime.swift
//  TimecodeKit • https://github.com/orchetect/TimecodeKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if canImport(CoreMedia)

import Foundation
import CoreMedia

@available(macOS 10.7, iOS 4.0, tvOS 9.0, watchOS 6.0, *)
extension Timecode {
    /// Instance from elapsed time `CMTime`.
    ///
    /// - Note: Many AVFoundation and Core Media objects utilize `CMTime` as a way to communicate
    /// times and durations.
    ///
    /// - Throws: ``ValidationError``
    public init(
        _ cmTime: CMTime,
        at rate: TimecodeFrameRate,
        limit: UpperLimit = ._24hours,
        base: SubFramesBase = .default()
    ) throws {
        properties = Properties(rate: rate, base: base, limit: limit)
        
        try setTimecode(cmTime)
    }
    
    /// Instance from elapsed time `CMTime`, clamping to valid timecode if necessary.
    ///
    /// - Note: Many AVFoundation and Core Media objects utilize `CMTime` as a way to communicate
    /// times and durations.
    ///
    /// - Throws: ``ValidationError``
    public init(
        clamping cmTime: CMTime,
        at rate: TimecodeFrameRate,
        limit: UpperLimit = ._24hours,
        base: SubFramesBase = .default()
    ) {
        properties = Properties(rate: rate, base: base, limit: limit)
        
        setTimecode(clamping: cmTime)
    }
    
    /// Instance from elapsed time `CMTime`, wrapping timecode if necessary.
    ///
    /// - Note: Many AVFoundation and Core Media objects utilize `CMTime` as a way to communicate
    /// times and durations.
    ///
    /// - Throws: ``ValidationError``
    public init(
        wrapping cmTime: CMTime,
        at rate: TimecodeFrameRate,
        limit: UpperLimit = ._24hours,
        base: SubFramesBase = .default()
    ) {
        properties = Properties(rate: rate, base: base, limit: limit)
        
        setTimecode(wrapping: cmTime)
    }
    
    /// Instance from elapsed time `CMTime`.
    ///
    /// Allows for invalid raw values (in this case, unbounded Days component).
    ///
    /// - Note: Many AVFoundation and Core Media objects utilize `CMTime` as a way to communicate
    /// times and durations.
    ///
    /// - Throws: ``ValidationError``
    public init(
        rawValues cmTime: CMTime,
        at rate: TimecodeFrameRate,
        limit: UpperLimit = ._24hours,
        base: SubFramesBase = .default()
    ) {
        properties = Properties(rate: rate, base: base, limit: limit)
        
        setTimecode(rawValues: cmTime)
    }
}

// MARK: - Get and Set

@available(macOS 10.7, iOS 4.0, tvOS 9.0, watchOS 6.0, *)
extension Timecode {
    /// Returns the time location as a `CMTime` instance.
    ///
    /// - Note: Many AVFoundation and Core Media objects utilize `CMTime` as a way to communicate
    /// times and durations.
    public var cmTime: CMTime {
        let fraction = rationalValue
        return CMTime(
            value: CMTimeValue(fraction.numerator),
            timescale: CMTimeScale(fraction.denominator)
        )
    }
    
    /// Instance from elapsed time `CMTime`.
    ///
    /// - Note: Many AVFoundation and Core Media objects utilize `CMTime` as a way to communicate
    /// times and durations.
    ///
    /// - Throws: ``ValidationError``
    public mutating func setTimecode(_ exactly: CMTime) throws {
        let fraction = Fraction(Int(exactly.value), Int(exactly.timescale))
        try setTimecode(fraction)
    }
    
    /// Instance from elapsed time `CMTime`.
    ///
    /// Clamps to valid timecode.
    ///
    /// - Note: Many AVFoundation and Core Media objects utilize `CMTime` as a way to communicate
    /// times and durations.
    public mutating func setTimecode(clamping cmTime: CMTime) {
        let fraction = Fraction(Int(cmTime.value), Int(cmTime.timescale))
        setTimecode(clamping: fraction)
    }
    
    /// Instance from elapsed time `CMTime`.
    ///
    /// Wraps timecode if necessary.
    ///
    /// - Note: Many AVFoundation and Core Media objects utilize `CMTime` as a way to communicate
    /// times and durations.
    public mutating func setTimecode(wrapping cmTime: CMTime) {
        let fraction = Fraction(Int(cmTime.value), Int(cmTime.timescale))
        setTimecode(wrapping: fraction)
    }
    
    /// Instance from elapsed time `CMTime`.
    ///
    /// Allows for invalid raw values (in this case, unbounded Days component).
    ///
    /// - Note: Many AVFoundation and Core Media objects utilize `CMTime` as a way to communicate
    /// times and durations.
    public mutating func setTimecode(rawValues cmTime: CMTime) {
        let fraction = Fraction(Int(cmTime.value), Int(cmTime.timescale))
        setTimecode(rawValues: fraction)
    }
}

@available(macOS 10.7, iOS 4.0, tvOS 9.0, watchOS 6.0, *)
extension CMTime {
    /// Convenience method to create an `Timecode` struct using the default
    /// `(_ exactly:)` initializer.
    ///
    /// - Throws: ``ValidationError``
    public func toTimecode(
        at rate: TimecodeFrameRate,
        limit: Timecode.UpperLimit = ._24hours,
        base: Timecode.SubFramesBase = .default()
    ) throws -> Timecode {
        try Timecode(
            self,
            at: rate,
            limit: limit,
            base: base
        )
    }
}

#endif
