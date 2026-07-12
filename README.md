# Curator — Museums Victoria Collections MCP Server

> An MCP server that turns the Museums Victoria Collections API (1.15M+ records) into natural-language discovery tools for MCP clients such as Copilot Studio.

![Status](https://img.shields.io/badge/status-production-green)
![Python](https://img.shields.io/badge/python-3.11+-blue)
![License](https://img.shields.io/badge/license-MIT-blue)

## Overview

**Curator** is a [Model Context Protocol](https://modelcontextprotocol.io) server exposing the
[Museums Victoria Collections API](https://collections.museumsvictoria.com.au/) as a set of tools. It
lets an AI agent search and explore specimens, items, articles, and species across the museum's
Natural Sciences and Humanities collections — with taxonomy, images, provenance, and dates.

It runs as a streamable-HTTP MCP service (built with `FastMCP`) and is served over HTTPS on Azure
Container Apps.

### Tools

| Tool | Purpose |
|------|---------|
| `search_collections` | Full-text search with type/image/category filters |
| `get_specimen` / `get_item` / `get_article` | Fetch a single record by ID |
| `list_specimens` / `list_items` / `list_articles` / `list_species` | Paginated browse |

## Architecture

```
GitHub Actions ──build & push──▶ Azure Container Registry ──pull (managed identity)──▶ Azure Container Apps
                                        (ABAC mode)                                    (HTTPS, scale-to-zero)
```

- **Server:** `curator_mcp_server.py` — FastMCP streamable-HTTP app, MCP endpoint at `/mcp` on port 8000.
- **CI/CD:** `.github/workflows/deploy-azure.yml` — builds the image, pushes to ACR with the workflow
  service principal's AAD token, and deploys to Container Apps. No registry passwords in the pipeline.
- **Auth:** the container app pulls images via a user-assigned managed identity; the ACR admin user is
  disabled. Because the registry runs in ABAC mode, the ABAC-native *Container Registry Repository
  Reader/Writer* roles are used (not the classic `AcrPull`/`AcrPush`).
- **IaC:** `infra/terraform/` — the whole Azure stack as Terraform (see its README).

## Local development

```bash
python -m venv venv && source venv/bin/activate
pip install -r requirements.txt

# Run the MCP server on http://localhost:8000/mcp
python curator_mcp_server.py
```

Or with Docker:

```bash
docker compose up --build   # serves on http://localhost:8000/mcp
```

## Deployment

Deployment is automated: pushing to `main` runs the GitHub Actions workflow, which builds the image
and rolls the Container App to the new build. The workflow needs one repository secret,
`AZURE_CREDENTIALS` (a service principal with Contributor on the resource group).

To provision the underlying infrastructure declaratively, use the Terraform in `infra/terraform/`.

## Data source & acknowledgement

This project is built on the **[Museums Victoria Collections API](https://collections.museumsvictoria.com.au/developers)**
(`https://collections.museumsvictoria.com.au/api`) and would not exist without it. All collection
data — specimens, items, articles, and species — is provided by Museums Victoria. Huge thanks to
Museums Victoria for making this data openly available.

Please note when using the data:

- **Licensing is per-record.** Individual records carry their own licence (commonly
  [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/), Public Domain Mark, or
  [CC0](https://creativecommons.org/publicdomain/zero/1.0/)) — check each record's `licence` and
  `rightsStatement` fields and attribute accordingly.
- **A `User-Agent` header is required** on every API request; this server sends one.
- **Some records contain culturally sensitive content.** Handle Aboriginal and Torres Strait
  Islander cultural material with appropriate respect.

This project is not affiliated with or endorsed by Museums Victoria.

## License

MIT — see the note above; the museum **data** is licensed per-record by Museums Victoria and is not
covered by this repository's licence.
