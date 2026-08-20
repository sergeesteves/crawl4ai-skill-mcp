# Exemple n8n — nœud HTTP Request vers Crawl4AI

Config du nœud **HTTP Request** (sans dépendre du nœud communautaire) :

| Champ | Valeur |
|---|---|
| Method | `POST` |
| URL | `={{ $env.CRAWL4AI_URL }}/crawl` (ou `/md`) |
| Authentication | Generic Credential → **Header Auth** : Name `Authorization`, Value `Bearer <token>` (dans le credential) |
| Send Headers | `Content-Type: application/json` |
| Send Body | JSON |

Body (JSON) — respecter le wrapper `{type, params}` :

```json
{
  "urls": ["={{ $json.url }}"],
  "crawler_config": { "type": "CrawlerRunConfig", "params": { "cache_mode": "bypass" } }
}
```

Body pour `/md` (markdown filtré BM25) :

```json
{ "url": "={{ $json.url }}", "f": "bm25", "q": "={{ $json.intent }}", "c": "0" }
```

Sortie à mapper : `{{ $json.results[0].markdown }}`, `.cleaned_html`, `.links`,
`.extracted_content` (si `extraction_strategy`).

> Garde l'URL du serveur en variable (`$env.CRAWL4AI_URL`) et le token dans le **credential** — jamais en dur.
