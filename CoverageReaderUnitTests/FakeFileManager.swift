import CoverageReader
import Foundation

internal class FakeFileManager: FileManagerProtocol {
    var calls: [String] = []

    private var returnValues: (Bool, Bool)

    init(fileExistsReturnValue: Bool, isDirectoryValue: Bool) {
        self.returnValues = (fileExistsReturnValue, isDirectoryValue)
    }

    func fileExists(atPath: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) -> Bool {
        let (fileExistsReturnValue, isDirectoryValue) = self.returnValues

        self.calls.append(atPath)
        isDirectory?.pointee = ObjCBool(isDirectoryValue)

        return fileExistsReturnValue
    }
}
