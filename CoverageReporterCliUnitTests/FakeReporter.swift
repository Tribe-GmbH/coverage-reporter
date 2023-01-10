import CoverageReporterCli

internal class FakeReporter: Reporter {
    var messages: [String] = []

    func report(_ message: String) {
        self.messages.append(message)
    }
}
