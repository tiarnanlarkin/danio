# 🐠 DIONYSUS — Danio Push Notification Sequence
**Author:** Dionysus (Humaniser sub-agent)  
**Brief:** 30-day sequence + re-engagement + special moments  
**Tone:** Warm, curious, proud — never guilty, never pressured  
**Psychology:** Validation · Discovery · Pride · Safety Net · Belonging

---

## DESIGN PRINCIPLES

1. **Care Continuity over Streaks** — we celebrate consistency, never punish gaps
2. **Discovery-first** — fish facts and "huh, really?" moments earn more opens than reminders
3. **Identity reinforcement** — users are *aquarists*, not app users
4. **Light touch after day 14** — if they're engaged, they don't need nudging; if they're not, we whisper not shout
5. **Never burn the channel** — a notification that doesn't get opened twice is a notification that gets turned off

---

## NOTIFICATION TYPES KEY
- `WELCOME` — onboarding message, sent once
- `CARE_REMINDER` — water change / feeding schedule nudge
- `DISCOVERY` — species fact, biology curiosity, "did you know"
- `MILESTONE` — streak, XP level, achievement unlock
- `SOCIAL_PROOF` — community stats, "aquarists like you" moments
- `IDENTITY` — who you're becoming as a fishkeeper
- `CONTENT` — new lesson, quiz, or collection item unlocked
- `RE_ENGAGEMENT` — sent after silence (3, 7, 14 days)
- `SUBSCRIPTION` — gentle upsell for free-tier users (Day 22+)
- `SPECIAL` — triggered by specific in-app events

---

## PART 1 — DAYS 1–7: HABIT FORMATION

---

### DAY 1 — Welcome

**Notification 1A — Welcome**
```
TYPE: WELCOME
TITLE: Welcome to Danio 🐠
BODY:  Your fishkeeping journey starts here. Let's meet your fish.
```

**Notification 1B — First Care Reminder (sent ~6 hours after signup)**
```
TYPE: CARE_REMINDER
TITLE: Time to check in on your tank
BODY:  A quick look goes a long way. Tap to log today's care.
```

---

### DAY 2 — Discovery Hook

**Notification 2**
```
TYPE: DISCOVERY
TITLE: Your betta is watching you
BODY:  Bettas recognise their owners' faces. Yours probably knows you already.
```

---

### DAY 3 — Care Continuity

**Notification 3**
```
TYPE: CARE_REMINDER
TITLE: Water change day is coming up 💧
BODY:  You set a schedule — Danio's keeping it warm for you. Tap to check.
```

---

### DAY 4 — Validation

**Notification 4**
```
TYPE: IDENTITY
TITLE: You've checked in 3 days in a row
BODY:  That's the kind of consistency healthy fish are built on. Quietly impressive.
```

---

### DAY 5 — Discovery

**Notification 5**
```
TYPE: DISCOVERY
TITLE: Did you know? Fish sleep too
BODY:  Not like us — but they do rest. [Species name] has a whole routine.
```

*(Dynamic: replace [Species name] with user's logged fish)*

---

### DAY 6 — Light Reminder

**Notification 6**
```
TYPE: CARE_REMINDER
TITLE: How's the tank looking today?
BODY:  A 30-second check now saves a headache later. You've got this.
```

---

### DAY 7 — First Milestone

**Notification 7**
```
TYPE: MILESTONE
TITLE: One week of care 🎉
BODY:  Seven days with your fish. That's a real relationship forming.
```

---

## PART 2 — DAYS 8–14: DEEPENING

---

### DAY 8 — Species Fact

**Notification 8**
```
TYPE: DISCOVERY
TITLE: [Species name] trivia unlocked 🔓
BODY:  There's a wild fact about your fish waiting inside. Took us ages to find it.
```

---

### DAY 9 — Care Reminder (Soft)

**Notification 9**
```
TYPE: CARE_REMINDER
TITLE: Water parameters worth checking
BODY:  pH and temp swings are sneaky. A quick test keeps [fish name] thriving.
```

---

### DAY 10 — Pride Moment

**Notification 10**
```
TYPE: IDENTITY
TITLE: 10 days in. That's real care.
BODY:  Most new aquarists give up by now. You're still here. Your fish noticed.
```

---

### DAY 11 — Discovery (Behaviour)

**Notification 11**
```
TYPE: DISCOVERY
TITLE: Why does your fish do that? 🤔
BODY:  That zigzag swim has a name — and a reason. Tap to find out.
```

---

### DAY 12 — Community Belonging

**Notification 12**
```
TYPE: SOCIAL_PROOF
BODY:  Thousands of aquarists logged a care check this week. You're in good company.
TITLE: You're not doing this alone
```

---

### DAY 13 — Content Unlock

**Notification 13**
```
TYPE: CONTENT
TITLE: New lesson: Water chemistry basics
BODY:  The science behind a healthy tank — explained without the textbook.
```

---

### DAY 14 — Milestone (2 weeks)

**Notification 14**
```
TYPE: MILESTONE
TITLE: Two weeks of consistent care 💙
BODY:  Fourteen days. Your tank is stable. Your fish is thriving. That's you.
```

---

## PART 3 — DAYS 15–21: SOCIAL PROOF + ACHIEVEMENT

---

### DAY 15 — Achievement Unlock

**Notification 15**
```
TYPE: MILESTONE
TITLE: Badge unlocked: Steady Keeper 🏅
BODY:  Awarded to aquarists who show up consistently. You've earned it.
```

---

### DAY 16 — Social Proof

**Notification 16**
```
TYPE: SOCIAL_PROOF
TITLE: Other [species] keepers ask this
BODY:  The most common question from [species name] owners — and the answer inside.
```

---

### DAY 17 — Discovery (Wild Fact)

**Notification 17**
```
TYPE: DISCOVERY
TITLE: Where your fish came from 🌍
BODY:  [Species name] wild habitat is nothing like your tank. The journey is wild.
```

---

### DAY 18 — Care Reminder (Seasonal angle)

**Notification 18**
```
TYPE: CARE_REMINDER
TITLE: Temperature check 🌡️
BODY:  Seasonal room temps can affect tank water. Worth a glance today.
```

---

### DAY 19 — Content Discovery

**Notification 19**
```
TYPE: CONTENT
TITLE: Quiz: Do you know your fish?
BODY:  5 questions about [species name]. Most keepers get 3 right. Beat them?
```

---

### DAY 20 — Identity Reinforcement

**Notification 20**
```
TYPE: IDENTITY
TITLE: You think like an aquarist now
BODY:  Water chemistry, behaviour, schedules — this is second nature to you.
```

---

### DAY 21 — Three Week Milestone

**Notification 21**
```
TYPE: MILESTONE
TITLE: Three weeks. Genuinely impressive.
BODY:  Most tanks fail in the first month. Yours didn't. You made that happen.
```

---

## PART 4 — DAYS 22–30: LOYALTY + IDENTITY + SUBSCRIPTION

---

### DAY 22 — Loyalty Recognition

**Notification 22**
```
TYPE: IDENTITY
TITLE: You're one of our regulars 🐟
BODY:  22 days in. The fish community is better with people like you in it.
```

---

### DAY 23 — Subscription Nudge (Free Tier Only)

**Notification 23**
```
TYPE: SUBSCRIPTION
TITLE: Your fish collection is growing 🌿
BODY:  Unlock species profiles, care alerts + journal on Danio Pro. First month free.
```

---

### DAY 24 — Discovery (Rare Fact)

**Notification 24**
```
TYPE: DISCOVERY
TITLE: This one surprised us too
BODY:  [Species name] can sense changes in barometric pressure. Wild, right?
```

---

### DAY 25 — Care Reminder (Ownership Pride)

**Notification 25**
```
TYPE: CARE_REMINDER
TITLE: Water change day 💧
BODY:  You know the drill. Fresh water, happy fish. In and out in 10 minutes.
```

---

### DAY 26 — Social Proof (Collector Belonging)

**Notification 26**
```
TYPE: SOCIAL_PROOF
TITLE: [Species name] keepers are a rare breed
BODY:  Only 8% of Danio users keep [species name]. You're in a niche club.
```

---

### DAY 27 — Content (New Species to Explore)

**Notification 27**
```
TYPE: CONTENT
TITLE: Ever thought about a tank mate?
BODY:  We found 3 species that get along perfectly with [fish name]. Take a look.
```

---

### DAY 28 — Subscription Nudge (Value-Led)

**Notification 28**
```
TYPE: SUBSCRIPTION
TITLE: Your care history is getting rich 📊
BODY:  28 days of data. Pro unlocks full trends + export. Worth a look?
```

---

### DAY 29 — Identity (Aquarist Label)

**Notification 29**
```
TYPE: IDENTITY
TITLE: You're an aquarist. No question.
BODY:  29 days of care. You've earned the title. Your fish would agree.
```

---

### DAY 30 — The Landmark

**Notification 30**
```
TYPE: MILESTONE
TITLE: 30 days. You really did that. 🏆
BODY:  A whole month of consistent care. That's not luck — that's who you are now.
```

---

## PART 5 — RE-ENGAGEMENT SEQUENCE

*Sent only after verified silence (no app open, no care log). Tone: warm, curious — never guilt.*

---

### RE-ENGAGEMENT: 3 Days Silence

```
TYPE: RE_ENGAGEMENT
TITLE: Your tank is on your mind, we bet
BODY:  No pressure — just checking in. Tap to see how [fish name] is doing.
```

---

### RE-ENGAGEMENT: 7 Days Silence

```
TYPE: RE_ENGAGEMENT
TITLE: [Fish name] misses the attention 🐠
BODY:  A week away — totally fine. Come back when you're ready. We kept your data.
```

---

### RE-ENGAGEMENT: 14 Days Silence

```
TYPE: RE_ENGAGEMENT
TITLE: Still here when you're ready
BODY:  Life gets busy. Your fishkeeping journey picks up right where you left it.
```

*After 14-day silence: send nothing further. The channel is quiet until user returns.*

---

## PART 6 — SPECIAL MOMENT TRIGGERS

*Event-driven. Sent immediately when the trigger condition fires.*

---

### SPECIAL: First Fish Logged

```
TYPE: SPECIAL
TITLE: [Fish name] is officially in your care 🐟
BODY:  First fish logged. Your aquarium journey just became real.
```

---

### SPECIAL: 7-Day Care Streak

```
TYPE: SPECIAL
TITLE: 7-day care streak 🔥
BODY:  A whole week without missing a beat. Your fish are in excellent hands.
```

---

### SPECIAL: 14-Day Care Streak

```
TYPE: SPECIAL
TITLE: 14-day streak — that's dedication 💙
BODY:  Two weeks of showing up. Consistent care is the best care there is.
```

---

### SPECIAL: 30-Day Care Streak

```
TYPE: SPECIAL
TITLE: 30-day streak. Legendary. 🏆
BODY:  A full month of care. This is what great aquarism looks like.
```

---

### SPECIAL: Level Up (XP Milestone)

```
TYPE: SPECIAL
TITLE: Level up! You're now [Level Name] 🌊
BODY:  New rank. New knowledge unlocked. Your fish are in expert hands.
```

---

### SPECIAL: Water Change Overdue (Gentle)

```
TYPE: SPECIAL
TITLE: Water change is due 💧
BODY:  You set this schedule yourself — [fish name] will thank you for it.
```

---

### SPECIAL: First XP Earned

```
TYPE: SPECIAL
TITLE: First XP earned ⭐
BODY:  You're off the mark. Every care check, every quiz — it all builds up.
```

---

### SPECIAL: Collection Milestone (5 Fish Logged)

```
TYPE: SPECIAL
TITLE: Five fish in your collection 🐠🐠🐠🐠🐠
BODY:  That's a real aquarium. Most people stop at two. Not you.
```

---

## COPYWRITING NOTES FOR DEVELOPERS

### Dynamic Variables
- `[fish name]` — most recently active fish (or first fish if multiple)
- `[species name]` — scientific or common name of logged species
- `[Level Name]` — XP level title from gamification system
- All variables should have graceful fallbacks (e.g. "your fish" if none logged)

### Timing Recommendations
| Day Range | Send Window | Max Per Day |
|-----------|-------------|-------------|
| Days 1–7  | 08:00–10:00 local | 1 |
| Days 8–14 | 09:00–11:00 local | 1 |
| Days 15–21 | 10:00–12:00 local | 1 (every other day) |
| Days 22–30 | 10:00–12:00 local | 1 (every 2–3 days) |
| Re-engagement | 10:00–11:00 local | 1 per silence window |
| Special triggers | Immediate (capped 08:00–21:00) | 2 max/day |

### Copy Rules
1. Never use the word "streak" in a negative context
2. Never use words: "breaking," "lost," "missed," "failed," "warning," "urgent"
3. Always assume the user is a competent adult who knows their fish
4. Avoid exclamation marks on reminders — they read as panic
5. Emoji: max 1 per notification, end of title only
6. "Your fish" > "The fish" — ownership language builds attachment

---

*Dionysus, Humaniser sub-agent — Mount Olympus*  
*"The best notification is the one they're glad they opened."*
