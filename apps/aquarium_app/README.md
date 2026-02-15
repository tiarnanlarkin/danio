# 🐠 Aquarium Hobby App

**Your Personal Aquarium Companion — Learn, Track, Thrive**

A beautiful, gamified mobile app for aquarium hobbyists of all levels. Track your tanks, learn the hobby, and level up your fishkeeping skills with Duolingo-style engagement mechanics.

![Flutter](https://img.shields.io/badge/Flutter-3.10-blue)
![Dart](https://img.shields.io/badge/Dart-3.10-blue)
![Riverpod](https://img.shields.io/badge/Riverpod-2.6-purple)
![Tests](https://img.shields.io/badge/Tests-98%25-brightgreen)
![Performance](https://img.shields.io/badge/FPS-60-brightgreen)
![License](https://img.shields.io/badge/License-Proprietary-red)

**Status:** ✅ Production Ready | **Version:** 1.0.0 | **Last Updated:** February 2025

---

## ✨ Features

### 🎓 Learning System
- **50+ structured lessons** covering beginner to advanced topics
- **Spaced repetition review** for long-term knowledge retention
- **Interactive quizzes** with multiple question types
- **Placement test** to find your starting level
- **14 comprehensive guides** (Nitrogen Cycle, Disease, Feeding, etc.)

### 🐟 Tank Management
- **Unlimited tanks** with full parameter tracking
- **122 species database** with care requirements
- **52 plants database** with growth needs
- **Equipment tracking** per tank
- **Photo gallery** with tank progression
- **Water testing logs** with trend charts
- **Maintenance task scheduler**

### 🎮 Gamification (Duolingo-Style)
- **XP System** — Earn XP for everything you do
- **Gem Currency** — Earn and spend gems on rewards
- **Hearts System** — Limited daily attempts (refill over time)
- **Streaks** — Build daily learning habits
- **Levels** — Progress from Beginner to Expert
- **55 Achievements** — Unlock badges for milestones
- **Shop** — Buy XP boosts, streak freezes, themes, and more

### 🛠️ Tools & Calculators
- Tank Volume Calculator
- Water Change Calculator
- Stocking Calculator
- CO₂ Calculator
- Dosing Calculator
- Unit Converter
- Lighting Schedule Planner
- Cost Tracker

### 📊 Analytics
- Water parameter trends over time
- XP and learning progress charts
- Tank comparison tools
- Daily/weekly goal tracking

---

## 📸 Screenshots

*Screenshots will be added before launch. Run the app to experience all features!*

**Key Screens:**
- 🏠 **Home** - XP progress, streaks, daily goals, quick access
- 📚 **Learning Hub** - Lesson paths, progress tracking, spaced repetition
- 🐟 **Tank Detail** - Species, parameters, maintenance, photos
- 🏆 **Achievements** - 55 badges across 5 categories
- 🏪 **Shop** - Gem economy, XP boosts, themes
- 📊 **Analytics** - Progress charts, trends, insights

---

## 🚀 Getting Started

### Prerequisites
- **Flutter SDK 3.10+**
- **Dart 3.10+**
- **Android Studio** or **VS Code** with Flutter extensions
- **Android SDK** (for Android builds)
- **Xcode 14+** (for iOS builds, macOS only)

### Quick Start

1. **Clone the repository**
   ```bash
   git clone https://github.com/tiarnanlarkin/aquarium-app.git
   cd aquarium-app/apps/aquarium_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   # Debug mode (with hot reload)
   flutter run

   # Release mode (optimized)
   flutter run --release

   # Profile mode (for performance testing)
   flutter run --profile
   ```

### Build APK

```bash
# Debug APK
flutter build apk --debug

# Release APK (for distribution)
flutter build apk --release

# Release APK path
# build/app/outputs/flutter-apk/app-release.apk
```

**Windows Build Script:**
```batch
# Use provided script
build-debug.bat      # Debug build
build-release.ps1    # Release build
```

**WSL Build Script:**
```bash
./build-and-test.sh # Build and run tests
```

See [BUILD_RELEASE_GUIDE.md](docs/BUILD_RELEASE_GUIDE.md) for detailed build instructions.

---

## 🧪 Development Setup

### Running Tests

```bash
# Run all tests
flutter test

# Run with coverage report
flutter test --coverage

# Run specific test file
flutter test test/hearts_test.dart

# Run integration tests
flutter test integration_test/
```

**Test Coverage:** 98%+ (435+ tests passing)

### Code Quality

```bash
# Analyze code for issues
flutter analyze

# Format code
dart format .

# Check for outdated dependencies
flutter pub outdated
```

### DevTools Profiling

```bash
# Install DevTools
flutter pub global activate devtools

# Run DevTools
flutter pub global run devtools

# Profile app performance
flutter run --profile
```

See [docs/performance/PROFILE.md](docs/performance/PROFILE.md) for performance benchmarks.

---

## 🏗️ Tech Stack

---

## 🏗️ Tech Stack

| Category | Technology |
|----------|------------|
| **Framework** | Flutter 3.10 |
| **Language** | Dart 3.10 |
| **State Management** | Riverpod 2.6 |
| **Navigation** | Go Router |
| **Local Storage** | Shared Preferences |
| **Charts** | FL Chart |
| **Animations** | Confetti (celebrations) |
| **Images** | Cached Network Image |
| **Notifications** | Flutter Local Notifications |
| **Architecture** | Clean Architecture with Provider pattern |

---

## 📁 Project Structure

```
lib/
├── models/                    # Data models (29 files)
│   ├── achievements.dart      # Achievement system
│   ├── exercises.dart         # Quiz/exercise types
│   ├── learning.dart          # Lesson, Path, Quiz models
│   ├── tank.dart              # Tank entity
│   ├── species.dart           # Fish species database
│   ├── user_profile.dart      # User state
│   └── ...
│
├── providers/                 # State management (15 files)
│   ├── user_profile_provider.dart
│   ├── tanks_provider.dart
│   ├── settings_provider.dart
│   └── ...
│
├── services/                  # Business logic (25 files)
│   ├── achievement_service.dart
│   ├── hearts_service.dart
│   ├── celebration_service.dart
│   ├── analytics_service.dart
│   ├── storage_service.dart
│   └── ...
│
├── screens/                   # UI screens (86 files)
│   ├── home/                  # Home screen + widgets
│   ├── onboarding/            # First-run experience
│   ├── rooms/                 # Virtual room system
│   ├── tank_detail/           # Tank management
│   ├── learn_screen.dart      # Learning hub
│   └── ...
│
├── widgets/                   # Reusable components (50+ files)
│   ├── core/                  # Base UI components
│   ├── celebrations/          # Confetti, animations
│   ├── mascot/                # Animated mascot
│   └── ...
│
├── theme/                     # App styling (2 files)
│   ├── app_theme.dart
│   └── colors.dart
│
├── utils/                     # Helpers (12 files)
│   ├── animations.dart
│   ├── date_utils.dart
│   ├── performance_monitor.dart
│   └── ...
│
├── data/                      # Static content (20+ files)
│   ├── lessons/               # Lesson content
│   ├── achievements.dart      # Achievement definitions
│   ├── species_database.dart  # Fish species data
│   └── ...
│
└── main.dart                  # App entry point

Total: 284 Dart files
```

---

## 🧪 Testing

### Test Coverage

| Type | Count | Status |
|------|-------|--------|
| **Unit Tests** | 435+ | ✅ 98% coverage |
| **Widget Tests** | 50+ | ✅ All passing |
| **Integration Tests** | 10+ | ✅ All passing |

### Running Tests

```bash
# Run all tests
flutter test

# Run with coverage report
flutter test --coverage

# Run specific test file
flutter test test/hearts_test.dart

# Run integration tests
flutter test integration_test/

# View coverage report
# Generated in coverage/lcov.info
```

See [docs/testing/](docs/testing/) for detailed test documentation.

---

## 📖 Documentation

### Architecture & Design

| Document | Description |
|----------|-------------|
| [docs/architecture/CURRENT_STATE.md](docs/architecture/CURRENT_STATE.md) | Complete architecture overview (7.5/10 score) |
| [ARCHITECTURE_DIAGRAM.txt](ARCHITECTURE_DIAGRAM.txt) | Exercise system architecture |
| [docs/performance/PROFILE.md](docs/performance/PROFILE.md) | Performance benchmarks (60fps target met) |

### Guides & Tutorials

| Document | Description |
|----------|-------------|
| [docs/BUILD_RELEASE_GUIDE.md](docs/BUILD_RELEASE_GUIDE.md) | Build and deployment guide |
| [docs/accessibility/](docs/accessibility/) | Accessibility implementation |
| [E2E_TESTING_GUIDE.md](E2E_TESTING_GUIDE.md) | End-to-end testing |
| [WIDGET_TEST_GUIDE.md](WIDGET_TEST_GUIDE.md) | Widget testing guide |

### Feature Documentation

| Document | Description |
|----------|-------------|
| [HEARTS_SYSTEM_IMPLEMENTATION.md](HEARTS_SYSTEM_IMPLEMENTATION.md) | Hearts/lives system |
| [OFFLINE_MODE_IMPLEMENTATION.md](OFFLINE_MODE_IMPLEMENTATION.md) | Offline-first design |
| [CELEBRATION_SYSTEM_FINAL_REPORT.md](docs/completed/CELEBRATION_SYSTEM_FINAL_REPORT.md) | Celebration animations |
| [PERFORMANCE_OPTIMIZATION_COMPLETE.md](PERFORMANCE_OPTIMIZATION_COMPLETE.md) | Performance optimizations |

### Launch & Deployment

| Document | Description |
|----------|-------------|
| [docs/launch/READINESS_CHECKLIST.md](docs/launch/READINESS_CHECKLIST.md) | Launch readiness checklist ✅ |
| [docs/analytics/TRACKING_PLAN.md](docs/analytics/TRACKING_PLAN.md) | Analytics tracking plan |

---

## 🎯 Performance

### Performance Metrics

| Metric | Target | Actual | Status |
|--------|--------|--------|--------|
| **Cold Start Time** | <3s | 1.8-2.2s | ✅ Excellent |
| **Frame Rate** | 60fps | 58-60fps | ✅ Excellent |
| **Memory Usage** | <150MB | 80-120MB | ✅ Good |
| **APK Size** | <15MB | 9-12MB | ✅ On target |
| **Test Coverage** | >90% | 98%+ | ✅ Outstanding |

See [docs/performance/PROFILE.md](docs/performance/PROFILE.md) for detailed performance analysis.

---

## 🛠️ Development Guidelines

### Code Conventions

- **File naming:** `snake_case.dart`
- **Class naming:** `PascalCase`
- **Variable naming:** `camelCase`
- **Private members:** `_leadingUnderscore`
- **Dartdoc comments:** All public APIs documented
- **Max line length:** 80 characters

### State Management Rules

- Use Riverpod providers for all state
- Prefer `ConsumerWidget` over `StatefulWidget`
- Use `select()` for fine-grained updates
- Auto-dispose providers when not needed
- Keep services stateless, state in providers

### Testing Guidelines

- Write unit tests for all services
- Test widget rendering and interactions
- Mock external dependencies
- Test error states and edge cases
- Aim for >90% coverage

### Pull Request Checklist

- [ ] All tests pass
- [ ] No new lint warnings
- [ ] Added/updated documentation
- [ ] Updated CHANGELOG.md
- [ ] Manual testing completed
- [ ] No performance regressions

---

## 🎯 Roadmap

### Completed Phases ✅

- [x] **Phase 0:** Navigation & Quick Wins (Dec 2024)
- [x] **Phase 1:** Gamification Integration (Jan 2025)
- [x] **Phase 2:** Content Expansion (Jan 2025)
- [x] **Phase 2.1:** Reduced Motion & Accessibility (Feb 2025)
- [x] **Phase 3:** Quality & Polish (Feb 2025) ✅

### Future Phases 🚧

- [ ] **Phase 4:** Backend & Cloud Sync (Q2 2025)
  - Firebase Auth (user accounts)
  - Firestore sync (cross-device)
  - Real leaderboards
  - Push notifications
  - Analytics enabled

- [ ] **Phase 5:** Social Features (Q3 2025)
  - Friend system (real)
  - Share achievements
  - Community challenges
  - Multiplayer quizzes

- [ ] **Phase 6:** Advanced Features (Q4 2025)
  - AI-powered recommendations
  - Advanced analytics
  - Custom themes marketplace
  - In-app purchases

---

## 🚀 Deployment

### Pre-Flight Checklist

- [ ] All tests passing
- [ ] Clean build successful
- [ ] Version number updated
- [ ] Release notes prepared
- [ ] Store assets finalized
- [ ] Privacy policy updated
- [ ] Terms of service updated

See [docs/launch/READINESS_CHECKLIST.md](docs/launch/READINESS_CHECKLIST.md) for complete launch checklist.

---

## 📋 Known Issues

### Non-Critical

1. **Firebase Analytics** - Code ready, not enabled (waiting for Firebase project setup)
2. **Social Features** - Leaderboards use mock data (real data in Phase 4)
3. **Cloud Sync** - Data is local-only (cloud sync in Phase 4)
4. **Room Scene FPS** - Occasional 52-55fps on room screen (still smooth)

All issues are non-blocking and documented in [docs/launch/READINESS_CHECKLIST.md](docs/launch/READINESS_CHECKLIST.md).

---

## 👤 Contributing

This is a proprietary project. Contributions are not currently accepted.

### For Internal Development

1. Create a feature branch: `git checkout -b feature/amazing-feature`
2. Make your changes
3. Write tests for new functionality
4. Run `flutter test` to ensure all tests pass
5. Run `flutter analyze` to check for issues
6. Commit with descriptive message
7. Push and create a pull request

### Code Review Checklist

- [ ] Code follows project conventions
- [ ] Tests added/updated
- [ ] Documentation updated
- [ ] No performance regressions
- [ ] Accessibility considered

---

## 👤 Author

**Tiarnan Larkin**  
- GitHub: [@tiarnanlarkin](https://github.com/tiarnanlarkin)
- Project: Aquarium Hobby App (v1.0.0)

---

## 📄 License

This project is proprietary software. All rights reserved.

© 2025 Tiarnan Larkin. All rights reserved.

---

## 🙏 Acknowledgments

- **Duolingo** - Inspired the gamification approach
- **Flutter Team** - Amazing framework and community
- **Riverpod Team** - Excellent state management
- **Aquarium Community** - Species data and care information compiled from various hobby resources
- **Material Design** - Beautiful icon set and design system

---

## 📞 Support

### Documentation
- [Architecture](docs/architecture/CURRENT_STATE.md)
- [Performance](docs/performance/PROFILE.md)
- [Analytics](docs/analytics/TRACKING_PLAN.md)
- [Build Guide](docs/BUILD_RELEASE_GUIDE.md)
- [Launch Checklist](docs/launch/READINESS_CHECKLIST.md)

### Legal
- [Privacy Policy](docs/privacy-policy.html)
- [Terms of Service](docs/terms-of-service.html)

---

## 📊 Stats

- **Total Files:** 284 Dart files
- **Lines of Code:** ~50,000+
- **Screens:** 86
- **Widgets:** 50+
- **Services:** 25
- **Tests:** 435+ (98% coverage)
- **Achievements:** 55
- **Lessons:** 50+
- **Species:** 122 fish + 52 plants

---

*"Teach a man to fish, and he'll learn about water chemistry." - Ancient Aquarium Wisdom*

---

**🐠 Happy Fishkeeping! 🐠**
