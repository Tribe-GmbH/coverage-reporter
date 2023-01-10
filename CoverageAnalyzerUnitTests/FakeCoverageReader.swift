import CoverageAnalyzer
import CoverageReader
import XCResultKit

internal class FakeCoverageReader: CoverageReaderProtocol {
    private var errorToReturn: Error?
    private var coverageToReturn: CodeCoverage?
    var calls: [String] = []

    init(errorToReturn: Error) {
        self.errorToReturn = errorToReturn
    }

    init(coverageToReturn: CodeCoverage) {
        self.coverageToReturn = coverageToReturn
    }

    func extractCoverageData(path: String) -> Result<CodeCoverage, Error> {
        self.calls.append(path)

        if let error = self.errorToReturn {
            return .failure(error)
        }

        if let coverage = self.coverageToReturn {
            return .success(coverage)
        }

        return .success(CodeCoverage())
    }
}
