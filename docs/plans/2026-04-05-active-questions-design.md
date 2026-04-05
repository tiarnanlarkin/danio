# Active Questions for Practice Sessions

**Date:** 2026-04-05
**Status:** Approved

## Problem

The current practice session uses a passive self-assessment model: users see a concept name and press "Forgot" or "Remembered." There's no actual challenge — users can lie to themselves, engagement is low, and every card looks the same. This undermines the spaced repetition system's effectiveness.

## Solution

Replace self-assessment with **active questions** — multiple choice and matching pairs — generated from existing lesson content. The system prioritises hand-written quiz questions, falls back to auto-generated MC from key points, and periodically presents matching pairs for variety.

## Question Resolution

A `QuestionResolver` service resolves each `ReviewCard` to a `ResolvedQuestion` at session start:

1. **Quiz match** — If the card's lesson has `QuizQuestion` objects, reuse one. Rotate through questions across reviews of the same concept.
2. **Key point MC fallback** — Generate MC from `keyPoint` sections: the fact becomes the correct answer, 3 distractors come from key points in sibling lessons within the same path.
3. **Matching pairs** — Every ~5th card becomes a matching question. Group 3-4 related concepts from the same learning path into left/right pairs (concept name → key fact).

Resolution is pure logic in `lib/services/question_resolver.dart` with no UI dependencies.

## Data Model

```
ResolvedQuestion (abstract)
├── card: ReviewCard
│
├── MultipleChoiceQuestion
│   ├── questionText: String
│   ├── options: List<String> (4 items)
│   ├── correctIndex: int
│   └── explanation: String?
│
└── MatchingPairsQuestion
    ├── cards: List<ReviewCard> (3-4 grouped cards)
    └── pairs: List<MatchPair> (left ↔ right)
        ├── left: String (concept/term)
        └── right: String (definition/fact)
```

## Session UI Changes

### Multiple Choice Cards
- Question text shown prominently (replaces "Review this concept:")
- 4 tappable option buttons (replaces Forgot/Remembered binary)
- Tap → instant colour feedback (green correct, red wrong)
- Explanation text appears after answering
- "Next Card" button to advance

### Matching Pairs Cards
- Left column: 3-4 concept names (shuffled)
- Right column: 3-4 facts/definitions (shuffled independently)
- Tap left item, then tap right match
- Matched pairs lock in green; wrong matches flash red
- Card completes when all pairs matched
- Scored proportionally (e.g. 3/4 correct = 75% credit)

## Scoring

- MC correct → +0.2 strength, full XP (same as current "Remembered")
- MC wrong → -0.3 strength, partial XP (same as current "Forgot")
- Matching → proportional: each correct pair contributes equally to the strength adjustment

## File Changes

**New:**
- `lib/models/resolved_question.dart` — Question data models
- `lib/services/question_resolver.dart` — Resolution logic
- `lib/screens/spaced_repetition_practice/widgets/mc_card_widget.dart` — MC UI
- `lib/screens/spaced_repetition_practice/widgets/matching_card_widget.dart` — Matching pairs UI

**Modified:**
- `lib/screens/spaced_repetition_practice/review_session_screen.dart` — Use resolved questions
- `lib/providers/spaced_repetition_provider.dart` — Add question resolution to session start

## Reusable Infrastructure
- `QuizQuestion` model in `lib/models/learning.dart` — existing MC questions with options/correctIndex/explanation
- `LessonSection` with `keyPoint` type — factual content for MC generation
- `LearningPath` grouping — sibling lessons provide cross-concept distractors
- `ReviewCard.afterReview()` — existing strength/interval calculation
- `AppButton`, `AppRadius`, `AppTypography` — design system tokens
- `conceptDisplayName()` in `lib/utils/concept_display_names.dart` — human-readable concept names
