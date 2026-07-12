# Contributing to Curator

Thanks for your interest in contributing! Here's how to get started.

## Development Setup

1. **Fork & clone:**
```bash
git clone https://github.com/YOUR_USERNAME/curator-mcp.git
cd curator-mcp
```

2. **Create virtual environment:**
```bash
python -m venv venv
source venv/bin/activate  # or: venv\Scripts\activate (Windows)
```

3. **Install dev dependencies:**
```bash
pip install -r requirements.txt
pip install pytest pytest-asyncio flake8
```

4. **Create feature branch:**
```bash
git checkout -b feature/your-feature-name
```

## Code Style

- Follow PEP 8
- Max line length: 120 characters
- Use type hints where possible
- Add docstrings to functions

Run linting:
```bash
flake8 curator_mcp_server.py
```

## Testing

```bash
# Test locally
python curator_mcp_server.py

# Test in Docker
docker-compose up
curl http://localhost:8000/tools/search_collections -d '{"query":"dinosaur"}'

# Run tests (when test suite is added)
pytest
```

## Adding New Tools

1. Add new endpoint in `curator_mcp_server.py`
2. Create async handler function
3. Register tool in `TOOLS` list
4. Add to `handle_tool_call()` dispatcher
5. Test locally
6. Submit PR

Example:
```python
Tool(
    name="my_new_tool",
    description="Does something useful",
    inputSchema={...}
)

@server.call_tool()
async def handle_tool_call(name: str, arguments: dict):
    if name == "my_new_tool":
        # Your logic here
        return ToolResult(...)
```

## Submitting Changes

1. **Make your changes**
2. **Test locally:**
```bash
docker-compose up
# Test your changes
```

3. **Commit with clear message:**
```bash
git commit -m "feat: add new discovery tool" 
```

4. **Push to your fork:**
```bash
git push origin feature/your-feature-name
```

5. **Open a Pull Request** with:
   - Clear title and description
   - Link to any related issues
   - Screenshots/examples if applicable

## Commit Message Format

```
type(scope): short description

Longer explanation if needed. Explain what and why,
not how.

Fixes #123
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

## Reporting Issues

- **Bug:** Use "Bug Report" template
- **Feature:** Use "Feature Request" template
- **Question:** Use "Question" template

Include:
- Clear description
- Steps to reproduce (for bugs)
- Expected vs actual behavior
- Environment (OS, Python version, etc.)

## Pull Request Process

1. Update README.md with new features
2. Update DEPLOYMENT.md if infrastructure changes
3. Ensure GitHub Actions passes (test workflow)
4. Request review from maintainers
5. Make requested changes
6. Squash commits before merge

## Code of Conduct

- Be respectful
- Welcome diverse perspectives
- Focus on the code, not the person
- Report harassment to maintainers

## Questions?

- Check existing issues/PRs
- Open a GitHub Discussion
- DM the maintainer

Thanks for contributing! 🚀
