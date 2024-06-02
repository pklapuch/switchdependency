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

    func replacingFirstMatchingRegexWithSubstring(
        regex: Regex<Regex<Substring>.RegexOutput>,
        with substring: String
    ) throws -> String {
        if let match = firstMatch(of: regex) {
            let range = match.range.lowerBound..<match.range.upperBound
            return replacingCharacters(in: range, with: substring)
        } else {
            throw NSError(domain: "", code: 1)
        }
    }
}
