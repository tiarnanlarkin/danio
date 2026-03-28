# 🐠 Danio

**Learn Aquarium Keeping — the Duolingo Way**

Danio is a gamified Flutter mobile app for aquarium hobbyists of all levels. It combines bite-sized lessons, spaced repetition, smart tank management, and a cosy room-exploration UI to make fish keeping genuinely fun to learn.

---

## Quick Start (10 minutes to productive)

### Prerequisites

| Tool | Minimum version |
|------|----------------|
| Flutter | **3.32.x** (Dart SDK ^3.10.8) |
| Android Studio / Xcode | Latest stable |
| A device or emulator | Android 6+ / iOS 14+ |

> **WSL users:** see `docs/WSL_BUILD_GUIDE.md` for the full Windows/WSL build setup.

### Install & run

```bash
# 1. Clone the repo (if you haven't already)
git clone <repo-url>
cd "Danio Aquarium App Project/repo/apps/aquarium_app"

# 2. Get dependencies
flutter pub get

# 3. Run on a connected device / emulator
flutter run

# 4. Run in release mode (no debug banner, production perf)
flutter run --release
```

### Environment / secrets

The app uses Supabase for its backend. Copy the example env file and fill in your keys:

```bash
cp .env.example .env   # if present, otherwise check lib/supabase/
```

Secrets live in `lib/supabase/` — never commit real keys.

---

## Features

| Area | What it does |
|------|-------------|
| **Lessons** | Bite-sized learning cards with spaced repetition (SRS) |
| **Quiz engine** | Multiple choice, fill-in-the-blank, true/false, matching, ordering |
| **Tank management** | Create & track aquariums — volume, inhabitants, water parameters |
| **Water log** | Log pH, temperature, ammonia, nitrite, nitrate with trend arrows |
| **XP & streaks** | Daily goals, streak calendar, level-up celebrations |
| **Achievements** | Bronze → Diamond tier badge system |
| **AI stocking** | Smart fish compatibility checker + stocking suggestions |
| **Cosy room UI** | Explore a room scene; click desk, tank, bookshelf to navigate |
| **Dark mode** | Full warm-dark theme (not cold blue-grey — real warm charcoal) |
| **Offline** | Core content and tank data available without internet |

---

## Architecture

```
lib/
├── main.dart               ← App entry point; theme + providers wired here
├── theme/
│   └── app_theme.dart      ← Single source of truth: colours, typography, spacing, radius
├── features/               ← Feature slices (Riverpod providers + business logic)
│   ├── auth/               ← Sign-in, sign-up, session
│   └── smart/              ← AI stocking, compatibility
├── screens/                ← Full-screen UI (one file per route)
├── widgets/
│   ├── core/               ← Design system widgets (AppButton, AppCard, AppChip, AppTextField)
│   ├── common/             ← Shared utility widgets
│   ├── stage/              ← Stage/scene backdrop system
│   ├── room/               ← Cosy room scene widgets
│   ├── ambient/            ← Ambient animation effects
│   ├── effects/            ← Particle / celebration effects
│   ├── celebrations/       ← Streak & XP celebration overlays
│   ├── mascot/             ← Danio fish mascot widget
│   └── rive/               ← Rive animation integration
├── models/                 ← Plain Dart data classes
├── providers/              ← Riverpod state providers
├── services/               ← Business logic services (sync, backup, analytics)
├── utils/                  ← Helpers: app_feedback.dart, formatting, etc.
├── painters/               ← Custom CustomPainter classes
├── data/                   ← Static data (fish catalogue, lesson content)
├── constants/              ← App-wide constants
└── supabase/               ← Supabase client initialisation
```

### State management

[Riverpod](https://riverpod.dev/) throughout. Providers live in `lib/providers/` and feature-specific state in each `lib/features/` slice.

### Navigation

Standard Flutter `Navigator` + `MaterialPageRoute`. All routes get an automatic slide+fade transition via `AppTheme` (`_DanioPageTransitionsBuilder`).

### Backend

Supabase (Postgres + Auth + Realtime). The client is initialised once in `lib/supabase/` and injected via a Riverpod provider.

---

## Key Files

| File | What it is |
|------|-----------|
| `lib/theme/app_theme.dart` | **Start here.** All colours, spacing, radius, typography, shadows |
| `lib/main.dart` | App bootstrap — providers, theme, scroll behaviour |
| `lib/widgets/core/` | Design system components (use these, not raw Material widgets) |
| `lib/widgets/danio_snack_bar.dart` | App-wide snack bar API |
| `lib/widgets/app_bottom_sheet.dart` | Three bottom sheet patterns |
| `docs/theme-system.md` | How to style things in this app |
| `docs/widgets.md` | Widget library catalog |
| `docs/WSL_BUILD_GUIDE.md` | Build on Windows/WSL |
| `plans/typography-spec.md` | Font rationale (Fredoka / Nunito / Lora) |

---

## Running Tests

```bash
# Unit + widget tests
flutter test

# Single test file
flutter test test/my_test.dart

# With coverage
flutter test --coverage
# Open coverage/lcov.info in your IDE or run:
# genhtml coverage/lcov.info -o coverage/html && open coverage/html/index.html
```

Integration tests live in `integration_test/`.

---

## Building for Release

```bash
# Android APK
flutter build apk --release

# Android App Bundle (Play Store)
flutter build appbundle --release

# iOS (requires Xcode + signing)
flutter build ios --release
```

See `docs/BUILD_RELEASE_GUIDE.md` for signing, versioning, and Play Store upload steps.

---

## Code Style

- **Linting:** `analysis_options.yaml` (Flutter recommended rules)
- **Formatting:** `dart format .` before every commit
- **No raw `withOpacity()`:** use the pre-computed alpha constants in `AppColors` / `AppOverlays`
- **No raw `TextStyle()`:** use `AppTypography.*` or `Theme.of(context).textTheme.*`
- **No raw colours:** all colours come from `AppColors` or `DanioColors`

---

## Docs

| Document | Purpose |
|---------|---------|
| `docs/theme-system.md` | Colour, spacing, radius, typography guide |
| `docs/widgets.md` | Shared widget catalog |
| `docs/WSL_BUILD_GUIDE.md` | Windows/WSL build setup |
| `plans/typography-spec.md` | Font system rationale |
| `prd/` | Product requirements |
| `docs/architecture/` | Architecture decision records |

---

## Project Folder

`C:\Users\larki\Documents\Danio Aquarium App Project`
