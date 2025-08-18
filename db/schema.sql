-- New Pandalytics Database Schema
-- Two-table design: sessions and pageviews

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

-- Indexes for performance
CREATE INDEX idx_sessions_site_id ON sessions(site_id);
CREATE INDEX idx_sessions_start_time ON sessions(start_time);
CREATE INDEX idx_sessions_country ON sessions(country_code);

CREATE INDEX idx_pageviews_session_id ON pageviews(session_id);
CREATE INDEX idx_pageviews_timestamp ON pageviews(timestamp);
CREATE INDEX idx_pageviews_path ON pageviews(path);

-- Triggers to update session data
CREATE TRIGGER update_session_on_pageview_insert
AFTER INSERT ON pageviews
BEGIN
  UPDATE sessions 
  SET 
    total_pageviews = (
      SELECT COUNT(*) FROM pageviews WHERE session_id = NEW.session_id
    ),
    is_bounce = CASE 
      WHEN (SELECT COUNT(*) FROM pageviews WHERE session_id = NEW.session_id) > 1 THEN 0 
      ELSE 1 
    END,
    end_time = NEW.timestamp,
    total_duration_ms = NEW.timestamp - (
      SELECT start_time FROM sessions WHERE session_id = NEW.session_id
    ),
    updated_at = strftime('%s', 'now') * 1000
  WHERE session_id = NEW.session_id;
END;

CREATE TRIGGER update_session_on_pageview_update
AFTER UPDATE ON pageviews
BEGIN
  UPDATE sessions 
  SET 
    end_time = (
      SELECT MAX(timestamp + COALESCE(duration_ms, 0)) 
      FROM pageviews 
      WHERE session_id = NEW.session_id
    ),
    total_duration_ms = (
      SELECT MAX(timestamp + COALESCE(duration_ms, 0)) - MIN(timestamp)
      FROM pageviews 
      WHERE session_id = NEW.session_id
    ),
    updated_at = strftime('%s', 'now') * 1000
  WHERE session_id = NEW.session_id;
END;