import CoverageAnalyzer
import CoverageReporterCli
import Nimble
import Quick

final class MainCommandSpec: QuickSpec {
    override class func spec() {
        describe("MainCommand") {
            it("returns an error when an unknonwn subcommand is given") {
                expect {
                    try MainCommand.parseAsRoot(["unknown-command"])
                }.to(throwError {
                    (error: Error) in
                    expect(MainCommand.message(for: error)).to(equal("Unexpected argument 'unknown-command'"))
                })
            }

            it("doesn’t return an error when no subcommands are given") {
                expect {
                    try MainCommand.parseAsRoot([])
                }.notTo(throwError())
            }
        }
    }
}
