import Foundation

final class ManifestLoader {
    private let rootURL: URL
    private let remoteBaseURL: URL

    init(rootURL: URL, remoteBaseURL: URL) {
        self.rootURL = rootURL
        self.remoteBaseURL = remoteBaseURL
    }

    var configFileURL: URL {
        rootURL.appending(path: ".dependencyConfig")
    }

    func loadContents() throws -> [ManifestContent] {
        let manifestMetas = try loadManifestsMeta()
        let supportedPackageNames = manifestMetas.map(\.rootName)

        return try manifestMetas.map {
            try loadManifestContent($0, supportedPackageNames)
        }
    }

    private func loadManifestsMeta() throws -> [ManifestMeta] {
        let encodedConfig = try Data(contentsOf: configFileURL)
        let configs = try JSONDecoder().decode(PackageConfigs.self, from: encodedConfig)
        return configs.manifestsMeta
    }

    private func loadManifestContent(
        _ meta: ManifestMeta,
        _ supportedPackageNames: [String]
    ) throws -> ManifestContent {
        let url = meta.makeURL(rootURL: rootURL)
        let rawContent = try String(contentsOf: url)
        
        let lines = try Line.decodeLines(
            rawContent: rawContent,
            supportedPackageNames: supportedPackageNames,
            remoteBaseURL: remoteBaseURL
        )
        return ManifestContent(meta: meta, lines: lines)
    }
}
