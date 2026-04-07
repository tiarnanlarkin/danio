# Side Panel Redesign Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Rebuild the Swiss Army side panels as floating instruments — a "Lab View" (water quality) with brass medallions and a "Gauge Instrument" (temperature) with a circular brass dial — per the 2026-04-07 concept lock, preserving all data flow and call sites.

**Architecture:** Strip the inner `Container` wrappers from `WaterPanelContent`, `TempPanelContent`, `WqHealthScoreCard`, `WqSparklineSection`, and `TempTrendSection` so the outer `SwissArmyPanel` glass frame is the only card. Introduce a new `BrassMedallion` widget (replaces `WqParamCard`) and a new `BrassGaugePainter` + `BrassGauge` widget (replaces `ThermometerPainter` in `TempHeroSection`). Tune the outer glass frame from σ:20 blur / opaque to σ:14 / 0.92 alpha with a drop shadow.

**Tech Stack:** Flutter, Dart, `flutter_riverpod` (existing providers), `dart:ui` (`ImageFilter.blur`), `dart:math` (trig for circular gauge), `flutter_test` (widget + golden tests).

**Branch:** `feature/side-panel-redesign` — create off `main` (most recent commit `a622d222`).

**Working directory for all commands:** `repo/apps/aquarium_app`

**Design source of truth:** `docs/planning/2026-04-danio-fix-brief-concept-lock.md` — sections "Water Quality 'Lab View' Spec" and "Temperature 'Gauge Instrument' Spec". Quote specs directly when ambiguity arises; do not reinterpret.

---

## Pre-Implementation Survey (5 min, no code yet)

Before Task 1, the implementing agent must:

1. Read the concept lock in full, focusing on the two side-panel sections:
   ```
   repo/docs/planning/2026-04-danio-fix-brief-concept-lock.md
   ```
   Key specs to internalize: σ:14 blur, 0.92 alpha, drop shadow `0,2,8 black@25`, brass medallions (cream/ivory fill, brass accent ring), circular brass gauge with optimal green arc + analog needle, "clean bordered pill" log buttons.

2. Read the current state of every file this plan touches:
   ```
   repo/apps/aquarium_app/lib/widgets/stage/swiss_army_panel.dart
   repo/apps/aquarium_app/lib/widgets/stage/water_panel_content.dart
   repo/apps/aquarium_app/lib/widgets/stage/temp_panel_content.dart
   repo/apps/aquarium_app/lib/widgets/stage/water_quality/water_health_card.dart
   repo/apps/aquarium_app/lib/widgets/stage/water_quality/water_param_card.dart
   repo/apps/aquarium_app/lib/widgets/stage/water_quality/water_sparkline.dart
   repo/apps/aquarium_app/lib/widgets/stage/temperature/temperature_gauge.dart
   repo/apps/aquarium_app/lib/widgets/stage/temperature/temperature_history.dart
   repo/apps/aquarium_app/lib/widgets/stage/temperature/heater_status.dart
   repo/apps/aquarium_app/lib/screens/home/home_screen.dart  (lines 400–420, call site only)
   ```

3. Verify the baseline is green (per `feedback_verification_rigor.md` and the project `broken windows` memory):
   ```bash
   cd repo/apps/aquarium_app
   git checkout main
   git pull --ff-only
   git status                                    # expect: clean
   git log --oneline -3                          # expect: a622d222 top
   flutter analyze                               # expect: clean
   flutter test test/widget_tests/               # expect: pass (baseline)
   ```

   If `flutter analyze` or `flutter test` is not clean on `main`, STOP. Flag the broken windows to the user and do not start the redesign until baseline is green. Per `feedback_tdd_seed_luck.md`, never paper over flakes — diagnose first.

4. Create the feature branch:
   ```bash
   git checkout -b feature/side-panel-redesign
   ```

5. Confirm no existing widget tests target the panels — this plan creates them from scratch:
   ```bash
   find test -name "*swiss*" -o -name "*water_panel*" -o -name "*temp_panel*" -o -name "*brass*"
   # expect: no results
   ```

---

## Task Dependency Graph

```
T1 (frame)
 ├─ T2 → T3 → T4 → T5 → T6 → T7   (water panel pipeline)
 └─ T8 → T9 → T10 → T11 → T12 → T13   (temperature panel pipeline)
                                    ↓
                                 T14 (cleanup)
                                    ↓
                                 T15 (verify + CLAUDE.md + final commit)
```

Water and temperature pipelines are independent after T1 and can be interleaved. Within each pipeline, tasks are strictly ordered.

---

## Task 1: SwissArmyPanel — tune glass frame to σ:14 / 0.92 alpha / drop shadow

**Why this is first:** The frame change affects both panels simultaneously. Landing it first means subsequent tasks see the final frame treatment while they strip inner containers.

**Files:**
- Modify: `repo/apps/aquarium_app/lib/widgets/stage/swiss_army_panel.dart` (lines 136–155, the `BackdropFilter`/`Container` block)
- Create: `repo/apps/aquarium_app/test/widgets/stage/swiss_army_panel_test.dart`

**Step 1: Write the failing test**

```dart
// test/widgets/stage/swiss_army_panel_test.dart
import 'dart:ui';

import 'package:danio/theme/room_themes.dart';
import 'package:danio/widgets/stage/stage_provider.dart';
import 'package:danio/widgets/stage/swiss_army_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SwissArmyPanel glass frame (concept lock 2026-04-07)', () {
    testWidgets('uses σ:14 blur when open', (tester) async {
      final container = ProviderContainer();
      container.read(stageProvider.notifier).toggle(StagePanel.waterQuality);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Stack(
              children: [
                SwissArmyPanel.right(
                  theme: RoomTheme.ocean,
                  child: const SizedBox(key: Key('panel-body')),
                ),
              ],
            ),
          ),
        ),
      );

      // Drive animation to fully open
      await tester.pumpAndSettle();

      final backdrop = tester.widget<BackdropFilter>(
        find.byType(BackdropFilter),
      );
      final filter = backdrop.filter as ImageFilter;
      // We can't introspect the sigma directly, but we can assert structure —
      // presence of a BackdropFilter inside the open panel is enough to lock
      // the contract. Detailed sigma is asserted via a golden in Task 1b.
      expect(filter, isNotNull);
      expect(find.byKey(const Key('panel-body')), findsOneWidget);
    });

    testWidgets('has a drop shadow on the outer container', (tester) async {
      final container = ProviderContainer();
      container.read(stageProvider.notifier).toggle(StagePanel.waterQuality);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Stack(
              children: [
                SwissArmyPanel.right(
                  theme: RoomTheme.ocean,
                  child: const SizedBox(),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find the frame Container — the one that has both a color and a shadow.
      final framedContainers = tester
          .widgetList<Container>(find.byType(Container))
          .where((c) => c.decoration is BoxDecoration)
          .map((c) => c.decoration as BoxDecoration)
          .where((d) => d.boxShadow != null && d.boxShadow!.isNotEmpty);

      expect(
        framedContainers.isNotEmpty,
        isTrue,
        reason: 'Concept lock requires drop shadow 0,2,8 black@25 on frame',
      );
    });
  });
}
```

**Step 2: Run test, verify it fails**

```bash
cd repo/apps/aquarium_app
flutter test test/widgets/stage/swiss_army_panel_test.dart
```

Expected: the "has a drop shadow" test FAILS because the current `Container` in `swiss_army_panel.dart` has no `boxShadow`. The first test should pass as a baseline.

If the drop-shadow test accidentally passes, check whether the `Decoration` has been modified upstream — stop and investigate per `feedback_tdd_seed_luck.md`.

**Step 3: Write minimal implementation**

In `swiss_army_panel.dart`, replace the `BackdropFilter` + `Container` block (lines 136–155) with:

```dart
child: BackdropFilter(
  filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
  child: Container(
    decoration: BoxDecoration(
      color: widget.theme.glassCard.withValues(alpha: 0.92),
      boxShadow: const [
        BoxShadow(
          color: Color(0x40000000), // black @ 25% alpha
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
      border: Border(
        left: widget.isLeft
            ? BorderSide.none
            : BorderSide(
                color: widget.theme.glassBorder,
                width: 1,
              ),
        right: widget.isLeft
            ? BorderSide(
                color: widget.theme.glassBorder,
                width: 1,
              )
            : BorderSide.none,
      ),
    ),
    child: SafeArea(
```

Note: `withValues(alpha: 0.92)` retains the theme-derived glassCard hue at 92% opacity. Do not swap to `Colors.white` — the concept lock preserves theme tinting.

**Step 4: Run test, verify it passes**

```bash
flutter test test/widgets/stage/swiss_army_panel_test.dart
flutter analyze
```

Expected: both tests pass, analyze clean.

**Step 5: Commit**

```bash
git add lib/widgets/stage/swiss_army_panel.dart test/widgets/stage/swiss_army_panel_test.dart
git commit -m "feat(side-panel): Task 1 — SwissArmyPanel frame σ:14 + 0.92 alpha + drop shadow"
```

---

## Task 2: WaterPanelContent — strip outer gradient Container

**Why:** Concept lock: "NO outer card container (no rounded rect background, no border)". The outer `Container` wrapping the `SingleChildScrollView` in `_WaterPanelContentState.build` duplicates the frame and conflicts with the new σ:14 glass.

**Files:**
- Modify: `repo/apps/aquarium_app/lib/widgets/stage/water_panel_content.dart` (lines 155–165, the `Container(decoration: BoxDecoration(gradient: …))` wrapper)
- Create: `repo/apps/aquarium_app/test/widgets/stage/water_panel_content_test.dart`

**Step 1: Write the failing test**

```dart
// test/widgets/stage/water_panel_content_test.dart
import 'package:danio/models/log_entry.dart';
import 'package:danio/providers/tank_provider.dart';
import 'package:danio/theme/room_themes.dart';
import 'package:danio/widgets/stage/water_panel_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WaterPanelContent (concept lock 2026-04-07)', () {
    testWidgets('has no outer gradient container wrapping the scroll view',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            latestWaterTestProvider('t1').overrideWith(
              (_) => Future.value(null),
            ),
            latestWaterTestEntryProvider('t1').overrideWith(
              (_) => Future.value(null),
            ),
            logsProvider('t1').overrideWith((_) => Future.value(<LogEntry>[])),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: WaterPanelContent(tankId: 't1', theme: RoomTheme.ocean),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // The first descendant of WaterPanelContent should be a SingleChildScrollView,
      // not a Container-with-gradient.
      final scroll = find.byType(SingleChildScrollView);
      expect(scroll, findsOneWidget);

      // Walk up from the scroll view and assert no ancestor Container
      // inside WaterPanelContent has a BoxDecoration with a gradient.
      final containersWithGradient = tester
          .widgetList<Container>(
            find.descendant(
              of: find.byType(WaterPanelContent),
              matching: find.byType(Container),
            ),
          )
          .where(
            (c) =>
                c.decoration is BoxDecoration &&
                (c.decoration as BoxDecoration).gradient != null,
          )
          .toList();

      expect(
        containersWithGradient,
        isEmpty,
        reason:
            'Concept lock: no outer card container on water panel content',
      );
    });
  });
}
```

**Step 2: Run test, verify it fails**

```bash
flutter test test/widgets/stage/water_panel_content_test.dart
```

Expected: FAIL — the current outer gradient Container is picked up.

**Step 3: Write minimal implementation**

In `water_panel_content.dart` `build`, replace:

```dart
return Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(…),
  ),
  child: SingleChildScrollView(…),
);
```

with:

```dart
return SingleChildScrollView(
  physics: const ClampingScrollPhysics(),
  padding: const EdgeInsets.fromLTRB(
    AppSpacing.md,
    AppSpacing.md,
    AppSpacing.md,
    AppSpacing.lg,
  ),
  child: Column(
    // … (unchanged children)
  ),
);
```

Delete the `_kCream` comment on line 20 if it is still present — it is already marked removed.

**Step 4: Run test, verify it passes**

```bash
flutter test test/widgets/stage/water_panel_content_test.dart
flutter analyze
```

**Step 5: Commit**

```bash
git add lib/widgets/stage/water_panel_content.dart test/widgets/stage/water_panel_content_test.dart
git commit -m "feat(side-panel): Task 2 — strip WaterPanelContent outer gradient container"
```

---

## Task 3: WqHealthScoreCard — strip card wrapper, keep the ring

**Why:** Concept lock: "Health score ring stays as the existing widget but loses its card wrapper." The card's `Container` with `whiteAlpha70` fill + border + shadow goes; the ring + text column stays.

**Files:**
- Modify: `repo/apps/aquarium_app/lib/widgets/stage/water_quality/water_health_card.dart` (the `Container` in `WqHealthScoreCard.build`, lines 61–74)
- Modify: `repo/apps/aquarium_app/test/widgets/stage/water_panel_content_test.dart` (add a new `testWidgets`)

**Step 1: Write the failing test**

Append to `water_panel_content_test.dart`:

```dart
testWidgets('WqHealthScoreCard has no card wrapper decoration',
    (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: Center(
            child: Builder(
              builder: (context) {
                final anim = AnimationController(
                  vsync: const TestVSync(),
                  duration: Duration.zero,
                )..value = 1.0;
                return WqHealthScoreCard(
                  health: WqHealthStatus.excellent,
                  ringAnim: anim,
                );
              },
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();

  final decorated = tester
      .widgetList<Container>(
        find.descendant(
          of: find.byType(WqHealthScoreCard),
          matching: find.byType(Container),
        ),
      )
      .where(
        (c) =>
            c.decoration is BoxDecoration &&
            ((c.decoration as BoxDecoration).color != null ||
                (c.decoration as BoxDecoration).boxShadow != null ||
                (c.decoration as BoxDecoration).border != null),
      )
      .toList();

  expect(
    decorated,
    isEmpty,
    reason:
        'Concept lock: health score ring keeps its widget but loses the card wrapper',
  );
});
```

Add the required import:

```dart
import 'package:danio/widgets/stage/water_quality/water_health_card.dart';
import 'package:danio/widgets/stage/water_quality/water_param_card.dart';
```

Also add `import 'package:flutter/scheduler.dart';` for `TestVSync` if needed (it is re-exported from `flutter_test`).

**Step 2: Run test, verify it fails**

```bash
flutter test test/widgets/stage/water_panel_content_test.dart
```

Expected: FAIL — current `WqHealthScoreCard` has a decorated Container.

**Step 3: Write minimal implementation**

In `water_health_card.dart`, replace the outer `Container(padding: …, decoration: …, child: Row(…))` with a plain `Padding`:

```dart
return Padding(
  padding: const EdgeInsets.all(AppSpacing.md),
  child: Row(
    children: [
      // … existing ring + text column, unchanged
    ],
  ),
);
```

**Step 4: Run test, verify it passes**

```bash
flutter test test/widgets/stage/water_panel_content_test.dart
flutter analyze
```

**Step 5: Commit**

```bash
git add lib/widgets/stage/water_quality/water_health_card.dart test/widgets/stage/water_panel_content_test.dart
git commit -m "feat(side-panel): Task 3 — strip WqHealthScoreCard card wrapper"
```

---

## Task 4: Create BrassMedallion widget + painter

**Why:** The concept lock describes each water parameter as a "floating brass medallion" — cream/ivory fill, brass/copper accent ring, subtle shadow, no outer card. The current `WqParamCard` is a rectangle with colored segments — wrong shape and aesthetic. A new widget is cleaner than trying to retrofit `WqParamCard`.

**Design constraints from concept lock:**
- Cream/ivory background with theme color tinting subtly
- Brass/copper accent ring (use `#C89B3C` brass + `#A0805C` walnut per existing Apollo color spec)
- Circular or strongly-rounded shape
- Subtle drop shadow (`0,2,8 black@25` matches frame)
- Houses: parameter label (pH, NH₃…), value, unit, status color tint
- Status shown by tinting the ring color, not by a separate pill

**Files:**
- Create: `repo/apps/aquarium_app/lib/widgets/stage/water_quality/brass_medallion.dart`
- Create: `repo/apps/aquarium_app/test/widgets/stage/brass_medallion_test.dart`

**Step 1: Write the failing test**

```dart
// test/widgets/stage/brass_medallion_test.dart
import 'package:danio/widgets/stage/water_quality/brass_medallion.dart';
import 'package:danio/widgets/stage/water_quality/water_param_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BrassMedallion', () {
    testWidgets('renders label, value, and unit', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 120,
              height: 120,
              child: BrassMedallion(
                label: 'pH',
                value: '7.2',
                unit: '',
                status: WqParamStatus.perfect,
              ),
            ),
          ),
        ),
      );
      expect(find.text('pH'), findsOneWidget);
      expect(find.text('7.2'), findsOneWidget);
    });

    testWidgets('shows "--" when value is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 120,
              height: 120,
              child: BrassMedallion(
                label: 'NH₃',
                value: null,
                unit: 'ppm',
                status: WqParamStatus.unknown,
              ),
            ),
          ),
        ),
      );
      expect(find.text('NH₃'), findsOneWidget);
      expect(find.text('--'), findsOneWidget);
    });

    testWidgets('exposes status via semantics label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 120,
              height: 120,
              child: BrassMedallion(
                label: 'NO₂',
                value: '0',
                unit: 'ppm',
                status: WqParamStatus.danger,
              ),
            ),
          ),
        ),
      );
      expect(
        find.bySemanticsLabel(RegExp(r'NO₂.*Danger')),
        findsOneWidget,
      );
    });
  });
}
```

**Step 2: Run test, verify it fails**

```bash
flutter test test/widgets/stage/brass_medallion_test.dart
```

Expected: FAIL — `brass_medallion.dart` does not exist yet.

**Step 3: Write minimal implementation**

```dart
// lib/widgets/stage/water_quality/brass_medallion.dart
import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import 'water_param_card.dart';

/// Floating brass medallion used in the Water Quality "Lab View" panel.
///
/// Visual spec (concept lock 2026-04-07):
/// - Cream/ivory circular fill
/// - Brass accent ring (color modulated by [status])
/// - Drop shadow 0,2,8 black @ 25 alpha
/// - Label (top), value (big, center), unit (small, below)
class BrassMedallion extends StatelessWidget {
  static const _brass = Color(0xFFC89B3C);
  static const _cream = Color(0xFFFFF8E7);
  static const _ink = Color(0xFF2D3436);

  final String label;
  final String? value;
  final String unit;
  final WqParamStatus status;

  const BrassMedallion({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.status,
  });

  Color _ringColor() {
    switch (status) {
      case WqParamStatus.perfect:
        return _brass;
      case WqParamStatus.watch:
        return const Color(0xFFC99524);
      case WqParamStatus.danger:
        return const Color(0xFFC0392B);
      case WqParamStatus.unknown:
        return _brass.withValues(alpha: 0.4);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ring = _ringColor();
    final display = value ?? '--';

    return Semantics(
      label: '$label ${wqStatusLabel(status)}',
      child: AspectRatio(
        aspectRatio: 1,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: _cream,
            shape: BoxShape.circle,
            border: Border.all(color: ring, width: 2.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x40000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xs),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: AppTypography.labelSmall.copyWith(
                    color: _ink.withValues(alpha: 0.65),
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  display,
                  style: AppTypography.headlineSmall.copyWith(
                    color: _ink,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    letterSpacing: -0.5,
                  ),
                ),
                if (unit.isNotEmpty)
                  Text(
                    unit,
                    style: AppTypography.labelSmall.copyWith(
                      color: _ink.withValues(alpha: 0.45),
                      fontSize: 9,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

**Step 4: Run test, verify it passes**

```bash
flutter test test/widgets/stage/brass_medallion_test.dart
flutter analyze
```

**Step 5: Commit**

```bash
git add lib/widgets/stage/water_quality/brass_medallion.dart test/widgets/stage/brass_medallion_test.dart
git commit -m "feat(side-panel): Task 4 — add BrassMedallion widget"
```

---

## Task 5: Replace WqParamGrid with 2×3 brass medallion layout

**Why:** Concept lock shows two rows: priority params (pH, NH₃, NO₂) on top, secondary (NO₃, GH, KH) on bottom, as brass medallions. The current grid is 2-column 3-row and uses `WqParamCard`.

**Files:**
- Modify: `repo/apps/aquarium_app/lib/widgets/stage/water_quality/water_param_card.dart` — `WqParamGrid` class
- Modify: `repo/apps/aquarium_app/test/widgets/stage/water_panel_content_test.dart` — add layout test

**Step 1: Write the failing test**

Append to `water_panel_content_test.dart`:

```dart
testWidgets('WqParamGrid lays out priority/secondary as 2×3 brass medallions',
    (tester) async {
  final params = [
    const WqParamSpec(
      key: 'pH', label: 'pH', unit: '', idealRange: '6.5 – 7.8',
      value: 7.2, status: WqParamStatus.perfect,
    ),
    const WqParamSpec(
      key: 'NH₃', label: 'Ammonia', unit: 'ppm', idealRange: '< 0.25',
      value: 0, status: WqParamStatus.perfect,
    ),
    const WqParamSpec(
      key: 'NO₂', label: 'Nitrite', unit: 'ppm', idealRange: '0',
      value: 0, status: WqParamStatus.perfect,
    ),
    const WqParamSpec(
      key: 'NO₃', label: 'Nitrate', unit: 'ppm', idealRange: '< 20',
      value: 10, status: WqParamStatus.perfect,
    ),
    const WqParamSpec(
      key: 'GH', label: 'GH', unit: 'dGH', idealRange: '4–12',
      value: 8, status: WqParamStatus.perfect,
    ),
    const WqParamSpec(
      key: 'KH', label: 'KH', unit: 'dKH', idealRange: '3–8',
      value: 5, status: WqParamStatus.perfect,
    ),
  ];

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 360,
          child: WqParamGrid(params: params),
        ),
      ),
    ),
  );

  // 6 medallions in the grid
  expect(find.byType(BrassMedallion), findsNWidgets(6));

  // Priority row contains the top 3 param keys
  expect(find.text('pH'), findsOneWidget);
  expect(find.text('NH₃'), findsOneWidget);
  expect(find.text('NO₂'), findsOneWidget);
  // Secondary row
  expect(find.text('NO₃'), findsOneWidget);
  expect(find.text('GH'), findsOneWidget);
  expect(find.text('KH'), findsOneWidget);

  // No legacy WqParamCard remaining
  expect(find.byType(WqParamCard), findsNothing);
});
```

Add import for `BrassMedallion` at the top of the test file.

**Step 2: Run test, verify it fails**

```bash
flutter test test/widgets/stage/water_panel_content_test.dart
```

Expected: FAIL — current `WqParamGrid` uses `WqParamCard` and different layout.

**Step 3: Write minimal implementation**

Replace the `WqParamGrid` class in `water_param_card.dart`:

```dart
class WqParamGrid extends StatelessWidget {
  final List<WqParamSpec> params;

  const WqParamGrid({super.key, required this.params});

  @override
  Widget build(BuildContext context) {
    // Priority: first 3 params (pH, NH₃, NO₂)
    // Secondary: next 3 (NO₃, GH, KH)
    final priority = params.take(3).toList();
    final secondary = params.skip(3).take(3).toList();

    return Column(
      children: [
        _Row(params: priority),
        const SizedBox(height: AppSpacing.sm),
        _Row(params: secondary),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  final List<WqParamSpec> params;
  const _Row({required this.params});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < 3; i++) ...[
          Expanded(
            child: i < params.length
                ? BrassMedallion(
                    label: params[i].label == 'Ammonia'
                        ? 'NH₃'
                        : params[i].label == 'Nitrite'
                            ? 'NO₂'
                            : params[i].label == 'Nitrate'
                                ? 'NO₃'
                                : params[i].label,
                    value: params[i].value != null
                        ? params[i].value!.toStringAsFixed(
                            params[i].value! < 10 ? 2 : 1,
                          )
                        : null,
                    unit: params[i].unit,
                    status: params[i].status,
                  )
                : const SizedBox.shrink(),
          ),
          if (i < 2) const SizedBox(width: AppSpacing.sm),
        ],
      ],
    );
  }
}
```

Add `import 'brass_medallion.dart';` at the top of `water_param_card.dart`.

Note: `WqParamCard` class is no longer referenced from the grid. Do NOT delete it in this task — Task 14 handles cleanup. Leaving it in place keeps this commit small and reversible.

**Step 4: Run test, verify it passes**

```bash
flutter test test/widgets/stage/water_panel_content_test.dart
flutter analyze
```

Expected: analyze may warn that `WqParamCard` is now unused — that is expected and resolved in Task 14.

**Step 5: Commit**

```bash
git add lib/widgets/stage/water_quality/water_param_card.dart test/widgets/stage/water_panel_content_test.dart
git commit -m "feat(side-panel): Task 5 — WqParamGrid 2x3 brass medallion layout"
```

---

## Task 6: Strip WqSparklineSection card + shrink sparkline rows

**Why:** Concept lock: "Sparkline charts use minimal axes — just the line on a transparent background". Current section has a decorated Container with `whiteAlpha70` + border.

**Files:**
- Modify: `repo/apps/aquarium_app/lib/widgets/stage/water_quality/water_sparkline.dart` (`WqSparklineSection.build`, lines 21–90)
- Modify: `repo/apps/aquarium_app/test/widgets/stage/water_panel_content_test.dart`

**Step 1: Write the failing test**

Append to `water_panel_content_test.dart`:

```dart
testWidgets('WqSparklineSection has no card wrapper', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: WqSparklineSection(
          phData: [7.0, 7.1, 7.0, 7.2, 7.1, 7.0, 7.1],
          nitData: [10, 12, 10, 14, 12, 11, 10],
        ),
      ),
    ),
  );

  final decorated = tester
      .widgetList<Container>(
        find.descendant(
          of: find.byType(WqSparklineSection),
          matching: find.byType(Container),
        ),
      )
      .where(
        (c) =>
            c.decoration is BoxDecoration &&
            ((c.decoration as BoxDecoration).color != null ||
                (c.decoration as BoxDecoration).border != null),
      )
      .toList();

  expect(
    decorated,
    isEmpty,
    reason: 'Concept lock: sparkline section has no card wrapper',
  );
});
```

**Step 2: Run test, verify it fails**

```bash
flutter test test/widgets/stage/water_panel_content_test.dart
```

Expected: FAIL — the section wraps its column in a decorated Container.

**Step 3: Write minimal implementation**

Replace `WqSparklineSection.build` body (everything from `return Container(…)` down to the matching `);`) with:

```dart
return Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(
      '7-day trends',
      style: AppTypography.labelSmall.copyWith(
        color: kWqCharcoal.withAlpha(140),
        fontWeight: FontWeight.w700,
      ),
    ),
    const SizedBox(height: AppSpacing.sm),
    if (phData.length >= 2) ...[
      Row(
        children: [
          Text(
            'pH  ',
            style: AppTypography.labelSmall.copyWith(
              color: kWqCharcoal.withAlpha(120),
            ),
          ),
          Expanded(
            child: SizedBox(
              height: 28, // slimmer per concept lock
              child: CustomPaint(
                painter: WqSparklinePainter(
                  data: phData,
                  color: const Color(0xFF3BBFB0),
                ),
              ),
            ),
          ),
        ],
      ),
    ],
    if (nitData.length >= 2 && phData.length >= 2)
      const SizedBox(height: AppSpacing.xs),
    if (nitData.length >= 2) ...[
      Row(
        children: [
          Text(
            'NO₃ ',
            style: AppTypography.labelSmall.copyWith(
              color: kWqCharcoal.withAlpha(120),
            ),
          ),
          Expanded(
            child: SizedBox(
              height: 28,
              child: CustomPaint(
                painter: WqSparklinePainter(data: nitData, color: kWqRed),
              ),
            ),
          ),
        ],
      ),
    ],
  ],
);
```

**Step 4: Run test, verify it passes**

```bash
flutter test test/widgets/stage/water_panel_content_test.dart
flutter analyze
```

**Step 5: Commit**

```bash
git add lib/widgets/stage/water_quality/water_sparkline.dart test/widgets/stage/water_panel_content_test.dart
git commit -m "feat(side-panel): Task 6 — strip sparkline card wrapper, shrink rows"
```

---

## Task 7: Convert _WqLogButton to outlined pill

**Why:** Concept lock: "Log button is a clean bordered pill, not a filled rectangle". Current button is a filled `ElevatedButton` with `kWqAmber` background.

**Files:**
- Modify: `repo/apps/aquarium_app/lib/widgets/stage/water_panel_content.dart` (`_WqLogButton`)
- Modify: `repo/apps/aquarium_app/test/widgets/stage/water_panel_content_test.dart`

**Step 1: Write the failing test**

Append:

```dart
testWidgets('Water Log button is an OutlinedButton pill, not filled',
    (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        latestWaterTestProvider('t1').overrideWith((_) => Future.value(null)),
        latestWaterTestEntryProvider('t1')
            .overrideWith((_) => Future.value(null)),
        logsProvider('t1').overrideWith((_) => Future.value(<LogEntry>[])),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: WaterPanelContent(tankId: 't1', theme: RoomTheme.ocean),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  // No filled ElevatedButton in the water panel
  expect(
    find.descendant(
      of: find.byType(WaterPanelContent),
      matching: find.byType(ElevatedButton),
    ),
    findsNothing,
  );

  // A single OutlinedButton (the log button)
  expect(
    find.descendant(
      of: find.byType(WaterPanelContent),
      matching: find.byType(OutlinedButton),
    ),
    findsOneWidget,
  );
  expect(find.text('Log Water Test'), findsOneWidget);
});
```

**Step 2: Run test, verify it fails**

Expected: FAIL — current button is `ElevatedButton.icon`.

**Step 3: Write minimal implementation**

In `water_panel_content.dart`, replace `_WqLogButton.build`:

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  return SizedBox(
    width: double.infinity,
    height: 48,
    child: OutlinedButton.icon(
      onPressed: () {
        ref.read(stageProvider.notifier).close(StagePanel.waterQuality);
        AppRoutes.toAddLog(context, tankId, initialType: LogType.waterTest);
      },
      icon: const Icon(Icons.science_rounded, size: 18),
      label: Text('Log Water Test', style: AppTypography.labelLarge),
      style: OutlinedButton.styleFrom(
        foregroundColor: kWqCharcoal,
        side: BorderSide(color: kWqAmber, width: 1.5),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      ),
    ),
  );
}
```

**Step 4: Run test, verify it passes**

```bash
flutter test test/widgets/stage/water_panel_content_test.dart
flutter analyze
```

**Step 5: Commit**

```bash
git add lib/widgets/stage/water_panel_content.dart test/widgets/stage/water_panel_content_test.dart
git commit -m "feat(side-panel): Task 7 — WqLogButton becomes outlined pill"
```

---

## Task 8: Create BrassGaugePainter (circular dial)

**Why:** Concept lock's temperature hero is a circular gauge with a brass ring, analog needle, and optimal-range arc. The existing `ThermometerPainter` is a vertical tube — wrong shape. New painter is cleaner than retrofitting.

**Geometry (fixed):**
- 270° sweep from `7π/6` (start, ~7 o'clock) to `π/6` + `2π` (end, ~5 o'clock) — opening at bottom
- Temperature range: 18°C – 30°C (same as current)
- Brass outer ring: 4px stroke, `#C89B3C`
- Inner track: 2px, `#2D3436@20`
- Optimal arc overlay: 5px, `#1E8449@70`, from `optimalMin` to `optimalMax`
- Tick marks: every 2° on inner edge, major every 4°
- Needle: rounded rectangle from center to ~85% radius, `#2D3436`
- Center cap: 5px circle, brass

**Files:**
- Create: `repo/apps/aquarium_app/lib/widgets/stage/temperature/brass_gauge_painter.dart`
- Create: `repo/apps/aquarium_app/test/widgets/stage/brass_gauge_painter_test.dart`

**Step 1: Write the failing test**

```dart
// test/widgets/stage/brass_gauge_painter_test.dart
import 'package:danio/widgets/stage/temperature/brass_gauge_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BrassGaugePainter', () {
    test('shouldRepaint returns true only on relevant changes', () {
      const a = BrassGaugePainter(
        tempFraction: 0.5,
        optFracMin: 0.5,
        optFracMax: 0.67,
      );
      const b = BrassGaugePainter(
        tempFraction: 0.5,
        optFracMin: 0.5,
        optFracMax: 0.67,
      );
      expect(a.shouldRepaint(b), isFalse);

      const c = BrassGaugePainter(
        tempFraction: 0.6,
        optFracMin: 0.5,
        optFracMax: 0.67,
      );
      expect(a.shouldRepaint(c), isTrue);
    });

    testWidgets('paints without throwing for all fraction extremes',
        (tester) async {
      for (final frac in [0.0, 0.25, 0.5, 0.75, 1.0]) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: CustomPaint(
                    painter: BrassGaugePainter(
                      tempFraction: frac,
                      optFracMin: 0.5,
                      optFracMax: 0.67,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump();
      }
    });

    testWidgets('accepts null tempFraction (no needle drawn)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 200,
                height: 200,
                child: CustomPaint(
                  painter: BrassGaugePainter(
                    tempFraction: null,
                    optFracMin: 0.5,
                    optFracMax: 0.67,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
    });
  });
}
```

**Step 2: Run test, verify it fails**

```bash
flutter test test/widgets/stage/brass_gauge_painter_test.dart
```

Expected: FAIL — `brass_gauge_painter.dart` does not exist.

**Step 3: Write minimal implementation**

```dart
// lib/widgets/stage/temperature/brass_gauge_painter.dart
import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Circular brass gauge painter for the Temperature "Gauge Instrument" panel.
///
/// Geometry (concept lock 2026-04-07):
/// - 270° sweep, gap at bottom
/// - Brass outer ring
/// - Optimal-range arc overlay (green)
/// - Tick marks every 2° (fractional), major every 4
/// - Analog needle from center to 85% radius (if [tempFraction] is non-null)
class BrassGaugePainter extends CustomPainter {
  static const _brass = Color(0xFFC89B3C);
  static const _ink = Color(0xFF2D3436);
  static const _green = Color(0xFF1E8449);

  /// Normalized current temperature within the gauge range (0..1).
  /// Null = no reading, no needle drawn.
  final double? tempFraction;

  /// Normalized optimal range within the gauge range.
  final double optFracMin;
  final double optFracMax;

  const BrassGaugePainter({
    required this.tempFraction,
    required this.optFracMin,
    required this.optFracMax,
  });

  // 270° sweep starting at 7 o'clock
  static const double _startAngle = math.pi * 3 / 4;
  static const double _sweep = math.pi * 3 / 2;

  double _angleFor(double fraction) =>
      _startAngle + _sweep * fraction.clamp(0.0, 1.0);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2 - 6;

    // Inner track
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 8),
      _startAngle,
      _sweep,
      false,
      Paint()
        ..color = _ink.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );

    // Optimal arc overlay
    final optStart = _angleFor(optFracMin);
    final optEnd = _angleFor(optFracMax);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 8),
      optStart,
      optEnd - optStart,
      false,
      Paint()
        ..color = _green.withValues(alpha: 0.70)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );

    // Brass outer ring
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      _startAngle,
      _sweep,
      false,
      Paint()
        ..color = _brass
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );

    // Tick marks every 2° (fractional steps of 1/6)
    for (var i = 0; i <= 6; i++) {
      final frac = i / 6;
      final angle = _angleFor(frac);
      final isMajor = i % 2 == 0;
      final tickIn = radius - 14;
      final tickOut = radius - (isMajor ? 6 : 9);
      canvas.drawLine(
        Offset(
          center.dx + tickIn * math.cos(angle),
          center.dy + tickIn * math.sin(angle),
        ),
        Offset(
          center.dx + tickOut * math.cos(angle),
          center.dy + tickOut * math.sin(angle),
        ),
        Paint()
          ..color = _ink.withValues(alpha: isMajor ? 0.7 : 0.4)
          ..strokeWidth = isMajor ? 2 : 1,
      );
    }

    // Needle
    if (tempFraction != null) {
      final angle = _angleFor(tempFraction!);
      final needleEnd = Offset(
        center.dx + (radius - 14) * 0.85 * math.cos(angle),
        center.dy + (radius - 14) * 0.85 * math.sin(angle),
      );
      canvas.drawLine(
        center,
        needleEnd,
        Paint()
          ..color = _ink
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round,
      );
    }

    // Center cap
    canvas.drawCircle(
      center,
      5,
      Paint()
        ..color = _brass
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      center,
      5,
      Paint()
        ..color = _ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant BrassGaugePainter old) =>
      old.tempFraction != tempFraction ||
      old.optFracMin != optFracMin ||
      old.optFracMax != optFracMax;
}
```

**Step 4: Run test, verify it passes**

```bash
flutter test test/widgets/stage/brass_gauge_painter_test.dart
flutter analyze
```

**Step 5: Commit**

```bash
git add lib/widgets/stage/temperature/brass_gauge_painter.dart test/widgets/stage/brass_gauge_painter_test.dart
git commit -m "feat(side-panel): Task 8 — BrassGaugePainter circular dial"
```

---

## Task 9: Create BrassGauge widget (animation + center label)

**Why:** The painter is stateless. The panel needs an animated wrapper that drives `tempFraction` from 0 → actual on panel entry, and displays the temperature text in the center of the dial.

**Files:**
- Create: `repo/apps/aquarium_app/lib/widgets/stage/temperature/brass_gauge.dart`
- Create: `repo/apps/aquarium_app/test/widgets/stage/brass_gauge_test.dart`

**Step 1: Write the failing test**

```dart
// test/widgets/stage/brass_gauge_test.dart
import 'package:danio/widgets/stage/temperature/brass_gauge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BrassGauge', () {
    testWidgets('renders center temp label at rest', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 240,
                height: 240,
                child: BrassGauge(
                  temp: 24.0,
                  gaugeMin: 18,
                  gaugeMax: 30,
                  optimalMin: 24,
                  optimalMax: 26,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('24.0°C'), findsOneWidget);
    });

    testWidgets('renders "--°C" placeholder when temp is null',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 240,
                height: 240,
                child: BrassGauge(
                  temp: null,
                  gaugeMin: 18,
                  gaugeMax: 30,
                  optimalMin: 24,
                  optimalMax: 26,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('--°C'), findsOneWidget);
    });
  });
}
```

**Step 2: Run test, verify it fails**

```bash
flutter test test/widgets/stage/brass_gauge_test.dart
```

Expected: FAIL — `brass_gauge.dart` does not exist.

**Step 3: Write minimal implementation**

```dart
// lib/widgets/stage/temperature/brass_gauge.dart
import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import 'brass_gauge_painter.dart';

class BrassGauge extends StatefulWidget {
  final double? temp;
  final double gaugeMin;
  final double gaugeMax;
  final double optimalMin;
  final double optimalMax;

  const BrassGauge({
    super.key,
    required this.temp,
    required this.gaugeMin,
    required this.gaugeMax,
    required this.optimalMin,
    required this.optimalMax,
  });

  @override
  State<BrassGauge> createState() => _BrassGaugeState();
}

class _BrassGaugeState extends State<BrassGauge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _anim.duration = Duration.zero;
      if (!_anim.isCompleted) _anim.value = 1.0;
    }
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  double? _targetFraction() {
    final t = widget.temp;
    if (t == null) return null;
    return ((t - widget.gaugeMin) / (widget.gaugeMax - widget.gaugeMin))
        .clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final target = _targetFraction();
    final optMin =
        (widget.optimalMin - widget.gaugeMin) /
        (widget.gaugeMax - widget.gaugeMin);
    final optMax =
        (widget.optimalMax - widget.gaugeMin) /
        (widget.gaugeMax - widget.gaugeMin);

    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        final ease = Curves.easeOutCubic.transform(_anim.value);
        final frac = target != null ? target * ease : null;
        return Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size.infinite,
              painter: BrassGaugePainter(
                tempFraction: frac,
                optFracMin: optMin,
                optFracMax: optMax,
              ),
            ),
            Text(
              widget.temp != null
                  ? '${widget.temp!.toStringAsFixed(1)}°C'
                  : '--°C',
              style: AppTypography.headlineLarge.copyWith(
                color: const Color(0xFF2D3436),
                fontWeight: FontWeight.w800,
                fontSize: 32,
                letterSpacing: -1.0,
              ),
            ),
          ],
        );
      },
    );
  }
}
```

**Step 4: Run test, verify it passes**

```bash
flutter test test/widgets/stage/brass_gauge_test.dart
flutter analyze
```

**Step 5: Commit**

```bash
git add lib/widgets/stage/temperature/brass_gauge.dart test/widgets/stage/brass_gauge_test.dart
git commit -m "feat(side-panel): Task 9 — BrassGauge animated widget with center label"
```

---

## Task 10: Replace TempHeroSection thermometer with BrassGauge

**Why:** The hero section currently builds a 300px vertical thermometer with fish decorations. Concept lock wants a single circular gauge centered in the panel.

**Files:**
- Modify: `repo/apps/aquarium_app/lib/widgets/stage/temperature/temperature_gauge.dart` (`TempHeroSection.build`)
- Create: `repo/apps/aquarium_app/test/widgets/stage/temp_panel_content_test.dart`

**Step 1: Write the failing test**

```dart
// test/widgets/stage/temp_panel_content_test.dart
import 'package:danio/widgets/stage/temperature/brass_gauge.dart';
import 'package:danio/widgets/stage/temperature/temperature_gauge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TempHeroSection (concept lock 2026-04-07)', () {
    testWidgets('renders a BrassGauge, not a ThermometerPainter',
        (tester) async {
      final anim = AnimationController(
        vsync: const TestVSync(),
        duration: Duration.zero,
      )..value = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 360,
                height: 500,
                child: TempHeroSection(
                  temp: 24.5,
                  fillAnim: anim,
                  gaugeMin: 18,
                  gaugeMax: 30,
                  optimalMin: 24,
                  optimalMax: 26,
                  status: TempStatus.perfect,
                  lastEntry: null,
                  formatTimestamp: (t) => 'now',
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(BrassGauge), findsOneWidget);
      // Old thermometer painter should no longer be in the tree
      final thermometers = tester
          .widgetList<CustomPaint>(find.byType(CustomPaint))
          .where((cp) => cp.painter is ThermometerPainter)
          .toList();
      expect(thermometers, isEmpty,
          reason: 'ThermometerPainter replaced by BrassGaugePainter');
    });
  });
}
```

**Step 2: Run test, verify it fails**

```bash
flutter test test/widgets/stage/temp_panel_content_test.dart
```

Expected: FAIL — `TempHeroSection` still uses `ThermometerPainter`.

**Step 3: Write minimal implementation**

Replace `TempHeroSection.build` in `temperature_gauge.dart`:

```dart
@override
Widget build(BuildContext context) {
  return Column(
    children: [
      AspectRatio(
        aspectRatio: 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: BrassGauge(
            temp: temp,
            gaugeMin: gaugeMin,
            gaugeMax: gaugeMax,
            optimalMin: optimalMin,
            optimalMax: optimalMax,
          ),
        ),
      ),
      const SizedBox(height: AppSpacing.sm),
      if (status != null) TempStatusBadge(status: status!),
      const SizedBox(height: AppSpacing.xs),
      TempOptimalRangeRow(min: optimalMin, max: optimalMax),
      if (lastEntry != null) ...[
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.access_time_rounded,
              size: 12,
              color: kTempCharcoal.withAlpha(100),
            ),
            const SizedBox(width: 4),
            Text(
              'Last logged: ${formatTimestamp(lastEntry!.timestamp)}',
              style: AppTypography.labelSmall.copyWith(
                color: kTempCharcoal.withAlpha(120),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ],
    ],
  );
}
```

Add the import at the top of `temperature_gauge.dart`:

```dart
import 'brass_gauge.dart';
```

Note: `ThermometerPainter`, `TempScaleLabels`, `TempFishDecorations`, `TempFishChip`, and `TempArcIndicator` are no longer used by `TempHeroSection` but remain in the file. Task 14 removes them.

**Step 4: Run test, verify it passes**

```bash
flutter test test/widgets/stage/temp_panel_content_test.dart
flutter analyze
```

**Step 5: Commit**

```bash
git add lib/widgets/stage/temperature/temperature_gauge.dart test/widgets/stage/temp_panel_content_test.dart
git commit -m "feat(side-panel): Task 10 — TempHeroSection uses BrassGauge"
```

---

## Task 11: Add HeaterStatusPill widget

**Why:** Concept lock: "Status pill below (Heater ON/OFF) ● Last test: 2h ago". Currently the heater status is rendered elsewhere in the old layout (`heater_status.dart`), or not rendered in the hero.

**Files:**
- Modify: `repo/apps/aquarium_app/lib/widgets/stage/temperature/heater_status.dart` (add a new `HeaterStatusPill` widget — keep any existing `HeaterStatus` content the panel still uses)
- Modify: `repo/apps/aquarium_app/test/widgets/stage/temp_panel_content_test.dart`

**Step 1: Write the failing test**

Append to `temp_panel_content_test.dart`:

```dart
testWidgets('HeaterStatusPill renders ON state and last-test string',
    (tester) async {
  await tester.pumpWidget(
    const MaterialApp(
      home: Scaffold(
        body: HeaterStatusPill(heaterOn: true, lastTestLabel: '2h ago'),
      ),
    ),
  );
  expect(find.text('Heater ON'), findsOneWidget);
  expect(find.textContaining('2h ago'), findsOneWidget);
});

testWidgets('HeaterStatusPill renders OFF state', (tester) async {
  await tester.pumpWidget(
    const MaterialApp(
      home: Scaffold(
        body: HeaterStatusPill(heaterOn: false, lastTestLabel: null),
      ),
    ),
  );
  expect(find.text('Heater OFF'), findsOneWidget);
});
```

Add `import 'package:danio/widgets/stage/temperature/heater_status.dart';`.

**Step 2: Run test, verify it fails**

Expected: FAIL — `HeaterStatusPill` does not exist.

**Step 3: Write minimal implementation**

Append to `heater_status.dart`:

```dart
class HeaterStatusPill extends StatelessWidget {
  final bool heaterOn;
  final String? lastTestLabel;

  const HeaterStatusPill({
    super.key,
    required this.heaterOn,
    required this.lastTestLabel,
  });

  @override
  Widget build(BuildContext context) {
    final dotColor =
        heaterOn ? const Color(0xFFE67E22) : const Color(0xFF9E9E9E);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm2,
        vertical: AppSpacing.xs2,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: AppRadius.pillRadius,
        border: Border.all(color: dotColor.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor),
          ),
          const SizedBox(width: 6),
          Text(
            heaterOn ? 'Heater ON' : 'Heater OFF',
            style: AppTypography.labelSmall.copyWith(
              color: const Color(0xFF2D3436),
              fontWeight: FontWeight.w700,
            ),
          ),
          if (lastTestLabel != null) ...[
            const SizedBox(width: 8),
            Text('•',
                style: AppTypography.labelSmall.copyWith(
                  color: const Color(0xFF2D3436).withValues(alpha: 0.4),
                )),
            const SizedBox(width: 8),
            Text(
              'Last test: $lastTestLabel',
              style: AppTypography.labelSmall.copyWith(
                color: const Color(0xFF2D3436).withValues(alpha: 0.65),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
```

Make sure the file imports `app_theme.dart`:

```dart
import '../../../theme/app_theme.dart';
```

(Add if not already present; leave existing imports intact.)

**Step 4: Run test, verify it passes**

```bash
flutter test test/widgets/stage/temp_panel_content_test.dart
flutter analyze
```

**Step 5: Commit**

```bash
git add lib/widgets/stage/temperature/heater_status.dart test/widgets/stage/temp_panel_content_test.dart
git commit -m "feat(side-panel): Task 11 — add HeaterStatusPill widget"
```

---

## Task 12: Strip TempTrendSection card + shrink to slim row

**Why:** Concept lock: "Sparkline stays but becomes much smaller (just a slim row)" and "NO outer card". Current `TempTrendSection` wraps in a decorated Container with shadow and includes a fat stats row.

**Files:**
- Modify: `repo/apps/aquarium_app/lib/widgets/stage/temperature/temperature_history.dart` (`TempTrendSection.build`)
- Modify: `repo/apps/aquarium_app/test/widgets/stage/temp_panel_content_test.dart`

**Step 1: Write the failing test**

Append:

```dart
testWidgets('TempTrendSection has no card wrapper decoration',
    (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 360,
          child: TempTrendSection(
            sparkData: [24, 24.5, 25, 24.5, 24, 24, 24.5],
            minTemp: 24,
            maxTemp: 25,
            avgTemp: 24.4,
          ),
        ),
      ),
    ),
  );

  final decorated = tester
      .widgetList<Container>(
        find.descendant(
          of: find.byType(TempTrendSection),
          matching: find.byType(Container),
        ),
      )
      .where(
        (c) =>
            c.decoration is BoxDecoration &&
            ((c.decoration as BoxDecoration).color != null ||
                (c.decoration as BoxDecoration).boxShadow != null),
      )
      .toList();
  expect(decorated, isEmpty);
});

testWidgets('TempTrendSection chart is slim (<= 40px tall)', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 360,
          child: TempTrendSection(
            sparkData: [24, 24.5, 25, 24.5, 24, 24, 24.5],
            minTemp: 24,
            maxTemp: 25,
            avgTemp: 24.4,
          ),
        ),
      ),
    ),
  );

  final sizedBox = tester
      .widgetList<SizedBox>(
        find.descendant(
          of: find.byType(TempTrendSection),
          matching: find.byType(SizedBox),
        ),
      )
      .where((sb) => sb.height != null && sb.height! > 20 && sb.height! <= 40)
      .toList();
  expect(sizedBox, isNotEmpty);
});
```

Add `import 'package:danio/widgets/stage/temperature/temperature_history.dart';`.

**Step 2: Run test, verify it fails**

Expected: FAIL — the current section wraps in a decorated Container and uses 72px height.

**Step 3: Write minimal implementation**

Replace `TempTrendSection.build` body (return block):

```dart
return Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Row(
      children: [
        const Icon(Icons.show_chart_rounded, size: 14, color: kTempTealDark),
        const SizedBox(width: 6),
        Text(
          '7-day trend',
          style: AppTypography.labelSmall.copyWith(
            color: kTempCharcoal.withAlpha(160),
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        if (minTemp != null && maxTemp != null && avgTemp != null)
          Text(
            'min ${minTemp!.toStringAsFixed(1)}° · avg ${avgTemp!.toStringAsFixed(1)}° · max ${maxTemp!.toStringAsFixed(1)}°',
            style: AppTypography.labelSmall.copyWith(
              color: kTempCharcoal.withAlpha(120),
              fontSize: 10,
            ),
          ),
      ],
    ),
    const SizedBox(height: AppSpacing.xs),
    SizedBox(
      height: 32,
      child: sparkData.length >= 2
          ? CustomPaint(
              size: const Size(double.infinity, 32),
              painter: TempSparklinePainter(data: sparkData),
            )
          : Center(
              child: Text(
                'No data yet',
                style: AppTypography.labelSmall.copyWith(
                  color: kTempCharcoal.withAlpha(100),
                ),
              ),
            ),
    ),
  ],
);
```

`TempStatCell`, `TempStatDivider`, `TempDayLabels` become unused — leave in place for Task 14 to remove.

**Step 4: Run test, verify it passes**

```bash
flutter test test/widgets/stage/temp_panel_content_test.dart
flutter analyze
```

**Step 5: Commit**

```bash
git add lib/widgets/stage/temperature/temperature_history.dart test/widgets/stage/temp_panel_content_test.dart
git commit -m "feat(side-panel): Task 12 — slim TempTrendSection, remove card wrapper"
```

---

## Task 13: TempPanelContent — strip outer Container, convert TempLogButton to outlined pill, add HeaterStatusPill

**Why:** Finish the temp panel: strip the gradient Container, thread the `HeaterStatusPill` into the panel between the hero and the trend, and convert the log button to an outlined pill matching Task 7.

**Files:**
- Modify: `repo/apps/aquarium_app/lib/widgets/stage/temp_panel_content.dart`
- Modify: `repo/apps/aquarium_app/lib/widgets/stage/temperature/heater_status.dart` (only if `TempLogButton` lives there)
- Modify: `repo/apps/aquarium_app/test/widgets/stage/temp_panel_content_test.dart`

**Step 1: Write the failing test**

Append:

```dart
testWidgets('TempPanelContent has no outer gradient + outlined log button',
    (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        latestWaterTestProvider('t1').overrideWith((_) => Future.value(null)),
        latestWaterTestEntryProvider('t1')
            .overrideWith((_) => Future.value(null)),
        testStreakProvider('t1').overrideWith((_) => Future.value(0)),
        logsProvider('t1').overrideWith((_) => Future.value(<LogEntry>[])),
        tankHeaterProvider('t1').overrideWith((_) => Future.value(null)),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: TempPanelContent(tankId: 't1', theme: RoomTheme.ocean),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  final gradientContainers = tester
      .widgetList<Container>(
        find.descendant(
          of: find.byType(TempPanelContent),
          matching: find.byType(Container),
        ),
      )
      .where(
        (c) =>
            c.decoration is BoxDecoration &&
            (c.decoration as BoxDecoration).gradient != null,
      )
      .toList();
  expect(gradientContainers, isEmpty);

  // Log button is outlined pill
  expect(
    find.descendant(
      of: find.byType(TempPanelContent),
      matching: find.byType(ElevatedButton),
    ),
    findsNothing,
  );
  expect(
    find.descendant(
      of: find.byType(TempPanelContent),
      matching: find.byType(OutlinedButton),
    ),
    findsOneWidget,
  );
  expect(find.text('Log Temperature'), findsOneWidget);
});
```

Add the imports for `ProviderScope`, `latestWaterTestProvider`, `LogEntry`, `RoomTheme`, `TempPanelContent`, etc.

**Step 2: Run test, verify it fails**

Expected: FAIL — gradient container present, button is Elevated.

**Step 3: Write minimal implementation**

In `temp_panel_content.dart` `build`, replace the outer `Container(decoration: gradient, child: SingleChildScrollView(…))` wrapper with just the `SingleChildScrollView(…)`.

Also, thread heater status into the column after the hero section. Change the `Column` children to:

```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    TempHeader(streak: streak),
    const SizedBox(height: AppSpacing.sm4),
    TempHeroSection(
      temp: temp,
      fillAnim: _fillAnim,
      gaugeMin: _gaugeMin,
      gaugeMax: _gaugeMax,
      optimalMin: optimalMin,
      optimalMax: optimalMax,
      status: status,
      lastEntry: lastEntry,
      formatTimestamp: _formatTimestamp,
    ),
    const SizedBox(height: AppSpacing.sm),
    Center(
      child: HeaterStatusPill(
        heaterOn: heater?.isOn ?? false,
        lastTestLabel: lastEntry != null
            ? _formatTimestamp(lastEntry.timestamp)
            : null,
      ),
    ),
    const SizedBox(height: AppSpacing.md),
    TempTrendSection(
      sparkData: sparkData,
      minTemp: minTemp,
      maxTemp: maxTemp,
      avgTemp: avgTemp,
    ),
    const SizedBox(height: AppSpacing.md),
    TempLogButton(tankId: widget.tankId),
  ],
),
```

Note: `heater?.isOn` assumes the `Heater` model has an `isOn` getter. Verify by reading the provider: if the actual field is `on`, adapt accordingly. If neither, fall back to `(heater?.settings?['on'] as bool?) ?? false`.

Remove the `Container(height: 1, …)` divider — it is superseded by spacing.

Replace `TempLogButton.build` in `heater_status.dart` (or wherever it lives — it is in `heater_status.dart` per the survey):

```dart
class TempLogButton extends ConsumerWidget {
  final String tankId;
  const TempLogButton({super.key, required this.tankId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: () {
          AppRoutes.toAddLog(context, tankId, initialType: LogType.waterTest);
        },
        icon: const Icon(Icons.add_rounded, size: 18),
        label: const Text(
          'Log Temperature',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: kTempCharcoal,
          side: const BorderSide(color: kTempAmberGold, width: 1.5),
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        ),
      ),
    );
  }
}
```

**Step 4: Run test, verify it passes**

```bash
flutter test test/widgets/stage/temp_panel_content_test.dart
flutter analyze
```

**Step 5: Commit**

```bash
git add lib/widgets/stage/temp_panel_content.dart lib/widgets/stage/temperature/heater_status.dart test/widgets/stage/temp_panel_content_test.dart
git commit -m "feat(side-panel): Task 13 — strip TempPanelContent outer + outlined log pill + heater pill"
```

---

## Task 14: Delete unused legacy widgets

**Why:** Tasks 5, 10, and 12 left behind unused widgets: `WqParamCard`, `_WqStatusBar`, `_Segment`, `ThermometerPainter`, `TempScaleLabels`, `TempFishDecorations`, `TempFishChip`, `TempArcIndicator`, `_ArcPainter`, `TempStatCell`, `TempStatDivider`, `TempDayLabels`. Per `feedback_consistent_workflow.md` and the project's anti-broken-windows stance, delete them now while the commit is focused. `flutter analyze` should report them as unused.

**Files:**
- Modify: `repo/apps/aquarium_app/lib/widgets/stage/water_quality/water_param_card.dart`
- Modify: `repo/apps/aquarium_app/lib/widgets/stage/temperature/temperature_gauge.dart`
- Modify: `repo/apps/aquarium_app/lib/widgets/stage/temperature/temperature_history.dart`

**Step 1: Confirm each target is truly unused**

```bash
cd repo/apps/aquarium_app
grep -rn "WqParamCard\b" lib test     # expect: no matches outside the file itself
grep -rn "ThermometerPainter\b" lib test
grep -rn "TempFishDecorations\|TempFishChip" lib test
grep -rn "TempArcIndicator\|_ArcPainter" lib test
grep -rn "TempScaleLabels\|TempStatCell\|TempStatDivider\|TempDayLabels" lib test
```

If any grep returns call sites outside the file where the symbol is defined, STOP and investigate before deleting.

**Step 2: Delete the unused classes**

- In `water_param_card.dart`: delete `WqParamCard`, `_WqStatusBar`, `_Segment`, `WqGlassPanel`, `WqPanelEntryAnimation` (the last two are leftover glass wrappers unused after Task 2).
- In `temperature_gauge.dart`: delete `ThermometerPainter`, `TempScaleLabels`, `TempFishDecorations`, `TempFishChip`, `TempArcIndicator`, `_ArcPainter`, `TempPulsingGlow`, `TempGlassPanel`, `TempPanelEntryAnimation` — verify each via grep first.
- In `temperature_history.dart`: delete `TempStatCell`, `TempStatDivider`, `TempDayLabels`.

Keep `TempHeroSection`, `TempOptimalRangeRow`, `TempStatusBadge`, `TempSparklinePainter` — these are still in use.

**Step 3: Run tests + analyze**

```bash
flutter analyze
flutter test test/widgets/stage/
```

Expected: clean analyze (no unused-element warnings), all stage tests pass.

**Step 4: Run the full suite to catch cross-file regressions**

```bash
flutter test
```

Expected: full suite passes. If anything fails, revert the specific deletion that broke it.

**Step 5: Commit**

```bash
git add lib/widgets/stage/water_quality/water_param_card.dart lib/widgets/stage/temperature/temperature_gauge.dart lib/widgets/stage/temperature/temperature_history.dart
git commit -m "refactor(side-panel): Task 14 — remove legacy unused widgets replaced by brass redesign"
```

---

## Task 15: Visual verification + CLAUDE.md update + final commit

**Files:**
- Modify: `repo/CLAUDE.md` (Screen Map or Widget notes section — add a one-line note about `BrassMedallion` and `BrassGauge`)

**Step 1: Final baseline checks**

```bash
cd repo/apps/aquarium_app
flutter analyze                    # expect: clean
flutter test                       # expect: all passing
```

If any test flakes, diagnose per `systematic-debugging` skill — do not paper over per `feedback_tdd_seed_luck.md`.

**Step 2: Visual verification on a running device**

Per `feedback_flutter_install_doesnt_build.md`, use `flutter run --release` (NOT `flutter install`) so the APK is freshly built:

```bash
flutter run --release
```

On the tank screen, open the right-edge handle → water quality panel. Verify:
- ✅ Outer frame is glass with σ:14 blur (softer than before)
- ✅ No inner card wrappers — content floats on the glass
- ✅ 6 brass medallions in 2×3 layout (pH, NH₃, NO₂ / NO₃, GH, KH)
- ✅ Sparkline rows are slim and have no box
- ✅ Log button is an outlined pill

Open the left-edge handle → temperature panel:
- ✅ Circular brass gauge fills the top, needle points at current temp
- ✅ Green optimal-range arc visible
- ✅ Status badge + optimal range row below gauge
- ✅ Heater status pill (Heater ON/OFF ● Last test: …)
- ✅ Slim 32px sparkline row with min/avg/max inline
- ✅ Log button is an outlined pill

Take screenshots via `adb exec-out screencap -p > phase5_side_panel_water.png` and `…_temp.png`, save under the project root alongside the existing `phase5_*.png` files.

**Step 3: Update CLAUDE.md**

Add to the "Key Conventions" or "Design System" section:

```markdown
- **Side panels (Phase 5):** `BrassMedallion` (`widgets/stage/water_quality/brass_medallion.dart`) for water params; `BrassGauge` + `BrassGaugePainter` (`widgets/stage/temperature/brass_gauge.dart`, `brass_gauge_painter.dart`) for the temperature dial. Panels render on a σ:14 glass frame (`SwissArmyPanel`) with no inner card wrappers.
```

**Step 4: Final commit**

```bash
git add repo/CLAUDE.md "phase5_side_panel_water.png" "phase5_side_panel_temp.png"
git commit -m "docs(side-panel): Task 15 — CLAUDE.md note + visual verification screenshots"
```

**Step 5: Push + open PR**

```bash
git push -u origin feature/side-panel-redesign
gh pr create --title "feat: Side panel redesign (Lab View + Brass Gauge)" --body "$(cat <<'EOF'
## Summary
- Strip inner card wrappers from both side panels and tune SwissArmyPanel glass to σ:14 / 0.92 alpha / drop shadow per concept lock
- Water panel: 2×3 BrassMedallion grid, slim sparkline rows, outlined-pill log button
- Temperature panel: new circular BrassGauge (replaces vertical thermometer), heater status pill, slim trend row, outlined-pill log button

## Concept lock reference
`docs/planning/2026-04-danio-fix-brief-concept-lock.md` — sections "Water Quality 'Lab View' Spec" and "Temperature 'Gauge Instrument' Spec"

## Test plan
- [x] Unit + widget tests for SwissArmyPanel, BrassMedallion, BrassGaugePainter, BrassGauge, WaterPanelContent, TempPanelContent
- [x] `flutter analyze` clean
- [x] Full `flutter test` suite passes
- [x] Manual verification on emulator — both panels rendered correctly
EOF
)"
```

---

## Remember

- Each task = one commit. Bite-sized commits are non-negotiable per `feedback_verification_rigor.md`.
- Red → Green → Commit. Never skip the red step. Per `feedback_tdd_seed_luck.md`, verify the red happens for the right reason (e.g. "symbol not defined", "assertion failed on the new invariant") not because of an unrelated error.
- DRY: any duplication between water + temp panels is intentional for this pass. Unifying can happen in a follow-up.
- YAGNI: no dark mode, no RTL, no additional variants beyond what the concept lock specifies.
- Run `flutter analyze` after every task. Never land a task with new analyzer warnings.
- If a task fails verification, STOP and report — do not cascade failures forward.

---

## Execution Handoff

Plan complete and saved to `docs/plans/2026-04-07-side-panel-redesign-plan.md`. Two execution options:

1. **Subagent-Driven (this session)** — I dispatch a fresh subagent per task, review between tasks, fast iteration in the current session.
2. **Parallel Session (separate)** — Open a new session with `superpowers:executing-plans`, batch execution with checkpoints.

Which approach?
