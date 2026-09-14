# Self-hosted Crawl4AI — from n8n

Two options: the **community node** (simplest) or **HTTP Request** (most portable).

## Option A — `n8n-nodes-crawl4ai-plus` node (recommended for most cases)

Repo: <https://github.com/msoukhomlinov/n8n-nodes-crawl4ai-plus> — provides **2 nodes**:

**Crawl4AI Plus** (simple, 4 ops): *Get Page Content*, *Ask Question* (LLM QA over the page),
*Extract Data* (contact / financial / custom — regex or AI), *CSS Extractor*.

**Crawl4AI Plus Advanced** (15 ops, 3 groups):
- **Crawling**: Crawl URL, Crawl Multiple URLs, Stream Crawl, Process Raw HTML, Discover Links.
- **Extraction**: LLM Extractor, CSS Extractor, JSON Extractor, Regex Extractor, Cosine Similarity, **SEO Metadata**.
- **Jobs & Monitoring**: Submit Crawl Job, Submit LLM Job, Get Job Status, Health Check.

**"Crawl4AI API" credential**: *Docker URL* (default `http://crawl4ai:11235`), *Authentication*
(No Auth 0.8.x / **Token** 0.9.0+), *LLM Settings* (OpenAI/Anthropic/Groq/Ollama/LiteLLM).
Param collections: *Browser & Session*, *Crawl Settings*, *Output & Filtering*.

**Upside**: handles the credential, the `{type, params}` wrapping, and offers ready-made ops
(including **SEO Metadata**, *Discover Links*, *Cosine Similarity*). **Downside**: dependency on a
community node to install/maintain.

> Networking: if your n8n and Crawl4AI are on the **same Docker network**, `http://crawl4ai:11235`
> (internal service name) works. Otherwise, use your server's public URL.

## Option B — HTTP Request (portable, no third-party node)

- **Method**: `POST` · **URL**: `{{CRAWL4AI_URL}}/crawl` (or `/md`)
- **Authentication**: *Generic Credential* → **Header Auth**: Name `Authorization`, Value `Bearer <token>`
- **Headers**: `Content-Type: application/json`
- **Body** (raw JSON) — respect the `{type, params}` wrapper:

```json
{
  "urls": ["{{ $json.url }}"],
  "browser_config": { "type": "BrowserConfig", "params": { "text_mode": true } },
  "crawler_config": { "type": "CrawlerRunConfig", "params": { "cache_mode": "bypass" } }
}
```

`browser_config.text_mode` keeps `/crawl` from downloading images and fonts (`/crawl` reads the
BrowserConfig from the body only). Response: `results[0].markdown` / `.cleaned_html` / `.links` /
`.extracted_content`.

## When to pick what

- **Ready-made SEO ops** (SEO Metadata, Discover Links, Cosine Similarity) → the **node**.
- **Full control / portability / no node to install** → **HTTP Request**.

## Two-instance pattern (save the metered proxy)

Behind a per-GB proxy, don't proxy everything. Run **two** Crawl4AI instances and fall back only on a
**real** block:

- **A — no proxy (default).** Every crawl starts here. Cheap.
- **B — proxied (fallback).** Used only when A returns a real block: HTTP `403` / `429` or an anti-bot
  page. **Not** on empty content — an empty body is usually JS rendering, so first **retry A with JS**
  (`browser_config.params.java_script_enabled: true`) before going to B.

Wiring: `HTTP Request → A` → `IF`:
- HTTP `403` / `429` or anti-bot markers → `HTTP Request → B`;
- content too short with no block signal → retry `A` with `java_script_enabled: true`,
  `wait_until: "load"`, `delay_before_return_html: 2` → still short or blocked? → `B`.

On A and B: `max_retries: 0`, and `text_mode` / `avoid_*` / `java_script_enabled` in **`browser_config`**,
with JS **enabled** on B. Keep B's `CRAWL4AI_UPSTREAM_PROXY` set and A's unset (cf.
[`rest-api.md`](rest-api.md) → *Server-side proxy*).
