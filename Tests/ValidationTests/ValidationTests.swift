//
//  ValidationTests.swift
//
//
//  Created by Florian Claisse on 25/11/2023.
//

@testable import Validation
import XCTest

class ValidationTests: XCTestCase {
    func testValidate() throws {
        let user = User(name: "Coucou", age: 18, pet: Pet(name: "Zizek Pulaski", age: 4), preferedColors: ["blue?", "green?"])
        user.luckyNumber = 7
        user.email = "exemple@gmail.com"
        try user.validate()
        try user.pet.validate()

        let secondUser = User(name: "Natan", age: 30, pet: Pet(name: "Nina", age: 4), preferedColors: ["pink"])
        secondUser.profilePictureURL = "https://www.somedomain.com/somePath.png"
        secondUser.email = "natan@vapor.codes"
        try secondUser.validate()
    }

    func testASCII() throws {
        XCTAssertEqual(Validator<String>.ascii.validate("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789").isFailure, false)
        XCTAssertEqual(Validator<String>.ascii.validate(" !\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~").isFailure, false)
        XCTAssertEqual(Validator<String>.ascii.validate("\n\r\t").isFailure, false)
        
        XCTAssertEqual(Validator<String>.ascii.validate("\n\r\t\u{129}").isFailure, true)
        XCTAssertEqual(Validator<String>.ascii.validate("ABCDEFGHIJKLMNOPQR🤠STUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/").isFailure, true)
    }

    func testAlphanumeric() throws {
        XCTAssertEqual(Validator<String>.alphanumeric.validate("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789").isFailure, false)
        XCTAssertEqual(Validator<String>.alphanumeric.validate("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/").isFailure, true)
    }
    
    func testEmpty() throws {
        XCTAssertEqual(Validator<String>.empty.validate("").isFailure, false)
        XCTAssertEqual(Validator<String>.empty.validate("something").isFailure, true)
        XCTAssertEqual(Validator<[Int]>.empty.validate([]).isFailure, false)
        XCTAssertEqual(Validator<[Int]>.empty.validate([1, 2]).isFailure, true)
    }

    func testEmail() throws {
        XCTAssertEqual(Validator<String>.email.validate("tanner@vapor.codes").isFailure, false)
        XCTAssertEqual(Validator<String>.email.validate("tanner@vapor.codestanner@vapor.codes").isFailure, true)
        XCTAssertEqual(Validator<String>.email.validate("tanner@vapor.codes.").isFailure, true)
        XCTAssertEqual(Validator<String>.email.validate("tanner@@vapor.codes").isFailure, true)
        XCTAssertEqual(Validator<String>.email.validate("@vapor.codes").isFailure, true)
        XCTAssertEqual(Validator<String>.email.validate("tanner@codes").isFailure, true)
        XCTAssertEqual(Validator<String>.email.validate("asdf").isFailure, true)
    }
    
    func testRange() throws {
        XCTAssertEqual(Validator<Int>.range(-5...5).validate(4).isFailure, false)
        XCTAssertEqual(Validator<Int>.range(-5...5).validate(5).isFailure, false)
        XCTAssertEqual(Validator<Int>.range(-5...5).validate(-5).isFailure, false)
        XCTAssertEqual(Validator<Int>.range(-5...5).validate(6).failureDescription, "is greater than maximum of 5")
        XCTAssertEqual(Validator<Int>.range(-5...5).validate(-6).failureDescription, "is less than minimum of -5")

        XCTAssertEqual(Validator<Int>.range(5...).validate(.max).isFailure, false)

        XCTAssertEqual(Validator<Int>.range(-5..<6).validate(-5).isFailure, false)
        XCTAssertEqual(Validator<Int>.range(-5..<6).validate(-4).isFailure, false)
        XCTAssertEqual(Validator<Int>.range(-5..<6).validate(5).isFailure, false)
        XCTAssertEqual(Validator<Int>.range(-5..<6).validate(-6).isFailure, true)
        XCTAssertEqual(Validator<Int>.range(-5..<6).validate(6).isFailure, true)
    }

    func testCountCharacters() throws {
        let validator = Validator<String>.count(1...6)
        XCTAssertEqual(validator.validate("1").isFailure, false)
        XCTAssertEqual(validator.validate("123").isFailure, false)
        XCTAssertEqual(validator.validate("123456").isFailure, false)
        XCTAssertEqual(validator.validate("").failureDescription, "is less than minimum of 1 character(s)")
        XCTAssertEqual(validator.validate("1234567").failureDescription, "is greater than maximum of 6 character(s)")
    }

    func testCountItems() throws {
        let validator = Validator<[Int]>.count(1...6)
        XCTAssertEqual(validator.validate([1]).isFailure, false)
        XCTAssertEqual(validator.validate([1, 2, 3]).isFailure, false)
        XCTAssertEqual(validator.validate([1, 2, 3, 4, 5, 6]).isFailure, false)
        XCTAssertEqual(validator.validate([]).failureDescription, "is less than minimum of 1 item(s)")
        XCTAssertEqual(validator.validate([1, 2, 3, 4, 5, 6, 7]).failureDescription, "is greater than maximum of 6 item(s)")
    }

    func testURL() throws {
        XCTAssertEqual(Validator<String>.url.validate("https://www.somedomain.com/somepath.png").isFailure, false)
        XCTAssertEqual(Validator<String>.url.validate("https://www.somedomain.com/").isFailure, false)
        XCTAssertEqual(Validator<String>.url.validate("file:///Users/vapor/rocks/somePath.png").isFailure, false)
        XCTAssertEqual(Validator<String>.url.validate("www.somedomain.com/").isFailure, true)
        XCTAssertEqual(Validator<String>.url.validate("bananas").isFailure, true)
    }
    
    static var allTests = [
        ("testValidate", testValidate),
        ("testASCII", testASCII),
        ("testAlphanumeric", testAlphanumeric),
        ("testEmpty", testEmpty),
        ("testEmail", testEmail),
        ("testRange", testRange),
        ("testCountCharacters", testCountCharacters),
        ("testCountItems", testCountItems),
        ("testURL", testURL),
    ]
}

final class User: Validatable, Codable {
    var id: Int?
    var name: String
    var age: Int
    var email: String?
    var pet: Pet
    var luckyNumber: Int?
    var profilePictureURL: String?
    var preferedColors: [String]

    init(id: Int? = nil, name: String, age: Int, pet: Pet, preferedColors: [String] = []) {
        self.id = id
        self.name = name
        self.age = age
        self.pet = pet
        self.preferedColors = preferedColors
    }

    static func validations(_ validations: inout Validations<User>){
        // validate name is at least 5 characters and alphanumeric
        validations.add(\.name, at: "name", is: .count(5...) && .alphanumeric)
        // validate age is 18 or older
        validations.add(\.age, is: .range(18...), customMessage: "age is less than 18")
        // validate the email is valid and is not nil
        validations.add(\.email, is: .nil || .email, customError: UserError.email)
        validations.add(\.email, at: "email", is: !.nil && .email)
        validations.add(\.email, at: "email", is: .email && !.nil) // test other way
        // validate the email is valid or is nil
        
        validations.add(\.email, is: .email || .nil, customError: UserError.email) // test other way
        // validate that the lucky number is nil or is 5 or 7
        validations.add(\.luckyNumber, is: .nil || .in(5, 7), customError: UserError.otherError)
        // validate that the profile picture is nil or a valid URL
        validations.add(\.profilePictureURL, is: .url || .nil, customError: UserError.otherError)
        validations.add(\.preferedColors, is: !.empty, customError: UserError.otherError)
        print(validations)
    }
}

fileprivate enum UserError: String, ValidationError {
    case email
    case otherError
    
    var reason: String {
        switch self {
        case .email:
            return "invalid email"
        case .otherError:
            return "other error"
        }
    }
}

final class Pet: Codable, Validatable {
    var name: String
    var age: Int
    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }

    static func validations(_ validations: inout Validations<Pet>) {
        validations.add(\.name, is: .count(5...) && .characterSet(.alphanumerics + .whitespaces), customMessage: "some error")
        validations.add(\.age, at: "age", is: .range(3...))
    }
}
