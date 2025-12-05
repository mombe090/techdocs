# Agents Directory

This directory contains documentation about the setup and configuration of this documentation site.

## Contents

### 📚 [MULTILINGUAL_SETUP.md](./MULTILINGUAL_SETUP.md)

**Complete guide to the multilingual configuration**

Detailed documentation covering:

- How the i18n plugin works
- File structure and naming conventions
- Configuration walkthrough
- Adding new languages
- Search functionality
- Troubleshooting tips
- Best practices

**Read this for**: Understanding the complete multilingual implementation

---

### ⚡ [QUICK_REFERENCE.md](./QUICK_REFERENCE.md)

**Quick reference guide**

Fast lookup for:

- File naming patterns
- Common commands
- Directory structure
- Adding new content workflow
- Navigation translation examples
- Supported locales
- URL patterns

**Read this for**: Day-to-day operations and quick lookups

---

## Summary

This documentation site supports **English** and **French** using the `mkdocs-static-i18n` plugin with Material for MkDocs.

### Key Features

✅ **Automatic Language Selector** - Appears in site header  
✅ **URL-based Language Switching** - `/` for English, `/fr/` for French  
✅ **Translated Navigation** - Menu items auto-translate  
✅ **Multilingual Search** - Search works in all languages  
✅ **Fallback Support** - Shows English if translation missing  
✅ **Material Theme Integration** - Seamless integration with Material for MkDocs

### Quick Start

```bash
# View the site locally
uv run mkdocs serve

# English version
open http://127.0.0.1:8000/

# French version
open http://127.0.0.1:8000/fr/
```

### File Pattern

```
docs/
├── page.md      # English (default)
└── page.fr.md   # French translation
```

### More Information

- **Full Documentation**: See [MULTILINGUAL_SETUP.md](./MULTILINGUAL_SETUP.md)
- **Quick Reference**: See [QUICK_REFERENCE.md](./QUICK_REFERENCE.md)
- **mkdocs-static-i18n**: https://github.com/ultrabug/mkdocs-static-i18n
- **Material for MkDocs**: https://squidfunk.github.io/mkdocs-material/
