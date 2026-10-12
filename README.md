# Kinship Mobile site

Static site source for the Kinship Mobile project page. Eleventy builds the Nunjucks templates into `_site`; GitHub Actions publishes that directory to GitHub Pages.

## Local build

Requires Node.js and npm.

```sh
npm ci
npm run build
```

Generated site files are written to `_site/`. Root-relative links and assets are intentionally avoided so the site works under a GitHub project-site path.

## GitHub Pages deployment

In the repository settings, open **Pages** and set the build and deployment source to **GitHub Actions**. The workflow deploys on pushes to `gh-pages` and can also be run manually with `workflow_dispatch`.

A custom domain is planned but gated; no domain has been configured here. Do not add a `CNAME` until the domain is confirmed. This scaffold does not publish privacy or support drafts.
