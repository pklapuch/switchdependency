import Foundation

enum Operation: String {
    case local = "local"
    case remote = "remote"
    case fetchVersions = "fetchVersions"

    init(rawValue: String) throws {
        guard let operation = Operation(rawValue: rawValue) else {
            throw Self.invalidRawValueError(rawValue)
        }

        self = operation
    }

    private static func invalidRawValueError(_ rawValue: String) -> Error {
        NSError(
            domain: "SwitchDependencyError",
            code: 1,
            userInfo: ["reason": "Invalid rawValue: \(rawValue)"]
        )
    }
}
