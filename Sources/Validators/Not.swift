//
//  Not.swift
//
//
//  Created by Florian Claisse on 24/11/2023.
//

/// Inverts a ``Validation`` `x`.
public prefix func !<T>(validator: Validator<T>) -> Validator<T> {
    .init {
        ValidatorResults.Not(result: validator.validate($0))
    }
}

extension ValidatorResults {
    public struct Not {
        public let result: ValidatorResult
    }
}

extension ValidatorResults.Not: ValidatorResult {
    /// See ``ValidatorResult/isFailure``.
    public var isFailure: Bool {
        !self.result.isFailure
    }
    
    /// See ``ValidatorResult/successDescription``.
    public var successDescription: String? {
        self.result.failureDescription
    }
    
    /// See ``ValidatorResult/failureDescription``.
    public var failureDescription: String? {
        return self.result.successDescription
    }
}
