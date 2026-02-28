# Danio Quality Bar
Version: 1.0 | Date: 2026-02-28

Measurable targets for Play Store release. Every item must be checked before submission.

## Build & Stability
- [ ] 0 build errors on clean `flutter build apk --release`
- [ ] `flutter analyze`: 0 errors, 0 warnings (info-only acceptable)
- [ ] Crash-free sessions: ≥ 99.5% (Firebase Crashlytics once integrated)
- [ ] No `debugPrint` or `print` in production lib/ code

## Performance
- [ ] Cold start to usable screen: ≤ 2.0s on mid-range device (Pixel 6a equivalent)
- [ ] Smooth scrolling: 0 jank frames in learning paths list (60fps)
- [ ] Memory: <200MB during normal use, <100MB idle
- [ ] APK size: <50MB debug, target <40MB release
- [ ] No unnecessary rebuilds (Riverpod `select` used where appropriate)

## UI/UX Polish
- [ ] Design system applied: consistent spacing (AppSpacing 8dp grid), typography (AppTypography), colour semantic system (AppColors)
- [ ] Every screen has: loading state + empty state + error state
- [ ] No dead ends: every screen has a clear next action + back behaviour
- [ ] Navigation: tab state always reflects current screen
- [ ] Touch targets: ≥ 48dp on all interactive elements (AppTouchTargets enforced)
- [ ] No text truncation mid-word on any screen
- [ ] No Flutter overflow indicators visible (yellow/black stripes)
- [ ] No layout issues (clipping, overlapping) on screens 360dp–430dp wide
- [ ] Dark mode: fully themed, no white flashes, all screens match design system

## Accessibility
- [ ] TalkBack semantic labels on all interactive elements
- [ ] Font scaling: layouts don't break at 1.5× text scale
- [ ] Contrast: WCAG AA (4.5:1) on all body text (already designed into AppColors)
- [ ] No purely colour-coded information (always has icon/text backup)
- [ ] Reduced motion: respects `AccessibilityFeatures.reduceMotion` via `reduced_motion_provider.dart`

## Feature Completeness
- [ ] Data persists across app restarts (SharedPreferences + local JSON storage)
- [ ] Tank creation → parameter logging → history: complete E2E flow
- [ ] Learning system: lessons → quiz → spaced repetition → XP: complete E2E flow
- [ ] Achievements: unlock + persist correctly (55 achievements)
- [ ] Hearts system: deduct on wrong answers, refill over time, purchase with gems
- [ ] Gem economy: earn + spend + shop flow complete
- [ ] Friends/social: clearly marked as demo/coming-soon (mock data)
- [ ] Analytics: clearly marked as coming-soon (Firebase pending)
- [ ] Streaks: track daily usage, streak freeze available in shop

## Store Readiness
- [ ] App icon: high-quality, all densities (mipmap)
- [ ] Privacy policy: live URL in-app (`privacy_policy_screen.dart`)
- [ ] Terms of service: live URL in-app (`terms_of_service_screen.dart`)
- [ ] No hardcoded API keys or credentials in source (Supabase uses env/config)
- [ ] Release build works and is signed
- [ ] All declared permissions justified (notifications, camera for fish ID, storage for photos)
- [ ] Store listing assets: screenshots (5+), feature graphic, short/long descriptions

## Testing
- [ ] `flutter test`: all tests pass (0 failures)
- [ ] Test coverage: ≥ 60% on core logic (providers, services, models)
- [ ] E2E user journeys verified on physical device
- [ ] No flaky tests in CI
