import CoverageAnalyzer
import CoverageReporterCli
import Nimble
import Quick

private enum ExampleError: Error, Equatable {
    case anyError
}

final class VerifyCommandSpec: QuickSpec {
    override class func spec() {
        describe("VerifyCommand") {
            it("returns an error when no arguments are given") {
                expect {
                    try MainCommand.parseAsRoot(["verify"])
                }.to(throwError {
                    (error: Error) in
                    expect(MainCommand.message(for: error)).to(equal("Missing expected argument '<xcresult-path>'"))
                })
            }

            it("returns an error when only the xcresult path argument is given") {
                expect {
                    try MainCommand.parseAsRoot(["verify", "the-path"])
                }.to(throwError {
                    (error: Error) in
                    expect(MainCommand.message(for: error)).to(equal("Missing expected argument '<threshold>'"))
                })
            }

            it("returns an error when only the threshold argument is not a number") {
                expect {
                    try MainCommand.parseAsRoot(["verify", "the-path", "not-a-number"])
                }.to(throwError {
                    (error: Error) in
                    expect(MainCommand.message(for: error))
                        .to(equal("The value 'not-a-number' is invalid for '<threshold>'"))
                })
            }

            it("returns an error when the coverage threshold check fails") {
                let command = try! MainCommand.parseAsRoot(["verify", "the-path", "42"]) as! CommandWithContext
                let coverageAnalyzer = FakeCoverageAnalyzer(errorToReturn: ExampleError.anyError)
                let context = CommandContext(coverageAnalyzer: coverageAnalyzer, reporter: FakeReporter())

                expect {
                    try command.runWithContext(context)
                }.to(throwError {
                    error in
                    expect(error).to(equal(ExampleError.anyError))
                })
            }

            it("returns a command failure when the coverage check was performed but the threshold was not reached") {
                let command = try! MainCommand.parseAsRoot(["verify", "the-path", "42"]) as! CommandWithContext
                let coverageAnalyzer = FakeCoverageAnalyzer(
                    resultToReturn: ThresholdComparisonResult
                        .thresholdNotReached(actualCoverage: 42)
                )
                let context = CommandContext(coverageAnalyzer: coverageAnalyzer, reporter: FakeReporter())

                let result = try! command.runWithContext(context)

                expect(result).to(equal(CommandResult.failure))
            }

            it("reports a message when the coverage check was performed but the threshold was not reached") {
                let command = try! MainCommand.parseAsRoot(["verify", "the-path", "42"]) as! CommandWithContext
                let coverageAnalyzer = FakeCoverageAnalyzer(
                    resultToReturn: ThresholdComparisonResult
                        .thresholdNotReached(actualCoverage: 21)
                )
                let reporter = FakeReporter()
                let context = CommandContext(coverageAnalyzer: coverageAnalyzer, reporter: reporter)

                _ = try! command.runWithContext(context)

                expect(reporter.messages).to(equal(["Failure: line coverage of 21.00% is below threshold of 42.00%"]))
            }

            it("returns a command success when the coverage check was performed and the threshold was reached") {
                let command = try! MainCommand.parseAsRoot(["verify", "the-path", "42"]) as! CommandWithContext
                let coverageAnalyzer = FakeCoverageAnalyzer(
                    resultToReturn: ThresholdComparisonResult
                        .thresholdReached(actualCoverage: 42)
                )
                let context = CommandContext(coverageAnalyzer: coverageAnalyzer, reporter: FakeReporter())

                let result = try! command.runWithContext(context)

                expect(result).to(equal(CommandResult.success))
            }

            it("reports a message when the coverage check was performed and the threshold was reached") {
                let command = try! MainCommand.parseAsRoot(["verify", "the-path", "42"]) as! CommandWithContext
                let coverageAnalyzer = FakeCoverageAnalyzer(
                    resultToReturn: ThresholdComparisonResult
                        .thresholdReached(actualCoverage: 21)
                )
                let reporter = FakeReporter()
                let context = CommandContext(coverageAnalyzer: coverageAnalyzer, reporter: reporter)

                _ = try! command.runWithContext(context)

                expect(reporter.messages).to(equal(["Success: line coverage of 21.00% exceeds threshold of 42.00%"]))
            }
        }
    }
}
