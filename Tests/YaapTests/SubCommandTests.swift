import XCTest
@testable import Yaap

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
            "edit": DummyCommand(documentation: "The documentation for edit"),
            "unedit": DummyCommand(documentation: "The documentation for unedit"),
            "random": DummyCommand(documentation: "")
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
            "edit": DummyCommand(),
            "unedit": DummyCommand(),
            "random": DummyCommand()
        ])

        subCommand.setup(withLabel: "label")

        var arguments: [String] = []
        XCTAssertThrowsError(try subCommand.parse(arguments: &arguments), equals: SubCommandMissingError())
    }

    func test_parse_invalidValue() {
        let subCommand = SubCommand(commands: [
            "edit": DummyCommand(),
            "unedit": DummyCommand(),
            "random": DummyCommand()
        ])

        subCommand.setup(withLabel: "label")

        var arguments = ["incorrect"]
        XCTAssertThrowsError(
            try subCommand.parse(arguments: &arguments),
            equals: InvalidSubCommandError(command: "incorrect", suggestion: nil))

        arguments = ["edits"]
        XCTAssertThrowsError(
            try subCommand.parse(arguments: &arguments),
            equals: InvalidSubCommandError(command: "edits", suggestion: "edit"))

        arguments = ["undit"]
        XCTAssertThrowsError(
            try subCommand.parse(arguments: &arguments),
            equals: InvalidSubCommandError(command: "undit", suggestion: "unedit"))

        arguments = ["unnedit"]
        XCTAssertThrowsError(
            try subCommand.parse(arguments: &arguments),
            equals: InvalidSubCommandError(command: "unnedit", suggestion: "unedit"))
    }

    func test_parse_validCommand() throws {
        let mockCommand = MockCommand()
        let subCommand = SubCommand(commands: ["cmd": mockCommand])

        subCommand.setup(withLabel: "label")

        var arguments = ["cmd", "arg1", "arg2"]
        try subCommand.parse(arguments: &arguments)
        XCTAssert(subCommand.value === mockCommand)
        XCTAssertEqual(mockCommand.arguments, ["arg1", "arg2"])
    }
}
