import Foundation

/// Check manifest files declarations in `Manifests.swift`
/// Usage: `./switchdependency local -rootPath {path}`
/// Usage: `./switchdependency remote -rootPath {path}`
/// Usage: `./switchdependency fetchVersions -rootPath {path}`
/// - Parameter operation: local / remote / fetchVersions
/// - Parameter rootPath: optional paramter specifiying root directory of all packages (if not provided, defaults to current working directory)
try start(arguments: CommandLine.asCommandArguments)

// arguments[0] - system arugment
// arguments[1] - operation
// arguments[2+] - operation specific arguments
func start(arguments: CommandArguments) throws {
    let operation = try arguments.extractOperation()
    let rootURL = arguments.resolveRootURL()

    switch operation {
    case .local:
        try SwitchDependencyUseCase(rootURL: rootURL).apply(mode: "local")
    case .remote:
        try SwitchDependencyUseCase(rootURL: rootURL).apply(mode: "remote")
    case .fetchVersions:
        try DependencyVersionsUseCase(rootURL: rootURL).execute()
    }
}
