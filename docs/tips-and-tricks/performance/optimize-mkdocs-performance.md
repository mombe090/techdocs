# Optimize MkDocs Performance

Learn how to improve build times, reduce page load speeds, and optimize your MkDocs Material site performance.

## Build Speed Optimization

### Disable Strict Mode During Development

Speed up development builds by temporarily disabling strict mode:

```yaml title="mkdocs.yml"
# During development
strict: false

# Re-enable for production builds
# strict: true
```

!!! warning "Production Builds"

    Always re-enable strict mode for production to catch broken links and invalid references.

### Use Dirty Reload for Faster Previews

Get instant updates during development with dirty reload:

```bash
uv run mkdocs serve --dirtyreload
```

!!! tip "Dirty Reload Behavior"

    Dirty reload only rebuilds changed files, dramatically reducing preview refresh time during active editing.

## Image Optimization

### Convert to WebP Format

WebP provides superior compression compared to PNG or JPEG:

```bash
# Convert PNG to WebP
cwebp -q 80 image.png -o image.webp

# Convert JPEG to WebP
cwebp -q 80 image.jpg -o image.webp
```

!!! info "Quality Settings"

    - `-q 80`: Good balance between quality and file size
    - `-q 90`: Higher quality, larger file
    - `-q 70`: More compression, lower quality

### Enable Lazy Loading

Defer off-screen image loading to improve initial page load:

```markdown
![Alt text](image.png){ loading=lazy }

![Another image](screenshot.webp){ loading=lazy width="600" }
```

!!! tip "Best Practice"

    Apply lazy loading to all images below the fold (not visible on initial page load).

## Search Performance

### Configure Search Plugin

Optimize search indexing and performance:

```yaml title="mkdocs.yml"
plugins:
  - search:
      separator: '[\s\-,:!=\[\]()"`/]+|\.(?!\d)|&[lg]t;|(?!\b)(?=[A-Z][a-z])'
      lang:
        - en
        - fr
```

!!! info "Search Configuration"

    - `separator`: Regex pattern for word boundary detection
    - `lang`: Languages for search stemming and tokenization

## Performance Monitoring

### Measure Build Time

Track build performance over time:

```bash
# Time the build process
time uv run mkdocs build

# Verbose output for debugging
uv run mkdocs build --verbose
```

### Analyze Site Size

Monitor generated site size:

```bash
# Check site directory size
du -sh site/

# List largest files
du -h site/ | sort -rh | head -20
```

!!! success "Performance Target"

    Aim for build times under 10 seconds and total site size under 50MB for optimal performance.

## Next Steps

- [Customize Site Styling](../styling/customize-mkdocs-styling.md)
- [Deploy MkDocs to Production](../deployment/deploy-mkdocs.md)
