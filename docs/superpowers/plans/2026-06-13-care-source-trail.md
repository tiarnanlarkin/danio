# Care Source Trail Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add subtle source-trail cards to fish species and plant detail pages using broad trusted references.

**Architecture:** Add a small pure-data source model and reference lists, then render a shared source-trail card in species and plant detail sheets. Links open externally through the app's existing `url_launcher` dependency, and visible copy makes clear these are broad references for care guidance rather than per-field verification.

**Tech Stack:** Flutter, existing app cards/buttons, `url_launcher`, widget tests.

---

### Task 1: Add Failing Tests

**Files:**
- Modify: `apps/aquarium_app/test/widget_tests/species_browser_screen_test.dart`
- Modify: `apps/aquarium_app/test/widget_tests/plant_browser_screen_test.dart`

- [ ] **Step 1: Add fish source-trail test**

Add this test near existing species detail tests:

```dart
testWidgets('species detail shows source trail', (tester) async {
  await tester.pumpWidget(_wrap());
  await _advance(tester);

  await tester.tap(find.text('Neon Tetra'));
  await tester.pumpAndSettle();

  await tester.ensureVisible(find.text('Source trail'));
  await tester.pumpAndSettle();

  expect(find.text('Source trail'), findsOneWidget);
  expect(find.text('FishBase'), findsOneWidget);
  expect(find.text('Merck Veterinary Manual'), findsOneWidget);
  expect(find.text('RSPCA fish welfare advice'), findsOneWidget);
});
```

- [ ] **Step 2: Add plant source-trail test**

Add this test near existing plant detail tests:

```dart
testWidgets('plant detail shows source trail', (tester) async {
  await tester.pumpWidget(_wrap());
  await _advance(tester);

  await tester.tap(find.text('Anubias Barteri'));
  await tester.pumpAndSettle();

  await tester.ensureVisible(find.text('Source trail'));
  await tester.pumpAndSettle();

  expect(find.text('Source trail'), findsOneWidget);
  expect(find.text('Tropica plant database'), findsOneWidget);
  expect(find.text('INJAF planted aquarium guide'), findsOneWidget);
});
```

- [ ] **Step 3: Run tests to verify they fail**

Run:

```powershell
$env:JAVA_HOME = Join-Path $env:USERPROFILE 'development\jdk-21'
$env:ANDROID_SDK_ROOT = Join-Path $env:LOCALAPPDATA 'Android\Sdk'
$env:ANDROID_HOME = $env:ANDROID_SDK_ROOT
$env:Path = "$env:LOCALAPPDATA\Programs\Git\cmd;$env:USERPROFILE\development\flutter\bin;$env:JAVA_HOME\bin;$env:ANDROID_SDK_ROOT\platform-tools;$env:Path"
& "$env:USERPROFILE\development\flutter\bin\flutter.bat" test test/widget_tests/species_browser_screen_test.dart --name "species detail shows source trail"
& "$env:USERPROFILE\development\flutter\bin\flutter.bat" test test/widget_tests/plant_browser_screen_test.dart --name "plant detail shows source trail"
```

Expected: both fail because no `Source trail` cards exist yet.

### Task 2: Implement Shared Source Trail

**Files:**
- Create: `apps/aquarium_app/lib/data/care_sources.dart`
- Modify: `apps/aquarium_app/lib/screens/species_browser_screen.dart`
- Modify: `apps/aquarium_app/lib/screens/plant_browser_screen.dart`

- [ ] **Step 1: Add data file**

Create:

```dart
class CareSource {
  final String title;
  final String publisher;
  final String url;
  final String note;

  const CareSource({
    required this.title,
    required this.publisher,
    required this.url,
    required this.note,
  });
}

const fishCareSources = <CareSource>[
  CareSource(
    title: 'FishBase',
    publisher: 'FishBase Consortium',
    url: 'https://www.fishbase.se/',
    note: 'Taxonomy, biology, size, and species context.',
  ),
  CareSource(
    title: 'Merck Veterinary Manual',
    publisher: 'Merck & Co.',
    url: 'https://www.merckvetmanual.com/exotic-and-laboratory-animals/aquatic-systems/environmental-diseases-of-aquatic-animals-in-aquatic-systems',
    note: 'Water quality risk context and aquatic health principles.',
  ),
  CareSource(
    title: 'RSPCA fish welfare advice',
    publisher: 'RSPCA',
    url: 'https://www.rspca.org.uk/adviceandwelfare/pets/fish',
    note: 'General companion fish welfare and care checks.',
  ),
];

const plantCareSources = <CareSource>[
  CareSource(
    title: 'Tropica plant database',
    publisher: 'Tropica Aquarium Plants',
    url: 'https://tropica.com/en/plants/',
    note: 'Plant difficulty, light, CO2, and aquarium placement context.',
  ),
  CareSource(
    title: 'INJAF planted aquarium guide',
    publisher: 'INJAF',
    url: 'https://injaf.org/articles-guides/beginners-guides/beginners-guide-to-aquarium-plants/',
    note: 'Beginner-friendly planted tank care and plant selection guidance.',
  ),
];
```

- [ ] **Step 2: Render fish source card**

In `species_browser_screen.dart`, import `care_sources.dart` and `url_launcher.dart`, add `_SourceTrailCard`, and render:

```dart
const _SourceTrailCard(sources: fishCareSources),
```

near the bottom of `_SpeciesDetailSheet` after treatment warnings and before final spacing.

- [ ] **Step 3: Render plant source card**

In `plant_browser_screen.dart`, import `care_sources.dart` and `url_launcher.dart`, add or reuse a local `_SourceTrailCard`, and render:

```dart
const _SourceTrailCard(sources: plantCareSources),
```

after Care Tips and before final spacing.

- [ ] **Step 4: Source card behavior**

The card should show:
- Heading: `Source trail`
- A short body: `Broad references behind Danio's care guidance. Always check species-specific needs before acting.`
- Each source title, publisher/note, and an `Open` `AppButton`
- Use `launchUrl(Uri.parse(source.url), mode: LaunchMode.externalApplication)` for taps
- Show `DanioSnackBar.error(context, 'Could not open source')` on launch failure

- [ ] **Step 5: Run focused tests**

Run both focused tests again. Expected: PASS.

### Task 3: Verify And Commit

**Files:**
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md`
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md`

- [ ] **Step 1: Format and normalize Dart files**

Run `dart format` on the created/modified Dart files and normalize line endings.

- [ ] **Step 2: Verify**

Run:

```powershell
& "$env:USERPROFILE\development\flutter\bin\flutter.bat" analyze
& "$env:USERPROFILE\development\flutter\bin\flutter.bat" test
& "$env:USERPROFILE\development\flutter\bin\flutter.bat" test test/copy/current_docs_local_truth_test.dart
& "$env:USERPROFILE\development\flutter\bin\flutter.bat" build apk --debug --target lib/main.dart
git diff --check
```

Expected: analyze clean, all tests pass with two additional tests, doc truth passes, debug APK builds, diff check clean.

- [ ] **Step 3: Update docs and commit**

Record CL-P1-003J as source-trail cards and update the `flutter test` count to the latest verified number.

```powershell
git add apps/aquarium_app/lib/data/care_sources.dart apps/aquarium_app/lib/screens/species_browser_screen.dart apps/aquarium_app/lib/screens/plant_browser_screen.dart apps/aquarium_app/test/widget_tests/species_browser_screen_test.dart apps/aquarium_app/test/widget_tests/plant_browser_screen_test.dart apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md docs/superpowers/plans/2026-06-13-care-source-trail.md
git commit -m "feat: add care source trails"
```
