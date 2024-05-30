import Foundation
import RegexBuilder

struct CommonRegex {
    static var version: Regex<Regex<Substring>.RegexOutput> {
        Regex<Regex<Substring>.RegexOutput> {
            OneOrMore(.digit)
            "."
            OneOrMore(.digit)
            "."
            OneOrMore(.digit)
        }
    }
}
