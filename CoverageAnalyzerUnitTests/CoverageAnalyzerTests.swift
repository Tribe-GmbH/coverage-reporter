import CoverageAnalyzer
import Nimble
import Quick
import XCResultKit

private enum ExampleError: Error {
    case anyError
}

final class CoverageAnalyzerSpec: QuickSpec {
    override func spec() {
        describe("CoverageAnalyzer") {
            describe("meetsThreshold()") {
                it("returns a failure when given threshold is a negative number") {
                    let coverageReader = FakeCoverageReader(coverageToReturn: CodeCoverage())
                    let analyzer = CoverageAnalyzer(coverageReader: coverageReader)

                    let result = analyzer.meetsThreshold(xcresultPath: "foo", expectedThreshold: -10)

                    expect(result).to(beFailure { error in
                        expect("\(error)").to(equal("Threshold is too small (minimum value should be 0)"))
                    })
                }

                it("returns a failure when given threshold is greater than 100") {
                    let coverageReader = FakeCoverageReader(coverageToReturn: CodeCoverage())
                    let analyzer = CoverageAnalyzer(coverageReader: coverageReader)

                    let result = analyzer.meetsThreshold(xcresultPath: "foo", expectedThreshold: 101)

                    expect(result).to(beFailure { error in
                        expect("\(error)").to(equal("Threshold is too big (max allowed value is 100)"))
                    })
                }

                it("attempts to read the code coverage of the given xcresult path") {
                    let coverageReader = FakeCoverageReader(coverageToReturn: CodeCoverage())
                    let analyzer = CoverageAnalyzer(coverageReader: coverageReader)

                    _ = analyzer.meetsThreshold(xcresultPath: "path/to/xcresult", expectedThreshold: 42)

                    expect(coverageReader.calls).to(equal(["path/to/xcresult"]))
                }

                it(
                    "doesn’t attempts to read the code coverage of the given xcresult path when the given threshold is invalid"
                ) {
                    let coverageReader = FakeCoverageReader(coverageToReturn: CodeCoverage())
                    let analyzer = CoverageAnalyzer(coverageReader: coverageReader)

                    _ = analyzer.meetsThreshold(xcresultPath: "path/to/xcresult", expectedThreshold: -1)

                    expect(coverageReader.calls.count).to(equal(0))
                }

                it("returns a failure when reading the code coverage fails") {
                    let coverageReader = FakeCoverageReader(errorToReturn: ExampleError.anyError)
                    let analyzer = CoverageAnalyzer(coverageReader: coverageReader)

                    let result = analyzer.meetsThreshold(xcresultPath: "path/to/xcresult", expectedThreshold: 42)

                    expect(result).to(beFailure { error in
                        expect(error).to(matchError(ExampleError.anyError))
                    })
                }

                it("returns success with thresholdReached when the line coverage is greater than the given threshold") {
                    let coverage = CodeCoverage(
                        target: "the-target",
                        files: [CodeCoverageFile(
                            coveredLines: 100,
                            lineCoverage: 84,
                            path: "foo/bar",
                            name: "foo",
                            executableLines: 200,
                            functions: []
                        )]
                    )
                    let coverageReader = FakeCoverageReader(coverageToReturn: coverage)
                    let analyzer = CoverageAnalyzer(coverageReader: coverageReader)

                    let result = analyzer.meetsThreshold(xcresultPath: "path/to/xcresult", expectedThreshold: 42)

                    expect(result).to(beSuccess { value in
                        expect(value).to(equal(ThresholdComparisonResult.thresholdReached(actualCoverage: 50)))
                    })
                }

                it("returns success with thresholdReached when the line coverage is equals to the given threshold") {
                    let coverage = CodeCoverage(
                        target: "the-target",
                        files: [CodeCoverageFile(
                            coveredLines: 100,
                            lineCoverage: 84,
                            path: "foo/bar",
                            name: "foo",
                            executableLines: 200,
                            functions: []
                        )]
                    )
                    let coverageReader = FakeCoverageReader(coverageToReturn: coverage)
                    let analyzer = CoverageAnalyzer(coverageReader: coverageReader)

                    let result = analyzer.meetsThreshold(xcresultPath: "path/to/xcresult", expectedThreshold: 50)

                    expect(result).to(beSuccess { value in
                        expect(value).to(equal(ThresholdComparisonResult.thresholdReached(actualCoverage: 50)))
                    })
                }

                it("returns success with thresholdNotReached when the line coverage is lower than the given threshold") {
                    let coverage = CodeCoverage(
                        target: "the-target",
                        files: [CodeCoverageFile(
                            coveredLines: 1,
                            lineCoverage: 84,
                            path: "foo/bar",
                            name: "foo",
                            executableLines: 200,
                            functions: []
                        )]
                    )
                    let coverageReader = FakeCoverageReader(coverageToReturn: coverage)
                    let analyzer = CoverageAnalyzer(coverageReader: coverageReader)

                    let result = analyzer.meetsThreshold(xcresultPath: "path/to/xcresult", expectedThreshold: 42)

                    expect(result).to(beSuccess { value in
                        expect(value).to(equal(ThresholdComparisonResult.thresholdNotReached(actualCoverage: 0.5)))
                    })
                }
            }
        }
    }
}
