# Widget Library Catalog — Danio Aquarium App

> These are the shared components in `lib/widgets/`. **Always prefer these over raw Material widgets** — they carry app-specific styling, accessibility, and haptics already baked in.

---

## Table of Contents

### Core Design System (`lib/widgets/core/`)
1. [AppButton](#appbutton)
2. [AppCard](#appcard)
3. [AppChip & AppBadge](#appchip--appbadge)
4. [AppTextField](#apptextfield)
5. [AppListTile](#applisttile)
6. [AppAppBar](#appappbar)
7. [AppEmptyState & AppLoadingState](#appemptystate--apploadingstate)
8. [GlassCard](#glasscard)
9. [AnimatedCounter](#animatedcounter)
10. [BubbleLoader & FishLoader](#bubbleloader--fishloader)

### Bottom Sheets (`lib/widgets/app_bottom_sheet.dart`)
11. [showAppBottomSheet](#showappbottomsheet)
12. [showAppDragSheet](#showappdragsheet)
13. [showAppScrollableSheet](#showappscrollablesheet)

### Snack Bars (`lib/widgets/danio_snack_bar.dart`)
14. [DanioSnackBar](#daniosnackbar)

### Other Shared Widgets
15. [DanioSnackBar](#daniosnackbar)
16. [SkeletonLoader & LessonSkeleton](#skeletonloader--lessonskeleton)
17. [ErrorBoundary](#errorboundary)
18. [XpProgressBar](#xpprogressbar)
19. [SpeedDialFab](#speeddialfab)
20. [Empty / Animated Empty State](#empty--animated-empty-state)

---

## AppButton

**File:** `lib/widgets/core/app_button.dart`

The single button component for the entire app. Replaces raw `ElevatedButton`, `TextButton`, and `OutlinedButton` with branded styling, accessibility, and haptic feedback.

### Variants

| `AppButtonVariant` | Appearance | When to use |
|--------------------|------------|-------------|
| `primary` (default) | Filled amber — prominent CTA | "Save", "Continue", "Add Tank" |
| `secondary` | Outlined amber | Secondary actions alongside a primary |
| `text` | Text-only | Low-priority actions, "Cancel" |
| `destructive` | Filled red | Delete, remove — irreversible actions |
| `ghost` | Minimal / borderless | Contextual light-touch actions |

### Sizes

| `AppButtonSize` | Height | When to use |
|-----------------|--------|-------------|
| `small` | 48dp | Compact contexts |
| `medium` (default) | 48dp | Most buttons |
| `large` | 56dp | Tablet / prominent CTAs |

### Key parameters

```dart
AppButton(
  label: 'Save',                            // required — button text
  onPressed: () => save(),                  // null → disabled state
  variant: AppButtonVariant.primary,
  size: AppButtonSize.medium,
  leadingIcon: Icons.check,                 // icon before label
  trailingIcon: Icons.arrow_forward,        // icon after label
  isLoading: _isSaving,                     // shows spinner, disables tap
  isFullWidth: true,                        // expands to parent width
  semanticsLabel: 'Save tank settings',    // accessibility override
  enableHaptics: true,                      // vibration on press (default: true)
)
```

### When NOT to use raw Material buttons

Use `AppButton` everywhere inside the app. The raw `ElevatedButton` / `FilledButton` / `OutlinedButton` / `TextButton` widgets are configured in `AppTheme` but should only be used in scaffolding or third-party package output — never in app screens.

---

## AppCard

**File:** `lib/widgets/core/app_card.dart`

A composable card with five visual variants and optional interactivity.

### Variants

| `AppCardVariant` | Appearance | When to use |
|------------------|------------|-------------|
| `elevated` | White card + soft shadow | Default — feature cards, tank cards |
| `outlined` | White card + border | Secondary cards, form sections |
| `filled` | Surface-colour fill | Subtle groupings, inner sections |
| `glass` | Glassmorphism + blur | Hero / decorative cards over imagery |
| `gradient` | Gradient background | Highlighted / special-status cards |

### Padding presets

| `AppCardPadding` | dp |
|------------------|----|
| `none` | 0 |
| `compact` | 8 |
| `standard` (default) | 16 |
| `spacious` | 24 |

### Usage

```dart
AppCard(
  variant: AppCardVariant.elevated,
  padding: AppCardPadding.standard,
  onTap: () => openDetail(),          // makes card tappable with ripple
  onLongPress: () => showMenu(),
  child: Column(children: [...]),
)

// Minimal static decoration (no widget overhead)
decoration: AppCardDecoration.standard(context)
decoration: AppCardDecoration.elevated(context)
decoration: AppCardDecoration.outlined(context)
```

---

## AppChip & AppBadge

**File:** `lib/widgets/core/app_chip.dart`

### AppChip

Consolidates 30+ chip/badge variants. Use for filters, tags, and selection states.

```dart
AppChip(
  label: 'Freshwater',
  variant: AppChipVariant.filled,    // filled | outlined | tonal
  size: AppChipSize.medium,          // small | medium | large
  isSelected: _isFreshwater,
  icon: Icons.water,
  onTap: () => toggleFilter(),
  onDeleted: () => removeFilter(),   // adds × icon
)
```

### AppBadge

For notification counts and status dots:

```dart
AppBadge(count: 3)       // "3" badge
AppBadge(isDot: true)    // small dot indicator
AppBadge(label: 'New')   // text label badge
AppBadge(count: 9, pulse: true)  // animated pulse for urgent states
```

**When to use vs raw Chip:** Always use `AppChip`. It handles touch target padding, haptics, and consistent styling automatically.

---

## AppTextField

**File:** `lib/widgets/core/app_text_field.dart`

A unified text input with validation states and consistent styling.

### States

`AppTextFieldState`: `normal`, `focused`, `error`, `success`, `disabled`, `loading`

### Key parameters

```dart
AppTextField(
  label: 'Tank Name',
  hint: 'e.g. My 60L Community',
  helperText: 'Give your tank a memorable name',
  errorText: _nameError,            // non-null → error state
  controller: _nameController,
  focusNode: _nameFocus,
  keyboardType: TextInputType.text,
  textInputAction: TextInputAction.next,
  onChanged: (v) => validate(v),
  onSubmitted: (v) => submitForm(),
  maxLength: 50,
  maxLines: 1,
  obscureText: false,               // true for passwords
  leadingIcon: Icons.water,
  trailingWidget: IconButton(...),  // custom trailing (clear button, toggle)
  isLoading: _isValidating,         // spinner in trailing position
)
```

**When to use vs raw `TextField`:** Use `AppTextField` for all user input. Raw `TextField` / `TextFormField` may be used inside form packages or where a custom `InputDecoration` is genuinely needed.

---

## AppListTile

**File:** `lib/widgets/core/app_list_tile.dart`

Consolidated list tile replacing 35+ inline variants.

```dart
AppListTile(
  title: 'Neon Tetra',
  subtitle: 'Paracheirodon innesi',
  meta: 'Added 3 days ago',         // third line / metadata
  leading: FishAvatarWidget(),
  trailing: Icon(Icons.chevron_right),
  onTap: () => openDetail(),
  onLongPress: () => showMenu(),
  isSelected: false,
  isDisabled: false,
  isDestructive: false,             // red title for delete-style actions
  backgroundColor: AppColors.card,
  minHeight: 56,                    // 56dp default — accessibility compliant
)
```

**When to use vs raw `ListTile`:** Use `AppListTile` in all list screens. It enforces 56dp min height and consistent padding (`20dp horizontal`).

---

## AppAppBar

**File:** `lib/widgets/core/app_navigation.dart`

A pre-styled `PreferredSizeWidget` that matches `AppTheme.appBarTheme`.

```dart
Scaffold(
  appBar: AppAppBar(
    title: 'My Tanks',
    actions: [
      IconButton(icon: Icon(Icons.add), onPressed: addTank),
    ],
    transparent: false,          // true → clear background over imagery
    bottom: TabBar(...),         // optional tab bar
  ),
)
```

**When to use vs raw `AppBar`:** `AppAppBar` sets the correct title style (`AppTypography.headlineSmall`), eliminates shadow, and centres the title consistently. Use it everywhere.

---

## AppEmptyState & AppLoadingState

**File:** `lib/widgets/core/app_states.dart`

### AppEmptyState

Display when a list or screen has nothing to show.

```dart
AppEmptyState(
  variant: EmptyStateVariant.noData,   // noData | noResults | offline | unavailable | getStarted
  icon: Icons.set_meal,
  title: 'No fish yet',
  message: 'Add your first fish to get started!',
  actionLabel: 'Add Fish',
  onAction: () => navigator.push(AddFishRoute()),
  secondaryActionLabel: 'Browse Catalogue',
  onSecondaryAction: () => openCatalogue(),
)
```

### AppLoadingState

Full-screen loading indicator with optional message:

```dart
AppLoadingState(message: 'Loading your tanks...')
```

**When to use vs raw `CircularProgressIndicator`:** Use `AppEmptyState` / `AppLoadingState` for full-screen states. Inline loading (inside buttons, text fields) uses the `isLoading` parameter on the respective component.

---

## GlassCard

**File:** `lib/widgets/core/glass_card.dart`

A premium glassmorphism card with `BackdropFilter` blur. Use for hero cards placed over imagery or gradient backgrounds.

```dart
GlassCard(
  variant: GlassVariant.frosted,    // frosted | soft | aurora | cozy | watercolor
  blurAmount: 10,                   // blur intensity
  padding: EdgeInsets.all(AppSpacing.md),
  borderRadius: AppRadius.largeRadius,
  tintColor: AppColors.primaryAlpha10,
  onTap: () => openCard(),
  child: CardContent(),
)
```

**Performance note:** `BackdropFilter` is expensive. Use `GlassCard` sparingly — hero cards only, not in long lists.

---

## AnimatedCounter

**File:** `lib/widgets/core/animated_counter.dart`

Animates a numeric value change (count up / count down). Used for XP, streaks, scores.

```dart
AnimatedCounter(
  value: xpPoints,       // animates to this value when it changes
  duration: AppDurations.medium4,
  style: AppTypography.headlineMedium.copyWith(color: AppColors.xp),
)
```

---

## BubbleLoader & FishLoader

**File:** `lib/widgets/core/bubble_loader.dart`, `fish_loader.dart`

App-branded loading animations:

```dart
// Floating bubbles loader (for list loading states)
BubbleLoader(size: 48)

// Animated fish mascot loader (for full-screen loading)
FishLoader(size: 80, message: 'Fetching your fish...')
```

Use `FishLoader` for full-screen loading. Use `BubbleLoader` inside cards and tiles.

---

## showAppBottomSheet

**File:** `lib/widgets/app_bottom_sheet.dart`

**Pattern A:** Card-style sheet — rounded corners, margin, and inner padding. Most common variant.

```dart
showAppBottomSheet(
  context: context,
  child: MySheetContent(),
  padding: EdgeInsets.all(AppSpacing.lg2),   // default
  margin: EdgeInsets.all(AppSpacing.md),     // default — insets from screen edge
  isScrollControlled: true,                  // default — sheet can grow
  maxHeightFraction: 0.85,                   // optional max height cap
)
```

**When to use:** Confirmation dialogs, filter panels, quick-add forms, detail previews.

---

## showAppDragSheet

**File:** `lib/widgets/app_bottom_sheet.dart`

**Pattern B:** Material 3 native sheet with drag handle. The `builder` receives a `BuildContext`.

```dart
showAppDragSheet(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (ctx) => MyDraggableSheetContent(),
)
```

**When to use:** Sheets that the user should be able to resize by dragging (settings panels, detail sheets).

---

## showAppScrollableSheet

**File:** `lib/widgets/app_bottom_sheet.dart`

**Pattern C:** `DraggableScrollableSheet` wrapper — scrollable content with snap-to sizes.

```dart
showAppScrollableSheet(
  context: context,
  initialSize: 0.5,   // 50% of screen height
  minSize: 0.25,
  maxSize: 0.9,
  builder: (ctx, scrollController) => ListView(
    controller: scrollController,
    children: [...],
  ),
)
```

**When to use:** Long lists inside a bottom sheet (fish catalogue picker, parameter history).

---

## DanioSnackBar

**File:** `lib/widgets/danio_snack_bar.dart`

Semantic, consistently-styled snack bars. Delegates to `AppFeedback` for implementation.

### Quick API

```dart
// Generic (choose type explicitly)
DanioSnackBar.show(context, 'Tank saved!');
DanioSnackBar.show(context, 'Network error', type: SnackType.error, onRetry: retry);

// Typed convenience methods
DanioSnackBar.success(context, 'Fish added!');
DanioSnackBar.error(context, 'Could not save', onRetry: () => save());
DanioSnackBar.info(context, 'pH readings update every 10 minutes');
DanioSnackBar.warning(context, 'Ammonia is elevated');
DanioSnackBar.dismiss(context);  // remove current snack bar
```

### SnackType

| Type | Colour | When |
|------|--------|------|
| `neutral` | Dark (default) | General messages |
| `success` | Green | Operation succeeded |
| `error` | Red | Something went wrong |
| `info` | Blue | Neutral information |
| `warning` | Amber | Non-critical caution |

**When to use vs raw `ScaffoldMessenger`:** Always use `DanioSnackBar`. Never call `ScaffoldMessenger.of(context).showSnackBar(SnackBar(...))` directly — it bypasses app styling.

---

## SkeletonLoader & LessonSkeleton

**File:** `lib/widgets/skeleton_loader.dart`, `lesson_skeleton.dart`

Shimmer placeholder loaders while content fetches:

```dart
// Generic skeleton blocks
SkeletonLoader(width: double.infinity, height: 80)

// Lesson-specific skeleton with correct proportions
LessonSkeleton()
```

Use these instead of `CircularProgressIndicator` when loading list items or cards — they preserve layout and reduce layout shift.

---

## ErrorBoundary

**File:** `lib/widgets/error_boundary.dart`

Catches widget-tree errors and displays a graceful fallback:

```dart
ErrorBoundary(
  child: PotentiallyFragileWidget(),
  fallback: Text('Something went wrong'),   // optional custom fallback
)
```

Wrap screen bodies (especially feature screens that call external services) with `ErrorBoundary`.

---

## XpProgressBar

**File:** `lib/widgets/xp_progress_bar.dart`

Animated XP / level progress bar with level badge:

```dart
XpProgressBar(
  currentXp: 340,
  xpForNextLevel: 500,
  level: 3,
  animated: true,
)
```

---

## SpeedDialFab

**File:** `lib/widgets/speed_dial_fab.dart`

Expandable FAB with multiple child actions (add tank, add fish, log water, etc.):

```dart
SpeedDialFab(
  icon: Icons.add,
  children: [
    SpeedDialChild(icon: Icons.water, label: 'Log Water', onTap: logWater),
    SpeedDialChild(icon: Icons.set_meal, label: 'Add Fish', onTap: addFish),
    SpeedDialChild(icon: Icons.science, label: 'Add Tank', onTap: addTank),
  ],
)
```

---

## Common Widgets (`lib/widgets/common/`)

| Widget | File | Purpose |
|--------|------|---------|
| `CozyCard` | `cozy_card.dart` | Warm-cream decorative card for room UI |
| `DrawerListItem` | `drawer_list_item.dart` | Styled navigation drawer item |
| `PrimaryActionTile` | `primary_action_tile.dart` | Large tappable action tile with icon |
| `RoomHeader` | `room_header.dart` | Header with room scene branding |
| `StandardInput` | `standard_input.dart` | Thin wrapper around `AppTextField` for common defaults |

---

## Misc Widgets (at-a-glance)

| Widget | File | Purpose |
|--------|------|---------|
| `DanioDailyCard` | `danio_daily_card.dart` | Daily lesson card with streak indicator |
| `PlacementChallengeCard` | `placement_challenge_card.dart` | Onboarding assessment challenge card |
| `SeasonalTipCard` | `seasonal_tip_card.dart` | Seasonal aquarium tip callout |
| `AchievementCard` | `achievement_card.dart` | Achievement tile with tier badge |
| `AchievementUnlockedDialog` | `achievement_unlocked_dialog.dart` | Celebration modal for new achievements |
| `LevelUpDialog` | `level_up_dialog.dart` | XP level-up celebration dialog |
| `LearningStreakBadge` | `learning_streak_badge.dart` | Compact streak flame badge |
| `StreakCalendar` | `streak_calendar.dart` | Monthly activity calendar heatmap |
| `DifficultyBadge` | `difficulty_badge.dart` | Beginner / Intermediate / Expert pill |
| `WaterTrendArrows` | `water_trend_arrows.dart` | ↑↓ trend indicator for water params |
| `CyclingStatusCard` | `cycling_status_card.dart` | Nitrogen cycle progress display |
| `OfflineIndicator` | `offline_indicator.dart` | Floating "You're offline" banner |
| `SyncIndicator` | `sync_indicator.dart` | Sync status dot (syncing / synced / error) |
| `CompatibilityCheckerWidget` | `compatibility_checker_widget.dart` | Fish compatibility inline checker |
| `AiStockingSuggestion` | `ai_stocking_suggestion.dart` | AI-generated stocking suggestion card |
| `HeartsOverlay` | `hearts_overlay.dart` | Lives/hearts overlay (lesson mode) |
| `XpAwardAnimation` | `xp_award_animation.dart` | Floating +XP particle animation |
| `TutorialOverlay` | `tutorial_overlay.dart` | Step-by-step tooltip overlay |
| `OptimizedImage` | `optimized_image.dart` | Cached, sized image with fallback |
| `EmptyState` | `empty_state.dart` | Simple (non-animated) empty state |
| `AnimatedEmptyState` | `animated_empty_state.dart` | Lottie/Rive animated empty state |

---

## Choosing the Right Widget

| Need | Use |
|------|-----|
| A button | `AppButton` |
| A card container | `AppCard` |
| A filter/tag | `AppChip` |
| A notification count | `AppBadge` |
| A text input | `AppTextField` |
| A list row | `AppListTile` |
| A bottom sheet | `showAppBottomSheet` / `showAppDragSheet` / `showAppScrollableSheet` |
| A snack bar | `DanioSnackBar` |
| An empty screen state | `AppEmptyState` |
| A loading screen state | `AppLoadingState` |
| A loading placeholder in a list | `SkeletonLoader` |
| A glassmorphism card | `GlassCard` |
| A premium card over imagery | `GlassCard(variant: .frosted)` |
| A standard non-interactive card | `AppCardDecoration.standard(context)` (BoxDecoration) |
