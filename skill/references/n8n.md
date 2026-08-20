# Crawl4AI self-hosté — depuis n8n

Deux options : le **nœud communautaire** (le plus simple) ou **HTTP Request** (le plus portable).

## Option A — nœud `n8n-nodes-crawl4ai-plus` (recommandé pour la plupart des cas)

Repo : <https://github.com/msoukhomlinov/n8n-nodes-crawl4ai-plus> — fournit **2 nœuds** :

**Crawl4AI Plus** (simple, 4 ops) : *Get Page Content*, *Ask Question* (QA LLM sur la page),
*Extract Data* (contact / financier / custom — regex ou IA), *CSS Extractor*.

**Crawl4AI Plus Advanced** (15 ops, 3 groupes) :
- **Crawling** : Crawl URL, Crawl Multiple URLs, Stream Crawl, Process Raw HTML, Discover Links.
- **Extraction** : LLM Extractor, CSS Extractor, JSON Extractor, Regex Extractor, Cosine Similarity, **SEO Metadata**.
- **Jobs & Monitoring** : Submit Crawl Job, Submit LLM Job, Get Job Status, Health Check.

**Credential « Crawl4AI API »** : *Docker URL* (déf `http://crawl4ai:11235`), *Authentication*
(No Auth 0.8.x / **Token** 0.9.0+), *LLM Settings* (OpenAI/Anthropic/Groq/Ollama/LiteLLM).
Collections de params : *Browser & Session*, *Crawl Settings*, *Output & Filtering*.

**Avantage** : gère le credential, le wrapping `{type, params}`, et offre des ops prêtes (dont
**SEO Metadata**, *Discover Links*, *Cosine Similarity*). **Inconvénient** : dépendance à un nœud
communautaire à installer/maintenir.

> Réseau : si ton n8n et Crawl4AI sont sur le **même réseau Docker**, `http://crawl4ai:11235` (nom de
> service interne) fonctionne. Sinon, mets l'URL publique de ton serveur.

## Option B — HTTP Request (portable, sans nœud tiers)

- **Method** : `POST` · **URL** : `{{CRAWL4AI_URL}}/crawl` (ou `/md`)
- **Authentication** : *Generic Credential* → **Header Auth** : Name `Authorization`, Value `Bearer <token>`
- **Headers** : `Content-Type: application/json`
- **Body** (JSON raw) — respecter le wrapper `{type, params}` :

```json
{
  "urls": ["{{ $json.url }}"],
  "crawler_config": { "type": "CrawlerRunConfig", "params": { "cache_mode": "bypass" } }
}
```

Réponse : `results[0].markdown` / `.cleaned_html` / `.links` / `.extracted_content`.

## Quand choisir quoi

- **Ops SEO prêtes** (SEO Metadata, Discover Links, Cosine Similarity) → le **nœud**.
- **Contrôle total / portabilité / pas de nœud à installer** → **HTTP Request**.
