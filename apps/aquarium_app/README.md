# Danio

**Learn aquarium keeping with a local-first, tank-centred companion.**

Danio is a gamified Flutter mobile app for aquarium hobbyists of all levels. It
combines bite-sized lessons, spaced repetition, smart local tank care, practical
tools, and a cosy illustrated aquarium room to make fishkeeping easier to learn
and more satisfying to maintain.

The active finish line is complete local quality first: the app should feel
polished, useful, and honest on Android phone and tablet before public store
launch work resumes.

---

## Quick Start

### Prerequisites

| Tool | Minimum version |
|------|-----------------|
| Flutter | 3.44.x |
| Dart | 3.12.x |
| Android Studio / Xcode | Latest stable |
| A device or emulator | Android 6+ / iOS 14+ |

WSL users can use `docs/WSL_BUILD_GUIDE.md` for the Windows/WSL build setup.

### Install and run

```bash
# 1. Clone the repo if needed
git clone <repo-url>
cd "Danio Aquarium App Project/repo/apps/aquarium_app"

# 2. Get dependencies
flutter pub get

# 3. Run on a connected device or emulator
flutter run

# 4. Run in release mode
flutter run --release
```

### Environment and optional services

The core app is local-first. Lessons, tank data, tools, backup export/import,
progress, and the non-AI Smart Hub checks run without a backend.

Optional services are present in code but are not required for local completion:

| Service | Current role |
|---------|--------------|
| OpenAI | Optional AI tools when a user key or configured proxy is available |
| Supabase | Optional account/cloud helpers when configured; disabled in the local build |
| Firebase Crashlytics | Optional diagnostics after user consent |

Never commit real service keys. Local testing should work with no secrets.

---

## Features

| Area | What it does |
|------|--------------|
| Tank | Illustrated aquarium room, tank care status, quick actions, logs, tasks, livestock, equipment, and multi-tank support |
| Learn | 12 learning paths, 82 lessons, stories, quizzes, XP, hearts, gems, and spaced repetition |
| Practice | Due reviews, weak-spot practice, and broader fishkeeping skill drills |
| Smart | Local compatibility, anomaly history, care suggestions, optional AI photo ID, symptom triage, Ask Danio, and weekly planning |
| Workshop | Water change, stocking, CO2, dosing, volume, unit, lighting, compatibility, cycling, and cost tools |
| Data | Local JSON storage, SharedPreferences progress, ZIP backup/export/import, and clear local data controls |
| Design | Illustrated watercolor-style tank/room surfaces with warm light and motion |

---

## Architecture

```text
lib/
|-- main.dart               App entry point, theme, providers, bootstrap
|-- theme/                  Colors, typography, spacing, radius, shadows
|-- features/               Feature slices such as auth and Smart
|-- screens/                Full-screen UI routes
|-- widgets/                Shared UI, room, tank, mascot, effects, and core widgets
|-- models/                 Plain Dart data classes
|-- providers/              Riverpod state providers
|-- services/               Local storage, backup, notifications, optional AI/account helpers
|-- utils/                  Logging, formatting, feedback, and helper APIs
|-- painters/               Custom painter classes
|-- data/                   Bundled species, plant, lesson, and story content
|-- constants/              App-wide constants
`-- supabase/               Optional cloud/account schema and helper code
```

### State management

Danio uses Riverpod throughout. Shared providers live in `lib/providers/`, and
feature-specific state lives inside the relevant `lib/features/` slice.

### Navigation

The app uses standard Flutter `Navigator` and `MaterialPageRoute`, with
project-level route helpers in `lib/navigation/`.

### Local data

Tank data is stored locally through `LocalJsonStorageService`. Progress,
preferences, and Smart history use `SharedPreferences` where appropriate.
Backup/export/import is file-based and does not require a cloud account.

---

## Key Files

| File | What it is |
|------|------------|
| `lib/theme/app_theme.dart` | Color, spacing, radius, typography, and shadow system |
| `lib/main.dart` | App bootstrap, providers, theme, startup work |
| `lib/widgets/core/` | Shared design-system components |
| `lib/widgets/danio_snack_bar.dart` | App-wide snackbar API |
| `lib/widgets/app_bottom_sheet.dart` | Shared bottom sheet patterns |
| `docs/product/danio-complete-local-audit-backlog-2026-06-13.md` | Active complete-local backlog |
| `docs/product/danio-complete-local-current-audit-2026-06-13.md` | Current audit status |

---

## Running Tests

```bash
# Unit and widget tests
flutter test

# Single test file
flutter test test/copy/current_docs_local_truth_test.dart

# Analyzer
flutter analyze --no-pub
```

Integration tests live in `integration_test/`. Android emulator or device QA
should only run after confirming no other local Codex session is using the same
target.

---

## Building

```bash
# Android debug APK
flutter build apk --debug

# Android release APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release
```

Public release and Play Store work are intentionally downstream of the
complete-local quality bar.

---

## Code Style

- Use `dart format` before committing Dart changes.
- Prefer shared widgets from `lib/widgets/core/`.
- Use `AppTypography`, `AppColors`, `DanioColors`, and `AppOverlays` instead of
  raw text styles, raw colors, or raw opacity values.
- Keep visible feature copy honest: every visible feature should work locally or
  clearly say what optional setup is needed.

---

## Project Folder

`C:\Users\larki\OneDrive\Documents\App Projects\Danio Aquarium App Project`
