import Nimble
import Quick

final class CliSpec: QuickSpec {
    override class func spec() {
        describe("CLI") {
            it("prints the help message when no commands are given") {
                let projectFolder = determineProjectFolder()
                let result = execute(command: "\(projectFolder)/.build/release/coverage-reporter")

                expect(result).to(equal(.done(
                    output: "OVERVIEW: A tool to extract, analyze and format coverage information from\nxcresult reports.\n\nUSAGE: coverage-reporter <subcommand>\n\nOPTIONS:\n  -h, --help              Show help information.\n\nSUBCOMMANDS:\n  verify                  Checks if the collected coverage is below the given\n                          threshold.\n\n  See \'coverage-reporter help <subcommand>\' for detailed help.\n",
                    exitCode: 0
                )))
            }

            it("prints an error message when an unknown subcommand is given") {
                let projectFolder = determineProjectFolder()
                let result = execute(command: "\(projectFolder)/.build/release/coverage-reporter foo")

                expect(result).to(equal(.done(
                    output: "Error: Unexpected argument \'foo\'\nUsage: coverage-reporter <subcommand>\n  See \'coverage-reporter --help\' for more information.\n",
                    exitCode: 64
                )))
            }

            describe("verify command") {
                it("prints an error message when an invalid threshold is given") {
                    let projectFolder = determineProjectFolder()
                    let result = execute(command: "\(projectFolder)/.build/release/coverage-reporter verify foo bar")

                    expect(result).to(equal(.done(
                        output: "Error: The value \'bar\' is invalid for \'<threshold>\'\nHelp:  <threshold>  The expected coverage threshold (0-100).\nUsage: coverage-reporter verify <xcresult-path> <threshold>\n  See \'coverage-reporter verify --help\' for more information.\n",
                        exitCode: 64
                    )))
                }

                it("prints an error message when the given path to the xcresult doesn’t exist") {
                    let projectFolder = determineProjectFolder()
                    let result = execute(command: "\(projectFolder)/.build/release/coverage-reporter verify foo 42")

                    expect(result).to(equal(.done(output: "Error: The xcresult path does not exist\n", exitCode: 1)))
                }

                it("prints an error message when the threshold greater than 100") {
                    let projectFolder = determineProjectFolder()
                    let result =
                        execute(
                            command: "\(projectFolder)/.build/release/coverage-reporter verify CliIntegrationTests/fixtures/example.xcresult 142"
                        )

                    expect(result)
                        .to(equal(.done(
                            output: "Error: Threshold is too big (max allowed value is 100)\n",
                            exitCode: 1
                        )))
                }

                it(
                    "prints a success message and exits with exit-code 0 when the actual coverage is greater than the given threshold"
                ) {
                    let projectFolder = determineProjectFolder()
                    let result = execute(
                        command: "\(projectFolder)/.build/release/coverage-reporter verify CliIntegrationTests/fixtures/example.xcresult 10",
                        ignoreErrorOutput: true
                    )

                    expect(result)
                        .to(equal(.done(
                            output: "Success: line coverage of 97.90% exceeds threshold of 10.00%\n",
                            exitCode: 0
                        )))
                }

                it(
                    "prints a error message and exits with exit-code 1 when the actual coverage is less than the given threshold"
                ) {
                    let projectFolder = determineProjectFolder()
                    let result = execute(
                        command: "\(projectFolder)/.build/release/coverage-reporter verify CliIntegrationTests/fixtures/example.xcresult 100",
                        ignoreErrorOutput: true
                    )

                    expect(result)
                        .to(equal(.done(
                            output: "Failure: line coverage of 97.90% is below threshold of 100.00%\n",
                            exitCode: 1
                        )))
                }
            }
        }
    }
}
