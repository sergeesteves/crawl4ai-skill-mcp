# Attribution

This kit documents how to use a **self-hosted Crawl4AI server**. It **neither modifies nor
redistributes** the Crawl4AI source code, and does not re-host the official SDK documentation (it
links to it).

- **Crawl4AI** — open-source crawler under **Apache-2.0**:
  <https://github.com/unclecode/crawl4ai> · docs & official skill: <https://docs.crawl4ai.com/>
  The Python SDK (`AsyncWebCrawler`) and the SDK reference are maintained by the upstream project.
- **n8n-nodes-crawl4ai-plus** — community n8n node (author: msoukhomlinov):
  <https://github.com/msoukhomlinov/n8n-nodes-crawl4ai-plus>

The endpoint and tool schemas described here come from Crawl4AI's public documentation and from
introspecting a standard self-hosted server (`unclecode/crawl4ai` image). Always verify the exact
fields for **your** version via `GET {{CRAWL4AI_URL}}/schema` (public, no token).
