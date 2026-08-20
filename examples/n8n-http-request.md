# n8n example — HTTP Request node to Crawl4AI

**HTTP Request** node config (without relying on the community node):

| Field | Value |
|---|---|
| Method | `POST` |
| URL | `={{ $env.CRAWL4AI_URL }}/crawl` (or `/md`) |
| Authentication | Generic Credential → **Header Auth**: Name `Authorization`, Value `Bearer <token>` (in the credential) |
| Send Headers | `Content-Type: application/json` |
| Send Body | JSON |

Body (JSON) — respect the `{type, params}` wrapper:

```json
{
  "urls": ["={{ $json.url }}"],
  "crawler_config": { "type": "CrawlerRunConfig", "params": { "cache_mode": "bypass" } }
}
```

Body for `/md` (BM25-filtered markdown):

```json
{ "url": "={{ $json.url }}", "f": "bm25", "q": "={{ $json.intent }}", "c": "0" }
```

Output to map: `{{ $json.results[0].markdown }}`, `.cleaned_html`, `.links`,
`.extracted_content` (if `extraction_strategy`).

> Keep the server URL in a variable (`$env.CRAWL4AI_URL`) and the token in the **credential** — never hard-coded.
