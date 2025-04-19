import Foundation
import MCP

public struct JJCommands {
    public static func listChanges() async throws -> [Tool.Content] {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/local/bin/jj")
        process.arguments = ["status"]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        try process.run()
        process.waitUntilExit()

        let data = try pipe.fileHandleForReading.readToEnd() ?? Data()
        let output = String(data: data, encoding: .utf8) ?? ""

        return [.text(output)]
    }

    public static func commit(message: String) async throws -> [Tool.Content] {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/local/bin/jj")
        process.arguments = ["commit", "-m", message]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        try process.run()
        process.waitUntilExit()

        let data = try pipe.fileHandleForReading.readToEnd() ?? Data()
        let output = String(data: data, encoding: .utf8) ?? ""

        return [.text(output)]
    }

    public static func commitEmpty() async throws -> [Tool.Content] {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/local/bin/jj")
        process.arguments = ["commit", "--empty"]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        try process.run()
        process.waitUntilExit()

        let data = try pipe.fileHandleForReading.readToEnd() ?? Data()
        let output = String(data: data, encoding: .utf8) ?? ""

        return [.text(output)]
    }

    public static func edit(commit: String) async throws -> [Tool.Content] {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/local/bin/jj")
        process.arguments = ["edit", commit]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        try process.run()
        process.waitUntilExit()

        let data = try pipe.fileHandleForReading.readToEnd() ?? Data()
        let output = String(data: data, encoding: .utf8) ?? ""

        return [.text(output)]
    }
}