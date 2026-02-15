# 🚀 Launch Checklist - Quick Reference

**Status:** 75% Complete | **Blockers:** 2 | **Time to Launch:** 3-5 days

---

## ❌ BLOCKERS (Must Fix Before Submission)

### 1. Privacy Policy URL (15 minutes)
**Required by Google Play Console**

- [ ] Host `docs/legal/privacy-policy.md` online
- [ ] Recommended: GitHub Pages (free, easy)
- [ ] Get public URL for Play Console

**Quick Setup:**
```bash
# Create GitHub repo, enable Pages, push privacy-policy.md
# URL: https://yourusername.github.io/aquarium-privacy/
```

---

### 2. High-Res App Icon 1024×1024 (10-15 minutes)
**Required by Google Play Console**

- [ ] Export existing icon at 1024×1024 resolution
- [ ] Or recreate fish + bubbles design at high-res
- [ ] Save as PNG

**Tools:** Canva, Figma, Photoshop, GIMP

---

## ⚠️ HIGHLY RECOMMENDED (2-3 Hours Before Launch)

### 3. Build & Test Release AAB (15 minutes)
- [ ] Run build from Windows PowerShell (NOT WSL — too slow)
- [ ] Command: `flutter build appbundle --release`
- [ ] Verify: `build/app/outputs/bundle/release/app-release.aab` exists
- [ ] Test install on real device
- [ ] Check: app launches, no crashes, core features work

---

### 4. Add Crash Reporting - Sentry (30-45 minutes)
**You won't know if app is crashing without this!**

- [ ] Create free Sentry account: https://sentry.io/signup/
- [ ] Add `sentry_flutter: ^7.14.0` to pubspec.yaml
- [ ] Initialize in main.dart
- [ ] Update privacy policy to mention crash reporting
- [ ] Test with intentional crash

**Why:** Know when app breaks in production

---

### 5. Create Feature Graphic 1024×500 (20-30 minutes)
**Not required but HIGHLY recommended for store visibility**

- [ ] Design banner with app icon + tagline
- [ ] Text ideas: "Track your tanks like a pro" or "Private. Local. Powerful."
- [ ] Export as PNG, exactly 1024×500 pixels

**Tools:** Canva (has Play Store templates)

---

### 6. Complete Content Rating (5 minutes)
**Submit in Google Play Console**

Answer questionnaire:
- Violence: No
- Sexual content: No
- Profanity: No
- User interaction: No
- Location: No
- Personal info: No

**Expected Rating:** EVERYONE or EVERYONE 3+

---

## ✅ ALREADY COMPLETE

- ✅ **App Icon** — All densities (mdpi → xxxhdpi)
- ✅ **Adaptive Icon** — Android 8+ support
- ✅ **Splash Screen** — Branded light blue
- ✅ **App Name** — "Aquarium Hobbyist"
- ✅ **Screenshots** — 7 high-quality captures
- ✅ **Privacy Policy** — Comprehensive, well-written (just needs URL)
- ✅ **Terms of Service** — Complete, in-app screens
- ✅ **Permissions** — Minimal, justified, best-in-class
- ✅ **Store Copy** — Short/full descriptions, ASO keywords
- ✅ **Release Keystore** — Generated, configured, **BACKUP THIS!**
- ✅ **Signing Config** — build.gradle.kts configured
- ✅ **ProGuard Rules** — Minification enabled
- ✅ **COPPA Compliant** — No data collection
- ✅ **GDPR Compliant** — Local-only storage

---

## 🚦 LAUNCH TIMELINE

### TODAY (30 min - Remove Blockers)
1. Host privacy policy → get URL
2. Create high-res icon 1024×1024

**Output:** Can now submit to Play Console ✅

---

### DAY 1 (2 hours - Add Safety Net)
3. Build release AAB from Windows
4. Test on real device
5. Add Sentry crash reporting
6. Update privacy policy

**Output:** Production-ready build with monitoring ✅

---

### DAY 1-2 (30 min - Polish)
7. Create feature graphic
8. Review all store listing content

**Output:** Maximum store visibility ✅

---

### DAY 2 (30 min - Internal Testing)
9. Create app in Play Console
10. Upload store listing (copy, screenshots, graphics)
11. Complete content rating
12. Upload AAB to internal testing track
13. Invite 3-5 testers

**Output:** App in testing ✅

---

### DAY 2-4 (Testing Period)
14. Monitor Sentry for crashes
15. Collect tester feedback
16. Fix critical issues if found
17. Update AAB if needed

**Output:** Verified stable build ✅

---

### DAY 5 (15 min - Production Launch!)
18. Promote to production track
19. Final review of listing
20. Submit for Google review
21. Wait 1-3 days for approval

**Output:** App live on Play Store! 🎉

---

## 🔒 CRITICAL SECURITY REMINDER

**⚠️ BACKUP THESE FILES NOW:**

1. `android/app/aquarium-release.jks` (keystore)
2. `android/key.properties` (passwords)
3. Root: `KEYSTORE_INFO.txt` (details)

**Why:** If you lose these, you CANNOT update your app. Ever.

**Backup to 2+ locations:**
- [ ] Encrypted cloud (Google Drive, Dropbox)
- [ ] External hard drive
- [ ] Password manager (secure note)

**Test:** Can you access backups from different device?

---

## 📊 WHAT'S NOT NEEDED (Yet)

**Skip for v1.0, consider for v1.1+:**

- ❌ Firebase Analytics (conflicts with privacy-first positioning)
- ❌ Localization (English-only is fine)
- ❌ Promo video (optional, can add later)
- ❌ Beta testing program (internal testing is enough)
- ❌ App bundle optimization (current size is acceptable)

**Ship v1.0, iterate based on real user feedback!**

---

## 🎯 GO/NO-GO CRITERIA

**Can submit when ALL are checked:**

- [ ] Privacy policy URL (public, accessible)
- [ ] High-res icon 1024×1024 (uploaded to console)
- [ ] Release AAB built & tested (no crashes)
- [ ] Crash reporting added (Sentry initialized)
- [ ] Feature graphic created (1024×500)
- [ ] Content rating submitted (in console)
- [ ] Keystore files backed up (2+ locations)
- [ ] Store listing complete (all fields filled)

**All checked?** → ✅ READY TO SUBMIT!

---

## 📞 NEED HELP?

**Full Details:** See `LAUNCH_READINESS_AUDIT.md` (comprehensive report)

**Key Docs:**
- Privacy policy: `docs/legal/privacy-policy.md`
- Store copy: `docs/completed/PLAY_STORE_LAUNCH_COMPLETE.md`
- Screenshots: `docs/testing/screenshots/`
- Build guide: `docs/completed/PLAY_STORE_LAUNCH_COMPLETE.md`

**Contact:** tiarnan.larkin@gmail.com

---

## 📈 SUCCESS TARGETS (Post-Launch)

After 30 days, aim for:
- ⭐ 4.0+ rating
- 📊 >90% crash-free rate
- 🔄 >40% Day 7 retention
- 📉 <20% Day 1 uninstall rate

**You've got this! 🚀🐠**

---

*Last Updated: February 15, 2026*  
*See LAUNCH_READINESS_AUDIT.md for complete details*
