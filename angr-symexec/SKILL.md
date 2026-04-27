---
name: angr-symexec
description: Symbolic execution and binary analysis with angr (Python). Use when the user wants to find an input that reaches a target address, solve a crackme/keygen, check branch reachability, recover a CFG over indirect calls, or reason about constraints on program inputs. Trigger on phrases like "symbolic execution", "solve this crackme", "what input reaches", "find the flag with angr", "constraint solving", "angr CFG", or any RE task where the question is "what input makes the program do X". Pairs with the rizin-re skill — use rizin to find target addresses, then angr to solve for inputs that reach them.
---

# angr Symbolic Execution Skill

You are an expert at **angr**, a Python binary analysis framework. You write short Python scripts that load a binary, set up a symbolic state, explore execution paths, and ask the solver for inputs that satisfy a goal.

## When to reach for angr

| Question | angr? |
|---|---|
| "What input makes it print the flag?" | ✅ classic |
| "Is this branch reachable?" | ✅ |
| "Generate a keygen" | ✅ |
| "Recover CFG over indirect jumps" | ✅ (`CFGEmulated`) |
| "What does this function do?" | ❌ use rizin (`pdf`/`pdc`) |
| "Find imports / strings / xrefs" | ❌ use rizin |
| "Triage a 50MB Go binary" | ❌ angr will choke |
| "Heavy libc / threading / syscalls" | ⚠️ expect state explosion |

**Rule of thumb:** rizin to find *where* to look, angr to solve for *what input* gets there.

## Minimal session pattern

Always run angr scripts as one-shot Python invocations, not a REPL. Write to a temp file, run with `python3`, read the output.

```python
import angr, claripy

proj = angr.Project("/path/to/bin", auto_load_libs=False)
# auto_load_libs=False is almost always what you want — speeds up loading,
# replaces libc with SimProcedure stubs.

state = proj.factory.entry_state()
sm = proj.factory.simulation_manager(state)
sm.explore(find=0xdeadbeef, avoid=[0xbadc0de])

if sm.found:
    print(sm.found[0].posix.dumps(0))   # stdin that reached `find`
else:
    print("no path found")
```

Run with:
```bash
python3 /tmp/solve.py
```

## Common building blocks

### Symbolic stdin of a known length
```python
flag = claripy.BVS("flag", 8 * 32)            # 32-byte symbolic input
state = proj.factory.entry_state(stdin=flag)
```

### Symbolic argv
```python
arg = claripy.BVS("arg", 8 * 16)
state = proj.factory.entry_state(args=["./bin", arg])
```

### Constrain to printable ASCII
```python
for byte in flag.chop(8):
    state.solver.add(byte >= 0x20, byte <= 0x7e)
```

### Start mid-function (skip setup / anti-debug)
```python
state = proj.factory.blank_state(addr=0x401234)
# blank_state has uninitialized regs/mem — set what matters:
state.regs.rdi = claripy.BVS("arg0", 64)
```

### Hook a function with a Python stub
```python
@proj.hook(0x401500, length=5)
def skip_check(state):
    state.regs.rax = 1
```

### Replace a libc function
```python
proj.hook_symbol("strcmp", angr.SIM_PROCEDURES["libc"]["strcmp"]())
```

## CFG recovery

```python
cfg = proj.analyses.CFGFast()                 # fast, static, default choice
cfg = proj.analyses.CFGEmulated(keep_state=True)  # slower, handles indirect calls
for func in cfg.functions.values():
    print(hex(func.addr), func.name)
```

## Decompiler (when rizin's `pdc` isn't enough)

```python
proj.analyses.CFGFast(normalize=True)
dec = proj.analyses.Decompiler(proj.kb.functions[0x401200])
print(dec.codegen.text)
```

angr's decompiler is competitive with Ghidra on small functions; it churns more than rizin commands do, so pin angr versions if you script it.

## Reading results

| Goal | How |
|---|---|
| stdin bytes that reached a state | `state.posix.dumps(0)` |
| stdout produced along the way | `state.posix.dumps(1)` |
| Concretize a symbolic var | `state.solver.eval(sym, cast_to=bytes)` |
| All solutions (up to N) | `state.solver.eval_upto(sym, N, cast_to=bytes)` |
| Current PC | `state.addr` |
| Active paths | `sm.active`, `sm.deadended`, `sm.found`, `sm.errored` |

## Workflow

1. **Get target addresses from rizin first.** Don't make angr discover them — `rz -A -q -c 'afl~main; iz~flag' bin` is faster than `CFGFast`.
2. **Pick the cheapest entry point.** `entry_state` is simplest. `blank_state` at the check function skips startup cost. `full_init_state` only if you need real loader semantics — and **never on Windows PEs** unless you've budgeted serious time, since the CRT + libgcc init paths explode symbolically and rarely return.
3. **Set `auto_load_libs=False`** unless you have a reason not to.
4. **Define `find` and `avoid` precisely.** A wrong-but-tempting address in `find` (e.g. a printf inside the success branch) gives spurious solutions.
5. **Constrain inputs** to printable / null-free / fixed-length so the solver doesn't return garbage that "works" but isn't realistic.
6. **Run, then iterate.** If `sm.found` is empty: check `sm.errored`, increase exploration with `sm.explore(..., num_find=1, n=50)`, or move the entry point closer to the check.

## Gotchas

- **State explosion** is the #1 failure mode. Symptoms: script eats RAM, never returns. Fixes: tighter `avoid` set, hook expensive functions with stubs, start later in the binary, use `veritesting=True` on the simulation manager, or switch to `LAZY_SOLVES`.
- **Unconstrained successors** mean angr lost track of PC (often: jump through symbolic pointer). Inspect `sm.unconstrained`. Usually means you need to hook the function or supply concrete state.
- **`auto_load_libs=True` + glibc** loads ~30MB of ELF and runs ld.so symbolically. Almost never what you want.
- **Fork bombs in loops.** A symbolic loop counter forks once per iteration. Concretize the counter or unroll with a hook.
- **angr is slow to import** (~2s). Bundle multiple queries into one script.
- **API drift.** `simuvex` is gone, `path_group` is now `simulation_manager`, the decompiler API moves between releases. Check `angr.__version__` if old snippets fail.
- **Don't symbolically execute through `printf`.** Use the SimProcedure (default with `auto_load_libs=False`).

## Output to the user

- **Lead with the answer.** "Input that reaches `win`: `b'AAAA...'`". Then show the script.
- **Include the script** so the user can rerun/modify.
- **Report what was explored** — number of states, time, where it ended up — so the user can judge whether the result is trustworthy.
- **If it didn't work, say why** (state explosion, no path found, errored states) and propose the next move (different entry point, hook a function, concretize an input).

## Pairing with rizin-re

Typical handoff:
1. In rizin: `iz~flag`, `afl~check`, `axt @ sym.imp.strcmp` → get address of the comparison or the success branch.
2. In angr: `sm.explore(find=<that addr>, avoid=[<failure addr>])`.
3. Print `state.posix.dumps(0)`.
4. Back in rizin (or just `./bin`): verify the input works.

For programmatic handoff, `rzpipe` lets a Python script query a running rizin session:
```python
import rzpipe
rz = rzpipe.open("./bin"); rz.cmd("aaa")
win = next(f["offset"] for f in rz.cmdj("aflj") if f["name"] == "sym.win")
```
But for one-shot work, eyeballing addresses from rizin output is usually faster.

## Local references

Offline copies of the most-needed angr docs live in `references/` next to this skill. **Read them on demand** — don't preload. Pick by task:

| File | When to load |
|---|---|
| `references/cheatsheet.md` | One-stop API reference: states, sm, claripy, hooks, posix. **Read this first** for any non-trivial script. |
| `references/quickstart.md` | Minimal end-to-end example. Load when bootstrapping a new script. |
| `references/symbolic-execution.md` | Conceptual primer on `claripy.BVS`, constraints, `state.solver.eval`. Load when the user is new to symbolic execution. |
| `references/simulation-managers.md` | Stashes (`active`/`found`/`deadended`/`unconstrained`), explore options, exploration techniques (DFS, Veritesting, LengthLimiter). Load when `sm.found` is empty or state explosion hits. |
| `references/solver.md` | Claripy depth: BV ops, `eval_upto`, `cast_to`, FP. Load for keygens or multi-solution problems. |
| `references/loading.md` | CLE backends, `main_opts`, `lib_opts`, custom base addr, blob loading. Load when the binary isn't a vanilla ELF/PE. |
| `references/gotchas.md` | Official footguns list — symbolic length, file ops, environment. Load when something behaves unexpectedly. |
| `references/examples.md` | Index of upstream CTF/crackme writeups by binary. Load to find a precedent for the current challenge. |

## Notes

- Install: `pip install angr` (pulls claripy, cle, pyvex, z3-solver). Heavy — use a venv.
- Docs: https://docs.angr.io/en/latest/
- Examples repo: https://github.com/angr/angr-doc/tree/master/examples — `defcamp_r100`, `sym-write`, and `fauxware` cover 80% of CTF patterns.
