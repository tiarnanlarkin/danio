#!/usr/bin/env bash
set -euo pipefail

# Safe Danio save helper. Refuses to commit from main.
cd "/mnt/c/Users/larki/Documents/Danio Aquarium App Project/repo"

branch="$(git branch --show-current)"
if [[ -z "$branch" ]]; then
  echo "Error: could not determine current branch." >&2
  exit 1
fi

if [[ "$branch" == "main" ]]; then
  echo "Refusing to commit or push directly from main." >&2
  echo "Create a branch first, for example:" >&2
  echo "  git checkout -b fix/short-description" >&2
  exit 1
fi

echo "Checking for changes on branch $branch..."
git status --short

if git diff --quiet && git diff --cached --quiet; then
  echo "No changes to commit."
else
  git add -A
  git commit -m "Work session: $(date '+%Y-%m-%d %H:%M')"
fi

echo "Pushing $branch to origin..."
git push -u origin "$branch"

echo "Work saved to GitHub on branch $branch."
echo "Remote: https://github.com/tiarnanlarkin/danio"
