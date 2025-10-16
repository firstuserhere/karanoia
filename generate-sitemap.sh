#!/usr/bin/env bash
set -euo pipefail
DOMAIN="$(cat CNAME 2>/dev/null || echo "kunvarthaman.com")"
BASE="https://${DOMAIN}"

{
  echo '<?xml version="1.0" encoding="UTF-8"?>'
  echo '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">'
  # root
  ROOT_LASTMOD="$(git log -1 --format=%cs -- index.html 2>/dev/null || date +%F)"
  echo "  <url><loc>${BASE}/</loc><lastmod>${ROOT_LASTMOD}</lastmod></url>"
  # all HTML files
  while IFS= read -r f; do
    [ "$f" = "index.html" ] && continue
    path="${f#./}"
    if [[ "$path" == */index.html ]]; then
      loc="${BASE}/${path%index.html}"
    else
      loc="${BASE}/${path}"
    fi
    loc="${loc//\/\//\/}"
    lastmod="$(git log -1 --format=%cs -- "$f" 2>/dev/null || date +%F)"
    printf '  <url><loc>%s</loc><lastmod>%s</lastmod></url>\n' "$loc" "$lastmod"
  done < <(git ls-files '*.html')
  echo '</urlset>'
} > sitemap.xml

echo "Wrote sitemap.xml"
