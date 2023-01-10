import Foundation

public protocol FileManagerProtocol {
    func fileExists(atPath: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) -> Bool
}
