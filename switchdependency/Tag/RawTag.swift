import Foundation

struct RawTag: RawRepresentable {
    var rawValue: String

    func getVersion() throws -> String? {
        if tagDoesNotExist() {
            return nil
        } else {
            return try rawValue.firstSubstringMatching(regex: CommonRegex.gitTag)
        }
    }

    private func tagDoesNotExist() -> Bool {
        rawValue.contains("No tags can describe")
    }
}
