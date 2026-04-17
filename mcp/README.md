# MCP Server Integration (Future)

This directory is reserved for a future MCP (Model Context Protocol) server that will provide dynamic knowledge retrieval from the ai_info repository.

## Planned Features

1. **search-knowledge** — Search across all knowledge files by keyword
2. **get-project-context** — Retrieve context for a specific project
3. **list-conventions** — List all applicable conventions for a given file type
4. **list-skills** — List available skills

## Configuration

When ready, each project will add to its `.mcp.json`:

```json
{
  "mcpServers": {
    "etst-knowledge": {
      "type": "stdio",
      "command": "node",
      "args": ["../ai_info/mcp/server/index.js"]
    }
  }
}
```

## Why MCP?

Currently, knowledge is loaded statically via `@import` directives. An MCP server would enable:
- Dynamic, query-based retrieval (only load what's needed)
- Larger knowledge bases without context window pressure
- Tool-based interaction (Claude can actively search)
- Integration with other AI systems beyond Claude Code
