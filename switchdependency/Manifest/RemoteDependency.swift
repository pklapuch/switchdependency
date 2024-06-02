import Foundation

struct RemoteDependency: Equatable, Hashable {
    let packageName: String
    let tag: DependencyTag

    init(packageName: String, tag: DependencyTag) {
        self.packageName = packageName
        self.tag = tag
    }

    func isLatest(against tag: DependencyTag) -> Bool {
        self.tag >= tag
    }
}
