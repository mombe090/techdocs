# Multilingual Setup Documentation

## Overview

This documentation site now supports **French (Français)** and **English** using the `mkdocs-static-i18n` plugin. Users can switch between languages using a language selector in the site header.

## How It Works

### Plugin: mkdocs-static-i18n

The `mkdocs-static-i18n` plugin enables multilingual support in MkDocs by:

1. **Building separate language versions** of your documentation
2. **Creating language-specific URLs** (e.g., `/fr/` for French)
3. **Adding a language selector** to the Material theme
4. **Translating navigation items** automatically

### File Structure

The plugin uses a **suffix-based structure** where translations are stored in files with language codes:

```
docs/
├── index.md           # English version (default)
├── index.fr.md        # French version
├── guides/
│   ├── formatting.md     # English
│   └── formatting.fr.md  # French
└── reference/
    ├── icons.md          # English
    └── icons.fr.md       # French
```

## Configuration

### 1. Dependencies Added

In `pyproject.toml`:

```toml
dependencies = [
    # ... other dependencies
    "mkdocs-static-i18n>=1.2",
]
```

### 2. Plugin Configuration

In `mkdocs.yml`:

```yaml
plugins:
  - search:
      separator: '[\s\u200b\-_,:!=\[\]()"`/]+|\.(?!\d)|&[lg]t;|(?!\b)(?=[A-Z][a-z])'
  - i18n:
      docs_structure: suffix          # Use .fr.md, .es.md suffix pattern
      fallback_to_default: true       # Fall back to English if translation missing
      reconfigure_material: true      # Integrate with Material theme
      reconfigure_search: true        # Enable multilingual search
      languages:
        - locale: en
          default: true               # English is default language
          name: English
          build: true
        - locale: fr
          name: Français
          build: true
          nav_translations:           # Translate navigation items
            Home: Accueil
            Guides: Guides
            Formatting: Formatage
            Reference: Référence
            Icons & Emojis: Icônes & Emojis
```

### Key Configuration Options

- **`docs_structure: suffix`**: Files are named like `page.fr.md` for French
- **`fallback_to_default: true`**: If a translation is missing, show English version
- **`reconfigure_material: true`**: Adds language selector to Material theme
- **`reconfigure_search: true`**: Makes search work in all languages
- **`nav_translations`**: Translates navigation menu items for each language

## How to Add Content in Multiple Languages

### Method 1: Create Language-Specific Files

1. **Create English version** (default):
   ```bash
   echo "# My Page" > docs/my-page.md
   ```

2. **Create French version**:
   ```bash
   echo "# Ma Page" > docs/my-page.fr.md
   ```

3. **Add to navigation** in `mkdocs.yml`:
   ```yaml
   nav:
     - My Page: my-page.md
   ```

4. **Add French translation** to nav_translations:
   ```yaml
   nav_translations:
     My Page: Ma Page
   ```

### Method 2: Organize by Sections

For larger sites, organize content by section:

```
docs/
├── index.md
├── index.fr.md
├── getting-started/
│   ├── installation.md
│   ├── installation.fr.md
│   ├── configuration.md
│   └── configuration.fr.md
└── tutorials/
    ├── basic.md
    ├── basic.fr.md
    ├── advanced.md
    └── advanced.fr.md
```

## Building and Serving

### Development (with live reload)

```bash
uv run mkdocs serve
```

This will:
- Serve English at: `http://127.0.0.1:8000/`
- Serve French at: `http://127.0.0.1:8000/fr/`

### Production Build

```bash
uv run mkdocs build
```

Output structure:
```
site/
├── index.html              # English homepage
├── guides/
│   └── formatting/
│       └── index.html      # English guide
├── fr/
│   ├── index.html          # French homepage
│   └── guides/
│       └── formatting/
│           └── index.html  # French guide
└── ...
```

## Adding More Languages

To add Spanish support:

1. **Update mkdocs.yml**:
   ```yaml
   languages:
     - locale: en
       default: true
       name: English
       build: true
     - locale: fr
       name: Français
       build: true
       nav_translations:
         # French translations...
     - locale: es
       name: Español
       build: true
       nav_translations:
         Home: Inicio
         Guides: Guías
         # ... more translations
   ```

2. **Create Spanish content**:
   ```bash
   # Create Spanish versions
   docs/index.es.md
   docs/guides/formatting.es.md
   docs/reference/icons.es.md
   ```

## Language Selector UI

The language selector appears in the site header (top right) when using Material theme with `reconfigure_material: true`. It shows:

- 🌐 Language icon
- Current language name
- Dropdown with all available languages

## Search in Multiple Languages

With `reconfigure_search: true`, the search plugin automatically:

1. **Indexes content in all languages** separately
2. **Shows results in the current language** only
3. **Uses language-specific tokenization** for better search results

French search uses French stop words and stemming algorithms.

## Best Practices

### 1. Consistency

- **Always translate navigation items** in `nav_translations`
- **Keep the same file structure** for all languages
- **Use consistent naming**: `page.md` → `page.fr.md` → `page.es.md`

### 2. Fallback Strategy

- Set `fallback_to_default: true` to show English if translation missing
- This allows partial translations while building content

### 3. Content Management

- **Mark incomplete translations** with admonitions:
  ```markdown
  !!! warning "Translation in Progress"
      This page is being translated. Some content may still be in English.
  ```

### 4. Testing

- **Test all language versions** before deploying:
  ```bash
  uv run mkdocs build
  # Check site/index.html (English)
  # Check site/fr/index.html (French)
  ```

## Troubleshooting

### Language selector not appearing

- Ensure `reconfigure_material: true` is set
- Check that you have more than one language with `build: true`

### Navigation not translating

- Verify `nav_translations` matches exact navigation keys
- Navigation keys are case-sensitive

### Search not working in French

- Ensure `reconfigure_search: true` is enabled
- The search plugin must be listed BEFORE the i18n plugin

### Missing translations

- Check file naming: must be `filename.LOCALE.md` (e.g., `page.fr.md`)
- Verify `docs_structure: suffix` is set correctly

## Resources

- [mkdocs-static-i18n Documentation](https://github.com/ultrabug/mkdocs-static-i18n)
- [Material for MkDocs Language Support](https://squidfunk.github.io/mkdocs-material/setup/changing-the-language/)
- [MkDocs Documentation](https://www.mkdocs.org/)

## Summary

Your site now supports:
- ✅ English (default language)
- ✅ French (Français)
- ✅ Automatic language selector in header
- ✅ Translated navigation menus
- ✅ Multilingual search
- ✅ Fallback to English for missing translations
- ✅ Clean URL structure (`/` for English, `/fr/` for French)

To preview: `uv run mkdocs serve`
- English: http://127.0.0.1:8000/
- French: http://127.0.0.1:8000/fr/
