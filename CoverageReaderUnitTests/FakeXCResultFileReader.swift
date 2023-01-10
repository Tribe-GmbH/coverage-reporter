import CoverageReader
import Foundation
import XCResultKit

internal class FakeXCResultFileReader: XCResultFileReader {
    let url: URL
    private let coverageToReturn: CodeCoverage?

    init(url: URL, coverageToReturn: CodeCoverage?) {
        self.url = url
        self.coverageToReturn = coverageToReturn
    }

    func getCodeCoverage() -> CodeCoverage? {
        return self.coverageToReturn
    }
}

internal class FakeXCResultFileReaderFactory: XCResultFileReaderFactory {
    private let coverageToReturn: CodeCoverage?
    private var xcResultFileReader: FakeXCResultFileReader?

    init(coverageToReturn: CodeCoverage?) {
        self.coverageToReturn = coverageToReturn
    }

    func make(url: URL) -> XCResultFileReader {
        let reader = FakeXCResultFileReader(url: url, coverageToReturn: self.coverageToReturn)

        self.xcResultFileReader = reader

        return reader
    }

    func getXCResultFileReaderInstance() -> FakeXCResultFileReader? {
        return self.xcResultFileReader
    }
}
