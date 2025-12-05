# Catppuccin Lavender Setup

## 🎨 What's Applied

Your site now features the beautiful **Catppuccin Latte Lavender** color scheme for light mode!

### Color Breakdown

**Light Mode (Catppuccin Latte Lavender)**

```
Primary: #7287fd (Latte Lavender)
RGB:     rgb(114, 135, 253)
HSL:     hsl(231deg, 97%, 72%)
Accent:  #7287fd (Latte Lavender)
Style:   Soft purple-blue, dreamy, elegant
```

**Dark Mode**

```
Primary: Teal
Accent:  Teal
Style:   Modern, balanced
```

## 🌈 About Catppuccin Lavender

From the official [Catppuccin palette](https://catppuccin.com/palette/):

**Lavender** (`#7287fd`) is one of 26 carefully crafted colors in the Latte (light) flavor.

### Why Lavender?

- 💜 **Unique**: Soft purple-blue stands out from typical blues
- ✨ **Elegant**: Sophisticated and modern
- 👀 **Eye-Friendly**: High lightness (72%) is easy to read
- 🎨 **Harmonious**: Blends beautifully with other colors
- 💝 **Popular**: Widely loved in the Catppuccin community

## 📁 Files Modified

```
techdocs/
├── docs/
│   └── stylesheets/
│       └── extra.css          ← Catppuccin Lavender colors
│
└── mkdocs.yml                 ← Added extra_css
```

## 🔍 How It Works

### 1. Custom CSS Override

`docs/stylesheets/extra.css` contains:

```css
[data-md-color-scheme="default"] {
  --md-primary-fg-color: #7287fd; /* Catppuccin Latte Lavender */
  --md-accent-fg-color: #7287fd;
}
```

### 2. MkDocs Configuration

`mkdocs.yml` includes:

```yaml
extra_css:
  - stylesheets/extra.css
```

### 3. Theme Settings

```yaml
palette:
  - media: "(prefers-color-scheme: light)"
    scheme: default
    primary: custom # Uses our Lavender CSS
    accent: custom
```

## 🚀 Preview

```bash
uv run mkdocs serve
```

Visit:

- **English**: http://127.0.0.1:8000/
- **French**: http://127.0.0.1:8000/fr/
- **Toggle**: Use theme switcher in header

## 🎯 Where Colors Appear

The Catppuccin lavender will be visible in:

✅ Navigation header  
✅ Active menu items  
✅ Links throughout content  
✅ Button hover states  
✅ Search highlights  
✅ Code block language labels  
✅ Footnote references  
✅ Table of contents active items  
✅ Tab selections

## 🎨 Full Catppuccin Latte Palette

All available colors from https://catppuccin.com/palette/:

### Cool Colors

| Color        | Hex       | Description                    |
| ------------ | --------- | ------------------------------ |
| **Lavender** | `#7287fd` | **Current** - Soft purple-blue |
| Blue         | `#1e66f5` | Vibrant blue                   |
| Sapphire     | `#209fb5` | Cyan-blue                      |
| Sky          | `#04a5e5` | Bright sky blue                |
| Teal         | `#179299` | Blue-green                     |

### Warm Colors

| Color  | Hex       | Description   |
| ------ | --------- | ------------- |
| Green  | `#40a02b` | Fresh green   |
| Yellow | `#df8e1d` | Warm yellow   |
| Peach  | `#fe640b` | Orange accent |
| Red    | `#d20f39` | Bold red      |
| Maroon | `#e64553` | Deep red      |

### Purple & Pink

| Color     | Hex       | Description |
| --------- | --------- | ----------- |
| Mauve     | `#8839ef` | Rich purple |
| Pink      | `#ea76cb` | Soft pink   |
| Flamingo  | `#dd7878` | Coral pink  |
| Rosewater | `#dc8a78` | Warm rose   |

## 🔧 Try Other Colors

### Option 1: Switch to Mauve (Purple)

Edit `docs/stylesheets/extra.css`:

```css
[data-md-color-scheme="default"] {
  --md-primary-fg-color: #8839ef; /* Mauve */
  --md-accent-fg-color: #8839ef;
}
```

### Option 2: Switch to Sapphire (Cyan)

```css
[data-md-color-scheme="default"] {
  --md-primary-fg-color: #209fb5; /* Sapphire */
  --md-accent-fg-color: #209fb5;
}
```

### Option 3: Switch to Pink

```css
[data-md-color-scheme="default"] {
  --md-primary-fg-color: #ea76cb; /* Pink */
  --md-accent-fg-color: #ea76cb;
}
```

## 🌙 Catppuccin for Dark Mode

Want Catppuccin Mocha (dark) colors too?

Edit `docs/stylesheets/extra.css`:

```css
/* Catppuccin Mocha Lavender for dark mode */
[data-md-color-scheme="slate"] {
  --md-primary-fg-color: #b4befe; /* Mocha Lavender */
  --md-accent-fg-color: #b4befe;
}
```

### Mocha Dark Colors

| Color    | Hex       | Usage            |
| -------- | --------- | ---------------- |
| Lavender | `#b4befe` | Soft purple-blue |
| Blue     | `#89b4fa` | Vibrant blue     |
| Sapphire | `#74c7ec` | Cyan-blue        |
| Sky      | `#89dceb` | Sky blue         |
| Teal     | `#94e2d5` | Blue-green       |
| Mauve    | `#cba6f7` | Purple           |

## 📊 Color Comparison

**Latte (Light) vs Mocha (Dark) Lavender:**

| Flavor | Hex       | RGB                  | HSL                   |
| ------ | --------- | -------------------- | --------------------- |
| Latte  | `#7287fd` | `rgb(114, 135, 253)` | `hsl(231°, 97%, 72%)` |
| Mocha  | `#b4befe` | `rgb(180, 190, 254)` | `hsl(232°, 97%, 85%)` |

The Mocha version is lighter (85% vs 72%) because it's used on a dark background.

## 🔗 Resources

- **Official Palette**: https://catppuccin.com/palette/
- **Main Repo**: https://github.com/catppuccin/catppuccin
- **Style Guide**: https://github.com/catppuccin/catppuccin/blob/main/docs/style-guide.md
- **600+ Ports**: Browse themes for different apps

## ✅ Benefits

Why Catppuccin Latte Lavender?

1. **Official Colors**: Direct from catppuccin.com/palette
2. **Eye-Friendly**: Pastel colors reduce eye strain
3. **Distinctive**: Purple-blue stands out elegantly
4. **Professional**: Sophisticated appearance
5. **Harmonious**: Part of coordinated color system
6. **Community**: Used by thousands of developers worldwide

## 📝 Quick Commands

```bash
# Preview changes
uv run mkdocs serve

# Build site
uv run mkdocs build

# Edit colors
vim docs/stylesheets/extra.css
```

## 🎭 Theme Preview Matrix

| Mode  | Color    | Hex       | Appearance                |
| ----- | -------- | --------- | ------------------------- |
| Light | Lavender | `#7287fd` | Soft purple-blue on white |
| Dark  | Teal     | Built-in  | Green-blue on dark slate  |

---

**Status**: ✅ Catppuccin Latte Lavender active in light mode!

**Official Source**: https://catppuccin.com/palette/ (Latte flavor)
