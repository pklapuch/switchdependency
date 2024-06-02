import Foundation

struct ManifestsMeta: CustomStringConvertible {
    let manifets: [ManifestMeta]

    var description: String {
        manifets.map { "\($0)" }.joined(separator: "\n")
    }
}
