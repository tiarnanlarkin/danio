# Test Scenarios
## Aquarium App - Comprehensive Test Scripts

This document provides detailed step-by-step test scenarios for all major features, including happy paths, edge cases, and error recovery.

---

## 📋 Table of Contents

1. [First-Time User Flow Tests](#1-first-time-user-flow-tests)
2. [Daily Active User Flow Tests](#2-daily-active-user-flow-tests)
3. [Tank Management Flow Tests](#3-tank-management-flow-tests)
4. [Social Flow Tests](#4-social-flow-tests)
5. [Shop & Progression Flow Tests](#5-shop--progression-flow-tests)
6. [Edge Cases & Error Scenarios](#6-edge-cases--error-scenarios)
7. [Offline Behavior Tests](#7-offline-behavior-tests)
8. [Performance & Load Tests](#8-performance--load-tests)

---

## 1. First-Time User Flow Tests

### Test 1.1: Complete Onboarding (Happy Path)

**Objective:** Verify that a new user can successfully complete onboarding.

**Prerequisites:**
- Fresh app installation
- No existing user data

**Steps:**

1. Launch app for the first time
   - **Expected:** Splash screen appears with app logo
   - **Expected:** After 2-3 seconds, transitions to onboarding screen

2. View onboarding introduction
   - **Expected:** Welcome screen displayed
   - **Expected:** Can swipe through introduction slides
   - **Expected:** "Get Started" button visible

3. Tap "Get Started"
   - **Expected:** Navigate to profile creation screen

4. Enter profile information:
   - Name: "Test User" (optional, can be left blank)
   - Experience level: Select "Beginner"
   - Tank type: Select "Freshwater"
   - Goals: Select "Happy, healthy fish" and "Relaxation & zen"
   
   - **Expected:** All selections are highlighted
   - **Expected:** "Continue" button becomes enabled

5. Tap "Continue"
   - **Expected:** Navigate to placement test prompt

6. Choose "Take Placement Test"
   - **Expected:** Placement test screen loads
   - **Expected:** First question displayed

7. Complete placement test:
   - Answer all 10-15 questions
   - Select various correct/incorrect answers
   
   - **Expected:** Progress indicator updates (e.g., "Question 3 of 10")
   - **Expected:** Can navigate forward through questions
   - **Expected:** Submit button appears on last question

8. Submit placement test
   - **Expected:** Results screen displayed
   - **Expected:** Score percentage shown (e.g., "You scored 60%")
   - **Expected:** Placement level indicated (e.g., "Intermediate")
   - **Expected:** Recommended learning path shown

9. Tap "Start Learning"
   - **Expected:** Navigate to first recommended lesson

10. Complete first lesson:
    - Read through lesson content
    - Answer quiz questions
    - Complete lesson
    
    - **Expected:** Lesson content displays correctly
    - **Expected:** Images and formatting render properly
    - **Expected:** Quiz questions appear inline
    - **Expected:** Immediate feedback on answers
    - **Expected:** XP earned animation (typically +10 XP)
    - **Expected:** Gems earned animation (+5 gems)
    - **Expected:** Celebration animation

11. View home screen
    - **Expected:** Profile stats displayed
    - **Expected:** XP: 10, Gems: 5
    - **Expected:** Level: Beginner
    - **Expected:** Daily goal progress: 10/50 XP

**Pass Criteria:**
- ✅ User successfully completes entire onboarding flow
- ✅ Profile is created with selected preferences
- ✅ Placement test results are saved
- ✅ First lesson completion earns XP and gems
- ✅ User lands on home screen with correct stats

---

### Test 1.2: Skip Placement Test

**Objective:** Verify that users can skip placement test and still proceed.

**Prerequisites:**
- Fresh app installation
- Complete profile creation

**Steps:**

1. Reach placement test prompt
2. Tap "Skip"
   - **Expected:** Confirmation dialog: "Start at beginner level?"
3. Confirm skip
   - **Expected:** Navigate directly to lesson selection
   - **Expected:** Beginner lessons recommended
   - **Expected:** Placement status marked as skipped

**Pass Criteria:**
- ✅ User can skip placement test
- ✅ Defaults to beginner level
- ✅ Can still complete lessons

---

### Test 1.3: Incomplete Onboarding Recovery

**Objective:** Verify that incomplete onboarding can be resumed.

**Prerequisites:**
- Start onboarding process

**Steps:**

1. Complete profile creation
2. Reach placement test screen
3. Close app (force quit)
4. Relaunch app
   - **Expected:** App returns to placement test prompt
   - **Expected:** Profile information retained
   - **Expected:** Can continue or skip test

**Pass Criteria:**
- ✅ Onboarding state is preserved
- ✅ User can resume from where they left off
- ✅ No data loss

---

### Test 1.4: Empty Name Validation

**Objective:** Verify that name field is truly optional.

**Prerequisites:**
- Fresh app installation

**Steps:**

1. Reach profile creation screen
2. Leave name field blank
3. Select experience level, tank type, goals
4. Tap "Continue"
   - **Expected:** Allowed to proceed
   - **Expected:** Profile uses default/generic name or null

**Pass Criteria:**
- ✅ Name is optional
- ✅ App handles null/empty name gracefully
- ✅ UI displays appropriately without name

---

## 2. Daily Active User Flow Tests

### Test 2.1: Daily Goal Completion (Happy Path)

**Objective:** Verify daily goal tracking and completion rewards.

**Prerequisites:**
- User account with profile
- Daily goal set to 50 XP
- No XP earned today

**Steps:**

1. Launch app
   - **Expected:** Home screen shows 0/50 XP today
   - **Expected:** Daily goal progress bar at 0%

2. Complete first lesson (10 XP)
   - **Expected:** Progress updates to 10/50 XP (20%)
   - **Expected:** Progress bar animates

3. Complete second lesson (10 XP)
   - **Expected:** Progress updates to 20/50 XP (40%)

4. Complete three more lessons (30 XP total)
   - **Expected:** Progress updates to 50/50 XP (100%)
   - **Expected:** Daily goal completion animation triggers
   - **Expected:** Bonus gems awarded (+5 gems)
   - **Expected:** Celebration message: "Daily goal complete!"

5. Check profile stats
   - **Expected:** Daily goal marked as complete
   - **Expected:** Streak updated (if applicable)
   - **Expected:** Total XP increased by 50

**Pass Criteria:**
- ✅ Daily goal tracks XP accurately
- ✅ Completion triggers rewards
- ✅ Stats update correctly
- ✅ Visual feedback is clear

---

### Test 2.2: Streak Maintenance

**Objective:** Verify streak tracking and continuation.

**Prerequisites:**
- User with 5-day active streak
- Last activity was yesterday
- Completed XP yesterday

**Steps:**

1. Launch app today
   - **Expected:** Streak shows "5 days 🔥"
   - **Expected:** Streak status: "At risk - Learn today to maintain streak"

2. Complete a lesson (10 XP)
   - **Expected:** Streak updates to "6 days 🔥"
   - **Expected:** Celebration for streak extension
   - **Expected:** Streak status: "Active - Great work!"

3. Check profile
   - **Expected:** Current streak: 6
   - **Expected:** Longest streak: 6 (or higher if previously longer)

**Pass Criteria:**
- ✅ Streak increments correctly
- ✅ Warnings appear when at risk
- ✅ Celebrations trigger on extension
- ✅ Stats update accurately

---

### Test 2.3: Streak Break Recovery

**Objective:** Verify streak breaks and reset correctly.

**Prerequisites:**
- User with 10-day streak
- No activity for 2+ days

**Steps:**

1. Launch app after 2 days of inactivity
   - **Expected:** Streak reset to 0
   - **Expected:** Message: "Your streak ended at 10 days"
   - **Expected:** Longest streak preserved: 10 days

2. Complete a lesson
   - **Expected:** New streak starts at 1 day
   - **Expected:** Longest streak remains 10 days

**Pass Criteria:**
- ✅ Streak resets after missed day
- ✅ Longest streak is preserved
- ✅ User can start new streak
- ✅ Clear messaging about streak loss

---

### Test 2.4: Streak Freeze Usage

**Objective:** Verify streak freeze protects against missed days.

**Prerequisites:**
- User with active streak
- Streak freeze available (weekly free)

**Steps:**

1. Check streak freeze status
   - **Expected:** Indicator shows "🧊 Freeze available"

2. Skip a day (do not complete any lessons)
3. Launch app the next day
   - **Expected:** Streak is maintained
   - **Expected:** Streak freeze consumed
   - **Expected:** Message: "Streak freeze protected your streak!"
   - **Expected:** Freeze indicator shows "Used this week"

4. Skip another day
   - **Expected:** Streak breaks (no more freezes)

**Pass Criteria:**
- ✅ Streak freeze protects for 1 missed day
- ✅ Freeze is consumed on use
- ✅ Only 1 free freeze per week
- ✅ Clear indication of freeze status

---

### Test 2.5: Leaderboard Display

**Objective:** Verify leaderboard accurately shows rankings.

**Prerequisites:**
- User account with some XP
- Mock friends with various XP levels

**Steps:**

1. Navigate to Leaderboard tab
   - **Expected:** Leaderboard screen loads

2. View "This Week" tab
   - **Expected:** Users ranked by weekly XP
   - **Expected:** Your rank highlighted
   - **Expected:** Top 3 have special indicators (🥇🥈🥉)

3. View "All Time" tab
   - **Expected:** Users ranked by total XP
   - **Expected:** Rankings update correctly

4. View "Friends Only" tab
   - **Expected:** Only friends displayed
   - **Expected:** Accurate ranking among friends

**Pass Criteria:**
- ✅ Rankings are accurate
- ✅ All tabs function correctly
- ✅ User's rank is highlighted
- ✅ Stats match actual values

---

## 3. Tank Management Flow Tests

### Test 3.1: Create Tank (Happy Path)

**Objective:** Verify tank creation with valid data.

**Prerequisites:**
- User account active

**Steps:**

1. Navigate to Home → Tank section
2. Tap "Create Tank" or "+"
   - **Expected:** Tank creation form appears

3. Enter tank details:
   - Name: "Living Room 20G"
   - Type: Freshwater
   - Volume: 20
   - Unit: Gallons
   - Setup date: [Today's date]

4. Tap "Create"
   - **Expected:** Tank created successfully
   - **Expected:** Success message displayed
   - **Expected:** XP awarded (+15 XP)
   - **Expected:** Navigate to tank detail screen

5. Verify tank appears in tank list
   - **Expected:** Tank listed on home screen
   - **Expected:** All details correct

**Pass Criteria:**
- ✅ Tank creation succeeds with valid data
- ✅ XP reward granted
- ✅ Tank appears in lists
- ✅ All fields saved correctly

---

### Test 3.2: Add Livestock to Tank

**Objective:** Verify adding livestock to an existing tank.

**Prerequisites:**
- Tank already created

**Steps:**

1. Open tank detail screen
2. Navigate to Livestock tab
3. Tap "Add Livestock"
   - **Expected:** Species browser opens

4. Search for "Neon Tetra"
   - **Expected:** Search results show Neon Tetra
   - **Expected:** Species info displayed

5. Select Neon Tetra
6. Enter details:
   - Quantity: 10
   - Date added: [Today]
   - Custom name: "Neon School"
   - Notes: "First fish!"

7. Tap "Add"
   - **Expected:** Livestock added successfully
   - **Expected:** Appears in livestock list
   - **Expected:** Stocking level updated
   - **Expected:** Compatibility check runs

8. Verify stocking calculation
   - **Expected:** Stocking percentage increases
   - **Expected:** Warning if overstocked

**Pass Criteria:**
- ✅ Livestock adds successfully
- ✅ Details saved correctly
- ✅ Stocking level calculates accurately
- ✅ Compatibility warnings appear when needed

---

### Test 3.3: Log Water Test Results

**Objective:** Verify water parameter logging.

**Prerequisites:**
- Tank created

**Steps:**

1. Open tank → Logs tab
2. Tap "Add Log" → "Water Test"
   - **Expected:** Water test form appears

3. Enter parameters:
   - Date/Time: [Now]
   - Temperature: 76°F
   - pH: 7.0
   - Ammonia: 0 ppm
   - Nitrite: 0 ppm
   - Nitrate: 10 ppm
   - Notes: "All parameters good"

4. Tap "Save"
   - **Expected:** Log saved successfully
   - **Expected:** Appears in logs list
   - **Expected:** Latest values shown in tank overview

5. Navigate to Charts tab
   - **Expected:** New data point added to graphs
   - **Expected:** Trend lines update

**Pass Criteria:**
- ✅ Water test logs successfully
- ✅ All parameters saved
- ✅ Data appears in charts
- ✅ Trends calculate correctly

---

### Test 3.4: Complete Maintenance Task

**Objective:** Verify maintenance task completion and scheduling.

**Prerequisites:**
- Tank with scheduled tasks

**Steps:**

1. Open tank → Tasks tab
   - **Expected:** Pending tasks listed

2. Select "Water Change" task
3. Mark as complete
   - Add notes: "25% water change"
   - Upload photo: [Optional]

4. Tap "Complete"
   - **Expected:** Task marked complete
   - **Expected:** XP awarded (+5-10 XP)
   - **Expected:** Next occurrence scheduled
   - **Expected:** Completion logged

5. Verify next task
   - **Expected:** Next water change scheduled (e.g., 7 days from now)
   - **Expected:** Appears in upcoming tasks

**Pass Criteria:**
- ✅ Task completes successfully
- ✅ XP reward granted
- ✅ Next occurrence scheduled automatically
- ✅ History logged

---

### Test 3.5: View Tank Analytics

**Objective:** Verify charts and analytics display correctly.

**Prerequisites:**
- Tank with multiple log entries over time

**Steps:**

1. Open tank → Charts tab
   - **Expected:** Charts screen loads

2. View parameter trends:
   - Temperature over time
   - pH trends
   - Nitrate trends

   - **Expected:** Line graphs display correctly
   - **Expected:** Data points accurate
   - **Expected:** Axes labeled properly

3. Change date range to "7 days"
   - **Expected:** Charts update to show last 7 days only
   - **Expected:** Data filtered correctly

4. Change date range to "30 days"
   - **Expected:** Charts update to show last 30 days

**Pass Criteria:**
- ✅ Charts render correctly
- ✅ Data is accurate
- ✅ Date range filtering works
- ✅ Trends are meaningful

---

### Test 3.6: Tank Deletion

**Objective:** Verify tank can be deleted safely.

**Prerequisites:**
- Tank with livestock and logs

**Steps:**

1. Open tank settings
2. Tap "Delete Tank"
   - **Expected:** Confirmation dialog appears
   - **Expected:** Warning about data loss

3. Confirm deletion
   - **Expected:** Tank deleted
   - **Expected:** Removed from tank list
   - **Expected:** Associated data (livestock, logs) also deleted

4. Verify deletion
   - **Expected:** Tank no longer appears anywhere
   - **Expected:** No orphaned data

**Pass Criteria:**
- ✅ Deletion requires confirmation
- ✅ Tank and all associated data deleted
- ✅ No errors after deletion
- ✅ Cannot undo (or undo mechanism works if implemented)

---

## 4. Social Flow Tests

### Test 4.1: Add Friend (Happy Path)

**Objective:** Verify adding friends works correctly.

**Prerequisites:**
- User account active
- Mock friend data available

**Steps:**

1. Navigate to Friends tab
2. Tap "Add Friend" or "+"
   - **Expected:** Friend search interface appears

3. Search for friend by username: "TestUser123"
   - **Expected:** Search results show matching user
   - **Expected:** User profile preview displayed

4. Tap "Add Friend"
   - **Expected:** Friend request sent (or auto-accepted in demo)
   - **Expected:** Friend added to friends list
   - **Expected:** Success message displayed

5. Verify friend appears in list
   - **Expected:** Friend shown with avatar, name, level
   - **Expected:** Stats visible

**Pass Criteria:**
- ✅ Friend search works
- ✅ Friend adds successfully
- ✅ Friend appears in list
- ✅ Stats display correctly

---

### Test 4.2: View Friend Comparison

**Objective:** Verify friend comparison screen shows accurate data.

**Prerequisites:**
- User has at least 1 friend

**Steps:**

1. From Friends tab, tap on a friend
   - **Expected:** Friend comparison screen opens

2. Review side-by-side stats:
   - Total XP
   - Current level
   - Current streak
   - Longest streak
   - Achievements

   - **Expected:** Your stats on left
   - **Expected:** Friend's stats on right
   - **Expected:** Higher values highlighted

3. View weekly XP chart
   - **Expected:** Bar chart shows daily XP for both users
   - **Expected:** Different colors for you vs friend
   - **Expected:** Accurate data

4. View achievement comparison
   - **Expected:** Shared achievements indicated
   - **Expected:** Unique achievements shown
   - **Expected:** Locked achievements grayed out

**Pass Criteria:**
- ✅ Comparison data is accurate
- ✅ Charts render correctly
- ✅ Visual indicators are clear
- ✅ All sections functional

---

### Test 4.3: Send Encouragement

**Objective:** Verify sending encouragement to friends.

**Prerequisites:**
- User has friends

**Steps:**

1. From friend's profile, tap "Send Encouragement"
   - **Expected:** Emoji picker appears

2. Select emoji: 🎉
3. Add message: "Great work on your streak!"
4. Tap "Send"
   - **Expected:** Success message: "Encouragement sent!"
   - **Expected:** Encouragement logged

5. Verify sent status
   - **Expected:** Cannot spam (cooldown period)
   - **Expected:** Sent encouragements tracked

**Pass Criteria:**
- ✅ Encouragement sends successfully
- ✅ Message and emoji saved
- ✅ Spam prevention works
- ✅ Friend receives notification (mock)

---

### Test 4.4: View Activity Feed

**Objective:** Verify activity feed displays friend activities.

**Prerequisites:**
- User has friends with recent activities

**Steps:**

1. Navigate to Friends tab → Activity section
   - **Expected:** Activity feed loads

2. Scroll through activities
   - **Expected:** Recent activities listed
   - **Expected:** Activity types shown:
     - Level up
     - Achievement unlocked
     - Streak milestone
     - Lesson completed
     - Tank created

3. Check activity details:
   - Friend name
   - Avatar emoji
   - Description
   - Time ago (e.g., "2h ago")

   - **Expected:** All details accurate
   - **Expected:** Time ago updates correctly

4. Tap on an activity
   - **Expected:** Can send quick encouragement
   - **Expected:** Can view friend's profile

**Pass Criteria:**
- ✅ Activity feed loads correctly
- ✅ Activities sorted by time (newest first)
- ✅ All activity types display properly
- ✅ Interactions work

---

### Test 4.5: Remove Friend

**Objective:** Verify unfriending functionality.

**Prerequisites:**
- User has at least 1 friend

**Steps:**

1. Open friend's profile
2. Tap "Remove Friend" or settings icon
   - **Expected:** Confirmation dialog

3. Confirm removal
   - **Expected:** Friend removed from list
   - **Expected:** No longer see their activity
   - **Expected:** Comparison data no longer accessible

**Pass Criteria:**
- ✅ Unfriend requires confirmation
- ✅ Friend removed completely
- ✅ No errors after removal
- ✅ Can re-add later if desired

---

## 5. Shop & Progression Flow Tests

### Test 5.1: Browse Shop Catalog

**Objective:** Verify shop displays items correctly.

**Prerequisites:**
- User account with some gems

**Steps:**

1. Navigate to Shop tab
   - **Expected:** Shop Street screen loads
   - **Expected:** Gem balance displayed at top

2. Browse categories:
   - Room Themes
   - Power-Ups
   - Extras
   - Cosmetics

   - **Expected:** Each category shows items
   - **Expected:** Items display:
     - Name
     - Emoji icon
     - Description
     - Gem cost
     - Owned/locked status

3. Tap on item
   - **Expected:** Item detail modal appears
   - **Expected:** Full description shown
   - **Expected:** Effects/benefits listed
   - **Expected:** Purchase button visible

**Pass Criteria:**
- ✅ Shop loads correctly
- ✅ All categories accessible
- ✅ Items display properly
- ✅ Gem balance accurate

---

### Test 5.2: Purchase Item (Happy Path)

**Objective:** Verify purchasing items with sufficient gems.

**Prerequisites:**
- User has 50+ gems

**Steps:**

1. Browse shop and select "Streak Freeze" (30 gems)
2. Tap "Purchase"
   - **Expected:** Confirmation dialog: "Purchase for 30 gems?"

3. Confirm purchase
   - **Expected:** Success animation
   - **Expected:** Gems deducted (50 → 20)
   - **Expected:** Item added to inventory
   - **Expected:** Item marked as "Owned" in shop

4. Verify inventory
   - **Expected:** Streak Freeze appears in inventory
   - **Expected:** Quantity: 1

**Pass Criteria:**
- ✅ Purchase succeeds
- ✅ Gems deducted correctly
- ✅ Item added to inventory
- ✅ UI updates immediately

---

### Test 5.3: Purchase with Insufficient Gems

**Objective:** Verify handling of insufficient gem balance.

**Prerequisites:**
- User has 10 gems

**Steps:**

1. Try to purchase item costing 50 gems
2. Tap "Purchase"
   - **Expected:** Error message: "Not enough gems!"
   - **Expected:** Shows deficit: "You need 40 more gems"
   - **Expected:** Suggests earning methods:
     - "Complete 8 more lessons"
     - "Maintain your streak"
     - "Achieve daily goal"

3. Verify no deduction
   - **Expected:** Gem balance unchanged
   - **Expected:** Item not added to inventory

**Pass Criteria:**
- ✅ Purchase blocked appropriately
- ✅ Clear error messaging
- ✅ Helpful suggestions provided
- ✅ No transaction occurs

---

### Test 5.4: Use XP Boost Power-Up

**Objective:** Verify XP boost activation and effect.

**Prerequisites:**
- User owns "2x XP Boost" item

**Steps:**

1. Navigate to inventory
2. Select "2x XP Boost"
3. Tap "Activate"
   - **Expected:** Confirmation: "Activate 2x XP for 1 hour?"

4. Confirm activation
   - **Expected:** Timer starts (60:00)
   - **Expected:** XP boost indicator in UI
   - **Expected:** Item consumed from inventory

5. Complete a lesson (normally 10 XP)
   - **Expected:** Earn 20 XP (2x multiplier)
   - **Expected:** Bonus XP clearly indicated

6. Wait for timer to expire (or advance time)
   - **Expected:** Notification: "XP Boost expired"
   - **Expected:** Multiplier removed
   - **Expected:** Normal XP for subsequent lessons

**Pass Criteria:**
- ✅ Boost activates successfully
- ✅ Timer displays correctly
- ✅ XP multiplier applies accurately
- ✅ Boost expires after duration
- ✅ Item consumed from inventory

---

### Test 5.5: Use Streak Freeze

**Objective:** Verify streak freeze protection.

**Prerequisites:**
- User owns "Streak Freeze" item
- User has active streak

**Steps:**

1. Verify streak freeze in inventory
   - **Expected:** Shows owned quantity

2. Skip a day (do not complete lessons)
3. Launch app next day
   - **Expected:** Streak freeze automatically used
   - **Expected:** Streak maintained
   - **Expected:** Message: "Streak Freeze protected your streak!"
   - **Expected:** Item removed from inventory

4. Verify protection
   - **Expected:** Streak count unchanged
   - **Expected:** One freeze consumed

**Pass Criteria:**
- ✅ Freeze activates automatically when needed
- ✅ Streak is protected
- ✅ Item consumed after use
- ✅ Clear notification

---

### Test 5.6: Purchase and Apply Room Theme

**Objective:** Verify room theme purchase and application.

**Prerequisites:**
- User has 100+ gems

**Steps:**

1. Browse shop → Room Themes
2. Select "Cozy Cabin" (100 gems)
3. View preview
   - **Expected:** Preview image/mockup shown

4. Purchase theme
   - **Expected:** Gems deducted
   - **Expected:** Theme unlocked

5. Navigate to Settings → Theme
6. Select "Cozy Cabin"
   - **Expected:** Theme applied to UI
   - **Expected:** Visual changes throughout app
   - **Expected:** Theme persists after app restart

**Pass Criteria:**
- ✅ Theme purchases correctly
- ✅ Preview shows before purchase
- ✅ Theme applies globally
- ✅ Theme persists across sessions

---

## 6. Edge Cases & Error Scenarios

### Test 6.1: Multiple Rapid Lesson Completions

**Objective:** Test system under rapid consecutive lesson completions.

**Steps:**

1. Complete 10 lessons rapidly (within 5 minutes)
   - **Expected:** All XP awarded correctly
   - **Expected:** All gems awarded correctly
   - **Expected:** No duplicate rewards
   - **Expected:** Stats update accurately
   - **Expected:** No UI lag or freezing

**Pass Criteria:**
- ✅ Handles rapid interactions
- ✅ No reward duplication
- ✅ Accurate stat tracking
- ✅ Acceptable performance

---

### Test 6.2: Boundary Value Testing - Tank Volume

**Objective:** Test tank creation with extreme volumes.

**Test Cases:**

| Volume | Unit | Expected Result |
|--------|------|-----------------|
| 0 | Gallons | ❌ Error: "Volume must be greater than 0" |
| 0.5 | Gallons | ✅ Accepted |
| 10000 | Gallons | ✅ Accepted (with warning?) |
| -5 | Gallons | ❌ Error: "Volume must be positive" |
| "abc" | Gallons | ❌ Error: "Invalid number" |

**Pass Criteria:**
- ✅ Validation catches invalid inputs
- ✅ Clear error messages
- ✅ Accepts valid edge cases
- ✅ No crashes

---

### Test 6.3: Leap Year and Date Edge Cases

**Objective:** Verify date handling for streaks and scheduling.

**Test Cases:**

1. Streak spanning February 29 (leap year)
   - **Expected:** Counts correctly as 1 day

2. Streak spanning daylight saving time change
   - **Expected:** No double-count or skip

3. Task scheduled for Feb 31 (invalid)
   - **Expected:** Validation prevents or adjusts

**Pass Criteria:**
- ✅ Date logic is sound
- ✅ No off-by-one errors
- ✅ Handles timezone changes
- ✅ Invalid dates caught

---

### Test 6.4: Concurrent Data Modifications

**Objective:** Test data integrity with simultaneous changes.

**Steps:**

1. Open app on two devices with same account (if sync enabled)
2. Modify profile on device 1
3. Simultaneously complete lesson on device 2
   - **Expected:** Last-write-wins or conflict resolution
   - **Expected:** No data corruption
   - **Expected:** Both changes eventually reflected

**Pass Criteria:**
- ✅ No data loss
- ✅ Conflict resolution works
- ✅ Sync completes successfully
- ✅ Consistent final state

---

### Test 6.5: Storage Quota Exceeded

**Objective:** Verify handling when local storage is full.

**Steps:**

1. Fill device storage to near capacity
2. Attempt to create tank with large notes/photos
   - **Expected:** Error: "Storage full"
   - **Expected:** Graceful degradation
   - **Expected:** Suggestion to free space

3. Attempt to log water test
   - **Expected:** Same error handling
   - **Expected:** Data not corrupted

**Pass Criteria:**
- ✅ Storage errors caught
- ✅ Clear error messaging
- ✅ No crashes
- ✅ Existing data intact

---

### Test 6.6: Unicode and Special Characters

**Objective:** Verify handling of special characters in inputs.

**Test Cases:**

| Field | Input | Expected |
|-------|-------|----------|
| Tank name | "José's 🐠 Tank" | ✅ Accepted |
| Name | "用户名" (Chinese) | ✅ Accepted |
| Notes | "Line1\nLine2" | ✅ Preserved |
| Search | "Neon<script>" | ✅ Sanitized |

**Pass Criteria:**
- ✅ Unicode supported
- ✅ Emojis work
- ✅ Line breaks preserved
- ✅ XSS prevented (if web view)

---

## 7. Offline Behavior Tests

### Test 7.1: Offline Lesson Completion

**Objective:** Verify lessons work without internet.

**Prerequisites:**
- App previously loaded

**Steps:**

1. Enable airplane mode / disconnect WiFi
2. Open app
   - **Expected:** App loads from cache

3. Navigate to Learn tab
   - **Expected:** Lessons accessible

4. Complete a lesson
   - **Expected:** Lesson content loads
   - **Expected:** Progress tracked locally
   - **Expected:** XP/gems awarded (queued)
   - **Expected:** "Offline" indicator shown

5. Reconnect to internet
   - **Expected:** Data syncs automatically
   - **Expected:** Stats update on server
   - **Expected:** Sync notification

**Pass Criteria:**
- ✅ Core features work offline
- ✅ Data queued for sync
- ✅ Sync succeeds when online
- ✅ No data loss

---

### Test 7.2: Offline Tank Management

**Objective:** Verify tank operations offline.

**Steps:**

1. Go offline
2. Create tank
   - **Expected:** Tank created locally
   - **Expected:** Queued for sync

3. Add livestock
   - **Expected:** Added locally
   - **Expected:** Queued for sync

4. Log water test
   - **Expected:** Logged locally
   - **Expected:** Queued for sync

5. Go online
   - **Expected:** All changes sync
   - **Expected:** Server data updated

**Pass Criteria:**
- ✅ All operations work offline
- ✅ Queue mechanism works
- ✅ Sync is reliable
- ✅ Conflict resolution handles edge cases

---

### Test 7.3: Offline Shop Access

**Objective:** Verify shop behavior when offline.

**Steps:**

1. Go offline
2. Navigate to Shop
   - **Expected:** Cached catalog loads
   - **Expected:** "Offline" warning displayed

3. Attempt purchase
   - **Expected:** Warning: "Cannot purchase while offline"
   - **Expected:** Purchase blocked
   - **Expected:** Can still browse

**Pass Criteria:**
- ✅ Shop browsable offline
- ✅ Purchases blocked
- ✅ Clear messaging
- ✅ No errors

---

## 8. Performance & Load Tests

### Test 8.1: Large Tank List Performance

**Objective:** Verify app performance with many tanks.

**Steps:**

1. Create 50+ tanks
2. Navigate to tank list
   - **Expected:** List loads in <2 seconds
   - **Expected:** Smooth scrolling
   - **Expected:** No lag

3. Open tank detail
   - **Expected:** Loads quickly
   - **Expected:** Responsive UI

**Pass Criteria:**
- ✅ Handles large datasets
- ✅ Acceptable load times
- ✅ No performance degradation

---

### Test 8.2: Large Livestock Collection

**Objective:** Test performance with many livestock entries.

**Steps:**

1. Add 100+ livestock to a tank
2. View livestock list
   - **Expected:** List renders efficiently
   - **Expected:** Smooth scrolling
   - **Expected:** Search/filter works

**Pass Criteria:**
- ✅ Pagination or virtualization works
- ✅ No UI freezing
- ✅ Search remains fast

---

### Test 8.3: Long-Term Data Accumulation

**Objective:** Test app with months of historical data.

**Steps:**

1. Simulate 6+ months of daily logs
2. View charts
   - **Expected:** Charts load in <3 seconds
   - **Expected:** Data aggregated intelligently
   - **Expected:** Zoom/pan works smoothly

**Pass Criteria:**
- ✅ Handles long-term data
- ✅ Charts remain performant
- ✅ Data queries optimized

---

### Test 8.4: Memory Leak Detection

**Objective:** Ensure no memory leaks during extended use.

**Steps:**

1. Use app for 30+ minutes continuously
2. Navigate between all screens multiple times
3. Complete various actions
4. Monitor memory usage
   - **Expected:** Memory stays within acceptable bounds
   - **Expected:** No gradual increase
   - **Expected:** GC occurs appropriately

**Pass Criteria:**
- ✅ No memory leaks detected
- ✅ Stable memory footprint
- ✅ No crashes after extended use

---

## 🎯 Test Coverage Summary

### Critical Path Tests (Must Pass)
- ✅ First-time onboarding
- ✅ Lesson completion and XP earning
- ✅ Daily goal tracking
- ✅ Streak maintenance
- ✅ Tank creation and management
- ✅ Shop purchases

### Important Tests (Should Pass)
- ✅ Social features (friends, leaderboard)
- ✅ Offline functionality
- ✅ Error recovery
- ✅ Data validation

### Nice to Have (Can Defer)
- ✅ Extreme edge cases
- ✅ Performance under load
- ✅ Accessibility features

---

## 🐛 Bug Severity Guidelines

| Severity | Description | Examples |
|----------|-------------|----------|
| **Critical** | App unusable, data loss, crashes | Cannot complete onboarding, XP not saved, app crashes on launch |
| **High** | Major feature broken | Streak not tracking, shop purchases fail, leaderboard doesn't load |
| **Medium** | Feature partially broken or workaround exists | Chart display issue, typo in UI, slow performance |
| **Low** | Cosmetic or minor inconvenience | Icon misaligned, animation glitch, suggested feature |

---

## 📝 Testing Checklist

Use this checklist for each release:

### Pre-Release Smoke Tests
- [ ] App launches successfully
- [ ] Onboarding completes
- [ ] Can create account/profile
- [ ] Can complete a lesson
- [ ] Can create a tank
- [ ] Can log water test
- [ ] Shop loads and purchases work
- [ ] Friends can be added
- [ ] Settings save correctly
- [ ] App doesn't crash during normal use

### Regression Tests
- [ ] All critical path tests pass
- [ ] All high-priority tests pass
- [ ] No new crashes introduced
- [ ] Performance acceptable
- [ ] Offline mode works

### Platform-Specific Tests
- [ ] Test on iOS
- [ ] Test on Android
- [ ] Test on various screen sizes
- [ ] Test on different OS versions

---

*Last Updated: 2025-02-07*
*Version: 1.0*
