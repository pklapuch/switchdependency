import Foundation

struct CommandArguments: RawRepresentable {
    private enum ArgumentIndex {
        static let operation = 1
    }

    private enum Argument {
        static let rootPath = "-rootPath"
    }

    var rawValue: [String]

    func extractArgument(at index: Int) throws -> String {
        guard index < rawValue.count else {
            throw NSError(domain: "Not enough arguments!", code: 1)
        }

        return rawValue[index]
    }

    func extractArgument(named name: String) -> String? {
        guard let index = rawValue.firstIndex(of: name) else { return nil }
        guard index + 1 < rawValue.count else { return nil }
        return rawValue[index + 1]
    }
}

// MARK: - Operation Helpers

extension CommandArguments {
    func extractOperation() throws -> Operation {
        let rawValue = try extractArgument(at: ArgumentIndex.operation)
        return try Operation(rawValue: rawValue)        
    }
}

// MARK: - Switch Dependency Helpers

extension CommandArguments {
    func extractSwtichDependencyMode() throws -> String {
        try extractArgument(at: ArgumentIndex.operation)
    }

    func extractRootPath() -> String? {
        extractArgument(named: Argument.rootPath)
    }

    func resolveRootURL() -> URL {
        let path = extractRootPath() ?? FileManager.default.currentDirectoryPath
        return URL(fileURLWithPath: path)
    }
}

extension CommandLine {
    static var asCommandArguments: CommandArguments {
        CommandArguments(rawValue: arguments)
    }
}
