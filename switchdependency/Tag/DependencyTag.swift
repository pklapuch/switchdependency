import Foundation

struct DependencyTag: CustomStringConvertible, Equatable, Hashable {
    let components: [Int]

    init(gitTag: String) throws {
        let rawComponents = gitTag.components(separatedBy: ".")
        let intComponents = rawComponents.map(Int.init).compactMap { $0 }

        guard intComponents.count == 3 else {
            throw ExecutionError.make("Invalid gitTag: \(gitTag)")
        }

        components = intComponents
    }

    init(spmTag: String) throws {
        let rawComponents = spmTag.components(separatedBy: ", ")
        let intComponents = rawComponents.map(Int.init).compactMap { $0 }

        guard intComponents.count == 3 else {
            throw ExecutionError.make("Invalid spmTag: \(spmTag)")
        }

        components = intComponents
    }

    func exportSpmTag() -> String {
        components.map { "\($0)" }.joined(separator: ", ")
    }

    func exportGitTag() -> String {
        components.map { "\($0)" }.joined(separator: ".")
    }

    var description: String {
        exportGitTag()
    }

    static func >=(lhs: DependencyTag, rhs: DependencyTag) -> Bool {
        let lComponents = lhs.components
        let rComponents = rhs.components

        if lComponents[0] < rComponents[0] { return false }
        if lComponents[1] < rComponents[1] { return false }
        if lComponents[2] < rComponents[2] { return false }
        return true
    }
}
