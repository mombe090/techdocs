# How to Customize Colors

This guide shows you how to customize the color scheme of your MkDocs Material documentation site.

## Change Primary and Accent Colors

To change the primary and accent colors in `mkdocs.yml`:

1. Open `mkdocs.yml` in your editor
2. Locate the `theme.palette` section
3. Modify the `primary` and `accent` values:

```yaml
theme:
  palette:
    - scheme: default
      primary: blue # Change this
      accent: indigo # Change this
```

Available colors: `red`, `pink`, `purple`, `deep purple`, `indigo`, `blue`, `light blue`, `cyan`, `teal`, `green`, `light green`, `lime`, `yellow`, `amber`, `orange`, `deep orange`, `brown`, `grey`, `blue grey`, `black`, `white`.

## Use Custom Colors with CSS

For more control, use custom CSS with specific color codes:

1. Create `docs/stylesheets/extra.css` (if it doesn't exist)
2. Add your custom colors:

```css
[data-md-color-scheme="default"] {
  --md-primary-fg-color: #74c7ec; /* Your custom color */
  --md-accent-fg-color: #89b4fa; /* Your custom accent */
}
```

3. Reference it in `mkdocs.yml`:

```yaml
extra_css:
  - stylesheets/extra.css
```

## Apply Catppuccin Color Scheme

To use the Catppuccin Mocha palette:

1. Add to your `docs/stylesheets/extra.css`:

```css
/* Light mode */
[data-md-color-scheme="default"] {
  --md-primary-fg-color: #1e1e2e;
  --md-accent-fg-color: #74c7ec;
}

/* Dark mode */
[data-md-color-scheme="slate"] {
  --md-default-bg-color: #1e1e2e;
  --md-primary-fg-color: #74c7ec;
  --md-accent-fg-color: #74c7ec;
}
```

2. Set the theme to use custom colors in `mkdocs.yml`:

```yaml
theme:
  palette:
    - scheme: default
      primary: custom
      accent: custom
```

## Test Your Changes

1. Run the development server:

```bash
uv run mkdocs serve
```

2. Open `http://localhost:8000` in your browser
3. Toggle between light and dark modes to see your colors
4. Adjust the color codes as needed

!!! tip
Use a color picker tool or visit [Catppuccin Palette](https://catppuccin.com/palette) to find your preferred colors.
