# 🎯 Launch Action Plan - Step-by-Step

**Goal:** Take Aquarium Hobbyist from 75% → 100% launch-ready  
**Timeline:** 3-5 days  
**Estimated Effort:** 3 hours of work + 2-3 days testing

---

## 📋 PHASE 1: FIX BLOCKERS (30-45 minutes)

### ⏱️ Task 1.1: Host Privacy Policy Online (15 min)

**Why:** Google Play Console REQUIRES a public privacy policy URL.

**Option A: GitHub Pages (Recommended - Free & Easy)**

**Steps:**
1. **Create a new GitHub repository:**
   - Name: `aquarium-privacy`
   - Visibility: Public
   - Initialize with README: No

2. **Upload privacy policy:**
   ```bash
   cd /tmp
   git clone https://github.com/YOUR_USERNAME/aquarium-privacy.git
   cd aquarium-privacy
   
   # Copy privacy policy
   cp "/mnt/c/Users/larki/Documents/Aquarium App Dev/repo/docs/legal/privacy-policy.md" ./index.md
   
   # Commit and push
   git add index.md
   git commit -m "Add privacy policy"
   git push
   ```

3. **Enable GitHub Pages:**
   - Go to repo Settings → Pages
   - Source: Deploy from branch
   - Branch: main / root
   - Save

4. **Get URL:**
   - Wait 1-2 minutes for deployment
   - URL: `https://YOUR_USERNAME.github.io/aquarium-privacy/`
   - Test URL in browser — should show privacy policy

5. **Save URL:**
   ```bash
   echo "Privacy Policy URL: https://YOUR_USERNAME.github.io/aquarium-privacy/" >> "/mnt/c/Users/larki/Documents/Aquarium App Dev/repo/docs/audit/STORE_LISTING_URLS.txt"
   ```

**Option B: Simple HTML Page (Alternative)**

If you have web hosting, convert markdown to HTML:

```bash
# Install pandoc if needed
sudo apt install pandoc

# Convert to HTML
pandoc "/mnt/c/Users/larki/Documents/Aquarium App Dev/repo/docs/legal/privacy-policy.md" -o privacy.html

# Upload privacy.html to your web server
# Get public URL
```

**✅ Completion Checklist:**
- [ ] Privacy policy is publicly accessible
- [ ] URL works in browser
- [ ] URL saved for Play Console
- [ ] Page is readable and formatted

---

### ⏱️ Task 1.2: Create High-Res Icon 1024×1024 (10-15 min)

**Why:** Required by Google Play Console for store listing.

**Option A: Export from Existing Icon (If You Have Source)**

If you have the original design file (PSD, Figma, etc.):
1. Open source file
2. Export at 1024×1024 pixels
3. Format: PNG with transparency
4. Save as: `app-icon-1024.png`

**Option B: Upscale Existing Icon (Quick but Lower Quality)**

```bash
# Install ImageMagick if needed
sudo apt install imagemagick

# Upscale existing xxxhdpi icon
cd "/mnt/c/Users/larki/Documents/Aquarium App Dev/repo/apps/aquarium_app/android/app/src/main/res/mipmap-xxxhdpi/"

convert ic_launcher.png -resize 1024x1024 -quality 100 app-icon-1024.png

# Move to docs for easy access
mv app-icon-1024.png "/mnt/c/Users/larki/Documents/Aquarium App Dev/repo/docs/audit/"
```

**Option C: Recreate in Canva (Best Quality)**

1. Go to https://www.canva.com (free account)
2. Create Custom Size: 1024×1024 px
3. Design icon:
   - Background: Light blue (#E3F2FD)
   - Add fish illustration (from Elements)
   - Add bubbles
   - Keep it simple and recognizable
4. Download as PNG
5. Save to: `/mnt/c/Users/larki/Documents/Aquarium App Dev/repo/docs/audit/app-icon-1024.png`

**✅ Completion Checklist:**
- [ ] Icon is exactly 1024×1024 pixels
- [ ] File format is PNG
- [ ] Icon is recognizable at small sizes
- [ ] Matches app's existing branding
- [ ] File saved and ready to upload

---

## 📋 PHASE 2: BUILD & TEST (1-1.5 hours)

### ⏱️ Task 2.1: Build Release AAB (15 min)

**Why:** Verify app builds successfully in release mode before submitting.

**IMPORTANT:** Build from **Windows PowerShell**, NOT WSL (WSL is too slow).

**Steps:**

1. **Open PowerShell as Administrator:**
   - Press `Win + X`
   - Select "Windows PowerShell (Admin)"

2. **Navigate to project:**
   ```powershell
   cd "C:\Users\larki\Documents\Aquarium App Dev\repo\apps\aquarium_app"
   ```

3. **Clean previous builds:**
   ```powershell
   flutter clean
   flutter pub get
   ```

4. **Build release AAB:**
   ```powershell
   flutter build appbundle --release
   ```

5. **Wait for completion:**
   - Expected time: 1-3 minutes
   - Watch for "Built build\app\outputs\bundle\release\app-release.aab"

6. **Verify output:**
   ```powershell
   dir "build\app\outputs\bundle\release\app-release.aab"
   ```

7. **Check file size:**
   - Should be: 30-50 MB
   - If >100 MB: something's wrong (check assets)

8. **Copy to easy location:**
   ```powershell
   copy "build\app\outputs\bundle\release\app-release.aab" "C:\Users\larki\Documents\Aquarium App Dev\aquarium-v1.0.0.aab"
   ```

**If Build Fails:**
- Check error message
- Common issues:
  - Missing dependencies: run `flutter pub get`
  - Keystore issues: verify `key.properties` exists
  - ProGuard errors: check `proguard-rules.pro`

**✅ Completion Checklist:**
- [ ] Build succeeded without errors
- [ ] AAB file exists
- [ ] File size is reasonable (30-50 MB)
- [ ] AAB copied to easy location

---

### ⏱️ Task 2.2: Test on Real Device (15-20 min)

**Why:** Catch crashes before users do!

**Option A: Install from AAB (Using bundletool)**

1. **Download bundletool:**
   ```powershell
   # Download from: https://github.com/google/bundletool/releases
   # Save to: C:\Users\larki\Documents\bundletool.jar
   ```

2. **Generate APKs from AAB:**
   ```powershell
   cd "C:\Users\larki\Documents\Aquarium App Dev"
   
   java -jar bundletool.jar build-apks --bundle=aquarium-v1.0.0.aab --output=aquarium-v1.0.0.apks --mode=universal
   ```

3. **Extract universal APK:**
   ```powershell
   # Rename .apks to .zip
   copy aquarium-v1.0.0.apks aquarium-v1.0.0.zip
   
   # Extract ZIP (right-click → Extract All)
   # Find universal.apk inside
   ```

4. **Install on device:**
   - Connect Android device via USB
   - Enable USB debugging on device
   - Run:
   ```powershell
   adb install -r universal.apk
   ```

**Option B: Build APK Directly (Faster for Testing)**

```powershell
cd "C:\Users\larki\Documents\Aquarium App Dev\repo\apps\aquarium_app"
flutter build apk --release
```

Then install:
```powershell
adb install -r "build\app\outputs\flutter-apk\app-release.apk"
```

**Testing Checklist:**

Test these critical flows:

1. **App Launch:**
   - [ ] App opens without crash
   - [ ] Splash screen shows
   - [ ] Home screen loads

2. **Create Tank:**
   - [ ] Tap "Add Tank" button
   - [ ] Fill in tank details
   - [ ] Save tank
   - [ ] Tank appears on home screen

3. **Add Water Test:**
   - [ ] Open a tank
   - [ ] Add water test log
   - [ ] Enter test values
   - [ ] Save log

4. **Navigation:**
   - [ ] Bottom navigation works
   - [ ] All main screens accessible
   - [ ] No blank screens

5. **Learning Section:**
   - [ ] Open learning tab
   - [ ] View a lesson
   - [ ] Complete a quiz

6. **Settings:**
   - [ ] Open settings
   - [ ] Toggle a preference
   - [ ] View About screen
   - [ ] Privacy policy link works

**If Crashes Occur:**
- Note what action caused crash
- Check logcat for error:
  ```powershell
  adb logcat | Select-String "AndroidRuntime"
  ```
- Fix critical issues before proceeding

**✅ Completion Checklist:**
- [ ] App installed successfully
- [ ] No crashes on launch
- [ ] Can create a tank
- [ ] Can add water test
- [ ] Navigation works
- [ ] No critical bugs found

---

## 📋 PHASE 3: ADD CRASH REPORTING (30-45 minutes)

### ⏱️ Task 3.1: Set Up Sentry (30-45 min)

**Why:** You need to know when your app crashes in production!

**Steps:**

1. **Create Sentry Account:**
   - Go to: https://sentry.io/signup/
   - Sign up with GitHub or email
   - Free tier: 5,000 events/month (plenty!)

2. **Create Project:**
   - Select platform: **Flutter**
   - Project name: `aquarium-hobbyist`
   - Copy your DSN (looks like: `https://xxx@xxx.ingest.sentry.io/xxx`)

3. **Add Dependency:**

   Edit `pubspec.yaml`:
   ```yaml
   dependencies:
     # ... existing dependencies ...
     sentry_flutter: ^7.14.0
   ```

   Run:
   ```bash
   cd "/mnt/c/Users/larki/Documents/Aquarium App Dev/repo/apps/aquarium_app"
   /home/tiarnanlarkin/flutter/bin/flutter pub get
   ```

4. **Update main.dart:**

   Find current `main()` function and replace with:

   ```dart
   import 'package:sentry_flutter/sentry_flutter.dart';
   
   Future<void> main() async {
     await SentryFlutter.init(
       (options) {
         options.dsn = 'YOUR_SENTRY_DSN_HERE';
         options.tracesSampleRate = 0.1; // 10% performance monitoring
         options.environment = 'production';
         // In debug mode, disable Sentry
         options.debug = false;
       },
       appRunner: () => runApp(const MyApp()),
     );
   }
   ```

5. **Test Crash Reporting:**

   Add a test button (temporarily) to trigger a crash:

   ```dart
   ElevatedButton(
     onPressed: () {
       throw Exception('Test crash for Sentry');
     },
     child: Text('Test Crash'),
   ),
   ```

   - Rebuild app
   - Tap "Test Crash" button
   - Go to Sentry dashboard
   - Verify crash appears (may take 1-2 minutes)

6. **Remove Test Button:**

   After confirming Sentry works, remove the test crash button.

7. **Update Privacy Policy:**

   Add this section to `docs/legal/privacy-policy.md`:

   ```markdown
   ## Crash Reporting
   
   We use Sentry (https://sentry.io) to detect and fix crashes, improving app stability. When the app crashes:
   
   - **What's collected:** Error message, stack trace, device model, OS version
   - **What's NOT collected:** Personal data, aquarium data, user identity
   - **Purpose:** Fix bugs and improve app reliability
   - **Retention:** Error reports deleted after 90 days
   
   Crash data is NOT shared with third parties and is used solely for app improvement.
   ```

   Also update the GitHub Pages version (Task 1.1).

**✅ Completion Checklist:**
- [ ] Sentry account created
- [ ] DSN added to main.dart
- [ ] Dependency added
- [ ] Test crash verified in dashboard
- [ ] Privacy policy updated
- [ ] Test button removed

---

## 📋 PHASE 4: CREATE FEATURE GRAPHIC (20-30 minutes)

### ⏱️ Task 4.1: Design Feature Graphic (20-30 min)

**Why:** Increases store listing visibility and click-through rate.

**Specs:**
- Size: Exactly **1024×500 pixels**
- Format: PNG or JPEG
- Content: App icon + tagline/text
- Style: Simple, clean, readable at small sizes

**Option A: Canva (Recommended - Free)**

1. **Go to Canva:**
   - https://www.canva.com
   - Login/create free account

2. **Create Custom Size:**
   - Click "Create a design"
   - Custom size: 1024 × 500 px
   - Create new design

3. **Design Layout:**

   **Background:**
   - Add light blue gradient (#E3F2FD to #B3E5FC)
   - Or use solid color from app theme

   **Add App Icon:**
   - Upload your 1024×1024 icon
   - Place on left or center
   - Size: ~300-400px tall

   **Add Text:**
   - Main text (large): "Aquarium Hobbyist"
   - Font: Bold, modern (Montserrat, Poppins, etc.)
   - Size: 72-96pt
   
   - Tagline (smaller): One of these:
     - "Track your tanks like a pro"
     - "Private. Local. Powerful."
     - "Fish care made simple"
     - "Your aquarium journal"
   - Font: Same as main but lighter weight
   - Size: 36-48pt

   **Add Decorative Elements:**
   - Water ripple graphics
   - Fish silhouettes
   - Bubbles
   - Keep it clean — don't overcrowd

4. **Export:**
   - Click "Share" → "Download"
   - File type: PNG
   - Save as: `feature-graphic-1024x500.png`

5. **Verify:**
   - Check dimensions: exactly 1024×500
   - Text is readable at small sizes
   - Looks good on both light and dark backgrounds

6. **Save to repo:**
   ```bash
   cp ~/Downloads/feature-graphic-1024x500.png "/mnt/c/Users/larki/Documents/Aquarium App Dev/repo/docs/audit/"
   ```

**Option B: Figma (Alternative)**

Similar process:
1. Create frame: 1024×500
2. Design with app colors
3. Export as PNG

**Option C: Quick Photoshop/GIMP**

1. New image: 1024×500
2. Add background
3. Place app icon
4. Add text layers
5. Export as PNG

**✅ Completion Checklist:**
- [ ] Graphic is exactly 1024×500 pixels
- [ ] Includes app icon and text
- [ ] Text is readable
- [ ] Matches app branding
- [ ] Saved as PNG
- [ ] File ready to upload

---

## 📋 PHASE 5: SUBMIT TO INTERNAL TESTING (30-45 minutes)

### ⏱️ Task 5.1: Create Play Console Listing (30-45 min)

**Steps:**

1. **Go to Google Play Console:**
   - https://play.google.com/console
   - Login with Google account

2. **Create App:**
   - Click "Create app"
   - Fill in:
     - **App name:** Aquarium Hobbyist
     - **Default language:** English (United States)
     - **App or game:** App
     - **Free or paid:** Free
   - Declarations:
     - Check all required boxes
   - Click "Create app"

3. **Set Up Store Listing:**

   Navigate to: **Grow** → **Store presence** → **Main store listing**

   **App Details:**
   - **App name:** Aquarium Hobbyist
   - **Short description:** (Choose one from `STORE_LISTING_CONTENT.md`)
     ```
     Track your aquarium like a pro. Water tests, maintenance logs & fish care education—all private, all local.
     ```
   - **Full description:** Copy from `docs/completed/PLAY_STORE_LAUNCH_COMPLETE.md` or `docs/planning/aquarium-app-play-store-launch.md`

   **Graphics:**
   - **App icon:** Upload `app-icon-1024.png`
   - **Feature graphic:** Upload `feature-graphic-1024x500.png`
   - **Phone screenshots:** Upload all 7 from `docs/testing/screenshots/`
     - 01_home_dashboard.png
     - 02_tank_detail.png
     - 04_water_parameters.png
     - 08_additional_feature.png
     - 10_settings.png
     - 12_learning_module.png
     - 14_settings_extended.png

   **Categorization:**
   - **App category:** Lifestyle
   - **Tags:** (if asked) aquarium, fish, hobby, pets

   **Contact details:**
   - **Email:** tiarnan.larkin@gmail.com
   - **Phone:** (optional)
   - **Website:** (optional or GitHub repo URL)

   **Privacy Policy:**
   - **Privacy policy URL:** `https://YOUR_USERNAME.github.io/aquarium-privacy/`

   Click "Save"

4. **Set Up App Content:**

   Navigate to: **Policy** → **App content**

   **Privacy Policy:**
   - Already entered above ✅

   **Data Safety:**
   - Click "Start"
   - **Does your app collect or share user data?** NO
   - **Explanation:** "All aquarium data is stored locally on the user's device. No personal information is collected, transmitted, or shared with third parties."
   - Complete questionnaire
   - Submit

   **Advertising ID:**
   - **Does your app use advertising ID?** NO
   - Submit

5. **Content Rating:**

   - Click "Start questionnaire"
   - **App category:** Utility, Productivity, Communication, or Other
   - Answer questions:
     - Violence: No
     - Sexual content: No
     - Profanity: No
     - Controlled substances: No
     - User interaction: No
     - Location sharing: No
     - Personal info: No
   - Calculate rating
   - Expected: **EVERYONE** or **EVERYONE 3+**
   - Submit

6. **Target Audience:**

   - **Target age group:** Select "All ages" or "Teens" and up
   - **Appeal to children:** No (unless you want COPPA restrictions)
   - Submit

7. **News Apps (If Asked):**
   - Your app is NOT a news app
   - Submit

8. **COVID-19 Contact Tracing/Status (If Asked):**
   - Not applicable
   - Submit

**✅ Completion Checklist:**
- [ ] App created in Play Console
- [ ] Store listing filled (name, descriptions, graphics)
- [ ] Privacy policy URL added
- [ ] Data safety declared (no collection)
- [ ] Content rating completed (EVERYONE)
- [ ] All policy sections complete

---

### ⏱️ Task 5.2: Upload to Internal Testing (15 min)

**Steps:**

1. **Navigate to Internal Testing:**
   - Go to: **Release** → **Testing** → **Internal testing**
   - Click "Create new release"

2. **Upload AAB:**
   - Click "Upload"
   - Select: `C:\Users\larki\Documents\Aquarium App Dev\aquarium-v1.0.0.aab`
   - Wait for upload (may take 1-2 minutes)
   - Wait for processing (Google scans AAB)

3. **Release Details:**
   - **Release name:** 1.0.0 (Internal Test)
   - **Release notes:**
     ```
     Initial v1.0 release - Internal testing
     
     Features:
     - Tank management
     - Water testing logs
     - Livestock tracking
     - Equipment management
     - Maintenance scheduling
     - Learning modules (12 lessons)
     - Gamification (XP, achievements)
     
     Please test:
     - Create tank
     - Add water test
     - Complete a lesson
     - Report any crashes or bugs
     ```

4. **Review Release:**
   - Verify version: 1.0.0 (1)
   - Check AAB uploaded correctly
   - Click "Save"

5. **Start Rollout:**
   - Click "Rollout to Internal testing"
   - Confirm

6. **Create Testers List:**
   - Go to **Testers** tab
   - Create email list: "Internal Testers"
   - Add emails:
     ```
     your.email@gmail.com
     friend1@email.com
     friend2@email.com
     ```
   - Save

7. **Get Testing Link:**
   - Copy opt-in URL
   - Share with testers

**✅ Completion Checklist:**
- [ ] AAB uploaded successfully
- [ ] Release created
- [ ] Internal testing started
- [ ] Testers added
- [ ] Opt-in link shared

---

## 📋 PHASE 6: TESTING PERIOD (2-3 days)

### ⏱️ Task 6.1: Monitor & Collect Feedback (Ongoing)

**Daily Tasks:**

1. **Check Sentry Dashboard:**
   - Go to: https://sentry.io
   - Look for crash reports
   - If crashes found:
     - Read stack trace
     - Identify cause
     - Fix in code
     - Build new AAB
     - Upload to internal testing

2. **Check Play Console:**
   - Go to: **Release** → **Testing** → **Internal testing**
   - Check "Feedback" tab
   - Read tester comments

3. **Message Testers:**
   - Ask for specific feedback:
     - Did it crash?
     - Was anything confusing?
     - Did all features work?
     - Any visual bugs?

4. **Test on Multiple Devices (If Possible):**
   - Different screen sizes
   - Different Android versions
   - Tablet vs phone

**Issues to Watch For:**

| Issue Type | Severity | Action |
|------------|----------|--------|
| Crashes on startup | 🔴 Critical | Fix immediately |
| Feature not working | 🔴 Critical | Fix immediately |
| Visual glitches | 🟡 Medium | Fix if common |
| Typos in text | 🟢 Low | Fix if time permits |
| Feature request | 🟢 Low | Note for v1.1 |

**✅ Daily Checklist:**
- [ ] Check Sentry (morning + evening)
- [ ] Check Play Console feedback
- [ ] Respond to testers
- [ ] Fix critical issues
- [ ] Document bugs found

---

### ⏱️ Task 6.2: Fix Critical Issues (As Needed)

**If Critical Bug Found:**

1. **Reproduce Bug:**
   - Follow tester's steps
   - Confirm you can reproduce it
   - Document exact steps

2. **Fix Bug:**
   - Identify root cause
   - Fix in code
   - Test fix locally

3. **Build New AAB:**
   ```powershell
   cd "C:\Users\larki\Documents\Aquarium App Dev\repo\apps\aquarium_app"
   flutter clean
   flutter build appbundle --release
   ```

4. **Update Version:**
   - Edit `pubspec.yaml`:
     ```yaml
     version: 1.0.0+2  # Increment build number
     ```
   - Rebuild

5. **Upload New Build:**
   - Go to Play Console
   - Internal testing → Create new release
   - Upload new AAB
   - Release notes: "Fixed: [bug description]"
   - Rollout

6. **Notify Testers:**
   - "New build available, please update"
   - Ask them to verify fix

**✅ Bug Fix Checklist:**
- [ ] Bug reproduced
- [ ] Root cause identified
- [ ] Fix implemented
- [ ] Fix tested locally
- [ ] Version incremented
- [ ] New AAB uploaded
- [ ] Testers notified

---

## 📋 PHASE 7: PRODUCTION SUBMISSION (15 minutes)

### ⏱️ Task 7.1: Final Pre-Launch Checks (10 min)

**Before submitting to production, verify:**

**Store Listing:**
- [ ] App name correct
- [ ] Short description compelling
- [ ] Full description complete
- [ ] All 7 screenshots uploaded
- [ ] High-res icon uploaded
- [ ] Feature graphic uploaded
- [ ] Privacy policy URL works
- [ ] Contact email correct

**App Content:**
- [ ] Data safety declared (no collection)
- [ ] Content rating submitted (EVERYONE)
- [ ] Target audience set
- [ ] All policy sections complete (green checkmarks)

**Release:**
- [ ] Internal testing completed
- [ ] No critical bugs found
- [ ] Testers approve
- [ ] Sentry shows <1% crash rate
- [ ] AAB version is latest

**Security:**
- [ ] Keystore backed up (2+ locations)
- [ ] key.properties backed up
- [ ] Passwords documented

---

### ⏱️ Task 7.2: Submit for Production (5 min)

**Steps:**

1. **Go to Production Track:**
   - Navigate: **Release** → **Production** → **Releases**
   - Click "Create new release"

2. **Promote from Internal Testing:**
   - Click "Promote release"
   - Select internal testing build
   - Or upload AAB again

3. **Release Details:**
   - **Release name:** 1.0.0
   - **Release notes:**
     ```
     Welcome to Aquarium Hobbyist v1.0!
     
     Track your aquarium with ease:
     🐠 Manage multiple tanks
     💧 Log water parameters
     📊 Visualize trends
     🐟 Track livestock & equipment
     🔔 Set maintenance reminders
     📚 Learn fish care basics
     
     100% private - all data stored locally on your device.
     
     Questions? Email: tiarnan.larkin@gmail.com
     ```

4. **Countries:**
   - Select: **All countries** (or choose specific ones)

5. **Review Release:**
   - Double-check version: 1.0.0 (1)
   - Verify release notes
   - Click "Save"

6. **Start Rollout:**
   - **Rollout percentage:** Start with 100% (or 20% for safer launch)
   - Click "Start rollout to Production"

7. **Confirm Submission:**
   - Read warnings/confirmations
   - Click "Rollout"

8. **Wait for Review:**
   - Status changes to "In review"
   - Expected: 1-3 days for approval
   - You'll receive email when approved

**✅ Submission Checklist:**
- [ ] Production release created
- [ ] Correct AAB version
- [ ] Release notes complete
- [ ] Countries selected
- [ ] Rollout started
- [ ] Confirmation email received

---

## 📋 POST-SUBMISSION

### ⏱️ While Waiting for Approval (1-3 days)

**Monitor:**
- [ ] Check Play Console daily for status updates
- [ ] Watch for emails from Google Play
- [ ] Continue monitoring Sentry (just in case)

**Prepare for Launch:**
- [ ] Write social media announcement
- [ ] Prepare announcement email (if you have a list)
- [ ] Screenshot approval email when it arrives
- [ ] Plan v1.1 improvements based on feedback

**If Rejected:**
- Read rejection reason carefully
- Fix the issue
- Resubmit

**When Approved:**
- [ ] Celebrate! 🎉
- [ ] Share app link with friends/family
- [ ] Monitor reviews and ratings
- [ ] Respond to user feedback
- [ ] Plan v1.1 features

---

## 🎯 QUICK REFERENCE CHECKLIST

### Before You Start
- [ ] Read LAUNCH_READINESS_AUDIT.md
- [ ] Read LAUNCH_STATUS_DASHBOARD.md
- [ ] Backup keystore files

### Phase 1: Blockers (30-45 min)
- [ ] Host privacy policy online → Get URL
- [ ] Create high-res icon 1024×1024

### Phase 2: Build & Test (1-1.5 hours)
- [ ] Build release AAB from Windows
- [ ] Test on real device
- [ ] Verify no critical crashes

### Phase 3: Crash Reporting (30-45 min)
- [ ] Create Sentry account
- [ ] Add sentry_flutter dependency
- [ ] Initialize in main.dart
- [ ] Test crash reporting
- [ ] Update privacy policy

### Phase 4: Feature Graphic (20-30 min)
- [ ] Design 1024×500 graphic
- [ ] Export as PNG
- [ ] Save to repo

### Phase 5: Internal Testing (30-45 min)
- [ ] Create Play Console app
- [ ] Fill store listing
- [ ] Upload AAB to internal testing
- [ ] Add testers
- [ ] Share opt-in link

### Phase 6: Testing (2-3 days)
- [ ] Monitor Sentry daily
- [ ] Collect tester feedback
- [ ] Fix critical bugs
- [ ] Update build if needed

### Phase 7: Production (15 min)
- [ ] Final pre-launch checks
- [ ] Submit to production
- [ ] Wait for approval (1-3 days)

---

## 📞 NEED HELP?

**Documentation:**
- Full audit: `LAUNCH_READINESS_AUDIT.md`
- Quick checklist: `LAUNCH_CHECKLIST_SUMMARY.md`
- Status dashboard: `LAUNCH_STATUS_DASHBOARD.md`
- This guide: `LAUNCH_ACTION_PLAN.md`

**Support:**
- Email: tiarnan.larkin@gmail.com
- Previous work: `docs/completed/PLAY_STORE_LAUNCH_COMPLETE.md`

---

**You've got this! Follow the steps and you'll be live in 3-5 days! 🚀🐠**

---

*Action plan created: February 15, 2026*  
*Scope: Aquarium Hobbyist v1.0 Launch*
