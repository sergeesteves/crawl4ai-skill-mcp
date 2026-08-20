# Crawl4AI self-hosté — API REST

Serveur : image `unclecode/crawl4ai`, port par défaut `11235`. Base : `{{CRAWL4AI_URL}}`.

## Authentification

- **0.9.0 = secure-by-default** : token requis → en-tête `Authorization: Bearer <token>`.
- Si `security.jwt_enabled: true` (dans `config.yml`) : `POST /token` (`{ "email": "..." }`) → JWT, puis Bearer.
- 0.8.x : sécurité off par défaut (pas de token). **Vérifie ta config.**

## Endpoints

| Méthode | Path | Body | Renvoie |
|---|---|---|---|
| POST | `/crawl` | cf. § body | `{ "results": [...] }` (markdown, cleaned_html, links, media, screenshot, pdf, extracted_content…) |
| POST | `/crawl/stream` | idem `/crawl` | NDJSON streamé (1 résultat par ligne) |
| POST | `/md` | `{ "url", "f"?, "q"?, "c"? }` | Markdown seul (voir modes ci-dessous) |
| POST | `/html` | `{ "url" }` | HTML préprocessé (pour bâtir un schéma d'extraction) |
| POST | `/screenshot` | `{ "url", "screenshot_wait_for"?, "output_path"? }` | PNG (base64 ou id d'artefact en 0.9) |
| POST | `/pdf` | `{ "url", "output_path"? }` | PDF |
| POST | `/execute_js` | `{ "url", "scripts": ["return document.title", ...] }` | CrawlResult complet + retours JS |
| GET | `/health` | — | `{ "status": "healthy", "version": "..." }` (public) |
| GET | `/schema` | — | schéma complet de l'API (public) |
| GET | `/metrics` | — | métriques Prometheus |
| GET | `/mcp/schema` | — | schéma des tools MCP (le serveur expose aussi MCP) |

## ⚠️ Piège du body `/crawl` : le wrapper `{ type, params }`

`browser_config` / `crawler_config` **ne sont pas des dicts plats** (forme sérialisée `Config.dump()`),
et les **enums passent en string** :

```json
{
  "urls": ["https://example.com"],
  "browser_config": { "type": "BrowserConfig",    "params": { "headless": true } },
  "crawler_config":  { "type": "CrawlerRunConfig", "params": { "cache_mode": "bypass", "screenshot": false } }
}
```

## `/md` — modes (`f`)

- `fit` (défaut) : extraction *Readability* → contenu propre.
- `raw` : DOM → Markdown brut.
- `bm25` : **classement de pertinence BM25 par rapport à `q`** → ne garde que les passages pertinents.
- `llm` : résumé LLM avec `q` (nécessite un provider LLM configuré côté serveur).

`c` = mode de cache (`"0"` par défaut).

## Champs `crawler_config.params` fréquents

`cache_mode` (`"bypass"|"enabled"|"disabled"`), `css_selector`, `excluded_tags`,
`word_count_threshold`, `wait_for`, `page_timeout`, `js_code`, `scan_full_page`,
`remove_consent_popups`, `extraction_strategy` (ex. `JsonCssExtractionStrategy` → extraction **sans
LLM**), `screenshot`, `pdf`, `check_robots_txt`, `exclude_external_links`.

## curl

```bash
curl -sX POST "$CRAWL4AI_URL/crawl" \
  -H "Authorization: Bearer $CRAWL4AI_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"urls":["https://example.com"],
       "crawler_config":{"type":"CrawlerRunConfig","params":{"cache_mode":"bypass"}}}'
```

## Vérifier ta version (sans token)

`GET {{CRAWL4AI_URL}}/health` (→ version) et `GET {{CRAWL4AI_URL}}/schema` (→ champs exacts de ta
version) sont publics — cale toujours ton body dessus plutôt que sur la doc générique.
