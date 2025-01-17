//
//  Fraction.swift
//  TimecodeKit • https://github.com/orchetect/TimecodeKit
//  © 2020-2023 Steffan Andrews • Licensed under MIT License
//

import Foundation

/// Numerical fraction containing a numerator and a denominator.
///
/// Used to convert to/from ``Timecode``, Core Media `CMTime`, or metadata encoding such as Final Cut Pro XML or AAF.
public struct Fraction {
    public let numerator: Int
    public let denominator: Int
    
    private let _isReduced: Bool?
    
    /// Returns `true` if the fraction is reduced to its simplest form and can not be reduced any
    /// further.
    public var isReduced: Bool {
        if let _isReduced = _isReduced, _isReduced { return _isReduced }
        let reduced = reduced()
        return self == reduced
    }
    
    /// Returns `true` if one operand of the fraction is negative.
    public var isNegative: Bool {
        let n = numerator.signum() == -1
        let d = denominator.signum() == -1
        return (n && !d) || (!n && d)
    }
    
    // MARK: - Init
    
    /// Initialize with literal values.
    public init(_ numerator: Int, _ denominator: Int) {
        self.numerator = numerator
        self.denominator = denominator
        _isReduced = nil
    }
    
    /// Initialize by reducing and normalizing the fraction.
    public init(reducing numerator: Int, _ denominator: Int) {
        let reduced = Self.reduce(n: numerator, d: denominator)
        self.numerator = reduced.n
        self.denominator = reduced.d
        _isReduced = true
    }
    
    // MARK: - Conversions
    
    public var doubleValue: Double {
        Double(numerator) / Double(denominator)
    }
    
    public var floatValue: Float {
        Float(doubleValue)
    }
}

extension Fraction: Equatable {
    /// Performs a comparison against literal values.
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.numerator == rhs.numerator
            && lhs.denominator == rhs.denominator
    }
    
    /// Returns `true` if both fractions are mathematically equal (can reduce to the same values).
    public func isEqual(to other: Self) -> Bool {
        let lhsReduced = reduced().normalized()
        let rhsReduced = other.reduced().normalized()
        
        return lhsReduced == rhsReduced
    }
}

extension Fraction: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(numerator)
        hasher.combine(denominator)
    }
}

extension Fraction: CustomStringConvertible {
    public var description: String {
        "\(numerator)/\(denominator)"
    }
}

// MARK: - Operations

extension Fraction {
    /// Returns the absolute fraction.
    /// (Returns unmodified if positive, negates if negative.)
    /// The fraction is also normalized.
    public func abs() -> Self {
        let norm = normalized()
        return isNegative ? norm.negated() : norm
    }
    
    /// Internal:
    /// Reduce a fraction to its simplest form.
    /// This also normalizes signs.
    static func reduce(n: Int, d: Int) -> (n: Int, d: Int) {
        let (absN, signN) = n < 0 ? (-n, -1) : (n, 1)
        let (absD, signD) = d < 0 ? (-d, -1) : (d, 1)
        var v = n
        var u = d
        
        // Euclid's solution to finding the Greatest Common Denominator
        while (v != 0) {
            (v, u) = (u % v, v)
        }
        
        return (absN / u * signN, absD / u * signD)
    }
    
    /// Returns a new instance reduced to its simplest form.
    /// This also normalizes signs.
    public func reduced() -> Self {
        if _isReduced == true { return self }
        return Fraction(reducing: numerator, denominator)
    }
    
    /// Internal:
    /// Normalize a fraction.
    /// Fractions with two negative signs are normalized to two positive signs.
    /// Fractions with negative denominator are normalized to negative numerator and positive denominator.
    static func normalize(n: Int, d: Int) -> (n: Int, d: Int) {
        var n = n
        var d = d
        if n >= 0 && d >= 0 { return (n: n, d: d) }
        if (n < 0 && d < 0) || (d < 0) {
            n *= -1
            d *= -1
        }
        return (n: n, d: d)
    }
    
    /// Returns a new instance normalized.
    /// Fractions with two negative signs are normalized to two positive signs.
    /// Fractions with negative denominator are normalized to negative numerator and positive denominator.
    func normalized() -> Self {
        let result = Self.normalize(n: numerator, d: denominator)
        return Fraction(result.n, result.d)
    }
    
    /// Negates the fraction.
    public mutating func negate() {
        var n = numerator
        n.negate()
        self = Self(n, denominator)
    }
    
    /// Returns a new instance negated.
    public func negated() -> Self {
        var n = self
        n.negate()
        return n
    }
}

// MARK: Double

extension Double {
    /// Internal:
    /// Converts a floating-point number to its simplest rational fraction.
    ///
    /// - Parameters:
    ///   - precision: Number of places after the decimal to preserve.
    /// - Returns: Numerator and denominator.
    func rational(
        precision: Int = 10
    ) -> Fraction {
        let pad = Int(truncating: pow(10, precision) as NSNumber)
        let n = Int(self * Double(pad))
        let d = pad
        
        return Fraction(n, d).reduced()
    }
}
