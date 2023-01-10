import Foundation
import XCResultKit

public protocol CoverageReaderProtocol {
    func extractCoverageData(path: String) -> Result<CodeCoverage, Error>
}

public struct CoverageReader: CoverageReaderProtocol {
    private let fileManager: FileManagerProtocol
    private let xcResultReaderFactory: XCResultFileReaderFactory

    public init(fileManager: FileManagerProtocol, xcResultReaderFactory: XCResultFileReaderFactory) {
        self.fileManager = fileManager
        self.xcResultReaderFactory = xcResultReaderFactory
    }

    public func extractCoverageData(path: String) -> Result<CodeCoverage, Error> {
        var isDirectory: ObjCBool = false
        let fileExists = self.fileManager.fileExists(atPath: path, isDirectory: &isDirectory)

        if !fileExists {
            return .failure(CoverageReaderError.pathDoesNotExist)
        }
        if !isDirectory.boolValue {
            return .failure(CoverageReaderError.pathExistsButIsNotADirectory)
        }

        let url = URL(fileURLWithPath: path)
        let resultFile = self.xcResultReaderFactory.make(url: url)

        guard let coverage = resultFile.getCodeCoverage() else {
            return .failure(CoverageReaderError.coverageDataExtractionFailure)
        }

        return .success(coverage)
    }
}
