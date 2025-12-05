# Getting Started with Your Multilingual Docs

## 🎯 Quick Start (30 seconds)

```bash
# Start the development server
uv run mkdocs serve
```

Then open your browser:

- **English**: http://127.0.0.1:8000/
- **French**: http://127.0.0.1:8000/fr/

You'll see a language selector (🌐) in the top-right corner!

## 📁 Project Structure

```
techdocs/
│
├── agents/                          ← YOU ARE HERE
│   ├── README.md                    ← Start here for overview
│   ├── GETTING_STARTED.md           ← This file (quick start)
│   ├── SUMMARY.md                   ← What's been set up
│   ├── MULTILINGUAL_SETUP.md        ← Complete guide (deep dive)
│   └── QUICK_REFERENCE.md           ← Cheat sheet
│
├── docs/                            ← Your content
│   ├── index.md                     ← English homepage
│   ├── index.fr.md                  ← French homepage
│   ├── guides/
│   │   ├── formatting.md            ← English guide
│   │   └── formatting.fr.md         ← French guide
│   └── reference/
│       ├── icons.md                 ← English reference
│       └── icons.fr.md              ← French reference
│
├── site/                            ← Built site (generated)
│   ├── index.html                   ← English pages
│   └── fr/                          ← French pages
│       └── index.html
│
├── mkdocs.yml                       ← Configuration
├── pyproject.toml                   ← Dependencies
└── uv.lock                          ← Lock file

```

## 🎓 Learning Path

Choose your path based on what you need:

### 👉 Path 1: I just want to start writing

1. **Read**: `agents/QUICK_REFERENCE.md`
2. **Do**: Add new content following the examples
3. **Test**: `uv run mkdocs serve`

### 👉 Path 2: I want to understand everything

1. **Read**: `agents/SUMMARY.md` (what's been done)
2. **Read**: `agents/MULTILINGUAL_SETUP.md` (how it works)
3. **Reference**: `agents/QUICK_REFERENCE.md` (day-to-day use)

### 👉 Path 3: I want to customize

1. **Read**: `agents/MULTILINGUAL_SETUP.md` → "Configuration" section
2. **Modify**: `mkdocs.yml` (colors, fonts, features)
3. **Test**: `uv run mkdocs serve`

## 📖 Documentation Guide

### agents/README.md

- **Purpose**: Overview and navigation
- **When to read**: First time, to understand what's available
- **Time**: 2 minutes

### agents/SUMMARY.md

- **Purpose**: What's been configured and why
- **When to read**: Want to see the complete setup
- **Time**: 5 minutes

### agents/MULTILINGUAL_SETUP.md

- **Purpose**: Complete technical guide
- **When to read**: Need to understand the i18n system
- **Topics**: Plugin details, configuration, best practices
- **Time**: 15 minutes

### agents/QUICK_REFERENCE.md

- **Purpose**: Fast lookups and common tasks
- **When to read**: Daily usage, need quick answers
- **Topics**: Commands, patterns, translations
- **Time**: Quick lookup

### agents/GETTING_STARTED.md

- **Purpose**: This file - quick start guide
- **When to read**: Right now!
- **Time**: 3 minutes

## 🚀 Common Tasks

### Task 1: Add a New Page (Both Languages)

```bash
# 1. Create English version
cat > docs/my-topic.md << 'EOL'
# My Topic

This is my new topic in English.
EOL

# 2. Create French version
cat > docs/my-topic.fr.md << 'EOL'
# Mon Sujet

Ceci est mon nouveau sujet en français.
EOL

# 3. Add to navigation (edit mkdocs.yml)
# Under 'nav:', add:
#   - My Topic: my-topic.md

# 4. Add French translation (edit mkdocs.yml)
# Under 'nav_translations:', add:
#   My Topic: Mon Sujet

# 5. Preview
uv run mkdocs serve
```

### Task 2: Customize Colors

Edit `mkdocs.yml`:

```yaml
theme:
  palette:
    - scheme: default
      primary: blue # Change this
      accent: cyan # And this
```

Available colors: red, pink, purple, indigo, blue, cyan, teal, green, lime, yellow, amber, orange, deep orange

### Task 3: Change Site Name

Edit `mkdocs.yml`:

```yaml
site_name: My Amazing Docs # Change this
site_author: Your Name # And this
```

### Task 4: Add More Languages

See `agents/MULTILINGUAL_SETUP.md` → "Adding More Languages" section

## 🔍 Where to Find Things

| I want to...            | Look here                                                |
| ----------------------- | -------------------------------------------------------- |
| Understand the setup    | `agents/SUMMARY.md`                                      |
| Learn how i18n works    | `agents/MULTILINGUAL_SETUP.md`                           |
| Quick command reference | `agents/QUICK_REFERENCE.md`                              |
| Add new content         | `agents/QUICK_REFERENCE.md` → "Adding New Content"       |
| Change colors/fonts     | `mkdocs.yml` → `theme:` section                          |
| Add a new language      | `agents/MULTILINGUAL_SETUP.md` → "Adding More Languages" |
| Fix issues              | `agents/MULTILINGUAL_SETUP.md` → "Troubleshooting"       |

## 💡 Tips

### Tip 1: Test Both Languages

Always check both language versions:

```bash
uv run mkdocs serve
# Visit http://127.0.0.1:8000/     (English)
# Visit http://127.0.0.1:8000/fr/  (French)
```

### Tip 2: Partial Translations Are OK

You don't need to translate everything immediately. If a French translation is missing, the English version will be shown automatically.

### Tip 3: Use Live Reload

Keep `mkdocs serve` running while you edit. Changes appear instantly in your browser!

### Tip 4: Search Works Per Language

Search automatically uses the appropriate language based on which version you're viewing.

## 🎨 Example Customizations

### Change to a Green Theme

```yaml
theme:
  palette:
    - scheme: default
      primary: green
      accent: light green
```

### Enable More Features

```yaml
theme:
  features:
    - navigation.instant # Faster page loads
    - navigation.tracking # Update URL on scroll
    - toc.integrate # Merge TOC with sidebar
```

### Add Social Links

```yaml
extra:
  social:
    - icon: fontawesome/brands/github
      link: https://github.com/yourusername
    - icon: fontawesome/brands/twitter
      link: https://twitter.com/yourusername
```

## ⚡ Commands Cheat Sheet

```bash
# Development
uv run mkdocs serve          # Start dev server with live reload
uv run mkdocs serve -a 0.0.0.0:8000  # Allow external access

# Building
uv run mkdocs build          # Build production site
uv run mkdocs build --clean  # Clean build

# Deployment
uv run mkdocs gh-deploy      # Deploy to GitHub Pages

# Dependencies
uv sync                      # Install/update dependencies
uv add package-name          # Add new package
```

## 🎯 Next Steps

1. ✅ You've started the dev server
2. ✅ You've viewed both English and French versions
3. ⬜ Read `agents/SUMMARY.md` to understand what's configured
4. ⬜ Try adding a new page in both languages
5. ⬜ Customize colors in `mkdocs.yml`
6. ⬜ Deploy your site!

## 📞 Need Help?

- **Understanding i18n**: Read `agents/MULTILINGUAL_SETUP.md`
- **Quick lookups**: Check `agents/QUICK_REFERENCE.md`
- **Plugin docs**: https://github.com/ultrabug/mkdocs-static-i18n
- **Material theme**: https://squidfunk.github.io/mkdocs-material/

---

**Happy documenting! 📝**
