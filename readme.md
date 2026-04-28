---
description: Index of skills
---

# Agent Skills

A collection of specialized skills that provide domain-specific instructions and workflows for Claude.

## Available Skills

### angr-symexec


Symbolic execution and binary analysis with angr (Python). Use when the user wants to find an input that reaches a target address, solve a crackme/keygen, check branch reachability, recover a CFG over indirect calls, or reason about constraints on program inputs. Trigger on phrases like "symbolic execution", "solve this crackme", "what input reaches", "find the flag with angr", "constraint solving", "angr CFG", or any RE task where the question is "what input makes the program do X". Pairs with the rizin-re skill — use rizin to find target addresses, then angr to solve for inputs that reach them.

**Location:** `attack-chain-outliner/SKILL.md`

### attack-chain-outliner

Create structured attack chain documentation with MITRE ATT&CK mapping, detection logic, and professional threat reports. Use when documenting adversary techniques, writing detection rules, analyzing malware/APT TTPs, or creating threat intelligence reports.

**Location:** `attack-chain-outliner/SKILL.md`

### browser-use

Automates browser interactions for web testing, form filling, screenshots, and data extraction. Use when the user needs to navigate websites, interact with web pages, fill forms, take screenshots, or extract information from web pages.

**Location:** `browser-use/SKILL.md`

### context7

Use when looking up library documentation, API references, framework patterns, or code examples for ANY library (React, Next.js, Vue, Django, Laravel, etc.). Fetches current docs via Context7 REST API. Triggers on: how to use library, API docs, framework pattern, import usage, library example.

**Location:** `context7/SKILL.md`

### detection-engineering

Expert guidance for writing, reviewing, and improving security detection rules. Apply core detection engineering frameworks including Capability Abstraction, Detection Spectrum, and the Funnel of Fidelity. Use when writing detection rules (Sigma, YARA-L, KQL, Splunk SPL), reviewing existing detections for blind spots, analyzing attack techniques for detection opportunities, evaluating detection coverage and evasion resistance, or building detection strategies that balance precision vs breadth.

**Location:** `detection-engineering/SKILL.md`

### exa-search

Search the web with Exa's neural search API via curl. Use when the user wants to search the web, research a topic, find articles/papers/companies/people, fetch clean page contents from URLs, or get an LLM answer with citations — including triggers like "exa", "search the web", "look this up", "latest on", or factual questions needing fresh sources. Prefer over generic web_fetch for ranked/semantic results. Auth via `op` CLI (`op://infra/exa/token`).

**Location:** `exa-search/SKILL.md`

### google-secops-yaral

Write and debug YARAL queries for behavioral threat hunting and detection in Google SecOps. Use when creating YARAL detections, hunting for network/process behavior, or learning YARAL syntax.

**Location:** `google-secops-yaral/SKILL.md`

### grepai

Semantic code search, and call graph analysis with GrepAI. Use when (1) searching code by meaning/intent rather than exact text, (2) finding function callers or callees, or (3) integrating GrepAI with AI agents via JSON/TOON output.

**Location:** `grepai/SKILL.md`

### hindsight-memory-api

Store, retrieve, and reflect on agentic memories via the Hindsight API (hindsight.vectorize.io). Use for persistent cross-session memory — conversation history, fact recall, memory-grounded answers, per-user memory banks. Triggers: Hindsight, memory banks, retain/recall/reflect, agent memory, vectorize.io, making a chatbot "remember" across sessions, long-term AI context, or storing document knowledge in a searchable memory store.

**Location:** `hindsight-memory-api/SKILL.md`

### kql-mde-xdr

Write, optimize, and debug KQL (Kusto Query Language) queries for Microsoft Defender for Endpoint (MDE), Microsoft Sentinel, and Microsoft 365 Defender XDR. ALWAYS use this skill when the user mentions DeviceProcessEvents, DeviceFileEvents, DeviceNetworkEvents, DeviceLogonEvents, DeviceRegistryEvents, AlertInfo, or any MDE/Sentinel table names. Use for threat hunting queries, detection rules, incident investigation, IOC hunting, MITRE ATT&CK detections, query optimization, or converting SPL/other query languages to KQL. Trigger on phrases like "write a KQL query", "defender query", "sentinel query", "hunt for", "detection rule", "M365 defender", or any security analysis involving Microsoft security products.

**Location:** `kql-mde-xdr/SKILL.md`

### mcp-builder

Build MCP (Model Context Protocol) servers that connect LLMs to external APIs and services. Use when creating MCP servers in Python (FastMCP) or Node/TypeScript (MCP SDK).

**Location:** `mcp-builder/SKILL.md`

### notebooklm

Automate Google NotebookLM to generate AI podcasts, audio overviews, study guides, FAQs, briefing docs, and deep dives from YouTube, PDFs, URLs, audio, and images. Use for "create a podcast", "audio overview", "study guide", conversational AI-host audio, or chatting/querying multiple documents as one knowledge base. Triggers - "notebooklm", "audio briefing", "podcast about", "deep dive from". NOT for plain transcription, TTS, audio editing, or basic summarization.

**Location:** `notebooklm/SKILL.md`

### obsidian-vault

Write and edit Obsidian vault notes using Obsidian-flavored Markdown. Use when (1) creating new .md notes for an Obsidian vault, (2) editing existing Obsidian notes, (3) adding properties/frontmatter, wikilinks, callouts, embeds, tags, or other Obsidian-specific syntax, (4) converting standard Markdown to Obsidian format, (5) creating presentation slides for Obsidian Slides Extended (reveal.js), or (6) any task involving Obsidian Markdown formatting.

**Location:** `obsidian-vault/SKILL.md`

### react-best-practices

React and Next.js performance optimization guidelines from Vercel Engineering. Use when writing, reviewing, or refactoring React/Next.js components, data fetching, or bundle optimization.

**Location:** `react-best-practices/SKILL.md`

### rizin-re

Interactive binary reverse engineering with rizin via a persistent tmux session. Use when the user wants to open a binary and explore it — disassemble functions, find strings, inspect imports/exports, trace control flow, analyze malware, work CTF challenges, or do vulnerability research. Trigger on phrases like "open this binary", "reverse engineer", "disassemble", "analyze with rizin", "what does this function do", "find the flag", or any RE task involving an executable or library file.

**Location:** `rizin-re/SKILL.md`

### ship-learn-next

Transform learning content (like YouTube transcripts, articles, tutorials) into actionable implementation plans using the Ship-Learn-Next framework. Use when user wants to turn advice, lessons, or educational content into concrete action steps, reps, or a learning quest.

**Location:** `ship-learn-next/SKILL.md`

### skill-creator

Create new skills, modify and improve existing skills, and measure skill performance. Use when users want to create a skill from scratch, update or optimize an existing skill, run evals to test a skill, benchmark skill performance with variance analysis, or optimize a skill's description for better triggering accuracy.

**Location:** `skill-creator/SKILL.md`

### typst-copilot

Typst (.typ) document assistant for creation, layout debugging, compilation, and format conversion. Use this skill whenever (1) user mentions "Typst", ".typ files", or Typst syntax patterns (#figure, #table, #set, #show), (2) creating any document type in Typst - papers, reports, resumes, CVs, presentations, slides, (3) struggling with layout - figures floating to wrong places, page breaks cutting off content, columns not working, elements mispositioned, (4) document structure issues - TOC page numbers wrong, headers not updating, show rules misbehaving, (5) compiling Typst to PDF or hitting build errors ("unknown variable", syntax errors), (6) converting or migrating from LaTeX/Markdown to Typst. This skill is the go-to for anything Typst-related. If the problem involves .typ files or Typst-specific concepts, use this skill.

**Location:** `typst-copilot/SKILL.md`

### youtube-search

Search YouTube for videos by query and return structured JSON results including title, video ID, channel, duration, view count, publish time, approximate upload date, thumbnails, and video URL. Use when the user wants to find YouTube videos, look up content on YouTube, or needs video metadata from YouTube search results.

**Location:** `youtube-search/SKILL.md`

### youtube-transcript

Download YouTube video transcripts when user provides a YouTube URL or asks to download/get/fetch a transcript from YouTube. Also use when user wants to transcribe or get captions/subtitles from a YouTube video.

**Location:** `youtube-transcript/SKILL.md`
