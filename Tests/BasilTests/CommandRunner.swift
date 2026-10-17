import Foundation

struct CommandResult {
    let status: Int32
    let output: String
    let error: String
}

enum CommandRunnerError: Error {
    case executableNotFound
}

private final class TestBundleMarker: NSObject {}

/// Runs the built product without invoking SwiftPM or sharing process-wide output.
func runBasil(_ arguments: [String]) throws -> CommandResult {
    var directory = Bundle(for: TestBundleMarker.self)
        .bundleURL
        .standardizedFileURL
    
    var executable: URL?
    // Handles both SwiftPM test binaries and Xcode's nested test bundles.
    while directory.path != "/" {
        let candidate = directory.appendingPathComponent("Basil")
        if FileManager.default.isExecutableFile(atPath: candidate.path) {
            executable = candidate
            break
        }
        directory.deleteLastPathComponent()
    }
    guard let executable else { throw CommandRunnerError.executableNotFound }

    let temporaryDirectory = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(
        at: temporaryDirectory, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: temporaryDirectory) }

    let outputURL = temporaryDirectory.appendingPathComponent("stdout")
    let errorURL = temporaryDirectory.appendingPathComponent("stderr")
    try Data().write(to: outputURL)
    try Data().write(to: errorURL)
    let outputHandle = try FileHandle(forWritingTo: outputURL)
    defer { try? outputHandle.close() }
    let errorHandle = try FileHandle(forWritingTo: errorURL)
    defer { try? errorHandle.close() }

    let process = Process()
    process.executableURL = executable
    process.arguments = arguments
    process.standardInput = FileHandle.nullDevice
    process.standardOutput = outputHandle
    process.standardError = errorHandle
    try process.run()
    process.waitUntilExit()

    return CommandResult(
        status: process.terminationStatus,
        output: try String(contentsOf: outputURL, encoding: .utf8),
        error: try String(contentsOf: errorURL, encoding: .utf8))
}
