import Foundation

struct DependencyLine: Equatable {
    let packageName: String
    let indentation: Int
    let config: DependencyLineConfig

    static func decode(rawValue: String, remoteBaseURL: URL) throws -> DependencyLine {
        if rawValue.contains("package(url: ") {
            return try decodeRemoteLine(rawValue: rawValue, remoteBaseURL: remoteBaseURL)
        } else {
            return try decodeLocalLine(rawValue: rawValue)
        }
    }

    private static func decodeRemoteLine(
        rawValue: String,
        remoteBaseURL: URL
    ) throws -> DependencyLine {
        let ranges = rawValue.ranges(of: "\"")
        guard ranges.count == 2 else {
            throw ExecutionError.make("corrupted line: \(rawValue)")
        }

        guard let startRange = ranges.first else {
            throw ExecutionError.make("corrupted line: \(rawValue)")
        }

        guard let endRange = ranges.last else {
            throw ExecutionError.make("corrupted line: \(rawValue)")
        }

        let remotePath = String(rawValue[startRange.upperBound..<endRange.lowerBound])
        guard let remoteURL = URL(string: remotePath) else {
            throw ExecutionError.make("corrupted line: \(rawValue)")
        }

        let baseRemoteURL = remoteURL.deletingLastPathComponent()
        let spmTag = try rawValue.firstSubstringMatching(regex: CommonRegex.spmTag)

        let packageName = remoteURL.lastPathComponent
        let tag = try DependencyTag(spmTag: spmTag)
        let indentation = rawValue.prefix(while: { $0 == " " }).count

        let remoteConfig = RemoteDependencyLineConfig(baseURL: baseRemoteURL, tag: tag)
        let config = DependencyLineConfig.remote(remoteConfig)
        return DependencyLine(packageName: packageName, indentation: indentation, config: config)
    }

    private static func decodeLocalLine(rawValue: String) throws -> DependencyLine {
        let ranges = rawValue.ranges(of: "\"")
        guard ranges.count == 2 else {
            throw ExecutionError.make("corrupted line: \(rawValue)")
        }

        guard let startRange = ranges.first else {
            throw ExecutionError.make("corrupted line: \(rawValue)")
        }

        guard let endRange = ranges.last else {
            throw ExecutionError.make("corrupted line: \(rawValue)")
        }

        let localPath = String(rawValue[startRange.upperBound..<endRange.lowerBound])
        guard let localURL = URL(string: localPath) else {
            throw ExecutionError.make("corrupted line: \(rawValue)")
        }

        let packageName = localURL.lastPathComponent
        let indentation = rawValue.prefix(while: { $0 == " " }).count
        let depth = localPath.components(separatedBy: "/").count - 1
        let localConfig = LocalDependencyLineConfig(depth: depth)
        let config = DependencyLineConfig.local(localConfig)
        return DependencyLine(packageName: packageName, indentation: indentation, config: config)
    }

    static func representsLine(rawValue: String, supportedPackageNames: [String]) -> Bool {
        guard rawValue.contains("package(path: ") || rawValue.contains("package(url: ") else {
            return false
        }

        for supportedPackageName in supportedPackageNames {
            if rawValue.contains(supportedPackageName) {
                return true
            }
        }

        return false
    }

    var remoteTag: DependencyTag? {
        guard case let .remote(remoteConfig) = config else { return nil }
        return remoteConfig.tag
    }

    var remoteDependency: RemoteDependency? {
        guard let tag = remoteTag else { return nil }
        return RemoteDependency(packageName: packageName, tag: tag)
    }

    func updatingTag(tag: DependencyTag) throws -> DependencyLine {
        guard case let .remote(remoteConfig) = config else {
            throw ExecutionError.make("Invalid Command")
        }

        let newConfig = RemoteDependencyLineConfig(
            baseURL: remoteConfig.baseURL,
            tag: tag
        )

        return DependencyLine(
            packageName: packageName,
            indentation: indentation,
            config: .remote(newConfig)
        )
    }

    func switchingToLocal(depth: Int) throws -> DependencyLine {
        guard case .remote = config else {
            return self
        }

        return DependencyLine(
            packageName: packageName,
            indentation: indentation,
            config: .local(.init(depth: depth))
        )
    }

    func switchingToRemote(remoteBaseURL: URL, tag: DependencyTag) throws -> DependencyLine {
        switch config {
        case .local:
            let newConfig = RemoteDependencyLineConfig(
                baseURL: remoteBaseURL,
                tag: tag
            )

            let config = DependencyLineConfig.remote(newConfig)
            return DependencyLine(packageName: packageName, indentation: indentation, config: config)

        case .remote:
            return try updatingTag(tag: tag)
        }
    }

    func export() -> String {
        switch config {
        case let .remote(remoteConfig):
            return exportRemoteLine(config: remoteConfig)
        case let .local(localConfig):
            return exportLocalLine(config: localConfig)
        }
    }

    private func exportRemoteLine(config: RemoteDependencyLineConfig) -> String {
        let indentationString = (0..<indentation).map { _ in " " }.joined()
        let url = config.baseURL.appending(path: packageName)
        let spmTag = config.tag.exportSpmTag()
        return "\(indentationString).package(url: \"\(url)\", from: .init(\(spmTag))),"
    }

    private func exportLocalLine(config: LocalDependencyLineConfig) -> String {
        let indentationString = (0..<indentation).map { _ in " " }.joined()
        let depthPath = (0..<config.depth).map { _ in "../" }.joined()
        let url = URL(string: depthPath)!.appending(path: packageName)
        return "\(indentationString).package(path: \"\(url)\"),"
    }
}

