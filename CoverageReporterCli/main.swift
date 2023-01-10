import CoverageAnalyzer
import CoverageReader
import Foundation
import XCResultKit

extension FileManager: FileManagerProtocol {}
extension XCResultFile: XCResultFileReader {}

struct XCResultFileFactory: XCResultFileReaderFactory {
    func make(url: URL) -> XCResultFileReader {
        return XCResultFile(url: url)
    }
}

private let coverageReader = CoverageReader(
    fileManager: FileManager.default,
    xcResultReaderFactory: XCResultFileFactory()
)
private let coverageAnalyzer = CoverageAnalyzer(coverageReader: coverageReader)

private let context = CommandContext(coverageAnalyzer: coverageAnalyzer, reporter: ConsoleReporter())

do {
    var command = try MainCommand.parseAsRoot()

    if let commandWithContext = command as? CommandWithContext {
        let result = try commandWithContext.runWithContext(context)
        if result == CommandResult.failure {
            Foundation.exit(1)
        }
    } else {
        try command.run()
    }
} catch {
    MainCommand.exit(withError: error)
}
