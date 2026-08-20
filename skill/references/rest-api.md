# Self-hosted Crawl4AI — REST API

Server: `unclecode/crawl4ai` image, default port `11235`. Base: `{{CRAWL4AI_URL}}`.

## Authentication

- **0.9.0 = secure-by-default**: token required → `Authorization: Bearer <token>` header.
- If `security.jwt_enabled: true` (in `config.yml`): `POST /token` (`{ "email": "..." }`) → JWT, then Bearer.
- 0.8.x: security off by default (no token). **Check your config.**

## Endpoints

| Method | Path | Body | Returns |
|---|---|---|---|
| POST | `/crawl` | see § body | `{ "results": [...] }` (markdown, cleaned_html, links, media, screenshot, pdf, extracted_content…) |
| POST | `/crawl/stream` | same as `/crawl` | streamed NDJSON (1 result per line) |
| POST | `/md` | `{ "url", "f"?, "q"?, "c"? }` | Markdown only (see modes below) |
| POST | `/html` | `{ "url" }` | preprocessed HTML (to build an extraction schema) |
| POST | `/screenshot` | `{ "url", "screenshot_wait_for"?, "output_path"? }` | PNG (base64 or artifact id in 0.9) |
| POST | `/pdf` | `{ "url", "output_path"? }` | PDF |
| POST | `/execute_js` | `{ "url", "scripts": ["return document.title", ...] }` | full CrawlResult + JS return values |
| GET | `/health` | — | `{ "status": "healthy", "version": "..." }` (public) |
| GET | `/schema` | — | full API schema (public) |
| GET | `/metrics` | — | Prometheus metrics |
| GET | `/mcp/schema` | — | MCP tool schema (the server also exposes MCP) |

## ⚠️ The `/crawl` body gotcha: the `{ type, params }` wrapper

`browser_config` / `crawler_config` **are not flat dicts** (serialized `Config.dump()` form),
and **enums are passed as strings**:

```json
{
  "urls": ["https://example.com"],
  "browser_config": { "type": "BrowserConfig",    "params": { "headless": true } },
  "crawler_config":  { "type": "CrawlerRunConfig", "params": { "cache_mode": "bypass", "screenshot": false } }
}
```

## `/md` — modes (`f`)

- `fit` (default): *Readability* extraction → clean content.
- `raw`: DOM → raw Markdown.
- `bm25`: **BM25 relevance ranking against `q`** → keeps only the relevant passages.
- `llm`: LLM summary with `q` (requires an LLM provider configured on the server side).

`c` = cache mode (`"0"` by default).

## Common `crawler_config.params` fields

`cache_mode` (`"bypass"|"enabled"|"disabled"`), `css_selector`, `excluded_tags`,
`word_count_threshold`, `wait_for`, `page_timeout`, `js_code`, `scan_full_page`,
`remove_consent_popups`, `extraction_strategy` (e.g. `JsonCssExtractionStrategy` → extraction
**without an LLM**), `screenshot`, `pdf`, `check_robots_txt`, `exclude_external_links`.

## curl

```bash
curl -sX POST "$CRAWL4AI_URL/crawl" \
  -H "Authorization: Bearer $CRAWL4AI_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"urls":["https://example.com"],
       "crawler_config":{"type":"CrawlerRunConfig","params":{"cache_mode":"bypass"}}}'
```

## Check your version (no token)

`GET {{CRAWL4AI_URL}}/health` (→ version) and `GET {{CRAWL4AI_URL}}/schema` (→ exact fields for your
version) are public — always base your body on those rather than on the generic docs.
