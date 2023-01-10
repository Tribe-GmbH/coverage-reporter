import CoverageReader
import XCResultKit

public enum ThresholdComparisonResult: Equatable {
    case thresholdReached(actualCoverage: Double)
    case thresholdNotReached(actualCoverage: Double)
}

public protocol CoverageAnalyzerProtocol {
    func meetsThreshold(xcresultPath: String, expectedThreshold: Float) -> Result<ThresholdComparisonResult, Error>
}

public struct CoverageAnalyzer: CoverageAnalyzerProtocol {
    private let coverageReader: CoverageReaderProtocol

    public init(coverageReader: CoverageReaderProtocol) {
        self.coverageReader = coverageReader
    }

    private func determineLineCoverage(xcresultPath: String) -> Result<Double, Error> {
        return self.coverageReader.extractCoverageData(path: xcresultPath).map { coverageData in

            let lineCoverageInPercentage = coverageData.lineCoverage * 100

            return lineCoverageInPercentage
        }
    }

    public func meetsThreshold(
        xcresultPath: String,
        expectedThreshold: Float
    ) -> Result<ThresholdComparisonResult, Error> {
        return validateThreshold(expectedThreshold).flatMap {
            validThreshold in

            return determineLineCoverage(xcresultPath: xcresultPath).flatMap {
                lineCoverageInPercentage in

                if lineCoverageInPercentage >= Double(validThreshold) {
                    return .success(.thresholdReached(actualCoverage: lineCoverageInPercentage))
                }

                return .success(.thresholdNotReached(actualCoverage: lineCoverageInPercentage))
            }
        }
    }
}
