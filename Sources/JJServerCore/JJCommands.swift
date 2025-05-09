import Foundation
import MCP
import Logging

private actor JJCommandPathManager {
    static let shared = JJCommandPathManager()
    private var path: String?

    func setPath(_ path: String) {
        self.path = path
    }

    func getPath() throws -> String {
        guard let path = path else {
            throw MCPError.invalidParams("JJ command path not set")
        }
        return path
    }
}

public enum JJCommands {
    private static let logger = Logger(label: "JJCommands")

    public static func setJJCommandPath(_ path: String) async {
        logger.info("Setting JJ command path", metadata: ["path": .string(path)])
        await JJCommandPathManager.shared.setPath(path)
    }

    private static func getJJCommandPath() async throws -> String {
        try await JJCommandPathManager.shared.getPath()
    }

    public static func listChanges(repoPath: String) async throws -> [Tool.Content] {
        logger.info("Executing jj status command")
        let process = Process()
        process.executableURL = URL(fileURLWithPath: try await getJJCommandPath())
        let args = ["--repository", repoPath, "status"]
        process.arguments = args

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        try process.run()
        process.waitUntilExit()

        let data = try pipe.fileHandleForReading.readToEnd() ?? Data()
        let output = String(data: data, encoding: .utf8) ?? ""

        logger.debug("jj status command completed", metadata: ["exitCode": .string("\(process.terminationStatus)")])
        return [.text(output)]
    }

    public static func commit(message: String, repoPath: String) async throws -> [Tool.Content] {
        logger.info("Executing jj commit command", metadata: ["message": .string(message)])
        let process = Process()
        process.executableURL = URL(fileURLWithPath: try await getJJCommandPath())
        let args = ["--repository", repoPath, "commit", "-m", message]
        process.arguments = args

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        try process.run()
        process.waitUntilExit()

        let data = try pipe.fileHandleForReading.readToEnd() ?? Data()
        let output = String(data: data, encoding: .utf8) ?? ""

        logger.debug("jj commit command completed", metadata: ["exitCode": .string("\(process.terminationStatus)")])
        return [.text(output)]
    }

    public static func newCommit(repoPath: String) async throws -> [Tool.Content] {
        logger.info("Executing jj new command")
        let process = Process()
        process.executableURL = URL(fileURLWithPath: try await getJJCommandPath())
        let args = ["--repository", repoPath, "new"]
        process.arguments = args

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        try process.run()
        process.waitUntilExit()

        let data = try pipe.fileHandleForReading.readToEnd() ?? Data()
        let output = String(data: data, encoding: .utf8) ?? ""

        logger.debug("jj new command completed", metadata: ["exitCode": .string("\(process.terminationStatus)")])
        return [.text(output)]
    }

    public static func edit(commit: String, repoPath: String) async throws -> [Tool.Content] {
        logger.info("Executing jj edit command", metadata: ["commit": .string(commit)])
        let process = Process()
        process.executableURL = URL(fileURLWithPath: try await getJJCommandPath())
        let args = ["--repository", repoPath, "edit", commit]
        process.arguments = args

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        try process.run()
        process.waitUntilExit()

        let data = try pipe.fileHandleForReading.readToEnd() ?? Data()
        let output = String(data: data, encoding: .utf8) ?? ""

        logger.debug("jj edit command completed", metadata: ["exitCode": .string("\(process.terminationStatus)")])
        return [.text(output)]
    }
}