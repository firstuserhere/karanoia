#!/usr/bin/env bash
set -euo pipefail

# Update all post files with Published and Last updated dates
for post in posts/*.html; do
    # Skip template
    [[ "$post" == "posts/_template.html" ]] && continue

    echo "Processing: $post"

    # Check if post has a date line
    if ! grep -q 'post-date' "$post"; then
        echo "  ⊘ Skipped (no date line found)"
        continue
    fi

    # Extract current date from the post (this is the published date)
    published_date=$(grep -o '<p class="post-date">.*</p>' "$post" | sed -E 's/<p class="post-date">(Published on )?([^<]+)(<br>.*)?<\/p>/\2/')

    # Get last modified date from git
    last_modified=$(git log -1 --format=%cd --date=format:'%B %d, %Y' -- "$post" 2>/dev/null || date +'%B %d, %Y')

    # Only update if not already in the new format with both dates
    if ! grep -q "Last updated on" "$post"; then
        # Replace the old date line with new format
        sed -i '' "s|<p class=\"post-date\">.*</p>|<p class=\"post-date\">Published on ${published_date}<br>Last updated on ${last_modified}</p>|" "$post"
        echo "  ✓ Updated: Published on ${published_date} | Last updated on ${last_modified}"
    else
        echo "  ⊘ Skipped (already has both dates)"
    fi
done

echo ""
echo "Done! All posts have been updated."
