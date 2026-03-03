#!/usr/bin/env node

// YouTube Search - Pure Node.js script (no dependencies)
// Requires Node.js 18+ for built-in fetch

const UPLOAD_DATE_VALUES = { hour: 1, today: 2, week: 3, month: 4, year: 5 };
const DURATION_VALUES    = { short: 1, medium: 2, long: 3 };

/**
 * Build the YouTube `sp` search-filter parameter by encoding upload-date
 * and/or duration into a minimal protobuf message.
 *
 * Wire format (outer field 2, length-delimited):
 *   0x12 <len> [ 0x08 <upload_date> ] [ 0x18 <duration> ]
 */
function buildSearchFilter(uploadDate, duration) {
  const inner = [];
  if (uploadDate) inner.push(0x08, uploadDate);   // field 1, varint
  if (duration)   inner.push(0x18, duration);      // field 3, varint
  if (inner.length === 0) return null;
  const bytes = Buffer.from([0x12, inner.length, ...inner]);
  return encodeURIComponent(bytes.toString('base64'));
}

const args = process.argv.slice(2);
const query = args.find(a => !a.startsWith('--'));
const maxResults = parseInt(
  args.find(a => a.startsWith('--max-results='))?.split('=')[1] || '10',
  10
);
const uploadDate = args.find(a => a.startsWith('--upload-date='))?.split('=')[1]?.toLowerCase();
const duration   = args.find(a => a.startsWith('--duration='))?.split('=')[1]?.toLowerCase();

if (!query) {
  console.error('Usage: node search.mjs <query> [--max-results=N] [--upload-date=hour|today|week|month|year] [--duration=short|medium|long]');
  process.exit(1);
}

if (uploadDate && !UPLOAD_DATE_VALUES[uploadDate]) {
  console.error(`Invalid --upload-date value: "${uploadDate}". Valid options: ${Object.keys(UPLOAD_DATE_VALUES).join(', ')}`);
  process.exit(1);
}

if (duration && !DURATION_VALUES[duration]) {
  console.error(`Invalid --duration value: "${duration}". Valid options: ${Object.keys(DURATION_VALUES).join(', ')}`);
  process.exit(1);
}

const USER_AGENT =
  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';

/**
 * Extract the ytInitialData JSON object embedded in a YouTube HTML page.
 */
function extractYtInitialData(html) {
  // Format 1: var ytInitialData = {...};
  const marker = 'var ytInitialData = ';
  let idx = html.indexOf(marker);
  if (idx === -1) {
    // Alternate format without "var"
    const alt = 'ytInitialData = ';
    idx = html.indexOf(alt);
    if (idx !== -1) idx += alt.indexOf('{');
    else throw new Error('Could not find ytInitialData in response');
  } else {
    idx += marker.length;
  }

  // If the value starts with a quote, it's an escaped string
  if (html[idx] === "'") {
    const end = html.indexOf("';", idx + 1);
    if (end === -1) throw new Error('Could not parse escaped ytInitialData');
    const escaped = html.substring(idx + 1, end);
    const unescaped = escaped.replace(/\\x([0-9A-Fa-f]{2})/g, (_, hex) =>
      String.fromCharCode(parseInt(hex, 16))
    );
    return JSON.parse(unescaped);
  }

  // Otherwise it's a direct JSON object — find the matching closing brace
  let braceCount = 0;
  let endIdx = idx;
  for (let i = idx; i < html.length; i++) {
    if (html[i] === '{') braceCount++;
    else if (html[i] === '}') braceCount--;
    if (braceCount === 0) {
      endIdx = i + 1;
      break;
    }
  }

  return JSON.parse(html.substring(idx, endIdx));
}

/**
 * Convert a relative time string like "2 months ago" or "Streamed 3 days ago"
 * into an approximate ISO 8601 date string.
 */
function relativeTimeToDate(relativeTime) {
  if (!relativeTime) return null;

  // Strip prefixes like "Streamed " or "Premiered "
  const cleaned = relativeTime
    .replace(/^(Streamed|Premiered|Scheduled for)\s+/i, '')
    .trim();

  const match = cleaned.match(/^(\d+)\s+(second|minute|hour|day|week|month|year)s?\s+ago$/i);
  if (!match) return null;

  const amount = parseInt(match[1], 10);
  const unit = match[2].toLowerCase();
  const now = new Date();

  switch (unit) {
    case 'second': now.setSeconds(now.getSeconds() - amount); break;
    case 'minute': now.setMinutes(now.getMinutes() - amount); break;
    case 'hour':   now.setHours(now.getHours() - amount); break;
    case 'day':    now.setDate(now.getDate() - amount); break;
    case 'week':   now.setDate(now.getDate() - amount * 7); break;
    case 'month':  now.setMonth(now.getMonth() - amount); break;
    case 'year':   now.setFullYear(now.getFullYear() - amount); break;
  }

  return now.toISOString().split('T')[0];
}

/**
 * Parse a videoRenderer object into a structured result.
 */
function parseVideoRenderer(renderer) {
  if (!renderer || !renderer.videoId) return null;

  const channelRun = renderer.ownerText?.runs?.[0];
  const channelEndpoint = channelRun?.navigationEndpoint?.browseEndpoint;

  return {
    videoId: renderer.videoId,
    title:
      renderer.title?.runs?.map(r => r.text).join('') ||
      renderer.title?.simpleText ||
      null,
    channel: {
      name: channelRun?.text || null,
      id: channelEndpoint?.browseId || null,
      url: channelEndpoint?.browseId
        ? `https://www.youtube.com/channel/${channelEndpoint.browseId}`
        : null,
    },
    duration:
      renderer.lengthText?.simpleText ||
      renderer.lengthText?.accessibility?.accessibilityData?.label ||
      null,
    viewCount:
      renderer.viewCountText?.simpleText ||
      renderer.viewCountText?.runs?.map(r => r.text).join('') ||
      null,
    publishedTime: renderer.publishedTimeText?.simpleText || null,
    publishedDate: relativeTimeToDate(renderer.publishedTimeText?.simpleText),
    description:
      renderer.detailedMetadataSnippets?.[0]?.snippetText?.runs
        ?.map(r => r.text)
        .join('') ||
      renderer.descriptionSnippet?.runs?.map(r => r.text).join('') ||
      null,
    thumbnail:
      renderer.thumbnail?.thumbnails?.at(-1)?.url || null,
    url: `https://www.youtube.com/watch?v=${renderer.videoId}`,
  };
}

async function search(query, maxResults, uploadDate, duration) {
  let url = `https://www.youtube.com/results?search_query=${encodeURIComponent(query)}`;
  const sp = buildSearchFilter(UPLOAD_DATE_VALUES[uploadDate], DURATION_VALUES[duration]);
  if (sp) url += `&sp=${sp}`;

  const response = await fetch(url, {
    headers: {
      'User-Agent': USER_AGENT,
      Accept:
        'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8',
      'Accept-Language': 'en-US,en;q=0.9',
    },
  });

  if (!response.ok) {
    throw new Error(`YouTube returned HTTP ${response.status}: ${response.statusText}`);
  }

  const html = await response.text();
  const data = extractYtInitialData(html);

  // Navigate to the search results section
  const contents =
    data?.contents?.twoColumnSearchResultsRenderer?.primaryContents
      ?.sectionListRenderer?.contents || [];

  const videos = [];

  for (const section of contents) {
    const items = section?.itemSectionRenderer?.contents || [];
    for (const item of items) {
      if (videos.length >= maxResults) break;

      if (item.videoRenderer) {
        const parsed = parseVideoRenderer(item.videoRenderer);
        if (parsed) videos.push(parsed);
      }
    }
    if (videos.length >= maxResults) break;
  }

  return videos;
}

try {
  const results = await search(query, maxResults, uploadDate, duration);
  console.log(JSON.stringify(results, null, 2));
} catch (err) {
  console.error(`Error: ${err.message}`);
  process.exit(1);
}
