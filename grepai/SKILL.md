---
name: grepai
description: Semantic code search, and call graph analysis with GrepAI. Use when (1) searching code by meaning/intent rather than exact text, (2) finding function callers or callees, or (3) integrating GrepAI with AI agents via JSON/TOON output.
---

# GrepAI

GrepAI provides semantic code search and call graph tracing. Unlike grep/ripgrep (exact text match), GrepAI searches by **meaning** -- "authenticate user" finds login, auth, signin code.

## Prerequisites

1. `grepai init` -- initialize project
2. `grepai watch` -- build/update index
3. Embedding provider running (Ollama, etc.)
4. Check status: `grepai status`

## Semantic Search

### Basic Search

```bash
grepai search "your query here"
```

Default: 10 results. Adjust with `--limit N`.

### Result Format

```
Score: 0.89 | src/auth/middleware.go:15-45
──────────────────────────────────────────
[code content]
```

| Score | Meaning |
|-------|---------|
| 0.90+ | Excellent match |
| 0.80-0.89 | Good match |
| 0.70-0.79 | Related |
| 0.60-0.69 | Loosely related |
| <0.60 | Weak match |

### Writing Effective Queries

Describe **intent**, not implementation. Use 3-7 descriptive English words.

| Bad | Good |
|-----|------|
| `getUserById` | `fetch user record from database using ID` |
| `auth` | `user authentication and authorization` |
| `handleError` | `error handling and response to client` |
| `config` | `application configuration loading` |

Natural questions also work: `"how are users authenticated"`, `"where is the database configured"`.

If you know the exact function name, use regular grep instead.

### Query Patterns

```bash
# By behavior
grepai search "validate user credentials before login"
grepai search "retry failed HTTP requests"

# By purpose
grepai search "middleware that checks authentication"
grepai search "handler for payment processing"

# By domain
grepai search "shopping cart checkout process"
grepai search "patient record retrieval"
```

### Iterative Refinement

Start broad, add context, then be specific:

```bash
grepai search "authentication"              # too varied
grepai search "JWT authentication"           # better
grepai search "JWT token validation middleware"  # precise
```

Semantic search understands synonyms -- try different phrasings if results aren't good.

## Output Formats

### JSON

```bash
grepai search "authentication" --json
grepai search "authentication" --json --compact   # abbreviated keys, no content (~80% fewer tokens)
```

Compact JSON uses shortened keys: `q` (query), `r` (results), `s` (score), `f` (file), `l` (line range), `t` (total).

### TOON (v0.26.0+)

Token-Oriented Object Notation -- ~50% fewer tokens than JSON. Best for AI agents.

```bash
grepai search "authentication" --toon
grepai search "authentication" --toon --compact   # maximum token efficiency
```

`--json` and `--toon` are mutually exclusive.

### Token Comparison (5 results)

| Format | Tokens |
|--------|--------|
| Human-readable | ~2,000 |
| JSON full | ~1,500 |
| JSON compact | ~300 |
| TOON | ~250 |
| **TOON compact** | **~150** |

### Scripting with JSON

```bash
grepai search "config" --json | jq -r '.results[].file'           # file paths
grepai search "config" --json | jq '.results[] | select(.score > 0.8)'  # filter by score
```

## Search Boosting

Configure in `.grepai/config.yaml` to prioritize source code over tests/vendor:

```yaml
search:
  boost:
    enabled: true
    penalties:
      - pattern: /tests/
        factor: 0.5        # 50% reduction
      - pattern: _test.
        factor: 0.5
      - pattern: /vendor/
        factor: 0.3        # 70% reduction
      - pattern: /docs/
        factor: 0.6
    bonuses:
      - pattern: /src/
        factor: 1.1        # 10% increase
      - pattern: /internal/
        factor: 1.1
      - pattern: /core/
        factor: 1.2
```

Factors: `< 1.0` = penalty, `1.0` = neutral, `> 1.0` = bonus. Patterns match against full file path. Boosting re-ranks results; use ignore patterns to completely exclude files.

## Call Tracing

### Trace Callers

Find all code that calls a specific function ("Who calls this?"):

```bash
grepai trace callers "Login"
grepai trace callers "Login" --json
grepai trace callers "Login" --json --compact
grepai trace callers "Login" --toon
```

Use cases: impact analysis before refactoring, finding all usages, debugging call chains.

### Trace Callees

Find all functions called by a specific function ("What does this call?"):

```bash
grepai trace callees "ProcessOrder"
grepai trace callees "ProcessOrder" --json --compact
```

Use cases: understanding function behavior, mapping dependencies, detecting functions doing too much.

### Combined Analysis

```bash
grepai trace callers "processOrder"   # Who uses this?
grepai trace callees "processOrder"   # What does it do?
```

### Extraction Modes

| Mode | Flag | Speed | Accuracy | Dependencies |
|------|------|-------|----------|--------------|
| Fast (default) | `--mode fast` | Fast | Good | None |
| Precise | `--mode precise` | Slower | Excellent | tree-sitter |

### Trace Limitations

- May miss: dynamic/runtime calls, callbacks, closures, interface implementations, reflection
- Use `--mode precise` for better accuracy
- Ensure file types are in `enabled_languages` config

## Call Graphs

Build recursive dependency trees with `trace graph`:

```bash
grepai trace graph "main"                    # default depth 2
grepai trace graph "main" --depth 3          # deeper
grepai trace graph "main" --depth 1          # shallow (same as callees)
grepai trace graph "main" --depth 3 --json
grepai trace graph "main" --toon --compact
```

Output:
```
main
├── initialize
│   ├── loadConfig
│   │   └── parseYAML
│   └── connectDB
│       ├── createPool
│       └── ping
├── startServer
│   ├── registerRoutes
│   └── listen
└── gracefulShutdown
    └── closeDB
```

Cycles are detected and marked `[CYCLE]`. Start shallow (`--depth 2`) and increase as needed. For large codebases, trace specific subsystems rather than `main`.

## Trace Configuration

```yaml
# .grepai/config.yaml
trace:
  mode: fast  # fast or precise
  enabled_languages:
    - .go
    - .js
    - .ts
    - .py
    - .rs
    - .java
    - .php
    - .c
    - .cpp
    - .cs
    - .zig
  exclude_patterns:
    - "*_test.go"
    - "*.spec.ts"
```

## Troubleshooting

| Problem | Solution |
|---------|----------|
| No results | Check index: `grepai status`. Re-index: `rm .grepai/index.gob && grepai watch` |
| Irrelevant results | Be more specific, use different words, try synonyms |
| Function not found (trace) | Check spelling (case-sensitive), verify `enabled_languages` |
| Missing callers/callees | Try `--mode precise`, check ignore patterns |
| Graph too large/timeout | Reduce `--depth`, trace specific function instead of `main` |
| Many cycles detected | Indicates circular dependencies in code -- consider refactoring |
