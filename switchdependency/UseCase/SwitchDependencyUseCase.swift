import Foundation

final class SwitchDependencyUseCase {
    private let rootURL: URL
    private let remoteBaseURL: URL
    private let manifestLoader: ManifestLoader
    private let tagLoader: RemoteTagLoader
    
    init(rootURL: URL, remoteBaseURL: URL) {
        self.rootURL = rootURL
        self.remoteBaseURL = remoteBaseURL
        self.manifestLoader = ManifestLoader(rootURL: rootURL, remoteBaseURL: remoteBaseURL)
        self.tagLoader = RemoteTagLoader(rootURL: rootURL)
    }

    func switchToLocal() throws {
        var state = try loadState()
        try state.switchToLocal()
        try state.writeContentsToFile()
    }

    func switchToRemote() throws {
        var state = try loadState()
        try state.switchToRemote()
        try state.writeContentsToFile()
    }

    private func loadState() throws -> State {
        let manifestContents = try manifestLoader.loadContents()
        let remoteNames = try ManifestUtility.filterUniqueRemoteDependencyNames(from: manifestContents)
        let remotePackages = try tagLoader.getRemotePackages(packageNames: remoteNames)
        
        return State(
            rootURL: rootURL,
            remoteBaseURL: remoteBaseURL,
            contents: manifestContents,
            remotePackages: remotePackages
        )
    }
}
