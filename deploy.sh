#!/usr/bin/env bash
# Build the site locally and publish it to the gh-pages branch,
# which GitHub Pages serves at tucosaurus.com.
#
#   ./deploy.sh              build + commit + push
#   ./deploy.sh --dry-run    build + show what would change, no commit/push
set -euo pipefail

cd "$(dirname "$0")"

DRY_RUN=0
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=1

if [[ -n "$(git status --porcelain)" ]]; then
  echo "Working tree has uncommitted changes. Commit them first so the deploy matches master." >&2
  [[ $DRY_RUN -eq 1 ]] || exit 1
fi

SRC_SHA="$(git rev-parse --short HEAD)"

echo "→ Building with $(hugo version | cut -d' ' -f2)"
rm -rf public
hugo --minify --cleanDestinationDir
touch public/.nojekyll

WORKTREE="$(mktemp -d)"
cleanup() { git worktree remove --force "$WORKTREE" >/dev/null 2>&1 || true; }
trap cleanup EXIT

git fetch -q origin gh-pages
git worktree add -q --detach "$WORKTREE" origin/gh-pages

# Replace everything in the branch with the fresh build (keep its .git link).
find "$WORKTREE" -mindepth 1 -maxdepth 1 ! -name .git -exec rm -rf {} +
cp -R public/. "$WORKTREE/"

cd "$WORKTREE"
git add -A
if git diff --cached --quiet; then
  echo "✓ Nothing changed; site is already up to date."
  exit 0
fi

git --no-pager diff --cached --stat | tail -n 15
if [[ $DRY_RUN -eq 1 ]]; then
  echo "✓ Dry run: not committing or pushing."
  exit 0
fi

git commit -q -m "deploy: build of ${SRC_SHA}"
git push -q origin HEAD:gh-pages
echo "✓ Deployed ${SRC_SHA} to gh-pages. Live at https://tucosaurus.com in a minute or two."
