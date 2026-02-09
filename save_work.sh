#!/bin/bash
# Simple workflow to save all work to remote repo
# Run this after each build/work session

cd "/mnt/c/Users/larki/Documents/Aquarium App Dev/repo"

echo "📦 Checking for changes..."

# Stage all changes
git add -A

# Check if there are changes to commit
if git diff-staged --quiet; then
  echo "✅ No changes to commit - everything already saved"
else
  echo "💾 Committing changes..."
  # Commit with timestamp
  git commit -m "Work session: $(date '+%Y-%m-%d %H:%M')"
fi

echo "🚀 Pushing to remote..."
git push origin master

echo ""
echo "✅ All work saved to GitHub!"
echo "   View at: https://github.com/tiarnanlarkin/aquarium-app"
