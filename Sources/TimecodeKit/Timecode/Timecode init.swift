//
//  Timecode init.swift
//  TimecodeKit • https://github.com/orchetect/TimecodeKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import Foundation

extension Timecode {
    // MARK: - TimecodeSource
    
    /// Initialize by converting a time source to timecode at a given frame rate.
    /// Uses defaulted properties.
    public init(
        _ source: TimecodeSource,
        at frameRate: TimecodeFrameRate
    ) throws {
        properties = Properties(rate: frameRate)
        try set(source)
    }
    
    /// Initialize by converting a time source to timecode at a given frame rate.
    /// Uses defaulted properties.
    public init(
        _ source: TimecodeSource,
        at frameRate: TimecodeFrameRate,
        by validation: Validation
    ) {
        properties = Properties(rate: frameRate)
        set(source, by: validation)
    }
    
    /// Initialize by converting a time source to timecode using the given properties.
    public init(
        _ source: TimecodeSource,
        using properties: Properties
    ) throws {
        self.properties = properties
        try set(source)
    }
    
    /// Initialize by converting a time source to timecode using the given properties.
    public init(
        _ source: TimecodeSource,
        using properties: Properties,
        by validation: Validation
    ) {
        self.properties = properties
        set(source, by: validation)
    }
    
    /// Initialize with zero timecode (00:00:00:00) at a given frame rate.
    public init(
        at rate: TimecodeFrameRate
    ) {
        properties = Properties(rate: rate)
    }
    
    /// Initialize with zero timecode (00:00:00:00) at a given frame rate.
    public init(
        using properties: Properties
    ) {
        self.properties = properties
    }
    
    // MARK: - RichTimecodeSource
    
    /// Initialize by converting a rich time source to timecode.
    public init(
        _ source: RichTimecodeSource,
        overriding properties: Timecode.Properties? = nil
    ) throws {
        self.properties = properties ?? .init(rate: ._24)
        try set(source, overriding: properties)
    }
}

// MARK: - TimecodeSource Category Methods

extension TimecodeSource {
    /// Returns a new ``Timecode`` instance by converting a time source at the given frame rate.
    /// Uses defaulted properties.
    public func toTimecode(
        at frameRate: TimecodeFrameRate
    ) throws -> Timecode {
        try Timecode(self, at: frameRate)
    }
    
    /// Returns a new ``Timecode`` instance by converting a time source at the given frame rate.
    /// Uses defaulted properties.
    public func toTimecode(
        at frameRate: TimecodeFrameRate,
        by validation: Timecode.Validation
    ) -> Timecode {
        Timecode(self, at: frameRate, by: validation)
    }
    
    /// Returns a new ``Timecode`` instance by converting a time source.
    public func toTimecode(
        using properties: Timecode.Properties
    ) throws -> Timecode {
        try Timecode(self, using: properties)
    }
    
    /// Returns a new ``Timecode`` instance by converting a time source.
    public func toTimecode(
        using properties: Timecode.Properties,
        by validation: Timecode.Validation
    ) -> Timecode {
        Timecode(self, using: properties, by: validation)
    }
}
