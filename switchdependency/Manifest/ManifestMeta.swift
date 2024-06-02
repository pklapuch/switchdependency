import Foundation

struct ManifestMeta: Codable, Equatable, CustomStringConvertible {
    /// Human readable name for log output only
    /// ex. `ios-app-show-case (IntenralPackageA)`
    let displayName: String

    /// Root package name (i.e. `ios-app-show-case`)
    let rootName: String

    /// Relative path to manifest file
    /// i.e.: `Package.swift`, `InternalPackages/TestPackage/Package.swift`, etc
    let manifestURL: URL

    var depth: Int {
        manifestURL.path().components(separatedBy: "/").count
    }

    var description: String {
        "\(displayName): \(manifestURL.path()) (depth: \(depth))"
    }

    func makeURL(rootURL: URL) -> URL {
        rootURL.appending(path: rootName).appending(path: manifestURL.path())
    }
}
