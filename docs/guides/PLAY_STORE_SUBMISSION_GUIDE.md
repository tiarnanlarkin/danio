# Play Store Submission Guide - Aquarium Hobbyist

**App Version:** 1.0.0+1  
**Package:** com.tiarnanlarkin.aquarium.aquarium_app  
**Target:** Google Play Store (Android)

---

## Prerequisites Checklist

Before submitting, ensure you have:

- [ ] ✅ Release AAB built (`app-release.aab`)
- [ ] ✅ Google Play Console account created
- [ ] ✅ Developer registration fee paid ($25 one-time)
- [ ] ✅ App icon (512x512 PNG)
- [ ] ✅ Feature graphic (1024x500 PNG)
- [ ] ✅ Screenshots (7 images captured)
- [ ] ✅ Privacy policy hosted online
- [ ] ✅ Store listing copy ready

---

## Step 1: Build Release AAB

### Option A: Windows PowerShell (FAST - 2-4 min)
```powershell
cd "C:\Users\larki\Documents\Aquarium App Dev\repo\apps\aquarium_app"
.\build-release.ps1
```

### Option B: WSL (SLOW - 10-15 min)
```bash
cd "/mnt/c/Users/larki/Documents/Aquarium App Dev/repo/apps/aquarium_app"
/home/tiarnanlarkin/flutter/bin/flutter build appbundle --release
```

**Output Location:**
```
build\app\outputs\bundle\release\app-release.aab
```

**Expected Size:** 30-40 MB

---

## Step 2: Create Play Console App

1. Go to https://play.google.com/console
2. Click **"Create app"**
3. Fill in details:
   - **App name:** Aquarium Hobbyist
   - **Default language:** English (United States)
   - **App or game:** App
   - **Free or paid:** Free
   - **User data declaration:** Complete (see below)
   - **Ads:** No (we don't show ads)

4. Accept declarations:
   - Developer Program Policies
   - US export laws
   - Check all required boxes

5. Click **"Create app"**

---

## Step 3: Complete Store Listing

### 3.1 App Details

**Short description** (80 chars max):
```
Learn fishkeeping like Duolingo! Track tanks, master care, level up your hobby.
```

**Full description** (4000 chars max):
See `docs/completed/STORE_LISTING_CONTENT.md` for full copy (3,847 chars)

**Category:**
- **Lifestyle**

### 3.2 Graphics Assets

#### App Icon (512x512)
- **Location:** `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png` (extract 512x512 version)
- **Requirements:** PNG, 32-bit, no transparency
- **Design:** Aquarium theme with fish and bubbles

#### Feature Graphic (1024x500)
- **Need to create:** Simple banner with app name + aquarium visual
- **Requirements:** JPEG or 24-bit PNG, no transparency
- **Text:** "Aquarium Hobbyist" + tagline

#### Screenshots (minimum 2, we have 7)
**Location:** `docs/screenshots/`
1. `01_home_dashboard.png` - Dashboard overview
2. `02_tank_detail.png` - Tank management
3. `03_water_parameters.png` - Water tracking
4. `04_learn_screen.png` - Learning interface
5. `05_achievements.png` - Gamification
6. `06_species_database.png` - Fish species
7. `07_settings.png` - Settings screen

**Upload order:** As listed above (shows best features first)

### 3.3 Categorization

- **App category:** Lifestyle
- **Tags:** hobbies, education, pets, aquarium, fishkeeping

### 3.4 Contact Details

- **Email:** your@email.com
- **Phone:** (optional)
- **Website:** (optional - or link to GitHub)
- **Privacy policy URL:** **REQUIRED - see below**

---

## Step 4: Privacy Policy

### Hosting Options:

**Option A: GitHub Pages (Free)**
1. Upload `docs/legal/privacy-policy.md` to GitHub repo
2. Enable GitHub Pages in repo settings
3. URL: `https://yourusername.github.io/aquarium-app/privacy-policy`

**Option B: Google Sites (Free)**
1. Create site at https://sites.google.com
2. Paste privacy policy text
3. Publish and copy URL

**Option C: Dedicated domain**
- Host on your own website

**Privacy Policy Text:**
See `docs/legal/privacy-policy.md` (5,813 bytes - comprehensive)

---

## Step 5: Content Rating

Complete the Content Rating Questionnaire:

### Violence
- Q: Does your app contain...
  - Violence or blood? **NO**
  - Realistic depictions? **NO**

### Sexual Content
- Q: Does your app contain...
  - Sexual or suggestive content? **NO**
  - Nudity? **NO**

### User Interaction
- Q: Does your app...
  - Allow users to communicate? **NO**
  - Share location with other users? **NO**
  - Allow unrestricted web access? **NO**

### Personal Info
- Q: Does your app...
  - Share personal user information? **NO**
  - Allow purchase of physical goods? **NO**

**Expected Rating:** **EVERYONE**

---

## Step 6: Data Safety

Play Store now requires "Data Safety" disclosure:

### What data is collected?
- **Tank information:** Names, volumes, parameters (LOCAL ONLY)
- **Photos:** User-taken tank photos (LOCAL ONLY)
- **Progress:** XP, achievements, streaks (LOCAL ONLY)

### Is data shared with third parties?
- **NO** - All data stored locally on device

### Is data encrypted in transit?
- **NO** - No network transmission (local storage only)

### Can users request data deletion?
- **YES** - Uninstalling app deletes all data
- Or use "Clear App Data" in Settings

**Summary:** Check "No data collected" OR select categories and mark as "Not shared"

---

## Step 7: App Access

- **App access:** Available to everyone
- **No restrictions** based on geography (unless you want to soft-launch in one region first)

---

## Step 8: Upload AAB

### Production Track
1. Navigate to **"Production"** → **"Create new release"**
2. Click **"Upload"** → Select `app-release.aab`
3. Wait for processing (~2-5 minutes)
4. Review warnings (if any)
5. Add **Release notes**:

```
🎉 Initial Release - Version 1.0

Welcome to Aquarium Hobbyist! Your personal fishkeeping companion.

✨ Features:
• Track unlimited aquariums with detailed parameters
• Learn fishkeeping through 50+ interactive lessons
• Gamification: Earn XP, unlock achievements, maintain streaks
• Species database: 122 fish + 52 plants with full care guides
• Tools: Volume calculator, dosing calculator, stocking analyzer
• 100% FREE, no ads, all data stored locally (privacy-first)

📚 Perfect for:
• Beginners learning to keep fish alive
• Intermediate hobbyists optimizing tank health
• Advanced aquarists tracking multiple tanks

We're excited to be your fishkeeping journey companion! 🐠
```

6. Click **"Next"** → **"Save"**

---

## Step 9: Review & Submit

### Final Checks

- [ ] All store listing sections complete (green checkmarks)
- [ ] Content rating questionnaire submitted
- [ ] Data safety form completed
- [ ] Privacy policy URL added
- [ ] AAB uploaded successfully
- [ ] Release notes added
- [ ] App access set correctly

### Submit for Review

1. Click **"Send for review"** (bottom right)
2. Confirm submission
3. **Review time:** Typically 1-7 days
   - Fast track: 1-3 days
   - Standard: 3-7 days
   - If flagged: May require clarification

---

## Step 10: Post-Submission

### Monitor Status

Check Play Console daily for:
- **"Pending publication"** - Under review
- **"Approved"** - Ready to publish or publishing
- **"Published"** - Live on Play Store! 🎉
- **"Changes requested"** - Needs fixes (check email)

### If Approved

App goes live automatically (usually within hours after approval).

**Play Store URL:**
```
https://play.google.com/store/apps/details?id=com.tiarnanlarkin.aquarium.aquarium_app
```

### If Changes Requested

Common issues:
- Privacy policy URL not working
- Screenshots not meeting guidelines
- Content rating mismatch
- Permissions not justified

**Action:** Fix issues, upload new AAB, resubmit

---

## Common Rejection Reasons & Fixes

### 1. Privacy Policy Issues
- **Issue:** URL doesn't work or missing details
- **Fix:** Host on GitHub Pages, ensure it's accessible

### 2. Misleading Screenshots
- **Issue:** Screenshots show features not in app
- **Fix:** All 7 screenshots are accurate - no issue expected

### 3. Inappropriate Content
- **Issue:** Flagged for violence/sexual content
- **Fix:** Our app is EVERYONE rated - no issue expected

### 4. Broken Functionality
- **Issue:** App crashes on Google's test devices
- **Fix:** We've tested extensively - low risk

### 5. Permissions Not Justified
- **Issue:** App requests permissions without clear use
- **Fix:** We only use notifications (justified) - no issue expected

---

## Post-Launch Tasks

### Week 1
- [ ] Monitor crash reports (Play Console → "Vitals")
- [ ] Respond to user reviews (aim for 48h response time)
- [ ] Check analytics (installs, retention)
- [ ] Fix critical bugs if reported

### Week 2-4
- [ ] Gather user feedback
- [ ] Plan v1.1 updates
- [ ] Optimize store listing based on conversion data
- [ ] Consider A/B testing screenshots/descriptions

---

## Support Resources

- **Play Console Help:** https://support.google.com/googleplay/android-developer
- **Developer Policies:** https://play.google.com/about/developer-content-policy/
- **Rejection Appeals:** https://support.google.com/googleplay/android-developer/answer/2992033

---

## Emergency Contacts

If submission blocked or urgent issues:

1. **Play Console Support** (login required)
2. **Developer Forums:** https://support.google.com/googleplay/android-developer/community
3. **Twitter:** @GooglePlayDev (for public issues)

---

## Backup Plan

If rejection occurs:
1. Fix issues immediately
2. Resubmit within 24-48 hours
3. Document what was changed
4. If multiple rejections, consider soft-launch in single country first

---

## Success Metrics (Track These)

### Week 1
- Installs: Target 10-50
- Crashes: <1%
- ANRs: <0.5%
- User rating: >4.0

### Month 1
- Installs: Target 100-500
- Retention (Day 7): >20%
- Retention (Day 30): >10%
- User rating: >4.2

---

**🎉 You're ready to submit! Good luck with the launch! 🚀**
