# `Validation`

Validation API helps you validate incoming data before using it.

## Introduction 

Validation's deep integration Swift KeyPath means you don't have to worry about which property is passed as a parameter, because it will always be attached to your model.

### Human-Readable Errors

Decoding structs using the `JSONDecoder` API will yield errors if any of the data is not valid. However, these error messages can sometimes lack human-readability. For example, take the following string-backed enum:

```swift
enum Color: String, Codable {
    case red, blue, green
}
```

If a user tries to pass the string `"purple"` to a property of type `Color`, they will get an error similar to the following:

```swift
"Cannot initialize Color from invalid String value purple for key favoriteColor"
```

While this error is technically correct and successfully protected the endpoint from an invalid value, it could do better informing the user about the mistake and which options are available. By using the Validation API, you can generate errors like the following:

```swift
"favoriteColor is not red, blue, or green"
```

Additionally, `Validations` will stop attempting to validate a type as soon as the first error is encountered. This means that even if there are many invalid properties, the user will only see the first error.

### Specific Validation

Sometimes you want more than just validating the type of a property. For example, validating the contents of a string or validating the size of an integer. The Validation API has `Validator` to help validate data like emails, character sets, integer ranges, and more.

## Validatable

To validate a struct, you will need to generate a `Validations` collection. This is most commonly done by conforming an existing type to `Validatable`. 

Let's take a look at how you could add validation to this simple `CreateUser`.

```swift
enum Color: String, Codable {
    case red, blue, green
}

struct CreateUser {
    var name: String
    var username: String
    var age: Int
    var email: String
    var favoriteColor: Color
}
```

### Adding Validations

The first step is to conform the type, in this case `CreateUser`, to `Validatable`. This can be done in an extension.

```swift
extension CreateUser: Validatable {
    static func validations(_ validations: inout Validations<User>) {
        // Validations go here.
    }
}
```

The static method `validations(_:)` will be called when `CreateUser` is validated. Any validations you want to perform should be added to the supplied `Validations` collection. Let's take a look at adding a simple validation to require that the user's email is valid.

```swift
validations.add(\.email, at: "email", is: .email)
```

The first parameter is the value's expected `KeyPath`, in this case `\.email`. This should match the property name on the type being validated. The second parameter, `at`, is the readable path, in this case `"email"`. The type usually matches the property's type, but not always. Finally, one or more `Validator`'s can be added after the third parameter, `is`. In this case, we are adding a single `Validator` that checks if the value is an email address.

### Validating a type

Once you've conformed your type to `Validatable`, the `Validatable.validate()` function can be used to validate.

```swift
let testUser = CreateUser(email: example@gmail.com)
try testUser.validate()
```

Now, try testing with an invalid email:

```swift
let email = "invalidemail.com"
let testUser = CreateUser(email: email)
try testUser.validate()
```

You should see the following error returned:

```swift
"email is not a valid email address"
```

### Integer Validation

Great, now let's try adding a validation for `age`.

```swift
validations.add(\.age, at: "age", is: .range(13...))
```

The age validation requires that the age is greater than or equal to `13`. If you try this, you should see a new error now:

```swift
let testUser = CreateUser(age: 12)
try testUser.validate() // age is less than minimum of 13
```

### String Validation

Next, let's add validations for `name` and `username`. 

```swift
validations.add(\.name, at: "name", is: !.empty)
validations.add(\.username, at: "username", is: .count(3...) && .alphanumeric)
```

The name validation uses the `!` operator to invert the `Validator.empty` validation. This will require that the string is not empty.

The username validation combines two validators using `&&`. This will require that the string is at least 3 characters long _and_ contains only alphanumeric characters.

### Enum Validation

Finally, let's take a look at a slightly more advanced validation to check that the supplied `favoriteColor` is valid.

```swift
validations.add(\.favoriteColor, at: "favoriteColor", is: .in("red", "blue", "green"))
```

Since it's not possible to send a `Color` from an invalid value, this validation uses `String` as the base type. It uses the `Validator.in(_:)` validator to verify that the value is a valid option: red, blue, or green.

### Custom Errors

You might want to add custom human-readable errors to your `Validations` or `Validator`. To do so simply provide the additional `customError` parameter which will override the default error.

```swift
enum CustomError: ValidationErrpr {
    case invalidEmail
    case invalidUsername 

    var reason: String {
        switch self {
        case .invalidEmail: return "invalid email format."
        case .invalidUsername: return "invalid username format."
        }
    }
}

validations.add(\.name, is: !.empty, customError: CustomError.invalidEmail)
validations.add(\.username, is: .count(3...) && .alphanumeric, customError: CustomError.invalidUsername)
```


## Validators

Below is a list of the currently supported validators and a brief explanation of what they do.

|Validation                     | Description                                            |
|-------------------------------|--------------------------------------------------------|
| `Validator.ascii`             | Contains only ASCII characters.                        |
| `Validator.alphanumeric`      | Contains only alphanumeric characters.                 |
| `Validator.characterSet(_:)`  | Contains only characters from supplied `CharacterSet`. |
| `Validator.count(_:)`         | Collection's count is within supplied bounds.          |
| `Validator.email`             | Contains a valid email.                                |
| `Validator.empty`             | Collection is empty.                                   |
| `Validator.in(_:)`            | Value is in supplied `Collection`.                     |
| `Validator.nil`               | Value is `null`.                                       |
| `Validator.range(_:)`         | Value is within supplied `Range`.                      |
| `Validator.url`               | Contains a valid URL.                                  |

Validators can also be combined to build complex validations using operators. 

|Operator | Position | Description                                  |     
|---------|----------|----------------------------------------------|
| `!`     | prefix   | Inverts a validator, requiring the opposite. |
| `&&`    | infix    | Combines two validators, requires both.      |
| `OR`    | infix    | Combines two validators, requires one.       |

## Custom Validators

Creating a custom validator for zip codes allows you to extend the functionality of the validation framework. In this section, we'll walk you through the steps to create a custom validator for validating zip codes.

First create a new type to represent the `ZipCode` validation results. This struct will be responsible for reporting whether a given string is a valid zip code.

```swift
extension ValidatorResults {
    /// Represents the result of a validator that checks if a string is a valid zip code.
    public struct ZipCode {
        /// Indicates whether the input is a valid zip code.
        public let isValidZipCode: Bool
    }
}
```

Next, conform the new type to `ValidatorResult`, which defines the behavior expected from a custom validator.

```swift
extension ValidatorResults.ZipCode: ValidatorResult {
    public var isFailure: Bool {
        !self.isValidZipCode
    }
    
    public var successDescription: String? {
        "is a valid zip code"
    }
    
    public var failureDescription: String? {
        "is not a valid zip code"
    }
}
```

Finally, implement the validation logic for zip codes. Use a regular expression to check whether the input string matches the format of a USA zip code.

```swift
private let zipCodeRegex: String = "^\\d{5}(?:[-\\s]\\d{4})?$"

extension Validator where T == String {
    /// Validates whether a `String` is a valid zip code.
    public static var zipCode: Validator<T> {
        .init { input in
            guard let range = input.range(of: zipCodeRegex, options: [.regularExpression]),
                  range.lowerBound == input.startIndex && range.upperBound == input.endIndex
            else {
                return ValidatorResults.ZipCode(isValidZipCode: false)
            }
            return ValidatorResults.ZipCode(isValidZipCode: true)
        }
    }
}
```

Now that you've defined the custom `zipCode` validator, you can use it to validate zip codes in your application. Simply add the following line to your validation code:

```swift
validations.add(\.zipCode, at: "zipCode", is: .zipCode)
```
