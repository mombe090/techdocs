# How to Add New Pages

This guide shows you how to add new pages to your documentation and organize them in the navigation.

## Create a New Page

1. Create a new Markdown file in the `docs/` directory or a subdirectory:

```bash
touch docs/my-new-page.md
```

2. Add content to the file:

```markdown
# My New Page

This is the content of my new page.
```

3. The page will automatically appear in your documentation.

## Add Page to Navigation

To control where the page appears in the navigation menu:

1. Open `mkdocs.yml`
2. Add your page to the `nav` section:

```yaml
nav:
  - Home: index.md
  - Tutorials:
      - Getting Started: tutorials/getting-started.md
  - Your New Page: my-new-page.md # Add here
```

## Organize in Subdirectories

For better organization, create subdirectories:

1. Create a directory structure:

```bash
mkdir -p docs/guides
```

2. Create your page in that directory:

```bash
touch docs/guides/installation.md
```

3. Reference it in navigation:

```yaml
nav:
  - Guides:
      - Installation: guides/installation.md
      - Configuration: guides/configuration.md
```

## Add to Diátaxis Structure

Follow the Diátaxis framework by placing pages in appropriate directories:

- `tutorials/` - Learning-oriented, hands-on lessons
- `how-to/` - Goal-oriented, problem-solving guides
- `reference/` - Information-oriented, technical descriptions
- `explanation/` - Understanding-oriented, conceptual discussion

Example:

```bash
# Create a tutorial
touch docs/tutorials/build-your-first-api.md

# Create a how-to guide
touch docs/how-to/deploy-to-production.md

# Create reference documentation
touch docs/reference/api-endpoints.md

# Create explanation
touch docs/explanation/architecture-overview.md
```

## Test Your Changes

1. Start the development server:

```bash
uv run mkdocs serve
```

2. Navigate to your new page
3. Verify it appears in the navigation menu as expected

!!! note
Pages not listed in `nav` will still be accessible via direct URL but won't appear in the menu.
