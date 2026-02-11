# Navigation & Accessibility Roadmap

**Version:** 1.0  
**Date:** February 9, 2025  
**Mission:** Link ALL orphaned/hidden features to make 41% of unreachable code accessible  
**Impact:** Unlock 30+ fully-implemented features with 1-2 hours of work  

---

## Executive Summary

### Current State
- **90 total screens** built
- **83 accessible** (92.2%)
- **35 fully-implemented screens** are dead code (41% waste)
- **3 working calculators** hidden from users
- **15 comprehensive guides** not linked anywhere

### Target State
- **100% screen accessibility** 
- **Zero dead code** (everything linked or intentionally archived)
- **Enhanced Workshop** - All calculators accessible
- **Expanded Settings** - All guides reachable
- **Clear navigation paths** - Every feature ≤3 taps away

### Quick Wins (High Value, Low Effort)
1. **Water Change Calculator** - 5 min (add to Workshop grid)
2. **Stocking Calculator** - 5 min (add to Workshop grid)
3. **15 Guide Screens** - 30 min (add "Guides" section to Settings)
4. **Unit Converter** - 5 min (link from Workshop Quick Reference)

**Total Time to 30% More Features: 1-2 hours**

---

## 1. Complete Inventory of Unreachable Features

### 1.1 Calculators & Tools (13 screens) 🔧

| Screen | Status | Implementation | Value | Effort |
|--------|--------|----------------|-------|--------|
| `water_change_calculator_screen.dart` | ✅ 100% Complete | Full calculator with edge cases | **CRITICAL** | 5 min |
| `stocking_calculator_screen.dart` | ✅ 100% Complete | Bioload with species database | **HIGH** | 5 min |
| `tank_volume_calculator_screen.dart` | ✅ 100% Complete | 5 tank shapes, full features | **HIGH** | 10 min |
| `unit_converter_screen.dart` | ✅ 95% Complete | 4 tabs (volume, temp, length, hardness) | **MEDIUM** | 5 min |
| `co2_calculator_screen.dart` | ✅ 98% Complete | pH/KH → CO₂ with charts | **HIGH** | 5 min |
| `dosing_calculator_screen.dart` | ✅ 90% Complete | Fertilizer/treatment dosing | **HIGH** | 5 min |
| `lighting_schedule_screen.dart` | ✅ 85% Complete | Light timing control | **MEDIUM** | 10 min |
| `compatibility_checker_screen.dart` | ✅ 96% Complete | Multi-species compatibility | **HIGH** | 5 min |
| `cost_tracker_screen.dart` | ✅ 88% Complete | Expense tracking | **MEDIUM** | 5 min |
| `livestock_value_screen.dart` | ✅ 85% Complete | Livestock value tracking | **LOW** | 10 min |
| `tank_comparison_screen.dart` | ✅ 90% Complete | Compare multiple tanks | **MEDIUM** | 10 min |
| `tank_settings_screen.dart` | ✅ 75% Complete | Tank configuration | **MEDIUM** | 10 min |
| `charts_screen.dart` | ✅ 90% Complete | Parameter charts/graphs | **HIGH** | 10 min |

**Total: 13 screens | Average Completeness: 91% | Time to Link: 1.5 hours**

---

### 1.2 Educational Guides (26 screens) 📚

#### Core Care Guides (10 screens)
| Screen | Implementation | Value | Effort |
|--------|----------------|-------|--------|
| `parameter_guide_screen.dart` | ✅ 100% | **CRITICAL** | 5 min |
| `nitrogen_cycle_guide_screen.dart` | ✅ 100% | **CRITICAL** | 5 min |
| `disease_guide_screen.dart` | ✅ 100% | **HIGH** | 5 min |
| `algae_guide_screen.dart` | ✅ 100% | **HIGH** | 5 min |
| `feeding_guide_screen.dart` | ✅ 100% | **HIGH** | 5 min |
| `breeding_guide_screen.dart` | ✅ 100% | **MEDIUM** | 5 min |
| `acclimation_guide_screen.dart` | ✅ 100% | **HIGH** | 5 min |
| `quarantine_guide_screen.dart` | ✅ 100% | **MEDIUM** | 5 min |
| `emergency_guide_screen.dart` | ✅ 100% | **HIGH** | 5 min |
| `vacation_guide_screen.dart` | ✅ 100% | **MEDIUM** | 5 min |

#### Setup & Equipment Guides (6 screens)
| Screen | Implementation | Value | Effort |
|--------|----------------|-------|--------|
| `quick_start_guide_screen.dart` | ✅ 100% | **CRITICAL** | 5 min |
| `equipment_guide_screen.dart` | ✅ 100% | **HIGH** | 5 min |
| `substrate_guide_screen.dart` | ✅ 100% | **MEDIUM** | 5 min |
| `hardscape_guide_screen.dart` | ✅ 100% | **MEDIUM** | 5 min |
| `troubleshooting_screen.dart` | ✅ 100% | **HIGH** | 5 min |
| `glossary_screen.dart` | ✅ 100% | **MEDIUM** | 5 min |

**Subtotal: 16 screens | All 100% Complete | Time: 1.5 hours**

---

### 1.3 Settings & Configuration (6 screens) ⚙️

| Screen | Implementation | Value | Effort |
|--------|----------------|-------|--------|
| `backup_restore_screen.dart` | ✅ 95% | **HIGH** | 5 min |
| `difficulty_settings_screen.dart` | ✅ 80% | **MEDIUM** | 10 min |
| `notification_settings_screen.dart` | ✅ 90% | **HIGH** | 5 min |
| `theme_gallery_screen.dart` | ✅ 75% | **MEDIUM** | 5 min |
| `offline_mode_demo_screen.dart` | ✅ 90% | **LOW** | 5 min |
| `xp_animations_demo_screen.dart` | ✅ 90% | **LOW** | 5 min |

**Total: 6 screens | Average: 87% | Time: 35 min**

---

### 1.4 Orphaned/Duplicate Screens (7 screens) 🗑️

| Screen | Status | Recommendation | Effort |
|--------|--------|----------------|--------|
| `enhanced_quiz_screen.dart` | Alternative implementation | Archive or integrate | 30 min |
| `placement_test_screen.dart` | Not implemented yet | Link from onboarding OR delete | 20 min |
| `placement_result_screen.dart` | Not implemented yet | Link from placement_test OR delete | 10 min |
| `enhanced_placement_test_screen.dart` | Alternative implementation | Choose one, archive other | 30 min |
| `enhanced_onboarding_screen.dart` | Alternative implementation | Archive | 5 min |
| `gem_shop_screen.dart` | Feature not launched | Link from shop_street OR delete | 15 min |
| `stories_screen.dart` | Already accessible | Verify navigation | 5 min |
| `story_player_screen.dart` | Already accessible | Verify navigation | 5 min |

**Total: 7 screens | Decision Required | Time: 2 hours (if implementing)**

---

## 2. Feature-by-Feature Linking Plan

### 2.1 Workshop Screen Expansion 🔧

**Current State:**
```
Workshop Grid (6 items):
├─ Tank Volume (modal only) ⚠️
├─ CO₂ Calculator ❌
├─ Dosing Calculator ❌
├─ Compatibility Checker ❌
├─ Equipment 🚧 (placeholder)
└─ Cost Tracker ❌
```

**Target State:**
```
Workshop Grid (4×3 = 12 items):

Row 1: Volume & Calculations
├─ Tank Volume (full screen) ✅
├─ Water Change Calculator ✅
├─ Stocking Calculator ✅
└─ CO₂ Calculator ✅

Row 2: Dosing & Chemistry
├─ Dosing Calculator ✅
├─ Unit Converter ✅
├─ Charts & Data ✅
└─ Parameter Logs ✅

Row 3: Planning & Management
├─ Compatibility Checker ✅
├─ Cost Tracker ✅
├─ Lighting Schedule ✅
└─ Equipment Manager ✅

Bottom Section:
└─ Quick Reference (existing) ✅
```

#### Implementation Steps:

**Step 1: Add Missing Calculator Buttons (30 min)**

**File:** `lib/screens/workshop_screen.dart`

**Changes Required:**

1. **Replace modal Tank Volume with full screen** (Line ~180)
```dart
// OLD: _showVolumeCalculatorSheet(context);
// NEW:
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const TankVolumeCalculatorScreen(),
  ),
);
```

2. **Add Water Change Calculator button** (after existing grid items)
```dart
_ToolCard(
  icon: Icons.water_drop,
  title: 'Water Change',
  subtitle: 'Calculate change %',
  color: Colors.blue,
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const WaterChangeCalculatorScreen(),
    ),
  ),
),
```

3. **Add Stocking Calculator button**
```dart
_ToolCard(
  icon: Icons.show_chart,
  title: 'Stocking',
  subtitle: 'Bioload calculator',
  color: Colors.green,
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const StockingCalculatorScreen(),
    ),
  ),
),
```

4. **Add CO₂ Calculator button**
```dart
_ToolCard(
  icon: Icons.bubble_chart,
  title: 'CO₂',
  subtitle: 'pH/KH calculator',
  color: Colors.teal,
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const Co2CalculatorScreen(),
    ),
  ),
),
```

5. **Add Dosing Calculator button**
```dart
_ToolCard(
  icon: Icons.science,
  title: 'Dosing',
  subtitle: 'Treatment calculator',
  color: Colors.purple,
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const DosingCalculatorScreen(),
    ),
  ),
),
```

6. **Add Unit Converter button**
```dart
_ToolCard(
  icon: Icons.swap_horiz,
  title: 'Converter',
  subtitle: 'Units & conversions',
  color: Colors.orange,
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const UnitConverterScreen(),
    ),
  ),
),
```

7. **Add Charts button**
```dart
_ToolCard(
  icon: Icons.bar_chart,
  title: 'Charts',
  subtitle: 'Parameter graphs',
  color: Colors.indigo,
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const ChartsScreen(),
    ),
  ),
),
```

8. **Add Compatibility Checker button**
```dart
_ToolCard(
  icon: Icons.pets,
  title: 'Compatibility',
  subtitle: 'Species checker',
  color: Colors.pink,
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const CompatibilityCheckerScreen(),
    ),
  ),
),
```

9. **Add Lighting Schedule button**
```dart
_ToolCard(
  icon: Icons.light_mode,
  title: 'Lighting',
  subtitle: 'Schedule timer',
  color: Colors.amber,
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const LightingScheduleScreen(),
    ),
  ),
),
```

10. **Equipment Manager decision:**
```dart
// OPTION A: Keep placeholder with roadmap note
_ToolCard(
  icon: Icons.build,
  title: 'Equipment',
  subtitle: 'Coming soon',
  color: Colors.grey,
  onTap: () => _showComingSoonDialog(context),
),

// OPTION B: Remove entirely (recommended until implemented)
```

**Required Imports:**
```dart
import 'package:aquarium_app/screens/tank_volume_calculator_screen.dart';
import 'package:aquarium_app/screens/water_change_calculator_screen.dart';
import 'package:aquarium_app/screens/stocking_calculator_screen.dart';
import 'package:aquarium_app/screens/co2_calculator_screen.dart';
import 'package:aquarium_app/screens/dosing_calculator_screen.dart';
import 'package:aquarium_app/screens/unit_converter_screen.dart';
import 'package:aquarium_app/screens/charts_screen.dart';
import 'package:aquarium_app/screens/compatibility_checker_screen.dart';
import 'package:aquarium_app/screens/lighting_schedule_screen.dart';
```

**Time Estimate:** 30 minutes

---

### 2.2 Settings Screen Expansion 📋

**Current State:**
Settings screen has 40+ links, but missing organized guide section

**Target State:**
```
Settings Screen Sections:

┌─────────────────────────────────┐
│ ⚙️ App Settings                  │
├─────────────────────────────────┤
│ Theme Gallery                   │
│ Notifications                   │
│ Backup & Restore               │
│ Difficulty Settings             │
│ Offline Mode Demo              │
└─────────────────────────────────┘

┌─────────────────────────────────┐
│ 📚 Guides & Education           │ ← NEW SECTION
├─────────────────────────────────┤
│ Getting Started                 │
│ ├─ Quick Start Guide            │
│ └─ Glossary                     │
│                                 │
│ Water Chemistry                 │
│ ├─ Parameter Guide              │
│ ├─ Nitrogen Cycle Guide         │
│ └─ Troubleshooting              │
│                                 │
│ Fish Care                       │
│ ├─ Disease Guide                │
│ ├─ Feeding Guide                │
│ ├─ Acclimation Guide            │
│ ├─ Quarantine Guide             │
│ └─ Breeding Guide               │
│                                 │
│ Tank Setup                      │
│ ├─ Equipment Guide              │
│ ├─ Substrate Guide              │
│ └─ Hardscape Guide              │
│                                 │
│ Maintenance                     │
│ ├─ Algae Guide                  │
│ ├─ Emergency Guide              │
│ └─ Vacation Guide               │
└─────────────────────────────────┘

┌─────────────────────────────────┐
│ 🔧 Advanced Tools               │
├─────────────────────────────────┤
│ Tank Comparison                 │
│ Tank Settings                   │
│ Livestock Value Tracker         │
│ XP Animations Demo             │
└─────────────────────────────────┘

┌─────────────────────────────────┐
│ ℹ️ Information                   │
├─────────────────────────────────┤
│ FAQ                             │
│ About                           │
│ Privacy Policy                  │
│ Terms of Service                │
└─────────────────────────────────┘
```

#### Implementation Steps:

**Step 1: Add Guides Section to Settings (45 min)**

**File:** `lib/screens/settings_screen.dart`

**Changes Required:**

Add new section after app settings, before information section:

```dart
// GUIDES & EDUCATION SECTION
SliverToBoxAdapter(
  child: Padding(
    padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
    child: Text(
      '📚 Guides & Education',
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    ),
  ),
),

// Getting Started
_buildExpansionTile(
  context,
  title: 'Getting Started',
  icon: Icons.play_circle_outline,
  children: [
    _buildSettingTile(
      context,
      title: 'Quick Start Guide',
      subtitle: 'Beginner-friendly setup',
      icon: Icons.rocket_launch,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const QuickStartGuideScreen(),
        ),
      ),
    ),
    _buildSettingTile(
      context,
      title: 'Glossary',
      subtitle: 'Aquarium terminology',
      icon: Icons.menu_book,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const GlossaryScreen(),
        ),
      ),
    ),
  ],
),

// Water Chemistry
_buildExpansionTile(
  context,
  title: 'Water Chemistry',
  icon: Icons.water_drop,
  children: [
    _buildSettingTile(
      context,
      title: 'Parameter Guide',
      subtitle: 'pH, ammonia, nitrite, nitrate',
      icon: Icons.science,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ParameterGuideScreen(),
        ),
      ),
    ),
    _buildSettingTile(
      context,
      title: 'Nitrogen Cycle',
      subtitle: 'Understanding the cycle',
      icon: Icons.refresh,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const NitrogenCycleGuideScreen(),
        ),
      ),
    ),
    _buildSettingTile(
      context,
      title: 'Troubleshooting',
      subtitle: 'Fix common issues',
      icon: Icons.build,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const TroubleshootingScreen(),
        ),
      ),
    ),
  ],
),

// Fish Care
_buildExpansionTile(
  context,
  title: 'Fish Care',
  icon: Icons.pets,
  children: [
    _buildSettingTile(
      context,
      title: 'Disease Guide',
      subtitle: 'Identify and treat diseases',
      icon: Icons.healing,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const DiseaseGuideScreen(),
        ),
      ),
    ),
    _buildSettingTile(
      context,
      title: 'Feeding Guide',
      subtitle: 'Nutrition and schedules',
      icon: Icons.restaurant,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const FeedingGuideScreen(),
        ),
      ),
    ),
    _buildSettingTile(
      context,
      title: 'Acclimation Guide',
      subtitle: 'Safely introduce new fish',
      icon: Icons.trending_down,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AcclimationGuideScreen(),
        ),
      ),
    ),
    _buildSettingTile(
      context,
      title: 'Quarantine Guide',
      subtitle: 'Prevent disease spread',
      icon: Icons.medical_services,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const QuarantineGuideScreen(),
        ),
      ),
    ),
    _buildSettingTile(
      context,
      title: 'Breeding Guide',
      subtitle: 'Breeding basics',
      icon: Icons.favorite,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const BreedingGuideScreen(),
        ),
      ),
    ),
  ],
),

// Tank Setup
_buildExpansionTile(
  context,
  title: 'Tank Setup',
  icon: Icons.water,
  children: [
    _buildSettingTile(
      context,
      title: 'Equipment Guide',
      subtitle: 'Filters, heaters, lights',
      icon: Icons.settings_input_component,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const EquipmentGuideScreen(),
        ),
      ),
    ),
    _buildSettingTile(
      context,
      title: 'Substrate Guide',
      subtitle: 'Choosing substrate',
      icon: Icons.terrain,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SubstrateGuideScreen(),
        ),
      ),
    ),
    _buildSettingTile(
      context,
      title: 'Hardscape Guide',
      subtitle: 'Rocks and driftwood',
      icon: Icons.landscape,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const HardscapeGuideScreen(),
        ),
      ),
    ),
  ],
),

// Maintenance
_buildExpansionTile(
  context,
  title: 'Maintenance',
  icon: Icons.cleaning_services,
  children: [
    _buildSettingTile(
      context,
      title: 'Algae Guide',
      subtitle: 'Control and prevention',
      icon: Icons.grass,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AlgaeGuideScreen(),
        ),
      ),
    ),
    _buildSettingTile(
      context,
      title: 'Emergency Guide',
      subtitle: 'Handle emergencies',
      icon: Icons.warning,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const EmergencyGuideScreen(),
        ),
      ),
    ),
    _buildSettingTile(
      context,
      title: 'Vacation Guide',
      subtitle: 'Prepare for time away',
      icon: Icons.beach_access,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const VacationGuideScreen(),
        ),
      ),
    ),
  ],
),
```

**Helper method for expansion tiles:**
```dart
Widget _buildExpansionTile(
  BuildContext context, {
  required String title,
  required IconData icon,
  required List<Widget> children,
}) {
  return Card(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    child: ExpansionTile(
      leading: Icon(icon),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      children: children,
    ),
  );
}
```

**Required Imports:**
```dart
import 'package:aquarium_app/screens/quick_start_guide_screen.dart';
import 'package:aquarium_app/screens/glossary_screen.dart';
import 'package:aquarium_app/screens/parameter_guide_screen.dart';
import 'package:aquarium_app/screens/nitrogen_cycle_guide_screen.dart';
import 'package:aquarium_app/screens/troubleshooting_screen.dart';
import 'package:aquarium_app/screens/disease_guide_screen.dart';
import 'package:aquarium_app/screens/feeding_guide_screen.dart';
import 'package:aquarium_app/screens/acclimation_guide_screen.dart';
import 'package:aquarium_app/screens/quarantine_guide_screen.dart';
import 'package:aquarium_app/screens/breeding_guide_screen.dart';
import 'package:aquarium_app/screens/equipment_guide_screen.dart';
import 'package:aquarium_app/screens/substrate_guide_screen.dart';
import 'package:aquarium_app/screens/hardscape_guide_screen.dart';
import 'package:aquarium_app/screens/algae_guide_screen.dart';
import 'package:aquarium_app/screens/emergency_guide_screen.dart';
import 'package:aquarium_app/screens/vacation_guide_screen.dart';
```

**Step 2: Add Advanced Tools Section (15 min)**

```dart
// ADVANCED TOOLS SECTION
SliverToBoxAdapter(
  child: Padding(
    padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
    child: Text(
      '🔧 Advanced Tools',
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    ),
  ),
),

_buildSettingTile(
  context,
  title: 'Tank Comparison',
  subtitle: 'Compare multiple tanks',
  icon: Icons.compare_arrows,
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const TankComparisonScreen(),
    ),
  ),
),

_buildSettingTile(
  context,
  title: 'Livestock Value Tracker',
  subtitle: 'Track collection value',
  icon: Icons.attach_money,
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const LivestockValueScreen(),
    ),
  ),
),

// Developer Tools (optional)
_buildSettingTile(
  context,
  title: 'XP Animations Demo',
  subtitle: 'Preview animations',
  icon: Icons.animation,
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const XpAnimationsDemoScreen(),
    ),
  ),
),
```

**Additional Imports:**
```dart
import 'package:aquarium_app/screens/tank_comparison_screen.dart';
import 'package:aquarium_app/screens/livestock_value_screen.dart';
import 'package:aquarium_app/screens/xp_animations_demo_screen.dart';
```

**Time Estimate:** 1 hour total

---

### 2.3 Tank Detail Screen Enhancement 🐠

**Current Links (13 screens):**
- Tasks, Logs, Livestock, Equipment
- Maintenance Checklist, Photo Gallery, Journal
- Charts, Tank Settings, Livestock Value

**Missing Links:**
- Tank Comparison (compare with other tanks)
- Charts Screen (full version)

**Changes Required:**

**File:** `lib/screens/tank_detail_screen.dart`

**Add to action menu or bottom sheet:**

```dart
// In _buildActionMenu() or options menu
ListTile(
  leading: const Icon(Icons.bar_chart),
  title: const Text('View Charts'),
  subtitle: const Text('Parameter trends'),
  onTap: () {
    Navigator.pop(context); // Close menu
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChartsScreen(tankId: widget.tankId),
      ),
    );
  },
),

ListTile(
  leading: const Icon(Icons.compare_arrows),
  title: const Text('Compare Tanks'),
  subtitle: const Text('Compare with other tanks'),
  onTap: () {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TankComparisonScreen(
          selectedTankId: widget.tankId,
        ),
      ),
    );
  },
),
```

**Time Estimate:** 10 minutes

---

### 2.4 Orphaned Screen Decisions 🗑️

#### Option 1: Archive (Recommended for Duplicates)

**Screens to Archive:**
- `enhanced_quiz_screen.dart` (if keeping practice_screen)
- `enhanced_placement_test_screen.dart` (if not using)
- `enhanced_onboarding_screen.dart` (duplicate)

**Action:** Move to `lib/screens/archive/` directory

**Time:** 5 minutes

#### Option 2: Implement Missing Features

**A. Placement Test Integration (40 min)**

If you want placement tests during onboarding:

**File:** `lib/screens/onboarding/experience_assessment_screen.dart`

**Add button after quiz:**
```dart
ElevatedButton.icon(
  icon: const Icon(Icons.school),
  label: const Text('Take Placement Test'),
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EnhancedPlacementTestScreen(),
      ),
    );
  },
),
```

**B. Gem Shop Integration (30 min)**

If implementing gem shop:

**File:** `lib/screens/shop_street_screen.dart`

**Add to shop list:**
```dart
_ShopCard(
  icon: Icons.diamond,
  title: 'Gem Shop',
  subtitle: 'Purchase premium currency',
  color: Colors.purple,
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const GemShopScreen(),
    ),
  ),
),
```

**C. Difficulty Settings (20 min)**

**File:** `lib/screens/settings_screen.dart`

**Add to App Settings section:**
```dart
_buildSettingTile(
  context,
  title: 'Difficulty Settings',
  subtitle: 'Adjust learning difficulty',
  icon: Icons.trending_up,
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const DifficultySettingsScreen(),
    ),
  ),
),
```

---

## 3. Navigation Architecture Improvements

### 3.1 Current Navigation Structure

```
Main Entry (main.dart)
    ↓
HouseNavigator (6 rooms, swipe)
    ├─ Room 0: Learn 📚
    ├─ Room 1: Home 🛋️ [DEFAULT]
    │    ├─ Settings ⚙️
    │    ├─ Tank Detail 🐠
    │    └─ Search 🔍
    ├─ Room 2: Friends 👥
    ├─ Room 3: Leaderboard 🏆
    ├─ Room 4: Workshop 🔧
    └─ Room 5: Shop 🏪
```

### 3.2 Proposed Improvements

#### Improvement 1: Add "Guides" to Main Navigation

**Option A: Add 7th Room to HouseNavigator**

```
Room 6: Library 📖 (New)
    ├─ All Guides (categorized)
    ├─ Quick Reference
    └─ Search Guides
```

**Implementation:**
- Add GuideLibraryScreen
- Update HouseNavigator to 7 rooms
- Use book/library icon

**Pros:** Direct access, consistent with room metaphor  
**Cons:** More swipe distance  
**Time:** 2 hours

**Option B: Add to Home Bottom Nav**

Replace "Shop" tab with "More" tab:
```
Bottom Nav:
├─ Home 🏠
├─ Learn 📖
├─ Tools 🔧
└─ More ⋮ → Guides, Shop, Settings
```

**Pros:** Better organization  
**Cons:** Adds navigation depth  
**Time:** 1 hour

**Recommendation:** Option B (better UX)

#### Improvement 2: Add Quick Access FAB to Home

**Add to Home Screen:**
```dart
// Floating action button with Speed Dial
SpeedDial(
  children: [
    SpeedDialChild(
      label: 'Quick Guide',
      icon: Icons.help,
      onTap: () => _showQuickGuideSheet(context),
    ),
    SpeedDialChild(
      label: 'Calculator',
      icon: Icons.calculate,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const WorkshopScreen(),
        ),
      ),
    ),
    // ... existing FAB options
  ],
)
```

**Time:** 30 minutes

#### Improvement 3: Contextual Guide Links

Add "Learn More" buttons throughout the app:

**Example - Add Log Screen:**
```dart
// In parameter selection
Row(
  children: [
    Text('pH'),
    IconButton(
      icon: Icon(Icons.info_outline, size: 18),
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ParameterGuideScreen(
            initialParameter: 'pH',
          ),
        ),
      ),
    ),
  ],
),
```

**Locations to Add:**
- Add Log Screen (parameter info buttons)
- Create Tank Screen (tank type guides)
- Livestock Screen (care guides)
- Equipment Screen (equipment guides)

**Time:** 1 hour (4-6 locations)

---

## 4. Priority Ranking (Impact × Effort Matrix)

### 4.1 Priority Matrix

```
HIGH IMPACT, LOW EFFORT (DO FIRST) 🟢
├─ Water Change Calculator → Workshop (5 min, CRITICAL)
├─ Stocking Calculator → Workshop (5 min, HIGH value)
├─ Parameter Guide → Settings (5 min, CRITICAL)
├─ Nitrogen Cycle Guide → Settings (5 min, CRITICAL)
├─ CO₂ Calculator → Workshop (5 min, HIGH value)
├─ Disease Guide → Settings (5 min, HIGH value)
├─ Unit Converter → Workshop (5 min, MED value)
└─ Quick Start Guide → Settings (5 min, CRITICAL)
  Total: 40 min for 8 critical features

HIGH IMPACT, MEDIUM EFFORT (DO SECOND) 🟡
├─ All remaining guides → Settings (45 min)
├─ All calculators → Workshop (30 min)
├─ Charts screen → Tank Detail (10 min)
├─ Contextual guide links (1 hour)
└─ Tank comparison → Tank Detail (10 min)
  Total: 2.5 hours for 20+ features

MEDIUM IMPACT, LOW EFFORT (QUICK WINS) 🔵
├─ Backup/Restore → Settings (5 min)
├─ Notification Settings → Settings (5 min)
├─ Theme Gallery → Settings (5 min)
├─ Livestock Value → Settings (10 min)
└─ Demo screens → Settings/Developer (10 min)
  Total: 35 min for 5 features

LOW PRIORITY / DECISIONS REQUIRED ⚪
├─ Placement test screens (40 min if implementing)
├─ Gem shop screen (30 min if implementing)
├─ Difficulty settings (20 min)
├─ Enhanced quiz (30 min to choose/archive)
├─ Equipment manager (6-8 hours to implement)
└─ Add 7th room to HouseNavigator (2 hours)
  Total: 4-10 hours (optional features)
```

### 4.2 Recommended Implementation Phases

#### **Phase 1: Critical Quick Wins (1 hour)** 🎯
**Goal:** Unlock 30% more features with minimal effort

1. Add 3 missing calculators to Workshop (15 min)
   - Water Change Calculator ⭐
   - Stocking Calculator ⭐
   - CO₂ Calculator

2. Add critical guides to Settings (30 min)
   - Parameter Guide ⭐
   - Nitrogen Cycle Guide ⭐
   - Disease Guide ⭐
   - Quick Start Guide ⭐

3. Add Unit Converter to Workshop (5 min)

4. Test all navigation paths (10 min)

**Deliverable:** 8 major features accessible  
**Testing:** Verify each button navigates correctly

---

#### **Phase 2: Full Integration (2 hours)** 📦
**Goal:** Link all remaining screens

1. Complete Workshop grid (30 min)
   - All calculators
   - Lighting schedule
   - Cost tracker
   - Compatibility checker

2. Complete Settings guides section (45 min)
   - All 16 guide screens
   - Organized by category
   - Expansion tiles

3. Add advanced tools to Settings (15 min)
   - Tank comparison
   - Livestock value
   - Demo screens

4. Tank Detail enhancements (10 min)
   - Charts link
   - Tank comparison link

5. Full navigation testing (20 min)

**Deliverable:** 100% feature accessibility  
**Testing:** Test every link, verify correct screen loads

---

#### **Phase 3: Navigation Polish (2 hours)** ✨
**Goal:** Improve discoverability and UX

1. Add contextual guide links (1 hour)
   - Add Log Screen (parameter info)
   - Create Tank Screen (setup guides)
   - Livestock Screen (care guides)
   - Equipment Screen (equipment guides)

2. Improve Home screen quick access (30 min)
   - Enhanced FAB menu
   - Quick guide sheet
   - Calculator shortcuts

3. Add search/filter to guides (30 min)
   - Guide library screen (optional)
   - Search functionality
   - Category filters

**Deliverable:** Seamless navigation experience  
**Testing:** User flow testing (onboarding → feature discovery)

---

#### **Phase 4: Cleanup & Optimization (2 hours)** 🧹
**Goal:** Archive orphaned screens, reduce bloat

1. Archive duplicate screens (15 min)
   - enhanced_quiz_screen
   - enhanced_onboarding_screen
   - Move to lib/screens/archive/

2. Decision on incomplete features (1 hour)
   - Placement test: implement OR delete
   - Gem shop: implement OR delete
   - Difficulty settings: implement OR delete

3. Update README/documentation (30 min)
   - Navigation map
   - Feature accessibility matrix
   - Update AUDIT files

4. Final build testing (15 min)
   - Test release build
   - Verify size reduction
   - Performance check

**Deliverable:** Clean, maintainable codebase  
**Testing:** Full regression testing

---

## 5. Time Estimates Summary

### By Phase
| Phase | Focus | Time | Screens Unlocked |
|-------|-------|------|------------------|
| **Phase 1** | Critical quick wins | 1 hour | 8 screens (30%) |
| **Phase 2** | Full integration | 2 hours | 35 screens (100%) |
| **Phase 3** | Navigation polish | 2 hours | UX improvements |
| **Phase 4** | Cleanup | 2 hours | Code quality |
| **TOTAL** | Complete roadmap | **7 hours** | **43+ screens** |

### By Feature Category
| Category | Screens | Time | Priority |
|----------|---------|------|----------|
| Calculators | 13 | 1.5 hours | HIGH |
| Guides | 16 | 1.5 hours | HIGH |
| Settings | 6 | 35 min | MEDIUM |
| Advanced Tools | 3 | 25 min | MEDIUM |
| Navigation UX | - | 2 hours | MEDIUM |
| Cleanup | 7 | 2 hours | LOW |

---

## 6. Specific UI Changes Needed

### 6.1 Workshop Screen (`workshop_screen.dart`)

**Current Grid:** 6 items (1 modal, 1 placeholder, 4 dead links)

**Changes:**
1. **Replace line ~180:** Modal calculator → Full screen navigation
2. **Add 9 new _ToolCard widgets** after existing items
3. **Update grid crossAxisCount:** From 2 to 3 (or keep 2 for larger cards)
4. **Add 9 imports** at top of file
5. **Optional:** Remove or update Equipment placeholder

**UI Layout:**
```dart
GridView.count(
  crossAxisCount: 2, // or 3 for more compact
  mainAxisSpacing: 12,
  crossAxisSpacing: 12,
  childAspectRatio: 1.1,
  children: [
    // 12 tool cards total
  ],
),
```

**Testing:**
- Tap each card
- Verify correct screen loads
- Check back navigation works

---

### 6.2 Settings Screen (`settings_screen.dart`)

**Current Structure:** Flat list with some categories

**Changes:**
1. **Add new section** after "App Settings"
2. **Insert 5 ExpansionTile widgets** (Getting Started, Water Chemistry, Fish Care, Tank Setup, Maintenance)
3. **Add 16 _buildSettingTile calls** inside expansion tiles
4. **Add Advanced Tools section** with 3 tiles
5. **Add 19 imports** at top of file
6. **Add _buildExpansionTile helper method**

**UI Layout:**
```dart
CustomScrollView(
  slivers: [
    // App Bar
    SliverAppBar(...),
    
    // App Settings section
    _buildSection('⚙️ App Settings'),
    // ... existing settings tiles
    
    // NEW: Guides & Education section
    _buildSection('📚 Guides & Education'),
    _buildExpansionTile('Getting Started', ...),
    _buildExpansionTile('Water Chemistry', ...),
    _buildExpansionTile('Fish Care', ...),
    _buildExpansionTile('Tank Setup', ...),
    _buildExpansionTile('Maintenance', ...),
    
    // NEW: Advanced Tools section
    _buildSection('🔧 Advanced Tools'),
    // ... tool tiles
    
    // Information section (existing)
    _buildSection('ℹ️ Information'),
    // ... existing info tiles
  ],
),
```

**Testing:**
- Expand each category
- Tap each guide link
- Verify correct screen loads
- Check visual hierarchy (icons, spacing)

---

### 6.3 Tank Detail Screen (`tank_detail_screen.dart`)

**Current:** Tabs + action menu

**Changes:**
1. **Add to action menu/options** (in _buildActionMenu or similar)
2. **Insert 2 new ListTile widgets**
3. **Add 2 imports** at top of file

**UI Location:** Overflow menu (⋮) or action buttons

**Testing:**
- Open tank detail
- Tap overflow menu
- Tap "View Charts" → ChartsScreen opens
- Tap "Compare Tanks" → TankComparisonScreen opens

---

### 6.4 Home Screen (Optional - Phase 3)

**Changes:**
1. **Enhance SpeedDial FAB** with quick guide access
2. **Add calculator shortcut**

**UI Addition:**
```dart
SpeedDialChild(
  label: 'Quick Guide',
  icon: Icons.help,
  onTap: () => _showQuickGuideSheet(context),
),
```

**Quick Guide Sheet:**
```dart
void _showQuickGuideSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (context) => Column(
      children: [
        ListTile(
          leading: Icon(Icons.science),
          title: Text('Parameter Guide'),
          onTap: () { /* navigate */ },
        ),
        // ... more quick links
      ],
    ),
  );
}
```

---

## 7. Testing & Validation Plan

### 7.1 Navigation Testing Checklist

**Workshop Screen:**
- [ ] Tank Volume → Opens full TankVolumeCalculatorScreen
- [ ] Water Change → Opens WaterChangeCalculatorScreen
- [ ] Stocking → Opens StockingCalculatorScreen
- [ ] CO₂ → Opens Co2CalculatorScreen
- [ ] Dosing → Opens DosingCalculatorScreen
- [ ] Unit Converter → Opens UnitConverterScreen
- [ ] Charts → Opens ChartsScreen
- [ ] Compatibility → Opens CompatibilityCheckerScreen
- [ ] Lighting → Opens LightingScheduleScreen
- [ ] Cost Tracker → Opens CostTrackerScreen
- [ ] Back navigation works from all screens

**Settings Screen:**
- [ ] Each guide category expands
- [ ] All 16 guide links work
- [ ] Advanced tools section loads
- [ ] Tank Comparison → Opens correctly
- [ ] Livestock Value → Opens correctly
- [ ] Back navigation works from all guides

**Tank Detail Screen:**
- [ ] "View Charts" → Opens ChartsScreen with tank data
- [ ] "Compare Tanks" → Opens TankComparisonScreen
- [ ] Back navigation returns to tank detail

**Contextual Links (Phase 3):**
- [ ] Add Log → Parameter info buttons work
- [ ] Create Tank → Setup guide links work
- [ ] Livestock → Care guide links work

### 7.2 Build Testing

**Before Changes:**
- [ ] Record current APK size
- [ ] Document current navigation paths

**After Phase 1:**
- [ ] Verify 8 critical features accessible
- [ ] Test on device (not just emulator)
- [ ] Check for navigation errors in logs

**After Phase 2:**
- [ ] Full navigation map test (all 43+ screens)
- [ ] Build release APK
- [ ] Compare size to baseline

**After Phase 3:**
- [ ] User flow testing (new user → feature discovery)
- [ ] Performance testing (navigation speed)
- [ ] Memory usage check

**After Phase 4:**
- [ ] Verify dead code removed
- [ ] Final size comparison
- [ ] Regression testing (all core features still work)

### 7.3 Acceptance Criteria

**Phase 1 Complete:**
- ✅ 8 critical features accessible in <3 taps
- ✅ No navigation errors
- ✅ All buttons lead to working screens

**Phase 2 Complete:**
- ✅ 100% of implemented screens accessible
- ✅ No dead navigation links
- ✅ All guides categorized logically

**Phase 3 Complete:**
- ✅ Contextual help available in key screens
- ✅ Quick access to common tools (<2 taps)
- ✅ User can discover features without documentation

**Phase 4 Complete:**
- ✅ Zero orphaned screens (all archived or linked)
- ✅ Build size reduced by >10MB
- ✅ Clean codebase (no unused imports)

---

## 8. Risk Mitigation

### 8.1 Potential Issues

**Issue 1: Import Errors**
- **Risk:** Screen files may have changed names or locations
- **Mitigation:** Test imports incrementally, fix as needed
- **Time Buffer:** +30 min

**Issue 2: Screen State Errors**
- **Risk:** Some screens may require specific constructor params
- **Mitigation:** Check each screen's constructor before linking
- **Time Buffer:** +1 hour

**Issue 3: Navigation Conflicts**
- **Risk:** Some screens may already be linked elsewhere
- **Mitigation:** Search codebase for existing imports before adding
- **Time Buffer:** +15 min

**Issue 4: UI Overflow**
- **Risk:** Too many items in Settings may cause scroll issues
- **Mitigation:** Use ExpansionTiles to collapse categories
- **Solution Included:** Already in design

### 8.2 Rollback Plan

**If Phase 1 Fails:**
- Revert workshop_screen.dart to previous version
- Remove added imports
- Keep existing navigation

**If Phase 2 Fails:**
- Keep Phase 1 changes (critical features)
- Rollback Settings expansion
- Defer guides to Phase 3

**If Phase 3 Fails:**
- Keep Phases 1-2 (all features accessible)
- Skip contextual links
- Use current navigation only

**Version Control:**
- Commit after each phase
- Tag each successful phase
- Easy rollback to last working state

---

## 9. Success Metrics

### 9.1 Quantitative Metrics

**Before Roadmap:**
- Accessible screens: 83/90 (92%)
- Dead code: 35 screens (41% waste)
- Calculators accessible: 0/7 (0%)
- Guides accessible: 0/16 (0%)

**After Phase 1 (1 hour):**
- Accessible screens: 91/90 (101%) ← 8 new links
- Dead code: 27 screens (30% waste)
- Calculators accessible: 4/7 (57%)
- Guides accessible: 4/16 (25%)

**After Phase 2 (3 hours total):**
- Accessible screens: 100% ← All screens linked or archived
- Dead code: 7 screens (8% - decisions pending)
- Calculators accessible: 10/10 (100%)
- Guides accessible: 16/16 (100%)

**After Phase 4 (7 hours total):**
- Accessible screens: 100%
- Dead code: 0% ← All archived or deleted
- Build size reduction: >10MB
- Navigation depth: <3 taps for all features

### 9.2 Qualitative Metrics

**User Experience:**
- ✅ Can find calculators without searching
- ✅ Can access guides from Settings
- ✅ Contextual help available where needed
- ✅ No broken navigation links
- ✅ Logical feature organization

**Developer Experience:**
- ✅ Clear navigation structure
- ✅ No unused code
- ✅ Easy to add new features
- ✅ Documented navigation paths

---

## 10. Post-Implementation Documentation

### 10.1 Files to Update

**1. Navigation Map** (`docs/NAVIGATION_MAP.md`) - CREATE NEW
```markdown
# App Navigation Map

## Primary Navigation (HouseNavigator)
- Room 0: Learn
- Room 1: Home
- ...

## Workshop Screen Links
- Tank Volume → TankVolumeCalculatorScreen
- Water Change → WaterChangeCalculatorScreen
- ...

## Settings Screen Links
### Guides
- Getting Started
  - Quick Start Guide
  - Glossary
- Water Chemistry
  - Parameter Guide
  - ...
```

**2. Screen Inventory** (`docs/SCREEN_INVENTORY.md`) - UPDATE
- Update accessibility status for all screens
- Mark archived screens
- Document navigation paths

**3. Audit Files** - UPDATE
- Update AUDIT_03_SCREENS_UI.md (reduce orphaned count)
- Update AUDIT_08_TOOLS_CALCULATORS.md (increase accessible count)
- Update AUDIT_10_BUILD_INTEGRATION.md (reduce dead code %)

**4. README.md** - UPDATE
- Update feature list (note all accessible features)
- Add navigation section
- Link to navigation map

### 10.2 Code Documentation

**Add to workshop_screen.dart:**
```dart
/// Workshop Screen - Tools & Calculators Hub
/// 
/// Accessible Tools:
/// - Tank Volume Calculator (5 shapes, full features)
/// - Water Change Calculator (nitrate-based calculation)
/// - Stocking Calculator (bioload with species database)
/// - CO₂ Calculator (pH/KH formula with charts)
/// - Dosing Calculator (fertilizer/treatment dosing)
/// - Unit Converter (4 categories: volume, temp, length, hardness)
/// - Charts (parameter trends and graphs)
/// - Compatibility Checker (multi-species analysis)
/// - Lighting Schedule (timer control)
/// - Cost Tracker (expense management)
/// 
/// Navigation: Home → Tools tab OR HouseNavigator → Room 4
```

**Add to settings_screen.dart:**
```dart
/// Settings Screen - Configuration & Resources Hub
/// 
/// Sections:
/// - App Settings (theme, notifications, backup, etc.)
/// - Guides & Education (16 comprehensive guides, categorized)
/// - Advanced Tools (tank comparison, value tracking, demos)
/// - Information (FAQ, about, privacy, terms)
/// 
/// Guides Categorized By:
/// - Getting Started (2 guides)
/// - Water Chemistry (3 guides)
/// - Fish Care (5 guides)
/// - Tank Setup (3 guides)
/// - Maintenance (3 guides)
```

---

## 11. Future Enhancements (Beyond This Roadmap)

### 11.1 Search Functionality
**Goal:** Global search for guides and tools

**Implementation:**
- Add search bar to Settings screen
- Filter guides by keyword
- Show calculator descriptions in results

**Time:** 3-4 hours  
**Priority:** Low (nice-to-have)

### 11.2 Favorites System
**Goal:** Let users bookmark frequently-used features

**Implementation:**
- Add "favorite" button to each screen
- "Favorites" section in Home or Settings
- Quick access to bookmarked guides/calculators

**Time:** 4-5 hours  
**Priority:** Medium

### 11.3 Recent/History
**Goal:** Show recently accessed guides/tools

**Implementation:**
- Track navigation history
- "Recently Used" section in Home
- Last 5-10 accessed features

**Time:** 2-3 hours  
**Priority:** Low

### 11.4 Onboarding Tour
**Goal:** Show new users where features are

**Implementation:**
- Tutorial highlighting Workshop
- Callouts for Settings guides
- First-time user tooltips

**Time:** 3-4 hours  
**Priority:** Medium (post-launch)

### 11.5 Deep Links
**Goal:** Direct links to specific screens

**Implementation:**
- Implement go_router (already in dependencies)
- Define routes for all screens
- Enable sharing/bookmarking specific guides

**Time:** 6-8 hours  
**Priority:** Medium (future update)

---

## 12. Appendices

### Appendix A: Complete Screen Manifest

**Calculators & Tools (13):**
1. tank_volume_calculator_screen.dart ✅
2. water_change_calculator_screen.dart ✅
3. stocking_calculator_screen.dart ✅
4. co2_calculator_screen.dart ✅
5. dosing_calculator_screen.dart ✅
6. unit_converter_screen.dart ✅
7. charts_screen.dart ✅
8. compatibility_checker_screen.dart ✅
9. lighting_schedule_screen.dart ✅
10. cost_tracker_screen.dart ✅
11. livestock_value_screen.dart ✅
12. tank_comparison_screen.dart ✅
13. tank_settings_screen.dart ✅

**Guides (16):**
1. quick_start_guide_screen.dart ✅
2. glossary_screen.dart ✅
3. parameter_guide_screen.dart ✅
4. nitrogen_cycle_guide_screen.dart ✅
5. troubleshooting_screen.dart ✅
6. disease_guide_screen.dart ✅
7. feeding_guide_screen.dart ✅
8. acclimation_guide_screen.dart ✅
9. quarantine_guide_screen.dart ✅
10. breeding_guide_screen.dart ✅
11. equipment_guide_screen.dart ✅
12. substrate_guide_screen.dart ✅
13. hardscape_guide_screen.dart ✅
14. algae_guide_screen.dart ✅
15. emergency_guide_screen.dart ✅
16. vacation_guide_screen.dart ✅

**Settings (6):**
1. backup_restore_screen.dart ✅
2. difficulty_settings_screen.dart ⚠️
3. notification_settings_screen.dart ✅
4. theme_gallery_screen.dart ✅
5. offline_mode_demo_screen.dart ✅
6. xp_animations_demo_screen.dart ✅

**Orphaned/Decisions (7):**
1. enhanced_quiz_screen.dart 🗑️
2. placement_test_screen.dart 🗑️
3. placement_result_screen.dart 🗑️
4. enhanced_placement_test_screen.dart 🗑️
5. enhanced_onboarding_screen.dart 🗑️
6. gem_shop_screen.dart ⚠️
7. difficulty_settings_screen.dart ⚠️

**TOTAL: 42 screens to link/decide**

---

### Appendix B: File Paths Quick Reference

**Screens Directory:**
```
/mnt/c/Users/larki/Documents/Aquarium App Dev/repo/apps/aquarium_app/lib/screens/
```

**Key Files to Edit:**
```
lib/screens/workshop_screen.dart          ← Phase 1 & 2
lib/screens/settings_screen.dart          ← Phase 2
lib/screens/tank_detail_screen.dart       ← Phase 2
lib/screens/home_screen.dart              ← Phase 3 (optional)
```

**Test Build:**
```bash
cd "/mnt/c/Users/larki/Documents/Aquarium App Dev/repo/apps/aquarium_app"
/home/tiarnanlarkin/flutter/bin/flutter build apk --debug
```

---

### Appendix C: Import Template

**Copy-paste for workshop_screen.dart:**
```dart
// Calculators & Tools
import 'package:aquarium_app/screens/tank_volume_calculator_screen.dart';
import 'package:aquarium_app/screens/water_change_calculator_screen.dart';
import 'package:aquarium_app/screens/stocking_calculator_screen.dart';
import 'package:aquarium_app/screens/co2_calculator_screen.dart';
import 'package:aquarium_app/screens/dosing_calculator_screen.dart';
import 'package:aquarium_app/screens/unit_converter_screen.dart';
import 'package:aquarium_app/screens/charts_screen.dart';
import 'package:aquarium_app/screens/compatibility_checker_screen.dart';
import 'package:aquarium_app/screens/lighting_schedule_screen.dart';
import 'package:aquarium_app/screens/cost_tracker_screen.dart';
```

**Copy-paste for settings_screen.dart (Guides):**
```dart
// Educational Guides
import 'package:aquarium_app/screens/quick_start_guide_screen.dart';
import 'package:aquarium_app/screens/glossary_screen.dart';
import 'package:aquarium_app/screens/parameter_guide_screen.dart';
import 'package:aquarium_app/screens/nitrogen_cycle_guide_screen.dart';
import 'package:aquarium_app/screens/troubleshooting_screen.dart';
import 'package:aquarium_app/screens/disease_guide_screen.dart';
import 'package:aquarium_app/screens/feeding_guide_screen.dart';
import 'package:aquarium_app/screens/acclimation_guide_screen.dart';
import 'package:aquarium_app/screens/quarantine_guide_screen.dart';
import 'package:aquarium_app/screens/breeding_guide_screen.dart';
import 'package:aquarium_app/screens/equipment_guide_screen.dart';
import 'package:aquarium_app/screens/substrate_guide_screen.dart';
import 'package:aquarium_app/screens/hardscape_guide_screen.dart';
import 'package:aquarium_app/screens/algae_guide_screen.dart';
import 'package:aquarium_app/screens/emergency_guide_screen.dart';
import 'package:aquarium_app/screens/vacation_guide_screen.dart';

// Advanced Tools
import 'package:aquarium_app/screens/tank_comparison_screen.dart';
import 'package:aquarium_app/screens/livestock_value_screen.dart';
import 'package:aquarium_app/screens/xp_animations_demo_screen.dart';
```

---

## Summary & Next Steps

### What This Roadmap Delivers

✅ **Complete inventory** of 42 unreachable screens  
✅ **Specific navigation paths** for each feature  
✅ **Exact UI changes** needed (code snippets included)  
✅ **4-phase implementation plan** with time estimates  
✅ **Priority ranking** (impact × effort matrix)  
✅ **Testing & validation** checklist  
✅ **Documentation updates** required  

### Quick Win Opportunity

**1 hour of work unlocks 30% more features:**
- 3 critical calculators
- 4 essential guides
- Zero code changes to screens themselves
- Just navigation links

### Total Time Investment

- **Phase 1 (Critical):** 1 hour → 8 features
- **Phase 2 (Complete):** 2 hours → 35 features
- **Phase 3 (Polish):** 2 hours → UX improvements
- **Phase 4 (Cleanup):** 2 hours → Code quality
- **TOTAL:** 7 hours → 100% accessibility

### Recommendation

**Start with Phase 1 today:**
1. Add 3 calculators to Workshop (15 min)
2. Add 4 critical guides to Settings (30 min)
3. Test navigation (10 min)
4. Commit changes (5 min)

**Impact:** Instantly make app 30% more valuable with minimal effort.

---

**End of Roadmap**  
**Status:** Ready for Implementation  
**Next Action:** Begin Phase 1 (1 hour)
