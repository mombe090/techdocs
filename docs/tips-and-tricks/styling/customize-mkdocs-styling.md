# Customize MkDocs Styling

Learn how to customize colors, fonts, and visual styling in your MkDocs Material site.

## Custom Color Schemes

### Target Specific Elements

Override default colors using CSS custom properties:

```css title="docs/stylesheets/extra.css"
/* Customize header background */
.md-header {
  background-color: var(--md-primary-fg-color);
}

/* Change link colors */
.md-content a {
  color: var(--md-accent-fg-color);
}

/* Customize code block background */
.md-typeset code {
  background-color: var(--md-code-bg-color);
}
```

!!! tip "CSS Variables"

    MkDocs Material provides CSS custom properties for all theme colors. Use `var(--md-*)` to maintain consistency across light/dark modes.

### Override Catppuccin Colors

Modify existing Catppuccin palette colors:

```css title="docs/stylesheets/extra.css"
:root {
  /* Override primary color */
  --md-primary-fg-color: #89b4fa;
  
  /* Override accent color */
  --md-accent-fg-color: #f38ba8;
  
  /* Override background */
  --md-default-bg-color: #1e1e2e;
}
```

## Custom Fonts

### Use Google Fonts

Configure fonts directly in MkDocs configuration:

```yaml title="mkdocs.yml"
theme:
  font:
    text: Inter
    code: Fira Code
```

!!! info "Available Fonts"

    Browse available Google Fonts at [fonts.google.com](https://fonts.google.com)

### Self-Hosted Fonts

Host fonts locally for better privacy and performance:

```css title="docs/stylesheets/extra.css"
@font-face {
  font-family: 'CustomFont';
  src: url('../fonts/custom.woff2') format('woff2'),
       url('../fonts/custom.woff') format('woff');
  font-weight: normal;
  font-style: normal;
  font-display: swap;
}

:root {
  --md-text-font: "CustomFont", sans-serif;
  --md-code-font: "Fira Code", monospace;
}
```

!!! warning "Font Loading"

    Use `font-display: swap` to prevent invisible text while fonts load.

## Dark Mode Customization

### Custom Palette Toggle

Configure multiple color schemes with toggles:

```yaml title="mkdocs.yml"
theme:
  palette:
    # Auto mode based on system preference
    - media: "(prefers-color-scheme)"
      toggle:
        icon: material/link
        name: Switch to light mode
    
    # Light mode
    - media: "(prefers-color-scheme: light)"
      scheme: default
      primary: indigo
      accent: indigo
      toggle:
        icon: material/toggle-switch
        name: Switch to dark mode
    
    # Dark mode
    - media: "(prefers-color-scheme: dark)"
      scheme: slate
      primary: indigo
      accent: indigo
      toggle:
        icon: material/toggle-switch-off
        name: Switch to system preference
```

!!! tip "System Preference"

    The first palette entry with `media: "(prefers-color-scheme)"` respects the user's system preference.

### Dark Mode Specific Styles

Apply styles only in dark mode:

```css title="docs/stylesheets/extra.css"
[data-md-color-scheme="slate"] {
  /* Dark mode specific overrides */
  --md-default-bg-color: #1e1e2e;
  --md-default-fg-color: #cdd6f4;
}

[data-md-color-scheme="default"] {
  /* Light mode specific overrides */
  --md-default-bg-color: #eff1f5;
  --md-default-fg-color: #4c4f69;
}
```

## Advanced Customization

### Custom Navigation Styling

Style the navigation sidebar:

```css title="docs/stylesheets/extra.css"
/* Navigation item hover effect */
.md-nav__item--active > .md-nav__link {
  color: var(--md-accent-fg-color);
  font-weight: bold;
}

/* Nested navigation indentation */
.md-nav--secondary .md-nav__item {
  padding-left: 1rem;
}
```

### Custom Button Styles

Override Material button appearance:

```css title="docs/stylesheets/extra.css"
.md-button {
  border-radius: 0.5rem;
  text-transform: none;
  font-weight: 500;
}

.md-button--primary {
  background-color: var(--md-accent-fg-color);
  border-color: var(--md-accent-fg-color);
}
```

## Next Steps

- [Optimize Site Performance](../performance/optimize-mkdocs-performance.md)
- [Add Advanced Content Features](../content/enhance-mkdocs-content.md)
