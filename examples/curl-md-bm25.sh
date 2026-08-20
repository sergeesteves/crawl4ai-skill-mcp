#!/usr/bin/env bash
# Markdown of a page, filtered by BM25 relevance against a query.
# Returns the passages most relevant to the given intent (handy for SEO).
#   export CRAWL4AI_URL="http://localhost:11235"
#   export CRAWL4AI_TOKEN="<your-token>"
set -euo pipefail

URL="${1:-https://example.com}"
QUERY="${2:-pricing plans}"

curl -sX POST "$CRAWL4AI_URL/md" \
  -H "Authorization: Bearer $CRAWL4AI_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"url\": \"$URL\", \"f\": \"bm25\", \"q\": \"$QUERY\", \"c\": \"0\"}"
