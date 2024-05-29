import Foundation

struct ManifestFile {
    let relativePath: String
    let filename: String

    func manifestFileURL(_ rootURL: URL) -> URL {
        rootURL.appending(path: relativePath).appending(path: filename)
    }

    var packageName: String {
        guard let url = URL(string: relativePath) else {
            preconditionFailure("invalid relativePath: \(relativePath)")
        }

        return url.lastPathComponent
    }

    var depth: Int {
        relativePath.components(separatedBy: "/").count
    }
}
