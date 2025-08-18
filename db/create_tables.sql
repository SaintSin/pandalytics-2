-- Just create the new tables first
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

CREATE TABLE pageviews (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  session_id TEXT NOT NULL,
  url TEXT NOT NULL,
  path TEXT,
  referrer TEXT,
  timestamp INTEGER NOT NULL,
  duration_ms INTEGER DEFAULT 0,
  lcp INTEGER,
  cls INTEGER,
  fid INTEGER,
  fcp INTEGER,
  ttfb INTEGER,
  inp INTEGER,
  created_at INTEGER DEFAULT (strftime('%s', 'now') * 1000),
  FOREIGN KEY (session_id) REFERENCES sessions(session_id)
);

CREATE INDEX idx_sessions_site_id ON sessions(site_id);
CREATE INDEX idx_sessions_start_time ON sessions(start_time);
CREATE INDEX idx_pageviews_session_id ON pageviews(session_id);
CREATE INDEX idx_pageviews_timestamp ON pageviews(timestamp);