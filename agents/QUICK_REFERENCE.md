# Quick Reference: Multilingual Support

## File Naming Convention

| Language | File Name Pattern | Example |
|----------|------------------|---------|
| English (default) | `filename.md` | `index.md` |
| French | `filename.fr.md` | `index.fr.md` |
| Spanish | `filename.es.md` | `index.es.md` |
| German | `filename.de.md` | `index.de.md` |

## Commands

```bash
# Install dependencies
uv sync

# Serve with live reload (all languages)
uv run mkdocs serve

# Build production site
uv run mkdocs build

# Test English version
open http://127.0.0.1:8000/

# Test French version
open http://127.0.0.1:8000/fr/
```

## Directory Structure

```
techdocs/
├── docs/                    # Documentation source
│   ├── index.md            # English homepage
│   ├── index.fr.md         # French homepage
│   ├── guides/
│   │   ├── formatting.md
│   │   └── formatting.fr.md
│   └── reference/
│       ├── icons.md
│       └── icons.fr.md
├── site/                   # Built site (generated)
│   ├── index.html         # English site
│   └── fr/
│       └── index.html     # French site
├── agents/                # Documentation about setup
│   └── MULTILINGUAL_SETUP.md
├── mkdocs.yml            # Configuration
└── pyproject.toml        # Dependencies
```

## Adding New Content

### 1. Create English Page
```bash
echo "# New Feature" > docs/features/new-feature.md
```

### 2. Create French Translation
```bash
echo "# Nouvelle Fonctionnalité" > docs/features/new-feature.fr.md
```

### 3. Add to Navigation (mkdocs.yml)
```yaml
nav:
  - Features:
    - New Feature: features/new-feature.md
```

### 4. Add French Translation for Nav
```yaml
plugins:
  - i18n:
      languages:
        - locale: fr
          nav_translations:
            Features: Fonctionnalités
            New Feature: Nouvelle Fonctionnalité
```

## Key Configuration (mkdocs.yml)

```yaml
plugins:
  - search:
      # ... search config
  - i18n:
      docs_structure: suffix
      fallback_to_default: true
      reconfigure_material: true
      reconfigure_search: true
      languages:
        - locale: en
          default: true
          name: English
          build: true
        - locale: fr
          name: Français
          build: true
          nav_translations:
            # Navigation translations here
```

## Translation Checklist

When adding a new page:

- [ ] Create English version: `page.md`
- [ ] Create French version: `page.fr.md`
- [ ] Add to `nav` section in `mkdocs.yml`
- [ ] Add French nav translation to `nav_translations`
- [ ] Test with `uv run mkdocs serve`
- [ ] Check both `/` and `/fr/` URLs

## Common Navigation Translations

| English | French (Français) |
|---------|------------------|
| Home | Accueil |
| Getting Started | Démarrage |
| Guides | Guides |
| Tutorials | Tutoriels |
| Reference | Référence |
| API | API |
| Examples | Exemples |
| Installation | Installation |
| Configuration | Configuration |
| Deployment | Déploiement |
| Troubleshooting | Dépannage |
| FAQ | FAQ |
| Contributing | Contribuer |
| Changelog | Journal des modifications |
| License | Licence |

## Supported Locales

Common locale codes:
- `en` - English
- `fr` - French (Français)
- `es` - Spanish (Español)
- `de` - German (Deutsch)
- `it` - Italian (Italiano)
- `pt` - Portuguese (Português)
- `ja` - Japanese (日本語)
- `zh` - Chinese (中文)
- `ru` - Russian (Русский)
- `ar` - Arabic (العربية)

## URL Structure

| Language | URL Pattern | Example |
|----------|-------------|---------|
| English (default) | `/path/` | `https://site.com/guides/formatting/` |
| French | `/fr/path/` | `https://site.com/fr/guides/formatting/` |
| Spanish | `/es/path/` | `https://site.com/es/guides/formatting/` |

## Tips

### Partial Translations
You don't need to translate everything at once. With `fallback_to_default: true`, missing translations will show the English version.

### Translation Status
Add this to pages being translated:

```markdown
!!! info "Translation Status"
    🇫🇷 This page is fully translated.
    
# or

!!! warning "Traduction en Cours"
    Cette page est en cours de traduction.
```

### Testing
Always test both language versions:
```bash
# Start dev server
uv run mkdocs serve

# Open in browser
# English: http://127.0.0.1:8000/
# French:  http://127.0.0.1:8000/fr/
```

### Search
Search automatically works in all languages when you visit that language's pages. French search uses French, English search uses English.
