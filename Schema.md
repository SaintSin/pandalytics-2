CREATE TABLE metrics (
id INTEGER PRIMARY KEY AUTOINCREMENT,
session_id TEXT NOT NULL,
site_id TEXT NOT NULL,
url TEXT NOT NULL,
path TEXT NOT NULL,
referrer TEXT,
country_code TEXT,
screen_width INTEGER,
screen_height INTEGER,
user_agent TEXT,
lcp REAL,
cls REAL,
fid REAL,
fcp REAL,
ttfb REAL,
inp REAL,
duration_ms INTEGER,
bounce INTEGER, -- 1 = bounce, 0 = not bounce
pageviews_in_session INTEGER,
ts INTEGER NOT NULL -- epoch ms
);
