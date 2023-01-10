import ArgumentParser

public struct MainCommand: CommandWithContext {
    public init() {}

    public static var configuration = CommandConfiguration(
        commandName: "coverage-reporter",
        abstract: "A tool to extract, analyze and format coverage information from xcresult reports.",
        subcommands: [VerifyCommand.self]
    )
}
