---
name: crawl4ai-selfhost
description: >
  Call a self-hosted Crawl4AI server (Docker, unclecode/crawl4ai image) to crawl pages, produce
  Markdown/HTML, run JavaScript, take screenshots/PDFs and do structured extraction — from Claude
  (MCP), n8n, or over REST/HTTP. Use whenever you have a Crawl4AI server and want to call it:
  endpoints, Bearer auth, the {type, params} body format, SEO patterns. For the Python SDK
  (AsyncWebCrawler), use the official Crawl4AI skill instead.
license: MIT
---

# Self-hosted Crawl4AI — server access (MCP / n8n / REST)

This skill covers **calling a self-hosted Crawl4AI server** (`unclecode/crawl4ai` image, default port
`11235`). For the **Python SDK** (`AsyncWebCrawler`), see the official skill:
<https://docs.crawl4ai.com/>.

## Configuration (provided by the user)

- **Server**: `{{CRAWL4AI_URL}}` (e.g. `http://localhost:11235`).
- **Auth** (0.9+ = secure-by-default): `Authorization: Bearer <token>`.
- ⚠️ Never hard-code the production URL or token — env vars (REST/app) or a credential (n8n).

## The 3 access paths

- **MCP** (any MCP client, including Claude) → [`references/mcp.md`](references/mcp.md)
  (tools `crawl` / `md` / `html` / `screenshot` / `pdf` / `execute_js` / `ask`; `md.f` modes = fit/raw/bm25/llm).
- **n8n** → [`references/n8n.md`](references/n8n.md)
  (`n8n-nodes-crawl4ai-plus` node, or generic HTTP Request).
- **REST** (app / curl) → [`references/rest-api.md`](references/rest-api.md)
  (endpoints + ⚠️ **the `{type, params}` body gotcha**).

## SEO patterns

[`references/seo-patterns.md`](references/seo-patterns.md): BM25 Markdown per query, SEO metadata,
structured extraction **without an LLM**, site mapping.

## Rules

1. Check the server version / exact fields via `GET {{CRAWL4AI_URL}}/schema` (public, no token).
2. For editorial content → `/md` (`fit` or `bm25` mode). For structured extraction → `/crawl` + `extraction_strategy`.
3. Never expose a production URL or any secret in code or logs.
