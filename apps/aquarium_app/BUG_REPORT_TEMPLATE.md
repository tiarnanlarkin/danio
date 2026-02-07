# Bug Report Template
## Aquarium App - Issue Tracking

Use this template to report bugs and issues. Copy the template below and fill in all relevant sections.

---

## 🐛 Bug Report Template

```markdown
## Bug Report #[NUMBER]

### Title
[Clear, concise title describing the issue]

### Severity
- [ ] Critical - App crashes, data loss, cannot use core features
- [ ] High - Major feature broken, severe impact on user experience
- [ ] Medium - Feature partially broken, workaround exists
- [ ] Low - Cosmetic issue, minor inconvenience

### Priority
- [ ] P0 - Blocks release, fix immediately
- [ ] P1 - Must fix before release
- [ ] P2 - Should fix, but can defer if needed
- [ ] P3 - Nice to fix, low impact

### Affected Component
- [ ] Onboarding
- [ ] Learning System (Lessons/Quizzes)
- [ ] Gamification (XP/Streaks/Levels)
- [ ] Tank Management
- [ ] Social Features
- [ ] Shop
- [ ] Offline Functionality
- [ ] Settings
- [ ] UI/UX
- [ ] Performance
- [ ] Other: _______________

### Environment
- **Platform:** [iOS / Android]
- **OS Version:** [e.g., iOS 17.2, Android 14]
- **Device Model:** [e.g., iPhone 14, Samsung Galaxy S23]
- **App Version:** [e.g., 1.2.3]
- **Build Number:** [e.g., 42]
- **Network:** [WiFi / Cellular / Offline]

### Description
[Detailed description of the bug - what's happening vs. what should happen]

### Steps to Reproduce
1. [First step]
2. [Second step]
3. [Third step]
...

### Expected Behavior
[What should happen]

### Actual Behavior
[What actually happens]

### Reproduction Rate
- [ ] 100% - Happens every time
- [ ] 75% - Happens most of the time
- [ ] 50% - Happens about half the time
- [ ] 25% - Happens occasionally
- [ ] <10% - Rare, hard to reproduce

### Visual Evidence
[Screenshots, videos, GIFs - attach files or paste URLs]

### Logs/Error Messages
```
[Paste relevant logs, error messages, stack traces]
```

### User Impact
[How many users are affected? What's the workaround?]

### Regression Information
- [ ] This is a new bug (never worked)
- [ ] This is a regression (worked in version: ______)

### Related Issues
[Link to related bugs, feature requests, or discussions]

### Proposed Fix (Optional)
[If you have ideas on how to fix this]

### Additional Context
[Any other relevant information]

### Reported By
[Your name/username]

### Date Reported
[YYYY-MM-DD]

---

## Status Tracking

- [ ] **Reported** - Bug logged
- [ ] **Triaged** - Severity/priority assigned
- [ ] **Assigned** - Developer assigned
- [ ] **In Progress** - Work started
- [ ] **Fixed** - Code complete
- [ ] **Testing** - Fix being verified
- [ ] **Verified** - QA confirmed fix
- [ ] **Closed** - Released to production

### Root Cause (Filled by developer)
[Brief explanation of what caused the bug]

### Fix Description (Filled by developer)
[What was changed to fix the bug]

### Fix Version
[Version number where fix will be released]

### Verification Notes (Filled by QA)
[How the fix was verified, any edge cases tested]

```

---

## 📝 Example Bug Reports

### Example 1: Critical Bug

```markdown
## Bug Report #001

### Title
App crashes when completing first lesson after onboarding

### Severity
- [x] Critical - App crashes, data loss, cannot use core features

### Priority
- [x] P0 - Blocks release, fix immediately

### Affected Component
- [x] Learning System (Lessons/Quizzes)
- [x] Onboarding

### Environment
- **Platform:** iOS
- **OS Version:** iOS 17.2
- **Device Model:** iPhone 14
- **App Version:** 1.0.0
- **Build Number:** 25
- **Network:** WiFi

### Description
When a new user completes their first lesson immediately after onboarding, the app crashes on the celebration screen. The XP and gems are not saved, and the user has to complete the lesson again.

### Steps to Reproduce
1. Fresh install of the app
2. Complete onboarding (profile creation + placement test)
3. Start first recommended lesson
4. Complete lesson and quiz
5. Celebration animation starts
6. **App crashes**

### Expected Behavior
- Celebration animation completes
- XP (+10) and gems (+5) are saved
- User returns to home screen with updated stats
- Lesson marked as complete

### Actual Behavior
- Celebration animation starts
- App crashes to home screen (iOS springboard)
- On relaunch, XP/gems not saved
- Lesson still marked as incomplete
- User has to redo the lesson

### Reproduction Rate
- [x] 100% - Happens every time

### Visual Evidence
[Video showing crash: crash_first_lesson.mp4]

### Logs/Error Messages
```
Fatal Exception: NSInvalidArgumentException
Reason: *** setObjectForKey: object cannot be nil (key: userId)
Stack trace:
  UserProfileProvider.saveXP:51
  LessonScreen.onLessonComplete:342
  ...
```

### User Impact
All new users are affected. This is a showstopper for onboarding flow. 
Workaround: After crash, relaunch app and complete lesson again (works on second attempt).

### Regression Information
- [x] This is a new bug (never worked)

### Related Issues
None

### Proposed Fix
The crash occurs because user ID is null when saving XP. Profile creation saves to local storage but doesn't update provider state immediately. Need to ensure profile is fully loaded before allowing lesson completion.

Suggested fix: Add null check in saveXP() and delay lesson completion until profile is confirmed loaded.

### Additional Context
This only affects the FIRST lesson after onboarding. Subsequent lessons work fine because profile is loaded by then.

### Reported By
QA Team - Sarah

### Date Reported
2025-02-07

---

## Status Tracking

- [x] **Reported**
- [x] **Triaged** - P0/Critical
- [x] **Assigned** - Developer: John
- [x] **In Progress**
- [x] **Fixed**
- [x] **Testing**
- [x] **Verified**
- [ ] **Closed** - Will release in v1.0.1

### Root Cause
UserProfileProvider wasn't updating state synchronously after profile creation. When lesson completion tried to save XP, the user ID was still null, causing a crash.

### Fix Description
- Added await to profile creation save
- Ensured provider state updates before returning to navigation
- Added null safety checks in saveXP() as defensive measure
- Added unit tests for profile creation flow

### Fix Version
1.0.1 (Hotfix release)

### Verification Notes
- Tested fresh install → onboarding → first lesson on iOS 15, 16, 17
- Tested on Android 12, 13, 14
- 20 test runs, zero crashes
- XP/gems save correctly 100% of the time
- Verified with different lesson types and placement test results
```

---

### Example 2: Medium Priority Bug

```markdown
## Bug Report #015

### Title
Leaderboard shows incorrect rank after multiple users have same XP

### Severity
- [x] Medium - Feature partially broken, workaround exists

### Priority
- [x] P2 - Should fix, but can defer if needed

### Affected Component
- [x] Social Features

### Environment
- **Platform:** Android
- **OS Version:** Android 14
- **Device Model:** Pixel 7
- **App Version:** 1.1.0
- **Build Number:** 30
- **Network:** WiFi

### Description
When multiple users have the exact same XP amount, the leaderboard shows duplicate ranks. For example, if 3 users all have 500 XP, they all show as "#5" instead of #5, #6, #7.

### Steps to Reproduce
1. Have multiple users with same total XP (use test accounts)
2. Open leaderboard
3. View "All Time" tab
4. Observe users with same XP

### Expected Behavior
- Users with same XP should have same rank number
- Next user should skip ranks appropriately
- Example: User A: #5 (500 XP), User B: #5 (500 XP), User C: #7 (450 XP)

### Actual Behavior
- All users with same XP show same rank
- Next user also shows same rank (doesn't skip)
- Example: User A: #5 (500 XP), User B: #5 (500 XP), User C: #5 (450 XP)

### Reproduction Rate
- [x] 100% - Happens every time when XP matches

### Visual Evidence
[Screenshot: leaderboard_rank_bug.png]

### Logs/Error Messages
None

### User Impact
Low impact - affects display only, doesn't affect actual ranking or rewards. 
Estimated users affected: ~5% (cases where XP matches)
Workaround: Users can see their actual position by counting rows

### Regression Information
- [ ] This is a regression (worked in version: 1.0.0)

### Related Issues
None

### Proposed Fix
Update leaderboard ranking algorithm:
- Assign same rank to users with identical XP
- Skip ranks for next user (standard competition ranking: 1-2-2-4 not 1-2-2-3)

### Additional Context
This is standard sports ranking behavior. Should match user expectations.

### Reported By
User feedback - Alex

### Date Reported
2025-02-05

---

## Status Tracking

- [x] **Reported**
- [x] **Triaged** - P2/Medium
- [x] **Assigned** - Developer: Maria
- [x] **In Progress**
- [ ] **Fixed**
- [ ] **Testing**
- [ ] **Verified**
- [ ] **Closed**

### Root Cause
Ranking algorithm was using array index directly instead of implementing proper competition ranking.

### Fix Description
[To be filled]

### Fix Version
1.2.0

### Verification Notes
[To be filled]
```

---

### Example 3: Low Priority Bug

```markdown
## Bug Report #027

### Title
Tank name emoji appears too small on Android

### Severity
- [x] Low - Cosmetic issue, minor inconvenience

### Priority
- [x] P3 - Nice to fix, low impact

### Affected Component
- [x] Tank Management
- [x] UI/UX

### Environment
- **Platform:** Android
- **OS Version:** Android 13
- **Device Model:** Samsung Galaxy S22
- **App Version:** 1.1.2
- **Build Number:** 35
- **Network:** N/A

### Description
When users include emojis in their tank names (e.g., "🐠 Main Tank"), the emoji renders at a much smaller size than on iOS, making it hard to see.

### Steps to Reproduce
1. Create a tank
2. Name it with emoji prefix: "🐠 Living Room Tank"
3. Save tank
4. View tank in tank list
5. Compare with iOS device

### Expected Behavior
Emoji should render at same size as text (or slightly larger)

### Actual Behavior
Emoji renders ~50% smaller than text, looks squished

### Reproduction Rate
- [x] 100% - Happens every time on Android

### Visual Evidence
[Comparison screenshot: ios_android_emoji.png]

### Logs/Error Messages
None

### User Impact
Very low - purely cosmetic, doesn't affect functionality
Estimated users affected: ~30% (users who use emojis in names)
Workaround: Don't use emojis, or accept smaller size

### Regression Information
- [x] This is a new bug (never worked correctly on Android)

### Related Issues
Related to general Android emoji rendering

### Proposed Fix
Investigate Android emoji font rendering. May need to:
- Use a custom emoji font
- Adjust text style for emoji characters
- Use separate widget for emoji + text

### Additional Context
This is a known Android quirk. May not be worth fixing if solution is complex.

### Reported By
User feedback - Sam

### Date Reported
2025-02-01

---

## Status Tracking

- [x] **Reported**
- [x] **Triaged** - P3/Low
- [ ] **Assigned**
- [ ] **In Progress**
- [ ] **Fixed**
- [ ] **Testing**
- [ ] **Verified**
- [ ] **Closed**

### Root Cause
[To be filled]

### Fix Description
[To be filled]

### Fix Version
Backlog (TBD)

### Verification Notes
[To be filled]
```

---

## 🏷️ Bug Labels & Tags

Use these labels for organization and filtering:

### By Component
- `onboarding`
- `learning`
- `gamification`
- `tank-management`
- `social`
- `shop`
- `offline`
- `ui-ux`
- `performance`
- `security`

### By Platform
- `ios`
- `android`
- `cross-platform`

### By Type
- `crash`
- `data-loss`
- `regression`
- `enhancement`
- `documentation`

### By Status
- `needs-triage`
- `confirmed`
- `in-progress`
- `needs-verification`
- `verified`
- `wont-fix`
- `duplicate`

---

## 📊 Bug Metrics to Track

Monitor these metrics for release quality:

### Open Bug Metrics
- Total open bugs
- Critical/High priority bugs
- Bugs by component
- Bugs by age (< 1 week, 1-2 weeks, >2 weeks)

### Resolution Metrics
- Average time to triage
- Average time to fix
- Average time to verify
- Bugs fixed per release

### Quality Metrics
- Bugs found in testing vs. production
- Regression rate (% of bugs that are regressions)
- Reopen rate (% of bugs reopened after fix)
- Critical bugs per release

### Trend Metrics
- New bugs opened per week
- Bugs closed per week
- Bug backlog trend (growing or shrinking)

---

## 🎯 Bug Triage Guidelines

### Severity Assessment

**Critical**
- App crashes on launch
- Data loss or corruption
- Cannot complete onboarding
- Cannot complete core user flows (learn, create tank)
- Security vulnerabilities
- Payment issues (future)

**High**
- Major feature completely broken
- Severe performance degradation
- Incorrect data calculations (XP, gems, streaks)
- Cannot access important features
- Significant user experience issues

**Medium**
- Feature partially broken
- Workaround exists
- UI issues affecting usability
- Minor data inconsistencies
- Performance issues on some devices

**Low**
- Cosmetic issues
- Minor text/layout problems
- Edge case bugs with low impact
- Suggested improvements
- Nice-to-have enhancements

### Priority Guidelines

**P0 - Fix Immediately**
- Critical severity + high user impact
- Blocking release
- Actively breaking production
- Data loss issues

**P1 - Must Fix Before Release**
- High severity bugs
- Broken core features
- Affects large percentage of users
- No acceptable workaround

**P2 - Should Fix**
- Medium severity
- Affects some users
- Workaround exists
- Can defer to next release if needed

**P3 - Nice to Fix**
- Low severity
- Low user impact
- Enhancement requests
- Can be deferred indefinitely

---

## 🔄 Bug Lifecycle

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│  REPORTED → TRIAGED → ASSIGNED → IN PROGRESS → FIXED       │
│                ↓          ↓                                 │
│            DUPLICATE  WONT-FIX                              │
│                                                             │
│  FIXED → TESTING → VERIFIED → CLOSED                        │
│             ↓                                               │
│         REOPENED → IN PROGRESS                              │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### State Definitions

- **Reported**: Bug logged, awaiting triage
- **Triaged**: Severity/priority assigned, ready for assignment
- **Assigned**: Developer assigned, ready to work
- **In Progress**: Developer actively working on fix
- **Fixed**: Code complete, ready for QA
- **Testing**: QA verifying fix
- **Verified**: Fix confirmed working
- **Closed**: Released to production
- **Reopened**: Bug still exists, needs more work
- **Duplicate**: Same as another bug
- **Wont-Fix**: Decided not to fix

---

## 💡 Best Practices for Bug Reporting

### Do's ✅
- **Be specific** - Clear, detailed description
- **Include steps** - Exact reproduction steps
- **Add evidence** - Screenshots, videos, logs
- **Test environment** - Device, OS, app version
- **Expected vs actual** - What should happen vs. what does
- **User impact** - Who's affected, how many people
- **Search first** - Check if already reported

### Don'ts ❌
- **Don't be vague** - "App is slow" isn't helpful
- **Don't skip steps** - Every detail matters
- **Don't exaggerate** - Accurate severity helps prioritization
- **Don't report features** - Feature requests go elsewhere
- **Don't combine bugs** - One bug per report
- **Don't forget environment** - Platform/version is critical

### Writing Clear Bug Titles

**Good Titles** ✅
- "App crashes when completing first lesson after onboarding"
- "Leaderboard shows incorrect rank for users with same XP"
- "Tank name emoji renders too small on Android"
- "XP not saved when offline, lost after sync"

**Bad Titles** ❌
- "App doesn't work"
- "Bug in leaderboard"
- "Fix emoji"
- "Data loss"

---

## 🆘 Emergency Bug Procedure

For critical production issues:

1. **Immediately notify team** via emergency channel
2. **Create bug report** with `P0` priority
3. **Assess user impact** - how many users affected?
4. **Evaluate rollback** - can we revert to previous version?
5. **Hotfix or rollback** - decide quickly
6. **Communicate** - notify users if necessary
7. **Post-mortem** - after resolution, analyze what happened

### Hotfix Criteria
- Critical severity (crashes, data loss)
- Affecting >10% of users
- No acceptable workaround
- Can be fixed quickly (<4 hours)

### Rollback Criteria
- Cannot fix quickly
- Fix might introduce more bugs
- User impact is severe and growing
- Previous version was stable

---

*Last Updated: 2025-02-07*
*Version: 1.0*
