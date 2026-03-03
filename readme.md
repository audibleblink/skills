# Agent Skills

A collection of specialized skills that provide domain-specific instructions and workflows for Claude.

## Available Skills

### attack-chain-outliner
Create structured attack chain documentation with MITRE ATT&CK mapping, detection logic, and professional threat reports. Use when documenting adversary techniques, writing detection rules, analyzing malware/APT TTPs, or creating threat intelligence reports.

**Location:** `attack-chain-outliner/SKILL.md`

### detection-engineering
Expert guidance for writing, reviewing, and improving security detection rules. Apply core detection engineering frameworks including Capability Abstraction, Detection Spectrum, and the Funnel of Fidelity. Use when writing detection rules (Sigma, YARA-L, KQL, Splunk SPL), reviewing existing detections for blind spots, analyzing attack techniques for detection opportunities, evaluating detection coverage and evasion resistance, or building detection strategies that balance precision vs breadth.

**Location:** `detection-engineering/SKILL.md`

### google-secops-yaral
Write and debug YARAL queries for behavioral threat hunting and detection in Google SecOps. Use when creating YARAL detections, hunting for network/process behavior, or learning YARAL syntax.

**Location:** `google-secops-yaral/SKILL.md`

### grepai
Semantic code search, and call graph analysis with GrepAI. Use when (1) searching code by meaning/intent rather than exact text, (2) finding function callers or callees, or (3) integrating GrepAI with AI agents via JSON/TOON output.

**Location:** `grepai/SKILL.md`

### kql-mde-xdr
Write and optimize KQL queries for Microsoft Defender (MDE), Sentinel, and Microsoft 365 Defender XDR. Use when threat hunting, writing detection rules, investigating incidents, or analyzing security data with KQL.

**Location:** `kql-mde-xdr/SKILL.md`

### mcp-builder
Build MCP (Model Context Protocol) servers that connect LLMs to external APIs and services. Use when creating MCP servers in Python (FastMCP) or Node/TypeScript (MCP SDK).

**Location:** `mcp-builder/SKILL.md`

### obsidian-vault
Write and edit Obsidian vault notes using Obsidian-flavored Markdown. Use when (1) creating new .md notes for an Obsidian vault, (2) editing existing Obsidian notes, (3) adding properties/frontmatter, wikilinks, callouts, embeds, tags, or other Obsidian-specific syntax, (4) converting standard Markdown to Obsidian format, (5) creating presentation slides for Obsidian Slides Extended (reveal.js), or (6) any task involving Obsidian Markdown formatting.

**Location:** `obsidian-vault/SKILL.md`

### ship-learn-next
Transform learning content (like YouTube transcripts, articles, tutorials) into actionable implementation plans using the Ship-Learn-Next framework. Use when user wants to turn advice, lessons, or educational content into concrete action steps, reps, or a learning quest.

**Location:** `ship-learn-next/SKILL.md`

### skill-creator
Guide for creating effective skills. This skill should be used when users want to create a new skill (or update an existing skill) that extends Claude's capabilities with specialized knowledge, workflows, or tool integrations.

**Location:** `skill-creator/SKILL.md`

### typst-copilot
Typst document creation, editing, and compilation assistant. Use when (1) creating Typst documents, (2) converting Markdown/LaTeX to Typst, (3) compiling .typ files to PDF, (4) debugging layout/page flow issues, (5) answering Typst syntax questions.

**Location:** `typst-copilot/SKILL.md`

### vercel-react-best-practices
React and Next.js performance optimization guidelines from Vercel Engineering. Use when writing, reviewing, or refactoring React/Next.js components, data fetching, or bundle optimization.

**Location:** `react-best-practices/SKILL.md`

### youtube-search
Search YouTube for videos by query and return structured JSON results including title, video ID, channel, duration, view count, publish time, approximate upload date, thumbnails, and video URL. Use when the user wants to find YouTube videos, look up content on YouTube, or needs video metadata from YouTube search results.

**Location:** `youtube-search/SKILL.md`

### youtube-transcript
Download YouTube video transcripts when user provides a YouTube URL or asks to download/get/fetch a transcript from YouTube. Also use when user wants to transcribe or get captions/subtitles from a YouTube video.

**Location:** `youtube-transcript/SKILL.md`
