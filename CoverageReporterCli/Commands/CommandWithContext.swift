import ArgumentParser
import CoverageAnalyzer

public struct CommandContext {
    let coverageAnalyzer: CoverageAnalyzerProtocol
    let reporter: Reporter

    public init(coverageAnalyzer: CoverageAnalyzerProtocol, reporter: Reporter) {
        self.coverageAnalyzer = coverageAnalyzer
        self.reporter = reporter
    }
}

public enum CommandResult: Equatable {
    case success
    case failure
}

public protocol CommandWithContext: ParsableCommand {
    func runWithContext(_ context: CommandContext) throws -> CommandResult
}

extension CommandWithContext {
    public func runWithContext(_: CommandContext) throws -> CommandResult {
        throw CleanExit.helpRequest(self)
    }
}
