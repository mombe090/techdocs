# Enhance MkDocs Content

Learn how to create reusable content snippets, embed external files, and add advanced content features to your MkDocs site.

## Reusable Content Snippets

### Use Abbreviations

Define abbreviations that show definitions on hover:

```markdown
The HTML specification is maintained by the W3C.

*[HTML]: Hyper Text Markup Language
*[W3C]: World Wide Web Consortium
```

**Result:** Hover over HTML or W3C to see the definition!

!!! tip "Global Abbreviations"

    Place abbreviations in a separate file and include them across your documentation for consistency.

### Abbreviations File

Create a global abbreviations file:

```markdown title="docs/snippets/abbreviations.md"
*[API]: Application Programming Interface
*[REST]: Representational State Transfer
*[HTTP]: Hypertext Transfer Protocol
*[JSON]: JavaScript Object Notation
*[YAML]: YAML Ain't Markup Language
```

Reference in your main pages:

```markdown
--8<-- "snippets/abbreviations.md"
```

## Include External Content

### Enable Snippets Extension

Configure the snippets extension in your MkDocs configuration:

```yaml title="mkdocs.yml"
markdown_extensions:
  - pymdownx.snippets:
      base_path: docs/snippets
      check_paths: true
```

!!! info "Base Path"

    The `base_path` is relative to your `mkdocs.yml` location.

### Include Files

Include content from external files:

```markdown
--8<-- "common-note.md"

--8<-- "installation-steps.md"
```

### Include Code Files

Include source code directly:

```markdown
```python
--8<-- "examples/sample.py"
\```
```

!!! tip "Live Code Examples"

    Including actual source files ensures your documentation stays synchronized with your codebase.

### Partial Includes

Include specific lines from a file:

```markdown
--8<-- "config.yaml:10:20"
```

This includes lines 10-20 from `config.yaml`.

## Math Equations

### Enable MathJax Support

Add MathJax support for mathematical equations:

```yaml title="mkdocs.yml"
markdown_extensions:
  - pymdownx.arithmatex:
      generic: true

extra_javascript:
  - javascripts/mathjax.js
  - https://polyfill.io/v3/polyfill.min.js?features=es6
  - https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js
```

### Create MathJax Configuration

```javascript title="docs/javascripts/mathjax.js"
window.MathJax = {
  tex: {
    inlineMath: [["\\(", "\\)"]],
    displayMath: [["\\[", "\\]"]],
    processEscapes: true,
    processEnvironments: true
  },
  options: {
    ignoreHtmlClass: ".*|",
    processHtmlClass: "arithmatex"
  }
};

document$.subscribe(() => {
  MathJax.typesetPromise()
})
```

### Write Math Equations

#### Block Equations

```markdown
$$
E = mc^2
$$

$$
\frac{-b \pm \sqrt{b^2 - 4ac}}{2a}
$$
```

#### Inline Equations

```markdown
The Pythagorean theorem is $x^2 + y^2 = z^2$.

Einstein's equation $E = mc^2$ describes mass-energy equivalence.
```

!!! warning "Escaping"

    When using math equations in admonitions or other special blocks, you may need to escape backslashes.

## Content Macros

### Enable Macros Plugin

```yaml title="mkdocs.yml"
plugins:
  - macros
```

### Define Custom Macros

```python title="main.py"
def define_env(env):
    @env.macro
    def current_year():
        from datetime import datetime
        return datetime.now().year
    
    @env.macro
    def code_example(language, code):
        return f"```{language}\n{code}\n```"
```

### Use Macros in Content

```markdown
Copyright © {{ current_year() }} Your Company

{{ code_example('python', 'print("Hello, World!")') }}
```

## External Embeds

### Embed YouTube Videos

```html
<iframe width="560" height="315" 
  src="https://www.youtube.com/embed/VIDEO_ID" 
  frameborder="0" 
  allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" 
  allowfullscreen>
</iframe>
```

### Embed GitHub Gists

```html
<script src="https://gist.github.com/username/gist-id.js"></script>
```

### Embed Code Playgrounds

```html
<!-- CodePen -->
<iframe height="300" style="width: 100%;" scrolling="no" 
  src="https://codepen.io/username/embed/HASH?default-tab=html,result" 
  frameborder="no" loading="lazy" allowtransparency="true" allowfullscreen="true">
</iframe>

<!-- JSFiddle -->
<iframe width="100%" height="300" 
  src="//jsfiddle.net/username/HASH/embedded/" 
  allowfullscreen="allowfullscreen" frameborder="0">
</iframe>
```

## Content Validation

### Enable HTML Validation

```yaml title="mkdocs.yml"
validation:
  nav:
    omitted_files: warn
    not_found: warn
  links:
    not_found: warn
    absolute_links: warn
    unrecognized_links: warn
```

!!! tip "Strict Mode"

    Use `strict: true` in production to catch all validation errors.

## Next Steps

- [Optimize Performance](../performance/optimize-mkdocs-performance.md)
- [Deploy Your Site](../deployment/deploy-mkdocs.md)
