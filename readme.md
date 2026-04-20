---
description: Index of skills
---
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
Write, optimize, and debug KQL (Kusto Query Language) queries for Microsoft Defender for Endpoint (MDE), Microsoft Sentinel, and Microsoft 365 Defender XDR. ALWAYS use this skill when the user mentions DeviceProcessEvents, DeviceFileEvents, DeviceNetworkEvents, DeviceLogonEvents, DeviceRegistryEvents, AlertInfo, or any MDE/Sentinel table names. Use for threat hunting queries, detection rules, incident investigation, IOC hunting, MITRE ATT&CK detections, query optimization, or converting SPL/other query languages to KQL. Trigger on phrases like "write a KQL query", "defender query", "sentinel query", "hunt for", "detection rule", "M365 defender", or any security analysis involving Microsoft security products.

**Location:** `kql-mde-xdr/SKILL.md`

### mcp-builder
Build MCP (Model Context Protocol) servers that connect LLMs to external APIs and services. Use when creating MCP servers in Python (FastMCP) or Node/TypeScript (MCP SDK).

**Location:** `mcp-builder/SKILL.md`

### notebooklm
Automate Google NotebookLM to create AI-generated podcasts, audio overviews, study guides, FAQs, briefing docs, and deep dive analyses from sources like YouTube videos, PDFs, URLs, audio files, and images. ALWAYS use this skill when the user wants to "create a podcast", "make an audio overview", "generate a study guide", or turn content into a conversational audio format with AI hosts. Also triggers on "notebooklm", "audio briefing", "podcast about", "deep dive from", or requests to chat with/query multiple documents as a unified knowledge base. Does NOT apply to simple transcription, TTS, audio editing, or basic summarization.

**Location:** `notebooklm/SKILL.md`

### obsidian-vault
Write and edit Obsidian vault notes using Obsidian-flavored Markdown. Use when (1) creating new .md notes for an Obsidian vault, (2) editing existing Obsidian notes, (3) adding properties/frontmatter, wikilinks, callouts, embeds, tags, or other Obsidian-specific syntax, (4) converting standard Markdown to Obsidian format, (5) creating presentation slides for Obsidian Slides Extended (reveal.js), or (6) any task involving Obsidian Markdown formatting.

**Location:** `obsidian-vault/SKILL.md`

### ship-learn-next
Transform learning content (like YouTube transcripts, articles, tutorials) into actionable implementation plans using the Ship-Learn-Next framework. Use when user wants to turn advice, lessons, or educational content into concrete action steps, reps, or a learning quest.

**Location:** `ship-learn-next/SKILL.md`

### skill-creator
Create new skills, modify and improve existing skills, and measure skill performance. Use when users want to create a skill from scratch, update or optimize an existing skill, run evals to test a skill, benchmark skill performance with variance analysis, or optimize a skill's description for better triggering accuracy.

**Location:** `skill-creator/SKILL.md`

### typst-copilot
Typst (.typ) document assistant for creation, layout debugging, compilation, and format conversion. Use this skill whenever (1) user mentions "Typst", ".typ files", or Typst syntax patterns (#figure, #table, #set, #show), (2) creating any document type in Typst - papers, reports, resumes, CVs, presentations, slides, (3) struggling with layout - figures floating to wrong places, page breaks cutting off content, columns not working, elements mispositioned, (4) document structure issues - TOC page numbers wrong, headers not updating, show rules misbehaving, (5) compiling Typst to PDF or hitting build errors ("unknown variable", syntax errors), (6) converting or migrating from LaTeX/Markdown to Typst. This skill is the go-to for anything Typst-related. If the problem involves .typ files or Typst-specific concepts, use this skill.

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
