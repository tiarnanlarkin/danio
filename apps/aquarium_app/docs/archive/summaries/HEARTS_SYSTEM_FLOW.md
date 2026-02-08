# Hearts System - Flow Diagram

## User Journey Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    USER STARTS QUIZ                         │
│                    (5 Hearts Available)                     │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ▼
         ┌────────────────┐
         │  Answer Question│
         └────┬───────┬────┘
              │       │
        CORRECT│     │ WRONG
              │       │
              ▼       ▼
        ┌─────────┐ ┌──────────────┐
        │ ✓ Keep  │ │ ✗ Lose 1 ❤️  │
        │   Hearts│ │              │
        └────┬────┘ └──────┬───────┘
             │             │
             │             ▼
             │      ┌──────────────┐
             │      │ Hearts > 0?  │
             │      └──┬────────┬──┘
             │         │ YES    │ NO
             │         │        │
             │         ▼        ▼
             │    ┌────────┐ ┌─────────────────┐
             │    │Continue│ │ Navigate to     │
             │    │ Quiz   │ │ Practice Screen │
             │    └────────┘ └─────────────────┘
             │         │              │
             └─────────┘              │
                                      ▼
                            ┌──────────────────┐
                            │  Practice Mode   │
                            │  (Unlimited ❤️)  │
                            └────────┬─────────┘
                                     │
                           Complete Practice
                                     │
                                     ▼
                            ┌──────────────────┐
                            │  Earn 1 ❤️       │
                            │  Earn 5 XP       │
                            └────────┬─────────┘
                                     │
                                     ▼
                            ┌──────────────────┐
                            │ Return to Learn  │
                            │ (Hearts: 1/5)    │
                            └──────────────────┘
```

---

## Hearts Refill System

```
┌────────────────────────────────────────────────────────────┐
│                  HEART REFILL TIMELINE                     │
└────────────────────────────────────────────────────────────┘

Time:    0h      5h      10h     15h     20h     25h
Hearts:  0  ──>  1  ──>  2  ──>  3  ──>  4  ──>  5 (MAX)
         
         ❤️❤️❤️❤️❤️  Lost all hearts
         │
         │ (5 hours pass)
         ▼
         ❤️❤️❤️❤️❤️  +1 heart refilled
         │
         │ (5 hours pass)
         ▼
         ❤️❤️❤️❤️❤️  +1 heart refilled
         │
         ... continues until 5 hearts reached
```

---

## State Diagram

```
┌──────────────────────────────────────────────────────────┐
│                    HEARTS STATES                         │
└──────────────────────────────────────────────────────────┘

┌───────────────┐
│  Full Hearts  │  ❤️❤️❤️❤️❤️ (5/5)
│  (5/5)        │  • Can take quizzes
└───────┬───────┘  • Green border
        │
        │ Wrong answer
        ▼
┌───────────────┐
│  High Hearts  │  ❤️❤️❤️❤️🖤 (4/5)
│  (3-4)        │  • Can take quizzes
└───────┬───────┘  • Normal state
        │
        │ More wrong answers
        ▼
┌───────────────┐
│  Low Hearts   │  ❤️❤️🖤🖤🖤 (2/5)
│  (1-2)        │  • Can take quizzes
└───────┬───────┘  • Yellow/warning border
        │
        │ More wrong answers
        ▼
┌───────────────┐
│  No Hearts    │  🖤🖤🖤🖤🖤 (0/5)
│  (0)          │  • Cannot take quizzes
└───────┬───┬───┘  • Red border
        │   │       • Must practice or wait
        │   │
        │   └──────────────┐
        │                  │
        ▼                  ▼
  ┌──────────┐      ┌──────────────┐
  │  WAIT    │      │  PRACTICE    │
  │ (5 hours)│      │    MODE      │
  │ +1 ❤️    │      │   +1 ❤️      │
  └──────────┘      └──────────────┘
```

---

## Settings Flow

```
┌────────────────────────────────────────────────────┐
│              UNLIMITED HEARTS TOGGLE               │
└────────────────────────────────────────────────────┘

    ┌────────────────┐
    │   Settings     │
    └───────┬────────┘
            │
            ▼
    ┌───────────────────┐
    │ Unlimited Hearts? │
    └────┬──────────┬───┘
         │          │
      OFF│          │ON
         │          │
         ▼          ▼
┌────────────┐  ┌────────────────┐
│  Standard  │  │   Unlimited    │
│   Mode     │  │     Mode       │
├────────────┤  ├────────────────┤
│ • Max 5 ❤️ │  │ • Always ∞ ❤️  │
│ • Lose on  │  │ • Never lose   │
│   wrong    │  │   hearts       │
│ • Refill   │  │ • No practice  │
│   5h/heart │  │   required     │
└────────────┘  └────────────────┘
```

---

## Component Interaction

```
┌─────────────────────────────────────────────────────────┐
│              HEARTS SYSTEM ARCHITECTURE                 │
└─────────────────────────────────────────────────────────┘

┌─────────────────┐
│  UserProfile    │  Model - stores hearts data
│  Model          │  • currentHearts: int
└────────┬────────┘  • lastHeartLost: DateTime?
         │            • unlimitedHeartsEnabled: bool
         │
         ▼
┌─────────────────┐
│ UserProfile     │  Provider - manages hearts logic
│ Provider        │  • loseHeart()
└────────┬────────┘  • refillHearts()
         │            • earnHeartFromPractice()
         │            • toggleUnlimitedHearts()
         │
         ├──────────────────────┬────────────────┐
         │                      │                │
         ▼                      ▼                ▼
┌──────────────┐    ┌─────────────────┐  ┌──────────────┐
│ HeartsDisplay│    │  LessonScreen   │  │  Settings    │
│   Widget     │    │  (Quiz Logic)   │  │   Screen     │
└──────────────┘    └─────────────────┘  └──────────────┘
         │                      │                │
         │                      │                │
         │                      ▼                │
         │          ┌──────────────────┐         │
         │          │ PracticeRequired │         │
         │          │     Screen       │         │
         │          └────────┬─────────┘         │
         │                   │                   │
         │                   ▼                   │
         │          ┌──────────────────┐         │
         │          │  PracticeMode    │         │
         │          │     Screen       │         │
         │          └──────────────────┘         │
         │                                        │
         └────────────────────────────────────────┘
                    Updates hearts state
```

---

## XP Rewards Comparison

```
┌────────────────────────────────────────────────┐
│               XP REWARD SYSTEM                 │
└────────────────────────────────────────────────┘

Regular Quiz (with hearts):
    ┌─────────────────┐
    │  Complete Quiz  │
    │  Base: 10 XP    │
    │  Bonus: varies  │
    │  Total: 10-35XP │
    └─────────────────┘
           ❤️ Risk: Lose hearts on wrong answers

Practice Mode (no hearts risk):
    ┌─────────────────┐
    │ Complete Practice│
    │  Base: 5 XP     │
    │  Bonus: 1 ❤️    │
    │  Total: 5 XP    │
    └─────────────────┘
           ✓ Safe: Unlimited attempts, earn hearts

Trade-off: Higher XP with risk vs. Lower XP with safety
```

---

## Key Metrics

| Metric | Value | Notes |
|--------|-------|-------|
| Max Hearts | 5 | Starting and maximum amount |
| Refill Rate | 1 heart / 5 hours | Automatic time-based refill |
| Heart Cost | 1 per wrong answer | Standard quiz mode only |
| Practice Reward | 1 heart | Per completed session |
| Regular Quiz XP | 10 (base) | May include bonuses |
| Practice Mode XP | 5 (fixed) | Reduced but guaranteed |
| Refill Time (full) | 25 hours | 0 → 5 hearts |

---

## User Psychology

```
┌────────────────────────────────────────────────────────┐
│           HEARTS SYSTEM BEHAVIORAL DESIGN              │
└────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ 1. SCARCITY PRINCIPLE                                   │
│    Limited hearts → Users value each attempt more       │
│    → Read lessons carefully before quizzing             │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ 2. LOSS AVERSION                                        │
│    Seeing hearts decrease → Emotional feedback          │
│    → Motivates careful consideration                    │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ 3. SAFE PRACTICE ZONE                                   │
│    Practice mode → No penalty for mistakes              │
│    → Encourages learning over performance anxiety       │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ 4. RECOVERY MECHANISM                                   │
│    Multiple paths to regain hearts (practice + time)    │
│    → Users never feel permanently blocked               │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ 5. PROGRESSION BALANCE                                  │
│    Standard: Higher XP + Risk                           │
│    Practice: Lower XP + Safe                            │
│    → Users choose their learning style                  │
└─────────────────────────────────────────────────────────┘
```

---

## Edge Cases Handled

✅ **Hearts at 0 mid-quiz**
   → Navigate to Practice Required screen immediately

✅ **Unlimited hearts enabled**
   → Hearts display hidden, no deductions, no blocks

✅ **Time-based refills**
   → Calculated on display render and can span multiple days

✅ **Hearts already at max (5)**
   → No refill timer shown, no further refills

✅ **Practice completed with full hearts**
   → No heart awarded (already at max)

✅ **Settings toggle during quiz**
   → Unlimited mode takes effect immediately

✅ **Multiple practice sessions**
   → Each session awards 1 heart (up to max 5)

✅ **App closed during refill period**
   → Hearts refill based on elapsed time when app reopens

---

**Reference:** See HEARTS_SYSTEM_IMPLEMENTATION.md for full code implementation.
