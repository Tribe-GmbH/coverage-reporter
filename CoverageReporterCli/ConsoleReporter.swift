import Foundation

class ConsoleReporter: Reporter {
    func report(_ message: String) {
        print(message)
    }
}
