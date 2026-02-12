# 🐠 Aquarium Hobby App

**Your Personal Aquarium Companion — Learn, Track, Thrive**

A beautiful, gamified mobile app for aquarium hobbyists of all levels. Track your tanks, learn the hobby, and level up your fishkeeping skills with Duolingo-style engagement mechanics.

![Flutter](https://img.shields.io/badge/Flutter-3.10-blue)
![Dart](https://img.shields.io/badge/Dart-3.10-blue)
![Riverpod](https://img.shields.io/badge/Riverpod-2.6-purple)
![License](https://img.shields.io/badge/License-Proprietary-red)

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

| Home | Learning | Tank Detail |
|------|----------|-------------|
| ![Home](docs/screenshots/home.png) | ![Learning](docs/screenshots/learning.png) | ![Tank](docs/screenshots/tank-detail.png) |

| Species Browser | Shop | Achievements |
|-----------------|------|--------------|
| ![Species](docs/screenshots/species.png) | ![Shop](docs/screenshots/shop.png) | ![Achievements](docs/screenshots/achievements.png) |

*Screenshots pending — run the app to see the full experience!*

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.10+
- Dart 3.10+
- Android Studio or VS Code with Flutter extensions
- Android SDK (for Android builds)
- Xcode (for iOS builds, macOS only)

### Installation

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
   # Debug mode
   flutter run

   # Release mode
   flutter run --release
   ```

### Build APK

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release
```

APK output: `build/app/outputs/flutter-apk/`

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
├── models/           # Data models (Tank, Species, User, etc.)
├── providers/        # Riverpod providers (state management)
├── screens/          # UI screens (86 total)
├── services/         # Business logic services
├── widgets/          # Reusable UI components
├── theme/            # App theming and colors
├── utils/            # Helper utilities
└── main.dart         # App entry point
```

---

## 🧪 Testing

```bash
# Run all unit tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/hearts_test.dart
```

**Current Coverage:** 98%+ (435+ tests passing)

---

## 📖 Documentation

| Document | Description |
|----------|-------------|
| [CHANGELOG.md](CHANGELOG.md) | Version history and changes |
| [docs/FEATURE_LIST.md](../../docs/FEATURE_LIST.md) | Comprehensive feature list |
| [docs/planning/](../../docs/planning/) | Roadmaps and planning docs |
| [docs/testing/](../../docs/testing/) | Test reports and audits |
| [docs/guides/](../../docs/guides/) | User-facing guides |

---

## 🎯 Roadmap

- [x] **Phase 0:** Navigation & Quick Wins ✅
- [x] **Phase 1:** Gamification Integration ✅
- [x] **Phase 2:** Content Expansion ✅
- [ ] **Phase 3:** Quality & Polish (in progress)
- [ ] **Phase 4:** Backend & Cloud Sync (future)

See [MASTER_INTEGRATION_ROADMAP.md](../../MASTER_INTEGRATION_ROADMAP.md) for details.

---

## 👤 Author

**Tiarnan Larkin**  
- GitHub: [@tiarnanlarkin](https://github.com/tiarnanlarkin)

---

## 📄 License

This project is proprietary software. All rights reserved.

---

## 🙏 Acknowledgments

- Inspired by Duolingo's gamification approach
- Built with Flutter and the amazing Riverpod ecosystem
- Species data compiled from various aquarium resources
- Icons from Material Design

---

*Made with ❤️ for the aquarium hobby community*
