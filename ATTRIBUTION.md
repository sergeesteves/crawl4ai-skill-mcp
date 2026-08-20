# Attribution

Ce kit documente l'usage d'un serveur **Crawl4AI self-hosté**. Il **ne modifie ni ne redistribue**
le code source de Crawl4AI, et ne re-héberge pas la documentation SDK officielle (il y renvoie).

- **Crawl4AI** — crawler open-source sous **Apache-2.0** :
  <https://github.com/unclecode/crawl4ai> · doc & skill officiel : <https://docs.crawl4ai.com/>
  Le SDK Python (`AsyncWebCrawler`) et la référence SDK sont maintenus par le projet upstream.
- **n8n-nodes-crawl4ai-plus** — nœud communautaire n8n (auteur : msoukhomlinov) :
  <https://github.com/msoukhomlinov/n8n-nodes-crawl4ai-plus>

Les schémas d'endpoints et de tools décrits ici proviennent de la doc publique de Crawl4AI et de
l'introspection d'un serveur self-hosté standard (image `unclecode/crawl4ai`). Vérifie toujours les
champs exacts de **ta** version via `GET {{CRAWL4AI_URL}}/schema` (public, sans token).
