# SEO patterns with Crawl4AI

Common use cases for an SEO / growth expert, and the endpoint/tool to use.

## Clean page content → `md` mode `fit`

Readable Markdown (Readability), no nav/ads/footer. Ideal for analyzing a competitor article.

## Extract *the relevant passage* for an intent → `md` mode `bm25` + `q`

Give a URL + a query `q`; the server returns the passages **ranked by BM25 relevance**. Perfect for
"what does this page say about \<intent\>?" without pulling in the whole page.

## Keep image references + alt → `md` mode `raw` (with care)

`fit` (the `/md` default) strips images; **`raw` preserves `![alt](url)`** (alt text + URL) at no extra
bandwidth. But `raw` also drags in boilerplate (nav/menu/footer, 2–6× more links, `data:image/svg`
menu icons), so it's risky when the output is **truncated or fed straight to an LLM** — the nav at the
top eats the budget. Use it only when you actually need the image refs, and **clean it first**; or
prefer **`/crawl`** (structured `media.images` + a clean markdown) if you just need to know the page
uses visuals. See [`mcp.md`](mcp.md) → `md.f` modes.

## Page SEO metadata → *SEO Metadata* op (n8n node) or extraction

The `crawl4ai-plus` node (Advanced) has a dedicated **SEO Metadata** op. In REST/MCP, extract title,
meta description, canonical, Open Graph, h1… via `extraction_strategy` (CSS schema) on `/crawl`.

## Structured extraction **without an LLM** → `extraction_strategy` (JsonCssExtractionStrategy)

1. `POST /html` on a sample page to get the preprocessed HTML.
2. Build a **CSS schema** (selectors → fields).
3. `POST /crawl` with `crawler_config.params.extraction_strategy` = that schema → `extracted_content`.

Deterministic, reproducible, free (no LLM call) — great for homemade SERPs, product listings, prices.

## Map a site / competitor → *Discover Links* / multi-URL crawl

`crawl` with several `urls`, or the *Discover Links* op (node) to retrieve the internal link graph
and outbound links (with scoring if enabled).

## Rendering / proof → `screenshot` / `pdf`

Full-page screenshot or PDF (archiving, visual audit, before/after).

## JS pages / interactions → `execute_js`

Run JS snippets (scroll, clicks, reading the dynamic DOM) then return the CrawlResult.

## Combining with other tools

- **Keyword clustering / GSC**: Crawl4AI provides the content; a clustering service decides the
  pillars/pages (see your SEO stack).
- **DataForSEO**: SERP/volumes to complement what Crawl4AI extracts from pages.
