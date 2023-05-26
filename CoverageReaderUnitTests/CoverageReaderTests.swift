import CoverageReader
import Foundation
import Nimble
import Quick
import XCResultKit

private struct Overrides {
    let fileExists: Bool
    let isDirectoryValue: Bool
    let coverage: CodeCoverage?

    init(fileExists: Bool = false, isDirectoryValue: Bool = false, coverage: CodeCoverage? = nil) {
        self.fileExists = fileExists
        self.isDirectoryValue = isDirectoryValue
        self.coverage = coverage
    }
}

private func createReader(_ overrides: Overrides = Overrides())
    -> (CoverageReader, FakeFileManager, FakeXCResultFileReaderFactory) {
    let fileManager = FakeFileManager(
        fileExistsReturnValue: overrides.fileExists,
        isDirectoryValue: overrides.isDirectoryValue
    )
    let xcResultReaderFactory = FakeXCResultFileReaderFactory(coverageToReturn: overrides.coverage)

    let reader = CoverageReader(fileManager: fileManager, xcResultReaderFactory: xcResultReaderFactory)

    return (reader, fileManager, xcResultReaderFactory)
}

final class CoverageReaderSpec: QuickSpec {
    override class func spec() {
        describe("CoverageReader") {
            describe("extractCoverageData()") {
                it("checks the given path to exist") {
                    let (reader, fileManager, _) = createReader(Overrides(fileExists: false))

                    _ = reader.extractCoverageData(path: "path/to/check")

                    expect(fileManager.calls).to(equal(["path/to/check"]))
                }

                it("returns a failure when the file does not exist") {
                    let (reader, _, _) = createReader(Overrides(fileExists: false))

                    let result = reader.extractCoverageData(path: "foo")

                    expect(result).to(beFailure { error in
                        expect(error).to(matchError(CoverageReaderError.pathDoesNotExist))
                    })
                }

                it("returns a failure when the file exists but is not a directory") {
                    let (reader, _, _) = createReader(Overrides(fileExists: true, isDirectoryValue: false))

                    let result = reader.extractCoverageData(path: "foo")

                    expect(result).to(beFailure { error in
                        expect(error).to(matchError(CoverageReaderError.pathExistsButIsNotADirectory))
                    })
                }

                it("reads the given xcresult path when it exists and is a directory") {
                    let (
                        reader,
                        _,
                        xcResultFileReaderFactory
                    ) = createReader(Overrides(fileExists: true, isDirectoryValue: true))

                    _ = reader.extractCoverageData(path: "path/to/read")

                    expect(xcResultFileReaderFactory.getXCResultFileReaderInstance()?.url)
                        .to(equal(URL(fileURLWithPath: "path/to/read")))
                }

                it("returns a failure when the coverage is not available") {
                    let (
                        reader,
                        _,
                        _
                    ) = createReader(Overrides(fileExists: true, isDirectoryValue: true, coverage: nil))

                    let result = reader.extractCoverageData(path: "path/to/read")

                    expect(result).to(beFailure { error in
                        expect(error).to(matchError(CoverageReaderError.coverageDataExtractionFailure))
                    })
                }

                it("returns the read coverage") {
                    let coverage = CodeCoverage()
                    let (
                        reader,
                        _,
                        _
                    ) = createReader(Overrides(fileExists: true, isDirectoryValue: true, coverage: coverage))

                    let result = reader.extractCoverageData(path: "path/to/read")

                    expect(result).to(beSuccess { value in
                        expect(value.lineCoverage).to(equal(0))
                    })
                }
            }
        }
    }
}
