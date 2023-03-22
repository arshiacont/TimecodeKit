//
//  Timecode String.swift
//  TimecodeKit • https://github.com/orchetect/TimecodeKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import Foundation

#if os(macOS)
import AppKit
#elseif os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#endif

// MARK: - Init

extension Timecode {
    /// Instance exactly from timecode string and frame rate.
    ///
    /// An improperly formatted timecode string or one with out-of-bounds values will throw an
    /// error.
    ///
    /// Validation is based on the `upperLimit` and `subFramesBase` properties.
    ///
    /// - Throws: ``ValidationError`` or ``StringParseError``
    public init(
        _ exactlyTimecodeString: String,
        at rate: TimecodeFrameRate,
        limit: UpperLimit = ._24hours,
        base: SubFramesBase = .default()
    ) throws {
        properties = Properties(rate: rate, base: base, limit: limit)
        
        try setTimecode(exactly: exactlyTimecodeString)
    }
    
    /// Instance from timecode string and frame rate, clamping to valid timecode if necessary.
    ///
    /// Clamping is based on the `upperLimit` and `subFramesBase` properties.
    ///
    /// - Throws: ``StringParseError``
    public init(
        clamping timecodeString: String,
        at rate: TimecodeFrameRate,
        limit: UpperLimit = ._24hours,
        base: SubFramesBase = .default()
    ) throws {
        properties = Properties(rate: rate, base: base, limit: limit)
        
        try setTimecode(clamping: timecodeString)
    }
    
    /// Instance from timecode string and frame rate, clamping values if necessary.
    ///
    /// Individual components which are out-of-bounds will be clamped to minimum or maximum possible
    /// values.
    ///
    /// Clamping is based on the `upperLimit` and `subFramesBase` properties.
    ///
    /// - Throws: ``StringParseError``
    public init(
        clampingEach timecodeString: String,
        at rate: TimecodeFrameRate,
        limit: UpperLimit = ._24hours,
        base: SubFramesBase = .default()
    ) throws {
        properties = Properties(rate: rate, base: base, limit: limit)
        
        try setTimecode(clampingEach: timecodeString)
    }
    
    /// Instance from timecode string and frame rate, wrapping timecode if necessary.
    ///
    /// An improperly formatted timecode string or one with invalid values will return `nil`.
    ///
    /// Wrapping is based on the `upperLimit` and `subFramesBase` properties.
    ///
    /// - Throws: ``StringParseError``
    public init(
        wrapping timecodeString: String,
        at rate: TimecodeFrameRate,
        limit: UpperLimit = ._24hours,
        base: SubFramesBase = .default()
    ) throws {
        properties = Properties(rate: rate, base: base, limit: limit)
        
        try setTimecode(wrapping: timecodeString)
    }
    
    /// Instance from raw timecode values formatted as a timecode string and frame rate.
    ///
    /// Timecode values will not be validated or rejected if they overflow.
    ///
    /// This is useful, for example, when intending on running timecode validation methods against timecode values that are unknown to be valid or not at the time of initializing.
    ///
    /// - Throws: ``StringParseError``
    public init(
        rawValues timecodeString: String,
        at rate: TimecodeFrameRate,
        limit: UpperLimit = ._24hours,
        base: SubFramesBase = .default()
    ) throws {
        properties = Properties(rate: rate, base: base, limit: limit)
        
        try setTimecode(rawValues: timecodeString)
    }
}

// MARK: - Get and Set

extension Timecode {
    // MARK: stringValue
    
    /// Timecode string representation.
    ///
    /// Valid formats for 24-hour:
    ///
    ///     "00:00:00:00" "00:00:00;00"
    ///     "0:00:00:00" "0:00:00;00"
    ///     "00000000"
    ///
    /// Valid formats for 100-day: All of the above, as well as:
    ///
    ///     "0 00:00:00:00" "0 00:00:00;00"
    ///     "0:00:00:00:00" "0:00:00:00;00"
    ///
    /// (Validation is based on the frame rate and `upperLimit` property.)
    public func stringValue(
        format: StringFormat = .default(),
        filenameCompatible: Bool = false
    ) -> String {
        let sepDays = " "
        let sepMain = ":"
        let sepFrames = properties.frameRate.isDrop ? ";" : ":"
        let sepSubFrames = "."
        
        var output = ""
        
        output += "\(components.days != 0 ? "\(components.days)\(sepDays)" : "")"
        output += "\(String(format: "%02d", components.hours))\(sepMain)"
        output += "\(String(format: "%02d", components.minutes))\(sepMain)"
        output += "\(String(format: "%02d", components.seconds))\(sepFrames)"
        output += "\(String(format: "%0\(properties.frameRate.numberOfDigits)d", components.frames))"
        
        if format.showSubFrames {
            let numberOfSubFramesDigits = validRange(of: .subFrames).upperBound.numberOfDigits
            
            output += "\(sepSubFrames)\(String(format: "%0\(numberOfSubFramesDigits)d", components.subFrames))"
        }
        
        if filenameCompatible {
            return output
                .replacingOccurrences(of: ":", with: "-")
                .replacingOccurrences(of: ";", with: "-")
                .replacingOccurrences(of: " ", with: "-")
        } else {
            return output
        }
    }
    
    // MARK: stringValueValidated
    
    /// Returns `stringValue` as `NSAttributedString`, highlighting invalid values.
    ///
    /// `invalidAttributes` are the `NSAttributedString` attributes applied to invalid values.
    /// If `invalidAttributes` are not passed, the default of red foreground color is used.
    public func stringValueValidated(
        format: StringFormat = .default(),
        invalidAttributes: [NSAttributedString.Key: Any]? = nil,
        withDefaultAttributes attrs: [NSAttributedString.Key: Any]? = nil
    ) -> NSAttributedString {
        let sepDays = NSAttributedString(string: " ", attributes: attrs)
        let sepMain = NSAttributedString(string: ":", attributes: attrs)
        let sepFrames = NSAttributedString(string: properties.frameRate.isDrop ? ";" : ":", attributes: attrs)
        let sepSubFrames = NSAttributedString(string: ".", attributes: attrs)
        
        #if os(macOS)
        let invalidColor = invalidAttributes
            ?? [.foregroundColor: NSColor.red]
        #elseif os(iOS) || os(tvOS) || os(watchOS)
        let invalidColor = invalidAttributes
            ?? [.foregroundColor: UIColor.red]
        #else
        let invalidColor = invalidAttributes
            ?? []
        #endif
        
        let invalids = invalidComponents
        
        let output = NSMutableAttributedString(string: "", attributes: attrs)
        
        var piece: NSMutableAttributedString
        
        // days
        if components.days != 0 {
            piece = NSMutableAttributedString(string: "\(components.days)", attributes: attrs)
            if invalids.contains(.days) {
                piece.addAttributes(
                    invalidColor,
                    range: NSRange(location: 0, length: piece.string.count)
                )
            }
            
            output.append(piece)
            
            output.append(sepDays)
        }
        
        // hours
        
        piece = NSMutableAttributedString(
            string: String(format: "%02d", components.hours),
            attributes: attrs
        )
        if invalids.contains(.hours) {
            piece.addAttributes(
                invalidColor,
                range: NSRange(location: 0, length: piece.string.count)
            )
        }
        
        output.append(piece)
        
        output.append(sepMain)
        
        // minutes
        
        piece = NSMutableAttributedString(
            string: String(format: "%02d", components.minutes),
            attributes: attrs
        )
        if invalids.contains(.minutes) {
            piece.addAttributes(
                invalidColor,
                range: NSRange(location: 0, length: piece.string.count)
            )
        }
        
        output.append(piece)
        
        output.append(sepMain)
        
        // seconds
        
        piece = NSMutableAttributedString(
            string: String(format: "%02d", components.seconds),
            attributes: attrs
        )
        if invalids.contains(.seconds) {
            piece.addAttributes(
                invalidColor,
                range: NSRange(location: 0, length: piece.string.count)
            )
        }
        
        output.append(piece)
        
        output.append(sepFrames)
        
        // frames
        
        piece = NSMutableAttributedString(
            string:
            String(
                format: "%0\(properties.frameRate.numberOfDigits)d",
                components.frames
            ),
            attributes: attrs
        )
        if invalids.contains(.frames) {
            piece.addAttributes(
                invalidColor,
                range: NSRange(location: 0, length: piece.string.count)
            )
        }
        
        output.append(piece)
        
        // subframes
        
        if format.showSubFrames {
            let numberOfSubFramesDigits = validRange(of: .subFrames).upperBound.numberOfDigits
            
            output.append(sepSubFrames)
            
            piece = NSMutableAttributedString(
                string:
                String(
                    format: "%0\(numberOfSubFramesDigits)d",
                    components.subFrames
                ),
                attributes: attrs
            )
            if invalids.contains(.subFrames) {
                piece.addAttributes(
                    invalidColor,
                    range: NSRange(location: 0, length: piece.string.count)
                )
            }
            
            output.append(piece)
        }
        
        return output
    }
}

// MARK: Setters

extension Timecode {
    /// Set timecode from a timecode string. Values which are out-of-bounds will also cause the setter to fail, and return false. An error is thrown if the string is malformed and cannot be reasonably parsed.
    ///
    /// Validation is based on the `upperLimit` and `subFramesBase` properties.
    ///
    /// - Throws: ``StringParseError`` or ``ValidationError``
    public mutating func setTimecode(exactly string: String) throws {
        let decoded = try Timecode.decode(timecode: string)
        
        try setTimecode(exactly: decoded)
    }
    
    /// Set timecode from a timecode string, clamping to valid timecode if necessary. An error is thrown if the string is malformed and cannot be reasonably parsed.
    ///
    /// Clamping is based on the `upperLimit` and `subFramesBase` properties.
    ///
    /// - Throws: ``StringParseError``
    public mutating func setTimecode(clamping string: String) throws {
        let tcVals = try Timecode.decode(timecode: string)
        
        setTimecode(clamping: tcVals)
    }
    
    /// Set timecode from a timecode string, clamping individual values if necessary. Individual values which are out-of-bounds will be clamped to minimum or maximum possible values. An error is thrown if the string is malformed and cannot be reasonably parsed.
    ///
    /// Returns true/false depending on whether the string is formatted correctly or not.
    ///
    /// Clamping is based on the `upperLimit` and `subFramesBase` properties.
    ///
    /// - Throws: ``StringParseError``
    public mutating func setTimecode(clampingEach string: String) throws {
        let tcVals = try Timecode.decode(timecode: string)
        
        setTimecode(clampingEach: tcVals)
    }
    
    /// Set timecode from a string. Values which are out-of-bounds will be clamped to minimum or maximum possible values. An error is thrown if the string is malformed and cannot be reasonably parsed.
    ///
    /// Clamping is based on the `upperLimit` and `subFramesBase` properties.
    ///
    /// - Throws: ``StringParseError``
    public mutating func setTimecode(wrapping string: String) throws {
        let tcVals = try Timecode.decode(timecode: string)
        
        setTimecode(wrapping: tcVals)
    }
    
    /// Set timecode from a string, treating components as raw values. Timecode values will not be validated or rejected if they overflow. An error is thrown if the string is malformed and cannot be reasonably parsed.
    ///
    /// This is useful, for example, when intending on running timecode validation methods against timecode values that are unknown to be valid or not at the time of initializing.
    ///
    /// - Throws: ``StringParseError``
    public mutating func setTimecode(rawValues string: String) throws {
        let tcVals = try Timecode.decode(timecode: string)
        
        setTimecode(rawValues: tcVals)
    }
}

extension Timecode {
    /// Decodes a Timecode string into its component values, without validating.
    ///
    /// An error is thrown if the string is malformed and cannot be reasonably parsed. Raw values themselves will be passed as-is and not validated based on a frame rate or upper limit.
    ///
    /// Valid formats for 24-hour:
    ///
    ///     "00:00:00:00"    "00:00:00;00"
    ///     "00:00:00:00.00" "00:00:00;00.00"
    ///     "00;00;00;00"    "00;00;00;00"
    ///     "00;00;00;00.00" "00;00;00;00.00"
    ///
    /// Valid formats for 100-day: All of the above, as well as:
    ///
    ///     "0 00:00:00:00" "0 00:00:00;00"
    ///     "0:00:00:00:00" "0:00:00:00;00"
    ///     "0 00:00:00:00.00" "0 00:00:00;00.00"
    ///     "0:00:00:00:00.00" "0:00:00:00;00.00"
    ///     "0 00;00;00;00" "0 00;00;00;00"
    ///     "0;00;00;00;00" "0;00;00;00;00"
    ///     "0 00;00;00;00.00" "0 00;00;00;00.00"
    ///     "0;00;00;00;00.00" "0;00;00;00;00.00"
    ///
    /// - Throws: ``StringParseError``
    public static func decode(timecode string: String) throws -> Components {
        let pattern = #"^(\d+)??[\:;\s]??(\d+)[\:;](\d+)[\:;](\d+)[\:\;](\d+)[\.]??(\d+)??$"#
        
        let matches = string
            .regexMatches(captureGroupsFromPattern: pattern)
            .dropFirst()
        
        // attempt to convert strings to integers, preserving indexes and preserving nils
        // essentially converting [String?] to [Int?]
        // note: don't use compactMap here
        
        let ints = matches.map { $0 == nil ? nil : Int($0!) }
        
        // basic check - ensure there's at least 4 values but no more than 6
        
        let nonNilCount = ints.reduce(0) { $1 != nil ? $0 + 1 : $0 }
        
        guard (4 ... 6).contains(nonNilCount)
        else { throw StringParseError.malformed }
        
        // return components
        
        return Components(
            d:  ints[0] ?? 0,
            h:  ints[1] ?? 0,
            m:  ints[2] ?? 0,
            s:  ints[3] ?? 0,
            f:  ints[4] ?? 0,
            sf: ints[5] ?? 0
        )
    }
}

// MARK: - .toTimecode

extension String {
    /// Returns an instance of `Timecode(exactly:)`.
    /// If the string is not a valid timecode string, it returns nil.
    ///
    /// - Throws: ``ValidationError`` or ``StringParseError``
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
    
    /// Returns an instance of `Timecode(rawValues:)`.
    /// If the string is not a valid timecode string, it returns nil.
    ///
    /// - Throws: ``StringParseError``
    public func toTimecode(
        rawValuesAt rate: TimecodeFrameRate,
        limit: Timecode.UpperLimit = ._24hours,
        base: Timecode.SubFramesBase = .default()
    ) throws -> Timecode {
        try Timecode(
            rawValues: self,
            at: rate,
            limit: limit,
            base: base
        )
    }
}
