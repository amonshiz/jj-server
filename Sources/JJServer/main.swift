import Foundation
import MCP
import JJServerCore

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

let transport = StdioTransport()

// Register tool handlers
await server.withMethodHandler(ListTools.self) { _ in
    return .init(tools: [
        Tool(
            name: "jj-list-changes",
            description: "Lists all current changes in the working directory",
            inputSchema: .object([
                "type": "object",
                "properties": .object([:])
            ])
        ),
        Tool(
            name: "jj-commit",
            description: "Creates a new commit with the current changes and a message",
            inputSchema: .object([
                "type": "object",
                "properties": .object([
                    "message": .string("The commit message")
                ])
            ])
        ),
        Tool(
            name: "jj-commit-empty",
            description: "Creates a new commit without a message",
            inputSchema: .object([
                "type": "object",
                "properties": .object([:])
            ])
        ),
        Tool(
            name: "jj-edit",
            description: "Switch to (edit) a specific commit",
            inputSchema: .object([
                "type": "object",
                "properties": .object([
                    "commit": .string("The commit ID to edit")
                ])
            ])
        )
    ])
}

await server.withMethodHandler(CallTool.self) { params in
    let result: [Tool.Content]

    switch params.name {
    case "jj-list-changes":
        result = try await JJCommands.listChanges()
    case "jj-commit":
        guard let message = params.arguments?["message"]?.stringValue else {
            throw MCPError.invalidParams("Missing required parameter: message")
        }
        result = try await JJCommands.commit(message: message)
    case "jj-commit-empty":
        result = try await JJCommands.commitEmpty()
    case "jj-edit":
        guard let commit = params.arguments?["commit"]?.stringValue else {
            throw MCPError.invalidParams("Missing required parameter: commit")
        }
        result = try await JJCommands.edit(commit: commit)
    default:
        throw MCPError.methodNotFound("Unknown tool: \(params.name)")
    }

    return .init(content: result)
}

// Start the server
try await server.start(transport: transport)

// Wait for the server to complete
await server.waitUntilCompleted()
