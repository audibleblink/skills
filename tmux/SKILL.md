---
name: tmux
description: Guide for managing terminal sessions with tmux via bash. Use when running long-lived processes, managing multiple concurrent terminal sessions, monitoring background tasks, or needing persistent shells that survive disconnection. Covers session/window/pane management, sending commands to background processes, and capturing output.
license: Complete terms in LICENSE.txt
---

# tmux Terminal Multiplexer

tmux enables persistent terminal sessions with multiple windows and panes. Essential for:
- Running long-lived processes (servers, builds, watchers)
- Managing multiple concurrent tasks
- Capturing output from background processes
- Sessions that persist across disconnections

## Core Concepts

```
Session → Window(s) → Pane(s)
   │         │          └── Individual terminal
   │         └── Tab within session
   └── Named container (e.g., "dev", "build")
```

## Quick Reference

### Session Management

```bash
# Create detached session
tmux new-session -d -s myproject

# Create with initial directory
tmux new-session -d -s myproject -c /path/to/dir

# List sessions
tmux list-sessions

# Kill session
tmux kill-session -t myproject

# Check if session exists
tmux has-session -t myproject 2>/dev/null && echo "exists"
```

### Window Management

```bash
# Create window in session
tmux new-window -t myproject -n server

# List windows
tmux list-windows -t myproject

# Select window by index or name
tmux select-window -t myproject:0
tmux select-window -t myproject:server

# Kill window
tmux kill-window -t myproject:server
```

### Pane Management

```bash
# Split vertically (side by side)
tmux split-window -h -t myproject

# Split horizontally (stacked)
tmux split-window -v -t myproject

# Split specific window
tmux split-window -h -t myproject:server

# List panes
tmux list-panes -t myproject:0

# Select pane
tmux select-pane -t myproject:0.1

# Kill pane
tmux kill-pane -t myproject:0.1
```

### Sending Commands

```bash
# Send command to session (default window/pane)
tmux send-keys -t myproject "npm run dev" Enter

# Send to specific window
tmux send-keys -t myproject:server "node server.js" Enter

# Send to specific pane
tmux send-keys -t myproject:0.1 "tail -f logs/app.log" Enter

# Send without pressing Enter
tmux send-keys -t myproject "partial command"

# Send special keys
tmux send-keys -t myproject C-c      # Ctrl+C
tmux send-keys -t myproject C-d      # Ctrl+D (EOF)
tmux send-keys -t myproject C-l      # Clear screen
```

### Capturing Output

```bash
# Capture visible pane content
tmux capture-pane -t myproject -p

# Capture with history (last 1000 lines)
tmux capture-pane -t myproject -p -S -1000

# Capture to file
tmux capture-pane -t myproject -p > /tmp/output.txt

# Capture specific pane
tmux capture-pane -t myproject:0.1 -p

# Capture entire scrollback
tmux capture-pane -t myproject -p -S -
```

## Common Workflows

### Running a Development Server

```bash
# Setup
tmux new-session -d -s dev -c /path/to/project
tmux send-keys -t dev "npm run dev" Enter

# Check output
tmux capture-pane -t dev -p | tail -20

# Stop server
tmux send-keys -t dev C-c

# Cleanup
tmux kill-session -t dev
```

### Parallel Task Execution

```bash
# Create session with multiple windows
tmux new-session -d -s build
tmux new-window -t build -n frontend
tmux new-window -t build -n backend
tmux new-window -t build -n tests

# Run parallel tasks
tmux send-keys -t build:frontend "npm run build:frontend" Enter
tmux send-keys -t build:backend "npm run build:backend" Enter
tmux send-keys -t build:tests "npm test" Enter

# Monitor all
for win in frontend backend tests; do
  echo "=== $win ==="
  tmux capture-pane -t "build:$win" -p | tail -5
done
```

### Watching for Completion

```bash
# Wait for process to finish (pane becomes idle)
wait_for_idle() {
  local target=$1
  while tmux list-panes -t "$target" -F '#{pane_current_command}' | grep -qv '^(bash|zsh|sh)$'; do
    sleep 1
  done
}

# Or check for specific output
wait_for_output() {
  local target=$1 pattern=$2
  while ! tmux capture-pane -t "$target" -p | grep -q "$pattern"; do
    sleep 1
  done
}
```

### Split Pane Layout

```bash
# Create 2x2 grid
tmux new-session -d -s grid
tmux split-window -h -t grid        # Left | Right
tmux split-window -v -t grid:0.0    # Split left
tmux split-window -v -t grid:0.2    # Split right

# Send different commands to each pane
tmux send-keys -t grid:0.0 "htop" Enter
tmux send-keys -t grid:0.1 "tail -f /var/log/syslog" Enter
tmux send-keys -t grid:0.2 "watch df -h" Enter
tmux send-keys -t grid:0.3 "tail -f app.log" Enter
```

## Target Syntax

tmux uses a consistent targeting syntax:

| Target | Format | Example |
|--------|--------|---------|
| Session | `session` | `myproject` |
| Window | `session:window` | `myproject:0` or `myproject:server` |
| Pane | `session:window.pane` | `myproject:0.1` |

Windows and panes are 0-indexed by default.

## Best Practices

1. **Always use detached mode** (`-d`) for automation
2. **Name sessions descriptively** for easy identification
3. **Capture output before killing** to preserve results
4. **Use `C-c` to stop processes** before killing panes/sessions
5. **Check session existence** before operations to avoid errors
6. **Use specific targets** (`session:window.pane`) for precision

## Error Handling

```bash
# Safe session creation (idempotent)
tmux has-session -t myproject 2>/dev/null || tmux new-session -d -s myproject

# Safe command execution
if tmux has-session -t myproject 2>/dev/null; then
  tmux send-keys -t myproject "command" Enter
else
  echo "Session does not exist"
fi
```

## Advanced Patterns

For complex automation workflows, see [references/scripting.md](references/scripting.md) for:
- Session lifecycle management (idempotent creation, cleanup)
- Output monitoring and waiting for patterns
- Process coordination (sequential/parallel execution)
- Environment setup and cleanup patterns with traps
