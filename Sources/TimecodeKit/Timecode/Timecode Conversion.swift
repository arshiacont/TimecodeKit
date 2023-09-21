//
//  Timecode Conversion.swift
//  TimecodeKit • https://github.com/orchetect/TimecodeKit
//  © 2020-2023 Steffan Andrews • Licensed under MIT License
//

extension Timecode {
    // MARK: - FrameRate
    
    /// Return a new `Timecode` object converted to a new frame rate.
    ///
    /// - If `preservingValues` is `false` (default): entire timecode is converted based on the equivalent real time value.
    ///
    /// - If `preservingValues` is `true`: Return a new `Timecode` instance at the new frame rate preserving literal timecode values if
    ///   possible.
    ///   If any value is not expressible at the new frame rate, the entire timecode will be converted.
    ///
    /// - Note: this process may be lossy.
    ///
    /// - Throws: ``ValidationError``
    public func converted(
        to newFrameRate: TimecodeFrameRate,
        preservingValues: Bool = false
    ) throws -> Timecode {
        // just return self if frameRate is equal
        guard frameRate != newFrameRate else {
            return self
        }
        
        if preservingValues,
           let newTC = try? Timecode(
               .components(components),
               at: newFrameRate,
               base: subFramesBase,
               limit: upperLimit
           )
        {
            return newTC
        }
        
        // convert to new frame rate, retaining all ancillary property values
        
        return try Timecode(
            .realTime(seconds: realTimeValue),
            at: newFrameRate,
            base: subFramesBase,
            limit: upperLimit
        )
    }
    
    // MARK: - TimecodeTransformer
    
    /// Returns the timecode transformed by the given transformer.
    public func transformed(using transformer: TimecodeTransformer) -> Timecode {
        transformer.transform(self)
    }
    
    /// Transforms the timecode in-place using the given transformer.
    public mutating func transform(using transformer: TimecodeTransformer) {
        self = transformer.transform(self)
    }
}
