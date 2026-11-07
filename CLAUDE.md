# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal site for tucosaurus.com: a blog, an About page, and an Interests page. Built with [Hugo](https://gohugo.io/) using a small hand-written theme that lives directly in this repo (no theme submodule). The look is quiet and literary, modelled on manuelmoreale.com (typography, highlighter links, ✽ dividers, quote cards, dotted-leader archive, small-caps chrome), and an optional Craig Mod-style drop cap. **One typeface only, all serif, like Manu:** Iowan Old Style (system font on Apple devices), with Newsreader from Google Fonts as the single fallback everywhere else; monospace only for code. Don't introduce a sans-serif or a second display face. Light/dark modes follow `prefers-color-scheme`.

## Commands

Everything goes through the `Makefile` (run `make` for the list):

```sh
make setup                     # install Hugo via Homebrew (developed against v0.169 extended)
make serve                     # preview incl. drafts at http://localhost:1313
make post title="My post"      # new draft at content/posts/my-post.md from archetypes/posts.md
make drafts                    # list unpublished drafts
make build                     # production build into ./public
make check                     # dry-run deploy: build + diff against gh-pages, no push
make deploy                    # requires clean tree; git push origin master, then ./deploy.sh
make clean                     # remove public/, resources/
```

There are no tests or linters. `make build` should finish with no WARN lines.

## Publishing model

Builds happen locally. There is no CI. GitHub Pages serves the **`gh-pages` branch** (root) at tucosaurus.com. `master` holds the source only, and `public/` is gitignored.

`deploy.sh` refuses to run with uncommitted changes (except with `--dry-run`). It builds into `public/`, checks out `origin/gh-pages` in a temporary git worktree, replaces that branch's contents with the build, then commits `deploy: build of <master sha>` and pushes. `static/CNAME` must stay, because it is what keeps the custom domain attached on every deploy.

## Layout

- `hugo.toml`: site params, social links (`params.social`, used in the footer and the post-end aside), and the `main` menu (Writing / About / Interests).
- `layouts/`: uses Hugo's newer template lookup (0.146+). `baseof.html` is the shell; `home.html` is the front page: body of `content/_index.md` as the intro, the 10 newest posts in the archive style, then the `now:` front-matter field as a centered aside. `section.html` is the post archive. `page.html` renders every single page; for `posts` it adds the date line, a "What should you do next?" aside (with an email link only if `params.email` is set) and a "More writing" list. `_partials/archive.html` renders the post list with dotted leaders out to reading time, used by both.
- `assets/css/style.css`: the only stylesheet, processed through Hugo Pipes (minify + fingerprint). It goes in `assets/`, not `static/`. Colors are CSS variables on `:root`, redefined for dark mode.
- **No dates are shown anywhere on the site** (by design). Each post still has a `date` in front matter, set automatically by `make post`. It is the hidden sort key (newest first) and feeds RSS `pubDate`; to reorder a post, change its `date`. Don't add date output back to templates.
- `content/posts/`: blog posts. Front matter: `description` (the italic subtitle and the home-page one-liner) and `dropcap: true` (optional). `style-test.md` is a draft showing every styled element; it never builds without `-D`. `content/posts/_index.md` carries the `/archives/` and `/articles/` aliases so old URLs keep working.
- `content/about.md`, `content/interests.md`: standalone pages. They set `build.list: never` so they stay out of RSS and the post lists.
- Taxonomies (tags/categories) are disabled via `disableKinds`.
