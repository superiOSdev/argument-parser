import Foundation

public class Argument<T: ArgumentType>: CommandProperty {
    public private(set) var name: String?
    public let documentation: String?
    public private(set) var value: T!
    public let priority = 0.25

    public var usage: String? {
        return name.map({ "<\($0)>" })
    }

    public var info: [PropertyInfo] {
        if let name = name, let documentation = documentation {
            return [
                PropertyInfo(
                    category: "ARGUMENTS",
                    label: name,
                    documentation: documentation)
            ]
        } else {
            return []
        }
    }

    public init(name: String? = nil, documentation: String? = nil) {
        self.name = name
        self.documentation = documentation
    }

    public func setup(withLabel label: String) {
        if name == nil {
            name = label
        }
    }

    @discardableResult
    public func parse(arguments: inout [String]) throws -> Bool {
        if let firstArgument = arguments.first {
            guard !firstArgument.starts(with: "-") else {
                return false
            }
        }

        do {
            value = try T.init(arguments: &arguments)
            return true
        } catch ParseError.missingArgument {
            throw ArgumentMissingError(argument: name ?? "")
        } catch ParseError.invalidFormat(let value) {
            throw ArgumentInvalidFormatError(argument: name ?? "", value: value)
        }
    }

    public func validate(
        in commands: [Command],
        outputStream: inout TextOutputStream,
        errorStream: inout TextOutputStream
    ) throws {
        guard value != nil else {
            throw ArgumentMissingError(argument: name ?? "")
        }
    }
}

public struct ArgumentMissingError: LocalizedError, Equatable {
    public let argument: String

    public var errorDescription: String? {
        return "missing argument '\(argument)'"
    }
}

public struct ArgumentInvalidFormatError: LocalizedError, Equatable {
    public let argument: String
    public let value: String

    public var errorDescription: String? {
        return "invalid format '\(value)' for argument '\(argument)'"
    }
}
