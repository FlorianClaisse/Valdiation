//
//  Empty.swift
//
//
//  Created by Florian Claisse on 24/11/2023.
//

extension Validator where T: Collection {
    /// Validates that the data is empty. You can also check a non empty state by negating this validator: `!.empty`.
    public static var empty: Validator<T> {
        .init {
            ValidatorResults.Empty(isEmpty: $0.isEmpty)
        }
    }
}

extension ValidatorResults {
    /// ``ValidatorResult`` of a validator that validates whether the data is empty.
    public struct Empty {
        /// The input is empty.
        public let isEmpty: Bool
    }
}

extension ValidatorResults.Empty: ValidatorResult {
    /// See ``ValidatorResult/isFailure``.
    public var isFailure: Bool {
        !self.isEmpty
    }
    
    /// See ``ValidatorResult/successDescription``.
    public var successDescription: String? {
        "is empty"
    }
    
    /// See ``ValidatorResult/failureDescription``.
    public var failureDescription: String? {
        "is not empty"
    }
}
