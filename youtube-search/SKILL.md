---
name: youtube-search
description: Search YouTube for videos by query and return structured JSON results including title, video ID, channel, duration, view count, publish time, approximate upload date, thumbnails, and video URL. Use when the user wants to find YouTube videos, look up content on YouTube, or needs video metadata from YouTube search results.
---

# YouTube Search Skill

Search YouTube and return structured video results as JSON.

## Usage

Run the search script with a query:

```bash
node ./scripts/search.mjs "your search query"
```

### Options

| Argument | Description | Default |
|----------|-------------|---------|
| 1st positional | Search query (required) | — |
| `--max-results=N` | Maximum number of results to return | 10 |
| `--upload-date=PERIOD` | Filter by upload date: `hour`, `today`, `week`, `month`, `year` | no filter |
| `--duration=LENGTH` | Filter by duration: `short` (<4 min), `medium` (4–20 min), `long` (>20 min) | no filter |

### Examples

```bash
# Basic search
node scripts/search.mjs "typescript tutorial"

# Limit results
node scripts/search.mjs "bun runtime" --max-results=5

# Filter by upload date
node scripts/search.mjs "claude code" --upload-date=month

# Combine filters
node scripts/search.mjs "react tutorial" --max-results=5 --upload-date=week --duration=long
```

## Output Format

The script outputs a JSON array to stdout. Each element has:

```json
[
  {
    "videoId": "dQw4w9WgXcQ",
    "title": "Video title",
    "channel": {
      "name": "Channel Name",
      "id": "UCxxxxxx",
      "url": "https://www.youtube.com/channel/UCxxxxxx"
    },
    "duration": "3:32",
    "viewCount": "1,234,567 views",
    "publishedTime": "2 days ago",
    "publishedDate": "2026-02-18",
    "description": "Short snippet of the video description...",
    "thumbnail": "https://i.ytimg.com/vi/dQw4w9WgXcQ/hqdefault.jpg",
    "url": "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
  }
]
```

## Rendering Results

Always present results as a **markdown table** with the video title rendered as a clickable link. Use this format:

| # | Title | Channel | Duration | Views | Published |
|---|-------|---------|----------|-------|-----------|
| 1 | [Video title](https://www.youtube.com/watch?v=VIDEO_ID) | Channel Name | 3:32 | 1,234,567 views | 2 days ago |

## How It Works

1. Fetches the YouTube search results page for the given query
2. Extracts the embedded `ytInitialData` JSON from the HTML response
3. Parses video renderers from the search result contents
4. Returns structured JSON to stdout

No YouTube API key is required. The script scrapes public YouTube search pages using the same technique a browser would use.

## Error Handling

- Errors are written to stderr so they don't interfere with JSON output on stdout
- Non-zero exit code on failure
- Gracefully handles missing fields in video data (returns `null` for unavailable fields)
