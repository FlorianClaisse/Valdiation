//
//  Validation.swift
//
//
//  Created by Florian Claisse on 26/11/2023.
//

public struct Validation<M> {
    internal let path: String
    internal let customValidationError: ValidationError?
    internal let customFailureDescription: String?
    internal let validate: (M) -> ValidatorResult
    
    internal init(_ error: ValidationError, _ run: @escaping (M) -> ValidatorResult) {
        self.path = "data"
        self.customValidationError = error
        self.customFailureDescription = nil
        self.validate = run
    }
    
    internal init(_ reason: String, _ run: @escaping (M) -> ValidatorResult) {
        self.path = "data"
        self.customValidationError = nil
        self.customFailureDescription = reason
        self.validate = run
    }
    
    internal init(path: String, _ run: @escaping (M) -> ValidatorResult) {
        self.path = path
        self.customValidationError = nil
        self.customFailureDescription = nil
        self.validate = run
    }
}
