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
  "crawler_config": { "type": "CrawlerRunConfig", "params": { "cache_mode": "bypass" } }
}
```

Response: `results[0].markdown` / `.cleaned_html` / `.links` / `.extracted_content`.

## When to pick what

- **Ready-made SEO ops** (SEO Metadata, Discover Links, Cosine Similarity) → the **node**.
- **Full control / portability / no node to install** → **HTTP Request**.
