# crawl4ai-skill-mcp

Kit **multi-outils** pour utiliser un serveur **[Crawl4AI](https://github.com/unclecode/crawl4ai)
self-hosté** (Docker) depuis **Claude** (Agent Skill + MCP), **n8n**, ou n'importe quel client
**HTTP/REST**.

Crawl4AI est un crawler open-source (extraction web → Markdown, pages JS, extraction structurée
**sans LLM**). Ce repo **ne réimplémente rien** : il documente **comment appeler ton serveur
Crawl4AI self-hosté** à travers les outils — avec les pièges (auth, format du body) et des patterns
orientés SEO.

## Pourquoi ce repo

Le **skill officiel** et la doc de Crawl4AI couvrent le **SDK Python** (`AsyncWebCrawler`). Il
manquait la **couche d'accès au serveur self-hosté** (l'image `unclecode/crawl4ai` expose une API
REST + un endpoint MCP) — c'est ce que ce kit apporte :

- **3 voies d'accès** documentées : **MCP**, **nœud n8n**, **REST** (avec les schémas réels des tools MCP).
- Les **pièges** : auth `Bearer` (0.9 secure-by-default), et le format du body `/crawl` `{type, params}`.
- Des **patterns SEO** : Markdown BM25 par requête, SEO metadata, extraction structurée sans LLM.
- Un **Agent Skill** installable (`skill/`) — compatible Claude Code/Desktop, Cursor, Windsurf.

## Pour qui

Quiconque héberge Crawl4AI et l'appelle depuis un assistant IA ou une automatisation
(SEO, growth, data engineering).

## Installation

**Agent Skill (Claude Code/Desktop, Cursor, Windsurf…)** — copier le dossier `skill/` dans le dossier
skills de ton outil, par ex. :

```bash
cp -r skill ~/.claude/skills/crawl4ai-selfhost
```

**n8n** — voir [`skill/references/n8n.md`](skill/references/n8n.md) (nœud `n8n-nodes-crawl4ai-plus`
ou HTTP Request).

**REST / curl / app** — voir [`skill/references/rest-api.md`](skill/references/rest-api.md) et
[`examples/`](examples/).

## Configuration (à toi de la fournir)

- `{{CRAWL4AI_URL}}` = l'URL de **ton** serveur (ex. `http://localhost:11235` en local).
- **Auth** : en-tête `Authorization: Bearer <token>` (serveur 0.9+ = secure-by-default).

> ⚠️ Ne mets **jamais** ton URL de prod ni ton token en dur dans ce repo — utilise des variables
> d'environnement (REST/app) ou un credential (n8n).

## SDK Python

Pour l'usage du **SDK Python** (`AsyncWebCrawler`, hors périmètre de ce kit), installe le **skill
officiel Crawl4AI** : <https://docs.crawl4ai.com/> (bouton *Download Skill Package*).

## Crédits & licence

Voir [ATTRIBUTION.md](ATTRIBUTION.md). Crawl4AI est sous Apache-2.0. Ce kit est sous **MIT**.
