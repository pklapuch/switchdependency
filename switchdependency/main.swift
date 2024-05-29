import Foundation

/// Check manifest files declarations in `Manifests.swift`
/// Usage: `./switchdependency {mode} -rootPath {path}`
/// - Parameter mode: target dependency mode
/// - Parameter rootPath: optional paramter specifiying root directory of all packages (if not provided, defaults to current working directory)
var rootURL: URL!
try start(arguments: CommandLine.arguments)

// arguments[0] - system arugment
// arguments[1] - mode
// argument[2] - rootPath
func start(arguments: [String]) throws {
    rootURL = URL(fileURLWithPath: resolveRootPath(arguments))
    print("Packages Root: \(rootURL!)")

    let mode = try extractMode(arguments)
    try apply(mode: mode)
}

func resolveRootPath(_ arguments: [String]) -> String {
    if let rootPath = extractArgument(named: "rootPath", arguments) {
        return rootPath
    } else {
        return FileManager.default.currentDirectoryPath
    }
}

func extractMode(_ arguments: [String]) throws -> String {
    guard arguments.count >= 2 else {
        throw NSError(domain: "Not enough arguments!", code: 1)
    }

    return arguments[1]
}

func extractArgument(named name: String, _ arguments: [String]) -> String? {
    guard let index = arguments.firstIndex(of: name) else { return nil }
    guard index + 1 < arguments.count else { return nil }
    return arguments[index + 1]
}

func apply(mode: String) throws {
    switch mode.lowercased() {
    case "local":
        print("Convert to local")
        try manifests.forEach { try applyLocalSpec(manifest: $0) }
    case "remote":
        print("Reset")
        try manifests.forEach { try restoreBackup(manifest: $0) }
    default:
        print("Unknown mode!")
        break
    }
}

func restoreBackup(manifest: ManifestFile) throws {
    let url = manifest.manifestFileURL(rootURL)
    let backupURL = url.deletingLastPathComponent().appending(path: "\(manifest.filename).backup")

    let content = try String(contentsOf: backupURL)
    try content.write(to: url, atomically: true, encoding: .utf8)
    try FileManager.default.removeItem(at: backupURL)
}

func applyLocalSpec(manifest: ManifestFile) throws {
    let url = manifest.manifestFileURL(rootURL)
    let content = try String(contentsOf: url)

    let lines = content.components(separatedBy: .newlines)
    var updatedLines = [String]()

    for line in lines {
        guard let remoteDependencyLine = RemoteDependencyLine.make(line: line) else {
            updatedLines.append(line)
            continue
        }

        guard let newLine = remoteDependencyLine.toLineWithLocalSpec(depth: manifest.depth) else {
            updatedLines.append(line)
            continue
        }

        updatedLines.append(newLine)
    }

    let backupURL = url.deletingLastPathComponent().appending(path: "\(manifest.filename).backup")
    try content.write(to: backupURL, atomically: true, encoding: .utf8)

    let newContent = updatedLines.joined(separator: "\n")
    try newContent.write(to: url, atomically: true, encoding: .utf8)
}
