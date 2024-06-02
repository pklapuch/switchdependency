import Foundation

struct ManifestContent: Equatable {
    let meta: ManifestMeta
    var modified: Bool = false

    var lines: [Line]

    var remoteDependencies: [RemoteDependency] {
        lines.compactMap { $0.dependencyLine?.remoteDependency }
    }

    var localDependencies: [String] {
        lines.compactMap { $0.dependencyLine?.packageName }
    }

    func export() -> String {
        lines.map { $0.export() }.joined(separator: "\n")
    }

    mutating func mark(modified: Bool) {
        self.modified = modified
    }

    mutating func update(dependency: RemoteDependency, to tag: DependencyTag) throws {
        let packageName = dependency.packageName

        guard let index = lines.firstIndex(where: { $0.isDependencyLine(packageName: packageName) }) else {
            throw ExecutionError.make("Dependency \(dependency.packageName) not found!")
        }

        let dependencyLine = lines[index].dependencyLine!
        let updatedDependencyLine = try dependencyLine.updatingTag(tag: tag)
        lines[index] = .dependency(updatedDependencyLine)
    }

    mutating func switchToLocal() throws {
        lines = try lines.map {
            switch $0 {
            case .raw: 
                return $0
            case let .dependency(dependencyLine):
                let dependencyLine = try dependencyLine.switchingToLocal(depth: meta.depth)
                return .dependency(dependencyLine)
            }
        }
    }

    // Switches to latset remote versions
    mutating func switchToRemote(remoteBaseURL: URL, remotePackages: [RemotePackage]) throws {
        lines = try lines.map {
            switch $0 {
            case .raw:
                return $0
            case let .dependency(dependencyLine):
                guard let tag = remotePackages.tag(for: dependencyLine.packageName) else {
                    return $0
                }
                
                let updatedLine = try dependencyLine.switchingToRemote(
                    remoteBaseURL: remoteBaseURL,
                    tag: tag
                )

                return .dependency(updatedLine)
            }
        }
    }
}

private extension [RemotePackage] {
    func tag(for packageName: String) -> DependencyTag? {
        first(where: { $0.packageName == packageName })?.tag
    }
}
