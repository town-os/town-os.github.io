# Make bun reachable in recipes even right after the installer drops it in ~/.bun/bin
export PATH := $(HOME)/.bun/bin:$(PATH)

.DEFAULT_GOAL := help

help: ## Show this help
	@echo "Town OS website — available targets:"
	@echo ""
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| sort \
		| awk 'BEGIN {FS = ":.*?## "} {printf "  \033[36m%-8s\033[0m %s\n", $$1, $$2}'

serve: ## Start the dev server on 0.0.0.0
	bun run astro dev --host 0.0.0.0

check-i18n: ## Verify every page is translated and locale style blocks match English
	@./scripts/check-i18n.sh

# Install everything the other targets need: Node + npm (system package manager),
# Bun (preferred runtime, via its official installer), and the project's npm
# dependencies (astro, tailwind, ...). Works on Arch/Manjaro (pacman) and Debian/Ubuntu (apt).
deps: ## Install Node, npm, Bun and project dependencies (Arch/Manjaro & Debian)
	@set -e; \
	if command -v pacman >/dev/null 2>&1; then \
		echo ">> Arch/Manjaro detected — installing node, npm & curl via pacman"; \
		sudo pacman -S --needed --noconfirm nodejs npm curl; \
	elif command -v apt-get >/dev/null 2>&1; then \
		echo ">> Debian/Ubuntu detected — installing node, npm & curl via apt"; \
		sudo apt-get update; \
		sudo apt-get install -y nodejs npm curl; \
	else \
		echo "!! No supported package manager found (need pacman or apt-get)." >&2; \
		echo "!! Install nodejs, npm and curl manually, then re-run 'make deps'." >&2; \
		exit 1; \
	fi; \
	if command -v bun >/dev/null 2>&1; then \
		echo ">> bun already installed ($$(bun --version))"; \
	else \
		echo ">> Installing bun (preferred runtime)"; \
		curl -fsSL https://bun.sh/install | bash; \
	fi; \
	if command -v bun >/dev/null 2>&1; then \
		echo ">> Installing project dependencies with bun"; \
		bun install; \
	else \
		echo ">> bun unavailable — installing project dependencies with npm"; \
		npm install; \
	fi; \
	echo ">> Dependencies ready. Run 'make serve' to start the dev server."

.PHONY: help serve deps check-i18n
