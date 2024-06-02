import Foundation

struct State {
    let rootURL: URL
    let remoteBaseURL: URL
    var contents: [ManifestContent]
    let remotePackages: [RemotePackage]

    func checkForLatestVersions() throws {
        for (_, content) in contents.enumerated() {
            for dependency in content.remoteDependencies {
                let remotePackage = remotePackages.first(where: { $0.packageName == dependency.packageName })!

                if !dependency.isLatest(against: remotePackage.tag) {
                    let packageName = content.meta.displayName
                    let dependencyName = dependency.packageName

                    print(
                        """
                        \(packageName) uses outdated dependency: \(dependencyName):\
                        \(dependency.tag) (available version: \(remotePackage.tag))
                        """
                    )
                }
            }
        }
    }

    mutating func updateToLatestVersions() throws {
        for (index, content) in contents.enumerated() {
            for dependency in content.remoteDependencies {
                let remotePackage = remotePackages.first(where: { $0.packageName == dependency.packageName })!

                if !dependency.isLatest(against: remotePackage.tag) {
                    let packageName = content.meta.displayName
                    let dependencyName = dependency.packageName
                    try contents[index].update(dependency: dependency, to: remotePackage.tag)
                    contents[index].mark(modified: true)

                    print(
                        """
                        \(packageName): updated dependency: \(dependencyName) \
                        to latest version: \(remotePackage.tag))
                        """
                    )
                }
            }
        }
    }

    mutating func switchToLocal() throws {
        for (index, content) in contents.enumerated() {
            let packageName = content.meta.displayName
            try contents[index].switchToLocal()
            contents[index].mark(modified: true)

            print(
                """
                switched all dependencies of \(packageName) to local
                """
            )
        }
    }

    mutating func switchToRemote() throws {
        for (index, content) in contents.enumerated() {
            let packageName = content.meta.displayName

            try contents[index].switchToRemote(
                remoteBaseURL: remoteBaseURL,
                remotePackages: remotePackages
            )

            contents[index].mark(modified: true)

            print(
                """
                switched all dependencies of \(packageName) to remote
                """
            )
        }
    }

    mutating func writeContentsToFile() throws {
        for (index, content) in contents.enumerated() where content.modified {
            let url = content.meta.makeURL(rootURL: rootURL)
            let rawContent = content.export()
            try rawContent.write(to: url, atomically: true, encoding: .utf8)
            contents[index].mark(modified: false)
            print("saved chanes in: \(content.meta.displayName)")
        }
    }
}
