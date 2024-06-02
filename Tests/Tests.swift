import XCTest
@testable import switchdependency

final class Tests: XCTestCase {
    func test_init_withRemoteLine() throws {
        let dependencyTag = try DependencyTag(gitTag: "1.2.3")
        let baseURL = URL(string: "git@ssh.dev.azure.com:v3/FMXA/Mobile/")!

        let sut = DependencyLine(
            packageName: "test-package",
            indentation: 5,
            config: .remote(.init(baseURL: baseURL, tag: dependencyTag))
        )

        let rawRemoteLine = sut.export()
        print(rawRemoteLine)

        let decodedLine = try DependencyLine.decode(rawValue: rawRemoteLine)
        XCTAssertEqual(decodedLine, sut)
    }

    func test_init_withLocalLine() throws {
        let depth = 2

        let sut = DependencyLine(
            packageName: "test-package",
            indentation: 5,
            config: .local(.init(depth: depth))
        )

        let rawLocalLine = sut.export()
        print(rawLocalLine)

        let decodedLine = try DependencyLine.decode(rawValue: rawLocalLine)
        XCTAssertEqual(decodedLine, sut)
    }
}
