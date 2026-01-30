# 🐟 Aquarium Hobby App

A personal aquarium management app for freshwater hobbyists — track tanks, livestock, equipment, maintenance, and water parameters in one calm, organized interface.

![Flutter](https://img.shields.io/badge/Flutter-3.38+-blue.svg)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-green.svg)
![License](https://img.shields.io/badge/License-Private-red.svg)

## ✨ Features

### Core Features
- **Multi-tank management** — Track unlimited aquariums with individual settings
- **Water test logging** — Log NH₃, NO₂, NO₃, pH, GH, KH, temp, PO₄ with visual trends
- **Task management** — Recurring maintenance reminders with snooze/disable
- **Livestock tracking** — Add fish, shrimp, snails with species database integration
- **Equipment management** — Track filters, heaters, lights with maintenance schedules
- **Photo attachments** — Add photos to any log entry

### Smart Features
- **Compatibility checking** — Warns when livestock don't match tank parameters
- **Species database** — 45+ freshwater species with care requirements
- **Dashboard alerts** — Parameter warnings, trend detection, test overdue notices
- **State badges** — Quick visual status on home screen cards

### Quality of Life
- **Quick-add FAB** — One-tap water test, water change, feeding, observation
- **Global search** — Find tanks, fish, equipment, or browse species
- **Dark mode** — Full dark theme support with system preference
- **Data backup** — Export/import JSON for backup and transfer
- **Local notifications** — Task reminders at 9 AM on due date
- **Shop Street** — Curated aquarium shop directory (UK/US/EU)

## 📱 Screenshots

*Coming soon*

## 🚀 Getting Started

### Prerequisites
- Flutter 3.38+
- Android SDK 36+ or iOS 12+
- Dart 3.10+

### Installation

1. Clone the repository:
```bash
git clone https://github.com/tiarnanlarkin/aquarium-app.git
cd aquarium-app/apps/aquarium_app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### Building for Release

**Android APK:**
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

**Android App Bundle:**
```bash
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
```

## 🏗️ Architecture

```
lib/
├── data/           # Static data (species database, shop directory)
├── models/         # Data models (Tank, Livestock, Equipment, etc.)
├── providers/      # Riverpod state management
├── screens/        # UI screens
├── services/       # Business logic (storage, notifications, etc.)
├── theme/          # App theme and colors
├── widgets/        # Reusable UI components
└── main.dart       # App entry point
```

### Key Technologies
- **State Management:** Riverpod
- **Local Storage:** JSON file-based persistence
- **Charts:** fl_chart
- **Notifications:** flutter_local_notifications
- **Navigation:** MaterialPageRoute (simple navigation)

## 📊 Data Model

### Tank
- Name, type (freshwater/marine), volume, dimensions
- Start date, target parameters (temp, pH, GH, KH ranges)

### Livestock
- Common name, scientific name, count
- Links to species database for care requirements

### Equipment
- Type (filter, heater, light, etc.), brand, model
- Maintenance interval, last serviced date
- Auto-generates maintenance tasks

### Logs
- Water tests with all parameters
- Water changes with percentage
- Feeding, medication, observations
- Photo attachments

### Tasks
- User-created and auto-generated
- Recurring schedules (daily, weekly, monthly, custom)
- Completion history tracking

## 🎨 Design Philosophy

1. **Calm UX** — No alarm fatigue, no spammy notifications
2. **Equipment as first-class objects** — Each piece has settings, maintenance, history
3. **Local-first** — Your data stays on your device
4. **Accuracy over certainty** — Guidance is educational, not diagnostic

## 🗺️ Roadmap

### ✅ Phase 1: Core MVP (Complete)
- Tank creation and management
- Water test logging with trends
- Tasks and reminders
- Livestock and equipment tracking
- Charts and data export

### ✅ Phase 2: MVP+ (Complete)
- Species database with compatibility
- Dark mode
- Global search
- Notifications
- Shop directory

### 🔜 Phase 3: Future
- Plant identification (AI)
- Marine/reef support
- Cloud sync (optional)
- Community features

## 📄 License

Private project — not for redistribution.

## 🙏 Acknowledgments

- Species data compiled from Seriously Fish, Aquarium Wiki, and fishkeeping community resources
- Built with Flutter and ❤️
