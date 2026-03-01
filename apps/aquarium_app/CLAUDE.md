# Project: Danio — Aquarium Hobby App

> "Duolingo for Fishkeeping" — gamified aquarium education and tank management.

## Tech Stack
- **Language:** Dart (null-safe)
- **Framework:** Flutter 3.38.9 (stable)
- **State Management:** Riverpod 2.6.1 (riverpod_annotation + code gen)
- **Local Storage:** Hive 2.2.3 (offline-first)
- **Networking:** http 1.2.2 + Supabase Flutter 2.8.4 (cloud sync, optional)
- **Animations:** flutter_animate 4.5.0
- **Notifications:** flutter_local_notifications 18.0.1
- **AI:** OpenAI API via lib/services/openai_service.dart (gpt-4o-mini + gpt-4o vision)
- **Package:** com.tiarnanlarkin.aquarium.aquarium_app

## Architecture
```
lib/
  data/          → Static content (lessons, achievements, species, tips)
  features/smart/→ AI layer: fish_id, symptom_triage, weekly_plan, anomaly_detector
  models/        → Hive data models (Tank, Livestock, WaterLog, UserProfile...)
  navigation/    → GoRouter setup + route definitions
  providers/     → Riverpod providers (global state)
  screens/       → All screens (one file per screen)
  services/      → Business logic (openai, haptic, achievement, notification...)
  theme/         → AppTheme, AppColors, AppSpacing, AppRadius
  widgets/       → Reusable widgets
```

## Design System (ALWAYS use these — never raw values)
- **Colors:** AppColors.* — amber/teal only. NO blues/purples/pinks
- **Spacing:** AppSpacing.* (xs=4, sm=8, sm2=12, md=16, lg2=20, lg=24, xl=32, xxl=48)
- **Radii:** AppRadius.* (xs, small, md2, medium, large)
- **Text:** Theme.of(context).textTheme.* — NEVER hardcode fontSize
- **Dark mode:** colorScheme.* only — never hardcode hex greys or white backgrounds
- **Icons:** Icons.set_meal for fish — NEVER Icons.pets

## Commands
```bash
# Flutter is in WSL only — always use this path
FLUTTER="$HOME/flutter/bin/flutter"

$FLUTTER analyze lib/          # Must stay at 0 errors before any commit
$FLUTTER run                   # Debug run
$FLUTTER build apk --debug     # Debug APK for device
$FLUTTER build appbundle \
  --dart-define=OPENAI_API_KEY=<key> \
  --release                    # Signed release AAB for Play Store

# After model changes
$FLUTTER pub run build_runner build --delete-conflicting-outputs
```

## Git
- **Active branch:** openclaw/ui-fixes
- **Remote:** https://github.com/tiarnanlarkin/aquarium-app.git
- **WSL path:** /mnt/c/Users/larki/Documents/Aquarium App Dev/repo/apps/aquarium_app
- Conventional commits: feat(scope):, fix(scope):, style(ui):, chore():
- Commit after every working state — run analyze first

## Signing
- android/key.properties + android/aquarium-release.jks — both present, pre-configured

## Test Device
- Samsung SM-F966B (Galaxy Z Fold5), ID: RFCY8022D5R

## Conventions
- ASCII quotes/apostrophes only — Dart parser rejects Unicode curly quotes
- No smart quotes ('), no em dashes (—) in Dart source
- One screen per file, one concern per provider
- HapticFeedback via AppHaptics.success/light/medium() (respects user pref)

## Current Status (2026-03-01)
- flutter analyze → 0 errors
- 50+ improvement commits on openclaw/ui-fixes vs master
- Social features (friends/leaderboard) → "Coming Soon" overlay
- AI features require OPENAI_API_KEY dart-define at build time
- Play Store: needs signed build + smoke test + screenshots

## DO NOT
- Change the app icon (locked)
- Use Colors.blue/purple/indigo/pink
- Hardcode fontSize values
- Use Unicode smart quotes in Dart strings
- Commit with analyzer errors
