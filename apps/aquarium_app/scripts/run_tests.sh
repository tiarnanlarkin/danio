#!/bin/bash
# Run all Danio tests locally
set -e
echo "🔍 Running static analysis..."
~/flutter/bin/flutter analyze --no-pub
echo "✅ Analysis passed"
echo ""
echo "🧪 Running unit tests..."
~/flutter/bin/flutter test test/
echo "✅ Unit tests passed"
echo ""
echo "📦 Running widget tests..."
~/flutter/bin/flutter test test/widget_tests/
echo "✅ Widget tests passed"
echo ""
echo "🎉 All checks passed!"
