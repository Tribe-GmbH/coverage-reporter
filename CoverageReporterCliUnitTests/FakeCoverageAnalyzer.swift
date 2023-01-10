import CoverageAnalyzer

internal class FakeCoverageAnalyzer: CoverageAnalyzerProtocol {
    private var errorToReturn: Error?
    private var resultToReturn: ThresholdComparisonResult?

    init(errorToReturn: Error) {
        self.errorToReturn = errorToReturn
    }

    init(resultToReturn: ThresholdComparisonResult) {
        self.resultToReturn = resultToReturn
    }

    func meetsThreshold(
        xcresultPath _: String,
        expectedThreshold _: Float
    ) -> Result<ThresholdComparisonResult, Error> {
        if let error = self.errorToReturn {
            return .failure(error)
        }

        if let resultToReturn = self.resultToReturn {
            return .success(resultToReturn)
        }

        return .success(.thresholdNotReached(actualCoverage: -1))
    }
}
