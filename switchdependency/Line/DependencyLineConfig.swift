import Foundation

enum DependencyLineConfig: Equatable {
    case remote(RemoteDependencyLineConfig)
    case local(LocalDependencyLineConfig)
}
