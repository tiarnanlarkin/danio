# House Navigation Design

## Concept
Transform the app from "settings + everything" into a **virtual house** where each room has a purpose. Users feel at home, and features are naturally organized.

The current Living Room home screen is perfect - we extend that cozy illustrated style to other "rooms."

---

## The Rooms

### 🛋️ Living Room (Home)
**Current home screen - keep it!**
- Tank display with the beautiful illustrated room
- Tank switcher for multiple tanks
- Quick actions (tap tank, test kit, food)
- Status at a glance

### 📚 Study
**Learning & Knowledge**
- Learning paths (Duolingo-style lessons)
- XP progress & achievements
- Guide library:
  - Nitrogen cycle
  - Water parameters
  - Disease guide
  - Acclimation
  - Quarantine
- Glossary
- FAQ
- Species browser
- Plant browser

**Visual style:** Cozy study with bookshelves, desk lamp, open books, reading chair

### 🍳 Kitchen
**Feeding & Nutrition**
- Feeding schedules (per tank)
- Feeding log
- Food inventory
- Nutrition guide
- Feeding guide
- Auto-feeder settings

**Visual style:** Warm kitchen with fish food containers, feeding schedule on fridge, etc.

### 🥚 Breeding Room
**Reproduction & Genetics**
- Breeding guides
- Fry tracking
- Breeding pairs log
- Genetics info
- Species-specific breeding tips

**Visual style:** Separate tanks, breeding nets, fry containers, heating elements

### 🔧 Workshop
**Tools & Maintenance**
- All calculators:
  - Tank volume
  - Water change
  - Stocking
  - Dosing
  - CO2
  - Unit converter
- Equipment manager
- Task system
- Reminders
- Maintenance checklists
- Backup/restore

**Visual style:** Workbench with tools, test kits, equipment parts, toolbox

### 🏪 Shop Street (Outside)
**Shopping & Expenses**
- Wishlist
- Cost tracker
- Shop directory
- Price comparisons
- Purchase history

**Visual style:** Cute street view with fish store, plant shop, etc.

---

## Navigation Options

### Option A: Bottom Navigation Bar
```
┌─────────────────────────────────────┐
│                                     │
│          [Current Screen]           │
│                                     │
├─────────────────────────────────────┤
│ 🛋️   📚   🍳   🥚   🔧   🏪        │
│Living Study Kitchen Breed Workshop Shop│
└─────────────────────────────────────┘
```
**Pros:** Always visible, quick access, familiar pattern
**Cons:** 6 items might be crowded; takes screen space

### Option B: House Map (Recommended)
A visual map you can swipe to, showing the house layout:

```
       ┌───────────────────────────────┐
       │    🏪 Shop Street (outside)   │
       └───────────────────────────────┘
┌──────────┬──────────┬──────────┐
│   📚     │    🛋️    │    🍳    │
│  Study   │  Living  │  Kitchen │
│          │   Room   │          │
├──────────┼──────────┼──────────┤
│   🥚     │          │    🔧    │
│ Breeding │  [Garden │ Workshop │
│   Room   │   area]  │          │
└──────────┴──────────┴──────────┘
```

**Interaction:**
- Swipe left from Living Room → House map appears
- Tap any room → Enter that room
- Each room has back arrow → Living Room
- Or: FAB with house icon → Opens map

### Option C: Hybrid
- Bottom nav with 4 main rooms (Living, Study, Workshop, Shop)
- Kitchen + Breeding accessed from overflow menu or Living Room items

---

## Visual Consistency

### Color Palette Per Room
| Room | Primary | Accent | Feeling |
|------|---------|--------|---------|
| Living Room | Teal/Seafoam | Coral | Calm, home |
| Study | Deep blue | Gold | Wisdom |
| Kitchen | Warm orange | Cream | Cozy, warm |
| Breeding | Soft pink | Light purple | Nurturing |
| Workshop | Brown/Wood | Metal gray | Practical |
| Shop Street | Green | Yellow | Fresh, outdoor |

### Consistent Elements
- Same illustrated style across all rooms
- Floating elements (bubbles, leaves, tools) themed to room
- Warm, soft gradients (like current home)
- Tap-able objects in each room (like current test kit, food)

### Room Transition Animation
- Sliding/panning between rooms (like walking through house)
- Door-opening animation when entering a room
- Gentle fade for less jarring experience

---

## Flutter Implementation

### Folder Structure
```
lib/
├── screens/
│   ├── rooms/
│   │   ├── living_room/       # Current home
│   │   ├── study/             # Learning hub
│   │   ├── kitchen/           # Feeding
│   │   ├── breeding_room/     # Breeding
│   │   ├── workshop/          # Tools
│   │   └── shop_street/       # Shopping
│   └── house_map_screen.dart  # Navigation hub
├── widgets/
│   ├── room_scene/            # Base room widget
│   ├── room_background.dart   # Illustrated backgrounds
│   └── room_objects.dart      # Interactive elements
```

### Navigation Code
```dart
// Room enum
enum Room {
  livingRoom,
  study,
  kitchen,
  breedingRoom,
  workshop,
  shopStreet,
}

// Room provider
final currentRoomProvider = StateProvider<Room>((ref) => Room.livingRoom);

// House map with hero animations
class HouseMapScreen extends ConsumerWidget {
  // Grid of room cards with illustrations
  // Tap to navigate with hero animation
}
```

### Room Base Widget
```dart
abstract class RoomScreen extends ConsumerWidget {
  // Common structure:
  // - Illustrated background
  // - Interactive objects
  // - Content overlay
  // - Navigation back to map
}
```

---

## Phase 1 Implementation (MVP)

1. **Keep Living Room as-is** - it's great
2. **Add Study room** - move learning/guides there
3. **Add Workshop** - move tools/calculators there
4. **Simple bottom nav or FAB** for navigation
5. **Later phases:** Kitchen, Breeding, Shop with full illustrations

---

## Questions to Answer
- [ ] Do we want a visible bottom nav or discovery-based map?
- [ ] How much animation investment for room transitions?
- [ ] Should each room have its own illustrated scene or simpler UI?
- [ ] Priority order for implementing rooms?

---

*Created: 2026-01-31*
