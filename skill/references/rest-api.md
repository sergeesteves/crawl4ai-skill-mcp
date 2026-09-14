# Self-hosted Crawl4AI — REST API

Server: `unclecode/crawl4ai` image, default port `11235`. Base: `{{CRAWL4AI_URL}}`.

## Authentication

- **0.9.0 = secure-by-default**: token required → `Authorization: Bearer <token>` header.
- If `security.jwt_enabled: true` (in `config.yml`): `POST /token` (`{ "email": "..." }`) → JWT, then Bearer.
- 0.8.x: security off by default (no token). **Check your config.**

## Server-side proxy (authenticated upstream, image ≥ 0.9.3)

> 💸 **Cost warning — a per-GB proxy is billed on EVERYTHING the browser fetches.** Once the server has
> an upstream proxy, **100% of browser egress** goes through it: not just the target page but every
> third-party tracker it loads (Clarity, HubSpot, analytics…) and every sub-resource. A 1 GB/month plan
> can burn out in days. Scope the proxy tightly (below), cut bandwidth (next section), and prefer running
> **without** it by default — see the two-instance pattern in [`n8n.md`](n8n.md).

**Prefer `CRAWL4AI_UPSTREAM_PROXY`** over `HTTP_PROXY` / `HTTPS_PROXY`:

- `CRAWL4AI_UPSTREAM_PROXY = http://user:pass@host:port` — read **first**, and scoped to the **browser
  egress only**. The server's internal egress proxy injects the Basic auth itself (not Chromium). Scheme
  must be `http://`.
- `HTTP_PROXY` / `HTTPS_PROXY` are read by **every library in the container** (health checks, model
  pulls…), so they push far more traffic through the paid proxy. Use only if `CRAWL4AI_UPSTREAM_PROXY`
  is unavailable.
- A per-request override (`browser_config.proxy_config`) is **rejected** (`untrusted request`) — the
  proxy is a server-side setting only.

**`NO_PROXY`** matches by **domain suffix** (subdomains included) or **IP/CIDR** — *not* regex. Put your
own domains **and the third-party trackers** you don't want billed:
`NO_PROXY=localhost,127.0.0.1,::1,yourdomain.com,clarity.ms,hubspot.com`.

> ⚠️ **Hostname vs IP (anti-rebinding)**: the egress sends `CONNECT <pinned IP>` to the proxy, **never
> the hostname**. Proxy providers that require a hostname in `CONNECT` refuse the request — this is what
> gets accounts flagged for "requests without a hostname". Tested production workaround: a derived image
> that rewrites the two upstream-path lines of `egress_proxy.py` from `_bracket(pin.ip)` to
> `_bracket(pin.host)` (`sed` as `USER root`, then back to `USER appuser`), with a build-time test that
> **fails the build** if those lines change upstream. A feature request is open on crawl4ai.

> ⚠️ **DNS gotcha (frequent false lead)**: the container must be able to **resolve the proxy hostname**.
> If host DNS (e.g. `systemd-resolved`) can't resolve it, every crawl fails with
> `ERR_TUNNEL_CONNECTION_FAILED` (and `curl: (5) Could not resolve proxy` when tested on the server).
> Fix: give the container a working resolver (`--dns=1.1.1.1 --dns=8.8.8.8`), **not** a local no-auth
> forward proxy (auth is already handled internally).

## Bandwidth levers (behind a metered proxy)

> ⚠️ **The API silently drops a field placed in the wrong config class** (`UNTRUSTED_FIELD_ALLOWLIST`) —
> no error, no warning. A bandwidth lever put in the wrong object simply does nothing. Put each field in
> the **right** class (`browser_config` vs `crawler_config`) and confirm it took effect.

**`browser_config.params`** (per browser):
- `text_mode: true` — blocks images, fonts and media (biggest saver). **Does NOT block JS.**
- `light_mode: true`, `avoid_ads: true` (fixed blocklist — does **not** include HubSpot), `avoid_css`,
  `java_script_enabled`.

**`crawler_config.params`** (per crawl):
- `cache_mode: "enabled"` — set it **explicitly** to reuse cached fetches.
- `wait_until: "domcontentloaded"` — stop at the DOM; `"load"` waits for **every** resource (more bytes).
- `page_timeout` — capped at **60 s** server-side.
- `max_retries` — default `0`; **any value > 0 reloads the page** (re-spends bandwidth).

> ⚠️ **`java_script_enabled: false`** is cheap but **JS-rendered pages come back empty**. Never treat
> "empty content" as "blocked" — retry with JS before concluding a block.

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

## Images: `/md` vs `/crawl` (bandwidth)

- **`/md`** uses the **server config** (`config.yml: text_mode: true`) → **no images downloaded**. The
  `f` mode (fit/raw/bm25) changes only the **returned markdown**, never the bandwidth.
- **`/crawl`** uses **only the request body** → without `browser_config.params.text_mode: true`, it
  **downloads images and fonts**. Add `text_mode` to the body to keep `/crawl` light.

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
