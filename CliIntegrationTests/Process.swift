import Foundation

internal func determineProjectFolder() -> String {
    let currentFileUrl = URL(fileURLWithPath: #file)
    let currentFolderUrl = currentFileUrl.deletingLastPathComponent()
    let projectFolderUrl = currentFolderUrl.appending(component: "..")

    return projectFolderUrl.standardized.path()
}

private func readTextFromFileHandle(_ handle: FileHandle) -> String {
    let rawData = handle.readDataToEndOfFile()
    return String(decoding: rawData, as: UTF8.self)
}

internal enum ProcessResult: Equatable {
    case done(output: String, exitCode: Int)
    case failed(reason: String)
}

internal func execute(command: String, ignoreErrorOutput: Bool = false) -> ProcessResult {
    let process = Process()
    let outputStream = Pipe()

    do {
        process.launchPath = "/bin/sh"
        process.arguments = ["-c", command]

        process.standardOutput = outputStream
        if !ignoreErrorOutput {
            process.standardError = outputStream
        }

        try process.run()
        process.waitUntilExit()

        let output = readTextFromFileHandle(outputStream.fileHandleForReading)
        let exitCode = process.terminationStatus

        return .done(output: output, exitCode: Int(exitCode))
    } catch {
        return .failed(reason: "\(error)")
    }
}
