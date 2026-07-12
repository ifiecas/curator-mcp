#!/usr/bin/env python3
"""
Curator MCP Server - Museums Victoria Collections API

Exposes the Museums Victoria collection endpoints as MCP tools over the
streamable-HTTP transport, so it can be served by uvicorn on port 8000 and
consumed by Copilot Studio at  http://<host>:8000/mcp
"""

import json
from typing import Optional

import httpx
from mcp.server.fastmcp import FastMCP

BASE_URL = "https://collections.museumsvictoria.com.au/api"
USER_AGENT = "Curator-MCP-Server/1.0"

# stateless_http=True: no server-side session state, which suits a scale-out
# HTTP deployment (and Copilot Studio's request/response model).
mcp = FastMCP("curator-collections", stateless_http=True, host="0.0.0.0", port=8000)

client = httpx.AsyncClient(headers={"User-Agent": USER_AGENT}, timeout=30.0)


async def call_api(endpoint: str, params: Optional[dict] = None):
    """Make a request to the Museums Victoria API and return parsed JSON."""
    try:
        response = await client.get(f"{BASE_URL}{endpoint}", params=params)
        response.raise_for_status()
        return response.json()
    except httpx.HTTPError as e:
        return {"error": str(e), "endpoint": endpoint}


@mcp.tool()
async def search_collections(
    query: str,
    perpage: int = 5,
    page: int = 1,
    recordtype: Optional[str] = None,
    hasimages: Optional[str] = None,
    category: Optional[str] = None,
) -> str:
    """Search across all Museum Victoria collections. Supports query text,
    filters by type (specimen/item/article/species), images, and category.

    Args:
        query: Search term (e.g., 'dinosaur', 'coin', 'portrait').
        perpage: Results per page (1-100, default 5).
        page: Page number for pagination (default 1).
        recordtype: Filter by type: specimen, item, article, or species.
        hasimages: Filter by image availability: 'yes' or 'no'.
        category: Collection category (e.g., 'Natural Sciences', 'Humanities').
    """
    params: dict = {"query": query, "perpage": min(perpage, 100), "page": page}
    if recordtype:
        params["recordtype"] = recordtype
    if hasimages:
        params["hasimages"] = hasimages
    if category:
        params["category"] = category
    return json.dumps(await call_api("/search", params), indent=2)


@mcp.tool()
async def get_specimen(id: str) -> str:
    """Fetch a single specimen record by ID (format: specimens/XXXXX).
    Returns full details including taxonomy, media, and related items."""
    return json.dumps(await call_api(f"/specimens/{id}"), indent=2)


@mcp.tool()
async def get_item(id: str) -> str:
    """Fetch a single collection item by ID. Returns full details including
    media and acquisition info."""
    return json.dumps(await call_api(f"/items/{id}"), indent=2)


@mcp.tool()
async def get_article(id: str) -> str:
    """Fetch a single article/guide by ID (format: articles/XXXXX).
    Returns full article text and related resources."""
    return json.dumps(await call_api(f"/articles/{id}"), indent=2)


@mcp.tool()
async def list_specimens(perpage: int = 10, page: int = 1) -> str:
    """List all specimens with pagination. Use for browsing the full
    specimens collection.

    Args:
        perpage: Results per page (default 10, max 100).
        page: Page number.
    """
    params = {"perpage": min(perpage, 100), "page": page}
    return json.dumps(await call_api("/specimens", params), indent=2)


@mcp.tool()
async def list_items(perpage: int = 10, page: int = 1) -> str:
    """List all collection items with pagination.

    Args:
        perpage: Results per page (default 10, max 100).
        page: Page number.
    """
    params = {"perpage": min(perpage, 100), "page": page}
    return json.dumps(await call_api("/items", params), indent=2)


@mcp.tool()
async def list_articles(perpage: int = 10, page: int = 1) -> str:
    """List all articles and guides with pagination.

    Args:
        perpage: Results per page (default 10, max 100).
        page: Page number.
    """
    params = {"perpage": min(perpage, 100), "page": page}
    return json.dumps(await call_api("/articles", params), indent=2)


@mcp.tool()
async def list_species(perpage: int = 10, page: int = 1) -> str:
    """List all species records with pagination.

    Args:
        perpage: Results per page (default 10, max 100).
        page: Page number.
    """
    params = {"perpage": min(perpage, 100), "page": page}
    return json.dumps(await call_api("/species", params), indent=2)


# ASGI application served by uvicorn:  uvicorn curator_mcp_server:app
# MCP endpoint is mounted at /mcp
app = mcp.streamable_http_app()


if __name__ == "__main__":
    mcp.run(transport="streamable-http")
