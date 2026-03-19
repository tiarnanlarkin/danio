# AppCard Migration Guide

## Task
Migrate raw `Card()` widgets to `AppCard()` in your assigned file.

## AppCard API
```dart
AppCard(
  padding: AppCardPadding.compact,  // or .standard, .spacious, .none
  backgroundColor: Color?,            // optional override
  child: Widget,
)
```

**Important:** AppCardPadding values are:
- `compact` = 8dp (NOT "sm")
- `standard` = 16dp (NOT "md")
- `spacious` = 24dp
- `none` = 0dp

## Migration Pattern

**Before:**
```dart
Card(
  margin: EdgeInsets.zero,
  child: Padding(
    padding: const EdgeInsets.all(12),
    child: Column(...)
  ),
)
```

**After:**
```dart
AppCard(
  padding: AppCardPadding.compact,  // 12dp ≈ compact (8dp), use standard (16dp) if closer
  child: Column(...),
)
```

## Common Patterns

### Pattern 1: Card with Padding
```dart
// Before
Card(
  margin: EdgeInsets.zero,
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: content,
  ),
)

// After
AppCard(
  padding: AppCardPadding.standard,  // 16dp = standard
  child: content,
)
```

### Pattern 2: Card with Custom Color
```dart
// Before
Card(
  margin: EdgeInsets.zero,
  color: AppColors.warning,
  child: Padding(...),
)

// After
AppCard(
  padding: AppCardPadding.standard,
  backgroundColor: AppColors.warning,
  child: content,
)
```

### Pattern 3: Card with No Padding
```dart
// Before
Card(
  margin: EdgeInsets.zero,
  child: ListTile(...),
)

// After
AppCard(
  padding: AppCardPadding.none,
  child: ListTile(...),
)
```

## Padding Conversion Chart
- `EdgeInsets.all(8)` → `AppCardPadding.compact`
- `EdgeInsets.all(12)` → `AppCardPadding.compact` (closest)
- `EdgeInsets.all(16)` → `AppCardPadding.standard`
- `EdgeInsets.all(24)` → `AppCardPadding.spacious`
- `AppSpacing.md` (16) → `AppCardPadding.standard`

## Process
1. Find all `Card(` instances in your file
2. For each Card:
   - Check if it wraps a Padding widget
   - Convert padding value to AppCardPadding enum
   - Remove Padding wrapper
   - Change `Card` → `AppCard`
   - Remove `margin: EdgeInsets.zero`
   - Change `color:` → `backgroundColor:`
3. Test build after ALL changes
4. Fix any syntax errors
5. Commit with message: `feat: migrate [filename] to AppCard`

## Success Criteria
- ✅ All Card instances converted to AppCard
- ✅ Build succeeds (`flutter build apk --debug`)
- ✅ No syntax errors
- ✅ Changes committed to git

## Notes
- AppCard already imported in most files (`import '../widgets/core/app_card.dart'`)
- If not imported, add it
- Don't migrate Cards inside ExpansionTiles (breaks styling)
- Test incrementally if file has 20+ instances

## Example Commit
```bash
git add lib/screens/analytics_screen.dart
git commit -m "feat: migrate analytics_screen to AppCard (22 instances)"
```
