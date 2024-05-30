import Foundation

final class SwitchDependencyUseCase {
    private let rootURL: URL

    init(rootURL: URL) {
        self.rootURL = rootURL
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
}
