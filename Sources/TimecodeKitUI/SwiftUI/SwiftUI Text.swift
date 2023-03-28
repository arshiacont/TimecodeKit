//
//  SwiftUI Text.swift
//  TimecodeKit • https://github.com/orchetect/TimecodeKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if canImport(SwiftUI)

import SwiftUI
import TimecodeKit

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Timecode {
    // MARK: textViewValidated
    
    /// Returns ``stringValue(format:)`` as SwiftUI `Text`, highlighting invalid values.
    ///
    /// `invalidModifiers` are the view modifiers applied to invalid values.
    /// If `invalidModifiers` are not passed, the default of red foreground color is used.
    public func stringValueValidatedText(
        format: StringFormat = .default(),
        invalidModifiers: ((Text) -> Text)? = nil,
        withDefaultModifiers: ((Text) -> Text)? = nil
    ) -> Text {
        let withDefaultModifiers = withDefaultModifiers ?? {
            $0
        }
        
        let invalidModifiers = invalidModifiers ?? {
            $0.foregroundColor(Color.red)
        }
        
        let sepDays = withDefaultModifiers(Text(" "))
        let sepMain = format.filenameCompatible
            ? withDefaultModifiers(Text("-"))
            : withDefaultModifiers(Text(":"))
        let sepFrames = format.filenameCompatible
            ? withDefaultModifiers(Text("-"))
            : withDefaultModifiers(Text(properties.frameRate.isDrop ? ";" : ":"))
        let sepSubFrames = withDefaultModifiers(Text("."))
        
        let invalids = invalidComponents
        
        // early return logic
        if invalids.isEmpty {
            return withDefaultModifiers(Text(stringValue(format: format)))
        }
        
        var output = withDefaultModifiers(Text(""))
        
        // days
        if components.days != 0 {
            let daysText = Text("\(components.days)")
            if invalids.contains(.days) {
                output = output + invalidModifiers(daysText)
            } else {
                output = output + withDefaultModifiers(daysText)
            }
            
            output = output + sepDays
        }
        
        // hours
        
        let hoursText = Text(String(format: "%02d", components.hours))
        if invalids.contains(.hours) {
            output = output + invalidModifiers(hoursText)
        } else {
            output = output + withDefaultModifiers(hoursText)
        }
        
        output = output + sepMain
        
        // minutes
        
        let minutesText = Text(String(format: "%02d", components.minutes))
        if invalids.contains(.minutes) {
            output = output + invalidModifiers(minutesText)
        } else {
            output = output + withDefaultModifiers(minutesText)
        }
        
        output = output + sepMain
        
        // seconds
        
        let secondsText = Text(String(format: "%02d", components.seconds))
        if invalids.contains(.seconds) {
            output = output + invalidModifiers(secondsText)
        } else {
            output = output + withDefaultModifiers(secondsText)
        }
        
        output = output + sepFrames
        
        // frames
        
        let framesText = Text(String(format: "%0\(properties.frameRate.numberOfDigits)d", components.frames))
        if invalids.contains(.frames) {
            output = output + invalidModifiers(framesText)
        } else {
            output = output + withDefaultModifiers(framesText)
        }
        
        // subframes
        
        if format.showSubFrames {
            let numberOfSubFramesDigits = validRange(of: .subFrames).upperBound.numberOfDigits
            
            output = output + sepSubFrames
            
            let subframesText = Text(String(format: "%0\(numberOfSubFramesDigits)d", components.subFrames))
            if invalids.contains(.subFrames) {
                output = output + invalidModifiers(subframesText)
            } else {
                output = output + withDefaultModifiers(subframesText)
            }
        }
        
        return output
    }
}

#endif
