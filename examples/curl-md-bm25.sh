#!/usr/bin/env bash
# Markdown d'une page, filtré par pertinence BM25 sur une requête.
# Renvoie les passages les plus pertinents pour l'intention donnée (pratique SEO).
#   export CRAWL4AI_URL="http://localhost:11235"
#   export CRAWL4AI_TOKEN="<ton-token>"
set -euo pipefail

URL="${1:-https://example.com}"
QUERY="${2:-pricing plans}"

curl -sX POST "$CRAWL4AI_URL/md" \
  -H "Authorization: Bearer $CRAWL4AI_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"url\": \"$URL\", \"f\": \"bm25\", \"q\": \"$QUERY\", \"c\": \"0\"}"
