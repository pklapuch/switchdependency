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
    let remoteBaseURL = URL(string: "git@ssh.dev.azure.com:v3/FMXA/Mobile")!

    let switchDependencyUseCase = SwitchDependencyUseCase(
        rootURL: rootURL,
        remoteBaseURL: remoteBaseURL
    )

    let dependencyVersionUseCase = DependencyVersionsUseCase(
        rootURL: rootURL,
        remoteBaseURL: remoteBaseURL
    )

    switch operation {
    case .local:
        try switchDependencyUseCase.switchToLocal()
    case .remote:
        try switchDependencyUseCase.switchToRemote()
    case .checkVersions:
        try dependencyVersionUseCase.checkForLatestVersions()
    case .updateVersions:
        try dependencyVersionUseCase.updateToLatestVersions()
    }
}
