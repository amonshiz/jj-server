import Foundation
import MCP
import JJServerCore
import Logging
import LoggingOSLog

// Get the JJ command path from command-line arguments
guard CommandLine.arguments.count >= 2 else {
    print("Error: JJ command path is required as the first argument")
    exit(1)
}
let jjCommandPath = CommandLine.arguments[1]

// Set the JJ command path in JJCommands
await JJCommands.setJJCommandPath(jjCommandPath)

// Initialize the server with tool capabilities
let server = Server(
    name: "JJServer",
    version: "1.0.0",
    capabilities: .init(
        prompts: .init(),
        resources: .init(),
        tools: .init(listChanged: false)
    )
)

LoggingSystem.bootstrap(LoggingOSLog.init)
let logger = Logger(label: "com.loopwork.iMCP.server")
logger.debug("Starting server")

let transport = StdioTransport(logger: logger)

// Register tool handlers
await server.withMethodHandler(ListTools.self) { _ in
    return .init(tools: [
        Tool(
            name: "jj-list-changes",
            description: "Lists all current changes in the working directory",
            inputSchema: .object([
                "type": "object",
                "properties": .object([
                    "repo-path": .object([
                        "type": .string("string"),
                        "description": .string("Absolute path to the repository on disk")
                    ])
                ]),
                "required": .array([.string("repo-path")])
            ])
        ),
        Tool(
            name: "jj-commit",
            description: "Creates a new commit with the current changes and a message",
            inputSchema: .object([
                "type": .string("object"),
                "properties": .object([
                    "message": .object([
                        "type": .string("string"),
                        "description": .string("The commit message")
                    ]),
                    "repo-path": .object([
                        "type": .string("string"),
                        "description": .string("Absolute path to the repository on disk")
                    ])
                ]),
                "required": .array([.string("message"), .string("repo-path")])
            ])
        ),
        Tool(
            name: "jj-new",
            description: "Create a new, empty change and (by default) edit it in the working copy",
            inputSchema: .object([
                "type": "object",
                "properties": .object([
                    "repo-path": .object([
                        "type": .string("string"),
                        "description": .string("Absolute path to the repository on disk")
                    ])
                ]),
                "required": .array([.string("repo-path")])
            ])
        ),
        Tool(
            name: "jj-edit",
            description: "Switch to (edit) a specific commit",
            inputSchema: .object([
                "type": "object",
                "properties": .object([
                    "commit": .object([
                        "type": .string("string"),
                        "description": .string("The commit ID to edit")
                    ]),
                    "repo-path": .object([
                        "type": .string("string"),
                        "description": .string("Absolute path to the repository on disk")
                    ])
                ]),
                "required": .array([.string("commit"), .string("repo-path")])
            ])
        )
    ])
}

await server.withMethodHandler(CallTool.self) { params in
    guard let repoPath = params.arguments?["repo-path"]?.stringValue, !repoPath.isEmpty else {
        throw MCPError.invalidParams("Missing required parameter: repo-path")
    }
    let result: [Tool.Content]

    switch params.name {
    case "jj-list-changes":
        result = try await JJCommands.listChanges(repoPath: repoPath)
    case "jj-commit":
        guard let message = params.arguments?["message"]?.stringValue else {
            throw MCPError.invalidParams("Missing required parameter: message")
        }
        result = try await JJCommands.commit(message: message, repoPath: repoPath)
    case "jj-new":
        result = try await JJCommands.newCommit(repoPath: repoPath)
    case "jj-edit":
        guard let commit = params.arguments?["commit"]?.stringValue else {
            throw MCPError.invalidParams("Missing required parameter: commit")
        }
        result = try await JJCommands.edit(commit: commit, repoPath: repoPath)
    default:
        throw MCPError.methodNotFound("Unknown tool: \(params.name)")
    }

    return .init(content: result)
}

// Start the server
try await server.start(transport: transport)

// Wait for the server to complete
await server.waitUntilCompleted()
