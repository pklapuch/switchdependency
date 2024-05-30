import Foundation

extension String {
    func firstSubstringMatching(regex: Regex<Regex<Substring>.RegexOutput>) throws -> String {
        guard firstMatch(of: regex) != nil else {
            throw NSError(domain: "", code: 1)
        }

        if let match = firstMatch(of: regex) {
            return String(self[match.range.lowerBound..<match.range.upperBound])
        } else {
            throw NSError(domain: "", code: 1)
        }
    }
}
