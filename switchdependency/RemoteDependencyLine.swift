import Foundation

struct RemoteDependencyLine {
    let rawValue: String
    let packageName: String

    static func make(line: String) -> RemoteDependencyLine? {
        guard isLocalDependencySpec(line: line)  else { return nil }

        let ranges = line.ranges(of: "\"")
        guard ranges.count == 2 else { return nil }
        guard let startRange = ranges.first else { return nil }
        guard let endRange = ranges.last else { return nil }

        let remotePath = String(line[startRange.upperBound..<endRange.lowerBound])
        guard let remoteURL = URL(string: remotePath) else { return nil }

        return RemoteDependencyLine(rawValue: line, packageName: remoteURL.lastPathComponent)
    }

    func toLineWithLocalSpec(depth: Int) -> String? {
        let relativePath = (0..<depth).map { _ in "../" }.joined() + packageName
        let innerFunction = "path: \"\(relativePath)\""

        guard let firstBracket = rawValue.firstIndex(of: "(") else { return nil }
        guard let lastBracket = rawValue.lastIndex(of: ")") else { return nil }

        let startIndex = rawValue.index(firstBracket, offsetBy: 1)
        let endIndex = rawValue.index(lastBracket, offsetBy: -1)

        let replacementRange = startIndex...endIndex
        return rawValue.replacingCharacters(in: replacementRange, with: innerFunction)
    }

    static func isLocalDependencySpec(line: String) -> Bool {
        line.contains("git@ssh.dev.azure.com:v3/FMXA/Mobile")
    }

}
