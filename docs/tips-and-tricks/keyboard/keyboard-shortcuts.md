# Keyboard Shortcuts

Quick reference for built-in and custom keyboard shortcuts in MkDocs Material.

## Built-in Shortcuts

MkDocs Material includes several keyboard shortcuts out of the box:

| Shortcut | Action |
|----------|--------|
| ++f++ or ++s++ | Open search dialog |
| ++p++ | Navigate to previous page |
| ++n++ | Navigate to next page |
| ++slash++ | Open search (alternative) |
| ++esc++ | Close search dialog or other overlays |

!!! tip "Search Shortcuts"

    Both ++f++ and ++s++ keys open the search dialog for convenience. Use ++slash++ if you prefer vim-style navigation.

## Custom Keyboard Shortcuts

### Add Custom Keybindings

Create a custom JavaScript file to add additional shortcuts:

```javascript title="docs/javascripts/shortcuts.js"
document.addEventListener('keydown', (e) => {
  // Ctrl+K to open search (VS Code style)
  if (e.ctrlKey && e.key === 'k') {
    e.preventDefault();
    document.querySelector('[data-md-component="search-query"]').focus();
  }
  
  // Ctrl+B to toggle sidebar
  if (e.ctrlKey && e.key === 'b') {
    e.preventDefault();
    document.querySelector('[data-md-toggle="drawer"]').click();
  }
  
  // G then H for home (vim style)
  if (e.key === 'g' && lastKey === 'g') {
    window.location.href = '/';
  }
  lastKey = e.key;
});

let lastKey = '';
```

### Register Custom Scripts

Reference the custom JavaScript in your MkDocs configuration:

```yaml title="mkdocs.yml"
extra_javascript:
  - javascripts/shortcuts.js
```

!!! warning "Shortcut Conflicts"

    Avoid overriding browser shortcuts (like ++ctrl+t++) or MkDocs Material built-ins unless intentional.

## Platform-Specific Shortcuts

### macOS

| Shortcut | Action |
|----------|--------|
| ++cmd+k++ | Custom search (if configured) |
| ++cmd+b++ | Custom sidebar toggle (if configured) |

### Windows/Linux

| Shortcut | Action |
|----------|--------|
| ++ctrl+k++ | Custom search (if configured) |
| ++ctrl+b++ | Custom sidebar toggle (if configured) |

## Advanced Shortcut Patterns

### Vim-Style Navigation

Implement vim-style two-key shortcuts:

```javascript title="docs/javascripts/shortcuts.js"
let keySequence = [];
const TIMEOUT = 1000; // Reset after 1 second

document.addEventListener('keydown', (e) => {
  // Ignore if typing in input fields
  if (e.target.matches('input, textarea')) return;
  
  keySequence.push(e.key);
  
  // g + h = home
  if (keySequence.join('') === 'gh') {
    window.location.href = '/';
    keySequence = [];
  }
  
  // g + g = top of page
  if (keySequence.join('') === 'gg') {
    window.scrollTo({ top: 0, behavior: 'smooth' });
    keySequence = [];
  }
  
  // Reset sequence after timeout
  setTimeout(() => { keySequence = []; }, TIMEOUT);
});
```

### Command Palette

Create a command palette with ++ctrl+shift+p++:

```javascript title="docs/javascripts/command-palette.js"
document.addEventListener('keydown', (e) => {
  if (e.ctrlKey && e.shiftKey && e.key === 'P') {
    e.preventDefault();
    // Show custom command palette
    showCommandPalette();
  }
});

function showCommandPalette() {
  // Implementation for command palette UI
  console.log('Command palette opened');
}
```

!!! info "Command Palette"

    A full command palette implementation requires additional UI components and state management.

## Accessibility Considerations

### Focus Management

Ensure keyboard shortcuts work with screen readers:

```javascript title="docs/javascripts/accessible-shortcuts.js"
document.addEventListener('keydown', (e) => {
  // Skip shortcuts if using screen reader
  if (e.target.getAttribute('role') === 'dialog') return;
  
  // Announce shortcut action
  if (e.key === 'f' || e.key === 's') {
    announceToScreenReader('Opening search dialog');
  }
});

function announceToScreenReader(message) {
  const announcement = document.createElement('div');
  announcement.setAttribute('role', 'status');
  announcement.setAttribute('aria-live', 'polite');
  announcement.textContent = message;
  document.body.appendChild(announcement);
  setTimeout(() => announcement.remove(), 1000);
}
```

## Testing Shortcuts

Test keyboard shortcuts across browsers:

- **Chrome/Edge:** Built-in DevTools for debugging
- **Firefox:** Web Console for JavaScript errors
- **Safari:** Enable Developer menu for testing

!!! tip "Cross-Browser Testing"

    Always test custom shortcuts in multiple browsers, as key event handling can vary.

## Related Resources

- [MkDocs Material Documentation](https://squidfunk.github.io/mkdocs-material/)
- [MDN Web Docs - Keyboard Events](https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent)
