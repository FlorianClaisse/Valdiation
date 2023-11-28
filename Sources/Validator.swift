//
//  Validator.swift
//
//
//  Created by Florian Claisse on 19/11/2023.
//

/// A discrete ``Validator``.
///
/// All validation operators (`&&`, `||`, `!`, etc) work on ``Validator``'s.
/// ```swift
/// validations.add(\.firstName, at: "firstname", is: .count(5...) && .alphanumeric)
/// ```
///
/// Adding static properties to this type will enable leading-dot syntax when composing validators.
/// ```swift
/// extension Validator {
///     static func myValidator(...) -> Validator<T> {
///         .init {
///             ValidatorResults.MyValidator(...)
///         }
///     }
/// }
/// ```
public struct Validator<T> {
    /// Validates the supplied `T` data, return a ``ValidatorResult``.
    ///
    /// - Parameters:
    ///    - data: `T` to validate.
    /// - Returns: ``ValidatorResult``.
    public let validate: (_ data: T) -> ValidatorResult
    
    /// Creates a new ``Validator``.
    ///
    /// - Parameters:
    ///    - validate: Validates the supplied `T`, return a ``ValidatorResult``.
    public init(validate: @escaping (_ data: T) -> ValidatorResult) {
        self.validate = validate
    }
}
