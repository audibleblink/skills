---
name: grepai
description: Semantic code search, and call graph analysis with GrepAI. Use when (1) searching code by meaning/intent rather than exact text, (2) finding function callers or callees, or (3) integrating GrepAI with AI agents via JSON/TOON output.
---

# GrepAI

Semantic code search and call graph tracing. 
Unlike grep/ripgrep (exact text match), GrepAI searches by **meaning** -- "authenticate user" finds login, auth, signin code.

## Setup

```bash
grepai init --provider ollama --backend gob --yes   # initialize project (interactive: picks provider + backend)
grepai watch --background                           # start background daemon to build/maintain index
grepai status                                       # check index health
```

## Usage

Use accompanying MCP server tools, **not** bash. If MCP tools are not
available, tell the user to enable them. If you encounter initialization
errors, you are free to init and start.

### Writing Effective Queries

Describe **intent**, not implementation. Use 3-7 descriptive English words.

| Bad | Good |
|-----|------|
| `getUserById` | `fetch user record from database using ID` |
| `auth` | `user authentication and authorization` |
| `handleError` | `error handling and response to client` |

Natural questions also work: `"how are users authenticated"`, `"where is the database configured"`.

If you know the exact function name, use regular grep instead.

## Configuration

See [references/configuration.md](references/configuration.md) for search boosting and trace configuration options.

## Troubleshooting

| Problem | Solution |
|---------|----------|
| No results | Check index: `grepai status`. Re-index: `rm .grepai/index.gob && grepai watch` |
| Irrelevant results | Be more specific, use different words, try synonyms |
| Function not found (trace) | Check spelling (case-sensitive), verify `enabled_languages` |
| Missing callers/callees | Try precise mode, check ignore patterns |
| Graph too large/timeout | Reduce `--depth`, trace specific function instead of `main` |
