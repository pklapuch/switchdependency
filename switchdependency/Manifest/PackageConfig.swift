import Foundation

struct PackageConfig: Codable {
    /// Package name, ex. `ios-sdk-digital-key`
    let name: String

    /// Packages inside this package (normally there's only one package inside a package
    let manifestsMeta: [ManifestMeta]
}
