import Foundation

struct ExecutionError: Error, CustomNSError {
    static var errorDomain: String { "SwitchDependencyErrorDomain" }

    static func make(_ reason: String) -> Error {
        NSError(
            domain: errorDomain,
            code: 1,
            userInfo: ["reason": reason]
        )
    }
}
