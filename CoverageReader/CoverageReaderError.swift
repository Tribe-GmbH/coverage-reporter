import Foundation

public enum CoverageReaderError: String, Error, CustomStringConvertible {
    case coverageDataExtractionFailure = "Failed to extract coverage data from xcresult"
    case pathDoesNotExist = "The xcresult path does not exist"
    case pathExistsButIsNotADirectory = "The xcresult path exists but is not a directory"

    public var description: String {
        return self.rawValue
    }
}
