#!/bin/bash
# AppCard Migration Script
# Converts raw Card widgets to AppCard for consistency

set -e

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
APP_ROOT="$REPO_ROOT/apps/aquarium_app"

cd "$APP_ROOT"

echo "🎨 AppCard Migration Script"
echo "============================"
echo ""

# Count current usage
echo "📊 Current Status:"
echo "  Raw Card usage: $(grep -r "Card(" lib/screens/*.dart 2>/dev/null | wc -l)"
echo "  AppCard usage: $(grep -r "AppCard(" lib/screens/*.dart 2>/dev/null | wc -l)"
echo ""

# Backup first
echo "💾 Creating backup..."
BACKUP_DIR="/tmp/card_migration_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
cp -r lib/screens "$BACKUP_DIR/"
echo "  ✅ Backup created: $BACKUP_DIR"
echo ""

# Migration patterns
echo "🔄 Running migrations..."

# Pattern 1: Simple Card with child only
# Card(child: ...) → AppCard(child: ...)
find lib/screens -name "*.dart" -type f -exec sed -i 's/\bCard(/AppCard(/g' {} \;

# Add import if not present
for file in lib/screens/*.dart; do
    if grep -q "AppCard(" "$file" && ! grep -q "import.*app_card" "$file"; then
        # Find the last import line
        last_import=$(grep -n "^import" "$file" | tail -1 | cut -d: -f1)
        if [ -n "$last_import" ]; then
            # Insert after last import
            sed -i "${last_import}a import '../widgets/core/app_card.dart';" "$file"
        fi
    fi
done

echo "  ✅ Migration complete"
echo ""

# Show results
echo "📊 Results:"
echo "  Raw Card usage: $(grep -r "Card(" lib/screens/*.dart 2>/dev/null | wc -l)"
echo "  AppCard usage: $(grep -r "AppCard(" lib/screens/*.dart 2>/dev/null | wc -l)"
echo ""

echo "✅ Migration complete!"
echo ""
echo "Next steps:"
echo "  1. Run 'flutter analyze' to check for issues"
echo "  2. Fix any compilation errors (Card-specific props)"
echo "  3. Test app visually"
echo "  4. Commit changes"
echo ""
echo "Backup location: $BACKUP_DIR"
