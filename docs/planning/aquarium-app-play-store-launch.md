# ⚠️ HISTORICAL - See MASTER_INTEGRATION_ROADMAP v2.0

> **DO NOT USE as current plan.** This was an early launch plan before the comprehensive audit.
> 
> **Current source of truth:**
> `/mnt/c/Users/larki/Documents/Aquarium App Dev/repo/MASTER_INTEGRATION_ROADMAP.md`
> 
> Kept for historical reference only.

---

# Aquarium App - Play Store Launch Plan (ARCHIVED)

**Goal:** Transform the app from "builds successfully" to "100% Play Store ready"

**Current State:**
- ✅ 100 Dart files, comprehensive feature set
- ✅ Learning system complete (12 lessons, 11 quizzes, XP/achievements)
- ✅ Compiles successfully (debug APK built in 43.6s)
- ✅ Package ID: com.tiarnanlarkin.aquarium.aquarium_app
- ✅ Version 0.1.0+1

**Missing for Play Store:**
- ❌ Custom app icon (default Flutter logo)
- ❌ Friendly app name in manifest
- ❌ Splash screen (adaptive icon)
- ❌ Privacy policy page & content
- ❌ Terms of service page & content
- ❌ Release signing configuration
- ❌ Store listing assets (screenshots, description, graphics)
- ❌ Permissions audit & optimization
- ❌ Performance/accessibility polish

**Approach:** Multi-agent parallel execution with regular Telegram updates

**Estimated Total Time:** 3-4 hours

---

## Checkpoint 1: Branding & Visual Identity (30-45 min)

### Agent 1: App Icon & Splash
- [ ] Design custom app icon (aquarium theme - fish/tank/water) (~15 min)
  - **Action:** Create 1024x1024 base icon, generate all mipmap sizes
  - **Verify:** Icons exist in all mipmap-* folders
- [ ] Generate adaptive icon (Android 8+) (~10 min)
  - **Action:** Create foreground/background layers
  - **Verify:** Works on different launcher backgrounds
- [ ] Create splash screen (~10 min)
  - **Action:** Update drawable resources for launch screen
  - **Verify:** Shows branded splash on app launch
- [ ] Update app name in manifest (~5 min)
  - **Action:** Change "aquarium_app" → "Aquarium Hobbyist" (or better name)
  - **Verify:** Friendly name shows in launcher

### Agent 2: App Store Assets
- [ ] Generate 5-7 screenshots (different screens) (~20 min)
  - **Action:** Launch app, capture key screens (home, tank detail, learning, charts)
  - **Verify:** High-res screenshots saved
- [ ] Write short description (<80 chars) (~5 min)
  - **Action:** Compelling tagline for store listing
  - **Verify:** Under character limit, catchy
- [ ] Write full description (~15 min)
  - **Action:** Detailed feature list, benefits, target audience
  - **Verify:** Comprehensive, SEO-friendly, under 4000 chars
- [ ] Create feature graphic (1024x500) (~10 min)
  - **Action:** Banner image for store listing
  - **Verify:** Meets Play Store specs

---

## Checkpoint 2: Legal & Privacy (20-30 min)

### Agent 3: Privacy Policy
- [ ] Draft privacy policy content (~15 min)
  - **Action:** Cover data collection, storage, third-party services, user rights
  - **Verify:** Covers all required sections
- [ ] Create privacy policy screen in app (~10 min)
  - **Action:** Add PrivacyPolicyScreen.dart, link from settings/about
  - **Verify:** Accessible from app, scrollable, clear
- [ ] Host privacy policy online (~5 min)
  - **Action:** Create simple GitHub Pages or similar
  - **Verify:** URL accessible, formatted

### Agent 4: Terms of Service
- [ ] Draft terms of service (~10 min)
  - **Action:** Standard terms, disclaimers, limitations of liability
  - **Verify:** Covers app usage, content, restrictions
- [ ] Create terms screen in app (~5 min)
  - **Action:** Add TermsOfServiceScreen.dart
  - **Verify:** Accessible, linked
- [ ] Host terms online (~5 min)
  - **Action:** Same hosting as privacy policy
  - **Verify:** URL accessible

---

## Checkpoint 3: Release Configuration (20-30 min)

### Agent 5: Signing & Build Config
- [ ] Generate release keystore (~5 min)
  - **Action:** `keytool -genkey -v -keystore aquarium-release.jks ...`
  - **Verify:** Keystore file created, password secured
- [ ] Configure signing in build.gradle.kts (~10 min)
  - **Action:** Add release signing config, reference keystore
  - **Verify:** Build config references correct keystore
- [ ] Create key.properties (~5 min)
  - **Action:** Store keystore path, alias, passwords (gitignored)
  - **Verify:** File exists, .gitignore includes it
- [ ] Update version for launch (~2 min)
  - **Action:** Change to 1.0.0+1 in pubspec.yaml
  - **Verify:** Version incremented
- [ ] Build release AAB (~5 min)
  - **Action:** `flutter build appbundle --release`
  - **Verify:** AAB created successfully, signed

---

## Checkpoint 4: Permissions & Optimization (15-20 min)

### Agent 6: Permissions Audit
- [ ] Review AndroidManifest.xml permissions (~5 min)
  - **Action:** List all requested permissions
  - **Verify:** Only necessary permissions included
- [ ] Add permission descriptions (~5 min)
  - **Action:** Add usage descriptions for each permission
  - **Verify:** Clear why each permission is needed
- [ ] Test permission flows (~5 min)
  - **Action:** Ensure runtime permissions handled gracefully
  - **Verify:** No crashes on permission denial

### Agent 7: Performance Polish
- [ ] Run `flutter analyze` (~5 min)
  - **Action:** Fix any lint warnings/errors
  - **Verify:** Zero issues
- [ ] Check app size (~2 min)
  - **Action:** Review AAB size, identify large assets
  - **Verify:** Reasonable size (<50MB ideally)
- [ ] Test on multiple screen sizes (~8 min)
  - **Action:** Run on phone and tablet emulators
  - **Verify:** UI scales properly

---

## Checkpoint 5: Store Listing Preparation (15-20 min)

### Agent 8: Store Listing Content
- [ ] Categorization (~3 min)
  - **Action:** Choose category (Lifestyle or Education)
  - **Verify:** Category fits app purpose
- [ ] Content rating questionnaire prep (~5 min)
  - **Action:** Document answers for Play Store content rating
  - **Verify:** Accurate representation of app content
- [ ] Pricing & distribution (~2 min)
  - **Action:** Decide free vs paid, available countries
  - **Verify:** Decision documented
- [ ] Create store listing checklist (~10 min)
  - **Action:** Complete checklist of all Play Store requirements
  - **Verify:** All items addressed

---

## Checkpoint 6: Testing & Verification (20-30 min)

### Agent 9: Final Testing
- [ ] Install release APK on device (~5 min)
  - **Action:** Transfer and install signed APK
  - **Verify:** Installs without warnings
- [ ] Full feature walkthrough (~15 min)
  - **Action:** Test all major flows (onboarding, create tank, add log, etc.)
  - **Verify:** No crashes, all features work
- [ ] Test offline functionality (~5 min)
  - **Action:** Enable airplane mode, test core features
  - **Verify:** App works offline as expected
- [ ] Performance check (~5 min)
  - **Action:** Monitor startup time, memory usage
  - **Verify:** Responsive, no lag

---

## Verification Criteria

**All checkpoints complete:**
- [x] Custom icon & splash screen implemented
- [x] App store assets created (screenshots, descriptions)
- [x] Privacy policy & terms created (in-app + online)
- [x] Release build signed and tested
- [x] Permissions audited and justified
- [x] Performance optimized
- [x] Store listing prepared
- [x] Final testing passed

**Quality Standards:**
- App launches without errors
- All features functional
- Legal requirements met
- Visual polish complete
- Ready for Play Store submission

**User Approval:**
- Review store listing content
- Approve app icon/name
- Confirm pricing/distribution strategy

---

## Execution Strategy

**Phase 1: Parallel Agent Dispatch** (Agents 1-9 work simultaneously on independent tasks)
- Agent 1: Branding (icon/splash)
- Agent 2: Store assets (screenshots/descriptions)
- Agent 3: Privacy policy
- Agent 4: Terms of service
- Agent 5: Build/signing config
- Agent 6: Permissions audit
- Agent 7: Performance polish
- Agent 8: Store listing prep
- Agent 9: Final testing

**Phase 2: Integration & Review**
- Collect all agent outputs
- Integrate changes into main codebase
- Final build & verification
- Telegram update with results

**Phase 3: User Review & Submission Prep**
- Present store listing to Tiarnan
- Get approval on branding
- Provide submission instructions

---

**Blockers to Flag:**
- Apple Developer account (if iOS needed) - SKIP iOS for now, Android first
- Hosting for privacy/terms (can use GitHub Pages)
- Store listing graphics design - will use simple/clean approach
- Content rating - will document best answers

**Workarounds:**
- No designer? Use text-based icons or simple graphics
- No hosting? Use GitHub repo as privacy policy host
- iOS later? Focus 100% on Android Play Store for now

---

*Plan created: 2026-02-07*
*Status: Ready for execution*
