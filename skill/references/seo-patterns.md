# Patterns SEO avec Crawl4AI

Cas d'usage courants pour un expert SEO / growth, et l'endpoint/tool à utiliser.

## Contenu propre d'une page → `md` mode `fit`

Markdown lisible (Readability), sans nav/pub/footer. Idéal pour analyser un article concurrent.

## Extraire *le passage pertinent* pour une intention → `md` mode `bm25` + `q`

Donne une URL + une requête `q` ; le serveur renvoie les passages **classés par pertinence BM25**.
Parfait pour « qu'est-ce que cette page dit sur \<intention\> ? » sans ramener toute la page.

## Métadonnées SEO d'une page → op *SEO Metadata* (nœud n8n) ou extraction

Le nœud `crawl4ai-plus` (Advanced) a une op **SEO Metadata** dédiée. En REST/MCP, extrais title,
meta description, canonical, Open Graph, h1… via `extraction_strategy` (schéma CSS) sur `/crawl`.

## Extraction structurée **sans LLM** → `extraction_strategy` (JsonCssExtractionStrategy)

1. `POST /html` sur une page type pour obtenir le HTML préprocessé.
2. Construire un **schéma CSS** (sélecteurs → champs).
3. `POST /crawl` avec `crawler_config.params.extraction_strategy` = ce schéma → `extracted_content`.

Déterministe, reproductible, gratuit (pas d'appel LLM) — top pour SERP maison, listes produits, prix.

## Cartographier un site / concurrent → *Discover Links* / crawl multi-URL

`crawl` avec plusieurs `urls`, ou l'op *Discover Links* (nœud) pour récupérer le maillage interne
et les liens sortants (avec scoring si activé).

## Rendu / preuve → `screenshot` / `pdf`

Capture d'écran pleine page ou PDF (archivage, audit visuel, avant/après).

## Pages JS / interactions → `execute_js`

Exécute des snippets JS (scroll, clics, lecture du DOM dynamique) puis renvoie le CrawlResult.

## Combiner avec d'autres outils

- **Clustering de mots-clés / GSC** : Crawl4AI fournit le contenu ; un service de clustering décide
  des piliers/pages (voir ta stack SEO).
- **DataForSEO** : SERP/volumes en complément de ce que Crawl4AI extrait des pages.
