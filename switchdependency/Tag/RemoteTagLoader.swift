import Foundation

final class RemoteTagLoader {
    private let rootURL: URL

    init(rootURL: URL) {
        self.rootURL = rootURL
    }

    func getRemotePackages(packageNames: [String]) throws -> [RemotePackage] {
        var tagPerPackageName = [String: DependencyTag]()

        for packageName in packageNames {
            let remoteTag = try getLatestRemoteTag(packageName: packageName)
            tagPerPackageName[packageName] = remoteTag
        }

        return tagPerPackageName.map { RemotePackage(packageName: $0.key, tag: $0.value) }
    }

    private func getLatestRemoteTag(packageName: String) throws -> DependencyTag? {
        let path = rootURL.appending(path: packageName).path()

        let script =
            """
            cd \(path)
            git describe --tags --abbrev=0
        """

        let shellOutput = try ShellProcess(script: script).execute()
        guard let gitTag = try RawTag(rawValue: shellOutput).getVersion() else {
            return nil
        }

        return try DependencyTag(gitTag: gitTag)
    }
}
