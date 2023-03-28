//
//  Timecode Operators.swift
//  TimecodeKit • https://github.com/orchetect/TimecodeKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

// MARK: - Math operators: Self, Self

extension Timecode {
    /// a.k.a. `lhs.adding(wrapping: rhs)`
    public static func + (lhs: Self, rhs: Self) -> Timecode {
        if lhs.frameRate == rhs.frameRate {
            return lhs.adding(wrapping: rhs.components)
        } else {
            guard let rhsConverted = try? rhs.converted(to: lhs.frameRate) else {
                assertionFailure(
                    "Could not convert right-hand Timecode operand to left-hand Timecode frameRate."
                )
                return lhs
            }
            
            return lhs.adding(wrapping: rhsConverted.components)
        }
    }
    
    /// a.k.a. `lhs.add(wrapping: rhs)`
    public static func += (lhs: inout Self, rhs: Self) {
        if lhs.frameRate == rhs.frameRate {
            lhs.add(wrapping: rhs.components)
        } else {
            guard let rhsConverted = try? rhs.converted(to: lhs.frameRate) else {
                assertionFailure(
                    "Could not convert right-hand Timecode operand to left-hand Timecode frameRate."
                )
                return
            }
            
            return lhs.add(wrapping: rhsConverted.components)
        }
    }
    
    /// a.k.a. `lhs.subtracting(wrapping: rhs)`
    public static func - (lhs: Self, rhs: Self) -> Timecode {
        if lhs.frameRate == rhs.frameRate {
            return lhs.subtracting(wrapping: rhs.components)
        } else {
            guard let rhsConverted = try? rhs.converted(to: lhs.frameRate) else {
                assertionFailure(
                    "Could not convert right-hand Timecode operand to left-hand Timecode frameRate."
                )
                return lhs
            }
            
            return lhs.subtracting(wrapping: rhsConverted.components)
        }
    }
    
    /// a.k.a. `lhs.subtract(wrapping: rhs)`
    public static func -= (lhs: inout Self, rhs: Self) {
        if lhs.frameRate == rhs.frameRate {
            lhs.subtract(wrapping: rhs.components)
        } else {
            guard let rhsConverted = try? rhs.converted(to: lhs.frameRate) else {
                assertionFailure(
                    "Could not convert right-hand Timecode operand to left-hand Timecode frameRate."
                )
                return
            }
            
            return lhs.subtract(wrapping: rhsConverted.components)
        }
    }
}

// MARK: - Math operators: Self, BinaryInteger

extension Timecode {
    /// a.k.a. `lhs.multiplying(wrapping: rhs)`
    public static func * <T: BinaryInteger>(lhs: Self, rhs: T) -> Self {
        lhs.multiplying(wrapping: Double(rhs))
    }
    
    /// a.k.a. `lhs.multiply(wrapping: rhs)`
    public static func *= <T: BinaryInteger>(lhs: inout Self, rhs: T) {
        lhs.multiply(wrapping: Double(rhs))
    }
    
    /// a.k.a. `lhs.dividing(wrapping: rhs)`
    public static func / <T: BinaryInteger>(lhs: Self, rhs: T) -> Self {
        lhs.dividing(wrapping: Double(rhs))
    }
    
    /// a.k.a. `lhs.divide(wrapping: rhs)`
    public static func /= <T: BinaryInteger>(lhs: inout Self, rhs: T) {
        lhs.divide(wrapping: Double(rhs))
    }
}

// MARK: - Math operators: Self, Double

extension Timecode {
    /// a.k.a. `lhs.multiplying(wrapping: rhs)`
    public static func * (lhs: Self, rhs: Double) -> Self {
        lhs.multiplying(wrapping: rhs)
    }
    
    /// a.k.a. `lhs.multiply(wrapping: rhs)`
    public static func *= (lhs: inout Self, rhs: Double) {
        lhs.multiply(wrapping: rhs)
    }
    
    /// a.k.a. `lhs.dividing(wrapping: rhs)`
    public static func / (lhs: Self, rhs: Double) -> Self {
        lhs.dividing(wrapping: rhs)
    }
    
    /// a.k.a. `lhs.divide(wrapping: rhs)`
    public static func /= (lhs: inout Self, rhs: Double) {
        lhs.divide(wrapping: rhs)
    }
}
