//
//  Validations.swift
//
//
//  Created by Florian Claisse on 19/11/2023.
//

/// Holds zero or more ``Validation/Validation``'s for a ``Validatable`` model.
public struct Validations<M> where M: Validatable {
    /// Internal storage.
    private var storage: [Validation<M>]
    
    /// Create a new ``Validations`` instance with empty storage.
    public init(_ model: M.Type) {
        self.storage = []
    }
    
    /// Adds a new ``Validation/Validation`` at the supplied key path with custom ``ValidationError``.
    /// 
    /// ```swift
    /// validations.add(\.name, is: .count(5...) && .alphanumeric, customError: BasicValidationError(reason: "name error"))
    /// ```
    /// - Parameters:
    ///    - keyPath: `KeyPath` to validatable property.
    ///    - validator: ``Validator`` to run on this property.
    ///    - error: Custom ``ValidationError``which will be thrown in the event of non-validation.
    public mutating func add<T>(_ keyPath: KeyPath<M, T>, is validator: Validator<T>, customError error: ValidationError) {
        self.storage.append(.init(error) { validator.validate($0[keyPath: keyPath]) } )
    }
    
    /// Adds a new ``Validation/Validation`` at the supplied key path with custom error message.
    /// 
    /// ```swift
    /// validations.add(\.name, is: .count(5...) && .alphanumeric, customMessage: "name error")
    /// ```
    /// - Parameters:
    ///   - keyPath: `KeyPath` to validatable property.
    ///   - validator: ``Validator`` to run on this property.
    ///   - message: The custom error message that will be thrown in the event of non-validation.
    ///
    /// - Important: The error message is encapsulated in a ``BasicValidationError`` and will be found in the ``BasicValidationError/reason`` property.
    public mutating func add<T>(_ keyPath: KeyPath<M, T>, is validator: Validator<T>, customMessage message: String) {
        self.storage.append(.init(message) { validator.validate($0[keyPath: keyPath]) } )
    }
    
    /// Adds a new ``Validation/Validation`` at the supplied key path and readable path.
    ///
    /// ```swift
    /// validations.add(\.name, at: "name", is: .count(5...) && .alphanumeric)
    /// ```
    /// - Parameters:
    ///   - keyPath: `KeyPath` to validatable property.
    ///   - path: Readable path. Will be displayed when showing errors.
    ///   - validator: ``Validator`` to run on this property.
    public mutating func add<T>(_ keyPath: KeyPath<M, T>, at path: String, is validator: Validator<T>) {
        self.storage.append(.init(path: path) { validator.validate($0[keyPath: keyPath]) } )
    }
    
    /// Validate the ``Validation/Validation``'s on an instance of `M`.
    ///
    /// - Throws: A ``ValidationError`` in the event of non-validation.
    public func validate(on model: M) throws {
        for validation in self.storage {
            let result = validation.validate(model)
            if result.isFailure {
                if let error = validation.customValidationError {
                    throw error
                } else if let reason = validation.customFailureDescription {
                    throw BasicValidationError(reason: reason)
                } else {
                    throw BasicValidationError(reason: "\(validation.path) \(result.failureDescription ?? "")")
                }
            }
        }
    }
}
