import Foundation

enum ManifestUtility {
    static func filterUniqueRemoteDependencyNames(from contents: [ManifestContent]) throws -> [String] {
        var dependencies = [String]()

        for content in contents {
            for dependency in content.remoteDependencies {
                guard !dependencies.contains(where: { $0 == dependency.packageName }) else { continue }
                dependencies.append(dependency.packageName)
            }
        }

        for content in contents {
            for dependencyName in content.localDependencies {
                guard !dependencies.contains(where: { $0 == dependencyName }) else { continue }
                dependencies.append(dependencyName)
            }
        }

        return dependencies
    }
}
