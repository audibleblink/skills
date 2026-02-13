---
name: grepai
description: Semantic code search, and call graph analysis with GrepAI. Use when (1) searching code by meaning/intent rather than exact text, (2) finding function callers or callees, or (3) integrating GrepAI with AI agents via JSON/TOON output.
---

# GrepAI

Semantic code search and call graph tracing. Unlike grep/ripgrep (exact text match), GrepAI searches by **meaning** -- "authenticate user" finds login, auth, signin code.

## Setup

```bash
grepai init                # initialize project (interactive: picks provider + backend)
grepai watch --background  # start background daemon to build/maintain index
grepai status              # check index health
```

`init` flags:
- `--provider`: embedding provider (`ollama`, `lmstudio`, `openai`)
- `--backend`: storage backend (`gob`, `postgres`, `qdrant`)
- `--yes`: use defaults without prompting
- `--inherit`: inherit config from main worktree (for git worktrees)

`watch` flags:
- `--background`: run as background daemon
- `--status`: check if background watcher is running
- `--stop`: stop the background watcher
- `--log-dir`: custom log directory

## Semantic Search

```bash
grepai search "your query here"
grepai search "your query" --limit 20
```

### Writing Effective Queries

Describe **intent**, not implementation. Use 3-7 descriptive English words.

| Bad | Good |
|-----|------|
| `getUserById` | `fetch user record from database using ID` |
| `auth` | `user authentication and authorization` |
| `handleError` | `error handling and response to client` |

Natural questions also work: `"how are users authenticated"`, `"where is the database configured"`.

If you know the exact function name, use regular grep instead.

### Iterative Refinement

Start broad, then be specific:

```bash
grepai search "authentication"                # too varied
grepai search "JWT authentication"             # better
grepai search "JWT token validation middleware" # precise
```

### Score Interpretation

| Score | Meaning |
|-------|---------|
| 0.90+ | Excellent match |
| 0.80-0.89 | Good match |
| 0.70-0.79 | Related |
| <0.70 | Weak match |

## Output Formats

```bash
grepai search "query" --json                # JSON
grepai search "query" --json --compact      # abbreviated keys, no content (~80% fewer tokens)
grepai search "query" --toon                # TOON (~50% fewer tokens than JSON)
grepai search "query" --toon --compact      # maximum token efficiency
```

`--json` and `--toon` are mutually exclusive. `--compact` is only available on `search`.

Compact JSON keys: `q` (query), `r` (results), `s` (score), `f` (file), `l` (line range), `t` (total).

| Format | ~Tokens (5 results) |
|--------|---------------------|
| Human-readable | 2,000 |
| JSON compact | 300 |
| TOON compact | 150 |

## Call Tracing

### Callers ("Who calls this?")

```bash
grepai trace callers "Login"
grepai trace callers "Login" --json
grepai trace callers "Login" --toon
```

### Callees ("What does this call?")

```bash
grepai trace callees "ProcessOrder"
grepai trace callees "ProcessOrder" --json
```

### Call Graphs

Build recursive dependency trees:

```bash
grepai trace graph "main"                    # default depth 2
grepai trace graph "main" --depth 3          # deeper
grepai trace graph "main" --depth 3 --json
```

Cycles are detected and marked `[CYCLE]`. Start shallow and increase as needed.

### Extraction Modes

| Mode | Flag | Speed | Accuracy | Dependencies |
|------|------|-------|----------|--------------|
| Fast (default) | `--mode fast` | Fast | Good | None |
| Precise | `--mode precise` | Slower | Excellent | tree-sitter |

### Trace Limitations

- May miss: dynamic/runtime calls, callbacks, closures, interface implementations, reflection
- Use `--mode precise` for better accuracy
- Ensure file types are in `enabled_languages` config

## Configuration

See [references/configuration.md](references/configuration.md) for search boosting and trace configuration options.

## Troubleshooting

| Problem | Solution |
|---------|----------|
| No results | Check index: `grepai status`. Re-index: `rm .grepai/index.gob && grepai watch` |
| Irrelevant results | Be more specific, use different words, try synonyms |
| Function not found (trace) | Check spelling (case-sensitive), verify `enabled_languages` |
| Missing callers/callees | Try `--mode precise`, check ignore patterns |
| Graph too large/timeout | Reduce `--depth`, trace specific function instead of `main` |
