#!/bin/bash

# Script to find opportunities for const constructors
# This helps identify widgets that can be made const for better performance

echo "=== Finding Const Constructor Opportunities ==="
echo ""

echo "1. StatelessWidget classes without const widgets:"
echo "---------------------------------------------------"
grep -rn "class.*extends StatelessWidget" lib/screens/ lib/widgets/ | while read -r line; do
    file=$(echo "$line" | cut -d: -f1)
    linenum=$(echo "$line" | cut -d: -f2)
    
    # Check if the build method has any const widgets
    const_count=$(sed -n "${linenum},/^}/p" "$file" | grep -c "const ")
    
    if [ "$const_count" -eq 0 ]; then
        echo "$line"
    fi
done | head -20

echo ""
echo "2. Common widget patterns that should be const:"
echo "------------------------------------------------"

echo ""
echo "   a) SizedBox instances without const:"
grep -rn "SizedBox(" lib/screens/ | grep -v "const SizedBox" | wc -l
echo "      Found instances"

echo ""
echo "   b) EdgeInsets without const:"
grep -rn "EdgeInsets\." lib/screens/ | grep -v "const EdgeInsets" | wc -l
echo "      Found instances"

echo ""
echo "   c) Text widgets without const:"
grep -rn "Text(" lib/screens/ | grep -v "const Text" | grep -v "Text(" | wc -l
echo "      Found instances (approximation)"

echo ""
echo "   d) Icon widgets without const:"
grep -rn "Icon(" lib/screens/ | grep -v "const Icon" | wc -l
echo "      Found instances"

echo ""
echo "3. Widget constructors that could be const:"
echo "--------------------------------------------"
grep -rn "^\s*_[A-Z][a-zA-Z]*(" lib/screens/ | grep -v "const " | head -20

echo ""
echo "=== Summary ==="
echo "Run this command to add const to obvious cases:"
echo "  find lib -name '*.dart' -exec sed -i 's/SizedBox(/const SizedBox(/g' {} +"
echo "  (Review changes before committing!)"
echo ""
