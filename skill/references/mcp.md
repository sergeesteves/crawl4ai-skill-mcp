# Crawl4AI self-hosté — accès MCP

Le serveur expose un **endpoint MCP** (schéma des tools sur `GET {{CRAWL4AI_URL}}/mcp/schema`,
transport SSE typiquement sous `/mcp`). Il est donc utilisable par **tout client MCP** — Claude
Desktop/Code, ou tout autre assistant compatible.

## Brancher le serveur comme connecteur MCP

La procédure dépend du client, mais le principe est le même : ajouter un **serveur MCP distant** avec
l'URL du serveur et l'auth Bearer. Consulte la config MCP de ton outil ; côté serveur, tu fournis
`{{CRAWL4AI_URL}}` (endpoint MCP) + le token. Ne mets jamais le token en dur dans un fichier versionné.

## Tools exposés

| Tool | Params | Usage |
|---|---|---|
| `crawl` | `urls[]`, `browser_config`, `crawler_config`, `crawler_configs`, `hooks` | crawl complet → CrawlResult JSON (markdown, links, media, extracted_content…) |
| `md` | `url`, `f` (mode), `q` (requête), `c` (cache), `provider`, `temperature` | **Markdown** — voir modes ci-dessous |
| `html` | `url` | HTML préprocessé (pour bâtir un schéma d'extraction) |
| `screenshot` | `url`, `screenshot_wait_for`, `wait_for_images` | PNG → `artifact_id` + `url` |
| `pdf` | `url` | PDF → `artifact_id` + `url` |
| `execute_js` | `url`, `scripts[]` | exécute des snippets JS (IIFE/async **qui retournent une valeur**) → CrawlResult complet |
| `ask` | `context_type` (code\|doc\|all), `query`, `score_ratio`, `max_results` | **RAG sur la doc/le code de la LIBRAIRIE Crawl4AI** (pas sur une page arbitraire) |

## Modes de `md.f`

- `fit` (défaut) : Readability → contenu propre.
- `raw` : DOM → Markdown brut.
- `bm25` : classement de pertinence **BM25 selon `q`** → passages pertinents pour une intention.
- `llm` : résumé LLM avec `q` (provider LLM requis côté serveur).

## ⚠️ Ne pas confondre `ask`

Le tool `ask` interroge la **documentation de la librairie Crawl4AI** (pour aider un assistant à
générer du code crawl4ai) — **pas** une page web que tu crawles. Pour poser une question *sur une
page*, crawle-la (`md`/`crawl`) puis raisonne sur le résultat.
