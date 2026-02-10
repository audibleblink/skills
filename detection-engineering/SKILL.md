---
name: detection-engineering
description: Expert guidance for writing, reviewing, and improving security detection rules. Apply core detection engineering frameworks including Capability Abstraction, Detection Spectrum, and the Funnel of Fidelity. Use when writing detection rules (Sigma, YARA-L, KQL, Splunk SPL), reviewing existing detections for blind spots, analyzing attack techniques for detection opportunities, evaluating detection coverage and evasion resistance, or building detection strategies that balance precision vs breadth.
---

# Detection Engineering

Apply core detection engineering frameworks to write robust, evasion-resistant detection rules.

## Detection Rule Analysis Framework

When writing or reviewing a detection rule, answer these three questions:

### 1. Detection Goal
What activity is this rule trying to detect?
- Define the objective clearly (e.g., "detect malicious service creation")
- Understanding the goal is essential for evaluating efficacy

### 2. Identification
How does this rule establish the set of relevant events?
- Identify ALL events representing the target activity before classifying them
- Find the **base condition**: an event that must occur regardless of tool or method
- Example: Service creation base condition = registry key at `HKLM\System\CurrentControlSet\Services\<ServiceName>`

**Warning**: A rule detecting service creation via `sc.exe create` missed 99.97% of actual service creation events in testing.

### 3. Classification
How does the rule differentiate "good" from "bad" events?
- Apply detection logic to the identified population
- Balance false positives vs false negatives based on organizational capacity

## Capability Abstraction

Attacker tools are abstractions of underlying attack capabilities. Peel back layers to find robust detection points:

```
┌─────────────────────────────────────────────────────────────┐
│ Tools        │ Mimikatz, Rubeus, PowerShell scripts        │ ← Easy to bypass
├──────────────┼─────────────────────────────────────────────┤
│ Managed Code │ .NET classes (KerberosRequestorSecurityToken)│
├──────────────┼─────────────────────────────────────────────┤
│ Windows API  │ InitializeSecurityContext, LsaCallAuth...   │
├──────────────┼─────────────────────────────────────────────┤
│ RPC          │ Interface UUIDs, DLL endpoints              │
├──────────────┼─────────────────────────────────────────────┤
│ Network      │ Kerberos TGS-REQ/REP                        │ ← Hard to evade
└─────────────────────────────────────────────────────────────┘
```

**Key insight**: Lower abstraction layers = broader coverage but more false positives. Higher layers = precise but easier to evade.

## Detection Spectrum

Detections fall on a spectrum between precise and broad:

| Type | False Positives | False Negatives | Use Case |
|------|-----------------|-----------------|----------|
| **Precise** | Low | High | Known malicious tool hash, specific command patterns |
| **Broad** | High | Low | Fundamental behaviors (network protocols, API calls) |

**Effective strategy**: Layer multiple detections across different abstraction levels and spectrum positions.

## Building Robust Detections

1. **Identify spanning sets of observables**
   - Find events that cover many/all implementations
   - Use Detection Decomposition Diagrams (D3) to visualize coverage
   - Example: For Scheduled Tasks, both registry keys (TaskCache\Tasks) and EID 4698 are spanning observables

2. **Select observables most specific to malicious behavior**
   - Choose observables that are robust (hard to evade) AND effective at distinguishing malicious from benign
   - Example: EID 4698 covers most Scheduled Task implementations with good accuracy

3. **Add exclusions for false positive reduction**
   - Exclusions must be specific to avoid creating "hiding spaces"
   - Use robust fields (difficult for adversaries to modify)
   - Build environmental baselines for allow-listing
   - **Assume adversaries know your detection logic**

4. **Incorporate into fused analytic frameworks**
   - Combine multiple analytics: Risk-Based Alerting (RBA), Graph Analysis, Statistical Analysis

## Funnel of Fidelity

The five sequential phases of detection and response:

```
Collection (1000000s events) → Detection (100s alerts) → Triage → Investigation (10s leads) → Remediation (1s incidents)
```

**Don't clog the funnel**: Each stage must effectively filter for the next. Fix bottlenecks at the earliest stage first.

## Detection Categories by Timeframe

| Type | Description | Pros | Cons |
|------|-------------|------|------|
| **Point-in-Time (PIT)** | Scans for active technique use | Simple, no agent | Misses ephemeral data |
| **Historical (HDT)** | Analyzes logged data | Fills ephemeral gaps | Logs incomplete, tamperable |
| **Real-time/Agent** | Captures events as they happen | No blind spots | Agent can be disabled |

## Writing Detection Rules Checklist

Before finalizing a detection rule:

- [ ] **Goal**: Can you state the detection objective in one sentence?
- [ ] **Identification**: Does the rule capture ALL relevant events (not just one tool)?
- [ ] **Base condition**: Have you identified the unavoidable event for this technique?
- [ ] **Abstraction level**: What layer are you detecting at? Is it appropriate?
- [ ] **Spectrum position**: Is this precise or broad? Is that intentional?
- [ ] **Exclusions**: Are they specific and using robust fields?
- [ ] **Evasion resistance**: How easily can an attacker bypass this rule?
- [ ] **Coverage**: Combined with other rules, do you have layered coverage?
