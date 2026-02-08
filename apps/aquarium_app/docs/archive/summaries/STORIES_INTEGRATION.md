# Stories Mode Integration Guide

## Overview
Interactive narrative scenarios (Duolingo-style stories) that teach aquarium concepts through branching storylines with multiple-choice decisions.

## What's Been Implemented

### 1. **Models** (`lib/models/story.dart`)
- `Story` - Complete story with metadata, scenes, and unlock requirements
- `StoryScene` - Individual scene with text, choices, and media
- `StoryChoice` - Choice option with feedback and branching logic
- `StoryProgress` - User's progress through a story (saves between sessions)
- `StoryDifficulty` - Beginner, Intermediate, Advanced

### 2. **Story Content** (`lib/data/stories.dart`)
Currently includes **6 complete stories** across difficulty levels:

**Beginner Stories:**
- **New Tank Setup** (8 min, 75 XP) - Guide through nitrogen cycling
- **Choosing Your First Fish** (6 min, 60 XP) - Compatible species selection
- **Water Change Day** (5 min, 50 XP) - Maintenance routine

**Intermediate Stories:**
- **Algae Outbreak** (7 min, 85 XP) - Troubleshooting and problem-solving
- **Plant Paradise** (8 min, 90 XP) - Setting up planted tanks

**Advanced Stories:**
- **Breeding Project** (10 min, 100 XP) - Breeding setup and care

Each story:
- 5-10 branching scenes
- Multiple choice decisions
- Educational feedback
- Correct/incorrect tracking
- XP rewards based on score

### 3. **Screens**

#### `StoryPlayerScreen` (`lib/screens/story_player_screen.dart`)
Full-screen immersive story player with:
- Animated text transitions
- Choice buttons with slide-up animation
- Progress indicator
- Feedback overlay (green for correct, orange for hints)
- Aquarium-themed background with floating bubbles
- Auto-save progress
- XP calculation and rewards on completion

#### `StoriesScreen` (`lib/screens/stories_screen.dart`)
Story library with:
- Beautiful gradient header
- Filter by difficulty (All, Beginner, Intermediate, Advanced)
- Sort by: Newest, Difficulty, Completion
- Story cards showing:
  - Title, description, thumbnail
  - Difficulty level, estimated time, XP reward
  - Lock/unlock status
  - Completion indicator
  - "Continue" for in-progress stories
- Locked stories show requirements

### 4. **Widgets**

#### `StoriesCard` (`lib/widgets/stories_card.dart`)
Integration widget for LearnScreen showing:
- Total completion progress
- Suggested next story
- Quick access button
- Gradient purple design

### 5. **User Profile Updates**
`UserProfile` now tracks:
- `completedStories: List<String>` - Completed story IDs
- `storyProgress: Map<String, dynamic>` - In-progress stories

### 6. **Tests** (`test/models/story_test.dart`)
Comprehensive tests covering:
- Story navigation logic
- Score calculation
- XP rewards
- Choice tracking
- Story data validation
- Lock/unlock logic

## How to Integrate into LearnScreen

Add the Stories card to `lib/screens/learn_screen.dart`:

```dart
// Import the widget
import '../widgets/stories_card.dart';

// In the build method, after the Practice card:

// === EXISTING CODE ===
// Practice card
SliverToBoxAdapter(
  child: _PracticeCard(profile: profile),
),

// === ADD THIS ===
// Stories card
SliverToBoxAdapter(
  child: StoriesCard(profile: profile),
),

// === EXISTING CODE ===
// Learning paths header
SliverToBoxAdapter(
  child: Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
    child: Text(
      'Learning Paths',
      style: AppTypography.headlineSmall,
    ),
  ),
),
```

That's it! The card will appear in the Learn screen with automatic progress tracking.

## How It Works

### Story Flow
1. User taps "Interactive Stories" card → `StoriesScreen`
2. User selects an unlocked story → `StoryPlayerScreen`
3. Story displays current scene with 2-4 choice options
4. User selects choice → Feedback shown (2 seconds)
5. Navigate to next scene OR complete story
6. On completion: Show score, award XP, mark as completed

### Progress Saving
- Progress auto-saves after each choice
- Users can exit and resume anytime
- Completed stories can be replayed

### XP Rewards
- Base XP defined per story
- Multiplier based on score:
  - 90%+: 1.5x (50% bonus)
  - 70-89%: 1.25x (25% bonus)
  - 50-69%: 1.0x (full XP)
  - <50%: 0.75x (reduced)

### Unlocking Stories
Stories unlock based on:
- **User level** - `minLevel` requirement
- **Prerequisites** - Must complete earlier stories
- Beginner stories unlocked by default

## Adding New Stories

### Step 1: Define the Story
Add to `lib/data/stories.dart`:

```dart
static const Story yourNewStory = Story(
  id: 'your_story_id',
  title: 'Your Story Title',
  description: 'Brief description for the library',
  difficulty: StoryDifficulty.beginner,
  estimatedMinutes: 7,
  xpReward: 70,
  thumbnailImage: '🐠', // Emoji or asset path
  prerequisites: [], // Empty for no prerequisites
  minLevel: 0, // Minimum user level
  scenes: [
    // Define scenes here...
  ],
);
```

### Step 2: Design Scenes
Each scene needs:
- `id` - Unique within the story
- `text` - The narrative text
- `choices` - 2-4 options
- `isFinalScene: true` - Mark ending scenes

```dart
StoryScene(
  id: 'scene_1',
  text: 'Your narrative text here...',
  imageUrl: '🐟', // Optional emoji/image
  choices: [
    StoryChoice(
      id: 'choice_1',
      text: 'First option',
      nextSceneId: 'scene_2',
      isCorrect: true,
      feedback: 'Great choice!',
      xpModifier: 10, // Bonus XP
    ),
    StoryChoice(
      id: 'choice_2',
      text: 'Second option',
      nextSceneId: 'scene_3',
      isCorrect: false,
      feedback: 'Not ideal, but let\'s see what happens...',
    ),
  ],
),
```

### Step 3: Add to AllStories List
```dart
static final List<Story> allStories = [
  // Existing stories...
  yourNewStory, // Add here
];
```

### Step 4: Test Story Navigation
- Verify all `nextSceneId` values reference existing scenes
- Ensure at least one final scene exists
- Test all branching paths

## Design Guidelines

### Writing Good Stories
1. **Start with a hook** - Engaging opening scenario
2. **Educational content** - Teach real concepts
3. **Consequences** - Choices should have realistic outcomes
4. **Branching paths** - Multiple routes through the story
5. **Clear feedback** - Explain why choices are right/wrong
6. **Natural endings** - Satisfying conclusions

### Choice Design
- **2-4 choices per scene** (3 is optimal)
- **At least one correct path** through the story
- **Mix obvious and subtle choices** for challenge
- **Use feedback to teach** - Explain concepts
- **Avoid dead ends** - All paths should progress

### Difficulty Levels
- **Beginner**: Clear right/wrong answers, basic concepts
- **Intermediate**: Nuanced choices, troubleshooting
- **Advanced**: Complex scenarios, multiple valid approaches

## Story Ideas for Future Development

### Beginner
- "Emergency! Fish Acting Strange" - Disease identification
- "Setting Up a Quarantine Tank" - Biosecurity basics
- "Reading Water Test Results" - Parameter interpretation

### Intermediate
- "Tank Upgrade Planning" - Larger tank setup
- "Adding Shrimp to Your Tank" - Invertebrate care
- "Competition Preparation" - Show-quality standards

### Advanced
- "Aquascaping Contest Entry" - Design principles
- "Setting Up a Nano Reef" - Marine aquarium basics
- "Building a Sump System" - Advanced filtration

## Technical Architecture

```
Story System
├── Models (story.dart)
│   ├── Story - Container
│   ├── StoryScene - Content nodes
│   ├── StoryChoice - Branch points
│   └── StoryProgress - Save state
│
├── Data (stories.dart)
│   └── Stories - Content library
│
├── Screens
│   ├── StoriesScreen - Library/selection
│   └── StoryPlayerScreen - Playback engine
│
├── Widgets
│   └── StoriesCard - Learn screen integration
│
└── User Profile
    ├── completedStories - Completion tracking
    └── storyProgress - Save game state
```

## Performance Considerations

- **Story content is static** - Defined at compile time
- **Progress saves on each choice** - Ensures no data loss
- **Lazy loading** - Stories load only when needed
- **Efficient JSON serialization** - Fast save/load

## Accessibility

- Semantic labels for screen readers
- High contrast text
- Large touch targets (44x44 minimum)
- Clear visual feedback
- Progress indicators

## Future Enhancements

Potential additions:
1. **Audio narration** - Voice acting for scenes
2. **Background images** - Visual scene setting
3. **Sound effects** - Immersive audio (water, bubbles)
4. **Achievements** - "Complete all beginner stories"
5. **Leaderboard integration** - Speed run competitions
6. **Story editor** - User-generated content
7. **Multiplayer stories** - Cooperative decision-making
8. **Daily story challenge** - Bonus XP for featured stories
9. **Story unlockables** - Cosmetic rewards for completion

## Troubleshooting

### Story won't unlock
- Check `minLevel` requirement
- Verify prerequisites are completed
- Check UserProfile.currentLevel

### Choices not working
- Verify `nextSceneId` matches actual scene ID
- Check scene isn't marked as `isFinalScene`
- Ensure story has proper branching

### Progress not saving
- Check UserProfileProvider is available
- Verify JSON serialization in toJson/fromJson
- Check async/await in _saveProgress()

## Support

For questions or issues with Stories Mode:
1. Check test files for usage examples
2. Review existing story implementations
3. Validate story data with tests

---

**Status**: ✅ Complete and ready for integration
**Stories**: 6 complete interactive scenarios
**Estimated total play time**: ~44 minutes of content
**Total XP available**: 460 XP from stories
