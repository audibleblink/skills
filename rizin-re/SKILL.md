---
name: rizin-re
description: Interactive binary reverse engineering with rizin via a persistent tmux session. Use when the user wants to open a binary and explore it — disassemble functions, find strings, inspect imports/exports, trace control flow, analyze malware, work CTF challenges, or do vulnerability research. Trigger on phrases like "open this binary", "reverse engineer", "disassemble", "analyze with rizin", "what does this function do", "find the flag", or any RE task involving an executable or library file.
---

# Rizin Reverse Engineering Skill

You are an expert reverse engineer using **rizin** (`rz`) in a persistent tmux session. You open binaries, run analysis, and iteratively explore them — disassembling, annotating, and reasoning about code.

## Session Management

### Check for existing session
```bash
tmux has-session -t rizin 2>/dev/null && echo "exists" || echo "missing"
```

### Open a binary (create session if needed)
```bash
# Create a new detached tmux session running rizin with the binary
tmux new-session -d -s rizin -x 220 -y 50 "rizin -A /path/to/binary"
# Wait for analysis to complete (aA can take a few seconds)
sleep 3
```

If a session already exists with a different binary, kill it first:
```bash
tmux kill-session -t rizin 2>/dev/null; sleep 0.5
tmux new-session -d -s rizin -x 220 -y 50 "rizin -A /path/to/binary"
sleep 3
```

### Send a command and capture output
```bash
# Clear the pane buffer, send command, wait, capture
tmux send-keys -t rizin "cmd_here~" Enter
sleep 1
tmux capture-pane -t rizin -p -S -100
```

Use `~` suffix for JSON output where available (rizin's JSON flag). For commands that don't support `~`, omit it.

**Pattern for structured output:**
```bash
tmux send-keys -t rizin "afl~" Enter; sleep 1; tmux capture-pane -t rizin -p -S -200
```

**For longer-running commands** (large binaries, deep analysis), increase sleep to 3-5s.

### Close the session
```bash
tmux kill-session -t rizin
```

## Core Rizin Commands

### Analysis
| Command | Description |
|---------|-------------|
| `afl` | List all functions |
| `afl~` | Function list as JSON |
| `afn name @ addr` | Rename a function |
| `axl` | List cross-references |
| `axt @ addr` | Find xrefs TO address |
| `axf @ addr` | Find xrefs FROM address |
| `aa` | Basic analysis |
| `aaa` | Full analysis (done at open via `-A`) |

### Disassembly
| Command | Description |
|---------|-------------|
| `pdf @ sym.main` | Disassemble function at symbol |
| `pdf @ 0xdeadbeef` | Disassemble function at address |
| `pd 20 @ addr` | Disassemble 20 instructions at addr |
| `pdc @ sym.main` | Pseudo-C decompilation (if available) |
| `pdg @ sym.main` | Graph-mode disassembly |

### Strings & Data
| Command | Description |
|---------|-------------|
| `iz` | Strings in data section |
| `izz` | All strings in binary |
| `iz~keyword` | Search strings for keyword |
| `px 64 @ addr` | Hex dump 64 bytes at addr |
| `pf` | Print formatted data |

### Imports / Exports / Symbols
| Command | Description |
|---------|-------------|
| `ii` | Imports |
| `ii~` | Imports as JSON |
| `iE` | Exports |
| `is` | Symbols |
| `il` | Libraries linked |
| `iI` | Binary info (arch, bits, OS, etc.) |

### Seeking & Navigation
| Command | Description |
|---------|-------------|
| `s sym.main` | Seek to main |
| `s 0xdeadbeef` | Seek to address |
| `s-` | Undo seek |

### Flags & Comments
| Command | Description |
|---------|-------------|
| `fl` | List all flags |
| `f name @ addr` | Set a flag (label) |
| `CCa @ addr comment` | Add comment at address |

### Search
| Command | Description |
|---------|-------------|
| `/ string` | Search for string in memory |
| `/x deadbeef` | Search for hex pattern |
| `/R pop rdi` | Search for ROP gadgets matching pattern |
| `e search.in=dbg.maps` | Search in all memory maps |

### Scripting & Output
| Command | Description |
|---------|-------------|
| `~` | JSON output suffix (e.g. `afl~`) |
| `~keyword` | grep-style filter (e.g. `afl~main`) |
| `@@` | Iterator (e.g. `pdf @@ fcn.*` — disassemble all functions) |

## Workflow

### 1. Open the binary
- Confirm the file path with the user if ambiguous
- Check for an existing tmux session; reuse or create as needed
- Use `-A` flag so full analysis runs at startup (equivalent to `aaa`)
- Tell the user analysis is running and wait appropriately

### 2. Orient yourself
Always start with:
```
iI   → arch, bits, OS, compiler, stripped?
ii   → imports (what libraries/syscalls does it use?)
afl  → how many functions? any obvious names?
iz   → interesting strings?
```
Summarize findings in plain English before diving deeper.

### 3. Explore iteratively
- Use JSON output (`~`) when you need to parse/process results programmatically
- Use raw text when showing output directly to the user
- Navigate to interesting functions with `s` then `pdf`
- Use `pdc` for pseudo-C when available — much easier to reason about
- Cross-reference suspicious functions with `axt`

### 4. Reason and explain
- Don't just dump disassembly — explain what the code does
- Identify calling conventions, argument passing, return values
- Note anti-analysis tricks (obfuscation, packing, anti-debug)
- For CTF: look for comparison operations, crypto constants, flag formats

### 5. Annotate as you go
Use `afn` to rename functions and `CCa` to add comments so the session stays useful as analysis deepens.

## Output Format

- **Summary first**: plain English overview of what you found
- **Raw disassembly / text**: in fenced code blocks, labeled with address/function
- **JSON data**: parsed and presented as readable tables or bullet points — don't dump raw JSON at the user
- **Hypotheses**: clearly labeled ("This looks like a decryption routine because...")

## Common Scenarios

### CTF binary
1. `iI` — check protections (PIE, NX, canary)
2. `iz~flag` — search for flag format strings  
3. `afl~main` → `pdf @ sym.main` — find the logic
4. `pdc` for pseudo-C if available
5. Look for `strcmp`, `memcmp`, crypto functions in imports

### Malware sample
1. `ii` — suspicious imports (CreateRemoteThread, VirtualAlloc, WSAStartup, etc.)
2. `iz` — C2 URLs, registry keys, mutex names
3. `afl` — look for network, persistence, injection functions
4. Rename and annotate as you identify each function's role

### Vulnerability research
1. `ii~(gets\|strcpy\|sprintf\|recv)` — dangerous imports
2. Find callers with `axt @ sym.imp.gets`
3. Disassemble callers, check for bounds checking
4. Look at stack frame sizes (`pdf` shows local variable offsets)

## When NOT to use this skill (or: prefer one-shot over tmux)

**Before opening a tmux session, ask: do I actually need an interactive REPL?** For many tasks, a one-shot invocation is faster, more reliable, and doesn't accumulate readline cruft:

```bash
rizin -A -q -c 'iI; ii; izz~keyword; afl~main' /path/to/binary
```

Use `-q` (quiet, exit after commands) with `-c 'cmd1; cmd2; ...'` to get clean stdout with no race conditions. Chain as many commands as you want with `;`. This is the right default for:
- Triage / orientation (`iI`, `ii`, `iz`, `afl`)
- Extracting specific data to grep over
- Anything scriptable

Reserve the tmux session for genuinely iterative work where each command depends on reading the previous output (e.g. following xrefs, renaming as you go).

**For large Go/Rust binaries (20MB+), prefer `strings` + `--help` + `rz-bin` over disassembly.** A 35MB Go binary has tens of thousands of `sym.func.<addr>` entries with package paths not attached to names — `afl~packagename` will match nothing even when the code is there. The skill's CTF-sized workflow (`pdf @ sym.main`, `pdc`) doesn't scale. Go binaries in particular: `strings BIN | grep -E '/api/|ENV_VAR'` and running `BIN --help` will outperform rizin for attack-surface / config questions.

## tmux pitfalls (if you do use the session)

- **`send-keys` is async.** `sleep N` is a guess, not a guarantee. Increase sleep for heavy commands (`aaa`, large `afl`, `izz` on big binaries — 5–30s).
- **Rizin is not a shell.** Don't type `afl | grep foo` or `afl > file.txt` expecting shell semantics. Use rizin's own operators:
  - `~foo` — grep-style filter (e.g. `afl~main`)
  - `~{}` — JSON pretty-print
  - `> file` — redirect (this *does* work inside rizin)
  - `| shellcmd` — pipes to shell, but quoting is fragile over tmux
- **Botched commands leave readline cruft.** If you see your own keystrokes echoed in `capture-pane` output (e.g. `fl~foo`, `f | grep`), the pane is in a confused state. Send `Ctrl-C` (`tmux send-keys -t rizin C-c`) to clear the input buffer before retrying.
- **Don't mix input echo with output parsing.** `capture-pane -S -200` grabs both your typed commands and their output. If you need clean output, either use one-shot `-q -c` mode, or redirect inside rizin with `cmd > /tmp/out.txt` and read the file from the shell.
- **Prefer scripted transports for anything complex.** `r2pipe`/`rzpipe` (Python/Node bindings) give you structured request/response and skip the tmux layer entirely.

## Notes
- rizin session name is always `rizin` for consistency
- If the binary is packed/obfuscated, note it and suggest unpacking before analysis
- `pdc` requires the rzghidra or rz-ghidra plugin — if unavailable, fall back to `pdf`
- For 32-bit x86, arguments are on the stack; for x86-64, use RDI/RSI/RDX/RCX/R8/R9
- ARM: R0-R3 for args; AArch64: X0-X7
