#!/bin/bash
# Helper script to count withOpacity() calls in the codebase
# Usage: ./scripts/count_withopacity.sh (or: bash scripts/count_withopacity.sh from repo root)

# Change to repo root if needed
if [ "$(basename "$0")" != "count_withopacity.sh" ]; then
  cd "$(dirname "$0")/.." || exit
fi

echo "🔍 Counting withOpacity() calls in lib/"
echo "=========================================="

# Total count
total=$(grep -r "withOpacity" lib/ --include="*.dart" 2>/dev/null | wc -l)
echo "Total calls: $total"
echo ""

# Top 15 files
echo "Top 15 files by withOpacity count:"
echo "-----------------------------------"
grep -r "withOpacity" lib/ --include="*.dart" -c | sort -t: -k2 -rn | head -15

echo ""
echo "Target: 3 calls (only animated/dynamic opacity allowed)"
echo "Baseline: 378 calls"
echo "Progress: $((378 - total)) calls eliminated ($(echo "scale=1; (378 - $total) * 100 / 378" | bc)%)"
