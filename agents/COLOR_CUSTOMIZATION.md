# Color Customization Applied

## Current Color Scheme

Your site now uses **Catppuccin Latte Lavender** for light mode and **Teal** for dark mode!

### Configuration

**Light Mode - Catppuccin Latte Lavender:**

```css
--md-primary-fg-color: #7287fd; /* Catppuccin Latte Lavender */
--md-accent-fg-color: #7287fd; /* Catppuccin Latte Lavender */
```

**Dark Mode - Teal:**

```yaml
primary: teal
accent: teal
```

## What Changed

### Light Mode

- **Primary color**: Catppuccin Latte Lavender (`#7287fd`)
- **Accent color**: Catppuccin Latte Lavender (`#7287fd`)
- **RGB**: `rgb(114, 135, 253)`
- **HSL**: `hsl(231deg, 97%, 72%)`
- **Style**: Soft purple-blue, dreamy and elegant

### Dark Mode

- **Primary color**: Teal
- **Accent color**: Teal
- **Style**: Modern, balanced

## About Catppuccin Lavender

From the official [Catppuccin Latte palette](https://catppuccin.com/palette/):

**Lavender** is one of the 26 eye-candy colors in the Latte (light) flavor. It provides:

- ✅ Soft purple-blue hue
- ✅ High visibility without being harsh
- ✅ Elegant and modern appearance
- ✅ Perfect for creative/artistic documentation
- ✅ Part of the soothing Catppuccin palette

## Preview

Run to see the changes:

```bash
uv run mkdocs serve
```

Toggle between light and dark modes using the theme switcher to see:

- **Light mode**: Beautiful Catppuccin Latte Lavender
- **Dark mode**: Modern Teal

The lavender will be visible in:

- Navigation header
- Active menu items
- All links throughout content
- Button hover states
- Search highlights
- Code block language labels
- Table of contents active items

## File Structure

```
docs/
└── stylesheets/
    └── extra.css       ← Custom Catppuccin Lavender

mkdocs.yml              ← References the CSS file
```

## The Custom CSS

Located at `docs/stylesheets/extra.css`:

```css
/* Catppuccin Latte Lavender for Light Mode */
[data-md-color-scheme="default"] {
  --md-primary-fg-color: #7287fd; /* Catppuccin Latte Lavender */
  --md-primary-fg-color--light: #b4befe; /* Lighter shade */
  --md-primary-fg-color--dark: #5c6ef5; /* Darker shade */
  --md-accent-fg-color: #7287fd; /* Catppuccin Latte Lavender */
}
```

## Full Catppuccin Latte Color Palette

Want to try other Catppuccin colors? Here's the full Latte palette:

| Color        | Hex       | RGB                  | Usage                            |
| ------------ | --------- | -------------------- | -------------------------------- |
| **Lavender** | `#7287fd` | `rgb(114, 135, 253)` | **Current** - Dreamy purple-blue |
| Blue         | `#1e66f5` | `rgb(30, 102, 245)`  | Vibrant blue                     |
| Sapphire     | `#209fb5` | `rgb(32, 159, 181)`  | Cyan-blue                        |
| Sky          | `#04a5e5` | `rgb(4, 165, 229)`   | Bright sky blue                  |
| Teal         | `#179299` | `rgb(23, 146, 153)`  | Blue-green                       |
| Green        | `#40a02b` | `rgb(64, 160, 43)`   | Fresh green                      |
| Yellow       | `#df8e1d` | `rgb(223, 142, 29)`  | Warm yellow                      |
| Peach        | `#fe640b` | `rgb(254, 100, 11)`  | Orange accent                    |
| Red          | `#d20f39` | `rgb(210, 15, 57)`   | Bold red                         |
| Maroon       | `#e64553` | `rgb(230, 69, 83)`   | Deep red                         |
| Pink         | `#ea76cb` | `rgb(234, 118, 203)` | Soft pink                        |
| Mauve        | `#8839ef` | `rgb(136, 57, 239)`  | Rich purple                      |
| Rosewater    | `#dc8a78` | `rgb(220, 138, 120)` | Warm rose                        |
| Flamingo     | `#dd7878` | `rgb(221, 120, 120)` | Coral pink                       |

## Try Other Colors

### Switch to Sapphire (Cyan-Blue)

Edit `docs/stylesheets/extra.css`:

```css
[data-md-color-scheme="default"] {
  --md-primary-fg-color: #209fb5; /* Sapphire */
  --md-accent-fg-color: #209fb5;
}
```

### Switch to Mauve (Purple)

```css
[data-md-color-scheme="default"] {
  --md-primary-fg-color: #8839ef; /* Mauve */
  --md-accent-fg-color: #8839ef;
}
```

### Switch to Pink

```css
[data-md-color-scheme="default"] {
  --md-primary-fg-color: #ea76cb; /* Pink */
  --md-accent-fg-color: #ea76cb;
}
```

## Catppuccin for Dark Mode Too

Want to use Catppuccin Mocha colors for dark mode?

```css
/* Catppuccin Mocha Lavender for dark mode */
[data-md-color-scheme="slate"] {
  --md-primary-fg-color: #b4befe; /* Mocha Lavender */
  --md-accent-fg-color: #b4befe;
}
```

Or try other Mocha colors:

- Mocha Lavender: `#b4befe`
- Mocha Blue: `#89b4fa`
- Mocha Sapphire: `#74c7ec`
- Mocha Sky: `#89dceb`
- Mocha Teal: `#94e2d5`
- Mocha Mauve: `#cba6f7`

## Resources

- **Official Palette**: https://catppuccin.com/palette/
- **Catppuccin Main**: https://github.com/catppuccin/catppuccin
- **Style Guide**: https://github.com/catppuccin/catppuccin/blob/main/docs/style-guide.md
- **600+ Ports**: Browse themes at the repo

## Why Lavender?

Catppuccin Lavender (`#7287fd`) provides:

1. **Elegant**: Soft purple-blue is sophisticated
2. **Eye-Friendly**: High HSL lightness (72%) is easy to read
3. **Distinctive**: Stands out from typical blues
4. **Harmonious**: Blends beautifully with other Catppuccin colors
5. **Versatile**: Works for technical and creative content
6. **Popular**: Widely loved in the Catppuccin community

## Testing

```bash
# Start dev server
uv run mkdocs serve

# Visit in browser
# English: http://127.0.0.1:8000/
# French:  http://127.0.0.1:8000/fr/

# Toggle light/dark mode with the switcher in header
```

## Reverting

To go back to Material default:

1. Remove/comment out in `mkdocs.yml`:

```yaml
# extra_css:
#   - stylesheets/extra.css
```

2. Or delete `docs/stylesheets/extra.css`

---

**Current Status**:

- ✅ Catppuccin Latte Lavender for light mode
- ✅ Teal for dark mode
- ✅ Custom CSS implementation
- ✅ Official Catppuccin colors from https://catppuccin.com/palette/
