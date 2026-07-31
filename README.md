# akovtunov.github.io

Personal site + blog, built with [Jekyll](https://jekyllrb.com/) and served by
GitHub Pages. Writing spans engineering and leadership.

## Adding a post

Create a Markdown file in `_posts/` named `YYYY-MM-DD-title.md`:

```markdown
---
layout: post
title: "Your title here"
date: 2026-08-01 09:00:00 +0000
tags: [leadership, teams]
description: "One-sentence summary used on the homepage and for SEO."
---

Write the post in Markdown. Code blocks get syntax highlighting:

​```ruby
puts "hello"
​```

Images go in `/images/` and are referenced like `![alt](/images/pic.png)`.
```

Commit and push — GitHub Pages builds and publishes it automatically. You can
even add a post straight from GitHub's web editor; no tools required.

## Editing pages

- Homepage: `index.html`
- Writing index: `blog.html`
- About: `about.md` (has placeholders to fill in with your real details)
- Site title, tagline, links: `_config.yml`
- Look and feel: `assets/css/style.css` (one file; supports light + dark mode)

## Previewing locally (optional)

Requires Ruby. Once, install dependencies:

```bash
bundle install
```

Then run a live-reloading local server at http://localhost:4000 :

```bash
bundle exec jekyll serve --livereload
```

## Notes

- Old post URLs are preserved (`/blog/YYYY/MM/DD/title/`) via `permalink` in `_config.yml`.
- The RSS feed stays at `/atom.xml`; a sitemap is generated automatically.
- No analytics are included. To add Google Analytics 4 later, drop the snippet
  into `_layouts/default.html`.
- `_site/` is the generated output and is git-ignored; never edit it by hand.
```
