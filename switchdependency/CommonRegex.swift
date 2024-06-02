import Foundation
import RegexBuilder

struct CommonRegex {
    static var gitTag: Regex<Regex<Substring>.RegexOutput> {
        Regex<Regex<Substring>.RegexOutput> {
            OneOrMore(.digit)
            "."
            OneOrMore(.digit)
            "."
            OneOrMore(.digit)
        }
    }

    static var spmTag: Regex<Regex<Substring>.RegexOutput> {
        Regex<Regex<Substring>.RegexOutput> {
            OneOrMore(.digit)
            ", "
            OneOrMore(.digit)
            ", "
            OneOrMore(.digit)
        }
    }
}
