# Room Navigation V2 - Side-Scrolling House

## The Problem
Currently, the app flow is:
- **Living Room** (Home) → Settings → Find other rooms
- Rooms are buried 2 taps deep
- Doesn't feel like exploring a house

## The Solution: Swipeable Rooms

Make the entire app a horizontal house you swipe through:

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│   ← Study │ LIVING ROOM │ Workshop →                    │
│            (you are here)                               │
│                                                         │
│   Swipe left/right to move between rooms                │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## Room Layout (Left to Right)

```
[Study] ← [Living Room] → [Workshop] → [Shop Street]
   📚          🛋️              🔧            🏪
```

| Position | Room | Contents |
|----------|------|----------|
| 1 (Left) | 📚 Study | Learning paths, guides, glossary, species/plant browsers |
| 2 (Center/Home) | 🛋️ Living Room | Tanks, water params, quick actions |
| 3 | 🔧 Workshop | Calculators, equipment, tasks, reminders |
| 4 (Right) | 🏪 Shop Street | Wishlist, cost tracker, shop directory |

**Future rooms:** Kitchen (feeding), Breeding Room - can add as app grows

## Navigation UX

### Primary: Horizontal Swipe
- **PageView** with snapping
- Smooth transitions between rooms
- Each room is full-screen immersive scene
- Physics: bouncy at edges, momentum scrolling

### Secondary: Room Indicator Bar
Bottom of screen (above gesture area):
```
┌────────────────────────────────────────┐
│                                        │
│   📚    🛋️    🔧    🏪                │
│         ●                              │
│   Study Living Workshop Shop           │
└────────────────────────────────────────┘
```
- Tap any icon to jump to that room
- Current room highlighted
- Subtle, doesn't block content

### Tertiary: Quick Actions
- **Swipe up** on any room → Show room-specific actions
- **Long press** room indicator → Preview room
- **Shake device** → Return to Living Room (home)

## Visual Design

Each room should:
1. Have its own **illustrated scene** (like current Living Room)
2. Use **consistent glassmorphic cards** for UI elements
3. Have **themed colors** that blend but are distinct
4. Show **interactive objects** you can tap

### Room Color Themes
| Room | Primary | Accent | Vibe |
|------|---------|--------|------|
| Study | Deep blue (#2D3A4F) | Gold (#D4A574) | Cozy, wisdom |
| Living Room | Teal (#5B9A8B) | Coral (#E8A87C) | Calm, home |
| Workshop | Brown (#5D4E37) | Steel (#A0AEC0) | Practical |
| Shop Street | Green (#4A7C59) | Yellow (#F0C040) | Fresh, outdoor |

### Transition Animations
- **Parallax layers**: Background moves slower than foreground
- **Room objects**: Slide in/out with slight delay
- **Ambient elements**: Continuous (bubbles, sparkles, etc.)

## Flutter Implementation

### Core Structure
```dart
class HouseNavigator extends ConsumerStatefulWidget {
  // Main app shell - contains PageView of rooms
}

class HousePageView extends StatelessWidget {
  final PageController controller;
  final List<Widget> rooms; // [StudyRoom, LivingRoom, WorkshopRoom, ShopRoom]
}

class RoomIndicatorBar extends StatelessWidget {
  final int currentRoom;
  final Function(int) onRoomTap;
}
```

### Room Base Class
```dart
abstract class RoomScene extends ConsumerWidget {
  String get roomName;
  IconData get roomIcon;
  Color get primaryColor;
  
  Widget buildScene(BuildContext context, WidgetRef ref);
  Widget buildOverlay(BuildContext context, WidgetRef ref); // Cards, buttons
  List<QuickAction> get quickActions;
}
```

### State Management
```dart
final currentRoomProvider = StateProvider<int>((ref) => 1); // Start at Living Room

final roomControllerProvider = Provider<PageController>((ref) {
  return PageController(initialPage: 1); // Living Room is index 1
});
```

## Migration Plan

### Phase 1: Core Navigation
1. Create `HouseNavigator` shell
2. Wrap existing `HomeScreen` as Living Room
3. Add basic swipe between 2-3 rooms
4. Add room indicator bar

### Phase 2: Room Scenes  
1. Implement `StudyRoomScene` (already started!)
2. Implement `WorkshopRoomScene`
3. Implement `ShopStreetScene`
4. Add parallax transitions

### Phase 3: Polish
1. Quick action sheets per room
2. Haptic feedback
3. Sound effects (optional)
4. Onboarding tour of house

## Settings Changes

Settings becomes a **gear icon inside each room** (or slide-up panel):
- Room Themes (visual customization)
- Notifications
- Backup/Restore
- About

No more "Explore the House" in settings - the house IS the app!

---

## Quick Win: Minimal V1

If full implementation is too much, start with:

1. **PageView** with 3 pages: Study, Living Room, Workshop
2. **Dot indicators** at bottom
3. **Existing scenes** (Living Room works, Study in progress)
4. **Simple placeholder** for Workshop (list of tools)

This alone would make the app feel 10x more polished and explorable!

---

*Created: 2026-01-31*
*Status: Design concept - ready for implementation*
