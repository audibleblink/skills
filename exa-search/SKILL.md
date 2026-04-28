---
name: exa-search
description: Search the web with Exa's neural search API via curl. Use when the user wants to search the web, research a topic, find articles/papers/companies/people, fetch clean page contents from URLs, or get an LLM answer with citations — including triggers like "exa", "search the web", "look this up", "latest on", or factual questions needing fresh sources. Prefer over generic web_fetch for ranked/semantic results. Auth via `op` CLI (`op://infra/exa/token`).
---

# Exa Search

Exa is a neural web search API. This skill calls it with plain `curl`, authenticating via the 1Password CLI. Three endpoints are in scope:

- `POST /search` — ranked search results, optionally with page contents
- `POST /contents` — fetch cleaned text/highlights/summaries for specific URLs
- `POST /answer` — LLM-written answer with citations

Base URL: `https://api.exa.ai`

## Auth

The API key lives in 1Password at `op://infra/exa/token`. Read it at call time — don't echo it, don't save it to disk, don't put it on the command line (so it doesn't show up in `ps` or shell history). Pipe it via a header file or env var:

```bash
EXA_API_KEY=$(op read op://infra/exa/token)
```

If `op read` fails, tell the user — most likely they need to run `op signin` or unlock the vault. Don't try to work around it.

## Calling convention

Use `curl -s` with `--fail-with-body` so HTTP errors surface cleanly, and pipe the response through `jq` for readability. Keep the API key in the environment, not the argv:

```bash
curl -sS --fail-with-body https://api.exa.ai/search \
  -H "x-api-key: $EXA_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"query": "...", "numResults": 5, "contents": {"text": true}}' \
  | jq
```

For bodies with user-supplied strings, build the JSON with `jq -n` (not string interpolation) so quotes and newlines are handled correctly:

```bash
BODY=$(jq -n --arg q "$QUERY" '{query: $q, numResults: 5, contents: {text: true}}')
curl -sS --fail-with-body https://api.exa.ai/search \
  -H "x-api-key: $EXA_API_KEY" -H "Content-Type: application/json" \
  -d "$BODY"
```

## /search

Most common endpoint. Useful fields:

| Field | Notes |
|---|---|
| `query` (required) | Natural-language query. Exa is neural, so phrase it like you'd describe the ideal result. |
| `type` | `auto` (default), `neural`, `fast`, `deep`, `deep-reasoning`, `instant`. Use `auto` unless there's a reason. `deep` is slower but thorough. |
| `numResults` | Default 10. Bump up only if the user is doing broad research. |
| `category` | `company`, `research paper`, `news`, `pdf`, `github`, `personal site`, `people`, `financial report`. Narrows and improves quality a lot when it fits. |
| `includeDomains` / `excludeDomains` | Array of domains. |
| `startPublishedDate` / `endPublishedDate` | ISO 8601, e.g. `2024-01-01T00:00:00.000Z`. Use for "latest" / "recent" queries. |
| `contents` | See below — usually you want `{"text": true}` to get page content in the same call. |

Example — "latest papers on mixture of experts":

```bash
jq -n '{
  query: "recent research on mixture-of-experts language models",
  type: "auto",
  category: "research paper",
  numResults: 8,
  startPublishedDate: "2024-01-01T00:00:00.000Z",
  contents: {text: {maxCharacters: 2000}, summary: {query: "key findings"}}
}'
```

## /contents

Given a list of URLs or Exa result IDs, returns clean text, highlights, and/or summaries. Use this when the user already has URLs and wants the contents extracted:

```bash
jq -n --argjson urls "$(jq -c -n '["https://example.com/a","https://example.com/b"]')" '{
  urls: $urls,
  text: {maxCharacters: 4000},
  summary: {query: "what is this page about"}
}' | curl -sS --fail-with-body https://api.exa.ai/contents \
  -H "x-api-key: $EXA_API_KEY" -H "Content-Type: application/json" -d @-
```

Key options inside `text`/`summary`/`highlights`:
- `text.maxCharacters` — cap response size (costs + tokens).
- `summary.query` — direct the summary toward a specific angle.
- `highlights: true` — LLM-selected relevant snippets per page.
- `livecrawl: "preferred"` or `maxAgeHours: N` — freshness control.

## /answer

Returns a single synthesized answer with citations. Good for direct factual questions ("what is X's latest valuation?"). Set `text: true` to also get the underlying source text:

```bash
jq -n --arg q "$QUERY" '{query: $q, text: true}' \
  | curl -sS --fail-with-body https://api.exa.ai/answer \
    -H "x-api-key: $EXA_API_KEY" -H "Content-Type: application/json" -d @-
```

## Choosing the endpoint

- User asks an open-ended research / "find me" question → `/search` with `contents.text` or `contents.summary`.
- User has specific URLs and wants them cleaned/summarized → `/contents`.
- User asks a direct factual question expecting one answer → `/answer`.
- User wants multiple candidate sources to skim → `/search` without contents (cheaper), then `/contents` on the ones they pick.

## Presenting results to the user

Raw Exa JSON is noisy. After the call, summarize for the user: title, URL, publish date, and a 1–2 sentence takeaway per result (from `summary` or the first bit of `text`). Keep citations as clickable URLs. If the user asked for research, group or rank rather than dumping the raw list.

If a call fails, show the HTTP status and response body — Exa's error messages are usually specific (e.g. unsupported filter for a given `category`).

## Cost awareness

Each result with `contents.text` costs more than a bare search result, and `deep` / `deep-reasoning` cost more than `auto`. Default to `auto` + modest `numResults` (5–10) + `text: {maxCharacters: 2000}` unless the user signals they want something bigger.
