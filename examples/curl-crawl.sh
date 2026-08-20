#!/usr/bin/env bash
# Full crawl of a URL → Markdown + links + media.
# Prerequisites (env vars, NEVER hard-coded here):
#   export CRAWL4AI_URL="http://localhost:11235"
#   export CRAWL4AI_TOKEN="<your-token>"     # server 0.9+ secure-by-default
set -euo pipefail

curl -sX POST "$CRAWL4AI_URL/crawl" \
  -H "Authorization: Bearer $CRAWL4AI_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "urls": ["https://example.com"],
    "browser_config": { "type": "BrowserConfig",    "params": { "headless": true } },
    "crawler_config":  { "type": "CrawlerRunConfig", "params": { "cache_mode": "bypass" } }
  }' | jq '.results[0] | {success, url, markdown: (.markdown|.[0:300]), n_links: (.links|length)}'
