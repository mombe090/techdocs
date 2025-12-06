# Build Scripts

This directory contains build and deployment scripts for the TechDocs project.

## Scripts

### `cloudflare.worker.sh`

Bash script for building and deploying the MkDocs site to Cloudflare Workers.

**Usage:**

```bash
# Full build (install dependencies + build site)
./scripts/cloudflare.worker.sh full

# Install dependencies only
./scripts/cloudflare.worker.sh install

# Build site only
./scripts/cloudflare.worker.sh build

# Clean build artifacts
./scripts/cloudflare.worker.sh clean

# Show help
./scripts/cloudflare.worker.sh help
```

**Features:**

- ✅ Automatic `uv` installation if not present
- ✅ Python version checking (3.11+ required)
- ✅ System dependency installation (Cairo, Pillow for image optimization)
- ✅ Fast dependency installation with `uv` or fallback to `pip`
- ✅ Clean build with `--strict` mode
- ✅ Colored output for better readability
- ✅ Cross-platform support (Linux, macOS, Windows via Git Bash)

**Environment Variables:**

- `SKIP_SYSTEM_DEPS=1` - Skip system dependency installation (useful for CI/CD)

**Requirements:**

- Python 3.11+ (3.13+ recommended)
- `curl` (for installing `uv`)
- `git` (optional)

## Cloudflare Workers Deployment

### Setup

1. **Install Wrangler CLI:**

   ```bash
   npm install -g wrangler
   ```

2. **Login to Cloudflare:**

   ```bash
   wrangler login
   ```

3. **Configure `wrangler.toml`:**

   Edit the `wrangler.toml` file in the project root:

   ```toml
   name = "techdocs"
   compatibility_date = "2024-12-05"

   [build]
   command = "./scripts/cloudflare.worker.sh full"

   [assets]
   directory = "site"
   ```

### Deploy

```bash
# Deploy to Cloudflare Workers
wrangler deploy

# Or with custom environment
wrangler deploy --env production
```

### Custom Domain

To use a custom domain, uncomment and configure the `route` in `wrangler.toml`:

```toml
route = { pattern = "docs.yourdomain.com/*", zone_name = "yourdomain.com" }
```

## Local Development

For local development, use MkDocs directly:

```bash
# Install dependencies
uv sync

# Serve locally (with hot reload)
uv run mkdocs serve

# Build locally
uv run mkdocs build
```

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Deploy to Cloudflare Workers

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Python
        uses: actions/setup-python@v5
        with:
          python-version: "3.13"

      - name: Build site
        run: |
          chmod +x scripts/cloudflare.worker.sh
          SKIP_SYSTEM_DEPS=1 ./scripts/cloudflare.worker.sh full

      - name: Deploy to Cloudflare Workers
        uses: cloudflare/wrangler-action@v3
        with:
          apiToken: ${{ secrets.CLOUDFLARE_API_TOKEN }}
```

## Troubleshooting

### Build Fails with Python Version Error

Ensure Python 3.11+ is installed:

```bash
python3 --version
```

If not, install from [python.org](https://www.python.org/downloads/).

### `uv` Installation Fails

Install manually:

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

Or use pip:

```bash
pip install uv
```

### System Dependencies Missing

Install manually:

**Ubuntu/Debian:**

```bash
sudo apt-get install libcairo2-dev pkg-config python3-dev libjpeg-dev zlib1g-dev
```

**macOS:**

```bash
brew install cairo pkg-config
```

### Build Output Not Found

Ensure you're running from the project root where `mkdocs.yml` exists:

```bash
cd /path/to/techdocs
./scripts/cloudflare.worker.sh full
```

## References

- [Cloudflare Workers Documentation](https://developers.cloudflare.com/workers/)
- [Cloudflare Pages Documentation](https://developers.cloudflare.com/pages/)
- [Wrangler CLI Documentation](https://developers.cloudflare.com/workers/wrangler/)
- [MkDocs Material Documentation](https://squidfunk.github.io/mkdocs-material/)
- [uv Package Manager](https://docs.astral.sh/uv/)
