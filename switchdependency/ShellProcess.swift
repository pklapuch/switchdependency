import Foundation

struct ShellProcess {
    private let process = Process()
    private let handler = Pipe()

    init(script: String) {
        process.standardOutput = handler
        process.standardError = handler
        process.arguments = ["-c", script]
        process.launchPath = "/bin/zsh"
        process.standardInput = nil
    }

    func execute() throws -> String {
        process.launch()

        let encodedOutput = handler.fileHandleForReading.readDataToEndOfFile()

        guard let output = String(data: encodedOutput, encoding: .utf8) else {
            throw Self.invalidOutputError
        }

        return output
    }

    private static var invalidOutputError: NSError {
        NSError(
            domain: "SwitchDependencyError",
            code: 1,
            userInfo: ["reason": "Cannot read shell output"])
    }
}
