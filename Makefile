# tucosaurus.com — run `make` to see what's available.

PORT ?= 1313

.DEFAULT_GOAL := help
.PHONY: help setup serve post drafts build check deploy clean

help: ## Show this list
	@grep -E '^[a-z-]+:.*## ' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  make %-8s %s\n", $$1, $$2}'
	@echo
	@echo '  e.g.  make post title="Notes on slowness"'

setup: ## Install Hugo (via Homebrew)
	@command -v hugo >/dev/null || brew install hugo
	@hugo version

serve: ## Preview with drafts at localhost:1313 (PORT=… to change)
	hugo server --buildDrafts --port $(PORT) --navigateToChanged

post: ## New draft post: make post title="My post"
	@test -n "$(title)" || { echo 'Usage: make post title="My new post"'; exit 1; }
	@slug=$$(printf '%s' "$(title)" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$$//'); \
	  file="content/posts/$$slug.md"; \
	  test ! -e "$$file" || { echo "$$file already exists"; exit 1; }; \
	  hugo new "posts/$$slug.md" >/dev/null && \
	  T="$(title)" perl -pi -e 's/^title: .*/title: "$$ENV{T}"/' "$$file" && \
	  echo "Created $$file (draft). Set draft: false when it's ready."

drafts: ## List posts that are still drafts
	@hugo list drafts 2>/dev/null | tail -n +2 | cut -d, -f1 | sed 's/^/  /' | grep . || echo "  No drafts."

build: ## Build the production site into ./public
	hugo --minify --cleanDestinationDir

check: ## Dry-run deploy: build and show what would change on the live site
	./deploy.sh --dry-run

deploy: ## Push source to GitHub and publish the site
	@test -z "$$(git status --porcelain)" || { echo "Commit your changes first (git status)."; exit 1; }
	git push origin master
	./deploy.sh

clean: ## Remove build output
	rm -rf public resources .hugo_build.lock
