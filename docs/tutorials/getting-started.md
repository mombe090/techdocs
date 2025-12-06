# Getting Started with MkDocs Material

In this tutorial, we will create your first documentation page and see it in action. By the end, you will have a working documentation site running locally.

!!! note "What you'll learn" - How to start the development server - How to create your first documentation page - How to see your changes in real-time - How to use basic formatting

## Prerequisites

This tutorial assumes you have already:

- Installed Python and `uv`
- Cloned or set up this documentation project

## Step 1: Start the Development Server

First, let's start the development server. In your terminal, run:

```bash
uv run mkdocs serve
```

You should see output similar to:

```
INFO     -  Building documentation...
INFO     -  Cleaning site directory
INFO     -  Documentation built in 0.50 seconds
INFO     -  [10:00:00] Watching paths for changes: 'docs', 'mkdocs.yml'
INFO     -  [10:00:00] Serving on http://127.0.0.1:8000/
```

!!! success "Server is running!"
Open your browser and navigate to `http://localhost:8000`. You should see the documentation homepage.

## Step 2: Create Your First Page

Now, let's create a new page. With the server still running, create a new file called `my-first-page.md` in the `docs/` directory:

```bash
echo "# My First Page

Welcome to my first documentation page!" > docs/my-first-page.md
```

Notice that your browser automatically refreshes and you can now see the new file listed.

## Step 3: Add Some Content

Let's add some formatted content to your page. Open `docs/my-first-page.md` in your editor and replace its content with:

````markdown
# My First Page

Welcome to my first documentation page!

## Basic Formatting

This is a paragraph with **bold text** and _italic text_.

### Code Example

Here's a simple Python code block:

\```python
def greet(name):
return f"Hello, {name}!"

print(greet("World"))
\```

### An Important Note

!!! tip
This is a tip admonition. It helps highlight important information!
````

Save the file and watch your browser - it should automatically refresh with the new content.

## Step 4: Explore the Formatting

Try adding different formatting elements:

1. Create a numbered list (like this one)
2. Add an unordered list with `-`
3. Try creating a code block with syntax highlighting
4. Experiment with admonitions using `!!! note`, `!!! warning`, etc.

## What You've Accomplished

You've successfully:

- ✅ Started the MkDocs development server
- ✅ Created your first documentation page
- ✅ Used basic Markdown formatting
- ✅ Seen live reloading in action

## Next Steps

Now that you're familiar with the basics, you can:

- Explore the [Formatting Reference](../reference/formatting.md) for all available options
- Learn [How to Add New Pages](../how-to/add-new-pages.md)
- Learn [How to Customize Colors](../how-to/customize-colors.md)
- Read about [Documentation Architecture](../explanation/mkdocs/documentation-architecture.md) to understand best practices
