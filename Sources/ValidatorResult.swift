//
//  ValidatorResult.swift
//
//
//  Created by Florian Claisse on 26/11/2023.
//

public protocol ValidatorResult {
    var isFailure: Bool { get }
    var successDescription: String? { get }
    var failureDescription: String? { get }
}

public struct ValidatorResults {
    public struct Invalid {
        public let reason: String
    }
}

extension ValidatorResults.Invalid: ValidatorResult {
    public var isFailure: Bool {
        true
    }
    
    public var successDescription: String? {
        nil
    }
    
    public var failureDescription: String? {
        "is invalid: \(self.reason)"
    }
}
