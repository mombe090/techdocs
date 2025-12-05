# Tips & Tricks

Quick tips and useful tricks to enhance your MkDocs Material experience.

## :material-speedometer: Performance Tips

=== "Build Speed"

    **Optimize Build Times**
    
    ```yaml
    # In mkdocs.yml, disable strict mode during development
    strict: false
    
    # Re-enable for production builds
    # strict: true
    ```
    
    **Faster Previews**
    
    ```bash
    # Use direnv mode for instant updates
    uv run mkdocs serve --dirtyreload
    ```

=== "Image Optimization"

    **Compress Images**
    
    Use WebP format for better compression:
    
    ```bash
    # Convert PNG to WebP
    cwebp -q 80 image.png -o image.webp
    ```
    
    **Lazy Loading**
    
    ```markdown
    ![Image](image.png){ loading=lazy }
    ```

=== "Search Performance"

    **Configure Search**
    
    ```yaml
    plugins:
      - search:
          separator: '[\s\-,:!=\[\]()"`/]+|\.(?!\d)|&[lg]t;|(?!\b)(?=[A-Z][a-z])'
          lang: 
            - en
            - fr
    ```

## :material-brush: Styling Tricks

=== "Custom Colors"

    **Quick Color Changes**
    
    ```css
    /* Target specific elements */
    .md-header {
      background-color: var(--md-primary-fg-color);
    }
    
    /* Customize link colors */
    .md-content a {
      color: var(--md-accent-fg-color);
    }
    ```

=== "Custom Fonts"

    **Use Google Fonts**
    
    ```yaml
    theme:
      font:
        text: Inter
        code: Fira Code
    ```
    
    **Self-hosted Fonts**
    
    ```css
    @font-face {
      font-family: 'CustomFont';
      src: url('../fonts/custom.woff2');
    }
    
    :root {
      --md-text-font: "CustomFont";
    }
    ```

=== "Dark Mode Toggle"

    **Custom Palette**
    
    ```yaml
    theme:
      palette:
        # Auto mode based on system
        - media: "(prefers-color-scheme)"
          toggle:
            icon: material/link
            name: Switch to light mode
        # Light mode
        - media: "(prefers-color-scheme: light)"
          scheme: default
          toggle:
            icon: material/toggle-switch
            name: Switch to dark mode
        # Dark mode  
        - media: "(prefers-color-scheme: dark)"
          scheme: slate
          toggle:
            icon: material/toggle-switch-off
            name: Switch to system preference
    ```

## :material-keyboard: Keyboard Shortcuts

=== "Built-in Shortcuts"

    | Shortcut | Action |
    |----------|--------|
    | ++f++ or ++s++ | Open search |
    | ++p++ | Go to previous page |
    | ++n++ | Go to next page |
    | ++slash++ | Open search (alternative) |

=== "Custom Shortcuts"

    **Add Custom Keybindings**
    
    ```javascript
    // docs/javascripts/shortcuts.js
    document.addEventListener('keydown', (e) => {
      // Ctrl+K to open search
      if (e.ctrlKey && e.key === 'k') {
        e.preventDefault();
        document.querySelector('[data-md-component="search-query"]').focus();
      }
    });
    ```
    
    Reference in `mkdocs.yml`:
    
    ```yaml
    extra_javascript:
      - javascripts/shortcuts.js
    ```

## :material-code-braces: Content Tricks

=== "Reusable Snippets"

    **Use Abbreviations**
    
    ```markdown
    The HTML specification is maintained by the W3C.
    
    *[HTML]: Hyper Text Markup Language
    *[W3C]: World Wide Web Consortium
    ```
    
    Result: Hover over HTML or W3C to see definition!

=== "Embed Content"

    **Include Files**
    
    ```yaml
    markdown_extensions:
      - pymdownx.snippets:
          base_path: docs/snippets
    ```
    
    Then in your markdown:
    
    ```markdown
    --8<-- "common-note.md"
    ```

=== "Math Equations"

    **Enable MathJax**
    
    ```yaml
    markdown_extensions:
      - pymdownx.arithmatex:
          generic: true
    
    extra_javascript:
      - javascripts/mathjax.js
      - https://polyfill.io/v3/polyfill.min.js?features=es6
      - https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js
    ```
    
    **Write Equations**
    
    ```markdown
    $$
    E = mc^2
    $$
    
    Inline: $x^2 + y^2 = z^2$
    ```

## :material-rocket: Deployment Tricks

=== "GitHub Pages"

    **Automatic Deployment**
    
    Create `.github/workflows/deploy.yml`:
    
    ```yaml
    name: Deploy
    on:
      push:
        branches: [main]
    
    jobs:
      deploy:
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v4
          - uses: actions/setup-python@v5
            with:
              python-version: 3.x
          - run: pip install mkdocs-material
          - run: mkdocs gh-deploy --force
    ```

=== "Custom Domain"

    **Add CNAME**
    
    Create `docs/CNAME`:
    
    ```
    docs.yourdomain.com
    ```
    
    **Configure DNS**
    
    Add these records to your DNS:
    
    ```
    Type: CNAME
    Name: docs
    Value: yourusername.github.io
    ```

=== "Netlify"

    **Deploy to Netlify**
    
    Create `netlify.toml`:
    
    ```toml
    [build]
      command = "mkdocs build"
      publish = "site"
    
    [[redirects]]
      from = "/*"
      to = "/index.html"
      status = 200
    ```

## :material-file-document: Writing Tips

=== "Documentation Structure"

    **Follow Diátaxis**
    
    - Tutorials → `tutorials/` - Learning by doing
    - How-to → `how-to/` - Solving problems
    - Reference → `reference/` - Looking things up
    - Explanation → `explanation/` - Understanding concepts

=== "Content Organization"

    **Use Descriptive Names**
    
    ✅ Good:
    ```
    how-to/deploy-to-kubernetes.md
    how-to/configure-ssl.md
    ```
    
    ❌ Bad:
    ```
    guide1.md
    tutorial.md
    ```
    
    **Group Related Content**
    
    ```
    reference/
      api/
        authentication.md
        endpoints.md
      configuration/
        environment.md
        settings.md
    ```

=== "Writing Style"

    **Keep It Concise**
    
    - One idea per paragraph
    - Use bullet points for lists
    - Add code examples
    - Include visual aids
    
    **Use Admonitions Wisely**
    
    ```markdown
    !!! tip "Pro Tip"
        For important insights
    
    !!! warning
        For critical warnings
    
    !!! note
        For additional context
    ```

## :material-link: Useful Resources

- [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/)
- [Diátaxis Framework](https://diataxis.fr/)
- [Catppuccin Colors](https://catppuccin.com/)
- [Markdown Guide](https://www.markdownguide.org/)
- [PyMdown Extensions](https://facelessuser.github.io/pymdown-extensions/)

!!! success "Quick Win"
    Bookmark this page for quick reference when working on your documentation!
