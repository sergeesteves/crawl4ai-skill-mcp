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

- `fit` (default): Readability → clean content. ⚠️ strips most images (the `![alt](url)` refs are dropped).
- `raw`: DOM → raw Markdown. ✅ keeps `![alt](url)` image refs (alt + URL); `bm25` keeps them too. ⚠️ but `raw` is **noisy** — see the warning below.
- `bm25`: relevance ranking **BM25 against `q`** → passages relevant to an intent.
- `llm`: LLM summary with `q` (LLM provider required on the server side).

> 💡 Images & bandwidth — **`/md` only**: on `/md`, `raw` vs `fit` changes only the text output, not
> network usage. `/md` runs under the **server config** (`text_mode: true`), so images aren't downloaded
> here regardless of `f` — `raw` keeps `![alt](url)` at no bandwidth cost. ⚠️ **NOT true of `/crawl`**,
> which uses only the request body: without `browser_config.text_mode`, `/crawl` downloads images and
> fonts. See `rest-api.md` → *Images: /md vs /crawl* and *Bandwidth levers*.
>
> ⚠️ **`raw` is noisy.** Real tests (2 FR pages, `/md`) showed `raw` returns **2–6× more links**
> (nav/menu/related/footer), **~3× more boilerplate** (cookie/menu/legal), **+40–80% text**, and many
> of its images are `data:image/svg` **menu icons** (decoration, not content). Since the DOM leads with
> header/nav, this junk eats the **top** of a truncated LLM window and can push the real content out of
> range. **For editorial extraction, `fit` is usually the better default.** Use `raw` only when you
> specifically need image refs — then clean it first (drop cookie/nav/footer lines and
> `![...](data:image/svg...)`). For just the "page uses visuals" signal without the noise, prefer
> `/crawl`, which exposes `media.images` structured **plus** a clean markdown.

## ⚠️ Don't misuse `ask`

The `ask` tool queries the **Crawl4AI library documentation** (to help an assistant generate
crawl4ai code) — **not** a web page you're crawling. To ask a question *about a page*, crawl it
(`md`/`crawl`) then reason over the result.
