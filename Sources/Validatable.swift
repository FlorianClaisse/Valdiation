//
//  Validatable.swift
//
//
//  Created by Florian Claisse on 19/11/2023.
//

/// Capable of being validated. Conformance adds a throwing ``validate()`` method.
///
/// ```swift
/// struct User: Validatable {
///     var name: String
///     var age: Int
///
///     static func validations(_ validations: inout Validations<User>) {
///         // validate name is at least 5 characters and alphanumeric
///         validations.add(\.name, at: "name", is: .count(5...) && .alphanumeric)
///         return validations
///     }
/// }
/// ```
public protocol Validatable {
    /// The validations that will run when ``validate()`` is called on an instance of this class.
    ///
    /// ```swift
    /// struct User: Validatable {
    ///     var name: String
    ///     var age: Int
    ///
    ///     static func validations(_ validations: inout Validations<User>) {
    ///         // validate name is at least 5 characters and alphanumeric
    ///         validations.add(\.name, at: "name", is: .count(5...) && .alphanumeric)
    ///     }
    /// }
    /// ```
    static func validations(_ validations: inout Validations<Self>)
}

extension Validatable {
    /// Validates the model, throwing an error if any of the validations fail.
    ///
    /// ```swift
    /// let user = User(name: "Vapor", age: 3)
    /// try user.validate()
    /// ```
    /// - Throws: A ``ValidationError`` if any of the validations fail.
    public func validate() throws {
        try Self.validations().validate(on: self)
    }
    
    /// The entry point for a model.
    ///
    /// This method instantiates the ``Validations`` structure for the model, configures the validation with ``validations(_:)`` and returns the configured ``Validations``.
    /// - Returns: The configured ``Validations`` instance.
    public static func validations() -> Validations<Self> {
        var validations = Validations(Self.self)
        self.validations(&validations)
        return validations
    }
}
