import Foundation
import RegexBuilder

struct PackageConfig: Codable {
    /// Package name, ex. `ios-sdk-digital-key`
    let name: String

//    /// Manifest file name, ex. `Package.swift` / `Project.swift`
//    let manifestFilename: String
//
//    /// Relative path to manifest file, ex. `ios-sdk-digital-key` (i.e. manifest is located at package root)
//    let manifestFileDirPath: String
}

struct PackageConfigs: Codable {
    let packages: [PackageConfig]
}

final class DependencyVersionsUseCase {
    private let rootURL: URL

    init(rootURL: URL) {
        self.rootURL = rootURL
    }

    var configFileURL: URL {
        rootURL.appending(path: ".dependencyConfig")
    }

    func loadPackageConfigs() throws -> PackageConfigs {
        let encodedConfig = try Data(contentsOf: configFileURL)
        return try JSONDecoder().decode(PackageConfigs.self, from: encodedConfig)
    }

    func execute() throws {
        let packageConfigs = try loadPackageConfigs()

        for packageConfig in packageConfigs.packages {
            let latestTag = try getLatestTag(config: packageConfig)
            print("Latest tag for: \(packageConfig.name) is \(latestTag)")
        }

//        let packageConfig = PackageConfig(name: "ios-sdk-digital-key")
//        let packageConfigs = PackageConfigs(packages: [packageConfig])
//        let encodedNotPretty = try! JSONEncoder().encode(packageConfigs)
//        let jsonObject = try! JSONSerialization.jsonObject(with: encodedNotPretty)
//        let encodedPretty = try! JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)

        //let outputURL =
//        try! encodedPretty.write(to: outputURL)

    }

    private  func getLatestTag(config: PackageConfig) throws -> String {
        let script =
            """
            cd \(rootURL.path())
            cd \(config.name)
            git describe --tags --abbrev=0
        """

        return try ShellProcess(script: script)
            .execute()
            .firstSubstringMatching(regex: CommonRegex.version)
    }
}
