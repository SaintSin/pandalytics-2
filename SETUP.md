# Pandalytics 2 - Setup Instructions

A lightweight analytics solution built with Astro, Netlify Functions, and Turso (SQLite).

## Features

- **Core Web Vitals tracking**: LCP, CLS, FID, FCP, TTFB, INP
- **Session management**: Track unique sessions and user journeys
- **Real-time metrics**: Page views, session duration, bounce rate
- **Geographic data**: Country detection via Netlify headers
- **Browser detection**: Automatic browser and version parsing
- **Privacy-focused**: No cookies, minimal client-side tracking

## Prerequisites

- Node.js 18+
- Netlify account
- Turso account (free tier available)
- Astro project

## Database Setup

### 1. Create Turso Database

```bash
# Install Turso CLI
curl -sSfL https://get.tur.so/install.sh | bash

# Create database
turso db create pandalytics

# Get database URL and auth token
turso db show pandalytics
turso db tokens create pandalytics
```

### 2. Create Database Schema

Execute the following SQL in your Turso database:

```sql
-- Sessions table: One record per user session
CREATE TABLE sessions (
  session_id TEXT PRIMARY KEY,
  site_id TEXT NOT NULL,
  start_time INTEGER NOT NULL,
  end_time INTEGER,
  total_pageviews INTEGER DEFAULT 1,
  country_code TEXT,
  screen_width INTEGER,
  screen_height INTEGER,
  user_agent TEXT,
  browser TEXT,
  is_bounce BOOLEAN DEFAULT 1,
  total_duration_ms INTEGER DEFAULT 0,
  created_at INTEGER DEFAULT (strftime('%s', 'now') * 1000),
  updated_at INTEGER DEFAULT (strftime('%s', 'now') * 1000)
);

-- Pageviews table: One record per page visit
CREATE TABLE pageviews (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  session_id TEXT NOT NULL,
  url TEXT NOT NULL,
  path TEXT,
  referrer TEXT,
  timestamp INTEGER NOT NULL,
  duration_ms INTEGER DEFAULT 0,

  -- Core Web Vitals
  lcp INTEGER, -- Largest Contentful Paint (ms)
  cls INTEGER, -- Cumulative Layout Shift (scaled by 1000)
  fid INTEGER, -- First Input Delay (ms)
  fcp INTEGER, -- First Contentful Paint (ms)
  ttfb INTEGER, -- Time to First Byte (ms)
  inp INTEGER, -- Interaction to Next Paint (ms)

  created_at INTEGER DEFAULT (strftime('%s', 'now') * 1000),

  FOREIGN KEY (session_id) REFERENCES sessions(session_id)
);

-- Performance indexes
CREATE INDEX idx_sessions_site_id ON sessions(site_id);
CREATE INDEX idx_sessions_start_time ON sessions(start_time);
CREATE INDEX idx_sessions_country ON sessions(country_code);
CREATE INDEX idx_pageviews_session_id ON pageviews(session_id);
CREATE INDEX idx_pageviews_timestamp ON pageviews(timestamp);
CREATE INDEX idx_pageviews_path ON pageviews(path);
```

Alternatively, run the provided schema file:

```bash
turso db shell pandalytics < db/create_tables.sql
```

## Environment Variables

### Netlify Environment Variables

Add these to your Netlify site settings:

```env
PANDALYTICS_TURSO_REST_ENDPOINT=https://your-database.turso.io
PANDALYTICS_TURSO_API_TOKEN=your_auth_token_here
```

### Local Development (.env)

```env
PANDALYTICS_TURSO_REST_ENDPOINT=https://your-database.turso.io
PANDALYTICS_TURSO_API_TOKEN=your_auth_token_here
```

## Installation

### 1. Install Dependencies

```bash
npm install
```

### 2. Add Analytics Component

Include the analytics component in your layout:

```astro
---
import Analytics from "@components/page/Analytics.astro";
---

<!doctype html>
<html>
	<body>
		<!-- Your content -->
		<Analytics />
	</body>
</html>
```

### 3. Configure Site ID

Update the site ID in `src/components/page/Analytics.astro`:

```javascript
const siteId = "Your Site Name"; // Change per site
```

### 4. Deploy Functions

Ensure your Netlify functions are deployed:

```bash
netlify dev  # For local testing
netlify deploy --prod  # For production
```

## Usage

### View Metrics

Navigate to `/metrics` on your deployed site to see analytics data.

### Custom Analytics Queries

Access your Turso database to run custom queries:

```sql
-- Session overview
SELECT
  site_id,
  COUNT(*) as sessions,
  AVG(total_pageviews) as avg_pageviews,
  AVG(total_duration_ms) as avg_duration
FROM sessions
GROUP BY site_id;

-- Page performance
SELECT
  path,
  COUNT(*) as pageviews,
  AVG(lcp) as avg_lcp,
  AVG(fcp) as avg_fcp,
  AVG(cls) as avg_cls
FROM pageviews
GROUP BY path
ORDER BY pageviews DESC;
```

## File Structure

```text
├── db/
│   ├── schema.sql              # Full schema with triggers
│   └── create_tables.sql       # Simple table creation
├── netlify/functions/
│   └── pandalytics.ts          # Analytics endpoint
├── src/
│   ├── components/page/
│   │   └── Analytics.astro     # Client-side tracking
│   └── pages/
│       └── metrics.astro       # Analytics dashboard
└── SETUP.md                    # This file
```

## How It Works

1. **Client-side**: `Analytics.astro` collects Core Web Vitals and session data
2. **API**: Netlify function receives and validates data
3. **Database**: Data stored in separate `sessions` and `pageviews` tables
4. **Dashboard**: `/metrics` page displays analytics with formatted CWV data

## Privacy & Performance

- **No cookies**: Uses localStorage for session management
- **Minimal data**: Only collects essential metrics
- **Deduplication**: Prevents duplicate entries from page refreshes
- **Geographic privacy**: Only stores country codes (via Netlify headers)
- **Performance optimized**: Uses `sendBeacon` API for non-blocking sends

## Troubleshooting

### Common Issues

1. **No data appearing**: Check Netlify function logs and environment variables
2. **Database errors**: Verify Turso connection and table creation
3. **High pageview counts**: Clear localStorage or use private browsing

### Debug Mode

Uncomment debug lines in `netlify/functions/pandalytics.ts` to enable detailed logging:

```typescript
console.log("=== PANDALYTICS REQUEST START ===");
```

## License

MIT License - feel free to modify and use as needed.
