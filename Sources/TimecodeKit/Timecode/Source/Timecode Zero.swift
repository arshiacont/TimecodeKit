//
//  Timecode Zero.swift
//  TimecodeKit • https://github.com/orchetect/TimecodeKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

extension Timecode {
    /// Zero timecode.
    /// Do not initialize directly; instead, pass `.zero` into a ``Timecode`` initializer.
    internal struct Zero {
        public init() { }
    }
}

// MARK: - TimecodeSource

extension Timecode.Zero: GuaranteedTimecodeSource {
    public func set(timecode: inout Timecode) {
        timecode.set(Timecode.Components.zero, by: .allowingInvalid)
    }
}

// MARK: - Static Constructors

extension GuaranteedTimecodeSourceValue {
    /// Zero timecode (00:00:00:00).
    /// This is guaranteed at all frame rates and requires no validation or error handling.
    public static let zero: Self = .init(value: Timecode.Zero())
}
