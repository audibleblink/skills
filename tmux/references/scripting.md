# tmux Scripting Patterns

Advanced bash patterns for tmux automation.

## Table of Contents

1. [Session Lifecycle](#session-lifecycle)
2. [Output Monitoring](#output-monitoring)
3. [Process Coordination](#process-coordination)
4. [Environment Setup](#environment-setup)
5. [Cleanup Patterns](#cleanup-patterns)

---

## Session Lifecycle

### Idempotent Session Creation

```bash
ensure_session() {
  local name=$1
  local dir=${2:-$PWD}
  if ! tmux has-session -t "$name" 2>/dev/null; then
    tmux new-session -d -s "$name" -c "$dir"
  fi
}

# Usage
ensure_session "dev" "/path/to/project"
```

### Session with Multiple Windows

```bash
setup_dev_session() {
  local name=$1
  local dir=$2
  
  tmux new-session -d -s "$name" -c "$dir" -n editor
  tmux new-window -t "$name" -n server -c "$dir"
  tmux new-window -t "$name" -n logs -c "$dir"
  tmux new-window -t "$name" -n shell -c "$dir"
  
  # Return to first window
  tmux select-window -t "$name:0"
}
```

### Cleanup on Exit

```bash
cleanup_session() {
  local name=$1
  if tmux has-session -t "$name" 2>/dev/null; then
    # Send Ctrl+C to all windows
    for win in $(tmux list-windows -t "$name" -F '#I'); do
      tmux send-keys -t "$name:$win" C-c
    done
    sleep 1
    tmux kill-session -t "$name"
  fi
}

# Use with trap for automatic cleanup
trap 'cleanup_session myproject' EXIT
```

---

## Output Monitoring

### Capture and Search

```bash
# Check if pattern appears in output
check_output() {
  local target=$1
  local pattern=$2
  tmux capture-pane -t "$target" -p | grep -q "$pattern"
}

# Get last N lines
get_recent_output() {
  local target=$1
  local lines=${2:-20}
  tmux capture-pane -t "$target" -p | tail -n "$lines"
}

# Get output since marker
get_output_since() {
  local target=$1
  local marker=$2
  tmux capture-pane -t "$target" -p -S -1000 | sed -n "/$marker/,\$p"
}
```

### Wait for Specific Output

```bash
wait_for_pattern() {
  local target=$1
  local pattern=$2
  local timeout=${3:-60}
  local elapsed=0
  
  while ! tmux capture-pane -t "$target" -p | grep -q "$pattern"; do
    sleep 1
    ((elapsed++))
    if ((elapsed >= timeout)); then
      echo "Timeout waiting for: $pattern" >&2
      return 1
    fi
  done
  return 0
}

# Usage: wait for server to be ready
tmux send-keys -t dev:server "npm run dev" Enter
wait_for_pattern "dev:server" "listening on port" 30
```

### Wait for Process Exit

```bash
wait_for_exit() {
  local target=$1
  local timeout=${2:-300}
  local elapsed=0
  
  while true; do
    local cmd=$(tmux list-panes -t "$target" -F '#{pane_current_command}')
    # Check if shell is the current command (process finished)
    if [[ "$cmd" =~ ^(bash|zsh|sh|fish)$ ]]; then
      return 0
    fi
    sleep 1
    ((elapsed++))
    if ((elapsed >= timeout)); then
      return 1
    fi
  done
}
```

### Get Exit Status

```bash
# After process completes, check exit status
get_exit_status() {
  local target=$1
  # Capture and look for exit code in prompt or use $?
  tmux send-keys -t "$target" "echo \$?" Enter
  sleep 0.5
  tmux capture-pane -t "$target" -p | tail -2 | head -1
}
```

---

## Process Coordination

### Sequential Execution

```bash
run_sequential() {
  local target=$1
  shift
  
  for cmd in "$@"; do
    tmux send-keys -t "$target" "$cmd" Enter
    wait_for_exit "$target"
    
    local status=$(get_exit_status "$target")
    if [[ "$status" != "0" ]]; then
      echo "Command failed: $cmd" >&2
      return 1
    fi
  done
}

# Usage
run_sequential "build:main" "npm install" "npm run build" "npm test"
```

### Parallel with Synchronization

```bash
run_parallel_wait() {
  local session=$1
  shift
  local -a windows=("$@")
  
  # Wait for all windows to complete
  for win in "${windows[@]}"; do
    wait_for_exit "$session:$win" || return 1
  done
}

# Usage
tmux send-keys -t build:frontend "npm run build:frontend" Enter
tmux send-keys -t build:backend "npm run build:backend" Enter
run_parallel_wait "build" "frontend" "backend"
```

### Process Pool

```bash
run_with_pool() {
  local session=$1
  local max_parallel=$2
  shift 2
  local -a commands=("$@")
  
  local -a active_panes=()
  local cmd_idx=0
  
  while ((cmd_idx < ${#commands[@]})) || ((${#active_panes[@]} > 0)); do
    # Start new processes if under limit
    while ((${#active_panes[@]} < max_parallel && cmd_idx < ${#commands[@]})); do
      local pane_id=$(tmux split-window -t "$session" -P -F '#{pane_id}' -d)
      tmux send-keys -t "$pane_id" "${commands[$cmd_idx]}" Enter
      active_panes+=("$pane_id")
      ((cmd_idx++))
    done
    
    # Check for completed panes
    local -a still_active=()
    for pane in "${active_panes[@]}"; do
      if tmux list-panes -F '#{pane_id}' | grep -q "$pane"; then
        local cmd=$(tmux display-message -t "$pane" -p '#{pane_current_command}')
        if [[ ! "$cmd" =~ ^(bash|zsh|sh)$ ]]; then
          still_active+=("$pane")
        else
          tmux kill-pane -t "$pane"
        fi
      fi
    done
    active_panes=("${still_active[@]}")
    sleep 0.5
  done
}
```

---

## Environment Setup

### Pass Environment Variables

```bash
# Set env var in pane
tmux send-keys -t dev "export API_KEY='secret'" Enter

# Or use tmux set-environment (session-wide)
tmux set-environment -t dev API_KEY "secret"

# Start process with env vars
tmux send-keys -t dev "API_KEY=secret node server.js" Enter
```

### Working Directory

```bash
# Change directory before command
tmux send-keys -t dev "cd /path/to/dir && npm start" Enter

# Or create window with specific directory
tmux new-window -t dev -n api -c /path/to/api
```

### Source RC Files

```bash
# Ensure shell initialization
tmux send-keys -t dev "source ~/.bashrc && nvm use 18" Enter
```

---

## Cleanup Patterns

### Graceful Shutdown

```bash
graceful_stop() {
  local target=$1
  local timeout=${2:-10}
  
  # Try Ctrl+C first
  tmux send-keys -t "$target" C-c
  sleep 2
  
  # Check if still running
  local cmd=$(tmux list-panes -t "$target" -F '#{pane_current_command}' 2>/dev/null)
  if [[ ! "$cmd" =~ ^(bash|zsh|sh|fish)$ ]] && [[ -n "$cmd" ]]; then
    # Send SIGTERM via Ctrl+C again
    tmux send-keys -t "$target" C-c
    sleep 2
  fi
  
  # Force kill if needed
  cmd=$(tmux list-panes -t "$target" -F '#{pane_current_command}' 2>/dev/null)
  if [[ ! "$cmd" =~ ^(bash|zsh|sh|fish)$ ]] && [[ -n "$cmd" ]]; then
    # Kill the process
    tmux send-keys -t "$target" C-\\  # SIGQUIT
  fi
}
```

### Full Cleanup

```bash
full_cleanup() {
  local session=$1
  
  if ! tmux has-session -t "$session" 2>/dev/null; then
    return 0
  fi
  
  # Capture all output for debugging
  for win in $(tmux list-windows -t "$session" -F '#I:#W'); do
    local idx=${win%%:*}
    local name=${win#*:}
    tmux capture-pane -t "$session:$idx" -p > "/tmp/${session}_${name}.log" 2>/dev/null
  done
  
  # Graceful stop all windows
  for win in $(tmux list-windows -t "$session" -F '#I'); do
    graceful_stop "$session:$win"
  done
  
  # Kill session
  tmux kill-session -t "$session"
}
```

### Cleanup with Error Handling

```bash
safe_cleanup() {
  local session=$1
  
  {
    tmux kill-session -t "$session"
  } 2>/dev/null || true
}

# With trap
main() {
  local session="task-$$"
  trap "safe_cleanup '$session'" EXIT ERR INT TERM
  
  tmux new-session -d -s "$session"
  # ... do work ...
}
```
