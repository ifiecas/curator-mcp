FROM python:3.11-slim

WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy MCP server code
COPY curator_mcp_server.py .

# Expose port for MCP communication
EXPOSE 8000

# Run the MCP server (streamable-HTTP ASGI app, endpoint at /mcp)
CMD ["python", "-m", "uvicorn", "curator_mcp_server:app", "--host", "0.0.0.0", "--port", "8000"]
