---
name: crawl4ai-selfhost
description: >
  Appeler un serveur Crawl4AI self-hosté (Docker, image unclecode/crawl4ai) pour crawler des pages,
  produire du Markdown/HTML, exécuter du JavaScript, prendre des screenshots/PDF et faire de
  l'extraction structurée — depuis Claude (MCP), n8n, ou en REST/HTTP. À utiliser dès qu'on dispose
  d'un serveur Crawl4AI et qu'on veut l'appeler : endpoints, auth Bearer, format du body {type, params},
  patterns SEO. Pour le SDK Python (AsyncWebCrawler), utiliser plutôt le skill officiel Crawl4AI.
license: MIT
---

# Crawl4AI self-hosté — accès serveur (MCP / n8n / REST)

Ce skill couvre l'**appel d'un serveur Crawl4AI self-hosté** (image `unclecode/crawl4ai`, port par
défaut `11235`). Pour le **SDK Python** (`AsyncWebCrawler`), voir le skill officiel :
<https://docs.crawl4ai.com/>.

## Configuration (fournie par l'utilisateur)

- **Serveur** : `{{CRAWL4AI_URL}}` (ex. `http://localhost:11235`).
- **Auth** (0.9+ = secure-by-default) : `Authorization: Bearer <token>`.
- ⚠️ Ne jamais coder l'URL de prod ni le token en dur — variables d'env (REST/app) ou credential (n8n).

## Les 3 voies d'accès

- **MCP** (tout client MCP, dont Claude) → [`references/mcp.md`](references/mcp.md)
  (tools `crawl` / `md` / `html` / `screenshot` / `pdf` / `execute_js` / `ask` ; modes `md.f` = fit/raw/bm25/llm).
- **n8n** → [`references/n8n.md`](references/n8n.md)
  (nœud `n8n-nodes-crawl4ai-plus`, ou HTTP Request générique).
- **REST** (app / curl) → [`references/rest-api.md`](references/rest-api.md)
  (endpoints + ⚠️ **piège du body `{type, params}`**).

## Patterns SEO

[`references/seo-patterns.md`](references/seo-patterns.md) : Markdown BM25 par requête, SEO metadata,
extraction structurée **sans LLM**, cartographie de site.

## Règles

1. Vérifier la version/les champs exacts du serveur via `GET {{CRAWL4AI_URL}}/schema` (public, sans token).
2. Pour du contenu éditorial → `/md` (mode `fit` ou `bm25`). Pour de l'extraction structurée → `/crawl` + `extraction_strategy`.
3. Ne jamais exposer d'URL de prod ni de secret dans le code ou les logs.
