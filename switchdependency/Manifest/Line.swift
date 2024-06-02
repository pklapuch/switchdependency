import Foundation

enum Line: Equatable {
    case raw(String)
    case dependency(DependencyLine)

    var dependencyLine: DependencyLine? {
        guard case let .dependency(line) = self else { return nil }
        return line
    }

    static func decodeLines(
        rawContent: String,
        supportedPackageNames: [String],
        remoteBaseURL: URL
    ) throws -> [Line] {
        let rawLines = rawContent.components(separatedBy: .newlines)
        var lines = [Line]()

        for rawLine in rawLines {
            guard DependencyLine.representsLine(
                rawValue: rawLine,
                supportedPackageNames: supportedPackageNames
            ) else {
                lines.append(.raw(rawLine))
                continue
            }

            let dependencyLine = try DependencyLine.decode(
                rawValue: rawLine,
                remoteBaseURL: remoteBaseURL
            )

            lines.append(.dependency(dependencyLine))
        }

        return lines
    }

    func isDependencyLine(packageName: String) -> Bool {
        guard let dependencyLine else { return false }

        return dependencyLine.packageName == packageName
    }

    func export() -> String {
        switch self {
        case let .raw(rawValue): return rawValue
        case let .dependency(line): return line.export()
        }
    }
}
