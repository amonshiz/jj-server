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

public struct JJCommands {
    private static let logger = Logger(label: "com.loopwork.iMCP.jjcommands")

    public static func setJJCommandPath(_ path: String) async {
        logger.info("Setting JJ command path", metadata: ["path": .string(path)])
        await JJCommandPathManager.shared.setPath(path)
    }

    private static func getJJCommandPath() async throws -> String {
        try await JJCommandPathManager.shared.getPath()
    }

    public static func listChanges() async throws -> [Tool.Content] {
        logger.info("Executing jj status command")
        let process = Process()
        process.executableURL = URL(fileURLWithPath: try await getJJCommandPath())
        process.arguments = ["status"]

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

    public static func commit(message: String) async throws -> [Tool.Content] {
        logger.info("Executing jj commit command", metadata: ["message": .string(message)])
        let process = Process()
        process.executableURL = URL(fileURLWithPath: try await getJJCommandPath())
        process.arguments = ["commit", "-m", message]

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

    public static func commitEmpty() async throws -> [Tool.Content] {
        logger.info("Executing jj commit --empty command")
        let process = Process()
        process.executableURL = URL(fileURLWithPath: try await getJJCommandPath())
        process.arguments = ["commit", "--empty"]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        try process.run()
        process.waitUntilExit()

        let data = try pipe.fileHandleForReading.readToEnd() ?? Data()
        let output = String(data: data, encoding: .utf8) ?? ""

        logger.debug("jj commit --empty command completed", metadata: ["exitCode": .string("\(process.terminationStatus)")])
        return [.text(output)]
    }

    public static func edit(commit: String) async throws -> [Tool.Content] {
        logger.info("Executing jj edit command", metadata: ["commit": .string(commit)])
        let process = Process()
        process.executableURL = URL(fileURLWithPath: try await getJJCommandPath())
        process.arguments = ["edit", commit]

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