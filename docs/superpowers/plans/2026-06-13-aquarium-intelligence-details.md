# Aquarium Intelligence Details Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a full-screen local Aquarium Intelligence detail area from Smart so users can review all local risks, care-plan actions, compatibility/anomaly reasons, and routes without optional AI.

**Architecture:** Reuse `aquariumIntelligenceProvider` and `AquariumIntelligenceReport` from CL-P0-007A. Add a new screen under `features/smart/intelligence`, add a `Review Intelligence` action to the compact Smart section, and route through `NavigationThrottle`.

**Tech Stack:** Flutter, Riverpod, existing Smart local intelligence provider, existing route helpers, widget tests.

---

## File Structure

- Create `apps/aquarium_app/lib/features/smart/intelligence/aquarium_intelligence_screen.dart`: full-screen local intelligence review.
- Modify `apps/aquarium_app/lib/features/smart/intelligence/aquarium_intelligence_section.dart`: add `Review Intelligence` action and route to the new screen.
- Modify `apps/aquarium_app/test/widget_tests/smart_screen_test.dart`: add widget coverage for opening the detail screen from Smart.
- Modify `apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md`: record CL-P0-007B progress.
- Modify `apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md`: update CL-P0-007 remaining work.

---

### Task 1: Detail Route Test

**Files:**
- Modify: `apps/aquarium_app/test/widget_tests/smart_screen_test.dart`

- [x] **Step 1: Write failing widget test**

Add a test named `opens full local Aquarium Intelligence review` that:

- creates `_SmartTestStorageService`;
- saves one tank named `River Room`;
- saves an unsafe ammonia water-test log with `0.5`;
- renders Smart with `_wrap(storage: storage)`;
- expects `Review Intelligence`;
- taps `Review Intelligence`;
- expects `Aquarium Intelligence`, `Local care plan`, `What Danio checked`, `Unsafe water detected`, and `Ammonia 0.50 ppm` on the detail screen.

- [x] **Step 2: Run widget test to verify failure**

Run:

```powershell
cd apps/aquarium_app
flutter test test/widget_tests/smart_screen_test.dart --plain-name "opens full local Aquarium Intelligence review"
```

Expected: FAIL because the button and detail screen do not exist yet.

---

### Task 2: Detail Screen And Route

**Files:**
- Create: `apps/aquarium_app/lib/features/smart/intelligence/aquarium_intelligence_screen.dart`
- Modify: `apps/aquarium_app/lib/features/smart/intelligence/aquarium_intelligence_section.dart`

- [x] **Step 1: Create detail screen**

Create `AquariumIntelligenceScreen` as a `ConsumerWidget` that watches `aquariumIntelligenceProvider` and renders:

- app bar title `Aquarium Intelligence`;
- subtitle `Local checks, no AI key needed`;
- summary counts for risks, care, compatibility, and anomalies;
- `Local care plan` section listing report items with actions;
- `What Danio checked` section listing `Water safety`, `Care schedule`, `Livestock health`, `Compatibility`, `Anomaly history`, and `Equipment maintenance`.

- [x] **Step 2: Add route button**

In `AquariumIntelligenceSection`, add an `AppButton` with label `Review Intelligence`, icon `Icons.open_in_full`, and `NavigationThrottle.push(context, const AquariumIntelligenceScreen(), rootNavigator: true)`.

- [x] **Step 3: Run widget test to verify pass**

Run:

```powershell
cd apps/aquarium_app
flutter test test/widget_tests/smart_screen_test.dart --plain-name "opens full local Aquarium Intelligence review"
```

Expected: PASS.

- [x] **Step 4: Run full Smart widget test file**

Run:

```powershell
cd apps/aquarium_app
flutter test test/widget_tests/smart_screen_test.dart
```

Expected: PASS.

---

### Task 3: Docs, Verification, Commit

**Files:**
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md`
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md`
- Modify: `docs/superpowers/plans/2026-06-13-aquarium-intelligence-details.md`

- [x] **Step 1: Update product tracking**

Record `CL-P0-007B Aquarium Intelligence details progress` and note that Smart now has a full-screen local review area for care-plan actions and checked reasons.

- [x] **Step 2: Format changed Dart files**

Run:

```powershell
cd apps/aquarium_app
dart format lib/features/smart/intelligence/aquarium_intelligence_screen.dart lib/features/smart/intelligence/aquarium_intelligence_section.dart test/widget_tests/smart_screen_test.dart
```

- [x] **Step 3: Run focused tests**

Run:

```powershell
cd apps/aquarium_app
flutter test test/widget_tests/smart_screen_test.dart
```

- [x] **Step 4: Run analyzer**

Run:

```powershell
cd apps/aquarium_app
flutter analyze
```

- [x] **Step 5: Check diff**

Run:

```powershell
git diff --check
git diff -- apps/aquarium_app/lib/features/smart/intelligence/aquarium_intelligence_screen.dart apps/aquarium_app/lib/features/smart/intelligence/aquarium_intelligence_section.dart apps/aquarium_app/test/widget_tests/smart_screen_test.dart apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md docs/superpowers/plans/2026-06-13-aquarium-intelligence-details.md
```

- [x] **Step 6: Commit**

Run:

```powershell
git add apps/aquarium_app/lib/features/smart/intelligence/aquarium_intelligence_screen.dart apps/aquarium_app/lib/features/smart/intelligence/aquarium_intelligence_section.dart apps/aquarium_app/test/widget_tests/smart_screen_test.dart apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md docs/superpowers/plans/2026-06-13-aquarium-intelligence-details.md
git commit -m "feat: add aquarium intelligence details"
```
