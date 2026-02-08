# Stories Mode Implementation Guide

## Overview

This document provides a complete implementation guide for adding a **Duolingo-style Stories mode** to the Aquarium App. Stories Mode teaches aquarium concepts through immersive narrative scenarios with dialogue, choices, and comprehension checks.

**Features:**
- 🎭 Interactive story scenarios with character dialogue
- 🔀 Branching narratives based on player choices
- 🧠 Comprehension questions embedded in the story flow
- 📊 Progress tracking per story
- 🎁 XP rewards for completion
- 📈 Difficulty progression (beginner → advanced)

---

## Architecture

### 1. Data Models

#### Story Model (`lib/models/story.dart`)

```dart
import 'package:flutter/foundation.dart';
import 'user_profile.dart';

/// Difficulty level for stories
enum StoryDifficulty {
  beginner,
  intermediate,
  advanced,
}

extension StoryDifficultyExt on StoryDifficulty {
  String get displayName {
    switch (this) {
      case StoryDifficulty.beginner:
        return 'Beginner';
      case StoryDifficulty.intermediate:
        return 'Intermediate';
      case StoryDifficulty.advanced:
        return 'Advanced';
    }
  }

  String get emoji {
    switch (this) {
      case StoryDifficulty.beginner:
        return '🌱';
      case StoryDifficulty.intermediate:
        return '🐟';
      case StoryDifficulty.advanced:
        return '🦈';
    }
  }

  int get xpReward {
    switch (this) {
      case StoryDifficulty.beginner:
        return 75;
      case StoryDifficulty.intermediate:
        return 100;
      case StoryDifficulty.advanced:
        return 150;
    }
  }
}

/// A complete interactive story with chapters
@immutable
class Story {
  final String id;
  final String title;
  final String description;
  final StoryDifficulty difficulty;
  final String coverImage; // Asset path or emoji
  final List<String> learningObjectives; // What the user will learn
  final List<StoryChapter> chapters;
  final int estimatedMinutes;
  final List<TankType>? relevantTankTypes; // null = all types

  const Story({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.coverImage,
    required this.learningObjectives,
    required this.chapters,
    this.estimatedMinutes = 10,
    this.relevantTankTypes,
  });

  int get xpReward => difficulty.xpReward;
  
  bool isRelevantFor(UserProfile profile) {
    if (relevantTankTypes == null) return true;
    return relevantTankTypes!.contains(profile.primaryTankType);
  }
}

/// A chapter/scene within a story
@immutable
class StoryChapter {
  final String id;
  final String? title; // Optional chapter title
  final List<StoryNode> nodes; // Sequence of dialogue/choices/questions

  const StoryChapter({
    required this.id,
    this.title,
    required this.nodes,
  });
}

/// Base class for story nodes (dialogue, choice, question)
@immutable
abstract class StoryNode {
  final String id;
  final StoryNodeType type;

  const StoryNode({
    required this.id,
    required this.type,
  });
}

enum StoryNodeType {
  dialogue,       // Character speaking
  narration,      // Narrator text
  choice,         // Player makes a decision
  comprehension,  // Quiz question
  image,          // Image with optional caption
}

/// Character dialogue node
@immutable
class DialogueNode extends StoryNode {
  final String character;
  final String text;
  final String? characterImage; // Asset path or emoji
  final String? emotion; // e.g., "worried", "happy", "thinking"

  const DialogueNode({
    required super.id,
    required this.character,
    required this.text,
    this.characterImage,
    this.emotion,
  }) : super(type: StoryNodeType.dialogue);
}

/// Narrator text node
@immutable
class NarrationNode extends StoryNode {
  final String text;
  final String? style; // e.g., "emphasis", "warning", "success"

  const NarrationNode({
    required super.id,
    required this.text,
    this.style,
  }) : super(type: StoryNodeType.narration);
}

/// Player choice node (branching narrative)
@immutable
class ChoiceNode extends StoryNode {
  final String prompt;
  final List<StoryChoice> choices;

  const ChoiceNode({
    required super.id,
    required this.prompt,
    required this.choices,
  }) : super(type: StoryNodeType.choice);
}

/// A choice option within a ChoiceNode
@immutable
class StoryChoice {
  final String id;
  final String text;
  final bool isCorrect; // For teaching moments
  final String? feedback; // Immediate feedback after selection
  final List<StoryNode>? consequence; // Nodes shown after this choice

  const StoryChoice({
    required this.id,
    required this.text,
    this.isCorrect = true,
    this.feedback,
    this.consequence,
  });
}

/// Comprehension question node
@immutable
class ComprehensionNode extends StoryNode {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const ComprehensionNode({
    required super.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  }) : super(type: StoryNodeType.comprehension);
}

/// Image node
@immutable
class ImageNode extends StoryNode {
  final String imageUrl; // Asset path
  final String? caption;

  const ImageNode({
    required super.id,
    required this.imageUrl,
    this.caption,
  }) : super(type: StoryNodeType.image);
}

/// Progress tracking for stories
@immutable
class StoryProgress {
  final String storyId;
  final bool isCompleted;
  final DateTime? completedDate;
  final int currentChapterIndex;
  final int currentNodeIndex;
  final Map<String, String> choicesMade; // nodeId -> choiceId
  final int score; // Comprehension questions answered correctly

  const StoryProgress({
    required this.storyId,
    this.isCompleted = false,
    this.completedDate,
    this.currentChapterIndex = 0,
    this.currentNodeIndex = 0,
    this.choicesMade = const {},
    this.score = 0,
  });

  StoryProgress copyWith({
    String? storyId,
    bool? isCompleted,
    DateTime? completedDate,
    int? currentChapterIndex,
    int? currentNodeIndex,
    Map<String, String>? choicesMade,
    int? score,
  }) {
    return StoryProgress(
      storyId: storyId ?? this.storyId,
      isCompleted: isCompleted ?? this.isCompleted,
      completedDate: completedDate ?? this.completedDate,
      currentChapterIndex: currentChapterIndex ?? this.currentChapterIndex,
      currentNodeIndex: currentNodeIndex ?? this.currentNodeIndex,
      choicesMade: choicesMade ?? this.choicesMade,
      score: score ?? this.score,
    );
  }

  Map<String, dynamic> toJson() => {
    'storyId': storyId,
    'isCompleted': isCompleted,
    'completedDate': completedDate?.toIso8601String(),
    'currentChapterIndex': currentChapterIndex,
    'currentNodeIndex': currentNodeIndex,
    'choicesMade': choicesMade,
    'score': score,
  };

  factory StoryProgress.fromJson(Map<String, dynamic> json) {
    return StoryProgress(
      storyId: json['storyId'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedDate: json['completedDate'] != null
          ? DateTime.parse(json['completedDate'] as String)
          : null,
      currentChapterIndex: json['currentChapterIndex'] as int? ?? 0,
      currentNodeIndex: json['currentNodeIndex'] as int? ?? 0,
      choicesMade: Map<String, String>.from(json['choicesMade'] as Map? ?? {}),
      score: json['score'] as int? ?? 0,
    );
  }
}
```

### 2. UserProfile Extension

Add to `lib/models/user_profile.dart`:

```dart
// Add to UserProfile class
final Map<String, StoryProgress> storyProgress; // Track story progress

// Add to constructor
this.storyProgress = const {},

// Add to copyWith
Map<String, StoryProgress>? storyProgress,

storyProgress: storyProgress ?? this.storyProgress,

// Add to toJson
'storyProgress': storyProgress.map((key, value) => MapEntry(key, value.toJson())),

// Add to fromJson
storyProgress: (json['storyProgress'] as Map<String, dynamic>?)
    ?.map((key, value) => MapEntry(key, StoryProgress.fromJson(value as Map<String, dynamic>)))
    ?? {},

// Add to completedLessons list
final List<String> completedStories; // Story IDs

// Initialize in constructor
this.completedStories = const [],

// Add to copyWith, toJson, fromJson
```

### 3. Story Content Data

Create `lib/data/story_content.dart`:

```dart
import '../models/story.dart';
import '../models/user_profile.dart';

/// All available stories in the app
class StoryContent {
  static final List<Story> allStories = [
    _firstTankSetup,
    _ammoniaSpike,
    _sickBetta,
    _plantedTransformation,
    _breedingGoneWrong,
  ];

  /// Get stories by difficulty
  static List<Story> getByDifficulty(StoryDifficulty difficulty) {
    return allStories.where((s) => s.difficulty == difficulty).toList();
  }

  /// Get recommended stories for a user
  static List<Story> getRecommendedFor(UserProfile profile) {
    return allStories.where((s) => s.isRelevantFor(profile)).toList();
  }

  /// Get story by ID
  static Story? getById(String id) {
    try {
      return allStories.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}
```

---

## Complete Story Scenarios

### Story 1: First Tank Setup (Beginner)

```dart
static const Story _firstTankSetup = Story(
  id: 'first_tank_setup',
  title: 'First Tank Setup',
  description: 'Help Alex set up their very first aquarium. Learn about the nitrogen cycle, tank cycling, and making safe choices for beginners.',
  difficulty: StoryDifficulty.beginner,
  coverImage: '🐠',
  estimatedMinutes: 8,
  learningObjectives: [
    'Understand the importance of cycling',
    'Learn basic equipment needs',
    'Avoid beginner mistakes',
    'Choose appropriate starter fish',
  ],
  chapters: [
    StoryChapter(
      id: 'intro',
      title: 'Excitement at the Store',
      nodes: [
        DialogueNode(
          id: 'alex_excited',
          character: 'Alex',
          text: "I'm so excited! I just bought a 20-gallon tank. Can I add fish today?",
          characterImage: '😊',
        ),
        DialogueNode(
          id: 'shopkeeper_concerned',
          character: 'Shopkeeper',
          text: "Not so fast! Have you cycled the tank yet?",
          characterImage: '🤔',
          emotion: 'concerned',
        ),
        DialogueNode(
          id: 'alex_confused',
          character: 'Alex',
          text: "Cycled? What does that mean?",
          characterImage: '😕',
        ),
        NarrationNode(
          id: 'narration_cycle_explain',
          text: 'The shopkeeper explains that new tanks need beneficial bacteria to break down fish waste. This process is called cycling.',
        ),
        ComprehensionNode(
          id: 'q1_why_cycle',
          question: 'Why do new tanks need to be cycled?',
          options: [
            'To make the water clearer',
            'To grow beneficial bacteria',
            'To adjust the temperature',
            'To add oxygen',
          ],
          correctIndex: 1,
          explanation: 'Cycling grows beneficial bacteria that convert toxic ammonia into safer compounds. Without these bacteria, fish waste would poison the tank.',
        ),
        DialogueNode(
          id: 'shopkeeper_methods',
          character: 'Shopkeeper',
          text: "There are two main ways to cycle: fishless cycling with ammonia, or adding hardy fish slowly. Which sounds better to you?",
          characterImage: '🤔',
        ),
        ChoiceNode(
          id: 'choice_cycling_method',
          prompt: 'How should Alex cycle the tank?',
          choices: [
            StoryChoice(
              id: 'fishless',
              text: 'Fishless cycling with ammonia (safer, takes 4-6 weeks)',
              isCorrect: true,
              feedback: 'Great choice! Fishless cycling is safer because no fish are exposed to toxic ammonia.',
              consequence: [
                DialogueNode(
                  id: 'shopkeeper_approve',
                  character: 'Shopkeeper',
                  text: "Excellent! That's the safest method. I'll sell you some pure ammonia and a test kit.",
                  characterImage: '👍',
                ),
              ],
            ),
            StoryChoice(
              id: 'fish_in',
              text: 'Add a few hardy fish right away (faster but riskier)',
              isCorrect: false,
              feedback: 'This works but exposes fish to ammonia stress. Daily water changes are crucial.',
              consequence: [
                DialogueNode(
                  id: 'shopkeeper_warn',
                  character: 'Shopkeeper',
                  text: "That can work, but you'll need to do daily water changes and watch for ammonia spikes. It's stressful for the fish.",
                  characterImage: '😟',
                  emotion: 'worried',
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    StoryChapter(
      id: 'equipment_check',
      title: 'Getting the Right Equipment',
      nodes: [
        NarrationNode(
          id: 'two_weeks_later',
          text: '🕐 Two weeks later...',
          style: 'emphasis',
        ),
        DialogueNode(
          id: 'alex_excited_progress',
          character: 'Alex',
          text: "My ammonia is converting to nitrite now! The bacteria are growing!",
          characterImage: '🎉',
        ),
        DialogueNode(
          id: 'shopkeeper_next_step',
          character: 'Shopkeeper',
          text: "Perfect! Soon you'll see nitrate, and then you'll be ready for fish. Have you thought about what equipment you need?",
          characterImage: '🤔',
        ),
        ComprehensionNode(
          id: 'q2_essential_equipment',
          question: 'Which equipment is ESSENTIAL for a beginner freshwater tank?',
          options: [
            'UV sterilizer and CO2 system',
            'Filter, heater, and test kit',
            'Protein skimmer and wave maker',
            'Auto-feeder and chiller',
          ],
          correctIndex: 1,
          explanation: 'A filter (biological filtration), heater (stable temperature), and test kit (monitor water parameters) are the bare essentials. The other equipment is advanced or saltwater-specific.',
        ),
        DialogueNode(
          id: 'alex_research',
          character: 'Alex',
          text: "I've been researching fish! I want something colorful and easy.",
          characterImage: '📚',
        ),
        ChoiceNode(
          id: 'choice_first_fish',
          prompt: 'What should Alex choose as their first fish?',
          choices: [
            StoryChoice(
              id: 'guppy',
              text: 'Guppies (hardy, colorful, easy to care for)',
              isCorrect: true,
              feedback: 'Perfect! Guppies are ideal beginners fish - colorful, hardy, and forgiving of minor mistakes.',
            ),
            StoryChoice(
              id: 'betta',
              text: 'Betta fish (beautiful but needs specific care)',
              isCorrect: true,
              feedback: 'Good choice! Bettas are beautiful and can work, but need warm water (78-80°F) and no strong currents.',
            ),
            StoryChoice(
              id: 'discus',
              text: 'Discus (stunning but very advanced)',
              isCorrect: false,
              feedback: 'Whoa! Discus are beautiful but need pristine water, high temperatures, and expert care. Save these for later!',
              consequence: [
                DialogueNode(
                  id: 'shopkeeper_stop',
                  character: 'Shopkeeper',
                  text: "Hold on! Discus are expert-level fish. They need perfect water chemistry and daily attention. Let's start easier.",
                  characterImage: '✋',
                  emotion: 'warning',
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    StoryChapter(
      id: 'success',
      title: 'The Big Day',
      nodes: [
        NarrationNode(
          id: 'six_weeks_later',
          text: '🕐 Six weeks later... the cycle is complete!',
          style: 'success',
        ),
        DialogueNode(
          id: 'alex_test_results',
          character: 'Alex',
          text: "Ammonia: 0, Nitrite: 0, Nitrate: 20! My tank is ready!",
          characterImage: '🎊',
        ),
        DialogueNode(
          id: 'shopkeeper_proud',
          character: 'Shopkeeper',
          text: "You did it! You waited patiently, tested regularly, and now you have a healthy environment for fish. That's what good fishkeeping is all about.",
          characterImage: '🎓',
        ),
        NarrationNode(
          id: 'narration_success',
          text: 'Alex carefully acclimates their new fish over 30 minutes, watching them explore their new home. The patient approach paid off!',
        ),
        ComprehensionNode(
          id: 'q3_final_lesson',
          question: 'What was the most important lesson Alex learned?',
          options: [
            'Expensive equipment is essential',
            'Patience and testing prevent problems',
            'Fish can adapt to any water',
            'Cycling is optional for small tanks',
          ],
          correctIndex: 1,
          explanation: 'Patience and regular testing are the foundation of successful fishkeeping. Rushing leads to dead fish and frustration.',
        ),
        NarrationNode(
          id: 'conclusion',
          text: '✨ Story Complete! You learned about cycling, equipment, and choosing appropriate fish. Your patience will save countless fish lives!',
          style: 'success',
        ),
      ],
    ),
  ],
);
```

### Story 2: Ammonia Spike Emergency (Intermediate)

```dart
static const Story _ammoniaSpike = Story(
  id: 'ammonia_spike',
  title: 'Ammonia Spike Emergency',
  description: 'A sudden ammonia spike threatens Jordan\'s tank. Learn to diagnose problems, take emergency action, and prevent future crises.',
  difficulty: StoryDifficulty.intermediate,
  coverImage: '⚠️',
  estimatedMinutes: 10,
  learningObjectives: [
    'Recognize ammonia poisoning symptoms',
    'Perform emergency water changes',
    'Diagnose root causes',
    'Prevent future spikes',
  ],
  relevantTankTypes: [TankType.freshwater, TankType.planted],
  chapters: [
    StoryChapter(
      id: 'crisis',
      title: 'Something Is Wrong',
      nodes: [
        DialogueNode(
          id: 'jordan_panic',
          character: 'Jordan',
          text: "Help! My fish are gasping at the surface and their gills are red!",
          characterImage: '😰',
          emotion: 'panicked',
        ),
        DialogueNode(
          id: 'expert_calm',
          character: 'Expert',
          text: "Stay calm. Describe what you're seeing - are they all affected?",
          characterImage: '🧑‍⚕️',
        ),
        DialogueNode(
          id: 'jordan_symptoms',
          character: 'Jordan',
          text: "Yes! They're all acting weird. Some are hiding, others are at the surface. I fed them an hour ago.",
          characterImage: '😟',
        ),
        ComprehensionNode(
          id: 'q1_symptoms',
          question: 'What do these symptoms suggest?',
          options: [
            'The fish are just hungry',
            'Possible ammonia or nitrite poisoning',
            'Temperature is too low',
            'They need more decorations',
          ],
          correctIndex: 1,
          explanation: 'Gasping at surface, red gills, and lethargy are classic signs of ammonia/nitrite poisoning - a life-threatening emergency.',
        ),
        DialogueNode(
          id: 'expert_test',
          character: 'Expert',
          text: "Test your water immediately - ammonia, nitrite, nitrate, and pH.",
          characterImage: '🧪',
        ),
        NarrationNode(
          id: 'test_results',
          text: '🧪 Test Results: Ammonia: 4.0 ppm (DANGER!), Nitrite: 0.25 ppm, Nitrate: 30 ppm, pH: 7.4',
          style: 'warning',
        ),
        ChoiceNode(
          id: 'choice_emergency_action',
          prompt: 'What should Jordan do IMMEDIATELY?',
          choices: [
            StoryChoice(
              id: 'water_change',
              text: 'Large water change (50%) with dechlorinated water',
              isCorrect: true,
              feedback: 'Correct! Diluting ammonia immediately is the first priority.',
              consequence: [
                DialogueNode(
                  id: 'expert_approve_wc',
                  character: 'Expert',
                  text: "Perfect! Change 50% now, test again in 2 hours, and be ready for another change if needed.",
                  characterImage: '👍',
                ),
              ],
            ),
            StoryChoice(
              id: 'add_chemicals',
              text: 'Add ammonia-removing chemicals',
              isCorrect: false,
              feedback: 'Chemicals can help, but water changes are faster and more reliable in emergencies.',
              consequence: [
                DialogueNode(
                  id: 'expert_better_way',
                  character: 'Expert',
                  text: "Those can help, but dilution is faster. Do a water change FIRST, then add chemicals if you have them.",
                  characterImage: '🤔',
                ),
              ],
            ),
            StoryChoice(
              id: 'wait',
              text: 'Wait and see if it improves',
              isCorrect: false,
              feedback: 'NEVER wait! Ammonia above 1 ppm is toxic and can kill fish within hours.',
              consequence: [
                DialogueNode(
                  id: 'expert_urgent',
                  character: 'Expert',
                  text: "No! At 4.0 ppm, your fish could die within hours. Act NOW with a water change!",
                  characterImage: '🚨',
                  emotion: 'urgent',
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    StoryChapter(
      id: 'investigation',
      title: 'Finding the Cause',
      nodes: [
        NarrationNode(
          id: 'after_water_change',
          text: '💧 After a 50% water change, ammonia drops to 1.0 ppm. Fish are breathing easier.',
        ),
        DialogueNode(
          id: 'jordan_relief',
          character: 'Jordan',
          text: "They're looking better! But why did this happen? My tank is 6 months old.",
          characterImage: '😌',
        ),
        DialogueNode(
          id: 'expert_investigate',
          character: 'Expert',
          text: "Good question. Ammonia spikes in established tanks have specific causes. When did you last clean the filter?",
          characterImage: '🔍',
        ),
        DialogueNode(
          id: 'jordan_filter',
          character: 'Jordan',
          text: "Yesterday! I replaced all the filter media with brand new cartridges. The old ones were dirty.",
          characterImage: '😬',
        ),
        ComprehensionNode(
          id: 'q2_filter_mistake',
          question: 'What did Jordan do wrong?',
          options: [
            'Should have cleaned filter more often',
            'Replaced ALL beneficial bacteria at once',
            'Should have used a different brand',
            'Filter cartridges don\'t need changing',
          ],
          correctIndex: 1,
          explanation: 'Replacing all filter media removes ALL beneficial bacteria, crashing the cycle. Never replace everything at once - rinse in old tank water or replace gradually.',
        ),
        DialogueNode(
          id: 'expert_explain',
          character: 'Expert',
          text: "There's the problem! The 'dirty' media was actually housing all your beneficial bacteria. You crashed your cycle.",
          characterImage: '💡',
        ),
        ChoiceNode(
          id: 'choice_recovery',
          prompt: 'How should Jordan recover the cycle?',
          choices: [
            StoryChoice(
              id: 'daily_changes',
              text: 'Daily water changes + bottled bacteria',
              isCorrect: true,
              feedback: 'Exactly! Daily changes keep ammonia safe while bacteria re-establish. Bottled bacteria speeds recovery.',
            ),
            StoryChoice(
              id: 'stop_feeding',
              text: 'Stop feeding fish to reduce waste',
              isCorrect: false,
              feedback: 'Fish still produce ammonia from respiration. Reduced feeding helps, but water changes are essential.',
            ),
            StoryChoice(
              id: 'add_more_fish',
              text: 'Add more fish to speed up cycling',
              isCorrect: false,
              feedback: 'NO! More fish = more ammonia = bigger crisis. Never add fish during an ammonia spike.',
            ),
          ],
        ),
      ],
    ),
    StoryChapter(
      id: 'resolution',
      title: 'Recovery and Prevention',
      nodes: [
        NarrationNode(
          id: 'two_weeks_later',
          text: '🕐 Two weeks of daily testing and water changes...',
        ),
        DialogueNode(
          id: 'jordan_success',
          character: 'Jordan',
          text: "Ammonia and nitrite are finally back to zero! The bacteria have recovered.",
          characterImage: '🎉',
        ),
        DialogueNode(
          id: 'expert_lesson',
          character: 'Expert',
          text: "You handled it well. Now, let's talk about prevention. How will you maintain the filter next time?",
          characterImage: '🎓',
        ),
        ComprehensionNode(
          id: 'q3_prevention',
          question: 'Best practice for filter maintenance?',
          options: [
            'Replace all media monthly',
            'Never clean the filter',
            'Rinse media in old tank water, replace gradually',
            'Only use chemical filtration',
          ],
          correctIndex: 2,
          explanation: 'Rinse mechanical media in old tank water (not tap water - chlorine kills bacteria). Replace media gradually, never all at once.',
        ),
        NarrationNode(
          id: 'conclusion',
          text: '✨ Story Complete! You learned to recognize ammonia poisoning, take emergency action, and prevent filter maintenance mistakes.',
          style: 'success',
        ),
      ],
    ),
  ],
);
```

### Story 3: The Sick Betta (Intermediate)

```dart
static const Story _sickBetta = Story(
  id: 'sick_betta',
  title: 'The Sick Betta',
  description: 'Sam\'s beloved betta, Ruby, is showing worrying symptoms. Learn to diagnose common diseases, set up a hospital tank, and treat ich.',
  difficulty: StoryDifficulty.intermediate,
  coverImage: '🐟',
  estimatedMinutes: 12,
  learningObjectives: [
    'Identify common betta diseases',
    'Set up a hospital/quarantine tank',
    'Treat ich (white spot disease)',
    'Understand medication safety',
  ],
  chapters: [
    StoryChapter(
      id: 'discovery',
      title: 'White Spots',
      nodes: [
        DialogueNode(
          id: 'sam_worried',
          character: 'Sam',
          text: "Ruby has tiny white spots all over her body! She's also clamping her fins.",
          characterImage: '😟',
        ),
        DialogueNode(
          id: 'vet_examine',
          character: 'Aquatic Vet',
          text: "Let me see a photo. Hmm... white spots like grains of salt, and fin clamping?",
          characterImage: '🩺',
        ),
        DialogueNode(
          id: 'sam_photo',
          character: 'Sam',
          text: "Yes! Each spot is tiny and raised. She's also scratching against decorations.",
          characterImage: '📸',
        ),
        ComprehensionNode(
          id: 'q1_diagnosis',
          question: 'What disease is this most likely?',
          options: [
            'Fin rot',
            'Ich (white spot disease)',
            'Velvet disease',
            'Dropsy',
          ],
          correctIndex: 1,
          explanation: 'Ich (Ichthyophthirius) appears as white "salt grain" spots, causes scratching (flashing), and fin clamping. It\'s very common and treatable.',
        ),
        DialogueNode(
          id: 'vet_confirm',
          character: 'Aquatic Vet',
          text: "Classic ich. It's a parasite with a life cycle - the spots are just one stage. We need to treat the whole tank.",
          characterImage: '🔬',
        ),
        NarrationNode(
          id: 'ich_lifecycle',
          text: '📚 Ich Lifecycle: Parasite attaches to fish (white spots) → drops off → multiplies in substrate → free-swimming stage (vulnerable to treatment) → re-infects fish.',
        ),
        ChoiceNode(
          id: 'choice_treatment_location',
          prompt: 'Where should Sam treat Ruby?',
          choices: [
            StoryChoice(
              id: 'hospital_tank',
              text: 'Set up a hospital/quarantine tank',
              isCorrect: true,
              feedback: 'Good thinking! A hospital tank lets you medicate without stressing healthy fish or killing beneficial bacteria.',
            ),
            StoryChoice(
              id: 'main_tank',
              text: 'Treat the entire main tank',
              isCorrect: true,
              feedback: 'Also correct! Since ich spreads easily, treating the whole tank prevents re-infection. Just watch for sensitive species.',
            ),
            StoryChoice(
              id: 'isolation_only',
              text: 'Just isolate Ruby without treatment',
              isCorrect: false,
              feedback: 'Isolation alone won\'t help - ich is already in the main tank water. Treatment is essential.',
            ),
          ],
        ),
      ],
    ),
    StoryChapter(
      id: 'treatment',
      title: 'Hospital Tank Setup',
      nodes: [
        DialogueNode(
          id: 'sam_setup',
          character: 'Sam',
          text: "I'll use a hospital tank. What do I need?",
          characterImage: '🏥',
        ),
        DialogueNode(
          id: 'vet_equipment',
          character: 'Aquatic Vet',
          text: "Simple setup: 5-10 gallon tank, sponge filter or air stone, heater set to 78-80°F, and hiding spots. No substrate - easier to clean.",
          characterImage: '🛠️',
        ),
        ComprehensionNode(
          id: 'q2_hospital_tank',
          question: 'Why no substrate in a hospital tank?',
          options: [
            'Fish don\'t like substrate',
            'Easier to monitor medication and clean waste',
            'Substrate causes disease',
            'It\'s cheaper',
          ],
          correctIndex: 1,
          explanation: 'Bare-bottom hospital tanks make it easy to see waste/medication residue, monitor the fish, and do thorough cleanings without harboring parasites.',
        ),
        NarrationNode(
          id: 'water_match',
          text: '💡 Important: Sam fills the hospital tank with water from the main tank to match temperature and parameters.',
        ),
        DialogueNode(
          id: 'vet_medication',
          character: 'Aquatic Vet',
          text: "For ich, we'll use heat + salt OR a copper-free ich medication. Heat speeds up the parasite lifecycle so meds work faster.",
          characterImage: '💊',
        ),
        ChoiceNode(
          id: 'choice_treatment_method',
          prompt: 'Which treatment should Sam use?',
          choices: [
            StoryChoice(
              id: 'heat_salt',
              text: 'Heat to 86°F + aquarium salt (natural method)',
              isCorrect: true,
              feedback: 'Effective! Heat speeds the cycle, salt stresses the parasite. Safe for bettas but raise temp gradually.',
            ),
            StoryChoice(
              id: 'medication',
              text: 'Commercial ich medication (malachite green)',
              isCorrect: true,
              feedback: 'Also works! Follow dosing carefully and remove carbon filtration. Can stain decorations blue/green.',
            ),
            StoryChoice(
              id: 'antibiotics',
              text: 'Antibiotics',
              isCorrect: false,
              feedback: 'No! Ich is a parasite, not bacteria. Antibiotics won\'t help and can harm beneficial bacteria.',
            ),
          ],
        ),
      ],
    ),
    StoryChapter(
      id: 'recovery',
      title: 'The Long Game',
      nodes: [
        NarrationNode(
          id: 'treatment_timeline',
          text: '🕐 Day 3 of treatment: White spots are starting to fall off...',
        ),
        DialogueNode(
          id: 'sam_hopeful',
          character: 'Sam',
          text: "The spots are disappearing! Is she cured?",
          characterImage: '😊',
        ),
        DialogueNode(
          id: 'vet_patience',
          character: 'Aquatic Vet',
          text: "Not yet! The parasites are in the free-swimming stage now. Keep treating for 7-10 days AFTER spots disappear.",
          characterImage: '⏰',
          emotion: 'serious',
        ),
        ComprehensionNode(
          id: 'q3_treatment_duration',
          question: 'Why continue treatment after spots are gone?',
          options: [
            'To prevent other diseases',
            'To kill free-swimming parasites before they re-infect',
            'The medication strengthens the fish',
            'It\'s not necessary',
          ],
          correctIndex: 1,
          explanation: 'Spots falling off means parasites entered the free-swimming stage. They\'ll re-infect unless killed during this vulnerable phase. Always complete the full treatment course.',
        ),
        NarrationNode(
          id: 'day_10',
          text: '🕐 Day 10: No new spots, Ruby is swimming actively...',
        ),
        DialogueNode(
          id: 'sam_success',
          character: 'Sam',
          text: "She's back to her sassy self! Flaring at me and begging for food.",
          characterImage: '🎉',
        ),
        DialogueNode(
          id: 'vet_prevention',
          character: 'Aquatic Vet',
          text: "Excellent! Now, ich usually appears when fish are stressed. Check your water parameters and make sure temp is stable.",
          characterImage: '🎓',
        ),
        NarrationNode(
          id: 'conclusion',
          text: '✨ Story Complete! You learned to diagnose ich, set up a hospital tank, choose appropriate treatment, and complete the full course.',
          style: 'success',
        ),
      ],
    ),
  ],
);
```

### Story 4: Planted Tank Transformation (Advanced)

```dart
static const Story _plantedTransformation = Story(
  id: 'planted_transformation',
  title: 'Planted Tank Transformation',
  description: 'Transform Maya\'s simple tank into a thriving planted aquascape. Master CO2, fertilization, lighting schedules, and algae control.',
  difficulty: StoryDifficulty.advanced,
  coverImage: '🌿',
  estimatedMinutes: 15,
  learningObjectives: [
    'Balance light, CO2, and nutrients',
    'Implement the Walstad method vs. high-tech',
    'Control algae through balance',
    'Create a maintenance schedule',
  ],
  relevantTankTypes: [TankType.planted],
  chapters: [
    StoryChapter(
      id: 'planning',
      title: 'The Vision',
      nodes: [
        DialogueNode(
          id: 'maya_inspiration',
          character: 'Maya',
          text: "I saw an incredible planted tank online - lush, red plants, no algae. I want THAT.",
          characterImage: '😍',
        ),
        DialogueNode(
          id: 'expert_caution',
          character: 'Plant Expert',
          text: "Beautiful tanks take balance. High light without enough CO2 and nutrients = algae nightmare.",
          characterImage: '🌱',
        ),
        DialogueNode(
          id: 'maya_current',
          character: 'Maya',
          text: "Right now I have basic LED lighting, no CO2, and some root tabs. What do I need to change?",
          characterImage: '🤔',
        ),
        ComprehensionNode(
          id: 'q1_balance',
          question: 'What is the key to planted tank success?',
          options: [
            'Maximum lighting for fast growth',
            'Expensive equipment',
            'Balance between light, CO2, and nutrients',
            'Daily water changes',
          ],
          correctIndex: 2,
          explanation: 'Planted tanks thrive on BALANCE. High light needs high CO2 + nutrients. Low light needs less. Imbalance = algae.',
        ),
        DialogueNode(
          id: 'expert_approaches',
          character: 'Plant Expert',
          text: "Two approaches: Low-tech (Walstad method - low light, no CO2) or High-tech (high light, pressurized CO2, liquid ferts). Pick your commitment level.",
          characterImage: '🔬',
        ),
        ChoiceNode(
          id: 'choice_approach',
          prompt: 'Which approach should Maya choose?',
          choices: [
            StoryChoice(
              id: 'high_tech',
              text: 'High-tech (stunning but demanding)',
              isCorrect: true,
              feedback: 'Beautiful results! But requires daily monitoring, CO2 adjustment, and consistent maintenance.',
              consequence: [
                DialogueNode(
                  id: 'expert_high_tech',
                  character: 'Plant Expert',
                  text: "Ambitious! You'll need: pressurized CO2, good light (PAR 50+), liquid fertilizers, and daily attention.",
                  characterImage: '⚗️',
                ),
              ],
            ),
            StoryChoice(
              id: 'low_tech',
              text: 'Low-tech (easier, still beautiful)',
              isCorrect: true,
              feedback: 'Smart choice! Slower growth but much more forgiving. Less algae risk.',
              consequence: [
                DialogueNode(
                  id: 'expert_low_tech',
                  character: 'Plant Expert',
                  text: "Wise! Low-tech uses soil substrate, low-medium light, and hardy plants. Much more stable.",
                  characterImage: '🌿',
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    StoryChapter(
      id: 'implementation',
      title: 'Setting Up High-Tech',
      nodes: [
        NarrationNode(
          id: 'maya_goes_high_tech',
          text: '💡 Maya chose high-tech for the challenge...',
        ),
        DialogueNode(
          id: 'maya_equipment',
          character: 'Maya',
          text: "I bought a CO2 system, Fluval 3.0 light, and Aqua Soil. Now what?",
          characterImage: '🛒',
        ),
        DialogueNode(
          id: 'expert_co2_setup',
          character: 'Plant Expert',
          text: "CO2 first. Aim for 30 ppm during light hours. Use a drop checker to monitor. Start low, increase gradually.",
          characterImage: '💨',
        ),
        ComprehensionNode(
          id: 'q2_co2',
          question: 'Why run CO2 only during light hours?',
          options: [
            'To save money',
            'Plants only use CO2 during photosynthesis',
            'Fish prefer it that way',
            'CO2 expires at night',
          ],
          correctIndex: 1,
          explanation: 'Plants use CO2 during photosynthesis (light hours). At night, they respire and produce CO2. Running it 24/7 wastes gas and can stress fish.',
        ),
        DialogueNode(
          id: 'expert_photoperiod',
          character: 'Plant Expert',
          text: "Set a consistent photoperiod - 6 hours to start, increase to 8 if no algae. More light isn't always better.",
          characterImage: '⏰',
        ),
        NarrationNode(
          id: 'week_two',
          text: '🕐 Week 2: Plants are growing, but green algae is appearing on glass...',
        ),
        ChoiceNode(
          id: 'choice_algae_response',
          prompt: 'How should Maya handle the algae?',
          choices: [
            StoryChoice(
              id: 'reduce_light',
              text: 'Reduce photoperiod to 6 hours, check CO2 levels',
              isCorrect: true,
              feedback: 'Smart! Algae often means light exceeds CO2/nutrients. Reduce one or boost the others.',
            ),
            StoryChoice(
              id: 'algaecide',
              text: 'Add algaecide chemicals',
              isCorrect: false,
              feedback: 'Quick fix but doesn\'t address the root cause. Algae will return unless you fix the imbalance.',
            ),
            StoryChoice(
              id: 'increase_light',
              text: 'Increase light to out-compete algae',
              isCorrect: false,
              feedback: 'NO! More light without more CO2/nutrients makes algae WORSE. Always maintain balance.',
            ),
          ],
        ),
      ],
    ),
    StoryChapter(
      id: 'mastery',
      title: 'Achieving Balance',
      nodes: [
        NarrationNode(
          id: 'month_two',
          text: '🕐 Two months later: Maya has dialed in her system...',
        ),
        DialogueNode(
          id: 'maya_success',
          character: 'Maya',
          text: "No algae for 3 weeks! Plants are pearling (bubbling oxygen). Red plants are actually RED!",
          characterImage: '🎨',
        ),
        DialogueNode(
          id: 'expert_pearling',
          character: 'Plant Expert',
          text: "Pearling means photosynthesis is maxed out - perfect balance! Now maintain it with a schedule.",
          characterImage: '✨',
        ),
        ComprehensionNode(
          id: 'q3_maintenance',
          question: 'What weekly maintenance does a high-tech tank need?',
          options: [
            'Just top off evaporation',
            '50% water change + dose fertilizers',
            'Full substrate cleaning',
            'Replace all plants',
          ],
          correctIndex: 1,
          explanation: 'High-tech tanks need consistent water changes (50% weekly) to remove excess nutrients and replenish minerals, plus regular fertilizer dosing to match plant uptake.',
        ),
        NarrationNode(
          id: 'final_scene',
          text: '🌿 Maya's tank is now a thriving underwater garden - schools of tetras darting through carpets of glossy green, red accents catching the light.',
        ),
        DialogueNode(
          id: 'maya_reflection',
          character: 'Maya',
          text: "It was frustrating at first, but understanding the balance changed everything. Now it's almost effortless.",
          characterImage: '🧘',
        ),
        NarrationNode(
          id: 'conclusion',
          text: '✨ Story Complete! You mastered CO2 injection, lighting schedules, nutrient balance, and algae control through understanding ecosystem balance.',
          style: 'success',
        ),
      ],
    ),
  ],
);
```

### Story 5: Breeding Project Gone Wrong (Advanced)

```dart
static const Story _breedingGoneWrong = Story(
  id: 'breeding_gone_wrong',
  title: 'Breeding Project Gone Wrong',
  description: 'Chris\'s breeding project spirals out of control. Learn about selective breeding, population management, and ethical fishkeeping.',
  difficulty: StoryDifficulty.advanced,
  coverImage: '🥚',
  estimatedMinutes: 14,
  learningObjectives: [
    'Understand breeding ethics and responsibility',
    'Manage unexpected population explosions',
    'Selective breeding vs. culling',
    'Prevent inbreeding depression',
  ],
  chapters: [
    StoryChapter(
      id: 'beginning',
      title: 'The Breeding Pair',
      nodes: [
        DialogueNode(
          id: 'chris_excited',
          character: 'Chris',
          text: "My guppy pair just had babies! 30 tiny fry! This is so cool!",
          characterImage: '🍼',
        ),
        DialogueNode(
          id: 'mentor_concerned',
          character: 'Breeder Mentor',
          text: "Congratulations! But... do you have a plan for 30 guppies in 2 months? 300 in 6 months?",
          characterImage: '🤔',
          emotion: 'concerned',
        ),
        DialogueNode(
          id: 'chris_confused',
          character: 'Chris',
          text: "Wait, what? They'll have MORE babies?",
          characterImage: '😳',
        ),
        ComprehensionNode(
          id: 'q1_guppy_breeding',
          question: 'How often can guppies breed?',
          options: [
            'Once per year',
            'Every 3-6 months',
            'Every 21-30 days',
            'Only once in their lifetime',
          ],
          correctIndex: 2,
          explanation: 'Female guppies can produce fry every 21-30 days, and can store sperm for multiple batches. Population explosions happen FAST.',
        ),
        DialogueNode(
          id: 'mentor_reality',
          character: 'Breeder Mentor',
          text: "Livebearers are called 'the million fish' for a reason. You need a plan: sell them, give them away, or separate males and females NOW.",
          characterImage: '📊',
        ),
        ChoiceNode(
          id: 'choice_initial_response',
          prompt: 'What should Chris do immediately?',
          choices: [
            StoryChoice(
              id: 'separate_sexes',
              text: 'Separate males and females to stop breeding',
              isCorrect: true,
              feedback: 'Smart! Population control is essential. But the females might already be pregnant...',
            ),
            StoryChoice(
              id: 'let_nature',
              text: 'Let nature take its course, parents will eat some',
              isCorrect: false,
              feedback: 'True, but not enough. You\'ll still have population explosion. Responsible breeding requires active management.',
            ),
            StoryChoice(
              id: 'get_predators',
              text: 'Add a predator fish to control population',
              isCorrect: false,
              feedback: 'Unethical and unreliable. Predators don\'t eat exactly the right number, and you\'re just creating more mouths to feed.',
            ),
          ],
        ),
      ],
    ),
    StoryChapter(
      id: 'crisis',
      title: 'Population Explosion',
      nodes: [
        NarrationNode(
          id: 'three_months_later',
          text: '🕐 Three months later...',
        ),
        DialogueNode(
          id: 'chris_overwhelmed',
          character: 'Chris',
          text: "I have 8 tanks now. Over 200 guppies. The store won't take more. My water bill is insane.",
          characterImage: '😰',
        ),
        DialogueNode(
          id: 'mentor_hard_truth',
          character: 'Breeder Mentor',
          text: "This is why responsible breeders are selective. They don't keep every fish. We need to talk about culling.",
          characterImage: '😔',
          emotion: 'serious',
        ),
        DialogueNode(
          id: 'chris_shocked',
          character: 'Chris',
          text: "Culling? You mean... I can't do that!",
          characterImage: '😨',
        ),
        ComprehensionNode(
          id: 'q2_culling_ethics',
          question: 'What is the ethical purpose of culling in breeding?',
          options: [
            'To be cruel to fish',
            'To improve genetics and prevent suffering',
            'To make money faster',
            'It serves no purpose',
          ],
          correctIndex: 1,
          explanation: 'Ethical culling prevents weak/deformed fish from suffering, controls unsustainable populations, and improves genetics. It\'s a hard but necessary responsibility of breeding.',
        ),
        DialogueNode(
          id: 'mentor_alternatives',
          character: 'Breeder Mentor',
          text: "If you can't cull, you MUST prevent breeding. Separate sexes, or don't breed at all. There's no shame in stopping.",
          characterImage: '🛑',
        ),
        ChoiceNode(
          id: 'choice_crisis_response',
          prompt: 'How should Chris resolve this crisis?',
          choices: [
            StoryChoice(
              id: 'stop_breeding',
              text: 'Permanently separate sexes, find homes for current fish',
              isCorrect: true,
              feedback: 'Responsible choice! Admitting you\'re overwhelmed and stopping is better than continuing unsustainably.',
            ),
            StoryChoice(
              id: 'selective_breeding',
              text: 'Learn proper selective breeding + culling',
              isCorrect: true,
              feedback: 'Valid path if you\'re committed. Requires education, equipment, and emotional maturity for tough decisions.',
            ),
            StoryChoice(
              id: 'release_wild',
              text: 'Release extras into local ponds',
              isCorrect: false,
              feedback: 'ILLEGAL and ecologically devastating! Never release aquarium fish into the wild. They spread disease and destroy ecosystems.',
              consequence: [
                DialogueNode(
                  id: 'mentor_angry',
                  character: 'Breeder Mentor',
                  text: "ABSOLUTELY NOT! That's illegal and destroys local ecosystems. Invasive species cause billions in damage. NEVER release aquarium fish.",
                  characterImage: '🚫',
                  emotion: 'angry',
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    StoryChapter(
      id: 'resolution',
      title: 'A Lesson Learned',
      nodes: [
        NarrationNode(
          id: 'six_months_later',
          text: '🕐 Six months later...',
        ),
        DialogueNode(
          id: 'chris_wiser',
          character: 'Chris',
          text: "I found homes for most of them. Now I keep males-only tanks - still beautiful, zero population stress.",
          characterImage: '😌',
        ),
        DialogueNode(
          id: 'mentor_proud',
          character: 'Breeder Mentor',
          text: "You learned the hard way, but you learned. Breeding sounds fun until you're drowning in fish. Respect the responsibility.",
          characterImage: '🎓',
        ),
        ComprehensionNode(
          id: 'q3_breeding_responsibility',
          question: 'What should EVERY breeder have BEFORE breeding?',
          options: [
            'Expensive equipment',
            'A plan for every fish produced',
            'Social media followers',
            'Multiple tanks',
          ],
          correctIndex: 1,
          explanation: 'NEVER breed without a plan for every fish: sales channels, local stores committed to taking them, or willingness to cull. Breeding without a plan is irresponsible.',
        ),
        DialogueNode(
          id: 'chris_advice',
          character: 'Chris',
          text: "If I could go back, I'd research FIRST. Talk to stores. Understand the commitment. Maybe just... not breed.",
          characterImage: '💭',
        ),
        NarrationNode(
          id: 'final_wisdom',
          text: '💡 Not every fish needs to breed. Not every hobbyist needs to be a breeder. There\'s honor in simply providing excellent care.',
        ),
        NarrationNode(
          id: 'conclusion',
          text: '✨ Story Complete! You learned about breeding ethics, population management, the reality of culling, and the responsibility that comes with creating life.',
          style: 'success',
        ),
      ],
    ),
  ],
);
```

---

## UI Implementation

### 1. Story List Screen (`lib/screens/story_list_screen.dart`)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/story_content.dart';
import '../models/story.dart';
import '../models/user_profile.dart';
import '../providers/user_profile_provider.dart';
import '../theme/app_theme.dart';
import 'story_screen.dart';

/// Screen showing all available stories with progress
class StoryListScreen extends ConsumerWidget {
  const StoryListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('📖 Stories'),
        elevation: 0,
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (profile) {
          final stories = StoryContent.allStories;
          final beginner = stories.where((s) => s.difficulty == StoryDifficulty.beginner).toList();
          final intermediate = stories.where((s) => s.difficulty == StoryDifficulty.intermediate).toList();
          final advanced = stories.where((s) => s.difficulty == StoryDifficulty.advanced).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Header card
              _buildHeaderCard(context, profile),
              const SizedBox(height: 24),

              // Beginner stories
              if (beginner.isNotEmpty) ...[
                _buildSectionHeader(StoryDifficulty.beginner),
                const SizedBox(height: 12),
                ...beginner.map((story) => _buildStoryCard(context, ref, story, profile)),
                const SizedBox(height: 24),
              ],

              // Intermediate stories
              if (intermediate.isNotEmpty) ...[
                _buildSectionHeader(StoryDifficulty.intermediate),
                const SizedBox(height: 12),
                ...intermediate.map((story) => _buildStoryCard(context, ref, story, profile)),
                const SizedBox(height: 24),
              ],

              // Advanced stories
              if (advanced.isNotEmpty) ...[
                _buildSectionHeader(StoryDifficulty.advanced),
                const SizedBox(height: 12),
                ...advanced.map((story) => _buildStoryCard(context, ref, story, profile)),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, UserProfile? profile) {
    final completedCount = profile?.completedStories.length ?? 0;
    final totalCount = StoryContent.allStories.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Learn Through Stories',
              style: AppTypography.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Real-world scenarios that teach you aquarium concepts through interactive narratives.',
              style: AppTypography.bodyMedium.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: totalCount > 0 ? completedCount / totalCount : 0,
              backgroundColor: Colors.grey[200],
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Text(
              '$completedCount of $totalCount stories completed',
              style: AppTypography.labelMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(StoryDifficulty difficulty) {
    return Row(
      children: [
        Text(
          difficulty.emoji,
          style: const TextStyle(fontSize: 24),
        ),
        const SizedBox(width: 8),
        Text(
          difficulty.displayName,
          style: AppTypography.titleLarge,
        ),
      ],
    );
  }

  Widget _buildStoryCard(BuildContext context, WidgetRef ref, Story story, UserProfile? profile) {
    final progress = profile?.storyProgress[story.id];
    final isCompleted = progress?.isCompleted ?? false;
    final inProgress = progress != null && !isCompleted;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StoryScreen(story: story),
          ),
        ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Cover icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _getDifficultyColor(story.difficulty).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    story.coverImage,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Story info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            story.title,
                            style: AppTypography.titleMedium,
                          ),
                        ),
                        if (isCompleted)
                          const Icon(Icons.check_circle, color: Colors.green, size: 20),
                        if (inProgress)
                          const Icon(Icons.play_circle_outline, color: Colors.orange, size: 20),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      story.description,
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.timer_outlined, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${story.estimatedMinutes} min',
                          style: AppTypography.labelSmall.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.emoji_events_outlined, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '+${story.xpReward} XP',
                          style: AppTypography.labelSmall.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getDifficultyColor(StoryDifficulty difficulty) {
    switch (difficulty) {
      case StoryDifficulty.beginner:
        return Colors.green;
      case StoryDifficulty.intermediate:
        return Colors.orange;
      case StoryDifficulty.advanced:
        return Colors.red;
    }
  }
}
```

### 2. Story Screen (`lib/screens/story_screen.dart`)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/story.dart';
import '../models/user_profile.dart';
import '../providers/user_profile_provider.dart';
import '../theme/app_theme.dart';

/// Interactive story screen with dialogue, choices, and comprehension
class StoryScreen extends ConsumerStatefulWidget {
  final Story story;

  const StoryScreen({super.key, required this.story});

  @override
  ConsumerState<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends ConsumerState<StoryScreen> {
  int _currentChapterIndex = 0;
  int _currentNodeIndex = 0;
  final Map<String, String> _choicesMade = {};
  int _correctAnswers = 0;
  List<StoryNode> _dynamicNodes = [];

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  void _loadProgress() {
    final profile = ref.read(userProfileProvider).value;
    final progress = profile?.storyProgress[widget.story.id];
    if (progress != null && !progress.isCompleted) {
      setState(() {
        _currentChapterIndex = progress.currentChapterIndex;
        _currentNodeIndex = progress.currentNodeIndex;
        _choicesMade.addAll(progress.choicesMade);
        _correctAnswers = progress.score;
      });
    }
  }

  StoryChapter get _currentChapter => widget.story.chapters[_currentChapterIndex];
  
  List<StoryNode> get _currentNodes {
    final baseNodes = _currentChapter.nodes;
    final allNodes = [...baseNodes, ..._dynamicNodes];
    return allNodes;
  }

  StoryNode? get _currentNode {
    if (_currentNodeIndex < _currentNodes.length) {
      return _currentNodes[_currentNodeIndex];
    }
    return null;
  }

  bool get _isLastNode => _currentNodeIndex >= _currentNodes.length - 1;
  bool get _isLastChapter => _currentChapterIndex >= widget.story.chapters.length - 1;

  void _nextNode() {
    setState(() {
      if (_isLastNode) {
        if (_isLastChapter) {
          _completeStory();
        } else {
          _currentChapterIndex++;
          _currentNodeIndex = 0;
          _dynamicNodes.clear();
        }
      } else {
        _currentNodeIndex++;
      }
      _saveProgress();
    });
  }

  void _handleChoice(ChoiceNode choiceNode, StoryChoice choice) {
    setState(() {
      _choicesMade[choiceNode.id] = choice.id;
      
      // Add consequence nodes if any
      if (choice.consequence != null && choice.consequence!.isNotEmpty) {
        _dynamicNodes.addAll(choice.consequence!);
      }
    });

    // Show feedback dialog
    if (choice.feedback != null) {
      _showFeedbackDialog(choice.feedback!, choice.isCorrect);
    } else {
      _nextNode();
    }
  }

  void _handleComprehension(ComprehensionNode node, int selectedIndex) {
    final isCorrect = selectedIndex == node.correctIndex;
    if (isCorrect) {
      _correctAnswers++;
    }

    _showComprehensionFeedback(node, selectedIndex, isCorrect);
  }

  void _showFeedbackDialog(String feedback, bool isCorrect) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              isCorrect ? Icons.check_circle : Icons.info_outline,
              color: isCorrect ? Colors.green : Colors.orange,
            ),
            const SizedBox(width: 8),
            Text(isCorrect ? 'Good Choice!' : 'Interesting...'),
          ],
        ),
        content: Text(feedback),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _nextNode();
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showComprehensionFeedback(ComprehensionNode node, int selectedIndex, bool isCorrect) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              isCorrect ? Icons.check_circle : Icons.cancel,
              color: isCorrect ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            Text(isCorrect ? 'Correct!' : 'Not Quite'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isCorrect) ...[
              Text('The correct answer was:', style: AppTypography.labelMedium),
              const SizedBox(height: 4),
              Text(
                node.options[node.correctIndex],
                style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
            ],
            Text(node.explanation),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _nextNode();
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _saveProgress() {
    final actions = ref.read(userProfileActionsProvider);
    final progress = StoryProgress(
      storyId: widget.story.id,
      currentChapterIndex: _currentChapterIndex,
      currentNodeIndex: _currentNodeIndex,
      choicesMade: _choicesMade,
      score: _correctAnswers,
    );
    // Save to user profile
    actions.updateStoryProgress(widget.story.id, progress);
  }

  void _completeStory() {
    final actions = ref.read(userProfileActionsProvider);
    
    // Award XP
    actions.awardXp(widget.story.xpReward, source: 'story_complete');
    
    // Mark story as complete
    final progress = StoryProgress(
      storyId: widget.story.id,
      isCompleted: true,
      completedDate: DateTime.now(),
      currentChapterIndex: _currentChapterIndex,
      currentNodeIndex: _currentNodeIndex,
      choicesMade: _choicesMade,
      score: _correctAnswers,
    );
    actions.updateStoryProgress(widget.story.id, progress);
    actions.addCompletedStory(widget.story.id);

    // Show completion dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.celebration, color: Colors.amber),
            SizedBox(width: 8),
            Text('Story Complete!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('You completed "${widget.story.title}"!'),
            const SizedBox(height: 16),
            Text(
              '+${widget.story.xpReward} XP',
              style: AppTypography.headlineMedium.copyWith(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close story screen
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final node = _currentNode;

    if (node == null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.story.title)),
        body: const Center(child: Text('Story complete!')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.story.title),
        actions: [
          // Progress indicator
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '${_currentChapterIndex + 1}/${widget.story.chapters.length}',
                style: AppTypography.labelMedium,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Chapter title (if present)
          if (_currentChapter.title != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Text(
                _currentChapter.title!,
                style: AppTypography.titleMedium,
                textAlign: TextAlign.center,
              ),
            ),

          // Story content
          Expanded(
            child: _buildNodeContent(node),
          ),

          // Next button (for non-interactive nodes)
          if (node.type != StoryNodeType.choice && node.type != StoryNodeType.comprehension)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _nextNode,
                    child: Text(_isLastNode && _isLastChapter ? 'Finish' : 'Continue'),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNodeContent(StoryNode node) {
    switch (node.type) {
      case StoryNodeType.dialogue:
        return _buildDialogue(node as DialogueNode);
      case StoryNodeType.narration:
        return _buildNarration(node as NarrationNode);
      case StoryNodeType.choice:
        return _buildChoice(node as ChoiceNode);
      case StoryNodeType.comprehension:
        return _buildComprehension(node as ComprehensionNode);
      case StoryNodeType.image:
        return _buildImage(node as ImageNode);
    }
  }

  Widget _buildDialogue(DialogueNode node) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Character avatar + name
          Row(
            children: [
              if (node.characterImage != null)
                Text(node.characterImage!, style: const TextStyle(fontSize: 48)),
              const SizedBox(width: 16),
              Text(
                node.character,
                style: AppTypography.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Dialogue bubble
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
              ),
            ),
            child: Text(
              node.text,
              style: AppTypography.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNarration(NarrationNode node) {
    Color? bgColor;
    IconData? icon;

    switch (node.style) {
      case 'emphasis':
        bgColor = Colors.blue.withOpacity(0.1);
        icon = Icons.auto_awesome;
        break;
      case 'warning':
        bgColor = Colors.orange.withOpacity(0.1);
        icon = Icons.warning_amber;
        break;
      case 'success':
        bgColor = Colors.green.withOpacity(0.1);
        icon = Icons.celebration;
        break;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: bgColor ?? Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 32),
                const SizedBox(width: 16),
              ],
              Expanded(
                child: Text(
                  node.text,
                  style: AppTypography.bodyLarge.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChoice(ChoiceNode node) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            node.prompt,
            style: AppTypography.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ...node.choices.map((choice) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ElevatedButton(
              onPressed: () => _handleChoice(node, choice),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                choice.text,
                style: AppTypography.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildComprehension(ComprehensionNode node) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.quiz, size: 48, color: Colors.blue),
          const SizedBox(height: 16),
          Text(
            'Comprehension Check',
            style: AppTypography.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            node.question,
            style: AppTypography.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ...List.generate(node.options.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: OutlinedButton(
                onPressed: () => _handleComprehension(node, index),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  node.options[index],
                  style: AppTypography.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildImage(ImageNode node) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              node.imageUrl,
              fit: BoxFit.cover,
            ),
          ),
          if (node.caption != null) ...[
            const SizedBox(height: 16),
            Text(
              node.caption!,
              style: AppTypography.bodyMedium.copyWith(
                fontStyle: FontStyle.italic,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
```

---

## Integration

### 1. Add Stories to Learn Screen

Modify `lib/screens/learn_screen.dart` to include a Stories section:

```dart
// Add after learning paths section
SliverToBoxAdapter(
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('📖 Stories', style: AppTypography.headlineSmall),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StoryListScreen()),
              ),
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Show 2-3 featured/recommended stories
        _buildFeaturedStories(context, ref, profile),
      ],
    ),
  ),
),
```

### 2. Update UserProfile Provider

Add actions for story progress:

```dart
// Add to UserProfileActions
void updateStoryProgress(String storyId, StoryProgress progress) {
  final current = state.value;
  if (current == null) return;

  final updatedProgress = Map<String, StoryProgress>.from(current.storyProgress);
  updatedProgress[storyId] = progress;

  final updated = current.copyWith(
    storyProgress: updatedProgress,
    updatedAt: DateTime.now(),
  );

  state = AsyncValue.data(updated);
  _save(updated);
}

void addCompletedStory(String storyId) {
  final current = state.value;
  if (current == null) return;

  final updated = current.copyWith(
    completedStories: [...current.completedStories, storyId],
    updatedAt: DateTime.now(),
  );

  state = AsyncValue.data(updated);
  _save(updated);
}
```

### 3. Add Story Achievement

Add to `lib/models/learning.dart`:

```dart
Achievement(
  id: 'first_story',
  title: 'Storyteller',
  description: 'Complete your first story',
  emoji: '📖',
  category: AchievementCategory.learning,
  tier: AchievementTier.bronze,
),
Achievement(
  id: 'story_master',
  title: 'Story Master',
  description: 'Complete all stories',
  emoji: '📚',
  category: AchievementCategory.learning,
  tier: AchievementTier.platinum,
),
```

---

## Testing Checklist

- [ ] Story models serialize/deserialize correctly
- [ ] Story progress saves and loads
- [ ] Dialogue nodes display with character info
- [ ] Choice nodes branch correctly
- [ ] Comprehension questions show feedback
- [ ] XP awards on story completion
- [ ] Progress indicator shows current chapter
- [ ] Can resume incomplete stories
- [ ] All 5 stories are complete and functional
- [ ] Stories integrate into Learn screen
- [ ] Achievements unlock correctly

---

## Future Enhancements

1. **Audio Narration**: Add text-to-speech or voice acting for dialogue
2. **Animations**: Subtle character emotion animations
3. **Illustrations**: Custom artwork for characters and scenes
4. **Branching Endings**: Multiple story outcomes based on choices
5. **User-Generated Stories**: Community story submissions
6. **Story Analytics**: Track which choices users make most often
7. **Seasonal Stories**: Holiday or event-themed stories
8. **Multiplayer Stories**: Collaborative decision-making

---

## Summary

This implementation provides a complete Duolingo-style Stories mode with:

✅ **5 fully-written interactive stories** across 3 difficulty levels  
✅ **Complete data models** for stories, chapters, nodes, and progress  
✅ **Two full UI screens** (Story List + Story Player)  
✅ **Progress tracking** integrated with UserProfile  
✅ **XP rewards** and achievement system  
✅ **Branching narratives** with player choices  
✅ **Comprehension checks** embedded in story flow  
✅ **Save/resume** functionality for incomplete stories

The stories teach real aquarium concepts through engaging narratives, making learning immersive and memorable. Players learn by experiencing problems and solutions through relatable characters.

**Total estimated implementation time: 8-12 hours** (3-4 hours for models/data, 4-6 hours for UI, 1-2 hours for integration and testing)
