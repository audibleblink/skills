# GrepAI Configuration Reference

All configuration lives in `.grepai/config.yaml`.

## Search Boosting

Prioritize source code over tests/vendor by re-ranking results:

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

## Trace Configuration

```yaml
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
