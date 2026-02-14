#!/bin/bash
# Count withOpacity() calls in key screen files
# Fixed to handle subdirectories properly

cd "$(dirname "$0")/.." || exit

total=$(grep -r "withOpacity" lib/ --include="*.dart" 2>/dev/null | wc -l)

echo "Total withOpacity calls: $total"
echo ""
echo "Files by category:"
echo "High-traffic screens (most rendered):"
echo "Medium-traffic screens"
echo "Low-traffic screens"

# Check specific screen counts
high_traffic=$(find lib/screens/ -name "*screen.dart" -exec grep -l "withOpacity" {} + 2>/dev/null | awk '$2 > 5 {sum+=1} END {print "High-traffic: "sum}' 2>/dev/null)

medium_traffic=$(find lib/screens/ -name "*screen.dart" -exec grep -l "withOpacity" {} + 2>/dev/null | awk '$2 >= 3 && $2 <= 15 {sum+=1} END {print "Medium-traffic: "sum}' 2>/dev/null)

low_traffic=$(find lib/screens/ -name "*screen.dart" -exec grep -l "withOpacity" {} + 2>/dev/null | awk '$2 < 3 && $2 >= 1 {sum+=1} END {print "Low-traffic: "sum}' 2>/dev/null)

echo "High-traffic: $high_traffic"
echo "Medium-traffic: $medium_traffic"
echo "Low-traffic: $low_traffic"
echo ""
echo "Target: 3 calls (only animated/dynamic)"
echo "Progress: $((($total - 3) * 100 / 378))% eliminated"
