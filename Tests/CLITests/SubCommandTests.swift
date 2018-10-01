import XCTest
@testable import CLI

class SubCommandTests: XCTestCase {
    func tes_priority() {
        let subCommand = SubCommand(commands: [:])
        XCTAssertEqual(subCommand.priority, 0.25)
    }

    func test_usage() {
        let subCommand = SubCommand(commands: [:])
        subCommand.setup(withLabel: "label")
        XCTAssertEqual(subCommand.usage, "label")
    }

    func test_help() {
        let subCommand = SubCommand(commands: [
            "edit": Command(documentation: "The documentation for edit"),
            "unedit": Command(documentation: "The documentation for unedit"),
            "random": Command(documentation: "")
        ])

        subCommand.setup(withLabel: "label")
        XCTAssertEqual(subCommand.help, [
            ArgumentHelp(category: "SUBCOMMANDS", label: "edit", description: "The documentation for edit"),
            ArgumentHelp(category: "SUBCOMMANDS", label: "random", description: ""),
            ArgumentHelp(category: "SUBCOMMANDS", label: "unedit", description: "The documentation for unedit"),
        ])
    }

    func test_parse_noArguments() {
        let subCommand = SubCommand(commands: [
            "edit": Command(documentation: "The documentation for edit"),
            "unedit": Command(documentation: "The documentation for unedit"),
            "random": Command(documentation: "Some random command")
        ])

        subCommand.setup(withLabel: "label")

        var leftover: [String] = []
        XCTAssertThrowsError(
            try subCommand.parse(arguments: [], leftover: &leftover),
            equals: SubCommandMissingArgumentError())
    }

    func test_parse_invalidValue() {
        let subCommand = SubCommand(commands: [
            "edit": Command(documentation: "The documentation for edit"),
            "unedit": Command(documentation: "The documentation for unedit"),
            "random": Command(documentation: "Some random command")
        ])

        subCommand.setup(withLabel: "label")

        var leftover: [String] = []
        XCTAssertThrowsError(
            try subCommand.parse(arguments: ["incorrect"], leftover: &leftover),
            equals: InvalidSubCommandError(command: "incorrect", proposition: nil))
        XCTAssertThrowsError(
            try subCommand.parse(arguments: ["edits"], leftover: &leftover),
            equals: InvalidSubCommandError(command: "edits", proposition: "edit"))
        XCTAssertThrowsError(
            try subCommand.parse(arguments: ["undit"], leftover: &leftover),
            equals: InvalidSubCommandError(command: "undit", proposition: "unedit"))
        XCTAssertThrowsError(
            try subCommand.parse(arguments: ["unnedit"], leftover: &leftover),
            equals: InvalidSubCommandError(command: "unnedit", proposition: "unedit"))
    }

    func test_parse_validCommand() throws {
        class MockCommand: Command {
            private(set) var arguments: [String] = []

            override func parse<I: IteratorProtocol>(arguments: inout I) throws where I.Element == String {
                self.arguments.removeAll()
                while let argument = arguments.next() {
                    self.arguments.append(argument)
                }
            }
        }

        let mockCommand = MockCommand(documentation: "")
        let subCommand = SubCommand(commands: ["cmd": mockCommand])

        subCommand.setup(withLabel: "label")

        var leftover: [String] = []
        try subCommand.parse(arguments: ["cmd", "arg1", "arg2"], leftover: &leftover)
        XCTAssert(subCommand.value === mockCommand)
        XCTAssertEqual(mockCommand.arguments, ["arg1", "arg2"])
    }
}