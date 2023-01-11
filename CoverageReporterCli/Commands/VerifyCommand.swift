import ArgumentParser
import Foundation

protocol NumericStringRepresentable: CVarArg {}
extension Double: NumericStringRepresentable {}
extension Float: NumericStringRepresentable {}

private func formatPercentageValue<T: NumericStringRepresentable>(_ value: T) -> String {
    return String(format: "%.2f", value) + "%"
}

struct VerifyCommand: CommandWithContext {
    static var configuration = CommandConfiguration(
        commandName: "verify", abstract: "Checks if the collected coverage is below the given threshold."
    )

    @Argument(help: ArgumentHelp(
        "The path to the .xcresult directory.",
        valueName: "xcresult-path"
    )) var xcResultPath: String

    @Argument(help: ArgumentHelp(
        "The expected coverage threshold (0-100).",
        valueName: "threshold"
    )) var expectedThreshold: Float

    func runWithContext(_ context: CommandContext) throws -> CommandResult {
        let result = context.coverageAnalyzer.meetsThreshold(
            xcresultPath: self.xcResultPath,
            expectedThreshold: self.expectedThreshold
        )

        switch result {
        case let .success(comparisonResult):
            switch comparisonResult {
            case let .thresholdReached(actualCoverage):
                context.reporter
                    .report(
                        "Success: line coverage of \(formatPercentageValue(actualCoverage)) exceeds threshold of \(formatPercentageValue(self.expectedThreshold))"
                    )
                return .success
            case let .thresholdNotReached(actualCoverage):
                context.reporter
                    .report(
                        "Failure: line coverage of \(formatPercentageValue(actualCoverage)) is below threshold of \(formatPercentageValue(self.expectedThreshold))"
                    )
                return .failure
            }
        case let .failure(error):
            throw error
        }
    }
}
