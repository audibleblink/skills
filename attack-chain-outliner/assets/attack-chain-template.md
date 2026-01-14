# [Attack Phase]

## [Technique Name]

### Technique Overview

[First principles explanation of the technique - how it works technically, why adversaries use it, prerequisites, privileges required, platform-specific details]

### Attack Steps

1. **[Step Name]**: [Description of what happens]

2. **[Next Step]**: [Further detail with technical specifics]

3. **[Configuration/Code]**: [Show actual config or code]

```[language]
[code example]
```

4. **[Execution]**: [How the technique is triggered]

### Detection Opportunities

- **[Detection Method] (High/Medium/Low Fidelity)**: [What to detect and why]

- **[Another Method] ([Fidelity])**: [Detection strategy]

- **Evasion Techniques**: [How attackers bypass detection]

- **False Positives**: [Legitimate scenarios that may trigger alerts]

### Data Sources & Log Fields

**[Data Source Name]:**

- `EVENT_TYPE`: [Description of event]
  - [Field 1]: [What to look for]
  - [Field 2]: [Additional context]

**[Another Data Source]:**

- `EVENT_TYPE`: [Description]
  - [Field]: [Details]

**Command-line access:**
```bash
[command to query logs]
```

**Artifacts to monitor:**
- `/path/to/monitor/*`

### Pseudocode Queries

**[Fidelity Level]: [Descriptive Rule Name]**
```
event.type == "[event_type]" AND
[field] [operator] "[value]"
```

**[Fidelity]: [Another Detection]**
```
[query logic]
```

### MITRE ATT&CK Mapping

| Tactic | Technique ID | Technique Name |
|--------|--------------|----------------|
| [Tactic] | [T####.###] | [Technique Name] |
| [Tactic] | [T####.###] | [Technique Name] |
