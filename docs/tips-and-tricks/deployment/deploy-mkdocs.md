# Deploy MkDocs Site

Learn how to deploy your MkDocs Material site to various hosting platforms including GitHub Pages, Netlify, and custom domains.

## GitHub Pages Deployment

### Automatic Deployment with GitHub Actions

Create a GitHub Actions workflow for automatic deployment:

```yaml title=".github/workflows/deploy.yml"
name: Deploy MkDocs

on:
  push:
    branches: [main]
  workflow_dispatch:

permissions:
  contents: write

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - uses: actions/setup-python@v5
        with:
          python-version: 3.x
      
      - name: Install dependencies
        run: |
          pip install mkdocs-material
          pip install -r requirements.txt
      
      - name: Deploy to GitHub Pages
        run: mkdocs gh-deploy --force
```

!!! warning "Branch Protection"

    Ensure the workflow has write permissions to the `gh-pages` branch.

### Manual GitHub Pages Deployment

Deploy manually from your local machine:

```bash
# Build and deploy to gh-pages branch
mkdocs gh-deploy

# With custom commit message
mkdocs gh-deploy --message "docs: update documentation"

# Force push (use with caution)
mkdocs gh-deploy --force
```

!!! tip "First-Time Setup"

    The `gh-deploy` command automatically creates the `gh-pages` branch if it doesn't exist.

### Configure GitHub Pages

1. Go to repository **Settings** → **Pages**
2. Set **Source** to `gh-pages` branch
3. Set **Folder** to `/ (root)`
4. Click **Save**

Your site will be available at `https://username.github.io/repository-name/`

## Custom Domain Setup

### Add CNAME File

Create a CNAME file in your docs directory:

```text title="docs/CNAME"
docs.yourdomain.com
```

!!! info "CNAME Persistence"

    MkDocs will copy the CNAME file to the built site, ensuring it persists after deployment.

### Configure DNS Records

Add these DNS records to your domain provider:

#### Using CNAME (Subdomain)

```
Type: CNAME
Name: docs
Value: yourusername.github.io
TTL: 3600
```

#### Using A Records (Apex Domain)

```
Type: A
Name: @
Value: 185.199.108.153
Value: 185.199.109.153
Value: 185.199.110.153
Value: 185.199.111.153
TTL: 3600
```

!!! warning "DNS Propagation"

    DNS changes can take up to 48 hours to propagate worldwide, though they usually happen much faster.

### Enable HTTPS

1. Go to repository **Settings** → **Pages**
2. Check **Enforce HTTPS**
3. Wait for certificate provisioning (can take up to 24 hours)

## Netlify Deployment

### Create Netlify Configuration

```toml title="netlify.toml"
[build]
  command = "mkdocs build"
  publish = "site"

[build.environment]
  PYTHON_VERSION = "3.11"

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200

[[headers]]
  for = "/*"
  [headers.values]
    X-Frame-Options = "DENY"
    X-Content-Type-Options = "nosniff"
    Referrer-Policy = "no-referrer-when-downgrade"
```

### Deploy to Netlify

#### Via Git Integration

1. Log in to [Netlify](https://netlify.com)
2. Click **Add new site** → **Import an existing project**
3. Connect your Git repository
4. Build settings are auto-detected from `netlify.toml`
5. Click **Deploy site**

#### Via Netlify CLI

```bash
# Install Netlify CLI
npm install -g netlify-cli

# Build site
mkdocs build

# Deploy to Netlify
netlify deploy --prod --dir=site
```

### Custom Domain on Netlify

1. Go to **Site settings** → **Domain management**
2. Click **Add custom domain**
3. Follow DNS configuration instructions
4. Enable HTTPS (automatic via Let's Encrypt)

## Cloudflare Pages Deployment

### Deploy via Git Integration

1. Log in to [Cloudflare Dashboard](https://dash.cloudflare.com)
2. Go to **Workers & Pages** → **Create application**
3. Select **Pages** → **Connect to Git**
4. Configure build settings:
   - **Build command:** `mkdocs build`
   - **Build output directory:** `site`
   - **Environment variables:** `PYTHON_VERSION=3.11`

### Cloudflare Pages Configuration

```toml title="wrangler.toml"
name = "techdocs"
compatibility_date = "2024-01-01"

[site]
bucket = "./site"

[[redirects]]
from = "/*"
to = "/index.html"
status = 200
```

!!! tip "Edge Performance"

    Cloudflare Pages serves content from their global CDN, providing excellent performance worldwide.

## Vercel Deployment

### Create Vercel Configuration

```json title="vercel.json"
{
  "buildCommand": "mkdocs build",
  "outputDirectory": "site",
  "devCommand": "mkdocs serve",
  "installCommand": "pip install -r requirements.txt"
}
```

### Deploy to Vercel

```bash
# Install Vercel CLI
npm install -g vercel

# Deploy
vercel --prod
```

## Docker Deployment

### Create Dockerfile

```dockerfile title="Dockerfile"
FROM squidfunk/mkdocs-material:latest

COPY . /docs

WORKDIR /docs

EXPOSE 8000

CMD ["serve", "--dev-addr=0.0.0.0:8000"]
```

### Build and Run

```bash
# Build Docker image
docker build -t mkdocs-site .

# Run container
docker run -p 8000:8000 mkdocs-site

# Access at http://localhost:8000
```

### Docker Compose

```yaml title="docker-compose.yml"
version: '3.8'

services:
  mkdocs:
    image: squidfunk/mkdocs-material:latest
    volumes:
      - .:/docs
    ports:
      - "8000:8000"
    command: serve --dev-addr=0.0.0.0:8000
```

Run with:

```bash
docker-compose up
```

## Pre-Deployment Checklist

Before deploying to production, verify:

- [ ] All internal links work (`mkdocs build --strict`)
- [ ] Images load correctly
- [ ] Search functionality works
- [ ] Dark/light mode toggles properly
- [ ] Mobile responsiveness looks good
- [ ] Custom domain DNS configured (if applicable)
- [ ] HTTPS enabled
- [ ] Analytics configured (if desired)

!!! success "Deployment Complete"

    Your MkDocs site is now live! Monitor analytics and user feedback to continue improving your documentation.

## Next Steps

- [Optimize Site Performance](../performance/optimize-mkdocs-performance.md)
- [Add Analytics and Monitoring](../../explanation/mkdocs/documentation-architecture.md)
