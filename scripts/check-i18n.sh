#!/bin/bash
# Verify that every translated page still carries the English page's <style>
# block verbatim, and that no locale is missing a page.
#
# The locale pages under src/pages/<locale>/ duplicate the English page's
# scoped <style> block because Astro scopes styles per-component — a shared
# stylesheet would lose the scoping. Any style change to an English page must
# be mirrored into every locale copy; this check catches the ones that weren't.
set -euo pipefail
cd "$(dirname "$0")/.."

LOCALES=(es-MX es-ES zh-CN zh-TW ja)
status=0

style_block() {
  local file="$1" start
  start=$(grep -n '^<style>' "$file" | head -1 | cut -d: -f1)
  [ -n "$start" ] || { echo ""; return; }
  tail -n +"$start" "$file"
}

for page in src/pages/*.astro; do
  name=$(basename "$page")
  for locale in "${LOCALES[@]}"; do
    translated="src/pages/$locale/$name"
    if [ ! -f "$translated" ]; then
      echo "MISSING: $translated (no $locale translation of $name)"
      status=1
      continue
    fi
    if ! diff -q <(style_block "$page") <(style_block "$translated") >/dev/null; then
      echo "STYLE DRIFT: $translated differs from $page"
      echo "  fix with: diff <(sed -n '/^<style>/,\$p' $page) <(sed -n '/^<style>/,\$p' $translated)"
      status=1
    fi
  done
done

if [ "$status" -eq 0 ]; then
  echo "i18n check passed: all pages translated, no style drift."
fi
exit "$status"
