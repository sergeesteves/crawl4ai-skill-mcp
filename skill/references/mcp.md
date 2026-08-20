# Self-hosted Crawl4AI — MCP access

The server exposes an **MCP endpoint** (tool schema at `GET {{CRAWL4AI_URL}}/mcp/schema`, typically
SSE transport under `/mcp`). It is therefore usable by **any MCP client** — Claude Desktop/Code, or
any other compatible assistant.

## Wiring the server as an MCP connector

The procedure depends on the client, but the principle is the same: add a **remote MCP server** with
the server URL and Bearer auth. Check your tool's MCP config; on the server side you provide
`{{CRAWL4AI_URL}}` (MCP endpoint) + the token. Never hard-code the token in a version-controlled file.

## Exposed tools

| Tool | Params | Usage |
|---|---|---|
| `crawl` | `urls[]`, `browser_config`, `crawler_config`, `crawler_configs`, `hooks` | full crawl → CrawlResult JSON (markdown, links, media, extracted_content…) |
| `md` | `url`, `f` (mode), `q` (query), `c` (cache), `provider`, `temperature` | **Markdown** — see modes below |
| `html` | `url` | preprocessed HTML (to build an extraction schema) |
| `screenshot` | `url`, `screenshot_wait_for`, `wait_for_images` | PNG → `artifact_id` + `url` |
| `pdf` | `url` | PDF → `artifact_id` + `url` |
| `execute_js` | `url`, `scripts[]` | runs JS snippets (IIFE/async **that return a value**) → full CrawlResult |
| `ask` | `context_type` (code\|doc\|all), `query`, `score_ratio`, `max_results` | **RAG over the Crawl4AI LIBRARY docs/code** (not over an arbitrary page) |

## `md.f` modes

- `fit` (default): Readability → clean content.
- `raw`: DOM → raw Markdown.
- `bm25`: relevance ranking **BM25 against `q`** → passages relevant to an intent.
- `llm`: LLM summary with `q` (LLM provider required on the server side).

## ⚠️ Don't misuse `ask`

The `ask` tool queries the **Crawl4AI library documentation** (to help an assistant generate
crawl4ai code) — **not** a web page you're crawling. To ask a question *about a page*, crawl it
(`md`/`crawl`) then reason over the result.
