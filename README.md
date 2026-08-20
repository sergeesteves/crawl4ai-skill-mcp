# crawl4ai-skill-mcp

**Multi-tool** kit for using a **self-hosted [Crawl4AI](https://github.com/unclecode/crawl4ai)
server** (Docker) from **Claude** (Agent Skill + MCP), **n8n**, or any **HTTP/REST** client.

Crawl4AI is an open-source crawler (web extraction → Markdown, JS pages, structured extraction
**without an LLM**). This repo **reimplements nothing**: it documents **how to call your self-hosted
Crawl4AI server** through those tools — including the gotchas (auth, body format) and SEO-oriented
patterns.

## Why this repo

The **official skill** and Crawl4AI docs cover the **Python SDK** (`AsyncWebCrawler`). What was
missing is the **access layer for the self-hosted server** (the `unclecode/crawl4ai` image exposes a
REST API + an MCP endpoint) — that's what this kit provides:

- **3 access paths** documented: **MCP**, **n8n node**, **REST** (with the real MCP tool schemas).
- The **gotchas**: `Bearer` auth (0.9 secure-by-default), and the `/crawl` body format `{type, params}`.
- **SEO patterns**: BM25 Markdown per query, SEO metadata, structured extraction without an LLM.
- An installable **Agent Skill** (`skill/`) — compatible with Claude Code/Desktop, Cursor, Windsurf.

## Who it's for

Anyone hosting Crawl4AI and calling it from an AI assistant or an automation
(SEO, growth, data engineering).

## Installation

**Agent Skill (Claude Code/Desktop, Cursor, Windsurf…)** — copy the `skill/` folder into your tool's
skills directory, e.g.:

```bash
cp -r skill ~/.claude/skills/crawl4ai-selfhost
```

**n8n** — see [`skill/references/n8n.md`](skill/references/n8n.md) (`n8n-nodes-crawl4ai-plus` node
or HTTP Request).

**REST / curl / app** — see [`skill/references/rest-api.md`](skill/references/rest-api.md) and
[`examples/`](examples/).

## Configuration (you provide it)

- `{{CRAWL4AI_URL}}` = the URL of **your** server (e.g. `http://localhost:11235` locally).
- **Auth**: `Authorization: Bearer <token>` header (server 0.9+ = secure-by-default).

> ⚠️ **Never** hard-code your production URL or token in this repo — use environment
> variables (REST/app) or a credential (n8n).

## Python SDK

For **Python SDK** usage (`AsyncWebCrawler`, out of scope for this kit), install the **official
Crawl4AI skill**: <https://docs.crawl4ai.com/> (*Download Skill Package* button).

## Credits & license

See [ATTRIBUTION.md](ATTRIBUTION.md). Crawl4AI is licensed under Apache-2.0. This kit is licensed
under **MIT**.
