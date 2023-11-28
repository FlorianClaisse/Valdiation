//
//  ValidationsError.swift
//
//
//  Created by Florian Claisse on 19/11/2023.
//

import Foundation

/// A validation error.
///
/// See ``BasicValidationError`` for a default implementation.
public protocol ValidationError: Error {
    var identifier: String { get }
    var reason: String { get }
}

extension ValidationError where Self: RawRepresentable, Self.RawValue == String {
    public var identifier: String { self.rawValue }
}


public struct BasicValidationError: ValidationError {
    public let identifier: String = "validation failed"
    public let reason: String
    
    /// Create a new ``BasicValidationError``.
    public init(reason: String) {
        self.reason = reason
    }
}
