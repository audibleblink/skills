# Agent Skills

A collection of specialized skills that provide domain-specific instructions and workflows for Claude.

## Available Skills

### attack-chain-outliner
Create structured attack chain documentation with MITRE ATT&CK mapping, detection logic, and professional threat reports. Use when documenting adversary techniques, writing detection rules, analyzing malware/APT TTPs, or creating threat intelligence reports.

**Location:** `attack-chain-outliner/SKILL.md`

### google-secops-yaral
Master YARAL query language for low-maintenance threat hunting and detection in Google SecOps. Build behavioral detections without magic strings or IOC lists. Use when writing YARAL queries, creating custom detections based on network/process behavior, debugging failing queries, or learning YARAL syntax and best practices.

**Location:** `google-secops-yaral/SKILL.md`

### kql-mde-xdr
Expert in Kusto Query Language (KQL) and Microsoft Defender for Endpoint (MDE) / Microsoft 365 Defender XDR. Use when working with KQL queries, threat hunting, security investigations, writing detection rules, analyzing security data in Microsoft Sentinel, MDE, or any Microsoft XDR platform. Triggers on KQL syntax questions, threat hunting queries, detection engineering, incident investigation, or security analytics using Microsoft security tools.

**Location:** `kql-mde-xdr/SKILL.md`

### mcp-builder
Guide for creating high-quality MCP (Model Context Protocol) servers that enable LLMs to interact with external services through well-designed tools. Use when building MCP servers to integrate external APIs or services, whether in Python (FastMCP) or Node/TypeScript (MCP SDK).

**Location:** `mcp-builder/SKILL.md`

### obsidian-slide-creator
Create presentation slide decks for Obsidian Slides Extended (reveal.js wrapper). Use when the user requests slide generation, presentation creation, or converting content to slides. Handles multiple input formats including outlines, topic descriptions, existing markdown, and interactive planning. Always uses the 'blood' theme.

**Location:** `obsidian-slide-creator/SKILL.md`

### skill-creator
Guide for creating effective skills. This skill should be used when users want to create a new skill (or update an existing skill) that extends Claude's capabilities with specialized knowledge, workflows, or tool integrations.

**Location:** `skill-creator/SKILL.md`

### tmux
Guide for managing terminal sessions with tmux via bash. Use when running long-lived processes, managing multiple concurrent terminal sessions, monitoring background tasks, or needing persistent shells that survive disconnection. Covers session/window/pane management, sending commands to background processes, and capturing output.

**Location:** `tmux/SKILL.md`

### typst-copilot
Typst document creation, editing, and compilation assistant. Use when (1) creating Typst documents, (2) converting Markdown/LaTeX to Typst, (3) compiling .typ files to PDF, (4) debugging layout/page flow issues, (5) answering Typst syntax questions.

**Location:** `typst-copilot/SKILL.md`

### vercel-react-best-practices
React and Next.js performance optimization guidelines from Vercel Engineering. This skill should be used when writing, reviewing, or refactoring React/Next.js code to ensure optimal performance patterns. Triggers on tasks involving React components, Next.js pages, data fetching, bundle optimization, or performance improvements.

**Location:** `react-best-practices/SKILL.md`
