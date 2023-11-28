//
//  Case.swift
//
//
//  Created by Florian Claisse on 26/11/2023.
//

extension Validator {
    /// Validates that the data can be converted to a value of an enum type with iterable cases.
    public static func `case`<E>(of enum: E.Type) -> Validator<T> where E: RawRepresentable & CaseIterable, E.RawValue == T, T: CustomStringConvertible {
        .init {
            ValidatorResults.Case(enumType: E.self, rawValue: $0)
        }
    }
}

extension ValidatorResults {
    /// ``ValidatorResult` of a validator that validates whether the data can be represented as a specific Enum case.
    public struct Case<T, E> where E: RawRepresentable & CaseIterable, E.RawValue == T, T: CustomStringConvertible {
        /// The type of the enum to check.
        public let enumType: E.Type
        
        /// The raw value that would be tested against the enum type.
        public let rawValue: T
    }
}

extension ValidatorResults.Case: ValidatorResult {
    /// See ``ValidatorResult/isFailure``.
    public var isFailure: Bool {
        return enumType.init(rawValue: rawValue) == nil
    }
    
    /// See ``ValidatorResult/successDescription``.
    public var successDescription: String? {
        makeDescription(not: false)
    }
    
    /// See ``ValidatorResult/failureDescription``.
    public var failureDescription: String? {
        makeDescription(not: true)
    }
    
    private func makeDescription(not: Bool) -> String {
        let items = E.allCases.map { "\($0.rawValue)" }
        let descritpion: String
        switch items.count {
        case 1:
            descritpion = items[0].description
        case 2:
            descritpion = "\(items[0].description) or \(items[1].description)"
        default:
            let first = items[0..<(items.count - 1)].map { $0.description }.joined(separator: ", ")
            let last = items[items.count - 1].description
            descritpion = "\(first) or \(last)"
        }
        return "is\(not ? "not" : "") \(descritpion)"
    }
}
