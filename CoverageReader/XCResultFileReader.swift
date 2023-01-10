import Foundation
import XCResultKit

public protocol XCResultFileReader {
    func getCodeCoverage() -> CodeCoverage?
}

public protocol XCResultFileReaderFactory {
    func make(url: URL) -> XCResultFileReader
}
