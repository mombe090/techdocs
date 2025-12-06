# TechDocs

Personal technical documentation built with [MkDocs Material](https://squidfunk.github.io/mkdocs-material/) and organized using the [Diátaxis framework](https://diataxis.fr/).

## Features

- 📚 **Structured Documentation** - Organized into Tutorials, How-to Guides, Reference, and Explanation
- 🌍 **Bilingual** - Full English and French support
- 🎨 **Catppuccin Theme** - Beautiful light and dark modes using Catppuccin colors
- 🔍 **Advanced Search** - Full-text search with syntax highlighting
- 📱 **Responsive Design** - Works perfectly on mobile and desktop
- 🚀 **Fast** - Optimized for performance with minification
- 🐳 **Deployable** - Ready for Cloudflare Workers, GitHub Pages, or any static host

## Current Topics

### Apache Kafka

Comprehensive guides covering Apache Kafka fundamentals and advanced concepts:

- **Tutorial**: Getting Started with Kafka
- **How-to Guides**:
  - Produce Messages to Kafka
  - Consume Messages from Kafka
  - Connect External Systems with Kafka Connect
  - Use Schema Registry for Data Governance
  - Build Stream Processing Applications

All with production-ready Docker Compose configurations and multi-language examples (Java, Python, Node.js, Go).

## Quick Start

### Prerequisites

- Python 3.11+ (3.13+ recommended)
- [uv](https://docs.astral.sh/uv/) (will be auto-installed by build script)
- Git

### Local Development

1. **Clone the repository:**

   ```bash
   git clone https://github.com/mombe090/techdocs.git
   cd techdocs
   ```

2. **Install dependencies:**

   ```bash
   uv sync
   ```

3. **Serve locally:**

   ```bash
   uv run mkdocs serve
   ```

   Open http://127.0.0.1:8000 in your browser.

4. **Build for production:**

   ```bash
   uv run mkdocs build
   ```

## Deployment

### Cloudflare Workers (Recommended)

Deploy your documentation to Cloudflare Workers for global edge performance.

1. **Install Wrangler CLI:**

   ```bash
   npm install -g wrangler
   ```

2. **Login to Cloudflare:**

   ```bash
   wrangler login
   ```

3. **Configure `wrangler.toml`:**

   Edit `name` and optionally `route` for custom domain:

   ```toml
   name = "techdocs"
   compatibility_date = "2024-12-05"

   # Optional: Custom domain
   # route = { pattern = "docs.yourdomain.com/*", zone_name = "yourdomain.com" }

   [build]
   command = "./scripts/cloudflare.worker.sh full"

   [assets]
   directory = "site"
   ```

4. **Deploy:**

   ```bash
   wrangler deploy
   ```

Your site will be live at `https://techdocs.yourusername.workers.dev`

### GitHub Pages

1. **Enable GitHub Pages** in repository settings (Settings → Pages)

2. **Create `.github/workflows/deploy.yml`:**

   ```yaml
   name: Deploy Documentation

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

         - name: Install uv
           run: curl -LsSf https://astral.sh/uv/install.sh | sh

         - name: Install dependencies
           run: uv sync

         - name: Build site
           run: uv run mkdocs build

         - name: Deploy to GitHub Pages
           uses: peaceiris/actions-gh-pages@v4
           with:
             github_token: ${{ secrets.GITHUB_TOKEN }}
             publish_dir: ./site
   ```

3. **Push to GitHub:**

   ```bash
   git push origin main
   ```

Your site will be live at `https://yourusername.github.io/techdocs`

### Other Platforms

The built `site/` directory is static HTML and can be hosted anywhere:

- **Netlify**: Drag and drop `site/` folder
- **Vercel**: Connect repository and set build command to `mkdocs build`
- **AWS S3 + CloudFront**: Upload `site/` to S3 bucket
- **Any static host**: Upload `site/` folder

## Project Structure

```
techdocs/
├── docs/                   # Documentation content
│   ├── tutorials/         # Learning-oriented guides
│   ├── how-to/           # Goal-oriented guides
│   ├── reference/        # Technical specifications
│   ├── explanation/      # Conceptual documentation
│   └── stylesheets/      # Custom CSS
├── scripts/              # Build and deployment scripts
│   ├── cloudflare.worker.sh   # Cloudflare Workers build script
│   └── README.md              # Scripts documentation
├── .github/              # GitHub workflows (if using)
├── mkdocs.yml           # MkDocs configuration
├── wrangler.toml        # Cloudflare Workers configuration
├── pyproject.toml       # Python dependencies
├── uv.lock              # Locked dependencies
└── README.md            # This file
```

## Documentation Guidelines

We follow the [Diátaxis framework](https://diataxis.fr/) for documentation organization:

### Tutorials (`docs/tutorials/`)

- **Purpose**: Learning by doing
- **Audience**: Beginners
- **Style**: Step-by-step, prescriptive
- **Example**: "Getting Started with Kafka"

### How-to Guides (`docs/how-to/`)

- **Purpose**: Solve specific problems
- **Audience**: Users with basic knowledge
- **Style**: Goal-oriented, practical
- **Example**: "How to Configure Kafka Producers"

### Reference (`docs/reference/`)

- **Purpose**: Technical information
- **Audience**: Practitioners needing precise details
- **Style**: Factual, comprehensive
- **Example**: "Kafka Configuration Parameters"

### Explanation (`docs/explanation/`)

- **Purpose**: Understanding concepts
- **Audience**: Users wanting deeper knowledge
- **Style**: Discursive, theoretical
- **Example**: "Understanding Event Streaming Architecture"

## Contributing

### Adding New Documentation

1. **Determine the quadrant** (Tutorial, How-to, Reference, or Explanation)

2. **Create English and French files:**

   ```bash
   # English
   docs/how-to/my-new-guide.md

   # French
   docs/how-to/my-new-guide.fr.md
   ```

3. **Update `mkdocs.yml` navigation:**

   ```yaml
   nav:
     - How-to:
         - My New Guide: how-to/my-new-guide.md
   ```

4. **Follow MkDocs Material features:**
   - Use admonitions (`!!! tip`, `!!! warning`, etc.)
   - Add code annotations for explanations
   - Use linked tabs for multi-language examples
   - Add Mermaid diagrams for architecture
   - **NEVER hardcode colors in Mermaid diagrams** (see AGENTS.md)

5. **Test locally:**

   ```bash
   uv run mkdocs serve
   ```

6. **Commit with conventional commits:**

   ```bash
   git add docs/ mkdocs.yml
   git commit -m "feat: add guide for XYZ feature"
   git push origin main
   ```

### Pre-commit Hooks

All commits must pass validation:

```bash
# Install hooks
pre-commit install

# Run manually
pre-commit run --all-files
```

Hooks include:

- ✅ Trailing whitespace checks
- ✅ YAML/JSON validation
- ✅ EditorConfig compliance
- ✅ Markdown linting
- ✅ Prettier formatting
- ✅ Conventional commits validation

## Development Tools

### Build Scripts

Use the Cloudflare Workers build script for consistent builds:

```bash
# Full build (install + build)
./scripts/cloudflare.worker.sh full

# Install dependencies only
./scripts/cloudflare.worker.sh install

# Build site only
./scripts/cloudflare.worker.sh build

# Clean artifacts
./scripts/cloudflare.worker.sh clean

# Show help
./scripts/cloudflare.worker.sh help
```

See [scripts/README.md](scripts/README.md) for detailed documentation.

### MkDocs Commands

```bash
# Serve with live reload
uv run mkdocs serve

# Build static site
uv run mkdocs build

# Build with strict mode (fail on warnings)
uv run mkdocs build --strict

# Clean build artifacts
rm -rf site/
```

## Customization

### Theme Colors

Colors are customized using Catppuccin Mocha palette in `docs/stylesheets/extra.css`.

To change colors, edit CSS variables:

```css
:root {
  --md-primary-fg-color: #89b4fa; /* Sapphire */
  --md-accent-fg-color: #f38ba8; /* Red */
}
```

See [Catppuccin palette](https://github.com/catppuccin/catppuccin#-palette) for color reference.

### Navigation

Edit `mkdocs.yml` to customize navigation structure:

```yaml
nav:
  - Home: index.md
  - Tutorials:
      - Getting Started: tutorials/getting-started.md
  - How-to:
      - My Guide: how-to/my-guide.md
```

### Features

Enable/disable features in `mkdocs.yml`:

```yaml
theme:
  features:
    - navigation.tabs # Top-level tabs
    - navigation.sections # Sections in sidebar
    - content.code.copy # Copy button in code blocks
    - search.highlight # Highlight search results
```

See [MkDocs Material features](https://squidfunk.github.io/mkdocs-material/setup/setting-up-navigation/) for all options.

## License

This project is open source. Feel free to use it as a template for your own documentation.

## Resources

- [Diátaxis Framework](https://diataxis.fr/) - Documentation structure
- [MkDocs Material](https://squidfunk.github.io/mkdocs-material/) - Theme documentation
- [Catppuccin](https://github.com/catppuccin/catppuccin) - Color palette
- [Cloudflare Workers](https://developers.cloudflare.com/workers/) - Deployment platform
- [uv Package Manager](https://docs.astral.sh/uv/) - Fast Python package installer
- [AGENTS.md](AGENTS.md) - AI collaboration context

## Support

For questions or issues:

1. Check [scripts/README.md](scripts/README.md) for deployment troubleshooting
2. See [AGENTS.md](AGENTS.md) for documentation guidelines
3. Open an issue on GitHub

---

**Built with ❤️ using MkDocs Material and Diátaxis**
